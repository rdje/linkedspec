import 'action_ast.dart';
import '../ast/spec_ast.dart' show CallableSignature;

ActionBlock parseActionBlock(String source) {
  return _ActionParser(source, 0, source).parseBlock();
}

ActionStatement parseActionStatement(String source) {
  return _ActionParser(source, 0, source).parseStatement();
}

ActionExpr parseActionExpression(String source) {
  return _ActionParser(source, 0, source).parseExpression();
}

final class _ActionParser {
  _ActionParser(this.source, this.baseStart, this.rootSource);

  final String source;
  final int baseStart;
  final String rootSource;

  _ActionParser _child(String source, int baseStart) {
    return _ActionParser(source, baseStart, rootSource);
  }

  ActionSourceSpan _characterSpan(int start, int end) {
    return ActionSourceSpan(
      start: rootSource.substring(0, start).runes.length,
      end: rootSource.substring(0, end).runes.length,
    );
  }

  ActionBlock parseBlock() {
    final pieces = _splitTopLevelStatements(source, baseStart);
    return ActionBlock(
      source: source,
      sourceSpan: _span(baseStart, baseStart + source.length),
      statements: [
        for (final piece in pieces)
          _child(piece.text, piece.start).parseStatement(),
      ],
    );
  }

  ActionStatement parseStatement() {
    final trimmed = _trimWithOffsets(source, baseStart);
    final expr = trimmed.text == 'next'
        ? ActionCallExpr(
            source: trimmed.text,
            sourceSpan: _span(trimmed.start, trimmed.end),
            name: 'next',
            sourceMethod: 'next',
            args: const [],
          )
        : _child(trimmed.text, trimmed.start).parseExpression();
    return ActionStatement(
      source: trimmed.text,
      sourceSpan: _span(trimmed.start, trimmed.end),
      expr: expr,
    );
  }

  ActionExpr parseExpression() {
    final trimmed = _trimWithOffsets(source, baseStart);
    if (trimmed.text.isEmpty) {
      return _raw(trimmed, 'empty_expression');
    }
    return _parseExpr(trimmed.text, trimmed.start);
  }

  ActionExpr _parseExpr(String text, int start) {
    final assignment = _parseAssignment(text, start);
    if (assignment != null) {
      return assignment;
    }

    final chain = _parseFluentChain(text, start);
    if (chain != null) {
      return chain;
    }

    return _parseExprWithoutChain(text, start);
  }

