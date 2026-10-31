// TYPE-REFERENCE-BOOK.1.2.23.3.63.3 — canonical arithmetic source and Number-prefix result guards.
import 'dart:convert';
import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

Map<String, Object? Function()> routes(String source, String input) {
  final parsed = parseSpecWithStagedUserFunctionDefinitions(source);
  final compiled = compileSpec(parsed);
  final restored = SpecFile.fromJson(
    (jsonDecode(jsonEncode(parsed.toJson())) as Map).cast<String, Object?>(),
  );
  return {
    'native': () => LinkedSpecRuntimeEngine(compiled).execute(input).value,
    'restored': () =>
        LinkedSpecRuntimeEngine(compileSpec(restored)).execute(input).value,
    'plan': () => executeGeneratedParserV2(
      compiled,
      buildGeneratedRulePlan(compiled),
      input,
      'free-numeric-result-composition.spec',
    ),
  };
}

void check(String label, String source, String input, Object? expected) {
  final observed = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      observed[route.key] = {'ok': route.value()};
    } catch (error) {
      observed[route.key] = {'unexpected_error': error.toString()};
    }
  }
  print('FREE_NUMERIC_VALUE $label ${jsonEncode(observed)}');
  for (final row in observed.entries) {
    expect(row.value, {'ok': expected}, reason: row.key);
  }
}

Map<String, Object?> errorRows(String source, String input) {
  final actual = <String, Object?>{};
  for (final route in routes(source, input).entries) {
    try {
      actual[route.key] = {'value': route.value()};
    } catch (error) {
      actual[route.key] = {
        'error': error.toString(),
        'class': error.runtimeType.toString(),
        if (error is RuntimeInterpreterException)
          'diagnostic': error.diagnostic?.toJson(),
      };
    }
  }
  return actual;
}

