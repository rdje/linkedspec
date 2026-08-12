import 'action_ast.dart';
import 'function_registry.dart';

final class ActionContractResolution {
  const ActionContractResolution({
    required this.contracts,
    required this.diagnostics,
  });

  final List<ActionResolvedContract> contracts;
  final List<ActionContractDiagnostic> diagnostics;

  bool get ok => diagnostics.isEmpty;

  ActionJsonObject toJson() {
    return {
      'ok': ok,
      'contracts': [for (final contract in contracts) contract.toJson()],
      'diagnostics': [
        for (final diagnostic in diagnostics) diagnostic.toJson(),
      ],
    };
  }
}

final class ActionResolvedContract {
  const ActionResolvedContract({
    required this.sourceName,
    required this.canonicalName,
    required this.family,
    required this.surface,
    required this.source,
    required this.sourceSpan,
    required this.positionalArgCount,
    required this.keywordArgCount,
  });

  final String sourceName;
  final String canonicalName;
  final String family;
  final String surface;
  final String source;
  final ActionSourceSpan sourceSpan;
  final int positionalArgCount;
  final int keywordArgCount;

  bool get canonicalized => sourceName != canonicalName;

  ActionJsonObject toJson() {
    return {
      'source_name': sourceName,
      'canonical_name': canonicalName,
      'family': family,
      'surface': surface,
      'source': source,
      'source_span': sourceSpan.toJson(),
      'positional_arg_count': positionalArgCount,
      'keyword_arg_count': keywordArgCount,
      if (canonicalized) 'canonicalized': true,
    };
  }
}

final class ActionContractDiagnostic {
  const ActionContractDiagnostic({
    required this.code,
    required this.message,
    required this.source,
    required this.sourceSpan,
    this.helperName,
  });

  final String code;
  final String message;
  final String source;
  final ActionSourceSpan sourceSpan;
  final String? helperName;

  ActionJsonObject toJson() {
    return {
      'code': code,
      'message': message,
      'source': source,
      'source_span': sourceSpan.toJson(),
      if (helperName != null) 'helper_name': helperName,
    };
  }
}

ActionContractResolution resolveActionBlockContracts(
  ActionBlock block, {
  UserFunctionRegistry? functionRegistry,
}) {
  final resolver = _ActionContractResolver(functionRegistry: functionRegistry);
  resolver.visitBlock(block);
  return resolver.finish();
}

ActionContractResolution resolveActionStatementContracts(
  ActionStatement statement, {
  UserFunctionRegistry? functionRegistry,
}) {
  final resolver = _ActionContractResolver(functionRegistry: functionRegistry);
  resolver.visitStatement(statement);
  return resolver.finish();
}

ActionContractResolution resolveActionExpressionContracts(
  ActionExpr expr, {
  UserFunctionRegistry? functionRegistry,
}) {
  final resolver = _ActionContractResolver(functionRegistry: functionRegistry);
  resolver.visitExpr(expr);
  return resolver.finish();
}

String canonicalActionHelperName(String name) {
  return _numericAliasCanonicalNames[name] ??
      _currentAliasCanonicalNames[name] ??
      name;
}

bool isKnownActionIrCallName(String name) {
  return knownActionIrCallNames.contains(name);
}

const knownActionIrCallNames = <String>{
  ...supportedActionIrCallNames,
  ...numericAliasActionIrCallNames,
  ...currentAliasActionIrCallNames,
  ..._sourceBoundaryCompatibilityAliasActionIrCallNames,
};

const completeNamedMarkActionIrCallNames = <String>{
  'clear_mark',
  'mark_col',
  'mark_entry_end',
  'mark_entry_start',
  'mark_line',
  'mark_match_end',
  'mark_match_start',
};

