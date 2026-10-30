// Local Telosnex default language registry.
//
// The upstream `package:highlight_fork/highlight.dart` imports and registers every
// generated language definition.  That pulls the generated 1C grammar into
// Flutter web's main.dart.js; on iOS Safari/WebKit that grammar can fail while
// compiling regexes during startup (`SyntaxError: \u can only be followed by a
// Unicode character sequence`).  Register only the languages Telosnex commonly
// renders in Markdown code fences instead of eagerly loading the full grammar
// set.

import 'package:highlight_fork/languages/bash.dart';
import 'package:highlight_fork/languages/cpp.dart';
import 'package:highlight_fork/languages/cs.dart';
import 'package:highlight_fork/languages/css.dart';
import 'package:highlight_fork/languages/dart.dart';
import 'package:highlight_fork/languages/diff.dart';
import 'package:highlight_fork/languages/dockerfile.dart';
import 'package:highlight_fork/languages/go.dart';
import 'package:highlight_fork/languages/graphql.dart';
import 'package:highlight_fork/languages/http.dart';
import 'package:highlight_fork/languages/ini.dart';
import 'package:highlight_fork/languages/java.dart';
import 'package:highlight_fork/languages/javascript.dart';
import 'package:highlight_fork/languages/json.dart';
import 'package:highlight_fork/languages/kotlin.dart';
import 'package:highlight_fork/languages/lua.dart';
import 'package:highlight_fork/languages/makefile.dart';
import 'package:highlight_fork/languages/markdown.dart';
import 'package:highlight_fork/languages/nginx.dart';
import 'package:highlight_fork/languages/objectivec.dart';
import 'package:highlight_fork/languages/perl.dart';
import 'package:highlight_fork/languages/php.dart';
import 'package:highlight_fork/languages/plaintext.dart';
import 'package:highlight_fork/languages/powershell.dart';
import 'package:highlight_fork/languages/python.dart';
import 'package:highlight_fork/languages/r.dart';
import 'package:highlight_fork/languages/ruby.dart';
import 'package:highlight_fork/languages/rust.dart';
import 'package:highlight_fork/languages/scss.dart';
import 'package:highlight_fork/languages/shell.dart';
import 'package:highlight_fork/languages/solidity.dart';
import 'package:highlight_fork/languages/sql.dart';
import 'package:highlight_fork/languages/swift.dart';
import 'package:highlight_fork/languages/tex.dart';
import 'package:highlight_fork/languages/typescript.dart';
import 'package:highlight_fork/languages/vue.dart';
import 'package:highlight_fork/languages/xml.dart';
import 'package:highlight_fork/languages/yaml.dart';
import 'package:highlight_fork/src/highlight.dart';

export 'package:highlight_fork/src/highlight.dart';
export 'package:highlight_fork/src/mode.dart';
export 'package:highlight_fork/src/node.dart';
export 'package:highlight_fork/src/result.dart';

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
