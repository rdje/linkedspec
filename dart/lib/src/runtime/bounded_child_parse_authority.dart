/// Private authority for synchronous child parsing over one bounded source span.
///
/// This library owns no authored syntax, ActionIR node, interpreter carrier,
/// generated format, or rollout decision. A trusted host supplies immutable
/// entries containing already-compiled callbacks and starts one invocation over
/// caller-owned decoded source snapshots. Active execution can then select only
/// a logical parser identity, an allowed top rule, and one direct same-source
/// span.
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'source_location.dart';

const _dispatchEffect = 'parser_registry_or_staged_dispatch';
const _defaultOrigin = 'dispatch_span';
const _liveResultFieldTokens = <String>[
  'authority',
  'handle',
  'parser',
  'registry',
  'transaction',
  'cancellation',
  'path',
  'source_text',
  'host',
];

/// Maximum diagnostic source detail granted to one child parser.
enum ProgressiveSourceDetail {
  none('none'),
  identity('identity'),
  span('span'),
  text('text');

  const ProgressiveSourceDetail(this.serializedName);

  final String serializedName;

  /// Parses one neutral-contract spelling.
  static ProgressiveSourceDetail parse(String value) {
    for (final detail in values) {
      if (detail.serializedName == value) {
        return detail;
      }
    }
    throw ProgressiveConfigurationException(
      'invalid progressive source detail ${_quoted(value)}',
    );
  }
}

/// Capability-independent policy and resource ceilings.
final class ProgressiveCeilings {
  factory ProgressiveCeilings({
    required ProgressiveSourceDetail sourceDetail,
    required Iterable<String> policyModes,
    required int maxSteps,
    required int maxResultNodes,
    required int maxDiagnosticBytes,
  }) {
    final ownedModes = _validatedStrings(
      policyModes,
      context: 'progressive policy modes',
    );
    if (maxSteps <= 0 || maxResultNodes <= 0 || maxDiagnosticBytes <= 0) {
      throw ProgressiveConfigurationException(
        'progressive numeric ceilings must be positive',
      );
    }
    return ProgressiveCeilings._(
      sourceDetail: sourceDetail,
      policyModes: ownedModes,
      maxSteps: maxSteps,
      maxResultNodes: maxResultNodes,
      maxDiagnosticBytes: maxDiagnosticBytes,
    );
  }

  const ProgressiveCeilings._({
    required this.sourceDetail,
    required this.policyModes,
    required this.maxSteps,
    required this.maxResultNodes,
    required this.maxDiagnosticBytes,
  });

  final ProgressiveSourceDetail sourceDetail;
  final List<String> policyModes;
  final int maxSteps;
  final int maxResultNodes;
  final int maxDiagnosticBytes;
}

/// Synchronous already-compiled child authority.
///
/// Returning `null` means child failure. Throwing is contained and normalized
/// into the same portable child-failure diagnostic.
typedef ProgressiveCompiledAuthority =
    Object? Function(ProgressiveDispatchRequest request);

/// One deeply owned immutable logical-registry entry.
final class ProgressiveRegistryEntry {
  factory ProgressiveRegistryEntry({
    required String parserId,
    required ProgressiveCompiledAuthority compiledAuthority,
    required String fingerprint,
    required Iterable<String> allowedTopRules,
    required Iterable<String> capabilities,
    required ProgressiveCeilings ceilings,
  }) {
    if (!_validParserId(parserId)) {
      throw ProgressiveConfigurationException(
        'invalid progressive parser identity ${_quoted(parserId)}',
      );
    }
    if (!_validFingerprint(fingerprint)) {
      throw ProgressiveConfigurationException(
        'invalid progressive fingerprint for ${_quoted(parserId)}',
      );
    }
    final ownedRules = _validatedStrings(
      allowedTopRules,
      context: 'allowed progressive top rules',
    );
    if (ownedRules.any((String rule) => !_validTopRule(rule))) {
      throw ProgressiveConfigurationException(
        'invalid allowed top rule for ${_quoted(parserId)}',
      );
    }
    return ProgressiveRegistryEntry._(
      parserId: parserId,
      compiledAuthority: compiledAuthority,
      fingerprint: fingerprint,
      allowedTopRules: ownedRules,
      capabilities: _validatedStrings(
        capabilities,
        context: 'progressive capabilities',
      ),
      ceilings: ceilings,
    );
  }

  const ProgressiveRegistryEntry._({
    required this.parserId,
    required this.compiledAuthority,
    required this.fingerprint,
    required this.allowedTopRules,
    required this.capabilities,
    required this.ceilings,
  });

  final String parserId;
  final ProgressiveCompiledAuthority compiledAuthority;
  final String fingerprint;
  final List<String> allowedTopRules;
  final List<String> capabilities;
  final ProgressiveCeilings ceilings;
}

