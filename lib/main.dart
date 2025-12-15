import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/* ===== FULLSCREEN ===== */
void toggleFullscreen() {
  final doc = html.document;
  if (doc.fullscreenElement == null) {
    doc.documentElement?.requestFullscreen();
  } else {
    doc.exitFullscreen();
  }
}

void main() {
  runApp(const MyApp());
}

/* ================= INTENT ================= */
class StartPauseIntent extends Intent {}

class ResetIntent extends Intent {}

class FullscreenIntent extends Intent {}

class SelectSoalIntent extends Intent {
  final int index;
  const SelectSoalIntent(this.index);
}

class SaveKelompokIntent extends Intent {
  final int kelompok;
  const SaveKelompokIntent(this.kelompok);
}

/* ================= APP ================= */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StopwatchPage(),
    );
  }
}

/* ================= PAGE ================= */
class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  final List<List<String>> _soalLogs = List.generate(5, (_) => []);
  int? _selectedSoal;

  /* ===== FORMAT WAKTU ===== */
  String get _timeText {
    final d = _stopwatch.elapsed;
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes % 60)}:"
        "${two(d.inSeconds % 60)}."
        "${(d.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}";
  }

  /* ===== CONTROLLER ===== */
  void _startPause() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
      _timer ??= Timer.periodic(
        const Duration(milliseconds: 30),
        (_) => setState(() {}),
      );
    }
  }

  void _reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _timer = null;
    for (final s in _soalLogs) {
      s.clear();
    }
    _selectedSoal = null;
    setState(() {});
  }

  void _selectSoal(int index) {
    _selectedSoal = index;
    setState(() {});
  }

  void _saveKelompok(int kelompok) {
    if (_selectedSoal == null || !_stopwatch.isRunning) return;
    _soalLogs[_selectedSoal!].add("Kelompok $kelompok - $_timeText");
    setState(() {});
  }

  int get _maxRows =>
      _soalLogs.map((e) => e.length).fold(0, (a, b) => a > b ? a : b);

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.space): StartPauseIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyX): ResetIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyF): FullscreenIntent(),

        LogicalKeySet(LogicalKeyboardKey.keyQ): const SelectSoalIntent(0),
        LogicalKeySet(LogicalKeyboardKey.keyW): const SelectSoalIntent(1),
        LogicalKeySet(LogicalKeyboardKey.keyE): const SelectSoalIntent(2),
        LogicalKeySet(LogicalKeyboardKey.keyR): const SelectSoalIntent(3),
        LogicalKeySet(LogicalKeyboardKey.keyT): const SelectSoalIntent(4),

        LogicalKeySet(LogicalKeyboardKey.digit1): const SaveKelompokIntent(1),
        LogicalKeySet(LogicalKeyboardKey.digit2): const SaveKelompokIntent(2),
        LogicalKeySet(LogicalKeyboardKey.digit3): const SaveKelompokIntent(3),
        LogicalKeySet(LogicalKeyboardKey.digit4): const SaveKelompokIntent(4),
        LogicalKeySet(LogicalKeyboardKey.digit5): const SaveKelompokIntent(5),
        LogicalKeySet(LogicalKeyboardKey.digit6): const SaveKelompokIntent(6),
        LogicalKeySet(LogicalKeyboardKey.digit7): const SaveKelompokIntent(7),
        LogicalKeySet(LogicalKeyboardKey.digit8): const SaveKelompokIntent(8),
        LogicalKeySet(LogicalKeyboardKey.digit9): const SaveKelompokIntent(9),
      },
      child: Actions(
        actions: {
          StartPauseIntent: CallbackAction(onInvoke: (_) => _startPause()),
          ResetIntent: CallbackAction(onInvoke: (_) => _reset()),
          FullscreenIntent: CallbackAction(onInvoke: (_) => toggleFullscreen()),

          SelectSoalIntent: CallbackAction<SelectSoalIntent>(
            onInvoke: (intent) => _selectSoal(intent.index),
          ),
          SaveKelompokIntent: CallbackAction<SaveKelompokIntent>(
            onInvoke: (intent) => _saveKelompok(intent.kelompok),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Text(
                    _timeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _selectedSoal == null
                        ? "Pilih Soal (Q–T)"
                        : "Soal Aktif: ${_selectedSoal! + 1}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "SPACE: Start/Pause | Q–T: Soal | 1–9: Kelompok | X: Reset | F: Fullscreen",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(color: Colors.white54),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.white12),
                            children: [
                              _Cell("Soal 1 (Q)", bold: true),
                              _Cell("Soal 2 (W)", bold: true),
                              _Cell("Soal 3 (E)", bold: true),
                              _Cell("Soal 4 (R)", bold: true),
                              _Cell("Soal 5 (T)", bold: true),
                            ],
                          ),
                          for (int row = 0; row < _maxRows; row++)
                            TableRow(
                              children: List.generate(5, (col) {
                                final data = _soalLogs[col];
                                return _Cell(
                                  row < data.length ? data[row] : "-",
                                  highlight: col == _selectedSoal,
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= CELL ================= */
class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool highlight;

  const _Cell(this.text, {this.bold = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: highlight ? Colors.green.withOpacity(0.12) : null,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
