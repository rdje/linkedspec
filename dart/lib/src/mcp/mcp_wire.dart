part of 'mcp_server.dart';

const _mcpUtf8Bom = <int>[0xEF, 0xBB, 0xBF];
const _mcpIoLogRecord = 'linkedspec_mcp_io_failure\n';
const _mcpSafeIntegerId = '9007199254740991';

enum _WireRejection { parse, invalidRequest }

enum _WireTokenKind { string, number, other }

enum _WireContainerKind { object, array }

enum _WirePhase {
  objectKeyOrEnd,
  objectKey,
  objectColon,
  objectValue,
  objectCommaOrEnd,
  arrayValueOrEnd,
  arrayValue,
  arrayCommaOrEnd,
}

final class _WireIdToken {
  const _WireIdToken(this.kind, this.start, this.end);

  final _WireTokenKind kind;
  final int start;
  final int end;
}

final class _WireContainer {
  _WireContainer.object({required this.root})
    : kind = _WireContainerKind.object,
      phase = _WirePhase.objectKeyOrEnd,
      keys = <String>{};

  _WireContainer.array()
    : kind = _WireContainerKind.array,
      root = false,
      phase = _WirePhase.arrayValueOrEnd,
      keys = null;

  final _WireContainerKind kind;
  final bool root;
  final Set<String>? keys;
  _WirePhase phase;
  String? key;
}

final class _WireScanner {
  _WireScanner(this.text, this.maximumDepth);

  final String text;
  final int maximumDepth;
  final List<_WireContainer> _containers = [];
  int offset = 0;
  _WireIdToken? idToken;

  void scan() {
    _skipWhitespace();
    _parseValue(rootContainer: true, captureRootId: false);
    while (_containers.isNotEmpty) {
      final container = _containers.last;
      switch (container.phase) {
        case _WirePhase.objectKeyOrEnd:
          _skipWhitespace();
          if (_take(0x7D)) {
            _containers.removeLast();
            continue;
          }
          container.phase = _WirePhase.objectKey;
          continue;
        case _WirePhase.objectKey:
          _skipWhitespace();
          if (_peek() != 0x22) {
            throw const FormatException('JSON object key is not a string');
          }
          final key = _parseString();
          if (!container.keys!.add(key)) {
            throw const FormatException('duplicate decoded JSON key');
          }
          container.key = key;
          container.phase = _WirePhase.objectColon;
          continue;
        case _WirePhase.objectColon:
          _skipWhitespace();
          if (!_take(0x3A)) {
            throw const FormatException('JSON object colon is missing');
          }
          container.phase = _WirePhase.objectValue;
          continue;
        case _WirePhase.objectValue:
          _skipWhitespace();
          final captureId = container.root && container.key == 'id';
          container.phase = _WirePhase.objectCommaOrEnd;
          _parseValue(rootContainer: false, captureRootId: captureId);
          continue;
        case _WirePhase.objectCommaOrEnd:
          _skipWhitespace();
          if (_take(0x7D)) {
            _containers.removeLast();
            continue;
          }
          if (!_take(0x2C)) {
            throw const FormatException('JSON object comma is missing');
          }
          container.phase = _WirePhase.objectKey;
          continue;
        case _WirePhase.arrayValueOrEnd:
          _skipWhitespace();
          if (_take(0x5D)) {
            _containers.removeLast();
            continue;
          }
          container.phase = _WirePhase.arrayValue;
          continue;
        case _WirePhase.arrayValue:
          _skipWhitespace();
          container.phase = _WirePhase.arrayCommaOrEnd;
          _parseValue(rootContainer: false, captureRootId: false);
          continue;
        case _WirePhase.arrayCommaOrEnd:
          _skipWhitespace();
          if (_take(0x5D)) {
            _containers.removeLast();
            continue;
          }
          if (!_take(0x2C)) {
            throw const FormatException('JSON array comma is missing');
          }
          container.phase = _WirePhase.arrayValue;
          continue;
      }
    }
    _skipWhitespace();
    if (offset != text.length) {
      throw const FormatException('trailing JSON data');
    }
  }

  void _parseValue({required bool rootContainer, required bool captureRootId}) {
    _skipWhitespace();
    final start = offset;
    final token = _tokenKind();
    switch (_peek()) {
      case 0x7B:
        offset += 1;
        _push(_WireContainer.object(root: rootContainer));
        return;
      case 0x5B:
        offset += 1;
        _push(_WireContainer.array());
        return;
      case 0x22:
        _parseString();
        break;
      case 0x74:
        _parseLiteral('true');
        break;
      case 0x66:
        _parseLiteral('false');
        break;
      case 0x6E:
        _parseLiteral('null');
        break;
      case 0x2D:
        _parseNumber();
        break;
      case final int digit when digit >= 0x30 && digit <= 0x39:
        _parseNumber();
        break;
      default:
        throw const FormatException('invalid JSON token');
    }
    if (captureRootId) {
      idToken = _WireIdToken(token, start, offset);
    }
  }