  ActionExpr _parseExprWithoutChain(String text, int start) {
    final grouped = _parseGrouped(text, start);
    if (grouped != null) {
      return grouped;
    }

    final literal = _parseLiteral(text, start);
    if (literal != null) {
      return literal;
    }

    final shape = _parseShapeOrBlock(text, start);
    if (shape != null) {
      return shape;
    }

    final control = _parseControlFlow(text, start);
    if (control != null) {
      return control;
    }

    final valueAccess = _parseCallResultAccess(text, start);
    if (valueAccess != null) {
      return valueAccess;
    }

    final call = _parseCall(text, start);
    if (call != null) {
      return call;
    }

    final access = _parseVariableOrAccess(text, start);
    if (access != null) {
      return access;
    }

    return ActionRawExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      reason: 'unsupported_expression',
    );
  }

  ActionExpr? _parseGrouped(String text, int start) {
    if (!text.startsWith('(') || !text.endsWith(')')) {
      return null;
    }
    final close = _findMatchingDelimiter(text, 0, '(', ')');
    if (close != text.length - 1) {
      return null;
    }
    final inner = text.substring(1, text.length - 1);
    final trimmed = _trimWithOffsets(inner, start + 1);
    return _child(trimmed.text, trimmed.start).parseExpression();
  }

  ActionExpr? _parseLiteral(String text, int start) {
    final end = start + text.length;
    final number = RegExp(r'^-?\d+(?:\.\d+)?$').firstMatch(text);
    if (number != null) {
      final parsed = num.parse(text);
      return ActionNumberLiteralExpr(
        source: text,
        sourceSpan: _span(start, end),
        value: parsed,
      );
    }
    if (text == 'undef') {
      return ActionUndefExpr(source: text, sourceSpan: _span(start, end));
    }
    if (text == 'true' || text == 'false') {
      return ActionBooleanLiteralExpr(
        source: text,
        sourceSpan: _span(start, end),
        value: text == 'true',
      );
    }
    if (text.length >= 2 &&
        (text.startsWith('"') || text.startsWith("'")) &&
        text.endsWith(text[0])) {
      final payload = text.substring(1, text.length - 1);
      return ActionStringLiteralExpr(
        source: text,
        sourceSpan: _span(start, end),
        value: _unescapeString(payload),
        quote: text[0],
      );
    }
    final regex = RegExp(r'^/((?:\\.|[^/])*)/([A-Za-z]*)$').firstMatch(text);
    if (regex != null) {
      return ActionRegexLiteralExpr(
        source: text,
        sourceSpan: _span(start, end),
        pattern: regex[1]!,
        flags: regex[2]!,
      );
    }
    return null;
  }

  ActionExpr? _parseShapeOrBlock(String text, int start) {
    if (text.startsWith('[')) {
      return _parseArrayLiteral(text, start);
    }
    if (text.startsWith('{')) {
      return _parseBraceExpr(text, start);
    }
    return null;
  }

  ActionExpr? _parseArrayLiteral(String text, int start) {
    if (!_outerDelimiterIsBalanced(text, '[', ']')) {
      return null;
    }
    final payload = text.substring(1, text.length - 1);
    return ActionArrayLiteralExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      items: [
        for (final part in _splitTopLevelCsv(payload, start + 1))
          _child(part.text, part.start).parseExpression(),
      ],
    );
  }

  ActionExpr? _parseBraceExpr(String text, int start) {
    if (!_outerDelimiterIsBalanced(text, '{', '}')) {
      return null;
    }
    if (text.startsWith('{|')) {
      return _parseCodeblockLiteral(text, start);
    }
    final payload = text.substring(1, text.length - 1);
    if (RegExp(r'^\s+\|').hasMatch(payload)) {
      return _codeblockLiteralError(text, start, 'invalid_codeblock_opener');
    }
    if (payload.trim().isEmpty || _hasTopLevelHashPairSeparator(payload)) {
      return _parseHashLiteral(text, payload, start);
    }
    return ActionBlockValueExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      block: _child(payload, start + 1).parseBlock(),
    );
  }

  ActionExpr _parseCodeblockLiteral(String text, int start) {
    final signatureEnd = text.indexOf('|', 2);
    if (signatureEnd < 0) {
      return _codeblockLiteralError(
        text,
        start,
        'missing_codeblock_signature_closer',
      );
    }
    final parsed = _parseCodeblockSignature(text.substring(2, signatureEnd));
    if (parsed.signature == null) {
      return _codeblockLiteralError(text, start, parsed.errorCode!);
    }
    final bodyStart = start + signatureEnd + 1;
    final bodyEnd = start + text.length - 1;
    final bodySource = text.substring(signatureEnd + 1, text.length - 1);
    return ActionCodeblockLiteralExpr(
      source: text,
      sourceSpan: _characterSpan(start, start + text.length),
      version: 1,
      signature: parsed.signature!,
      bodySource: bodySource,
      bodyAst: _child(bodySource, bodyStart).parseBlock(),
      bodySpan: _characterSpan(bodyStart, bodyEnd),
    );
  }

  ActionExpr _codeblockLiteralError(String source, int start, String code) {
    return ActionCodeblockLiteralErrorExpr(
      source: source,
      sourceSpan: _characterSpan(start, start + source.length),
      code: code,
    );
  }

  ActionExpr _parseHashLiteral(String text, String payload, int start) {
    final entries = <ActionHashLiteralEntry>[];
    for (final part in _splitTopLevelCsv(payload, start + 1)) {
      if (part.text.trim().isEmpty) {
        continue;
      }
      final separator = _findTopLevelHashPairSeparator(part.text);
      if (separator == null) {
        return ActionRawExpr(
          source: text,
          sourceSpan: _span(start, start + text.length),
          reason: 'invalid_hash_literal',
        );
      }
      if (separator.token == '=>') {
        return ActionRawExpr(
          source: text,
          sourceSpan: _span(start, start + text.length),
          reason: 'hash_literal_use_colon',
        );
      }
      final keyText = part.text.substring(0, separator.index);
      final valueText = part.text.substring(separator.index + separator.length);
      final key = _trimWithOffsets(keyText, part.start);
      final value = _trimWithOffsets(
        valueText,
        part.start + separator.index + separator.length,
      );
      entries.add(
        ActionHashLiteralEntry(
          key: _child(key.text, key.start).parseExpression(),
          value: _child(value.text, value.start).parseExpression(),
        ),
      );
    }
    return ActionHashLiteralExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      entries: entries,
    );
  }

  ActionExpr? _parseControlFlow(String text, int start) {
    final attached = _splitAttachedBlock(text);
    if (attached != null) {
      final head = _trimWithOffsets(attached.head, start);
      if (head.text.isNotEmpty) {
        return _parseControlHead(
          head.text,
          head.start,
          text,
          start,
          start + text.length,
          attached,
        );
      }
    }
    return _parseControlHead(
      text,
      start,
      text,
      start,
      start + text.length,
      null,
    );
  }

  ActionExpr? _parseControlHead(
    String head,
    int headStart,
    String fullSource,
    int fullStart,
    int fullEnd,
    _AttachedBlock? attached,
  ) {
    final normalized = _normalizeControlHead(head);
    if (normalized == null) {
      return null;
    }
    final parsed = _parseCallee(normalized.head);
    if (parsed == null) {
      return null;
    }
    final canonical = _canonicalControlKeyword(parsed.name);
    if (canonical == null) {
      return null;
    }
    final args = _parseArguments(
      parsed.payload,
      headStart + parsed.payloadStart,
    );
    final body = attached == null
        ? null
        : _child(
            attached.body,
            fullStart + attached.openIndex + 1,
          ).parseBlock();
    final bodySpan = attached == null
        ? null
        : _span(
            fullStart + attached.openIndex,
            fullStart + attached.closeIndex + 1,
          );

    ActionExpr? firstArg() => args.length == 1 ? args.single.value : null;

    switch (parsed.name) {
      case 'if':
      case 'i':
      case 'when':
      case 'elseif':
      case 'elif':
        final condition = firstArg();
        if (condition == null) {
          return null;
        }
        return ActionControlIfExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          branchRole: parsed.name == 'elseif' || parsed.name == 'elif'
              ? 'elseif'
              : 'if',
          condition: condition,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
        );
      case 'else':
      case 'otherwise':
        if (args.isNotEmpty) {
          return null;
        }
        return ActionControlElseExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
        );
      case 'endif':
        if (args.isNotEmpty || attached != null) {
          return null;
        }
        return ActionControlMarkerExpr(
          kind: 'control_endif',
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          args: args,
        );
      case 'while':
        final condition = firstArg();
        if (condition == null) {
          return null;
        }
        return ActionControlWhileExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          condition: condition,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
        );
      case 'switch':
        final sourceExpr = firstArg();
        if (sourceExpr == null) {
          return null;
        }
        final branches = attached == null
            ? const _SwitchBranches()
            : _parseSwitchBranches(
                fullSource.substring(
                  attached.openIndex,
                  attached.closeIndex + 1,
                ),
                fullStart + attached.openIndex,
              );
        return ActionControlSwitchExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          sourceExpr: sourceExpr,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
          cases: branches.cases,
          defaultCase: branches.defaultCase,
        );
      case 'case':
        final match = firstArg();
        if (match == null) {
          return null;
        }
        return ActionControlCaseExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          match: match,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
        );
      case 'default':
        if (args.isNotEmpty) {
          return null;
        }
        return ActionControlDefaultExpr(
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          args: args,
          body: body,
          bodySourceSpan: bodySpan,
        );
      case 'endcase':
      case 'endswitch':
        if (args.isNotEmpty || attached != null) {
          return null;
        }
        return ActionControlMarkerExpr(
          kind: parsed.name == 'endcase'
              ? 'control_endcase'
              : 'control_endswitch',
          source: fullSource,
          sourceSpan: _span(fullStart, fullEnd),
          keyword: normalized.keyword,
          canonicalKeyword: canonical,
          args: args,
        );
    }
    return null;
  }

  _SwitchBranches _parseSwitchBranches(String source, int start) {
    if (!_outerDelimiterIsBalanced(source, '{', '}')) {
      return const _SwitchBranches();
    }
    final payload = source.substring(1, source.length - 1);
    final payloadStart = start + 1;
    final cases = <ActionControlCaseExpr>[];
    ActionControlDefaultExpr? defaultCase;
    var index = 0;
    while (index < payload.length) {
      while (index < payload.length &&
          (payload[index].trim().isEmpty || payload[index] == ';')) {
        index += 1;
      }
      if (index >= payload.length) {
        break;
      }
      final open = _findTopLevelOpenBrace(payload, index);
      if (open == null) {
        break;
      }
      final close = _findMatchingDelimiter(payload, open, '{', '}');
      if (close == null) {
        break;
      }
      final exprText = payload.substring(index, close + 1);
      final expr = _child(exprText, payloadStart + index).parseExpression();
      if (expr is ActionControlCaseExpr) {
        cases.add(expr);
      } else if (expr is ActionControlDefaultExpr) {
        defaultCase = expr;
      }
      index = close + 1;
    }
    return _SwitchBranches(cases: cases, defaultCase: defaultCase);
  }

  ActionExpr? _parseCall(String text, int start) {
    final attached = _splitAttachedBlock(text);
    if (attached != null) {
      final head = _trimWithOffsets(attached.head, start);
      final parsed = _parseCallee(head.text);
      if (parsed == null) {
        return null;
      }
      final args = _parseArguments(
        parsed.payload,
        head.start + parsed.payloadStart,
      );
      final blockSource = text.substring(
        attached.openIndex,
        attached.closeIndex + 1,
      );
      args.add(
        ActionPositionalArgument(
          _contextualCodeblockCandidate(
            source: blockSource,
            sourceSpan: _span(
              start + attached.openIndex,
              start + attached.closeIndex + 1,
            ),
            bodyAst: _child(
              attached.body,
              start + attached.openIndex + 1,
            ).parseBlock(),
            syntax: ActionContextualBlockSyntax.attached,
          ),
        ),
      );
      return ActionCallExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: parsed.name,
        sourceMethod: parsed.sourceMethod,
        args: args,
        trailingBlockArg: true,
        trailingBlockSourceSpan: _span(
          start + attached.openIndex,
          start + attached.closeIndex + 1,
        ),
      );
    }

    final parsed = _parseCallee(text);
    if (parsed == null) {
      return null;
    }
    final args = _parseArguments(parsed.payload, start + parsed.payloadStart);
    final transaction = _recognitionTransactionExpr(
      name: parsed.name,
      args: args,
      source: text,
      sourceSpan: _span(start, start + text.length),
    );
    if (transaction != null) {
      return transaction;
    }
    return ActionCallExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      name: parsed.name,
      sourceMethod: parsed.sourceMethod,
      args: args,
    );
  }

  ActionExpr? _recognitionTransactionExpr({
    required String name,
    required List<ActionArgument> args,
    required String source,
    required ActionSourceSpan sourceSpan,
  }) {
    String? bareName(ActionArgument argument) {
      if (argument case ActionPositionalArgument(
        value: ActionVariableExpr(:final name),
      )) {
        return name;
      }
      return null;
    }

    Never invalid() => throw FormatException(
      'LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:'
      'recognition_static_form_required:$name',
    );

    Never invalidObservationTarget() => throw const FormatException(
      'source_location_recursive_observation_target',
    );

    Never invalidObservationOperand() => throw const FormatException(
      'source_location_recursive_observation_operand',
    );

    switch (name) {
      case 'recognition_checkpoint':
        if (args.isNotEmpty) {
          invalid();
        }
        return ActionRecognitionCheckpointExpr(
          source: source,
          sourceSpan: sourceSpan,
        );
      case 'recognize_once':
        if (args.length != 2) {
          invalid();
        }
        final token = bareName(args.first);
        final operand = args.last;
        if (token == null ||
            operand is! ActionPositionalArgument ||
            operand.value is! ActionCallExpr) {
          invalid();
        }
        final call = operand.value as ActionCallExpr;
        if (call.name != 'call' ||
            call.sourceMethod != 'call' ||
            call.args.length != 1) {
          invalid();
        }
        final rule = bareName(call.args.single);
        if (rule == null) {
          invalid();
        }
        return ActionRecognizeOnceExpr(
          source: source,
          sourceSpan: sourceSpan,
          token: token,
          rule: rule,
        );
      case 'recognition_commit':
      case 'recognition_rollback':
        if (args.length != 1) {
          invalid();
        }
        final token = bareName(args.single);
        if (token == null) {
          invalid();
        }
        return name == 'recognition_commit'
            ? ActionRecognitionCommitExpr(
                source: source,
                sourceSpan: sourceSpan,
                token: token,
              )
            : ActionRecognitionRollbackExpr(
                source: source,
                sourceSpan: sourceSpan,
                token: token,
              );
      case 'observe_recognition':
        if (args.isEmpty || bareName(args.first) == null) {
          invalidObservationTarget();
        }
        if (args.length != 2) {
          invalidObservationOperand();
        }
        final operand = args.last;
        if (operand is! ActionPositionalArgument ||
            operand.value is! ActionCallExpr) {
          invalidObservationOperand();
        }
        final call = operand.value as ActionCallExpr;
        if (call.name != 'call' ||
            call.sourceMethod != 'call' ||
            call.args.length != 1) {
          invalidObservationOperand();
        }
        final rule = bareName(call.args.single);
        if (rule == null) {
          invalidObservationOperand();
        }
        return ActionObserveRecognitionExpr(
          source: source,
          sourceSpan: sourceSpan,
          target: bareName(args.first)!,
          rule: rule,
        );
      default:
        return null;
    }
  }

  ActionValueAccessExpr? _parseCallResultAccess(String text, int start) {
    final open = _findTopLevelOpenParen(text);
    if (open == null) {
      return null;
    }
    final close = _findMatchingDelimiter(text, open, '(', ')');
    if (close == null) {
      return null;
    }
    var accessStart = close + 1;
    while (accessStart < text.length && text[accessStart].trim().isEmpty) {
      accessStart += 1;
    }
    if (accessStart == text.length || text[accessStart] != '[') {
      return null;
    }
    final receiverSource = text.substring(0, close + 1);
    final receiver = _parseCall(receiverSource, start);
    if (receiver == null) {
      return null;
    }
    final segments = _parseAccessSegments(text, accessStart, start);
    if (segments == null || segments.isEmpty) {
      return null;
    }
    return ActionValueAccessExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      receiver: receiver,
      segments: segments,
    );
  }

  ActionExpr? _parseVariableOrAccess(String text, int start) {
    final match = RegExp(r'^\$?([A-Za-z_]\w*)').firstMatch(text);
    if (match == null) {
      return null;
    }
    final name = match[1]!;
    var pos = match[0]!.length;
    while (pos < text.length && text[pos].trim().isEmpty) {
      pos += 1;
    }
    if (pos == text.length) {
      return ActionVariableExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: name,
      );
    }
    if (text[pos] != '[') {
      return null;
    }
    final segments = _parseAccessSegments(text, pos, start);
    if (segments == null || segments.isEmpty) {
      return null;
    }
    if (segments.length == 1 && segments.single is ActionIndexAccessSegment) {
      return ActionIndexedVarExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: name,
        index: (segments.single as ActionIndexAccessSegment).expr,
      );
    }
    return ActionNestedAccessExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      base: name,
      segments: segments,
    );
  }

  List<ActionAccessSegment>? _parseAccessSegments(
    String text,
    int pos,
    int start,
  ) {
    final segments = <ActionAccessSegment>[];
    while (pos < text.length) {
      while (pos < text.length && text[pos].trim().isEmpty) {
        pos += 1;
      }
      if (pos == text.length) {
        return segments;
      }
      if (text[pos] != '[') {
        return null;
      }
      final close = _findMatchingDelimiter(text, pos, '[', ']');
      if (close == null) {
        return null;
      }
      final payload = text.substring(pos + 1, close);
      final trimmed = _trimWithOffsets(payload, start + pos + 1);
      final expr = _child(trimmed.text, trimmed.start).parseExpression();
      final segmentSource = text.substring(pos, close + 1);
      final segmentSpan = _span(start + pos, start + close + 1);
      if (expr is ActionStringLiteralExpr) {
        segments.add(
          ActionKeyAccessSegment(
            value: expr.value,
            source: segmentSource,
            sourceSpan: segmentSpan,
          ),
        );
      } else {
        segments.add(
          ActionIndexAccessSegment(
            expr: expr,
            source: segmentSource,
            sourceSpan: segmentSpan,
          ),
        );
      }
      pos = close + 1;
    }
    return segments;
  }

  ActionExpr? _parseAssignment(String text, int start) {
    final appendIndex = _findTopLevelToken(text, '+=');
    if (appendIndex != null) {
      final left = text.substring(0, appendIndex).trim();
      if (!_isIdentifier(left)) {
        return null;
      }
      final value = _trimWithOffsets(
        text.substring(appendIndex + 2),
        start + appendIndex + 2,
      );
      return ActionAssignArrayAppendExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: left,
        value: _child(value.text, value.start).parseExpression(),
      );
    }

    final eqIndex = _findTopLevelAssignmentEquals(text);
    if (eqIndex == null) {
      return null;
    }
    final left = _trimWithOffsets(text.substring(0, eqIndex), start);
    if (left.text.isEmpty) {
      return null;
    }
    final right = _trimWithOffsets(
      text.substring(eqIndex + 1),
      start + eqIndex + 1,
    );
    final value = _child(right.text, right.start).parseExpression();
    if (_isIdentifier(left.text)) {
      return ActionAssignScalarExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: left.text,
        value: value,
      );
    }
    final target = _child(
      left.text,
      left.start,
    )._parseVariableOrAccess(left.text, left.start);
    if (target is ActionIndexedVarExpr) {
      return ActionAssignHashIndexExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        name: target.name,
        key: target.index,
        value: value,
      );
    }
    if (target is ActionNestedAccessExpr) {
      if (target.segments.length == 1) {
        final segment = target.segments.single;
        final key = segment is ActionKeyAccessSegment
            ? ActionStringLiteralExpr(
                source: segment.source,
                sourceSpan: segment.sourceSpan,
                value: segment.value,
                quote: '"',
              )
            : (segment as ActionIndexAccessSegment).expr;
        return ActionAssignHashIndexExpr(
          source: text,
          sourceSpan: _span(start, start + text.length),
          name: target.base,
          key: key,
          value: value,
        );
      }
      return ActionAssignNestedAccessExpr(
        source: text,
        sourceSpan: _span(start, start + text.length),
        base: target.base,
        segments: target.segments,
        value: value,
      );
    }
    return null;
  }

  ActionExpr? _parseFluentChain(String text, int start) {
    final segments = _splitTopLevelFluentSegments(text);
    if (segments.length <= 1) {
      return null;
    }
    final receiverSegment = segments.first;
    final receiver = _child(receiverSegment.text, start + receiverSegment.start)
        ._parseExprWithoutChain(
          receiverSegment.text,
          start + receiverSegment.start,
        );
    final calls = <ActionFluentCall>[];
    for (var index = 1; index < segments.length; index += 1) {
      final segment = segments[index];
      final call = _parseFluentCallSegment(
        segment.text,
        start + segment.start,
        start + segment.end,
        allowBareIdentifier: index == segments.length - 1,
      );
      if (call == null) {
        return ActionRawExpr(
          source: text,
          sourceSpan: _span(start, start + text.length),
          reason: 'invalid_fluent_chain',
        );
      }
      calls.add(call);
    }
    return ActionFluentChainExpr(
      source: text,
      sourceSpan: _span(start, start + text.length),
      receiver: receiver,
      calls: calls,
    );
  }

  ActionFluentCall? _parseFluentCallSegment(
    String text,
    int start,
    int end, {
    required bool allowBareIdentifier,
  }) {
    final parsed = _parseCallee(text);
    if (parsed != null) {
      return ActionFluentCall(
        method: parsed.name,
        sourceMethod: parsed.sourceMethod,
        args: _parseArguments(parsed.payload, start + parsed.payloadStart),
        source: text,
        sourceSpan: _span(start, end),
      );
    }
    final bare = text.trim();
    if (allowBareIdentifier && _isIdentifier(bare)) {
      return ActionFluentCall(
        method: bare,
        sourceMethod: bare,
        args: const [],
        source: text,
        sourceSpan: _span(start, end),
      );
    }
    final attached = _splitAttachedBlock(text);
    if (attached == null) {
      return null;
    }
    final head = _trimWithOffsets(attached.head, start);
    final headCall = _parseCallee(head.text);
    if (headCall == null) {
      return null;
    }
    final args = _parseArguments(
      headCall.payload,
      head.start + headCall.payloadStart,
    );
    final blockSource = text.substring(
      attached.openIndex,
      attached.closeIndex + 1,
    );
    args.add(
      ActionPositionalArgument(
        _contextualCodeblockCandidate(
          source: blockSource,
          sourceSpan: _span(
            start + attached.openIndex,
            start + attached.closeIndex + 1,
          ),
          bodyAst: _child(
            attached.body,
            start + attached.openIndex + 1,
          ).parseBlock(),
          syntax: ActionContextualBlockSyntax.attached,
        ),
      ),
    );
    return ActionFluentCall(
      method: headCall.name,
      sourceMethod: headCall.sourceMethod,
      args: args,
      source: text,
      sourceSpan: _span(start, end),
      trailingBlockArg: true,
      receiverTrailingBlockArg: true,
      trailingBlockSourceSpan: _span(
        start + attached.openIndex,
        start + attached.closeIndex + 1,
      ),
    );
  }

  List<ActionArgument> _parseArguments(String payload, int start) {
    final args = <ActionArgument>[];
    for (final part in _splitTopLevelCsv(payload, start)) {
      if (part.text.trim().isEmpty) {
        continue;
      }
      final separator = _findTopLevelHashPairSeparator(part.text);
      if (separator != null && separator.token == ':') {
        final name = part.text.substring(0, separator.index).trim();
        if (_isIdentifier(name)) {
          final value = _trimWithOffsets(
            part.text.substring(separator.index + separator.length),
            part.start + separator.index + separator.length,
          );
          final expression = _child(value.text, value.start).parseExpression();
          args.add(
            ActionKeywordArgument(
              name: name,
              value: _parenthesizedCodeblockCandidate(expression),
            ),
          );
          continue;
        }
      }
      final parsedExpression = _child(part.text, part.start).parseExpression();
      final expression = _parenthesizedCodeblockCandidate(parsedExpression);
      final keywordIndex = _findTopLevelAssignmentEquals(part.text);
      if (keywordIndex != null && expression is! ActionAssignScalarExpr) {
        final name = part.text.substring(0, keywordIndex).trim();
        if (_isIdentifier(name)) {
          final value = _trimWithOffsets(
            part.text.substring(keywordIndex + 1),
            part.start + keywordIndex + 1,
          );
          args.add(
            ActionKeywordArgument(
              name: name,
              value: _child(value.text, value.start).parseExpression(),
            ),
          );
          continue;
        }
      }
      args.add(ActionPositionalArgument(expression));
    }
    return args;
  }

  ActionRawExpr _raw(_TextSpan text, String reason) {
    return ActionRawExpr(
      source: text.text,
      sourceSpan: _span(text.start, text.end),
      reason: reason,
    );
  }

  ActionExpr _parenthesizedCodeblockCandidate(ActionExpr expression) {
    if (expression is! ActionBlockValueExpr) {
      return expression;
    }
    return _contextualCodeblockCandidate(
      source: expression.source,
      sourceSpan: expression.sourceSpan,
      bodyAst: expression.block,
      syntax: ActionContextualBlockSyntax.parenthesized,
    );
  }

  ActionContextualCodeblockCandidateExpr _contextualCodeblockCandidate({
    required String source,
    required ActionSourceSpan sourceSpan,
    required ActionBlock bodyAst,
    required ActionContextualBlockSyntax syntax,
  }) {
    return ActionContextualCodeblockCandidateExpr(
      source: source,
      sourceSpan: sourceSpan,
      syntax: syntax,
      version: 1,
      signature: const CallableSignature(
        kind: 'callable_signature',
        version: 1,
        positionalParams: [],
        restParam: null,
        minArity: 0,
        maxArity: 0,
      ),
      bodySource: bodyAst.source,
      bodyAst: parseActionBlock(bodyAst.source),
      bodySpan: bodyAst.sourceSpan,
    );
  }
}

