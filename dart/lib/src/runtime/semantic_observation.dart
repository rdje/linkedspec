import 'dart:convert' show utf8;

import '../semantic/sha256.dart' show sha256Hex;

/// Versioned identity carried by every runtime semantic observation event.
const linkedSpecSemanticExecutionObservationContract =
    'linkedspec-semantic-execution-observation-v1';

/// Closed event vocabulary captured during one normal runtime invocation.
enum RuntimeSemanticObservationEventKind {
  regexSlotSelected('regex_slot_selected'),
  ruleResult('rule_result');

  const RuntimeSemanticObservationEventKind(this.wireName);

  final String wireName;
}

/// One immutable typed fact delivered during normal parser execution.
///
/// The public constructor lets callers retain, serialize, and later validate
/// event sequences without exposing runtime context or compiled host objects.
final class RuntimeSemanticObservationEvent {
  const RuntimeSemanticObservationEvent({
    required this.contractId,
    required this.eventKind,
    required this.ruleLabel,
    required this.targetRule,
    required this.regexIndex,
    required this.position,
    required this.inputIdentity,
    required this.status,
  });

  factory RuntimeSemanticObservationEvent.regexSlotSelected({
    required String ruleLabel,
    required String targetRule,
    required int regexIndex,
    required int position,
  }) => RuntimeSemanticObservationEvent(
    contractId: linkedSpecSemanticExecutionObservationContract,
    eventKind: RuntimeSemanticObservationEventKind.regexSlotSelected,
    ruleLabel: ruleLabel,
    targetRule: targetRule,
    regexIndex: regexIndex,
    position: position,
    inputIdentity: null,
    status: null,
  );

  factory RuntimeSemanticObservationEvent.ruleResult({
    required String ruleLabel,
    required int position,
    required String input,
  }) => RuntimeSemanticObservationEvent(
    contractId: linkedSpecSemanticExecutionObservationContract,
    eventKind: RuntimeSemanticObservationEventKind.ruleResult,
    ruleLabel: ruleLabel,
    targetRule: null,
    regexIndex: null,
    position: position,
    inputIdentity: 'input:sha256:${sha256Hex(utf8.encode(input))}',
    status: 'succeeded',
  );

  final String contractId;
  final RuntimeSemanticObservationEventKind eventKind;
  final String ruleLabel;
  final String? targetRule;
  final int? regexIndex;
  final int position;
  final String? inputIdentity;
  final String? status;

  Map<String, Object?> toJson() => {
    'contract_id': contractId,
    'event_kind': eventKind.wireName,
    'rule_label': ruleLabel,
    'target_rule': targetRule,
    'regex_index': regexIndex,
    'position': position,
    'input_identity': inputIdentity,
    'status': status,
  };

  @override
  bool operator ==(Object other) =>
      other is RuntimeSemanticObservationEvent &&
      other.contractId == contractId &&
      other.eventKind == eventKind &&
      other.ruleLabel == ruleLabel &&
      other.targetRule == targetRule &&
      other.regexIndex == regexIndex &&
      other.position == position &&
      other.inputIdentity == inputIdentity &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    contractId,
    eventKind,
    ruleLabel,
    targetRule,
    regexIndex,
    position,
    inputIdentity,
    status,
  );
}

/// Optional caller-owned synchronous sink installed for one invocation.
typedef RuntimeSemanticObservationSink =
    void Function(RuntimeSemanticObservationEvent event);
