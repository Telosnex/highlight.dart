// Reads highlight.js fixtures with dart:io: the VM only.
@TestOn('vm')
library highlight_test;

import 'dart:io';
import 'package:highlight/languages/all.dart';
import 'package:path/path.dart' as path;
import 'package:highlight/highlight_core.dart' show highlight;
import 'package:test/test.dart';

/// Fixtures that upstream 0.7.0 already fails (its port of highlight.js
/// 9.18 is incomplete for these). Skipped, so a new failure stands out.
const _knownFailures = {
  'markup/elixir/sigils.txt',
  'markup/typescript/inline-languages.txt',
  'markup/abnf/default.txt',
  'markup/kotlin/string.txt',
  'markup/ini/comments.txt',
  'markup/ini/array.txt',
  'markup/ini/variable.txt',
  'markup/ini/types.txt',
  'markup/handlebars/comments.txt',
  'markup/handlebars/raw-block.txt',
  'markup/handlebars/escaped-mustaches.txt',
  'markup/handlebars/block-expression-variants-in-helper-name.txt',
  'markup/handlebars/simple-expression.txt',
  'markup/handlebars/partial-call.txt',
  'markup/handlebars/block-with-param.txt',
  'markup/handlebars/built-ins.txt',
  'markup/handlebars/triple-mustache.txt',
  'markup/handlebars/block-expression-variants-in-param.txt',
  'markup/handlebars/block.txt',
  'markup/handlebars/expression-variants.txt',
  'markup/handlebars/sub-expressions.txt',
  'markup/handlebars/block-expression-variants-as-path-segment.txt',
  'markup/fortran/numbers.txt',
  'markup/coffeescript/regex.txt',
  'markup/javascript/inline-languages.txt',
  'markup/twig/filter_with_underscore.txt',
  'markup/twig/template_tags.txt',
  'markup/stata/built_ins.txt',
  'detect/plaintext/default.txt',
  'detect/xml/js.txt',
  'detect/xml/groovy-julia.txt',
  'detect/xml/default.txt',
  'detect/ini/default.txt',
  'detect/handlebars/default.txt',
  'detect/cpp/default.txt',
  'detect/cpp/comment.txt',
  'detect/stata/default.txt',
};

String? _skip(String suite, String lang, String file) =>
    _knownFailures.contains('$suite/$lang/$file')
        ? 'Fails in upstream 0.7.0 too'
        : null;

void main() {
  var fixturesDir = '../vendor/highlight.js/test';
  highlight.registerLanguages(builtinLanguages);

  group('basic', () {
    test('language is null', () {
      expect(() => highlight.parse('abc'), throwsArgumentError);
    });

    test('language not exists', () {
      expect(
        highlight
            .parse('abc', language: 'no-such-lang', autoDetection: true)
            .toHtml(),
        'abc',
      );
    });

    test('auto detection', () {
      expect(() => highlight.parse('abc', autoDetection: true),
          isNot(throwsArgumentError));
    });
  });

  group('markup', () {
    Directory('$fixturesDir/markup').listSync().forEach((entity) {
      if (entity.path.endsWith('.js')) return;
      var lang = path.basename(entity.path);

      group(lang, () {
        Directory('$fixturesDir/markup/$lang').listSync().forEach((entity) {
          if (entity.path.contains('expect')) return;

          test(path.basename(entity.path), () {
            var code = File(entity.path).readAsStringSync();
            var expected =
                File(entity.path.replaceFirst(RegExp(r'\.txt$'), '.expect.txt'))
                    .readAsStringSync()
                    .trim();

            expect(highlight.parse(code, language: lang).toHtml().trim(),
                expected);
          }, skip: _skip('markup', lang, path.basename(entity.path)));
        });
      });
    });
  });

  group('detect', () {
    Directory('$fixturesDir/detect').listSync().forEach((entity) {
      if (entity.path.endsWith('.js')) return;
      var lang = path.basename(entity.path);

      group(lang, () {
        Directory('$fixturesDir/detect/$lang').listSync().forEach((entity) {
          test(path.basename(entity.path), () {
            var code = File(entity.path).readAsStringSync();
            expect(highlight.parse(code, autoDetection: true).language, lang);
          }, skip: _skip('detect', lang, path.basename(entity.path)));
        });
      });
    });
  });
}