/// Immutable logical registry over already-compiled child parsers.
final class ProgressiveRegistry {
  factory ProgressiveRegistry({
    required Iterable<ProgressiveRegistryEntry> entries,
  }) {
    final byId = <String, ProgressiveRegistryEntry>{};
    for (final entry in entries) {
      if (byId.containsKey(entry.parserId)) {
        throw ProgressiveConfigurationException(
          'duplicate progressive parser identity ${_quoted(entry.parserId)}',
        );
      }
      byId[entry.parserId] = entry;
    }
    if (byId.isEmpty) {
      throw ProgressiveConfigurationException(
        'progressive registry must be nonempty',
      );
    }
    return ProgressiveRegistry._(
      Map<String, ProgressiveRegistryEntry>.unmodifiable(byId),
    );
  }

  const ProgressiveRegistry._(this._entries);

  final Map<String, ProgressiveRegistryEntry> _entries;

  /// Runtime registration is never an authored capability.
  Never register(String parserId) {
    throw ProgressiveDispatchException._(
      'progressive_registry_mutation_forbidden',
      <String, Object?>{'origin': 'registry:register', 'parser_id': parserId},
    );
  }

  /// Runtime path/provider loading is never an authored capability.
  Never load(String parserId) {
    throw ProgressiveDispatchException._(
      'progressive_implicit_load_forbidden',
      <String, Object?>{'origin': 'registry:load', 'parser_id': parserId},
    );
  }

  /// Starts one fresh invocation with caller-owned source and limit authority.
  ProgressiveInvocation startInvocation(ProgressiveInvocationConfig config) =>
      ProgressiveInvocation._(registry: this, config: config);
}

/// Identity-bearing cancellation authority shared by parent and children.
final class ProgressiveCancellationToken {
  bool _cancelled = false;

  /// Cancels every dispatch sharing this exact token object.
  void cancel() {
    _cancelled = true;
  }

  bool get _isCancelled => _cancelled;
}

/// Caller-owned monotonic clock observed only at dispatch safe points.
final class ProgressiveClock {
  const ProgressiveClock(this._now);

  final int Function() _now;

  int get now => _now();
}

/// One parser/top/source/global-span row already active in an invocation.
final class ProgressiveChainFrame {
  factory ProgressiveChainFrame({
    required String parserId,
    required String topRule,
    required String sourceId,
    required int start,
    required int end,
  }) {
    if (!_validParserId(parserId) ||
        !_validTopRule(topRule) ||
        sourceId.isEmpty ||
        start < 0 ||
        end < 0) {
      throw ProgressiveConfigurationException(
        'invalid progressive active-chain identity',
      );
    }
    return ProgressiveChainFrame._(
      parserId: parserId,
      topRule: topRule,
      sourceId: sourceId,
      start: start,
      end: end,
    );
  }

  const ProgressiveChainFrame._({
    required this.parserId,
    required this.topRule,
    required this.sourceId,
    required this.start,
    required this.end,
  });

  final String parserId;
  final String topRule;
  final String sourceId;
  final int start;
  final int end;
}

/// Complete fresh-invocation authority supplied by a trusted host.
final class ProgressiveInvocationConfig {
  factory ProgressiveInvocationConfig({
    required Map<String, String> sources,
    required String sourceId,
    required ProgressiveCancellationToken cancellationToken,
    required ProgressiveClock clock,
    required int deadlineTick,
    required int remainingSteps,
    required int maxDepth,
    required int maxCalls,
    Iterable<ProgressiveChainFrame> activeChain =
        const <ProgressiveChainFrame>[],
    int totalCalls = 0,
  }) => ProgressiveInvocationConfig._(
    sources: Map<String, String>.unmodifiable(<String, String>{
      for (final entry in sources.entries) entry.key: entry.value,
    }),
    sourceId: sourceId,
    cancellationToken: cancellationToken,
    clock: clock,
    deadlineTick: deadlineTick,
    remainingSteps: remainingSteps,
    maxDepth: maxDepth,
    maxCalls: maxCalls,
    activeChain: List<ProgressiveChainFrame>.unmodifiable(activeChain),
    totalCalls: totalCalls,
  );

  const ProgressiveInvocationConfig._({
    required this.sources,
    required this.sourceId,
    required this.cancellationToken,
    required this.clock,
    required this.deadlineTick,
    required this.remainingSteps,
    required this.maxDepth,
    required this.maxCalls,
    required this.activeChain,
    required this.totalCalls,
  });

  final Map<String, String> sources;
  final String sourceId;
  final ProgressiveCancellationToken cancellationToken;
  final ProgressiveClock clock;
  final int deadlineTick;
  final int remainingSteps;
  final int maxDepth;
  final int maxCalls;
  final List<ProgressiveChainFrame> activeChain;
  final int totalCalls;
}

