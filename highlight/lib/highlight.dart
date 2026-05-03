// Local Telosnex default language registry.
//
// The upstream `package:highlight/highlight.dart` imports and registers every
// generated language definition.  That pulls the generated 1C grammar into
// Flutter web's main.dart.js; on iOS Safari/WebKit that grammar can fail while
// compiling regexes during startup (`SyntaxError: \u can only be followed by a
// Unicode character sequence`).  Register only the languages Telosnex commonly
// renders in Markdown code fences instead of eagerly loading the full grammar
// set.

import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/cs.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/diff.dart';
import 'package:highlight/languages/dockerfile.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/graphql.dart';
import 'package:highlight/languages/http.dart';
import 'package:highlight/languages/ini.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/lua.dart';
import 'package:highlight/languages/makefile.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/nginx.dart';
import 'package:highlight/languages/objectivec.dart';
import 'package:highlight/languages/perl.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/plaintext.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/r.dart';
import 'package:highlight/languages/ruby.dart';
import 'package:highlight/languages/rust.dart';
import 'package:highlight/languages/scss.dart';
import 'package:highlight/languages/shell.dart';
import 'package:highlight/languages/solidity.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/tex.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/vue.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/src/highlight.dart';

export 'package:highlight/src/highlight.dart';
export 'package:highlight/src/mode.dart';
export 'package:highlight/src/node.dart';
export 'package:highlight/src/result.dart';

final highlight = Highlight()
  ..registerLanguages({
    'bash': bash,
    'shell': shell,
    'sh': bash,
    'zsh': bash,
    'console': shell,
    'cpp': cpp,
    'c': cpp,
    'cc': cpp,
    'h': cpp,
    'hpp': cpp,
    'cs': cs,
    'csharp': cs,
    'css': css,
    'dart': dart,
    'diff': diff,
    'patch': diff,
    'dockerfile': dockerfile,
    'docker': dockerfile,
    'go': go,
    'golang': go,
    'graphql': graphql,
    'gql': graphql,
    'http': http,
    'https': http,
    'ini': ini,
    'toml': ini,
    'java': java,
    'javascript': javascript,
    'js': javascript,
    'jsx': javascript,
    'mjs': javascript,
    'cjs': javascript,
    'json': json,
    'kotlin': kotlin,
    'kt': kotlin,
    'lua': lua,
    'makefile': makefile,
    'mk': makefile,
    'markdown': markdown,
    'md': markdown,
    'nginx': nginx,
    'nginxconf': nginx,
    'objectivec': objectivec,
    'objc': objectivec,
    'obj-c': objectivec,
    'mm': objectivec,
    'perl': perl,
    'pl': perl,
    'php': php,
    'plaintext': plaintext,
    'text': plaintext,
    'txt': plaintext,
    'powershell': powershell,
    'ps': powershell,
    'ps1': powershell,
    'python': python,
    'py': python,
    'r': r,
    'ruby': ruby,
    'rb': ruby,
    'rust': rust,
    'rs': rust,
    'scss': scss,
    'solidity': solidity,
    'sol': solidity,
    'sql': sql,
    'swift': swift,
    'tex': tex,
    'latex': tex,
    'typescript': typescript,
    'ts': typescript,
    'vue': vue,
    'xml': xml,
    'html': xml,
    'xhtml': xml,
    'svg': xml,
    'yaml': yaml,
    'yml': yaml,
  });
