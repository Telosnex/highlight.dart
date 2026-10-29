// GENERATED CODE - DO NOT MODIFY BY HAND

// Not every language uses common_modes.
// ignore_for_file: unused_import

import '../src/mode.dart';
import '../src/common_modes.dart';

final clojureRepl = Mode(refs: {}, contains: [
  Mode(
      className: "meta",
      begin: "^([\\w.-]+|\\s*#_)?=>",
      starts: Mode(end: "\$", subLanguage: ["clojure"]))
]);