/// Dynamic defensive arguments accepted before a static ActionIR carrier exists.
final class ProgressiveDispatchArguments {
  const ProgressiveDispatchArguments({
    required this.origin,
    required this.parserId,
    required this.topRule,
    required this.span,
    required this.callerCapabilities,
    required this.requiredCapabilities,
    required this.callerCeilings,
    required this.requiredSourceDetail,
    required this.childToken,
    required this.cost,
    this.transactionActive = false,
  });

  final String origin;
  final Object? parserId;
  final Object? topRule;
  final Object? span;
  final List<String> callerCapabilities;
  final List<String> requiredCapabilities;
  final ProgressiveCeilings callerCeilings;
  final ProgressiveSourceDetail requiredSourceDetail;
  final ProgressiveCancellationToken childToken;
  final int cost;
  final bool transactionActive;
}

/// Exact capability and policy intersection delivered to a child callback.
final class ProgressiveEffectiveAuthority {
  const ProgressiveEffectiveAuthority._({
    required this.capabilities,
    required this.sourceDetail,
    required this.policyModes,
    required this.maxSteps,
    required this.maxResultNodes,
    required this.maxDiagnosticBytes,
  });

  final List<String> capabilities;
  final ProgressiveSourceDetail sourceDetail;
  final List<String> policyModes;
  final int maxSteps;
  final int maxResultNodes;
  final int maxDiagnosticBytes;

  /// Returns one fresh detached neutral record.
  Map<String, Object?> toJson() => <String, Object?>{
    'capabilities': <String>[...capabilities],
    'source_detail': sourceDetail.serializedName,
    'policy_modes': <String>[...policyModes],
    'max_steps': maxSteps,
    'max_result_nodes': maxResultNodes,
    'max_diagnostic_bytes': maxDiagnosticBytes,
  };
}

/// Child request containing no path, loader, compiler, or parent parser state.
final class ProgressiveDispatchRequest {
  const ProgressiveDispatchRequest._({
    required this.parserId,
    required this.topRule,
    required this.fingerprint,
    required this.sourceView,
    required this.effective,
    required this.cancellationToken,
    required this.deadlineTick,
    required this.remainingSteps,
    required Object? Function(ProgressiveDispatchArguments) nestedDispatch,
  }) : _nestedDispatch = nestedDispatch;

  final String parserId;
  final String topRule;
  final String fingerprint;
  final ProgressiveSourceView sourceView;
  final ProgressiveEffectiveAuthority effective;
  final ProgressiveCancellationToken cancellationToken;
  final int deadlineTick;
  final int remainingSteps;
  final Object? Function(ProgressiveDispatchArguments) _nestedDispatch;

  /// Runs one nested dispatch only while this callback request remains active.
  Object? dispatchNested(ProgressiveDispatchArguments arguments) {
    sourceView._ensureActive();
    return _nestedDispatch(arguments);
  }
}

/// One callback-scoped bounded view over the invocation's original source.
final class ProgressiveSourceView {
  const ProgressiveSourceView._(this._state);

  final _ProgressiveSourceViewState _state;

  /// Returns only the bounded decoded child text.
  String get text {
    _ensureActive();
    return _state.text;
  }

  /// Returns the original source identity.
  String get sourceId {
    _ensureActive();
    return _state.sourceId;
  }

  /// Returns the direct-span provenance supplied by the caller.
  String get provenance {
    _ensureActive();
    return _state.provenance;
  }

  /// Rebases one local Unicode-scalar boundary into the original source.
  int localToGlobal(int offset) {
    _ensureLocalOffset(offset);
    return _state.start + offset;
  }

  /// Returns one detached globally rebased typed-position record.
  Map<String, Object?> rebasePosition(int offset) {
    final global = localToGlobal(offset);
    return _state.authority
        .position(
          sourceId: _state.sourceId,
          offset: global,
          context: _locationContext,
        )
        .toJson();
  }

  /// Validates and globally rebases one local exact span record.
  Map<String, Object?> rebaseSpan(Object? value) {
    _ensureActive();
    final span = _parseSpan(value, _state.origin);
    if (span.sourceId != _state.sourceId) {
      throw _sourceMismatch(
        _state.origin,
        expected: _state.sourceId,
        actual: span.sourceId,
      );
    }
    _ensureLocalOffset(span.start);
    _ensureLocalOffset(span.end);
    if (span.start > span.end) {
      throw _reversedSpan(_state.origin, span);
    }
    final start = _state.authority.position(
      sourceId: span.sourceId,
      offset: _state.start + span.start,
      context: _locationContext,
    );
    final end = _state.authority.position(
      sourceId: span.sourceId,
      offset: _state.start + span.end,
      context: _locationContext,
    );
    return _state.authority
        .directSpan(
          start: start,
          end: end,
          provenance: span.provenance,
          context: _locationContext,
        )
        .toJson();
  }

