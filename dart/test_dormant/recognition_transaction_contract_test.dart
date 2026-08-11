// FUTURE-PARITY-BACKLOG.14.3.4.0.1 — dormant Dart recognition-transaction RED.
//
// Ordinary `dart test` does not discover this pre-admission directory, and
// `analysis_options.yaml` excludes this exact file while its future private
// authority import is absent. Run the deliberate RED through project data:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test_dormant/recognition_transaction_contract_test.dart
//
// Private authority work removes the analyzer exclusion. Admission moves this
// unchanged consumer under ordinary discovery only after every test is GREEN.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/runtime/recognition_transaction.dart'
    as transaction;
import 'package:linkedspec_dart/src/runtime/source_location.dart' as typed;
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

final _JsonObject _contract = _readObject(
  '../capability_conformance/recognition_transaction_contract.json',
);

const _authoredSource = r'''
Top::AND
 => Child {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  if(matched) {
   payload = recognition_commit(tx)
   return(payload)
  } else {
   recognition_rollback(tx)
   return("miss")
  }
 }

Child::AND
 /x/
 E { return(false) }
''';

const _ordinaryCursorSource = r'''
Top::AND
 /a/ E {
  save_cursor()
  rewind_match_start()
  restore_cursor()
  return("ok")
 }
''';

