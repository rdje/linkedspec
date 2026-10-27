// TYPE-REFERENCE-BOOK.1.2.23.3.31.6.2 — callback invocation identity controls.
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
      'callback-identity.spec',
    ),
  };
}

void check(String source, String input, Object? expected) {
  for (final route in routes(source, input).entries) {
    final actual = route.value();
    print('CALLBACK_IDENTITY ${route.key} ${jsonEncode(actual)}');
    expect(actual, expected, reason: route.key);
  }
}

String top(String body) => 'Top:: I {$body}';
void reject(String body, String code, String name, List<String>? cycle) {
  for (final route in routes(top(body), 'x').entries) {
    Object? failure;
    try {
      route.value();
    } catch (error) {
      failure = error;
    }
    print('CALLBACK_ERROR ${route.key} $failure');
    expect(failure, isNotNull, reason: route.key);
    final text = failure.toString();
    expect(text, contains(code), reason: route.key);
    expect(
      text,
      contains('${cycle == null ? 'name' : 'callable_name'}="$name"'),
      reason: route.key,
    );
    if (cycle != null) {
      expect(text, contains('cycle=$cycle'), reason: route.key);
    }
    if (failure is RuntimeInterpreterException) {
      final diagnostic = failure.diagnostic?.toJson();
      expect(diagnostic?['code'], code);
      expect(diagnostic?['stage'], 'callable_codeblock_invocation');
      expect(diagnostic?[cycle == null ? 'name' : 'callable_name'], name);
      if (cycle != null) {
        expect(diagnostic?['cycle'], cycle);
        expect(
          diagnostic?['handler_source_label'],
          'dart_runtime:codeblock:$name',
        );
      }
    }
  }
}

void main() {
  test('distinct explicit callbacks restore their parameters', () {
    check(
      top(
        r'''value="saved";result=with("outer",{|outer|return(with("inner",{|inner|return(cat(outer,inner))}))});return([result,value,coalesce(outer,"missing"),coalesce(inner,"missing")]);''',
      ),
      'x',
      ['outerinner', 'saved', 'missing', 'missing'],
    );
  });

  test('distinct nested helper callbacks restore outer value', () {
    check(
      top(
        r'''value="outer";result=with("outside"){return(with("inside"){return(value)})};return([result,value]);''',
      ),
      'x',
      ['inside', 'outer'],
    );
  });
  test('distinct nested tree callbacks', () {
    check(
      top(
        r'''return([1].map_leaves(){return([value].map_leaves(){return(value)})})''',
      ),
      'x',
      [
        [1],
      ],
    );
  });
  test('helper bound cycle retains cb identity', () {
    reject(
      r'''calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));''',
      'codeblock_recursion_unsupported',
      'cb',
      ['cb', 'cb'],
    );
  });
  test('receiver bound cycle retains cb identity', () {
    reject(
      r'''calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),v.with(cb),"escaped"))};return(cb("x"));''',
      'codeblock_recursion_unsupported',
      'cb',
      ['cb', 'cb'],
    );
  });
  test('opaque helper callback retains active cycle rejection', () {
    reject(
      r'''calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,coalesce(cb,cb)),"escaped"))};return(cb("x"));''',
      'codeblock_recursion_unsupported',
      'cb',
      ['cb', 'cb'],
    );
  });
  test('anonymous body keeps unknown helper error', () {
    reject(
      r'''return(with("x"){return(missing())})''',
      'unknown_helper',
      'missing',
      null,
    );
  });
  test('direct and mutual cycles retain order', () {
    reject(
      r'''calls=0;reader={||calls=num_add(calls,1);return(if(num_lt(calls,4),reader(),"escaped"))};return(reader());''',
      'codeblock_recursion_unsupported',
      'reader',
      ['reader', 'reader'],
    );
    reject(
      r'''calls=0;a={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),b(v),"escaped"))};b={|v|return(a(v))};return(a("x"));''',
      'codeblock_recursion_unsupported',
      'a',
      ['a', 'b', 'a'],
    );
  });
}
