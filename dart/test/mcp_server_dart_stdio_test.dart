// FUTURE-PARITY-BACKLOG.10.9.4.2 — public Dart MCP stdio/lifecycle proof.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:linkedspec_dart/src/mcp/mcp_server.dart'
    show McpServerTestHarness;
import 'package:test/test.dart';

const _dartServerName = 'linkedspec-semantic-dart';
const _ioLogRecord = 'linkedspec_mcp_io_failure\n';

void main() {
  test('public stdio matches every neutral raw classification', () async {
    final corpus = _corpus();
    for (final row
        in (corpus['raw_inputs']! as List<Object?>)
            .cast<Map<String, Object?>>()) {
      final id = row['id']! as String;
      final server = McpServer();
      final output = _SinkProbe();
      final log = _SinkProbe();
      await server.serveStdio(
        Stream<List<int>>.value(_rawFixture(row)),
        output.sink,
        utf8.encode('raw-principal'),
        log: log.sink,
      );
      expect(log.bytes, isEmpty, reason: '$id is operationally silent');
      final expected = id == 'valid_crlf_discovery'
          ? _frameBytes(_frame('discover_response_dart')..['id'] = 1)
          : _errorBytes(
              (row['expected']! as Map<String, Object?>)['code']! as int,
              (row['expected']! as Map<String, Object?>)['message']! as String,
            );
      expect(output.bytes, expected, reason: '$id exact canonical bytes');
      expect(output.closed, isFalse, reason: '$id output remains caller-owned');
      expect(log.closed, isFalse, reason: '$id log remains caller-owned');
      expect(McpServerTestHarness.registeredHandles(server), 0);
    }
  });

  test(
    'lexical identity, depth, number, id, and line limits are exact',
    () async {
      for (final bytes in <List<int>>[
        utf8.encode(
          '{"\\u0069d":1,"id":2,"jsonrpc":"2.0",'
          '"method":"server/discover","params":{}}\n',
        ),
        utf8.encode(
          '{"id":1,"jsonrpc":"2.0","method":"server/discover",'
          '"params":{"x":{"a":1,"\\u0061":2}}}\n',
        ),
        utf8.encode(
          '{"id":"\\uD800","jsonrpc":"2.0",'
          '"method":"server/discover","params":{}}\n',
        ),
        utf8.encode(
          '{"id":NaN,"jsonrpc":"2.0",'
          '"method":"server/discover","params":{}}\n',
        ),
        utf8.encode(
          '{"id":1,"jsonrpc":"2.0","method":"server/discover",'
          '"params":{"value":1e999}}\n',
        ),
        <int>[0x0A],
      ]) {
        expect(await _outputFor(bytes), _errorBytes(-32700, 'Parse error'));
      }

      final depth64 = <int>[
        ...List<int>.filled(64, 0x5B),
        0x30,
        ...List<int>.filled(64, 0x5D),
        0x0A,
      ];
      expect(await _outputFor(depth64), _errorBytes(-32600, 'Invalid Request'));

      final discover = _frame('discover_request');
      final maximum = <int>[
        ...utf8.encode(McpServerTestHarness.canonicalJson(discover)),
      ];
      maximum.addAll(List<int>.filled(1048576 - maximum.length, 0x20));
      maximum.addAll(<int>[0x0D, 0x0A]);
      expect(
        await _outputFor(maximum),
        _frameBytes(_frame('discover_response_dart')),
      );

      for (final id in <String>[
        '1.0',
        '1e0',
        '9007199254740992',
        '-9007199254740992',
        'null',
      ]) {
        expect(
          await _outputFor(
            utf8.encode(
              '{"id":$id,"jsonrpc":"2.0",'
              '"method":"server/discover","params":{}}\n',
            ),
          ),
          _errorBytes(-32600, 'Invalid Request'),
          reason: id,
        );
      }
      for (final id in <int>[-9007199254740991, 9007199254740991]) {
        final request = _frame('discover_request')..['id'] = id;
        final expected = _frame('discover_response_dart')..['id'] = id;
        expect(await _outputFor(_frameBytes(request)), _frameBytes(expected));
      }
      for (final (characters, accepted) in <(int, bool)>[
        (64, true),
        (65, false),
      ]) {
        final id = List<String>.filled(characters, 'é').join();
        final request = _frame('discover_request')..['id'] = id;
        final output = await _outputFor(_frameBytes(request));
        final expected = accepted
            ? _frameBytes(_frame('discover_response_dart')..['id'] = id)
            : _errorBytes(-32600, 'Invalid Request');
        expect(output, expected);
        if (accepted) {
          expect(utf8.decode(output), isNot(contains(r'\u00e9')));
        }
      }
    },
  );

  test(
    'framing recovers, canonical responses flush, and cancellation is exact',
    () async {
      final list = _frame('tools_list_request');
      final expectedList = _frameBytes(
        _withDartIdentity(_frame('tools_list_response_perl')),
      );
      expect(
        await _outputFor(<int>[...utf8.encode('{\n'), ..._frameBytes(list)]),
        <int>[..._errorBytes(-32700, 'Parse error'), ...expectedList],
      );
      expect(
        await _outputFor(<int>[
          ...List<int>.filled(1048577, 0x78),
          0x0A,
          ..._frameBytes(list),
        ]),
        <int>[..._errorBytes(-32700, 'Parse error'), ...expectedList],
      );
      expect(
        await _outputFor(List<int>.filled(1048577, 0x78)),
        _errorBytes(-32700, 'Parse error'),
      );

      final finalRequest = _frame('discover_request')..['id'] = 'réq';
      final noNewline = <int>[..._frameBytes(finalRequest)]..removeLast();
      expect(
        await _outputFor(noNewline),
        _frameBytes(_frame('discover_response_dart')..['id'] = 'réq'),
      );

      final index = _graphIndex();
      final server = _testServer();
      final handle = server.registerIndex(index, utf8.encode('wire-principal'));
      final requests = <Map<String, Object?>>[
        _frame('discover_request'),
        list,
        _withHandle(_frame('capabilities_call_request'), handle),
        _withHandle(_frame('query_call_request'), handle),
        _frame('legacy_initialized_notification'),
      ];
      final wire = <int>[];
      for (final request in requests) {
        wire.addAll(_frameBytes(request));
      }
      final chunks = _splitBytes(wire, <int>[1, 7, 65535, 3, 29]);
      final output = _SinkProbe();
      await server.serveStdio(
        Stream<List<int>>.fromIterable(chunks),
        output.sink,
        utf8.encode('wire-principal'),
      );
      final expected = <int>[];
      for (final response in <Map<String, Object?>>[
        _frame('discover_response_dart'),
        _withDartIdentity(_frame('tools_list_response_perl')),
        _withDartIdentity(_frame('capabilities_call_response')),
        _withDartIdentity(_frame('query_call_response')),
      ]) {
        expected.addAll(_frameBytes(response));
      }
      expect(output.bytes, expected);
      expect(output.bytes, isNot(contains(0x0D)));
      expect(McpServerTestHarness.registeredHandles(server), 0);
      expect(McpServerTestHarness.activeRequests(server), 0);

      late List<int> cancellationAuthorization;
      var cancelled = false;
      final cancellationServer = McpServerTestHarness.create(
        entropy: () => List<int>.filled(32, 0x5A),
        nowMs: () => 10000,
        beforeWireEmit: (activeServer, prepared) {
          if (prepared == null || cancelled) {
            return;
          }
          cancelled = true;
          final cancel = _frame('cancelled_notification');
          (cancel['params']! as Map<String, Object?>)['requestId'] = jsonDecode(
            prepared,
          );
          expect(
            activeServer.dispatch(cancel, cancellationAuthorization),
            isNull,
          );
        },
      );
      cancellationAuthorization = utf8.encode('cancel-principal');
      final cancelledOutput = _SinkProbe();
      await cancellationServer.serveStdio(
        Stream<List<int>>.value(_frameBytes(_frame('discover_request'))),
        cancelledOutput.sink,
        cancellationAuthorization,
      );
      expect(cancelled, isTrue);
      expect(cancelledOutput.bytes, isEmpty);
      expect(McpServerTestHarness.activeRequests(cancellationServer), 0);

      final lateServer = _testServer();
      final request = _frame('discover_request');
      final cancel = _frame('cancelled_notification');
      (cancel['params']! as Map<String, Object?>)['requestId'] = request['id'];
      expect(
        await _outputFor(<int>[
          ..._frameBytes(request),
          ..._frameBytes(cancel),
        ], server: lateServer),
        _frameBytes(_frame('discover_response_dart')),
      );
    },
  );

  test('EOF and every hostile I/O path release and sanitize', () async {
    final clean = _testServer();
    clean.registerIndex(_graphIndex(), utf8.encode('clean-release-principal'));
    final cleanOutput = _SinkProbe();
    await clean.serveStdio(
      const Stream<List<int>>.empty(),
      cleanOutput.sink,
      utf8.encode('clean-release-principal'),
    );
    expect(McpServerTestHarness.registeredHandles(clean), 0);
    expect(cleanOutput.closed, isFalse);
    expect(
      () => clean.serveStdio(
        const Stream<List<int>>.empty(),
        _SinkProbe().sink,
        utf8.encode('clean-release-principal'),
      ),
      throwsA(_serverError('linkedspec_mcp_server_shutdown')),
    );

    final inputFailure = _testServer();
    inputFailure.registerIndex(
      _graphIndex(),
      utf8.encode('input-private-principal'),
    );
    final inputOutput = _SinkProbe();
    final inputLog = _SinkProbe();
    await expectLater(
      inputFailure.serveStdio(
        Stream<List<int>>.error(
          StateError('private input path and authorization'),
        ),
        inputOutput.sink,
        utf8.encode('input-private-principal'),
        log: inputLog.sink,
      ),
      throwsA(_serverError('linkedspec_mcp_io_failure')),
    );
    expect(inputOutput.bytes, isEmpty);
    expect(inputLog.text, _ioLogRecord);
    expect(McpServerTestHarness.registeredHandles(inputFailure), 0);

    final laterFailure = _testServer();
    final laterOutput = _SinkProbe();
    final laterLog = _SinkProbe();
    await expectLater(
      laterFailure.serveStdio(
        _chunkThenFail(_frameBytes(_frame('discover_request'))),
        laterOutput.sink,
        utf8.encode('later-private-principal'),
        log: laterLog.sink,
      ),
      throwsA(_serverError('linkedspec_mcp_io_failure')),
    );
    expect(laterOutput.bytes, _frameBytes(_frame('discover_response_dart')));
    expect(laterLog.text, _ioLogRecord);

    final outputFailure = _testServer();
    outputFailure.registerIndex(
      _graphIndex(),
      utf8.encode('output-private-principal'),
    );
    final hostileOutput = _SinkProbe(failAdd: true);
    final outputLog = _SinkProbe();
    await expectLater(
      outputFailure.serveStdio(
        Stream<List<int>>.value(_frameBytes(_frame('discover_request'))),
        hostileOutput.sink,
        utf8.encode('output-private-principal'),
        log: outputLog.sink,
      ),
      throwsA(_serverError('linkedspec_mcp_io_failure')),
    );
    expect(outputLog.text, _ioLogRecord);
    expect(McpServerTestHarness.registeredHandles(outputFailure), 0);
    for (final privateWord in <String>[
      'graph',
      'handle',
      'principal',
      'source',
      'request',
      'response',
      'path',
      'object',
      'exception',
    ]) {
      expect(outputLog.text, isNot(contains(privateWord)));
    }

    final logFailure = _testServer();
    final failingLog = _SinkProbe(failAdd: true);
    await expectLater(
      logFailure.serveStdio(
        Stream<List<int>>.error(StateError('private dual failure')),
        _SinkProbe().sink,
        utf8.encode('log-private-principal'),
        log: failingLog.sink,
      ),
      throwsA(_serverError('linkedspec_mcp_io_failure')),
    );

    final invalidArguments = _testServer();
    var listened = false;
    final controller = StreamController<List<int>>(
      onListen: () => listened = true,
    );
    final sameSink = _SinkProbe();
    expect(
      () => invalidArguments.serveStdio(
        controller.stream,
        sameSink.sink,
        utf8.encode('valid-principal'),
        log: sameSink.sink,
      ),
      throwsA(_serverError('linkedspec_mcp_invalid_stdio')),
    );
    expect(
      () => invalidArguments.serveStdio(
        controller.stream,
        _SinkProbe().sink,
        const <int>[],
      ),
      throwsA(_serverError('linkedspec_mcp_invalid_authorization')),
    );
    expect(listened, isFalse);
    unawaited(controller.close());
  });

  test('production wire authority is narrow and dependency-free', () {
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
    final primary = File('bin/linkedspec_dart.dart').readAsStringSync();
    expect(primary, isNot(contains('McpServer')));
    expect(primary, isNot(contains('serveStdio')));
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    expect(pubspec.where((line) => line == 'dependencies:'), isEmpty);
  });
}