final class _TextSpan {
  const _TextSpan({required this.text, required this.start, required this.end});

  final String text;
  final int start;
  final int end;
}

final class _AttachedBlock {
  const _AttachedBlock({
    required this.head,
    required this.body,
    required this.openIndex,
    required this.closeIndex,
  });

  final String head;
  final String body;
  final int openIndex;
  final int closeIndex;
}

final class _ParsedCallee {
  const _ParsedCallee({
    required this.name,
    required this.sourceMethod,
    required this.payload,
    required this.payloadStart,
  });

  final String name;
  final String sourceMethod;
  final String payload;
  final int payloadStart;
}

final class _ControlHead {
  const _ControlHead({required this.head, required this.keyword});

  final String head;
  final String keyword;
}

final class _SwitchBranches {
  const _SwitchBranches({this.cases = const [], this.defaultCase});

  final List<ActionControlCaseExpr> cases;
  final ActionControlDefaultExpr? defaultCase;
}

final class _Separator {
  const _Separator({
    required this.index,
    required this.length,
    required this.token,
  });

  final int index;
  final int length;
  final String token;
}

final class _CodeblockSignatureResult {
  const _CodeblockSignatureResult.valid(this.signature) : errorCode = null;

  const _CodeblockSignatureResult.invalid(this.errorCode) : signature = null;

