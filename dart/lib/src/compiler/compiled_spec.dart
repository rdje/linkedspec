import '../action/action_ast.dart';
import '../action/action_contracts.dart';
import '../action/action_parser.dart';
import '../action/function_registry.dart';
import '../ast/spec_ast.dart';
import '../trace/trace.dart';
import '../validation/spec_validator.dart';

final class CompiledSpecException implements Exception {
  const CompiledSpecException(this.message);

  final String message;

  @override
  String toString() => 'CompiledSpecException: $message';
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

    final functionRegistry = UserFunctionRegistry.fromSpec(spec, trace: trace);
    final definitionOrder = <String>[];
    final rulesByLabel = <String, CompiledRule>{};
    final redefinedRuleLabels = <String>[];
    final redefinedSeen = <String>{};

    for (final rule in spec.rules) {
      final label = rule.header.label;
      definitionOrder.add(label);
      if (rulesByLabel.containsKey(label) && redefinedSeen.add(label)) {
        redefinedRuleLabels.add(label);
      }
      rulesByLabel[label] = _compileRule(rule, functionRegistry);
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
    validateNoRemovedAggregateSelectors(compiled);
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

  CompiledDescriptorState get descriptorState {
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
        validateBlock(parseActionBlock(source), '$context fluent call $index');
      } on CompiledSpecException {
        rethrow;
      } on Object {
        // Fluent syntax historically remains runtime-parsed. Do not turn an
        // unrelated deferred parse failure into a new compile-time change.
      }
    }
  }

  for (final function in compiled.functions) {
    try {
      validateBlock(
        parseActionBlock(function.bodySource),
        "function '${function.name}' body",
      );
    } on CompiledSpecException {
      rethrow;
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

final class CompiledRule {
  const CompiledRule({
    required this.label,
    required this.header,
    required this.modeMetadata,
    required this.regexPatterns,
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
      'action_edges': [for (final edge in actionEdges) edge.toJson()],
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
        'mode': modeMetadata.toJson(),
      },
    };
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

  /// Preserve pre-rule-local runtime interpretation until execution leaf
  /// FUTURE-PARITY-BACKLOG.9.1.5.2 removes this bounded adapter.
  bool get usesLegacyAndInterpretation => isAnd || name == 'Pipe';

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
    this.code,
    this.actionPayload,
  });

  final int line;
  final String source;
  final List<DependencyRef> targets;
  final int regexIndex;
  final int childRegexIndex;
  final bool hasParentRegex;
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
        'parse_mode': 'seek',
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

CompiledRule _compileRule(Rule rule, UserFunctionRegistry functionRegistry) {
  final regexPatterns = <String>[];
  final dependencyRefs = <DependencyRef>[];
  final actionEdges = <CompiledActionEdge>[];
  final blindEdges = <CompiledBlindEdge>[];
  final lifecycleActionPayloads = <CompiledActionPayload>[];
  final plainActionPayloads = <CompiledActionPayload>[];
  var currentRegexIndex = 0;
  int? lastRegexLine;

  for (final element in rule.body) {
    switch (element.kind) {
      case RegexBodyElementKind(:final pattern):
        regexPatterns.add(pattern);
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
          final ref = DependencyRef(label: target.label, index: target.index);
          dependencyRefs.add(ref);
          actionEdges.add(
            CompiledActionEdge(
              line: element.line,
              source: element.source,
              targets: List.unmodifiable([ref]),
              regexIndex: regexIndex,
              childRegexIndex: target.index,
              hasParentRegex: hasParentRegex,
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
    dependencyRefs: List.unmodifiable(dependencyRefs),
    actionEdges: List.unmodifiable(actionEdges),
    blindEdges: List.unmodifiable(blindEdges),
    lifecycleActionPayloads: List.unmodifiable(lifecycleActionPayloads),
    plainActionPayloads: List.unmodifiable(plainActionPayloads),
    bodyElements: List.unmodifiable(rule.body),
  );
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