void main() {
  test('neutral contract and dormant Dart rollout boundary are exact', () {
    expect(_contract['contract_id'], 'linkedspec-recognition-transaction-v1');
    expect(_contract['format'], 1);
    expect(
      _contract['status'],
      'neutral_perl_and_rust_complete_other_legs_red',
    );

    final counts = _object(_contract['expected_counts']);
    expect(counts, containsPair('current_action_ir_nodes', 128));
    expect(counts, containsPair('dedicated_action_ir_nodes', 4));
    expect(counts, containsPair('all_action_ir_nodes', 132));
    expect(counts, containsPair('canonical_call_contracts', 246));
    expect(counts, containsPair('token_positive_cases', 8));
    expect(counts, containsPair('token_negative_cases', 17));
    expect(counts, containsPair('effect_graph_cases', 6));
    expect(counts, containsPair('mark_cases', 6));
    expect(counts, containsPair('progress_cases', 8));
    expect(counts, containsPair('diagnostics', 15));
    expect(counts, containsPair('mutations', 42));

    expect(_object(_contract['authored_surface']), {
      'checkpoint': 'tx = recognition_checkpoint()',
      'attempt': 'matched = recognize_once(tx, call(Child))',
      'commit': 'payload = recognition_commit(tx)',
      'rollback': 'recognition_rollback(tx)',
      'operand':
          'recognize_once accepts exactly one unevaluated static call(Rule) operand',
      'result_separation':
          'recognize_once returns a strict match boolean; the recognized payload remains staged until commit',
      'availability':
          'available only in an admitted backend; currently Perl and Rust, with all later runtime legs future and unavailable',
    });

    final rollout = _objectRows('rollout');
    expect(rollout, hasLength(9));
    expect(rollout.take(3).map((row) => row['leg']), [
      'neutral',
      'perl',
      'rust',
    ]);
    expect(rollout.take(3).every((row) => row['status'] == 'complete'), isTrue);
    expect(rollout[3], {
      'order': 4,
      'owner': 'FUTURE-PARITY-BACKLOG.14.3.4',
      'leg': 'dart',
      'status': 'red',
      'paths': <Object?>[],
    });
    expect(rollout.skip(3).every((row) => row['status'] == 'red'), isTrue);
  });

  test(
    'invocation identities and same-label mark generations are isolated',
    () {
      final authority = _newAuthority('input.spec');
      final parent = authority.enterInvocation(
        rule: 'Top',
        origin: 'root',
        state: _initialState(),
      );
      authority.writeMark(parent, 'shared', 1);
      final parentSnapshot = _object(authority.frameSnapshot(parent).toJson());

      final child = authority.enterInvocation(
        rule: 'Top',
        origin: 'Top->Top',
        state: _state(3, 2, const <String, int>{}),
      );
      final childSnapshot = _object(authority.frameSnapshot(child).toJson());
      expect(
        childSnapshot['invocation']! as int,
        greaterThan(parentSnapshot['invocation']! as int),
      );
      expect(
        childSnapshot['generation']! as int,
        greaterThan(parentSnapshot['generation']! as int),
      );
      expect(authority.readMark(child, 'shared'), isNull);
      authority.writeMark(child, 'shared', 4);
      expect(authority.readMark(parent, 'shared'), 1);
      authority.leaveInvocation(child);

      final next = authority.enterInvocation(
        rule: 'Top',
        origin: 'Top->Top:next',
        state: _state(3, 2, const <String, int>{}),
      );
      final nextSnapshot = _object(authority.frameSnapshot(next).toJson());
      expect(
        nextSnapshot['invocation']! as int,
        greaterThan(childSnapshot['invocation']! as int),
      );
      expect(
        nextSnapshot['generation']! as int,
        greaterThan(childSnapshot['generation']! as int),
      );
      authority.leaveInvocation(next);

      final detachedMarks = _object(parentSnapshot['marks']);
      detachedMarks['shared'] = 99;
      expect(authority.readMark(parent, 'shared'), 1);
      authority.leaveInvocation(parent);
      _expectDiagnostic(
        'recognition_mark_generation_invalid',
        () => authority.frameSnapshot(parent),
        {
          'rule': 'Top',
          'origin': 'root',
          'generation': parentSnapshot['generation'],
        },
      );
    },
  );

  test('all eight positive tokens separate match from staged payload', () {
    for (final fixture in _fixtureRows('token_positive')) {
      final authority = _newAuthority('input.spec');
      final id = fixture['id']! as String;
      final frame = authority.enterInvocation(
        rule: 'Top',
        origin: id,
        state: _initialState(),
      );
      final token = authority.checkpoint(frame, id);
      final operations = _list(fixture['ops']).cast<String>();
      final attempt = operations.singleWhere(
        (operation) => operation.startsWith('attempt_'),
      );
      final matched = attempt != 'attempt_miss';
      final payload = matched ? _payloadFor(attempt) : null;
      expect(
        authority.attempt(
          frame,
          token,
          matched: matched,
          payload: payload,
          state: matched ? _stagedState() : _initialState(),
        ),
        matched,
        reason: '$id strict match',
      );

      if (operations.last == 'commit') {
        expect(
          authority.commit(frame, token),
          payload,
          reason: '$id committed payload',
        );
      } else {
        authority.rollback(frame, token);
      }
      authority.leaveInvocation(frame);
    }
  });

  test('commit retains and rollback restores cursor boundary and marks', () {
    for (final fixture in _fixtureRows('marks').take(2)) {
      final authority = _newAuthority('input.spec');
      final id = fixture['id']! as String;
      final frame = authority.enterInvocation(
        rule: 'Top',
        origin: id,
        state: _initialState(),
      );
      final token = authority.checkpoint(frame, id);
      authority.attempt(
        frame,
        token,
        matched: true,
        payload: 'payload',
        state: _stagedState(),
      );
      if (fixture['terminal'] == 'commit') {
        authority.commit(frame, token);
      } else {
        authority.rollback(frame, token);
      }
      final snapshot = _object(authority.frameSnapshot(frame).toJson());
      expect(
        {
          'cursor': snapshot['cursor'],
          'boundary': snapshot['boundary'],
          'marks': snapshot['marks'],
        },
        fixture['expected'],
        reason: '$id terminal state',
      );
      authority.leaveInvocation(frame);
    }
  });

  test('escape and lifecycle failures use exact portable diagnostics', () {
    const escapes = <String>{
      'copy',
      'comparison',
      'aggregate_storage',
      'function_storage',
      'codeblock_storage',
      'return',
      'capture',
      'serialization',
    };
    for (final fixture in _fixtureRows(
      'token_negative',
    ).where((row) => escapes.contains(row['violation']))) {
      final authority = _newAuthority('input.spec');
      final id = fixture['id']! as String;
      final escape = fixture['violation']! as String;
      final frame = authority.enterInvocation(
        rule: 'Top',
        origin: id,
        state: _initialState(),
      );
      final token = authority.checkpoint(frame, id);
      _expectDiagnostic(
        'recognition_token_escape',
        () => authority.rejectEscape(frame, token, escape),
        {'rule': 'Top', 'origin': id, 'escape': escape},
      );
      authority.leaveInvocation(frame);
    }

    final missingAuthority = _newAuthority('input.spec');
    final missingFrame = missingAuthority.enterInvocation(
      rule: 'Top',
      origin: 'missing_attempt',
      state: _initialState(),
    );
    final missingToken = missingAuthority.checkpoint(
      missingFrame,
      'missing_attempt',
    );
    _expectDiagnostic(
      'recognition_attempt_count',
      () => missingAuthority.rollback(missingFrame, missingToken),
      {'rule': 'Top', 'origin': 'missing_attempt', 'count': 0},
    );
    missingAuthority.leaveInvocation(missingFrame);

    final retryAuthority = _newAuthority('input.spec');
    final retryFrame = retryAuthority.enterInvocation(
      rule: 'Top',
      origin: 'retry',
      state: _initialState(),
    );
    final retryToken = retryAuthority.checkpoint(retryFrame, 'retry');
    retryAuthority.attempt(
      retryFrame,
      retryToken,
      matched: false,
      payload: null,
      state: _initialState(),
    );
    _expectDiagnostic(
      'recognition_attempt_count',
      () => retryAuthority.attempt(
        retryFrame,
        retryToken,
        matched: true,
        payload: 'value',
        state: _stagedState(),
      ),
      {'rule': 'Top', 'origin': 'retry', 'count': 2},
    );
    retryAuthority.leaveInvocation(retryFrame);
  });

  test('cross-owner nesting reuse unwind and discard restore exactly', () {
    final invocationAuthority = _newAuthority('input.spec');
    final parent = invocationAuthority.enterInvocation(
      rule: 'Top',
      origin: 'parent',
      state: _initialState(),
    );
    final parentToken = invocationAuthority.checkpoint(parent, 'parent');
    final child = invocationAuthority.enterInvocation(
      rule: 'Top',
      origin: 'child',
      state: _initialState(),
    );
    _expectDiagnostic(
      'recognition_cross_invocation',
      () => invocationAuthority.rollback(child, parentToken),
      {'rule': 'Top', 'origin': 'child'},
    );
    invocationAuthority.leaveInvocation(child);
    invocationAuthority.leaveInvocation(parent);

    final first = _newAuthority('first.spec');
    final firstFrame = first.enterInvocation(
      rule: 'Top',
      origin: 'cross_source',
      state: _initialState(),
    );
    final firstToken = first.checkpoint(firstFrame, 'cross_source');
    final second = _newAuthority('second.spec');
    final secondFrame = second.enterInvocation(
      rule: 'Top',
      origin: 'cross_source',
      state: _initialState(),
    );
    _expectDiagnostic(
      'recognition_cross_source',
      () => second.rollback(secondFrame, firstToken),
      {'rule': 'Top', 'origin': 'cross_source'},
    );
    second.leaveInvocation(secondFrame);
    first.leaveInvocation(firstFrame);

    final reuseAuthority = _newAuthority('input.spec');
    final reuseFrame = reuseAuthority.enterInvocation(
      rule: 'Top',
      origin: 'double_terminal',
      state: _initialState(),
    );
    final reuseToken = reuseAuthority.checkpoint(reuseFrame, 'double_terminal');
    reuseAuthority.attempt(
      reuseFrame,
      reuseToken,
      matched: true,
      payload: 'value',
      state: _stagedState(),
    );
    reuseAuthority.commit(reuseFrame, reuseToken);
    _expectDiagnostic(
      'recognition_token_reused',
      () => reuseAuthority.rollback(reuseFrame, reuseToken),
      {'rule': 'Top', 'origin': 'double_terminal', 'operation': 'rollback'},
    );
    reuseAuthority.leaveInvocation(reuseFrame);

    final nestingAuthority = _newAuthority('input.spec');
    final nestingParent = nestingAuthority.enterInvocation(
      rule: 'Top',
      origin: 'nesting_parent',
      state: _initialState(),
    );
    final before = _frameState(nestingAuthority, nestingParent);
    final nestingToken = nestingAuthority.checkpoint(
      nestingParent,
      'nesting_parent',
    );
    nestingAuthority.attempt(
      nestingParent,
      nestingToken,
      matched: true,
      payload: 'value',
      state: _stagedState(),
    );
    final nestingChild = nestingAuthority.enterInvocation(
      rule: 'Child',
      origin: 'nesting_child',
      state: _state(3, 2, const <String, int>{}),
    );
    _expectDiagnostic(
      'recognition_nesting_forbidden',
      () => nestingAuthority.checkpoint(nestingChild, 'nesting_child'),
      {'rule': 'Child', 'origin': 'nesting_child'},
    );
    expect(_frameState(nestingAuthority, nestingParent), before);
    nestingAuthority.leaveInvocation(nestingChild);
    nestingAuthority.leaveInvocation(nestingParent);

    final discardAuthority = _newAuthority('input.spec');
    final discardFrame = discardAuthority.enterInvocation(
      rule: 'Top',
      origin: 'discard',
      state: _initialState(),
    );
    final discardBefore = _frameState(discardAuthority, discardFrame);
    final discardToken = discardAuthority.checkpoint(discardFrame, 'discard');
    discardAuthority.attempt(
      discardFrame,
      discardToken,
      matched: true,
      payload: 'value',
      state: _stagedState(),
    );
    discardAuthority.discardToken(discardFrame, discardToken);
    expect(_frameState(discardAuthority, discardFrame), discardBefore);
    discardAuthority.leaveInvocation(discardFrame);

    final unwindAuthority = _newAuthority('input.spec');
    final unwindFrame = unwindAuthority.enterInvocation(
      rule: 'Top',
      origin: 'unwind',
      state: _initialState(),
    );
    final unwindToken = unwindAuthority.checkpoint(unwindFrame, 'unwind');
    unwindAuthority.attempt(
      unwindFrame,
      unwindToken,
      matched: true,
      payload: 'value',
      state: _stagedState(),
    );
    _expectDiagnostic(
      'recognition_terminal_required',
      () => unwindAuthority.leaveInvocation(unwindFrame),
      {'rule': 'Top', 'origin': 'unwind'},
    );
  });

  test('authored forms lower to four dedicated non-eager ActionIR nodes', () {
    final compiled = _compile(_authoredSource);
    final top = compiled.rule('Top')!;
    final payload = top.blindEdges.single.actionPayload!;
    final action = payload.actionAst.toJson();
    final expected = <String, int>{
      'recognition_checkpoint': 1,
      'recognize_once': 1,
      'recognition_commit': 1,
      'recognition_rollback': 1,
    };
    for (final entry in expected.entries) {
      expect(
        _mapsWithKind(action, entry.key),
        hasLength(entry.value),
        reason: 'one dedicated ${entry.key} node',
      );
    }
    final attempt = _mapsWithKind(action, 'recognize_once').single;
    expect(attempt, containsPair('token', 'tx'));
    expect(attempt, containsPair('rule', 'Child'));
    expect(
      _allMaps(
        action,
      ).where((node) => node['kind'] == 'call' && node['name'] == 'Child'),
      isEmpty,
      reason: 'call(Child) must remain unevaluated transaction structure',
    );
  });

  test('neutral effect closure and cursor-only progress are exact', () {
    final dynamic integration = _newAuthority('input.spec');
    for (final graph in _fixtureRows('effect_graphs')) {
      final accepted = graph['accepted']! as bool;
      if (accepted) {
        integration.classifyEffects(graph);
      } else {
        _expectDiagnostic(
          graph['diagnostic']! as String,
          () => integration.classifyEffects(graph),
          const <String, Object?>{},
        );
      }
    }
    for (final fixture in _fixtureRows('progress')) {
      final accepted = fixture['accepted']! as bool;
      if (accepted) {
        integration.validateProgress(fixture);
      } else {
        _expectDiagnostic(
          fixture['diagnostic']! as String,
          () => integration.validateProgress(fixture),
          const <String, Object?>{},
        );
      }
    }
  });

  test(
    'native reconstructed and generated-plan carriers keep false payload',
    () {
      final parsed = parseSpec(_authoredSource);
      validateSpec(parsed);
      final compiled = compileSpec(parsed);
      expect(
        LinkedSpecRuntimeEngine(compiled).parse('xx').value,
        isFalse,
        reason: 'native transaction carrier',
      );

      final reconstructed = SpecFile.fromJson(
        _object(jsonDecode(jsonEncode(parsed.toJson()))),
      );
      validateSpec(reconstructed);
      final reconstructedCompiled = compileSpec(reconstructed);
      expect(
        LinkedSpecRuntimeEngine(reconstructedCompiled).parse('xx').value,
        isFalse,
        reason: 'reconstructed transaction carrier',
      );
      expect(
        executeGeneratedParserV2(
          compiled,
          buildGeneratedRulePlan(compiled),
          'xx',
          'recognition-transaction/dart.spec',
        ),
        isFalse,
        reason: 'generated-plan transaction carrier',
      );

      final ordinary = _compile(_ordinaryCursorSource);
      expect(
        LinkedSpecRuntimeEngine(ordinary).parse('a').value,
        'ok',
        reason: 'nontransaction compatibility cursor stack',
      );
    },
  );

  test('freshly emitted source uses the same transaction runtime', () async {
    final compiled = _compile(_authoredSource);
    final emitted = emitDartSourceV2(
      compiled,
      'recognition-transaction/dart.spec',
    );
    final packageRoot = Directory.current.absolute;
    final scratch = Directory.systemTemp.createTempSync(
      'linkedspec-dart-recognition-transaction-',
    );
    final pubCache = Directory('${scratch.path}/pub-cache')..createSync();
    try {
      Directory('${scratch.path}/lib').createSync();
      Directory('${scratch.path}/bin').createSync();
      File('${scratch.path}/pubspec.yaml').writeAsStringSync('''
name: linkedspec_recognition_transaction_probe
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ${jsonEncode(packageRoot.path)}
''');
      File('${scratch.path}/lib/generated.dart').writeAsStringSync(emitted);
      File('${scratch.path}/bin/main.dart').writeAsStringSync(r'''
import 'dart:convert';

import 'package:linkedspec_recognition_transaction_probe/generated.dart'
    as generated;

void main() {
  final value = generated.execute('xx');
  if (value != false) {
    throw StateError('unexpected emitted transaction result: $value');
  }
  print(jsonEncode(value));
}
''');
      final environment = <String, String>{
        ...Platform.environment,
        'PUB_CACHE': pubCache.path,
      };
      await _expectProcessSuccess(scratch, environment, const [
        'pub',
        'get',
        '--offline',
      ]);
      await _expectProcessSuccess(scratch, environment, const [
        'analyze',
        '--fatal-infos',
        '--fatal-warnings',
      ]);
      final run = await _expectProcessSuccess(scratch, environment, const [
        'run',
        'bin/main.dart',
      ]);
      expect((run.stdout as String).trim(), 'false');
    } finally {
      scratch.deleteSync(recursive: true);
    }
  });
}

