import '../ast/spec_ast.dart';
import 'action_ast.dart';
import 'action_contracts.dart';
import 'action_parser.dart';
import 'function_registry.dart';

final class CallableContractException implements Exception {
  const CallableContractException(this.message);

  final String message;

  @override
  String toString() => 'CallableContractException: $message';
}

enum CallableSurface { helper, receiver }

final class FinalCodeblockContract {
  const FinalCodeblockContract({
    required this.minBeforeCodeblock,
    required this.maxBeforeCodeblock,
    required this.finalParameterName,
  });

  final int minBeforeCodeblock;
  final int maxBeforeCodeblock;
  final String finalParameterName;

  bool accepts(int beforeCount) {
    return beforeCount >= minBeforeCodeblock &&
        beforeCount <= maxBeforeCodeblock;
  }
}

FinalCodeblockContract? builtinFinalCodeblockContract(
  CallableSurface surface,
  String name,
) {
  final canonical = canonicalActionHelperName(name);
  final (minimum, maximum) = switch ((surface, canonical)) {
    (CallableSurface.helper, 'with') => (0, 1),
    (CallableSurface.receiver, 'with') => (0, 0),
    (CallableSurface.receiver, 'walk_leaves') => (0, 0),
    (CallableSurface.receiver, 'map_leaves') => (0, 0),
    (CallableSurface.receiver, 'reduce_leaves') => (1, 1),
    _ => (-1, -1),
  };
  if (minimum < 0) {
    return null;
  }
  return FinalCodeblockContract(
    minBeforeCodeblock: minimum,
    maxBeforeCodeblock: maximum,
    finalParameterName: 'callback',
  );
}

FinalCodeblockContract? userFunctionFinalCodeblockContract(
  UserFunctionEntry function,
) {
  if (function.params.isEmpty) {
    return null;
  }
  final finalName = function.params.last;
  if (function.parameterKinds.length != 1 ||
      function.parameterKinds[finalName] != 'codeblock') {
    return null;
  }
  final before = function.params.length - 1;
  return FinalCodeblockContract(
    minBeforeCodeblock: before,
    maxBeforeCodeblock: before,
    finalParameterName: finalName,
  );
}

FunctionDefinition normalizeFunctionFinalCodeblocks(
  FunctionDefinition function,
  UserFunctionRegistry registry,
) {
  final body = parseActionBlock(function.bodySource);
  normalizeActionBlockFinalCodeblocks(body, registry);
  return FunctionDefinition(
    name: function.name,
    params: function.params,
    arity: function.arity,
    parameterKinds: function.parameterKinds,
    signature: function.signature,
    bodySource: function.bodySource,
    bodyPayload: function.bodyPayload,
    bodyParseJob: function.bodyParseJob,
    bodyAst: body.toJson(),
    source: function.source,
    sourceSpan: function.sourceSpan,
    bodySpan: function.bodySpan,
  );
}

void normalizeActionBlockFinalCodeblocks(
  ActionBlock block,
  UserFunctionRegistry registry,
) {
  for (final statement in block.statements) {
    _normalizeExpr(statement.expr, registry);
  }
}

void _normalizeArgs(
  CallableSurface surface,
  String name,
  List<ActionArgument> args,
  UserFunctionRegistry registry,
) {
  for (final argument in args) {
    _normalizeExpr(argument.value, registry);
  }

  final last = args.isEmpty ? null : args.last;
  final candidate =
      last is ActionPositionalArgument &&
          last.value is ActionContextualCodeblockCandidateExpr
      ? last.value as ActionContextualCodeblockCandidateExpr
      : null;
  if (candidate == null) {
    _restoreParenthesizedBlocks(args);
    return;
  }

  final contract =
      builtinFinalCodeblockContract(surface, name) ??
      (surface == CallableSurface.helper
          ? _userContract(registry, name)
          : null);
  if (contract == null) {
    if (candidate.syntax == ActionContextualBlockSyntax.attached) {
      throw CallableContractException(
        "callable_contract_rejected: ${surface.name} '$name' does not "
        'declare a final codeblock parameter',
      );
    }
    _restoreParenthesizedBlocks(args);
    return;
  }

  final beforeCount = args.length - 1;
  if (!contract.accepts(beforeCount)) {
    throw CallableContractException(
      "callable_contract_arity_mismatch: ${surface.name} '$name' expects "
      '${contract.minBeforeCodeblock}..=${contract.maxBeforeCodeblock} value '
      'argument(s) before final codeblock, got $beforeCount',
    );
  }

  args[args.length - 1] = ActionPositionalArgument(
    ActionCodeblockArgumentExpr(
      source: candidate.source,
      sourceSpan: candidate.sourceSpan,
      version: candidate.version,
      signature: candidate.signature,
      bodySource: candidate.bodySource,
      bodyAst: candidate.bodyAst,
      bodySpan: candidate.bodySpan,
    ),
  );
  _restoreParenthesizedBlocks(args);
}

