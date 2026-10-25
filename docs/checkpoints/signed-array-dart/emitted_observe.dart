import 'package:linkedspec_dart/linkedspec_dart.dart';

typedef SignedExecute = Object? Function(String, {
  String? topRule, RuntimeDiagnosticOutputSink? diagnosticOutputSink,
});

Map<String, Object?> observeEmitted(Map fixture, SignedExecute execute) {
  final effects = <String>[];
  final injection = fixture['injection'] as Map?;
  final injected = injection == null ? null : RuntimeInterpreterException(
    injection['message'] as String,
    diagnostic: RuntimeDiagnostic(type: 'fixture', stage: 'caller_diagnostic_sink',
      summary: 'injected fixture failure', detail: injection['message'] as String,
      code: injection['code'] as String),
  );
  final row = <String, Object?>{'id': fixture['id'], 'route': 'generated_wrapper',
    'carrier': 'fresh_emitted_module'};
  try {
    row['ok'] = execute('x', topRule: 'Top', diagnosticOutputSink: (event) {
      final marker = event.message.trimRight();
      effects.add(marker);
      if (injection != null && marker == injection['marker']) throw injected!;
    });
  } on RuntimeInterpreterException catch (error) {
    row['native_error'] = error.toJson();
    if (injected != null) row['injected_identity'] = identical(error, injected);
  } on GeneratedSourceException catch (error) {
    row['generated_error'] = error.toJson();
    if (injected != null) row['injected_identity'] = identical(error, injected);
  } on Object catch (error) {
    row['other_error'] = '$error';
    row['other_type'] = '${error.runtimeType}';
  }
  row['effects'] = effects;
  return row;
}