  void _push(_WireContainer container) {
    if (_containers.length >= maximumDepth) {
      throw const FormatException('JSON nesting depth exceeded');
    }
    _containers.add(container);
  }

  String _parseString() {
    if (!_take(0x22)) {
      throw const FormatException('JSON string is missing');
    }
    final result = StringBuffer();
    while (offset < text.length) {
      final unit = text.codeUnitAt(offset);
      if (unit == 0x22) {
        offset += 1;
        return result.toString();
      }
      if (unit < 0x20) {
        throw const FormatException('unescaped JSON control character');
      }
      if (unit == 0x5C) {
        offset += 1;
        if (offset >= text.length) {
          throw const FormatException('truncated JSON escape');
        }
        final escape = text.codeUnitAt(offset);
        offset += 1;
        switch (escape) {
          case 0x22 || 0x2F || 0x5C:
            result.writeCharCode(escape);
            break;
          case 0x62:
            result.writeCharCode(0x08);
            break;
          case 0x66:
            result.writeCharCode(0x0C);
            break;
          case 0x6E:
            result.writeCharCode(0x0A);
            break;
          case 0x72:
            result.writeCharCode(0x0D);
            break;
          case 0x74:
            result.writeCharCode(0x09);
            break;
          case 0x75:
            _appendEscapedScalar(result);
            break;
          default:
            throw const FormatException('invalid JSON escape');
        }
        continue;
      }
      if (_isHighSurrogate(unit)) {
        if (offset + 1 >= text.length) {
          throw const FormatException('unpaired UTF-16 surrogate');
        }
        final low = text.codeUnitAt(offset + 1);
        if (!_isLowSurrogate(low)) {
          throw const FormatException('unpaired UTF-16 surrogate');
        }
        result.writeCharCode(_combineSurrogates(unit, low));
        offset += 2;
        continue;
      }
      if (_isLowSurrogate(unit)) {
        throw const FormatException('unpaired UTF-16 surrogate');
      }
      result.writeCharCode(unit);
      offset += 1;
    }
    throw const FormatException('unterminated JSON string');
  }

  void _appendEscapedScalar(StringBuffer result) {
    final high = _takeHexQuad();
    if (_isHighSurrogate(high)) {
      if (offset + 2 > text.length ||
          text.codeUnitAt(offset) != 0x5C ||
          text.codeUnitAt(offset + 1) != 0x75) {
        throw const FormatException('unpaired escaped surrogate');
      }
      offset += 2;
      final low = _takeHexQuad();
      if (!_isLowSurrogate(low)) {
        throw const FormatException('unpaired escaped surrogate');
      }
      result.writeCharCode(_combineSurrogates(high, low));
      return;
    }
    if (_isLowSurrogate(high)) {
      throw const FormatException('unpaired escaped surrogate');
    }
    result.writeCharCode(high);
  }

  int _takeHexQuad() {
    if (offset + 4 > text.length) {
      throw const FormatException('truncated JSON Unicode escape');
    }
    var value = 0;
    for (var index = 0; index < 4; index += 1) {
      final digit = _hexValue(text.codeUnitAt(offset + index));
      if (digit < 0) {
        throw const FormatException('invalid JSON Unicode escape');
      }
      value = value * 16 + digit;
    }
    offset += 4;
    return value;
  }

  void _parseLiteral(String literal) {
    if (!text.startsWith(literal, offset)) {
      throw const FormatException('invalid JSON literal');
    }
    offset += literal.length;
  }

  void _parseNumber() {
    if (_take(0x2D) && offset >= text.length) {
      throw const FormatException('invalid JSON number');
    }
    final first = _peek();
    if (first == 0x30) {
      offset += 1;
    } else if (first != null && first >= 0x31 && first <= 0x39) {
      offset += 1;
      while (_isDigit(_peek())) {
        offset += 1;
      }
    } else {
      throw const FormatException('invalid JSON number');
    }
    if (_take(0x2E)) {
      if (!_isDigit(_peek())) {
        throw const FormatException('invalid JSON fraction');
      }
      while (_isDigit(_peek())) {
        offset += 1;
      }
    }
    if (_peek() == 0x65 || _peek() == 0x45) {
      offset += 1;
      if (_peek() == 0x2B || _peek() == 0x2D) {
        offset += 1;
      }
      if (!_isDigit(_peek())) {
        throw const FormatException('invalid JSON exponent');
      }
      while (_isDigit(_peek())) {
        offset += 1;
      }
    }
  }