  /// Rebases local offset/span fields and returns detached diagnostic data.
  Map<String, Object?> rebaseDiagnostic(Object? value) {
    _ensureActive();
    if (value is! Map<Object?, Object?>) {
      throw const ProgressiveSourceViewException._(
        'diagnostic must be an object',
      );
    }
    final copy = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const ProgressiveSourceViewException._(
          'diagnostic keys must be strings',
        );
      }
      final fieldValue = entry.value;
      if (key == 'span' && fieldValue is Map<Object?, Object?>) {
        copy[key] = rebaseSpan(fieldValue);
      } else if (_isOffsetField(key) && fieldValue is int) {
        copy[key] = localToGlobal(fieldValue);
      } else {
        copy[key] = _detachDiagnosticValue(fieldValue);
      }
    }
    copy['source_id'] = _state.sourceId;
    if (utf8.encode(jsonEncode(copy)).length > _state.diagnosticCeiling) {
      throw const ProgressiveSourceViewException._(
        'rebased diagnostic exceeds its effective byte ceiling',
      );
    }
    return copy;
  }

  SourceLocationContext get _locationContext => SourceLocationContext(
    ruleRole: 'progressive_child',
    invocationRole: _state.origin,
  );

  void _ensureActive() {
    if (!_state.active) {
      throw const ProgressiveSourceViewException._(
        'progressive source view is outside child execution',
      );
    }
  }

  void _ensureLocalOffset(int offset) {
    _ensureActive();
    final length = _state.end - _state.start;
    if (offset < 0 || offset > length) {
      throw _outOfBounds(
        _state.origin,
        sourceId: _state.sourceId,
        start: offset,
        end: offset,
        sourceLength: length,
      );
    }
  }

  void _invalidate() {
    _state.active = false;
  }
}

final class _ProgressiveSourceViewState {
  _ProgressiveSourceViewState({
    required this.authority,
    required this.sourceId,
    required this.text,
    required this.start,
    required this.end,
    required this.provenance,
    required this.origin,
    required this.diagnosticCeiling,
  });

  bool active = true;
  final SourceAuthority authority;
  final String sourceId;
  final String text;
  final int start;
  final int end;
  final String provenance;
  final String origin;
  final int diagnosticCeiling;
}

