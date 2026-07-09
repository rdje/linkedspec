import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('executes specs/user_function_definition.spec for definition nodes', () {
    final parserSpecSource = File(
      '../$userFunctionDefinitionSpecRelativePath',
    ).readAsStringSync();
    final source = [
      'fn zero() {return("zero")}',
      'Top::',
      ' /x/ -> Done { return(zero()) }',
      '',
      'Done:',
      ' /[a-z]+/',
      '',
      'fn after(value) { return(value) }',
      '',
    ].join('\n');

    final nodes = parseUserFunctionDefinitionAsts(
      source,
      parserSpecSource: parserSpecSource,
    );

    expect(nodes, hasLength(2));
    final zero = nodes.first! as Map<String, Object?>;
    expect(zero['type'], 'function_definition');
    expect(zero['kind'], 'user_function_definition');
    expect(zero['name'], 'zero');
    expect(zero['params'], isEmpty);
    expect(zero['body_source'], 'return("zero")');

    final after = nodes.last! as Map<String, Object?>;
    expect(after['name'], 'after');
    expect(after['params'], ['value']);
    expect(after['body_source'], ' return(value) ');
  });

  test('parses full source with staged function bodies from spec shell', () {
    final parserSpecSource = File(
      '../$userFunctionDefinitionSpecRelativePath',
    ).readAsStringSync();
    final source = [
      'fn zero() {return("zero")}',
      'Top::',
      ' /x/ -> Done { return(zero()) }',
      '',
      'Done:',
      ' /[a-z]+/',
    ].join('\n');

    final spec = parseSpecWithStagedUserFunctionDefinitions(
      source,
      parserSpecSource: parserSpecSource,
    );

    expect(spec.functions, hasLength(1));
    expect(spec.functions.single.bodyParseJob!.parentAstPath, [
      'functions',
      '0',
      'body_source',
    ]);
    expect(spec.functions.single.bodyAst, isA<Map<String, Object?>>());
    expect(spec.rules.map((rule) => rule.header.label), ['Top', 'Done']);
  });

  test('normalizes supported shell output wrapper shapes', () {
    final node = {'type': 'function_definition'};

    expect(definitionNodesFromUserFunctionDefinitionOutput(null), isEmpty);
    expect(definitionNodesFromUserFunctionDefinitionOutput([]), isEmpty);
    expect(definitionNodesFromUserFunctionDefinitionOutput(node), [node]);
    expect(definitionNodesFromUserFunctionDefinitionOutput([node]), [node]);
    expect(
      definitionNodesFromUserFunctionDefinitionOutput([
        [node],
        <Object?>[],
      ]),
      [node],
    );
  });
}
