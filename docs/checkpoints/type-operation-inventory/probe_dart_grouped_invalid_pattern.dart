import 'dart:convert';

import '../../../dart/lib/linkedspec_dart.dart';

void main() {
  for (final expression in [
    r'/(/',
    r'matches("abc",/(/)',
    r'matches("abc",/a**/)',
    '/(8,2)',
    '/ (8,2)',
  ]) {
    final ast = parseActionExpression(expression);
    final row = <String, Object?>{
      'expression': expression,
      'ast': ast.toJson(),
    };
    try {
      final source = 'Top:: I { return($expression) }';
      final compiled = compileSpec(parseSpec(source));
      row['value'] = LinkedSpecRuntimeEngine(compiled).execute('x').value;
    } catch (error) {
      row['error'] = error.toString();
    }
    print(jsonEncode(row));
  }
}
