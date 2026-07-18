import 'dart:math' as math;

import '../action/action_ast.dart';
import '../action/action_contracts.dart';
import '../action/action_parser.dart';
import '../action/function_registry.dart';
import '../ast/spec_ast.dart';
import '../compiler/compiled_spec.dart';
import '../trace/trace.dart';
import 'generated_plan.dart';
import 'matching.dart';
import 'unicode_case_mapping.dart';

final _leadingBlankLine = RegExp(r'[ \t]*\n');
final _leadingCommentLine = RegExp(r'[ \t]*#[^\n]*(?:\n|$)');

final class RuntimeDiagnostic {
  const RuntimeDiagnostic({
    required this.type,
    required this.stage,
    required this.summary,
    required this.detail,
    this.code,
    this.helperName,
    this.actualArity,
    this.expectedArity,
    this.ownerStage,
    this.specName,
    this.specPath,
    this.topRule,
    this.entryRule,
    this.ruleLabel,
    this.handlerSourceLabel,
  });

  final String type;
  final String stage;
  final String? ownerStage;
  final String summary;
  final String detail;
  final String? code;
  final String? helperName;
  final int? actualArity;
  final String? expectedArity;
  final String? specName;
  final String? specPath;
  final String? topRule;
  final String? entryRule;
  final String? ruleLabel;
  final String? handlerSourceLabel;

  JsonObject toJson() => {
    'type': type,
    'stage': stage,
    if (ownerStage != null) 'owner_stage': ownerStage,
    'summary': summary,
    'detail': detail,
    if (code != null) 'code': code,
    if (helperName != null) 'helper_name': helperName,
    if (actualArity != null) 'actual_arity': actualArity,
    if (expectedArity != null) 'expected_arity': expectedArity,
    if (specName != null) 'spec_name': specName,
    if (specPath != null) 'spec_path': specPath,
    if (topRule != null) 'top_rule': topRule,
    if (entryRule != null) 'entry_rule': entryRule,
    if (ruleLabel != null) 'rule_label': ruleLabel,
    if (handlerSourceLabel != null) 'handler_source_label': handlerSourceLabel,
  };
}

final class RuntimeInterpreterException implements Exception {
  const RuntimeInterpreterException(this.message, {this.diagnostic});

  final String message;
  final RuntimeDiagnostic? diagnostic;

  RuntimeInterpreterException withDiagnostic(RuntimeDiagnostic diagnostic) {
    if (this.diagnostic != null) {
      return this;
    }
    return RuntimeInterpreterException(message, diagnostic: diagnostic);
  }

  JsonObject toJson() => {
    'message': message,
    if (diagnostic != null) 'diagnostic': diagnostic!.toJson(),
  };

  @override
  String toString() => 'RuntimeInterpreterException: $message';
}

final class RuntimeDiagnosticOutputEvent {
  const RuntimeDiagnosticOutputEvent({
    required this.helperName,
    required this.ruleLabel,
    required this.message,
  });

  final String helperName;
  final String ruleLabel;
  final String message;

  JsonObject toJson() => {
    'helper_name': helperName,
    'rule_label': ruleLabel,
    'message': message,
  };
}

typedef RuntimeDiagnosticOutputSink =
    void Function(RuntimeDiagnosticOutputEvent event);

final class RuntimeExitNow implements Exception {
  const RuntimeExitNow(this.status);

  final int status;

  @override
  String toString() => 'RuntimeExitNow($status)';
}

