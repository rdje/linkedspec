import 'dart:async' show Future, Stream;
import 'dart:collection';
import 'dart:convert';
import 'dart:io' show IOSink;
import 'dart:math';
import 'dart:typed_data';

import '../semantic/semantic_index.dart'
    show SemanticIndex, SemanticSourceDetail;
import '../semantic/sha256.dart' show sha256Hex;

part 'mcp_contract.dart';
part 'mcp_contract_runtime.dart';
part 'mcp_wire.dart';

const _authorizationMaximumBytes = 4096;
const _entropyBytes = 32;
const _handleCharacters = 43;
const _maximumHandleAttempts = 16;
const _maximumClockValue = 0x7FFFFFFFFFFFFFFF;
final _dummyAuthorizationDigest = Uint8List(32);

/// Optional lower-only semantic query budgets for one registered handle.
final class McpBudgetLimits {
  const McpBudgetLimits({
    required this.maxRecords,
    required this.maxRelations,
    required this.maxDepth,
  });

  final int maxRecords;
  final int maxRelations;
  final int maxDepth;
}

/// Optional deployment ceilings applied below one index's native capabilities.
final class McpDeploymentPolicy {
  const McpDeploymentPolicy({
    this.sourceDetailCeiling,
    this.pageMax,
    this.budgetMaxima,
  });

  final SemanticSourceDetail? sourceDetailCeiling;
  final int? pageMax;
  final McpBudgetLimits? budgetMaxima;
}

/// Registration policy for one caller-owned semantic index.
final class McpRegistrationOptions {
  const McpRegistrationOptions({this.lifetimeMs, this.policy});

  final int? lifetimeMs;
  final McpDeploymentPolicy? policy;
}

/// Sanitized typed host-API failure; protocol failures are JSON-RPC values.
final class McpServerError implements Exception {
  const McpServerError(this.code, this.message);

  /// Stable machine-readable host-API error code.
  final String code;

  /// Fixed message containing no caller, source, path, or host failure data.
  final String message;

  @override
  String toString() => '$code: $message';
}

typedef _EntropySource = List<int> Function();
typedef _ClockSource = int Function();
typedef _CapabilitiesSource = Object? Function(SemanticIndex index);
typedef _QuerySource = Object? Function(SemanticIndex index, Object? request);
typedef _WireBeforeEmit =
    void Function(McpServer server, String? preparedRequest);

final class _NativeLimits {
  const _NativeLimits({
    required this.sourceDetailCeiling,
    required this.contentDigestAvailable,
    required this.pageDefault,
    required this.pageMax,
    required this.budgetDefaults,
    required this.budgetMaxima,
  });

  final SemanticSourceDetail sourceDetailCeiling;
  final bool contentDigestAvailable;
  final int pageDefault;
  final int pageMax;
  final McpBudgetLimits budgetDefaults;
  final McpBudgetLimits budgetMaxima;
}

final class _EffectivePolicy {
  const _EffectivePolicy({required this.limits, required this.project});

  final _NativeLimits limits;
  final bool project;
}

final class _RegistryEntry {
  const _RegistryEntry({
    required this.index,
    required this.authorizationDigest,
    required this.expiresMs,
    required this.policy,
  });

  final SemanticIndex index;
  final Uint8List authorizationDigest;
  final int expiresMs;
  final _EffectivePolicy policy;
}

final class _ActiveRequest {
  bool cancelled = false;
  bool prepared = false;
}

enum _ToolOperation { capabilities, query }

