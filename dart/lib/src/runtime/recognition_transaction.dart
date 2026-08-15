/// Private recognition-invocation frames and linear transaction tokens.
///
/// The runtime and exact conformance consumer share this package-internal
/// authority. The public facade exposes only the authored transaction forms
/// after their separate admission; it does not export these state handles.
library;

import 'source_location.dart';

const _tokenExpectedCode = 'recognition_token_expected';
const _tokenEscapeCode = 'recognition_token_escape';
const _tokenReusedCode = 'recognition_token_reused';
const _nestingForbiddenCode = 'recognition_nesting_forbidden';
const _crossInvocationCode = 'recognition_cross_invocation';
const _crossSourceCode = 'recognition_cross_source';
const _attemptCountCode = 'recognition_attempt_count';
const _terminalRequiredCode = 'recognition_terminal_required';
const _effectForbiddenCode = 'recognition_effect_forbidden';
const _unknownEffectCode = 'recognition_unknown_effect';
const _zeroProgressRepetitionCode = 'recognition_zero_progress_repetition';
const _zeroProgressRecursiveCycleCode =
    'recognition_zero_progress_recursive_cycle';
const _markGenerationInvalidCode = 'recognition_mark_generation_invalid';

const _allowedEffects = <String>{
  'pure_value',
  'source_read',
  'structured_control',
  'rule_recognition',
  'transaction_state',
  'cursor_advance',
  'capture_boundary_write',
  'invocation_mark_write',
  'staged_return',
};

const _rejectedEffects = <String>{
  'binding_write',
  'aggregate_write',
  'ast_or_object_write',
  'compatibility_cursor_control',
  'output',
  'authored_diagnostic',
  'exit_or_unbounded_control',
  'dynamic_callable',
  'parser_registry_or_staged_dispatch',
  'external_or_host',
  'unknown_or_raw',
};

/// Cursor, anonymous-boundary, and invocation-local named-mark state.
final class RecognitionFrameState {
  RecognitionFrameState({
    required this.cursor,
    required this.boundary,
    required Map<String, int> marks,
  }) : marks = Map<String, int>.unmodifiable(marks);

  final int cursor;
  final int? boundary;
  final Map<String, int> marks;

  RecognitionFrameState _copy() =>
      RecognitionFrameState(cursor: cursor, boundary: boundary, marks: marks);

  Map<String, Object?> _toJson() => <String, Object?>{
    'cursor': cursor,
    'boundary': boundary,
    'marks': Map<String, int>.from(marks),
  };
}

/// Detached observation of one live recognition frame.
final class RecognitionFrameSnapshot {
  RecognitionFrameSnapshot._({
    required this.source,
    required this.rule,
    required this.invocation,
    required this.generation,
    required RecognitionFrameState state,
  }) : _state = state._copy();

  final String source;
  final String rule;
  final int invocation;
  final int generation;
  final RecognitionFrameState _state;

  /// Returns a detached neutral record.
  Map<String, Object?> toJson() => <String, Object?>{
    'source': source,
    'rule': rule,
    'invocation': invocation,
    'generation': generation,
    ..._state._toJson(),
  };
}

/// Opaque parse-local invocation lineage used by the private runtime adapter.
final class RecognitionInvocationIdentity {
  const RecognitionInvocationIdentity._({
    required this.rule,
    required this.invocationId,
    required this.parentInvocationId,
  });

  final String rule;
  final int invocationId;
  final int? parentInvocationId;
}

/// Detached structural identity carried by one selected action edge.
///
/// This type is package-internal: it is intentionally absent from the public
/// facade. [ownerInvocationId] prevents a nested or unrelated invocation from
/// observing a stale parent edge.
final class RecognitionGapEntrySlot {
  const RecognitionGapEntrySlot({
    required this.ownerInvocationId,
    required this.targetRule,
    required this.regexIndex,
    required this.slotId,
    required this.selectorKind,
    required this.authoredSelector,
  });

  final int ownerInvocationId;
  final String targetRule;
  final int regexIndex;
  final String? slotId;
  final String selectorKind;
  final Object? authoredSelector;

  Map<String, Object?> detachedRecord() => <String, Object?>{
    'target_rule': targetRule,
    'regex_index': regexIndex,
    'slot_id': slotId,
    'selector_kind': selectorKind,
    'authored_selector': authoredSelector,
  };
}