const supportedActionIrCallNames = <String>{
  'and',
  'array',
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
  'capture_slice_col',
  'capture_slice_len',
  'capture_slice_line',
  'capture_slice_pos',
  'capture_slice_until_cursor',
  'capture_slice_until_cursor_len',
  'capture_until_boundary',
  'capture_take',
  'capture_take_between',
  'capture_take_between_len',
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
  'clear_mark',
  'coalesce',
  'coalesce_nonempty',
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
  'entry_end_col',
  'entry_end_line',
  'entry_end_pos',
  'entry_group',
  'entry_groups',
  'entry_has',
  'entry_len',
  'entry_line',
  'entry_map',
  'entry_named',
  'entry_start_col',
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
  'hash',
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
  'map_leaves',
  'mark_capture_slice',
  'mark_col',
  'mark_copy',
  'mark_entry_end',
  'mark_entry_start',
  'mark_exists',
  'mark_here',
  'mark_input_end',
  'mark_input_start',
  'mark_line',
  'mark_match_end',
  'mark_match_start',
  'mark_pos',
  'match_col',
  'match_end_col',
  'match_end_line',
  'match_end_pos',
  'match_group',
  'match_groups',
  'match_has',
  'match_len',
  'match_line',
  'match_map',
  'match_named',
  'match_start_col',
  'match_start_line',
  'match_start_pos',
  'match_text',
  'matches',
  'merge_hash',
  'next',
  'not',
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
  'or',
  'pick_keys',
  'pop_back',
  'pop_front',
  'print',
  'print_each',
  'push',
  'push_back',
  'push_front',
  'reduce_leaves',
  'rename_key',
  'replace_substr',
  'return',
  'return_undef',
  'restore_cursor',
  'rewind_entry_start',
  'rewind_match_start',
  'reversed',
  'rm_prefix',
  'rm_suffix',
  'say',
  'save_cursor',
  'set',
  'set_key',
  'slice',
  'sorted',
  'sorted_keys',
  'sorted_values',
  'split',
  'split_each',
  'split_tagged_records',
  'start_capture_slice',
  'start_capture_slice_from',
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
  'walk_leaves',
  'while',
  'with',
};

