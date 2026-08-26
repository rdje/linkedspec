import '../action/action_ast.dart';
import '../action/callable_contract.dart';
import '../action/action_contracts.dart';
import '../action/action_parser.dart';
import '../action/function_registry.dart';
import '../ast/spec_ast.dart';
import '../trace/trace.dart';
import '../validation/spec_validator.dart';

const linkedSpecRootRuleSelectionContract = 'linkedspec-root-rule-selection-v1';
const linkedSpecRegexSlotIdentityContract =
    'linkedspec-duplicate-regex-slot-identity-v1';

/// Stable structural identity for one compiled regex slot.
final class CompiledRegexSlotIdentity {
  const CompiledRegexSlotIdentity({
    required this.targetRule,
    required this.regexIndex,
  });

  final String targetRule;
  final int regexIndex;

  String get wireName => '$targetRule#$regexIndex';

  JsonObject toJson() => {'target_rule': targetRule, 'regex_index': regexIndex};
}

/// Stable ordered-execution invariant failure for a mismatched regex slot.
final class OrderedRegexSlotIdentityException implements Exception {
  const OrderedRegexSlotIdentityException({
    required this.ruleLabel,
    required this.targetRule,
    required this.expectedRegexIndex,
    required this.actualRegexIndex,
  });

  final String ruleLabel;
  final String targetRule;
  final int expectedRegexIndex;
  final int actualRegexIndex;

  SpecPortableDiagnostic get diagnostic => SpecPortableDiagnostic(
    code: 'ordered_regex_slot_identity_lost',
    stage: 'execute_rule',
    message: toString(),
    fields: {
      'rule_label': ruleLabel,
      'target_rule': targetRule,
      'expected_regex_index': expectedRegexIndex,
      'actual_regex_index': actualRegexIndex,
    },
  );

  @override
  String toString() {
    return 'ordered_regex_slot_identity_lost stage=execute_rule '
        'rule_label=$ruleLabel target_rule=$targetRule '
        'expected_regex_index=$expectedRegexIndex '
        'actual_regex_index=$actualRegexIndex';
  }
}

/// Assert that an ordered matcher returned its required structural slot.
void assertOrderedRegexSlotIdentity({
  required String ruleLabel,
  required String expectedTargetRule,
  required int expectedRegexIndex,
  required String actualTargetRule,
  required int actualRegexIndex,
}) {
  if (expectedTargetRule == actualTargetRule &&
      expectedRegexIndex == actualRegexIndex) {
    return;
  }
  throw OrderedRegexSlotIdentityException(
    ruleLabel: ruleLabel,
    targetRule: expectedTargetRule,
    expectedRegexIndex: expectedRegexIndex,
    actualRegexIndex: actualRegexIndex,
  );
}

final class CompiledSpecException implements Exception {
  const CompiledSpecException(this.message);

  final String message;

  @override
  String toString() => 'CompiledSpecException: $message';
}

enum EntryRuleSelectionBasis {
  explicitSelector('explicit_selector'),
  firstAuthoredMarker('first_authored_marker'),
  firstAuthoredRule('first_authored_rule');

  const EntryRuleSelectionBasis(this.contractName);

  final String contractName;
}

final class ResolvedEntryRule {
  const ResolvedEntryRule({required this.rule, required this.basis});

  final CompiledRule rule;
  final EntryRuleSelectionBasis basis;
}

final class EntryRuleSelectionException implements Exception {
  const EntryRuleSelectionException._({
    required this.code,
    required this.stage,
    required this.message,
    this.entryRule,
  });

  const EntryRuleSelectionException.noRules()
    : this._(
        code: 'no_rules_defined',
        stage: 'validate_spec',
        message: 'compiled spec does not contain any rules',
      );

  EntryRuleSelectionException.unknownRule(String entryRule)
    : this._(
        code: 'entry_rule_not_found',
        stage: 'select_entry_rule',
        message: "entry rule '$entryRule' is not defined",
        entryRule: entryRule,
      );

  final String code;
  final String stage;
  final String message;
  final String? entryRule;

  JsonObject toJson() {
    return {
      'code': code,
      'stage': stage,
      'message': message,
      'fields': {if (entryRule != null) 'entry_rule': entryRule},
    };
  }

  @override
  String toString() => 'EntryRuleSelectionException: $message';
}

CompiledSpec compileSpec(
  SpecFile spec, {
  bool validateSource = true,
  bool strictSyntax = false,
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_compiler:compile_spec',
    'rules=${spec.rules.length} functions=${spec.functions.length} '
        'validate=${validateSource ? 1 : 0} strict=${strictSyntax ? 1 : 0}',
    LinkedSpecTraceLevel.high,
  );
  try {
    if (validateSource) {
      validateSpec(spec, strictSyntax: strictSyntax, trace: trace);
    } else {
      trace?.traceDecision(
        'dart_compiler:compile_spec:validation',
        false,
        'validate_source=0',
        LinkedSpecTraceLevel.medium,
      );
    }

    final declaredFunctionRegistry = UserFunctionRegistry.fromSpec(spec);
    final List<FunctionDefinition> normalizedFunctions;
    try {
      normalizedFunctions = [
        for (final function in spec.functions)
          normalizeFunctionFinalCodeblocks(function, declaredFunctionRegistry),
      ];
    } on CallableContractException catch (error) {
      throw CompiledSpecException(error.message);
    }
    final functionRegistry = UserFunctionRegistry.fromFunctions(
      normalizedFunctions,
      trace: trace,
    );
    final definitionOrder = <String>[];
    final rulesByLabel = <String, CompiledRule>{};
    final sourceRulesByLabel = <String, Rule>{
      for (final rule in spec.rules) rule.header.label: rule,
    };
    final redefinedRuleLabels = <String>[];
    final redefinedSeen = <String>{};

    for (final rule in spec.rules) {
      final label = rule.header.label;
      definitionOrder.add(label);
      if (rulesByLabel.containsKey(label) && redefinedSeen.add(label)) {
        redefinedRuleLabels.add(label);
      }
      rulesByLabel[label] = _compileRule(
        rule,
        functionRegistry,
        sourceId: spec.sourceId,
        sourceRulesByLabel: sourceRulesByLabel,
      );
      trace?.traceDecision(
        'dart_compiler:compile_spec:rule',
        true,
        'label=$label definition_index=${definitionOrder.length - 1}',
        LinkedSpecTraceLevel.medium,
      );
    }

    final compiledRuleOrder = _lastDefinitionOrder(definitionOrder);
    final resolvedRulesByLabel = _resolveActionEdgeDependencyRegexes(
      compiledRuleOrder: compiledRuleOrder,
      rulesByLabel: rulesByLabel,
    );
    final dependencyRegexState = _buildDependencyRegexState(
      compiledRuleOrder: compiledRuleOrder,
      rulesByLabel: resolvedRulesByLabel,
    );
    trace?.traceDecision(
      'dart_compiler:compile_spec:dependency_regex',
      true,
      'rule_count=${compiledRuleOrder.length}',
      LinkedSpecTraceLevel.medium,
    );

    final compiled = CompiledSpec(
      definitionOrder: List.unmodifiable(definitionOrder),
      compiledRuleOrder: List.unmodifiable(compiledRuleOrder),
      rulesByLabel: Map.unmodifiable(resolvedRulesByLabel),
      redefinedRuleLabels: List.unmodifiable(redefinedRuleLabels),
      functionRegistry: functionRegistry,
      dependencyRegexState: dependencyRegexState,
    );
    validateCompiledRegexSlotIdentities(compiled);
    validateNoRemovedAggregateSelectors(compiled);
    validateProgressiveSpanDispatchContract(compiled);
    validateStagedParseJobContract(compiled);
    _validateRecursiveObservationPolicy(compiled);
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok rules=${compiledRuleOrder.length} '
        'functions=${functionRegistry.entries.length}',
      );
    }
    return compiled;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