void main() {
  test('primitive_arithmetic', () {
    check(
      'primitive_arithmetic',
      r'''Value:: I {return([num_abs(-3),num_floor(3.8),num_ceil(3.2),num_round(2.5),num_add(1,2,3),num_sub(5,2),num_mul(2,3,4),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(7,3,5),num_max(3,5,4)])}''',
      'x',
      jsonDecode(r'''[3,3,4,3,6,3,24,3.5,1,10,3,5]'''),
    );
  });
  test('compatible_values', () {
    check(
      'compatible_values',
      r'''Value:: I {return([num_add(2,3).cat("!"),num_div(6,2).cat(",tail").split(",").last().uppercase(),num_add(0,0).coalesce_nonempty(9).add(1),2.add(3).cat("!")])}''',
      'x',
      jsonDecode(r'''["5!","TAIL",1,"5!"]'''),
    );
  });
  test('free_container_guards', () {
    check(
      'free_container_guards',
      r'''Value:: I {order="";left=num_add(1,2).take({order=cat(order,"A");1});right=num_sub(5,2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('receiver_container_guards', () {
    check(
      'receiver_container_guards',
      r'''Value:: I {order="";left=1.add(2).take({order=cat(order,"A");1});right=5.sub(2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}''',
      'x',
      jsonDecode(r'''[null,null,""]'''),
    );
  });
  test('free_guard_before_with', () {
    check(
      'free_guard_before_with',
      r'''Value:: I {order="";out=num_add({order=cat(order,"S");return(1)},2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('receiver_guard_before_with', () {
    check(
      'receiver_guard_before_with',
      r'''Value:: I {order="";out={order=cat(order,"S");return(1)}.add(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,"S"]'''),
    );
  });
  test('free_bridge_rejection', () {
    check(
      'free_bridge_rejection',
      r'''Value:: I {order="";out=num_add(1,2).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('receiver_bridge_rejection', () {
    check(
      'receiver_bridge_rejection',
      r'''Value:: I {order="";out=1.add(2).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}''',
      'x',
      jsonDecode(r'''[null,""]'''),
    );
  });
  test('valid_array_bridges', () {
    check(
      'valid_array_bridges',
      r'''Value:: I {return([num_add(1,2).split(",").first().cat("!"),1.add(2).split(",").first().cat("!")])}''',
      'x',
      jsonDecode(r'''["3!","3!"]'''),
    );
  });
  test('source_operand_snapshot', () {
    check(
      'source_operand_snapshot',
      r'''Value:: I {value=3;order="";out=num_add({order=cat(order,"S");return(value)},{value=99;order=cat(order,"O");return(2)}).cat({order=cat(order,"C");"!"});return([out,value,order])}''',
      'x',
      jsonDecode(r'''["5!",99,"SOC"]'''),
    );
  });
  test('zero_typed_indices', () {
    check(
      'zero_typed_indices',
      r'''Value:: I {slots=["old"];index=num_add(0,0).copy();slots[index]="free";other=0.add(0).copy();slots[other]="receiver";return([index,other,slots])}''',
      'x',
      jsonDecode(r'''[0,0,["receiver"]]'''),
    );
  });
  test('valid_null_with', () {
    check(
      'valid_null_with',
      r'''Value:: I {order="";left=num_div(1,0).with(){order=cat(order,"F");return("free")};right=1.div(0).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}''',
      'x',
      jsonDecode(r'''["free","receiver","FR"]'''),
    );
  });
  test('valid_empty_with', () {
    check(
      'valid_empty_with',
      r'''Value:: I {order="";out=num_div(1,0).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}''',
      'x',
      jsonDecode(r'''[0,"W"]'''),
    );
  });
  test('all_canonical_free_guards', () {
    check(
      'all_canonical_free_guards',
      r'''Value:: I {order="";out=[num_abs(-3).take({order=cat(order,"A");1}),num_floor(3.8).take({order=cat(order,"A");1}),num_ceil(3.2).take({order=cat(order,"A");1}),num_round(2.5).take({order=cat(order,"A");1}),num_add(1,2,3).take({order=cat(order,"A");1}),num_sub(5,2).take({order=cat(order,"A");1}),num_mul(2,3,4).take({order=cat(order,"A");1}),num_div(7,2).take({order=cat(order,"A");1}),num_mod(7,3).take({order=cat(order,"A");1}),num_clamp(12,0,10).take({order=cat(order,"A");1}),num_min(7,3,5).take({order=cat(order,"A");1}),num_max(3,5,4).take({order=cat(order,"A");1})];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('all_short_receiver_with_guards', () {
    check(
      'all_short_receiver_with_guards',
      r'''Value:: I {order="";out=[3.abs().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.8.floor().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.2.ceil().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.5.round().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},1.add(2,3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},5.sub(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.mul(3,4).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.div(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.mod(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},12.clamp(0,10).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.min(3,5).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.max(5,4).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}''',
      'x',
      jsonDecode(
        r'''[[null,null,null,null,null,null,null,null,null,null,null,null],""]''',
      ),
    );
  });
  test('function_scope', () {
    check(
      'function_scope',
      r'''fn build(){order="";left=num_add(1,2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=1.add(2).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}''',
      'x',
      jsonDecode(r'''[[null,null,""],"caller"]'''),
    );
  });
  test('needed source error precedes recovery', () {
    final actual = errorRows(
      r'''Value:: I {return(num_add({items="text";push(items,"x")},1).coalesce("masked"))}''',
      'x',
    );
    print('FREE_NUMERIC_ERROR ${jsonEncode(actual)}');
    for (final route in actual.entries) {
      expect(
        (route.value! as Map)['error'],
        contains('binding_kind_mismatch'),
        reason: route.key,
      );
    }
  });
  test('public excluded arithmetic source shapes stay current', () {
    final observed = <Object?>[];
    for (final source in [
      r'''num_abs().take(1).with(){return("x")}''',
      r'''num_add(1).take(1).with(){return("x")}''',
      r'''num_clamp(1,2).take(1)''',
      r'''num_add(first:1,second:2).take(1)''',
      r'''add(1,2).take(1)''',
      r'''+(1,2).take(1)''',
      r'''num_min([1,2]).take(1)''',
      r'''[1,2].min().with(){return(value)}''',
      r'''num_eq(1,1).take(1).with(){return("x")}''',
      r'''1.eq(1).take(1).with(){return("x")}''',
      r'''1.add().with(){return("x")}''',
      r'''1.add(2){return("x")}''',
      r'''{|| return(num_add(1,2).take(1)) }''',
      r'''num_add(1,2).map_leaves(){return(value)}''',
    ]) {
      try {
        observed.add({
          'source': source,
          'ast': parseActionExpression(source).toJson(),
        });
      } catch (error) {
        observed.add({
          'source': source,
          'error': error.toString(),
          'class': error.runtimeType.toString(),
        });
      }
    }
    expect(observed, hasLength(14));
    print('FREE_NUMERIC_SHAPES ${jsonEncode(observed)}');
  });
}
