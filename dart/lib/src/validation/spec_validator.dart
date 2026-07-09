import '../ast/spec_ast.dart';

final class SpecValidationException implements Exception {
  const SpecValidationException(this.message);

  final String message;

  @override
  String toString() => 'SpecValidationException: $message';
}

void validateSpec(SpecFile spec, {bool strictSyntax = false}) {
  _checkTopRuleExists(spec);
  _checkDuplicateRuleLabels(spec);
  _checkDuplicateFunctionNames(spec);
  _checkFunctionRegistry(spec);
  _checkMalformedRawBodyLines(spec);
  _checkMixedEdges(spec);
  _checkGroupedActionEdges(spec);
  _checkEdgeTargets(spec);
  _checkRegexSyntax(spec);
  if (strictSyntax) {
    _checkUnusedRules(spec);
  }
}

void _checkTopRuleExists(SpecFile spec) {
  if (spec.rules.any((rule) => rule.header.isTop)) {
    return;
  }
  throw const SpecValidationException(
    "no top rule found: at least one rule must use '::' (double colon)",
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
    if (_isFunctionKeyword(name) || _knownActionIrCallNames.contains(name)) {
      throw SpecValidationException(
        "user function '$name' collides with built-in helper/control name '$name'",
      );
    }

    final seenParams = <String>{};
    for (final param in function.params) {
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
        default:
          break;
      }
    }
    if (hasAction && hasBlind) {
      throw SpecValidationException(
        "rule '${rule.header.label}' mixes action (->) and blind-call (=>) edges",
      );
    }
  }
}

void _checkGroupedActionEdges(SpecFile spec) {
  for (final rule in spec.rules) {
    for (final element in rule.body) {
      final kind = element.kind;
      if (kind is ActionEdgeBodyElementKind &&
          kind.targets.length > 1 &&
          kind.code == null) {
        throw SpecValidationException(
          "rule '${rule.header.label}': grouped action-edge targets require "
          'a shared code block',
        );
      }
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
            _checkTarget(rule, rulesByLabel, target.label, target.index);
          }
        case BlindEdgeBodyElementKind(:final target):
          _checkTarget(rule, rulesByLabel, target, 0);
        default:
          break;
      }
    }
  }
}

void _checkTarget(
  Rule owner,
  Map<String, Rule> rulesByLabel,
  String target,
  int index,
) {
  final targetRule = rulesByLabel[target];
  if (targetRule == null) {
    throw SpecValidationException(
      "rule '${owner.header.label}' references undefined rule '$target'",
    );
  }

  final regexCount = _regexCount(targetRule);
  if (index < 0 || index >= regexCount) {
    throw SpecValidationException(
      "rule '${owner.header.label}' references rule '$target' regex slot "
      '$index, but that rule has $regexCount regex slot(s)',
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

const _knownActionIrCallNames = {
  ..._numericWordAliasNames,
  'a',
  'and',
  'array',
  'array_copy',
  'assign',
  'BACKTRACK',
  'call',
  'capture_between',
  'capture_from',
  'capture_len_between',
  'capture_len_from',
  'capture_rest',
  'capture_rest_from',
  'capture_rest_len',
  'capture_rest_len_from',
  'capture_slice',
  'capture_slice_len',
  'capture_slice_line',
  'capture_slice_pos',
  'capture_slice_until_cursor',
  'capture_slice_until_cursor_len',
  'capture_take',
  'capture_take_len',
  'capture_take_len_from',
  'capture_take_rest',
  'capture_take_rest_from',
  'capture_take_rest_len',
  'capture_take_rest_len_from',
  'capture_take_until_cursor',
  'capture_take_until_cursor_from',
  'capture_take_until_cursor_len',
  'capture_take_until_cursor_len_from',
  'capture_until_cursor_from',
  'capture_until_cursor_len_from',
  'case',
  'cat',
  'coalesce',
  'coalesce_nonempty',
  'concat',
  'concat_arrays',
  'contains',
  'contains_substr',
  'copy',
  'count',
  'count_keys',
  'cursor_col',
  'cursor_line',
  'cursor_pos',
  'cursor_rest',
  'cursor_rest_len',
  'declare',
  'default',
  'drop_back',
  'drop_front',
  'drop_keys',
  'else',
  'elseif',
  'endcase',
  'endif',
  'ends_with',
  'endswitch',
  'entry_col',
  'entry_end_pos',
  'entry_group',
  'entry_groups',
  'entry_has',
  'entry_len',
  'entry_line',
  'entry_map',
  'entry_named',
  'entry_named_map',
  'entry_start_line',
  'entry_start_pos',
  'entry_text',
  'exit_now',
  'filter_match',
  'filter_nonempty',
  'first',
  'flat',
  'flat_array',
  'flat_hash',
  'has_key',
  'h',
  'hash',
  'hash_copy',
  'IBACKTRACK',
  'if',
  'index_of',
  'input_end_col',
  'input_end_line',
  'input_end_pos',
  'input_len',
  'input_slice',
  'input_text',
  'is_defined',
  'is_empty',
  'is_nonempty',
  'is_undefined',
  'join_values',
  'last',
  'length',
  'lowercase',
  'lowercase_each',
  'mark_copy',
  'mark_exists',
  'mark_here',
  'mark_input_end',
  'mark_input_start',
  'mark_pos',
  'match_col',
  'match_end_pos',
  'match_group',
  'match_groups',
  'match_has',
  'match_len',
  'match_line',
  'match_map',
  'match_named',
  'match_named_map',
  'match_start_pos',
  'match_text',
  'matches',
  'merge_hash',
  'next',
  'not',
  'or',
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
  'otherwise',
  'pick_keys',
  'print',
  'print_each',
  'push',
  'push_nonempty',
  'push_value',
  'rename_key',
  'replace_substr',
  'return',
  'return_undef',
  'reversed',
  'rm_prefix',
  'rm_suffix',
  'say',
  'set',
  'set_key',
  'slice',
  'sorted',
  'sorted_keys',
  'sorted_values',
  'split',
  'split_each',
  'start_capture_slice',
  'starts_with',
  'str_eq',
  'str_ge',
  'str_gt',
  'str_le',
  'str_lt',
  'str_ne',
  'substr',
  'switch',
  'take',
  'take_last',
  'trim',
  'trim_each',
  'uniq',
  'uppercase',
  'uppercase_each',
  'when',
  'with',
  'while',
};

const _numericWordAliasNames = {
  'abs',
  'add',
  'avg',
  'ceil',
  'clamp',
  'div',
  'eq',
  'floor',
  'ge',
  'gt',
  'le',
  'lt',
  'max',
  'median',
  'min',
  'mod',
  'mul',
  'ne',
  'range',
  'round',
  'sub',
  'sum',
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