/// Native Dart MCP server for caller-registered immutable semantic indexes.
final class McpServer {
  /// Construct a production server using secure entropy and monotonic time.
  factory McpServer() {
    try {
      final profile = _mcpContract()['handle_registry'];
      final registry = _jsonMap(profile);
      if (registry == null) {
        throw const _McpContractError();
      }
      final maximumHandles = _positiveInt(
        registry['default_maximum_live_handles'],
      );
      final defaultLifetimeMs = _positiveInt(registry['default_lifetime_ms']);
      final maximumLifetimeMs = _positiveInt(registry['maximum_lifetime_ms']);
      if (maximumHandles == null ||
          defaultLifetimeMs == null ||
          maximumLifetimeMs == null ||
          maximumLifetimeMs < defaultLifetimeMs) {
        throw const _McpContractError();
      }
      final random = Random.secure();
      final clock = Stopwatch()..start();
      return McpServer._(
        entropy: () => List<int>.generate(
          _entropyBytes,
          (_) => random.nextInt(256),
          growable: false,
        ),
        nowMs: () => clock.elapsedMilliseconds,
        maximumHandles: maximumHandles,
        handleAttempts: _maximumHandleAttempts,
        defaultLifetimeMs: defaultLifetimeMs,
        maximumLifetimeMs: maximumLifetimeMs,
        capabilitiesOf: _nativeCapabilities,
        queryIndex: _nativeQuery,
        wireBeforeEmit: null,
      );
    } on McpServerError {
      rethrow;
    } on _McpContractError {
      throw _contractFailure();
    } on Object {
      throw _entropyFailure();
    }
  }

  McpServer._({
    required _EntropySource entropy,
    required _ClockSource nowMs,
    required int maximumHandles,
    required int handleAttempts,
    required int defaultLifetimeMs,
    required int maximumLifetimeMs,
    required _CapabilitiesSource capabilitiesOf,
    required _QuerySource queryIndex,
    required _WireBeforeEmit? wireBeforeEmit,
  }) : _entropy = entropy,
       _nowMs = nowMs,
       _maximumHandles = maximumHandles,
       _handleAttempts = handleAttempts,
       _defaultLifetimeMs = defaultLifetimeMs,
       _maximumLifetimeMs = maximumLifetimeMs,
       _capabilitiesOf = capabilitiesOf,
       _queryIndex = queryIndex,
       _wireBeforeEmit = wireBeforeEmit;

  final Map<String, _RegistryEntry> _entries = {};
  final Map<String, _ActiveRequest> _active = {};
  final _EntropySource _entropy;
  final _ClockSource _nowMs;
  final int _maximumHandles;
  final int _handleAttempts;
  final int _defaultLifetimeMs;
  final int _maximumLifetimeMs;
  final _CapabilitiesSource _capabilitiesOf;
  final _QuerySource _queryIndex;
  final _WireBeforeEmit? _wireBeforeEmit;
  bool _stopped = false;

  /// Register one existing native index and return a fresh opaque handle.
  String registerIndex(
    SemanticIndex index,
    List<int> authorizationContext, {
    McpRegistrationOptions options = const McpRegistrationOptions(),
  }) {
    if (_stopped) {
      throw _serverShutdown();
    }
    final authorization = _authorizationBytes(authorizationContext);
    final lifetimeMs = options.lifetimeMs ?? _defaultLifetimeMs;
    if (lifetimeMs < 1 || lifetimeMs > _maximumLifetimeMs) {
      throw const McpServerError(
        'linkedspec_mcp_invalid_registration',
        'Registration lifetime is outside the contract bounds.',
      );
    }
    final now = _readClock();
    _entries.removeWhere((_, entry) => now >= entry.expiresMs);
    if (_entries.length >= _maximumHandles) {
      throw const McpServerError(
        'linkedspec_mcp_registry_full',
        'The MCP handle registry is at capacity.',
      );
    }

    final Map<String, Object?> capabilities;
    try {
      capabilities = _requiredJsonMap(_capabilitiesOf(index));
    } on Object {
      throw _invalidIndex();
    }
    if (!_mcpValidateNamed('semanticQueryResponse', capabilities)) {
      throw _invalidIndex();
    }
    final native = _nativeLimits(capabilities);
    final policy = _effectivePolicy(options.policy, native);
    if (now > _maximumClockValue - lifetimeMs) {
      throw _clockFailure();
    }
    final handle = _uniqueHandle();
    _entries[handle] = _RegistryEntry(
      index: index,
      authorizationDigest: _authorizationDigest(authorization),
      expiresMs: now + lifetimeMs,
      policy: policy,
    );
    return handle;
  }