  final CallableSignature? signature;
  final String? errorCode;
}

const _reservedCodeblockParameters = <String>{
  'fn',
  'return',
  'I',
  'LS',
  'LE',
  'E',
  'EX',
  'IT',
  'LX',
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

_CodeblockSignatureResult _parseCodeblockSignature(String source) {
  final parts = source.isEmpty
      ? const <String>[]
      : source.split(',').map((part) => part.trim()).toList();
  if (parts.any((part) => part.isEmpty)) {
    return const _CodeblockSignatureResult.invalid('invalid_parameter');
  }

  final positional = <String>[];
  String? rest;
  final seen = <String>{};
  for (final (index, part) in parts.indexed) {
    late final String name;
    if (part.startsWith('...')) {
      if (index != parts.length - 1) {
        return const _CodeblockSignatureResult.invalid(
          'rest_parameter_must_be_final',
        );
      }
      final match = RegExp(
        r'^\.\.\.([A-Za-z_][A-Za-z0-9_]*)$',
      ).firstMatch(part);
      if (match == null) {
        return const _CodeblockSignatureResult.invalid(
          'invalid_rest_parameter',
        );
      }
      name = match[1]!;
      rest = name;
    } else {
      if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(part)) {
        return const _CodeblockSignatureResult.invalid('invalid_parameter');
      }
      name = part;
      positional.add(name);
    }
    if (!seen.add(name)) {
      return const _CodeblockSignatureResult.invalid('duplicate_parameter');
    }
    if (_reservedCodeblockParameters.contains(name)) {
      return const _CodeblockSignatureResult.invalid('reserved_parameter');
    }
  }

  return _CodeblockSignatureResult.valid(
    CallableSignature(
      kind: 'callable_signature',
      version: 1,
      positionalParams: List.unmodifiable(positional),
      restParam: rest,
      minArity: positional.length,
      maxArity: rest == null ? positional.length : null,
    ),
  );
}