final class CompiledSpec {
  const CompiledSpec({
    required this.definitionOrder,
    required this.compiledRuleOrder,
    required this.rulesByLabel,
    required this.redefinedRuleLabels,
    required this.functionRegistry,
    required this.dependencyRegexState,
  });

  final List<String> definitionOrder;
  final List<String> compiledRuleOrder;
  final Map<String, CompiledRule> rulesByLabel;
  final List<String> redefinedRuleLabels;
  final UserFunctionRegistry functionRegistry;
  final CompiledDependencyRegexState dependencyRegexState;

  Iterable<UserFunctionEntry> get functions => functionRegistry.entries;

  CompiledRule? rule(String label) => rulesByLabel[label];

  ResolvedEntryRule resolveEntryRule(String? explicitSelector) {
    if (compiledRuleOrder.isEmpty) {
      throw const EntryRuleSelectionException.noRules();
    }

    if (explicitSelector != null) {
      final selected = rulesByLabel[explicitSelector];
      if (selected == null) {
        throw EntryRuleSelectionException.unknownRule(explicitSelector);
      }
      return ResolvedEntryRule(
        rule: selected,
        basis: EntryRuleSelectionBasis.explicitSelector,
      );
    }

    for (final label in compiledRuleOrder) {
      final candidate = _orderedRule(label);
      if (candidate.header.isTop) {
        return ResolvedEntryRule(
          rule: candidate,
          basis: EntryRuleSelectionBasis.firstAuthoredMarker,
        );
      }
    }
    return ResolvedEntryRule(
      rule: _orderedRule(compiledRuleOrder.first),
      basis: EntryRuleSelectionBasis.firstAuthoredRule,
    );
  }

  CompiledRule _orderedRule(String label) {
    final rule = rulesByLabel[label];
    if (rule == null) {
      throw CompiledSpecException(
        "compiled rule order refers to missing rule '$label'",
      );
    }
    return rule;
  }

  CompiledDescriptorState get descriptorState {
    validateCompiledRegexSlotIdentities(this);
    return CompiledDescriptorState(
      compiledSpecState: this,
      dependencyRegexState: dependencyRegexState,
    );
  }

  JsonObject toJson() {
    return {
      'kind': 'compiled_spec_state',
      'definition_order': definitionOrder,
      'compiled_rule_order': compiledRuleOrder,
      'rules_by_label': {
        for (final label in compiledRuleOrder)
          label: rulesByLabel[label]!.toJson(),
      },
      'redefined_rule_labels': redefinedRuleLabels,
      'function_order': [for (final function in functions) function.name],
      'functions_by_name': {
        for (final function in functions) function.name: function.toJson(),
      },
    };
  }

  JsonObject toDescriptorJson() => descriptorState.toJson();
}

/// Validate every action edge's typed target-rule plus regex-index identity.
///
/// This boundary is intentionally public: generated-source adapters and
/// runtimes must reject caller-constructed malformed compiled state before
/// matching it.
void validateCompiledRegexSlotIdentities(CompiledSpec compiled) {
  for (final label in compiled.compiledRuleOrder) {
    final rule = compiled.rulesByLabel[label];
    if (rule == null) {
      continue;
    }
    for (final edge in rule.actionEdges) {
      if (edge.targets.length != 1) {
        continue;
      }
      final target = edge.targets.single;
      final targetRule = compiled.rulesByLabel[target.label];
      final targetRegexCount = targetRule == null
          ? 0
          : _authoredRegexCount(targetRule);
      final identityIndex = edge.childRegexIndex;
      final identityIsValid =
          targetRule != null &&
          identityIndex >= 0 &&
          identityIndex < targetRegexCount &&
          target.index == identityIndex &&
          edge.regexIndex >= 0 &&
          edge.regexIndex < rule.regexPatterns.length;
      if (identityIsValid) {
        continue;
      }
      final message =
          "rule '$label' references rule '${target.label}' regex slot "
          '$identityIndex, but that structural slot does not exist';
      throw SpecValidationException(
        message,
        diagnostic: SpecPortableDiagnostic(
          code: 'regex_slot_identity_invalid',
          stage: 'validate_compiled_rule',
          message: message,
          fields: {
            'rule_label': label,
            'target_rule': target.label,
            'regex_index': identityIndex,
          },
        ),
      );
    }
  }
}

/// Return the authored structural identities selected by one compiled slot.
List<CompiledRegexSlotIdentity> compiledRegexSlotIdentitiesFor(
  CompiledRule rule,
  int regexIndex,
) {
  final identities = [
    for (final edge in rule.actionEdges)
      if (edge.regexIndex == regexIndex && edge.targets.length == 1)
        CompiledRegexSlotIdentity(
          targetRule: edge.targets.single.label,
          regexIndex: edge.childRegexIndex,
        ),
  ];
  if (identities.isNotEmpty) {
    return List.unmodifiable(identities);
  }
  return List.unmodifiable([
    CompiledRegexSlotIdentity(targetRule: rule.label, regexIndex: regexIndex),
  ]);
}

