import '../ast/spec_ast.dart' show CallableSignature;

typedef ActionJsonObject = Map<String, Object?>;

final class ActionSourceSpan {
  const ActionSourceSpan({required this.start, required this.end});

  final int start;
  final int end;

  ActionJsonObject toJson() => {'start': start, 'end': end};
}

abstract base class ActionNode {
  const ActionNode({
    required this.kind,
    required this.source,
    required this.sourceSpan,
  });

  final String kind;
  final String source;
  final ActionSourceSpan sourceSpan;

  ActionJsonObject baseJson() {
    return {'kind': kind, 'source': source, 'source_span': sourceSpan.toJson()};
  }

  ActionJsonObject toJson();
}

final class ActionBlock extends ActionNode {
  const ActionBlock({
    required super.source,
    required super.sourceSpan,
    required this.statements,
  }) : super(kind: 'action_block');

  final List<ActionStatement> statements;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'statements': [for (final statement in statements) statement.toJson()],
    };
  }
}

final class ActionStatement extends ActionNode {
  const ActionStatement({
    required super.source,
    required super.sourceSpan,
    required this.expr,
    this.dropsValue = true,
  }) : super(kind: 'action_stmt');

  final ActionExpr expr;
  final bool dropsValue;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'expr': expr.toJson(), 'drops_value': dropsValue};
  }
}

abstract base class ActionExpr extends ActionNode {
  const ActionExpr({
    required super.kind,
    required super.source,
    required super.sourceSpan,
  });
}

sealed class ActionArgument {
  const ActionArgument();

  ActionExpr get value;

  Object toJson();
}

final class ActionPositionalArgument extends ActionArgument {
  const ActionPositionalArgument(this.value);

  @override
  final ActionExpr value;

  @override
  Object toJson() => value.toJson();
}

final class ActionKeywordArgument extends ActionArgument {
  const ActionKeywordArgument({required this.name, required this.value});

  final String name;

  @override
  final ActionExpr value;

  @override
  ActionJsonObject toJson() => {'name': name, 'value': value.toJson()};
}

final class ActionCallExpr extends ActionExpr {
  const ActionCallExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
    required this.args,
    this.sourceMethod,
    this.trailingBlockArg = false,
    this.trailingBlockSourceSpan,
  }) : super(kind: 'call');

  final String name;
  final List<ActionArgument> args;
  final String? sourceMethod;
  final bool trailingBlockArg;
  final ActionSourceSpan? trailingBlockSourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'name': name,
      if (sourceMethod != null) 'source_method': sourceMethod,
      'args': [for (final arg in args) arg.toJson()],
      if (trailingBlockArg) 'trailing_block_arg': true,
      if (trailingBlockSourceSpan != null)
        'trailing_block_source_span': trailingBlockSourceSpan!.toJson(),
    };
  }
}

/// Creates one rule-local opaque recognition-transaction token.
final class ActionRecognitionCheckpointExpr extends ActionExpr {
  const ActionRecognitionCheckpointExpr({
    required super.source,
    required super.sourceSpan,
  }) : super(kind: 'recognition_checkpoint');

  @override
  ActionJsonObject toJson() => baseJson();
}

/// Performs one non-eager recognition attempt against a static child rule.
final class ActionRecognizeOnceExpr extends ActionExpr {
  const ActionRecognizeOnceExpr({
    required super.source,
    required super.sourceSpan,
    required this.token,
    required this.rule,
  }) : super(kind: 'recognize_once');

  final String token;
  final String rule;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'token': token, 'rule': rule};
}

/// Commits one attempted token and returns its staged payload.
final class ActionRecognitionCommitExpr extends ActionExpr {
  const ActionRecognitionCommitExpr({
    required super.source,
    required super.sourceSpan,
    required this.token,
  }) : super(kind: 'recognition_commit');

  final String token;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'token': token};
}

/// Restores one attempted token's checkpoint and invalidates the token.
final class ActionRecognitionRollbackExpr extends ActionExpr {
  const ActionRecognitionRollbackExpr({
    required super.source,
    required super.sourceSpan,
    required this.token,
  }) : super(kind: 'recognition_rollback');

  final String token;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'token': token};
}