/// Code-unit-rooted private candidate projected through [SourceAuthority].
final class RecognitionGapContext {
  const RecognitionGapContext({
    required this.sourceId,
    required this.ruleLabel,
    required this.invocationId,
    required this.edgeOrdinal,
    required this.kind,
    required this.startCodeUnit,
    required this.endCodeUnit,
  });

  final String sourceId;
  final String ruleLabel;
  final int invocationId;
  final int edgeOrdinal;
  final String kind;
  final int startCodeUnit;
  final int endCodeUnit;
}

/// Private typed diagnostic for a gap read without a live candidate or tail.
final class InterMatchGapException implements Exception {
  InterMatchGapException._({
    required String ruleLabel,
    required String sourceId,
    required int invocationId,
    required String phase,
    required String accessor,
  }) : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
         'code': 'gap_capture_context_unavailable',
         'rule_label': ruleLabel,
         'source_id': sourceId,
         'invocation_id': invocationId,
         'phase': phase,
         'accessor': accessor,
       });

  final Map<String, Object?> _record;

  Map<String, Object?> toJson() => Map<String, Object?>.from(_record);

  @override
  String toString() => 'LINKEDSPEC_INTER_MATCH_GAP_ERROR:${_record['code']}';
}

/// Private typed diagnostic for a cursor that regresses before gap commit.
final class GapCursorRegressionException implements Exception {
  GapCursorRegressionException._({
    required String ruleLabel,
    required String sourceId,
    required int selectedEndCodeUnit,
    required int cursorCodeUnit,
  }) : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
         'code': 'source_location_cursor_regression',
         'phase': 'advance',
         'rule_role': ruleLabel,
         'invocation_role': 'gap_owner',
         'source_id': sourceId,
         'start_offset': selectedEndCodeUnit,
         'end_offset': cursorCodeUnit,
         'originating_edge_or_job': '$ruleLabel:capture_gaps_commit',
       });

  final Map<String, Object?> _record;

  Map<String, Object?> toJson() => Map<String, Object?>.from(_record);

  @override
  String toString() => 'LINKEDSPEC_SOURCE_LOCATION_ERROR:${_record['code']}';
}

/// Portable private recognition-transaction diagnostic.
final class RecognitionTransactionException implements Exception {
  RecognitionTransactionException._(String code, Map<String, Object?> fields)
    : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
        'code': code,
        ...fields,
      });

  final Map<String, Object?> _record;

  /// Returns a detached machine-readable error record.
  Map<String, Object?> toJson() => Map<String, Object?>.from(_record);

  @override
  String toString() =>
      'LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:${_record['code']}';
}

final class _RecognitionInvocationFrame {
  _RecognitionInvocationFrame(this.state);

  final _InvocationState state;

  @override
  String toString() => 'RecognitionInvocationFrame(<opaque>)';
}

final class _RecognitionTransactionToken {
  _RecognitionTransactionToken(this.state);

  final _TransactionState state;

  @override
  String toString() => 'RecognitionTransactionToken(<opaque>)';
}

final class _InvocationState {
  _InvocationState({
    required this.authorityId,
    required this.sourceAuthority,
    required this.sourceIdentity,
    required this.rule,
    required this.origin,
    required this.invocation,
    required this.parentInvocation,
    required this.generation,
    required bool captureGaps,
    required this.entrySlot,
    required RecognitionFrameState frameState,
  }) : frameState = frameState._copy(),
       gapState = captureGaps
           ? _GapMutableState(
               committedGapCursor: frameState.cursor,
               acceptedEdgeCount: 0,
               currentGap: null,
             )
           : null;

  final int authorityId;
  final SourceAuthority sourceAuthority;
  final String sourceIdentity;
  final String rule;
  final String origin;
  final int invocation;
  final int? parentInvocation;
  final int generation;
  bool active = true;
  RecognitionFrameState frameState;
  _GapMutableState? gapState;
  String gapPhase = 'I';
  final RecognitionGapEntrySlot? entrySlot;
  _TransactionState? activeToken;
}

final class _GapMutableState {
  _GapMutableState({
    required this.committedGapCursor,
    required this.acceptedEdgeCount,
    required this.currentGap,
  });

  int committedGapCursor;
  int acceptedEdgeCount;
  RecognitionGapContext? currentGap;

