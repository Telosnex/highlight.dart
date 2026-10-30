// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'package:highlight/src/utils.dart' show substring;

import 'is_in_ci.dart';
import 'perf_tester.dart';

Future<void> main() async {
  if (kIsRunningInCi) {
    print('Skipping performance test in CI environment.');
    return;
  }

  final testCases = _buildTestCases();
  print('Prepared ${testCases.length} joinRe scenarios');

  final tester = PerfTester<_JoinReCase, String>(
    testName: 'Opportunity #3 – _joinRe construction',
    testCases: testCases,
    implementation1: (c) => _joinReOriginal(c.patterns, c.separator),
    implementation2: (c) => _joinReOptimized(c.patterns, c.separator),
    impl1Name: 'Original _joinRe',
    impl2Name: 'Optimized _joinRe',
  );

  await tester.run(
    warmupRuns: 10,
    benchmarkRuns: 800,
  );
}

class _JoinReCase {
  final List<String?> patterns;
  final String separator;

  const _JoinReCase({required this.patterns, this.separator = '|'});

  @override
  String toString() =>
      'patterns=${patterns.length} separator="$separator" first="${patterns.first}"';
}

List<_JoinReCase> _buildTestCases() {
  const basePatterns = <List<String?>>[
    [
      r'\.?(?:class\s+\w+)',
      r'\.?(?:interface\s+\w+)',
      r'\.?(?:enum\s+\w+)',
      r'\.?(?:mixin\s+\w+)',
      r'\.?(?:extension\s+\w+)',
    ],
    [
      r'<[^>]+>',
      r'&[A-Za-z]+?;',
      r'\{\{',
      r'\}\}',
      r'\{%',
      r'%\}',
    ],
    [
      r"'(?:\\\\.|[^\\\\'])*'",
      r'"(?:\\\\.|[^\\\\"])*"',
      r'`(?:\\\\.|[^\\\\`])*`',
    ],
    [
      r'(?:^|\s)(TODO|FIXME|NOTE):',
      r'///+\s*',
      r'/\*\*',
      r'\*/',
      r'//',
    ],
    [
      r'(\s*)([A-Za-z_][\w]*)',
      r'\1=\2',
      r'\1\2\(',
    ],
  ];

  final massiveKeywordList = List<String?>.generate(
    120,
    (index) => r'\bkeyword' + index.toString() + r'\b',
  );

  final nestedGroups = <String?>[
    r'(?:for|while|if)\s*\(',
    r'(?:return|throw)\b',
    r'(?:case|default)\s*:',
    r'(?:else\s+if|else)\b',
    r'(?:catch|finally)\b',
    r'(?:async|await)\b',
    r'(?:try)\b',
    r'(?:switch)\b',
  ];

  final complexBackrefs = <String?>[
    r'(\s*)(\w+)(\s*)',
    r'\1if\2',
    r'\1else\2',
    r'(?:\1for\2)',
    r'\1switch\2',
    r'(?:\1while\2)',
  ];

  final cases = <_JoinReCase>[];
  for (final patterns in basePatterns) {
    cases.add(_JoinReCase(patterns: patterns));
  }
  cases.add(_JoinReCase(patterns: massiveKeywordList));
  cases.add(_JoinReCase(patterns: nestedGroups));
  cases.add(_JoinReCase(patterns: complexBackrefs));
  cases.add(_JoinReCase(patterns: complexBackrefs, separator: '||'));

  // Mix and match combinations to emulate highlight terminator lists.
  for (var i = 0; i < basePatterns.length - 1; i++) {
    final merged = <String?>[
      ...basePatterns[i],
      ...basePatterns[i + 1],
      ...massiveKeywordList.sublist(i * 5, i * 5 + 20),
    ];
    cases.add(_JoinReCase(patterns: merged));
  }

  // ensures we have varying separators
  const separators = ['|', '||', '\\|', ''];
  for (final sep in separators) {
    cases.add(_JoinReCase(patterns: nestedGroups, separator: sep));
  }

  return cases;
}

String _joinReOriginal(List<String?> regexps, String separator) {
  var backreferenceRe = r'\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\.';

  var numCaptures = 0;
  var ret = '';
  for (var i = 0; i < regexps.length; i++) {
    var offset = numCaptures;
    var re = regexps[i] ?? '';
    if (i > 0) {
      ret += separator;
    }

    while (re.isNotEmpty) {
      var match = RegExp(backreferenceRe).firstMatch(re);
      if (match == null) {
        ret += re;
        break;
      }
      ret += substring(re, 0, match.start);
      re = substring(re, match.start + match[0]!.length);
      if (match[0]![0] == '\\' && match[1] != null) {
        ret += '\\' + (int.parse(match[1]!) + offset).toString();
      } else {
        ret += match[0]!;
        if (match[0] == '(') {
          numCaptures++;
        }
      }
    }
  }
  return ret;
}

final RegExp _backreferenceRegExp =
    RegExp(r'\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\.');

String _joinReOptimized(List<String?> regexps, String separator) {
  var numCaptures = 0;
  final buffer = StringBuffer();

  for (var i = 0; i < regexps.length; i++) {
    final pattern = regexps[i] ?? '';
    final offset = numCaptures;

    if (i > 0) {
      buffer.write(separator);
    }

    var remaining = pattern;
    while (remaining.isNotEmpty) {
      final match = _backreferenceRegExp.firstMatch(remaining);
      if (match == null) {
        buffer.write(remaining);
        break;
      }
      buffer.write(substring(remaining, 0, match.start));
      remaining = substring(remaining, match.start + match[0]!.length);

      final head = match[0]![0];
      if (head == '\\' && match[1] != null) {
        buffer
          ..write('\\')
          ..write((int.parse(match[1]!) + offset).toString());
      } else {
        buffer.write(match[0]);
        if (match[0] == '(') {
          numCaptures++;
        }
      }
    }
  }

  return buffer.toString();
}