int _authoredRegexCount(CompiledRule rule) {
  return rule.bodyElements
      .where((element) => element.kind is RegexBodyElementKind)
      .length;
}

/// Reject removed public aggregate selectors in every executable part of a
/// compiled specification.
///
/// Generated-source adapters call this public boundary as well so they do not
/// trust a caller-constructed [CompiledSpec].
void validateNoRemovedAggregateSelectors(CompiledSpec compiled) {
  void validateBlock(ActionBlock block, String context) {
    final selector = findRemovedAggregateSelectorInBlock(block);
    if (selector != null) {
      throw CompiledSpecException('$context: ${selector.diagnostic}');
    }
  }

  void validateFluentCalls(List<FluentCall> calls, String context) {
    for (final (index, call) in calls.indexed) {
      final args = call.args.trim();
      final source = args.isEmpty
          ? '${call.method}()'
          : '${call.method}($args)';
      try {
        final block = parseActionBlock(source);
        normalizeActionBlockFinalCodeblocks(block, compiled.functionRegistry);
        validateBlock(block, '$context fluent call $index');
      } on CompiledSpecException {
        rethrow;
      } on CallableContractException catch (error) {
        throw CompiledSpecException(error.message);
      } on Object {
        // Fluent syntax historically remains runtime-parsed. Do not turn an
        // unrelated deferred parse failure into a new compile-time change.
      }
    }
  }

  for (final function in compiled.functions) {
    try {
      final block = parseActionBlock(function.bodySource);
      normalizeActionBlockFinalCodeblocks(block, compiled.functionRegistry);
      validateBlock(block, "function '${function.name}' body");
    } on CompiledSpecException {
      rethrow;
    } on CallableContractException catch (error) {
      throw CompiledSpecException(error.message);
    } on Object {
      // Preserve the existing runtime timing for unrelated function-body parse
      // failures while still rejecting structurally valid removed selectors.
    }
  }

  for (final label in compiled.compiledRuleOrder) {
    final rule = compiled.rulesByLabel[label]!;
    for (final payload in rule.actionPayloads) {
      validateBlock(
        payload.actionAst,
        "rule '$label' ${payload.role} line ${payload.line}",
      );
    }
    for (final (index, edge) in rule.actionEdges.indexed) {
      validateFluentCalls(edge.fluentChain, "rule '$label' action edge $index");
    }
    for (final (index, edge) in rule.blindEdges.indexed) {
      validateFluentCalls(edge.fluentChain, "rule '$label' blind edge $index");
    }
  }
}

/// Reject every generic spelling that escaped the exclusive assignment parser.
void validateProgressiveSpanDispatchContract(CompiledSpec compiled) {
  void validate(Object? value) {
    if (value is List) {
      for (final child in value) {
        validate(child);
      }
      return;
    }
    if (value is! Map) {
      return;
    }
    final object = value.cast<String, Object?>();
    if (object['kind'] == 'call' && object['name'] == 'dispatch_span') {
      throw const CompiledSpecException(
        'LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:'
        'progressive_span_binding_required',
      );
    }
    for (final child in object.values) {
      validate(child);
    }
  }

  for (final label in compiled.compiledRuleOrder) {
    final rule = compiled.rulesByLabel[label]!;
    for (final payload in rule.actionPayloads) {
      validate(payload.actionAst.toJson());
    }
  }
  for (final function in compiled.functions) {
    validate(parseActionBlock(function.bodySource).toJson());
  }
}

/// Reject every generic `parse_job` spelling that escaped the exclusive scalar
/// assignment parser. A staged declaration can only exist as its dedicated,
/// typed ActionIR node.
void validateStagedParseJobContract(CompiledSpec compiled) {
  void validate(Object? value) {
    if (value is List) {
      for (final child in value) {
        validate(child);
      }
      return;
    }
    if (value is! Map) {
      return;
    }
    final object = value.cast<String, Object?>();
    if (object['kind'] == 'call' && object['name'] == 'parse_job') {
      throw const CompiledSpecException(
        'LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:'
        'staged_parse_job_options_required',
      );
    }
    for (final child in object.values) {
      validate(child);
    }
  }

  for (final label in compiled.compiledRuleOrder) {
    final rule = compiled.rulesByLabel[label]!;
    for (final payload in rule.actionPayloads) {
      validate(payload.actionAst.toJson());
    }
  }
  for (final function in compiled.functions) {
    validate(parseActionBlock(function.bodySource).toJson());
  }
}

final class _RecursiveObservationEffects {
  bool writesObservation = false;
  bool usesParserOrStagedDispatch = false;
  final Set<String> ruleCalls = <String>{};
  final Set<String> functionCalls = <String>{};
  final Set<String> recognitionAttempts = <String>{};
  final Set<String> observedRules = <String>{};
}

