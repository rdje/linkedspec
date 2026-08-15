import '../ast/spec_ast.dart';
import '../action/action_contracts.dart';
import '../parser/unicode_rule_label.dart';
import '../trace/trace.dart';

final class SpecValidationException implements Exception {
  const SpecValidationException(this.message, {this.diagnostic});

  final String message;
  final SpecPortableDiagnostic? diagnostic;

  @override
  String toString() => 'SpecValidationException: $message';
}

/// A stable backend-neutral validation/normalization failure.
final class SpecPortableDiagnostic {
  SpecPortableDiagnostic({
    required this.code,
    required this.stage,
    required this.message,
    Map<String, Object?> fields = const {},
  }) : fields = Map.unmodifiable(
         Map.fromEntries(
           (fields.entries.toList()
                 ..sort((left, right) => left.key.compareTo(right.key)))
               .map((entry) => MapEntry(entry.key, entry.value)),
         ),
       );

  final String code;
  final String stage;
  final String message;
  final Map<String, Object?> fields;

  factory SpecPortableDiagnostic.fromJson(JsonObject json) {
    final code = json['code'];
    final stage = json['stage'];
    final message = json['message'];
    final rawFields = json['fields'];
    if (code is! String ||
        stage is! String ||
        message is! String ||
        rawFields is! Map) {
      throw const FormatException('invalid portable spec diagnostic JSON');
    }
    return SpecPortableDiagnostic(
      code: code,
      stage: stage,
      message: message,
      fields: Map<String, Object?>.from(rawFields),
    );
  }

  Object? field(String name) => fields[name];

  JsonObject toJson() {
    return {'code': code, 'stage': stage, 'message': message, 'fields': fields};
  }
}

void validateSpec(
  SpecFile spec, {
  bool strictSyntax = false,
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_frontend:validate_spec',
    'rules=${spec.rules.length} functions=${spec.functions.length} '
        'strict=${strictSyntax ? 1 : 0}',
    LinkedSpecTraceLevel.high,
  );
  try {
    _checkAtLeastOneRule(spec);
    _checkRuleLabels(spec);
    _checkDuplicateRuleLabels(spec);
    _checkRegexSlotDeclarations(spec);
    _checkDuplicateFunctionNames(spec);
    _checkFunctionRegistry(spec);
    _checkMalformedRawBodyLines(spec);
    _checkEdgeStructure(spec);
    _checkEdgeTargets(spec);
    _checkCaptureGapsDirectives(spec);
    _checkMixedEdges(spec);
    _checkRegexSyntax(spec);
    if (strictSyntax) {
      _checkUnusedRules(spec);
    }
    trace?.traceDecision(
      'dart_frontend:validate_spec:checks',
      true,
      'strict=${strictSyntax ? 1 : 0}',
      LinkedSpecTraceLevel.medium,
    );
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'ok');
    }
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

void _checkAtLeastOneRule(SpecFile spec) {
  if (spec.rules.isNotEmpty) {
    return;
  }
  throw _portableDiagnostic(
    code: 'no_rules_defined',
    stage: 'validate_spec',
    message: 'spec does not define any rules',
    fields: const {},
  );
}

void _checkRuleLabels(SpecFile spec) {
  for (final rule in spec.rules) {
    if (!isRuleLabel(rule.header.label)) {
      throw _invalidRuleLabelDiagnostic(
        label: rule.header.label,
        role: 'declaration',
        line: rule.header.line,
      );
    }
    for (final element in rule.body) {
      final targets = switch (element.kind) {
        ActionEdgeBodyElementKind(:final targets) => [
          for (final target in targets) target.label,
        ],
        BlindEdgeBodyElementKind(:final target) => [target],
        BareEdgeBodyElementKind(:final targets) => [
          for (final target in targets) target.label,
        ],
        _ => const <String>[],
      };
      for (final target in targets) {
        if (!isRuleLabel(target)) {
          throw _invalidRuleLabelDiagnostic(
            label: target,
            role: 'edge_target',
            line: element.line,
            owner: rule.header.label,
          );
        }
      }
    }
  }
}