  /// Revoke a syntactically valid handle without disclosing its prior state.
  void revokeHandle(String handle) {
    if (!_validHandle(handle)) {
      throw const McpServerError(
        'linkedspec_mcp_invalid_handle',
        'MCP handle syntax is invalid.',
      );
    }
    _entries.remove(handle);
  }

  /// Dispatch one already-decoded JSON request.
  ///
  /// Notifications return `null`; requests return one detached JSON-RPC map.
  Map<String, Object?>? dispatch(
    Object? request,
    List<int> authorizationContext,
  ) => _dispatchWithPreparation(
    request,
    authorizationContext,
    retainPrepared: false,
  );

  /// Run modern MCP JSON lines over caller-owned input and borrowed sinks.
  ///
  /// Normal operation is silent except for canonical protocol frames on
  /// [output]. An optional distinct [log] receives only one fixed sanitized
  /// record after an unexpected input, output, or flush failure. Neither sink
  /// nor [input] is closed by the server. EOF shuts the server down and
  /// releases every registered index.
  Future<void> serveStdio(
    Stream<List<int>> input,
    IOSink output,
    List<int> authorizationContext, {
    IOSink? log,
  }) {
    if (_stopped) {
      throw _serverShutdown();
    }
    _authorizationBytes(authorizationContext);
    if (log != null && identical(output, log)) {
      throw const McpServerError(
        'linkedspec_mcp_invalid_stdio',
        'MCP protocol output and operational log sinks must be distinct.',
      );
    }
    return _mcpServeStdio(this, input, output, authorizationContext, log: log);
  }

  (Map<String, Object?>?, String?) _dispatchForWire(
    Object? request,
    List<int> authorizationContext,
  ) {
    String? candidate;
    final object = _jsonMap(request);
    final id = object?['id'];
    if (_validRequestId(id)) {
      try {
        candidate = _mcpCanonicalJson(id);
      } on Object {
        candidate = null;
      }
    }
    final wasActive = candidate != null && _active.containsKey(candidate);
    final response = _dispatchWithPreparation(
      request,
      authorizationContext,
      retainPrepared: true,
    );
    final prepared =
        !wasActive && candidate != null && _active[candidate]?.prepared == true
        ? candidate
        : null;
    return (response, prepared);
  }

  bool _wireResponseReady(String? key) {
    if (key == null) {
      return true;
    }
    final active = _active[key];
    if (active == null || !active.prepared) {
      return false;
    }
    if (active.cancelled) {
      _active.remove(key);
      return false;
    }
    return true;
  }

  void _wireResponseEmitted(String? key) {
    if (key != null) {
      _active.remove(key);
    }
  }

  Map<String, Object?>? _dispatchWithPreparation(
    Object? request,
    List<int> authorizationContext, {
    required bool retainPrepared,
  }) {
    _authorizationBytes(authorizationContext);
    final Object? copied;
    try {
      copied = _copyJson(request);
    } on Object {
      return _protocolError(null, 'invalid_request');
    }
    final object = _jsonMap(copied);
    final candidateId = object == null ? null : object['id'];
    final id = _validRequestId(candidateId) ? _copyJson(candidateId) : null;
    if (_stopped) {
      return _protocolError(id, 'internal_error');
    }
    if (object == null ||
        object['jsonrpc'] != '2.0' ||
        object['method'] is! String) {
      return _protocolError(null, 'invalid_request');
    }
    final method = object['method']! as String;
    if (!object.containsKey('id')) {
      if (method == 'notifications/cancelled' &&
          _mcpValidateNamed('cancelledNotification', object)) {
        final params = _jsonMap(object['params']);
        final requestId = params?['requestId'];
        try {
          final key = _mcpCanonicalJson(requestId);
          final active = _active[key];
          if (active != null) {
            active.cancelled = true;
          }
        } on Object {
          // Schema validation above owns the admissible cancellation id.
        }
      }
      return null;
    }
    if (id == null) {
      return _protocolError(null, 'invalid_request');
    }
    if (method == 'initialize') {
      return _protocolError(id, 'legacy_initialize');
    }
    if (method == 'notifications/cancelled') {
      return _protocolError(id, 'invalid_request');
    }
    if (method != 'server/discover' &&
        method != 'tools/list' &&
        method != 'tools/call') {
      return _protocolError(id, 'method_not_found');
    }
    final requested = _requestedProtocol(object);
    if (requested != null && requested != _mcpProtocolVersion()) {
      return _protocolError(id, 'unsupported_version', requested: requested);
    }

    switch (method) {
      case 'server/discover':
        if (!_mcpValidateNamed('discoverRequest', object)) {
          return _protocolError(id, 'invalid_params');
        }
        return _prepareResponse(
          id,
          retainPrepared: retainPrepared,
          builder: () => _mcpDiscoverResponse(id),
        );
      case 'tools/list':
        if (!_mcpValidateNamed('toolsListRequest', object)) {
          return _protocolError(id, 'invalid_params');
        }
        return _prepareResponse(
          id,
          retainPrepared: retainPrepared,
          builder: () => _mcpToolsListResponse(id),
        );
      case 'tools/call':
        return _dispatchToolCall(
          object,
          id,
          authorizationContext,
          retainPrepared: retainPrepared,
        );
    }
    throw StateError('unreachable MCP method');
  }

