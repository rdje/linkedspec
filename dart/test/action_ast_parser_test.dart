import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('parses action blocks into value-drop statements and calls', () {
    final block = parseActionBlock(
      'set(results, []); push(results, retv)\n'
      'return(copy(results))',
    );

    expect(block.kind, 'action_block');
    expect(block.statements, hasLength(3));
    expect(block.statements.every((statement) => statement.dropsValue), isTrue);

    final setCall = block.statements[0].expr as ActionCallExpr;
    expect(setCall.name, 'set');
    expect(setCall.args[0].value, isA<ActionVariableExpr>());
    expect(setCall.args[1].value, isA<ActionArrayLiteralExpr>());

    final pushCall = block.statements[1].expr as ActionCallExpr;
    expect(pushCall.name, 'push');
    expect(pushCall.args[1].value, isA<ActionVariableExpr>());
  });

  test('parses literals, direct access, and shape literals', () {
    expect(parseActionExpression('42'), isA<ActionNumberLiteralExpr>());
    expect(parseActionExpression('true'), isA<ActionBooleanLiteralExpr>());
    expect(parseActionExpression('undef'), isA<ActionUndefExpr>());
    expect(parseActionExpression('/a\\\\sb/i'), isA<ActionRegexLiteralExpr>());
    final singleQuoted =
        parseActionExpression("'\"|\\s'") as ActionStringLiteralExpr;
    expect(singleQuoted.value, r'"|\s');

    final nested =
        parseActionExpression(r'foo["a"][i][0]') as ActionNestedAccessExpr;
    expect(nested.base, 'foo');
    expect(nested.segments.map((segment) => segment.kind), [
      'key',
      'index',
      'index',
    ]);

    final array =
        parseActionExpression('[value, true, []]') as ActionArrayLiteralExpr;
    expect(array.items.map((item) => item.kind), [
      'variable',
      'boolean',
      'array_literal',
    ]);

    final hash =
        parseActionExpression(r'{ key : value, "fixed" : [value] }')
            as ActionHashLiteralExpr;
    expect(hash.entries[0].key, isA<ActionVariableExpr>());
    expect(hash.entries[1].key, isA<ActionStringLiteralExpr>());
    expect(hash.entries[1].value, isA<ActionArrayLiteralExpr>());
  });

  test('parses assignments and assignment receiver chains', () {
    final assignment =
        parseActionExpression('items = [value]') as ActionAssignScalarExpr;
    expect(assignment.name, 'items');
    expect(assignment.value, isA<ActionArrayLiteralExpr>());

    final append =
        parseActionExpression('items += value') as ActionAssignArrayAppendExpr;
    expect(append.name, 'items');
    expect(append.value, isA<ActionVariableExpr>());

    final hash =
        parseActionExpression('meta[key] = { stage : value }')
            as ActionAssignHashIndexExpr;
    expect(hash.key, isA<ActionVariableExpr>());
    expect(hash.value, isA<ActionHashLiteralExpr>());

    final nested =
        parseActionExpression(r'payload["children"][0]["name"] = value')
            as ActionAssignNestedAccessExpr;
    expect(nested.segments, hasLength(3));

    final chain =
        parseActionExpression('(items += value).count()')
            as ActionFluentChainExpr;
    expect(chain.receiver, isA<ActionAssignArrayAppendExpr>());
    expect(chain.calls.single.method, 'count');

    final call =
        parseActionExpression('array(items = [value], copy(items))')
            as ActionCallExpr;
    expect(call.args.first, isA<ActionPositionalArgument>());
    expect(call.args.first.value, isA<ActionAssignScalarExpr>());
  });

  test('parses receiver chains and trailing block calls', () {
    final chain =
        parseActionExpression(r'" raw ".trim().split("-").count()')
            as ActionFluentChainExpr;
    expect(chain.receiver, isA<ActionStringLiteralExpr>());
    expect(chain.calls.map((call) => call.method), ['trim', 'split', 'count']);

    final withCall =
        parseActionExpression('with("x") { return(value) }') as ActionCallExpr;
    expect(withCall.trailingBlockArg, isTrue);
    expect(withCall.args.last.value, isA<ActionBlockValueExpr>());

    final receiverWith =
        parseActionExpression('"x".with() { return(value) }')
            as ActionFluentChainExpr;
    expect(receiverWith.calls.single.method, 'with');
    expect(receiverWith.calls.single.receiverTrailingBlockArg, isTrue);
    expect(
      receiverWith.calls.single.args.single.value,
      isA<ActionBlockValueExpr>(),
    );
  });

  test('keeps delimiters inside helper string arguments quoted', () {
    final printCall =
        parseActionExpression(
              r'''print("begin_end_blocks: BEGIN   (", entry_text(), "\n")''',
            )
            as ActionCallExpr;

    expect(printCall.name, 'print');
    expect(printCall.args, hasLength(3));
    expect(printCall.args.first.value, isA<ActionStringLiteralExpr>());
  });

  test('parses block values and attached control flow nodes', () {
    final blockValue =
        parseActionExpression(r'{ set(x, "a"); x }') as ActionBlockValueExpr;
    expect(blockValue.block.statements, hasLength(2));
    expect(blockValue.block.statements.last.expr, isA<ActionVariableExpr>());

    final ifNode =
        parseActionExpression('if(flag) { set(out, "yes") }')
            as ActionControlIfExpr;
    expect(ifNode.keyword, 'if');
    expect(ifNode.condition, isA<ActionVariableExpr>());
    expect(ifNode.body!.statements.single.expr, isA<ActionCallExpr>());

    final branchBlock = parseActionBlock(
      'if(false) { set(out, "bad") } '
      'elseif(true) { set(out, "yes") } '
      'else { set(out, "no") }',
    );
    expect(branchBlock.statements.map((statement) => statement.expr.kind), [
      'control_if',
      'control_if',
      'control_else',
    ]);
    expect(
      (branchBlock.statements[1].expr as ActionControlIfExpr).branchRole,
      'elseif',
    );

    final whileNode =
        parseActionExpression('while(flag) { next() }')
            as ActionControlWhileExpr;
    expect(whileNode.condition, isA<ActionVariableExpr>());
    expect(whileNode.body!.statements.single.expr, isA<ActionCallExpr>());

    final switchNode =
        parseActionExpression(
              'switch(kind) { case("a") { return("hit") } default { return("miss") } }',
            )
            as ActionControlSwitchExpr;
    expect(switchNode.sourceExpr, isA<ActionVariableExpr>());
    expect(switchNode.cases, hasLength(1));
    expect(switchNode.defaultCase, isNotNull);
  });

  test('keeps unsupported expressions structural as raw_perl nodes', () {
    final raw = parseActionExpression('@invalid') as ActionRawExpr;
    expect(raw.reason, 'unsupported_expression');
    expect(raw.toJson()['kind'], 'raw_perl');
  });
}
