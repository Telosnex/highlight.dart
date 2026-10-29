// GENERATED CODE - DO NOT MODIFY BY HAND

// Not every language uses common_modes.
// ignore_for_file: unused_import

import '../src/mode.dart';
import '../src/common_modes.dart';

final bnf = Mode(refs: {}, contains: [
  Mode(className: "attribute", begin: "<", end: ">"),
  Mode(
      begin: "::=",
      starts: Mode(end: "\$", contains: [
        Mode(begin: "<", end: ">"),
        C_LINE_COMMENT_MODE,
        C_BLOCK_COMMENT_MODE,
        APOS_STRING_MODE,
        QUOTE_STRING_MODE
      ]))
]);
