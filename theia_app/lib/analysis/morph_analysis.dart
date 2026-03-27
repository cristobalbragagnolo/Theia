// lib/analysis/morph_analysis.dart
// Lógica GPA/PCA validada contra geomorph (R) – versión GTP:
// ignore_for_file: non_constant_identifier_names
// - GPA: centrado + CS=1 + rotación Kabsch (SVD 2×2) y al final swap X<->Y.
// - PCA: X aplanado intercalado [x1,y1,...], centrado por columna,
//        cov = Xc^T Xc / (N-1), eigen por power iteration + deflación.
// Con cheques defensivos para evitar "type 'Null' is not a subtype of type 'Matrix'".
//
// Mantiene nombres públicos usados por la app:
//   - flattenShape, unflattenShape
//   - centroid, centroidSize, centerAndScale
//   - runGPA(List<Matrix>)
//   - runPCA(List<Matrix> alignedShapes, {int k=3})
//
// Requiere: ml_linalg: ^13.12.6

import 'dart:math' as math;
import 'package:ml_linalg/linalg.dart';

class MorphometricAnalysis {
  // ===========================
  // UTIL: Matrix (p x 2) -> Vector (2p) intercalado [x1,y1,x2,y2,...]
  // ===========================
  static Vector flattenShape(Matrix shape) {
    final p = shape.rowCount;
    final flat = List<double>.filled(p * 2, 0.0);
    var t = 0;
    for (var r = 0; r < p; r++) {
      flat[t++] = shape[r][0];
      flat[t++] = shape[r][1];
    }
    return Vector.fromList(flat);
  }

  // Inverso: Vector [x1,y1,x2,y2,...] -> Matrix (p x 2)
  static Matrix unflattenShape(Vector v) {
    final p = v.length ~/ 2;
    final out = <Vector>[];
    for (var i = 0; i < p; i++) {
      out.add(Vector.fromList([v[2 * i], v[2 * i + 1]]));
    }
    return Matrix.fromRows(out);
  }

  // ===========================
  // Centroid y centroid size
  // ===========================
  static Vector centroid(Matrix shape) {
    final cx = _columnMean(shape, 0);
    final cy = _columnMean(shape, 1);
    return Vector.fromList([cx, cy]);
  }

  static double centroidSize(Matrix shape) {
    final c = centroid(shape);
    var s = 0.0;
    for (var r = 0; r < shape.rowCount; r++) {
      final dx = shape[r][0] - c[0];
      final dy = shape[r][1] - c[1];
      s += dx * dx + dy * dy;
    }
    return math.sqrt(s);
  }

  static double _columnMean(Matrix m, int col) {
    var s = 0.0;
    for (var r = 0; r < m.rowCount; r++) {
      s += m[r][col];
    }
    return s / m.rowCount;
  }

  // ===========================
  // Centrar y (opcional) escalar a CS=1
  // ===========================
  static Matrix centerAndScale(Matrix shape, {bool scale = true}) {
    final c = centroid(shape);
    final cs = centroidSize(shape);
    final rows = <Vector>[];
    for (var r = 0; r < shape.rowCount; r++) {
      var x = shape[r][0] - c[0];
      var y = shape[r][1] - c[1];
      if (scale && cs > 0) {
        x /= cs;
        y /= cs;
      }
      rows.add(Vector.fromList([x, y]));
    }
    return Matrix.fromRows(rows);
  }

  // ===========================
  // SVD 2x2 (para Kabsch)
  // ===========================
  static Map<String, Matrix> _svd2x2(Matrix A) {
    assert(A.rowCount == 2 && A.columnCount == 2);
    final ATA = A.transpose() * A;
    final a = ATA[0][0];
    final b = ATA[0][1];
    final d = ATA[1][1];
    final tr = a + d;
    final det = a * d - b * b;
    final disc = math.max(0.0, tr * tr - 4 * det);
    final sqrtDisc = math.sqrt(disc);
    final lambda1 = (tr + sqrtDisc) / 2.0;
    final lambda2 = (tr - sqrtDisc) / 2.0;
    final s1 = lambda1 > 0 ? math.sqrt(lambda1) : 0.0;
    final s2 = lambda2 > 0 ? math.sqrt(lambda2) : 0.0;

    // Eigenvector dominante de ATA
    List<double> v1;
    if (b.abs() > 1e-14 || (a - lambda1).abs() > 1e-14) {
      v1 = [b, lambda1 - a];
    } else {
      v1 = [1.0, 0.0];
    }
    final nrm1 = math.sqrt(v1[0] * v1[0] + v1[1] * v1[1]);
    v1 = [v1[0] / (nrm1 == 0 ? 1 : nrm1), v1[1] / (nrm1 == 0 ? 1 : nrm1)];
    final v2 = [-v1[1], v1[0]];
    final V = Matrix.fromColumns([Vector.fromList(v1), Vector.fromList(v2)]);

    final S = Matrix.diagonal([s1, s2]);

    final inv1 = (s1.abs() < 1e-14) ? 0.0 : 1.0 / s1;
    final inv2 = (s2.abs() < 1e-14) ? 0.0 : 1.0 / s2;
    final Sinv = Matrix.diagonal([inv1, inv2]);

    // U = A * V * S^{-1}
    final U = A * V * Sinv;

    return {'U': U, 'S': S, 'V': V};
  }

