// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'dart:math' as math;

import 'package:highlight/src/node.dart';

import 'is_in_ci.dart';
import 'perf_tester.dart';

Future<void> main() async {
  if (kIsRunningInCi) {
    print('Skipping performance test in CI environment.');
    return;
  }

  final cases = _buildCases();
  print('Prepared ${cases.length} result node trees');

  final tester = PerfTester<_ToHtmlCase, String>(
    testName: 'Opportunity #5 – Result.toHtml()',
    testCases: cases,
    implementation1: (c) => _toHtmlOriginal(c.nodes),
    implementation2: (c) => _toHtmlOptimized(c.nodes),
    impl1Name: 'String concatenation',
    impl2Name: 'StringBuffer',
  );

  await tester.run(
    warmupRuns: 10,
    benchmarkRuns: 400,
  );
}

List<_ToHtmlCase> _buildCases() {
  final random = math.Random(1234);
  final cases = <_ToHtmlCase>[];

  List<Node> buildTree(int depth, int breadth) {
    if (depth == 0) {
      return [
        Node(
          className: null,
          value: _randomLexeme(random, 15),
        ),
      ];
    }

    return List<Node>.generate(breadth, (index) {
      final hasChildren = depth > 1 && random.nextBool();
      if (hasChildren) {
        return Node(
          className: index.isEven ? 'keyword' : 'string',
          children: buildTree(depth - 1, breadth - 1),
        );
      } else {
        return Node(
          className: index % 3 == 0 ? 'comment' : 'symbol',
          value: _randomLexeme(random, 32 + index * 3),
        );
      }
    });
  }

  final configs = <(int depth, int breadth, int repeats)>[
    (2, 4, 5),
    (3, 5, 3),
    (4, 6, 2),
    (5, 5, 2),
    (6, 4, 1),
  ];

  for (final config in configs) {
    for (var i = 0; i < config.$3; i++) {
      cases.add(_ToHtmlCase(nodes: buildTree(config.$1, config.$2)));
    }
  }

  // Include a flat tree with many leaves to capture concatenation hot path.
  cases.add(
    _ToHtmlCase(
      nodes: List<Node>.generate(
        600,
        (index) => Node(
          className: index.isEven ? 'attr' : 'value',
          value: _randomLexeme(random, 10 + (index % 20)),
        ),
      ),
    ),
  );

  // Include deeply nested but sparse structures.
  cases.add(
    _ToHtmlCase(
      nodes: [
        Node(
          className: 'outer',
          children: [
            Node(
              className: 'middle',
              children: [
                Node(
                  className: 'inner',
                  children: [
                    Node(value: _randomLexeme(random, 120)),
                    Node(
                      className: 'emphasis',
                      children: [Node(value: _randomLexeme(random, 80))],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ],
    ),
  );

  return cases;
}

String _randomLexeme(math.Random random, int length) {
  const alphabet =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>/&\"' ";
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(alphabet[random.nextInt(alphabet.length)]);
  }
  return buffer.toString();
}

String _toHtmlOriginal(List<Node> nodes) {
  var str = '';

  String escape(String value) {
    return value
        .replaceAll(RegExp(r'&'), '&amp;')
        .replaceAll(RegExp(r'<'), '&lt;')
        .replaceAll(RegExp(r'>'), '&gt;');
  }

  void traverse(Node node) {
    final shouldAddSpan = node.className != null &&
        ((node.value != null && node.value!.isNotEmpty) ||
            (node.children != null && node.children!.isNotEmpty));

    if (shouldAddSpan) {
      final prefix = node.noPrefix ? '' : 'hljs-';
      str += '<span class="${prefix + node.className!}">';
    }

    if (node.value != null) {
      str += escape(node.value!);
    } else if (node.children != null) {
      node.children!.forEach(traverse);
    }

    if (shouldAddSpan) {
      str += '</span>';
    }
  }

  nodes.forEach(traverse);
  return str;
}

String _toHtmlOptimized(List<Node> nodes) {
  final buffer = StringBuffer();

  String escape(String value) {
    return value
        .replaceAll(RegExp(r'&'), '&amp;')
        .replaceAll(RegExp(r'<'), '&lt;')
        .replaceAll(RegExp(r'>'), '&gt;');
  }

  void traverse(Node node) {
    final shouldAddSpan = node.className != null &&
        ((node.value != null && node.value!.isNotEmpty) ||
            (node.children != null && node.children!.isNotEmpty));

    if (shouldAddSpan) {
      final prefix = node.noPrefix ? '' : 'hljs-';
      buffer.write('<span class="${prefix + node.className!}">');
    }

    if (node.value != null) {
      buffer.write(escape(node.value!));
    } else if (node.children != null) {
      for (final child in node.children!) {
        traverse(child);
      }
    }

    if (shouldAddSpan) {
      buffer.write('</span>');
    }
  }

  for (final node in nodes) {
    traverse(node);
  }
  return buffer.toString();
}

class _ToHtmlCase {
  final List<Node> nodes;

  const _ToHtmlCase({required this.nodes});

  @override
  String toString() => 'nodes=${nodes.length}';
}
