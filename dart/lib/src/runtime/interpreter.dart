import 'dart:math' as math;

import '../action/action_ast.dart';
import '../action/action_contracts.dart';
import '../ast/spec_ast.dart';
import '../compiler/compiled_spec.dart';
import 'matching.dart';

final class RuntimeInterpreterException implements Exception {
  const RuntimeInterpreterException(this.message);

  final String message;

  @override
  String toString() => 'RuntimeInterpreterException: $message';
}

final class RuntimeLifecycleEvent {
  const RuntimeLifecycleEvent({
    required this.ruleLabel,
    required this.lifecycle,
    required this.line,
  });

  final String ruleLabel;
  final String lifecycle;
  final int line;

  JsonObject toJson() => {
    'rule_label': ruleLabel,
    'lifecycle': lifecycle,
    'line': line,
  };
}

final class RuntimeParseResult {
  const RuntimeParseResult({
    required this.matched,
    required this.value,
    required this.output,
    required this.cursorCodeUnit,
    required this.cursorCharOffset,
    required this.lifecycleEvents,
  });

  final bool matched;
  final Object? value;
  final List<Object?> output;
  final int cursorCodeUnit;
  final int cursorCharOffset;
  final List<RuntimeLifecycleEvent> lifecycleEvents;

  JsonObject toJson() => {
    'matched': matched,
    'value': value,
    'output': output,
    'cursor_code_unit': cursorCodeUnit,
    'cursor_char_offset': cursorCharOffset,
    'lifecycle_events': [for (final event in lifecycleEvents) event.toJson()],
  };
}

final class LinkedSpecRuntimeEngine {
  LinkedSpecRuntimeEngine(
    this.compiledSpec, {
    this.parseMode = LinkedSpecParseMode.seek,
    this.maxIterations = 10000,
  });

  final CompiledSpec compiledSpec;
  final LinkedSpecParseMode parseMode;
  final int maxIterations;

  RuntimeParseResult parse(String input, {String? topRule}) {
    final label = topRule ?? _defaultTopRuleLabel();
    final context = _RuntimeExecutionContext(
      engine: this,
      input: input,
      parseMode: parseMode,
      maxIterations: maxIterations,
    );
    final result = _executeRule(label, 0, context);
    return RuntimeParseResult(
      matched: result.matched,
      value: result.value,
      output: List<Object?>.unmodifiable([_copyValue(result.value)]),
      cursorCodeUnit: context.cursorCodeUnit,
      cursorCharOffset: codeUnitOffsetToCharOffset(
        input,
        context.cursorCodeUnit,
      ),
      lifecycleEvents: List<RuntimeLifecycleEvent>.unmodifiable(
        context.lifecycleEvents,
      ),
    );
  }

  RuntimeParseResult execute(String input, {String? topRule}) {
    return parse(input, topRule: topRule);
  }

  String _defaultTopRuleLabel() {
    for (final label in compiledSpec.compiledRuleOrder) {
      final rule = compiledSpec.rule(label)!;
      if (rule.header.isTop) {
        return label;
      }
    }
    if (compiledSpec.compiledRuleOrder.isEmpty) {
      throw const RuntimeInterpreterException(
        'compiled spec does not contain any rules',
      );
    }
    return compiledSpec.compiledRuleOrder.first;
  }

  _RuleResult _executeRule(
    String label,
    int entryRegexIndex,
    _RuntimeExecutionContext context,
  ) {
    final rule = compiledSpec.rule(label);
    if (rule == null) {
      throw RuntimeInterpreterException("rule '$label' is not compiled");
    }

    final recursionKey = '$label:$entryRegexIndex:${context.cursorCodeUnit}';
    if (!context.activeRuleEntries.add(recursionKey)) {
      return _RuleResult(matched: false, value: null);
    }

    final savedRegisters = context.registers;
    context.registers = RuntimeMatchRegisters(
      input: context.input,
      cursorCodeUnit: context.cursorCodeUnit,
      entryMatch: savedRegisters.localMatch,
      captureStartCodeUnit:
          savedRegisters.localMatch?.codeUnitEnd ?? context.cursorCodeUnit,
    );

    try {
      final initReturn = _executeLifecycle(rule, 'I', context);
      if (initReturn != null) {
        return _returned(initReturn.value);
      }

      try {
        final result = rule.blindEdges.isNotEmpty
            ? _executeBlindRule(rule, context)
            : _executeRegexRule(rule, entryRegexIndex, context);
        return result;
      } on _ActionReturn catch (returnSignal) {
        return _returned(returnSignal.value);
      }
    } finally {
      context.registers = savedRegisters;
      context.activeRuleEntries.remove(recursionKey);
    }
  }

  _RuleResult _executeBlindRule(
    CompiledRule rule,
    _RuntimeExecutionContext context,
  ) {
    final min = rule.modeMetadata.repMin;
    if (min == null) {
      final matched = _executeBlindOnce(rule, context);
      if (!matched) {
        final loopExit = _executeLifecycle(rule, 'LX', context);
        if (loopExit != null) {
          return _returned(loopExit.value);
        }
      }
      final exitReturn = _executeLifecycle(rule, 'E', context);
      if (exitReturn != null) {
        return _returned(exitReturn.value);
      }
      return _RuleResult(matched: matched, value: null);
    }

    var matches = 0;
    var madeFailedAttempt = false;
    for (var iteration = 0; iteration < context.maxIterations; iteration += 1) {
      final max = rule.modeMetadata.repMax;
      if (max != null && matches >= max) {
        break;
      }
      final before = context.cursorCodeUnit;
      final loopStart = _executeLifecycle(rule, 'LS', context);
      if (loopStart != null) {
        return _returned(loopStart.value);
      }

      final matched = _executeBlindOnce(rule, context);
      if (!matched) {
        madeFailedAttempt = true;
        break;
      }

      matches += 1;
      final loopEnd = _executeLifecycle(rule, 'LE', context);
      if (loopEnd != null) {
        return _returned(loopEnd.value);
      }
      final iterationReturn = _executeLifecycle(rule, 'IT', context);
      if (iterationReturn != null) {
        return _returned(iterationReturn.value);
      }
      if (context.cursorCodeUnit == before) {
        break;
      }
    }

    if (matches < min) {
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
      throw RuntimeInterpreterException(
        "rule '${rule.label}' expected at least $min matches, got $matches",
      );
    }

    final extendedExit = _executeLifecycle(rule, 'EX', context);
    if (extendedExit != null) {
      return _returned(extendedExit.value);
    }
    if (madeFailedAttempt || matches > 0) {
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
    }
    final exitReturn = _executeLifecycle(rule, 'E', context);
    if (exitReturn != null) {
      return _returned(exitReturn.value);
    }
    return _RuleResult(matched: matches > 0, value: null);
  }

