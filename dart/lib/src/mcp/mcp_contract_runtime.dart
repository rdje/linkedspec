part of 'mcp_server.dart';

const _dartServerName = 'linkedspec-semantic-dart';

final class _McpContractError implements Exception {
  const _McpContractError();
}

late final Map<String, Object?> _mcpBundle = _initializeMcpBundle();

Map<String, Object?> _initializeMcpBundle() {
  if (sha256Hex(utf8.encode(_mcpBundleJson)) != _mcpBundleSha256) {
    throw const _McpContractError();
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(_mcpBundleJson);
  } on Object {
    throw const _McpContractError();
  }
  final root = _jsonMap(decoded);
  if (root == null || root['binding_format'] != _mcpBindingFormat) {
    throw const _McpContractError();
  }
  final semanticPayloads = _jsonMap(root['semantic_payloads']);
  final payloads = semanticPayloads?['payloads'];
  if (payloads is! List) {
    throw const _McpContractError();
  }
  final ids = <String>{};
  for (final payload in payloads) {
    final row = _jsonMap(payload);
    final id = row?['id'];
    if (id is! String || !ids.add(id)) {
      throw const _McpContractError();
    }
  }
  return root;
}

Map<String, Object?> _mcpContract() {
  final contract = _mcpBundle['contract'];
  final result = _jsonMap(_copyJson(contract));
  if (result == null) {
    throw const _McpContractError();
  }
  return result;
}

String _mcpProtocolVersion() {
  final contract = _jsonMap(_mcpBundle['contract']);
  final version = contract?['protocol_version'];
  if (version is! String) {
    throw const _McpContractError();
  }
  return version;
}

Map<String, Object?>? _mcpFrame(String id) {
  final frames = _jsonMap(_mcpBundle['canonical_frames']);
  if (frames == null || !frames.containsKey(id)) {
    return null;
  }
  return _jsonMap(_copyJson(frames[id]));
}

String _mcpCanonicalJson(Object? value) {
  try {
    return jsonEncode(_canonicalJsonValue(_copyJson(value)));
  } on Object {
    throw const _McpContractError();
  }
}

Object? _canonicalJsonValue(Object? value) {
  if (value is List) {
    return <Object?>[for (final child in value) _canonicalJsonValue(child)];
  }
  if (value is Map) {
    final sorted = SplayTreeMap<String, Object?>();
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw const _McpContractError();
      }
      sorted[entry.key as String] = _canonicalJsonValue(entry.value);
    }
    return sorted;
  }
  if (value is double && !value.isFinite) {
    throw const _McpContractError();
  }
  if (value == null ||
      value is bool ||
      value is String ||
      value is int ||
      value is double) {
    return value;
  }
  throw const _McpContractError();
}

bool _mcpValidateNamed(String name, Object? value) {
  final schema = _jsonMap(_mcpBundle['schema']);
  final definitions = _jsonMap(schema?['\$defs']);
  final definition = definitions?[name];
  return definition != null && _mcpMatches(value, definition, schema!, 0);
}

bool _mcpValidateFrame(Object? value) {
  final schema = _jsonMap(_mcpBundle['schema']);
  return schema != null && _mcpMatches(value, schema, schema, 0);
}

bool _mcpMatches(
  Object? value,
  Object? schema,
  Map<String, Object?> root,
  int depth,
) {
  try {
    _mcpValidate(value, schema, root, depth);
    return true;
  } on Object {
    return false;
  }
}

void _mcpValidate(
  Object? value,
  Object? schemaValue,
  Map<String, Object?> root,
  int depth,
) {
  if (depth > 256) {
    throw const _McpContractError();
  }
  if (schemaValue is bool) {
    if (!schemaValue) {
      throw const _McpContractError();
    }
    return;
  }
  final schema = _jsonMap(schemaValue);
  if (schema == null) {
    throw const _McpContractError();
  }

  final reference = schema['\$ref'];
  if (reference != null) {
    if (reference is! String || !reference.startsWith('#/\$defs/')) {
      throw const _McpContractError();
    }
    final name = reference.substring('#/\$defs/'.length);
    if (name.isEmpty || name.contains('/')) {
      throw const _McpContractError();
    }
    final definitions = _jsonMap(root['\$defs']);
    final definition = definitions?[name];
    if (definition == null) {
      throw const _McpContractError();
    }
    _mcpValidate(value, definition, root, depth + 1);
  }

  final type = schema['type'];
  if (type != null) {
    final matches = switch (type) {
      String kind => _mcpHasType(value, kind),
      List<Object?> kinds => kinds.whereType<String>().any(
        (kind) => _mcpHasType(value, kind),
      ),
      _ => false,
    };
    if (!matches) {
      throw const _McpContractError();
    }
  }
  if (schema.containsKey('const') && !_jsonEqual(value, schema['const'])) {
    throw const _McpContractError();
  }
  final allowed = schema['enum'];
  if (allowed != null &&
      (allowed is! List || !allowed.any((item) => _jsonEqual(value, item)))) {
    throw const _McpContractError();
  }
  final oneOf = schema['oneOf'];
  if (oneOf != null) {
    if (oneOf is! List ||
        oneOf
                .where((branch) => _mcpMatches(value, branch, root, depth + 1))
                .length !=
            1) {
      throw const _McpContractError();
    }
  }
  final allOf = schema['allOf'];
  if (allOf != null) {
    if (allOf is! List) {
      throw const _McpContractError();
    }
    for (final branch in allOf) {
      _mcpValidate(value, branch, root, depth + 1);
    }
  }

  final object = _jsonMap(value);
  if (object != null) {
    _mcpValidateObject(object, schema, root, depth);
  }
  if (value is List) {
    _mcpValidateArray(value, schema, root, depth);
  }
  if (value is String) {
    _mcpValidateString(value, schema);
  }
  if (value is int) {
    _mcpValidateInteger(value, schema);
  }
}

