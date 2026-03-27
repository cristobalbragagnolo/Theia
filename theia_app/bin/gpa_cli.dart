// bin/gpa_cli.dart
// ignore_for_file: avoid_print, non_constant_identifier_names
//
// Runner CLI para GPA+PCA fuera de la app, comparando Dart (lógica GTP) vs R (CSV ref).
// Cambios claves:
//  - PCA propio: covarianza + eigen (power iteration simétrica + deflación).
//  - Flatten intercalado [x1,y1,x2,y2,...] (emula Python/R).
//  - Scores = Xc * V; EVR = lambda_i / sum(lambda).
//  - Flip de signo PC-a-PC (1↔1, 2↔2, 3↔3).
//  - Orden salida: GPA → PCA → Varianza.
//
// Uso:
//   dart run bin/gpa_cli.dart --k=3 --head=10 --verbose /ruta/landmarks.csv
// Si en la misma carpeta hay ref_pca.csv, ref_var.csv, ref_mean.csv, los autodetecta.

import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  int k = 3;
  int head = 10;
  bool verbose = false;
  String? refPcaPath, refVarPath, refMeanPath, csvPath;

  for (final a in args) {
    if (a.startsWith('--k=')) {
      k = int.tryParse(a.substring(4)) ?? 3;
    } else if (a.startsWith('--head=')) {
      head = int.tryParse(a.substring(7)) ?? 10;
    } else if (a == '--verbose') {
      verbose = true;
    } else if (a.startsWith('--ref-pca=')) {
      refPcaPath = a.substring('--ref-pca='.length);
    } else if (a.startsWith('--ref-var=')) {
      refVarPath = a.substring('--ref-var='.length);
    } else if (a.startsWith('--ref-mean=')) {
      refMeanPath = a.substring('--ref-mean='.length);
    } else if (!a.startsWith('--')) {
      csvPath = a;
    }
  }

  if (csvPath == null) {
    stderr.writeln('USO: dart run bin/gpa_cli.dart [opciones] /ruta/landmarks.csv');
    stderr.writeln('Opciones: --k=3  --head=10  --verbose');
    stderr.writeln('          --ref-pca=...  --ref-var=...  --ref-mean=...');
    exit(64);
  }

  if (verbose) {
    print('RAW args: ${args.join(' ')}');
    print('Posicionales detectados: $csvPath');
  }

  // Auto-discovery de refs si faltan
  if (refPcaPath == null || refVarPath == null || refMeanPath == null) {
    final dir = p.dirname(csvPath);
    final candP = p.join(dir, 'ref_pca.csv');
    final candV = p.join(dir, 'ref_var.csv');
    final candM = p.join(dir, 'ref_mean.csv');
    if (refPcaPath == null && File(candP).existsSync()) refPcaPath = candP;
    if (refVarPath == null && File(candV).existsSync()) refVarPath = candV;
    if (refMeanPath == null && File(candM).existsSync()) refMeanPath = candM;
  }

  if (verbose) {
    print('ARGS detectados:'
        '\n  k=$k, head=$head, verbose=$verbose'
        '\n  refPca=${refPcaPath ?? '-'}'
        '\n  refVar=${refVarPath ?? '-'}'
        '\n  refMean=${refMeanPath ?? '-'}'
        '\n  csv=$csvPath');
  }

  // ===== Carga landmarks =====
  final lm = await _loadLandmarksCsv(csvPath);
  final imageNames = lm.imageNames;
  final shapes = lm.shapes;
  final n = shapes.length;
  final pnt = shapes.first.rowCount;
  final dims = shapes.first.columnCount;
  print('Cargados $n especímenes, $pnt landmarks, ${dims}D.');

  // ===== GPA (GTP con swap XY final para alinear con R) =====
  final aligned = _runGpaGtp(shapes);
  final meanShapeGtp = _meanShape(aligned);

  // Mean R (opcional)
  Matrix? meanR;
  if (refMeanPath != null && File(refMeanPath).existsSync()) {
    meanR = await _readMeanRefSmart(refMeanPath);
  }

  // ===== PCA (nuevo EVD) =====
  final pca = _runPcaFromAligned_EVD(aligned, k: k, verbose: verbose);

  // ===== COMPARACIÓN (orden: GPA → PCA → Varianza) =====
  print('\n================ COMPARACIÓN R vs Dart ================');

  // --- 1) GPA ---
  if (meanR != null &&
      meanR.rowCount == meanShapeGtp.rowCount &&
      meanR.columnCount == meanShapeGtp.columnCount) {
    print('\n--- GPA: Forma media (R vs Dart) ---');
    _printGpaHead(meanR, meanShapeGtp, head);
    final cx = _corr(_col(meanR, 0), _col(meanShapeGtp, 0));
    final cy = _corr(_col(meanR, 1), _col(meanShapeGtp, 1));
    final rms = _rms(meanR, meanShapeGtp);
    print('\nCorrelación GPA:  X=${cx.toStringAsFixed(6)}   Y=${cy.toStringAsFixed(6)}   |   RMS=${rms.toStringAsFixed(6)}');
  } else {
    print('\n--- GPA: (sin ref_mean.csv válido para comparar) ---');
  }

  // --- 2) PCA ---
  if (refPcaPath != null && File(refPcaPath).existsSync()) {
    final rPca = await _readPcaRef(refPcaPath, imageNames);
    if (rPca != null) {
      // Flip signo PC a PC (1→1, 2→2, 3→3) por correlación
      final signs = <double>[];
      final colsCmp = min(3, min(rPca.scores.columnCount, pca.scores.columnCount));
      for (var j = 0; j < colsCmp; j++) {
        final c = _corr(_col(rPca.scores, j), _col(pca.scores, j));
        signs.add((c.isNaN || c >= 0) ? 1.0 : -1.0);
      }
      final scoresAdj = _applySignsToScores(pca.scores, signs);

      // Tabla lado a lado (head)
      final h = min(head, min(rPca.scores.rowCount, scoresAdj.rowCount));
      print('\n--- PCA (tabla head lado a lado, PY con signo alineado) ---');
      const colW = 12;
      final hdr = <String>[
        'Specimen'.padRight(30),
        for (var i = 0; i < colsCmp; i++) 'R_PC${i + 1}'.padLeft(colW),
        for (var i = 0; i < colsCmp; i++) 'PY_PC${i + 1}'.padLeft(colW),
      ].join('  ');
      print(hdr);
      for (var i = 0; i < h; i++) {
        final row = <String>[imageNames[i].padRight(30)];
        for (var j = 0; j < colsCmp; j++) {
          row.add(rPca.scores[i][j].toStringAsFixed(6).padLeft(colW));
        }
        for (var j = 0; j < colsCmp; j++) {
          row.add(scoresAdj[i][j].toStringAsFixed(6).padLeft(colW));
        }
        print(row.join('  '));
      }

      // Correlaciones PC1..PC3 (full y head)
      print('\n--- PCA (correlaciones R vs Dart, PC↔PC, con flip aplicado) ---');
      for (var j = 0; j < colsCmp; j++) {
        final rFull = _corr(_col(rPca.scores, j), _col(scoresAdj, j));
        final rHead = _corr(
          _col(rPca.scores, j).sublist(0, h),
          _col(scoresAdj, j).sublist(0, h),
        );
        print('PC${j + 1}:  r_full=${rFull.toStringAsFixed(8)}   r_head=${rHead.toStringAsFixed(8)}');
      }
    } else {
      print('\n--- PCA: (ref_pca.csv no legible) ---');
    }
  } else {
    print('\n--- PCA: (sin ref_pca.csv válido para comparar) ---');
  }

  // --- 3) Varianza ---
  if (refVarPath != null && File(refVarPath).existsSync()) {
    final refVar = await _readVarRef(refVarPath);
    if (refVar.isNotEmpty) {
      print('\n--- Varianza explicada (%) ---');
      final fmtR = _fmtVarList(refVar);
      final fmtD = _fmtVarList(pca.explainedVarianceRatio.toList());
      final sumR = refVar.take(3).fold<double>(0.0, (a, b) => a + b);
      final sumD = pca.explainedVarianceRatio.toList().take(3).fold<double>(0.0, (a, b) => a + b);
      print('R     : $fmtR  | SUM(top-3)≈${sumR.toStringAsFixed(2)}');
      print('Dart  : $fmtD  | SUM(top-3)≈${sumD.toStringAsFixed(2)}');

      final k3 = min(3, min(refVar.length, pca.explainedVarianceRatio.length));
      final corrVar = _corr(refVar.take(k3).toList(), pca.explainedVarianceRatio.toList().take(k3).toList());
      print('Correlación Varianza (top-3):  ${corrVar.toStringAsFixed(6)}  (nota: con 3 pts la métrica es frágil)');
    } else {
      print('\n--- Varianza: (ref_var.csv vacío) ---');
    }
  } else {
    print('\n--- Varianza: (sin ref_var.csv válido para comparar) ---');
  }
}