/// Validates static recursive-observation ownership and closes its binding
/// effect through ordinary rule and user-function calls.
///
/// This is intentionally part of compilation rather than runtime dispatch:
/// `call(Rule)` inside an observation is structural, and a `recognize_once`
/// target that can reach the observation's two binding writes is forbidden.
void _validateRecursiveObservationPolicy(CompiledSpec compiled) {
  final functionNames = <String>{
    for (final function in compiled.functions) function.name,
  };

  _RecursiveObservationEffects scan(Object? value) {
    final effects = _RecursiveObservationEffects();

    void visit(Object? node) {
      if (node is List) {
        for (final child in node) {
          visit(child);
        }
        return;
      }
      if (node is! Map) {
        return;
      }
      final object = node.cast<String, Object?>();
      final kind = object['kind'];
      if (kind == 'observe_recognition') {
        effects.writesObservation = true;
        final rule = object['rule'];
        if (rule is String) {
          effects.observedRules.add(rule);
        }
      } else if (kind == 'progressive_dispatch_span' ||
          kind == 'staged_parse_job_marker') {
        effects.usesParserOrStagedDispatch = true;
      } else if (kind == 'recognize_once') {
        final rule = object['rule'];
        if (rule is String) {
          effects.recognitionAttempts.add(rule);
        }
      } else if (kind == 'call') {
        final name = object['name'];
        if (name == 'call') {
          final args = object['args'];
          if (args is List && args.length == 1 && args.single is Map) {
            final argument = (args.single as Map).cast<String, Object?>();
            if (argument['kind'] == 'variable' && argument['name'] is String) {
              effects.ruleCalls.add(argument['name']! as String);
            }
          }
        } else if (name is String && functionNames.contains(name)) {
          effects.functionCalls.add(name);
        }
      }
      for (final child in object.values) {
        visit(child);
      }
    }

    visit(value);
    return effects;
  }

  final ruleEffects = <String, _RecursiveObservationEffects>{};
  for (final label in compiled.compiledRuleOrder) {
    final rule = compiled.rulesByLabel[label]!;
    ruleEffects[label] = scan(<Object?>[
      for (final payload in rule.actionPayloads) payload.actionAst.toJson(),
    ]);
  }

  final functionEffects = <String, _RecursiveObservationEffects>{};
  for (final function in compiled.functions) {
    final block = parseActionBlock(function.bodySource);
    final current = functionEffects.putIfAbsent(
      function.name,
      _RecursiveObservationEffects.new,
    );
    final discovered = scan(block.toJson());
    current
      ..writesObservation =
          current.writesObservation || discovered.writesObservation
      ..usesParserOrStagedDispatch =
          current.usesParserOrStagedDispatch ||
          discovered.usesParserOrStagedDispatch
      ..ruleCalls.addAll(discovered.ruleCalls)
      ..functionCalls.addAll(discovered.functionCalls)
      ..recognitionAttempts.addAll(discovered.recognitionAttempts)
      ..observedRules.addAll(discovered.observedRules);
  }

  for (final entry in <MapEntry<String, _RecursiveObservationEffects>>[
    ...ruleEffects.entries,
    ...functionEffects.entries,
  ]) {
    for (final observedRule in entry.value.observedRules) {
      if (!compiled.rulesByLabel.containsKey(observedRule)) {
        throw CompiledSpecException(
          'source_location_recursive_observation_operand '
          "missing static rule '$observedRule'",
        );
      }
    }
  }

  final ruleWrites = <String, bool>{
    for (final entry in ruleEffects.entries)
      entry.key: entry.value.writesObservation,
  };
  final functionWrites = <String, bool>{
    for (final entry in functionEffects.entries)
      entry.key: entry.value.writesObservation,
  };
  final ruleDispatches = <String, bool>{
    for (final entry in ruleEffects.entries)
      entry.key: entry.value.usesParserOrStagedDispatch,
  };
  final functionDispatches = <String, bool>{
    for (final entry in functionEffects.entries)
      entry.key: entry.value.usesParserOrStagedDispatch,
  };
  var changed = true;
  while (changed) {
    changed = false;
    for (final entry in ruleEffects.entries) {
      final inherited =
          entry.value.ruleCalls.any((callee) => ruleWrites[callee] ?? false) ||
          entry.value.functionCalls.any(
            (callee) => functionWrites[callee] ?? false,
          );
      if (inherited && !(ruleWrites[entry.key] ?? false)) {
        ruleWrites[entry.key] = true;
        changed = true;
      }
      final inheritedDispatch =
          entry.value.ruleCalls.any(
            (callee) => ruleDispatches[callee] ?? false,
          ) ||
          entry.value.functionCalls.any(
            (callee) => functionDispatches[callee] ?? false,
          );
      if (inheritedDispatch && !(ruleDispatches[entry.key] ?? false)) {
        ruleDispatches[entry.key] = true;
        changed = true;
      }
    }
    for (final entry in functionEffects.entries) {
      final inherited =
          entry.value.ruleCalls.any((callee) => ruleWrites[callee] ?? false) ||
          entry.value.functionCalls.any(
            (callee) => functionWrites[callee] ?? false,
          );
      if (inherited && !(functionWrites[entry.key] ?? false)) {
        functionWrites[entry.key] = true;
        changed = true;
      }
      final inheritedDispatch =
          entry.value.ruleCalls.any(
            (callee) => ruleDispatches[callee] ?? false,
          ) ||
          entry.value.functionCalls.any(
            (callee) => functionDispatches[callee] ?? false,
          );
      if (inheritedDispatch && !(functionDispatches[entry.key] ?? false)) {
        functionDispatches[entry.key] = true;
        changed = true;
      }
    }
  }

  for (final entry in <MapEntry<String, _RecursiveObservationEffects>>[
    ...ruleEffects.entries,
    ...functionEffects.entries,
  ]) {
    for (final target in entry.value.recognitionAttempts) {
      if (ruleDispatches[target] ?? false) {
        throw CompiledSpecException(
          'recognition_effect_forbidden:parser_registry_or_staged_dispatch '
          'owner=${entry.key} target=$target',
        );
      }
      if (ruleWrites[target] ?? false) {
        throw CompiledSpecException(
          'recognition_effect_forbidden:binding_write '
          'owner=${entry.key} target=$target',
        );
      }
    }
  }
}

final class CompiledRegexSlotMetadata {
  const CompiledRegexSlotMetadata({
    required this.regexIndex,
    required this.slotId,
    required this.sourceId,
    required this.line,
  });

  final int regexIndex;
  final String? slotId;
  final String sourceId;
  final int line;

  JsonObject toJson() => {
    'regex_index': regexIndex,
    'slot_id': slotId,
    'source_id': sourceId,
    'line': line,
  };
}

final class CompiledCaptureGapsMetadata {
  const CompiledCaptureGapsMetadata({
    required this.directive,
    required this.sourceId,
    required this.line,
  });

  final String directive;
  final String sourceId;
  final int line;

  JsonObject toJson() => {
    'enabled': true,
    'directive': directive,
    'source_id': sourceId,
    'line': line,
  };
}

final class CompiledRule {
  const CompiledRule({
    required this.label,
    required this.header,
    required this.modeMetadata,
    required this.regexPatterns,
    this.regexSlots = const [],
    this.captureGaps,
    required this.dependencyRefs,
    required this.actionEdges,
    required this.blindEdges,
    required this.lifecycleActionPayloads,
    required this.plainActionPayloads,
    required this.bodyElements,
  });

  final String label;
  final RuleHeader header;
  final CompiledRuleModeMetadata modeMetadata;
  final List<String> regexPatterns;
  final List<CompiledRegexSlotMetadata> regexSlots;
  final CompiledCaptureGapsMetadata? captureGaps;
  final List<DependencyRef> dependencyRefs;
  final List<CompiledActionEdge> actionEdges;
  final List<CompiledBlindEdge> blindEdges;
  final List<CompiledActionPayload> lifecycleActionPayloads;
  final List<CompiledActionPayload> plainActionPayloads;
  final List<BodyElement> bodyElements;

