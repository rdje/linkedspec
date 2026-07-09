import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'spec AST round-trips through JSON with backend-neutral field names',
    () {
      final spec = SpecFile(
        functions: [
          FunctionDefinition(
            name: 'normalize',
            params: const ['value'],
            arity: 1,
            bodySource: 'return(trim(value))',
            bodyPayload: const {'kind': 'action_block'},
            bodyParseJob: const StagedParseJob(
              jobId: 'parse_job:function_body:functions.0.body_source',
              parentAstPath: ['functions', '0', 'body_source'],
              nodeKind: 'function_definition',
              payloadKind: 'action_block',
              text: 'return(trim(value))',
              sourceSpan: StagedSourceSpan(
                start: 10,
                end: 28,
                lineStart: 1,
                lineEnd: 1,
              ),
              parserSpecId: 'actionir-body.spec',
              topRule: 'action_block',
              resultPolicy: 'replace_field',
              resultField: 'body_ast',
              failurePolicy: 'diagnostic',
            ),
            bodyAst: const {'kind': 'code_block', 'statements': <Object?>[]},
            source: 'fn normalize(value) { return(trim(value)) }',
            sourceSpan: const SourceSpan(lineStart: 1, lineEnd: 1),
            bodySpan: const SourceSpan(lineStart: 1, lineEnd: 1),
          ),
        ],
        rules: [
          Rule(
            header: RuleHeader(
              label: 'Top',
              isTop: true,
              mode: RuleMode.andBounded(min: 1, max: 2),
              rest: '/x/ -> Child[0] { return(normalize(retv)) }',
              line: 2,
            ),
            body: const [
              BodyElement(
                kind: RegexBodyElementKind(pattern: 'x'),
                source: '/x/',
                line: 2,
              ),
              BodyElement(
                kind: ActionEdgeBodyElementKind(
                  targets: [EdgeTarget(label: 'Child')],
                  code: 'return(normalize(retv))',
                  fluentChain: [FluentCall(method: 'push', args: '')],
                ),
                source: '-> Child[0] { return(normalize(retv)) }.push',
                line: 2,
              ),
              BodyElement(
                kind: CodeBlockBodyElementKind(
                  lifecycle: 'I',
                  code: 'set(count, 0)',
                ),
                source: 'I { set(count, 0) }',
                line: 3,
              ),
            ],
          ),
        ],
      );

      final encoded = jsonEncode(spec.toJson());
      final decoded = SpecFile.fromJson(
        jsonDecode(encoded) as Map<String, Object?>,
      );

      expect(decoded.functions.single.name, 'normalize');
      expect(decoded.functions.single.bodyParseJob!.kind, 'parse_job');
      expect(decoded.topRule!.header.mode, RuleMode.andBounded(min: 1, max: 2));
      expect(decoded.topRule!.header.mode.isAnd, isTrue);
      expect(decoded.topRule!.header.mode.repMin, 1);
      expect(decoded.topRule!.header.mode.repMax, 2);
      expect(decoded.topRule!.body[1].kind, isA<ActionEdgeBodyElementKind>());
      expect(decoded.toJson(), spec.toJson());
    },
  );

  test('rule modes expose Rust-equivalent repetition helpers', () {
    expect(RuleMode.defaultMode.repMin, 0);
    expect(RuleMode.star.repMin, 0);
    expect(RuleMode.optional.repMax, 1);
    expect(RuleMode.plus.repMin, 1);
    expect(RuleMode.and.isAnd, isTrue);
    expect(RuleMode.or.isAnd, isFalse);
    expect(RuleMode.orBounded(min: 2).repMax, isNull);
  });
}