  /// Idempotently clear all registered indexes and active request state.
  void shutdown() {
    _stopped = true;
    _entries.clear();
    _active.clear();
  }

  Map<String, Object?>? _dispatchToolCall(
    Map<String, Object?> request,
    Object id,
    List<int> authorizationContext, {
    required bool retainPrepared,
  }) {
    final params = _jsonMap(request['params']);
    final name = params?['name'];
    final (definition, operation) = switch (name) {
      'linkedspec_semantic_capabilities' => (
        'capabilitiesCallRequest',
        _ToolOperation.capabilities,
      ),
      'linkedspec_semantic_query' => (
        'semanticQueryCallRequest',
        _ToolOperation.query,
      ),
      _ => ('', _ToolOperation.query),
    };
    if (definition.isEmpty) {
      return _protocolError(id, 'invalid_params');
    }
    if (!_mcpValidateNamed(definition, request)) {
      return _protocolError(id, 'invalid_params');
    }
    final authorizationDigest = _authorizationDigest(
      _authorizationBytes(authorizationContext),
    );
    return _prepareResponse(
      id,
      retainPrepared: retainPrepared,
      builder: () =>
          _buildToolResponse(request, id, operation, authorizationDigest),
    );
  }

  Map<String, Object?> _buildToolResponse(
    Map<String, Object?> request,
    Object id,
    _ToolOperation operation,
    Uint8List authorizationDigest,
  ) {
    final params = _requiredMap(request['params']);
    final arguments = _requiredMap(params['arguments']);
    final handle = arguments['handle'];
    if (handle is! String) {
      throw const _McpContractError();
    }
    final authorized = _authorizedEntry(handle, authorizationDigest);
    if (authorized == null) {
      return _mcpToolErrorResponse(id, unavailable: true);
    }
    if (operation == _ToolOperation.query &&
        !_requestWithinPolicy(arguments['request'], authorized.policy.limits)) {
      return _mcpToolErrorResponse(id, unavailable: false);
    }

    final Map<String, Object?> payload;
    switch (operation) {
      case _ToolOperation.capabilities:
        payload = _requiredJsonMap(_capabilitiesOf(authorized.index));
        return _mcpToolSuccessResponse(
          id,
          _projectCapabilities(payload, authorized.policy),
        );
      case _ToolOperation.query:
        payload = _requiredJsonMap(
          _queryIndex(authorized.index, _copyJson(arguments['request'])),
        );
        return _mcpToolSuccessResponse(id, payload);
    }
  }