  CompiledRule copyWith({
    List<String>? regexPatterns,
    List<CompiledActionEdge>? actionEdges,
  }) {
    return CompiledRule(
      label: label,
      header: header,
      modeMetadata: modeMetadata,
      regexPatterns: regexPatterns ?? this.regexPatterns,
      regexSlots: regexSlots,
      captureGaps: captureGaps,
      dependencyRefs: dependencyRefs,
      actionEdges: actionEdges ?? this.actionEdges,
      blindEdges: blindEdges,
      lifecycleActionPayloads: lifecycleActionPayloads,
      plainActionPayloads: plainActionPayloads,
      bodyElements: bodyElements,
    );
  }

  List<CompiledActionPayload> get actionPayloads {
    return [
      for (final edge in actionEdges)
        if (edge.actionPayload != null) edge.actionPayload!,
      for (final edge in blindEdges)
        if (edge.actionPayload != null) edge.actionPayload!,
      ...lifecycleActionPayloads,
      ...plainActionPayloads,
    ];
  }

  JsonObject toJson() {
    return {
      'label': label,
      'header': header.toJson(),
      're': regexPatterns,
      'regex_slots': [for (final slot in regexSlots) slot.toJson()],
      'capture_gaps': captureGaps?.toJson(),
      'dependency_refs': [for (final ref in dependencyRefs) ref.toJson()],
      'mode_metadata': modeMetadata.toJson(),
      'action_edges': [for (final edge in actionEdges) edge.toJson()],
      'blind_edges': [for (final edge in blindEdges) edge.toJson()],
      'lifecycle_action_payloads': [
        for (final payload in lifecycleActionPayloads) payload.toJson(),
      ],
      'plain_action_payloads': [
        for (final payload in plainActionPayloads) payload.toJson(),
      ],
      'body': [for (final element in bodyElements) element.toJson()],
    };
  }

  JsonObject toDescriptorRuleJson() {
    return {
      'handler': {
        'kind': 'dart_interpreter_rule',
        'label': label,
        'status': 'compiled_state_only',
      },
      're': regexPatterns,
      'dependency_refs': [for (final ref in dependencyRefs) ref.toJson()],
      'action_edges': [for (final edge in actionEdges) edge.toDescriptorJson()],
      'blind_edges': [for (final edge in blindEdges) edge.toJson()],
      'lifecycle_action_payloads': [
        for (final payload in lifecycleActionPayloads) payload.toJson(),
      ],
      'plain_action_payloads': [
        for (final payload in plainActionPayloads) payload.toJson(),
      ],
      'meta': {
        'label': label,
        'line': header.line,
        'is_top': header.isTop,
        'family': modeMetadata.family,
        'cursor_policy': modeMetadata.cursorPolicy,
        'edge_ownership': _edgeOwnership,
        'resolved_edges': _resolvedEdgeDescriptorJson(),
        'regex_slots': [for (final slot in regexSlots) slot.toJson()],
        'capture_gaps': captureGaps?.toJson(),
        'resolved_slot_edges': _resolvedSlotEdgeDescriptorJson(),
        'mode': modeMetadata.toJson(),
      },
    };
  }

  String get _edgeOwnership {
    return switch ((actionEdges.isEmpty, blindEdges.isEmpty)) {
      (false, true) => 'action',
      (true, false) => 'blind',
      (true, true) => 'none',
      (false, false) => 'mixed',
    };
  }

  List<JsonObject> _resolvedEdgeDescriptorJson() {
    return [
      for (final edge in actionEdges)
        for (final target in edge.targets)
          {
            'ownership': 'action',
            'target': target.label,
            'regex_index': edge.childRegexIndex,
            'block': edge.code != null,
            'fluent': _descriptorFluentText(edge.fluentChain),
          },
      for (final edge in blindEdges)
        {
          'ownership': 'blind',
          'target': edge.target.label,
          'regex_index': null,
          'block': edge.code != null,
          'fluent': _descriptorFluentText(edge.fluentChain),
        },
    ];
  }

  List<JsonObject> _resolvedSlotEdgeDescriptorJson() {
    return [
      for (final edge in actionEdges)
        {
          'selector_kind': edge.selectorKind,
          'authored_selector': edge.authoredSelector,
          'target_rule': edge.targets.single.label,
          'regex_index': edge.childRegexIndex,
          'target_slot_id': edge.targetSlotId,
        },
    ];
  }
}

final class CompiledRuleModeMetadata {
  const CompiledRuleModeMetadata({
    required this.name,
    required this.isTop,
    required this.isAnd,
    required this.isRepetition,
    this.repMin,
    this.repMax,
  });

  factory CompiledRuleModeMetadata.fromHeader(RuleHeader header) {
    return CompiledRuleModeMetadata(
      name: header.mode.name,
      isTop: header.isTop,
      isAnd: header.mode.isAnd,
      isRepetition: header.mode.isRepetition,
      repMin: header.mode.repMin,
      repMax: header.mode.repMax,
    );
  }

  final String name;
  final bool isTop;
  final bool isAnd;
  final bool isRepetition;
  final int? repMin;
  final int? repMax;

  String get family => isAnd ? 'and' : 'or_default';

  String get cursorPolicy => isAnd ? 'consume' : 'seek';

  JsonObject toJson() {
    return {
      'name': name,
      'is_top': isTop,
      'is_and': isAnd,
      'is_repetition': isRepetition,
      if (repMin != null) 'rep_min': repMin,
      if (repMax != null) 'rep_max': repMax,
    };
  }
}

final class DependencyRef {
  const DependencyRef({required this.label, required this.index});

  final String label;
  final int index;

  JsonObject toJson() => {'label': label, 'idx': index};
}

final class CompiledActionEdge {
  const CompiledActionEdge({
    required this.line,
    required this.source,
    required this.targets,
    required this.regexIndex,
    required this.childRegexIndex,
    required this.hasParentRegex,
    required this.fluentChain,
    this.selectorKind = 'unindexed',
    this.authoredSelector,
    this.targetSlotId,
    this.sourceId = 'inline',
    this.code,
    this.actionPayload,
  });

