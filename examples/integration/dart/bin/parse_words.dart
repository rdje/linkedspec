import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

void main(List<String> arguments) {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  try {
    var offset = 0;
    final diagnostics =
        arguments.isNotEmpty && arguments.first == '--diagnostics';
    if (diagnostics) offset++;
    if (offset < arguments.length && arguments[offset] == '--') offset++;
    if (arguments.length - offset < 2) {
      throw ArgumentError(
        'Usage: parse_words [--diagnostics] [--] GRAMMAR INPUT [INPUT ...]',
      );
    }
    // Resolve exactly this grammar path against the caller's working directory.
    final loaded = loadAndCompileSpec(
      SpecRequest.path(arguments[offset]),
      SpecLoadOptions(cwd: Directory.current),
    );
    final engine = loaded.createEngine();
    for (final input in arguments.skip(offset + 1)) {
      // Compile once, then execute each independent input in the same process.
      final result = engine.execute(
        input,
        topRule: 'Top',
        diagnosticOutputSink: diagnostics
            ? (event) => stderr.writeln(
                jsonEncode({'type': 'diagnostic_output', ...event.toJson()}),
              )
            : null,
      );
      stdout.writeln(jsonEncode(result.value));
    }
  } on SpecPipelineException catch (error) {
    stderr.writeln(jsonEncode(error.toJson()));
    exitCode = 1;
  } on RuntimeExitNow catch (error) {
    // The application chooses its process status; retain the grammar's status.
    stderr.writeln(
      jsonEncode({'type': 'runtime_exit_now', 'status': error.status}),
    );
    exitCode = 1;
  } on RuntimeInterpreterException catch (error) {
    stderr.writeln(jsonEncode({'type': 'runtime_error', ...error.toJson()}));
    exitCode = 1;
  } on Object catch (error) {
    stderr.writeln(jsonEncode({'type': 'consumer_error', 'detail': '$error'}));
    exitCode = 1;
  }
}