  _GapMutableState _copy() => _GapMutableState(
    committedGapCursor: committedGapCursor,
    acceptedEdgeCount: acceptedEdgeCount,
    currentGap: currentGap,
  );
}

enum _TransactionStatus {
  activeUnattempted,
  activeStagedMatch,
  activeStagedMiss,
  invalidated,
}

final class _TransactionState {
  _TransactionState({
    required this.authorityId,
    required this.sourceAuthority,
    required this.sourceIdentity,
    required this.rule,
    required this.origin,
    required this.invocation,
    required this.generation,
    required this.transaction,
    required RecognitionFrameState snapshot,
    required _GapMutableState? gapSnapshot,
    required this.frame,
  }) : snapshot = snapshot._copy(),
       gapSnapshot = gapSnapshot?._copy();

  final int authorityId;
  final SourceAuthority sourceAuthority;
  final String sourceIdentity;
  final String rule;
  final String origin;
  final int invocation;
  final int generation;
  final int transaction;
  final RecognitionFrameState snapshot;
  final _GapMutableState? gapSnapshot;
  final _InvocationState frame;
  _TransactionStatus status = _TransactionStatus.activeUnattempted;
  int attemptCount = 0;
  bool matched = false;
  Object? payload;
}

/// Authority for private invocation frames, mark generations, and tokens.
final class RecognitionTransactionAuthority {
  RecognitionTransactionAuthority({
    required SourceAuthority sourceAuthority,
    required String sourceIdentity,
  }) : _authorityId = _claimAuthorityId(),
       _sourceAuthority = sourceAuthority,
       _sourceIdentity = sourceIdentity;

  static int _nextAuthorityId = 1;

  final int _authorityId;
  final SourceAuthority _sourceAuthority;
  final String _sourceIdentity;
  int _nextInvocation = 1;
  int _nextGeneration = 1;
  int _nextTransaction = 1;
  final List<_InvocationState> _invocationStack = <_InvocationState>[];

  static int _claimAuthorityId() => _nextAuthorityId++;

  /// Enters one independent rule invocation with fresh opaque generations.
  Object enterInvocation({
    required String rule,
    required String origin,
    required RecognitionFrameState state,
    bool captureGaps = false,
    RecognitionGapEntrySlot? entrySlot,
  }) {
    final invocation = _nextInvocation++;
    final parentInvocation = _invocationStack.isEmpty
        ? null
        : _invocationStack.last.invocation;
    final generation = _nextGeneration++;
    final parent = _invocationStack.isEmpty ? null : _invocationStack.last;
    final acceptedEntrySlot =
        entrySlot != null &&
            parent != null &&
            parent.invocation == entrySlot.ownerInvocationId &&
            parent.gapState?.currentGap != null &&
            entrySlot.targetRule == rule
        ? entrySlot
        : null;
    final frame = _InvocationState(
      authorityId: _authorityId,
      sourceAuthority: _sourceAuthority,
      sourceIdentity: _sourceIdentity,
      rule: rule,
      origin: origin,
      invocation: invocation,
      parentInvocation: parentInvocation,
      generation: generation,
      captureGaps: captureGaps,
      entrySlot: acceptedEntrySlot,
      frameState: state,
    );
    _invocationStack.add(frame);
    return _RecognitionInvocationFrame(frame);
  }

  /// Returns the parse-local identity of one active invocation.
  RecognitionInvocationIdentity invocationIdentity(Object frame) {
    final state = _frameForAuthority(frame);
    return RecognitionInvocationIdentity._(
      rule: state.rule,
      invocationId: state.invocation,
      parentInvocationId: state.parentInvocation,
    );
  }

  /// Reserves one rejected attempted-child identity without pushing a frame.
  RecognitionInvocationIdentity reserveRejectedInvocation({
    required String rule,
  }) {
    final parentInvocation = _invocationStack.isEmpty
        ? null
        : _invocationStack.last.invocation;
    return RecognitionInvocationIdentity._(
      rule: rule,
      invocationId: _nextInvocation++,
      parentInvocationId: parentInvocation,
    );
  }