  _WireTokenKind _tokenKind() => switch (_peek()) {
    0x22 => _WireTokenKind.string,
    0x2D => _WireTokenKind.number,
    final int digit when digit >= 0x30 && digit <= 0x39 =>
      _WireTokenKind.number,
    _ => _WireTokenKind.other,
  };

  void _skipWhitespace() {
    while (switch (_peek()) {
      0x20 || 0x09 || 0x0A || 0x0D => true,
      _ => false,
    }) {
      offset += 1;
    }
  }

  bool _take(int unit) {
    if (_peek() != unit) {
      return false;
    }
    offset += 1;
    return true;
  }

  int? _peek() => offset < text.length ? text.codeUnitAt(offset) : null;
}

Future<void> _mcpServeStdio(
  McpServer server,
  Stream<List<int>> input,
  IOSink output,
  List<int> authorizationContext, {
  IOSink? log,
}) async {
  final (maximumLineBytes, maximumDepth) = _wireRequestLimits();
  var buffer = BytesBuilder(copy: false);
  var overlong = false;
  try {
    await for (final chunk in input) {
      if (chunk.any((byte) => byte < 0 || byte > 255)) {
        throw const FormatException('input stream did not contain bytes');
      }
      var offset = 0;
      while (offset < chunk.length) {
        final newline = chunk.indexOf(0x0A, offset);
        final end = newline < 0 ? chunk.length : newline;
        if (!overlong) {
          final pieceLength = end - offset;
          if (buffer.length + pieceLength > maximumLineBytes + 1) {
            buffer = BytesBuilder(copy: false);
            overlong = true;
          } else {
            for (var index = offset; index < end; index += 1) {
              buffer.addByte(chunk[index]);
            }
          }
        }
        if (newline < 0) {
          break;
        }
        if (overlong) {
          await _wireEmitResponse(
            server,
            output,
            _protocolError(null, 'parse_error'),
            null,
          );
        } else {
          final line = buffer.takeBytes();
          final payload = line.isNotEmpty && line.last == 0x0D
              ? Uint8List.sublistView(line, 0, line.length - 1)
              : line;
          if (payload.length > maximumLineBytes) {
            await _wireEmitResponse(
              server,
              output,
              _protocolError(null, 'parse_error'),
              null,
            );
          } else {
            final (response, prepared) = _wireProcessPayload(
              server,
              payload,
              authorizationContext,
              maximumDepth,
            );
            await _wireEmitResponse(server, output, response, prepared);
          }
        }
        buffer = BytesBuilder(copy: false);
        overlong = false;
        offset = newline + 1;
      }
    }

    if (overlong) {
      await _wireEmitResponse(
        server,
        output,
        _protocolError(null, 'parse_error'),
        null,
      );
    } else if (buffer.length > 0) {
      final payload = buffer.takeBytes();
      if (payload.length > maximumLineBytes) {
        await _wireEmitResponse(
          server,
          output,
          _protocolError(null, 'parse_error'),
          null,
        );
      } else {
        final (response, prepared) = _wireProcessPayload(
          server,
          payload,
          authorizationContext,
          maximumDepth,
        );
        await _wireEmitResponse(server, output, response, prepared);
      }
    }
    await output.flush();
    server.shutdown();
  } on Object {
    await _wireIoFailure(server, log);
  }
}

(Map<String, Object?>?, String?) _wireProcessPayload(
  McpServer server,
  List<int> payload,
  List<int> authorizationContext,
  int maximumDepth,
) {
  final Map<String, Object?> request;
  try {
    request = _wireDecodePayload(payload, maximumDepth);
  } on _WireParseFailure catch (failure) {
    final kind = failure.rejection == _WireRejection.parse
        ? 'parse_error'
        : 'invalid_request';
    return (_protocolError(null, kind), null);
  }
  final id = _wireValidatedId(request);
  Map<String, Object?>? response;
  String? prepared;
  try {
    final dispatched = server._dispatchForWire(request, authorizationContext);
    response = dispatched.$1;
    prepared = dispatched.$2;
  } on Object {
    return (_protocolError(id, 'internal_error'), null);
  }
  if (response == null) {
    return (null, null);
  }
  if (_mcpValidateFrame(response)) {
    return (response, prepared);
  }
  server._wireResponseEmitted(prepared);
  return (_protocolError(id, 'internal_error'), null);
}