SpecValidationException _invalidRuleLabelDiagnostic({
  required String label,
  required String role,
  required int line,
  String? owner,
}) {
  return _portableDiagnostic(
    code: 'invalid_rule_label',
    stage: 'validate_rule_labels',
    message:
        "$role '$label' is not a nonempty Unicode 17.0.0 "
        'XID_Continue rule label',
    fields: {
      'label': label,
      'line': line,
      'role': role,
      if (owner != null) 'rule_label': owner,
    },
  );
}

void _checkDuplicateRuleLabels(SpecFile spec) {
  final seen = <String>{};
  for (final rule in spec.rules) {
    if (!seen.add(rule.header.label)) {
      throw SpecValidationException(
        "duplicate rule label '${rule.header.label}'",
      );
    }
  }
}

void _checkRegexSlotDeclarations(SpecFile spec) {
  for (final rule in spec.rules) {
    final firstLines = <String, int>{};
    for (final element in rule.body) {
      final kind = element.kind;
      if (kind is! RegexBodyElementKind || kind.slotId == null) {
        continue;
      }
      final slotId = kind.slotId!;
      if (!isRuleLabel(slotId) || _isAsciiDigitOnly(slotId)) {
        throw _gapDiagnostic(
          code: 'regex_slot_name_invalid',
          stage: 'parse_declaration',
          message:
              "rule '${rule.header.label}' has invalid regex slot name "
              "'$slotId'",
          spec: spec,
          rule: rule,
          line: element.line,
          fields: {'slot_name': slotId},
        );
      }
      final firstLine = firstLines[slotId];
      if (firstLine != null) {
        throw _gapDiagnostic(
          code: 'regex_slot_duplicate_name',
          stage: 'resolve_declaration',
          message:
              "rule '${rule.header.label}' declares regex slot '$slotId' "
              'more than once',
          spec: spec,
          rule: rule,
          line: element.line,
          fields: {'slot_name': slotId, 'first_line': firstLine},
        );
      }
      firstLines[slotId] = element.line;
    }
  }
}

void _checkDuplicateFunctionNames(SpecFile spec) {
  final seen = <String>{};
  for (final function in spec.functions) {
    if (!seen.add(function.name)) {
      throw SpecValidationException(
        "duplicate user function definition '${function.name}'",
      );
    }
  }
}

void _checkFunctionRegistry(SpecFile spec) {
  final ruleLabels = {for (final rule in spec.rules) rule.header.label};

  for (final function in spec.functions) {
    final name = function.name;
    if (!_isIdentifier(name)) {
      throw SpecValidationException("invalid user function name '$name'");
    }
    if (ruleLabels.contains(name)) {
      throw SpecValidationException(
        "user function '$name' collides with rule label '$name'",
      );
    }
    if (_isReservedRuntimeSymbol(name)) {
      throw SpecValidationException(
        "user function '$name' uses a reserved runtime symbol",
      );
    }
    if (_isLifecycleMarkerName(name)) {
      throw SpecValidationException(
        "user function '$name' collides with lifecycle marker '$name'",
      );
    }
    if (_isFunctionKeyword(name) || isKnownActionIrCallName(name)) {
      throw SpecValidationException(
        "user function '$name' collides with built-in helper/control name '$name'",
      );
    }

    final signature = function.signature;
    if (signature != null &&
        (signature.kind != 'callable_signature' ||
            signature.version != 1 ||
            !_stringListsEqual(signature.positionalParams, function.params) ||
            signature.restParam == null ||
            signature.minArity != function.arity ||
            signature.minArity != signature.positionalParams.length ||
            signature.maxArity != null)) {
      throw SpecValidationException(
        "user function '$name' has an invalid variadic callable signature",
      );
    }

    final parameterKinds = function.parameterKinds;
    if (parameterKinds.isNotEmpty) {
      final finalParam = function.params.isEmpty ? null : function.params.last;
      if (signature != null ||
          finalParam == null ||
          parameterKinds.length != 1 ||
          parameterKinds[finalParam] != 'codeblock') {
        throw SpecValidationException(
          "user function '$name' has invalid final-codeblock parameter metadata",
        );
      }
    }

    final seenParams = <String>{};
    final allParams = [
      ...function.params,
      if (signature?.restParam != null) signature!.restParam!,
    ];
    for (final param in allParams) {
      if (!_isIdentifier(param)) {
        throw SpecValidationException(
          "user function '$name' has invalid parameter '$param'",
        );
      }
      if (!seenParams.add(param)) {
        throw SpecValidationException(
          "duplicate parameter '$param' in function '$name'",
        );
      }
      if (_isReservedRuntimeSymbol(param) ||
          _isLifecycleMarkerName(param) ||
          _isFunctionKeyword(param)) {
        throw SpecValidationException(
          "user function '$name' parameter '$param' is reserved",
        );
      }
    }
  }
}