void _mcpValidateObject(
  Map<String, Object?> value,
  Map<String, Object?> schema,
  Map<String, Object?> root,
  int depth,
) {
  final maximum = schema['maxProperties'];
  if (maximum is int && value.length > maximum) {
    throw const _McpContractError();
  }
  final required = schema['required'];
  if (required != null) {
    if (required is! List ||
        required.whereType<String>().any((name) => !value.containsKey(name))) {
      throw const _McpContractError();
    }
  }
  final properties = _jsonMap(schema['properties']);
  for (final entry in value.entries) {
    final propertyNames = schema['propertyNames'];
    if (propertyNames != null) {
      _mcpValidate(entry.key, propertyNames, root, depth + 1);
    }
    if (properties?.containsKey(entry.key) == true) {
      _mcpValidate(entry.value, properties![entry.key], root, depth + 1);
      continue;
    }
    final additional = schema['additionalProperties'];
    if (additional == false) {
      throw const _McpContractError();
    }
    if (additional is Map || additional is bool) {
      _mcpValidate(entry.value, additional, root, depth + 1);
    }
  }
}

void _mcpValidateArray(
  List<Object?> value,
  Map<String, Object?> schema,
  Map<String, Object?> root,
  int depth,
) {
  final prefix = schema['prefixItems'];
  final prefixItems = prefix is List ? prefix : const <Object?>[];
  final prefixCount = min(value.length, prefixItems.length);
  for (var index = 0; index < prefixCount; index += 1) {
    _mcpValidate(value[index], prefixItems[index], root, depth + 1);
  }
  final items = schema['items'];
  if (items != null) {
    for (var index = prefixItems.length; index < value.length; index += 1) {
      _mcpValidate(value[index], items, root, depth + 1);
    }
  }
  final minimum = schema['minItems'];
  final maximum = schema['maxItems'];
  if ((minimum is int && value.length < minimum) ||
      (maximum is int && value.length > maximum)) {
    throw const _McpContractError();
  }
}

void _mcpValidateString(String value, Map<String, Object?> schema) {
  final length = value.runes.length;
  final minimum = schema['minLength'];
  final maximum = schema['maxLength'];
  final maximumBytes = schema['x-linkedspec-maxUtf8Bytes'];
  if ((minimum is int && length < minimum) ||
      (maximum is int && length > maximum) ||
      (maximumBytes is int && utf8.encode(value).length > maximumBytes)) {
    throw const _McpContractError();
  }
  final pattern = schema['pattern'];
  if (pattern != null) {
    final matches = switch (pattern) {
      r'^[A-Za-z0-9_-]{43}$' =>
        value.length == 43 && RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(value),
      r'^sha256:[0-9a-f]{64}$' =>
        value.length == 71 && RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(value),
      _ => false,
    };
    if (!matches) {
      throw const _McpContractError();
    }
  }
  if (schema['format'] == 'uri' &&
      !RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:').hasMatch(value)) {
    throw const _McpContractError();
  }
}

void _mcpValidateInteger(int value, Map<String, Object?> schema) {
  final minimum = schema['minimum'];
  final maximum = schema['maximum'];
  if ((minimum is int && value < minimum) ||
      (maximum is int && value > maximum)) {
    throw const _McpContractError();
  }
}

bool _mcpHasType(Object? value, String kind) => switch (kind) {
  'null' => value == null,
  'boolean' => value is bool,
  'array' => value is List,
  'object' => _jsonMap(value) != null,
  'string' => value is String,
  'integer' => value is int,
  'number' => value is num && (value is! double || value.isFinite),
  _ => false,
};

