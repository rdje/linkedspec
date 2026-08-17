// FUTURE-PARITY-BACKLOG.14.6.4.1 — private Dart progressive authority.
//
// Ordinary `dart test` discovery ignores test_dormant/. Run this focused proof
// through repository-local project data:
//
//   cd dart
//   bash ../tools/run_dart_project_data.sh test --reporter failures-only \
//     test_dormant/progressive_span_dispatch_authority_test.dart
//
// The separate final-path consumer remains intentionally RED until `.4.2`
// adds its dedicated node and four execution carriers.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/runtime/bounded_child_parse_authority.dart';
import 'package:test/test.dart';

typedef _JsonObject = Map<String, Object?>;

const _contractPath =
    '../capability_conformance/progressive_span_dispatch_contract.json';
const _ciDriverPath = '../tools/run_ci_local.sh';
const _origin = 'progressive_span_dispatch_authority';

final _JsonObject _contract = _object(
  jsonDecode(File(_contractPath).readAsStringSync()),
);

void main() {
  test('enforces every neutral authority case and all 26 diagnostics', () {
    final observed = <String, _JsonObject>{};

    final viewRegistry = _registry((request) {
      final text = request.sourceView.text;
      return <String, Object?>{
        'text': text,
        'offsets': <int>[
          for (var offset = 0; offset <= text.runes.length; offset += 1)
            request.sourceView.localToGlobal(offset),
        ],
      };
    });
    for (final row in _rows('view_cases')) {
      final token = ProgressiveCancellationToken();
      final invocation = viewRegistry.startInvocation(
        _invocationConfig(
          sourceId: row['authority_source_id']! as String,
          token: token,
          nowTick: 1,
          deadlineTick: 100,
          remainingSteps: 100,
        ),
      );
      if (row['accepted']! as bool) {
        final result = _object(
          invocation.dispatch(
            _arguments(
              parserId: 'expr-v1',
              topRule: 'Expr',
              span: row['span'],
              token: token,
              cost: 1,
            ),
          ),
        );
        expect(result['text'], row['view_text'], reason: row['id']! as String);
        expect(
          result['offsets'],
          row['local_to_global'],
          reason: row['id']! as String,
        );
      } else {
        expect(
          _remember(
            observed,
            () => invocation.dispatch(
              _arguments(
                parserId: 'expr-v1',
                topRule: 'Expr',
                span: row['span'],
                token: token,
                cost: 1,
              ),
            ),
          ),
          row['diagnostic'],
          reason: row['id']! as String,
        );
      }
    }

    for (final row in _rows('authority_cases')) {
      _JsonObject? effectiveSeen;
      final authorityRegistry = _registry((request) {
        effectiveSeen = request.effective.toJson();
        return false;
      });
      final token = ProgressiveCancellationToken();
      final entryId = row['entry_id']! as String;
      final arguments = _arguments(
        parserId: entryId,
        topRule: entryId == 'json-v1' ? 'Document' : 'Expr',
        span: <String, Object?>{
          'source_id': 'unicode',
          'start': 0,
          'end': 1,
          'provenance': 'authority-case',
        },
        token: token,
        cost: 1,
        callerCapabilities: _strings(row['caller_capabilities']),
        requiredCapabilities: _strings(row['required_capabilities']),
        callerCeilings: _ceilings(_object(row['caller_ceilings'])),
        requiredSourceDetail: ProgressiveSourceDetail.parse(
          row['required_source_detail']! as String,
        ),
      );
      final invocation = authorityRegistry.startInvocation(
        _invocationConfig(
          sourceId: 'unicode',
          token: token,
          nowTick: 1,
          deadlineTick: 100,
          remainingSteps: 100,
        ),
      );
      if (row['accepted']! as bool) {
        expect(
          invocation.dispatch(arguments),
          isFalse,
          reason: row['id']! as String,
        );
        expect(effectiveSeen, row['effective'], reason: row['id']! as String);
      } else {
        expect(
          _remember(observed, () => invocation.dispatch(arguments)),
          row['diagnostic'],
          reason: row['id']! as String,
        );
      }
    }

    final successRegistry = _registry((_) => true);
    for (final row in _rows('cancellation_cases')) {
      final token = ProgressiveCancellationToken();
      if (row['cancelled']! as bool) {
        token.cancel();
      }
      final childToken = row['token'] == row['child_token']
          ? token
          : ProgressiveCancellationToken();
      final invocation = successRegistry.startInvocation(
        _invocationConfig(
          sourceId: 'unicode',
          token: token,
          nowTick: row['now_tick']! as int,
          deadlineTick: row['deadline_tick']! as int,
          remainingSteps: row['remaining_steps']! as int,
        ),
      );
      final call = _arguments(
        parserId: 'expr-v1',
        topRule: 'Expr',
        span: <String, Object?>{
          'source_id': 'unicode',
          'start': 0,
          'end': 1,
          'provenance': 'safe-point',
        },
        token: childToken,
        cost: row['cost']! as int,
      );
      if (row['accepted']! as bool) {
        expect(invocation.dispatch(call), isTrue, reason: row['id']! as String);
      } else {
        expect(
          _remember(observed, () => invocation.dispatch(call)),
          row['diagnostic'],
          reason: row['id']! as String,
        );
      }
      expect(
        invocation.remainingSteps,
        row['remaining_after'],
        reason: row['id']! as String,
      );
    }

    for (final row in _rows('chain_cases')) {
      final candidate = _list(row['candidate']);
      final token = ProgressiveCancellationToken();
      final invocation = successRegistry.startInvocation(
        _invocationConfig(
          sourceId: candidate[2]! as String,
          token: token,
          nowTick: 1,
          deadlineTick: 100,
          remainingSteps: 100,
          maxDepth: row['max_depth']! as int,
          totalCalls: row['total_calls']! as int,
          maxCalls: row['max_calls']! as int,
          activeChain: _list(row['active']).map((value) {
            final frame = _list(value);
            return ProgressiveChainFrame(
              parserId: frame[0]! as String,
              topRule: frame[1]! as String,
              sourceId: frame[2]! as String,
              start: frame[3]! as int,
              end: frame[4]! as int,
            );
          }),
        ),
      );
      final call = _arguments(
        parserId: candidate[0],
        topRule: candidate[1],
        span: <String, Object?>{
          'source_id': candidate[2],
          'start': candidate[3],
          'end': candidate[4],
          'provenance': 'chain-case',
        },
        token: token,
        cost: 1,
      );
      if (row['accepted']! as bool) {
        expect(invocation.dispatch(call), isTrue, reason: row['id']! as String);
      } else {
        expect(
          _remember(observed, () => invocation.dispatch(call)),
          row['diagnostic'],
          reason: row['id']! as String,
        );
      }
    }

    for (final row in _rows('execution_cases')) {
      final childResult = row['child_result'];
      final executionRegistry = _registry((_) => childResult);
      final token = ProgressiveCancellationToken();
      final parentState = _deepCopy(row['parent_before']);
      final invocation = executionRegistry.startInvocation(
        _invocationConfig(
          sourceId: 'unicode',
          token: token,
          nowTick: 1,
          deadlineTick: 100,
          remainingSteps: row['budget_before']! as int,
        ),
      );
      final call = _arguments(
        parserId: 'expr-v1',
        topRule: 'Expr',
        span: <String, Object?>{
          'source_id': 'unicode',
          'start': 1,
          'end': 4,
          'provenance': 'execution-case',
        },
        token: token,
        cost: row['child_cost']! as int,
      );
      if (row['accepted']! as bool) {
        expect(
          invocation.dispatch(call),
          row['child_result'],
          reason: row['id']! as String,
        );
      } else {
        expect(
          _remember(observed, () => invocation.dispatch(call)),
          row['diagnostic'],
          reason: row['id']! as String,
        );
      }
      expect(parentState, row['parent_after'], reason: row['id']! as String);
      expect(
        invocation.remainingSteps,
        row['budget_after'],
        reason: row['id']! as String,
      );
    }

    final seamToken = ProgressiveCancellationToken();
    final seamInvocation = successRegistry.startInvocation(
      _invocationConfig(
        sourceId: 'unicode',
        token: seamToken,
        nowTick: 1,
        deadlineTick: 100,
        remainingSteps: 100,
      ),
    );
    final validSpan = <String, Object?>{
      'source_id': 'unicode',
      'start': 0,
      'end': 1,
      'provenance': 'seam',
    };
    final seamCalls = <ProgressiveDispatchArguments>[
      _arguments(
        parserId: 17,
        topRule: 'Expr',
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'BAD',
        topRule: 'Expr',
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'expr-v1',
        topRule: <Object?>[],
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'expr-v1',
        topRule: 'bad/rule',
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'expr-v1',
        topRule: 'Expr',
        span: 'copied',
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'missing-v1',
        topRule: 'Expr',
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'expr-v1',
        topRule: 'Document',
        span: validSpan,
        token: seamToken,
        cost: 1,
      ),
      _arguments(
        parserId: 'expr-v1',
        topRule: 'Expr',
        span: validSpan,
        token: seamToken,
        cost: 1,
        transactionActive: true,
      ),
    ];
    for (final call in seamCalls) {
      _remember(observed, () => seamInvocation.dispatch(call));
    }
    _remember(observed, () => successRegistry.register('expr-v1'));
    _remember(observed, () => successRegistry.load('expr-v1'));

    final diagnostics = <String, _JsonObject>{
      for (final row in _rows('diagnostics')) row['code']! as String: row,
    };
    expect(observed.keys.toSet(), diagnostics.keys.toSet());
    for (final entry in diagnostics.entries) {
      final record = observed[entry.key]!;
      for (final field in _strings(entry.value['required_context'])) {
        expect(record, contains(field), reason: '${entry.key} lacks $field');
      }
    }
  });

  test(
    'nested dispatch rebases typed values, shares limits, and expires views',
    () {
      ProgressiveSourceView? retained;
      ProgressiveDispatchRequest? retainedRequest;
      final token = ProgressiveCancellationToken();
      final nestedRegistry = _registry((request) {
        retained = request.sourceView;
        retainedRequest = request;
        final text = request.sourceView.text;
        if (text.runes.length > 3) {
          return request.dispatchNested(
            _arguments(
              parserId: 'expr-v1',
              topRule: 'Expr',
              span: <String, Object?>{
                'source_id': 'unicode',
                'start': 1,
                'end': 4,
                'provenance': 'nested',
              },
              token: token,
              cost: 3,
            ),
          );
        }
        return <String, Object?>{
          'text': text,
          'position': request.sourceView.rebasePosition(1),
          'span': request.sourceView.rebaseSpan(<String, Object?>{
            'source_id': 'unicode',
            'start': 0,
            'end': 2,
            'provenance': 'child-match',
          }),
          'diagnostic': request.sourceView.rebaseDiagnostic(<String, Object?>{
            'offset': 1,
            'span': <String, Object?>{
              'source_id': 'unicode',
              'start': 0,
              'end': 2,
              'provenance': 'child-diagnostic',
            },
          }),
          'effective': request.effective.toJson(),
        };
      });
      final invocation = nestedRegistry.startInvocation(
        _invocationConfig(
          sourceId: 'unicode',
          token: token,
          nowTick: 1,
          deadlineTick: 100,
          remainingSteps: 20,
          maxDepth: 4,
          maxCalls: 8,
        ),
      );
      final result = _object(
        invocation.dispatch(
          _arguments(
            parserId: 'expr-v1',
            topRule: 'Expr',
            span: <String, Object?>{
              'source_id': 'unicode',
              'start': 0,
              'end': 5,
              'provenance': 'outer',
            },
            token: token,
            cost: 2,
          ),
        ),
      );
      expect(result['text'], 'é🙂B');
      expect(_object(result['position'])['offset'], 2);
      expect(_object(result['span']), containsPair('start', 1));
      expect(_object(result['span']), containsPair('end', 3));
      final diagnostic = _object(result['diagnostic']);
      expect(diagnostic['offset'], 2);
      expect(_object(diagnostic['span'])['start'], 1);
      expect(_object(diagnostic['span'])['end'], 3);
      expect(invocation.remainingSteps, 15);
      expect(invocation.totalCalls, 2);
      expect(
        () => retained!.text,
        throwsA(
          isA<ProgressiveSourceViewException>().having(
            (error) => error.message,
            'message',
            contains('outside child execution'),
          ),
        ),
      );
      expect(
        () => retainedRequest!.dispatchNested(
          _arguments(
            parserId: 'expr-v1',
            topRule: 'Expr',
            span: <String, Object?>{
              'source_id': 'unicode',
              'start': 2,
              'end': 3,
              'provenance': 'expired-nested-authority',
            },
            token: token,
            cost: 1,
          ),
        ),
        throwsA(isA<ProgressiveSourceViewException>()),
        reason:
            'retained callbacks must not retain live nested-dispatch authority',
      );
    },
  );

  test('registry inputs and child results are deeply detached and bounded', () {
    final topRules = <String>['Expr'];
    final capabilities = <String>['typed-source-location-v1'];
    final resultSeed = <String, Object?>{
      'kind': 'seed',
      'items': <Object?>[1],
    };
    final entry = ProgressiveRegistryEntry(
      parserId: 'expr-v1',
      compiledAuthority: (_) => resultSeed,
      fingerprint:
          'sha256:1111111111111111111111111111111111111111111111111111111111111111',
      allowedTopRules: topRules,
      capabilities: capabilities,
      ceilings: ProgressiveCeilings(
        sourceDetail: ProgressiveSourceDetail.span,
        policyModes: <String>['deterministic'],
        maxSteps: 10,
        maxResultNodes: 16,
        maxDiagnosticBytes: 1024,
      ),
    );
    topRules[0] = 'Mutated';
    capabilities[0] = 'mutated';
    final registry = ProgressiveRegistry(
      entries: <ProgressiveRegistryEntry>[entry],
    );
    final token = ProgressiveCancellationToken();
    final invocation = registry.startInvocation(
      _invocationConfig(
        sourceId: 'unicode',
        token: token,
        nowTick: 1,
        deadlineTick: 100,
        remainingSteps: 10,
      ),
    );
    final call = _arguments(
      parserId: 'expr-v1',
      topRule: 'Expr',
      span: <String, Object?>{
        'source_id': 'unicode',
        'start': 0,
        'end': 1,
        'provenance': 'detachment',
      },
      token: token,
      cost: 1,
      callerCapabilities: <String>['typed-source-location-v1'],
      callerCeilings: ProgressiveCeilings(
        sourceDetail: ProgressiveSourceDetail.span,
        policyModes: <String>['deterministic'],
        maxSteps: 10,
        maxResultNodes: 16,
        maxDiagnosticBytes: 1024,
      ),
    );
    final detached = _object(invocation.dispatch(call));
    resultSeed['kind'] = 'mutated';
    _list(resultSeed['items']).add(2);
    expect(detached, <String, Object?>{
      'kind': 'seed',
      'items': <Object?>[1],
    });

    final oversized = _singleDispatch(
      callback: (_) => <Object?>[1, 2],
      callerCeilings: ProgressiveCeilings(
        sourceDetail: ProgressiveSourceDetail.span,
        policyModes: <String>['deterministic', 'fail-only'],
        maxSteps: 10,
        maxResultNodes: 2,
        maxDiagnosticBytes: 1024,
      ),
    );
    expect(
      () => oversized.$1.dispatch(oversized.$2),
      throwsA(
        isA<ProgressiveDispatchException>().having(
          (error) => error.code,
          'code',
          'progressive_result_not_detached',
        ),
      ),
    );

    final diagnostic = _singleDispatch(
      callback: (_) => throw 'éé',
      callerCeilings: ProgressiveCeilings(
        sourceDetail: ProgressiveSourceDetail.span,
        policyModes: <String>['deterministic', 'fail-only'],
        maxSteps: 10,
        maxResultNodes: 16,
        maxDiagnosticBytes: 1,
      ),
    );
    try {
      diagnostic.$1.dispatch(diagnostic.$2);
      fail('bounded child diagnostic must reject');
    } on ProgressiveDispatchException catch (error) {
      expect(error.code, 'progressive_child_failed');
      expect(error.toJson()['child_diagnostic'], '?');
    }

    final cycle = <String, Object?>{};
    cycle['child'] = cycle;
    final cyclic = _singleDispatch(callback: (_) => cycle);
    expect(
      () => cyclic.$1.dispatch(cyclic.$2),
      throwsA(
        isA<ProgressiveDispatchException>().having(
          (error) => error.code,
          'code',
          'progressive_result_not_detached',
        ),
      ),
    );
  });

  test(
    'private authority has no ActionIR, ordinary, canonical, or public route',
    () {
      final ciDriver = File(_ciDriverPath).readAsStringSync();
      final publicUmbrella = File(
        'lib/linkedspec_dart.dart',
      ).readAsStringSync();
      expect(
        File('test/progressive_span_dispatch_authority_test.dart').existsSync(),
        isFalse,
      );
      expect(
        ciDriver,
        isNot(contains('progressive_span_dispatch_authority_test')),
      );
      expect(publicUmbrella, isNot(contains('bounded_child_parse_authority')));
      expect(
        File(
          'test_dormant/progressive_span_dispatch_contract_test.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('lib/src/runtime/interpreter.dart').readAsStringSync(),
        isNot(contains('dispatch_bounded_child_parse')),
      );
    },
  );
}

ProgressiveRegistry _registry(ProgressiveCompiledAuthority callback) =>
    ProgressiveRegistry(
      entries: <ProgressiveRegistryEntry>[
        for (final row in _rows('registry_entries'))
          ProgressiveRegistryEntry(
            parserId: row['parser_id']! as String,
            compiledAuthority: callback,
            fingerprint: row['fingerprint']! as String,
            allowedTopRules: _strings(row['allowed_top_rules']),
            capabilities: _strings(row['capabilities']),
            ceilings: _ceilings(_object(row['ceilings'])),
          ),
      ],
    );

ProgressiveInvocationConfig _invocationConfig({
  required String sourceId,
  required ProgressiveCancellationToken token,
  required int nowTick,
  required int deadlineTick,
  required int remainingSteps,
  int maxDepth = 8,
  int totalCalls = 0,
  int maxCalls = 16,
  Iterable<ProgressiveChainFrame> activeChain = const <ProgressiveChainFrame>[],
}) => ProgressiveInvocationConfig(
  sources: <String, String>{
    for (final row in _rows('sources'))
      row['id']! as String: row['text']! as String,
  },
  sourceId: sourceId,
  cancellationToken: token,
  clock: ProgressiveClock(() => nowTick),
  deadlineTick: deadlineTick,
  remainingSteps: remainingSteps,
  maxDepth: maxDepth,
  maxCalls: maxCalls,
  activeChain: activeChain,
  totalCalls: totalCalls,
);

ProgressiveDispatchArguments _arguments({
  required Object? parserId,
  required Object? topRule,
  required Object? span,
  required ProgressiveCancellationToken token,
  required int cost,
  List<String>? callerCapabilities,
  List<String>? requiredCapabilities,
  ProgressiveCeilings? callerCeilings,
  ProgressiveSourceDetail requiredSourceDetail = ProgressiveSourceDetail.none,
  bool transactionActive = false,
}) => ProgressiveDispatchArguments(
  origin: _origin,
  parserId: parserId,
  topRule: topRule,
  span: span,
  callerCapabilities:
      callerCapabilities ??
      <String>[
        'actionir-v1',
        'caller-only',
        'structured-result-v1',
        'typed-source-location-v1',
      ],
  requiredCapabilities: requiredCapabilities ?? <String>[],
  callerCeilings: callerCeilings ?? _permissiveCeilings(),
  requiredSourceDetail: requiredSourceDetail,
  childToken: token,
  cost: cost,
  transactionActive: transactionActive,
);

ProgressiveCeilings _ceilings(_JsonObject value) => ProgressiveCeilings(
  sourceDetail: ProgressiveSourceDetail.parse(
    value['source_detail']! as String,
  ),
  policyModes: _strings(value['policy_modes']),
  maxSteps: value['max_steps']! as int,
  maxResultNodes: value['max_result_nodes']! as int,
  maxDiagnosticBytes: value['max_diagnostic_bytes']! as int,
);

ProgressiveCeilings _permissiveCeilings() => ProgressiveCeilings(
  sourceDetail: ProgressiveSourceDetail.text,
  policyModes: <String>['deterministic', 'fail-only', 'trace', 'strict-json'],
  maxSteps: 1000,
  maxResultNodes: 1000,
  maxDiagnosticBytes: 4096,
);

(ProgressiveInvocation, ProgressiveDispatchArguments) _singleDispatch({
  required ProgressiveCompiledAuthority callback,
  ProgressiveCeilings? callerCeilings,
}) {
  final registry = _registry(callback);
  final token = ProgressiveCancellationToken();
  final invocation = registry.startInvocation(
    _invocationConfig(
      sourceId: 'unicode',
      token: token,
      nowTick: 1,
      deadlineTick: 100,
      remainingSteps: 10,
    ),
  );
  return (
    invocation,
    _arguments(
      parserId: 'expr-v1',
      topRule: 'Expr',
      span: <String, Object?>{
        'source_id': 'unicode',
        'start': 0,
        'end': 1,
        'provenance': 'single-dispatch',
      },
      token: token,
      cost: 1,
      callerCeilings: callerCeilings,
    ),
  );
}

String _remember(
  Map<String, _JsonObject> observed,
  Object? Function() operation,
) {
  try {
    operation();
    fail('expected progressive dispatch failure');
  } on ProgressiveDispatchException catch (error) {
    observed[error.code] = error.toJson();
    return error.code;
  }
}

List<_JsonObject> _rows(String field) =>
    _list(_contract[field]).map(_object).toList(growable: false);

List<String> _strings(Object? value) =>
    _list(value).map((item) => item! as String).toList(growable: false);

Object? _deepCopy(Object? value) => jsonDecode(jsonEncode(value));

_JsonObject _object(Object? value) => (value! as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value! as List).cast<Object?>();