final class ActionVariableExpr extends ActionExpr {
  const ActionVariableExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
  }) : super(kind: 'variable');

  final String name;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'name': name};
}

final class ActionIndexedVarExpr extends ActionExpr {
  const ActionIndexedVarExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
    required this.index,
  }) : super(kind: 'indexed_var');

  final String name;
  final ActionExpr index;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'name': name, 'index': index.toJson()};
  }
}

sealed class ActionAccessSegment {
  const ActionAccessSegment({required this.kind, required this.sourceSpan});

  final String kind;
  final ActionSourceSpan sourceSpan;

  ActionJsonObject toJson();
}

final class ActionKeyAccessSegment extends ActionAccessSegment {
  const ActionKeyAccessSegment({
    required this.value,
    required this.source,
    required super.sourceSpan,
  }) : super(kind: 'key');

  final String value;
  final String source;

  @override
  ActionJsonObject toJson() {
    return {
      'kind': kind,
      'value': value,
      'source': source,
      'source_span': sourceSpan.toJson(),
    };
  }
}

final class ActionIndexAccessSegment extends ActionAccessSegment {
  const ActionIndexAccessSegment({
    required this.expr,
    required this.source,
    required super.sourceSpan,
  }) : super(kind: 'index');

  final ActionExpr expr;
  final String source;

  @override
  ActionJsonObject toJson() {
    return {
      'kind': kind,
      'expr': expr.toJson(),
      'source': source,
      'source_span': sourceSpan.toJson(),
    };
  }
}

final class ActionNestedAccessExpr extends ActionExpr {
  const ActionNestedAccessExpr({
    required super.source,
    required super.sourceSpan,
    required this.base,
    required this.segments,
  }) : super(kind: 'nested_access');

  final String base;
  final List<ActionAccessSegment> segments;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'base': base,
      'segments': [for (final segment in segments) segment.toJson()],
    };
  }
}

/// A mixed access path whose receiver is an evaluated expression result.
final class ActionValueAccessExpr extends ActionExpr {
  const ActionValueAccessExpr({
    required super.source,
    required super.sourceSpan,
    required this.receiver,
    required this.segments,
  }) : super(kind: 'value_access');

  final ActionExpr receiver;
  final List<ActionAccessSegment> segments;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'receiver': receiver.toJson(),
      'segments': [for (final segment in segments) segment.toJson()],
    };
  }
}

final class ActionArrayLiteralExpr extends ActionExpr {
  const ActionArrayLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.items,
  }) : super(kind: 'array_literal');

  final List<ActionExpr> items;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'items': [for (final item in items) item.toJson()],
    };
  }
}

final class ActionHashLiteralEntry {
  const ActionHashLiteralEntry({required this.key, required this.value});

  final ActionExpr key;
  final ActionExpr value;

  ActionJsonObject toJson() => {'key': key.toJson(), 'value': value.toJson()};
}

final class ActionHashLiteralExpr extends ActionExpr {
  const ActionHashLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.entries,
  }) : super(kind: 'hash_literal');

  final List<ActionHashLiteralEntry> entries;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'entries': [for (final entry in entries) entry.toJson()],
    };
  }
}

final class ActionBlockValueExpr extends ActionExpr {
  const ActionBlockValueExpr({
    required super.source,
    required super.sourceSpan,
    required this.block,
  }) : super(kind: 'block_value');

  final ActionBlock block;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'block': block.toJson()};
}

enum ActionContextualBlockSyntax {
  attached('attached'),
  parenthesized('parenthesized');

  const ActionContextualBlockSyntax(this.wireName);

  final String wireName;
}

/// A structurally recognized block argument awaiting callable metadata.
final class ActionContextualCodeblockCandidateExpr extends ActionExpr {
  const ActionContextualCodeblockCandidateExpr({
    required super.source,
    required super.sourceSpan,
    required this.syntax,
    required this.version,
    required this.signature,
    required this.bodySource,
    required this.bodyAst,
    required this.bodySpan,
  }) : super(kind: 'contextual_codeblock_candidate');

  final ActionContextualBlockSyntax syntax;
  final int version;
  final CallableSignature signature;
  final String bodySource;
  final ActionBlock bodyAst;
  final ActionSourceSpan bodySpan;