  final int line;
  final String source;
  final List<DependencyRef> targets;
  final int regexIndex;
  final int childRegexIndex;
  final bool hasParentRegex;
  final String selectorKind;
  final Object? authoredSelector;
  final String? targetSlotId;
  final String sourceId;
  final String? code;
  final List<FluentCall> fluentChain;
  final CompiledActionPayload? actionPayload;

  CompiledActionEdge copyWith({int? regexIndex}) {
    return CompiledActionEdge(
      line: line,
      source: source,
      targets: targets,
      regexIndex: regexIndex ?? this.regexIndex,
      childRegexIndex: childRegexIndex,
      hasParentRegex: hasParentRegex,
      selectorKind: selectorKind,
      authoredSelector: authoredSelector,
      targetSlotId: targetSlotId,
      sourceId: sourceId,
      code: code,
      fluentChain: fluentChain,
      actionPayload: actionPayload,
    );
  }

  JsonObject toJson() {
    return {
      'line': line,
      'source': source,
      'targets': [for (final target in targets) target.toJson()],
      'regex_index': regexIndex,
      'child_regex_index': childRegexIndex,
      'selector_kind': selectorKind,
      'authored_selector': authoredSelector,
      'target_rule': targets.single.label,
      'target_slot_id': targetSlotId,
      'source_id': sourceId,
      'has_parent_regex': hasParentRegex,
      if (code != null) 'code': code,
      'fluent_chain': [for (final call in fluentChain) call.toJson()],
      if (actionPayload != null) 'action_payload': actionPayload!.toJson(),
    };
  }

  JsonObject toDescriptorJson() {
    return {
      'line': line,
      'source': source,
      'targets': [for (final target in targets) target.toJson()],
      'regex_index': regexIndex,
      'child_regex_index': childRegexIndex,
      'has_parent_regex': hasParentRegex,
      if (code != null) 'code': code,
      'fluent_chain': [for (final call in fluentChain) call.toJson()],
      if (actionPayload != null) 'action_payload': actionPayload!.toJson(),
    };
  }
}

final class CompiledBlindEdge {
  const CompiledBlindEdge({
    required this.line,
    required this.source,
    required this.target,
    required this.fluentChain,
    this.code,
    this.actionPayload,
  });

  final int line;
  final String source;
  final DependencyRef target;
  final String? code;
  final List<FluentCall> fluentChain;
  final CompiledActionPayload? actionPayload;

  JsonObject toJson() {
    return {
      'line': line,
      'source': source,
      'target': target.toJson(),
      if (code != null) 'code': code,
      'fluent_chain': [for (final call in fluentChain) call.toJson()],
      if (actionPayload != null) 'action_payload': actionPayload!.toJson(),
    };
  }
}

final class CompiledActionPayload {
  const CompiledActionPayload({
    required this.role,
    required this.line,
    required this.source,
    required this.code,
    required this.actionAst,
    required this.contracts,
    this.lifecycle,
  });

  final String role;
  final int line;
  final String source;
  final String code;
  final String? lifecycle;
  final ActionBlock actionAst;
  final ActionContractResolution contracts;

  JsonObject toJson() {
    return {
      'role': role,
      'line': line,
      'source': source,
      'code': code,
      if (lifecycle != null) 'lifecycle': lifecycle,
      'action_ast': actionAst.toJson(),
      'contracts': contracts.toJson(),
    };
  }
}

final class CompiledDependencyRegexState {
  const CompiledDependencyRegexState({required this.dependencyRegexMap});

  final Map<String, CompiledDependencyRegexEntry> dependencyRegexMap;

  JsonObject toJson() {
    return {
      'kind': 'compiled_dependency_regex_state',
      'dependency_regex_map': {
        for (final entry in dependencyRegexMap.entries)
          entry.key: entry.value.toJson(),
      },
    };
  }

  JsonObject toDescriptorJson() {
    return {
      for (final entry in dependencyRegexMap.entries)
        entry.key: entry.value.toJson(),
    };
  }
}

final class CompiledDependencyRegexEntry {
  const CompiledDependencyRegexEntry({
    required this.ownerLabel,
    required this.dependencyRefs,
    required this.patterns,
  });

  final String ownerLabel;
  final List<DependencyRef> dependencyRefs;
  final List<String> patterns;

  String get combinedPattern {
    return patterns.map((pattern) => '(?:$pattern)').join('|');
  }

  JsonObject toJson() {
    return {
      'owner_label': ownerLabel,
      'dependency_refs': [for (final ref in dependencyRefs) ref.toJson()],
      'patterns': patterns,
      'combined_pattern': combinedPattern,
    };
  }
}

final class CompiledDescriptorState {
  const CompiledDescriptorState({
    required this.compiledSpecState,
    required this.dependencyRegexState,
  });

  final CompiledSpec compiledSpecState;
  final CompiledDependencyRegexState dependencyRegexState;

  JsonObject toJson() {
    return {
      'spec': {
        for (final label in compiledSpecState.compiledRuleOrder)
          label: compiledSpecState.rulesByLabel[label]!.toDescriptorRuleJson(),
      },
      'functions': {
        for (final function in compiledSpecState.functions)
          function.name: function.toDescriptorJson(),
      },
      'dependency_regex_map': dependencyRegexState.toDescriptorJson(),
      'meta': {
        'descriptor_model': 'compiled_descriptor_state',
        'compiled_spec_model': 'compiled_spec_state',
        'compiled_dependency_regex_model': 'compiled_dependency_regex_state',
        'cursor_contract': 'linkedspec-rule-local-cursor-v1',
        'entry_rule_contract': linkedSpecRootRuleSelectionContract,
        'regex_slot_identity_contract': linkedSpecRegexSlotIdentityContract,
        'definition_order': compiledSpecState.definitionOrder,
        'compiled_rule_order': compiledSpecState.compiledRuleOrder,
        'redefined_rule_labels': compiledSpecState.redefinedRuleLabels,
        'function_order': [
          for (final function in compiledSpecState.functions) function.name,
        ],
        'function_count': compiledSpecState.functionRegistry.entries.length,
      },
    };
  }
}

String? _descriptorFluentText(List<FluentCall> chain) {
  if (chain.isEmpty) {
    return null;
  }
  return chain
      .map(
        (call) =>
            call.args.isEmpty ? call.method : '${call.method}(${call.args})',
      )
      .join('.');
}