  /// Leaves the most recently entered invocation.
  ///
  /// An unfinished token restores its snapshot and is invalidated before the
  /// portable terminal-required diagnostic is reported.
  void leaveInvocation(Object frame) {
    final frameState = _frameForAuthority(frame);
    if (_invocationStack.isEmpty ||
        !identical(_invocationStack.last, frameState)) {
      final expectedInvocation = _invocationStack.isEmpty
          ? frameState.invocation
          : _invocationStack.last.invocation;
      throw _error(_crossInvocationCode, <String, Object?>{
        'rule': frameState.rule,
        'origin': frameState.origin,
        'expected_invocation': expectedInvocation,
        'actual_invocation': frameState.invocation,
      });
    }

    final activeToken = frameState.activeToken;
    if (activeToken != null && _tokenIsActive(activeToken)) {
      final rule = activeToken.rule;
      final origin = activeToken.origin;
      _restoreAndInvalidate(activeToken);
      _invocationStack.removeLast();
      frameState.active = false;
      throw _error(_terminalRequiredCode, <String, Object?>{
        'rule': rule,
        'origin': origin,
      });
    }

    _invocationStack.removeLast();
    frameState.active = false;
  }

  /// Snapshots one live frame into a detached neutral value.
  RecognitionFrameSnapshot frameSnapshot(Object frame) {
    final state = _frameForAuthority(frame);
    return RecognitionFrameSnapshot._(
      source: state.sourceIdentity,
      rule: state.rule,
      invocation: state.invocation,
      generation: state.generation,
      state: state.frameState,
    );
  }

  /// Returns a detached copy of one live backend frame state.
  RecognitionFrameState frameState(Object frame) =>
      _frameForAuthority(frame).frameState._copy();

  /// Synchronizes one live frame from the backend's native registers.
  void setFrameState(Object frame, RecognitionFrameState state) {
    _frameForAuthority(frame).frameState = state._copy();
  }

  /// Reports that a dedicated transaction node did not resolve its slot.
  Never rejectMissingToken(Object frame, String origin) {
    final state = _frameForAuthority(frame);
    throw _error(_tokenExpectedCode, <String, Object?>{
      'rule': state.rule,
      'origin': origin,
    });
  }

  /// Writes one invocation-local named mark.
  int writeMark(Object frame, String name, int offset) {
    final state = _frameForAuthority(frame);
    final marks = Map<String, int>.from(state.frameState.marks)
      ..[name] = offset;
    state.frameState = RecognitionFrameState(
      cursor: state.frameState.cursor,
      boundary: state.frameState.boundary,
      marks: marks,
    );
    return offset;
  }

  /// Reads one invocation-local named mark.
  int? readMark(Object frame, String name) =>
      _frameForAuthority(frame).frameState.marks[name];

  /// Records the exact private lifecycle phase for typed gap diagnostics.
  void setGapPhase(Object frame, String phase) {
    _frameForAuthority(frame).gapPhase = phase;
  }

  /// Installs one prefix/interstitial candidate before capture-enabled `LS`.
  void installGapCandidate(Object frame, int matchStartCodeUnit) {
    final state = _frameForAuthority(frame);
    final gap = state.gapState;
    if (gap == null) {
      return;
    }
    gap.currentGap = RecognitionGapContext(
      sourceId: state.sourceIdentity,
      ruleLabel: state.rule,
      invocationId: state.invocation,
      edgeOrdinal: gap.acceptedEdgeCount,
      kind: gap.acceptedEdgeCount == 0 ? 'prefix' : 'interstitial',
      startCodeUnit: gap.committedGapCursor,
      endCodeUnit: matchStartCodeUnit,
    );
    state.gapPhase = 'selection';
  }

  /// Commits one accepted edge after `LE` and clears it before `IT`.
  void commitGapCandidate(
    Object frame, {
    required int cursorCodeUnit,
    required int selectedEndCodeUnit,
  }) {
    final state = _frameForAuthority(frame);
    final gap = state.gapState;
    final current = gap?.currentGap;
    if (gap == null || current == null) {
      return;
    }
    if (cursorCodeUnit < selectedEndCodeUnit) {
      throw GapCursorRegressionException._(
        ruleLabel: state.rule,
        sourceId: current.sourceId,
        selectedEndCodeUnit: selectedEndCodeUnit,
        cursorCodeUnit: cursorCodeUnit,
      );
    }
    gap
      ..committedGapCursor = cursorCodeUnit
      ..acceptedEdgeCount += 1
      ..currentGap = null;
    state.gapPhase = 'post_commit';
  }

