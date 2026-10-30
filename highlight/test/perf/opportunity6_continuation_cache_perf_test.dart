// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'dart:math' as math;

import 'is_in_ci.dart';
import 'perf_tester.dart';

Future<void> main() async {
  if (kIsRunningInCi) {
    print('Skipping performance test in CI environment.');
    return;
  }

  final testCases = _buildCases();
  print('Prepared ${testCases.length} continuation cache scenarios');

  final tester = PerfTester<_ContinuationCase, List<int>>(
    testName: 'Opportunity #6 – Continuation cache reuse',
    testCases: testCases,
    implementation1: _originalContinuations,
    implementation2: _optimizedContinuations,
    impl1Name: 'Fresh map per parse',
    impl2Name: 'Shared cache map',
    equalityCheck: _listEquals,
  );

  await tester.run(
    warmupRuns: 20,
    benchmarkRuns: 600,
  );
}

List<_ContinuationCase> _buildCases() {
  final random = math.Random(7);
  final cases = <_ContinuationCase>[];

  List<String> buildLanguageList(int count) {
    return List<String>.generate(count, (i) {
      final length = 5 + random.nextInt(12);
      final buffer = StringBuffer();
      buffer.write('lang');
      buffer.write(i);
      buffer.write('_');
      for (var j = 0; j < length; j++) {
        buffer.writeCharCode(97 + random.nextInt(26));
      }
      return buffer.toString();
    });
  }

  final configs = <(int languages, int iterations)>[
    (18, 80),
    (32, 60),
    (48, 40),
    (100, 35),
    (200, 20),
  ];

  for (final config in configs) {
    cases.add(
      _ContinuationCase(
        languages: buildLanguageList(config.$1),
        iterations: config.$2,
      ),
    );
  }

  // Include a case with many repeated languages to maximize cache hits.
  final hotLanguages = buildLanguageList(25);
  final repeatedList = <String>[];
  for (var i = 0; i < 400; i++) {
    repeatedList.add(hotLanguages[i % hotLanguages.length]);
  }
  cases.add(_ContinuationCase(languages: repeatedList, iterations: 50));

  return cases;
}

int _expensiveContinuationComputation(String language) {
  var hash = 0;
  for (var i = 0; i < language.length; i++) {
    var value = language.codeUnitAt(i);
    for (var round = 0; round < 64; round++) {
      value = ((value * 33) ^ (round + hash)) & 0x7fffffff;
      hash = (hash + (value ^ (hash << 5))) & 0x7fffffff;
    }
  }

  // Mix in a small deterministic pseudo-random walk to imitate child traversal.
  var accumulator = 0;
  var current = hash;
  for (var step = 0; step < 80; step++) {
    current = ((current * 1103515245 + 12345) & 0x7fffffff);
    accumulator ^= (current >> (step % 13));
  }

  return accumulator & 0x7fffffff;
}

List<int> _originalContinuations(_ContinuationCase testCase) {
  final outputs = <int>[];
  for (var iteration = 0; iteration < testCase.iterations; iteration++) {
    final continuations = <String, int>{};
    for (final language in testCase.languages) {
      continuations[language] ??= _expensiveContinuationComputation(language);
      outputs.add(continuations[language]!);
    }
  }
  return outputs;
}

final Map<String, int> _continuationCache = {};

List<int> _optimizedContinuations(_ContinuationCase testCase) {
  final outputs = <int>[];
  for (var iteration = 0; iteration < testCase.iterations; iteration++) {
    for (final language in testCase.languages) {
      final value = _continuationCache.putIfAbsent(
        language,
        () => _expensiveContinuationComputation(language),
      );
      outputs.add(value);
    }
  }
  return outputs;
}

bool _listEquals(List<int>? a, List<int>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _ContinuationCase {
  final List<String> languages;
  final int iterations;

  const _ContinuationCase({
    required this.languages,
    required this.iterations,
  });

  @override
  String toString() =>
      'languages=${languages.length} iterations=$iterations unique=${languages.toSet().length}';
}