// ======================= CARGA LANDMARKS =======================

class _LandmarkSet {
  final List<String> imageNames;
  final List<Matrix> shapes;
  _LandmarkSet(this.imageNames, this.shapes);
}

Future<_LandmarkSet> _loadLandmarksCsv(String path) async {
  final csvStr = await File(path).readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(csvStr);
  if (rows.isEmpty) throw StateError('CSV vacío: $path');

  final headers = rows.first.map((e) => e.toString()).toList();
  final idxImage = headers.indexOf('image_name');
  if (idxImage < 0) throw StateError("El CSV debe tener columna 'image_name'");

  final imageNames = <String>[];
  final shapes = <Matrix>[];

  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    if (row.isEmpty) continue;

    imageNames.add(row[idxImage].toString());

    // Toma todas las columnas numéricas post image_name:
    final vals = <double>[];
    for (var j = 0; j < headers.length; j++) {
      if (j == idxImage) continue;
      final v = (j < row.length) ? row[j] : null;
      final d = (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '');
      vals.add(d ?? double.nan);
    }

    final p = vals.length ~/ 2;
    final rowsM = <Vector>[];
    for (var i = 0; i < p; i++) {
      final x = vals[2 * i];
      final y = vals[2 * i + 1];
      rowsM.add(Vector.fromList([x, y]));
    }
    shapes.add(Matrix.fromRows(rowsM));
  }

  return _LandmarkSet(imageNames, shapes);
}

