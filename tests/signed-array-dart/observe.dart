import 'dart:convert';

import '../../dart/lib/linkedspec_dart.dart';

const signedDartRoutes = [
  'native',
  'spec_json',
  'validated_engine_plan',
  'generated_wrapper',
];

/// Observes actual public carriers; expected values belong to independent fixtures.
final class PreparedSignedDartCase {
  PreparedSignedDartCase(this.fixture)
    : parsed = parseSpecWithStagedUserFunctionDefinitions(
        fixture['source']! as String,
      ) {
    validateSpec(parsed);
    compiled = compileSpec(parsed);
    reconstructed = SpecFile.fromJson(
      (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
    );
    plan = buildGeneratedRulePlan(compiled);
    validateGeneratedRulePlanV2(compiled, plan, identity);
  }

  final Map<String, Object?> fixture;
  final SpecFile parsed;
  late final SpecFile reconstructed;
  late final CompiledSpec compiled;
  late final List<GeneratedPlanRow> plan;

  String get id => fixture['id']! as String;
  String get identity => 'signed-array-dart/$id.spec';

  Map<String, Object?> describe() => {
    'id': id,
    'source': fixture['source'],
    'spec_json': jsonEncode(parsed.toJson()),
    'compiled_json': jsonEncode(compiled.toJson()),
    'plan': [for (final row in plan) row.toJson()],
  };

  Map<String, Object?> observe(String route) {
    final events = <String>[];
    final injection = (fixture['injection'] as Map?)?.cast<String, Object?>();
    final injected = injection == null
        ? null
        : RuntimeInterpreterException(
            injection['message']! as String,
            diagnostic: RuntimeDiagnostic(
              type: 'fixture',
              stage: 'caller_diagnostic_sink',
              summary: 'injected fixture failure',
              detail: injection['message']! as String,
              code: injection['code']! as String,
            ),
          );
    void sink(RuntimeDiagnosticOutputEvent event) {
      final marker = event.message.trimRight();
      events.add(marker);
      if (injection != null && marker == injection['marker']) throw injected!;
    }

    final result = <String, Object?>{'id': id, 'route': route};
    try {
      result['ok'] = switch (route) {
        'native' => LinkedSpecRuntimeEngine(
          compiled,
          specPath: identity,
        ).execute('x', topRule: 'Top', diagnosticOutputSink: sink).value,
        'spec_json' => LinkedSpecRuntimeEngine(
          compileSpec(reconstructed),
          specPath: identity,
        ).execute('x', topRule: 'Top', diagnosticOutputSink: sink).value,
        'validated_engine_plan' =>
          LinkedSpecRuntimeEngine(compiled, specPath: identity)
              .executeGeneratedWithPlan(
                'x',
                {
                  for (final row in plan)
                    row.label: GeneratedRuleFamily.fromWireName(row.family)!,
                },
                identity,
                topRule: 'Top',
                diagnosticOutputSink: sink,
              )
              .value,
        'generated_wrapper' => executeGeneratedParserV2(
          compiled,
          plan,
          'x',
          identity,
          topRule: 'Top',
          diagnosticOutputSink: sink,
        ),
        _ => throw ArgumentError.value(route, 'route'),
      };
    } on RuntimeInterpreterException catch (error) {
      result['native_error'] = error.toJson();
      if (injected != null)
        result['injected_identity'] = identical(error, injected);
    } on GeneratedSourceException catch (error) {
      result['generated_error'] = error.toJson();
      if (injected != null)
        result['injected_identity'] = identical(error, injected);
    } on Object catch (error) {
      result['other_error'] = '$error';
      result['other_type'] = '${error.runtimeType}';
    }
    result['effects'] = events;
    return result;
  }
}