/// Misuse of a callback-scoped source view.
final class ProgressiveSourceViewException implements Exception {
  const ProgressiveSourceViewException._(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One shared invocation authority containing no parent parser registers.
final class ProgressiveInvocation {
  factory ProgressiveInvocation._({
    required ProgressiveRegistry registry,
    required ProgressiveInvocationConfig config,
  }) {
    if (config.sources.isEmpty || config.sourceId.isEmpty) {
      throw ProgressiveConfigurationException(
        'progressive invocation requires decoded sources and one source id',
      );
    }
    if (!config.sources.containsKey(config.sourceId)) {
      throw ProgressiveConfigurationException(
        'progressive invocation source ${_quoted(config.sourceId)} is unavailable',
      );
    }
    if (config.deadlineTick < 0 ||
        config.remainingSteps < 0 ||
        config.maxDepth <= 0 ||
        config.maxCalls <= 0 ||
        config.totalCalls < 0) {
      throw ProgressiveConfigurationException(
        'progressive invocation limits are invalid',
      );
    }
    final authority = SourceAuthority(sources: config.sources);
    for (final frame in config.activeChain) {
      final length = authority.sourceScalarLength(frame.sourceId);
      if (length == null || frame.start > frame.end || frame.end > length) {
        throw ProgressiveConfigurationException(
          'progressive active-chain span is invalid',
        );
      }
    }
    return ProgressiveInvocation._owned(
      registry: registry,
      sourceAuthority: authority,
      sourceId: config.sourceId,
      cancellationToken: config.cancellationToken,
      clock: config.clock,
      deadlineTick: config.deadlineTick,
      remainingSteps: config.remainingSteps,
      maxDepth: config.maxDepth,
      maxCalls: config.maxCalls,
      totalCalls: config.totalCalls,
      activeChain: <ProgressiveChainFrame>[...config.activeChain],
    );
  }

  ProgressiveInvocation._owned({
    required ProgressiveRegistry registry,
    required SourceAuthority sourceAuthority,
    required String sourceId,
    required ProgressiveCancellationToken cancellationToken,
    required ProgressiveClock clock,
    required int deadlineTick,
    required int remainingSteps,
    required int maxDepth,
    required int maxCalls,
    required int totalCalls,
    required List<ProgressiveChainFrame> activeChain,
  }) : _registry = registry,
       _sourceAuthority = sourceAuthority,
       _sourceId = sourceId,
       _cancellationToken = cancellationToken,
       _clock = clock,
       _deadlineTick = deadlineTick,
       _remainingSteps = remainingSteps,
       _maxDepth = maxDepth,
       _maxCalls = maxCalls,
       _totalCalls = totalCalls,
       _activeChain = activeChain;

  final ProgressiveRegistry _registry;
  final SourceAuthority _sourceAuthority;
  final String _sourceId;
  final ProgressiveCancellationToken _cancellationToken;
  final ProgressiveClock _clock;
  final int _deadlineTick;
  int _remainingSteps;
  final int _maxDepth;
  final int _maxCalls;
  int _totalCalls;
  final List<ProgressiveChainFrame> _activeChain;

  /// Shared remaining step budget after completed or attempted child work.
  int get remainingSteps => _remainingSteps;

  /// Total successfully entered progressive calls in this invocation.
  int get totalCalls => _totalCalls;

  /// Executes one synchronous isolated child dispatch.
  Object? dispatch(ProgressiveDispatchArguments arguments) {
    final origin = arguments.origin.isEmpty ? _defaultOrigin : arguments.origin;
    final parserId = _literalString(
      arguments.parserId,
      origin: origin,
      code: 'progressive_parser_identity_literal_required',
    );
    if (!_validParserId(parserId)) {
      throw ProgressiveDispatchException._(
        'progressive_parser_identity_invalid',
        <String, Object?>{'origin': origin, 'parser_id': parserId},
      );
    }
    final topRule = _literalString(
      arguments.topRule,
      origin: origin,
      code: 'progressive_top_rule_literal_required',
    );
    if (!_validTopRule(topRule)) {
      throw ProgressiveDispatchException._(
        'progressive_top_rule_invalid',
        <String, Object?>{'origin': origin, 'top_rule': topRule},
      );
    }
    if (arguments.span is! Map<Object?, Object?>) {
      throw ProgressiveDispatchException._(
        'progressive_span_binding_required',
        <String, Object?>{
          'origin': origin,
          'operand': _diagnosticOperand(arguments.span),
        },
      );
    }
    final span = _parseSpan(arguments.span, origin);
    if (span.sourceId != _sourceId) {
      throw _sourceMismatch(origin, expected: _sourceId, actual: span.sourceId);
    }
    final sourceLength =
        _sourceAuthority.sourceScalarLength(span.sourceId) ?? 0;
    if (span.end > sourceLength) {
      throw _outOfBounds(
        origin,
        sourceId: span.sourceId,
        start: span.start,
        end: span.end,
        sourceLength: sourceLength,
      );
    }
    if (span.start > span.end) {
      throw _reversedSpan(origin, span);
    }
    if (arguments.transactionActive) {
      throw ProgressiveDispatchException._(
        'progressive_transaction_forbidden',
        <String, Object?>{'origin': origin, 'effect': _dispatchEffect},
      );
    }

    final entry = _registry._entries[parserId];
    if (entry == null) {
      throw ProgressiveDispatchException._(
        'progressive_registry_missing',
        <String, Object?>{'origin': origin, 'parser_id': parserId},
      );
    }
    if (!entry.allowedTopRules.contains(topRule)) {
      throw ProgressiveDispatchException._(
        'progressive_top_rule_forbidden',
        <String, Object?>{
          'origin': origin,
          'parser_id': parserId,
          'top_rule': topRule,
        },
      );
    }
    final effective = _effectiveAuthority(entry, arguments, origin);
    _checkChain(parserId, topRule, span, origin);
    _checkSafePoint(
      childToken: arguments.childToken,
      parserId: parserId,
      cost: arguments.cost,
      effectiveMaxSteps: effective.maxSteps,
      origin: origin,
    );

    _totalCalls += 1;
    _remainingSteps -= arguments.cost;
    final locationContext = SourceLocationContext(
      ruleRole: 'progressive_parent',
      invocationRole: origin,
    );
    final start = _sourceAuthority.position(
      sourceId: span.sourceId,
      offset: span.start,
      context: locationContext,
    );
    final end = _sourceAuthority.position(
      sourceId: span.sourceId,
      offset: span.end,
      context: locationContext,
    );
    final typedSpan = _sourceAuthority.directSpan(
      start: start,
      end: end,
      provenance: span.provenance,
      context: locationContext,
    );
    final sourceView = ProgressiveSourceView._(
      _ProgressiveSourceViewState(
        authority: _sourceAuthority,
        sourceId: span.sourceId,
        text: _sourceAuthority.materialize(typedSpan, context: locationContext),
        start: span.start,
        end: span.end,
        provenance: span.provenance,
        origin: origin,
        diagnosticCeiling: effective.maxDiagnosticBytes,
      ),
    );
    _activeChain.add(
      ProgressiveChainFrame._(
        parserId: parserId,
        topRule: topRule,
        sourceId: span.sourceId,
        start: span.start,
        end: span.end,
      ),
    );
    final request = ProgressiveDispatchRequest._(
      parserId: entry.parserId,
      topRule: topRule,
      fingerprint: entry.fingerprint,
      sourceView: sourceView,
      effective: effective,
      cancellationToken: _cancellationToken,
      deadlineTick: _deadlineTick,
      remainingSteps: math.min(
        _remainingSteps,
        math.max(0, effective.maxSteps - arguments.cost),
      ),
      nestedDispatch: dispatch,
    );

    Object? childResult;
    Object? childFailure;
    try {
      childResult = entry.compiledAuthority(request);
    } catch (error) {
      childFailure = error;
    } finally {
      _activeChain.removeLast();
      sourceView._invalidate();
    }
    if (childFailure != null || childResult == null) {
      throw _childFailed(
        origin,
        parserId: parserId,
        topRule: topRule,
        span: span,
        diagnostic: childFailure?.toString() ?? '<null child result>',
        byteCeiling: effective.maxDiagnosticBytes,
      );
    }
    _checkCancellationAndDeadline(parserId, origin);
    return _detachResult(
      childResult,
      parserId: parserId,
      origin: origin,
      maximum: effective.maxResultNodes,
    );
  }

  void _checkSafePoint({
    required ProgressiveCancellationToken childToken,
    required String parserId,
    required int cost,
    required int effectiveMaxSteps,
    required String origin,
  }) {
    if (!identical(_cancellationToken, childToken)) {
      throw ProgressiveDispatchException._(
        'progressive_cancellation_authority_mismatch',
        <String, Object?>{'origin': origin, 'parser_id': parserId},
      );
    }
    _checkCancellationAndDeadline(parserId, origin);
    if (cost < 0 ||
        _remainingSteps == 0 ||
        cost > _remainingSteps ||
        cost > effectiveMaxSteps) {
      throw ProgressiveDispatchException._(
        'progressive_budget_exhausted',
        <String, Object?>{
          'origin': origin,
          'parser_id': parserId,
          'remaining': math.min(_remainingSteps, effectiveMaxSteps),
        },
      );
    }
  }

  void _checkCancellationAndDeadline(String parserId, String origin) {
    if (_cancellationToken._isCancelled) {
      throw ProgressiveDispatchException._(
        'progressive_cancelled',
        <String, Object?>{'origin': origin, 'parser_id': parserId},
      );
    }
    if (_clock.now >= _deadlineTick) {
      throw ProgressiveDispatchException._(
        'progressive_deadline_exceeded',
        <String, Object?>{
          'origin': origin,
          'parser_id': parserId,
          'deadline': _deadlineTick,
        },
      );
    }
  }

  void _checkChain(
    String parserId,
    String topRule,
    _NeutralSpan span,
    String origin,
  ) {
    if (_activeChain.length >= _maxDepth) {
      throw ProgressiveDispatchException._(
        'progressive_depth_exceeded',
        <String, Object?>{
          'origin': origin,
          'depth': _activeChain.length,
          'maximum': _maxDepth,
        },
      );
    }
    if (_totalCalls >= _maxCalls) {
      throw ProgressiveDispatchException._(
        'progressive_call_limit_exceeded',
        <String, Object?>{
          'origin': origin,
          'calls': _totalCalls,
          'maximum': _maxCalls,
        },
      );
    }
    for (final active in _activeChain) {
      if (active.parserId != parserId ||
          active.topRule != topRule ||
          active.sourceId != span.sourceId) {
        continue;
      }
      final contained =
          active.start <= span.start &&
          span.start <= span.end &&
          span.end <= active.end;
      final smaller = span.end - span.start < active.end - active.start;
      if (contained && smaller) {
        continue;
      }
      throw ProgressiveDispatchException._(
        'progressive_cycle_non_decreasing',
        <String, Object?>{
          'origin': origin,
          'parser_id': parserId,
          'top_rule': topRule,
          'source_id': span.sourceId,
          'span': '${span.start}:${span.end}',
          'active_span': '${active.start}:${active.end}',
        },
      );
    }
  }
}

/// Portable progressive-dispatch diagnostic.
final class ProgressiveDispatchException implements Exception {
  ProgressiveDispatchException._(String code, Map<String, Object?> fields)
    : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
        'code': code,
        ..._deepCopyRecord(fields),
      });