  // Rotación Kabsch (sin escala) entre target y reference (ambas centradas/CS=1)
  static Matrix _rotationKabsch(Matrix targetCentered, Matrix referenceCentered) {
    final C = targetCentered.transpose() * referenceCentered; // 2x2
    final svd = _svd2x2(C);
    final U = svd['U']!;
    final V = svd['V']!;
    // R = U * diag(1, det(UV^T)) * V^T
    final UVt = U * V.transpose();
    final detUVt = (UVt[0][0] * UVt[1][1] - UVt[0][1] * UVt[1][0]);
    final diag = Matrix.diagonal([1.0, detUVt >= 0 ? 1.0 : -1.0]);
    final R = U * diag * V.transpose();
    return R;
  }

  // ===========================
  // GPA (GTP): centrado+CS=1, Kabsch iterativo, swap X<->Y al final
  // Con cheques defensivos para evitar Nulls/matrices inválidas
  // ===========================
  static List<Matrix> runGPA(List<Matrix> shapes, {int maxIter = 10, double tol = 1e-9}) {
    // --- Chequeo defensivo de entrada ---
    if (shapes.isEmpty) {
      throw ArgumentError('runGPA: lista de formas vacía.');
    }
    for (var i = 0; i < shapes.length; i++) {
      final s = shapes[i];
      // forzamos acceso para capturar nulos/matrices inválidas cuanto antes
      try {
        final rc = s.rowCount;
        final cc = s.columnCount;
        if (cc != 2) {
          throw StateError('runGPA: la forma #$i no tiene 2 columnas (tiene $cc).');
        }
        if (rc <= 0) {
          throw StateError('runGPA: la forma #$i no tiene filas.');
        }
      } catch (e) {
        // Si s es null o no es Matrix, caerá aquí.
        throw StateError('runGPA: la forma #$i es null o no es Matrix(p×2). Detalle: $e');
      }
    }

    // 1) Pre: centrar + CS=1
    final pre = shapes.map((s) => centerAndScale(s, scale: true)).toList();
    var aligned = List<Matrix>.from(pre);

    // 2) Iteraciones: alinear contra la media normalizada
    for (var it = 0; it < maxIter; it++) {
      final mean = _calculateMeanShape(aligned);
      final ref = centerAndScale(mean, scale: true);

      var maxDelta = 0.0;
      final newAligned = <Matrix>[];

      for (final s in aligned) {
        final R = _rotationKabsch(s, ref);
        final rot = s * R;
        newAligned.add(rot);
        maxDelta = math.max(maxDelta, _froNormDiff(rot, s));
      }

      aligned = newAligned;
      if (maxDelta < tol) break;
    }

    // 3) Convención geomorph: X<->Y
    final swapped = aligned.map(_swapXY).toList();
    return swapped;
  }

  static Matrix _swapXY(Matrix shape) {
    final rows = <Vector>[];
    for (var r = 0; r < shape.rowCount; r++) {
      rows.add(Vector.fromList([shape[r][1], shape[r][0]]));
    }
    return Matrix.fromRows(rows);
  }

  static double _froNormDiff(Matrix a, Matrix b) {
    var s = 0.0;
    for (var i = 0; i < a.rowCount; i++) {
      for (var j = 0; j < a.columnCount; j++) {
        final d = a[i][j] - b[i][j];
        s += d * d;
      }
    }
    return math.sqrt(s);
  }

  static Matrix _calculateMeanShape(List<Matrix> shapes) {
    final p = shapes.first.rowCount;
    final acc = List.generate(p, (_) => List<double>.filled(2, 0.0));
    for (final s in shapes) {
      for (var i = 0; i < p; i++) {
        acc[i][0] += s[i][0];
        acc[i][1] += s[i][1];
      }
    }
    final n = shapes.length.toDouble();
    final rows = <Vector>[];
    for (var i = 0; i < p; i++) {
      rows.add(Vector.fromList([acc[i][0] / n, acc[i][1] / n]));
    }
    return Matrix.fromRows(rows);
  }