Map<String, Object?> _wireDecodePayload(List<int> payload, int maximumDepth) {
  if (payload.length >= 3 &&
      payload[0] == _mcpUtf8Bom[0] &&
      payload[1] == _mcpUtf8Bom[1] &&
      payload[2] == _mcpUtf8Bom[2]) {
    throw const _WireParseFailure(_WireRejection.parse);
  }
  final String text;
  try {
    text = utf8.decode(payload, allowMalformed: false);
  } on Object {
    throw const _WireParseFailure(_WireRejection.parse);
  }
  final scanner = _WireScanner(text, maximumDepth);
  try {
    scanner.scan();
  } on Object {
    throw const _WireParseFailure(_WireRejection.parse);
  }
  final Object? value;
  try {
    value = jsonDecode(text);
  } on Object {
    throw const _WireParseFailure(_WireRejection.parse);
  }
  if (!_wireJsonTreeIsFinite(value)) {
    throw const _WireParseFailure(_WireRejection.parse);
  }
  final object = _jsonMap(value);
  if (object == null) {
    throw const _WireParseFailure(_WireRejection.invalidRequest);
  }
  if (object.containsKey('id') &&
      !_wireValidId(object['id'], scanner.idToken, text)) {
    throw const _WireParseFailure(_WireRejection.invalidRequest);
  }
  return object;
}

Future<void> _wireEmitResponse(
  McpServer server,
  IOSink output,
  Map<String, Object?>? response,
  String? prepared,
) async {
  if (response == null) {
    return;
  }
  server._wireBeforeEmit?.call(server, prepared);
  if (!server._wireResponseReady(prepared)) {
    return;
  }
  if (!_mcpValidateFrame(response)) {
    throw const FormatException('invalid MCP response');
  }
  final bytes = utf8.encode(_mcpCanonicalJson(response));
  output.add(<int>[...bytes, 0x0A]);
  await output.flush();
  server._wireResponseEmitted(prepared);
}

Future<void> _wireIoFailure(McpServer server, IOSink? log) async {
  server.shutdown();
  if (log != null) {
    try {
      log.add(utf8.encode(_mcpIoLogRecord));
      await log.flush();
    } on Object {
      // The primary failure remains the only caller-visible classification.
    }
  }
  throw const McpServerError(
    'linkedspec_mcp_io_failure',
    'The MCP stdio stream failed.',
  );
}

(int, int) _wireRequestLimits() {
  try {
    final limits = _jsonMap(_mcpContract()['request_limits']);
    final lineBytes = _positiveInt(limits?['line_bytes_excluding_delimiter']);
    final depth = _positiveInt(limits?['json_nesting_depth']);
    if (lineBytes == null || depth == null) {
      throw const _McpContractError();
    }
    return (lineBytes, depth);
  } on Object {
    throw _contractFailure();
  }
}

bool _wireValidId(Object? value, _WireIdToken? token, String payload) {
  if (token == null) {
    return false;
  }
  if (token.kind == _WireTokenKind.number) {
    final raw = payload.substring(token.start, token.end);
    if (raw.contains('.') || raw.contains('e') || raw.contains('E')) {
      return false;
    }
    if (!_wireSafeIntegerId(raw)) {
      return false;
    }
  } else if (token.kind != _WireTokenKind.string) {
    return false;
  }
  return _mcpValidateNamed('requestId', value);
}

bool _wireSafeIntegerId(String raw) {
  var digits = raw.startsWith('-') ? raw.substring(1) : raw;
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  if (digits.isEmpty) {
    digits = '0';
  }
  return digits.length < _mcpSafeIntegerId.length ||
      (digits.length == _mcpSafeIntegerId.length &&
          digits.compareTo(_mcpSafeIntegerId) <= 0);
}

Object? _wireValidatedId(Map<String, Object?> request) {
  final value = request['id'];
  return _mcpValidateNamed('requestId', value) ? _copyJson(value) : null;
}

bool _wireJsonTreeIsFinite(Object? root) {
  final pending = <Object?>[root];
  while (pending.isNotEmpty) {
    final value = pending.removeLast();
    if (value == null || value is bool || value is String || value is int) {
      continue;
    }
    if (value is double) {
      if (!value.isFinite) {
        return false;
      }
      continue;
    }
    if (value is List) {
      pending.addAll(value);
      continue;
    }
    if (value is Map) {
      if (value.keys.any((key) => key is! String)) {
        return false;
      }
      pending.addAll(value.values);
      continue;
    }
    return false;
  }
  return true;
}

bool _isDigit(int? unit) => unit != null && unit >= 0x30 && unit <= 0x39;

bool _isHighSurrogate(int value) => value >= 0xD800 && value <= 0xDBFF;

bool _isLowSurrogate(int value) => value >= 0xDC00 && value <= 0xDFFF;

int _combineSurrogates(int high, int low) =>
    0x10000 + ((high - 0xD800) << 10) + (low - 0xDC00);

int _hexValue(int unit) {
  if (unit >= 0x30 && unit <= 0x39) {
    return unit - 0x30;
  }
  if (unit >= 0x41 && unit <= 0x46) {
    return unit - 0x41 + 10;
  }
  if (unit >= 0x61 && unit <= 0x66) {
    return unit - 0x61 + 10;
  }
  return -1;
}

final class _WireParseFailure implements Exception {
  const _WireParseFailure(this.rejection);

  final _WireRejection rejection;
}