bool _jsonEqual(Object? left, Object? right) {
  if (left is num && right is num) {
    return left.runtimeType == right.runtimeType && left == right;
  }
  if (left is List && right is List) {
    return left.length == right.length &&
        Iterable<int>.generate(
          left.length,
        ).every((index) => _jsonEqual(left[index], right[index]));
  }
  final leftMap = _jsonMap(left);
  final rightMap = _jsonMap(right);
  if (leftMap != null || rightMap != null) {
    return leftMap != null &&
        rightMap != null &&
        leftMap.length == rightMap.length &&
        leftMap.entries.every(
          (entry) =>
              rightMap.containsKey(entry.key) &&
              _jsonEqual(entry.value, rightMap[entry.key]),
        );
  }
  return left == right;
}

Map<String, Object?> _mcpDiscoverResponse(Object id) {
  final response = _mcpFrame('discover_response_dart');
  if (response == null) {
    throw const _McpContractError();
  }
  response['id'] = _copyJson(id);
  return response;
}

Map<String, Object?> _mcpToolsListResponse(Object id) {
  final response = _mcpFrame('tools_list_response_perl');
  if (response == null) {
    throw const _McpContractError();
  }
  _setDartServerName(response);
  response['id'] = _copyJson(id);
  return response;
}

Map<String, Object?> _mcpToolSuccessResponse(
  Object id,
  Map<String, Object?> payload,
) {
  if (!_mcpValidateNamed('semanticQueryResponse', payload)) {
    throw const _McpContractError();
  }
  final response = _mcpFrame('capabilities_call_response');
  if (response == null) {
    throw const _McpContractError();
  }
  _setDartServerName(response);
  response['id'] = _copyJson(id);
  final result = _requiredMap(response['result']);
  result['structuredContent'] = _copyJson(payload);
  final content = result['content'];
  if (content is! List || content.isEmpty) {
    throw const _McpContractError();
  }
  final first = _requiredMap(content.first);
  first['text'] = _mcpCanonicalJson(payload);
  return response;
}

Map<String, Object?> _mcpToolErrorResponse(
  Object id, {
  required bool unavailable,
}) {
  final response = _mcpFrame('policy_denied_response');
  if (response == null) {
    throw const _McpContractError();
  }
  _setDartServerName(response);
  if (unavailable) {
    final unavailableResponse = _mcpFrame('handle_unavailable_response');
    final unavailableResult = _jsonMap(unavailableResponse?['result']);
    final result = _requiredMap(response['result']);
    if (unavailableResult == null) {
      throw const _McpContractError();
    }
    result['content'] = _copyJson(unavailableResult['content']);
  }
  response['id'] = _copyJson(id);
  return response;
}

Map<String, Object?> _mcpJsonRpcError(
  Object? id,
  String kind, {
  String? requested,
}) {
  final contract = _jsonMap(_mcpBundle['contract']);
  if (contract == null) {
    throw const _McpContractError();
  }
  int? code;
  String? message;
  if (kind == 'legacy_initialize') {
    final legacy = _jsonMap(contract['legacy_diagnostic']);
    code = legacy?['code'] as int?;
    message = legacy?['message'] as String?;
  } else {
    final owner = switch (kind) {
      'parse_error' => 'invalid_utf8',
      'invalid_request' => 'invalid_envelope',
      'method_not_found' => 'unknown_method',
      'invalid_params' => 'method_params',
      'internal_error' => 'sanitized_unexpected_failure',
      'unsupported_version' => 'unsupported_protocol_version',
      _ => null,
    };
    final rows = contract['json_rpc_errors'];
    if (owner == null || rows is! List) {
      throw const _McpContractError();
    }
    for (final candidate in rows) {
      final row = _jsonMap(candidate);
      final owns = row?['owns'];
      if (owns is List && owns.contains(owner)) {
        code = row?['code'] as int?;
        message = row?['message'] as String?;
        break;
      }
    }
  }
  if (code == null || message == null) {
    throw const _McpContractError();
  }
  final error = <String, Object?>{'code': code, 'message': message};
  if (kind == 'unsupported_version') {
    error['data'] = {
      'requested': requested ?? '',
      'supported': [_mcpProtocolVersion()],
    };
  }
  return {'jsonrpc': '2.0', 'id': _copyJson(id), 'error': error};
}

void _setDartServerName(Map<String, Object?> response) {
  final result = _requiredMap(response['result']);
  final metadata = _requiredMap(result['_meta']);
  final server = _requiredMap(metadata['io.modelcontextprotocol/serverInfo']);
  server['name'] = _dartServerName;
}
