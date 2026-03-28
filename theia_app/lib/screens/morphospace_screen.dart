// lib/screens/morphospace_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ml_linalg/linalg.dart' hide Axis;
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/widgets/theia_toolbar_action.dart';
import 'specimen_viewer_screen.dart';

class MorphospaceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pcaScores;
  final List<Matrix> alignedShapes;
  final Matrix meanShape;

  /// Porcentajes de varianza [PC1, PC2, ...] opcionales
  final List<double>? explainedPercent;

  const MorphospaceScreen({
    super.key,
    required this.pcaScores,
    required this.alignedShapes,
    required this.meanShape,
    this.explainedPercent,
  });

  @override
  State<MorphospaceScreen> createState() => _MorphospaceScreenState();
}

class _MorphospaceScreenState extends State<MorphospaceScreen> {
  int _selectedIndex = -1;

  // ---- Scroll + keys para hacer scroll automático a la fila seleccionada
  final ScrollController _tableScroll = ScrollController();
  late List<GlobalKey> _rowKeys;

  @override
  void initState() {
    super.initState();
    _rowKeys =
        List<GlobalKey>.generate(widget.pcaScores.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant MorphospaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pcaScores.length != widget.pcaScores.length) {
      _rowKeys =
          List<GlobalKey>.generate(widget.pcaScores.length, (_) => GlobalKey());
    }
  }

