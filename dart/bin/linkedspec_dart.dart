import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/linkedspec_dart.dart [--help]

LinkedSpec Dart backend.
Parser, compiled state, runtime matching, and first rule interpreter are available.
Value blocks, structured controls, with-blocks, and tree traversal helpers are available.
Explicit cursor controls and cursor/input helpers are available.
Tracing, staged runtime execution, and corpus-output parity land in later DART-BACKEND-PARITY leaves.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  print(describeLinkedSpecDartScaffold());
}