  Map<String, Object?>? _prepareResponse(
    Object id, {
    required bool retainPrepared,
    required Map<String, Object?> Function() builder,
  }) {
    final String key;
    try {
      key = _mcpCanonicalJson(id);
    } on Object {
      return _protocolError(id, 'internal_error');
    }
    if (_active.containsKey(key)) {
      return _protocolError(id, 'internal_error');
    }
    final active = _ActiveRequest();
    _active[key] = active;

    Map<String, Object?>? response;
    try {
      response = builder();
    } on Object {
      response = _protocolError(id, 'internal_error');
    }
    if (active.cancelled) {
      _active.remove(key);
      return null;
    }
    if (retainPrepared) {
      active.prepared = true;
    } else {
      _active.remove(key);
    }
    return response;
  }

  _RegistryEntry? _authorizedEntry(
    String handle,
    Uint8List authorizationDigest,
  ) {
    final existing = _entries[handle];
    final expected = existing?.authorizationDigest ?? _dummyAuthorizationDigest;
    final authorized = _fixedDigestEqual(expected, authorizationDigest);
    final now = _readClock();
    if (existing != null && now >= existing.expiresMs) {
      _entries.remove(handle);
    }
    return authorized ? _entries[handle] : null;
  }

  String _uniqueHandle() {
    for (var attempt = 0; attempt < _handleAttempts; attempt += 1) {
      final List<int> bytes;
      try {
        bytes = List<int>.of(_entropy(), growable: false);
      } on Object {
        throw _entropyFailure();
      }
      if (bytes.length != _entropyBytes ||
          bytes.any((byte) => byte < 0 || byte > 255)) {
        throw _entropyFailure();
      }
      final handle = base64Url.encode(bytes).replaceAll('=', '');
      if (!_validHandle(handle)) {
        throw _entropyFailure();
      }
      if (!_entries.containsKey(handle)) {
        return handle;
      }
    }
    throw const McpServerError(
      'linkedspec_mcp_entropy_failure',
      'A unique MCP handle could not be generated.',
    );
  }

  int _readClock() {
    final int value;
    try {
      value = _nowMs();
    } on Object {
      throw _clockFailure();
    }
    if (value < 0 || value > _maximumClockValue) {
      throw _clockFailure();
    }
    return value;
  }
}

/// Package-internal deterministic seams; absent from the package umbrella.
final class McpServerTestHarness {
  const McpServerTestHarness._();

  static McpServer create({
    required List<int> Function() entropy,
    required int Function() nowMs,
    int maximumHandles = 4,
    int handleAttempts = _maximumHandleAttempts,
    Object? Function(SemanticIndex index) capabilitiesOf = _nativeCapabilities,
    Object? Function(SemanticIndex index, Object? request) queryIndex =
        _nativeQuery,
    void Function(McpServer server, String? preparedRequest)? beforeWireEmit,
  }) {
    if (maximumHandles < 1 || maximumHandles > 1024) {
      throw ArgumentError.value(maximumHandles, 'maximumHandles');
    }
    if (handleAttempts < 1 || handleAttempts > _maximumHandleAttempts) {
      throw ArgumentError.value(handleAttempts, 'handleAttempts');
    }
    return McpServer._(
      entropy: entropy,
      nowMs: nowMs,
      maximumHandles: maximumHandles,
      handleAttempts: handleAttempts,
      defaultLifetimeMs: 900000,
      maximumLifetimeMs: 86400000,
      capabilitiesOf: capabilitiesOf,
      queryIndex: queryIndex,
      wireBeforeEmit: beforeWireEmit,
    );
  }

  static int registeredHandles(McpServer server) => server._entries.length;

  static int activeRequests(McpServer server) => server._active.length;

  static Map<String, Object?> contract() => _mcpContract();

  static Map<String, Object?>? frame(String id) => _mcpFrame(id);

  static bool validateNamed(String name, Object? value) =>
      _mcpValidateNamed(name, value);

  static bool validateFrame(Object? value) => _mcpValidateFrame(value);

  static String canonicalJson(Object? value) => _mcpCanonicalJson(value);
}

Object? _nativeCapabilities(SemanticIndex index) => index.capabilities.toJson();

Object? _nativeQuery(SemanticIndex index, Object? request) =>
    index.queryNeutral(request).toJson();

