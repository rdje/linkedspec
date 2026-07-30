// FUTURE-PARITY-BACKLOG.10.9.4.3 — exact twelve-role Dart MCP admission.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

const _roleOrder = <String>[
  'contract_inventory',
  'canonical_static_dispatch',
  'native_capabilities_identity',
  'native_query_identity',
  'raw_input_outcomes',
  'lifecycle_outcomes',
  'handle_state_indistinguishability',
  'policy_overlay',
  'cancellation_emission',
  'shutdown_and_io',
  'hostile_output_and_log_privacy',
  'authority_surface_fences',
];

const _rawIds = <String>[
  'invalid_utf8',
  'utf8_bom',
  'malformed_json',
  'duplicate_key',
  'overlong_line',
  'json_batch',
  'non_object',
  'invalid_boolean_id',
  'nesting_depth_65',
  'valid_crlf_discovery',
];

const _lifecycleIds = <String>[
  'ready_at_stream_loop_start',
  'cancel_before_response_emission',
  'cancel_unknown_request',
  'cancel_after_sync_completion',
  'legacy_initialized_notification',
  'stdout_discipline',
  'stderr_default',
  'registry_capacity',
  'graceful_eof',
  'unexpected_io_failure',
];

const _handleStates = <String>['unknown', 'expired', 'revoked', 'unauthorized'];

const _policyIds = <String>[
  'default_capabilities_identity',
  'restricted_capabilities_projection',
  'allowed_query_identity',
  'above_policy_pre_dispatch_denial',
];

const _dartServerName = 'linkedspec-semantic-dart';
const _ioLogRecord = 'linkedspec_mcp_io_failure\n';

