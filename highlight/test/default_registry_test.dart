import 'package:highlight/highlight.dart';
import 'package:test/test.dart';

/// The default registry (lib/highlight.dart) has only the languages
/// Telosnex renders. Runs in browsers too: building every grammar's regexes
/// is what failed in WebKit with the full set.
void main() {
  const aliases = [
    'bash', 'shell', 'sh', 'zsh', 'console', 'cpp', 'c', 'cs', 'csharp', //
    'css', 'dart', 'diff', 'dockerfile', 'go', 'graphql', 'http', 'ini',
    'toml', 'java', 'javascript', 'js', 'json', 'kotlin', 'lua', 'makefile',
    'markdown', 'md', 'nginx', 'objectivec', 'perl', 'php', 'plaintext',
    'text', 'powershell', 'python', 'py', 'r', 'ruby', 'rb', 'rust', 'rs',
    'scss', 'solidity', 'sql', 'swift', 'tex', 'latex', 'typescript', 'ts',
    'vue', 'xml', 'html', 'yaml', 'yml',
  ];

  for (final alias in aliases) {
    test('$alias parses', () {
      final result = highlight.parse('a = "b" // c\n', language: alias);
      expect(result.toHtml(), contains('a'));
    });
  }

  test('1C, which broke WebKit, is not registered (plain text)', () {
    final html = highlight
        .parse(r'Процедура Тест() КонецПроцедуры', language: '1c')
        .toHtml();
    expect(html, isNot(contains('hljs-')));
  });

  test('auto detection runs on the default registry', () {
    final result =
        highlight.parse('def f(x):\n    return x\n', autoDetection: true);
    expect(result.language, isNotNull);
  });

  test('continuation resumes after a line', () {
    const code = '/* one\ntwo */ int x = 1;\n';
    final whole = highlight.parse(code, language: 'cpp').toHtml();
    final first = highlight.parseWithContinuation('/* one\n', language: 'cpp');
    final rest = highlight.parseWithContinuation('two */ int x = 1;\n',
        language: 'cpp', continuation: first.top);
    expect(first.toHtml() + rest.toHtml(), isNot(isEmpty));
    expect(rest.toHtml(), contains('hljs-comment'));
    expect(whole, contains('hljs-comment'));
  });
}