McpServer _testServer() => McpServerTestHarness.create(
  entropy: () => List<int>.filled(32, 0x5A),
  nowMs: () => 10000,
);

Future<List<int>> _outputFor(List<int> bytes, {McpServer? server}) async {
  final output = _SinkProbe();
  await (server ?? _testServer()).serveStdio(
    Stream<List<int>>.value(bytes),
    output.sink,
    utf8.encode('wire-principal'),
  );
  return output.bytes;
}

Stream<List<int>> _chunkThenFail(List<int> chunk) async* {
  yield chunk;
  throw StateError('private later input failure');
}

List<List<int>> _splitBytes(List<int> bytes, List<int> widths) {
  final result = <List<int>>[];
  var offset = 0;
  var widthIndex = 0;
  while (offset < bytes.length) {
    final width = widths[widthIndex % widths.length];
    final candidateEnd = offset + width;
    final end = candidateEnd < bytes.length ? candidateEnd : bytes.length;
    result.add(bytes.sublist(offset, end));
    offset = end;
    widthIndex += 1;
  }
  return result;
}

Map<String, Object?> _corpus() =>
    jsonDecode(
          File(
            '../capability_conformance/mcp_semantic_transport/corpus.json',
          ).readAsStringSync(),
        )
        as Map<String, Object?>;

Map<String, Object?> _frame(String id) {
  final rows = (_corpus()['frames']! as List<Object?>)
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
  return jsonDecode(lines[position])! as Map<String, Object?>;
}

SemanticIndex _graphIndex() => SemanticIndex.fromUtf8(
  File(
    '../capability_conformance/semantic_introspection/graph.spec',
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
    utf8.encode('${McpServerTestHarness.canonicalJson(value)}\n');

List<int> _errorBytes(int code, String message) => _frameBytes({
  'jsonrpc': '2.0',
  'id': null,
  'error': {'code': code, 'message': message},
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