  bool _executeBlindOnce(CompiledRule rule, _RuntimeExecutionContext context) {
    if (rule.modeMetadata.isAnd) {
      var matchedAll = true;
      for (final edge in rule.blindEdges) {
        final child = _executeRule(
          edge.target.label,
          edge.target.index,
          context,
        );
        context.retv = child.value;
        final edgeReturn = _executeOptionalPayload(
          edge.actionPayload,
          context,
          rule.label,
          currentEdge: null,
        );
        if (edgeReturn != null) {
          throw _ActionReturn(edgeReturn.value);
        }
        if (!_truthy(child.value)) {
          matchedAll = false;
          break;
        }
      }
      return matchedAll;
    }

    for (final edge in rule.blindEdges) {
      final child = _executeRule(edge.target.label, edge.target.index, context);
      context.retv = child.value;
      final edgeReturn = _executeOptionalPayload(
        edge.actionPayload,
        context,
        rule.label,
        currentEdge: null,
      );
      if (edgeReturn != null) {
        throw _ActionReturn(edgeReturn.value);
      }
      if (_truthy(child.value)) {
        return true;
      }
    }
    return false;
  }

  _RuleResult _executeRegexRule(
    CompiledRule rule,
    int entryRegexIndex,
    _RuntimeExecutionContext context,
  ) {
    final min = rule.modeMetadata.repMin;
    if (min == null) {
      final matched = _executeRegexOnce(
        rule,
        context,
        entryRegexIndex: entryRegexIndex,
        andSequence: rule.modeMetadata.isAnd && rule.regexPatterns.length > 1,
      );
      if (!matched) {
        final loopExit = _executeLifecycle(rule, 'LX', context);
        if (loopExit != null) {
          return _returned(loopExit.value);
        }
      }
      final exitReturn = _executeLifecycle(rule, 'E', context);
      if (exitReturn != null) {
        return _returned(exitReturn.value);
      }
      return _RuleResult(matched: matched, value: null);
    }

    var matches = 0;
    var madeFailedAttempt = false;
    for (var iteration = 0; iteration < context.maxIterations; iteration += 1) {
      final max = rule.modeMetadata.repMax;
      if (max != null && matches >= max) {
        break;
      }
      final before = context.cursorCodeUnit;
      final loopStart = _executeLifecycle(rule, 'LS', context);
      if (loopStart != null) {
        return _returned(loopStart.value);
      }

      final matched = _executeRegexOnce(
        rule,
        context,
        andSequence: rule.modeMetadata.isAnd && rule.regexPatterns.length > 1,
      );
      if (!matched) {
        madeFailedAttempt = true;
        break;
      }

      matches += 1;
      final iterationReturn = _executeLifecycle(rule, 'IT', context);
      if (iterationReturn != null) {
        return _returned(iterationReturn.value);
      }
      if (context.cursorCodeUnit == before) {
        break;
      }
    }

    if (matches < min) {
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
      throw RuntimeInterpreterException(
        "rule '${rule.label}' expected at least $min matches, got $matches",
      );
    }

    final extendedExit = _executeLifecycle(rule, 'EX', context);
    if (extendedExit != null) {
      return _returned(extendedExit.value);
    }
    if (madeFailedAttempt || matches > 0) {
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
    }
    final exitReturn = _executeLifecycle(rule, 'E', context);
    if (exitReturn != null) {
      return _returned(exitReturn.value);
    }
    return _RuleResult(matched: matches > 0, value: null);
  }

  bool _executeRegexOnce(
    CompiledRule rule,
    _RuntimeExecutionContext context, {
    int entryRegexIndex = 0,
    bool andSequence = false,
  }) {
    final plan = _regexPlanFor(rule);
    if (plan.patterns.isEmpty) {
      return false;
    }

    if (andSequence) {
      for (
        var expectedIndex = 0;
        expectedIndex < plan.patterns.length;
        expectedIndex += 1
      ) {
        final match = _matchSpecific(plan, expectedIndex, context);
        if (match == null) {
          return false;
        }
        _acceptRegexMatch(rule, plan, match, context);
        final loopEnd = _executeLifecycle(rule, 'LE', context);
        if (loopEnd != null) {
          throw _ActionReturn(loopEnd.value);
        }
      }
      return true;
    }

    final match = entryRegexIndex > 0 && entryRegexIndex < plan.patterns.length
        ? _matchSpecific(plan, entryRegexIndex, context)
        : RuntimeRegexAlternation.compile(
            plan.patterns,
          ).match(context.input, context.cursorCodeUnit, parseMode: parseMode);
    if (match == null) {
      return false;
    }

    _acceptRegexMatch(rule, plan, match, context);
    final loopEnd = _executeLifecycle(rule, 'LE', context);
    if (loopEnd != null) {
      throw _ActionReturn(loopEnd.value);
    }
    return true;
  }

  RuntimeRegexMatch? _matchSpecific(
    _RegexPlan plan,
    int expectedIndex,
    _RuntimeExecutionContext context,
  ) {
    final match = RuntimeRegexAlternation.compile([
      plan.patterns[expectedIndex],
    ]).match(context.input, context.cursorCodeUnit, parseMode: parseMode);
    if (match == null) {
      return null;
    }
    if (match.alternativeIndex == expectedIndex) {
      return match;
    }
    return RuntimeRegexMatch.reindexed(match, expectedIndex);
  }

  void _acceptRegexMatch(
    CompiledRule rule,
    _RegexPlan plan,
    RuntimeRegexMatch match,
    _RuntimeExecutionContext context,
  ) {
    context.cursorCodeUnit = match.codeUnitEnd;
    context.registers = context.registers.withLocalMatch(match);

    final edgeMatch = _actionEdgeFor(rule, plan, match.alternativeIndex);
    if (edgeMatch == null) {
      return;
    }

    final edgeContext = _CurrentActionEdge(
      ruleLabel: rule.label,
      edge: edgeMatch.edge,
      target: edgeMatch.target,
    );
    if (edgeMatch.edge.actionPayload == null) {
      final child = _executeActionEdgeChild(edgeContext, context);
      context.retv = child.value;
      return;
    }

    final actionReturn = _executeActionBlock(
      edgeMatch.edge.actionPayload!.actionAst,
      context,
      rule.label,
      currentEdge: edgeContext,
    );
    if (actionReturn != null) {
      throw _ActionReturn(actionReturn.value);
    }
    if (!edgeContext.childDispatched && edgeMatch.target.label != rule.label) {
      final child = _executeActionEdgeChild(edgeContext, context);
      context.retv = child.value;
    }
  }