FinalCodeblockContract? _userContract(
  UserFunctionRegistry registry,
  String name,
) {
  final function = registry.lookup(name);
  return function == null ? null : userFunctionFinalCodeblockContract(function);
}

void _restoreParenthesizedBlocks(List<ActionArgument> args) {
  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    final value = argument.value;
    if (value is! ActionContextualCodeblockCandidateExpr ||
        value.syntax != ActionContextualBlockSyntax.parenthesized) {
      continue;
    }
    final restored = ActionBlockValueExpr(
      source: value.source,
      sourceSpan: value.sourceSpan,
      block: value.bodyAst,
    );
    args[index] = switch (argument) {
      ActionPositionalArgument() => ActionPositionalArgument(restored),
      ActionKeywordArgument(:final name) => ActionKeywordArgument(
        name: name,
        value: restored,
      ),
    };
  }
}

void _normalizeExpr(ActionExpr expr, UserFunctionRegistry registry) {
  switch (expr) {
    case ActionCallExpr(:final name, :final args):
      _normalizeArgs(CallableSurface.helper, name, args, registry);
    case ActionRecognitionCheckpointExpr():
    case ActionProgressiveDispatchSpanExpr():
    case ActionRecognizeOnceExpr():
    case ActionRecognitionCommitExpr():
    case ActionRecognitionRollbackExpr():
    case ActionObserveRecognitionExpr():
      break;
    case ActionFluentChainExpr(:final receiver, :final calls):
      _normalizeExpr(receiver, registry);
      for (final call in calls) {
        _normalizeArgs(
          CallableSurface.receiver,
          call.method,
          call.args,
          registry,
        );
      }
    case ActionAssignScalarExpr(:final value):
    case ActionAssignArrayAppendExpr(:final value):
      _normalizeExpr(value, registry);
    case ActionAssignHashIndexExpr(:final key, :final value):
      _normalizeExpr(key, registry);
      _normalizeExpr(value, registry);
    case ActionAssignNestedAccessExpr(:final segments, :final value):
      _normalizeSegments(segments, registry);
      _normalizeExpr(value, registry);
    case ActionIndexedVarExpr(:final index):
      _normalizeExpr(index, registry);
    case ActionNestedAccessExpr(:final segments):
      _normalizeSegments(segments, registry);
    case ActionValueAccessExpr(:final receiver, :final segments):
      _normalizeExpr(receiver, registry);
      _normalizeSegments(segments, registry);
    case ActionArrayLiteralExpr(:final items):
      for (final item in items) {
        _normalizeExpr(item, registry);
      }
    case ActionHashLiteralExpr(:final entries):
      for (final entry in entries) {
        _normalizeExpr(entry.key, registry);
        _normalizeExpr(entry.value, registry);
      }
    case ActionBlockValueExpr(:final block):
      normalizeActionBlockFinalCodeblocks(block, registry);
    case ActionContextualCodeblockCandidateExpr(:final bodyAst):
    case ActionCodeblockArgumentExpr(:final bodyAst):
    case ActionCodeblockLiteralExpr(:final bodyAst):
      normalizeActionBlockFinalCodeblocks(bodyAst, registry);
    case ActionControlIfExpr(:final args, :final body):
    case ActionControlElseExpr(:final args, :final body):
    case ActionControlWhileExpr(:final args, :final body):
    case ActionControlCaseExpr(:final args, :final body):
    case ActionControlDefaultExpr(:final args, :final body):
      _normalizeArgumentValues(args, registry);
      if (body != null) {
        normalizeActionBlockFinalCodeblocks(body, registry);
      }
    case ActionControlSwitchExpr(
      :final args,
      :final body,
      :final cases,
      :final defaultCase,
    ):
      _normalizeArgumentValues(args, registry);
      if (body != null) {
        normalizeActionBlockFinalCodeblocks(body, registry);
      }
      for (final item in cases) {
        _normalizeExpr(item, registry);
      }
      if (defaultCase != null) {
        _normalizeExpr(defaultCase, registry);
      }
    case ActionControlMarkerExpr(:final args):
      _normalizeArgumentValues(args, registry);
    case ActionVariableExpr():
    case ActionStringLiteralExpr():
    case ActionNumberLiteralExpr():
    case ActionBooleanLiteralExpr():
    case ActionRegexLiteralExpr():
    case ActionUndefExpr():
    case ActionCodeblockLiteralErrorExpr():
    case ActionRawExpr():
      break;
  }
}

void _normalizeArgumentValues(
  List<ActionArgument> args,
  UserFunctionRegistry registry,
) {
  for (final argument in args) {
    _normalizeExpr(argument.value, registry);
  }
}

void _normalizeSegments(
  List<ActionAccessSegment> segments,
  UserFunctionRegistry registry,
) {
  for (final segment in segments) {
    if (segment is ActionIndexAccessSegment) {
      _normalizeExpr(segment.expr, registry);
    }
  }
}