ActionSourceSpan _span(int start, int end) {
  return ActionSourceSpan(start: start, end: end);
}

_TextSpan _trimWithOffsets(String text, int baseStart) {
  var leading = 0;
  while (leading < text.length && text[leading].trim().isEmpty) {
    leading += 1;
  }
  var trailing = text.length;
  while (trailing > leading && text[trailing - 1].trim().isEmpty) {
    trailing -= 1;
  }
  return _TextSpan(
    text: text.substring(leading, trailing),
    start: baseStart + leading,
    end: baseStart + trailing,
  );
}

String _unescapeString(String payload) {
  return payload.replaceAllMapped(
    RegExp(r'''\\([\\'"])'''),
    (match) => match[1]!,
  );
}

bool _outerDelimiterIsBalanced(String text, String open, String close) {
  if (!text.startsWith(open) || !text.endsWith(close)) {
    return false;
  }
  return _findMatchingDelimiter(text, 0, open, close) == text.length - 1;
}

int? _findMatchingDelimiter(
  String text,
  int openIndex,
  String open,
  String close,
) {
  var depth = 0;
  final state = _ScanState();
  for (var index = openIndex; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeQuotedOrRegex(state, text, index, ch)) {
      continue;
    }
    if (ch == '"' || ch == "'") {
      state.quote = ch;
      continue;
    }
    if (ch == '/' && _looksLikeRegexStart(text, index)) {
      state.inRegex = true;
      continue;
    }
    if (ch == open) {
      depth += 1;
    } else if (ch == close) {
      depth -= 1;
      if (depth == 0) {
        return index;
      }
    }
  }
  return null;
}

