// lib/screens/data_manager_screen.dart
//
// DataManagerScreen
// - Clasifica por tipo (LM / ANL CSV / ANL JSON / META / ECO / legacy)
// - Excluye archivos eco_field_* de Landmark files (input)
// - Permite abrir análisis guardados desde JSON enriquecido
// - Si se pulsa un ANL CSV, busca su JSON compañero

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:theia/analysis/analysis_constants.dart';
import 'package:theia/analysis/morph_analysis.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/screens/analysis_result_screen.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/widgets/theia_page_layout.dart';
import 'package:theia/widgets/theia_primary_button.dart';

enum _ManagedFileType {
  landmark,
  analysisCsv,
  analysisJson,
  meta,
  ecoTelemetry,
}

class _ManagedFileEntry {
  const _ManagedFileEntry({
    required this.file,
    required this.type,
    required this.datasetRoot,
    this.runId,
    this.legacy = false,
  });

  final File file;
  final _ManagedFileType type;
  final String datasetRoot;
  final String? runId;
  final bool legacy;

  String get basename =>
      file.uri.pathSegments.isEmpty ? file.path : file.uri.pathSegments.last;

  bool get isAnalysis =>
      type == _ManagedFileType.analysisCsv ||
      type == _ManagedFileType.analysisJson;
}

class DataManagerScreen extends StatefulWidget {
  const DataManagerScreen({super.key});

  @override
  State<DataManagerScreen> createState() => _DataManagerScreenState();
}

