import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'callable_array_transform_observation.dart' as observation;

void main(List<String> arguments) {
  if (arguments.length != 1 ||
      !RegExp(
        r'^docs/checkpoints/array-transform-callable-dart-2026-11-12/trace$',
      ).hasMatch(arguments.single)) {
    throw ArgumentError('the owned repository-relative trace path is required');
  }
  final phase = arguments.single;
  final output = Directory('../$phase');
  final grammar = File(
    '../$userFunctionDefinitionSpecRelativePath',
  ).readAsStringSync();
  print('CALLABLE_TRANSFORM_DART_TRACE_GRAMMAR ${jsonEncode(grammar)}');
  final cases =
      (jsonDecode(File('${output.path}/cases.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  Directory('${output.path}/inputs').createSync(recursive: true);
  for (final row in cases) {
    final id = row['id'] as String;
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(id)) {
      throw FormatException('unsafe trace case id');
    }
    final stdout = StringBuffer();
    final trace = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(
        LinkedSpecTraceLevel.debug,
      ).withTraceFile('${output.path}/$id.trace.log').withResetFile(true),
      stdoutWriter: stdout.write,
    );
    final parsed = parseSpecWithStagedUserFunctionDefinitions(
      row['source'] as String,
      parserSpecSource: grammar,
      trace: trace,
    );
    final serialized = jsonEncode(parsed.toJson());
    File('${output.path}/inputs/$id.json').writeAsStringSync(serialized);
    if (File('${output.path}/inputs/$id.json').readAsStringSync() !=
        serialized) {
      throw StateError('trace parsed snapshot changed before compile');
    }
    print('CALLABLE_TRANSFORM_DART_TRACE_INPUT $id $serialized');
    final compiled = compileSpec(parsed, trace: trace);
    final actual = observation.observeCallableTransform(
      () => LinkedSpecRuntimeEngine(
        compiled,
      ).execute(row['input'] as String, trace: trace).value,
    );
    if (stdout.isNotEmpty) {
      throw StateError('routed trace unexpectedly wrote stdout');
    }
    print('CALLABLE_TRANSFORM_DART_TRACE $id ${jsonEncode(actual)}');
  }
}