List<_TextSpan> _splitTopLevelStatements(String text, int baseStart) {
  final pieces = <_TextSpan>[];
  final state = _ScanState();
  var segmentStart = 0;
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (ch == '}' && state.isTopLevel) {
      final next = _nextNonWhitespaceIndex(text, index + 1);
      if (next != null && _startsAttachedBranchContinuation(text, next)) {
        final piece = _trimWithOffsets(
          text.substring(segmentStart, index + 1),
          baseStart + segmentStart,
        );
        if (piece.text.isNotEmpty) {
          pieces.add(piece);
        }
        segmentStart = next;
        index = next - 1;
        continue;
      }
    }
    final separator =
        state.isTopLevel && (ch == ';' || ch == '\n' || ch == '\r');
    if (!separator) {
      continue;
    }
    final piece = _trimWithOffsets(
      text.substring(segmentStart, index),
      baseStart + segmentStart,
    );
    if (piece.text.isNotEmpty) {
      pieces.add(piece);
    }
    segmentStart = index + 1;
  }
  final finalPiece = _trimWithOffsets(
    text.substring(segmentStart),
    baseStart + segmentStart,
  );
  if (finalPiece.text.isNotEmpty) {
    pieces.add(finalPiece);
  }
  return pieces;
}

int? _nextNonWhitespaceIndex(String text, int start) {
  for (var index = start; index < text.length; index += 1) {
    if (text[index].trim().isNotEmpty) {
      return index;
    }
  }
  return null;
}