void main() {
  test('exact Dart MCP admission executes every role once', () async {
    final rolesSeen = <String>[];

    await _admissionRole(rolesSeen, 'contract_inventory', () async {
      final corpus = _corpus();
      final frames = (corpus['frames']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(
        (corpus['canonical_order']! as List<Object?>).cast<String>(),
        frames.map((row) => row['id']).toList(),
      );
      expect(frames, hasLength(35));
      expect(
        (corpus['raw_inputs']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((row) => row['id'])
            .toList(),
        _rawIds,
      );
      expect(
        (corpus['lifecycle_cases']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((row) => row['id'])
            .toList(),
        _lifecycleIds,
      );
      expect(
        (corpus['handle_cases']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((row) => row['state'])
            .toList(),
        _handleStates,
      );
      expect(
        (corpus['policy_cases']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((row) => row['id'])
            .toList(),
        _policyIds,
      );

      final lines = _repoFile(
        'capability_conformance/mcp_semantic_transport/canonical_frames.jsonl',
      ).readAsLinesSync();
      expect(lines, hasLength(35));
      for (var index = 0; index < frames.length; index += 1) {
        expect(jsonEncode(jsonDecode(lines[index])), lines[index]);
      }
      final validator = _readObject(
        'capability_conformance/mcp_semantic_transport/validator_cases.json',
      );
      expect(
        validator['mutation_order'],
        isA<List<Object?>>().having((value) => value.length, 'length', 68),
      );
      final transport = _readObject(
        'capability_conformance/mcp_semantic_transport_contract.json',
      );
      expect(transport['contract_id'], 'linkedspec-mcp-transport-v1');
      expect(transport['protocol_version'], '2026-07-28');
    });

    await _admissionRole(rolesSeen, 'canonical_static_dispatch', () async {
      final server = McpServer();
      for (final (requestId, responseId, dartIdentity)
          in <(String, String, bool)>[
            ('discover_request', 'discover_response_dart', false),
            ('tools_list_request', 'tools_list_response_perl', true),
            (
              'unsupported_version_request',
              'unsupported_version_response',
              false,
            ),
            ('missing_metadata_request', 'missing_metadata_response', false),
            ('legacy_initialize_request', 'legacy_initialize_response', false),
            ('unknown_method_request', 'unknown_method_response', false),
            ('unknown_tool_request', 'unknown_tool_response', false),
            (
              'malformed_arguments_request',
              'malformed_arguments_response',
              false,
            ),
          ]) {
        final expected = dartIdentity
            ? _withDartIdentity(_frame(responseId))
            : _frame(responseId);
        expect(
          server.dispatch(_frame(requestId), utf8.encode('static-principal')),
          expected,
          reason: requestId,
        );
      }
      expect(
        server.dispatch(
          _frame('legacy_initialized_notification'),
          utf8.encode('static-principal'),
        ),
        isNull,
      );
      server.shutdown();
    });

    await _admissionRole(rolesSeen, 'native_capabilities_identity', () async {
      final index = _graphIndex();
      final native = index.capabilities.toJson();
      final server = McpServer();
      final handle = server.registerIndex(
        index,
        utf8.encode('capabilities-principal'),
      );
      final actual = server.dispatch(
        _withHandle(_frame('capabilities_call_request'), handle),
        utf8.encode('capabilities-principal'),
      )!;
      expect(actual, _withDartIdentity(_frame('capabilities_call_response')));
      final result = actual['result']! as Map<String, Object?>;
      expect(result['structuredContent'], native);
      final content = (result['content']! as List<Object?>).single;
      final text = (content! as Map<String, Object?>)['text']! as String;
      expect(jsonDecode(text), native);
      server.shutdown();
    });

    await _admissionRole(rolesSeen, 'native_query_identity', () async {
      final index = _graphIndex();
      final server = McpServer();
      final handle = server.registerIndex(
        index,
        utf8.encode('query-principal'),
      );
      final request = _withHandle(_frame('query_call_request'), handle);
      final arguments =
          (request['params']! as Map<String, Object?>)['arguments']!
              as Map<String, Object?>;
      final native = index.queryNeutral(arguments['request']).toJson();
      final actual = server.dispatch(request, utf8.encode('query-principal'))!;
      expect(actual, _withDartIdentity(_frame('query_call_response')));
      final result = actual['result']! as Map<String, Object?>;
      expect(result['structuredContent'], native);
      final content = (result['content']! as List<Object?>).single;
      final text = (content! as Map<String, Object?>)['text']! as String;
      expect(jsonDecode(text), native);
      server.shutdown();
    });

    await _admissionRole(rolesSeen, 'raw_input_outcomes', () async {
      final rows = (_corpus()['raw_inputs']! as List<Object?>)
          .cast<Map<String, Object?>>();
      for (final row in rows) {
        final id = row['id']! as String;
        final (output, log, outputClosed, logClosed) = await _runStream(
          McpServer(),
          Stream<List<int>>.value(_rawFixture(row)),
          'raw-principal',
        );
        final expected = id == 'valid_crlf_discovery'
            ? _frameBytes(_frame('discover_response_dart')..['id'] = 1)
            : _errorBytes(
                (row['expected']! as Map<String, Object?>)['code']! as int,
                (row['expected']! as Map<String, Object?>)['message']!
                    as String,
              );
        expect(output, expected, reason: id);
        expect(log, isEmpty, reason: '$id remains silent');
        expect(outputClosed, isFalse, reason: '$id output remains borrowed');
        expect(logClosed, isFalse, reason: '$id log remains borrowed');
      }
    });

    await _admissionRole(rolesSeen, 'lifecycle_outcomes', () async {
      final lifecycle = (_corpus()['lifecycle_cases']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(lifecycle, hasLength(10));
      expect(lifecycle.first['expected'], 'dispatch_without_handshake');

      final (ready, readyLog, _, _) = await _runStream(
        McpServer(),
        Stream<List<int>>.value(_frameBytes(_frame('discover_request'))),
        'ready-principal',
      );
      expect(ready, _frameBytes(_frame('discover_response_dart')));
      expect(ready, isNot(contains(0x0D)));
      expect(readyLog, isEmpty);

      final (unknownCancel, _, _, _) = await _runStream(
        McpServer(),
        Stream<List<int>>.value(_frameBytes(_frame('cancelled_notification'))),
        'cancel-principal',
      );
      expect(unknownCancel, isEmpty);

      final request = _frame('discover_request');
      final cancellation = _frame('cancelled_notification');
      (cancellation['params']! as Map<String, Object?>)['requestId'] =
          request['id'];
      final (lateCancel, _, _, _) = await _runStream(
        McpServer(),
        Stream<List<int>>.value(<int>[
          ..._frameBytes(request),
          ..._frameBytes(cancellation),
        ]),
        'cancel-principal',
      );
      expect(lateCancel, _frameBytes(_frame('discover_response_dart')));

      final (legacy, _, _, _) = await _runStream(
        McpServer(),
        Stream<List<int>>.value(
          _frameBytes(_frame('legacy_initialized_notification')),
        ),
        'legacy-principal',
      );
      expect(legacy, isEmpty);

      final transport = _readObject(
        'capability_conformance/mcp_semantic_transport_contract.json',
      );
      final registry = transport['handle_registry']! as Map<String, Object?>;
      final maximum = registry['default_maximum_live_handles']! as int;
      final index = _graphIndex();
      final capacity = McpServer();
      capacity.registerIndex(
        index,
        utf8.encode('capacity-principal'),
        options: const McpRegistrationOptions(lifetimeMs: 1),
      );
      await Future<void>.delayed(const Duration(milliseconds: 3));
      for (var count = 0; count < maximum; count += 1) {
        capacity.registerIndex(index, utf8.encode('capacity-principal'));
      }
      expect(
        () => capacity.registerIndex(index, utf8.encode('capacity-principal')),
        throwsA(_serverError('linkedspec_mcp_registry_full')),
      );
      capacity.shutdown();

      final graceful = McpServer();
      graceful.registerIndex(index, utf8.encode('eof-principal'));
      await graceful.serveStdio(
        const Stream<List<int>>.empty(),
        _SinkProbe().sink,
        utf8.encode('eof-principal'),
      );
      expect(
        () => graceful.registerIndex(index, utf8.encode('eof-principal')),
        throwsA(_serverError('linkedspec_mcp_server_shutdown')),
      );

      final failure = McpServer();
      final failureOutput = _SinkProbe();
      final failureLog = _SinkProbe();
      await expectLater(
        failure.serveStdio(
          Stream<List<int>>.error(StateError('private lifecycle failure')),
          failureOutput.sink,
          utf8.encode('failure-principal'),
          log: failureLog.sink,
        ),
        throwsA(_serverError('linkedspec_mcp_io_failure')),
      );
      expect(failureOutput.bytes, isEmpty);
      expect(failureLog.text, _ioLogRecord);
    });

    await _admissionRole(
      rolesSeen,
      'handle_state_indistinguishability',
      () async {
        final expected = _withDartIdentity(
          _frame('handle_unavailable_response'),
        );
        final index = _graphIndex();

        final unknown = McpServer();
        expect(
          unknown.dispatch(
            _frame('handle_unavailable_request'),
            utf8.encode('state-principal'),
          ),
          expected,
        );
        unknown.shutdown();

        final expired = McpServer();
        final expiredHandle = expired.registerIndex(
          index,
          utf8.encode('state-principal'),
          options: const McpRegistrationOptions(lifetimeMs: 1),
        );
        await Future<void>.delayed(const Duration(milliseconds: 3));
        expect(
          expired.dispatch(
            _withHandle(_frame('handle_unavailable_request'), expiredHandle),
            utf8.encode('state-principal'),
          ),
          expected,
        );
        expired.shutdown();

        final revoked = McpServer();
        final revokedHandle = revoked.registerIndex(
          index,
          utf8.encode('state-principal'),
        );
        revoked.revokeHandle(revokedHandle);
        expect(
          revoked.dispatch(
            _withHandle(_frame('handle_unavailable_request'), revokedHandle),
            utf8.encode('state-principal'),
          ),
          expected,
        );
        revoked.shutdown();

        final unauthorized = McpServer();
        final unauthorizedHandle = unauthorized.registerIndex(
          index,
          utf8.encode('state-principal'),
        );
        expect(
          unauthorized.dispatch(
            _withHandle(
              _frame('handle_unavailable_request'),
              unauthorizedHandle,
            ),
            utf8.encode('wrong-principal'),
          ),
          expected,
        );
        unauthorized.shutdown();
      },
    );

    await _admissionRole(rolesSeen, 'policy_overlay', () async {
      final index = _graphIndex();
      final server = McpServer();
      final defaultHandle = server.registerIndex(
        index,
        utf8.encode('default-policy-principal'),
      );
      expect(
        server.dispatch(
          _withHandle(_frame('capabilities_call_request'), defaultHandle),
          utf8.encode('default-policy-principal'),
        ),
        _withDartIdentity(_frame('capabilities_call_response')),
      );
      expect(
        server.dispatch(
          _withHandle(_frame('query_call_request'), defaultHandle),
          utf8.encode('default-policy-principal'),
        ),
        _withDartIdentity(_frame('query_call_response')),
      );

      final restricted = server.registerIndex(
        index,
        utf8.encode('restricted-policy-principal'),
        options: const McpRegistrationOptions(
          policy: McpDeploymentPolicy(
            sourceDetailCeiling: SemanticSourceDetail.identity,
            pageMax: 50,
            budgetMaxima: McpBudgetLimits(
              maxRecords: 100,
              maxRelations: 200,
              maxDepth: 2,
            ),
          ),
        ),
      );
      expect(
        server.dispatch(
          _withHandle(_frame('restricted_capabilities_request'), restricted),
          utf8.encode('restricted-policy-principal'),
        ),
        _withDartIdentity(_frame('restricted_capabilities_response')),
      );
      expect(
        server.dispatch(
          _withHandle(_frame('policy_denied_request'), restricted),
          utf8.encode('restricted-policy-principal'),
        ),
        _withDartIdentity(_frame('policy_denied_response')),
      );
      server.shutdown();
    });

    await _admissionRole(rolesSeen, 'cancellation_emission', () async {
      final lifecycle = (_corpus()['lifecycle_cases']! as List<Object?>)
          .cast<Map<String, Object?>>();
      final before = lifecycle.singleWhere(
        (row) => row['id'] == 'cancel_before_response_emission',
      );
      expect(before['expected'], 'stop_and_suppress_response');
      final focused = _repoFile(
        'dart/test/mcp_server_dart_stdio_test.dart',
      ).readAsStringSync();
      expect(focused, contains('beforeWireEmit:'));
      expect(focused, contains('expect(cancelledOutput.bytes, isEmpty);'));
      expect(focused, isNot(contains('skip:')));

      final request = _frame('discover_request');
      final cancel = _frame('cancelled_notification');
      (cancel['params']! as Map<String, Object?>)['requestId'] = request['id'];
      final (output, log, _, _) = await _runStream(
        McpServer(),
        Stream<List<int>>.value(<int>[
          ..._frameBytes(request),
          ..._frameBytes(cancel),
        ]),
        'emission-principal',
      );
      expect(output, _frameBytes(_frame('discover_response_dart')));
      expect(log, isEmpty);
    });

    await _admissionRole(rolesSeen, 'shutdown_and_io', () async {
      final complete = _frameBytes(_frame('discover_request'));
      final later = McpServer();
      final laterOutput = _SinkProbe();
      final laterLog = _SinkProbe();
      await expectLater(
        later.serveStdio(
          _chunkThenFail(complete),
          laterOutput.sink,
          utf8.encode('later-failure-principal'),
          log: laterLog.sink,
        ),
        throwsA(_serverError('linkedspec_mcp_io_failure')),
      );
      expect(laterOutput.bytes, _frameBytes(_frame('discover_response_dart')));
      expect(laterLog.text, _ioLogRecord);
      expect(laterOutput.closed, isFalse);
      expect(laterLog.closed, isFalse);

      final index = _graphIndex();
      final outputFailure = McpServer();
      outputFailure.registerIndex(
        index,
        utf8.encode('write-failure-principal'),
      );
      final brokenOutput = _SinkProbe(failAdd: true);
      final outputLog = _SinkProbe();
      await expectLater(
        outputFailure.serveStdio(
          Stream<List<int>>.value(complete),
          brokenOutput.sink,
          utf8.encode('write-failure-principal'),
          log: outputLog.sink,
        ),
        throwsA(_serverError('linkedspec_mcp_io_failure')),
      );
      expect(outputLog.text, _ioLogRecord);
      expect(
        () => outputFailure.registerIndex(
          index,
          utf8.encode('write-failure-principal'),
        ),
        throwsA(_serverError('linkedspec_mcp_server_shutdown')),
      );
    });

    await _admissionRole(rolesSeen, 'hostile_output_and_log_privacy', () async {
      const secret = 'private=/private/secret handle=opaque auth=principal';
      final server = McpServer();
      final output = _SinkProbe();
      final log = _SinkProbe();
      Object? failure;
      try {
        await server.serveStdio(
          Stream<List<int>>.error(StateError(secret)),
          output.sink,
          utf8.encode('hostile-principal'),
          log: log.sink,
        );
      } on Object catch (error) {
        failure = error;
      }
      expect(failure, _serverError('linkedspec_mcp_io_failure'));
      expect(output.bytes, isEmpty);
      expect(log.text, _ioLogRecord);
      final exposed = '${output.text}${log.text}$failure';
      for (final forbidden in <String>[
        'private/',
        'secret',
        'handle=',
        'auth=',
        'principal',
      ]) {
        expect(exposed, isNot(contains(forbidden)), reason: forbidden);
      }

      final nativeFocused = _repoFile(
        'dart/test/mcp_server_dart_dispatch_test.dart',
      ).readAsStringSync();
      expect(
        nativeFocused,
        contains(
          'native failures are sanitized and cancellation suppresses preparation',
        ),
      );
      expect(nativeFocused, contains("mode = 'throw';"));
      expect(nativeFocused, isNot(contains('skip:')));
    });

    await _admissionRole(rolesSeen, 'authority_surface_fences', () async {
      final sources = <String, String>{
        for (final path in <String>[
          'dart/lib/src/mcp/mcp_contract.dart',
          'dart/lib/src/mcp/mcp_contract_runtime.dart',
          'dart/lib/src/mcp/mcp_server.dart',
          'dart/lib/src/mcp/mcp_wire.dart',
        ])
          path: _repoFile(path).readAsStringSync(),
      };
      expect(
        sources['dart/lib/src/mcp/mcp_server.dart'],
        contains("import 'dart:io' show IOSink;"),
      );
      for (final entry in sources.entries) {
        if (entry.key != 'dart/lib/src/mcp/mcp_server.dart') {
          expect(entry.value, isNot(contains("import 'dart:io'")));
        }
      }
      final production = sources.values.join('\n');
      for (final forbidden in <String>[
        "import 'dart:ffi'",
        "import 'dart:isolate'",
        'File(',
        'Directory(',
        'Process.',
        'Socket',
        'HttpClient',
        'parseSpec(',
        'compileSpec(',
        'loadSpec(',
        'LinkedSpecRuntimeEngine',
        'LINKEDSPEC_TRACE_LEVEL',
        'emitDartSource',
      ]) {
        expect(production, isNot(contains(forbidden)), reason: forbidden);
      }
      final umbrella = _repoFile(
        'dart/lib/linkedspec_dart.dart',
      ).readAsStringSync();
      expect(umbrella, contains("export 'src/mcp/mcp_server.dart'"));
      for (final forbidden in <String>[
        'loadSource',
        'openSource',
        'semanticIndexFromPath',
        'serveNetwork',
      ]) {
        expect(umbrella, isNot(contains(forbidden)), reason: forbidden);
      }
      final primary = _repoFile(
        'dart/bin/linkedspec_dart.dart',
      ).readAsStringSync();
      expect(primary, isNot(contains('McpServer')));
      expect(primary, isNot(contains('serveStdio')));
      final pubspec = _repoFile('dart/pubspec.yaml').readAsLinesSync();
      expect(pubspec.where((line) => line == 'dependencies:'), isEmpty);
    });

    expect(rolesSeen, _roleOrder);
  });
}

Future<void> _admissionRole(
  List<String> rolesSeen,
  String role,
  FutureOr<void> Function() proof,
) async {
  rolesSeen.add(role);
  await proof();
}

Directory get _repositoryRoot {
  final path = Platform.environment['LINKEDSPEC_REPO_ROOT'];
  if (path == null || path.isEmpty) {
    throw StateError(
      'LINKEDSPEC_REPO_ROOT is required by the project-data gate',
    );
  }
  return Directory(path);
}

File _repoFile(String rootRelativePath) =>
    File('${_repositoryRoot.path}/$rootRelativePath');

Map<String, Object?> _readObject(String rootRelativePath) =>
    jsonDecode(_repoFile(rootRelativePath).readAsStringSync())!
        as Map<String, Object?>;

Map<String, Object?> _corpus() =>
    _readObject('capability_conformance/mcp_semantic_transport/corpus.json');

Map<String, Object?> _frame(String id) {
  final rows = (_corpus()['frames']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final position = rows.indexWhere((row) => row['id'] == id);
  if (position < 0) {
    throw StateError('missing MCP frame $id');
  }
  final lines = _repoFile(
    'capability_conformance/mcp_semantic_transport/canonical_frames.jsonl',
  ).readAsLinesSync();
  if (lines.length != rows.length) {
    throw StateError('canonical frame order is incomplete');
  }
  return jsonDecode(lines[position])! as Map<String, Object?>;
}

SemanticIndex _graphIndex() => SemanticIndex.fromUtf8(
  _repoFile(
    'capability_conformance/semantic_introspection/graph.spec',
  ).readAsBytesSync(),
  options: const SemanticIndexOptions(
    logicalName: 'graph.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);

Map<String, Object?> _withHandle(Map<String, Object?> request, String handle) {
  final params = request['params']! as Map<String, Object?>;
  final arguments = params['arguments']! as Map<String, Object?>;
  arguments['handle'] = handle;
  return request;
}

Map<String, Object?> _withDartIdentity(Map<String, Object?> response) {
  final result = response['result']! as Map<String, Object?>;
  final metadata = result['_meta']! as Map<String, Object?>;
  final server =
      metadata['io.modelcontextprotocol/serverInfo']! as Map<String, Object?>;
  server['name'] = _dartServerName;
  return response;
}

List<int> _frameBytes(Map<String, Object?> value) =>
    utf8.encode('${jsonEncode(value)}\n');

List<int> _errorBytes(int code, String message) => _frameBytes({
  'error': {'code': code, 'message': message},
  'id': null,
  'jsonrpc': '2.0',
});

List<int> _rawFixture(Map<String, Object?> row) {
  switch (row['encoding']) {
    case 'hex':
      return _decodeHex(row['data']! as String);
    case 'utf8':
      return utf8.encode(row['data']! as String);
    case 'repeat_hex':
      return <int>[
        ...List<int>.filled(
          row['count']! as int,
          _decodeHex(row['byte']! as String).single,
        ),
        ..._decodeHex(row['suffix']! as String),
      ];
    case 'nested_json':
      final depth = row['depth']! as int;
      return <int>[
        ...List<int>.filled(depth, 0x5B),
        0x30,
        ...List<int>.filled(depth, 0x5D),
        0x0A,
      ];
  }
  throw StateError('unknown raw fixture encoding ${row['encoding']}');
}

List<int> _decodeHex(String hex) {
  if (hex.length.isOdd) {
    throw StateError('hex fixture has a partial byte');
  }
  return <int>[
    for (var offset = 0; offset < hex.length; offset += 2)
      int.parse(hex.substring(offset, offset + 2), radix: 16),
  ];
}

Future<(List<int>, List<int>, bool, bool)> _runStream(
  McpServer server,
  Stream<List<int>> input,
  String authorization,
) async {
  final output = _SinkProbe();
  final log = _SinkProbe();
  await server.serveStdio(
    input,
    output.sink,
    utf8.encode(authorization),
    log: log.sink,
  );
  return (output.bytes, log.bytes, output.closed, log.closed);
}

Stream<List<int>> _chunkThenFail(List<int> chunk) async* {
  yield chunk;
  throw StateError('private later input failure');
}

Matcher _serverError(String code) =>
    isA<McpServerError>().having((error) => error.code, 'code', code);

final class _SinkProbe implements StreamConsumer<List<int>> {
  factory _SinkProbe({bool failAdd = false}) {
    final result = _SinkProbe._(failAdd);
    result.sink = IOSink(result);
    return result;
  }

  _SinkProbe._(this.failAdd);

  final bool failAdd;
  late final IOSink sink;
  final BytesBuilder _bytes = BytesBuilder(copy: false);
  bool closed = false;

  List<int> get bytes => _bytes.toBytes();

  String get text => utf8.decode(bytes);

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    if (failAdd) {
      throw StateError('private sink path and response');
    }
    await for (final chunk in stream) {
      _bytes.add(chunk);
    }
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}