List<int> _authorizationBytes(List<int> value) {
  if (value.isEmpty ||
      value.length > _authorizationMaximumBytes ||
      value.any((byte) => byte < 0 || byte > 255)) {
    throw const McpServerError(
      'linkedspec_mcp_invalid_authorization',
      'Authorization context must be 1 through 4096 opaque bytes.',
    );
  }
  return List<int>.of(value, growable: false);
}

Uint8List _authorizationDigest(List<int> value) {
  final hex = sha256Hex(value);
  final result = Uint8List(32);
  for (var index = 0; index < result.length; index += 1) {
    result[index] = int.parse(
      hex.substring(index * 2, index * 2 + 2),
      radix: 16,
    );
  }
  return result;
}

bool _fixedDigestEqual(Uint8List left, Uint8List right) {
  var difference = left.length ^ right.length;
  for (var index = 0; index < 32; index += 1) {
    final leftByte = index < left.length ? left[index] : 0;
    final rightByte = index < right.length ? right[index] : 0;
    difference |= leftByte ^ rightByte;
  }
  return difference == 0;
}

bool _validHandle(String value) =>
    value.length == _handleCharacters &&
    RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(value);

bool _validRequestId(Object? value) =>
    value != null && _mcpValidateNamed('requestId', value);

String? _requestedProtocol(Map<String, Object?> request) {
  final params = _jsonMap(request['params']);
  final metadata = _jsonMap(params?['_meta']);
  final value = metadata?['io.modelcontextprotocol/protocolVersion'];
  return value is String ? value : null;
}

_NativeLimits _nativeLimits(Map<String, Object?> response) {
  final records = response['records'];
  if (records is! List) {
    throw _invalidIndex();
  }
  final capabilities = records
      .where((record) {
        final map = _jsonMap(record);
        return map?['kind'] == 'capabilities';
      })
      .toList(growable: false);
  if (capabilities.length != 1) {
    throw _invalidIndex();
  }
  final record = _requiredMap(capabilities.single);
  final facts = _requiredMap(record['facts']);
  final snapshot = _requiredMap(response['snapshot']);
  final source = _sourceDetail(facts['source_detail_ceiling']);
  final snapshotSource = _sourceDetail(snapshot['source_detail_ceiling']);
  final pageDefault = _positiveInt(facts['page_default']);
  final pageMax = _positiveInt(facts['page_max']);
  final defaults = _budgetLimits(facts['budget_defaults']);
  final maxima = _budgetLimits(facts['budget_maxima']);
  final contentDigest = snapshot['content_digest_available'];
  if (source == null ||
      snapshotSource == null ||
      pageDefault == null ||
      pageMax == null ||
      defaults == null ||
      maxima == null ||
      contentDigest is! bool ||
      pageDefault > pageMax ||
      !_budgetWithin(defaults, maxima)) {
    throw _invalidIndex();
  }
  return _NativeLimits(
    sourceDetailCeiling: source,
    contentDigestAvailable: contentDigest,
    pageDefault: pageDefault,
    pageMax: pageMax,
    budgetDefaults: defaults,
    budgetMaxima: maxima,
  );
}