bool _startsAttachedBranchContinuation(String text, int index) {
  for (final keyword in const ['elseif', 'elif', 'else', 'otherwise']) {
    if (!text.startsWith(keyword, index)) {
      continue;
    }
    final end = index + keyword.length;
    if (end >= text.length) {
      return true;
    }
    final next = text[end];
    if (next.trim().isEmpty || next == '(' || next == '{') {
      return true;
    }
  }
  return false;
}

List<_TextSpan> _splitTopLevelCsv(String text, int baseStart) {
  return _splitTopLevelOn(text, baseStart, ',');
}

List<_TextSpan> _splitTopLevelOn(String text, int baseStart, String separator) {
  final pieces = <_TextSpan>[];
  final state = _ScanState();
  var segmentStart = 0;
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (state.isTopLevel && ch == separator) {
      final piece = _trimWithOffsets(
        text.substring(segmentStart, index),
        baseStart + segmentStart,
      );
      if (piece.text.isNotEmpty) {
        pieces.add(piece);
      }
      segmentStart = index + 1;
    }
  }
  final finalPiece = _trimWithOffsets(
    text.substring(segmentStart),
    baseStart + segmentStart,
  );
  if (finalPiece.text.isNotEmpty) {
    pieces.add(finalPiece);
  }
  return pieces;
}

bool _hasTopLevelHashPairSeparator(String text) {
  return _findTopLevelHashPairSeparator(text) != null;
}

_Separator? _findTopLevelHashPairSeparator(String text) {
  final state = _ScanState();
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (!state.isTopLevel) {
      continue;
    }
    if (ch == '=' && index + 1 < text.length && text[index + 1] == '>') {
      return _Separator(index: index, length: 2, token: '=>');
    }
    if (ch == ':') {
      final prev = index > 0 ? text[index - 1] : '';
      final next = index + 1 < text.length ? text[index + 1] : '';
      if (prev != ':' && next != ':') {
        return _Separator(index: index, length: 1, token: ':');
      }
    }
  }
  return null;
}

int? _findTopLevelToken(String text, String token) {
  final state = _ScanState();
  for (var index = 0; index <= text.length - token.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (state.isTopLevel && text.startsWith(token, index)) {
      return index;
    }
  }
  return null;
}

int? _findTopLevelAssignmentEquals(String text) {
  final state = _ScanState();
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (!state.isTopLevel || ch != '=') {
      continue;
    }
    final prev = index > 0 ? text[index - 1] : '';
    final next = index + 1 < text.length ? text[index + 1] : '';
    if (prev == '!' ||
        prev == '<' ||
        prev == '>' ||
        prev == '=' ||
        next == '=' ||
        next == '>') {
      continue;
    }
    return index;
  }
  return null;
}

_AttachedBlock? _splitAttachedBlock(String text) {
  final open = _findTopLevelOpenBrace(text, 0);
  if (open == null) {
    return null;
  }
  final close = _findMatchingDelimiter(text, open, '{', '}');
  if (close == null || text.substring(close + 1).trim().isNotEmpty) {
    return null;
  }
  return _AttachedBlock(
    head: text.substring(0, open),
    body: text.substring(open + 1, close),
    openIndex: open,
    closeIndex: close,
  );
}

int? _findTopLevelOpenBrace(String text, int start) {
  final state = _ScanState();
  for (var index = start; index < text.length; index += 1) {
    final ch = text[index];
    if (state.quote == null &&
        !state.inRegex &&
        state.isTopLevel &&
        ch == '{') {
      return index;
    }
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
  }
  return null;
}

