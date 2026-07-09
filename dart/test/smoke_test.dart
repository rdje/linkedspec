import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('scaffold exposes package status', () {
    expect(linkedSpecDartPackageName, 'linkedspec_dart');
    expect(
      linkedSpecDartScaffoldStatus,
      'runtime interpreter with cursor rewinds ready',
    );
    expect(
      describeLinkedSpecDartScaffold(),
      'linkedspec_dart runtime interpreter with cursor rewinds ready',
    );
  });
}
