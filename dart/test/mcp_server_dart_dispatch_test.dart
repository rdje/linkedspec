// FUTURE-PARITY-BACKLOG.10.9.4.1 — public Dart decoded MCP dispatch proof.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/mcp/mcp_server.dart'
    show McpServerTestHarness;
import 'package:test/test.dart';

const _dartServerName = 'linkedspec-semantic-dart';

void main() {
  test(
    'public static dispatch matches every owned canonical classification',
    () {
      final server = McpServer();
      for (final (requestId, responseId, dartIdentity) in [
        ('discover_request', 'discover_response_dart', false),
        ('tools_list_request', 'tools_list_response_perl', true),
        ('unsupported_version_request', 'unsupported_version_response', false),
        ('missing_metadata_request', 'missing_metadata_response', false),
        ('legacy_initialize_request', 'legacy_initialize_response', false),
        ('unknown_method_request', 'unknown_method_response', false),
        ('unknown_tool_request', 'unknown_tool_response', false),
        ('malformed_arguments_request', 'malformed_arguments_response', false),
      ]) {
        final request = _frame(requestId);
        final before = _canonical(request);
        final expected = dartIdentity
            ? _withDartIdentity(_frame(responseId))
            : _frame(responseId);
        expect(
          server.dispatch(request, utf8.encode('static-principal')),
          expected,
          reason: requestId,
        );
        expect(
          _canonical(request),
          before,
          reason: '$requestId clone isolation',
        );
      }

      expect(
        server.dispatch(
          _frame('legacy_initialized_notification'),
          utf8.encode('static-principal'),
        ),
        isNull,
      );
      expect(
        server.dispatch({
          'jsonrpc': '2.0',
          'method': 'notifications/host_private',
        }, utf8.encode('static-principal')),
        isNull,
      );
    },
  );

  test('registration preserves native identity and lowers policy only', () {
    final index = _graphIndex();
    var capabilityCalls = 0;
    var queryCalls = 0;
    var entropyByte = 0x42;
    final server = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, entropyByte++),
      nowMs: () => 1000,
      capabilitiesOf: (received) {
        expect(identical(received, index), isTrue);
        capabilityCalls += 1;
        return received.capabilities.toJson();
      },
      queryIndex: (received, request) {
        expect(identical(received, index), isTrue);
        queryCalls += 1;
        return received.queryNeutral(request).toJson();
      },
    );
    final handle = server.registerIndex(index, utf8.encode('native-principal'));
    expect(handle, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(capabilityCalls, 1);

    final capabilities = _withHandle(
      _frame('capabilities_call_request'),
      handle,
    );
    final capabilitiesBefore = _canonical(capabilities);
    expect(
      server.dispatch(capabilities, utf8.encode('native-principal')),
      _withDartIdentity(_frame('capabilities_call_response')),
    );
    expect(capabilityCalls, 2);
    expect(_canonical(capabilities), capabilitiesBefore);

    final query = _withHandle(_frame('query_call_request'), handle);
    final queryBefore = _canonical(query);
    expect(
      server.dispatch(query, utf8.encode('native-principal')),
      _withDartIdentity(_frame('query_call_response')),
    );
    expect(queryCalls, 1);
    expect(_canonical(query), queryBefore);

    final semanticError = _withHandle(
      _frame('semantic_ok_false_request'),
      handle,
    );
    expect(
      server.dispatch(semanticError, utf8.encode('native-principal')),
      _withDartIdentity(_frame('semantic_ok_false_response')),
    );
    expect(queryCalls, 2);

    final restricted = server.registerIndex(
      index,
      utf8.encode('restricted-principal'),
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
        utf8.encode('restricted-principal'),
      ),
      _withDartIdentity(_frame('restricted_capabilities_response')),
    );
    final beforeDenied = queryCalls;
    expect(
      server.dispatch(
        _withHandle(_frame('policy_denied_request'), restricted),
        utf8.encode('restricted-principal'),
      ),
      _withDartIdentity(_frame('policy_denied_response')),
    );
    expect(queryCalls, beforeDenied);

    final allowed = _withHandle(_frame('query_call_request'), restricted);
    final allowedRequest = _requestArguments(allowed);
    (allowedRequest['page']! as Map<String, Object?>)['limit'] = 50;
    allowedRequest['budget'] = {
      'max_records': 100,
      'max_relations': 200,
      'max_depth': 2,
    };
    final deniedCases = <Map<String, Object?>>[];
    final sourceDenied = _cloneMap(allowed);
    (_requestArguments(sourceDenied)['source']!
            as Map<String, Object?>)['detail'] =
        'span';
    deniedCases.add(sourceDenied);
    final digestDenied = _cloneMap(allowed);
    (_requestArguments(digestDenied)['source']!
            as Map<String, Object?>)['include_content_digest'] =
        true;
    deniedCases.add(digestDenied);
    final pageDenied = _cloneMap(allowed);
    (_requestArguments(pageDenied)['page']! as Map<String, Object?>)['limit'] =
        51;
    deniedCases.add(pageDenied);
    for (final (name, value) in [
      ('max_records', 101),
      ('max_relations', 201),
      ('max_depth', 3),
    ]) {
      final budgetDenied = _cloneMap(allowed);
      (_requestArguments(budgetDenied)['budget']!
              as Map<String, Object?>)[name] =
          value;
      deniedCases.add(budgetDenied);
    }
    final policyForEight = _withDartIdentity(_frame('policy_denied_response'))
      ..['id'] = 8;
    for (final deniedCase in deniedCases) {
      final beforePolicyDenial = queryCalls;
      expect(
        server.dispatch(deniedCase, utf8.encode('restricted-principal')),
        policyForEight,
      );
      expect(queryCalls, beforePolicyDenial);
    }

    for (final policy in const [
      McpDeploymentPolicy(pageMax: 1001),
      McpDeploymentPolicy(
        budgetMaxima: McpBudgetLimits(
          maxRecords: 10001,
          maxRelations: 2000,
          maxDepth: 4,
        ),
      ),
      McpDeploymentPolicy(
        budgetMaxima: McpBudgetLimits(
          maxRecords: -1,
          maxRelations: 1,
          maxDepth: 1,
        ),
      ),
    ]) {
      expect(
        () => server.registerIndex(
          index,
          utf8.encode('invalid-policy-principal'),
          options: McpRegistrationOptions(policy: policy),
        ),
        throwsA(_serverError('linkedspec_mcp_invalid_policy')),
      );
    }
  });

  test('unavailable states, validation, capacity, and shutdown are safe', () {
    final index = _graphIndex();
    final expectedUnavailable = _withDartIdentity(
      _frame('handle_unavailable_response'),
    );
    final unknown = _testServer(0x44);
    expect(
      unknown.dispatch(
        _frame('handle_unavailable_request'),
        utf8.encode('principal'),
      ),
      expectedUnavailable,
    );

    final unauthorized = _testServer(0x45);
    final unauthorizedHandle = unauthorized.registerIndex(
      index,
      utf8.encode('principal'),
    );
    expect(
      unauthorized.dispatch(
        _withHandle(_frame('handle_unavailable_request'), unauthorizedHandle),
        utf8.encode('wrong'),
      ),
      expectedUnavailable,
    );

    final clock = _ClockBox(1000);
    final expired = _testServer(0x46, clock: clock);
    final expiredHandle = expired.registerIndex(
      index,
      utf8.encode('principal'),
      options: const McpRegistrationOptions(lifetimeMs: 1),
    );
    clock.value = 1001;
    expect(
      expired.dispatch(
        _withHandle(_frame('handle_unavailable_request'), expiredHandle),
        utf8.encode('principal'),
      ),
      expectedUnavailable,
    );

    final revoked = _testServer(0x47);
    final revokedHandle = revoked.registerIndex(
      index,
      utf8.encode('principal'),
    );
    revoked.revokeHandle(revokedHandle);
    revoked.revokeHandle(revokedHandle);
    expect(
      revoked.dispatch(
        _withHandle(_frame('handle_unavailable_request'), revokedHandle),
        utf8.encode('principal'),
      ),
      expectedUnavailable,
    );

    for (final authorization in <List<int>>[
      [],
      List<int>.filled(4097, 0x61),
      [-1],
    ]) {
      expect(
        () => revoked.registerIndex(index, authorization),
        throwsA(_serverError('linkedspec_mcp_invalid_authorization')),
      );
    }
    for (final lifetime in [0, 86400001]) {
      expect(
        () => revoked.registerIndex(
          index,
          utf8.encode('principal'),
          options: McpRegistrationOptions(lifetimeMs: lifetime),
        ),
        throwsA(_serverError('linkedspec_mcp_invalid_registration')),
      );
    }

    final capacityClock = _ClockBox(2000);
    var entropyByte = 0x48;
    final capacity = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, entropyByte++),
      nowMs: () => capacityClock.value,
      maximumHandles: 1,
    );
    capacity.registerIndex(
      index,
      utf8.encode('principal'),
      options: const McpRegistrationOptions(lifetimeMs: 1),
    );
    expect(
      () => capacity.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_registry_full')),
    );
    capacityClock.value = 2001;
    expect(
      capacity.registerIndex(index, utf8.encode('principal')),
      matches(RegExp(r'^[A-Za-z0-9_-]{43}$')),
    );
    expect(McpServerTestHarness.registeredHandles(capacity), 1);
    capacity.shutdown();
    capacity.shutdown();
    expect(McpServerTestHarness.registeredHandles(capacity), 0);
    expect(
      capacity.dispatch(_frame('discover_request'), utf8.encode('principal')),
      containsPair('error', containsPair('code', -32603)),
    );
    expect(
      () => capacity.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_server_shutdown')),
    );
  });

  test('entropy and clock failures are bounded and sanitized', () {
    final index = _graphIndex();
    final shortEntropy = McpServerTestHarness.create(
      entropy: () => List<int>.filled(31, 0x49),
      nowMs: () => 0,
    );
    expect(
      () => shortEntropy.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_entropy_failure')),
    );

    final badClock = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, 0x4A),
      nowMs: () => throw StateError('host path /private/secret'),
    );
    expect(
      () => badClock.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_clock_failure')),
    );

    final collision = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, 0x4B),
      nowMs: () => 0,
      maximumHandles: 2,
      handleAttempts: 2,
    );
    collision.registerIndex(index, utf8.encode('principal'));
    expect(
      () => collision.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_entropy_failure')),
    );

    final overflowClock = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, 0x4D),
      nowMs: () => 0x7FFFFFFFFFFFFFFF,
    );
    expect(
      () => overflowClock.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_clock_failure')),
    );

    final invalidIndex = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, 0x4E),
      nowMs: () => 0,
      capabilitiesOf: (_) => {'host_private': true},
    );
    expect(
      () => invalidIndex.registerIndex(index, utf8.encode('principal')),
      throwsA(_serverError('linkedspec_mcp_invalid_index')),
    );

    final authorization = utf8.encode('copied-principal');
    final copiedAuthorization = McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, 0x4F),
      nowMs: () => 0,
    );
    final copiedHandle = copiedAuthorization.registerIndex(
      index,
      authorization,
    );
    authorization.fillRange(0, authorization.length, 0);
    expect(
      copiedAuthorization.dispatch(
        _withHandle(_frame('capabilities_call_request'), copiedHandle),
        utf8.encode('copied-principal'),
      ),
      _withDartIdentity(_frame('capabilities_call_response')),
    );

    final production = McpServer();
    expect(
      production.registerIndex(index, utf8.encode('principal')),
      matches(RegExp(r'^[A-Za-z0-9_-]{43}$')),
    );
  });

  test(
    'native failures are sanitized and cancellation suppresses preparation',
    () {
      final index = _graphIndex();
      var mode = 'normal';
      late McpServer server;
      server = McpServerTestHarness.create(
        entropy: () => List<int>.filled(32, 0x4C),
        nowMs: () => 0,
        capabilitiesOf: (received) {
          if (mode == 'throw') {
            throw StateError('host secret /private/path');
          }
          if (mode == 'invalid') {
            return {'host_private': true};
          }
          if (mode == 'cancel') {
            final cancel = _frame('cancelled_notification');
            final params = cancel['params']! as Map<String, Object?>;
            params['requestId'] = 7;
            server.dispatch(cancel, utf8.encode('principal'));
          }
          return received.capabilities.toJson();
        },
      );
      final handle = server.registerIndex(index, utf8.encode('principal'));
      final request = _withHandle(_frame('capabilities_call_request'), handle);
      final internal = _frame('sanitized_internal_error_response')..['id'] = 7;

      mode = 'throw';
      final thrown = server.dispatch(request, utf8.encode('principal'));
      expect(thrown, internal);
      expect(_canonical(thrown), isNot(contains('host secret')));
      expect(_canonical(thrown), isNot(contains('private/path')));

      mode = 'invalid';
      expect(server.dispatch(request, utf8.encode('principal')), internal);

      mode = 'cancel';
      expect(server.dispatch(request, utf8.encode('principal')), isNull);
      expect(McpServerTestHarness.activeRequests(server), 0);

      mode = 'normal';
      final completed = server.dispatch(request, utf8.encode('principal'));
      expect(
        completed,
        _withDartIdentity(_frame('capabilities_call_response')),
      );
      final lateCancel = _frame('cancelled_notification');
      final params = lateCancel['params']! as Map<String, Object?>;
      params['requestId'] = 7;
      expect(server.dispatch(lateCancel, utf8.encode('principal')), isNull);
      expect(
        completed,
        _withDartIdentity(_frame('capabilities_call_response')),
      );
    },
  );

  test('production authority stays native, in-process, and transport-only', () {
    final server = File('lib/src/mcp/mcp_server.dart').readAsStringSync();
    final runtime = File(
      'lib/src/mcp/mcp_contract_runtime.dart',
    ).readAsStringSync();
    final wire = File('lib/src/mcp/mcp_wire.dart').readAsStringSync();
    expect(server, contains("import 'dart:io' show IOSink;"));
    expect(server, contains("part 'mcp_wire.dart';"));
    expect(runtime, isNot(contains("import 'dart:io'")));
    expect(wire, isNot(contains("import 'dart:io'")));
    final production = '$server\n$runtime\n$wire';
    for (final forbidden in [
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
    final primary = File('bin/linkedspec_dart.dart').readAsStringSync();
    expect(primary, isNot(contains('McpServer')));
    expect(primary, isNot(contains('serveStdio')));
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    expect(pubspec.where((line) => line == 'dependencies:'), isEmpty);
  });
}

McpServer _testServer(int entropyByte, {_ClockBox? clock}) =>
    McpServerTestHarness.create(
      entropy: () => List<int>.filled(32, entropyByte),
      nowMs: () => clock?.value ?? 0,
    );

SemanticIndex _graphIndex() => SemanticIndex.fromUtf8(
  File(
    '../capability_conformance/semantic_introspection/graph.spec',
  ).readAsBytesSync(),
  options: const SemanticIndexOptions(
    logicalName: 'graph.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);

Map<String, Object?> _frame(String id) {
  final corpus =
      jsonDecode(
            File(
              '../capability_conformance/mcp_semantic_transport/corpus.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final rows = (corpus['frames']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final position = rows.indexWhere((row) => row['id'] == id);
  if (position < 0) {
    throw StateError('missing MCP frame $id');
  }
  final lines = File(
    '../capability_conformance/mcp_semantic_transport/canonical_frames.jsonl',
  ).readAsLinesSync();
  if (lines.length != rows.length) {
    throw StateError('canonical frame order is incomplete');
  }
  return (jsonDecode(lines[position])! as Map<String, Object?>);
}

Map<String, Object?> _withHandle(Map<String, Object?> request, String handle) {
  final params = request['params']! as Map<String, Object?>;
  final arguments = params['arguments']! as Map<String, Object?>;
  arguments['handle'] = handle;
  return request;
}

Map<String, Object?> _requestArguments(Map<String, Object?> request) {
  final params = request['params']! as Map<String, Object?>;
  final arguments = params['arguments']! as Map<String, Object?>;
  return arguments['request']! as Map<String, Object?>;
}

Map<String, Object?> _cloneMap(Map<String, Object?> value) =>
    jsonDecode(jsonEncode(value))! as Map<String, Object?>;

Map<String, Object?> _withDartIdentity(Map<String, Object?> response) {
  final result = response['result']! as Map<String, Object?>;
  final metadata = result['_meta']! as Map<String, Object?>;
  final server =
      metadata['io.modelcontextprotocol/serverInfo']! as Map<String, Object?>;
  server['name'] = _dartServerName;
  return response;
}

String _canonical(Object? value) => McpServerTestHarness.canonicalJson(value);

Matcher _serverError(String code) =>
    isA<McpServerError>().having((error) => error.code, 'code', code);

final class _ClockBox {
  _ClockBox(this.value);

  int value;
}
