import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/linkedspec_dart.dart [--help]

LinkedSpec Dart backend.
Parser, compiled state, runtime matching, and first rule interpreter are available.
Value blocks, structured controls, with-blocks, and tree traversal helpers are available.
Explicit cursor controls and cursor/input helpers are available.
Runtime structured diagnostics are available.
Trace controls, event classes, and sink routing are available.
Runtime branch/lifecycle/source-boundary trace events are available.
Staged function-body registry dispatch is available.
User-function runtime execution and corpus-output parity land in later DART-BACKEND-PARITY leaves.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  print(describeLinkedSpecDartScaffold());
}