transaction.RecognitionTransactionAuthority _newAuthority(
  String sourceIdentity,
) => transaction.RecognitionTransactionAuthority(
  sourceAuthority: typed.SourceAuthority(
    sources: const <String, String>{'input': 'abcdef'},
  ),
  sourceIdentity: sourceIdentity,
);

transaction.RecognitionFrameState _state(
  int cursor,
  int? boundary,
  Map<String, int> marks,
) => transaction.RecognitionFrameState(
  cursor: cursor,
  boundary: boundary,
  marks: marks,
);

transaction.RecognitionFrameState _initialState() =>
    _state(2, 1, const <String, int>{'a': 1});

transaction.RecognitionFrameState _stagedState() =>
    _state(5, 4, const <String, int>{'a': 3, 'b': 4});

_JsonObject _frameState(dynamic authority, dynamic frame) {
  final snapshot = _object(authority.frameSnapshot(frame).toJson());
  return <String, Object?>{
    'cursor': snapshot['cursor'],
    'boundary': snapshot['boundary'],
    'marks': snapshot['marks'],
  };
}

void _expectDiagnostic(
  String code,
  Object? Function() operation,
  _JsonObject expected,
) {
  transaction.RecognitionTransactionException? captured;
  try {
    operation();
  } on transaction.RecognitionTransactionException catch (error) {
    captured = error;
  }
  expect(captured, isNotNull, reason: '$code must fail');
  final record = captured!.toJson();
  final fixture = _objectRows(
    'diagnostics',
  ).singleWhere((row) => row['code'] == code);
  expect(record.keys.toSet(), _list(fixture['fields']).cast<String>().toSet());
  expect(record['code'], code);
  for (final entry in expected.entries) {
    expect(record[entry.key], entry.value, reason: '$code ${entry.key}');
  }
  expect(captured.toString(), 'LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:$code');
}

