import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('resolves canonical helper contracts through nested typed nodes', () {
    final block = parseActionBlock(
      'set(out, +(1, 2));\n'
      'if(gt(out, 0)) { return(cat("ok", out)) }\n'
      '" x ".trim().with() { return(value) }',
    );

    final resolution = resolveActionBlockContracts(block);

    expect(resolution.ok, isTrue);
    expect(_canonicalNames(resolution), containsAll(['set', 'num_add']));
    expect(_canonicalNames(resolution), containsAll(['if', 'num_gt']));
    expect(_canonicalNames(resolution), containsAll(['return', 'cat']));
    expect(_canonicalNames(resolution), containsAll(['trim', 'with']));

    final addContract = resolution.contracts.singleWhere(
      (contract) => contract.sourceName == '+',
    );
    expect(addContract.canonicalName, 'num_add');
    expect(addContract.family, 'numeric');
    expect(addContract.canonicalized, isTrue);

    final gtContract = resolution.contracts.singleWhere(
      (contract) => contract.sourceName == 'gt',
    );
    expect(gtContract.canonicalName, 'num_gt');
    expect(gtContract.positionalArgCount, 2);
  });

  test('maps structural assignment nodes to canonical contracts', () {
    final block = parseActionBlock(
      'name = "ok"; items += name; meta[name] = [name]; '
      r'payload["children"][0]["name"] = name',
    );

    final resolution = resolveActionBlockContracts(block);

    expect(resolution.ok, isTrue);
    expect(_contract(resolution, '=').canonicalName, 'set');
    expect(_contract(resolution, '+=').canonicalName, 'push');
    expect(_contract(resolution, '[]=').canonicalName, 'set_key');
    expect(
      _contract(resolution, 'nested_access=').canonicalName,
      'nested_access_assignment',
    );
  });

  test('diagnoses unknown helpers and raw fallback expressions', () {
    final block = parseActionBlock('unknown_helper(value); @invalid');

    final resolution = resolveActionBlockContracts(block);

    expect(resolution.ok, isFalse);
    expect(_diagnosticCodes(resolution), ['unknown_helper', 'raw_perl']);
    expect(resolution.diagnostics.first.helperName, 'unknown_helper');
  });

  test('shares known helper names with function registry validation', () {
    expect(isKnownActionIrCallName('cat'), isTrue);
    expect(isKnownActionIrCallName('gt'), isTrue);
    expect(isKnownActionIrCallName('push_back'), isTrue);
    expect(isKnownActionIrCallName('sorted_keys'), isTrue);
    expect(isKnownActionIrCallName('mystery_helper'), isFalse);
    expect(canonicalActionHelperName('>='), 'num_ge');

    final collision = SpecFile(
      rules: [
        Rule(
          header: const RuleHeader(
            label: 'Top',
            isTop: true,
            mode: RuleMode.defaultMode,
            rest: '',
            line: 1,
          ),
          body: [
            BodyElement(
              line: 2,
              source: '/x/',
              kind: const RegexBodyElementKind(pattern: 'x'),
            ),
          ],
        ),
      ],
      functions: const [
        FunctionDefinition(
          name: 'cat',
          params: ['value'],
          arity: 1,
          source: 'fn cat(value) { return(value) }',
          bodySource: ' return(value) ',
          sourceSpan: SourceSpan(lineStart: 1, lineEnd: 1),
          bodySpan: SourceSpan(lineStart: 1, lineEnd: 1),
        ),
      ],
    );

    expect(
      () => validateSpec(collision),
      throwsA(
        isA<SpecValidationException>().having(
          (error) => error.message,
          'message',
          contains('built-in helper/control name'),
        ),
      ),
    );
  });

  test('resolves exact-arity user calls before helper fallback', () {
    final registry = UserFunctionRegistry.fromFunctions([
      _function('normalize', const ['value']),
    ]);
    final block = parseActionBlock(
      'return(normalize(" x ")); normalize("x", "y"); mystery("z")',
    );

    final resolution = resolveActionBlockContracts(
      block,
      functionRegistry: registry,
    );

    final userContract = resolution.contracts.singleWhere(
      (contract) => contract.sourceName == 'normalize',
    );
    expect(userContract.family, 'user_function');
    expect(userContract.canonicalName, 'normalize');
    expect(userContract.positionalArgCount, 1);
    expect(_diagnosticCodes(resolution), [
      'user_function_arity_mismatch',
      'unknown_helper',
    ]);
    expect(
      resolution.diagnostics.first.message,
      contains("expects arity 1, got 2"),
    );
  });
}

List<String> _canonicalNames(ActionContractResolution resolution) {
  return [for (final contract in resolution.contracts) contract.canonicalName];
}

ActionResolvedContract _contract(
  ActionContractResolution resolution,
  String sourceName,
) {
  return resolution.contracts.singleWhere(
    (contract) => contract.sourceName == sourceName,
  );
}

List<String> _diagnosticCodes(ActionContractResolution resolution) {
  return [for (final diagnostic in resolution.diagnostics) diagnostic.code];
}

FunctionDefinition _function(String name, List<String> params) {
  return FunctionDefinition(
    name: name,
    params: params,
    arity: params.length,
    bodySource: 'return(value)',
    source: 'fn $name(${params.join(", ")}) { return(value) }',
    sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
    bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
  );
}
