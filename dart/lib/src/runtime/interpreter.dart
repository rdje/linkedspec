import '../action/action_ast.dart';
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
    switch (call.name) {
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
      case 'cat':
        return positionalArgs
            .map(
              (arg) => _stringValue(
                _evaluateExpression(
                  arg,
                  context,
                  ruleLabel,
                  currentEdge: currentEdge,
                ),
              ),
            )
            .join();
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
    switch (call.method) {
      case 'copy':
        return _copyValue(receiver);
      case 'cat':
        return _stringValue(receiver) +
            call.args
                .map(
                  (arg) => _stringValue(
                    _evaluateExpression(
                      arg.value,
                      context,
                      ruleLabel,
                      currentEdge: currentEdge,
                    ),
                  ),
                )
                .join();
      default:
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
