import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  final selfHostedRegexArtifact = File(
    '../unicode_case/unicode_rule_label_regex_class.txt',
  ).readAsLinesSync();
  final ruleLabelAtom = selfHostedRegexArtifact.last;
  final canonicalSource = File('../specs/spec.spec').readAsStringSync();

  test('canonical grammar consumes the exact generated label atom', () {
    expect(ruleLabelAtom, startsWith('['));
    expect(ruleLabelAtom, endsWith(']+'));
    expect(ruleLabelAtom.runes.any((scalar) => scalar > 0xFFFF), isTrue);
    expect(ruleLabelAtom.allMatches(canonicalSource), hasLength(12));
  });

  test('runtime regex enables Unicode mode for supplementary label ranges', () {
    final alternation = RuntimeRegexAlternation.compile([ruleLabelAtom]);

    expect(alternation.alternatives.single.regex.isUnicode, isTrue);
    expect(alternation.consumeMatch('𐐀Rule', 0)?.text, '𐐀Rule');
  });

  test('current canonical grammar executes every Unicode label edge form', () {
    final compiled = compileSpec(parseSpec(canonicalSource));
    final result = LinkedSpecRuntimeEngine(compiled).execute(r'''
Töp::
 /x/
 -> Δοκιμή { return("action") }
 -> Töp.trim()
 -> 𐐀Rule[2]
 => 規則 { return("blind") }
 => A·B.trim()
 => 9_rule
 _ { return("bare") }
 töp.trim()
 Δοκιμή[1]
''');

    expect(result.matched, isTrue);
    final paragraphs = (result.value! as List<Object?>).cast<List<Object?>>();
    final nodes = paragraphs.single.cast<Map<Object?, Object?>>();
    expect(nodes, hasLength(11));
    expect(nodes[0], containsPair('label', 'Töp'));
    expect(nodes[2], containsPair('targets', 'Δοκιμή'));
    expect(nodes[3], containsPair('target', 'Töp'));
    expect(nodes[4], containsPair('target', '𐐀Rule'));
    expect(nodes[4], containsPair('index', '2'));
    expect(nodes[5], containsPair('target', '規則'));
    expect(nodes[6], containsPair('target', 'A·B'));
    expect(nodes[7], containsPair('target', '9_rule'));
    expect(nodes[8], containsPair('targets', '_'));
    expect(nodes[9], containsPair('target', 'töp'));
    expect(nodes[10], containsPair('target', 'Δοκιμή'));
    expect(nodes[10], containsPair('index', '1'));
  });
}
