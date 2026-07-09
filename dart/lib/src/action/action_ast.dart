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
