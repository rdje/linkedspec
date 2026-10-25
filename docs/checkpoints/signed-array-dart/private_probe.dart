// Appended only to a byte-verified copy of the production interpreter library.
// This observes private stores; public grammar/carrier coverage is independent.
Map<String, Object?> signedPrivateObserve(
  LinkedSpecRuntimeEngine engine,
  Map<String, Object?> row,
) {
  final events = <String>[];
  String? failingMarker;
  RuntimeInterpreterException? injected;
  for (final part in [
    ...row['segments']! as List,
    row['rhs'],
  ]) {
    if (part is Map && part['evaluation_error'] is Map) {
      final error = part['evaluation_error'] as Map;
      injected = RuntimeInterpreterException(
        error['message'] as String,
        diagnostic: RuntimeDiagnostic(
          type: 'fixture', stage: 'caller_diagnostic_sink',
          summary: 'injected fixture failure', detail: error['message'] as String,
          code: error['code'] as String,
        ),
      );
    }
  }
  final context = _RuntimeExecutionContext(
    engine: engine, input: 'x', maxIterations: 10000, topRule: 'Top',
    trace: null, semanticObservationSink: null,
    diagnosticOutputSink: (event) {
      final marker = event.message.trimRight();
      events.add(marker);
      if (marker == failingMarker) throw injected!;
    },
  );
  final binding = row['binding']! as String;
  final initial = row['initial_binding']! as Map;
  final original = initial['value'];
  if (initial['present'] == true) context.variables[binding] = original;
  final guard = row['guard'] as Map?;
  int? active;
  _ScopedVariableBinding? scope;
  if (guard != null) {
    active = context.activateReceiverMutation(binding);
    if (active == null) throw StateError('missing guard identity');
    if (guard['active_identity'] != guard['target_identity']) {
      scope = context.enterScopedScalar(binding, original);
    }
  }
  final targetIdentity = context.visibleBindingIdentity(binding);
  final result = <String, Object?>{'id': row['id']};
  if (guard != null) {
    result['same_identity'] = active == targetIdentity;
  }
  Object? returned;
  if (row['private_kind'] == 'read') {
    for (final part in row['segments']! as List) {
      final name = (part as Map)['source'] as String;
      if (RegExp(r'^[A-Za-z_][A-Za-z_0-9]*$').hasMatch(name)) {
        context.variables[name] = part['value'];
      }
    }
    returned = engine._evaluateExpression(
      parseActionExpression(row['source']! as String), context, 'Top', currentEdge: null,
    );
    result['ok'] = returned;
  } else {
    final parsed = parseActionExpression(row['source']! as String)
        as ActionAssignNestedAccessExpr;
    final parts = (row['segments']! as List).cast<Map>();
    final rhs = row['rhs']! as Map;
    ActionExpr operand(Map part, String marker, int index) {
      final name = '__signed_value_$index';
      context.variables[name] = part['value'];
      if (part['evaluation_error'] != null) failingMarker = marker;
      final statements = <String>['say("$marker")'];
      if (part.containsKey('same_binding_after')) {
        final effect = '__signed_effect_$index';
        context.variables[effect] = part['same_binding_after'];
        statements.add('$binding=$effect');
      }
      statements.add(name);
      final body = statements.join('; ');
      return ActionBlockValueExpr(
        source: body, sourceSpan: const ActionSourceSpan(start: 0, end: 0),
        block: parseActionBlock(body),
      );
    }
    final expression = ActionAssignNestedAccessExpr(
      source: parsed.source, sourceSpan: parsed.sourceSpan, base: parsed.base,
      segments: [
        for (var index = 0; index < parts.length; index++)
          ActionWritePathSegment(
            source: parsed.segments[index].source,
            sourceSpan: parsed.segments[index].sourceSpan,
            expression: operand(parts[index], 'segment:$index', index),
          ),
      ],
      value: operand(rhs, 'rhs', parts.length),
    );
    try {
      returned = engine._evaluateExpression(expression, context, 'Top', currentEdge: null);
      result['ok'] = _copyValue(returned);
    } on _RuntimeDiagnosticOutputSinkFailure catch (failure) {
      if (failure.error is! RuntimeInterpreterException) rethrow;
      result['error'] = (failure.error as RuntimeInterpreterException).toJson();
      result['injected_identity'] = identical(failure.error, injected);
    } on RuntimeInterpreterException catch (error) {
      result['error'] = error.toJson();
      if (injected != null) result['injected_identity'] = identical(error, injected);
    }
    if (row['detachment'] case final Map probe) {
      final stored = _rootStorageForWrite(context, binding).value;
      result['binding_before_detachment'] = _copyValue(stored);
      final targets = <String, Object?>{
        'initial': original, 'rhs': rhs['value'],
        'binding': stored, 'result': returned,
      };
      for (final mutation in probe['mutations'] as List) {
        final change = mutation as Map;
        final path = change['path'] as List;
        dynamic receiver = targets[change['target']];
        for (final key in path.take(path.length - 1)) {
          receiver = receiver[key];
        }
        receiver[path.last] = change['value'];
      }
      result['detachment'] = targets;
    }
  }
  final stored = _rootStorageForWrite(context, binding);
  result['binding'] = {
    'present': stored.present,
    if (stored.present) 'value': stored.value,
  };
  result['effects'] = events;
  if (scope != null) {
    context.exitScopedVariable(scope);
    result['outer_restored'] = context.visibleBindingIdentity(binding) == active;
    result['outer_value'] = _rootStorageForWrite(context, binding).value;
  }
  if (active != null) context.deactivateReceiverMutation(active);
  failingMarker = null;
  return result;
}

Map<String, Object?> signedPrivateArithmetic(
  LinkedSpecRuntimeEngine engine, Map<String, Object?> row,
) {
  final length = row['length']! as int;
  final index = row['index']! as int;
  final items = List<Object?>.generate(length, (offset) => offset);
  final source = 'tree[$index] = 99';
  final actual = signedPrivateObserve(engine, {
    'id': row['id'], 'binding': 'tree', 'source': source,
    'initial_binding': {'present': true, 'value': items},
    'segments': [{'source': '$index', 'value': index}],
    'rhs': {'source': '99', 'value': 99},
  });
  actual['read'] = _indexValue(List<Object?>.generate(length, (offset) => offset), index);
  return actual;
}
