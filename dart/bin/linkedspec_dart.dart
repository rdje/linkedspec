import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/linkedspec_dart.dart [--help]

LinkedSpec Dart backend scaffold.
Parser and runtime semantics land in later DART-BACKEND-PARITY leaves.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  print(describeLinkedSpecDartScaffold());
}