  @override
  ActionJsonObject toJson() {
    return {
      'kind': kind,
      'syntax': syntax.wireName,
      'version': version,
      'signature': signature.toJson(),
      'body_source': bodySource,
      'body_ast': bodyAst.toJson(),
      'source_text': source,
      'source_span': sourceSpan.toJson(),
      'body_span': bodySpan.toJson(),
    };
  }
}

/// A metadata-admitted zero-positional contextual final codeblock argument.
final class ActionCodeblockArgumentExpr extends ActionExpr {
  const ActionCodeblockArgumentExpr({
    required super.source,
    required super.sourceSpan,
    required this.version,
    required this.signature,
    required this.bodySource,
    required this.bodyAst,
    required this.bodySpan,
  }) : super(kind: 'codeblock_argument');

  final int version;
  final CallableSignature signature;
  final String bodySource;
  final ActionBlock bodyAst;
  final ActionSourceSpan bodySpan;

  @override
  ActionJsonObject toJson() {
    return {
      'kind': kind,
      'version': version,
      'signature': signature.toJson(),
      'body_source': bodySource,
      'body_ast': bodyAst.toJson(),
      'source_text': source,
      'source_span': sourceSpan.toJson(),
      'body_span': bodySpan.toJson(),
    };
  }
}

/// An inert, serializable callable-codeblock value.
///
/// The body remains typed ActionIR, but construction does not visit or execute
/// it. Invocation is a separate runtime concern.
final class ActionCodeblockLiteralExpr extends ActionExpr {
  const ActionCodeblockLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.version,
    required this.signature,
    required this.bodySource,
    required this.bodyAst,
    required this.bodySpan,
  }) : super(kind: 'codeblock_literal');

  final int version;
  final CallableSignature signature;
  final String bodySource;
  final ActionBlock bodyAst;
  final ActionSourceSpan bodySpan;

  @override
  ActionJsonObject toJson() {
    return {
      'kind': kind,
      'version': version,
      'signature': signature.toJson(),
      'body_source': bodySource,
      'body_ast': bodyAst.toJson(),
      'source_text': source,
      'source_span': sourceSpan.toJson(),
      'body_span': bodySpan.toJson(),
    };
  }
}

/// Stable parser result for a malformed callable-codeblock literal.
final class ActionCodeblockLiteralErrorExpr extends ActionExpr {
  const ActionCodeblockLiteralErrorExpr({
    required super.source,
    required super.sourceSpan,
    required this.code,
  }) : super(kind: 'codeblock_literal_error');

  final String code;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'code': code};
}

final class ActionStringLiteralExpr extends ActionExpr {
  const ActionStringLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.value,
    required this.quote,
  }) : super(kind: 'string');

  final String value;
  final String quote;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'value': value, 'quote': quote};
  }
}

final class ActionNumberLiteralExpr extends ActionExpr {
  const ActionNumberLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.value,
  }) : super(kind: 'number');

  final num value;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'value': value};
}

final class ActionBooleanLiteralExpr extends ActionExpr {
  const ActionBooleanLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.value,
  }) : super(kind: 'boolean');

  final bool value;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'value': value};
}

final class ActionRegexLiteralExpr extends ActionExpr {
  const ActionRegexLiteralExpr({
    required super.source,
    required super.sourceSpan,
    required this.pattern,
    this.flags = '',
  }) : super(kind: 'regex');

  final String pattern;
  final String flags;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'pattern': pattern, 'flags': flags};
  }
}

final class ActionUndefExpr extends ActionExpr {
  const ActionUndefExpr({required super.source, required super.sourceSpan})
    : super(kind: 'undef');

  @override
  ActionJsonObject toJson() => baseJson();
}

final class ActionAssignScalarExpr extends ActionExpr {
  const ActionAssignScalarExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
    required this.value,
  }) : super(kind: 'assign_scalar');

  final String name;
  final ActionExpr value;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'name': name, 'value': value.toJson()};
  }
}

