// FUTURE-PARITY-BACKLOG.10.5.1.2 — opaque Dart compilation foundation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final graph = _fixture('graph.spec');
  final failed = _fixture('failed.spec');

  test('graph retains one opaque compiled outcome and exact shared plan', () {
    final index = SemanticIndex.fromUtf8(
      graph,
      options: _options('graph.spec', SemanticSourceDetail.text),
    );

    expect(
      index.snapshot,
      SemanticSnapshot(
        id: 'snapshot:0',
        state: SemanticSnapshotState.compiled,
        hasExecution: false,
        sourceDetailCeiling: SemanticSourceDetail.text,
        contentDigestAvailable: true,
      ),
    );
    expect(
      index.compilationAuthority,
      const SemanticCompilationAuthority(
        parsed: true,
        validated: true,
        compiled: true,
      ),
    );
    expect(index.compilationDiagnostic, isNull);
    expect(
      index.entrySelection,
      const SemanticEntrySelection(
        label: 'Top',
        basis: 'first_authored_marker',
      ),
    );
    expect(
      index.generatedPlan,
      SemanticGeneratedPlanInput(
        contractId: 'linkedspec-generated-source-v2',
        formatVersion: 2,
        sourceIdentity: 'graph.spec',
        rows: [
          SemanticGeneratedPlanRow(label: 'Top', family: 'and_acode_seq'),
          SemanticGeneratedPlanRow(label: 'Child', family: 'rep_acode'),
        ],
      ),
    );
    expect(index.toString(), isNot(contains('return("first")')));
    expect(index.toString(), isNot(contains('graph.spec')));
  });

  test('portable validation failure remains an immutable language outcome', () {
    final index = SemanticIndex.fromUtf8(
      failed,
      options: _options('failed.spec', SemanticSourceDetail.text),
    );

    expect(index.snapshot.state, SemanticSnapshotState.failedCompilation);
    expect(
      index.compilationAuthority,
      const SemanticCompilationAuthority(
        parsed: true,
        validated: false,
        compiled: false,
      ),
    );
    expect(index.entrySelection, isNull);
    expect(index.generatedPlan, isNull);
    final diagnostic = index.compilationDiagnostic!;
    expect(diagnostic.code, 'bare_edge_target_undefined');
    expect(diagnostic.stage, 'normalize_edges');
    expect(
      diagnostic.message,
      "bare edge in rule 'Top' targets undefined rule 'Missing'",
    );
    expect(diagnostic.fields, {'rule_label': 'Top', 'target': 'Missing'});

    final detached = diagnostic.toJson();
    (detached['fields']! as Map<String, Object?>)['target'] = 'Mutated';
    expect(index.compilationDiagnostic!.fields['target'], 'Missing');
    expect(index.sourceExcerptForBytes(6, 13), 'Missing');
  });

  test('entry selection preserves explicit identity and failure authority', () {
    final selected = SemanticIndex.fromUtf8(
      graph,
      options: SemanticIndexOptions(
        logicalName: 'graph.spec',
        sourceDetailCeiling: SemanticSourceDetail.identity,
        entryRule: 'Child',
      ),
    );
    expect(
      selected.entrySelection,
      const SemanticEntrySelection(label: 'Child', basis: 'explicit_selector'),
    );

    final missing = SemanticIndex.fromUtf8(
      graph,
      options: SemanticIndexOptions(
        logicalName: 'graph.spec',
        sourceDetailCeiling: SemanticSourceDetail.span,
        entryRule: 'Missing',
      ),
    );
    expect(missing.snapshot.state, SemanticSnapshotState.failedCompilation);
    expect(
      missing.compilationAuthority,
      const SemanticCompilationAuthority(
        parsed: true,
        validated: true,
        compiled: false,
      ),
    );
    expect(missing.entrySelection, isNull);
    expect(missing.generatedPlan, isNull);
    expect(missing.compilationDiagnostic!.toJson(), {
      'code': 'entry_rule_not_found',
      'stage': 'select_entry_rule',
      'message': "entry rule 'Missing' is not defined",
      'fields': {'entry_rule': 'Missing'},
    });
  });

  test('parse validation and compile errors retain deterministic stages', () {
    final parsed = SemanticIndex.fromSource(
      'not a spec\n',
      options: _options('parse-failure.spec', SemanticSourceDetail.none),
    );
    expect(parsed.compilationAuthority.parsed, isFalse);
    expect(parsed.compilationDiagnostic!.toJson(), {
      'code': 'semantic_index_parse_failed',
      'stage': 'parse_source',
      'message': contains('expected rule definition'),
      'fields': {'line': 1},
    });

    final validated = SemanticIndex.fromSource(
      'Top:\n /a/\nTop:\n /b/\n',
      options: _options('validation-failure.spec', SemanticSourceDetail.none),
    );
    expect(validated.compilationAuthority.parsed, isTrue);
    expect(validated.compilationAuthority.validated, isFalse);
    expect(
      validated.compilationDiagnostic!.code,
      'semantic_index_validation_failed',
    );
    expect(validated.compilationDiagnostic!.stage, 'validate_source');
    expect(
      validated.compilationDiagnostic!.message,
      "duplicate rule label 'Top'",
    );

    final retiredSelector = _uniformBindingInvalidSource('array_read');
    final compiled = SemanticIndex.fromSource(
      'Top::\n /x/ -> Done { return($retiredSelector) }\nDone::\n /x/\n',
      options: _options('compile-failure.spec', SemanticSourceDetail.none),
    );
    expect(compiled.compilationAuthority.validated, isTrue);
    expect(compiled.compilationAuthority.compiled, isFalse);
    expect(
      compiled.compilationDiagnostic!.code,
      'semantic_index_compilation_failed',
    );
    expect(compiled.compilationDiagnostic!.stage, 'compile_source');
    expect(
      compiled.compilationDiagnostic!.message,
      contains('aggregate_selector_removed'),
    );
  });

  test('plan and snapshot values are detached and ceiling governed', () {
    final none = SemanticIndex.fromUtf8(
      graph,
      options: _options('graph.spec', SemanticSourceDetail.none),
    );
    expect(
      () => none.generatedPlan,
      throwsA(
        isA<SemanticIndexError>().having(
          (error) => error.code,
          'code',
          'semantic_source_detail_forbidden',
        ),
      ),
    );
    expect(none.snapshot.contentDigestAvailable, isFalse);

    final text = SemanticIndex.fromUtf8(
      graph,
      options: _options('graph.spec', SemanticSourceDetail.text),
    );
    final planJson = text.generatedPlan!.toJson();
    ((planJson['rows']! as List<Object?>).first
            as Map<String, Object?>)['label'] =
        '/tmp/private.spec';
    expect(text.generatedPlan!.rows.first.label, 'Top');
    expect(
      () => text.generatedPlan!.rows.add(
        const SemanticGeneratedPlanRow(label: 'Mutated', family: 'default'),
      ),
      throwsUnsupportedError,
    );

    final snapshotJson = text.snapshot.toJson();
    snapshotJson['state'] = 'mutated';
    expect(text.snapshot.state, SemanticSnapshotState.compiled);
  });

  test('staged functions compile without executing target actions', () {
    final index = SemanticIndex.fromUtf8(
      _fixture('calls_and_staging.spec'),
      options: _options(
        'calls_and_staging.spec',
        SemanticSourceDetail.identity,
      ),
    );

    expect(index.snapshot.state, SemanticSnapshotState.compiled);
    expect(index.snapshot.hasExecution, isFalse);
    expect(index.compilationAuthority.compiled, isTrue);
    expect(index.compilationDiagnostic, isNull);
    expect(index.entrySelection!.label, 'Top');
    expect(index.generatedPlan!.rows, const [
      SemanticGeneratedPlanRow(label: 'Top', family: 'default'),
      SemanticGeneratedPlanRow(label: 'Done', family: 'default'),
    ]);

    final implementation = File(
      'lib/src/semantic/semantic_index.dart',
    ).readAsStringSync();
    expect(
      'parseSpecWithStagedUserFunctionDefinitions(source)'.allMatches(
        implementation,
      ),
      hasLength(1),
    );
    expect('validateSpec(parsed)'.allMatches(implementation), hasLength(1));
    expect(
      'compileSpec(parsed, validateSource: false)'.allMatches(implementation),
      hasLength(1),
    );
    for (final forbidden in [
      'dart:io',
      'LoadedSpec',
      'LinkedSpecRuntimeEngine',
      'RuntimeDiagnosticOutputSink',
      'RuntimeSemanticObservation',
      'emitDartSource',
      'executeGeneratedParser',
    ]) {
      expect(implementation, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

SemanticIndexOptions _options(
  String logicalName,
  SemanticSourceDetail detail,
) =>
    SemanticIndexOptions(logicalName: logicalName, sourceDetailCeiling: detail);

List<int> _fixture(String name) => File(
  '../capability_conformance/semantic_introspection/$name',
).readAsBytesSync();

String _uniformBindingInvalidSource(String id) {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/uniform_binding_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final cases = (contract['invalid_selector_cases']! as List<Object?>)
      .cast<Map<String, Object?>>();
  return cases.singleWhere((item) => item['id'] == id)['source']! as String;
}