Object? _payloadFor(String operation) => switch (operation) {
  'attempt_match:false' => false,
  'attempt_match:0' => 0,
  'attempt_match:' => '',
  'attempt_match:null' => null,
  'attempt_match:value' => 'value',
  _ => throw StateError('unowned matched-payload operation $operation'),
};

Iterable<_JsonObject> _allMaps(Object? value) sync* {
  if (value is Map) {
    final object = value.cast<String, Object?>();
    yield object;
    for (final child in object.values) {
      yield* _allMaps(child);
    }
  } else if (value is List) {
    for (final child in value) {
      yield* _allMaps(child);
    }
  }
}

List<_JsonObject> _mapsWithKind(Object? value, String kind) => _allMaps(
  value,
).where((node) => node['kind'] == kind).toList(growable: false);

CompiledSpec _compile(String source) {
  final parsed = parseSpec(source);
  validateSpec(parsed);
  return compileSpec(parsed);
}

Future<ProcessResult> _expectProcessSuccess(
  Directory workingDirectory,
  Map<String, String> environment,
  List<String> arguments,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: workingDirectory.path,
    environment: environment,
  );
  expect(
    result.exitCode,
    0,
    reason:
        'dart ${arguments.join(' ')} failed:\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}',
  );
  return result;
}

List<_JsonObject> _fixtureRows(String key) => _list(
  _object(_contract['fixtures'])[key],
).map(_object).toList(growable: false);

List<_JsonObject> _objectRows(String key) =>
    _list(_contract[key]).map(_object).toList(growable: false);

_JsonObject _readObject(String path) =>
    _object(jsonDecode(File(path).readAsStringSync()));

_JsonObject _object(Object? value) => (value! as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value! as List).cast<Object?>();
