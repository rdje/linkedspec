import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _markedSource = '''Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later:
 /x/
 E { return("later") }
''';

const _markerlessSource = '''First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
''';

void main() {
  test('loaded and normalized routes preserve ordered authored identity', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-root-routes-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });

    for (final route in [
      ('marked', _markedSource, 'marked', 'Later', 'later'),
      ('markerless', _markerlessSource, 'first', 'Second', 'second'),
    ]) {
      final file = File(
        '${scratch.path}${Platform.pathSeparator}${route.$1}.spec',
      )..writeAsStringSync(route.$2);
      final loaded = loadAndCompileSpec(
        SpecRequest.path(file.path),
        SpecLoadOptions(cwd: scratch),
      );
      final before = loaded.compiled.toDescriptorJson();
      expect(loaded.createEngine().parse('x').value, route.$3);
      expect(
        loaded.createEngine().parse('x', topRule: route.$4).value,
        route.$5,
      );
      expect(loaded.compiled.toDescriptorJson(), before);

      final normalized = SpecFile.fromJson(
        Map<String, Object?>.from(
          jsonDecode(jsonEncode(parseSpec(route.$2).toJson())) as Map,
        ),
      );
      final reconstructed = compileSpec(normalized);
      final reconstructedEngine = LinkedSpecRuntimeEngine(reconstructed);
      expect(reconstructedEngine.parse('x').value, route.$3);
      expect(reconstructedEngine.parse('x', topRule: route.$4).value, route.$5);
      expect(reconstructed.toDescriptorJson(), before);
    }
  });

  test('generated direct and traced routes expose the selected basis', () {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-root-route-trace-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });

    for (final route in [
      ('marked', _markedSource, 'marked', 'Marked', 'first_authored_marker'),
      (
        'markerless',
        _markerlessSource,
        'first',
        'First',
        'first_authored_rule',
      ),
    ]) {
      final compiled = compileSpec(parseSpec(route.$2));
      final plan = buildGeneratedRulePlan(compiled);
      final identity = 'root-routes/${route.$1}.spec';
      expect(executeGeneratedParserV2(compiled, plan, 'x', identity), route.$3);

      final traceFile = File(
        '${scratch.path}${Platform.pathSeparator}${route.$1}.trace',
      );
      expect(
        executeGeneratedParserWithTraceV2(
          compiled,
          plan,
          'x',
          LinkedSpecTraceConfig(
            level: LinkedSpecTraceLevel.debug,
            traceFile: traceFile.path,
            sinkMode: LinkedSpecTraceSinkMode.route,
            resetFile: true,
          ),
          identity,
        ),
        route.$3,
      );
      final trace = traceFile.readAsStringSync();
      expect(trace, contains('dart_runtime:entry_rule_selection'));
      expect(trace, contains('requested=<default>'));
      expect(trace, contains('effective=${route.$4}'));
      expect(trace, contains('basis=${route.$5}'));
    }

    final compiled = compileSpec(parseSpec(_markedSource));
    final plan = buildGeneratedRulePlan(compiled);
    final traceFile = File(
      '${scratch.path}${Platform.pathSeparator}explicit.trace',
    );
    expect(
      executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        'x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        'root-routes/explicit.spec',
        topRule: 'Earlier',
      ),
      'earlier',
    );
    final trace = traceFile.readAsStringSync();
    expect(trace, contains('requested=Earlier'));
    expect(trace, contains('effective=Earlier'));
    expect(trace, contains('basis=explicit_selector'));
  });

  test('generated failures stay portable after plan validation', () {
    const identity = 'root-routes/failure.spec';
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-root-route-failure-',
    );
    addTearDown(() {
      if (scratch.existsSync()) {
        scratch.deleteSync(recursive: true);
      }
    });
    final compiled = compileSpec(parseSpec(_markedSource));
    final plan = buildGeneratedRulePlan(compiled);

    expect(
      () => executeGeneratedParserV2(
        compiled,
        plan,
        'x',
        identity,
        topRule: 'Missing',
      ),
      throwsA(
        isA<GeneratedSourceException>()
            .having((error) => error.toJson(), 'portable unknown selection', {
              'type': 'generated_source_error',
              'stage': 'select_entry_rule',
              'code': 'entry_rule_not_found',
              'summary': 'Generated Dart parser entry-rule selection failed',
              'source_identity': identity,
              'entry_rule': 'Missing',
              'rule_label': 'Missing',
              'detail': "entry rule 'Missing' is not defined",
            }),
      ),
    );

    final traceFile = File(
      '${scratch.path}${Platform.pathSeparator}failure.trace',
    );
    expect(
      () => executeGeneratedParserWithTraceV2(
        compiled,
        plan,
        'x',
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.low,
          traceFile: traceFile.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        identity,
        topRule: 'Missing',
      ),
      throwsA(
        isA<GeneratedSourceException>()
            .having(
              (error) => error.stage,
              'stage',
              GeneratedSourceStage.selectEntryRule,
            )
            .having(
              (error) => error.code,
              'code',
              GeneratedSourceCode.entryRuleNotFound,
            ),
      ),
    );
    final failureTrace = traceFile.readAsStringSync();
    expect(failureTrace, contains('requested=Missing'));
    expect(failureTrace, contains('effective=<none>'));
    expect(failureTrace, contains('stage=select_entry_rule'));
    expect(failureTrace, contains('code=entry_rule_not_found'));

    final empty = compileSpec(const SpecFile(rules: []), validateSource: false);
    expect(
      () => executeGeneratedParserV2(
        empty,
        const [],
        '',
        identity,
        topRule: 'Missing',
      ),
      throwsA(
        isA<GeneratedSourceException>()
            .having((error) => error.toJson(), 'portable zero-rule failure', {
              'type': 'generated_source_error',
              'stage': 'validate_spec',
              'code': 'no_rules_defined',
              'summary': 'Generated Dart parser entry-rule selection failed',
              'source_identity': identity,
              'detail': 'compiled spec does not contain any rules',
            }),
      ),
    );

    expect(
      () => executeGeneratedParserV2(
        empty,
        const [],
        '',
        identity,
        topRule: 'Missing',
        actualContract: 'linkedspec-generated-source-v1',
      ),
      throwsA(
        isA<GeneratedSourceException>()
            .having(
              (error) => error.stage,
              'stage',
              GeneratedSourceStage.validateGeneratedPlan,
            )
            .having(
              (error) => error.code,
              'code',
              GeneratedSourceCode.generatedSourceContractVersionMismatch,
            ),
      ),
    );
  });
}