// =========================== GPA (GTP) ===========================

List<Matrix> _runGpaGtp(List<Matrix> shapes, {int maxIter = 10, double tol = 1e-10}) {
  final pre = shapes.map((s) => _centerAndScale(s, scale: true)).toList();
  var aligned = List<Matrix>.from(pre);
  var mean = _centerAndScale(_meanShape(aligned), scale: true);

  for (var it = 0; it < maxIter; it++) {
    final next = <Matrix>[];
    for (final s in aligned) {
      final R = _rotationKabsch(s, mean);
      next.add(s * R);
    }
    final newMean = _meanShape(next);
    final ref = _centerAndScale(newMean, scale: true);
    final diff = _squaredFrob(newMean - mean);
    aligned = next;
    mean = ref;
    if (diff < tol) break;
  }

  // FIX GTP para alinear con R: intercambiar X<->Y
  aligned = aligned.map(_swapXY).toList();
  return aligned;
}

Matrix _swapXY(Matrix m) {
  final xs = m.getColumn(0);
  final ys = m.getColumn(1);
  return Matrix.fromColumns([ys, xs]);
}

Matrix _centerAndScale(Matrix shape, {bool scale = true}) {
  final c = _centroid(shape);
  final rows = <Vector>[];
  for (var r = 0; r < shape.rowCount; r++) {
    rows.add(Vector.fromList([shape[r][0] - c[0], shape[r][1] - c[1]]));
  }
  var centered = Matrix.fromRows(rows);
  if (scale) {
    final cs = _centroidSize(centered);
    if (cs > 0) centered = centered * (1.0 / cs);
  }
  return centered;
}