  /// Installs the successful terminal tail without moving the parse cursor.
  void installGapTail(Object frame, int inputEndCodeUnit, String phase) {
    final state = _frameForAuthority(frame);
    final gap = state.gapState;
    if (gap == null) {
      return;
    }
    gap.currentGap = RecognitionGapContext(
      sourceId: state.sourceIdentity,
      ruleLabel: state.rule,
      invocationId: state.invocation,
      edgeOrdinal: gap.acceptedEdgeCount,
      kind: 'tail',
      startCodeUnit: gap.committedGapCursor,
      endCodeUnit: inputEndCodeUnit,
    );
    state.gapPhase = phase;
  }

  /// Returns the live candidate/tail or the exact typed private diagnostic.
  RecognitionGapContext currentGap(Object frame, String accessor) {
    final state = _frameForAuthority(frame);
    final current = state.gapState?.currentGap;
    if (current != null) {
      return current;
    }
    throw InterMatchGapException._(
      ruleLabel: state.rule,
      sourceId: state.sourceIdentity,
      invocationId: state.invocation,
      phase: state.gapPhase,
      accessor: accessor,
    );
  }

  /// Returns a fresh detached action-edge entry identity, or null directly.
  Map<String, Object?>? entrySlot(Object frame) =>
      _frameForAuthority(frame).entrySlot?.detachedRecord();

  /// Creates a child entry identity only while the owning candidate is live.
  RecognitionGapEntrySlot? gapEntrySlot(
    Object frame, {
    required String targetRule,
    required int regexIndex,
    required String? slotId,
    required String selectorKind,
    required Object? authoredSelector,
  }) {
    final state = _frameForAuthority(frame);
    if (state.gapState?.currentGap == null) {
      return null;
    }
    return RecognitionGapEntrySlot(
      ownerInvocationId: state.invocation,
      targetRule: targetRule,
      regexIndex: regexIndex,
      slotId: slotId,
      selectorKind: selectorKind,
      authoredSelector: authoredSelector,
    );
  }

  /// Creates one linear token over the current frame state.
  Object checkpoint(Object frame, String origin) {
    final frameState = _frameForAuthority(frame);
    for (final stackedFrame in _invocationStack) {
      final activeToken = stackedFrame.activeToken;
      if (activeToken != null && _tokenIsActive(activeToken)) {
        _restoreAndInvalidate(activeToken);
        throw _error(_nestingForbiddenCode, <String, Object?>{
          'rule': frameState.rule,
          'origin': origin,
        });
      }
    }

    final tokenState = _TransactionState(
      authorityId: _authorityId,
      sourceAuthority: _sourceAuthority,
      sourceIdentity: _sourceIdentity,
      rule: frameState.rule,
      origin: origin,
      invocation: frameState.invocation,
      generation: frameState.generation,
      transaction: _nextTransaction++,
      snapshot: frameState.frameState,
      gapSnapshot: frameState.gapState,
      frame: frameState,
    );
    frameState.activeToken = tokenState;
    return _RecognitionTransactionToken(tokenState);
  }

  /// Performs the token's one allowed attempt and stages its frame state.
  bool attempt(
    Object frame,
    Object token, {
    required bool matched,
    required Object? payload,
    required RecognitionFrameState state,
  }) {
    final frameState = _frameForAuthority(frame);
    final tokenState = _tokenForOperation(frameState, token, 'attempt');
    if (tokenState.status != _TransactionStatus.activeUnattempted) {
      final count = tokenState.attemptCount + 1;
      final rule = tokenState.rule;
      final origin = tokenState.origin;
      _restoreAndInvalidate(tokenState);
      throw _error(_attemptCountCode, <String, Object?>{
        'rule': rule,
        'origin': origin,
        'count': count,
      });
    }

    frameState.frameState = state._copy();
    tokenState
      ..attemptCount = 1
      ..matched = matched
      ..payload = matched ? payload : null
      ..status = matched
          ? _TransactionStatus.activeStagedMatch
          : _TransactionStatus.activeStagedMiss;
    return matched;
  }

