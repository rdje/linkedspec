import 'package:linkedspec_dart/linkedspec_dart.dart';

const _usage = '''
Usage: dart run bin/corpus_runner.dart --corpus <path>

LinkedSpec Dart corpus-runner scaffold.
Manifest loading and drift checks land in DART-BACKEND-PARITY.1.3.
''';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print(_usage.trimRight());
    return;
  }

  print(
    '$linkedSpecDartPackageName corpus runner scaffold; '
    'manifest IO is not implemented yet.',
  );
}