Vector _centroid(Matrix shape) {
  var sx = 0.0, sy = 0.0;
  for (var i = 0; i < shape.rowCount; i++) {
    sx += shape[i][0]; sy += shape[i][1];
  }
  final n = shape.rowCount.toDouble();
  return Vector.fromList([sx / n, sy / n]);
}

double _centroidSize(Matrix shape) {
  final c = _centroid(shape);
  var s = 0.0;
  for (var i = 0; i < shape.rowCount; i++) {
    final dx = shape[i][0] - c[0];
    final dy = shape[i][1] - c[1];
    s += dx * dx + dy * dy;
  }
  return sqrt(s);
}

Matrix _meanShape(List<Matrix> shapes) {
  final p = shapes.first.rowCount;
  final acc = List.generate(p, (_) => [0.0, 0.0]);
  for (final m in shapes) {
    for (var i = 0; i < p; i++) {
      acc[i][0] += m[i][0];
      acc[i][1] += m[i][1];
    }
  }
  final n = shapes.length.toDouble();
  for (var i = 0; i < p; i++) {
    acc[i][0] /= n;
    acc[i][1] /= n;
  }
  return Matrix.fromRows(acc.map((r) => Vector.fromList(r)).toList());
}

double _squaredFrob(Matrix m) {
  var s = 0.0;
  for (var i = 0; i < m.rowCount; i++) {
    for (var j = 0; j < m.columnCount; j++) {
      s += m[i][j] * m[i][j];
    }
  }
  return s;
}

Matrix _rotationKabsch(Matrix target, Matrix reference) {
  final C = target.transpose() * reference;
  final svd = _svd2x2(C);
  final U = svd['U']!;
  final V = svd['V']!;
  var R = U * V.transpose();
  final detR = R[0][0] * R[1][1] - R[0][1] * R[1][0];
  if (detR < 0) {
    final u0 = U.getColumn(0);
    final u1 = U.getColumn(1) * -1.0;
    final Ucorr = Matrix.fromColumns([u0, u1]);
    R = Ucorr * V.transpose();
  }
  return R;
}

Map<String, Matrix> _svd2x2(Matrix C) {
  final a = C[0][0], b = C[0][1], c = C[1][0], d = C[1][1];
  final ata00 = a * a + c * c;
  final ata01 = a * b + c * d;
  final ata11 = b * b + d * d;
  final tr = ata00 + ata11;
  final det = ata00 * ata11 - ata01 * ata01;
  final disc = max(0.0, tr * tr - 4.0 * det);
  final root = sqrt(disc);
  final l1 = (tr + root) / 2.0;
  final l2 = (tr - root) / 2.0;
  final s1 = l1 > 0 ? sqrt(l1) : 0.0;
  final s2 = l2 > 0 ? sqrt(l2) : 0.0;

  List<double> v1;
  if (ata01.abs() > 1e-12 || (ata00 - l1).abs() > 1e-12) {
    v1 = [ata01, l1 - ata00];
  } else {
    v1 = [1.0, 0.0];
  }
  final n1 = sqrt(v1[0] * v1[0] + v1[1] * v1[1]);
  v1 = [v1[0] / n1, v1[1] / n1];
  final v2 = [-v1[1], v1[0]];
  final V = Matrix.fromColumns([Vector.fromList(v1), Vector.fromList(v2)]);

  final invS1 = s1.abs() < 1e-12 ? 0.0 : 1.0 / s1;
  final invS2 = s2.abs() < 1e-12 ? 0.0 : 1.0 / s2;
  final Sinv = Matrix.fromRows([
    Vector.fromList([invS1, 0.0]),
    Vector.fromList([0.0, invS2]),
  ]);
  final U = C * V * Sinv;
  return {'U': U, 'V': V};
}

// =========================== PCA (EVD) ===========================

class _PcaResult {
  final Matrix scores; // (n x k)
  final List<double> explainedVariance; // lambdas
  final List<double> explainedVarianceRatio; // %
  _PcaResult(this.scores, this.explainedVariance, this.explainedVarianceRatio);
}