const numericAliasActionIrCallNames = <String>{
  '+',
  '-',
  '*',
  '/',
  '%',
  '==',
  '!=',
  '>',
  '>=',
  '<',
  '<=',
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

const currentAliasActionIrCallNames = <String>{
  '=',
  'elif',
  'i',
  'otherwise',
  'when',
};

const _sourceBoundaryCompatibilityAliasActionIrCallNames = <String>{
  'capture_from_rule_start',
  'capture_len_from_rule_start',
  'capture_rest_length',
  'capture_slice_here',
  'capture_slice_length',
  'entry_named_map',
  'match_named_map',
};

const _numericAliasCanonicalNames = <String, String>{
  '+': 'num_add',
  '-': 'num_sub',
  '*': 'num_mul',
  '/': 'num_div',
  '%': 'num_mod',
  '==': 'num_eq',
  '!=': 'num_ne',
  '>': 'num_gt',
  '>=': 'num_ge',
  '<': 'num_lt',
  '<=': 'num_le',
  'abs': 'num_abs',
  'add': 'num_add',
  'avg': 'num_avg',
  'ceil': 'num_ceil',
  'clamp': 'num_clamp',
  'div': 'num_div',
  'eq': 'num_eq',
  'floor': 'num_floor',
  'ge': 'num_ge',
  'gt': 'num_gt',
  'le': 'num_le',
  'lt': 'num_lt',
  'max': 'num_max',
  'median': 'num_median',
  'min': 'num_min',
  'mod': 'num_mod',
  'mul': 'num_mul',
  'ne': 'num_ne',
  'range': 'num_range',
  'round': 'num_round',
  'sub': 'num_sub',
  'sum': 'num_sum',
};

const _currentAliasCanonicalNames = <String, String>{
  '=': 'set',
  'capture_from_rule_start': 'capture_slice',
  'capture_len_from_rule_start': 'capture_slice_len',
  'capture_rest_length': 'capture_rest_len',
  'capture_slice_here': 'start_capture_slice',
  'capture_slice_length': 'capture_slice_len',
  'elif': 'elseif',
  'entry_named_map': 'entry_map',
  'i': 'if',
  'match_named_map': 'match_map',
  'otherwise': 'else',
  'when': 'if',
};

const _stringHelpers = <String>{
  'cat',
  'coalesce',
  'coalesce_nonempty',
  'contains_substr',
  'ends_with',
  'length',
  'lowercase',
  'matches',
  'replace_substr',
  'rm_prefix',
  'rm_suffix',
  'starts_with',
  'substr',
  'trim',
  'uppercase',
};

const _arrayHelpers = <String>{
  'array',
  'concat_arrays',
  'contains',
  'copy',
  'count',
  'drop_back',
  'drop_front',
  'filter_match',
  'filter_nonempty',
  'first',
  'flat',
  'flat_array',
  'index_of',
  'is_empty',
  'is_nonempty',
  'join_values',
  'last',
  'lowercase_each',
  'pop_back',
  'pop_front',
  'push',
  'push_back',
  'push_front',
  'reversed',
  'slice',
  'sorted',
  'split',
  'split_each',
  'split_tagged_records',
  'take',
  'take_last',
  'trim_each',
  'uniq',
  'uppercase_each',
  'walk_leaves',
  'map_leaves',
  'reduce_leaves',
};

const _hashHelpers = <String>{
  'copy',
  'count_keys',
  'drop_keys',
  'flat',
  'flat_hash',
  'has_key',
  'hash',
  'merge_hash',
  'pick_keys',
  'rename_key',
  'set_key',
  'sorted_keys',
  'sorted_values',
  'walk_leaves',
  'map_leaves',
  'reduce_leaves',
};

const _controlHelpers = <String>{
  'and',
  'case',
  'call',
  'default',
  'else',
  'elseif',
  'endcase',
  'endif',
  'endswitch',
  'exit_now',
  'if',
  'next',
  'not',
  'or',
  'return',
  'return_undef',
  'switch',
  'while',
  'with',
};

const _captureMarkHelpers = <String>{
  'capture_between',
  'capture_from',
  'capture_len_between',
  'capture_len_from',
  'capture_rest',
  'capture_rest_from',
  'capture_rest_len',
  'capture_rest_len_from',
  'capture_slice',
  'capture_slice_col',
  'capture_slice_len',
  'capture_slice_line',
  'capture_slice_pos',
  'capture_slice_until_cursor',
  'capture_slice_until_cursor_len',
  'capture_until_boundary',
  'capture_take',
  'capture_take_between',
  'capture_take_between_len',
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
  'clear_mark',
  'mark_capture_slice',
  'mark_col',
  'mark_copy',
  'mark_entry_end',
  'mark_entry_start',
  'mark_exists',
  'mark_here',
  'mark_input_end',
  'mark_input_start',
  'mark_line',
  'mark_match_end',
  'mark_match_start',
  'mark_pos',
  'start_capture_slice',
  'start_capture_slice_from',
};

const _entryMatchHelpers = <String>{
  'entry_col',
  'entry_end_col',
  'entry_end_line',
  'entry_end_pos',
  'entry_group',
  'entry_groups',
  'entry_has',
  'entry_len',
  'entry_line',
  'entry_map',
  'entry_named',
  'entry_start_col',
  'entry_start_line',
  'entry_start_pos',
  'entry_text',
  'match_col',
  'match_end_col',
  'match_end_line',
  'match_end_pos',
  'match_group',
  'match_groups',
  'match_has',
  'match_len',
  'match_line',
  'match_map',
  'match_named',
  'match_start_col',
  'match_start_line',
  'match_start_pos',
  'match_text',
};

const _inputHelpers = <String>{
  'cursor_col',
  'cursor_line',
  'cursor_pos',
  'cursor_rest',
  'cursor_rest_len',
  'input_end_col',
  'input_end_line',
  'input_end_pos',
  'input_len',
  'input_slice',
  'input_text',
};

const _runtimeHelpers = <String>{
  'restore_cursor',
  'rewind_entry_start',
  'rewind_match_start',
  'save_cursor',
};

const _outputHelpers = <String>{'print', 'print_each', 'say'};

String _familyForCanonical(String canonicalName) {
  if (canonicalName.startsWith('num_')) {
    return 'numeric';
  }
  if (canonicalName.startsWith('str_')) {
    return 'string';
  }
  if (_controlHelpers.contains(canonicalName)) {
    return 'control';
  }
  if (_captureMarkHelpers.contains(canonicalName)) {
    return 'capture_mark';
  }
  if (_entryMatchHelpers.contains(canonicalName)) {
    return 'entry_match';
  }
  if (_inputHelpers.contains(canonicalName)) {
    return 'input_cursor';
  }
  if (_stringHelpers.contains(canonicalName)) {
    return 'string';
  }
  if (_arrayHelpers.contains(canonicalName) &&
      _hashHelpers.contains(canonicalName)) {
    return 'container';
  }
  if (_arrayHelpers.contains(canonicalName)) {
    return 'array';
  }
  if (_hashHelpers.contains(canonicalName)) {
    return 'hash';
  }
  if (_outputHelpers.contains(canonicalName)) {
    return 'output';
  }
  if (_runtimeHelpers.contains(canonicalName)) {
    return 'runtime';
  }
  if (canonicalName == 'set') {
    return 'assignment';
  }
  return 'helper';
}

final class _ActionContractResolver {
  _ActionContractResolver({this.functionRegistry});

  final UserFunctionRegistry? functionRegistry;
  final List<ActionResolvedContract> _contracts = [];
  final List<ActionContractDiagnostic> _diagnostics = [];

  ActionContractResolution finish() {
    return ActionContractResolution(
      contracts: List.unmodifiable(_contracts),
      diagnostics: List.unmodifiable(_diagnostics),
    );
  }

  void visitBlock(ActionBlock block) {
    for (final statement in block.statements) {
      visitStatement(statement);
    }
  }

  void visitStatement(ActionStatement statement) {
    visitExpr(statement.expr);
  }

  void visitExpr(ActionExpr expr) {
    switch (expr) {
      case ActionCallExpr(:final name, :final args):
        _resolveHelperCall(
          name: name,
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          surface: 'function',
          args: args,
        );
        _visitArgs(args);
      case ActionRecognitionCheckpointExpr():
      case ActionRecognizeOnceExpr():
      case ActionRecognitionCommitExpr():
      case ActionRecognitionRollbackExpr():
      case ActionObserveRecognitionExpr():
        // Grammar-owned recognition intrinsics are dedicated ActionIR nodes,
        // not entries in the ordinary callable-helper registry.
        break;
      case ActionFluentChainExpr(:final receiver, :final calls):
        visitExpr(receiver);
        for (final call in calls) {
          _resolveHelperCall(
            name: call.method,
            source: call.source,
            sourceSpan: call.sourceSpan,
            surface: 'receiver_method',
            args: call.args,
          );
          _visitArgs(call.args);
        }
      case ActionAssignScalarExpr(:final value):
        _recordStructuralContract(
          sourceName: '=',
          canonicalName: 'set',
          family: 'assignment',
          surface: 'assignment',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: 2,
        );
        visitExpr(value);
      case ActionAssignArrayAppendExpr(:final value):
        _recordStructuralContract(
          sourceName: '+=',
          canonicalName: 'push',
          family: 'array',
          surface: 'assignment',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: 2,
        );
        visitExpr(value);
      case ActionAssignHashIndexExpr(:final key, :final value):
        _recordStructuralContract(
          sourceName: '[]=',
          canonicalName: 'set_key',
          family: 'hash',
          surface: 'assignment',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: 3,
        );
        visitExpr(key);
        visitExpr(value);
      case ActionAssignNestedAccessExpr(:final segments, :final value):
        _recordStructuralContract(
          sourceName: 'nested_access=',
          canonicalName: 'nested_access_assignment',
          family: 'assignment',
          surface: 'assignment',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: 2,
        );
        _visitAccessSegments(segments);
        visitExpr(value);
      case ActionBlockValueExpr(:final block):
        visitBlock(block);
      case ActionContextualCodeblockCandidateExpr():
      case ActionCodeblockArgumentExpr():
      case ActionCodeblockLiteralExpr():
        // Callable bodies are retained state. Construction must not resolve
        // their helpers or dependencies eagerly.
        break;
      case ActionCodeblockLiteralErrorExpr(:final code):
        _diagnostics.add(
          ActionContractDiagnostic(
            code: code,
            message: 'invalid callable-codeblock literal: $code',
            source: expr.source,
            sourceSpan: expr.sourceSpan,
          ),
        );
      case ActionArrayLiteralExpr(:final items):
        for (final item in items) {
          visitExpr(item);
        }
      case ActionHashLiteralExpr(:final entries):
        for (final entry in entries) {
          visitExpr(entry.key);
          visitExpr(entry.value);
        }
      case ActionIndexedVarExpr(:final index):
        visitExpr(index);
      case ActionNestedAccessExpr(:final segments):
        _visitAccessSegments(segments);
      case ActionValueAccessExpr(:final receiver, :final segments):
        visitExpr(receiver);
        _visitAccessSegments(segments);
      case ActionControlIfExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (body != null) {
          visitBlock(body);
        }
      case ActionControlElseExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (body != null) {
          visitBlock(body);
        }
      case ActionControlMarkerExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
      case ActionControlWhileExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (body != null) {
          visitBlock(body);
        }
      case ActionControlSwitchExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final cases,
        :final defaultCase,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (cases.isNotEmpty || defaultCase != null) {
          for (final item in cases) {
            visitExpr(item);
          }
          if (defaultCase != null) {
            visitExpr(defaultCase);
          }
        } else if (body != null) {
          visitBlock(body);
        }
      case ActionControlCaseExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (body != null) {
          visitBlock(body);
        }
      case ActionControlDefaultExpr(
        :final canonicalKeyword,
        :final keyword,
        :final args,
        :final body,
      ):
        _recordStructuralContract(
          sourceName: keyword,
          canonicalName: canonicalKeyword,
          family: 'control',
          surface: 'control',
          source: expr.source,
          sourceSpan: expr.sourceSpan,
          positionalArgCount: _positionalArgCount(args),
          keywordArgCount: _keywordArgCount(args),
        );
        _visitArgs(args);
        if (body != null) {
          visitBlock(body);
        }
      case ActionRawExpr(:final reason):
        _diagnostics.add(
          ActionContractDiagnostic(
            code: 'raw_perl',
            message:
                'unsupported ActionIR expression remains raw_perl: $reason',
            source: expr.source,
            sourceSpan: expr.sourceSpan,
          ),
        );
      case ActionVariableExpr():
      case ActionStringLiteralExpr():
      case ActionNumberLiteralExpr():
      case ActionBooleanLiteralExpr():
      case ActionRegexLiteralExpr():
      case ActionUndefExpr():
        break;
    }
  }

  void _resolveHelperCall({
    required String name,
    required String source,
    required ActionSourceSpan sourceSpan,
    required String surface,
    required List<ActionArgument> args,
  }) {
    final positionalArgCount = _positionalArgCount(args);
    final keywordArgCount = _keywordArgCount(args);
    final registry = functionRegistry;
    if (surface == 'function' && registry != null) {
      if (registry.hasName(name) && keywordArgCount > 0) {
        _diagnostics.add(
          ActionContractDiagnostic(
            code: 'user_function_keyword_arguments_unsupported',
            message:
                "user function '$name' accepts positional arguments only, "
                'got $keywordArgCount keyword argument(s)',
            helperName: name,
            source: source,
            sourceSpan: sourceSpan,
          ),
        );
        return;
      }
      final resolution = registry.resolveCall(name, positionalArgCount);
      if (resolution.matched) {
        _contracts.add(
          ActionResolvedContract(
            sourceName: name,
            canonicalName: name,
            family: 'user_function',
            surface: surface,
            source: source,
            sourceSpan: sourceSpan,
            positionalArgCount: positionalArgCount,
            keywordArgCount: keywordArgCount,
          ),
        );
        return;
      }
      if (resolution.arityMismatch) {
        final registered = registry.lookup(name)!;
        final expectation = registered.signature == null
            ? 'arity ${registered.arity}'
            : registered.arityExpectation;
        _diagnostics.add(
          ActionContractDiagnostic(
            code: 'user_function_arity_mismatch',
            message:
                "user function '$name' expects "
                '$expectation, got $positionalArgCount',
            helperName: name,
            source: source,
            sourceSpan: sourceSpan,
          ),
        );
        return;
      }
    }

    if (!isKnownActionIrCallName(name)) {
      _diagnostics.add(
        ActionContractDiagnostic(
          code: 'unknown_helper',
          message:
              "unknown helper '$name' is not part of the canonical ActionIR helper contract",
          helperName: name,
          source: source,
          sourceSpan: sourceSpan,
        ),
      );
      return;
    }
    final canonicalName = canonicalActionHelperName(name);
    _contracts.add(
      ActionResolvedContract(
        sourceName: name,
        canonicalName: canonicalName,
        family: _familyForCanonical(canonicalName),
        surface: surface,
        source: source,
        sourceSpan: sourceSpan,
        positionalArgCount: positionalArgCount,
        keywordArgCount: keywordArgCount,
      ),
    );
  }

  void _recordStructuralContract({
    required String sourceName,
    required String canonicalName,
    required String family,
    required String surface,
    required String source,
    required ActionSourceSpan sourceSpan,
    required int positionalArgCount,
    int keywordArgCount = 0,
  }) {
    _contracts.add(
      ActionResolvedContract(
        sourceName: sourceName,
        canonicalName: canonicalName,
        family: family,
        surface: surface,
        source: source,
        sourceSpan: sourceSpan,
        positionalArgCount: positionalArgCount,
        keywordArgCount: keywordArgCount,
      ),
    );
  }

  void _visitArgs(List<ActionArgument> args) {
    for (final arg in args) {
      visitExpr(arg.value);
    }
  }

  void _visitAccessSegments(List<ActionAccessSegment> segments) {
    for (final segment in segments) {
      if (segment is ActionIndexAccessSegment) {
        visitExpr(segment.expr);
      }
    }
  }
}

int _positionalArgCount(List<ActionArgument> args) {
  var count = 0;
  for (final arg in args) {
    if (arg is ActionPositionalArgument) {
      count += 1;
    }
  }
  return count;
}

int _keywordArgCount(List<ActionArgument> args) {
  var count = 0;
  for (final arg in args) {
    if (arg is ActionKeywordArgument) {
      count += 1;
    }
  }
  return count;
}
