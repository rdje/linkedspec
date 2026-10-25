import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

void main(List<String> args) {
  final fixture = jsonDecode(File(args[0]).readAsStringSync()) as Map;
  final destination = Directory(args[1]);
  if (destination.existsSync()) throw StateError('consumed output directory');
  destination.createSync(recursive: true);
  for (final (index, item) in (fixture['cases'] as List).indexed) {
    final row = item as Map;
    final parsed = parseSpecWithStagedUserFunctionDefinitions(row['source'] as String);
    validateSpec(parsed);
    final compiled = compileSpec(parsed);
    final identity = 'signed-array-dart/${row['id']}.spec';
    final source = emitDartSourceV2(compiled, identity);
    final name = '${index.toString().padLeft(3, '0')}.dart';
    File('${destination.path}/$name').writeAsStringSync(source);
    print(jsonEncode({'id': row['id'], 'file': name, 'identity': identity,
      'plan': [for (final row in buildGeneratedRulePlan(compiled)) row.toJson()]}));
  }
}