// PCA con covarianza y eigen simétrica por power iteration + deflación.
// Flatten INTERCALADO [x1,y1,x2,y2,...] para emular Python/R.
_PcaResult _runPcaFromAligned_EVD(List<Matrix> aligned, {int k = 3, bool verbose = false}) {
  final n = aligned.length;
  final p = aligned.first.rowCount;
  final d = p * 2;

  // X (n x d)
  final rows = <Vector>[];
  for (final m in aligned) {
    rows.add(_flattenInterleaved(m));
  }
  final X = Matrix.fromRows(rows);

  // centrar por columnas
  final mu = _colMean(X);
  final Xc = _subtractMean(X, mu);

  // cov (d x d)
  final cov = (Xc.transpose() * Xc) * (1.0 / (n - 1));

  // EVD simétrico (top-k)
  final covArr = _toArray(cov);
  final evd = _symmetricTopKEigen(covArr, k: min(k, d), maxIter: 500, tol: 1e-10);
  final lambdas = evd.$1; // desc
  final vecs = evd.$2;    // columnas

  // Scores = Xc * V
  final pcs = Matrix.fromColumns(vecs.map((v) => Vector.fromList(v)).toList());
  final scores = Xc * pcs;

  // EVR (%)
  double trace = 0.0;
  for (var i = 0; i < d; i++) {
    trace += covArr[i][i];
  }
  final ratios = (trace > 0)
      ? lambdas.map((l) => 100.0 * l / trace).toList()
      : List<double>.filled(lambdas.length, 0.0);

  if (verbose) {
    final sumTop = ratios.fold<double>(0.0, (a, b) => a + b);
    print('DEBUG: scores=${scores.rowCount}x${scores.columnCount}, meanShape=${p}x2');
    print('DEBUG: evrSum(%) ~ ${sumTop.toStringAsFixed(6)}');
  }

  return _PcaResult(scores, lambdas, ratios);
}

Vector _flattenInterleaved(Matrix m) {
  final p = m.rowCount;
  final out = List<double>.filled(p * 2, 0.0);
  for (var i = 0; i < p; i++) {
    out[2 * i] = m[i][0];
    out[2 * i + 1] = m[i][1];
  }
  return Vector.fromList(out);
}

Vector _colMean(Matrix X) {
  final r = X.rowCount, c = X.columnCount;
  final sums = List<double>.filled(c, 0.0);
  for (var i = 0; i < r; i++) {
    for (var j = 0; j < c; j++) {
      sums[j] += X[i][j];
    }
  }
  return Vector.fromList(sums.map((s) => s / r).toList());
}

Matrix _subtractMean(Matrix X, Vector mu) {
  final r = X.rowCount, c = X.columnCount;
  final rows = <Vector>[];
  for (var i = 0; i < r; i++) {
    final row = List<double>.generate(c, (j) => X[i][j] - mu[j]);
    rows.add(Vector.fromList(row));
  }
  return Matrix.fromRows(rows);
}

List<List<double>> _toArray(Matrix M) {
  final out = List.generate(M.rowCount, (_) => List<double>.filled(M.columnCount, 0.0));
  for (var i = 0; i < M.rowCount; i++) {
    for (var j = 0; j < M.columnCount; j++) {
      out[i][j] = M[i][j];
    }
  }
  return out;
}

// Power iteration simétrica + deflación (top-k eigenpairs, descendente).
(List<double>, List<List<double>>) _symmetricTopKEigen(
  List<List<double>> A, {
  required int k,
  int maxIter = 1000,
  double tol = 1e-10,
}) {
  final n = A.length;
  final B = List.generate(n, (i) => List<double>.from(A[i]));
  final lambdas = <double>[];
  final vecs = <List<double>>[];

  for (var comp = 0; comp < k; comp++) {
    // vector inicial
    var v = List<double>.generate(n, (i) => 1.0 / sqrt(n));
    double lambdaOld = 0.0;

    for (var it = 0; it < maxIter; it++) {
      final Av = _mulMatVec(B, v);
      final norm = _norm2(Av);
      if (norm == 0.0) break;
      final vNew = Av.map((e) => e / norm).toList();
      final lambda = _dot(vNew, _mulMatVec(B, vNew));
      final diff = _norm2(_sub(vNew, v));
      v = vNew;
      if ((lambda - lambdaOld).abs() < tol && diff < 1e-9) {
        lambdaOld = lambda;
        break;
      }
      lambdaOld = lambda;
    }

    // deflación
    _rank1Deflate(B, v, lambdaOld);
    lambdas.add(lambdaOld);
    vecs.add(v);
  }

  // ordenar descendente por lambda
  final idx = List<int>.generate(lambdas.length, (i) => i)
    ..sort((i, j) => lambdas[j].compareTo(lambdas[i]));
  final lambdasSorted = [for (final i in idx) lambdas[i]];
  final vecsSorted = [for (final i in idx) vecs[i]];

  return (lambdasSorted, vecsSorted);
}