  // ===========================
  // PCA (EVD simétrica: power iteration + deflación)
  // Con cheques defensivos
  // ===========================
  static Map<String, dynamic> runPCA(List<Matrix> alignedShapes, {int k = 3}) {
    if (alignedShapes.isEmpty) {
      throw ArgumentError('runPCA: lista de formas vacía.');
    }
    // validar cada forma
    for (var i = 0; i < alignedShapes.length; i++) {
      final s = alignedShapes[i];
      try {
        final rc = s.rowCount;
        final cc = s.columnCount;
        if (cc != 2) {
          throw StateError('runPCA: la forma #$i no tiene 2 columnas (tiene $cc).');
        }
        if (rc <= 0) {
          throw StateError('runPCA: la forma #$i no tiene filas.');
        }
      } catch (e) {
        throw StateError('runPCA: la forma #$i es null o no es Matrix(p×2). Detalle: $e');
      }
    }



    // 1) X (N x D), D = 2*p, intercalado [x1,y1,x2,y2,...]
    final Xrows = <Vector>[];
    for (final m in alignedShapes) {
      Xrows.add(flattenShape(m));
    }
    final X = Matrix.fromRows(Xrows); // N x D
    final N = X.rowCount;
    final D = X.columnCount;

    // 2) Media por columna (D)
    final meanList = List<double>.filled(D, 0.0);
    for (var c = 0; c < D; c++) {
      var s = 0.0;
      for (var r = 0; r < N; r++) {
        s += X[r][c];
      }
      meanList[c] = s / N;
    }
    final meanVec = Vector.fromList(meanList);

    // 3) Centrar X -> Xc
    final centeredRows = <Vector>[];
    for (var r = 0; r < N; r++) {
      final rowVals = List<double>.filled(D, 0.0);
      for (var c = 0; c < D; c++) {
        rowVals[c] = X[r][c] - meanList[c];
      }
      centeredRows.add(Vector.fromList(rowVals));
    }
    final Xc = Matrix.fromRows(centeredRows); // N x D

    // 4) Covarianza (D x D) = Xc^T * Xc / (N-1)
    final cov = (Xc.transpose() * Xc) * (1.0 / (N - 1));

    // 5) Eigen top-k (matriz simétrica)
    final evd = _symmetricTopKEigen(cov, k: k, maxIter: 2000, tol: 1e-11);
    final eigenVectors = evd['vectors'] as Matrix; // D x k
    final eigenValues = evd['values'] as List<double>; // k
    final trace = _traceOf(cov);
    final evr = eigenValues.map((e) => e / (trace == 0 ? 1.0 : trace)).toList();

    // 6) Scores (N x k) = Xc * V
    final scores = Xc * eigenVectors;

    return {
      'scores': scores,
      'mean': meanVec,
      'pcs': eigenVectors,
      'eigenvalues': Vector.fromList(eigenValues),
      'varianceExplained': Vector.fromList(eigenValues), // crudo
      'varianceExplainedRatio': Vector.fromList(evr),    // % (suma ~ 1.0)
    };
  }

  // ------- Helpers numéricos para PCA -------
  static double _traceOf(Matrix m) {
    final d = math.min(m.rowCount, m.columnCount);
    var s = 0.0;
    for (var i = 0; i < d; i++) {
      s += m[i][i];
    }
    return s;
  }

  static Map<String, dynamic> _symmetricTopKEigen(Matrix cov,
      {required int k, int maxIter = 1000, double tol = 1e-9}) {
    final d = cov.rowCount;
    final kk = math.min(k, d);

    // Copia de cov a lista 2D para deflación
    final A = List.generate(
      d,
      (i) => List<double>.generate(d, (j) => cov[i][j], growable: false),
      growable: false,
    );

    final vectors = List.generate(d, (_) => List<double>.filled(kk, 0.0));
    final values = List<double>.filled(kk, 0.0);

    for (var comp = 0; comp < kk; comp++) {
      // v inicial
      var v = List<double>.filled(d, 1.0 / math.sqrt(d));

      // Power iteration
      for (var it = 0; it < maxIter; it++) {
        final Av = _matVec(A, v);
        final nrm = _vecNorm(Av);
        if (nrm == 0) break;
        final vNew = Av.map((e) => e / nrm).toList();

        // Convergencia
        final diff = _diffNorm(vNew, v);
        v = vNew;
        if (diff < tol) break;
      }

      // Eigenvalue de Rayleigh
      final Av = _matVec(A, v);
      final lambda = _dot(v, Av);

      // Guardar vector (columna) y valor
      for (var i = 0; i < d; i++) {
        vectors[i][comp] = v[i];
      }
      values[comp] = lambda;

      // Deflación: A := A - lambda * v * v^T
      for (var i = 0; i < d; i++) {
        final vi = v[i];
        for (var j = 0; j < d; j++) {
          A[i][j] -= lambda * vi * v[j];
        }
      }
    }

    // Empaquetar en Matrix columnas
    final cols = <Vector>[];
    for (var c = 0; c < kk; c++) {
      final col = List<double>.filled(d, 0.0);
      for (var r = 0; r < d; r++) {
        col[r] = vectors[r][c];
      }
      cols.add(Vector.fromList(col));
    }

    return {
      'vectors': Matrix.fromColumns(cols), // D x k
      'values': values,                    // List<double> (k)
    };
  }

  static List<double> _matVec(List<List<double>> A, List<double> v) {
    final n = A.length;
    final out = List<double>.filled(n, 0.0);
    for (var i = 0; i < n; i++) {
      var s = 0.0;
      final row = A[i];
      for (var j = 0; j < v.length; j++) {
        s += row[j] * v[j];
      }
      out[i] = s;
    }
    return out;
  }

  static double _dot(List<double> a, List<double> b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  static double _vecNorm(List<double> v) => math.sqrt(_dot(v, v));

  static double _diffNorm(List<double> a, List<double> b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      final d = a[i] - b[i];
      s += d * d;
    }
    return math.sqrt(s);
  }
}