_EffectivePolicy _effectivePolicy(
  McpDeploymentPolicy? supplied,
  _NativeLimits native,
) {
  var source = native.sourceDetailCeiling;
  var contentDigest = native.contentDigestAvailable;
  var pageDefault = native.pageDefault;
  var pageMax = native.pageMax;
  var budgetDefaults = native.budgetDefaults;
  var budgetMaxima = native.budgetMaxima;
  if (supplied == null) {
    return _EffectivePolicy(limits: native, project: false);
  }
  final detail = supplied.sourceDetailCeiling;
  if (detail != null) {
    if (_sourceRank(detail) > _sourceRank(native.sourceDetailCeiling)) {
      throw _invalidPolicy('MCP source-detail policy is invalid or elevating.');
    }
    source = detail;
    if (detail != SemanticSourceDetail.text) {
      contentDigest = false;
    }
  }
  final suppliedPage = supplied.pageMax;
  if (suppliedPage != null) {
    if (suppliedPage < 1 || suppliedPage > native.pageMax) {
      throw _invalidPolicy('MCP page policy is invalid or elevating.');
    }
    pageMax = suppliedPage;
    pageDefault = min(pageDefault, pageMax);
  }
  final suppliedBudget = supplied.budgetMaxima;
  if (suppliedBudget != null) {
    if (!_validBudget(suppliedBudget) ||
        !_budgetWithin(suppliedBudget, native.budgetMaxima)) {
      throw _invalidPolicy('MCP budget policy is invalid or elevating.');
    }
    budgetMaxima = suppliedBudget;
    budgetDefaults = McpBudgetLimits(
      maxRecords: min(budgetDefaults.maxRecords, suppliedBudget.maxRecords),
      maxRelations: min(
        budgetDefaults.maxRelations,
        suppliedBudget.maxRelations,
      ),
      maxDepth: min(budgetDefaults.maxDepth, suppliedBudget.maxDepth),
    );
  }
  return _EffectivePolicy(
    limits: _NativeLimits(
      sourceDetailCeiling: source,
      contentDigestAvailable: contentDigest,
      pageDefault: pageDefault,
      pageMax: pageMax,
      budgetDefaults: budgetDefaults,
      budgetMaxima: budgetMaxima,
    ),
    project: true,
  );
}

Map<String, Object?> _projectCapabilities(
  Map<String, Object?> response,
  _EffectivePolicy policy,
) {
  final projected = _requiredJsonMap(response);
  if (!policy.project) {
    return projected;
  }
  final records = projected['records'];
  if (records is! List) {
    throw _invalidIndex();
  }
  final capabilities = records
      .where((record) {
        final map = _jsonMap(record);
        return map?['kind'] == 'capabilities';
      })
      .toList(growable: false);
  if (capabilities.length != 1) {
    throw _invalidIndex();
  }
  final record = _requiredMap(capabilities.single);
  final facts = _requiredMap(record['facts']);
  facts['source_detail_ceiling'] = policy.limits.sourceDetailCeiling.wireName;
  facts['page_max'] = policy.limits.pageMax;
  facts['page_default'] = policy.limits.pageDefault;
  facts['budget_maxima'] = _budgetValue(policy.limits.budgetMaxima);
  facts['budget_defaults'] = _budgetValue(policy.limits.budgetDefaults);
  final snapshot = _requiredMap(projected['snapshot']);
  snapshot['source_detail_ceiling'] =
      policy.limits.sourceDetailCeiling.wireName;
  snapshot['content_digest_available'] =
      policy.limits.contentDigestAvailable &&
      policy.limits.sourceDetailCeiling == SemanticSourceDetail.text;
  return projected;
}

bool _requestWithinPolicy(Object? value, _NativeLimits policy) {
  final request = _jsonMap(value);
  final source = _jsonMap(request?['source']);
  final detail = _sourceDetail(source?['detail']);
  if (detail == null ||
      _sourceRank(detail) > _sourceRank(policy.sourceDetailCeiling)) {
    return false;
  }
  if (source?['include_content_digest'] == true &&
      (!policy.contentDigestAvailable ||
          policy.sourceDetailCeiling != SemanticSourceDetail.text)) {
    return false;
  }
  final page = _jsonMap(request?['page']);
  final limit = page?['limit'];
  if (limit is! int || limit > policy.pageMax) {
    return false;
  }
  final budget = _budgetLimits(request?['budget']);
  return budget != null && _budgetWithin(budget, policy.budgetMaxima);
}

McpBudgetLimits? _budgetLimits(Object? value) {
  final map = _jsonMap(value);
  if (map == null || map.length != 3) {
    return null;
  }
  final records = map['max_records'];
  final relations = map['max_relations'];
  final depth = map['max_depth'];
  if (records is! int || relations is! int || depth is! int) {
    return null;
  }
  return McpBudgetLimits(
    maxRecords: records,
    maxRelations: relations,
    maxDepth: depth,
  );
}

bool _validBudget(McpBudgetLimits value) =>
    value.maxRecords >= 0 && value.maxRelations >= 0 && value.maxDepth >= 0;