void _checkMalformedRawBodyLines(SpecFile spec) {
  for (final rule in spec.rules) {
    for (final element in rule.body) {
      if (element.kind case final RawBodyElementKind raw) {
        throw SpecValidationException(
          "rule '${rule.header.label}': unrecognized body syntax at line "
          '${element.line}: ${raw.text}',
        );
      }
    }
  }
}

bool _stringListsEqual(List<String> left, List<String> right) {
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

void _checkEdgeStructure(SpecFile spec) {
  final declaredLabels = {for (final rule in spec.rules) rule.header.label};

  for (final rule in spec.rules) {
    for (final element in rule.body) {
      switch (element.kind) {
        case BareEdgeBodyElementKind(:final targets, :final code):
          for (final target in targets) {
            if (!declaredLabels.contains(target.label)) {
              throw _portableDiagnostic(
                code: 'bare_edge_target_undefined',
                stage: 'normalize_edges',
                message:
                    "bare edge in rule '${rule.header.label}' targets "
                    "undefined rule '${target.label}'",
                fields: {
                  'rule_label': rule.header.label,
                  'target': target.label,
                },
              );
            }
          }

          if (rule.header.mode.isAnd) {
            final indexed = targets.where((target) => target.index != null);
            if (indexed.isNotEmpty) {
              final target = indexed.first;
              throw _portableDiagnostic(
                code: 'bare_edge_index_requires_action',
                stage: 'normalize_edges',
                message:
                    "indexed bare edge in AND rule '${rule.header.label}' "
                    'requires explicit action ownership',
                fields: {
                  'rule_label': rule.header.label,
                  'target': target.label,
                  'regex_index': target.index,
                },
              );
            }
            if (targets.length > 1) {
              throw _portableDiagnostic(
                code: 'bare_edge_group_requires_action',
                stage: 'normalize_edges',
                message:
                    "grouped bare edge in AND rule '${rule.header.label}' "
                    'requires explicit action ownership',
                fields: {
                  'rule_label': rule.header.label,
                  'targets': [for (final target in targets) target.label],
                },
              );
            }
          } else if (targets.length > 1 && code == null) {
            throw _groupedActionDiagnostic(rule, targets);
          }
        case ActionEdgeBodyElementKind(:final targets, :final code):
          if (targets.length > 1 && code == null) {
            throw _portableDiagnostic(
              code: 'grouped_action_shared_block_required',
              stage: 'validate_rule',
              message:
                  "rule '${rule.header.label}': grouped action-edge targets "
                  'require a shared code block',
              fields: {
                'rule_label': rule.header.label,
                'targets': [for (final target in targets) target.label],
              },
            );
          }
        case BlindEdgeBodyElementKind(:final target, :final index)
            when index != null:
          throw _portableDiagnostic(
            code: 'blind_call_index_forbidden',
            stage: 'validate_rule',
            message:
                "blind-call target '$target' in rule '${rule.header.label}' "
                'cannot select a regex index',
            fields: {
              'rule_label': rule.header.label,
              'target': target,
              'regex_index': index,
            },
          );
        default:
          break;
      }
    }
  }
}

SpecValidationException _groupedActionDiagnostic(
  Rule rule,
  List<BareEdgeTarget> targets,
) {
  return _portableDiagnostic(
    code: 'grouped_action_shared_block_required',
    stage: 'validate_rule',
    message:
        "rule '${rule.header.label}': grouped action-edge targets require "
        'a shared code block',
    fields: {
      'rule_label': rule.header.label,
      'targets': [for (final target in targets) target.label],
    },
  );
}

SpecValidationException _portableDiagnostic({
  required String code,
  required String stage,
  required String message,
  required Map<String, Object?> fields,
}) {
  return SpecValidationException(
    message,
    diagnostic: SpecPortableDiagnostic(
      code: code,
      stage: stage,
      message: message,
      fields: fields,
    ),
  );
}

SpecValidationException _gapDiagnostic({
  required String code,
  required String stage,
  required String message,
  required SpecFile spec,
  required Rule rule,
  required int line,
  required Map<String, Object?> fields,
}) {
  return _portableDiagnostic(
    code: code,
    stage: stage,
    message: message,
    fields: {
      'rule_label': rule.header.label,
      'source_id': spec.sourceId,
      'line': line,
      ...fields,
    },
  );
}

void _checkCaptureGapsDirectives(SpecFile spec) {
  for (final rule in spec.rules) {
    final directives = [
      for (final element in rule.body)
        if (element.kind is CaptureGapsDirectiveBodyElementKind) element,
    ];
    if (directives.isEmpty) {
      continue;
    }
    final directive = directives.first;
    if (directives.length > 1) {
      throw _gapDiagnostic(
        code: 'capture_gaps_duplicate_directive',
        stage: 'parse_directive',
        message:
            "rule '${rule.header.label}' declares @capture_gaps more than "
            'once',
        spec: spec,
        rule: rule,
        line: directives[1].line,
        fields: {'first_line': directive.line},
      );
    }

    for (final element in rule.body) {
      final kind = element.kind;
      if (kind is! SplitMarkerBodyElementKind || kind.marker.contains('mark')) {
        continue;
      }
      final marker = switch (kind.marker) {
        final value when value.contains('capture_slice') => '@capture_slice',
        final value when value.contains('capture_from_here') =>
          '@capture_from_here',
        _ => '@move_pos',
      };
      throw _gapDiagnostic(
        code: 'capture_gaps_legacy_marker_conflict',
        stage: 'validate_directive',
        message:
            "rule '${rule.header.label}' combines @capture_gaps with "
            "legacy marker '$marker'",
        spec: spec,
        rule: rule,
        line: directive.line,
        fields: {'marker': marker, 'marker_line': element.line},
      );
    }

    final family = rule.header.mode.isAnd ? 'and' : 'or_default';
    final cursorPolicy = rule.header.mode.isAnd ? 'consume' : 'seek';
    final executionShape = _captureGapsExecutionShape(rule.header.mode);
    final edgeOwnership = _captureGapsEdgeOwnership(rule);
    final eligibleMode = switch (rule.header.mode.name) {
      'Default' || 'Or' || 'OrPlus' || 'OrBounded' || 'Plus' => true,
      _ => false,
    };
    if (family != 'or_default' ||
        cursorPolicy != 'seek' ||
        edgeOwnership != 'action' ||
        !eligibleMode) {
      throw _gapDiagnostic(
        code: 'capture_gaps_rule_ineligible',
        stage: 'validate_directive',
        message:
            "rule '${rule.header.label}' is not eligible for @capture_gaps",
        spec: spec,
        rule: rule,
        line: directive.line,
        fields: {
          'family': family,
          'cursor_policy': cursorPolicy,
          'edge_ownership': edgeOwnership,
          'execution_shape': executionShape,
        },
      );
    }
  }
}

String _captureGapsExecutionShape(RuleMode mode) {
  return switch (mode.name) {
    'Default' => 'default_scan_loop',
    'Or' || 'OrPlus' || 'OrBounded' || 'Plus' => 'repeat_loop',
    _ => 'single_match',
  };
}

String _captureGapsEdgeOwnership(Rule rule) {
  var hasAction = false;
  var hasBlind = false;
  var hasLocalAdjacency = false;
  BodyElement? previous;
  for (final element in rule.body) {
    switch (element.kind) {
      case ActionEdgeBodyElementKind():
        hasAction = true;
        if (previous?.kind is RegexBodyElementKind &&
            previous!.line == element.line) {
          hasLocalAdjacency = true;
        }
      case BlindEdgeBodyElementKind():
        hasBlind = true;
      case BareEdgeBodyElementKind():
        if (rule.header.mode.isAnd) {
          hasBlind = true;
        } else {
          hasAction = true;
        }
      default:
        break;
    }
    previous = element;
  }
  if (hasAction && hasBlind) {
    return 'mixed';
  }
  if (hasLocalAdjacency) {
    return 'local_adjacency';
  }
  if (hasAction) {
    return 'action';
  }
  if (hasBlind) {
    return 'blind';
  }
  return 'none';
}

void _checkMixedEdges(SpecFile spec) {
  for (final rule in spec.rules) {
    var hasAction = false;
    var hasBlind = false;
    for (final element in rule.body) {
      switch (element.kind) {
        case ActionEdgeBodyElementKind():
          hasAction = true;
        case BlindEdgeBodyElementKind():
          hasBlind = true;
        case BareEdgeBodyElementKind():
          if (rule.header.mode.isAnd) {
            hasBlind = true;
          } else {
            hasAction = true;
          }
        default:
          break;
      }
    }
    if (hasAction && hasBlind) {
      throw _portableDiagnostic(
        code: 'mixed_edge_ownership',
        stage: 'validate_rule',
        message:
            "rule '${rule.header.label}' mixes action and blind edge ownership",
        fields: {
          'rule_label': rule.header.label,
          'ownerships': ['action', 'blind'],
        },
      );
    }
  }
}

void _checkEdgeTargets(SpecFile spec) {
  final rulesByLabel = {for (final rule in spec.rules) rule.header.label: rule};
  for (final rule in spec.rules) {
    for (final element in rule.body) {
      switch (element.kind) {
        case ActionEdgeBodyElementKind(:final targets):
          for (final target in targets) {
            _checkActionTarget(spec, rule, element, rulesByLabel, target);
          }
        case BlindEdgeBodyElementKind(:final target):
          _checkTarget(rule, rulesByLabel, target, 0);
        case BareEdgeBodyElementKind(:final targets):
          for (final target in targets) {
            _checkTarget(
              rule,
              rulesByLabel,
              target.label,
              target.index ?? 0,
              regexSlotIdentity: !rule.header.mode.isAnd,
            );
          }
        default:
          break;
      }
    }
  }
}

void _checkActionTarget(
  SpecFile spec,
  Rule owner,
  BodyElement element,
  Map<String, Rule> rulesByLabel,
  EdgeTarget target,
) {
  final targetRule = rulesByLabel[target.label];
  if (targetRule == null) {
    _checkTarget(
      owner,
      rulesByLabel,
      target.label,
      target.index,
      regexSlotIdentity: true,
    );
    return;
  }

  switch (target.selectorKind) {
    case 'invalid':
    case final selectorKind
        when selectorKind != 'named' &&
            selectorKind != 'numeric' &&
            selectorKind != 'unindexed':
      throw _gapDiagnostic(
        code: 'regex_slot_selector_invalid',
        stage: 'parse_selector',
        message:
            "rule '${owner.header.label}' has malformed regex selector "
            "for '${target.label}'",
        spec: spec,
        rule: owner,
        line: element.line,
        fields: {
          'target_rule': target.label,
          'authored_selector': target.authoredSelector,
        },
      );
    case 'named':
      final authored = target.authoredSelector;
      final slotIndex = _regexSlotIndex(targetRule, authored);
      if (slotIndex == null) {
        throw _gapDiagnostic(
          code: 'regex_slot_unknown_name',
          stage: 'resolve_selector',
          message:
              "rule '${owner.header.label}' references unknown regex slot "
              "'$authored' in rule '${target.label}'",
          spec: spec,
          rule: owner,
          line: element.line,
          fields: {'target_rule': target.label, 'authored_selector': authored},
        );
      }
    case 'numeric':
      final regexCount = _regexCount(targetRule);
      if (target.index < 0 || target.index >= regexCount) {
        throw _gapDiagnostic(
          code: 'regex_slot_index_out_of_range',
          stage: 'resolve_selector',
          message:
              "rule '${owner.header.label}' references rule "
              "'${target.label}' regex slot ${target.index}, but that rule "
              'has $regexCount regex slot(s)',
          spec: spec,
          rule: owner,
          line: element.line,
          fields: {
            'target_rule': target.label,
            'regex_index': target.index,
            'regex_count': regexCount,
          },
        );
      }
    case 'unindexed':
      _checkTarget(
        owner,
        rulesByLabel,
        target.label,
        target.index,
        regexSlotIdentity: true,
      );
  }
}

int? _regexSlotIndex(Rule rule, Object? slotId) {
  var index = 0;
  for (final element in rule.body) {
    final kind = element.kind;
    if (kind is! RegexBodyElementKind) {
      continue;
    }
    if (kind.slotId == slotId) {
      return index;
    }
    index += 1;
  }
  return null;
}

void _checkTarget(
  Rule owner,
  Map<String, Rule> rulesByLabel,
  String target,
  int index, {
  bool regexSlotIdentity = false,
}) {
  final targetRule = rulesByLabel[target];
  if (targetRule == null) {
    final message =
        "rule '${owner.header.label}' references undefined rule '$target'";
    if (!regexSlotIdentity) {
      throw SpecValidationException(message);
    }
    throw SpecValidationException(
      message,
      diagnostic: SpecPortableDiagnostic(
        code: 'regex_slot_identity_invalid',
        stage: 'validate_compiled_rule',
        message: message,
        fields: {
          'rule_label': owner.header.label,
          'target_rule': target,
          'regex_index': index,
        },
      ),
    );
  }

  final regexCount = _regexCount(targetRule);
  if (index < 0 || index >= regexCount) {
    final message =
        "rule '${owner.header.label}' references rule '$target' regex slot "
        '$index, but that rule has $regexCount regex slot(s)';
    if (!regexSlotIdentity) {
      throw SpecValidationException(message);
    }
    throw SpecValidationException(
      message,
      diagnostic: SpecPortableDiagnostic(
        code: 'regex_slot_identity_invalid',
        stage: 'validate_compiled_rule',
        message: message,
        fields: {
          'rule_label': owner.header.label,
          'target_rule': target,
          'regex_index': index,
        },
      ),
    );
  }
}

int _regexCount(Rule rule) {
  var count = 0;
  for (final element in rule.body) {
    if (element.kind is RegexBodyElementKind) {
      count += 1;
    }
  }
  return count;
}

void _checkRegexSyntax(SpecFile spec) {
  for (final rule in spec.rules) {
    for (final element in rule.body) {
      final kind = element.kind;
      if (kind is! RegexBodyElementKind) {
        continue;
      }
      final problem = _regexStructuralProblem(kind.pattern);
      if (problem != null) {
        throw SpecValidationException(
          "rule '${rule.header.label}': invalid regex pattern "
          "'/${kind.pattern}/': $problem",
        );
      }
    }
  }
}

String? _regexStructuralProblem(String pattern) {
  var escaped = false;
  var inClass = false;
  var parenDepth = 0;

  for (var index = 0; index < pattern.length; index += 1) {
    final code = pattern.codeUnitAt(index);
    if (escaped) {
      escaped = false;
      continue;
    }
    if (code == _backslash) {
      escaped = true;
      continue;
    }

    if (inClass) {
      if (code == _closeBracket) {
        inClass = false;
      }
      continue;
    }

    if (code == _openBracket) {
      inClass = true;
    } else if (code == _openParen) {
      parenDepth += 1;
    } else if (code == _closeParen) {
      parenDepth -= 1;
      if (parenDepth < 0) {
        return 'unmatched closing parenthesis';
      }
    }
  }

  if (escaped) {
    return 'dangling escape';
  }
  if (inClass) {
    return 'unclosed character class';
  }
  if (parenDepth != 0) {
    return 'unbalanced parentheses';
  }
  return null;
}

void _checkUnusedRules(SpecFile spec) {
  final used = <String>{};
  for (final rule in spec.rules) {
    for (final element in rule.body) {
      switch (element.kind) {
        case ActionEdgeBodyElementKind(:final targets):
          used.addAll(targets.map((target) => target.label));
        case BlindEdgeBodyElementKind(:final target):
          used.add(target);
        case BareEdgeBodyElementKind(:final targets):
          used.addAll(targets.map((target) => target.label));
        default:
          break;
      }
    }
  }

  final unused = [
    for (final rule in spec.rules)
      if (!used.contains(rule.header.label)) rule.header.label,
  ];
  if (unused.isNotEmpty) {
    throw SpecValidationException(
      'unused rule(s) in strict mode: ${unused.join(", ")}',
    );
  }
}

bool _isIdentifier(String value) {
  if (value.isEmpty) {
    return false;
  }
  final first = value.codeUnitAt(0);
  if (!_isAsciiAlphabetic(first) && first != _underscore) {
    return false;
  }
  for (var index = 1; index < value.length; index += 1) {
    final code = value.codeUnitAt(index);
    if (!_isAsciiAlphaNumeric(code) && code != _underscore) {
      return false;
    }
  }
  return true;
}

bool _isFunctionKeyword(String name) => name == 'fn' || name == 'return';

bool _isLifecycleMarkerName(String name) {
  return name == 'I' ||
      name == 'LS' ||
      name == 'LE' ||
      name == 'E' ||
      name == 'EX' ||
      name == 'IT' ||
      name == 'LX';
}

bool _isReservedRuntimeSymbol(String name) =>
    _reservedRuntimeSymbols.contains(name);

bool _isAsciiAlphaNumeric(int code) {
  return _isAsciiAlphabetic(code) || (code >= _zero && code <= _nine);
}

bool _isAsciiDigitOnly(String value) {
  if (value.isEmpty) {
    return false;
  }
  for (final code in value.codeUnits) {
    if (code < _zero || code > _nine) {
      return false;
    }
  }
  return true;
}

bool _isAsciiAlphabetic(int code) {
  return (code >= _uppercaseA && code <= _uppercaseZ) ||
      (code >= _lowercaseA && code <= _lowercaseZ);
}

const _reservedRuntimeSymbols = {
  'STRING',
  'descr',
  'minfo',
  'LSPOS',
  'LEPOS',
  'LMATCH',
  'LSMATCH',
  'IMATCH',
  'IMATCH_LIST',
  'LMATCH_LIST',
  'IMATCH_HASH',
  'LMATCH_HASH',
  'SELF',
  'this',
  'ctx',
  'runtime_ctx',
};

const _backslash = 0x5c;
const _openParen = 0x28;
const _closeParen = 0x29;
const _openBracket = 0x5b;
const _closeBracket = 0x5d;
const _zero = 0x30;
const _nine = 0x39;
const _uppercaseA = 0x41;
const _uppercaseZ = 0x5a;
const _lowercaseA = 0x61;
const _lowercaseZ = 0x7a;
const _underscore = 0x5f;