final class ActionAssignArrayAppendExpr extends ActionExpr {
  const ActionAssignArrayAppendExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
    required this.value,
  }) : super(kind: 'assign_array_append');

  final String name;
  final ActionExpr value;

  @override
  ActionJsonObject toJson() {
    return {...baseJson(), 'name': name, 'value': value.toJson()};
  }
}

final class ActionAssignHashIndexExpr extends ActionExpr {
  const ActionAssignHashIndexExpr({
    required super.source,
    required super.sourceSpan,
    required this.name,
    required this.key,
    required this.value,
  }) : super(kind: 'assign_hash_index');

  final String name;
  final ActionExpr key;
  final ActionExpr value;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'name': name,
      'key': key.toJson(),
      'value': value.toJson(),
    };
  }
}

final class ActionAssignNestedAccessExpr extends ActionExpr {
  const ActionAssignNestedAccessExpr({
    required super.source,
    required super.sourceSpan,
    required this.base,
    required this.segments,
    required this.value,
  }) : super(kind: 'assign_nested_access');

  final String base;
  final List<ActionAccessSegment> segments;
  final ActionExpr value;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'base': base,
      'segments': [for (final segment in segments) segment.toJson()],
      'value': value.toJson(),
    };
  }
}

final class ActionFluentCall {
  const ActionFluentCall({
    required this.method,
    required this.args,
    required this.source,
    required this.sourceSpan,
    this.sourceMethod,
    this.trailingBlockArg = false,
    this.receiverTrailingBlockArg = false,
    this.trailingBlockSourceSpan,
  });

  final String method;
  final List<ActionArgument> args;
  final String source;
  final ActionSourceSpan sourceSpan;
  final String? sourceMethod;
  final bool trailingBlockArg;
  final bool receiverTrailingBlockArg;
  final ActionSourceSpan? trailingBlockSourceSpan;

  ActionJsonObject toJson() {
    return {
      'method': method,
      if (sourceMethod != null) 'source_method': sourceMethod,
      'args': [for (final arg in args) arg.toJson()],
      'source': source,
      'source_span': sourceSpan.toJson(),
      if (trailingBlockArg) 'trailing_block_arg': true,
      if (receiverTrailingBlockArg) 'receiver_trailing_block_arg': true,
      if (trailingBlockSourceSpan != null)
        'trailing_block_source_span': trailingBlockSourceSpan!.toJson(),
    };
  }
}

final class ActionFluentChainExpr extends ActionExpr {
  const ActionFluentChainExpr({
    required super.source,
    required super.sourceSpan,
    required this.receiver,
    required this.calls,
  }) : super(kind: 'fluent_chain');

  final ActionExpr receiver;
  final List<ActionFluentCall> calls;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'receiver': receiver.toJson(),
      'calls': [for (final call in calls) call.toJson()],
    };
  }
}

final class ActionControlIfExpr extends ActionExpr {
  const ActionControlIfExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.branchRole,
    required this.condition,
    required this.args,
    this.body,
    this.bodySourceSpan,
  }) : super(kind: 'control_if');

  final String keyword;
  final String canonicalKeyword;
  final String branchRole;
  final ActionExpr condition;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'branch_role': branchRole,
      'condition': condition.toJson(),
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
    };
  }
}

final class ActionControlElseExpr extends ActionExpr {
  const ActionControlElseExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.args,
    this.body,
    this.bodySourceSpan,
  }) : super(kind: 'control_else');

  final String keyword;
  final String canonicalKeyword;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'branch_role': 'else',
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
    };
  }
}

final class ActionControlMarkerExpr extends ActionExpr {
  const ActionControlMarkerExpr({
    required super.kind,
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.args,
  });

  final String keyword;
  final String canonicalKeyword;
  final List<ActionArgument> args;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'args': [for (final arg in args) arg.toJson()],
    };
  }
}

final class ActionControlWhileExpr extends ActionExpr {
  const ActionControlWhileExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.condition,
    required this.args,
    this.body,
    this.bodySourceSpan,
  }) : super(kind: 'control_while');

  final String keyword;
  final String canonicalKeyword;
  final ActionExpr condition;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'condition': condition.toJson(),
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
    };
  }
}

