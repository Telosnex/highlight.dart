// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'dart:math' as math;

import 'perf_tester.dart';
import 'is_in_ci.dart';

Future<void> main() async {
  if (kIsRunningInCi) {
    print('Skipping performance test in CI environment.');
    return;
  }

  final testCases = _buildTestCases();
  print('Prepared ${testCases.length} mode buffer scenarios');

  final tester = PerfTester<_ModeBufferCase, List<int>>(
    testName: 'Opportunity #4 – mode_buffer consolidation',
    testCases: testCases,
    implementation1: _originalProcess,
    implementation2: _optimizedProcess,
    impl1Name: 'String += mode_buffer',
    impl2Name: 'StringBuffer with cache',
    equalityCheck: _listEquals,
  );

  await tester.run(
    warmupRuns: 6,
    benchmarkRuns: 180,
  );
}

List<_ModeBufferCase> _buildTestCases() {
  final random = math.Random(42);
  final cases = <_ModeBufferCase>[];

  List<String> buildSegments(int count, int minLen, int maxLen) {
    return List<String>.generate(count, (index) {
      final length = minLen + random.nextInt(maxLen - minLen + 1);
      final codeUnits = List<int>.generate(length, (i) {
        final pick = random.nextInt(5);
        switch (pick) {
          case 0:
            return 0x61 + random.nextInt(26); // a-z
          case 1:
            return 0x41 + random.nextInt(26); // A-Z
          case 2:
            return 0x30 + random.nextInt(10); // 0-9
          case 3:
            return random.nextInt(16) + 0x20; // punctuation
          default:
            return '\n'.codeUnitAt(0);
        }
      });
      return String.fromCharCodes(codeUnits);
    });
  }

  const patterns = [
    r'\b(class|extends|implements|with)\b',
    r'"(?:\\.|[^\\"])*"',
    r'//.*',
  ];

  final configs = <(
    int count,
    int minLen,
    int maxLen,
    int passes,
    int checkEvery,
    int flushEvery
  )>[
    (80, 3, 14, 4, 4, 40),
    (160, 2, 18, 6, 5, 60),
    (240, 1, 24, 7, 7, 90),
    (320, 2, 32, 8, 9, 120),
  ];

  for (final config in configs) {
    final segments = buildSegments(config.$1, config.$2, config.$3);
    for (final pattern in patterns) {
      cases.add(
        _ModeBufferCase(
          segments: segments,
          pattern: RegExp(pattern),
          passes: config.$4,
          checkInterval: config.$5,
          flushInterval: config.$6,
        ),
      );
    }
  }

  return cases;
}

List<int> _originalProcess(_ModeBufferCase testCase) {
  var modeBuffer = '';
  final results = <int>[];

  void flush() {
    if (modeBuffer.isEmpty) return;
    final match = testCase.pattern.firstMatch(modeBuffer);
    results.add(match?.start ?? -1);
    modeBuffer = '';
  }

  void record() {
    if (modeBuffer.isEmpty) {
      results.add(-1);
    } else {
      final match = testCase.pattern.firstMatch(modeBuffer);
      results.add(match?.start ?? -1);
    }
  }

  for (var pass = 0; pass < testCase.passes; pass++) {
    for (var i = 0; i < testCase.segments.length; i++) {
      final segment = testCase.segments[i];
      modeBuffer += segment;
      if ((i + 1) % testCase.checkInterval == 0) {
        record();
      }
      if ((i + 1) % testCase.flushInterval == 0) {
        flush();
      }
    }
    flush();
  }
  return results;
}

List<int> _optimizedProcess(_ModeBufferCase testCase) {
  final buffer = StringBuffer();
  String? cachedString;
  final results = <int>[];

  String currentString() => cachedString ??= buffer.toString();

  void flush() {
    if (buffer.isEmpty) {
      cachedString = '';
      return;
    }
    final match = testCase.pattern.firstMatch(currentString());
    results.add(match?.start ?? -1);
    buffer.clear();
    cachedString = '';
  }

  void record() {
    if (buffer.isEmpty) {
      results.add(-1);
      cachedString = '';
    } else {
      final match = testCase.pattern.firstMatch(currentString());
      results.add(match?.start ?? -1);
    }
  }

  for (var pass = 0; pass < testCase.passes; pass++) {
    for (var i = 0; i < testCase.segments.length; i++) {
      final segment = testCase.segments[i];
      buffer.write(segment);
      cachedString = null;
      if ((i + 1) % testCase.checkInterval == 0) {
        record();
      }
      if ((i + 1) % testCase.flushInterval == 0) {
        flush();
      }
    }
    flush();
  }
  return results;
}

bool _listEquals(List<int>? a, List<int>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _ModeBufferCase {
  final List<String> segments;
  final RegExp pattern;
  final int passes;
  final int checkInterval;
  final int flushInterval;

  _ModeBufferCase({
    required this.segments,
    required this.pattern,
    required this.passes,
    required this.checkInterval,
    required this.flushInterval,
  });

  @override
  String toString() =>
      'segments=${segments.length} pattern="${pattern.pattern}" passes=$passes '
      'checkEvery=$checkInterval flushEvery=$flushInterval';
}