  _RegexPlan _regexPlanFor(CompiledRule rule) {
    if (rule.regexPatterns.isNotEmpty) {
      return _RegexPlan(patterns: rule.regexPatterns, dependencyRefs: const []);
    }
    final dependencyEntry =
        compiledSpec.dependencyRegexState.dependencyRegexMap[rule.label];
    if (dependencyEntry == null) {
      return const _RegexPlan(patterns: [], dependencyRefs: []);
    }
    return _RegexPlan(
      patterns: dependencyEntry.patterns,
      dependencyRefs: dependencyEntry.dependencyRefs,
    );
  }

  _MatchedActionEdge? _actionEdgeFor(
    CompiledRule rule,
    _RegexPlan plan,
    int alternativeIndex,
  ) {
    if (rule.actionEdges.isEmpty) {
      return null;
    }
    if (rule.regexPatterns.isNotEmpty) {
      if (alternativeIndex >= rule.actionEdges.length) {
        return null;
      }
      final edge = rule.actionEdges[alternativeIndex];
      return _MatchedActionEdge(edge: edge, target: edge.targets.first);
    }

    if (alternativeIndex >= plan.dependencyRefs.length) {
      return null;
    }
    final ref = plan.dependencyRefs[alternativeIndex];
    for (final edge in rule.actionEdges) {
      for (final target in edge.targets) {
        if (target.label == ref.label && target.index == ref.index) {
          return _MatchedActionEdge(edge: edge, target: ref);
        }
      }
    }
    return null;
  }