  final Map<String, Object?> _record;

  String get code => _record['code']! as String;

  /// Returns a fresh detached machine-readable diagnostic record.
  Map<String, Object?> toJson() => _deepCopyRecord(_record);

  @override
  String toString() => 'LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:$code';
}

/// Invalid trusted-host authority construction.
final class ProgressiveConfigurationException implements Exception {
  const ProgressiveConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'progressive authority configuration: $message';
}

final class _NeutralSpan {
  const _NeutralSpan({
    required this.sourceId,
    required this.start,
    required this.end,
    required this.provenance,
  });

  final String sourceId;
  final int start;
  final int end;
  final String provenance;
}

_NeutralSpan _parseSpan(Object? value, String origin) {
  if (value is! Map<Object?, Object?>) {
    throw ProgressiveDispatchException._(
      'progressive_span_binding_required',
      <String, Object?>{'origin': origin, 'operand': _diagnosticOperand(value)},
    );
  }
  final fields = value.keys.map((Object? key) => key.toString()).toList()
    ..sort();
  const expected = <String>['end', 'provenance', 'source_id', 'start'];
  final sourceId = value['source_id'];
  final start = value['start'];
  final end = value['end'];
  final provenance = value['provenance'];
  if (!_sameStrings(fields, expected) ||
      sourceId is! String ||
      sourceId.isEmpty ||
      start is! int ||
      start < 0 ||
      end is! int ||
      end < 0 ||
      provenance is! String ||
      provenance.isEmpty) {
    throw ProgressiveDispatchException._(
      'progressive_span_shape_invalid',
      <String, Object?>{'origin': origin, 'fields': fields.join(',')},
    );
  }
  return _NeutralSpan(
    sourceId: sourceId,
    start: start,
    end: end,
    provenance: provenance,
  );
}