_ParsedCallee? _parseCallee(String text) {
  final trimmed = text.trim();
  final open = _findTopLevelOpenParen(trimmed);
  if (open == null) {
    return null;
  }
  final close = _findMatchingDelimiter(trimmed, open, '(', ')');
  if (close != trimmed.length - 1) {
    return null;
  }
  final rawName = trimmed.substring(0, open).trim();
  if (!_isIdentifier(rawName) && !_isSymbolCallee(rawName)) {
    return null;
  }
  return _ParsedCallee(
    name: rawName,
    sourceMethod: rawName,
    payload: trimmed.substring(open + 1, close),
    payloadStart: open + 1,
  );
}

int? _findTopLevelOpenParen(String text) {
  final state = _ScanState();
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (state.quote == null &&
        !state.inRegex &&
        state.isTopLevel &&
        ch == '(') {
      return index;
    }
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
  }
  return null;
}

_ControlHead? _normalizeControlHead(String head) {
  final trimmed = head.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed == 'otherwise') {
    return const _ControlHead(head: 'else()', keyword: 'otherwise');
  }
  if (const {
    'else',
    'endif',
    'default',
    'endcase',
    'endswitch',
  }.contains(trimmed)) {
    return _ControlHead(head: '$trimmed()', keyword: trimmed);
  }
  final match = RegExp(r'^([A-Za-z_]\w*)').firstMatch(trimmed);
  if (match == null || _canonicalControlKeyword(match[1]!) == null) {
    return null;
  }
  return _ControlHead(head: trimmed, keyword: match[1]!);
}

String? _canonicalControlKeyword(String method) {
  return switch (method) {
    'i' || 'when' => 'if',
    'elif' => 'elseif',
    'otherwise' => 'else',
    'if' ||
    'elseif' ||
    'else' ||
    'endif' ||
    'while' ||
    'switch' ||
    'case' ||
    'default' ||
    'endcase' ||
    'endswitch' => method,
    _ => null,
  };
}

List<_TextSpan> _splitTopLevelFluentSegments(String text) {
  final segments = <_TextSpan>[];
  final state = _ScanState();
  var segmentStart = 0;
  for (var index = 0; index < text.length; index += 1) {
    final ch = text[index];
    if (_consumeScanChar(state, text, index, ch)) {
      continue;
    }
    if (!state.isTopLevel || ch != '.') {
      continue;
    }
    final prev = index > 0 ? text[index - 1] : '';
    final next = index + 1 < text.length ? text[index + 1] : '';
    if (_isDigit(prev) && _isDigit(next)) {
      continue;
    }
    final piece = _trimWithOffsets(
      text.substring(segmentStart, index),
      segmentStart,
    );
    segments.add(piece);
    segmentStart = index + 1;
  }
  if (segments.isEmpty) {
    return const [];
  }
  segments.add(_trimWithOffsets(text.substring(segmentStart), segmentStart));
  return segments;
}

bool _isIdentifier(String value) {
  return RegExp(r'^[A-Za-z_]\w*$').hasMatch(value);
}

bool _isSymbolCallee(String value) {
  return const {
    '+',
    '-',
    '*',
    '/',
    '%',
    '=',
    '==',
    '!=',
    '>',
    '>=',
    '<',
    '<=',
  }.contains(value);
}

bool _isDigit(String value) {
  return value.length == 1 &&
      value.codeUnitAt(0) >= 48 &&
      value.codeUnitAt(0) <= 57;
}

final class _ScanState {
  String? quote;
  bool escaped = false;
  bool inRegex = false;
  int parenDepth = 0;
  int bracketDepth = 0;
  int braceDepth = 0;

  bool get isTopLevel =>
      parenDepth == 0 && bracketDepth == 0 && braceDepth == 0;
}

bool _consumeScanChar(_ScanState state, String text, int index, String ch) {
  if (_consumeQuotedOrRegex(state, text, index, ch)) {
    return true;
  }
  if (ch == '"' || ch == "'") {
    state.quote = ch;
    return true;
  }
  if (ch == '/' && _looksLikeRegexStart(text, index)) {
    state.inRegex = true;
    return true;
  }
  switch (ch) {
    case '(':
      state.parenDepth += 1;
    case ')':
      if (state.parenDepth > 0) {
        state.parenDepth -= 1;
      }
    case '[':
      state.bracketDepth += 1;
    case ']':
      if (state.bracketDepth > 0) {
        state.bracketDepth -= 1;
      }
    case '{':
      state.braceDepth += 1;
    case '}':
      if (state.braceDepth > 0) {
        state.braceDepth -= 1;
      }
  }
  return false;
}

bool _consumeQuotedOrRegex(
  _ScanState state,
  String text,
  int index,
  String ch,
) {
  if (state.quote != null) {
    if (state.escaped) {
      state.escaped = false;
      return true;
    }
    if (ch == r'\') {
      state.escaped = true;
      return true;
    }
    if (ch == state.quote) {
      state.quote = null;
    }
    return true;
  }
  if (state.inRegex) {
    if (state.escaped) {
      state.escaped = false;
      return true;
    }
    if (ch == r'\') {
      state.escaped = true;
      return true;
    }
    if (ch == '/') {
      state.inRegex = false;
    }
    return true;
  }
  return false;
}

bool _looksLikeRegexStart(String text, int index) {
  final next = index + 1 < text.length ? text[index + 1] : '';
  if (next == '(' || next.trim().isEmpty) {
    return false;
  }
  var prevIndex = index - 1;
  while (prevIndex >= 0 && text[prevIndex].trim().isEmpty) {
    prevIndex -= 1;
  }
  if (prevIndex < 0) {
    return true;
  }
  return '([{,=:'.contains(text[prevIndex]);
}
