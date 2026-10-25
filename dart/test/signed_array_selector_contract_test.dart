import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tests/signed-array-dart/observe.dart';

bool _sameTyped(Object? actual, Object? expected) {
  if (expected is Map) {
    return actual is Map &&
        actual.length == expected.length &&
        expected.entries.every(
          (entry) =>
              actual.containsKey(entry.key) &&
              _sameTyped(actual[entry.key], entry.value),
        );
  }
  if (expected is List) {
    return actual is List &&
        actual.length == expected.length &&
        List.generate(
          expected.length,
          (index) => index,
        ).every((index) => _sameTyped(actual[index], expected[index]));
  }
  if (expected is num) {
    return actual is num &&
        actual.runtimeType == expected.runtimeType &&
        actual == expected;
  }
  return actual == expected;
}

void _check(Map<String, Object?> fixture, Map<String, Object?> actual) {
  final reason = '${fixture['id']}/${actual['route']}';
  expect(actual.containsKey('other_error'), isFalse, reason: reason);
  expect(
    _sameTyped(actual['effects'], fixture['effects']),
    isTrue,
    reason: '$reason effects',
  );
  final expected = (fixture['expected']! as Map).cast<String, Object?>();
  if (expected.containsKey('ok')) {
    expect(
      actual.containsKey('ok'),
      isTrue,
      reason: '$reason success: $actual',
    );
    expect(
      _sameTyped(actual['ok'], expected['ok']),
      isTrue,
      reason: '$reason value: $actual',
    );
    return;
  }
  expect(actual.containsKey('ok'), isFalse, reason: '$reason rejected');
  final target = (expected['error']! as Map).cast<String, Object?>();
  final injection = (fixture['injection'] as Map?)?.cast<String, Object?>();
  final callerFailure =
      injection != null && target['code'] == injection['code'];
  expect(
    actual.containsKey('native_error'),
    actual['route'] != 'generated_wrapper' || callerFailure,
    reason: '$reason exception carrier',
  );
  if (actual['native_error'] case final Map<Object?, Object?> error) {
    final diagnostic = (error['diagnostic']! as Map).cast<String, Object?>();
    for (final entry in target.entries) {
      final observed = entry.key == 'message'
          ? diagnostic['detail']
          : diagnostic[entry.key];
      expect(
        _sameTyped(observed, entry.value),
        isTrue,
        reason: '$reason ${entry.key}: $actual',
      );
    }
  } else {
    final error = (actual['generated_error']! as Map).cast<String, Object?>();
    expect(error['type'], 'generated_source_error', reason: reason);
    expect(error['stage'], 'execute_generated', reason: reason);
    expect(error['code'], 'generated_execution_failed', reason: reason);
    expect(
      error['source_identity'],
      'signed-array-dart/${fixture['id']}.spec',
      reason: reason,
    );
    expect(
      error['detail']! as String,
      endsWith(target['message']! as String),
      reason: reason,
    );
  }
  if (injection != null) {
    expect(actual['injected_identity'], callerFailure, reason: reason);
  }
}

void main() {
  final fixture =
      (jsonDecode(
                File(
                  '../tests/signed-array-dart/cases.json',
                ).readAsStringSync(),
              )
              as Map)
          .cast<String, Object?>();
  final cases = [
    for (final row in fixture['cases']! as List)
      (row as Map).cast<String, Object?>(),
  ];
  test('signed selector fixture preserves the frozen source population', () {
    expect(cases, hasLength(113));
    for (final context in ['ordinary', 'callable']) {
      expect(
        cases.where(
          (row) => row['kind'] == 'read' && row['context'] == context,
        ),
        hasLength(14),
      );
      final frozen = cases.where(
        (row) =>
            row['kind'] == 'write' &&
            row['context'] == context &&
            !const {
              'partial_creation_then_negative',
              'negative_prefix_then_creation',
              'invalid_after_negative_wrong_root',
              'unicode_span+astral_prefix',
            }.contains(row['neutral_id']),
      );
      expect(frozen, hasLength(33));
    }
  });
  for (final row in cases) {
    test('${row['id']} preserves values, effects and declared diagnostics', () {
      final prepared = PreparedSignedDartCase(row);
      for (final route in signedDartRoutes) {
        _check(row, prepared.observe(route));
      }
    });
  }
}
