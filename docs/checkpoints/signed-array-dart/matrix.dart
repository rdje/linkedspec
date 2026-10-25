import 'dart:convert';
import 'dart:io';

import '../../../tests/signed-array-dart/observe.dart';

void main(List<String> arguments) {
  final fixture = jsonDecode(File(arguments.single).readAsStringSync()) as Map;
  for (final entry in fixture['cases'] as List) {
    final row = (entry as Map).cast<String, Object?>();
    try {
      final prepared = PreparedSignedDartCase(row);
      print('DART_SIGNED_SOURCE\t${jsonEncode(prepared.describe())}');
      for (final route in signedDartRoutes) {
        print('DART_SIGNED_ROW\t${jsonEncode(prepared.observe(route))}');
      }
    } on Object catch (error) {
      print(
        'DART_SIGNED_COMPILE_ERROR\t${jsonEncode({'id': row['id'], 'error': '$error', 'type': '${error.runtimeType}'})}',
      );
    }
  }
}