ProgressiveEffectiveAuthority _effectiveAuthority(
  ProgressiveRegistryEntry entry,
  ProgressiveDispatchArguments arguments,
  String origin,
) {
  final caller = arguments.callerCapabilities.toSet();
  final capabilities =
      entry.capabilities.where(caller.contains).toSet().toList()..sort();
  for (final required in arguments.requiredCapabilities) {
    if (!capabilities.contains(required)) {
      throw ProgressiveDispatchException._(
        'progressive_capability_denied',
        <String, Object?>{
          'origin': origin,
          'parser_id': entry.parserId,
          'capability': required,
        },
      );
    }
  }
  final entryModes = entry.ceilings.policyModes.toSet();
  final policyModes =
      arguments.callerCeilings.policyModes
          .where(entryModes.contains)
          .toSet()
          .toList()
        ..sort();
  if (policyModes.isEmpty) {
    throw ProgressiveDispatchException._(
      'progressive_policy_denied',
      <String, Object?>{
        'origin': origin,
        'parser_id': entry.parserId,
        'policy': arguments.callerCeilings.policyModes.join(','),
      },
    );
  }
  final sourceDetail =
      ProgressiveSourceDetail.values[math.min(
        arguments.callerCeilings.sourceDetail.index,
        entry.ceilings.sourceDetail.index,
      )];
  if (sourceDetail.index < arguments.requiredSourceDetail.index) {
    throw ProgressiveDispatchException._(
      'progressive_source_detail_denied',
      <String, Object?>{
        'origin': origin,
        'required': arguments.requiredSourceDetail.serializedName,
        'effective': sourceDetail.serializedName,
      },
    );
  }
  return ProgressiveEffectiveAuthority._(
    capabilities: List<String>.unmodifiable(capabilities),
    sourceDetail: sourceDetail,
    policyModes: List<String>.unmodifiable(policyModes),
    maxSteps: math.min(
      arguments.callerCeilings.maxSteps,
      entry.ceilings.maxSteps,
    ),
    maxResultNodes: math.min(
      arguments.callerCeilings.maxResultNodes,
      entry.ceilings.maxResultNodes,
    ),
    maxDiagnosticBytes: math.min(
      arguments.callerCeilings.maxDiagnosticBytes,
      entry.ceilings.maxDiagnosticBytes,
    ),
  );
}

Object? _detachResult(
  Object? value, {
  required String parserId,
  required String origin,
  required int maximum,
}) {
  var nodes = 0;
  final active = HashSet<Object>.identity();

  Object? visit(Object? current, String path) {
    nodes += 1;
    if (nodes > maximum) {
      throw _resultNotDetached(origin, parserId: parserId, field: path);
    }
    if (current == null ||
        current is bool ||
        current is num ||
        current is String) {
      return current;
    }
    if (current is List<Object?>) {
      if (!active.add(current)) {
        throw _resultNotDetached(origin, parserId: parserId, field: path);
      }
      try {
        return <Object?>[
          for (var index = 0; index < current.length; index += 1)
            visit(current[index], '$path/$index'),
        ];
      } finally {
        active.remove(current);
      }
    }
    if (current is Map<Object?, Object?>) {
      if (!active.add(current)) {
        throw _resultNotDetached(origin, parserId: parserId, field: path);
      }
      try {
        final copy = <String, Object?>{};
        for (final entry in current.entries) {
          final key = entry.key;
          if (key is! String) {
            throw _resultNotDetached(origin, parserId: parserId, field: path);
          }
          final lower = key.toLowerCase();
          if (_liveResultFieldTokens.any(lower.contains)) {
            throw _resultNotDetached(
              origin,
              parserId: parserId,
              field: '$path/$key',
            );
          }
          copy[key] = visit(entry.value, '$path/$key');
        }
        return copy;
      } finally {
        active.remove(current);
      }
    }
    throw _resultNotDetached(origin, parserId: parserId, field: path);
  }

  return visit(value, '<result>');
}