  /// Invalidates one attempted token and retains its staged frame state.
  Object? commit(Object frame, Object token) {
    final frameState = _frameForAuthority(frame);
    final tokenState = _tokenForOperation(frameState, token, 'commit');
    _requireAttempted(tokenState);
    final payload = tokenState.matched ? tokenState.payload : null;
    _invalidate(tokenState);
    return payload;
  }

  /// Restores one attempted token's snapshot, then invalidates it.
  void rollback(Object frame, Object token) {
    final frameState = _frameForAuthority(frame);
    final tokenState = _tokenForOperation(frameState, token, 'rollback');
    _requireAttempted(tokenState);
    _restoreAndInvalidate(tokenState);
  }

  /// Rejects any attempt to make a token escape its authored linear slot.
  Never rejectEscape(Object frame, Object token, String escape) {
    final frameState = _frameForAuthority(frame);
    final tokenState = _tokenForOperation(frameState, token, 'escape');
    final rule = tokenState.rule;
    final origin = tokenState.origin;
    _restoreAndInvalidate(tokenState);
    throw _error(_tokenEscapeCode, <String, Object?>{
      'rule': rule,
      'origin': origin,
      'escape': escape,
    });
  }

  /// Explicitly restores and invalidates an abandoned opaque token.
  void discardToken(Object frame, Object token) {
    final frameState = _frameForAuthority(frame);
    final tokenState = _tokenForOperation(frameState, token, 'discard');
    _restoreAndInvalidate(tokenState);
  }

  /// Classifies one neutral recognition-effect graph by recursive fixed point.
  void classifyEffects(Map<String, Object?> graph) {
    final entry = graph['entry'] is String
        ? graph['entry']! as String
        : '<entry>';
    final rawRules = graph['rules'];
    if (rawRules is! Map) {
      throw _effectError(_unknownEffectCode, entry, 'unknown_or_raw');
    }

    final effects = <String, Set<String>>{};
    final calls = <String, List<String>>{};
    for (final ruleEntry in rawRules.entries) {
      final rule = '${ruleEntry.key}';
      final rawRow = ruleEntry.value;
      if (rawRow is! Map) {
        throw _effectError(_unknownEffectCode, rule, 'unknown_or_raw');
      }
      final row = Map<String, Object?>.from(rawRow);
      final rawBase = row['base'];
      final rawCalls = row['calls'];
      if (rawBase is! List || rawCalls is! List) {
        throw _effectError(_unknownEffectCode, rule, 'unknown_or_raw');
      }

      final ruleEffects = <String>{};
      for (final rawEffect in rawBase) {
        final effect = rawEffect is String ? rawEffect : 'unknown_or_raw';
        if (!_allowedEffects.contains(effect) &&
            !_rejectedEffects.contains(effect)) {
          throw _effectError(_unknownEffectCode, rule, effect);
        }
        ruleEffects.add(effect);
      }
      effects[rule] = ruleEffects;
      calls[rule] = [
        for (final rawCallee in rawCalls)
          rawCallee is String ? rawCallee : '<dynamic>',
      ];
    }

    var changed = true;
    while (changed) {
      changed = false;
      for (final callEntry in calls.entries) {
        final inherited = <String>{};
        for (final callee in callEntry.value) {
          inherited.addAll(effects[callee] ?? const {'unknown_or_raw'});
        }
        final target = effects[callEntry.key]!;
        final before = target.length;
        target.addAll(inherited);
        changed = changed || target.length != before;
      }
    }

    final entryEffects = effects[entry];
    if (entryEffects == null) {
      throw _effectError(_unknownEffectCode, entry, 'unknown_or_raw');
    }
    final forbidden =
        entryEffects.where(_rejectedEffects.contains).toList(growable: false)
          ..sort();
    if (forbidden.isNotEmpty) {
      final effect = forbidden.first;
      throw _effectError(
        effect == 'unknown_or_raw' ? _unknownEffectCode : _effectForbiddenCode,
        entry,
        effect,
      );
    }
  }