// ========= helpers álgebra real =========

List<double> _mulMatVec(List<List<double>> A, List<double> x) {
  final n = A.length, m = A[0].length;
  final out = List<double>.filled(n, 0.0);
  for (var i = 0; i < n; i++) {
    var s = 0.0;
    for (var j = 0; j < m; j++) {
      s += A[i][j] * x[j];
    }
    out[i] = s;
  }
  return out;
}

double _dot(List<double> a, List<double> b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

double _norm2(List<double> a) => sqrt(_dot(a, a));

List<double> _sub(List<double> a, List<double> b) {
  return List<double>.generate(a.length, (i) => a[i] - b[i]);
}

void _rank1Deflate(List<List<double>> A, List<double> v, double lambda) {
  final n = A.length;
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      A[i][j] -= lambda * v[i] * v[j];
    }
  }
}

// ======================= COMPARACIÓN y util =======================

void _printGpaHead(Matrix meanR, Matrix meanDart, int head) {
  final h = min(head, min(meanR.rowCount, meanDart.rowCount));
  const colW = 12;
  print(' LM        R_X          R_Y          PY_X         PY_Y');
  for (var i = 0; i < h; i++) {
    final rx = meanR[i][0].toStringAsFixed(6).padLeft(colW);
    final ry = meanR[i][1].toStringAsFixed(6).padLeft(colW);
    final dx = meanDart[i][0].toStringAsFixed(6).padLeft(colW);
    final dy = meanDart[i][1].toStringAsFixed(6).padLeft(colW);
    print('${(i + 1).toString().padLeft(3)}  $rx  $ry  $dx  $dy');
  }
}

class _RefPca {
  final Matrix scores;
  _RefPca(this.scores);
}

Future<_RefPca?> _readPcaRef(String path, List<String> imageNames) async {
  final s = await File(path).readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(s);
  if (rows.isEmpty) return null;

  final hdr = rows.first.map((e) => e.toString()).toList();
  final idxName = hdr.indexWhere((h) =>
      h.toLowerCase().contains('image') ||
      h.toLowerCase().contains('specimen') ||
      h.toLowerCase().contains('name'));

  final mapNameToRow = <String, List<double>>{};
  const startRow = 1;
  for (var r = startRow; r < rows.length; r++) {
    final row = rows[r];
    if (row.isEmpty) continue;
    final name = (idxName >= 0) ? row[idxName].toString() : imageNames[r - startRow];
    final nums = <double>[];
    for (var j = 0; j < row.length; j++) {
      if (j == idxName) continue;
      final v = row[j];
      final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
      if (d != null) nums.add(d);
    }
    mapNameToRow[name] = (nums.length > 3) ? nums.sublist(0, 3) : nums;
  }

  final data = <Vector>[];
  for (final name in imageNames) {
    final rr = mapNameToRow[name];
    final row = (rr == null) ? <double>[0.0, 0.0, 0.0] : List<double>.from(rr);
    while (row.length < 3) {
      row.add(0.0);
    }
    data.add(Vector.fromList(row));
  }
  return _RefPca(Matrix.fromRows(data));
}

