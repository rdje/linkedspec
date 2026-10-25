import 'dart:convert';
import 'dart:io';

import 'lib/linkedspec_dart.dart';
import 'lib/src/runtime/interpreter.dart' as probe;

void main(List<String> args) {
  final fixture = jsonDecode(File(args.single).readAsStringSync()) as Map;
  final engine = LinkedSpecRuntimeEngine(compileSpec(parseSpec('Top::\n /x/\n')));
  for (final item in fixture['cases'] as List) {
    final row = (item as Map).cast<String, Object?>();
    print('DART_PRIVATE\t${jsonEncode(probe.signedPrivateObserve(engine, row))}');
  }
  for (final item in fixture['arithmetic'] as List) {
    final row = (item as Map).cast<String, Object?>();
    print('DART_ARITHMETIC\t${jsonEncode(probe.signedPrivateArithmetic(engine, row))}');
  }
}