  /// Enforces cursor-only progress for accepted repetition/recursion edges.
  void validateProgress(Map<String, Object?> fixture) {
    final context = fixture['context'] is String
        ? fixture['context']! as String
        : 'unknown';
    final start = fixture['start'] is num
        ? (fixture['start']! as num).toInt()
        : 0;
    final end = fixture['end'] is num ? (fixture['end']! as num).toInt() : 0;
    if (end > start || context == 'one_shot') {
      return;
    }

    final rule = fixture['id'] is String ? fixture['id']! as String : '<rule>';
    final recursive = context != 'accepted_repetition_iteration';
    throw _error(
      recursive ? _zeroProgressRecursiveCycleCode : _zeroProgressRepetitionCode,
      <String, Object?>{
        'rule': rule,
        'origin': '$rule:recognize_once',
        if (recursive) 'cycle': context,
        'start_offset': start,
        'end_offset': end,
      },
    );
  }

  _InvocationState _frameForAuthority(Object frame) {
    if (frame is! _RecognitionInvocationFrame) {
      throw ArgumentError.value(frame, 'frame', 'must be an opaque frame');
    }
    final state = frame.state;
    if (state.authorityId != _authorityId || !state.active) {
      throw _error(_markGenerationInvalidCode, <String, Object?>{
        'rule': state.rule,
        'origin': state.origin,
        'generation': state.generation,
      });
    }
    return state;
  }

  _TransactionState _tokenForOperation(
    _InvocationState frame,
    Object token,
    String operation,
  ) {
    if (token is! _RecognitionTransactionToken) {
      throw _error(_tokenExpectedCode, <String, Object?>{
        'rule': frame.rule,
        'origin': frame.origin,
      });
    }
    final state = token.state;

    if (!identical(frame.sourceAuthority, state.sourceAuthority)) {
      _restoreAndInvalidate(state);
      throw _error(_crossSourceCode, <String, Object?>{
        'rule': frame.rule,
        'origin': frame.origin,
        'expected_source': frame.sourceIdentity,
        'actual_source': state.sourceIdentity,
      });
    }

    if (frame.authorityId != state.authorityId ||
        frame.invocation != state.invocation) {
      _restoreAndInvalidate(state);
      throw _error(_crossInvocationCode, <String, Object?>{
        'rule': frame.rule,
        'origin': frame.origin,
        'expected_invocation': frame.invocation,
        'actual_invocation': state.invocation,
      });
    }

    if (!frame.active || frame.generation != state.generation) {
      _restoreAndInvalidate(state);
      throw _error(_markGenerationInvalidCode, <String, Object?>{
        'rule': frame.rule,
        'origin': frame.origin,
        'generation': state.generation,
      });
    }

    if (!_tokenIsActive(state)) {
      throw _error(_tokenReusedCode, <String, Object?>{
        'rule': state.rule,
        'origin': state.origin,
        'operation': operation,
      });
    }
    return state;
  }

  void _requireAttempted(_TransactionState token) {
    if (token.status == _TransactionStatus.activeStagedMatch ||
        token.status == _TransactionStatus.activeStagedMiss) {
      return;
    }
    final count = token.attemptCount;
    final rule = token.rule;
    final origin = token.origin;
    _restoreAndInvalidate(token);
    throw _error(_attemptCountCode, <String, Object?>{
      'rule': rule,
      'origin': origin,
      'count': count,
    });
  }
}

RecognitionTransactionException _effectError(
  String code,
  String rule,
  String effect,
) => _error(code, <String, Object?>{
  'rule': rule,
  'origin': '$rule:recognize_once',
  'effect': effect,
});

bool _tokenIsActive(_TransactionState token) =>
    token.status != _TransactionStatus.invalidated;

void _restoreAndInvalidate(_TransactionState token) {
  if (!_tokenIsActive(token)) {
    return;
  }
  final frame = token.frame;
  if (frame.active) {
    frame.frameState = token.snapshot._copy();
    if (frame.gapState != null && token.gapSnapshot != null) {
      frame.gapState = token.gapSnapshot!._copy();
    }
  }
  if (identical(frame.activeToken, token)) {
    frame.activeToken = null;
  }
  token
    ..status = _TransactionStatus.invalidated
    ..matched = false
    ..payload = null;
}

void _invalidate(_TransactionState token) {
  if (!_tokenIsActive(token)) {
    return;
  }
  final frame = token.frame;
  if (identical(frame.activeToken, token)) {
    frame.activeToken = null;
  }
  token
    ..status = _TransactionStatus.invalidated
    ..matched = false
    ..payload = null;
}

RecognitionTransactionException _error(
  String code,
  Map<String, Object?> fields,
) => RecognitionTransactionException._(code, fields);
