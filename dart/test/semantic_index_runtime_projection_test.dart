// FUTURE-PARITY-BACKLOG.10.5.5.2 — immutable observed-index derivation.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart';
import 'package:test/test.dart';

const _input = 'ab\n';
const _inputIdentity =
    'input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece';
const _responseDigest =
    '36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887';

void main() {
  late String source;
  late CompiledSpec compiled;
  late SemanticIndex base;

  setUpAll(() {
    source = File(
      '../capability_conformance/semantic_introspection/runtime.spec',
    ).readAsStringSync();
    final parsed = parseSpec(source);
    validateSpec(parsed);
    compiled = compileSpec(parsed);
    base = SemanticIndex.fromSource(
      source,
      options: const SemanticIndexOptions(
        logicalName: 'runtime.spec',
        sourceDetailCeiling: SemanticSourceDetail.text,
      ),
    );
  });

  test('derives an immutable snapshot matching the twentieth digest', () {
    final events = _capture(compiled);
    final request = SemanticQuery(
      operation: SemanticQueryOperation.list,
      recordKinds: const ['execution', 'event'],
      source: const SemanticQuerySource(detail: SemanticSourceDetail.identity),
    );
    final neutralRequest = request.toJson();

    expect(base.snapshot.hasExecution, isFalse);
    expect(base.query(request).records, isEmpty);
    final derived = base.withExecutionObservation(events);
    expect(derived.snapshot.hasExecution, isTrue);
    final typed = derived.query(request);
    final neutral = derived.queryNeutral(neutralRequest);

    expect(typed, neutral);
    expect(typed.records.map((record) => record.id), [
      'execution:0',
      'event:execution:0:0',
      'event:execution:0:1',
      'event:execution:0:2',
    ]);
    expect(_canonicalDigest(typed.toJson()), _responseDigest);

    final relations = derived.query(
      SemanticQuery(
        operation: SemanticQueryOperation.relations,
        subjects: const ['execution:0'],
        relationKinds: const ['observed_as'],
        source: const SemanticQuerySource(
          detail: SemanticSourceDetail.identity,
        ),
      ),
    );
    expect(relations.relations.map((relation) => relation.id), [
      'relation:observed_as:execution:0:event:execution:0:0:0',
      'relation:observed_as:execution:0:event:execution:0:1:1',
      'relation:observed_as:execution:0:event:execution:0:2:2',
    ]);
    expect(relations.relations.map((relation) => relation.evidenceIds), [
      ['regex:rule:Top:0'],
      ['regex:rule:Top:1'],
      ['rule:Top'],
    ]);

    events[0] = _slot(position: 999);
    final detached = typed.toJson();
    final records = detached['records']! as List<Object?>;
    final execution = records.first as Map<String, Object?>;
    (execution['facts']! as Map<String, Object?>)['status'] = 'mutated';
    expect(_canonicalDigest(derived.query(request).toJson()), _responseDigest);
    expect(base.snapshot.hasExecution, isFalse);
    expect(base.query(request).records, isEmpty);
  });

  test('rejects malformed foreign reordered and duplicate-final events', () {
    final valid = _expectedEvents();
    final cases = <(String, List<RuntimeSemanticObservationEvent>)>[
      ('empty', []),
      ('missing result', valid.take(2).toList()),
      ('duplicate final', [...valid, valid.last]),
      ('reordered final', [valid[0], valid[2], valid[1]]),
      (
        'foreign contract',
        [_slot(contractId: 'future-contract'), valid[1], valid[2]],
      ),
      ('missing rule label', [_slot(ruleLabel: ''), valid[1], valid[2]]),
      ('missing slot target', [_slot(targetRule: null), valid[1], valid[2]]),
      ('missing slot index', [_slot(regexIndex: null), valid[1], valid[2]]),
      ('negative slot index', [_slot(regexIndex: -1), valid[1], valid[2]]),
      ('negative slot position', [_slot(position: -1), valid[1], valid[2]]),
      (
        'slot carries result state',
        [_slot(status: 'succeeded'), valid[1], valid[2]],
      ),
      (
        'result carries slot state',
        [valid[0], valid[1], _result(targetRule: 'Top', regexIndex: 0)],
      ),
      ('foreign slot', [_slot(targetRule: 'Missing'), valid[1], valid[2]]),
      (
        'foreign result rule',
        [valid[0], valid[1], _result(ruleLabel: 'Missing')],
      ),
      ('failed result', [valid[0], valid[1], _result(status: 'failed')]),
      ('negative result position', [valid[0], valid[1], _result(position: -1)]),
      (
        'missing input identity',
        [valid[0], valid[1], _result(inputIdentity: null)],
      ),
      (
        'malformed input identity',
        [valid[0], valid[1], _result(inputIdentity: 'input:sha256:xyz')],
      ),
    ];

    for (final (label, observation) in cases) {
      expect(
        () => base.withExecutionObservation(observation),
        throwsA(
          isA<SemanticIndexError>()
              .having((error) => error.stage, 'stage', 'execution_observation')
              .having(
                (error) => error.code,
                'code',
                'semantic_index_invalid_observation',
              ),
        ),
        reason: label,
      );
    }
  });

  test('requires the selecting rule to own the selected slot relation', () {
    const unrelatedSource = '''
Top::
 /a/ -> Top[0] { return("top") }

Other::
 /b/ -> Other[0] { return("other") }
''';
    final unrelated = SemanticIndex.fromSource(
      unrelatedSource,
      options: const SemanticIndexOptions(
        logicalName: 'unrelated.spec',
        sourceDetailCeiling: SemanticSourceDetail.text,
      ),
    );
    final events = [
      _slot(ruleLabel: 'Top', targetRule: 'Other'),
      _result(ruleLabel: 'Top'),
    ];

    expect(
      () => unrelated.withExecutionObservation(events),
      throwsA(
        isA<SemanticIndexError>().having(
          (error) => error.message,
          'message',
          contains("does not select regex slot 'Other[0]'"),
        ),
      ),
    );
  });

  test('an already observed or failed index cannot derive again', () {
    final valid = _expectedEvents();
    final derived = base.withExecutionObservation(valid);
    expect(
      () => derived.withExecutionObservation(valid),
      throwsA(
        isA<SemanticIndexError>()
            .having((error) => error.stage, 'stage', 'execution_observation')
            .having(
              (error) => error.code,
              'code',
              'semantic_index_invalid_observation',
            ),
      ),
    );

    final failed = SemanticIndex.fromSource(
      'Top:: Missing\n',
      options: const SemanticIndexOptions(
        logicalName: 'failed.spec',
        sourceDetailCeiling: SemanticSourceDetail.span,
      ),
    );
    expect(failed.snapshot.state, SemanticSnapshotState.failedCompilation);
    expect(
      () => failed.withExecutionObservation(valid),
      throwsA(isA<SemanticIndexError>()),
    );
  });
}