String _literalString(
  Object? value, {
  required String origin,
  required String code,
}) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw ProgressiveDispatchException._(code, <String, Object?>{
    'origin': origin,
    'operand': _diagnosticOperand(value),
  });
}

Object _diagnosticOperand(Object? value) {
  if (value == null) {
    return '<missing>';
  }
  if (value is String || value is bool || value is num) {
    return value.toString();
  }
  return '<aggregate>';
}

ProgressiveDispatchException _sourceMismatch(
  String origin, {
  required String expected,
  required String actual,
}) => ProgressiveDispatchException._(
  'progressive_span_source_mismatch',
  <String, Object?>{
    'origin': origin,
    'expected_source_id': expected,
    'actual_source_id': actual,
  },
);

ProgressiveDispatchException _outOfBounds(
  String origin, {
  required String sourceId,
  required int start,
  required int end,
  required int sourceLength,
}) => ProgressiveDispatchException._(
  'progressive_span_out_of_bounds',
  <String, Object?>{
    'origin': origin,
    'source_id': sourceId,
    'start': start,
    'end': end,
    'source_length': sourceLength,
  },
);

ProgressiveDispatchException _reversedSpan(String origin, _NeutralSpan span) =>
    ProgressiveDispatchException._(
      'progressive_span_reversed',
      <String, Object?>{
        'origin': origin,
        'source_id': span.sourceId,
        'start': span.start,
        'end': span.end,
      },
    );

ProgressiveDispatchException _childFailed(
  String origin, {
  required String parserId,
  required String topRule,
  required _NeutralSpan span,
  required String diagnostic,
  required int byteCeiling,
}) {
  var bounded = _truncateUtf8(diagnostic, byteCeiling);
  if (bounded.isEmpty) {
    bounded = '?';
  }
  return ProgressiveDispatchException._(
    'progressive_child_failed',
    <String, Object?>{
      'origin': origin,
      'parser_id': parserId,
      'top_rule': topRule,
      'source_id': span.sourceId,
      'span': '${span.start}:${span.end}',
      'child_diagnostic': bounded,
    },
  );
}

ProgressiveDispatchException _resultNotDetached(
  String origin, {
  required String parserId,
  required String field,
}) => ProgressiveDispatchException._(
  'progressive_result_not_detached',
  <String, Object?>{'origin': origin, 'parser_id': parserId, 'field': field},
);

String _truncateUtf8(String value, int maximum) {
  if (utf8.encode(value).length <= maximum) {
    return value;
  }
  final buffer = StringBuffer();
  var bytes = 0;
  for (final rune in value.runes) {
    final scalar = String.fromCharCode(rune);
    final scalarBytes = utf8.encode(scalar).length;
    if (bytes + scalarBytes > maximum) {
      break;
    }
    buffer.write(scalar);
    bytes += scalarBytes;
  }
  return buffer.toString();
}

List<String> _validatedStrings(
  Iterable<String> values, {
  required String context,
}) {
  final owned = <String>[...values];
  if (owned.isEmpty || owned.any((String value) => value.isEmpty)) {
    throw ProgressiveConfigurationException(
      '$context must be nonempty strings',
    );
  }
  if (owned.toSet().length != owned.length) {
    throw ProgressiveConfigurationException('$context must be duplicate-free');
  }
  return List<String>.unmodifiable(owned);
}

bool _validParserId(String value) =>
    RegExp(r'^[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*$').hasMatch(value);

bool _validTopRule(String value) =>
    RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value);

bool _validFingerprint(String value) =>
    RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(value);

bool _isOffsetField(String key) =>
    key == 'offset' ||
    key == 'start' ||
    key == 'end' ||
    key.endsWith('_offset') ||
    key.endsWith('_start') ||
    key.endsWith('_end');

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

Object? _detachDiagnosticValue(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return value;
  }
  if (value is List<Object?>) {
    return <Object?>[for (final item in value) _detachDiagnosticValue(item)];
  }
  if (value is Map<Object?, Object?>) {
    final copy = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const ProgressiveSourceViewException._(
          'diagnostic keys must be strings',
        );
      }
      copy[key] = _detachDiagnosticValue(entry.value);
    }
    return copy;
  }
  throw const ProgressiveSourceViewException._(
    'diagnostic contains non-detached data',
  );
}

Map<String, Object?> _deepCopyRecord(
  Map<String, Object?> source,
) => <String, Object?>{
  for (final entry in source.entries) entry.key: _copyPlainValue(entry.value),
};

Object? _copyPlainValue(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return value;
  }
  if (value is List<Object?>) {
    return <Object?>[for (final item in value) _copyPlainValue(item)];
  }
  if (value is Map<Object?, Object?>) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _copyPlainValue(entry.value),
    };
  }
  return value.toString();
}

String _quoted(String value) => jsonEncode(value);
