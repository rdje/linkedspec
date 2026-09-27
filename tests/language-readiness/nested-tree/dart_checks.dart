import 'package:linkedspec_dart/linkedspec_dart.dart';

typedef Parse = Object? Function(String input);

void require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

// Check JSON kinds explicitly: a numeric-looking string is not a number.
void exactJson(Object? actual, Object? expected, [String path = r'$']) {
  if (expected is Map) {
    require(actual is Map, '$path must be an object');
    final value = actual as Map;
    require(value.length == expected.length, '$path object size');
    for (final key in expected.keys) {
      require(value.containsKey(key), '$path missing key $key');
      exactJson(value[key], expected[key], '$path.$key');
    }
  } else if (expected is List) {
    require(actual is List, '$path must be an array');
    final value = actual as List;
    require(value.length == expected.length, '$path array size');
    for (var index = 0; index < expected.length; index++) {
      exactJson(value[index], expected[index], '$path[$index]');
    }
  } else {
    final sameKind = switch (expected) {
      null => actual == null,
      bool() => actual is bool,
      num() => actual is num,
      String() => actual is String,
      _ => throw StateError('non-JSON oracle at $path'),
    };
    require(
      sameKind && actual == expected,
      '$path expected $expected, received $actual',
    );
  }
}

int sequence(Map<String, dynamic> cases, Parse parse) {
  final accepted = (cases['accept'] as List).cast<Map<String, dynamic>>();
  final rejected = (cases['reject'] as List).cast<Map<String, dynamic>>();
  require(accepted.length == 6 && rejected.length == 7, 'authored inventory');
  final recovery = accepted.singleWhere((row) => row['id'] == 'nested_state');
  var executions = 0;
  for (var round = 0; round < 2; round++) {
    for (final row in accepted) {
      exactJson(
        parse(row['input'] as String),
        row['expected'],
        row['id'] as String,
      );
      executions++;
    }
    for (final row in rejected) {
      var rejectedWithTypedExit = false;
      try {
        parse(row['input'] as String);
      } on RuntimeExitNow catch (error) {
        require(error.status == 1, '${row['id']} exact exit status');
        rejectedWithTypedExit = true;
      }
      require(
        rejectedWithTypedExit,
        '${row['id']} must reject without a value',
      );
      exactJson(
        parse(recovery['input'] as String),
        recovery['expected'],
        'recovery after ${row['id']}',
      );
      executions += 2;
    }
  }
  require(executions == 40, 'complete execution sequence');
  return executions;
}

void mutation(String id, Map<String, dynamic> cases, Parse parse) {
  final (group, caseId) = switch (id) {
    'prefix' => ('reject', 'hidden_prefix'),
    'gap' => ('reject', 'interstitial_junk'),
    'span' => ('accept', 'nested_state'),
    _ => throw StateError('unknown mutation $id'),
  };
  final row = (cases[group] as List).cast<Map<String, dynamic>>().singleWhere(
    (row) => row['id'] == caseId,
  );
  final value = parse(row['input'] as String);
  require(value is List, '$id mutant must execute and return a document');
  final forms = value as List;
  if (id == 'span') {
    exactJson((forms.first as Map)['span'], [9, 9]);
    final expected = row['expected'] as List;
    exactJson((expected.first as Map)['span'], [0, 9]);
  } else {
    require(
      forms.length == (id == 'prefix' ? 1 : 2),
      '$id mutant wrongly accepts surrounding forms',
    );
  }
}