CompiledRule _compileRule(
  Rule rule,
  UserFunctionRegistry functionRegistry, {
  required String sourceId,
  required Map<String, Rule> sourceRulesByLabel,
}) {
  final regexPatterns = <String>[];
  final regexSlots = <CompiledRegexSlotMetadata>[];
  final dependencyRefs = <DependencyRef>[];
  final actionEdges = <CompiledActionEdge>[];
  final blindEdges = <CompiledBlindEdge>[];
  final lifecycleActionPayloads = <CompiledActionPayload>[];
  final plainActionPayloads = <CompiledActionPayload>[];
  CompiledCaptureGapsMetadata? captureGaps;
  var currentRegexIndex = 0;
  int? lastRegexLine;

  for (final element in rule.body) {
    switch (element.kind) {
      case RegexBodyElementKind(:final pattern, :final slotId):
        regexPatterns.add(pattern);
        regexSlots.add(
          CompiledRegexSlotMetadata(
            regexIndex: currentRegexIndex,
            slotId: slotId,
            sourceId: sourceId,
            line: element.line,
          ),
        );
        currentRegexIndex += 1;
        lastRegexLine = element.line;
      case ActionEdgeBodyElementKind(
        :final targets,
        :final code,
        :final fluentChain,
      ):
        final hasParentRegex =
            lastRegexLine == element.line && currentRegexIndex > 0;
        final regexIndex = hasParentRegex ? currentRegexIndex - 1 : 0;
        final payload = _compileOptionalActionPayload(
          role: 'action_edge',
          element: element,
          sourceCode: code,
          fluentChain: fluentChain,
          functionRegistry: functionRegistry,
        );
        for (final target in targets) {
          final resolvedTarget = _resolveAuthoredTarget(
            target,
            sourceRulesByLabel,
          );
          final ref = DependencyRef(
            label: target.label,
            index: resolvedTarget.index,
          );
          dependencyRefs.add(ref);
          actionEdges.add(
            CompiledActionEdge(
              line: element.line,
              source: element.source,
              targets: List.unmodifiable([ref]),
              regexIndex: regexIndex,
              childRegexIndex: resolvedTarget.index,
              hasParentRegex: hasParentRegex,
              selectorKind: target.selectorKind,
              authoredSelector: target.authoredSelector,
              targetSlotId: resolvedTarget.slotId,
              sourceId: sourceId,
              code: code,
              fluentChain: List.unmodifiable(fluentChain),
              actionPayload: payload,
            ),
          );
        }
        lastRegexLine = null;
      case BlindEdgeBodyElementKind(
        :final target,
        :final code,
        :final fluentChain,
      ):
        lastRegexLine = null;
        final ref = DependencyRef(label: target, index: 0);
        dependencyRefs.add(ref);
        final payload = _compileOptionalActionPayload(
          role: 'blind_edge',
          element: element,
          sourceCode: code,
          fluentChain: fluentChain,
          functionRegistry: functionRegistry,
        );
        blindEdges.add(
          CompiledBlindEdge(
            line: element.line,
            source: element.source,
            target: ref,
            code: code,
            fluentChain: List.unmodifiable(fluentChain),
            actionPayload: payload,
          ),
        );
      case BareEdgeBodyElementKind(
        :final targets,
        :final code,
        :final fluentChain,
      ):
        lastRegexLine = null;
        final payload = _compileOptionalActionPayload(
          role: rule.header.mode.isAnd ? 'blind_edge' : 'action_edge',
          element: element,
          sourceCode: code,
          fluentChain: fluentChain,
          functionRegistry: functionRegistry,
        );
        if (rule.header.mode.isAnd) {
          final target = targets.single;
          final ref = DependencyRef(label: target.label, index: 0);
          dependencyRefs.add(ref);
          blindEdges.add(
            CompiledBlindEdge(
              line: element.line,
              source: element.source,
              target: ref,
              code: code,
              fluentChain: List.unmodifiable(fluentChain),
              actionPayload: payload,
            ),
          );
        } else {
          for (final target in targets) {
            final childRegexIndex = target.index ?? 0;
            final ref = DependencyRef(
              label: target.label,
              index: childRegexIndex,
            );
            dependencyRefs.add(ref);
            actionEdges.add(
              CompiledActionEdge(
                line: element.line,
                source: element.source,
                targets: List.unmodifiable([ref]),
                regexIndex: 0,
                childRegexIndex: childRegexIndex,
                hasParentRegex: false,
                selectorKind: target.index == null ? 'unindexed' : 'numeric',
                authoredSelector: target.index,
                targetSlotId: _slotIdAt(
                  sourceRulesByLabel[target.label],
                  childRegexIndex,
                ),
                sourceId: sourceId,
                code: code,
                fluentChain: List.unmodifiable(fluentChain),
                actionPayload: payload,
              ),
            );
          }
        }
      case CodeBlockBodyElementKind(:final lifecycle, :final code):
        lastRegexLine = null;
        lifecycleActionPayloads.add(
          _compileActionPayload(
            role: 'lifecycle',
            element: element,
            code: code,
            lifecycle: lifecycle,
            functionRegistry: functionRegistry,
          ),
        );
      case PlainBlockBodyElementKind(:final code):
        lastRegexLine = null;
        plainActionPayloads.add(
          _compileActionPayload(
            role: 'plain_block',
            element: element,
            code: code,
            functionRegistry: functionRegistry,
          ),
        );
      case CaptureGapsDirectiveBodyElementKind(:final directive):
        lastRegexLine = null;
        captureGaps = CompiledCaptureGapsMetadata(
          directive: directive,
          sourceId: sourceId,
          line: element.line,
        );
      case SplitMarkerBodyElementKind():
      case LifecycleMarkerBodyElementKind():
      case FluentChainBodyElementKind():
      case ConditionalBodyElementKind():
      case RawBodyElementKind():
        lastRegexLine = null;
        break;
    }
  }

  return CompiledRule(
    label: rule.header.label,
    header: rule.header,
    modeMetadata: CompiledRuleModeMetadata.fromHeader(rule.header),
    regexPatterns: List.unmodifiable(regexPatterns),
    regexSlots: List.unmodifiable(regexSlots),
    captureGaps: captureGaps,
    dependencyRefs: List.unmodifiable(dependencyRefs),
    actionEdges: List.unmodifiable(actionEdges),
    blindEdges: List.unmodifiable(blindEdges),
    lifecycleActionPayloads: List.unmodifiable(lifecycleActionPayloads),
    plainActionPayloads: List.unmodifiable(plainActionPayloads),
    bodyElements: List.unmodifiable(rule.body),
  );
}