bool _budgetWithin(McpBudgetLimits value, McpBudgetLimits maximum) =>
    _validBudget(value) &&
    value.maxRecords <= maximum.maxRecords &&
    value.maxRelations <= maximum.maxRelations &&
    value.maxDepth <= maximum.maxDepth;

Map<String, Object?> _budgetValue(McpBudgetLimits value) => {
  'max_records': value.maxRecords,
  'max_relations': value.maxRelations,
  'max_depth': value.maxDepth,
};

SemanticSourceDetail? _sourceDetail(Object? value) => switch (value) {
  'none' => SemanticSourceDetail.none,
  'identity' => SemanticSourceDetail.identity,
  'span' => SemanticSourceDetail.span,
  'text' => SemanticSourceDetail.text,
  _ => null,
};

int _sourceRank(SemanticSourceDetail value) => switch (value) {
  SemanticSourceDetail.none => 0,
  SemanticSourceDetail.identity => 1,
  SemanticSourceDetail.span => 2,
  SemanticSourceDetail.text => 3,
};

int? _positiveInt(Object? value) => value is int && value > 0 ? value : null;

Map<String, Object?> _protocolError(
  Object? id,
  String kind, {
  String? requested,
}) {
  try {
    return _mcpJsonRpcError(id, kind, requested: requested);
  } on Object {
    return {
      'jsonrpc': '2.0',
      'id': _copyJson(id),
      'error': {'code': -32603, 'message': 'Internal error'},
    };
  }
}

Map<String, Object?> _requiredJsonMap(Object? value) {
  final copied = _copyJson(value);
  final result = _jsonMap(copied);
  if (result == null) {
    throw const _McpContractError();
  }
  return result;
}

Map<String, Object?> _requiredMap(Object? value) {
  final result = _jsonMap(value);
  if (result == null) {
    throw const _McpContractError();
  }
  return result;
}

Map<String, Object?>? _jsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is! Map) {
    return null;
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      return null;
    }
    result[entry.key as String] = entry.value;
  }
  return result;
}

Object? _copyJson(Object? value, [int depth = 0, Set<Object>? ancestors]) {
  if (depth > 256) {
    throw const FormatException('JSON nesting exceeds the contract bound');
  }
  if (value == null || value is bool || value is String || value is int) {
    return value;
  }
  if (value is double) {
    if (!value.isFinite) {
      throw const FormatException('non-finite JSON number');
    }
    return value;
  }
  final active = ancestors ?? HashSet<Object>.identity();
  if (value is List) {
    if (!active.add(value)) {
      throw const FormatException('cyclic JSON list');
    }
    try {
      return <Object?>[
        for (final child in value) _copyJson(child, depth + 1, active),
      ];
    } finally {
      active.remove(value);
    }
  }
  if (value is Map) {
    if (!active.add(value)) {
      throw const FormatException('cyclic JSON map');
    }
    try {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String || result.containsKey(key)) {
          throw const FormatException('invalid JSON object key');
        }
        result[key] = _copyJson(entry.value, depth + 1, active);
      }
      return result;
    } finally {
      active.remove(value);
    }
  }
  throw const FormatException('unsupported JSON host value');
}

McpServerError _contractFailure() => const McpServerError(
  'linkedspec_mcp_contract_failure',
  'The generated MCP contract is unavailable.',
);

McpServerError _invalidIndex() => const McpServerError(
  'linkedspec_mcp_invalid_index',
  'The semantic index did not provide valid capabilities.',
);

McpServerError _invalidPolicy(String message) =>
    McpServerError('linkedspec_mcp_invalid_policy', message);

McpServerError _serverShutdown() => const McpServerError(
  'linkedspec_mcp_server_shutdown',
  'The MCP server has shut down.',
);

McpServerError _entropyFailure() => const McpServerError(
  'linkedspec_mcp_entropy_failure',
  'Operating-system entropy is unavailable.',
);

McpServerError _clockFailure() => const McpServerError(
  'linkedspec_mcp_clock_failure',
  'Monotonic time is unavailable.',
);
