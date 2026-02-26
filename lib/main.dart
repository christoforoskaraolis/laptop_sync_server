import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Prevent widget errors from crashing the app on device (e.g. Realme/ColorOS)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0D1B2A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Something went wrong.\nRestart the app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFFFFB74D), fontSize: 16),
          ),
        ),
      ),
    );
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runZonedGuarded(() {
    runApp(const RallyMarshalApp());
  }, (error, stack) {
    // Catch async errors so they don't crash the app
    debugPrint('Zone error: $error\n$stack');
  });
}

// Rally theme colours (aligned with app logo: navy + orange)
const _rallyNavy = Color(0xFF0D1B2A);
const _rallyNavySurface = Color(0xFF1B263B);
const _rallyOrange = Color(0xFFE65100);
const _rallyOrangeBright = Color(0xFFFFB74D);
const _rallyRed = Color(0xFFC62828);

class RallyMarshalApp extends StatelessWidget {
  const RallyMarshalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally Control Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: _rallyOrange,
          secondary: _rallyOrangeBright,
          surface: _rallyNavySurface,
          error: _rallyRed,
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: _rallyNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: _rallyNavySurface,
          foregroundColor: _rallyOrangeBright,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const RallyMarshalTimerScreen(),
    );
  }
}

class RallyMarshalTimerScreen extends StatefulWidget {
  const RallyMarshalTimerScreen({super.key});

  @override
  State<RallyMarshalTimerScreen> createState() => _RallyMarshalTimerScreenState();
}