final class ActionControlSwitchExpr extends ActionExpr {
  const ActionControlSwitchExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.sourceExpr,
    required this.args,
    this.body,
    this.bodySourceSpan,
    this.cases = const [],
    this.defaultCase,
  }) : super(kind: 'control_switch');

  final String keyword;
  final String canonicalKeyword;
  final ActionExpr sourceExpr;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;
  final List<ActionControlCaseExpr> cases;
  final ActionControlDefaultExpr? defaultCase;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'source_expr': sourceExpr.toJson(),
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
      if (cases.isNotEmpty) 'cases': [for (final item in cases) item.toJson()],
      if (defaultCase != null) 'default': defaultCase!.toJson(),
    };
  }
}

final class ActionControlCaseExpr extends ActionExpr {
  const ActionControlCaseExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.match,
    required this.args,
    this.body,
    this.bodySourceSpan,
  }) : super(kind: 'control_case');

  final String keyword;
  final String canonicalKeyword;
  final ActionExpr match;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'match': match.toJson(),
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
    };
  }
}

final class ActionControlDefaultExpr extends ActionExpr {
  const ActionControlDefaultExpr({
    required super.source,
    required super.sourceSpan,
    required this.keyword,
    required this.canonicalKeyword,
    required this.args,
    this.body,
    this.bodySourceSpan,
  }) : super(kind: 'control_default');

  final String keyword;
  final String canonicalKeyword;
  final List<ActionArgument> args;
  final ActionBlock? body;
  final ActionSourceSpan? bodySourceSpan;

  @override
  ActionJsonObject toJson() {
    return {
      ...baseJson(),
      'keyword': keyword,
      'canonical_keyword': canonicalKeyword,
      'args': [for (final arg in args) arg.toJson()],
      if (body != null) 'body': body!.toJson(),
      if (bodySourceSpan != null) 'body_source_span': bodySourceSpan!.toJson(),
    };
  }
}

final class ActionRawExpr extends ActionExpr {
  const ActionRawExpr({
    required super.source,
    required super.sourceSpan,
    required this.reason,
  }) : super(kind: 'raw_perl');

  final String reason;

  @override
  ActionJsonObject toJson() => {...baseJson(), 'reason': reason};
}

/// An exact aggregate-selector call removed from the public ActionIR surface.
///
/// Zero-argument, multi-argument, quoted, and computed `array(...)` / `hash(...)`
/// calls remain constructors. Only the former one-bare-identifier selector
/// shape is rejected.
final class RemovedAggregateSelector {
  const RemovedAggregateSelector({
    required this.surface,
    required this.identifier,
  });

  final String surface;
  final String identifier;

  String get diagnostic {
    return 'aggregate_selector_removed surface=$surface '
        'identifier=$identifier replacement=$identifier';
  }

  @override
  String toString() => diagnostic;
}

/// Return the first removed aggregate selector in [block], if any.
RemovedAggregateSelector? findRemovedAggregateSelectorInBlock(
  ActionBlock block,
) {
  for (final statement in block.statements) {
    final selector = findRemovedAggregateSelectorInExpr(statement.expr);
    if (selector != null) {
      return selector;
    }
  }
  return null;
}