  _ActionReturn? _executeLifecycle(
    CompiledRule rule,
    String lifecycle,
    _RuntimeExecutionContext context,
  ) {
    for (final payload in rule.lifecycleActionPayloads) {
      if (payload.lifecycle != lifecycle) {
        continue;
      }
      context.lifecycleEvents.add(
        RuntimeLifecycleEvent(
          ruleLabel: rule.label,
          lifecycle: lifecycle,
          line: payload.line,
        ),
      );
      final result = _executeActionBlock(
        payload.actionAst,
        context,
        rule.label,
        currentEdge: null,
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  _ActionReturn? _executeOptionalPayload(
    CompiledActionPayload? payload,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    if (payload == null) {
      return null;
    }
    return _executeActionBlock(
      payload.actionAst,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  _ActionReturn? _executeActionBlock(
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    try {
      for (final statement in block.statements) {
        _evaluateExpression(
          statement.expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
      }
      return null;
    } on _ActionReturn catch (returnSignal) {
      return returnSignal;
    } on RuntimeInterpreterException {
      rethrow;
    } catch (error) {
      throw RuntimeInterpreterException(
        'action block failed in rule $ruleLabel: $error',
      );
    }
  }

  Object? _evaluateExpression(
    ActionExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    switch (expr) {
      case ActionStringLiteralExpr(:final value):
        return value;
      case ActionNumberLiteralExpr(:final value):
        return value;
      case ActionBooleanLiteralExpr(:final value):
        return value;
      case ActionRegexLiteralExpr(:final pattern):
        return pattern;
      case ActionUndefExpr():
        return null;
      case ActionVariableExpr(:final name):
        if (name == 'retv') {
          return _readRetv(context, currentEdge);
        }
        return context.variables[name];
      case ActionArrayLiteralExpr(:final items):
        return [
          for (final item in items)
            _copyValue(
              _evaluateExpression(
                item,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            ),
        ];
      case ActionHashLiteralExpr(:final entries):
        return {
          for (final entry in entries)
            _stringValue(
              _evaluateExpression(
                entry.key,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            ): _copyValue(
              _evaluateExpression(
                entry.value,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            ),
        };
      case ActionAssignScalarExpr(:final name, :final value):
        final stored = _copyValue(
          _evaluateExpression(
            value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        context.variables[name] = stored;
        return _copyValue(stored);
      case ActionAssignArrayAppendExpr(:final name, :final value):
        final stored = _copyValue(
          _evaluateExpression(
            value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        context.arrayFor(name).add(stored);
        return List<Object?>.unmodifiable(context.arrayFor(name));
      case ActionAssignHashIndexExpr(:final name, :final key, :final value):
        final storedKey = _stringValue(
          _evaluateExpression(
            key,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        final storedValue = _copyValue(
          _evaluateExpression(
            value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        context.hashFor(name)[storedKey] = storedValue;
        return Map<String, Object?>.unmodifiable(context.hashFor(name));
      case ActionAssignNestedAccessExpr(
        :final base,
        :final segments,
        :final value,
      ):
        final stored = _copyValue(
          _evaluateExpression(
            value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        _writeNested(
          _rootForWrite(context, base, segments),
          segments,
          stored,
          context,
          ruleLabel,
          currentEdge,
        );
        return _copyValue(stored);
      case ActionIndexedVarExpr(:final name, :final index):
        final collection =
            context.variables[name] ??
            context.arrays[name] ??
            context.hashes[name];
        final indexValue = _evaluateExpression(
          index,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
        return _indexValue(collection, indexValue);
      case ActionNestedAccessExpr(:final base, :final segments):
        final root = base == 'retv'
            ? _readRetv(context, currentEdge)
            : (context.variables[base] ??
                  context.arrays[base] ??
                  context.hashes[base]);
        return _readNested(root, segments, context, ruleLabel, currentEdge);
      case ActionCallExpr():
        return _evaluateCall(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
      case ActionFluentChainExpr(:final receiver, :final calls):
        var value = _evaluateExpression(
          receiver,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
        for (final call in calls) {
          value = _evaluateFluentCall(
            value,
            call,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
        }
        return value;
      case ActionBlockValueExpr(:final block):
        final result = _executeActionBlock(
          block,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
        return result?.value;
      case ActionRawExpr(:final source):
        throw RuntimeInterpreterException(
          'unsupported raw action expression in rule $ruleLabel: $source',
        );
      default:
        throw RuntimeInterpreterException(
          'unsupported action expression ${expr.kind} in rule $ruleLabel',
        );
    }
  }

  Object? _evaluateCall(
    ActionCallExpr call,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    final positionalArgs = call.args.map((arg) => arg.value).toList();
    final helperName = canonicalActionHelperName(call.name);
    switch (helperName) {
      case 'return':
        final value = positionalArgs.isEmpty
            ? null
            : _evaluateExpression(
                positionalArgs.first,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              );
        throw _ActionReturn(_copyValue(value));
      case 'return_undef':
        throw const _ActionReturn(null);
      case 'set':
        return _callSet(positionalArgs, context, ruleLabel, currentEdge);
      case 'push':
        return _callPush(positionalArgs, context, ruleLabel, currentEdge);
      case 'array':
        return _callArray(positionalArgs, context, ruleLabel, currentEdge);
      case 'hash':
        return _callHash(positionalArgs, context, ruleLabel, currentEdge);
      case 'copy':
        if (positionalArgs.isEmpty) {
          return null;
        }
        return _copyArgument(
          positionalArgs.first,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'coalesce':
        return _callCoalesce(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
          requireNonempty: false,
        );
      case 'coalesce_nonempty':
        return _callCoalesce(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
          requireNonempty: true,
        );
      case 'entry_text':
        return context.registers.entryMatch?.text;
      case 'match_text':
        return context.registers.localMatch?.text;
      case 'entry_group':
        return _captureAt(
          context.registers.entryMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'match_group':
        return _captureAt(
          context.registers.localMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'entry_groups':
        return List<Object?>.unmodifiable(
          context.registers.entryMatch?.captures ?? const [],
        );
      case 'match_groups':
        return List<Object?>.unmodifiable(
          context.registers.localMatch?.captures ?? const [],
        );
      case 'entry_named':
        return _namedCapture(
          context.registers.entryMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'match_named':
        return _namedCapture(
          context.registers.localMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'entry_has':
        return _hasNamedCapture(
          context.registers.entryMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'match_has':
        return _hasNamedCapture(
          context.registers.localMatch,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'entry_map':
        return Map<String, Object?>.unmodifiable(
          context.registers.entryMatch?.named ?? const <String, String>{},
        );
      case 'match_map':
        return Map<String, Object?>.unmodifiable(
          context.registers.localMatch?.named ?? const <String, String>{},
        );
      case 'entry_len':
        return context.registers.entryMatch?.charLength;
      case 'match_len':
        return context.registers.localMatch?.charLength;
      case 'entry_start_pos':
        return context.registers.entryMatch?.charStart;
      case 'entry_end_pos':
        return context.registers.entryMatch?.charEnd;
      case 'match_start_pos':
        return context.registers.localMatch?.charStart;
      case 'match_end_pos':
        return context.registers.localMatch?.charEnd;
      case 'call':
        if (positionalArgs.isEmpty) {
          return null;
        }
        final targetLabel = _ruleNameFromExpr(
          positionalArgs.first,
          context,
          ruleLabel,
          currentEdge,
        );
        final targetIndex =
            currentEdge != null && currentEdge.target.label == targetLabel
            ? currentEdge.target.index
            : 0;
        final child =
            currentEdge != null && currentEdge.target.label == targetLabel
            ? _executeActionEdgeChild(currentEdge, context)
            : _executeRule(targetLabel, targetIndex, context);
        return child.value;
      default:
        if (_runtimePureHelperNames.contains(helperName)) {
          return _callPureHelper(
            helperName,
            _evaluateValues(positionalArgs, context, ruleLabel, currentEdge),
          );
        }
        throw RuntimeInterpreterException(
          "unsupported runtime helper '${call.name}' in rule $ruleLabel",
        );
    }
  }

  Object? _evaluateFluentCall(
    Object? receiver,
    ActionFluentCall call,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    final helperName = canonicalActionHelperName(call.method);
    switch (helperName) {
      case 'copy':
        return _copyValue(receiver);
      case 'coalesce':
        return _callCoalesceWithReceiver(
          receiver,
          call.args,
          context,
          ruleLabel,
          currentEdge,
          requireNonempty: false,
        );
      case 'coalesce_nonempty':
        return _callCoalesceWithReceiver(
          receiver,
          call.args,
          context,
          ruleLabel,
          currentEdge,
          requireNonempty: true,
        );
      default:
        if (_runtimeReceiverHelperNames.contains(helperName)) {
          return _callPureHelper(helperName, [
            receiver,
            ..._evaluateArgumentValues(
              call.args,
              context,
              ruleLabel,
              currentEdge,
            ),
          ]);
        }
        throw RuntimeInterpreterException(
          "unsupported runtime fluent method '.${call.method}' in rule $ruleLabel",
        );
    }
  }

  Object? _callSet(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.length < 2) {
      return null;
    }
    final value = _copyValue(
      _evaluateExpression(
        args[1],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
    );
    final arrayTarget = _arrayTargetName(args[0]);
    if (arrayTarget != null) {
      context.arrays[arrayTarget] = _asArray(value);
      return List<Object?>.unmodifiable(context.arrayFor(arrayTarget));
    }
    final hashTarget = _hashTargetName(args[0]);
    if (hashTarget != null) {
      context.hashes[hashTarget] = _asHash(value);
      return Map<String, Object?>.unmodifiable(context.hashFor(hashTarget));
    }
    final variableTarget = _variableName(args[0]);
    if (variableTarget == null) {
      throw RuntimeInterpreterException(
        'set target in rule $ruleLabel must be a variable or array(name)',
      );
    }
    context.variables[variableTarget] = value;
    return _copyValue(value);
  }

  Object? _callPush(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      final child = _requireCurrentEdgeChild(currentEdge, context, ruleLabel);
      context.arrayFor(ruleLabel).add(_copyValue(child.value));
      return List<Object?>.unmodifiable(context.arrayFor(ruleLabel));
    }

    if (args.length == 1 && currentEdge != null) {
      final target = _arrayTargetName(args[0]) ?? _variableName(args[0]);
      if (target == null) {
        throw RuntimeInterpreterException(
          'push target in rule $ruleLabel must be array(name) or a variable',
        );
      }
      final child = _executeActionEdgeChild(currentEdge, context);
      context.retv = child.value;
      context.arrayFor(target).add(_copyValue(child.value));
      return List<Object?>.unmodifiable(context.arrayFor(target));
    }

    if (args.length >= 2) {
      final firstName = _variableName(args[0]);
      final secondTarget = _arrayTargetName(args[1]) ?? _variableName(args[1]);
      if (currentEdge != null &&
          firstName != null &&
          compiledSpec.rule(firstName) != null &&
          secondTarget != null) {
        final child = firstName == currentEdge.target.label
            ? _executeActionEdgeChild(currentEdge, context)
            : _executeRule(firstName, 0, context);
        context.retv = child.value;
        context.arrayFor(secondTarget).add(_copyValue(child.value));
        return List<Object?>.unmodifiable(context.arrayFor(secondTarget));
      }

      final target = _arrayTargetName(args[0]) ?? _variableName(args[0]);
      if (target == null) {
        throw RuntimeInterpreterException(
          'push target in rule $ruleLabel must be array(name) or a variable',
        );
      }
      final value = _copyValue(
        _evaluateExpression(
          args[1],
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      );
      context.arrayFor(target).add(value);
      return List<Object?>.unmodifiable(context.arrayFor(target));
    }

    return null;
  }

  Object? _callArray(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.length == 1) {
      final name = _variableName(args.first);
      if (name != null) {
        return List<Object?>.unmodifiable(_arrayValueFor(context, name));
      }
    }
    return [
      for (final arg in args)
        _copyValue(
          _evaluateExpression(
            arg,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        ),
    ];
  }

  Object? _callHash(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.length == 1) {
      final name = _variableName(args.first);
      if (name != null) {
        return Map<String, Object?>.unmodifiable(_hashValueFor(context, name));
      }
    }

    final entries = <String, Object?>{};
    for (var index = 0; index < args.length; index += 2) {
      final key = _stringValue(
        _evaluateExpression(
          args[index],
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      );
      final value = index + 1 < args.length
          ? _copyValue(
              _evaluateExpression(
                args[index + 1],
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            )
          : null;
      entries[key] = value;
    }
    return entries;
  }

  List<Object?> _evaluateValues(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    return [
      for (final arg in args)
        _evaluateExpression(arg, context, ruleLabel, currentEdge: currentEdge),
    ];
  }

  List<Object?> _evaluateArgumentValues(
    List<ActionArgument> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    return [
      for (final arg in args)
        _evaluateExpression(
          arg.value,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
    ];
  }

  Object? _callCoalesce(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge, {
    required bool requireNonempty,
  }) {
    for (final arg in args) {
      final value = _evaluateExpression(
        arg,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      if (_coalesceAccepts(value, requireNonempty: requireNonempty)) {
        return _copyValue(value);
      }
    }
    return null;
  }

  Object? _callCoalesceWithReceiver(
    Object? receiver,
    List<ActionArgument> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge, {
    required bool requireNonempty,
  }) {
    if (_coalesceAccepts(receiver, requireNonempty: requireNonempty)) {
      return _copyValue(receiver);
    }
    for (final arg in args) {
      final value = _evaluateExpression(
        arg.value,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      if (_coalesceAccepts(value, requireNonempty: requireNonempty)) {
        return _copyValue(value);
      }
    }
    return null;
  }

  Object? _readRetv(
    _RuntimeExecutionContext context,
    _CurrentActionEdge? currentEdge,
  ) {
    if (context.retv != null || currentEdge == null) {
      return context.retv;
    }
    final child = _executeActionEdgeChild(currentEdge, context);
    context.retv = child.value;
    return child.value;
  }

  _RuleResult _requireCurrentEdgeChild(
    _CurrentActionEdge? currentEdge,
    _RuntimeExecutionContext context,
    String ruleLabel,
  ) {
    if (currentEdge == null) {
      throw RuntimeInterpreterException(
        'push() in rule $ruleLabel requires an action-edge child context',
      );
    }
    final child = _executeActionEdgeChild(currentEdge, context);
    context.retv = child.value;
    return child;
  }

  _RuleResult _executeActionEdgeChild(
    _CurrentActionEdge currentEdge,
    _RuntimeExecutionContext context,
  ) {
    currentEdge.childDispatched = true;
    final childRule = compiledSpec.rule(currentEdge.target.label);
    if (childRule == null) {
      throw RuntimeInterpreterException(
        "action edge references undefined child '${currentEdge.target.label}'",
      );
    }
    if (_isPassiveTerminalRule(childRule)) {
      return _RuleResult(matched: false, value: null);
    }
    return _executeRule(
      currentEdge.target.label,
      currentEdge.target.index,
      context,
    );
  }

  bool _isPassiveTerminalRule(CompiledRule rule) {
    return rule.lifecycleActionPayloads.isEmpty &&
        rule.actionEdges.isEmpty &&
        rule.blindEdges.isEmpty &&
        rule.plainActionPayloads.isEmpty;
  }
}

const _runtimePureHelperNames = <String>{
  'cat',
  'contains_substr',
  'ends_with',
  'is_defined',
  'is_empty',
  'is_nonempty',
  'is_undefined',
  'length',
  'lowercase',
  'matches',
  'num_abs',
  'num_add',
  'num_avg',
  'num_ceil',
  'num_clamp',
  'num_div',
  'num_eq',
  'num_floor',
  'num_ge',
  'num_gt',
  'num_le',
  'num_lt',
  'num_max',
  'num_median',
  'num_min',
  'num_mod',
  'num_mul',
  'num_ne',
  'num_range',
  'num_round',
  'num_sub',
  'num_sum',
  'replace_substr',
  'rm_prefix',
  'rm_suffix',
  'split',
  'starts_with',
  'str_eq',
  'str_ge',
  'str_gt',
  'str_le',
  'str_lt',
  'str_ne',
  'substr',
  'trim',
  'uppercase',
};

const _runtimeReceiverHelperNames = <String>{
  ..._runtimePureHelperNames,
  'coalesce',
  'coalesce_nonempty',
};

Object? _callPureHelper(String helperName, List<Object?> values) {
  if (helperName.startsWith('num_')) {
    return _callNumericHelper(helperName, values);
  }
  if (helperName.startsWith('str_')) {
    return _callStringCompareHelper(helperName, values);
  }
  return switch (helperName) {
    'cat' => _callCat(values),
    'contains_substr' => _callStringPredicate(
      values,
      (value, needle) => value.contains(needle),
    ),
    'ends_with' => _callStringPredicate(
      values,
      (value, suffix) => value.endsWith(suffix),
    ),
    'is_defined' => values.isNotEmpty && values.first != null,
    'is_empty' => _isEmptyValue(values.isEmpty ? null : values.first),
    'is_nonempty' => !_isEmptyValue(values.isEmpty ? null : values.first),
    'is_undefined' => values.isEmpty || values.first == null,
    'length' => _lengthValue(values.isEmpty ? null : values.first),
    'lowercase' => _stringTransform(values, (value) => value.toLowerCase()),
    'matches' => _callMatches(values),
    'replace_substr' => _callReplaceSubstr(values),
    'rm_prefix' => _callRemoveEdge(values, prefix: true),
    'rm_suffix' => _callRemoveEdge(values, prefix: false),
    'split' => _callSplit(values),
    'starts_with' => _callStringPredicate(
      values,
      (value, prefix) => value.startsWith(prefix),
    ),
    'substr' => _callSubstr(values),
    'trim' => _stringTransform(values, (value) => value.trim()),
    'uppercase' => _stringTransform(values, (value) => value.toUpperCase()),
    _ => throw RuntimeInterpreterException(
      "unsupported pure runtime helper '$helperName'",
    ),
  };
}

bool _coalesceAccepts(Object? value, {required bool requireNonempty}) {
  if (value == null) {
    return false;
  }
  if (!requireNonempty) {
    return true;
  }
  return value is! String || value.isNotEmpty;
}

Object? _callCat(List<Object?> values) {
  final buffer = StringBuffer();
  for (final value in values) {
    final string = _scalarString(value, nullAsEmpty: true);
    if (string == null) {
      return null;
    }
    buffer.write(string);
  }
  return buffer.toString();
}

Object? _stringTransform(
  List<Object?> values,
  String Function(String value) transform,
) {
  final value = values.isEmpty ? null : _scalarString(values.first);
  return value == null ? null : transform(value);
}

Object? _callStringPredicate(
  List<Object?> values,
  bool Function(String value, String needle) test,
) {
  if (values.length < 2) {
    return false;
  }
  final value = _scalarString(values[0]);
  final needle = _scalarString(values[1], nullAsEmpty: true);
  if (value == null || needle == null) {
    return false;
  }
  return test(value, needle);
}

Object? _callMatches(List<Object?> values) {
  if (values.length < 2) {
    return false;
  }
  final value = _scalarString(values[0]);
  final pattern = _scalarString(values[1]);
  if (value == null || pattern == null) {
    return false;
  }
  return RuntimeRegexAlternation.compile([pattern]).seekMatch(value, 0) != null;
}

Object? _callReplaceSubstr(List<Object?> values) {
  if (values.length < 3) {
    return null;
  }
  final value = _scalarString(values[0]);
  final oldValue = _scalarString(values[1], nullAsEmpty: true);
  final newValue = _scalarString(values[2], nullAsEmpty: true);
  if (value == null || oldValue == null || newValue == null) {
    return null;
  }
  if (oldValue.isEmpty) {
    return value;
  }
  return value.replaceAll(oldValue, newValue);
}

Object? _callRemoveEdge(List<Object?> values, {required bool prefix}) {
  if (values.length < 2) {
    return null;
  }
  final value = _scalarString(values[0]);
  final edge = _scalarString(values[1], nullAsEmpty: true);
  if (value == null || edge == null) {
    return null;
  }
  if (prefix) {
    return value.startsWith(edge) ? value.substring(edge.length) : value;
  }
  return value.endsWith(edge)
      ? value.substring(0, value.length - edge.length)
      : value;
}

Object? _callSubstr(List<Object?> values) {
  if (values.length < 2 || values.first == null || values[1] == null) {
    return null;
  }
  final value = _scalarString(values[0]);
  if (value == null) {
    return null;
  }
  final start = math.max(0, _intValue(values[1]) ?? 0);
  final length = values.length >= 3 && values[2] != null
      ? math.max(0, _intValue(values[2]) ?? 0)
      : null;
  return _charSubstring(value, start, length);
}

Object? _callSplit(List<Object?> values) {
  if (values.length < 2) {
    return null;
  }
  final value = _scalarString(values[0]);
  final delimiter = _scalarString(values[1], nullAsEmpty: true);
  if (value == null || delimiter == null) {
    return null;
  }
  if (delimiter.isEmpty) {
    return [for (final rune in value.runes) String.fromCharCode(rune)];
  }
  return value.split(delimiter);
}

Object? _lengthValue(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.runes.length;
  }
  if (value is List) {
    return value.length;
  }
  return _scalarString(value)?.runes.length;
}

bool _isEmptyValue(Object? value) {
  return switch (value) {
    null => true,
    String value => value.isEmpty,
    List<dynamic> value => value.isEmpty,
    Map<dynamic, dynamic> value => value.isEmpty,
    _ => false,
  };
}

Object? _callStringCompareHelper(String helperName, List<Object?> values) {
  if (values.length < 2) {
    return null;
  }
  final left = _scalarString(values[0]);
  final right = _scalarString(values[1]);
  if (left == null || right == null) {
    return null;
  }
  final comparison = left.compareTo(right);
  return switch (helperName) {
    'str_eq' => comparison == 0,
    'str_ne' => comparison != 0,
    'str_gt' => comparison > 0,
    'str_ge' => comparison >= 0,
    'str_lt' => comparison < 0,
    'str_le' => comparison <= 0,
    _ => throw RuntimeInterpreterException(
      "unsupported string comparison helper '$helperName'",
    ),
  };
}

Object? _callNumericHelper(String helperName, List<Object?> values) {
  switch (helperName) {
    case 'num_add':
      return _numericFold(values, (left, right) => left + right);
    case 'num_sub':
      return _numericFold(values, (left, right) => left - right);
    case 'num_mul':
      return _numericFold(values, (left, right) => left * right);
    case 'num_div':
      return _numericFold(values, (left, right) {
        if (right == 0) {
          throw const _InvalidNumericResult();
        }
        return left / right;
      });
    case 'num_mod':
      if (values.length < 2) {
        return null;
      }
      final left = _numValue(values[0]);
      final right = _numValue(values[1]);
      if (left == null ||
          right == null ||
          right == 0 ||
          !_isInteger(left) ||
          !_isInteger(right)) {
        return null;
      }
      return left.toInt() % right.toInt();
    case 'num_abs':
      return _unaryNumber(values, (value) => value.abs());
    case 'num_floor':
      return _unaryNumber(values, (value) => value.floor());
    case 'num_ceil':
      return _unaryNumber(values, (value) => value.ceil());
    case 'num_round':
      return _unaryNumber(values, (value) => value.round());
    case 'num_min':
      return _minMax(values, math.min);
    case 'num_max':
      return _minMax(values, math.max);
    case 'num_clamp':
      if (values.length < 3) {
        return null;
      }
      final value = _numValue(values[0]);
      final lower = _numValue(values[1]);
      final upper = _numValue(values[2]);
      if (value == null || lower == null || upper == null || lower > upper) {
        return null;
      }
      return _jsonNumber(value.clamp(lower, upper));
    case 'num_sum':
      final numbers = _numericList(values.isEmpty ? null : values.first);
      if (numbers == null) {
        return null;
      }
      return _jsonNumber(numbers.fold<num>(0, (sum, value) => sum + value));
    case 'num_avg':
      final numbers = _numericList(values.isEmpty ? null : values.first);
      if (numbers == null || numbers.isEmpty) {
        return null;
      }
      return _jsonNumber(
        numbers.fold<num>(0, (sum, value) => sum + value) / numbers.length,
      );
    case 'num_median':
      final numbers = _numericList(values.isEmpty ? null : values.first);
      if (numbers == null || numbers.isEmpty) {
        return null;
      }
      final sorted = [...numbers]..sort();
      final middle = sorted.length ~/ 2;
      if (sorted.length.isOdd) {
        return _jsonNumber(sorted[middle]);
      }
      return _jsonNumber((sorted[middle - 1] + sorted[middle]) / 2);
    case 'num_range':
      final numbers = _numericList(values.isEmpty ? null : values.first);
      if (numbers == null || numbers.isEmpty) {
        return null;
      }
      var minimum = numbers.first;
      var maximum = numbers.first;
      for (final value in numbers.skip(1)) {
        minimum = math.min(minimum, value);
        maximum = math.max(maximum, value);
      }
      return _jsonNumber(maximum - minimum);
    case 'num_eq':
    case 'num_ne':
    case 'num_gt':
    case 'num_ge':
    case 'num_lt':
    case 'num_le':
      return _numericCompare(helperName, values);
    default:
      throw RuntimeInterpreterException(
        "unsupported numeric helper '$helperName'",
      );
  }
}

Object? _numericFold(
  List<Object?> values,
  num Function(num left, num right) combine,
) {
  if (values.isEmpty) {
    return null;
  }
  final first = _numValue(values.first);
  if (first == null) {
    return null;
  }
  var current = first;
  try {
    for (final value in values.skip(1)) {
      final next = _numValue(value);
      if (next == null) {
        return null;
      }
      current = combine(current, next);
    }
  } on _InvalidNumericResult {
    return null;
  }
  return _jsonNumber(current);
}

Object? _unaryNumber(List<Object?> values, num Function(num value) transform) {
  if (values.isEmpty) {
    return null;
  }
  final value = _numValue(values.first);
  return value == null ? null : _jsonNumber(transform(value));
}

Object? _minMax(
  List<Object?> values,
  num Function(num left, num right) select,
) {
  if (values.length == 1 && values.first is List) {
    final numbers = _numericList(values.first);
    if (numbers == null || numbers.isEmpty) {
      return null;
    }
    return _jsonNumber(numbers.skip(1).fold<num>(numbers.first, select));
  }
  return _numericFold(values, select);
}

Object? _numericCompare(String helperName, List<Object?> values) {
  if (values.length < 2) {
    return null;
  }
  final left = _numValue(values[0]);
  final right = _numValue(values[1]);
  if (left == null || right == null) {
    return null;
  }
  return switch (helperName) {
    'num_eq' => left == right,
    'num_ne' => left != right,
    'num_gt' => left > right,
    'num_ge' => left >= right,
    'num_lt' => left < right,
    'num_le' => left <= right,
    _ => throw RuntimeInterpreterException(
      "unsupported numeric comparison helper '$helperName'",
    ),
  };
}

List<num>? _numericList(Object? value) {
  if (value is! List) {
    return null;
  }
  final numbers = <num>[];
  for (final item in value) {
    final number = _numValue(item);
    if (number == null) {
      return null;
    }
    numbers.add(number);
  }
  return numbers;
}

num? _numValue(Object? value) {
  if (value == null || value is List || value is Map || value is bool) {
    return null;
  }
  if (value is num) {
    return value.isFinite ? value : null;
  }
  final text = '$value'.trim();
  if (text.isEmpty) {
    return null;
  }
  final parsed = num.tryParse(text);
  return parsed != null && parsed.isFinite ? parsed : null;
}

int? _intValue(Object? value) {
  if (value == null || value is List || value is Map || value is bool) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value'.trim());
}

bool _isInteger(num value) {
  return value.isFinite && value == value.truncateToDouble();
}

Object _jsonNumber(num value) {
  if (_isInteger(value)) {
    return value.toInt();
  }
  return value;
}

String? _scalarString(Object? value, {bool nullAsEmpty = false}) {
  if (value == null) {
    return nullAsEmpty ? '' : null;
  }
  if (value is List || value is Map) {
    return null;
  }
  return '$value';
}

String _charSubstring(String value, int start, int? length) {
  final chars = value.runes.toList();
  if (start >= chars.length) {
    return '';
  }
  final end = length == null
      ? chars.length
      : math.min(chars.length, start + length);
  return String.fromCharCodes(chars.sublist(start, end));
}

final class _InvalidNumericResult implements Exception {
  const _InvalidNumericResult();
}

final class _RuntimeExecutionContext {
  _RuntimeExecutionContext({
    required this.engine,
    required this.input,
    required this.parseMode,
    required this.maxIterations,
  }) : registers = RuntimeMatchRegisters.empty(input);

  final LinkedSpecRuntimeEngine engine;
  final String input;
  final LinkedSpecParseMode parseMode;
  final int maxIterations;
  final Map<String, Object?> variables = <String, Object?>{};
  final Map<String, List<Object?>> arrays = <String, List<Object?>>{};
  final Map<String, Map<String, Object?>> hashes =
      <String, Map<String, Object?>>{};
  final Set<String> activeRuleEntries = <String>{};
  final List<RuntimeLifecycleEvent> lifecycleEvents = <RuntimeLifecycleEvent>[];

  RuntimeMatchRegisters registers;
  Object? retv;
  int cursorCodeUnit = 0;

  List<Object?> arrayFor(String name) {
    return arrays.putIfAbsent(name, () => <Object?>[]);
  }

  Map<String, Object?> hashFor(String name) {
    return hashes.putIfAbsent(name, () => <String, Object?>{});
  }
}

final class _RegexPlan {
  const _RegexPlan({required this.patterns, required this.dependencyRefs});

  final List<String> patterns;
  final List<DependencyRef> dependencyRefs;
}

final class _MatchedActionEdge {
  const _MatchedActionEdge({required this.edge, required this.target});

  final CompiledActionEdge edge;
  final DependencyRef target;
}

final class _CurrentActionEdge {
  _CurrentActionEdge({
    required this.ruleLabel,
    required this.edge,
    required this.target,
  });

  final String ruleLabel;
  final CompiledActionEdge edge;
  final DependencyRef target;
  bool childDispatched = false;
}

final class _RuleResult {
  const _RuleResult({required this.matched, required this.value});

  final bool matched;
  final Object? value;
}

final class _ActionReturn implements Exception {
  const _ActionReturn(this.value);

  final Object? value;
}

_RuleResult _returned(Object? value) {
  return _RuleResult(matched: _truthy(value), value: _copyValue(value));
}

Object? _captureAt(
  RuntimeRegexMatch? match,
  List<ActionExpr> args,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (match == null || args.isEmpty) {
    return null;
  }
  final indexValue = context.engine._evaluateExpression(
    args.first,
    context,
    ruleLabel,
    currentEdge: currentEdge,
  );
  final index = indexValue is num
      ? indexValue.toInt()
      : int.tryParse('$indexValue');
  if (index == null || index < 0 || index >= match.captures.length) {
    return null;
  }
  return match.captures[index];
}

String _ruleNameFromExpr(
  ActionExpr expr,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final name = _variableName(expr);
  if (name != null) {
    return name;
  }
  final evaluated = context.engine._evaluateExpression(
    expr,
    context,
    ruleLabel,
    currentEdge: currentEdge,
  );
  return _stringValue(evaluated);
}

String? _arrayTargetName(ActionExpr expr) {
  if (expr is! ActionCallExpr ||
      expr.name != 'array' ||
      expr.args.length != 1) {
    return null;
  }
  return _variableName(expr.args.single.value);
}

String? _hashTargetName(ActionExpr expr) {
  if (expr is! ActionCallExpr || expr.name != 'hash' || expr.args.length != 1) {
    return null;
  }
  return _variableName(expr.args.single.value);
}

String? _variableName(ActionExpr expr) {
  return switch (expr) {
    ActionVariableExpr(:final name) => name,
    _ => null,
  };
}

List<Object?> _asArray(Object? value) {
  if (value is List<Object?>) {
    return [for (final item in value) _copyValue(item)];
  }
  if (value is List) {
    return [for (final item in value) _copyValue(item)];
  }
  return <Object?>[];
}

Map<String, Object?> _asHash(Object? value) {
  if (value is Map<String, Object?>) {
    return {
      for (final entry in value.entries) entry.key: _copyValue(entry.value),
    };
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        '${entry.key}': _copyValue(entry.value),
    };
  }
  return <String, Object?>{};
}

List<Object?> _arrayValueFor(_RuntimeExecutionContext context, String name) {
  final stored = context.arrays[name];
  if (stored != null) {
    return [for (final item in stored) _copyValue(item)];
  }
  final variable = context.variables[name];
  if (variable is List) {
    return [for (final item in variable) _copyValue(item)];
  }
  return <Object?>[];
}

Map<String, Object?> _hashValueFor(
  _RuntimeExecutionContext context,
  String name,
) {
  final stored = context.hashes[name];
  if (stored != null) {
    return {
      for (final entry in stored.entries) entry.key: _copyValue(entry.value),
    };
  }
  final variable = context.variables[name];
  if (variable is Map) {
    return _asHash(variable);
  }
  return <String, Object?>{};
}

Object? _readNested(
  Object? root,
  List<ActionAccessSegment> segments,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  var value = root;
  for (final segment in segments) {
    switch (segment) {
      case ActionKeyAccessSegment(value: final key):
        value = value is Map ? value[key] : null;
      case ActionIndexAccessSegment(:final expr):
        final index = context.engine._evaluateExpression(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
        value = _indexValue(value, index);
    }
  }
  return value;
}

Object? _indexValue(Object? collection, Object? indexValue) {
  if (collection is Map) {
    return collection[_stringValue(indexValue)];
  }
  final index = indexValue is num
      ? indexValue.toInt()
      : int.tryParse('$indexValue');
  if (collection is List &&
      index != null &&
      index >= 0 &&
      index < collection.length) {
    return collection[index];
  }
  return null;
}

Object _rootForWrite(
  _RuntimeExecutionContext context,
  String base,
  List<ActionAccessSegment> segments,
) {
  final existing =
      context.variables[base] ?? context.arrays[base] ?? context.hashes[base];
  if (existing != null) {
    return existing;
  }
  final root = segments.first is ActionIndexAccessSegment
      ? <Object?>[]
      : <String, Object?>{};
  context.variables[base] = root;
  return root;
}

void _writeNested(
  Object root,
  List<ActionAccessSegment> segments,
  Object? value,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (segments.isEmpty) {
    throw RuntimeInterpreterException(
      'nested assignment in rule $ruleLabel requires at least one segment',
    );
  }
  var node = root;
  for (var index = 0; index < segments.length; index += 1) {
    final isLast = index == segments.length - 1;
    final segment = segments[index];
    switch (segment) {
      case ActionKeyAccessSegment(value: final key):
        if (node is! Map<String, Object?>) {
          throw RuntimeInterpreterException(
            'nested key assignment in rule $ruleLabel needs a hash parent',
          );
        }
        if (isLast) {
          node[key] = value;
        } else {
          final child = node[key] ?? _emptyContainerFor(segments[index + 1]);
          node[key] = child;
          node = child;
        }
      case ActionIndexAccessSegment(:final expr):
        final rawIndex = context.engine._evaluateExpression(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
        final listIndex = rawIndex is num
            ? rawIndex.toInt()
            : int.tryParse('$rawIndex');
        if (node is! List<Object?> || listIndex == null || listIndex < 0) {
          throw RuntimeInterpreterException(
            'nested index assignment in rule $ruleLabel needs an array parent',
          );
        }
        while (node.length <= listIndex) {
          node.add(null);
        }
        if (isLast) {
          node[listIndex] = value;
        } else {
          final child =
              node[listIndex] ?? _emptyContainerFor(segments[index + 1]);
          node[listIndex] = child;
          node = child;
        }
    }
  }
}

Object _emptyContainerFor(ActionAccessSegment segment) {
  return segment is ActionIndexAccessSegment
      ? <Object?>[]
      : <String, Object?>{};
}

Object? _copyArgument(
  ActionExpr expr,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final name = _variableName(expr);
  if (name != null) {
    if (context.arrays.containsKey(name)) {
      return _arrayValueFor(context, name);
    }
    if (context.hashes.containsKey(name)) {
      return _hashValueFor(context, name);
    }
  }
  return _copyValue(
    context.engine._evaluateExpression(
      expr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    ),
  );
}

Object? _namedCapture(
  RuntimeRegexMatch? match,
  List<ActionExpr> args,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (match == null || args.isEmpty) {
    return null;
  }
  final name = _captureName(args.first, context, ruleLabel, currentEdge);
  return match.namedCapture(name);
}

bool _hasNamedCapture(
  RuntimeRegexMatch? match,
  List<ActionExpr> args,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (match == null || args.isEmpty) {
    return false;
  }
  final name = _captureName(args.first, context, ruleLabel, currentEdge);
  return match.named.containsKey(name);
}

String _captureName(
  ActionExpr expr,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final literalName = _variableName(expr);
  if (literalName != null) {
    return literalName;
  }
  return _stringValue(
    context.engine._evaluateExpression(
      expr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    ),
  );
}

Object? _copyValue(Object? value) {
  if (value is List<Object?>) {
    return [for (final item in value) _copyValue(item)];
  }
  if (value is List) {
    return [for (final item in value) _copyValue(item)];
  }
  if (value is Map<String, Object?>) {
    return {
      for (final entry in value.entries) entry.key: _copyValue(entry.value),
    };
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        '${entry.key}': _copyValue(entry.value),
    };
  }
  return value;
}

String _stringValue(Object? value) {
  if (value == null) {
    return '';
  }
  return '$value';
}

bool _truthy(Object? value) {
  return switch (value) {
    null => false,
    bool value => value,
    num value => value != 0,
    String value => value.isNotEmpty,
    List<dynamic> value => value.isNotEmpty,
    Map<dynamic, dynamic> value => value.isNotEmpty,
    _ => true,
  };
}
