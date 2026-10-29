// GENERATED CODE - DO NOT MODIFY BY HAND

// Not every language uses common_modes.
// ignore_for_file: unused_import

import '../src/mode.dart';
import '../src/common_modes.dart';

final juliaRepl = Mode(refs: {}, contains: [
  Mode(
      className: "meta",
      begin: "^julia>",
      relevance: 10,
      starts: Mode(end: "^(?![ ]{6})", subLanguage: ["julia"]),
      aliases: ["jldoctest"])
]);