  void _viewSpecimen(int index) {
    if (index < 0 || index >= widget.pcaScores.length) return;
    final l = AppLocalizations.of(context)!;
    final String name =
        widget.pcaScores[index]['image_name'] ?? l.specimenViewerSpecimen;
    final Matrix specimenShape = widget.alignedShapes[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecimenViewerScreen(
          meanShape: widget.meanShape,
          specimenShape: specimenShape,
          specimenName: name,
        ),
      ),
    );
  }

  void _scrollToRow(int index) {
    if (index < 0 || index >= _rowKeys.length) return;
    final ctx = _rowKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        alignment: 0.2, // deja algo de espacio por arriba
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Datos para el scatter
    final List<FlSpot> spots = widget.pcaScores.map((m) {
      return FlSpot((m['PC1'] as num).toDouble(), (m['PC2'] as num).toDouble());
    }).toList();

    final bounds = _axisBoundsSymmetric(spots);

    // Crear puntos, llevando el seleccionado al frente
    final scheme = Theme.of(context).colorScheme;
    final consensusColor = scheme.primary;
    final aiColor = scheme.tertiary;
    final onSurface = scheme.onSurface;
    final fadedLineColor = onSurface.withValues(alpha: 0.25);
    final axisColor = onSurface.withValues(alpha: 0.8);
    final spotsWithIndex = widget.pcaScores.asMap().entries.map((e) {
      final i = e.key;
      final m = e.value;
      final bool isSel = i == _selectedIndex;
      final bool isFaded = _selectedIndex != -1 && !isSel;
      final color = isSel
          ? consensusColor
          : (isFaded ? aiColor.withValues(alpha: 0.28) : aiColor);
      final radius = isSel ? 8.0 : 4.0;
      return ScatterSpot(
        (m['PC1'] as num).toDouble(),
        (m['PC2'] as num).toDouble(),
        dotPainter: FlDotCirclePainter(radius: radius, color: color),
      );
    }).toList();

    if (_selectedIndex != -1 && _selectedIndex < spotsWithIndex.length) {
      final sel = spotsWithIndex.removeAt(_selectedIndex);
      spotsWithIndex.add(sel); // dibuja seleccionado encima
    }

    final exp = widget.explainedPercent;
    String hdr(String base, int i) => exp != null && exp.length > i
        ? '$base (${exp[i].toStringAsFixed(1)}%)'
        : base;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(l.morphTitle),
        ),
        actions: [
          if (_selectedIndex != -1)
            TheiaToolbarAction(
              tooltip: l.morphClearSelectionTooltip,
              icon: Icons.highlight_off,
              onPressed: () => setState(() => _selectedIndex = -1),
            ),
        ],
      ),
      body: Column(
        children: [
          // ====== GRÁFICO (cuadrado) ======
          AspectRatio(
            aspectRatio: 1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: spotsWithIndex,
                  minX: bounds.minX, maxX: bounds.maxX,
                  minY: bounds.minY, maxY: bounds.maxY,
                  // Líneas BLANCAS visibles en tema oscuro
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: bounds.interval,
                    verticalInterval: bounds.interval,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: (v == 0) ? axisColor : fadedLineColor,
                      strokeWidth: (v == 0) ? 1.2 : 1.0,
                    ),
                    getDrawingVerticalLine: (v) => FlLine(
                      color: (v == 0) ? axisColor : fadedLineColor,
                      strokeWidth: (v == 0) ? 1.2 : 1.0,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: onSurface.withValues(alpha: 0.55)),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        l.morphAxisLabel,
                        style: TextStyle(color: onSurface),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: bounds.interval,
                        getTitlesWidget: (value, meta) {
                          if (value == bounds.maxX || value == bounds.minX) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(color: onSurface, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: bounds.interval,
                        getTitlesWidget: (value, meta) {
                          if (value == bounds.maxY || value == bounds.minY) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(color: onSurface, fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipItems: (spot) {
                        final idx = _indexOfPoint(spot.x, spot.y);
                        if (idx == -1) return null;
                        final name =
                            widget.pcaScores[idx]['image_name'] ?? 'N/A';
                        return ScatterTooltipItem(
                          name,
                          textStyle: TextStyle(
                              color: onSurface, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    touchCallback: (event, resp) {
                      if (resp?.touchedSpot == null) return;
                      if (event is FlTapUpEvent) {
                        final s = resp!.touchedSpot!.spot;
                        final idx = _indexOfPoint(s.x, s.y);
                        if (idx != -1) {
                          setState(() => _selectedIndex = idx); // selecciona
                          // hace scroll a la fila
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _scrollToRow(idx));
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // ====== TABLA (solo PC1 y PC2) ======
          Expanded(
            child: _buildScoresTable(
              imageHeader: l.analysisCsvHeaderImage,
              headerPc1: hdr('PC1', 0),
              headerPc2: hdr('PC2', 1),
            ),
          ),
        ],
      ),
    );
  }

  // ======= Tabla con selección bidireccional (sin checkbox) =======
  Widget _buildScoresTable(
      {required String imageHeader,
      required String headerPc1,
      required String headerPc2}) {
    final rows = widget.pcaScores;

    return SingleChildScrollView(
      controller: _tableScroll,
      child: DataTable(
        showCheckboxColumn: false, // << sin checkboxes
        columns: [
          DataColumn(label: Text(imageHeader)),
          DataColumn(label: Text(headerPc1), numeric: true),
          DataColumn(label: Text(headerPc2), numeric: true),
        ],
        rows: rows.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final name = (m['image_name'] ?? 'N/A').toString();
          final pc1 = (m['PC1'] as num).toDouble();
          final pc2 = (m['PC2'] as num).toDouble();

          return DataRow(
            // IMPORTANTE: no se puede usar GlobalKey aquí (espera LocalKey).
            // Usamos la key dentro del primer DataCell para poder hacer ensureVisible.
            selected: i == _selectedIndex,
            onSelectChanged: (sel) {
              final newIdx = (sel ?? false) ? i : -1;
              setState(() => _selectedIndex = newIdx);
            },
            cells: [
              DataCell(
                // << envolvemos el nombre con un KeyedSubtree para tener contexto scrolleable
                KeyedSubtree(
                  key: _rowKeys[i],
                  child: Text(name, overflow: TextOverflow.ellipsis),
                ),
                onTap: () => _viewSpecimen(i), // SOLO el nombre navega
              ),
              DataCell(Text(pc1.toStringAsFixed(4))),
              DataCell(Text(pc2.toStringAsFixed(4))),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Busca el índice del punto por coords exactas (provienen de la misma fuente)
  int _indexOfPoint(double x, double y) {
    return widget.pcaScores.indexWhere((m) =>
        (m['PC1'] as num).toDouble() == x && (m['PC2'] as num).toDouble() == y);
    // Si en el futuro hay redondeos, usar una búsqueda con tolerancia (epsilon).
  }

  // ======= Límites simétricos con padding proporcional (NO elimina outliers) =======
  _Bounds _axisBoundsSymmetric(List<FlSpot> pts) {
    if (pts.isEmpty) {
      return const _Bounds(minX: -1, maxX: 1, minY: -1, maxY: 1, interval: 0.5);
    }
    double maxAbs = 0;
    for (final s in pts) {
      if (s.x.abs() > maxAbs) maxAbs = s.x.abs();
      if (s.y.abs() > maxAbs) maxAbs = s.y.abs();
    }
    // Padding 15% de la amplitud máxima, mínimo 0.25 para no “aplastar”
    final pad = (maxAbs * 0.15).clamp(0.25, double.infinity);
    final lim = (maxAbs + pad);
    final L = _roundUpNice(lim);
    final iv = _niceInterval(L);
    return _Bounds(minX: -L, maxX: L, minY: -L, maxY: L, interval: iv);
  }

  double _roundUpNice(double v) {
    // Redondeo “bonito” a múltiplos de 0.1 / 0.25 / 0.5 / 1.0 según tamaño
    if (v > 4) return (v).ceilToDouble();
    if (v > 2) return ((v / 0.5).ceil() * 0.5);
    if (v > 1) return ((v / 0.25).ceil() * 0.25);
    return ((v / 0.1).ceil() * 0.1);
  }

  double _niceInterval(double limit) {
    if (limit > 4) return 1.0;
    if (limit > 2) return 0.5;
    if (limit > 1) return 0.25;
    return 0.1;
  }
}

class _Bounds {
  final double minX, maxX, minY, maxY, interval;
  const _Bounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}
