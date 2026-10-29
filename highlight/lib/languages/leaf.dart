// GENERATED CODE - DO NOT MODIFY BY HAND

// Not every language uses common_modes.
// ignore_for_file: unused_import

import '../src/mode.dart';
import '../src/common_modes.dart';

final leaf = Mode(refs: {}, contains: [
  Mode(
      className: "function",
      begin: "#+[A-Za-z_0-9]*\\(",
      end: " {",
      returnBegin: true,
      excludeEnd: true,
      contains: [
        Mode(className: "keyword", begin: "#+"),
        Mode(className: "title", begin: "[A-Za-z_][A-Za-z_0-9]*"),
        Mode(
            className: "params",
            begin: "\\(",
            end: "\\)",
            endsParent: true,
            contains: [
              Mode(className: "string", begin: "\"", end: "\""),
              Mode(className: "variable", begin: "[A-Za-z_][A-Za-z_0-9]*")
            ])
      ])
]);