final class _RuntimeDiagnosticOutputSinkFailure implements Exception {
  const _RuntimeDiagnosticOutputSinkFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
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
    this.maxIterations = 10000,
    this.specName,
    this.specPath,
  });

  final CompiledSpec compiledSpec;
  final int maxIterations;
  final String? specName;
  final String? specPath;
  final Map<int, ActionBlock> _userFunctionBodyCache = <int, ActionBlock>{};

  RuntimeParseResult parse(
    String input, {
    String? topRule,
    LinkedSpecTraceEmitter? trace,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  }) {
    return _parse(
      input,
      topRule: topRule,
      trace: trace,
      diagnosticOutputSink: diagnosticOutputSink,
    );
  }

  /// Execute through a validated generated-family plan.
  ///
  /// Generated source adapters validate ordered labels and families before
  /// calling this method. Each rule entry then selects its structural executor
  /// from [generatedPlan] instead of re-classifying the compiled rule.
  RuntimeParseResult executeGeneratedWithPlan(
    String input,
    Map<String, GeneratedRuleFamily> generatedPlan,
    String sourceIdentity, {
    String? topRule,
    LinkedSpecTraceEmitter? trace,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  }) {
    return _parse(
      input,
      topRule: topRule,
      trace: trace,
      diagnosticOutputSink: diagnosticOutputSink,
      generatedPlan: Map.unmodifiable(generatedPlan),
      generatedSourceIdentity: sourceIdentity,
    );
  }

  RuntimeParseResult _parse(
    String input, {
    String? topRule,
    LinkedSpecTraceEmitter? trace,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
    Map<String, GeneratedRuleFamily>? generatedPlan,
    String? generatedSourceIdentity,
  }) {
    final ResolvedEntryRule selection;
    try {
      selection = compiledSpec.resolveEntryRule(topRule);
    } on EntryRuleSelectionException catch (error) {
      throw RuntimeInterpreterException(
        error.message,
        diagnostic: _diagnostic(
          stage: error.stage,
          code: error.code,
          summary: 'Dart runtime entry-rule selection failed',
          detail: error.message,
          topRule: error.entryRule,
          entryRule: error.entryRule,
          ruleLabel: error.entryRule,
        ),
      );
    }
    final label = selection.rule.label;
    final context = _RuntimeExecutionContext(
      engine: this,
      input: input,
      maxIterations: maxIterations,
      topRule: label,
      trace: trace,
      diagnosticOutputSink: diagnosticOutputSink,
      generatedPlan: generatedPlan,
      generatedSourceIdentity: generatedSourceIdentity,
    );
    // Mirror Perl's public parser wrapper; direct descriptor handlers bypass
    // this leading trivia skip.
    context._setCursorCodeUnit(_publicParserStartCursor(input));
    final traceScope = trace?.enterScope(
      'dart_runtime:parse',
      'top_rule=$label',
      LinkedSpecTraceLevel.high,
    );
    try {
      final result = _executeRule(label, 0, context);
      final parseResult = RuntimeParseResult(
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
      if (traceScope != null) {
        trace?.exitScope(
          traceScope,
          'matched=${parseResult.matched} cursor=${parseResult.cursorCodeUnit}',
        );
      }
      return parseResult;
    } on _RuntimeDiagnosticOutputSinkFailure catch (failure) {
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'diagnostic_output_sink_error');
      }
      Error.throwWithStackTrace(failure.error, failure.stackTrace);
    } on RuntimeExitNow catch (exit) {
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'exit_status=${exit.status}');
      }
      rethrow;
    } on RuntimeInterpreterException catch (error) {
      final wrapped = error.withDiagnostic(
        context.diagnostic(
          stage: 'runtime_execution',
          summary: 'Dart runtime interpreter failed',
          detail: error.message,
          ruleLabel: context.currentRuleLabel ?? label,
        ),
      );
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'error=${wrapped.message}');
      }
      throw wrapped;
    }
  }

  RuntimeParseResult parseWithTrace(
    String input,
    LinkedSpecTraceConfig traceConfig, {
    String? topRule,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  }) {
    final trace = LinkedSpecTraceEmitter(traceConfig);
    return parse(
      input,
      topRule: topRule,
      trace: trace,
      diagnosticOutputSink: diagnosticOutputSink,
    );
  }

  RuntimeParseResult execute(
    String input, {
    String? topRule,
    LinkedSpecTraceEmitter? trace,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  }) {
    return parse(
      input,
      topRule: topRule,
      trace: trace,
      diagnosticOutputSink: diagnosticOutputSink,
    );
  }

  RuntimeParseResult executeWithTrace(
    String input,
    LinkedSpecTraceConfig traceConfig, {
    String? topRule,
    RuntimeDiagnosticOutputSink? diagnosticOutputSink,
  }) {
    return parseWithTrace(
      input,
      traceConfig,
      topRule: topRule,
      diagnosticOutputSink: diagnosticOutputSink,
    );
  }

  int _publicParserStartCursor(String input) {
    var cursor = 0;
    while (cursor < input.length) {
      final blank = _leadingBlankLine.matchAsPrefix(input, cursor);
      if (blank != null) {
        cursor = blank.end;
        continue;
      }
      final comment = _leadingCommentLine.matchAsPrefix(input, cursor);
      if (comment != null) {
        cursor = comment.end;
        continue;
      }
      break;
    }
    return cursor;
  }

  _RuleResult _executeRule(
    String label,
    int entryRegexIndex,
    _RuntimeExecutionContext context,
  ) {
    final rule = compiledSpec.rule(label);
    if (rule == null) {
      throw RuntimeInterpreterException(
        "rule '$label' is not compiled",
        diagnostic: context.diagnostic(
          stage: 'rule_lookup',
          summary: 'Dart runtime rule lookup failed',
          detail: "rule '$label' is not compiled",
          ruleLabel: label,
        ),
      );
    }

    final generatedFamily = context.generatedPlan?[label];
    if (context.generatedPlan != null && generatedFamily == null) {
      throw RuntimeInterpreterException(
        "generated rule plan does not contain '$label'",
        diagnostic: context.diagnostic(
          stage: 'generated_rule_plan',
          summary: 'Dart generated rule plan lookup failed',
          detail: "generated rule plan does not contain '$label'",
          ruleLabel: label,
        ),
      );
    }
    final executionPolicy = _executionPolicyFor(rule, generatedFamily);

    final recursionKey = '$label:$entryRegexIndex:${context.cursorCodeUnit}';
    if (!context.activeRuleEntries.add(recursionKey)) {
      context.trace?.traceDecision(
        'dart_runtime:recursion_guard',
        true,
        'rule=$label entry_regex=$entryRegexIndex cursor=${context.cursorCodeUnit}',
        LinkedSpecTraceLevel.debug,
      );
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
    context.enterRule(label);
    context.enterRuleLocalBindingScope();
    final generatedIdentity = context.generatedSourceIdentity;
    if (generatedFamily != null && generatedIdentity != null) {
      context.trace?.emitEvent(
        LinkedSpecTraceEventKind.mark,
        'generated_rule_enter',
        'source_identity=$generatedIdentity rule=$label '
            'entry_regex_idx=$entryRegexIndex cursor=${context.cursorCodeUnit}',
        LinkedSpecTraceLevel.low,
      );
      context.trace?.emitEvent(
        LinkedSpecTraceEventKind.mark,
        'generated_family_decision',
        'source_identity=$generatedIdentity rule=$label '
            'family=${generatedFamily.wireName}',
        LinkedSpecTraceLevel.low,
      );
    }
    final traceScope = context.trace?.enterScope(
      'dart_runtime:rule',
      'label=$label entry_regex=$entryRegexIndex '
          'mode=${rule.modeMetadata.name} '
          'cursor_policy=${executionPolicy.cursorPolicy.name} '
          'cursor=${context.cursorCodeUnit}',
      LinkedSpecTraceLevel.high,
    );
    var traceExitDetails = 'matched=false cursor=${context.cursorCodeUnit}';

    try {
      final initReturn = _executeLifecycle(rule, 'I', context);
      if (initReturn != null) {
        final result = _returned(initReturn.value);
        traceExitDetails =
            'matched=${result.matched} cursor=${context.cursorCodeUnit}';
        return result;
      }

      try {
        final usesBlindDispatch =
            generatedFamily?.usesBlindDispatch ?? rule.blindEdges.isNotEmpty;
        final result = usesBlindDispatch
            ? _executeBlindRule(
                rule,
                context,
                usesAndExecution: executionPolicy.usesAndExecution,
              )
            : _executeRegexRule(
                rule,
                entryRegexIndex,
                context,
                cursorPolicy: executionPolicy.cursorPolicy,
                usesAndExecution: executionPolicy.usesAndExecution,
              );
        traceExitDetails =
            'matched=${result.matched} cursor=${context.cursorCodeUnit}';
        return result;
      } on _ActionReturn catch (returnSignal) {
        final result = _returned(returnSignal.value);
        traceExitDetails =
            'matched=${result.matched} cursor=${context.cursorCodeUnit}';
        return result;
      }
    } on RuntimeInterpreterException catch (error) {
      traceExitDetails =
          'error=${error.message} cursor=${context.cursorCodeUnit}';
      throw error.withDiagnostic(
        context.diagnostic(
          stage: 'runtime_execution',
          summary: 'Dart runtime interpreter failed',
          detail: error.message,
          ruleLabel: label,
        ),
      );
    } finally {
      if (traceScope != null) {
        context.trace?.exitScope(traceScope, traceExitDetails);
      }
      if (generatedFamily != null && generatedIdentity != null) {
        context.trace?.emitEvent(
          LinkedSpecTraceEventKind.mark,
          'generated_rule_exit',
          'source_identity=$generatedIdentity rule=$label '
              'family=${generatedFamily.wireName} $traceExitDetails',
          LinkedSpecTraceLevel.low,
        );
      }
      context.exitRuleLocalBindingScope();
      context.exitRule();
      context.registers = savedRegisters;
      context.activeRuleEntries.remove(recursionKey);
    }
  }

  _RuleExecutionPolicy _executionPolicyFor(
    CompiledRule rule,
    GeneratedRuleFamily? generatedFamily,
  ) {
    if (generatedFamily != null) {
      return _RuleExecutionPolicy(
        cursorPolicy: generatedFamily.cursorPolicy,
        usesAndExecution: generatedFamily.usesAndExecution,
      );
    }
    return _RuleExecutionPolicy(
      cursorPolicy: rule.modeMetadata.isAnd
          ? LinkedSpecParseMode.consume
          : LinkedSpecParseMode.seek,
      usesAndExecution: rule.modeMetadata.isAnd,
    );
  }

  RuntimeDiagnostic _diagnostic({
    required String stage,
    required String summary,
    required String detail,
    String? code,
    String? helperName,
    int? actualArity,
    String? expectedArity,
    String? topRule,
    String? entryRule,
    String? ruleLabel,
    String? handlerSourceLabel,
  }) {
    final effectiveRule = ruleLabel ?? topRule;
    return RuntimeDiagnostic(
      type: 'runtime_parser',
      stage: stage,
      ownerStage: 'dart_runtime',
      summary: summary,
      detail: detail,
      code: code,
      helperName: helperName,
      actualArity: actualArity,
      expectedArity: expectedArity,
      specName: specName,
      specPath: specPath,
      topRule: topRule,
      entryRule: entryRule,
      ruleLabel: ruleLabel,
      handlerSourceLabel:
          handlerSourceLabel ??
          (effectiveRule == null
              ? 'dart_runtime'
              : 'dart_runtime:rule:$effectiveRule'),
    );
  }

  _RuleResult _executeBlindRule(
    CompiledRule rule,
    _RuntimeExecutionContext context, {
    required bool usesAndExecution,
  }) {
    final min = rule.modeMetadata.repMin;
    if (min == null) {
      final implicitAndResult = <Object?>[];
      var matchedAny = false;
      for (
        var iteration = 0;
        iteration < context.maxIterations;
        iteration += 1
      ) {
        final before = context.cursorCodeUnit;
        final matched = _nextableBool(
          () => _executeBlindOnce(
            rule,
            context,
            usesAndExecution: usesAndExecution,
            implicitAndResult: implicitAndResult,
          ),
        );
        if (matched.nexted) {
          matchedAny = true;
          if (context.cursorCodeUnit == before) {
            break;
          }
          continue;
        }
        if (!matched.value) {
          final loopExit = _executeLifecycle(rule, 'LX', context);
          if (loopExit != null) {
            return _returned(loopExit.value);
          }
        }
        final exitReturn = _executeLifecycle(rule, 'E', context);
        if (exitReturn != null) {
          return _returned(exitReturn.value);
        }
        return _RuleResult(
          matched: matched.value || matchedAny,
          value: usesAndExecution && implicitAndResult.isNotEmpty
              ? List<Object?>.unmodifiable(implicitAndResult)
              : null,
        );
      }
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
      final exitReturn = _executeLifecycle(rule, 'E', context);
      if (exitReturn != null) {
        return _returned(exitReturn.value);
      }
      return _RuleResult(
        matched: matchedAny,
        value: usesAndExecution && implicitAndResult.isNotEmpty
            ? List<Object?>.unmodifiable(implicitAndResult)
            : null,
      );
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

      final matched = _nextableBool(
        () => _executeBlindOnce(
          rule,
          context,
          usesAndExecution: usesAndExecution,
        ),
      );
      if (matched.nexted) {
        matches += 1;
        if (context.cursorCodeUnit == before) {
          break;
        }
        continue;
      }
      if (!matched.value) {
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

  bool _executeBlindOnce(
    CompiledRule rule,
    _RuntimeExecutionContext context, {
    required bool usesAndExecution,
    List<Object?>? implicitAndResult,
  }) {
    if (usesAndExecution) {
      var matchedAll = true;
      for (
        var edgeIndex = 0;
        edgeIndex < rule.blindEdges.length;
        edgeIndex += 1
      ) {
        final edge = rule.blindEdges[edgeIndex];
        final before = context.cursorCodeUnit;
        final child = _executeRule(
          edge.target.label,
          edge.target.index,
          context,
        );
        final childMatched = child.matched;
        context.trace?.traceDecision(
          'dart_runtime:child_dispatch',
          childMatched,
          'edge_family=blind mode=AND rule=${rule.label} index=$edgeIndex '
              'target=${edge.target.label}[${edge.target.index}] '
              'cursor_before=$before cursor_after=${context.cursorCodeUnit}',
          LinkedSpecTraceLevel.debug,
        );
        context.retv = child.value;
        if (childMatched) {
          implicitAndResult?.add(_copyValue(child.value));
        }
        final edgeReturn = _executeOptionalPayload(
          edge.actionPayload,
          context,
          rule.label,
          currentEdge: null,
        );
        if (edgeReturn != null) {
          throw _ActionReturn(edgeReturn.value);
        }
        if (!childMatched) {
          matchedAll = false;
          break;
        }
      }
      return matchedAll;
    }

    for (
      var edgeIndex = 0;
      edgeIndex < rule.blindEdges.length;
      edgeIndex += 1
    ) {
      final edge = rule.blindEdges[edgeIndex];
      final before = context.cursorCodeUnit;
      final child = _executeRule(edge.target.label, edge.target.index, context);
      final childMatched = child.matched;
      context.trace?.traceDecision(
        'dart_runtime:child_dispatch',
        childMatched,
        'edge_family=blind mode=OR rule=${rule.label} index=$edgeIndex '
            'target=${edge.target.label}[${edge.target.index}] '
            'cursor_before=$before cursor_after=${context.cursorCodeUnit}',
        LinkedSpecTraceLevel.debug,
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
      if (childMatched) {
        return true;
      }
    }
    return false;
  }

  _RuleResult _executeRegexRule(
    CompiledRule rule,
    int entryRegexIndex,
    _RuntimeExecutionContext context, {
    required LinkedSpecParseMode cursorPolicy,
    required bool usesAndExecution,
  }) {
    final min = rule.modeMetadata.repMin;
    if (min == null) {
      var matchedAny = false;
      for (
        var iteration = 0;
        iteration < context.maxIterations;
        iteration += 1
      ) {
        final before = context.cursorCodeUnit;
        final matched = _nextableBool(
          () => _executeRegexOnce(
            rule,
            context,
            entryRegexIndex: entryRegexIndex,
            cursorPolicy: cursorPolicy,
            andSequence: usesAndExecution && rule.regexPatterns.length > 1,
          ),
        );
        if (matched.nexted) {
          matchedAny = true;
          if (context.cursorCodeUnit == before) {
            break;
          }
          continue;
        }
        if (!matched.value) {
          final loopExit = _executeLifecycle(rule, 'LX', context);
          if (loopExit != null) {
            return _returned(loopExit.value);
          }
        }
        final exitReturn = _executeLifecycle(rule, 'E', context);
        if (exitReturn != null) {
          return _returned(exitReturn.value);
        }
        return _RuleResult(matched: matched.value || matchedAny, value: null);
      }
      final loopExit = _executeLifecycle(rule, 'LX', context);
      if (loopExit != null) {
        return _returned(loopExit.value);
      }
      final exitReturn = _executeLifecycle(rule, 'E', context);
      if (exitReturn != null) {
        return _returned(exitReturn.value);
      }
      return _RuleResult(matched: matchedAny, value: null);
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

      final matched = _nextableBool(
        () => _executeRegexOnce(
          rule,
          context,
          cursorPolicy: cursorPolicy,
          andSequence: usesAndExecution && rule.regexPatterns.length > 1,
        ),
      );
      if (matched.nexted) {
        matches += 1;
        if (context.cursorCodeUnit == before) {
          break;
        }
        continue;
      }
      if (!matched.value) {
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
    required LinkedSpecParseMode cursorPolicy,
    bool andSequence = false,
  }) {
    final plan = _regexPlanFor(rule);
    final cursorBefore = context.cursorCodeUnit;
    if (plan.patterns.isEmpty) {
      _traceRegexDecision(
        context,
        rule,
        matched: false,
        cursorBefore: cursorBefore,
        cursorPolicy: cursorPolicy,
        reason: 'patterns=0',
      );
      return false;
    }

    if (andSequence) {
      for (
        var expectedIndex = 0;
        expectedIndex < plan.patterns.length;
        expectedIndex += 1
      ) {
        final match = _matchSpecific(
          plan,
          expectedIndex,
          context,
          cursorPolicy,
        );
        if (match == null) {
          _traceRegexDecision(
            context,
            rule,
            matched: false,
            cursorBefore: context.cursorCodeUnit,
            cursorPolicy: cursorPolicy,
            reason: 'mode=AND expected_index=$expectedIndex',
          );
          return false;
        }
        _traceRegexDecision(
          context,
          rule,
          matched: true,
          cursorBefore: context.cursorCodeUnit,
          cursorPolicy: cursorPolicy,
          match: match,
          reason: 'mode=AND expected_index=$expectedIndex',
        );
        _acceptRegexMatch(rule, match, context);
        final loopEnd = _executeLifecycle(rule, 'LE', context);
        if (loopEnd != null) {
          throw _ActionReturn(loopEnd.value);
        }
      }
      return true;
    }

    final match = entryRegexIndex > 0 && entryRegexIndex < plan.patterns.length
        ? _matchSpecific(plan, entryRegexIndex, context, cursorPolicy)
        : RuntimeRegexAlternation.compile(plan.patterns).match(
            context.input,
            context.cursorCodeUnit,
            parseMode: cursorPolicy,
          );
    if (match == null) {
      _traceRegexDecision(
        context,
        rule,
        matched: false,
        cursorBefore: cursorBefore,
        cursorPolicy: cursorPolicy,
        reason: 'entry_regex=$entryRegexIndex',
      );
      return false;
    }

    _traceRegexDecision(
      context,
      rule,
      matched: true,
      cursorBefore: cursorBefore,
      cursorPolicy: cursorPolicy,
      match: match,
      reason: 'entry_regex=$entryRegexIndex',
    );
    _acceptRegexMatch(rule, match, context);
    final loopEnd = _executeLifecycle(rule, 'LE', context);
    if (loopEnd != null) {
      throw _ActionReturn(loopEnd.value);
    }
    return true;
  }

  void _traceRegexDecision(
    _RuntimeExecutionContext context,
    CompiledRule rule, {
    required bool matched,
    required int cursorBefore,
    required LinkedSpecParseMode cursorPolicy,
    required String reason,
    RuntimeRegexMatch? match,
  }) {
    context.trace?.traceDecision(
      'dart_runtime:regex_match',
      matched,
      'rule=${rule.label} $reason parse_mode=${cursorPolicy.name} '
          'alternative=${match?.alternativeIndex ?? -1} '
          'match_start=${match?.codeUnitStart ?? -1} '
          'match_end=${match?.codeUnitEnd ?? -1} '
          'cursor_before=$cursorBefore',
      LinkedSpecTraceLevel.debug,
    );
  }

  RuntimeRegexMatch? _matchSpecific(
    _RegexPlan plan,
    int expectedIndex,
    _RuntimeExecutionContext context,
    LinkedSpecParseMode cursorPolicy,
  ) {
    final match = RuntimeRegexAlternation.compile([
      plan.patterns[expectedIndex],
    ]).match(context.input, context.cursorCodeUnit, parseMode: cursorPolicy);
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
    RuntimeRegexMatch match,
    _RuntimeExecutionContext context,
  ) {
    context.cursorCodeUnit = match.codeUnitEnd;
    context.registers = context.registers.withLocalMatch(match);

    final edgeMatches = _actionEdgesFor(rule, match.alternativeIndex);
    if (edgeMatches.isEmpty) {
      return;
    }

    for (final edgeMatch in edgeMatches) {
      final edgeContext = _CurrentActionEdge(
        ruleLabel: rule.label,
        edge: edgeMatch.edge,
        target: edgeMatch.target,
      );
      if (edgeMatch.edge.actionPayload == null) {
        final child = _executeActionEdgeChild(edgeContext, context);
        context.retv = child.value;
        continue;
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
      if (!edgeContext.childDispatched &&
          edgeMatch.target.label != rule.label) {
        final child = _executeActionEdgeChild(edgeContext, context);
        context.retv = child.value;
      }
    }
  }

  _RegexPlan _regexPlanFor(CompiledRule rule) {
    return _RegexPlan(patterns: rule.regexPatterns);
  }

  List<_MatchedActionEdge> _actionEdgesFor(
    CompiledRule rule,
    int alternativeIndex,
  ) {
    if (rule.actionEdges.isEmpty) {
      return const [];
    }
    return [
      for (final edge in rule.actionEdges)
        if (edge.regexIndex == alternativeIndex)
          _MatchedActionEdge(edge: edge, target: edge.targets.first),
    ];
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
      context.trace?.emitEvent(
        LinkedSpecTraceEventKind.mark,
        'dart_runtime:lifecycle_block',
        'rule=${rule.label} lifecycle=$lifecycle line=${payload.line} '
            'cursor=${context.cursorCodeUnit}',
        LinkedSpecTraceLevel.high,
      );
      if (lifecycle == 'I') {
        for (final statement in payload.actionAst.statements) {
          if (statement.expr case ActionAssignScalarExpr(:final name)) {
            context.recordRuleLocalBinding(name);
          }
          final expr = statement.expr;
          if (expr is ActionCallExpr &&
              expr.name == 'set' &&
              expr.args.isNotEmpty) {
            final name = _variableName(expr.args.first.value);
            if (name != null) {
              context.recordRuleLocalBinding(name);
            }
          }
        }
      }
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
      for (var index = 0; index < block.statements.length; index += 1) {
        final step = _executeActionStatementAt(
          block.statements,
          index,
          context,
          ruleLabel,
          currentEdge,
        );
        index = step.nextIndex;
      }
      return null;
    } on _ActionReturn catch (returnSignal) {
      return returnSignal;
    } on _ActionNext {
      rethrow;
    } on RuntimeExitNow {
      rethrow;
    } on _RuntimeDiagnosticOutputSinkFailure {
      rethrow;
    } on RuntimeInterpreterException {
      rethrow;
    } catch (error) {
      throw RuntimeInterpreterException(
        'action block failed in rule $ruleLabel: $error',
      );
    }
  }

  _StatementStep _executeActionStatementAt(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final statement = statements[index];
    final expr = statement.expr;
    if (expr is ActionControlIfExpr &&
        expr.branchRole == 'if' &&
        expr.body != null) {
      return _executeAttachedIfChainStatement(
        statements,
        index,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    if (expr is ActionControlIfExpr &&
        expr.branchRole == 'if' &&
        expr.body == null) {
      return _executeMarkerIfChainStatement(
        statements,
        index,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    if (expr is ActionControlWhileExpr && expr.body != null) {
      _executeAttachedWhileStatement(expr, context, ruleLabel, currentEdge);
      return _StatementStep(index);
    }
    if (_isMarkerSwitchStart(expr)) {
      return _executeMarkerSwitchChainStatement(
        statements,
        index,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    if (expr is ActionControlSwitchExpr &&
        (expr.cases.isNotEmpty || expr.defaultCase != null)) {
      _executeAttachedSwitchStatement(expr, context, ruleLabel, currentEdge);
      return _StatementStep(index);
    }
    if ((expr is ActionControlIfExpr && expr.branchRole == 'elseif') ||
        expr is ActionControlElseExpr ||
        expr is ActionControlCaseExpr ||
        expr is ActionControlDefaultExpr ||
        expr is ActionControlMarkerExpr) {
      return _StatementStep(index);
    }
    _evaluateExpression(
      statement.expr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
      statementContext: statement.dropsValue,
    );
    return _StatementStep(index);
  }

  _StatementStep _executeAttachedIfChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    var nextIndex = index;
    ActionBlock? selectedBody;
    for (var cursor = index; cursor < statements.length; cursor += 1) {
      final expr = statements[cursor].expr;
      if (cursor == index) {
        final first = expr as ActionControlIfExpr;
        if (runtimeLogicalTruth(
          _evaluateExpression(
            first.condition,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        )) {
          selectedBody = first.body;
        }
      } else if (expr is ActionControlIfExpr && expr.branchRole == 'elseif') {
        if (selectedBody == null &&
            runtimeLogicalTruth(
              _evaluateExpression(
                expr.condition,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            )) {
          selectedBody = expr.body;
        }
      } else if (expr is ActionControlElseExpr) {
        selectedBody ??= expr.body;
      } else {
        break;
      }
      nextIndex = cursor;
      if (expr is ActionControlElseExpr) {
        break;
      }
    }

    if (selectedBody != null) {
      final result = _executeActionBlock(
        selectedBody,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      if (result != null) {
        throw _ActionReturn(result.value);
      }
    }
    return _StatementStep(nextIndex);
  }

  _StatementStep _executeMarkerIfChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final selection = _selectMarkerIfChain(
      statements,
      index,
      context,
      ruleLabel,
      currentEdge,
    );
    if (selection.start != null && selection.end != null) {
      _executeActionStatementRange(
        statements,
        selection.start!,
        selection.end!,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    return _StatementStep(selection.nextIndex);
  }

  void _executeActionStatementRange(
    List<ActionStatement> statements,
    int start,
    int end,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    for (var cursor = start; cursor < end; cursor += 1) {
      final step = _executeActionStatementAt(
        statements,
        cursor,
        context,
        ruleLabel,
        currentEdge,
      );
      cursor = step.nextIndex;
    }
  }

  _StatementStep _executeMarkerSwitchChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final selection = _selectMarkerSwitchChain(
      statements,
      index,
      context,
      ruleLabel,
      currentEdge,
    );
    if (selection.start != null && selection.end != null) {
      _executeActionStatementRange(
        statements,
        selection.start!,
        selection.end!,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    return _StatementStep(selection.nextIndex);
  }

  void _executeAttachedWhileStatement(
    ActionControlWhileExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final body = expr.body;
    if (body == null) {
      return;
    }
    for (var iteration = 0; iteration < context.maxIterations; iteration += 1) {
      if (!runtimeLogicalTruth(
        _evaluateExpression(
          expr.condition,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      )) {
        return;
      }
      final result = _executeActionBlock(
        body,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      if (result != null) {
        throw _ActionReturn(result.value);
      }
    }
    throw RuntimeInterpreterException(_whileIterationLimitMessage(context));
  }

  void _executeAttachedSwitchStatement(
    ActionControlSwitchExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final body = _selectSwitchBody(expr, context, ruleLabel, currentEdge);
    if (body == null) {
      return;
    }
    final result = _executeActionBlock(
      body,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
    if (result != null) {
      throw _ActionReturn(result.value);
    }
  }

  Object? _evaluateBlockValue(
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    final flow = _executeValueBlockStatements(
      block,
      context,
      ruleLabel,
      currentEdge,
      finalExpressionYields: true,
    );
    return flow.returned ? flow.value : null;
  }

  _ValueBlockFlow _executeValueBlockStatements(
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge, {
    required bool finalExpressionYields,
  }) {
    final statements = block.statements;
    for (var index = 0; index < statements.length; index += 1) {
      final statement = statements[index];
      final expr = statement.expr;
      final isLast = index == statements.length - 1;

      if (expr is ActionControlIfExpr &&
          expr.branchRole == 'if' &&
          expr.body != null) {
        final step = _executeValueIfChainStatement(
          statements,
          index,
          context,
          ruleLabel,
          currentEdge,
        );
        if (step.flow.returned) {
          return step.flow;
        }
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        index = step.nextIndex;
        continue;
      }

      if (expr is ActionControlIfExpr &&
          expr.branchRole == 'if' &&
          expr.body == null) {
        final step = _executeValueMarkerIfChainStatement(
          statements,
          index,
          context,
          ruleLabel,
          currentEdge,
        );
        if (step.flow.returned) {
          return step.flow;
        }
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        index = step.nextIndex;
        continue;
      }

      if (expr is ActionControlWhileExpr && expr.body != null) {
        final flow = _executeValueWhileStatement(
          expr,
          context,
          ruleLabel,
          currentEdge,
        );
        if (flow.returned) {
          return flow;
        }
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        continue;
      }

      if (_isMarkerSwitchStart(expr)) {
        final step = _executeValueMarkerSwitchChainStatement(
          statements,
          index,
          context,
          ruleLabel,
          currentEdge,
        );
        if (step.flow.returned) {
          return step.flow;
        }
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        index = step.nextIndex;
        continue;
      }

      if (expr is ActionControlSwitchExpr &&
          (expr.cases.isNotEmpty || expr.defaultCase != null)) {
        final flow = _executeValueSwitchStatement(
          expr,
          context,
          ruleLabel,
          currentEdge,
        );
        if (flow.returned) {
          return flow;
        }
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        continue;
      }

      if ((expr is ActionControlIfExpr && expr.branchRole == 'elseif') ||
          expr is ActionControlElseExpr ||
          expr is ActionControlCaseExpr ||
          expr is ActionControlDefaultExpr ||
          expr is ActionControlMarkerExpr) {
        if (isLast && finalExpressionYields) {
          return const _ValueBlockFlow.returned(null);
        }
        continue;
      }

      final returnPayload = _localReturnPayload(expr);
      if (returnPayload != null) {
        return _ValueBlockFlow.returned(
          returnPayload.hasValue
              ? _copyValue(
                  _evaluateExpression(
                    returnPayload.value!,
                    context,
                    ruleLabel,
                    currentEdge: currentEdge,
                  ),
                )
              : null,
        );
      }

      if (isLast && finalExpressionYields) {
        return _ValueBlockFlow.returned(
          _evaluateExpression(
            expr,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
      }

      _evaluateExpression(
        expr,
        context,
        ruleLabel,
        currentEdge: currentEdge,
        statementContext: true,
      );
    }
    return const _ValueBlockFlow.continued();
  }

  _ValueStatementStep _executeValueIfChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    var nextIndex = index;
    ActionBlock? selectedBody;
    for (var cursor = index; cursor < statements.length; cursor += 1) {
      final expr = statements[cursor].expr;
      if (cursor == index) {
        final first = expr as ActionControlIfExpr;
        if (runtimeLogicalTruth(
          _evaluateExpression(
            first.condition,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        )) {
          selectedBody = first.body;
        }
      } else if (expr is ActionControlIfExpr && expr.branchRole == 'elseif') {
        if (selectedBody == null &&
            runtimeLogicalTruth(
              _evaluateExpression(
                expr.condition,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            )) {
          selectedBody = expr.body;
        }
      } else if (expr is ActionControlElseExpr) {
        selectedBody ??= expr.body;
      } else {
        break;
      }
      nextIndex = cursor;
      if (expr is ActionControlElseExpr) {
        break;
      }
    }

    if (selectedBody == null) {
      return _ValueStatementStep(nextIndex, const _ValueBlockFlow.continued());
    }
    return _ValueStatementStep(
      nextIndex,
      _executeValueBlockStatements(
        selectedBody,
        context,
        ruleLabel,
        currentEdge,
        finalExpressionYields: false,
      ),
    );
  }

  _ValueStatementStep _executeValueMarkerIfChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final selection = _selectMarkerIfChain(
      statements,
      index,
      context,
      ruleLabel,
      currentEdge,
    );
    if (selection.start == null || selection.end == null) {
      return _ValueStatementStep(
        selection.nextIndex,
        const _ValueBlockFlow.continued(),
      );
    }
    return _ValueStatementStep(
      selection.nextIndex,
      _executeValueStatementRange(
        statements,
        selection.start!,
        selection.end!,
        context,
        ruleLabel,
        currentEdge,
      ),
    );
  }

  _ValueStatementStep _executeValueMarkerSwitchChainStatement(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final selection = _selectMarkerSwitchChain(
      statements,
      index,
      context,
      ruleLabel,
      currentEdge,
    );
    if (selection.start == null || selection.end == null) {
      return _ValueStatementStep(
        selection.nextIndex,
        const _ValueBlockFlow.continued(),
      );
    }
    return _ValueStatementStep(
      selection.nextIndex,
      _executeValueStatementRange(
        statements,
        selection.start!,
        selection.end!,
        context,
        ruleLabel,
        currentEdge,
      ),
    );
  }

  _ValueBlockFlow _executeValueStatementRange(
    List<ActionStatement> statements,
    int start,
    int end,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    for (var cursor = start; cursor < end; cursor += 1) {
      final statement = statements[cursor];
      final expr = statement.expr;

      if (expr is ActionControlIfExpr &&
          expr.branchRole == 'if' &&
          expr.body == null) {
        final step = _executeValueMarkerIfChainStatement(
          statements,
          cursor,
          context,
          ruleLabel,
          currentEdge,
        );
        if (step.flow.returned) {
          return step.flow;
        }
        cursor = step.nextIndex;
        continue;
      }

      if (_isMarkerSwitchStart(expr)) {
        final step = _executeValueMarkerSwitchChainStatement(
          statements,
          cursor,
          context,
          ruleLabel,
          currentEdge,
        );
        if (step.flow.returned) {
          return step.flow;
        }
        cursor = step.nextIndex;
        continue;
      }

      final returnPayload = _localReturnPayload(expr);
      if (returnPayload != null) {
        return _ValueBlockFlow.returned(
          returnPayload.hasValue
              ? _copyValue(
                  _evaluateExpression(
                    returnPayload.value!,
                    context,
                    ruleLabel,
                    currentEdge: currentEdge,
                  ),
                )
              : null,
        );
      }

      _evaluateExpression(
        expr,
        context,
        ruleLabel,
        currentEdge: currentEdge,
        statementContext: true,
      );
    }
    return const _ValueBlockFlow.continued();
  }

  _MarkerIfSelection _selectMarkerIfChain(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final first = statements[index].expr as ActionControlIfExpr;
    int? selectedStart;
    int? selectedEnd;
    var selected = false;
    var depth = 0;
    var nextIndex = statements.length - 1;

    if (runtimeLogicalTruth(
      _evaluateExpression(
        first.condition,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
    )) {
      selectedStart = index + 1;
      selected = true;
    }

    for (var cursor = index + 1; cursor < statements.length; cursor += 1) {
      final expr = statements[cursor].expr;
      if (_isMarkerIfStart(expr)) {
        depth += 1;
        continue;
      }
      if (_isMarkerIfEnd(expr)) {
        if (depth > 0) {
          depth -= 1;
          continue;
        }
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        nextIndex = cursor;
        break;
      }
      if (depth != 0) {
        continue;
      }
      if (expr is ActionControlIfExpr &&
          expr.branchRole == 'elseif' &&
          expr.body == null) {
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        if (!selected &&
            runtimeLogicalTruth(
              _evaluateExpression(
                expr.condition,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            )) {
          selectedStart = cursor + 1;
          selected = true;
        }
        continue;
      }
      if (expr is ActionControlElseExpr && expr.body == null) {
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        if (!selected) {
          selectedStart = cursor + 1;
          selected = true;
        }
      }
    }

    if (selected && selectedEnd == null) {
      selectedEnd = statements.length;
    }
    return _MarkerIfSelection(
      start: selectedStart,
      end: selectedEnd,
      nextIndex: nextIndex,
    );
  }

  bool _isMarkerIfStart(ActionExpr expr) {
    return expr is ActionControlIfExpr &&
        expr.branchRole == 'if' &&
        expr.body == null;
  }

  bool _isMarkerIfEnd(ActionExpr expr) {
    return expr is ActionControlMarkerExpr && expr.canonicalKeyword == 'endif';
  }

  _MarkerSwitchSelection _selectMarkerSwitchChain(
    List<ActionStatement> statements,
    int index,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final first = statements[index].expr as ActionControlSwitchExpr;
    final selector = _evaluateExpression(
      first.sourceExpr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
    int? selectedStart;
    int? selectedEnd;
    var selected = false;
    var branchMatched = false;
    var depth = 0;
    var nextIndex = statements.length - 1;

    for (var cursor = index + 1; cursor < statements.length; cursor += 1) {
      final expr = statements[cursor].expr;
      if (_isMarkerSwitchStart(expr)) {
        depth += 1;
        continue;
      }
      if (_isMarkerSwitchEnd(expr)) {
        if (depth > 0) {
          depth -= 1;
          continue;
        }
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        nextIndex = cursor;
        break;
      }
      if (depth != 0) {
        continue;
      }
      if (expr is ActionControlCaseExpr && expr.body == null) {
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        selected = false;
        if (!branchMatched) {
          final candidate = _evaluateSwitchCaseMatch(
            expr.match,
            context,
            ruleLabel,
            currentEdge,
          );
          if (_stringValue(candidate) == _stringValue(selector)) {
            selectedStart = cursor + 1;
            selected = true;
            branchMatched = true;
          }
        }
        continue;
      }
      if (expr is ActionControlDefaultExpr && expr.body == null) {
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        selected = false;
        if (!branchMatched) {
          selectedStart = cursor + 1;
          selected = true;
          branchMatched = true;
        }
        continue;
      }
      if (_isMarkerCaseEnd(expr)) {
        if (selected && selectedEnd == null) {
          selectedEnd = cursor;
        }
        selected = false;
      }
    }

    if (selected && selectedEnd == null) {
      selectedEnd = statements.length;
    }
    return _MarkerSwitchSelection(
      start: selectedStart,
      end: selectedEnd,
      nextIndex: nextIndex,
    );
  }

  bool _isMarkerSwitchStart(ActionExpr expr) {
    return expr is ActionControlSwitchExpr &&
        expr.body == null &&
        expr.cases.isEmpty &&
        expr.defaultCase == null;
  }

  bool _isMarkerSwitchEnd(ActionExpr expr) {
    return expr is ActionControlMarkerExpr &&
        expr.canonicalKeyword == 'endswitch';
  }

  bool _isMarkerCaseEnd(ActionExpr expr) {
    return expr is ActionControlMarkerExpr &&
        expr.canonicalKeyword == 'endcase';
  }

  _ValueBlockFlow _executeValueWhileStatement(
    ActionControlWhileExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final body = expr.body;
    if (body == null) {
      return const _ValueBlockFlow.continued();
    }
    for (var iteration = 0; iteration < context.maxIterations; iteration += 1) {
      if (!runtimeLogicalTruth(
        _evaluateExpression(
          expr.condition,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      )) {
        return const _ValueBlockFlow.continued();
      }
      final flow = _executeValueBlockStatements(
        body,
        context,
        ruleLabel,
        currentEdge,
        finalExpressionYields: false,
      );
      if (flow.returned) {
        return flow;
      }
    }
    throw RuntimeInterpreterException(_whileIterationLimitMessage(context));
  }

  _ValueBlockFlow _executeValueSwitchStatement(
    ActionControlSwitchExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final body = _selectSwitchBody(expr, context, ruleLabel, currentEdge);
    if (body == null) {
      return const _ValueBlockFlow.continued();
    }
    return _executeValueBlockStatements(
      body,
      context,
      ruleLabel,
      currentEdge,
      finalExpressionYields: false,
    );
  }

  ActionBlock? _selectSwitchBody(
    ActionControlSwitchExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final selector = _evaluateExpression(
      expr.sourceExpr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
    for (final item in expr.cases) {
      final candidate = _evaluateSwitchCaseMatch(
        item.match,
        context,
        ruleLabel,
        currentEdge,
      );
      if (_stringValue(candidate) == _stringValue(selector)) {
        return item.body;
      }
    }
    return expr.defaultCase?.body;
  }

  Object? _evaluateSwitchCaseMatch(
    ActionExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (expr is ActionVariableExpr) {
      return expr.name;
    }
    return _evaluateExpression(
      expr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  _LocalReturnPayload? _localReturnPayload(ActionExpr expr) {
    if (expr is! ActionCallExpr) {
      return null;
    }
    final helperName = canonicalActionHelperName(expr.name);
    if (helperName == 'return_undef' && expr.args.isEmpty) {
      return const _LocalReturnPayload.undef();
    }
    if (helperName != 'return') {
      return null;
    }
    final positionalArgs = expr.args.map((arg) => arg.value).toList();
    return positionalArgs.isEmpty
        ? const _LocalReturnPayload.undef()
        : _LocalReturnPayload.value(positionalArgs.first);
  }

  String _whileIterationLimitMessage(_RuntimeExecutionContext context) {
    return 'LinkedSpec while iteration safety limit exceeded after '
        '${context.maxIterations} iterations';
  }

  Object? _evaluateStructuredControlExpression(
    ActionExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
  }) {
    switch (expr) {
      case ActionControlIfExpr(:final body):
        if (body == null) {
          return null;
        }
        final statements = [
          ActionStatement(
            source: expr.source,
            sourceSpan: expr.sourceSpan,
            expr: expr,
          ),
        ];
        _executeAttachedIfChainStatement(
          statements,
          0,
          context,
          ruleLabel,
          currentEdge,
        );
        return null;
      case ActionControlWhileExpr():
        _executeAttachedWhileStatement(expr, context, ruleLabel, currentEdge);
        return null;
      case ActionControlSwitchExpr():
        _executeAttachedSwitchStatement(expr, context, ruleLabel, currentEdge);
        return null;
      default:
        return null;
    }
  }

  Object? _callInlineIf(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      return null;
    }
    if (runtimeLogicalTruth(
      _evaluateExpression(
        args[0],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
    )) {
      return args.length >= 2
          ? _evaluateExpression(
              args[1],
              context,
              ruleLabel,
              currentEdge: currentEdge,
            )
          : true;
    }
    for (var index = 2; index < args.length; index += 1) {
      final arg = args[index];
      if (arg is! ActionCallExpr) {
        return _evaluateExpression(
          arg,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
      }
      final branchName = canonicalActionHelperName(arg.name);
      final branchArgs = arg.args.map((item) => item.value).toList();
      if (branchName == 'elseif') {
        if (branchArgs.length >= 2 &&
            runtimeLogicalTruth(
              _evaluateExpression(
                branchArgs[0],
                context,
                ruleLabel,
                currentEdge: currentEdge,
              ),
            )) {
          return _evaluateExpression(
            branchArgs[1],
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
        }
      } else if (branchName == 'else') {
        return branchArgs.isEmpty
            ? null
            : _evaluateExpression(
                branchArgs[0],
                context,
                ruleLabel,
                currentEdge: currentEdge,
              );
      } else {
        return _evaluateExpression(
          arg,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
      }
    }
    return null;
  }

  Object? _callInlineSwitch(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      return null;
    }
    final selector = _evaluateExpression(
      args.first,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
    ActionExpr? defaultExpr;
    for (final branch in args.skip(1)) {
      if (branch is! ActionCallExpr) {
        continue;
      }
      final branchName = canonicalActionHelperName(branch.name);
      final branchArgs = branch.args.map((arg) => arg.value).toList();
      if (branchName == 'case' && branchArgs.length >= 2) {
        final candidate = _evaluateSwitchCaseMatch(
          branchArgs[0],
          context,
          ruleLabel,
          currentEdge,
        );
        if (_stringValue(candidate) == _stringValue(selector)) {
          return _evaluateExpression(
            branchArgs[1],
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
        }
      } else if (branchName == 'default' && branchArgs.isNotEmpty) {
        defaultExpr ??= branchArgs.first;
      }
    }
    return defaultExpr == null
        ? null
        : _evaluateExpression(
            defaultExpr,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
  }

  Object? _callWithTrailingBlock(
    ActionCallExpr call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (!call.trailingBlockArg || call.args.isEmpty || call.args.length > 2) {
      throw RuntimeInterpreterException(
        "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper "
        "`with(...) { ... }` expects zero or one value argument plus a "
        "trailing block in rule '$ruleLabel'",
      );
    }
    final blockExpr = call.args.last.value;
    if (blockExpr is! ActionBlockValueExpr) {
      throw RuntimeInterpreterException(
        "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper `with(...)` "
        "requires a trailing block argument in rule '$ruleLabel'",
      );
    }
    final scopedValue = call.args.length == 2
        ? _evaluateExpression(
            call.args.first.value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          )
        : null;
    final binding = context.enterScopedScalar('value', scopedValue);
    try {
      return _evaluateBlockValue(
        blockExpr.block,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
    } finally {
      context.exitScopedVariable(binding);
    }
  }

  Object? _callReceiverWithTrailingBlock(
    Object? receiver,
    ActionFluentCall call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (!call.receiverTrailingBlockArg || call.args.length != 1) {
      throw RuntimeInterpreterException(
        "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver "
        "`.with() { ... }` expects no parenthesized arguments in rule "
        "'$ruleLabel'",
      );
    }
    final blockExpr = call.args.single.value;
    if (blockExpr is! ActionBlockValueExpr) {
      throw RuntimeInterpreterException(
        "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver `.with()` "
        "requires a trailing block argument in rule '$ruleLabel'",
      );
    }
    final binding = context.enterScopedScalar('value', _copyValue(receiver));
    try {
      return _evaluateBlockValue(
        blockExpr.block,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
    } finally {
      context.exitScopedVariable(binding);
    }
  }

  Object? _callTreeTraversalTrailingBlock(
    Object? receiver,
    ActionFluentCall call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final method = canonicalActionHelperName(call.method);
    if (!_treeTraversalHelperNames.contains(method)) {
      return null;
    }
    if (call.args.isEmpty || call.args.last.value is! ActionBlockValueExpr) {
      throw RuntimeInterpreterException(
        _treeTraversalMalformedMessage(method, ruleLabel),
      );
    }
    if ((method == 'walk_leaves' || method == 'map_leaves') &&
        call.args.length != 1) {
      throw RuntimeInterpreterException(
        _treeTraversalMalformedMessage(method, ruleLabel),
      );
    }
    if (method == 'reduce_leaves' && call.args.length != 2) {
      throw RuntimeInterpreterException(
        _treeTraversalMalformedMessage(method, ruleLabel),
      );
    }
    final block = (call.args.last.value as ActionBlockValueExpr).block;
    if (receiver is Map) {
      final hash = _asHash(receiver);
      return switch (method) {
        'walk_leaves' => _walkHashTree(
          hash,
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        'map_leaves' => _mapHashTree(
          hash,
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        'reduce_leaves' => _reduceHashTree(
          hash,
          _evaluateExpression(
            call.args.first.value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        _ => null,
      };
    }
    if (receiver is List) {
      final items = _asArray(receiver);
      return switch (method) {
        'walk_leaves' => _walkArrayTree(
          items,
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        'map_leaves' => _mapArrayTree(
          items,
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        'reduce_leaves' => _reduceArrayTree(
          items,
          _evaluateExpression(
            call.args.first.value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
          block,
          context,
          ruleLabel,
          currentEdge,
        ),
        _ => null,
      };
    }
    return null;
  }

  String _treeTraversalMalformedMessage(String method, String ruleLabel) {
    final signature = switch (method) {
      'reduce_leaves' => '.reduce_leaves(initial) { ... }',
      'walk_leaves' => '.walk_leaves() { ... }',
      'map_leaves' => '.map_leaves() { ... }',
      _ => '.<tree-traversal-method>() { ... }',
    };
    return 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:$method: receiver '
        '`$signature` requires the accepted tree traversal trailing-block '
        "arity in rule '$ruleLabel'";
  }

  Object? _walkHashTree(
    Map<String, Object?> hash,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    void walk(Map<String, Object?> node, List<String> path) {
      final keys = node.keys.toList()..sort();
      for (final key in keys) {
        final value = node[key];
        final nextPath = [...path, key];
        if (value is Map) {
          walk(_asHash(value), nextPath);
        } else {
          _evaluateHashLeafBlock(
            block,
            value,
            key,
            nextPath,
            null,
            false,
            context,
            ruleLabel,
            currentEdge,
          );
        }
      }
    }

    walk(hash, const []);
    return _copyValue(hash);
  }

  Object? _mapHashTree(
    Map<String, Object?> hash,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    Map<String, Object?> mapNode(Map<String, Object?> node, List<String> path) {
      final result = <String, Object?>{};
      final keys = node.keys.toList()..sort();
      for (final key in keys) {
        final value = node[key];
        final nextPath = [...path, key];
        result[key] = value is Map
            ? mapNode(_asHash(value), nextPath)
            : _evaluateHashLeafBlock(
                block,
                value,
                key,
                nextPath,
                null,
                false,
                context,
                ruleLabel,
                currentEdge,
              );
      }
      return result;
    }

    return mapNode(hash, const []);
  }

  Object? _reduceHashTree(
    Map<String, Object?> hash,
    Object? initial,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    var acc = _copyValue(initial);
    void reduceNode(Map<String, Object?> node, List<String> path) {
      final keys = node.keys.toList()..sort();
      for (final key in keys) {
        final value = node[key];
        final nextPath = [...path, key];
        if (value is Map) {
          reduceNode(_asHash(value), nextPath);
        } else {
          acc = _evaluateHashLeafBlock(
            block,
            value,
            key,
            nextPath,
            acc,
            true,
            context,
            ruleLabel,
            currentEdge,
          );
        }
      }
    }

    reduceNode(hash, const []);
    return acc;
  }

  Object? _evaluateHashLeafBlock(
    ActionBlock block,
    Object? value,
    String key,
    List<String> path,
    Object? acc,
    bool bindAcc,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final bindings = <_ScopedVariableBinding>[
      if (bindAcc) context.enterScopedScalar('acc', _copyValue(acc)),
      context.enterScopedScalar('value', _copyValue(value)),
      context.enterScopedScalar('key', key),
      context.enterScopedScalar('path', [for (final item in path) item]),
      context.enterScopedScalar('depth', path.length),
    ];
    try {
      return _evaluateBlockValue(
        block,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
    } finally {
      for (final binding in bindings.reversed) {
        context.exitScopedVariable(binding);
      }
    }
  }

  Object? _walkArrayTree(
    List<Object?> items,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    void walk(List<Object?> node, List<int> path) {
      for (final (index, value) in node.indexed) {
        final nextPath = [...path, index];
        if (value is List) {
          walk(_asArray(value), nextPath);
        } else {
          _evaluateArrayLeafBlock(
            block,
            value,
            index,
            nextPath,
            null,
            false,
            context,
            ruleLabel,
            currentEdge,
          );
        }
      }
    }

    walk(items, const []);
    return _copyValue(items);
  }

  Object? _mapArrayTree(
    List<Object?> items,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    List<Object?> mapNode(List<Object?> node, List<int> path) {
      final result = <Object?>[];
      for (final (index, value) in node.indexed) {
        final nextPath = [...path, index];
        result.add(
          value is List
              ? mapNode(_asArray(value), nextPath)
              : _evaluateArrayLeafBlock(
                  block,
                  value,
                  index,
                  nextPath,
                  null,
                  false,
                  context,
                  ruleLabel,
                  currentEdge,
                ),
        );
      }
      return result;
    }

    return mapNode(items, const []);
  }

  Object? _reduceArrayTree(
    List<Object?> items,
    Object? initial,
    ActionBlock block,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    var acc = _copyValue(initial);
    void reduceNode(List<Object?> node, List<int> path) {
      for (final (index, value) in node.indexed) {
        final nextPath = [...path, index];
        if (value is List) {
          reduceNode(_asArray(value), nextPath);
        } else {
          acc = _evaluateArrayLeafBlock(
            block,
            value,
            index,
            nextPath,
            acc,
            true,
            context,
            ruleLabel,
            currentEdge,
          );
        }
      }
    }

    reduceNode(items, const []);
    return acc;
  }

  Object? _evaluateArrayLeafBlock(
    ActionBlock block,
    Object? value,
    int index,
    List<int> path,
    Object? acc,
    bool bindAcc,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final bindings = <_ScopedVariableBinding>[
      if (bindAcc) context.enterScopedScalar('acc', _copyValue(acc)),
      context.enterScopedScalar('value', _copyValue(value)),
      context.enterScopedScalar('index', index),
      context.enterScopedScalar('path', [for (final item in path) item]),
      context.enterScopedScalar('depth', path.length),
    ];
    try {
      return _evaluateBlockValue(
        block,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
    } finally {
      for (final binding in bindings.reversed) {
        context.exitScopedVariable(binding);
      }
    }
  }

  Object? _evaluateExpression(
    ActionExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel, {
    required _CurrentActionEdge? currentEdge,
    bool statementContext = false,
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
        return _bindingValueFor(context, name);
      case ActionArrayLiteralExpr(:final items):
        final values = <Object?>[];
        for (final item in items) {
          final value = _evaluateExpression(
            item,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
          if (_isArraySpliceArgument(item)) {
            _appendArraySpliceValue(values, value);
          } else {
            values.add(_copyValue(value));
          }
        }
        return values;
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
        context.arrays.remove(name);
        context.hashes.remove(name);
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
        return _appendArrayValue(context, name, stored);
      case ActionAssignHashIndexExpr(:final name, :final key, :final value):
        return _assignHashIndex(
          context,
          name,
          key,
          value,
          ruleLabel,
          currentEdge,
        );
      case ActionAssignNestedAccessExpr(
        :final base,
        :final segments,
        :final value,
      ):
        return _writeNested(
          context,
          base,
          segments,
          value,
          ruleLabel,
          currentEdge,
        );
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
      case ActionControlIfExpr():
      case ActionControlWhileExpr():
      case ActionControlSwitchExpr():
        return _evaluateStructuredControlExpression(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
      case ActionControlElseExpr():
      case ActionControlCaseExpr():
      case ActionControlDefaultExpr():
      case ActionControlMarkerExpr():
        return null;
      case ActionCallExpr():
        return _evaluateCall(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
          statementContext: statementContext,
        );
      case ActionFluentChainExpr(:final receiver, :final calls):
        if (statementContext &&
            _executeArrayEndMutationStatement(
              expr,
              context,
              ruleLabel,
              currentEdge,
            )) {
          return null;
        }
        if (calls.isEmpty) {
          return _evaluateExpression(
            receiver,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          );
        }
        if (const {
          'push_back',
          'push_front',
          'pop_back',
          'pop_front',
        }.contains(calls.first.method)) {
          Object? value = _evaluateArrayEndMutationCall(
            receiver,
            calls.first,
            context,
            ruleLabel,
            currentEdge,
          );
          if (value == null) {
            return null;
          }
          for (final call in calls.skip(1)) {
            value = _evaluateFluentCall(
              value,
              call,
              context,
              ruleLabel,
              currentEdge: currentEdge,
            );
          }
          return value;
        }
        var value = _evaluateFluentReceiver(
          receiver,
          canonicalActionHelperName(calls.first.method),
          context,
          ruleLabel,
          currentEdge,
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
        return _evaluateBlockValue(
          block,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        );
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
    bool statementContext = false,
  }) {
    final positionalArgs = call.args.map((arg) => arg.value).toList();
    final helperName = canonicalActionHelperName(call.name);
    _validateDiagnosticOutputArity(call, helperName, context, ruleLabel);
    if (helperName == 'with' && call.trailingBlockArg) {
      return _callWithTrailingBlock(call, context, ruleLabel, currentEdge);
    }
    if (statementContext &&
        helperName == 'set_key' &&
        _executeSetKeyStatement(call, context, ruleLabel, currentEdge)) {
      return null;
    }
    if (statementContext &&
        (helperName == 'substr' || helperName == 'regex_subst') &&
        _executeRegexSubstitutionStatement(
          call,
          context,
          ruleLabel,
          currentEdge,
        )) {
      return null;
    }
    if (statementContext &&
        _executeArrayStringTransformStatement(
          helperName,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        )) {
      return null;
    }
    if (compiledSpec.functionRegistry.hasName(call.name) &&
        call.args.any((arg) => arg is ActionKeywordArgument)) {
      throw RuntimeInterpreterException(
        "user function '${call.name}' accepts positional arguments only in "
        'rule $ruleLabel',
      );
    }
    final functionResolution = compiledSpec.functionRegistry.resolveCall(
      call.name,
      positionalArgs.length,
    );
    if (functionResolution.matched) {
      return _executeUserFunction(
        functionResolution.entry!,
        positionalArgs,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    if (functionResolution.arityMismatch) {
      throw RuntimeInterpreterException(
        "user function '${call.name}' expects "
        '${functionResolution.expectedArityDescriptions.join(" or ")} '
        'argument(s), '
        'got ${positionalArgs.length} in rule $ruleLabel',
      );
    }
    _validateLogicalHelperArity(call, helperName, context, ruleLabel);
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
      case 'next':
        if (statementContext) {
          throw const _ActionNext();
        }
        return null;
      case 'if':
        return _callInlineIf(positionalArgs, context, ruleLabel, currentEdge);
      case 'switch':
        return _callInlineSwitch(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'else':
      case 'elseif':
      case 'case':
      case 'default':
        return positionalArgs.isEmpty
            ? null
            : _evaluateExpression(
                positionalArgs.last,
                context,
                ruleLabel,
                currentEdge: currentEdge,
              );
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
      case 'split':
        return _callSplitFromExpressions(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
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
      case 'entry_line':
      case 'entry_start_line':
        return _matchStartLine(context.input, context.registers.entryMatch);
      case 'entry_col':
      case 'entry_start_col':
        return _matchStartColumn(context.input, context.registers.entryMatch);
      case 'entry_end_line':
        return _matchEndLine(context.input, context.registers.entryMatch);
      case 'entry_end_col':
        return _matchEndColumn(context.input, context.registers.entryMatch);
      case 'match_line':
      case 'match_start_line':
        return _matchStartLine(context.input, context.registers.localMatch);
      case 'match_col':
      case 'match_start_col':
        return _matchStartColumn(context.input, context.registers.localMatch);
      case 'match_end_line':
        return _matchEndLine(context.input, context.registers.localMatch);
      case 'match_end_col':
        return _matchEndColumn(context.input, context.registers.localMatch);
      case 'entry_start_pos':
        return context.registers.entryMatch?.charStart;
      case 'entry_end_pos':
        return context.registers.entryMatch?.charEnd;
      case 'match_start_pos':
        return context.registers.localMatch?.charStart;
      case 'match_end_pos':
        return context.registers.localMatch?.charEnd;
      case 'cursor_pos':
        return context.cursorCharOffset;
      case 'cursor_line':
        return context.cursorLineColumn.line;
      case 'cursor_col':
        return context.cursorLineColumn.column;
      case 'cursor_rest':
        return context.input.substring(context.cursorCodeUnit);
      case 'cursor_rest_len':
        return context.input.substring(context.cursorCodeUnit).runes.length;
      case 'input_text':
        return context.input;
      case 'input_len':
        return context.input.runes.length;
      case 'input_slice':
        return _callInputSlice(positionalArgs, context, ruleLabel, currentEdge);
      case 'input_end_pos':
        return context.input.runes.length;
      case 'input_end_line':
        return lineColumnAtCodeUnitOffset(
          context.input,
          context.input.length,
        ).line;
      case 'input_end_col':
        return lineColumnAtCodeUnitOffset(
          context.input,
          context.input.length,
        ).column;
      case 'start_capture_slice':
        context.startCaptureSlice();
        return null;
      case 'capture_slice':
        return _captureSliceText(context, untilCursor: false);
      case 'capture_slice_len':
        return _captureSliceLength(context, untilCursor: false);
      case 'capture_slice_until_cursor':
        return _captureSliceText(context, untilCursor: true);
      case 'capture_slice_until_cursor_len':
        return _captureSliceLength(context, untilCursor: true);
      case 'capture_slice_pos':
        return codeUnitOffsetToCharOffset(
          context.input,
          _captureStartCodeUnit(context),
        );
      case 'capture_slice_line':
        return lineColumnAtCodeUnitOffset(
          context.input,
          _captureStartCodeUnit(context),
        ).line;
      case 'capture_slice_col':
        return lineColumnAtCodeUnitOffset(
          context.input,
          _captureStartCodeUnit(context),
        ).column;
      case 'start_capture_slice_from':
      case 'capture_rest':
      case 'capture_rest_len':
      case 'capture_take':
      case 'capture_take_len':
      case 'capture_take_until_cursor':
      case 'capture_take_until_cursor_len':
      case 'capture_take_rest':
      case 'capture_take_rest_len':
      case 'mark_here':
      case 'mark_input_start':
      case 'mark_input_end':
      case 'mark_entry_start':
      case 'mark_entry_end':
      case 'mark_match_start':
      case 'mark_match_end':
      case 'mark_copy':
      case 'mark_capture_slice':
      case 'mark_exists':
      case 'mark_pos':
      case 'mark_line':
      case 'mark_col':
      case 'clear_mark':
      case 'capture_from':
      case 'capture_len_from':
      case 'capture_until_cursor_from':
      case 'capture_until_cursor_len_from':
      case 'capture_rest_from':
      case 'capture_rest_len_from':
      case 'capture_take_len_from':
      case 'capture_take_until_cursor_from':
      case 'capture_take_until_cursor_len_from':
      case 'capture_take_rest_from':
      case 'capture_take_rest_len_from':
      case 'capture_between':
      case 'capture_len_between':
      case 'capture_take_between':
      case 'capture_take_between_len':
        return _callCaptureMarkHelper(
          helperName,
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'capture_until_boundary':
        return _callCaptureUntilBoundary(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'save_cursor':
        final before = context.cursorCodeUnit;
        final stackBefore = context.cursorStack.length;
        context.saveCursor();
        _traceCursorControl(
          context,
          ruleLabel,
          'save_cursor',
          before: before,
          stackBefore: stackBefore,
        );
        return null;
      case 'restore_cursor':
        final before = context.cursorCodeUnit;
        final stackBefore = context.cursorStack.length;
        context.restoreCursor();
        _traceCursorControl(
          context,
          ruleLabel,
          'restore_cursor',
          before: before,
          stackBefore: stackBefore,
        );
        return null;
      case 'rewind_match_start':
        final before = context.cursorCodeUnit;
        final stackBefore = context.cursorStack.length;
        context.rewindToLocalMatchStart();
        _traceCursorControl(
          context,
          ruleLabel,
          'rewind_match_start',
          before: before,
          stackBefore: stackBefore,
        );
        return null;
      case 'rewind_entry_start':
        final before = context.cursorCodeUnit;
        final stackBefore = context.cursorStack.length;
        context.rewindToEntryMatchStart();
        _traceCursorControl(
          context,
          ruleLabel,
          'rewind_entry_start',
          before: before,
          stackBefore: stackBefore,
        );
        return null;
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
        context.retv = child.value;
        return child.value;
      case 'and':
        return _callLogicalAnd(positionalArgs, context, ruleLabel, currentEdge);
      case 'or':
        return _callLogicalOr(positionalArgs, context, ruleLabel, currentEdge);
      case 'not':
        return _callLogicalNot(positionalArgs, context, ruleLabel, currentEdge);
      case 'print':
      case 'say':
        final values = _evaluateValues(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
        final message = values.map(_diagnosticOutputFragment).join();
        _emitDiagnosticOutput(
          context,
          RuntimeDiagnosticOutputEvent(
            helperName: helperName,
            ruleLabel: ruleLabel,
            message: helperName == 'say' ? '$message\n' : message,
          ),
        );
        return null;
      case 'print_each':
        final values = _evaluateValues(
          positionalArgs,
          context,
          ruleLabel,
          currentEdge,
        );
        final target = values.first;
        if (target is! List) {
          return null;
        }
        final prefix = _diagnosticOutputFragment(values[1]);
        final suffix = values.length == 3
            ? _diagnosticOutputFragment(values[2])
            : '';
        for (final item in target) {
          _emitDiagnosticOutput(
            context,
            RuntimeDiagnosticOutputEvent(
              helperName: helperName,
              ruleLabel: ruleLabel,
              message: '$prefix${_diagnosticOutputFragment(item)}$suffix',
            ),
          );
        }
        return null;
      case 'exit_now':
        final status = positionalArgs.isEmpty
            ? 1
            : _intValue(
                    _evaluateExpression(
                      positionalArgs.first,
                      context,
                      ruleLabel,
                      currentEdge: currentEdge,
                    ),
                  ) ??
                  1;
        throw RuntimeExitNow(status);
      default:
        if (_runtimeArrayHelperNames.contains(helperName)) {
          return _callArrayHelperFromExpressions(
            helperName,
            positionalArgs,
            context,
            ruleLabel,
            currentEdge,
          );
        }
        if (_runtimeHashHelperNames.contains(helperName)) {
          return _callHashHelperFromExpressions(
            helperName,
            positionalArgs,
            context,
            ruleLabel,
            currentEdge,
          );
        }
        if (_runtimePureHelperNames.contains(helperName)) {
          return _callPureHelper(
            helperName,
            _evaluatePureHelperValues(
              helperName,
              positionalArgs,
              context,
              ruleLabel,
              currentEdge,
            ),
          );
        }
        throw RuntimeInterpreterException(
          "unsupported runtime helper '${call.name}' in rule $ruleLabel",
        );
    }
  }

  Object? _executeUserFunction(
    UserFunctionEntry entry,
    List<ActionExpr> argExprs,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final values = [
      for (final arg in argExprs)
        _copyValue(
          _evaluateExpression(
            arg,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        ),
    ];
    if (!entry.acceptsArity(values.length)) {
      throw RuntimeInterpreterException(
        "user function '${entry.name}' expects ${entry.arityExpectation} "
        'argument(s), '
        'got ${values.length} in rule $ruleLabel',
      );
    }

    final activeIndex = context.activeUserFunctions.indexOf(entry.name);
    if (activeIndex >= 0) {
      final cycle = [
        ...context.activeUserFunctions.sublist(activeIndex),
        entry.name,
      ].join(' -> ');
      final detail =
          "user function recursion is not supported: $cycle in rule "
          '$ruleLabel';
      throw RuntimeInterpreterException(
        detail,
        diagnostic: context.diagnostic(
          stage: 'user_function_call',
          summary: 'Dart user function recursion failed',
          detail: detail,
          ruleLabel: ruleLabel,
          handlerSourceLabel: 'dart_runtime:function:${entry.name}',
        ),
      );
    }

    final block = _userFunctionBodyBlock(entry, ruleLabel, context);
    final snapshot = _RuntimeStoreSnapshot.capture(context);
    context.activeUserFunctions.add(entry.name);
    context.suspendRuleLocalBindingTracking();
    context.clearStores();
    for (var index = 0; index < entry.params.length; index += 1) {
      context.bindUserFunctionParam(entry.params[index], values[index]);
    }
    final signature = entry.signature;
    if (signature != null) {
      context.bindUserFunctionParam(
        signature.restParam,
        values.sublist(signature.minArity),
      );
    }

    try {
      final flow = _executeValueBlockStatements(
        block,
        context,
        ruleLabel,
        currentEdge,
        finalExpressionYields: true,
      );
      return flow.returned ? _copyValue(flow.value) : null;
    } finally {
      context.resumeRuleLocalBindingTracking();
      snapshot.restore(context);
      context.activeUserFunctions.removeLast();
    }
  }

  ActionBlock _userFunctionBodyBlock(
    UserFunctionEntry entry,
    String ruleLabel,
    _RuntimeExecutionContext context,
  ) {
    final cached = _userFunctionBodyCache[entry.index];
    if (cached != null) {
      return cached;
    }
    try {
      final parsed = parseActionBlock(entry.bodySource);
      _userFunctionBodyCache[entry.index] = parsed;
      return parsed;
    } catch (error) {
      final detail =
          "user function '${entry.name}' body parse failed in rule "
          '$ruleLabel: $error';
      throw RuntimeInterpreterException(
        detail,
        diagnostic: context.diagnostic(
          stage: 'user_function_body_parse',
          summary: 'Dart user function body parse failed',
          detail: detail,
          ruleLabel: ruleLabel,
          handlerSourceLabel: 'dart_runtime:function:${entry.name}',
        ),
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
    if (helperName == 'with') {
      return _callReceiverWithTrailingBlock(
        receiver,
        call,
        context,
        ruleLabel,
        currentEdge,
      );
    }
    if (_treeTraversalHelperNames.contains(helperName)) {
      return _callTreeTraversalTrailingBlock(
        receiver,
        call,
        context,
        ruleLabel,
        currentEdge,
      );
    }
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
      case 'split':
        return _callSplitWithReceiver(
          receiver,
          call.args,
          context,
          ruleLabel,
          currentEdge,
        );
      case 'push_back':
      case 'push_front':
      case 'pop_back':
      case 'pop_front':
        return null;
      default:
        if (helperName == 'join_values') {
          final values = _evaluateArgumentValues(
            call.args,
            context,
            ruleLabel,
            currentEdge,
          );
          return _callArrayHelper(helperName, [
            values.isEmpty ? '' : values.first,
            receiver,
          ]);
        }
        if (_runtimeArrayHelperNames.contains(helperName)) {
          return _callArrayHelper(helperName, [
            receiver,
            ..._evaluateArgumentValues(
              call.args,
              context,
              ruleLabel,
              currentEdge,
            ),
          ]);
        }
        if (_runtimeHashHelperNames.contains(helperName)) {
          return _callHashHelper(helperName, [
            receiver,
            ..._evaluateArgumentValues(
              call.args,
              context,
              ruleLabel,
              currentEdge,
            ),
          ]);
        }
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
    final variableTarget = _variableName(args[0]);
    if (variableTarget == null) {
      throw RuntimeInterpreterException(
        'set target in rule $ruleLabel must be a variable',
      );
    }
    context.variables[variableTarget] = value;
    context.arrays.remove(variableTarget);
    context.hashes.remove(variableTarget);
    return _copyValue(value);
  }

  bool _executeArrayStringTransformStatement(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (!const {
          'trim_each',
          'filter_nonempty',
          'lowercase_each',
          'uppercase_each',
        }.contains(helperName) ||
        args.length != 1) {
      return false;
    }
    final bareTarget = _variableName(args.single);
    if (bareTarget == null) {
      return false;
    }
    final transformed = _callArrayHelperFromExpressions(
      helperName,
      args,
      context,
      ruleLabel,
      currentEdge,
    );
    _replaceBareArrayValue(context, bareTarget, _asArray(transformed));
    return true;
  }

  Object? _callPush(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      final child = _requireCurrentEdgeChild(currentEdge, context, ruleLabel);
      return _appendArrayValue(context, ruleLabel, child.value);
    }

    if (args.length == 1 && currentEdge != null) {
      final childRule = _variableName(args[0]);
      if (childRule != null && compiledSpec.rule(childRule) != null) {
        final child = childRule == currentEdge.target.label
            ? _executeActionEdgeChild(currentEdge, context)
            : _executeRule(childRule, 0, context);
        context.retv = child.value;
        return _appendArrayValue(context, ruleLabel, child.value);
      }
      final target = _variableName(args[0]);
      if (target == null) {
        throw RuntimeInterpreterException(
          'push target in rule $ruleLabel must be a variable',
        );
      }
      final child = _executeActionEdgeChild(currentEdge, context);
      context.retv = child.value;
      return _appendArrayValue(context, target, child.value);
    }

    if (args.length >= 2) {
      final firstName = _variableName(args[0]);
      final secondTarget = _variableName(args[1]);
      if (currentEdge != null &&
          firstName != null &&
          compiledSpec.rule(firstName) != null) {
        final childIndex = _literalNonNegativeInteger(args[1]);
        if (secondTarget != null || childIndex != null) {
          final child = firstName == currentEdge.target.label
              ? _executeActionEdgeChild(currentEdge, context)
              : _executeRule(firstName, 0, context);
          context.retv = child.value;
          if (secondTarget != null) {
            return _appendArrayValue(context, secondTarget, child.value);
          }
          return _appendArrayValue(
            context,
            ruleLabel,
            _indexValue(child.value, childIndex),
          );
        }
      }

      final target = _variableName(args[0]);
      if (target == null) {
        throw RuntimeInterpreterException(
          'push target in rule $ruleLabel must be a variable',
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
      return _appendArrayValue(context, target, value);
    }

    return null;
  }

  Object? _callArray(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final values = <Object?>[];
    for (final arg in args) {
      final value = _evaluateExpression(
        arg,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      if (_isArraySpliceArgument(arg)) {
        _appendArraySpliceValue(values, value);
      } else {
        values.add(_copyValue(value));
      }
    }
    return values;
  }

  Object? _callHash(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final entries = <String, Object?>{};
    final values = [
      for (final arg in args)
        _evaluateExpression(arg, context, ruleLabel, currentEdge: currentEdge),
    ];
    for (var index = 0; index + 1 < values.length; index += 2) {
      final key = _stringValue(values[index]);
      final value = _copyValue(values[index + 1]);
      entries[key] = value;
    }
    for (final (index, value) in values.indexed) {
      if (_isHashSpliceArgument(args[index]) && value is Map) {
        for (final entry in _asHash(value).entries) {
          entries[entry.key] = _copyValue(entry.value);
        }
      }
    }
    return entries;
  }

  Object? _callInputSlice(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      return context.input;
    }
    final start = _nonNegativeInt(
      _evaluateExpression(
        args[0],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
      0,
    );
    final width = args.length >= 2
        ? _nonNegativeInt(
            _evaluateExpression(
              args[1],
              context,
              ruleLabel,
              currentEdge: currentEdge,
            ),
            context.input.runes.length,
          )
        : context.input.runes.length - start;
    final end = math.min(context.input.runes.length, start + width);
    final startCodeUnit = charOffsetToCodeUnitOffset(context.input, start);
    final endCodeUnit = charOffsetToCodeUnitOffset(context.input, end);
    return context.input.substring(startCodeUnit, endCodeUnit);
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

  void _validateDiagnosticOutputArity(
    ActionCallExpr call,
    String helperName,
    _RuntimeExecutionContext context,
    String ruleLabel,
  ) {
    final expected = switch (helperName) {
      'print' || 'say' => 'at least 1 positional argument',
      'print_each' => '2 or 3 positional arguments',
      _ => null,
    };
    if (expected == null) {
      return;
    }

    final positionalCount = call.args
        .whereType<ActionPositionalArgument>()
        .length;
    final allPositional = positionalCount == call.args.length;
    final validCount = switch (helperName) {
      'print' || 'say' => positionalCount >= 1,
      'print_each' => positionalCount == 2 || positionalCount == 3,
      _ => true,
    };
    if (allPositional && validCount) {
      return;
    }

    final message =
        "helper '$helperName' expects $expected, got $positionalCount "
        'in rule $ruleLabel';
    throw RuntimeInterpreterException(
      message,
      diagnostic: context.diagnostic(
        stage: 'helper_arity_mismatch',
        summary: 'Dart runtime helper arity mismatch',
        detail: message,
        ruleLabel: ruleLabel,
      ),
    );
  }

  void _validateLogicalHelperArity(
    ActionCallExpr call,
    String helperName,
    _RuntimeExecutionContext context,
    String ruleLabel,
  ) {
    final expected = switch (helperName) {
      'and' || 'or' => 'at least 1 positional argument',
      'not' => 'exactly 1 positional argument',
      _ => null,
    };
    if (expected == null) {
      return;
    }

    final positionalCount = call.args
        .whereType<ActionPositionalArgument>()
        .length;
    final allPositional = positionalCount == call.args.length;
    final validCount = switch (helperName) {
      'and' || 'or' => positionalCount >= 1,
      'not' => positionalCount == 1,
      _ => true,
    };
    if (allPositional && validCount) {
      return;
    }

    final message =
        'helper_arity_mismatch helper_name=$helperName '
        'actual_arity=$positionalCount expected_arity="$expected" '
        'rule_label=$ruleLabel';
    throw RuntimeInterpreterException(
      message,
      diagnostic: context.diagnostic(
        stage: 'helper_arity_mismatch',
        summary: 'Dart runtime logical-helper arity mismatch',
        detail: message,
        code: 'helper_arity_mismatch',
        helperName: helperName,
        actualArity: positionalCount,
        expectedArity: expected,
        ruleLabel: ruleLabel,
        handlerSourceLabel: 'dart_runtime:helper:$helperName',
      ),
    );
  }

  void _emitDiagnosticOutput(
    _RuntimeExecutionContext context,
    RuntimeDiagnosticOutputEvent event,
  ) {
    final sink = context.diagnosticOutputSink;
    if (sink == null) {
      return;
    }
    try {
      sink(event);
    } on Object catch (error, stackTrace) {
      throw _RuntimeDiagnosticOutputSinkFailure(error, stackTrace);
    }
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

  Object? _evaluateFluentReceiver(
    ActionExpr receiver,
    String helperName,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final receiverName = _variableName(receiver);
    if (receiverName != null) {
      if (_treeTraversalHelperNames.contains(helperName)) {
        if (_hasHashValue(context, receiverName)) {
          return Map<String, Object?>.unmodifiable(
            _hashValueFor(context, receiverName),
          );
        }
        if (_hasArrayValue(context, receiverName)) {
          return List<Object?>.unmodifiable(
            _arrayValueFor(context, receiverName),
          );
        }
      }
      if ((helperName == 'copy' || helperName == 'flat') &&
          _hasArrayValue(context, receiverName)) {
        return List<Object?>.unmodifiable(
          _arrayValueFor(context, receiverName),
        );
      }
      if ((helperName == 'copy' || helperName == 'flat') &&
          _hasHashValue(context, receiverName)) {
        return Map<String, Object?>.unmodifiable(
          _hashValueFor(context, receiverName),
        );
      }
      if (_arrayOnlyReceiverHelpers.contains(helperName)) {
        return List<Object?>.unmodifiable(
          _arrayValueFor(context, receiverName),
        );
      }
      if (_arrayPreferredReceiverHelpers.contains(helperName) &&
          _hasArrayValue(context, receiverName)) {
        return List<Object?>.unmodifiable(
          _arrayValueFor(context, receiverName),
        );
      }
      if (_hashOnlyReceiverHelpers.contains(helperName)) {
        return Map<String, Object?>.unmodifiable(
          _hashValueFor(context, receiverName),
        );
      }
      if (_hashPreferredReceiverHelpers.contains(helperName) &&
          _hasHashValue(context, receiverName)) {
        return Map<String, Object?>.unmodifiable(
          _hashValueFor(context, receiverName),
        );
      }
    }
    return _evaluateExpression(
      receiver,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  bool _executeArrayEndMutationStatement(
    ActionFluentChainExpr expr,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (expr.calls.length != 1) {
      return false;
    }
    final call = expr.calls.single;
    return _evaluateArrayEndMutationCall(
          expr.receiver,
          call,
          context,
          ruleLabel,
          currentEdge,
        ) !=
        null;
  }

  List<Object?>? _evaluateArrayEndMutationCall(
    ActionExpr receiver,
    ActionFluentCall call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final bareTarget = _variableName(receiver);
    if (bareTarget == null) {
      return null;
    }
    final target = bareTarget;
    switch (call.method) {
      case 'push_back':
      case 'push_front':
        if (call.args.length != 1) {
          return null;
        }
        final value = _copyValue(
          _evaluateExpression(
            call.args.single.value,
            context,
            ruleLabel,
            currentEdge: currentEdge,
          ),
        );
        final array = _bareArrayForMutation(context, target);
        if (call.method == 'push_back') {
          array.add(value);
        } else {
          array.insert(0, value);
        }
        return _storeBareArray(context, target, array);
      case 'pop_back':
      case 'pop_front':
        if (call.args.isNotEmpty) {
          return null;
        }
        final array = _bareArrayForMutation(context, target);
        if (array.isNotEmpty) {
          if (call.method == 'pop_back') {
            array.removeLast();
          } else {
            array.removeAt(0);
          }
        }
        return _storeBareArray(context, target, array);
      default:
        return null;
    }
  }

  bool _executeSetKeyStatement(
    ActionCallExpr call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (canonicalActionHelperName(call.name) != 'set_key') {
      return false;
    }
    var args = call.args.map((arg) => arg.value).toList();
    if (args.length == 4 && _variableName(args.first) != null) {
      args = args.sublist(1);
    }
    if (args.length != 3) {
      return false;
    }
    final bareTarget = _variableName(args[0]);
    if (bareTarget == null || bareTarget.isEmpty) {
      return false;
    }
    final target = bareTarget;
    final key = _stringValue(
      _evaluateExpression(
        args[1],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
    );
    final value = _copyValue(
      _evaluateExpression(
        args[2],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      ),
    );
    _setBareHashEntry(context, target, key, value);
    return true;
  }

  bool _executeRegexSubstitutionStatement(
    ActionCallExpr call,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final helperName = canonicalActionHelperName(call.name);
    if (helperName != 'substr' && helperName != 'regex_subst') {
      return false;
    }
    final args = call.args.map((arg) => arg.value).toList();
    if (args.length < 3) {
      return false;
    }
    final target = _scalarTargetName(args[0]);
    if (target == null || target.isEmpty) {
      return false;
    }
    final source = _scalarString(context.variables[target], nullAsEmpty: true);
    if (source == null) {
      return false;
    }
    final patternValue = _evaluatePatternArgument(
      args[1],
      context,
      ruleLabel,
      currentEdge,
    );
    final pattern = patternValue is _RuntimeRegexPattern
        ? patternValue.pattern
        : _scalarString(patternValue);
    if (pattern == null) {
      return false;
    }
    final replacement = args[2] is ActionRegexLiteralExpr
        ? (args[2] as ActionRegexLiteralExpr).pattern
        : (_scalarString(
                _evaluateExpression(
                  args[2],
                  context,
                  ruleLabel,
                  currentEdge: currentEdge,
                ),
                nullAsEmpty: true,
              ) ??
              '');
    final flags = args.length >= 4
        ? _regexFlagString(args[3], context, ruleLabel, currentEdge)
        : '';
    final regex = _compileRegex(pattern, flags: flags);
    if (regex == null) {
      return false;
    }
    final updated = _replaceRegex(
      source,
      regex,
      replacement,
      global: flags.contains('g'),
    );
    context.variables[target] = updated;
    context.arrays.remove(target);
    context.hashes.remove(target);
    return true;
  }

  Object? _callSplitFromExpressions(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final bareTarget = args.length >= 3 ? _variableName(args.first) : null;
    if (bareTarget != null) {
      final source = _evaluateExpression(
        args[1],
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      final delimiterExpr = args.length >= 3 ? args[2] : null;
      final delimiter = delimiterExpr == null
          ? ''
          : _evaluateExpression(
              delimiterExpr,
              context,
              ruleLabel,
              currentEdge: currentEdge,
            );
      final parts = _splitStringValue(
        source,
        delimiter,
        regexDelimiter: delimiterExpr is ActionRegexLiteralExpr,
      );
      return _replaceBareArrayValue(context, bareTarget, parts);
    }

    final values = _evaluateValues(args, context, ruleLabel, currentEdge);
    return _callSplit(
      values,
      regexDelimiter: args.length >= 2 && args[1] is ActionRegexLiteralExpr,
    );
  }

  Object? _callSplitWithReceiver(
    Object? receiver,
    List<ActionArgument> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      return null;
    }
    final delimiterExpr = args.first.value;
    final delimiter = _evaluateExpression(
      delimiterExpr,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
    return _splitStringValue(
      receiver,
      delimiter,
      regexDelimiter: delimiterExpr is ActionRegexLiteralExpr,
    );
  }

  Object? _callArrayHelperFromExpressions(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    return _callArrayHelper(
      helperName,
      _evaluateArrayHelperValues(
        helperName,
        args,
        context,
        ruleLabel,
        currentEdge,
      ),
    );
  }

  List<Object?> _evaluateArrayHelperValues(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    Object? evaluate(ActionExpr arg) =>
        _evaluateExpression(arg, context, ruleLabel, currentEdge: currentEdge);
    Object? arrayArg(int index) => index < args.length
        ? _evaluateArrayArgument(args[index], context, ruleLabel, currentEdge)
        : null;
    Object? maybeArrayArg(int index) => index < args.length
        ? _evaluateMaybeArrayArgument(
            args[index],
            context,
            ruleLabel,
            currentEdge,
          )
        : null;

    return switch (helperName) {
      'count' || 'is_empty' || 'is_nonempty' => [maybeArrayArg(0)],
      'first' ||
      'last' ||
      'sorted' ||
      'reversed' ||
      'trim_each' ||
      'filter_nonempty' ||
      'lowercase_each' ||
      'uppercase_each' ||
      'uniq' => [arrayArg(0)],
      'take' ||
      'take_last' ||
      'drop_front' ||
      'drop_back' ||
      'contains' ||
      'index_of' => [
        arrayArg(0),
        for (final arg in args.skip(1)) evaluate(arg),
      ],
      'filter_match' || 'split_each' => [
        arrayArg(0),
        if (args.length >= 2)
          _evaluatePatternArgument(args[1], context, ruleLabel, currentEdge),
      ],
      'slice' => [arrayArg(0), for (final arg in args.skip(1)) evaluate(arg)],
      'join_values' => [
        args.isEmpty ? '' : evaluate(args[0]),
        args.length >= 2 ? arrayArg(1) : <Object?>[],
      ],
      'flat' => [if (args.isNotEmpty) maybeArrayArg(0)],
      'flat_array' || 'concat_arrays' => [
        for (final arg in args)
          _evaluateMaybeArrayArgument(arg, context, ruleLabel, currentEdge),
      ],
      'split_tagged_records' => [
        if (args.isNotEmpty) evaluate(args[0]),
        if (args.length >= 2)
          _evaluatePatternArgument(args[1], context, ruleLabel, currentEdge),
        for (final arg in args.skip(2)) evaluate(arg),
      ],
      _ => [for (final arg in args) evaluate(arg)],
    };
  }

  Object? _callHashHelperFromExpressions(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    return _callHashHelper(
      helperName,
      _evaluateHashHelperValues(
        helperName,
        args,
        context,
        ruleLabel,
        currentEdge,
      ),
    );
  }

  List<Object?> _evaluateHashHelperValues(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    Object? evaluate(ActionExpr arg) =>
        _evaluateExpression(arg, context, ruleLabel, currentEdge: currentEdge);
    Object? hashArg(int index) => index < args.length
        ? _evaluateHashArgument(args[index], context, ruleLabel, currentEdge)
        : null;
    Object? maybeHashArg(int index) => index < args.length
        ? _evaluateMaybeHashArgument(
            args[index],
            context,
            ruleLabel,
            currentEdge,
          )
        : null;

    return switch (helperName) {
      'merge_hash' => [
        if (args.isNotEmpty) evaluate(args[0]),
        for (var index = 1; index < args.length; index += 1)
          maybeHashArg(index),
      ],
      'flat_hash' => [
        for (var index = 0; index < args.length; index += 1)
          maybeHashArg(index),
      ],
      'count_keys' || 'sorted_keys' || 'sorted_values' => [hashArg(0)],
      'has_key' || 'set_key' || 'rename_key' || 'drop_keys' || 'pick_keys' => [
        hashArg(0),
        for (final arg in args.skip(1)) evaluate(arg),
      ],
      _ => [for (final arg in args) evaluate(arg)],
    };
  }

  Object? _evaluateArrayArgument(
    ActionExpr arg,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final name = _variableName(arg);
    if (name != null) {
      return List<Object?>.unmodifiable(_arrayValueFor(context, name));
    }
    return _evaluateExpression(
      arg,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  Object? _evaluateMaybeArrayArgument(
    ActionExpr arg,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final name = _variableName(arg);
    if (name != null && _hasArrayValue(context, name)) {
      return List<Object?>.unmodifiable(_arrayValueFor(context, name));
    }
    return _evaluateExpression(
      arg,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  Object? _evaluateHashArgument(
    ActionExpr arg,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final name = _variableName(arg);
    if (name != null) {
      return Map<String, Object?>.unmodifiable(_hashValueFor(context, name));
    }
    return _evaluateExpression(
      arg,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  Object? _evaluateMaybeHashArgument(
    ActionExpr arg,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final name = _variableName(arg);
    if (name != null && _hasHashValue(context, name)) {
      return Map<String, Object?>.unmodifiable(_hashValueFor(context, name));
    }
    return _evaluateExpression(
      arg,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  Object? _evaluatePatternArgument(
    ActionExpr arg,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (arg is ActionRegexLiteralExpr) {
      return _RuntimeRegexPattern(arg.pattern);
    }
    return _evaluateExpression(
      arg,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    );
  }

  List<Object?> _evaluatePureHelperValues(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (_numericAggregateHelperNames.contains(helperName) && args.length == 1) {
      return [_copyArgument(args.first, context, ruleLabel, currentEdge)];
    }
    return _evaluateValues(args, context, ruleLabel, currentEdge);
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

  String? _captureSliceText(
    _RuntimeExecutionContext context, {
    required bool untilCursor,
  }) {
    final start = _captureStartCodeUnit(context);
    final end = _captureEndCodeUnit(context, untilCursor: untilCursor);
    if (end < start) {
      return null;
    }
    return context.input.substring(start, end);
  }

  int? _captureSliceLength(
    _RuntimeExecutionContext context, {
    required bool untilCursor,
  }) {
    final text = _captureSliceText(context, untilCursor: untilCursor);
    return text?.runes.length;
  }

  int _captureStartCodeUnit(_RuntimeExecutionContext context) {
    return (context.registers.captureStartCodeUnit ?? 0).clamp(
      0,
      context.input.length,
    );
  }

  int _captureEndCodeUnit(
    _RuntimeExecutionContext context, {
    required bool untilCursor,
  }) {
    final end = untilCursor
        ? context.cursorCodeUnit
        : context.registers.localMatch?.codeUnitStart ?? context.cursorCodeUnit;
    return end.clamp(0, context.input.length);
  }

  Object? _callCaptureMarkHelper(
    String helperName,
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    String? markName(int index) {
      if (index >= args.length) {
        return null;
      }
      return _captureName(args[index], context, ruleLabel, currentEdge);
    }

    String? spanText(int start, int end) {
      if (start < 0 || end < start || end > context.input.length) {
        return null;
      }
      return context.input.substring(start, end);
    }

    int? spanLength(int start, int end) => spanText(start, end)?.runes.length;

    final captureStart = _captureStartCodeUnit(context);
    final matchStart = _captureEndCodeUnit(context, untilCursor: false);
    final cursor = context.cursorCodeUnit;
    final inputEnd = context.input.length;
    final marks = context.marksFor(ruleLabel);

    switch (helperName) {
      case 'start_capture_slice_from':
        final name = markName(0);
        final offset = name == null ? null : marks[name];
        if (offset != null) {
          context.startCaptureSliceAt(offset);
        }
        return null;
      case 'capture_rest':
        return spanText(captureStart, inputEnd);
      case 'capture_rest_len':
        return spanLength(captureStart, inputEnd);
      case 'capture_take':
        final value = spanText(captureStart, matchStart);
        if (value != null) {
          context.startCaptureSliceAt(cursor);
        }
        return value;
      case 'capture_take_len':
        final value = spanLength(captureStart, matchStart);
        if (value != null) {
          context.startCaptureSliceAt(cursor);
        }
        return value;
      case 'capture_take_until_cursor':
        final value = spanText(captureStart, cursor);
        if (value != null) {
          context.startCaptureSliceAt(cursor);
        }
        return value;
      case 'capture_take_until_cursor_len':
        final value = spanLength(captureStart, cursor);
        if (value != null) {
          context.startCaptureSliceAt(cursor);
        }
        return value;
      case 'capture_take_rest':
        final value = spanText(captureStart, inputEnd);
        if (value != null) {
          context.startCaptureSliceAt(inputEnd);
        }
        return value;
      case 'capture_take_rest_len':
        final value = spanLength(captureStart, inputEnd);
        if (value != null) {
          context.startCaptureSliceAt(inputEnd);
        }
        return value;
      case 'mark_here':
        final name = markName(0);
        if (name != null) {
          marks[name] = cursor;
        }
        return null;
      case 'mark_input_start':
        final name = markName(0);
        if (name != null) {
          marks[name] = 0;
        }
        return null;
      case 'mark_input_end':
        final name = markName(0);
        if (name != null) {
          marks[name] = inputEnd;
        }
        return null;
      case 'mark_entry_start':
        final name = markName(0);
        final offset = context.registers.entryMatch?.codeUnitStart;
        if (name != null && offset != null) {
          marks[name] = offset;
        }
        return null;
      case 'mark_entry_end':
        final name = markName(0);
        final offset = context.registers.entryMatch?.codeUnitEnd;
        if (name != null && offset != null) {
          marks[name] = offset;
        }
        return null;
      case 'mark_match_start':
        final name = markName(0);
        final offset = context.registers.localMatch?.codeUnitStart;
        if (name != null && offset != null) {
          marks[name] = offset;
        }
        return null;
      case 'mark_match_end':
        final name = markName(0);
        final offset = context.registers.localMatch?.codeUnitEnd;
        if (name != null && offset != null) {
          marks[name] = offset;
        }
        return null;
      case 'mark_copy':
        final target = markName(0);
        final source = markName(1);
        if (target != null) {
          final offset = source == null ? null : marks[source];
          if (offset == null) {
            marks.remove(target);
          } else {
            marks[target] = offset;
          }
        }
        return null;
      case 'mark_capture_slice':
        final name = markName(0);
        if (name != null) {
          marks[name] = captureStart;
        }
        return null;
      case 'mark_exists':
        final name = markName(0);
        return name != null && marks.containsKey(name) ? 1 : 0;
      case 'mark_pos':
        final name = markName(0);
        final offset = name == null ? null : marks[name];
        return offset == null
            ? null
            : codeUnitOffsetToCharOffset(context.input, offset);
      case 'mark_line':
        final name = markName(0);
        final offset = name == null ? null : marks[name];
        return offset == null
            ? null
            : lineColumnAtCodeUnitOffset(context.input, offset).line;
      case 'mark_col':
        final name = markName(0);
        final offset = name == null ? null : marks[name];
        return offset == null
            ? null
            : lineColumnAtCodeUnitOffset(context.input, offset).column;
      case 'clear_mark':
        final name = markName(0);
        if (name != null) {
          marks.remove(name);
        }
        return null;
      case 'capture_from':
      case 'capture_len_from':
      case 'capture_until_cursor_from':
      case 'capture_until_cursor_len_from':
      case 'capture_rest_from':
      case 'capture_rest_len_from':
      case 'capture_take_len_from':
      case 'capture_take_until_cursor_from':
      case 'capture_take_until_cursor_len_from':
      case 'capture_take_rest_from':
      case 'capture_take_rest_len_from':
        final name = markName(0);
        final start = name == null ? null : marks[name];
        if (name == null || start == null) {
          return null;
        }
        final end = switch (helperName) {
          'capture_from' ||
          'capture_len_from' ||
          'capture_take_len_from' => matchStart,
          'capture_until_cursor_from' ||
          'capture_until_cursor_len_from' ||
          'capture_take_until_cursor_from' ||
          'capture_take_until_cursor_len_from' => cursor,
          _ => inputEnd,
        };
        final lengthResult =
            helperName.contains('_len_') || helperName == 'capture_len_from';
        final value = lengthResult
            ? spanLength(start, end)
            : spanText(start, end);
        if (value != null && helperName.startsWith('capture_take_')) {
          marks[name] = helperName.contains('_rest_') ? inputEnd : cursor;
        }
        return value;
      case 'capture_between':
      case 'capture_len_between':
      case 'capture_take_between':
      case 'capture_take_between_len':
        final startName = markName(0);
        final endName = markName(1);
        final start = startName == null ? null : marks[startName];
        final end = endName == null ? null : marks[endName];
        if (startName == null || start == null || end == null) {
          return null;
        }
        final value = helperName.contains('len')
            ? spanLength(start, end)
            : spanText(start, end);
        if (value != null && helperName.startsWith('capture_take_')) {
          marks[startName] = end;
        }
        return value;
      default:
        return null;
    }
  }

  Object? _callCaptureUntilBoundary(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    if (args.isEmpty) {
      return null;
    }
    var sawValidBoundary = false;
    int? boundaryStart;
    for (final arg in args) {
      final targetLabel = _ruleNameFromExpr(
        arg,
        context,
        ruleLabel,
        currentEdge,
      );
      final targetRule = compiledSpec.rule(targetLabel);
      if (targetRule == null) {
        continue;
      }
      final plan = _regexPlanFor(targetRule);
      if (plan.patterns.isEmpty) {
        continue;
      }
      sawValidBoundary = true;
      final boundaryMatch = RuntimeRegexAlternation.compile(
        plan.patterns,
      ).seekMatch(context.input, context.cursorCodeUnit);
      if (boundaryMatch != null &&
          (boundaryStart == null ||
              boundaryMatch.codeUnitStart < boundaryStart)) {
        boundaryStart = boundaryMatch.codeUnitStart;
      }
    }
    if (!sawValidBoundary) {
      return null;
    }
    boundaryStart ??= context.input.length;
    final captureStart = context.cursorCodeUnit;
    if (boundaryStart < captureStart) {
      context.trace?.traceDecision(
        'dart_runtime:source_boundary',
        false,
        'helper=capture_until_boundary rule=$ruleLabel '
            'capture_start=$captureStart boundary=$boundaryStart',
        LinkedSpecTraceLevel.debug,
      );
      return null;
    }
    context._setCursorCodeUnit(boundaryStart);
    final captured = context.input.substring(captureStart, boundaryStart);
    context.trace?.emitEvent(
      LinkedSpecTraceEventKind.mark,
      'dart_runtime:source_boundary',
      'helper=capture_until_boundary rule=$ruleLabel '
          'capture_start=$captureStart boundary=$boundaryStart '
          'length=${boundaryStart - captureStart}',
      LinkedSpecTraceLevel.debug,
    );
    return captured;
  }

  bool _callLogicalAnd(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final values = _evaluateValues(args, context, ruleLabel, currentEdge);
    var result = true;
    for (final value in values) {
      if (!runtimeLogicalTruth(value)) {
        result = false;
      }
    }
    return result;
  }

  bool _callLogicalOr(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final values = _evaluateValues(args, context, ruleLabel, currentEdge);
    var result = false;
    for (final value in values) {
      if (runtimeLogicalTruth(value)) {
        result = true;
      }
    }
    return result;
  }

  bool _callLogicalNot(
    List<ActionExpr> args,
    _RuntimeExecutionContext context,
    String ruleLabel,
    _CurrentActionEdge? currentEdge,
  ) {
    final values = _evaluateValues(args, context, ruleLabel, currentEdge);
    return !runtimeLogicalTruth(values.single);
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
    final before = context.cursorCodeUnit;
    final childRule = compiledSpec.rule(currentEdge.target.label);
    if (childRule == null) {
      throw RuntimeInterpreterException(
        "action edge references undefined child '${currentEdge.target.label}'",
      );
    }
    if (_isPassiveTerminalRule(childRule)) {
      context.trace?.traceDecision(
        'dart_runtime:child_dispatch',
        false,
        'edge_family=action rule=${currentEdge.ruleLabel} '
            'target=${currentEdge.target.label}[${currentEdge.target.index}] '
            'passive=1 cursor_before=$before cursor_after=${context.cursorCodeUnit}',
        LinkedSpecTraceLevel.debug,
      );
      return _RuleResult(matched: false, value: null);
    }
    final child = _executeRule(
      currentEdge.target.label,
      currentEdge.target.index,
      context,
    );
    context.trace?.traceDecision(
      'dart_runtime:child_dispatch',
      child.matched,
      'edge_family=action rule=${currentEdge.ruleLabel} '
          'target=${currentEdge.target.label}[${currentEdge.target.index}] '
          'cursor_before=$before cursor_after=${context.cursorCodeUnit}',
      LinkedSpecTraceLevel.debug,
    );
    return child;
  }

  void _traceCursorControl(
    _RuntimeExecutionContext context,
    String ruleLabel,
    String helperName, {
    required int before,
    required int stackBefore,
  }) {
    context.trace?.emitEvent(
      LinkedSpecTraceEventKind.mark,
      'dart_runtime:cursor_control',
      'helper=$helperName rule=$ruleLabel before=$before '
          'after=${context.cursorCodeUnit} stack_before=$stackBefore '
          'stack_after=${context.cursorStack.length}',
      LinkedSpecTraceLevel.debug,
    );
  }

  bool _isPassiveTerminalRule(CompiledRule rule) {
    return rule.lifecycleActionPayloads.isEmpty &&
        rule.actionEdges.isEmpty &&
        rule.blindEdges.isEmpty &&
        rule.plainActionPayloads.isEmpty;
  }
}

bool _isHashSpliceArgument(ActionExpr expr) {
  return switch (expr) {
    ActionCallExpr(:final name) => {
      'flat',
      'flat_hash',
    }.contains(canonicalActionHelperName(name)),
    ActionFluentChainExpr(:final calls) when calls.isNotEmpty => {
      'flat',
      'flat_hash',
    }.contains(canonicalActionHelperName(calls.last.method)),
    _ => false,
  };
}

bool _isArraySpliceArgument(ActionExpr expr) {
  return switch (expr) {
    ActionCallExpr(:final name) => {
      'flat',
      'flat_array',
      'flat_hash',
    }.contains(canonicalActionHelperName(name)),
    ActionFluentChainExpr(:final calls) when calls.isNotEmpty => {
      'flat',
      'flat_array',
      'flat_hash',
    }.contains(canonicalActionHelperName(calls.last.method)),
    _ => false,
  };
}

void _appendArraySpliceValue(List<Object?> values, Object? value) {
  if (value is Map) {
    for (final entry in _asHash(value).entries) {
      values.add(entry.key);
      values.add(_copyValue(entry.value));
    }
    return;
  }
  if (value is List) {
    for (final item in value) {
      values.add(_copyValue(item));
    }
    return;
  }
  values.add(_copyValue(value));
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

const _numericAggregateHelperNames = <String>{
  'num_avg',
  'num_max',
  'num_median',
  'num_min',
  'num_range',
  'num_sum',
};

const _runtimeArrayHelperNames = <String>{
  'concat_arrays',
  'contains',
  'count',
  'drop_back',
  'drop_front',
  'filter_match',
  'filter_nonempty',
  'first',
  'flat',
  'flat_array',
  'index_of',
  'join_values',
  'last',
  'lowercase_each',
  'reversed',
  'slice',
  'sorted',
  'split_each',
  'split_tagged_records',
  'take',
  'take_last',
  'trim_each',
  'uniq',
  'uppercase_each',
};

const _runtimeHashHelperNames = <String>{
  'count_keys',
  'drop_keys',
  'flat_hash',
  'has_key',
  'merge_hash',
  'pick_keys',
  'rename_key',
  'set_key',
  'sorted_keys',
  'sorted_values',
};

const _treeTraversalHelperNames = <String>{
  'walk_leaves',
  'map_leaves',
  'reduce_leaves',
};

const _arrayOnlyReceiverHelpers = <String>{
  ..._runtimeArrayHelperNames,
  'num_avg',
  'num_median',
  'num_range',
  'num_sum',
};

const _arrayPreferredReceiverHelpers = <String>{
  'is_empty',
  'is_nonempty',
  'num_max',
  'num_min',
};

const _hashOnlyReceiverHelpers = <String>{..._runtimeHashHelperNames};

const _hashPreferredReceiverHelpers = <String>{'is_empty', 'is_nonempty'};

const _runtimeReceiverHelperNames = <String>{
  ..._runtimePureHelperNames,
  ..._runtimeArrayHelperNames,
  ..._runtimeHashHelperNames,
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
    'lowercase' => _stringTransform(values, unicodeLowercase),
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
    'uppercase' => _stringTransform(values, unicodeUppercase),
    _ => throw RuntimeInterpreterException(
      "unsupported pure runtime helper '$helperName'",
    ),
  };
}

Object? _callArrayHelper(String helperName, List<Object?> values) {
  return switch (helperName) {
    'concat_arrays' => _callConcatArrays(values),
    'contains' => _callArrayContains(values),
    'count' => _lengthValue(values.isEmpty ? null : values.first) ?? 0,
    'drop_back' => _callDrop(values, front: false),
    'drop_front' => _callDrop(values, front: true),
    'filter_match' => _callFilterMatch(values),
    'filter_nonempty' => _arrayTransform(values, (items) {
      return [
        for (final item in items)
          if (!_isEmptyValue(item)) _copyValue(item),
      ];
    }),
    'first' => _arrayItem(values, first: true),
    'flat' => _callFlat(values),
    'flat_array' => _callFlatArray(values),
    'index_of' => _callIndexOf(values),
    'join_values' => _callJoinValues(values),
    'last' => _arrayItem(values, first: false),
    'lowercase_each' => _mapStringItems(values, unicodeLowercase),
    'reversed' => _arrayTransform(values, (items) {
      return [for (final item in items.reversed) _copyValue(item)];
    }),
    'slice' => _callSlice(values),
    'sorted' => _arrayTransform(values, (items) {
      final sorted = [for (final item in items) _copyValue(item)]
        ..sort(
          (left, right) => _scalarString(
            left,
            nullAsEmpty: true,
          )!.compareTo(_scalarString(right, nullAsEmpty: true)!),
        );
      return sorted;
    }),
    'split_each' => _callSplitEach(values),
    'split_tagged_records' => _callSplitTaggedRecords(values),
    'take' => _callTake(values, front: true),
    'take_last' => _callTake(values, front: false),
    'trim_each' => _mapStringItems(values, (value) => value.trim()),
    'uniq' => _callUniq(values),
    'uppercase_each' => _mapStringItems(values, unicodeUppercase),
    _ => throw RuntimeInterpreterException(
      "unsupported array runtime helper '$helperName'",
    ),
  };
}

Object? _callHashHelper(String helperName, List<Object?> values) {
  return switch (helperName) {
    'count_keys' =>
      _hashItems(values.isEmpty ? null : values.first)?.length ?? 0,
    'drop_keys' => _callDropKeys(values),
    'flat_hash' => _callFlatHash(values),
    'has_key' => _callHasKey(values),
    'merge_hash' => _callMergeHash(values),
    'pick_keys' => _callPickKeys(values),
    'rename_key' => _callRenameKey(values),
    'set_key' => _callSetKey(values),
    'sorted_keys' => _callSortedKeys(values),
    'sorted_values' => _callSortedValues(values),
    _ => throw RuntimeInterpreterException(
      "unsupported hash runtime helper '$helperName'",
    ),
  };
}

Object? _arrayItem(List<Object?> values, {required bool first}) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null || items.isEmpty) {
    return null;
  }
  return _copyValue(first ? items.first : items.last);
}

Object? _arrayTransform(
  List<Object?> values,
  List<Object?> Function(List<Object?> items) transform,
) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null) {
    return <Object?>[];
  }
  return transform(items);
}

Object? _callTake(List<Object?> values, {required bool front}) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null) {
    return <Object?>[];
  }
  final count = _nonNegativeInt(values.length >= 2 ? values[1] : null, 1);
  if (front) {
    return [for (final item in items.take(count)) _copyValue(item)];
  }
  final start = math.max(0, items.length - count);
  return [for (final item in items.skip(start)) _copyValue(item)];
}

Object? _callDrop(List<Object?> values, {required bool front}) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null) {
    return <Object?>[];
  }
  final count = _nonNegativeInt(values.length >= 2 ? values[1] : null, 1);
  if (front) {
    return [for (final item in items.skip(count)) _copyValue(item)];
  }
  final end = math.max(0, items.length - count);
  return [for (final item in items.take(end)) _copyValue(item)];
}

Object? _callSlice(List<Object?> values) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null) {
    return <Object?>[];
  }
  final start = _nonNegativeInt(values.length >= 2 ? values[1] : null, 0);
  final length = _nonNegativeInt(
    values.length >= 3 ? values[2] : null,
    items.length,
  );
  if (start >= items.length) {
    return <Object?>[];
  }
  final end = math.min(items.length, start + length);
  return [for (final item in items.sublist(start, end)) _copyValue(item)];
}

Object? _callArrayContains(List<Object?> values) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null || values.length < 2) {
    return 0;
  }
  final needle = _scalarString(values[1], nullAsEmpty: true);
  return items.any((item) => _scalarString(item, nullAsEmpty: true) == needle)
      ? 1
      : 0;
}

Object? _callIndexOf(List<Object?> values) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null || values.length < 2) {
    return null;
  }
  final needle = _scalarString(values[1], nullAsEmpty: true);
  for (final (index, item) in items.indexed) {
    if (_scalarString(item, nullAsEmpty: true) == needle) {
      return index;
    }
  }
  return null;
}

Object? _callJoinValues(List<Object?> values) {
  final delimiter = _scalarString(
    values.isEmpty ? '' : values.first,
    nullAsEmpty: true,
  );
  if (delimiter == null) {
    return '';
  }
  final items = values.length >= 2 ? _arrayItems(values[1]) : const <Object?>[];
  final parts = items ?? (values.length >= 2 ? <Object?>[values[1]] : const []);
  return parts
      .map((value) => _scalarString(value, nullAsEmpty: true) ?? '')
      .join(delimiter);
}

Object? _mapStringItems(
  List<Object?> values,
  String Function(String value) transform,
) {
  return _arrayTransform(values, (items) {
    return [
      for (final item in items)
        transform(_scalarString(item, nullAsEmpty: true) ?? ''),
    ];
  });
}

Object? _callSplitEach(List<Object?> values) {
  return _arrayTransform(values, (items) {
    final delimiter = values.length >= 2 ? values[1] : '';
    return [
      for (final item in items)
        ..._splitStringValue(item, delimiter, regexDelimiter: false),
    ];
  });
}

Object? _callFilterMatch(List<Object?> values) {
  final items = _arrayItems(values.isEmpty ? null : values.first);
  if (items == null || values.length < 2) {
    return <Object?>[];
  }
  final regex = _regexFromValue(values[1]);
  if (regex == null) {
    return <Object?>[];
  }
  return [
    for (final item in items)
      if (regex.hasMatch(_scalarString(item, nullAsEmpty: true) ?? ''))
        _copyValue(item),
  ];
}

Object? _callUniq(List<Object?> values) {
  return _arrayTransform(values, (items) {
    final seen = <String>{};
    final result = <Object?>[];
    for (final item in items) {
      final key = _scalarString(item, nullAsEmpty: true) ?? '';
      if (seen.add(key)) {
        result.add(_copyValue(item));
      }
    }
    return result;
  });
}

Object? _callFlat(List<Object?> values) {
  if (values.isEmpty) {
    return [null];
  }
  final value = values.first;
  if (value is Map) {
    return _asHash(value);
  }
  if (value is List) {
    return [for (final item in value) _copyValue(item)];
  }
  return [_copyValue(value)];
}

Object? _callFlatArray(List<Object?> values) {
  return [
    for (final value in values)
      if (value is List)
        for (final item in value) _copyValue(item)
      else
        _copyValue(value),
  ];
}

Object? _callConcatArrays(List<Object?> values) => _callFlatArray(values);

Object? _callSplitTaggedRecords(List<Object?> values) {
  if (values.length < 3) {
    return <Object?>[];
  }
  final tag = _scalarString(values[2], nullAsEmpty: true) ?? '';
  final fields = [for (final field in values.skip(3)) _copyValue(field)];
  return [
    for (final item in _splitStringValue(
      values[0],
      values[1],
      regexDelimiter: false,
    ))
      [tag, item, ...fields.map(_copyValue)],
  ];
}

Map<String, Object?>? _hashItems(Object? value) {
  if (value is! Map) {
    return null;
  }
  return _asHash(value);
}

Object? _callMergeHash(List<Object?> values) {
  final merged = <String, Object?>{};
  for (final value in values) {
    final hash = _hashItems(value);
    if (hash == null) {
      continue;
    }
    for (final entry in hash.entries) {
      merged[entry.key] = _copyValue(entry.value);
    }
  }
  return merged;
}

Object? _callSetKey(List<Object?> values) {
  if (values.length < 3) {
    return null;
  }
  final hash = _hashItems(values.first);
  if (hash == null) {
    return _copyValue(values.first);
  }
  hash[_stringValue(values[1])] = _copyValue(values[2]);
  return hash;
}

Object? _callRenameKey(List<Object?> values) {
  if (values.length < 3) {
    return null;
  }
  final hash = _hashItems(values.first);
  if (hash == null) {
    return _copyValue(values.first);
  }
  final oldKey = _stringValue(values[1]);
  final newKey = _stringValue(values[2]);
  return {
    for (final entry in hash.entries)
      if (entry.key == oldKey)
        newKey: _copyValue(entry.value)
      else
        entry.key: _copyValue(entry.value),
  };
}

Object? _callDropKeys(List<Object?> values) {
  final hash = _hashItems(values.isEmpty ? null : values.first);
  if (hash == null) {
    return values.isEmpty ? null : _copyValue(values.first);
  }
  final keys = {for (final value in values.skip(1)) _stringValue(value)};
  return {
    for (final entry in hash.entries)
      if (!keys.contains(entry.key)) entry.key: _copyValue(entry.value),
  };
}

Object? _callPickKeys(List<Object?> values) {
  final hash = _hashItems(values.isEmpty ? null : values.first);
  if (hash == null) {
    return null;
  }
  final keys = {for (final value in values.skip(1)) _stringValue(value)};
  return {
    for (final entry in hash.entries)
      if (keys.contains(entry.key)) entry.key: _copyValue(entry.value),
  };
}

Object? _callSortedKeys(List<Object?> values) {
  final hash = _hashItems(values.isEmpty ? null : values.first);
  if (hash == null) {
    return <Object?>[];
  }
  final keys = hash.keys.toList()..sort();
  return keys;
}

Object? _callSortedValues(List<Object?> values) {
  final hash = _hashItems(values.isEmpty ? null : values.first);
  if (hash == null) {
    return <Object?>[];
  }
  final entries = hash.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  return [for (final entry in entries) _copyValue(entry.value)];
}

Object? _callHasKey(List<Object?> values) {
  final hash = _hashItems(values.isEmpty ? null : values.first);
  if (hash == null || values.length < 2) {
    return 0;
  }
  return hash.containsKey(_stringValue(values[1])) ? 1 : 0;
}

Object? _callFlatHash(List<Object?> values) {
  final flattened = <String, Object?>{};
  for (final value in values) {
    final hash = _hashItems(value);
    if (hash == null) {
      continue;
    }
    for (final entry in hash.entries) {
      flattened[entry.key] = _copyValue(entry.value);
    }
  }
  return flattened;
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
    final string = _scalarString(value);
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
    return 0;
  }
  final value = _scalarString(values[0]);
  final needle = _scalarString(values[1], nullAsEmpty: true);
  if (value == null || needle == null) {
    return 0;
  }
  return test(value, needle) ? 1 : 0;
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

Object? _callSplit(List<Object?> values, {bool regexDelimiter = false}) {
  if (values.length < 2) {
    return null;
  }
  return _splitStringValue(
    values[0],
    values[1],
    regexDelimiter: regexDelimiter,
  );
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
  if (value is Map) {
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
      if (values.length < 2) {
        return null;
      }
      return _numericFold(values, (left, right) => left + right);
    case 'num_sub':
      if (values.length != 2) {
        return null;
      }
      return _numericFold(values, (left, right) => left - right);
    case 'num_mul':
      if (values.length < 2) {
        return null;
      }
      return _numericFold(values, (left, right) => left * right);
    case 'num_div':
      if (values.length != 2) {
        return null;
      }
      return _numericFold(values, (left, right) {
        if (right == 0) {
          throw const _InvalidNumericResult();
        }
        return left / right;
      });
    case 'num_mod':
      if (values.length != 2) {
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
      return _jsonNumber(left - (left / right).floor() * right);
    case 'num_abs':
      if (values.length != 1) {
        return null;
      }
      return _unaryNumber(values, (value) => value.abs());
    case 'num_floor':
      if (values.length != 1) {
        return null;
      }
      return _unaryNumber(values, (value) => value.floor());
    case 'num_ceil':
      if (values.length != 1) {
        return null;
      }
      return _unaryNumber(values, (value) => value.ceil());
    case 'num_round':
      if (values.length != 1) {
        return null;
      }
      return _unaryNumber(values, (value) => value.round());
    case 'num_min':
      return _minMax(values, math.min);
    case 'num_max':
      return _minMax(values, math.max);
    case 'num_clamp':
      if (values.length != 3) {
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
  if (values.length < 2) {
    return null;
  }
  return _numericFold(values, select);
}

Object? _numericCompare(String helperName, List<Object?> values) {
  if (values.length != 2) {
    return null;
  }
  final left = _numValue(values[0]);
  final right = _numValue(values[1]);
  if (left == null || right == null) {
    return null;
  }
  final result = switch (helperName) {
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
  return result ? 1 : 0;
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
  final text = '$value';
  final match = _strictDecimalText.matchAsPrefix(text);
  if (match == null || match.end != text.length) {
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

final _strictDecimalText = RegExp(r'-?(?:\d+(?:\.\d+)?|\.\d+)');

Object? _jsonNumber(num value) {
  if (!value.isFinite) {
    return null;
  }
  if (_isInteger(value)) {
    return value.toInt();
  }
  return value;
}

List<Object?>? _arrayItems(Object? value) {
  if (value is! List) {
    return null;
  }
  return [for (final item in value) _copyValue(item)];
}

int _nonNegativeInt(Object? value, int defaultValue) {
  return math.max(0, _intValue(value) ?? defaultValue);
}

List<Object?> _splitStringValue(
  Object? value,
  Object? delimiter, {
  required bool regexDelimiter,
}) {
  final source = _scalarString(value);
  if (source == null) {
    return <Object?>[];
  }
  if (delimiter is _RuntimeRegexPattern || regexDelimiter) {
    final pattern = delimiter is _RuntimeRegexPattern
        ? delimiter.pattern
        : (_scalarString(delimiter) ?? '');
    final regex = _compileRegex(pattern);
    if (regex == null) {
      return <Object?>[];
    }
    return source.split(regex);
  }
  final literal = _scalarString(delimiter, nullAsEmpty: true);
  if (literal == null) {
    return <Object?>[];
  }
  if (literal.isEmpty) {
    return [for (final rune in source.runes) String.fromCharCode(rune)];
  }
  return source.split(literal);
}

RegExp? _regexFromValue(Object? value) {
  final pattern = value is _RuntimeRegexPattern
      ? value.pattern
      : _scalarString(value);
  if (pattern == null) {
    return null;
  }
  return _compileRegex(pattern);
}

RegExp? _compileRegex(String pattern, {String flags = ''}) {
  try {
    return compileRuntimeRegex(
      pattern,
      caseSensitive: !flags.contains('i'),
      multiLine: flags.contains('m'),
      dotAll: flags.contains('s'),
    );
  } on FormatException {
    return null;
  }
}

String _regexFlagString(
  ActionExpr expr,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final name = _variableName(expr);
  if (name != null) {
    return name;
  }
  return _scalarString(
        context.engine._evaluateExpression(
          expr,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
        nullAsEmpty: true,
      ) ??
      '';
}

String _replaceRegex(
  String source,
  RegExp regex,
  String replacement, {
  required bool global,
}) {
  if (global) {
    return source.replaceAllMapped(
      regex,
      (match) => _expandRegexReplacement(replacement, match),
    );
  }
  return source.replaceFirstMapped(
    regex,
    (match) => _expandRegexReplacement(replacement, match),
  );
}

String _expandRegexReplacement(String replacement, Match match) {
  return replacement.replaceAllMapped(RegExp(r'\$(\d+)'), (placeholder) {
    final index = int.tryParse(placeholder[1] ?? '');
    if (index == null || index < 0 || index > match.groupCount) {
      return '';
    }
    return match.group(index) ?? '';
  });
}

int _matchStartLine(String input, RuntimeRegexMatch? match) {
  final codeUnitStart = match?.codeUnitStart;
  if (codeUnitStart == null) {
    return 1;
  }
  return lineColumnAtCodeUnitOffset(input, codeUnitStart).line;
}

int _matchStartColumn(String input, RuntimeRegexMatch? match) {
  final codeUnitStart = match?.codeUnitStart;
  if (codeUnitStart == null) {
    return 1;
  }
  return lineColumnAtCodeUnitOffset(input, codeUnitStart).column;
}

int _matchEndLine(String input, RuntimeRegexMatch? match) {
  final codeUnitEnd = match?.codeUnitEnd;
  if (codeUnitEnd == null) {
    return 1;
  }
  return lineColumnAtCodeUnitOffset(input, codeUnitEnd).line;
}

int _matchEndColumn(String input, RuntimeRegexMatch? match) {
  final codeUnitEnd = match?.codeUnitEnd;
  if (codeUnitEnd == null) {
    return 1;
  }
  return lineColumnAtCodeUnitOffset(input, codeUnitEnd).column;
}

String? _scalarString(Object? value, {bool nullAsEmpty = false}) {
  if (value == null) {
    return nullAsEmpty ? '' : null;
  }
  if (value is _RuntimeRegexPattern) {
    return value.pattern;
  }
  if (value is List || value is Map) {
    return nullAsEmpty ? '' : null;
  }
  if (value is bool) {
    return value ? '1' : '0';
  }
  if (value is num) {
    if (!value.isFinite) {
      return null;
    }
    if (value == 0) {
      return '0';
    }
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
  return '$value';
}

String _diagnosticOutputFragment(Object? value) {
  return _scalarString(value, nullAsEmpty: true) ?? '';
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

final class _RuntimeRegexPattern {
  const _RuntimeRegexPattern(this.pattern);

  final String pattern;
}

final class _RuleExecutionPolicy {
  const _RuleExecutionPolicy({
    required this.cursorPolicy,
    required this.usesAndExecution,
  });

  final LinkedSpecParseMode cursorPolicy;
  final bool usesAndExecution;
}

final class _RuntimeExecutionContext {
  _RuntimeExecutionContext({
    required this.engine,
    required this.input,
    required this.maxIterations,
    required this.topRule,
    required this.trace,
    required this.diagnosticOutputSink,
    this.generatedPlan,
    this.generatedSourceIdentity,
  }) : registers = RuntimeMatchRegisters.empty(input);

  final LinkedSpecRuntimeEngine engine;
  final String input;
  final int maxIterations;
  final String topRule;
  final LinkedSpecTraceEmitter? trace;
  final RuntimeDiagnosticOutputSink? diagnosticOutputSink;
  final Map<String, GeneratedRuleFamily>? generatedPlan;
  final String? generatedSourceIdentity;
  final Map<String, Object?> variables = <String, Object?>{};
  final Map<String, List<Object?>> arrays = <String, List<Object?>>{};
  final Map<String, Map<String, Object?>> hashes =
      <String, Map<String, Object?>>{};
  final Map<String, Map<String, int>> markBuckets =
      <String, Map<String, int>>{};
  final Set<String> activeRuleEntries = <String>{};
  final List<String> activeUserFunctions = <String>[];
  final List<RuntimeLifecycleEvent> lifecycleEvents = <RuntimeLifecycleEvent>[];
  final List<int> cursorStack = <int>[];
  final List<String> _ruleStack = <String>[];
  final List<Map<String, _VariableSnapshot>> _ruleLocalBindingScopes =
      <Map<String, _VariableSnapshot>>[];
  int _ruleLocalBindingSuppressionDepth = 0;

  RuntimeMatchRegisters registers;
  Object? retv;
  int cursorCodeUnit = 0;

  String? get currentRuleLabel {
    return _ruleStack.isEmpty ? null : _ruleStack.last;
  }

  int get cursorCharOffset {
    return codeUnitOffsetToCharOffset(input, cursorCodeUnit);
  }

  LineColumn get cursorLineColumn {
    return lineColumnAtCodeUnitOffset(input, cursorCodeUnit);
  }

  List<Object?> arrayFor(String name) {
    return arrays.putIfAbsent(name, () => <Object?>[]);
  }

  Map<String, Object?> hashFor(String name) {
    return hashes.putIfAbsent(name, () => <String, Object?>{});
  }

  Map<String, int> marksFor(String ruleLabel) {
    return markBuckets.putIfAbsent(ruleLabel, () => <String, int>{});
  }

  void clearStores() {
    variables.clear();
    arrays.clear();
    hashes.clear();
  }

  void bindUserFunctionParam(String name, Object? value) {
    final copied = _copyValue(value);
    variables[name] = copied;
    if (copied is List) {
      arrays[name] = _asArray(copied);
      hashes.remove(name);
    } else if (copied is Map) {
      hashes[name] = _asHash(copied);
      arrays.remove(name);
    } else {
      arrays.remove(name);
      hashes.remove(name);
    }
  }

  void enterRule(String label) {
    _ruleStack.add(label);
  }

  void exitRule() {
    if (_ruleStack.isNotEmpty) {
      _ruleStack.removeLast();
    }
  }

  void enterRuleLocalBindingScope() {
    _ruleLocalBindingScopes.add(<String, _VariableSnapshot>{});
  }

  void exitRuleLocalBindingScope() {
    if (_ruleLocalBindingScopes.isEmpty) {
      return;
    }
    final scope = _ruleLocalBindingScopes.removeLast();
    for (final entry in scope.entries) {
      entry.value.restore(this, entry.key);
    }
  }

  void recordRuleLocalBinding(String name) {
    if (_ruleLocalBindingSuppressionDepth > 0 ||
        _ruleLocalBindingScopes.isEmpty) {
      return;
    }
    final scope = _ruleLocalBindingScopes.last;
    scope.putIfAbsent(name, () => _VariableSnapshot.capture(this, name));
  }

  void suspendRuleLocalBindingTracking() {
    _ruleLocalBindingSuppressionDepth += 1;
  }

  void resumeRuleLocalBindingTracking() {
    if (_ruleLocalBindingSuppressionDepth > 0) {
      _ruleLocalBindingSuppressionDepth -= 1;
    }
  }

  RuntimeDiagnostic diagnostic({
    required String stage,
    required String summary,
    required String detail,
    String? code,
    String? helperName,
    int? actualArity,
    String? expectedArity,
    String? ruleLabel,
    String? handlerSourceLabel,
  }) {
    final effectiveRule = ruleLabel ?? currentRuleLabel ?? topRule;
    return engine._diagnostic(
      stage: stage,
      summary: summary,
      detail: detail,
      code: code,
      helperName: helperName,
      actualArity: actualArity,
      expectedArity: expectedArity,
      topRule: topRule,
      ruleLabel: effectiveRule,
      handlerSourceLabel: handlerSourceLabel,
    );
  }

  _ScopedVariableBinding enterScopedScalar(String name, Object? value) {
    final binding = _ScopedVariableBinding(
      name: name,
      snapshot: _VariableSnapshot.capture(this, name),
    );
    variables[name] = _copyValue(value);
    arrays.remove(name);
    hashes.remove(name);
    return binding;
  }

  void exitScopedVariable(_ScopedVariableBinding binding) {
    binding.snapshot.restore(this, binding.name);
  }

  void saveCursor() {
    cursorStack.add(cursorCodeUnit);
  }

  void restoreCursor() {
    if (cursorStack.isEmpty) {
      return;
    }
    _setCursorCodeUnit(cursorStack.removeLast());
  }

  void rewindToLocalMatchStart() {
    final target = registers.localMatch?.codeUnitStart;
    if (target == null) {
      return;
    }
    _setCursorCodeUnit(target);
  }

  void rewindToEntryMatchStart() {
    final target = registers.entryMatch?.codeUnitStart;
    if (target == null) {
      return;
    }
    _setCursorCodeUnit(target);
  }

  void _setCursorCodeUnit(int codeUnitCursor) {
    cursorCodeUnit = codeUnitCursor.clamp(0, input.length);
    registers = registers.withCursorCodeUnit(cursorCodeUnit);
  }

  void startCaptureSlice() {
    registers = registers.withCaptureStartCodeUnit(cursorCodeUnit);
  }

  void startCaptureSliceAt(int codeUnitOffset) {
    registers = registers.withCaptureStartCodeUnit(codeUnitOffset);
  }
}

final class _StatementStep {
  const _StatementStep(this.nextIndex);

  final int nextIndex;
}

final class _ValueStatementStep {
  const _ValueStatementStep(this.nextIndex, this.flow);

  final int nextIndex;
  final _ValueBlockFlow flow;
}

final class _MarkerIfSelection {
  const _MarkerIfSelection({
    required this.start,
    required this.end,
    required this.nextIndex,
  });

  final int? start;
  final int? end;
  final int nextIndex;
}

final class _MarkerSwitchSelection {
  const _MarkerSwitchSelection({
    required this.start,
    required this.end,
    required this.nextIndex,
  });

  final int? start;
  final int? end;
  final int nextIndex;
}

final class _ValueBlockFlow {
  const _ValueBlockFlow.continued() : returned = false, value = null;

  const _ValueBlockFlow.returned(this.value) : returned = true;

  final bool returned;
  final Object? value;
}

final class _LocalReturnPayload {
  const _LocalReturnPayload.undef() : hasValue = false, value = null;

  const _LocalReturnPayload.value(this.value) : hasValue = true;

  final bool hasValue;
  final ActionExpr? value;
}

final class _ScopedVariableBinding {
  const _ScopedVariableBinding({required this.name, required this.snapshot});

  final String name;
  final _VariableSnapshot snapshot;
}

final class _VariableSnapshot {
  const _VariableSnapshot({
    required this.hadVariable,
    required this.variable,
    required this.hadArray,
    required this.array,
    required this.hadHash,
    required this.hash,
  });

  factory _VariableSnapshot.capture(
    _RuntimeExecutionContext context,
    String name,
  ) {
    return _VariableSnapshot(
      hadVariable: context.variables.containsKey(name),
      variable: _copyValue(context.variables[name]),
      hadArray: context.arrays.containsKey(name),
      array: [
        for (final item in context.arrays[name] ?? const []) _copyValue(item),
      ],
      hadHash: context.hashes.containsKey(name),
      hash: {
        for (final entry
            in (context.hashes[name] ?? const <String, Object?>{}).entries)
          entry.key: _copyValue(entry.value),
      },
    );
  }

  final bool hadVariable;
  final Object? variable;
  final bool hadArray;
  final List<Object?> array;
  final bool hadHash;
  final Map<String, Object?> hash;

  void restore(_RuntimeExecutionContext context, String name) {
    if (hadVariable) {
      context.variables[name] = _copyValue(variable);
    } else {
      context.variables.remove(name);
    }
    if (hadArray) {
      context.arrays[name] = [for (final item in array) _copyValue(item)];
    } else {
      context.arrays.remove(name);
    }
    if (hadHash) {
      context.hashes[name] = {
        for (final entry in hash.entries) entry.key: _copyValue(entry.value),
      };
    } else {
      context.hashes.remove(name);
    }
  }
}

final class _RuntimeStoreSnapshot {
  const _RuntimeStoreSnapshot({
    required this.variables,
    required this.arrays,
    required this.hashes,
  });

  factory _RuntimeStoreSnapshot.capture(_RuntimeExecutionContext context) {
    return _RuntimeStoreSnapshot(
      variables: {
        for (final entry in context.variables.entries)
          entry.key: _copyValue(entry.value),
      },
      arrays: {
        for (final entry in context.arrays.entries)
          entry.key: [for (final item in entry.value) _copyValue(item)],
      },
      hashes: {
        for (final entry in context.hashes.entries)
          entry.key: {
            for (final hashEntry in entry.value.entries)
              hashEntry.key: _copyValue(hashEntry.value),
          },
      },
    );
  }

  final Map<String, Object?> variables;
  final Map<String, List<Object?>> arrays;
  final Map<String, Map<String, Object?>> hashes;

  void restore(_RuntimeExecutionContext context) {
    context.clearStores();
    context.variables.addAll({
      for (final entry in variables.entries) entry.key: _copyValue(entry.value),
    });
    context.arrays.addAll({
      for (final entry in arrays.entries)
        entry.key: [for (final item in entry.value) _copyValue(item)],
    });
    context.hashes.addAll({
      for (final entry in hashes.entries)
        entry.key: {
          for (final hashEntry in entry.value.entries)
            hashEntry.key: _copyValue(hashEntry.value),
        },
    });
  }
}

final class _NestedWriteRoot {
  const _NestedWriteRoot._(this.name, this.value, this.kind);

  const _NestedWriteRoot.scalar(String name, Object? value)
    : this._(name, value, _NestedWriteRootKind.scalar);

  const _NestedWriteRoot.array(String name, Object? value)
    : this._(name, value, _NestedWriteRootKind.array);

  const _NestedWriteRoot.hash(String name, Object? value)
    : this._(name, value, _NestedWriteRootKind.hash);

  final String name;
  final Object? value;
  final _NestedWriteRootKind kind;

  void store(_RuntimeExecutionContext context, Object? value) {
    switch (kind) {
      case _NestedWriteRootKind.scalar:
        context.variables[name] = _copyValue(value);
      case _NestedWriteRootKind.array:
        context.arrays[name] = _asArray(value);
      case _NestedWriteRootKind.hash:
        context.hashes[name] = _asHash(value);
    }
  }
}

enum _NestedWriteRootKind { scalar, array, hash }

final class _EvaluatedAccessSegment {
  const _EvaluatedAccessSegment.key(this.key)
    : kind = _EvaluatedAccessSegmentKind.key,
      index = null;

  const _EvaluatedAccessSegment.index(this.index)
    : kind = _EvaluatedAccessSegmentKind.arrayIndex,
      key = null;

  final _EvaluatedAccessSegmentKind kind;
  final String? key;
  final int? index;
}

enum _EvaluatedAccessSegmentKind { key, arrayIndex }

final class _RegexPlan {
  const _RegexPlan({required this.patterns});

  final List<String> patterns;
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

final class _ActionNext implements Exception {
  const _ActionNext();
}

final class _NextableBool {
  const _NextableBool.value(this.value) : nexted = false;

  const _NextableBool.nexted() : value = false, nexted = true;

  final bool value;
  final bool nexted;
}

_NextableBool _nextableBool(bool Function() callback) {
  try {
    return _NextableBool.value(callback());
  } on _ActionNext {
    return const _NextableBool.nexted();
  }
}

_RuleResult _returned(Object? value) {
  return _RuleResult(matched: value != null, value: _copyValue(value));
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

String? _scalarTargetName(ActionExpr expr) {
  final variable = _variableName(expr);
  if (variable != null) {
    return variable;
  }
  if (expr is! ActionCallExpr ||
      expr.name != 'scalar' ||
      expr.args.length != 1) {
    return null;
  }
  return _variableName(expr.args.single.value);
}

bool _hasArrayValue(_RuntimeExecutionContext context, String name) {
  return context.arrays.containsKey(name) || context.variables[name] is List;
}

bool _hasHashValue(_RuntimeExecutionContext context, String name) {
  return context.hashes.containsKey(name) || context.variables[name] is Map;
}

String? _variableName(ActionExpr expr) {
  return switch (expr) {
    ActionVariableExpr(:final name) => name,
    _ => null,
  };
}

int? _literalNonNegativeInteger(ActionExpr expr) {
  if (expr is! ActionNumberLiteralExpr) {
    return null;
  }
  final value = expr.value;
  if (value < 0 || value != value.truncateToDouble()) {
    return null;
  }
  return value.toInt();
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
  final variable = context.variables[name];
  if (variable is List) {
    return [for (final item in variable) _copyValue(item)];
  }
  final stored = context.arrays[name];
  if (stored != null) {
    return [for (final item in stored) _copyValue(item)];
  }
  return <Object?>[];
}

Object? _bindingValueFor(_RuntimeExecutionContext context, String name) {
  if (context.variables.containsKey(name)) {
    return _copyValue(context.variables[name]);
  }
  if (context.arrays.containsKey(name)) {
    return List<Object?>.unmodifiable(_arrayValueFor(context, name));
  }
  if (context.hashes.containsKey(name)) {
    return Map<String, Object?>.unmodifiable(_hashValueFor(context, name));
  }
  if (context.engine.compiledSpec.rule(name) != null) {
    return const <Object?>[];
  }
  return null;
}

Never _bindingKindMismatch(String name, String expectedKind, Object? actual) {
  final actualKind = switch (actual) {
    List() => 'array',
    Map() => 'harray',
    _ => 'scalar',
  };
  throw RuntimeInterpreterException(
    'binding_kind_mismatch identifier=$name '
    'expected_kind=$expectedKind actual_kind=$actualKind',
  );
}

List<Object?> _bareArrayForMutation(
  _RuntimeExecutionContext context,
  String name,
) {
  if (context.variables.containsKey(name)) {
    final value = context.variables[name];
    if (value is List) {
      return _asArray(value);
    }
    _bindingKindMismatch(name, 'array', value);
  }
  if (context.arrays.containsKey(name)) {
    return _arrayValueFor(context, name);
  }
  if (context.hashes.containsKey(name)) {
    _bindingKindMismatch(name, 'array', context.hashes[name]);
  }
  return <Object?>[];
}

List<Object?> _storeBareArray(
  _RuntimeExecutionContext context,
  String name,
  List<Object?> values,
) {
  final updated = [for (final item in values) _copyValue(item)];
  if (context.arrays.containsKey(name) &&
      !context.variables.containsKey(name)) {
    context.arrays[name] = updated;
    context.hashes.remove(name);
  } else {
    context.variables[name] = updated;
    context.arrays.remove(name);
    context.hashes.remove(name);
  }
  return List<Object?>.unmodifiable([
    for (final item in updated) _copyValue(item),
  ]);
}

List<Object?> _appendArrayValue(
  _RuntimeExecutionContext context,
  String name,
  Object? value,
) {
  final stored = _copyValue(value);
  final updated = _bareArrayForMutation(context, name)..add(stored);
  return _storeBareArray(context, name, updated);
}

List<Object?> _replaceBareArrayValue(
  _RuntimeExecutionContext context,
  String name,
  List<Object?> values,
) {
  _bareArrayForMutation(context, name);
  return _storeBareArray(context, name, values);
}

Map<String, Object?> _hashValueFor(
  _RuntimeExecutionContext context,
  String name,
) {
  final variable = context.variables[name];
  if (variable is Map) {
    return _asHash(variable);
  }
  final stored = context.hashes[name];
  if (stored != null) {
    return {
      for (final entry in stored.entries) entry.key: _copyValue(entry.value),
    };
  }
  return <String, Object?>{};
}

Map<String, Object?> _bareHashForMutation(
  _RuntimeExecutionContext context,
  String name,
) {
  if (context.variables.containsKey(name)) {
    final value = context.variables[name];
    if (value is Map) {
      return _asHash(value);
    }
    _bindingKindMismatch(name, 'harray', value);
  }
  if (context.hashes.containsKey(name)) {
    return _hashValueFor(context, name);
  }
  if (context.arrays.containsKey(name)) {
    _bindingKindMismatch(name, 'harray', context.arrays[name]);
  }
  return <String, Object?>{};
}

Map<String, Object?> _storeBareHash(
  _RuntimeExecutionContext context,
  String name,
  Map<String, Object?> values,
) {
  final updated = _asHash(values);
  if (context.hashes.containsKey(name) &&
      !context.variables.containsKey(name)) {
    context.hashes[name] = updated;
    context.arrays.remove(name);
  } else {
    context.variables[name] = updated;
    context.arrays.remove(name);
    context.hashes.remove(name);
  }
  return Map<String, Object?>.unmodifiable(_asHash(updated));
}

Map<String, Object?> _setBareHashEntry(
  _RuntimeExecutionContext context,
  String name,
  String key,
  Object? value,
) {
  final updated = _bareHashForMutation(context, name);
  updated[key] = _copyValue(value);
  return _storeBareHash(context, name, updated);
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

Object? _assignHashIndex(
  _RuntimeExecutionContext context,
  String name,
  ActionExpr key,
  ActionExpr value,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (context.variables.containsKey(name)) {
    final root = context.variables[name];
    if (root is Map) {
      final storedKey = _stringValue(
        context.engine._evaluateExpression(
          key,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      );
      final storedValue = _copyValue(
        context.engine._evaluateExpression(
          value,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      );
      return _setBareHashEntry(context, name, storedKey, storedValue);
    }
    if (root is List) {
      if (key is ActionStringLiteralExpr) {
        return null;
      }
      final list = _asArray(root);
      final indexValue = context.engine._evaluateExpression(
        key,
        context,
        ruleLabel,
        currentEdge: currentEdge,
      );
      final index = _arrayIndex(indexValue);
      if (index == null || index > list.length) {
        return null;
      }
      final storedValue = _copyValue(
        context.engine._evaluateExpression(
          value,
          context,
          ruleLabel,
          currentEdge: currentEdge,
        ),
      );
      if (index == list.length) {
        list.add(storedValue);
      } else {
        list[index] = storedValue;
      }
      context.variables[name] = list;
      return _copyValue(list);
    }
    _bindingKindMismatch(name, 'harray', root);
  }

  final storedKey = _stringValue(
    context.engine._evaluateExpression(
      key,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    ),
  );
  final storedValue = _copyValue(
    context.engine._evaluateExpression(
      value,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    ),
  );
  return _setBareHashEntry(context, name, storedKey, storedValue);
}

_NestedWriteRoot? _rootStorageForWrite(
  _RuntimeExecutionContext context,
  String base,
) {
  if (context.variables.containsKey(base)) {
    return _NestedWriteRoot.scalar(base, context.variables[base]);
  }
  if (context.arrays.containsKey(base)) {
    return _NestedWriteRoot.array(base, context.arrays[base]);
  }
  if (context.hashes.containsKey(base)) {
    return _NestedWriteRoot.hash(base, context.hashes[base]);
  }
  return null;
}

Object? _writeNested(
  _RuntimeExecutionContext context,
  String base,
  List<ActionAccessSegment> segments,
  ActionExpr value,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final evaluatedSegments = _evaluateAccessSegments(
    segments,
    context,
    ruleLabel,
    currentEdge,
  );
  final storedValue = _copyValue(
    context.engine._evaluateExpression(
      value,
      context,
      ruleLabel,
      currentEdge: currentEdge,
    ),
  );
  final rootStorage = _rootStorageForWrite(context, base);
  if (rootStorage == null || evaluatedSegments.isEmpty) {
    return null;
  }
  final root = _copyValue(rootStorage.value);
  if (root is! Map && root is! List) {
    return null;
  }
  final updated = _assignNestedValue(root, evaluatedSegments, storedValue);
  if (!updated) {
    return null;
  }
  rootStorage.store(context, root);
  return _copyValue(root);
}

bool _assignNestedValue(
  Object? root,
  List<_EvaluatedAccessSegment> segments,
  Object? value,
) {
  var node = root;
  for (var index = 0; index < segments.length; index += 1) {
    final isLast = index == segments.length - 1;
    final segment = segments[index];
    switch (segment.kind) {
      case _EvaluatedAccessSegmentKind.key:
        final key = segment.key;
        if (key == null) {
          return false;
        }
        if (node is! Map<String, Object?>) {
          return false;
        }
        if (isLast) {
          node[key] = _copyValue(value);
        } else {
          final child = node[key];
          if (child == null) {
            return false;
          }
          node = child;
        }
      case _EvaluatedAccessSegmentKind.arrayIndex:
        final listIndex = segment.index;
        if (node is! List<Object?> || listIndex == null) {
          return false;
        }
        if (isLast) {
          if (listIndex > node.length) {
            return false;
          }
          if (listIndex == node.length) {
            node.add(_copyValue(value));
          } else {
            node[listIndex] = _copyValue(value);
          }
        } else {
          if (listIndex >= node.length) {
            return false;
          }
          final child = node[listIndex];
          if (child == null) {
            return false;
          }
          node = child;
        }
    }
  }
  return true;
}

List<_EvaluatedAccessSegment> _evaluateAccessSegments(
  List<ActionAccessSegment> segments,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  return [
    for (final segment in segments)
      switch (segment) {
        ActionKeyAccessSegment(value: final key) => _EvaluatedAccessSegment.key(
          key,
        ),
        ActionIndexAccessSegment(:final expr) => _EvaluatedAccessSegment.index(
          _arrayIndex(
            context.engine._evaluateExpression(
              expr,
              context,
              ruleLabel,
              currentEdge: currentEdge,
            ),
          ),
        ),
      },
  ];
}

int? _arrayIndex(Object? value) {
  final index = value is num ? value.toInt() : int.tryParse('$value');
  return index != null && index >= 0 ? index : null;
}

Object? _copyArgument(
  ActionExpr expr,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  final name = _variableName(expr);
  if (name != null) {
    if (context.variables[name] is List) {
      return _arrayValueFor(context, name);
    }
    if (context.variables[name] is Map) {
      return _hashValueFor(context, name);
    }
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

int _hasNamedCapture(
  RuntimeRegexMatch? match,
  List<ActionExpr> args,
  _RuntimeExecutionContext context,
  String ruleLabel,
  _CurrentActionEdge? currentEdge,
) {
  if (match == null || args.isEmpty) {
    return 0;
  }
  final name = _captureName(args.first, context, ruleLabel, currentEdge);
  return match.named.containsKey(name) ? 1 : 0;
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

/// Apply LinkedSpec's typed logical truth policy without invoking [value].
bool runtimeLogicalTruth(Object? value) {
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