class _RallyMarshalTimerScreenState extends State<RallyMarshalTimerScreen> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _hundredths = 0;

  bool _isRunning = false;
  int _baseHundredths = 0; // total hundredths when "OK" was pressed
  DateTime? _startTime;
  Timer? _timer;

  /// Newest first (descending order). Persisted to device storage.
  List<MarshalEntry> _entries = [];
  static const _entriesKey = 'rally_marshal_entries';
  static const _startTimeKey = 'rally_marshal_start_time';
  static const _rallyNameKey = 'rally_marshal_rally_name';
  static const _tcKey = 'rally_marshal_tc';

  Future<void> _loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_startTimeKey);
    if (json == null) return;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>?;
      if (map == null) return;
      if (!mounted) return;
      setState(() {
        _hours = (map['h'] as num?)?.toInt() ?? 0;
        _minutes = (map['m'] as num?)?.toInt() ?? 0;
        _seconds = (map['s'] as num?)?.toInt() ?? 0;
        _hundredths = (map['c'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _saveStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startTimeKey, jsonEncode({
      'h': _hours, 'm': _minutes, 's': _seconds, 'c': _hundredths,
    }));
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_entriesKey);
    if (json == null) return;
    try {
      final list = jsonDecode(json) as List<dynamic>?;
      if (list == null) return;
      if (!mounted) return;
      setState(() {
        _entries = list
            .map((e) => MarshalEntry(
                  time: e['time'] as String? ?? '',
                  carNumber: (e['carNumber'] as num?)?.toInt() ?? 0,
                ))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _entries.map((e) => {'time': e.time, 'carNumber': e.carNumber}).toList();
    await prefs.setString(_entriesKey, jsonEncode(list));
  }

  static int _toHundredths(int h, int m, int s, int hundredths) {
    return h * 360000 + m * 6000 + s * 100 + hundredths;
  }

  static (int h, int m, int s, int hundredths) _fromHundredths(int total) {
    total = total.clamp(0, 35999999); // cap at 99:59:59.99
    final h = total ~/ 360000;
    total %= 360000;
    final m = total ~/ 6000;
    total %= 6000;
    final s = total ~/ 100;
    final hundredths = total % 100;
    return (h, m, s, hundredths);
  }

  void _startFromSetTime() {
    _baseHundredths = _toHundredths(_hours, _minutes, _seconds, _hundredths);
    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted) return;
      setState(() {});
    });
    setState(() => _isRunning = true);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (_startTime != null) {
      final elapsedHundredths = (DateTime.now().difference(_startTime!).inMilliseconds / 10).floor();
      final (h, m, s, hundredths) = _fromHundredths(_baseHundredths + elapsedHundredths);
      _hours = h;
      _minutes = m;
      _seconds = s;
      _hundredths = hundredths;
    }
    _startTime = null;
    setState(() => _isRunning = false);
  }

  Future<void> _showRallyTcDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final rallyName = prefs.getString(_rallyNameKey);
    final tc = prefs.getString(_tcKey);
    if (rallyName != null && rallyName.isNotEmpty && tc != null && tc.isNotEmpty) return;
    if (!mounted) return;
    final rallyController = TextEditingController(text: rallyName ?? '');
    final tcController = TextEditingController(text: tc ?? '');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final w = MediaQuery.sizeOf(ctx).width;
        final inset = (w * 0.08).clamp(20.0, 32.0);
        final fontSize = (w * 0.04).clamp(14.0, 18.0);
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          insetPadding: EdgeInsets.symmetric(horizontal: inset),
          title: const Text('Rally info', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rally Name :',
                style: TextStyle(color: Colors.grey.shade300, fontSize: fontSize),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: rallyController,
                autofocus: true,
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              decoration: InputDecoration(
                hintText: 'e.g. Winter Rally 2025',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TC :',
              style: TextStyle(color: Colors.grey.shade300, fontSize: fontSize),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: tcController,
              style: TextStyle(color: Colors.white, fontSize: fontSize),
              decoration: InputDecoration(
                hintText: 'e.g. TC1',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_rallyNameKey, rallyController.text.trim());
              await prefs.setString(_tcKey, tcController.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text('OK'),
          ),
        ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadStartTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRallyTcDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _displayTime() {
    if (!_isRunning || _startTime == null) {
      return _format(_hours, _minutes, _seconds, _hundredths);
    }
    final elapsedHundredths = (DateTime.now().difference(_startTime!).inMilliseconds / 10).floor();
    final (h, m, s, hundredths) = _fromHundredths(_baseHundredths + elapsedHundredths);
    return _format(h, m, s, hundredths);
  }

  static String _format(int h, int m, int s, int hundredths) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}';
  }

  Future<void> _openSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final url = await SyncService.getServerUrl() ?? '';
    final rallyName = prefs.getString(_rallyNameKey) ?? '';
    final tc = prefs.getString(_tcKey) ?? '';
    if (!mounted) return;
    final urlController = TextEditingController(text: url);
    final rallyNameController = TextEditingController(text: rallyName);
    final tcController = TextEditingController(text: tc);
    int dialogH = _hours;
    int dialogM = _minutes;
    final isRunning = _isRunning;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        final screenH = mq.size.height;
        final screenW = mq.size.width;
        final insetH = (screenW * 0.06).clamp(16.0, 28.0);
        final insetV = (screenH * 0.05).clamp(16.0, 32.0);
        final maxContentHeight = screenH * 0.72;
        final timeInputSpacing = (screenW * 0.03).clamp(8.0, 16.0);
        return Theme(
          data: ThemeData.dark().copyWith(
            dividerColor: Colors.transparent,
            expansionTileTheme: ExpansionTileThemeData(
              iconColor: Colors.orange.shade200,
              collapsedIconColor: Colors.orange.shade200,
              textColor: Colors.white,
              collapsedTextColor: Colors.white,
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
            ),
          ),
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2D2D2D),
                insetPadding: EdgeInsets.symmetric(horizontal: insetH, vertical: insetV),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                content: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxContentHeight),
                  child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionTile(
                      title: const Text('Event Details', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rally Name :',
                                style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: rallyNameController,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Winter Rally 2025',
                                  hintStyle: TextStyle(color: Colors.grey.shade600),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'TC :',
                                style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: tcController,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'e.g. TC1',
                                  hintStyle: TextStyle(color: Colors.grey.shade600),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Sync to laptop', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sync server URL from Rally HQ. Works over the internet.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: urlController,
                                keyboardType: TextInputType.url,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'https://your-app.up.railway.app',
                                  hintStyle: TextStyle(color: Colors.grey.shade600),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Leave empty to disable sync.',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Start time', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time the timer will start from when you tap Start.',
                                style: TextStyle(color: Colors.white70, fontSize: (screenW * 0.033).clamp(12.0, 14.0)),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: timeInputSpacing,
                                runSpacing: 12,
                                children: [
                                  _TimeInput(
                                    key: const ValueKey('sh'),
                                    label: 'hh',
                                    value: dialogH,
                                    max: 99,
                                    onChanged: (v) => setDialogState(() => dialogH = v),
                                    compact: screenW < 360,
                                  ),
                                  _TimeInput(
                                    key: const ValueKey('sm'),
                                    label: 'mm',
                                    value: dialogM,
                                    max: 59,
                                    onChanged: (v) => setDialogState(() => dialogM = v),
                                    compact: screenW < 360,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Reset entries', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delete all recorded times and car numbers. Timer and Event Details are not changed.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: ctx,
                                      builder: (c) {
                                        final cw = MediaQuery.sizeOf(c).width;
                                        final inset = (cw * 0.08).clamp(20.0, 32.0);
                                        return AlertDialog(
                                          backgroundColor: const Color(0xFF2D2D2D),
                                          insetPadding: EdgeInsets.symmetric(horizontal: inset),
                                          title: const Text('Reset entries', style: TextStyle(color: Colors.white)),
                                          content: const Text(
                                            'Are you sure you want to reset entries?',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(c).pop(false),
                                              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.of(c).pop(true),
                                              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
                                              child: const Text('Yes, reset'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      setState(() => _entries = []);
                                      await _saveEntries();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Entries reset')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Reset all entries'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade300,
                                    side: BorderSide(color: Colors.red.shade700),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isRunning)
                      ExpansionTile(
                        title: const Text('Timer', style: TextStyle(fontWeight: FontWeight.w600)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _stop();
                                  Navigator.of(ctx).pop(false);
                                },
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop & set new time'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange.shade200,
                                  side: BorderSide(color: Colors.orange.shade700),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (result == true) {
      await SyncService.setServerUrl(urlController.text);
      await prefs.setString(_rallyNameKey, rallyNameController.text.trim());
      await prefs.setString(_tcKey, tcController.text.trim());
      setState(() {
        _hours = dialogH;
        _minutes = dialogM;
        _seconds = 0;
        _hundredths = 0;
      });
      await _saveStartTime();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    }
  }

  Future<void> _confirmDeleteEntry(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final w = MediaQuery.sizeOf(ctx).width;
        final inset = (w * 0.08).clamp(20.0, 32.0);
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          insetPadding: EdgeInsets.symmetric(horizontal: inset),
          title: const Text('Delete entry', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this entry?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: const Text('Delete'),
          ),
        ],
        );
      },
    );
    if (confirm == true && mounted) {
      setState(() => _entries.removeAt(index));
      await _saveEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
      }
    }
  }

  Future<void> _editEntryCarNumber(int index) async {
    final e = _entries[index];
    final newCarNumber = await showDialog<int>(
      context: context,
      builder: (ctx) => _CarNumberDialog(initialValue: e.carNumber),
    );
    if (newCarNumber == null || !mounted) return;
    if (newCarNumber != e.carNumber && _entries.any((entry) => entry.carNumber == newCarNumber)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car #$newCarNumber is already in the list'), backgroundColor: Colors.red.shade800),
        );
      }
      return;
    }
    setState(() {
      _entries[index] = MarshalEntry(time: e.time, carNumber: newCarNumber);
    });
    await _saveEntries();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Car number updated')));
    }
  }

  Future<void> _onRecordCarPressed() async {
    final carNumber = await showDialog<int>(
      context: context,
      builder: (ctx) => _CarNumberDialog(),
    );
    if (carNumber == null || !mounted) return;
    if (_entries.any((e) => e.carNumber == carNumber)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car #$carNumber is already in the list'), backgroundColor: Colors.red.shade800),
        );
      }
      return;
    }
    final time = _displayTime();
    setState(() {
      _entries.insert(0, MarshalEntry(time: time, carNumber: carNumber));
    });
    await _saveEntries();
    // Sync to laptop if server is configured (include TC so website can split by TC)
    final prefs = await SharedPreferences.getInstance();
    final tc = prefs.getString(_tcKey) ?? '';
    final err = await SyncService.sendEntry(time: time, carNumber: carNumber, tc: tc);
    if (mounted && err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $err'), backgroundColor: Colors.red.shade800),
      );
    } else if (mounted) {
      final url = await SyncService.getServerUrl();
      if (url != null && url.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved and synced to laptop'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  /// Export entries to PDF: Rally name + TC on top, two-column layout (left then right), share/save.
  Future<void> _exportPdf(BuildContext context) async {
    if (_entries.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final rallyName = prefs.getString(_rallyNameKey)?.trim() ?? '';
    final tcRaw = prefs.getString(_tcKey)?.trim() ?? '';
    final tcLabel = tcRaw.isEmpty ? '(No TC)' : (tcRaw.toUpperCase().startsWith('TC') ? tcRaw : 'TC$tcRaw');

    // Oldest first, same order as laptop website; format "1. #6  00:01:23.45"
    final ordered = _entries.reversed.toList();
    final lines = <String>[];
    for (var i = 0; i < ordered.length; i++) {
      final e = ordered[i];
      lines.add('${i + 1}. #${e.carNumber}  ${e.time}');
    }

    const entriesPerColumn = 45;
    const entriesPerPage = entriesPerColumn * 2;
    final pageFormat = PdfPageFormat.a4;
    final margin = 50.0;

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: pw.Font.helvetica()),
    );

    for (var pageStart = 0; pageStart < lines.length; pageStart += entriesPerPage) {
      final leftEnd = min(pageStart + entriesPerColumn, lines.length);
      final leftLines = lines.sublist(pageStart, leftEnd);
      final rightStart = pageStart + entriesPerColumn;
      final rightEnd = min(rightStart + entriesPerColumn, lines.length);
      final rightLines = rightStart < lines.length ? lines.sublist(rightStart, rightEnd) : <String>[];

      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(margin),
          build: (ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(rallyName.isEmpty ? 'Rally' : rallyName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(tcLabel, style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: leftLines.map((s) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(s, style: pw.TextStyle(fontSize: 11)),
                        )).toList(),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: rightLines.map((s) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(s, style: pw.TextStyle(fontSize: 11)),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final bytes = await doc.save();
    if (!context.mounted) return;
    await Printing.sharePdf(bytes: bytes, filename: 'rally-times-${tcRaw.isEmpty ? "tc" : tcRaw}.pdf');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF ready to share or save')));
    }
  }

  Widget _buildBody(double width) {
    final padding = (width * 0.06).clamp(12.0, 28.0);
    final spacing = (width * 0.04).clamp(12.0, 32.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          SizedBox(height: spacing),
          // Timer display – rally timing style
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding * 1.2, vertical: spacing * 0.6),
            decoration: BoxDecoration(
              color: _rallyNavySurface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rallyOrange.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: _rallyOrange.withOpacity(0.15), blurRadius: 12, spreadRadius: 0),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                _displayTime(),
                style: const TextStyle(
                  fontSize: 200,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: _rallyOrangeBright,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          SizedBox(height: spacing * 1.5),
          if (!_isRunning) ...[
            Text(
              'Start time: ${_format(_hours, _minutes, _seconds, _hundredths)}',
              style: TextStyle(fontSize: (width * 0.04).clamp(14.0, 18.0), color: _rallyOrangeBright.withOpacity(0.9)),
            ),
            SizedBox(height: spacing * 0.3),
            Text(
              'Set time in Settings (gear icon)',
              style: TextStyle(fontSize: (width * 0.03).clamp(11.0, 14.0), color: Colors.white54),
            ),
            SizedBox(height: spacing),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _startFromSetTime,
                style: FilledButton.styleFrom(
                  backgroundColor: _rallyOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('Start from this time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          SizedBox(height: spacing),
          // Record button – flag / finish-line style
          Center(
            child: Material(
              color: _rallyRed,
              shape: const CircleBorder(),
              elevation: 8,
              shadowColor: Colors.black54,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 3),
                ),
                child: InkWell(
                  onTap: _onRecordCarPressed,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: (width * 0.38).clamp(100.0, 160.0),
                    height: (width * 0.38).clamp(100.0, 160.0),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: (width * 0.18).clamp(44.0, 72.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing * 0.5),
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Text(
                      'No entries yet',
                      style: TextStyle(fontSize: 16, color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final e = _entries[index];
                      final num = _entries.length - index;
                      final entryFontSize = (width * 0.048).clamp(14.0, 22.0);
                      final iconSize = (width * 0.055).clamp(20.0, 28.0);
                      final isStripe = index.isOdd;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: (width * 0.008).clamp(2.0, 4.0)),
                        padding: EdgeInsets.symmetric(horizontal: padding * 0.6, vertical: (width * 0.02).clamp(8.0, 14.0)),
                        decoration: BoxDecoration(
                          color: isStripe ? _rallyNavySurface.withOpacity(0.5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(left: BorderSide(color: _rallyOrange.withOpacity(0.6), width: 3)),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$num. #${e.carNumber}  ',
                                    style: TextStyle(
                                      fontSize: entryFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    e.time,
                                    style: TextStyle(
                                      fontSize: entryFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: _rallyOrangeBright,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: iconSize, color: Colors.white70),
                              onPressed: () => _editEntryCarNumber(index),
                              tooltip: 'Edit car number',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: iconSize, color: _rallyRed),
                              onPressed: () => _confirmDeleteEntry(index),
                              tooltip: 'Delete entry',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _rallyNavy,
      appBar: AppBar(
        title: const Text('Rally Control Timer', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _entries.isEmpty ? null : () => _exportPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: _rallyOrange, height: 3),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_rallyNavy, _rallyNavySurface],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => _buildBody(constraints.maxWidth),
          ),
        ),
      ),
    );
  }
}

class MarshalEntry {
  final String time;
  final int carNumber;
  MarshalEntry({required this.time, required this.carNumber});
}

class _CarNumberDialog extends StatefulWidget {
  final int? initialValue;

  const _CarNumberDialog({this.initialValue});

  @override
  State<_CarNumberDialog> createState() => _CarNumberDialogState();
}

class _CarNumberDialogState extends State<_CarNumberDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final inset = (w * 0.08).clamp(20.0, 32.0);
    final fontSize = (w * 0.06).clamp(20.0, 28.0);
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      insetPadding: EdgeInsets.symmetric(horizontal: inset),
      title: Text(widget.initialValue != null ? 'Edit car number' : 'Car number', style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(fontSize: fontSize, color: Colors.white),
        decoration: InputDecoration(
          hintText: '0–99',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
          TextInputFormatter.withFunction((old, newVal) {
            if (newVal.text.isEmpty) return newVal;
            final v = int.tryParse(newVal.text);
            if (v != null && v <= 99) return newVal;
            return old;
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
        ),
        FilledButton(
          onPressed: () {
            final v = int.tryParse(_controller.text);
            if (v != null && v >= 0 && v <= 99) Navigator.of(context).pop(v);
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _TimeInput extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool compact;

  const _TimeInput({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = compact ? 52.0 : 64.0;
    final fontSize = compact ? 18.0 : 22.0;
    final padding = compact ? 8.0 : 12.0;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        SizedBox(
          width: w,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: padding),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxLengthFormatter(max),
              _RangeFormatter(0, max),
            ],
            onChanged: (s) {
              final v = int.tryParse(s);
              if (v != null) onChanged(v.clamp(0, max));
            },
          ),
        ),
      ],
    );
  }
}

class _MaxLengthFormatter extends TextInputFormatter {
  final int max;
  _MaxLengthFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= max.toString().length) return newValue;
    return oldValue;
  }
}

class _RangeFormatter extends TextInputFormatter {
  final int min;
  final int max;
  _RangeFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final v = int.tryParse(newValue.text);
    if (v == null || v < min) return oldValue;
    if (v > max) return TextEditingValue(
      text: max.toString(),
      selection: TextSelection.collapsed(offset: max.toString().length),
    );
    return newValue;
  }
}