List<RuntimeSemanticObservationEvent> _capture(CompiledSpec compiled) {
  final events = <RuntimeSemanticObservationEvent>[];
  final result = LinkedSpecRuntimeEngine(
    compiled,
  ).parse(_input, semanticObservationSink: events.add);
  expect(result.value, ['A', 'B']);
  return events;
}

List<RuntimeSemanticObservationEvent> _expectedEvents() => [
  _slot(),
  _slot(regexIndex: 1, position: 2),
  _result(),
];

RuntimeSemanticObservationEvent _slot({
  String contractId = linkedSpecSemanticExecutionObservationContract,
  String ruleLabel = 'Top',
  String? targetRule = 'Top',
  int? regexIndex = 0,
  int position = 1,
  String? inputIdentity,
  String? status,
}) => RuntimeSemanticObservationEvent(
  contractId: contractId,
  eventKind: RuntimeSemanticObservationEventKind.regexSlotSelected,
  ruleLabel: ruleLabel,
  targetRule: targetRule,
  regexIndex: regexIndex,
  position: position,
  inputIdentity: inputIdentity,
  status: status,
);

RuntimeSemanticObservationEvent _result({
  String contractId = linkedSpecSemanticExecutionObservationContract,
  String ruleLabel = 'Top',
  String? targetRule,
  int? regexIndex,
  int position = 2,
  String? inputIdentity = _inputIdentity,
  String? status = 'succeeded',
}) => RuntimeSemanticObservationEvent(
  contractId: contractId,
  eventKind: RuntimeSemanticObservationEventKind.ruleResult,
  ruleLabel: ruleLabel,
  targetRule: targetRule,
  regexIndex: regexIndex,
  position: position,
  inputIdentity: inputIdentity,
  status: status,
);

String _canonicalDigest(Map<String, Object?> value) =>
    sha256Hex(utf8.encode(jsonEncode(_canonicalValue(value))));

Object? _canonicalValue(Object? value) {
  if (value case Map<Object?, Object?>()) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalValue(value[key]),
    };
  }
  if (value case List<Object?>()) {
    return [for (final item in value) _canonicalValue(item)];
  }
  return value;
}
