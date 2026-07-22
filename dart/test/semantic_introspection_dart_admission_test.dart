// FUTURE-PARITY-BACKLOG.10.5.6 — composed Dart semantic admission.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/semantic/sha256.dart';
import 'package:test/test.dart';

const _consumerPath =
    'dart/test/semantic_introspection_dart_admission_test.dart';
const _canonicalDriver = 'tools/run_ci_local.sh';
const _runtimeInput = 'ab\n';
const _runtimeIdentity = 'semantic-introspection/runtime.spec';
const _runtimeResponseDigest =
    '36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887';
const _roles = <String>[
  'source_normalization',
  'compiled_snapshots',
  'failed_snapshot',
  'runtime_direct',
  'runtime_loaded',
  'runtime_generated',
  'runtime_traced',
  'native_and_neutral_json',
  'exact_twenty_queries',
  'privacy_page_budget_error_explain',
  'query_non_interference',
  'stale_host_leak_denial',
];

typedef _AdmissionRole = Future<void> Function(_AdmissionContext context);
typedef _RuntimeRoute = Object? Function(RuntimeSemanticObservationSink sink);

void main() {
  test(
    'composed Dart semantic admission executes every role exactly once',
    () async {
      final context = _AdmissionContext();
      final roleMap = <String, _AdmissionRole>{
        'source_normalization': role_source_normalization,
        'compiled_snapshots': role_compiled_snapshots,
        'failed_snapshot': role_failed_snapshot,
        'runtime_direct': role_runtime_direct,
        'runtime_loaded': role_runtime_loaded,
        'runtime_generated': role_runtime_generated,
        'runtime_traced': role_runtime_traced,
        'native_and_neutral_json': role_native_and_neutral_json,
        'exact_twenty_queries': role_exact_twenty_queries,
        'privacy_page_budget_error_explain':
            role_privacy_page_budget_error_explain,
        'query_non_interference': role_query_non_interference,
        'stale_host_leak_denial': role_stale_host_leak_denial,
      };
      expect(roleMap.keys.toList(), _roles);

      final completed = <String>{};
      for (final role in _roles) {
        expect(completed.add(role), isTrue, reason: 'role $role repeated');
        await roleMap[role]!(context);
      }
      expect(completed, roleMap.keys.toSet());

      final admission = context.targetAdmission('dart', 'dart');
      expect(admission['status'], 'complete');
      expect(admission['consumer'], {
        'path': _consumerPath,
        'canonical_driver': _canonicalDriver,
        'roles': _roles,
      });
      expect(context.rollout('dart_parity')['status'], 'complete');
      final canonicalCi = _object(context.contract['canonical_ci']);
      expect(
        _strings(canonicalCi['required_tracked_files']),
        contains(_consumerPath),
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

Future<void> role_source_normalization(_AdmissionContext context) async {
  final bytes = context.fixtureBytes('privacy');
  final decoded = utf8.decode(bytes, allowMalformed: false);
  final raw = SemanticIndex.fromUtf8(
    bytes,
    options: const SemanticIndexOptions(
      logicalName: 'privacy.spec',
      sourceDetailCeiling: SemanticSourceDetail.text,
    ),
  );
  final text = SemanticIndex.fromSource(
    decoded,
    options: const SemanticIndexOptions(
      logicalName: 'privacy.spec',
      sourceDetailCeiling: SemanticSourceDetail.text,
    ),
  );
  final queryCase = context.queryCase('privacy_text_and_digest');
  expect(
    context.assertCase(raw, queryCase).toJson(),
    context.assertCase(text, queryCase).toJson(),
  );
}

Future<void> role_compiled_snapshots(_AdmissionContext context) async {
  for (final (snapshot, queryId) in [
    ('graph', 'graph_list_rules'),
    ('calls', 'calls_symbols_and_shapes'),
    ('privacy', 'privacy_text_and_digest'),
    ('privacy_limited', 'source_ceiling_forbidden'),
  ]) {
    final index = context.indexFor(snapshot);
    expect(index.compilationAuthority.compiled, isTrue, reason: snapshot);
    expect(index.snapshot.hasExecution, isFalse, reason: snapshot);
    context.assertCase(index, context.queryCase(queryId));
  }
}

Future<void> role_failed_snapshot(_AdmissionContext context) async {
  final index = context.indexFor('failed');
  expect(index.compilationAuthority.compiled, isFalse);
  expect(index.snapshot.state, SemanticSnapshotState.failedCompilation);
  context.assertCase(index, context.queryCase('failed_diagnostic'));
}

Future<void> role_runtime_direct(_AdmissionContext context) async {
  final result = context.captureRuntimeRoute(
    'direct',
    (sink) => LinkedSpecRuntimeEngine(
      context.runtimeCompiled,
    ).parse(_runtimeInput, semanticObservationSink: sink).value,
  );
  context.runtimeIndex = result.$2;
  context.directEvents = result.$1;
}

Future<void> role_runtime_loaded(_AdmissionContext context) async {
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-semantic-admission-loaded-',
  );
  try {
    File(
      '${scratch.path}${Platform.pathSeparator}runtime.spec',
    ).writeAsBytesSync(context.fixtureBytes('runtime'));
    final loaded = loadAndCompileSpec(
      const SpecRequest.path('runtime.spec'),
      SpecLoadOptions(cwd: scratch),
    );
    final loadedResult = context.captureRuntimeRoute(
      'loaded',
      (sink) => loaded
          .createEngine()
          .parse(_runtimeInput, semanticObservationSink: sink)
          .value,
    );
    expect(_eventJson(loadedResult.$1), _eventJson(context.directEvents));

    final normalized = SpecFile.fromJson(
      _object(
        jsonDecode(jsonEncode(parseSpec(context.runtimeSource).toJson())),
      ),
    );
    validateSpec(normalized);
    final reconstructed = compileSpec(normalized);
    final reconstructedResult = context.captureRuntimeRoute(
      'reconstructed',
      (sink) => LinkedSpecRuntimeEngine(
        reconstructed,
      ).parse(_runtimeInput, semanticObservationSink: sink).value,
    );
    expect(
      _eventJson(reconstructedResult.$1),
      _eventJson(context.directEvents),
    );
  } finally {
    scratch.deleteSync(recursive: true);
  }
}

Future<void> role_runtime_generated(_AdmissionContext context) async {
  final generatedPlan = {
    for (final row in context.runtimePlan)
      row.label: GeneratedRuleFamily.values.singleWhere(
        (family) => family.wireName == row.family,
      ),
  };
  final planResult = context.captureRuntimeRoute(
    'generated plan',
    (sink) => LinkedSpecRuntimeEngine(context.runtimeCompiled)
        .executeGeneratedWithPlan(
          _runtimeInput,
          generatedPlan,
          _runtimeIdentity,
          semanticObservationSink: sink,
        )
        .value,
  );
  expect(_eventJson(planResult.$1), _eventJson(context.directEvents));

  final helperResult = context.captureRuntimeRoute(
    'generated helper',
    (sink) => executeGeneratedParserV2(
      context.runtimeCompiled,
      context.runtimePlan,
      _runtimeInput,
      _runtimeIdentity,
      semanticObservationSink: sink,
    ),
  );
  expect(_eventJson(helperResult.$1), _eventJson(context.directEvents));

  final emitted = await context.emittedProbe();
  expect(emitted.directValue, ['A', 'B']);
  context.assertRuntimeEvents('emitted direct', emitted.directEvents);
  expect(_eventJson(emitted.directEvents), _eventJson(context.directEvents));
}

Future<void> role_runtime_traced(_AdmissionContext context) async {
  final scratch = Directory.systemTemp.createTempSync(
    'linkedspec-dart-semantic-admission-traced-',
  );
  try {
    final directTrace = File('${scratch.path}/direct.trace');
    final direct = context.captureRuntimeRoute(
      'direct traced',
      (sink) => LinkedSpecRuntimeEngine(context.runtimeCompiled)
          .parseWithTrace(
            _runtimeInput,
            LinkedSpecTraceConfig(
              level: LinkedSpecTraceLevel.debug,
              traceFile: directTrace.path,
              sinkMode: LinkedSpecTraceSinkMode.route,
              resetFile: true,
            ),
            semanticObservationSink: sink,
          )
          .value,
    );
    expect(directTrace.readAsStringSync(), isNotEmpty);
    expect(_eventJson(direct.$1), _eventJson(context.directEvents));

    final generatedTrace = File('${scratch.path}/generated.trace');
    final generated = context.captureRuntimeRoute(
      'generated traced',
      (sink) => executeGeneratedParserWithTraceV2(
        context.runtimeCompiled,
        context.runtimePlan,
        _runtimeInput,
        LinkedSpecTraceConfig(
          level: LinkedSpecTraceLevel.debug,
          traceFile: generatedTrace.path,
          sinkMode: LinkedSpecTraceSinkMode.route,
          resetFile: true,
        ),
        _runtimeIdentity,
        semanticObservationSink: sink,
      ),
    );
    expect(generatedTrace.readAsStringSync(), isNotEmpty);
    expect(_eventJson(generated.$1), _eventJson(context.directEvents));

    final emitted = await context.emittedProbe();
    expect(emitted.tracedValue, ['A', 'B']);
    expect(emitted.traceNonEmpty, isTrue);
    context.assertRuntimeEvents('emitted traced', emitted.tracedEvents);
    expect(_eventJson(emitted.tracedEvents), _eventJson(context.directEvents));
  } finally {
    scratch.deleteSync(recursive: true);
  }
}

Future<void> role_native_and_neutral_json(_AdmissionContext context) async {
  final index = context.indexFor('graph');
  final queryCase = context.queryCase('capabilities');
  final request = _cloneMap(_object(queryCase['request']));
  final native = index.capabilities;
  final neutral = index.queryNeutral(request);
  expect(native, neutral);
  expect(jsonDecode(jsonEncode(native.toJson())), native.toJson());

  final detached = native.toJson();
  final records = _objects(detached['records']);
  final facts = _object(records.single['facts']);
  final kinds = (facts['record_kinds']! as List<Object?>);
  kinds[0] = 'host_private_kind';
  expect(
    _canonicalDigest(index.capabilities.toJson()),
    _object(queryCase['expected'])['response_sha256'],
  );
}

Future<void> role_exact_twenty_queries(_AdmissionContext context) async {
  final cases = _objects(context.contract['query_cases']);
  expect(cases, hasLength(20));
  for (final queryCase in cases) {
    final id = queryCase['id']! as String;
    final response = context.assertCase(
      context.indexFor(queryCase['snapshot']! as String),
      queryCase,
    );
    context.responses[id] = response.toJson();
  }
}

Future<void> role_privacy_page_budget_error_explain(
  _AdmissionContext context,
) async {
  final none = context.response('privacy_none');
  final noneRecord = _objects(none['records']).single;
  expect(noneRecord['source'], isNull);
  expect(noneRecord['redactions'], ['/facts/pattern']);

  final text = context.response('privacy_text_and_digest');
  final textRecord = _objects(text['records']).single;
  expect(_object(textRecord['facts'])['pattern'], 'é');
  expect(
    _object(textRecord['source'])['content_digest'],
    matches(RegExp(r'^sha256:[0-9a-f]{64}$')),
  );

  expect(context.response('source_ceiling_forbidden')['ok'], isFalse);
  for (final id in ['pagination_after_id', 'page_boundary']) {
    expect(
      _object(context.response(id)['page'])['complete'],
      _object(context.queryCase(id)['expected'])['complete'],
      reason: id,
    );
  }
  for (final (id, code) in [
    ('budget_prefix', 'semantic_query_budget_exceeded'),
    ('relation_budget_prefix', 'semantic_query_budget_exceeded'),
    ('unsupported_contract', 'semantic_query_contract_unsupported'),
    ('invalid_operation_combination', 'semantic_query_invalid'),
  ]) {
    expect(
      _objects(context.response(id)['diagnostics']).single['code'],
      code,
      reason: id,
    );
  }
  expect(
    _objects(
      context.response('graph_explain_entry')['records'],
    ).any((record) => record['kind'] == 'explanation_step'),
    isTrue,
  );
}

Future<void> role_query_non_interference(_AdmissionContext context) async {
  final index = context.indexFor('graph');
  final queryCase = context.queryCase('graph_explain_entry');
  final request = _cloneMap(_object(queryCase['request']));
  expect(index.snapshot.hasExecution, isFalse);
  final first = index.queryNeutral(request);
  final second = index.queryNeutral(request);
  expect(first, second);
  expect(index.snapshot.hasExecution, isFalse);
  expect(context.runtimeBase.snapshot.hasExecution, isFalse);

  final detached = first.toJson();
  final facts = _object(_objects(detached['records']).first['facts']);
  facts['outcome'] = 'mutated';
  expect(
    _canonicalDigest(index.queryNeutral(request).toJson()),
    _object(queryCase['expected'])['response_sha256'],
  );

  final implementation = File(
    'lib/src/semantic/semantic_query.dart',
  ).readAsStringSync();
  for (final forbidden in [
    'parseSpecWithStagedUserFunctionDefinitions(',
    'compileSpec(',
    'emitDartSource(',
    'executeGeneratedParser',
    'LinkedSpecRuntimeEngine',
    'LinkedSpecTraceEmitter',
    'RuntimeSemanticObservationSink',
    'Platform.environment',
    'File(',
  ]) {
    expect(implementation, isNot(contains(forbidden)), reason: forbidden);
  }
}

Future<void> role_stale_host_leak_denial(_AdmissionContext context) async {
  final encoded = jsonEncode(context.responses);
  for (final forbidden in [
    '/Users/',
    '/private/tmp/',
    'CompiledSpec',
    'ActionIR',
    'RuntimeSemanticObservationEvent',
    'generated_implementation_source',
    'Instance of',
    '0x',
  ]) {
    expect(encoded, isNot(contains(forbidden)), reason: forbidden);
  }
}

final class _AdmissionContext {
  _AdmissionContext()
    : contract = _object(
        jsonDecode(
          File(
            '../capability_conformance/semantic_introspection_contract.json',
          ).readAsStringSync(),
        ),
      );

  final Map<String, Object?> contract;
  final Map<String, SemanticIndex> _indexes = {};
  final Map<String, Map<String, Object?>> responses = {};
  Future<_EmittedProbe>? _emittedProbe;
  late final String runtimeSource = fixtureText('runtime');
  late final CompiledSpec runtimeCompiled = _compile(runtimeSource);
  late final List<GeneratedPlanRow> runtimePlan = buildGeneratedRulePlan(
    runtimeCompiled,
  );
  late final SemanticIndex runtimeBase = SemanticIndex.fromSource(
    runtimeSource,
    options: const SemanticIndexOptions(
      logicalName: 'runtime.spec',
      sourceDetailCeiling: SemanticSourceDetail.text,
    ),
  );
  late SemanticIndex runtimeIndex;
  late List<RuntimeSemanticObservationEvent> directEvents;

  List<int> fixtureBytes(String fixture) => File(
    '../capability_conformance/semantic_introspection/$fixture.spec',
  ).readAsBytesSync();

  String fixtureText(String fixture) =>
      utf8.decode(fixtureBytes(fixture), allowMalformed: false);

  SemanticIndex indexFor(String snapshot) {
    if (snapshot == 'runtime') {
      return runtimeIndex;
    }
    return _indexes.putIfAbsent(snapshot, () {
      final (fixture, ceiling, logicalName) = switch (snapshot) {
        'graph' => ('graph', SemanticSourceDetail.text, 'graph.spec'),
        'calls' => (
          'calls_and_staging',
          SemanticSourceDetail.text,
          'calls_and_staging.spec',
        ),
        'failed' => ('failed', SemanticSourceDetail.span, 'failed.spec'),
        'privacy' => ('privacy', SemanticSourceDetail.text, 'privacy.spec'),
        'privacy_limited' => (
          'privacy',
          SemanticSourceDetail.identity,
          'privacy.spec',
        ),
        _ => throw StateError('Unexpected semantic snapshot: $snapshot'),
      };
      return SemanticIndex.fromUtf8(
        fixtureBytes(fixture),
        options: SemanticIndexOptions(
          logicalName: logicalName,
          sourceDetailCeiling: ceiling,
        ),
      );
    });
  }

  Map<String, Object?> queryCase(String id) => _objects(
    contract['query_cases'],
  ).singleWhere((queryCase) => queryCase['id'] == id);

  Map<String, Object?> targetAdmission(String backend, String runtime) =>
      _objects(contract['target_admissions']).singleWhere(
        (row) => row['backend'] == backend && row['runtime'] == runtime,
      );

  Map<String, Object?> rollout(String capability) => _objects(
    contract['rollout'],
  ).singleWhere((row) => row['capability'] == capability);

  SemanticQueryResponse assertCase(
    SemanticIndex index,
    Map<String, Object?> queryCase,
  ) {
    final id = queryCase['id']! as String;
    final requestValue = _cloneMap(_object(queryCase['request']));
    final requestBefore = _cloneMap(requestValue);
    final request = _typedRequest(requestValue);
    final typed = id == 'capabilities'
        ? index.capabilities
        : index.query(request);
    final neutral = index.queryNeutral(requestValue);
    final expected = _object(queryCase['expected']);

    expect(requestValue, requestBefore, reason: '$id request isolation');
    expect(typed, neutral, reason: '$id typed/neutral identity');
    expect(typed.ok, expected['ok'], reason: '$id status');
    expect(
      typed.records.map((record) => record.id),
      expected['record_ids'],
      reason: '$id records',
    );
    expect(
      typed.relations.map((relation) => relation.id),
      expected['relation_ids'],
      reason: '$id relations',
    );
    expect(
      typed.diagnostics.map((diagnostic) => diagnostic.code),
      expected['diagnostic_codes'],
      reason: '$id diagnostics',
    );
    expect(typed.page.complete, expected['complete'], reason: id);
    expect(
      _canonicalDigest(typed.toJson()),
      expected['response_sha256'],
      reason: '$id response digest',
    );
    return typed;
  }

  (List<RuntimeSemanticObservationEvent>, SemanticIndex) captureRuntimeRoute(
    String route,
    _RuntimeRoute execute,
  ) {
    final events = <RuntimeSemanticObservationEvent>[];
    final value = execute(events.add);
    expect(value, ['A', 'B'], reason: '$route value');
    assertRuntimeEvents(route, events);
    final derived = runtimeBase.withExecutionObservation(events);
    assertCase(derived, queryCase('runtime_events'));
    return (events, derived);
  }

  void assertRuntimeEvents(
    String route,
    List<RuntimeSemanticObservationEvent> events,
  ) {
    expect(_eventJson(events), _eventJson(_expectedEvents), reason: route);
    final derived = runtimeBase.withExecutionObservation(events);
    expect(
      _canonicalDigest(
        derived
            .query(
              _typedRequest(_object(queryCase('runtime_events')['request'])),
            )
            .toJson(),
      ),
      _runtimeResponseDigest,
      reason: '$route twentieth digest',
    );
  }

  Map<String, Object?> response(String id) => responses[id]!;

  Future<_EmittedProbe> emittedProbe() => _emittedProbe ??= _runEmittedProbe();

  Future<_EmittedProbe> _runEmittedProbe() async {
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-semantic-admission-emitted-',
    );
    final packageRoot = Directory.current.absolute;
    try {
      Directory('${scratch.path}/lib').createSync();
      Directory('${scratch.path}/bin').createSync();
      File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_semantic_admission_emitted
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
      File(
        '${scratch.path}/lib/generated.dart',
      ).writeAsStringSync(emitDartSourceV2(runtimeCompiled, _runtimeIdentity));
      File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_semantic_admission_emitted/generated.dart'
    as generated;

void main() {
  const input = 'ab\n';
  final directEvents = <RuntimeSemanticObservationEvent>[];
  final direct = generated.execute(
    input,
    semanticObservationSink: directEvents.add,
  );
  final tracedEvents = <RuntimeSemanticObservationEvent>[];
  final traced = generated.executeWithTrace(
    input,
    const LinkedSpecTraceConfig(
      level: LinkedSpecTraceLevel.debug,
      traceFile: 'emitted.trace',
      sinkMode: LinkedSpecTraceSinkMode.route,
      resetFile: true,
    ),
    semanticObservationSink: tracedEvents.add,
  );
  print(jsonEncode({
    'direct_value': direct,
    'traced_value': traced,
    'direct_events': [for (final event in directEvents) event.toJson()],
    'traced_events': [for (final event in tracedEvents) event.toJson()],
    'trace_non_empty': File('emitted.trace').readAsStringSync().isNotEmpty,
  }));
}
''');

      await _runDart(scratch, const ['pub', 'get', '--offline']);
      final run = await _runDart(scratch, const ['run', 'bin/main.dart']);
      final output = _object(jsonDecode((run.stdout as String).trim()));
      return _EmittedProbe(
        directValue: output['direct_value'],
        tracedValue: output['traced_value'],
        directEvents: _eventsFromJson(output['direct_events']),
        tracedEvents: _eventsFromJson(output['traced_events']),
        traceNonEmpty: output['trace_non_empty']! as bool,
      );
    } finally {
      scratch.deleteSync(recursive: true);
    }
  }
}

final class _EmittedProbe {
  const _EmittedProbe({
    required this.directValue,
    required this.tracedValue,
    required this.directEvents,
    required this.tracedEvents,
    required this.traceNonEmpty,
  });

  final Object? directValue;
  final Object? tracedValue;
  final List<RuntimeSemanticObservationEvent> directEvents;
  final List<RuntimeSemanticObservationEvent> tracedEvents;
  final bool traceNonEmpty;
}

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

List<RuntimeSemanticObservationEvent> get _expectedEvents => [
  RuntimeSemanticObservationEvent.regexSlotSelected(
    ruleLabel: 'Top',
    targetRule: 'Top',
    regexIndex: 0,
    position: 1,
  ),
  RuntimeSemanticObservationEvent.regexSlotSelected(
    ruleLabel: 'Top',
    targetRule: 'Top',
    regexIndex: 1,
    position: 2,
  ),
  RuntimeSemanticObservationEvent.ruleResult(
    ruleLabel: 'Top',
    position: 2,
    input: _runtimeInput,
  ),
];

List<Map<String, Object?>> _eventJson(
  List<RuntimeSemanticObservationEvent> events,
) => [for (final event in events) event.toJson()];

List<RuntimeSemanticObservationEvent> _eventsFromJson(Object? value) => [
  for (final row in _objects(value))
    RuntimeSemanticObservationEvent(
      contractId: row['contract_id']! as String,
      eventKind: RuntimeSemanticObservationEventKind.values.singleWhere(
        (kind) => kind.wireName == row['event_kind'],
      ),
      ruleLabel: row['rule_label']! as String,
      targetRule: row['target_rule'] as String?,
      regexIndex: row['regex_index'] as int?,
      position: row['position']! as int,
      inputIdentity: row['input_identity'] as String?,
      status: row['status'] as String?,
    ),
];

SemanticQuery _typedRequest(Map<String, Object?> value) {
  final page = _object(value['page']);
  final budget = _object(value['budget']);
  final source = _object(value['source']);
  return SemanticQuery(
    contract: value['contract']! as String,
    operation: switch (value['operation']) {
      'capabilities' => SemanticQueryOperation.capabilities,
      'list' => SemanticQueryOperation.list,
      'get' => SemanticQueryOperation.get,
      'relations' => SemanticQueryOperation.relations,
      'explain' => SemanticQueryOperation.explain,
      final operation => throw StateError('Unexpected operation: $operation'),
    },
    subjects: _strings(value['subjects']),
    recordKinds: _strings(value['record_kinds']),
    relationKinds: _strings(value['relation_kinds']),
    direction: switch (value['direction']) {
      'outgoing' => SemanticQueryDirection.outgoing,
      'incoming' => SemanticQueryDirection.incoming,
      'both' => SemanticQueryDirection.both,
      final direction => throw StateError('Unexpected direction: $direction'),
    },
    page: SemanticQueryPage(
      afterId: page['after_id'] as String?,
      limit: page['limit']! as int,
    ),
    budget: SemanticQueryBudget(
      maxRecords: budget['max_records']! as int,
      maxRelations: budget['max_relations']! as int,
      maxDepth: budget['max_depth']! as int,
    ),
    source: SemanticQuerySource(
      detail: switch (source['detail']) {
        'none' => SemanticSourceDetail.none,
        'identity' => SemanticSourceDetail.identity,
        'span' => SemanticSourceDetail.span,
        'text' => SemanticSourceDetail.text,
        final detail => throw StateError('Unexpected source detail: $detail'),
      },
      includeContentDigest: source['include_content_digest']! as bool,
    ),
  );
}

Future<ProcessResult> _runDart(
  Directory workingDirectory,
  List<String> arguments,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: workingDirectory.path,
  );
  expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  return result;
}

Map<String, Object?> _object(Object? value) =>
    (value! as Map).cast<String, Object?>();

List<Map<String, Object?>> _objects(Object? value) => [
  for (final row in value! as List<Object?>) _object(row),
];

List<String> _strings(Object? value) =>
    (value! as List<Object?>).cast<String>();

Map<String, Object?> _cloneMap(Map<String, Object?> value) =>
    _object(jsonDecode(jsonEncode(value)));

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
