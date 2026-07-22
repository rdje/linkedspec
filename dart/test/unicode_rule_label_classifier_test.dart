// FUTURE-PARITY-BACKLOG.10.5.0.2.0 — generated Dart rule-label primitives.

import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/src/parser/unicode_rule_label.dart';
import 'package:test/test.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              '../capability_conformance/unicode_rule_label_contract.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final ranges = (contract['xid_continue_ranges']! as List<Object?>)
      .cast<List<Object?>>();
  final positives = (contract['positive_fixtures']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final negatives = (contract['negative_fixtures']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final distinct = (contract['distinct_fixtures']! as List<Object?>)
      .cast<Map<String, Object?>>();

  test('generated metadata and all range boundaries match the contract', () {
    expect(unicodeRuleLabelContractId, contract['contract_id']);
    expect(unicodeRuleLabelVersion, contract['unicode_version']);
    expect(unicodeRuleLabelDataSha256, contract['data_sha256']);
    expect(unicodeRuleLabelRangeCount, ranges.length);

    for (final range in ranges) {
      final start = int.parse(range[0]! as String, radix: 16);
      final end = int.parse(range[1]! as String, radix: 16);
      expect(
        isRuleLabelCodePoint(start),
        isTrue,
        reason: 'range start U+${range[0]}',
      );
      expect(
        isRuleLabelCodePoint(end),
        isTrue,
        reason: 'range end U+${range[1]}',
      );
    }
    expect(isRuleLabelCodePoint(-1), isFalse);
    expect(isRuleLabelCodePoint(0xD800), isFalse);
    expect(isRuleLabelCodePoint(0x110000), isFalse);
  });

  test('complete-label validation matches every neutral fixture', () {
    for (final fixture in positives) {
      final label = fixture['label']! as String;
      expect(isRuleLabel(label), isTrue, reason: fixture['id']! as String);
    }
    for (final fixture in negatives) {
      final label = fixture['label']! as String;
      expect(isRuleLabel(label), isFalse, reason: fixture['id']! as String);
    }
    for (final fixture in distinct) {
      final left = fixture['left']! as String;
      final right = fixture['right']! as String;
      expect(isRuleLabel(left), isTrue);
      expect(isRuleLabel(right), isTrue);
      expect(left, isNot(equals(right)), reason: fixture['id']! as String);
    }
  });

  test('longest-prefix scanning preserves scalar and UTF-16 boundaries', () {
    for (final fixture in positives) {
      final label = fixture['label']! as String;
      final scan = takeRuleLabelPrefix('$label[2]');
      expect(scan, isNotNull, reason: fixture['id']! as String);
      expect(scan!.label, label);
      expect(scan.remainder, '[2]');
    }

    final partial = takeRuleLabelPrefix('Top😀Rule');
    expect(partial!.label, 'Top');
    expect(partial.remainder, '😀Rule');
    expect(takeRuleLabelPrefix('😀Top'), isNull);
    expect(takeRuleLabelPrefix(''), isNull);
  });
}