class _DataManagerScreenState extends State<DataManagerScreen>
    with WidgetsBindingObserver {
  List<_ManagedFileEntry> _landmarkEntries = [];
  List<_ManagedFileEntry> _analysisEntries = [];

  File? _selectedLandmarkFile;
  File? _selectedAnalysisFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _findDataFiles();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _findDataFiles();
    }
  }

  Future<void> _findDataFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = directory.listSync();

      final landmarks = <_ManagedFileEntry>[];
      final analysis = <_ManagedFileEntry>[];

      for (final entity in entities) {
        if (entity is! File) continue;
        final entry = _classifyFile(entity);
        if (entry == null) continue;

        switch (entry.type) {
          case _ManagedFileType.landmark:
            landmarks.add(entry);
            break;
          case _ManagedFileType.analysisCsv:
          case _ManagedFileType.analysisJson:
            analysis.add(entry);
            break;
          case _ManagedFileType.meta:
          case _ManagedFileType.ecoTelemetry:
            // Se indexan implícitamente por datasetRoot, pero no se muestran en listas principales.
            break;
        }
      }

      landmarks.sort(
        (a, b) =>
            b.file.lastModifiedSync().compareTo(a.file.lastModifiedSync()),
      );
      analysis.sort(
        (a, b) =>
            b.file.lastModifiedSync().compareTo(a.file.lastModifiedSync()),
      );

      if (!mounted) return;
      setState(() {
        _landmarkEntries = landmarks;
        _analysisEntries = analysis;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error buscando archivos de datos: $e');
      }
    }
  }

  _ManagedFileEntry? _classifyFile(File file) {
    final name = file.uri.pathSegments.last;
    final lower = name.toLowerCase();

    // Nuevo naming: <ROOT>__LM.csv
    if (lower.endsWith('__lm.csv')) {
      final root = name.substring(0, name.length - '__LM.csv'.length);
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.landmark,
        datasetRoot: root,
      );
    }

    // Nuevo naming: <ROOT>__META.csv
    if (lower.endsWith('__meta.csv')) {
      final root = name.substring(0, name.length - '__META.csv'.length);
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.meta,
        datasetRoot: root,
      );
    }

    // Nuevo naming: <ROOT>__ANL_Axx.csv / .json
    final anlMatch = RegExp(
      r'^(.*)__ANL_(A\d{2})\.(csv|json)$',
      caseSensitive: false,
    ).firstMatch(name);
    if (anlMatch != null) {
      final root = anlMatch.group(1)!;
      final runId = anlMatch.group(2);
      final ext = anlMatch.group(3)!.toLowerCase();
      return _ManagedFileEntry(
        file: file,
        type: ext == 'json'
            ? _ManagedFileType.analysisJson
            : _ManagedFileType.analysisCsv,
        datasetRoot: root,
        runId: runId,
      );
    }

    // Eco telemetry (no debe aparecer como landmark)
    if (lower.startsWith('eco_field_') && lower.endsWith('.csv')) {
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.ecoTelemetry,
        datasetRoot: _datasetRootFromEcoTelemetry(name),
      );
    }

    // Legacy analysis CSV: ANALISIS_*.csv / ANALYSIS_*.csv
    if ((lower.startsWith('analisis_') || lower.startsWith('analysis_')) &&
        lower.endsWith('.csv')) {
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.analysisCsv,
        datasetRoot: _legacyRootFromAnalysisCsv(name),
        legacy: true,
      );
    }

    // Legacy analysis JSON: DATOS_ANALISIS_theia_*.json
    if (lower.startsWith('datos_analisis_theia_') && lower.endsWith('.json')) {
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.analysisJson,
        datasetRoot: _legacyRootFromAnalysisJson(name),
        legacy: true,
      );
    }

    // Legacy landmarks: theia_poblacion_*.csv / etc.
    if (lower.endsWith('.csv')) {
      final root = name.substring(0, name.length - 4);
      return _ManagedFileEntry(
        file: file,
        type: _ManagedFileType.landmark,
        datasetRoot: root,
        legacy: true,
      );
    }

    return null;
  }

  String _datasetRootFromEcoTelemetry(String name) {
    final noExt = name.substring(0, name.length - 4);
    return noExt.replaceFirst(RegExp(r'^eco_field_', caseSensitive: false), '');
  }

  String _legacyRootFromAnalysisCsv(String name) {
    var out = name.replaceFirst(
        RegExp(r'^(ANALISIS_|ANALYSIS_)', caseSensitive: false), '');
    out = out.replaceFirst(RegExp(r'^\d+_'), '');
    if (out.toLowerCase().endsWith('.csv')) {
      out = out.substring(0, out.length - 4);
    }
    return out;
  }

  String _legacyRootFromAnalysisJson(String name) {
    final match = RegExp(
      r'^DATOS_ANALISIS_theia_(?:\d+_)?(.+)\.json$',
      caseSensitive: false,
    ).firstMatch(name);
    if (match != null) return match.group(1)!;
    return name.replaceAll('.json', '');
  }

  Future<void> _deleteFile(_ManagedFileEntry entry) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.dmDeleteConfirmTitle),
        content: Text(l.dmDeleteConfirmContent(entry.basename)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.dmDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l.dmDeleteConfirm,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await entry.file.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.dmDeleteSuccess),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _findDataFiles();
      setState(() {
        if (_selectedLandmarkFile?.path == entry.file.path) {
          _selectedLandmarkFile = null;
        }
        if (_selectedAnalysisFile?.path == entry.file.path) {
          _selectedAnalysisFile = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.dmDeleteError('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _shareSelectedFile() async {
    final l = AppLocalizations.of(context)!;
    final file = _selectedAnalysisFile ?? _selectedLandmarkFile;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.dmSelectFileFirst)),
      );
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Theia - ${file.uri.pathSegments.last}',
        text: l.shareExport,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.dmShareError('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  static List<List<dynamic>> _parseCsvSync(String csv) {
    return const CsvToListConverter(eol: '\n').convert(csv);
  }

  Matrix _meanShapeOf(List<Matrix> shapes) {
    final p = shapes.first.rowCount;
    final acc = List.generate(p, (_) => List<double>.filled(2, 0.0));
    for (final s in shapes) {
      for (var i = 0; i < p; i++) {
        acc[i][0] += s[i][0];
        acc[i][1] += s[i][1];
      }
    }
    final n = shapes.length.toDouble();
    final rows = List<Vector>.generate(
        p, (i) => Vector.fromList([acc[i][0] / n, acc[i][1] / n]));
    return Matrix.fromRows(rows);
  }

  Future<void> _analyzeSelectedFile() async {
    if (_selectedLandmarkFile == null) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final totalSw = Stopwatch()..start();
    try {
      final readSw = Stopwatch()..start();
      final csvString = await _selectedLandmarkFile!.readAsString();
      readSw.stop();

      await Future.delayed(Duration.zero);

      final parseSw = Stopwatch()..start();
      final List<List<dynamic>> table = await compute(_parseCsvSync, csvString);
      parseSw.stop();

      if (table.length < 2) {
        throw Exception(l.dmCsvEmpty);
      }

      final buildSw = Stopwatch()..start();
      final imageNames = <String>[];
      final List<Matrix> shapes = [];

      for (int i = 1; i < table.length; i++) {
        final row = table[i];
        if (row.isEmpty || row.length < 3) continue;

        imageNames.add(row[0].toString());

        final pts = <Vector>[];
        for (int j = 1; j + 1 < row.length; j += 2) {
          final x = double.tryParse(row[j].toString()) ?? 0.0;
          final y = double.tryParse(row[j + 1].toString()) ?? 0.0;
          pts.add(Vector.fromList([x, y]));
        }
        if (pts.isNotEmpty) {
          shapes.add(Matrix.fromRows(pts));
        }
      }
      buildSw.stop();

      if (shapes.length < 3) {
        throw Exception(l.dmNeedThree);
      }

      await Future.delayed(Duration.zero);

      final gpaSw = Stopwatch()..start();
      final alignedShapes = MorphometricAnalysis.runGPA(shapes);
      gpaSw.stop();

      await Future.delayed(Duration.zero);

      final pcaSw = Stopwatch()..start();
      final pca = MorphometricAnalysis.runPCA(
        alignedShapes,
        k: analysisPrincipalComponents,
      );
      pcaSw.stop();

      final Matrix scores = pca['scores'] as Matrix;
      final Matrix loadings = (pca.containsKey('loadings')
          ? pca['loadings']
          : pca['pcs']) as Matrix;

      Matrix meanShape;
      if (pca.containsKey('mean_shape')) {
        meanShape = pca['mean_shape'] as Matrix;
      } else {
        meanShape = _meanShapeOf(alignedShapes);
      }

      final Vector pc1 = loadings.getColumn(0);
      final Vector pc2 = loadings.getColumn(1);

      final List<Map<String, dynamic>> pcaScores = [];
      final n = scores.rowCount;
      final componentCount = math.min(
        analysisPrincipalComponents,
        scores.columnCount,
      );
      for (int i = 0; i < n; i++) {
        final row = scores.getRow(i);
        final sample = <String, dynamic>{
          'image_name': i < imageNames.length ? imageNames[i] : 'specimen_$i',
        };
        for (var c = 0; c < componentCount; c++) {
          sample['PC${c + 1}'] = row.length > c ? row[c] : 0.0;
        }
        pcaScores.add(sample);
      }

      assert(() {
        final p = alignedShapes.first.rowCount;
        debugPrint('[DM] N=${alignedShapes.length}, p=$p');
        debugPrint('[DM] Timings ms -> read:${readSw.elapsedMilliseconds} '
            'parse:${parseSw.elapsedMilliseconds} build:${buildSw.elapsedMilliseconds} '
            'gpa:${gpaSw.elapsedMilliseconds} pca:${pcaSw.elapsedMilliseconds} '
            'total:${totalSw.elapsedMilliseconds}');
        return true;
      }());

      if (!mounted) return;
      final selectedEntry = _classifyFile(_selectedLandmarkFile!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            pcaScores: pcaScores,
            alignedShapes: alignedShapes,
            rawShapes: shapes,
            meanShape: meanShape,
            pc1Eigenvector: pc1,
            pc2Eigenvector: pc2,
            selectedFileName: _selectedLandmarkFile!.uri.pathSegments.last,
            workingDatasetRoot: selectedEntry?.datasetRoot,
            workingRunTag: 'A01',
            plotUrls: const {},
            serverUrl: '',
          ),
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.dmErrorAnalysis('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      debugPrint('[DM][ERROR] $e\n$st');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      totalSw.stop();
    }
  }

  Future<void> _openAnalysisEntry(_ManagedFileEntry entry) async {
    final l = AppLocalizations.of(context)!;

    File? jsonFile;
    if (entry.type == _ManagedFileType.analysisJson) {
      jsonFile = entry.file;
    } else {
      jsonFile = await _findCompanionJson(entry);
    }

    if (jsonFile == null || !await jsonFile.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.dmAnalysisJsonNotFound)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final raw = await jsonFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception(l.dmInvalidJsonFormat);
      }

      final map = decoded;
      final gpa = _asMap(map['gpa'], l);
      final pca = _asMap(map['pca'], l);

      final alignedShapes = _matricesFromDynamic(gpa['aligned_shapes'], l);
      if (alignedShapes.length < 3) {
        throw Exception(l.dmNeedThree);
      }

      final rawShapes = _matricesFromDynamicOrNull(map['raw_landmarks'], l);
      final meanShape = gpa.containsKey('mean_shape')
          ? _matrixFromDynamic(gpa['mean_shape'], l)
          : _meanShapeOf(alignedShapes);

      final loadings = pca.containsKey('loadings')
          ? _matrixFromDynamic(pca['loadings'], l)
          : _matrixFromDynamic(pca['pcs'], l);
      final scores = _matrixFromDynamic(pca['scores'], l);

      final zeroVector = Vector.fromList(
        List<double>.filled(meanShape.rowCount * 2, 0.0),
      );
      final pc1 = loadings.columnCount > 0 ? loadings.getColumn(0) : zeroVector;
      final pc2 = loadings.columnCount > 1 ? loadings.getColumn(1) : zeroVector;

      final specimens =
          (map['specimens'] as List?)?.map((e) => e.toString()).toList() ??
              const <String>[];

      final componentCount =
          math.min(analysisPrincipalComponents, scores.columnCount);
      final pcaScores = <Map<String, dynamic>>[];
      for (var i = 0; i < scores.rowCount; i++) {
        final row = scores.getRow(i);
        final sample = <String, dynamic>{
          'image_name': i < specimens.length ? specimens[i] : 'specimen_$i',
        };
        for (var c = 0; c < componentCount; c++) {
          sample['PC${c + 1}'] = row.length > c ? row[c] : 0.0;
        }
        pcaScores.add(sample);
      }

      final meta = _asMapOrNull(map['meta'], l);
      final sourceFile =
          meta?['source_file']?.toString() ?? jsonFile.uri.pathSegments.last;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            pcaScores: pcaScores,
            alignedShapes: alignedShapes,
            rawShapes: rawShapes,
            meanShape: meanShape,
            pc1Eigenvector: pc1,
            pc2Eigenvector: pc2,
            selectedFileName: sourceFile,
            workingDatasetRoot: entry.datasetRoot,
            workingRunTag: entry.runId,
            plotUrls: const {},
            serverUrl: '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.dmOpenAnalysisError('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<File?> _findCompanionJson(_ManagedFileEntry csvEntry) async {
    final name = csvEntry.basename;

    final newMatch = RegExp(r'^(.*)__ANL_(A\d{2})\.csv$', caseSensitive: false)
        .firstMatch(name);
    if (newMatch != null) {
      final root = newMatch.group(1)!;
      final run = newMatch.group(2)!;
      final jsonName = '${root}__ANL_$run.json';
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$jsonName');
      if (await file.exists()) return file;
    }

    // legacy: busca por mismo datasetRoot y toma el json más reciente
    final candidates = _analysisEntries
        .where((e) =>
            e.type == _ManagedFileType.analysisJson &&
            e.datasetRoot == csvEntry.datasetRoot)
        .map((e) => e.file)
        .toList();

    if (candidates.isEmpty) return null;
    candidates
        .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return candidates.first;
  }

  Map<String, dynamic> _asMap(dynamic value, AppLocalizations l) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    throw Exception(l.dmExpectedJsonObject);
  }

  Map<String, dynamic>? _asMapOrNull(dynamic value, AppLocalizations l) {
    if (value == null) return null;
    return _asMap(value, l);
  }

  Matrix _matrixFromDynamic(dynamic value, AppLocalizations l) {
    if (value is! List) throw Exception(l.dmExpectedMatrixList);
    final rows = <Vector>[];
    for (final row in value) {
      if (row is! List) continue;
      final numeric = row.map((e) => (e as num).toDouble()).toList();
      rows.add(Vector.fromList(numeric));
    }
    if (rows.isEmpty) {
      throw Exception(l.dmEmptyMatrix);
    }
    return Matrix.fromRows(rows);
  }

  List<Matrix> _matricesFromDynamic(dynamic value, AppLocalizations l) {
    if (value is! List) throw Exception(l.dmExpectedMatricesList);
    final list = <Matrix>[];
    for (final item in value) {
      list.add(_matrixFromDynamic(item, l));
    }
    return list;
  }

  List<Matrix>? _matricesFromDynamicOrNull(
    dynamic value,
    AppLocalizations l,
  ) {
    if (value == null) return null;
    return _matricesFromDynamic(value, l);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.dmTitle)),
      body: Column(
        children: [
          Expanded(
            child: _buildFileListSection(
              title: l.dmLandmarkFiles,
              files: _landmarkEntries,
              selectedFile: _selectedLandmarkFile,
              icon: Icons.edit_note,
              onTap: (entry) {
                setState(() {
                  _selectedLandmarkFile = entry.file;
                  _selectedAnalysisFile = null;
                });
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _buildFileListSection(
              title: l.dmAnalysisFiles,
              files: _analysisEntries,
              selectedFile: _selectedAnalysisFile,
              icon: Icons.analytics_outlined,
              onTap: (entry) async {
                setState(() {
                  _selectedAnalysisFile = entry.file;
                  _selectedLandmarkFile = null;
                });
                await _openAnalysisEntry(entry);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            )
          else
            TheiaPagePadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  TheiaPrimaryButton(
                    icon: Icons.share,
                    label: l.shareExport,
                    minHeight: AppSizes.buttonHeight,
                    onPressed:
                        (_selectedAnalysisFile ?? _selectedLandmarkFile) != null
                            ? _shareSelectedFile
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TheiaPrimaryButton(
                    icon: Icons.analytics,
                    label: l.dmAnalyzeButton,
                    minHeight: AppSizes.buttonHeight,
                    onPressed: _selectedLandmarkFile != null
                        ? _analyzeSelectedFile
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileListSection({
    required String title,
    required List<_ManagedFileEntry> files,
    required File? selectedFile,
    required IconData icon,
    required ValueChanged<_ManagedFileEntry> onTap,
  }) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: files.isEmpty
              ? Center(
                  child: Text(
                    l.dmNoFiles,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _findDataFiles,
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final entry = files[index];
                      final isSelected = selectedFile?.path == entry.file.path;
                      final subtitle = _buildSubtitle(entry);

                      return ListTile(
                        leading: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          entry.basename,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: subtitle == null ? null : Text(subtitle),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteFile(entry),
                        ),
                        onTap: () => onTap(entry),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  String? _buildSubtitle(_ManagedFileEntry entry) {
    if (entry.type == _ManagedFileType.landmark) {
      return entry.legacy
          ? 'Legacy landmark · ${entry.datasetRoot}'
          : 'Dataset: ${entry.datasetRoot}';
    }
    if (entry.type == _ManagedFileType.analysisJson) {
      final run = entry.runId ?? 'legacy';
      return 'ANL JSON · $run · ${entry.datasetRoot}';
    }
    if (entry.type == _ManagedFileType.analysisCsv) {
      final run = entry.runId ?? 'legacy';
      return 'ANL CSV · $run · ${entry.datasetRoot}';
    }
    return null;
  }
}