Future<List<double>> _readVarRef(String path) async {
  final s = await File(path).readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(s);
  if (rows.isEmpty) return <double>[];
  final nums = <double>[];

  // Acepta 1 fila o varias, recoge todos los números en orden hasta 3
  for (var r = 0; r < rows.length; r++) {
    for (final cell in rows[r]) {
      final d = (cell is num) ? cell.toDouble() : double.tryParse(cell.toString());
      if (d != null) nums.add(d);
    }
  }
  if (nums.length > 3) nums.removeRange(3, nums.length);
  return nums;
}

// NUEVO: lector robusto para ref_mean.csv (acepta con/sin cabecera, o 3 columnas con índice)
Future<Matrix> _readMeanRefSmart(String path) async {
  final s = await File(path).readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(s);
  if (rows.isEmpty) throw StateError('ref_mean.csv vacío');

  // Detecta si primera fila es cabecera textual
  bool hasHeader = false;
  {
    bool anyNonNumeric = false;
    for (final cell in rows.first) {
      if (cell is String) {
        // si hay texto, consideramos cabecera
        anyNonNumeric = true;
        break;
      } else if (cell is! num) {
        anyNonNumeric = true;
        break;
      }
    }
    hasHeader = anyNonNumeric;
  }

  final start = hasHeader ? 1 : 0;
  final outRows = <Vector>[];

  for (var r = start; r < rows.length; r++) {
    final row = rows[r];
    if (row.isEmpty) continue;

    // Extrae todos los números de la fila
    final nums = <double>[];
    for (final cell in row) {
      final d = (cell is num) ? cell.toDouble() : double.tryParse(cell.toString());
      if (d != null) nums.add(d);
    }

    if (nums.length >= 2) {
      // Si hay 3 columnas y la primera parece índice entero (1,2,3...), usa últimas 2 como X,Y
      if (nums.length >= 3 && nums.first.roundToDouble() == nums.first) {
        final x = nums[1];
        final y = nums[2];
        outRows.add(Vector.fromList([x, y]));
      } else {
        // Sino, toma las primeras 2 como X,Y
        outRows.add(Vector.fromList([nums[0], nums[1]]));
      }
    }
  }

  if (outRows.isEmpty) {
    throw StateError('ref_mean.csv no contiene pares numéricos (X,Y) legibles');
  }
  return Matrix.fromRows(outRows);
}

// NUEVO: formato compacto de varianzas "PC1=xx.xx  PC2=yy.yy  PC3=zz.zz"
String _fmtVarList(List<double> v) {
  final k = min(3, v.length);
  final parts = <String>[];
  for (var i = 0; i < k; i++) {
    parts.add('PC${i + 1}=${v[i].toStringAsFixed(2)}');
  }
  return parts.join('  ');
}

Matrix _applySignsToScores(Matrix dScores, List<double> signs) {
  final c = dScores.columnCount;
  final cols = <Vector>[];
  for (var j = 0; j < c; j++) {
    final s = (j < signs.length) ? signs[j] : 1.0;
    cols.add(dScores.getColumn(j) * s);
  }
  return Matrix.fromColumns(cols);
}

List<double> _col(Matrix m, int j) {
  final out = <double>[];
  for (var i = 0; i < m.rowCount; i++) {
    out.add(m[i][j]);
  }
  return out;
}

double _corr(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return double.nan;
  final n = a.length;
  final ma = a.reduce((x, y) => x + y) / n;
  final mb = b.reduce((x, y) => x + y) / n;
  var sa = 0.0, sb = 0.0, s = 0.0;
  for (var i = 0; i < n; i++) {
    final da = a[i] - ma;
    final db = b[i] - mb;
    s += da * db;
    sa += da * da;
    sb += db * db;
  }
  final denom = sqrt(sa) * sqrt(sb);
  if (denom == 0) return double.nan;
  return s / denom;
}

double _rms(Matrix A, Matrix B) {
  if (A.rowCount != B.rowCount || A.columnCount != B.columnCount) return double.nan;
  var s = 0.0;
  for (var i = 0; i < A.rowCount; i++) {
    for (var j = 0; j < A.columnCount; j++) {
      final d = A[i][j] - B[i][j];
      s += d * d;
    }
  }
  return sqrt(s / (A.rowCount * A.columnCount));
}
