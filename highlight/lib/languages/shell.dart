// GENERATED CODE - DO NOT MODIFY BY HAND

// Not every language uses common_modes.
// ignore_for_file: unused_import

import '../src/mode.dart';
import '../src/common_modes.dart';

final shell = Mode(refs: {}, aliases: [
  "console"
], contains: [
  Mode(
      className: "meta",
      begin: "^\\s{0,3}[/\\w\\d\\[\\]()@-]*[>%\$#]",
      starts: Mode(end: "\$", subLanguage: ["bash"]))
]);