/// Return the first removed aggregate selector anywhere below [expr].
RemovedAggregateSelector? findRemovedAggregateSelectorInExpr(ActionExpr expr) {
  RemovedAggregateSelector? inArgs(List<ActionArgument> args) {
    for (final arg in args) {
      final selector = findRemovedAggregateSelectorInExpr(arg.value);
      if (selector != null) {
        return selector;
      }
    }
    return null;
  }

  RemovedAggregateSelector? inBlock(ActionBlock? block) {
    return block == null ? null : findRemovedAggregateSelectorInBlock(block);
  }

  RemovedAggregateSelector? inSegments(List<ActionAccessSegment> segments) {
    for (final segment in segments) {
      if (segment is ActionIndexAccessSegment) {
        final selector = findRemovedAggregateSelectorInExpr(segment.expr);
        if (selector != null) {
          return selector;
        }
      }
    }
    return null;
  }

  switch (expr) {
    case ActionCallExpr(:final name, :final args):
      if ((name == 'array' || name == 'hash') && args.length == 1) {
        final arg = args.single;
        if (arg is ActionPositionalArgument &&
            arg.value is ActionVariableExpr) {
          return RemovedAggregateSelector(
            surface: name,
            identifier: (arg.value as ActionVariableExpr).name,
          );
        }
      }
      return inArgs(args);
    case ActionRecognitionCheckpointExpr():
    case ActionRecognizeOnceExpr():
    case ActionRecognitionCommitExpr():
    case ActionRecognitionRollbackExpr():
      return null;
    case ActionFluentChainExpr(:final receiver, :final calls):
      final receiverSelector = findRemovedAggregateSelectorInExpr(receiver);
      if (receiverSelector != null) {
        return receiverSelector;
      }
      for (final call in calls) {
        final selector = inArgs(call.args);
        if (selector != null) {
          return selector;
        }
      }
      return null;
    case ActionAssignScalarExpr(:final value):
    case ActionAssignArrayAppendExpr(:final value):
      return findRemovedAggregateSelectorInExpr(value);
    case ActionAssignHashIndexExpr(:final key, :final value):
      return findRemovedAggregateSelectorInExpr(key) ??
          findRemovedAggregateSelectorInExpr(value);
    case ActionAssignNestedAccessExpr(:final segments, :final value):
      return inSegments(segments) ?? findRemovedAggregateSelectorInExpr(value);
    case ActionIndexedVarExpr(:final index):
      return findRemovedAggregateSelectorInExpr(index);
    case ActionNestedAccessExpr(:final segments):
      return inSegments(segments);
    case ActionValueAccessExpr(:final receiver, :final segments):
      return findRemovedAggregateSelectorInExpr(receiver) ??
          inSegments(segments);
    case ActionArrayLiteralExpr(:final items):
      for (final item in items) {
        final selector = findRemovedAggregateSelectorInExpr(item);
        if (selector != null) {
          return selector;
        }
      }
      return null;
    case ActionHashLiteralExpr(:final entries):
      for (final entry in entries) {
        final selector =
            findRemovedAggregateSelectorInExpr(entry.key) ??
            findRemovedAggregateSelectorInExpr(entry.value);
        if (selector != null) {
          return selector;
        }
      }
      return null;
    case ActionBlockValueExpr(:final block):
      return findRemovedAggregateSelectorInBlock(block);
    case ActionContextualCodeblockCandidateExpr():
    case ActionCodeblockArgumentExpr():
    case ActionCodeblockLiteralExpr():
    case ActionCodeblockLiteralErrorExpr():
      return null;
    case ActionControlIfExpr(:final condition, :final args, :final body):
      return findRemovedAggregateSelectorInExpr(condition) ??
          inArgs(args) ??
          inBlock(body);
    case ActionControlElseExpr(:final args, :final body):
      return inArgs(args) ?? inBlock(body);
    case ActionControlMarkerExpr(:final args):
      return inArgs(args);
    case ActionControlWhileExpr(:final condition, :final args, :final body):
      return findRemovedAggregateSelectorInExpr(condition) ??
          inArgs(args) ??
          inBlock(body);
    case ActionControlSwitchExpr(
      :final sourceExpr,
      :final args,
      :final cases,
      :final defaultCase,
      :final body,
    ):
      final direct =
          findRemovedAggregateSelectorInExpr(sourceExpr) ??
          inArgs(args) ??
          inBlock(body);
      if (direct != null) {
        return direct;
      }
      for (final item in cases) {
        final selector = findRemovedAggregateSelectorInExpr(item);
        if (selector != null) {
          return selector;
        }
      }
      return defaultCase == null
          ? null
          : findRemovedAggregateSelectorInExpr(defaultCase);
    case ActionControlCaseExpr(:final match, :final args, :final body):
      return findRemovedAggregateSelectorInExpr(match) ??
          inArgs(args) ??
          inBlock(body);
    case ActionControlDefaultExpr(:final args, :final body):
      return inArgs(args) ?? inBlock(body);
    case ActionVariableExpr():
    case ActionStringLiteralExpr():
    case ActionNumberLiteralExpr():
    case ActionBooleanLiteralExpr():
    case ActionRegexLiteralExpr():
    case ActionUndefExpr():
    case ActionRawExpr():
      return null;
  }
  return null;
}
