import 'matching.dart';

/// Contract-v2 generated rule families shared by emission and execution.
enum GeneratedRuleFamily {
  defaultFamily('default', usesBlindDispatch: false),
  orAcode('or_acode', usesBlindDispatch: false),
  andSingleAcode('and_single_acode', usesBlindDispatch: false),
  andAcodeSeq('and_acode_seq', usesBlindDispatch: false),
  andBcode('and_bcode', usesBlindDispatch: true),
  orBcode('or_bcode', usesBlindDispatch: true),
  repAcode('rep_acode', usesBlindDispatch: false),
  repBcode('rep_bcode', usesBlindDispatch: true),
  repAndAcode('rep_and_acode', usesBlindDispatch: false),
  repAndBcode('rep_and_bcode', usesBlindDispatch: true);

  const GeneratedRuleFamily(this.wireName, {required this.usesBlindDispatch});

  final String wireName;
  final bool usesBlindDispatch;

  /// Derive cursor policy from the validated neutral family row.
  LinkedSpecParseMode get cursorPolicy {
    return switch (this) {
      defaultFamily ||
      orAcode ||
      orBcode ||
      repAcode ||
      repBcode => LinkedSpecParseMode.seek,
      andSingleAcode ||
      andAcodeSeq ||
      andBcode ||
      repAndAcode ||
      repAndBcode => LinkedSpecParseMode.consume,
    };
  }

  /// Derive sequence/choice structure from the validated neutral family row.
  bool get usesAndExecution => cursorPolicy == LinkedSpecParseMode.consume;

  static GeneratedRuleFamily? fromWireName(String wireName) {
    for (final family in values) {
      if (family.wireName == wireName) {
        return family;
      }
    }
    return null;
  }
}

/// One backend-neutral generated plan row.
final class GeneratedPlanRow {
  const GeneratedPlanRow({required this.label, required this.family});

  final String label;
  final String family;

  Map<String, Object?> toJson() => {'label': label, 'family': family};

  @override
  bool operator ==(Object other) {
    return other is GeneratedPlanRow &&
        other.label == label &&
        other.family == family;
  }

  @override
  int get hashCode => Object.hash(label, family);
}
