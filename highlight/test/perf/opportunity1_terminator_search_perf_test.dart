// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'is_in_ci.dart';
import 'perf_tester.dart';

Future<void> main() async {
  if (kIsRunningInCi) {
    print('Skipping performance test in CI environment.');
    return;
  }

  final testCases = _buildTestCases();
  print('Prepared ${testCases.length} terminator search scenarios');

  final tester = PerfTester<_TerminatorCase, _MatchSummary>(
    testName: 'Opportunity #1 – RegExp next match lookup',
    testCases: testCases,
    implementation1: _originalNextMatch,
    implementation2: _optimizedNextMatch,
    impl1Name: 'allMatches.firstWhereOrNull',
    impl2Name: 'Iterator.next (optimized)',
    equalityCheck: (a, b) => a == b,
  );

  await tester.run(
    warmupRuns: 20,
    benchmarkRuns: 500,
  );
}

List<_TerminatorCase> _buildTestCases() {
  final sourceText = File('lib/src/highlight.dart').readAsStringSync();
  final largeSource = List.filled(3, sourceText).join('\n');

  final patterns = <RegExp>[
    RegExp(
      r'\b(class|extends|implements|with|if|else|for|while)\b|[{()}.;]',
      multiLine: true,
    ),
    RegExp(
      "'(?:(?:\\\\.)|[^\\\\'])*'|\"(?:(?:\\\\.)|[^\\\\\"])*\"",
      multiLine: true,
    ),
    RegExp(r'//.*|/\*[\s\S]*?\*/', multiLine: true),
    RegExp(r'\b\d+(?:\.\d+)?(?:e[+-]?\d+)?\b', multiLine: true),
    RegExp(r'\bimport\s+[^;]+;', multiLine: true),
    RegExp(r'\{|\}|\(|\)|\[|\]', multiLine: true),
    RegExp(r'<[^>]+>|&[a-z]+;|\{\{?|\}\}?', multiLine: true),
  ];

  final random = math.Random(42);
  final cases = <_TerminatorCase>[];

  for (final pattern in patterns) {
    for (var i = 0; i < 40; i++) {
      final start = random.nextInt(math.max(1, largeSource.length - 1));
      cases.add(_TerminatorCase(
        source: largeSource,
        regexp: pattern,
        startIndex: start,
      ));
    }

    // Include tail-heavy cases where matches are rare or absent to magnify
    // iterator traversal costs.
    for (var i = 0; i < 40; i++) {
      final start = largeSource.length - 1 - random.nextInt(5000);
      cases.add(_TerminatorCase(
        source: largeSource,
        regexp: pattern,
        startIndex: start.clamp(0, largeSource.length - 1).toInt(),
      ));
    }
  }

  return cases;
}

_MatchSummary _originalNextMatch(_TerminatorCase testCase) {
  final match = testCase.regexp
      .allMatches(testCase.source, testCase.startIndex)
      .firstWhereOrNull((m) => true);
  return _MatchSummary.fromMatch(match);
}

_MatchSummary _optimizedNextMatch(_TerminatorCase testCase) {
  for (final match
      in testCase.regexp.allMatches(testCase.source, testCase.startIndex)) {
    return _MatchSummary.fromMatch(match);
  }
  return const _MatchSummary();
}

class _TerminatorCase {
  final String source;
  final RegExp regexp;
  final int startIndex;

  const _TerminatorCase({
    required this.source,
    required this.regexp,
    required this.startIndex,
  });

  @override
  String toString() {
    final snippetLength = math.min(30, regexp.pattern.length);
    return 'start=$startIndex pattern="${regexp.pattern.substring(0, snippetLength)}"';
  }
}

class _MatchSummary {
  final int? start;
  final int? end;
  final String? match;

  const _MatchSummary({this.start, this.end, this.match});

  factory _MatchSummary.fromMatch(RegExpMatch? match) {
    return _MatchSummary(
      start: match?.start,
      end: match?.end,
      match: match?.group(0),
    );
  }

  Map<String, Object?> toJson() => {
        'start': start,
        'end': end,
        'match': match,
      };

  @override
  bool operator ==(Object other) {
    return other is _MatchSummary &&
        other.start == start &&
        other.end == end &&
        other.match == match;
  }

  @override
  int get hashCode => Object.hash(start, end, match);
}
