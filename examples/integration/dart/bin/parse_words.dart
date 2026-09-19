import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

void main(List<String> arguments) {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  try {
    if (arguments.length < 2) {
      throw ArgumentError('Usage: parse_words.dart GRAMMAR INPUT [INPUT ...]');
    }
    // Resolve exactly this grammar path against the caller's working directory.
    final loaded = loadAndCompileSpec(
      SpecRequest.path(arguments.first),
      SpecLoadOptions(cwd: Directory.current),
    );
    final engine = loaded.createEngine();
    for (final input in arguments.skip(1)) {
      // Compile once, then execute each independent input in the same process.
      final result = engine.execute(input, topRule: 'Top');
      stdout.writeln(jsonEncode(result.value));
    }
  } on SpecPipelineException catch (error) {
    stderr.writeln(jsonEncode(error.toJson()));
    exitCode = 1;
  } on RuntimeInterpreterException catch (error) {
    stderr.writeln(jsonEncode({'type': 'runtime_error', ...error.toJson()}));
    exitCode = 1;
  } on Object catch (error) {
    stderr.writeln(jsonEncode({'type': 'consumer_error', 'detail': '$error'}));
    exitCode = 1;
  }
}