({int index, String? slotId}) _resolveAuthoredTarget(
  EdgeTarget target,
  Map<String, Rule> sourceRulesByLabel,
) {
  final targetRule = sourceRulesByLabel[target.label];
  if (target.selectorKind == 'named') {
    var index = 0;
    for (final element in targetRule?.body ?? const <BodyElement>[]) {
      final kind = element.kind;
      if (kind is! RegexBodyElementKind) {
        continue;
      }
      if (kind.slotId == target.authoredSelector) {
        return (index: index, slotId: kind.slotId);
      }
      index += 1;
    }
    return (index: 0, slotId: null);
  }
  return (index: target.index, slotId: _slotIdAt(targetRule, target.index));
}

String? _slotIdAt(Rule? rule, int index) {
  if (rule == null || index < 0) {
    return null;
  }
  var regexIndex = 0;
  for (final element in rule.body) {
    final kind = element.kind;
    if (kind is! RegexBodyElementKind) {
      continue;
    }
    if (regexIndex == index) {
      return kind.slotId;
    }
    regexIndex += 1;
  }
  return null;
}

Map<String, CompiledRule> _resolveActionEdgeDependencyRegexes({
  required List<String> compiledRuleOrder,
  required Map<String, CompiledRule> rulesByLabel,
}) {
  final resolved = Map<String, CompiledRule>.from(rulesByLabel);
  for (final label in compiledRuleOrder) {
    final rule = resolved[label]!;
    final patterns = List<String>.from(rule.regexPatterns);
    final actionEdges = <CompiledActionEdge>[];
    for (final edge in rule.actionEdges) {
      if (edge.hasParentRegex) {
        actionEdges.add(edge);
        continue;
      }

      final target = edge.targets.single;
      if (target.label == label) {
        if (target.index < 0 || target.index >= patterns.length) {
          throw CompiledSpecException(
            "rule '$label' references its own regex slot ${target.index}, "
            'but the rule has ${patterns.length} parent regex slot(s)',
          );
        }
        actionEdges.add(edge.copyWith(regexIndex: target.index));
        continue;
      }

      final child = resolved[target.label] ?? rulesByLabel[target.label];
      if (child == null) {
        throw CompiledSpecException(
          "rule '$label' references undefined rule '${target.label}'",
        );
      }
      if (target.index < 0 || target.index >= child.regexPatterns.length) {
        throw CompiledSpecException(
          "rule '$label' references rule '${target.label}' regex slot "
          '${target.index}, but that rule has '
          '${child.regexPatterns.length} regex slot(s)',
        );
      }
      final regexIndex = patterns.length;
      patterns.add(child.regexPatterns[target.index]);
      actionEdges.add(edge.copyWith(regexIndex: regexIndex));
    }

    resolved[label] = rule.copyWith(
      regexPatterns: List.unmodifiable(patterns),
      actionEdges: List.unmodifiable(actionEdges),
    );
  }
  return resolved;
}

CompiledActionPayload? _compileOptionalActionPayload({
  required String role,
  required BodyElement element,
  required String? sourceCode,
  required List<FluentCall> fluentChain,
  required UserFunctionRegistry functionRegistry,
}) {
  final code = sourceCode ?? _fluentChainToActionCode(fluentChain);
  if (code == null || code.trim().isEmpty) {
    return null;
  }
  return _compileActionPayload(
    role: role,
    element: element,
    code: code,
    functionRegistry: functionRegistry,
  );
}

CompiledActionPayload _compileActionPayload({
  required String role,
  required BodyElement element,
  required String code,
  required UserFunctionRegistry functionRegistry,
  String? lifecycle,
}) {
  final ast = parseActionBlock(code);
  try {
    normalizeActionBlockFinalCodeblocks(ast, functionRegistry);
  } on CallableContractException catch (error) {
    throw CompiledSpecException(error.message);
  }
  return CompiledActionPayload(
    role: role,
    line: element.line,
    source: element.source,
    code: code,
    lifecycle: lifecycle,
    actionAst: ast,
    contracts: resolveActionBlockContracts(
      ast,
      functionRegistry: functionRegistry,
    ),
  );
}

String? _fluentChainToActionCode(List<FluentCall> fluentChain) {
  if (fluentChain.isEmpty) {
    return null;
  }
  return fluentChain
      .map((call) {
        final args = call.args.trim();
        return args.isEmpty ? '${call.method}()' : '${call.method}($args)';
      })
      .join('; ');
}

List<String> _lastDefinitionOrder(List<String> definitionOrder) {
  final seen = <String>{};
  final reversed = <String>[];
  for (final label in definitionOrder.reversed) {
    if (seen.add(label)) {
      reversed.add(label);
    }
  }
  return reversed.reversed.toList(growable: false);
}

CompiledDependencyRegexState _buildDependencyRegexState({
  required List<String> compiledRuleOrder,
  required Map<String, CompiledRule> rulesByLabel,
}) {
  final dependencyRegexMap = <String, CompiledDependencyRegexEntry>{};
  for (final label in compiledRuleOrder) {
    final rule = rulesByLabel[label]!;
    if (rule.dependencyRefs.isEmpty) {
      continue;
    }
    final patterns = [
      for (final ref in rule.dependencyRefs)
        _dependencyPatternFor(
          ownerLabel: label,
          ref: ref,
          rulesByLabel: rulesByLabel,
        ),
    ];
    dependencyRegexMap[label] = CompiledDependencyRegexEntry(
      ownerLabel: label,
      dependencyRefs: rule.dependencyRefs,
      patterns: List.unmodifiable(patterns),
    );
  }
  return CompiledDependencyRegexState(
    dependencyRegexMap: Map.unmodifiable(dependencyRegexMap),
  );
}

String _dependencyPatternFor({
  required String ownerLabel,
  required DependencyRef ref,
  required Map<String, CompiledRule> rulesByLabel,
}) {
  final target = rulesByLabel[ref.label];
  if (target == null) {
    throw CompiledSpecException(
      "rule '$ownerLabel' references undefined rule '${ref.label}'",
    );
  }
  if (ref.index < 0 || ref.index >= target.regexPatterns.length) {
    throw CompiledSpecException(
      "rule '$ownerLabel' references rule '${ref.label}' regex slot "
      '${ref.index}, but that rule has ${target.regexPatterns.length} regex '
      'slot(s)',
    );
  }
  return target.regexPatterns[ref.index];
}
