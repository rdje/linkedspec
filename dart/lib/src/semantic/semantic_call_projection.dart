part of 'semantic_index.dart';

// FUTURE-PARITY-BACKLOG.10.5.3.1 — private typed call/binding core.

final class _SemanticCallDefinition {
  const _SemanticCallDefinition.function({
    required this.id,
    required this.startByte,
    required int index,
  }) : functionIndex = index,
       ruleLabel = null;

  const _SemanticCallDefinition.rule({
    required this.id,
    required this.startByte,
    required String label,
  }) : functionIndex = null,
       ruleLabel = label;

  final String id;
  final int startByte;
  final int? functionIndex;
  final String? ruleLabel;
}

final class _SemanticActionOwner {
  const _SemanticActionOwner({
    required this.ownerId,
    required this.block,
    required this.source,
  });

  final String ownerId;
  final ActionBlock block;
  final _SemanticSourceRange source;
}

final class _SemanticCallSite {
  const _SemanticCallSite({required this.name, required this.range});

  final String name;
  final _SemanticSourceRange range;
}

final class _SemanticCallCursor {
  _SemanticCallCursor(String source, int sourceStart)
    : _sites = _scanSemanticCalls(source, sourceStart);

  final List<_SemanticCallSite> _sites;
  var _next = 0;

  _SemanticSourceRange take(String name, String ownerId) {
    for (var index = _next; index < _sites.length; index += 1) {
      final site = _sites[index];
      if (site.name != name) {
        continue;
      }
      _next = index + 1;
      return site.range;
    }
    throw _semanticCallCorrelationError(
      'Typed call has no authored source occurrence',
      ownerId,
      fields: {'call_name': name},
    );
  }
}

final class _SemanticHelperContract {
  const _SemanticHelperContract({
    required this.parameters,
    required this.effects,
    required this.returnKind,
  });

  final List<(String, String)> parameters;
  final List<String> effects;
  final String returnKind;
}

const _semanticHelperContracts = <String, _SemanticHelperContract>{
  'trim': _SemanticHelperContract(
    parameters: [('value', 'value')],
    effects: [],
    returnKind: 'string',
  ),
  'match_text': _SemanticHelperContract(
    parameters: [],
    effects: ['reads_runtime_match'],
    returnKind: 'string',
  ),
  'return': _SemanticHelperContract(
    parameters: [('value', 'value')],
    effects: ['returns_owner'],
    returnKind: 'unknown',
  ),
};

void _extendSemanticCallProjection({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
  required SpecFile parsed,
  required CompiledSpec compiled,
  required Map<String, Object?> sourceRefs,
  required List<Map<String, Object?>> records,
  required List<Map<String, Object?>> relations,
}) {
  final functions = compiled.functions.toList(growable: false);
  if (functions.isEmpty) {
    return;
  }

  final functionRanges = [
    for (final function in functions)
      _semanticFunctionRange(
        sourceText: sourceText,
        sourceMap: sourceMap,
        function: function,
      ),
  ];
  final functionShapes = _inferSemanticFunctionShapes(functions);
  final definitions = <_SemanticCallDefinition>[];
  for (final (index, function) in functions.indexed) {
    final id = _semanticFunctionId(function.name);
    final range = functionRanges[index];
    definitions.add(
      _SemanticCallDefinition.function(
        id: id,
        startByte: sourceMap
            .spanForCodeUnitRange(range.start, range.end)
            .startByte,
        index: index,
      ),
    );
    _addSemanticFunction(
      sourceText: sourceText,
      sourceMap: sourceMap,
      logicalName: logicalName,
      contentDigest: contentDigest,
      sourceRefs: sourceRefs,
      records: records,
      relations: relations,
      function: function,
      functionOrder: index,
      declarationOrder: compiled.compiledRuleOrder.length + index,
      range: range,
      returnShape: functionShapes[function.name]!,
    );
  }
  for (final label in compiled.compiledRuleOrder) {
    final id = _semanticRuleId(label);
    definitions.add(
      _SemanticCallDefinition.rule(
        id: id,
        startByte: _semanticSourceStartByte(sourceRefs, id),
        label: label,
      ),
    );
  }
  definitions.sort((left, right) {
    final start = left.startByte.compareTo(right.startByte);
    return start != 0 ? start : left.id.compareTo(right.id);
  });
  final spec = records.singleWhere((record) => record['id'] == _semanticSpecId);
  final specFacts = spec['facts']! as Map<String, Object?>;
  specFacts['definition_order'] = [
    for (final definition in definitions) definition.id,
  ];

  final builder = _SemanticCallBuilder(
    sourceText: sourceText,
    sourceMap: sourceMap,
    logicalName: logicalName,
    contentDigest: contentDigest,
    sourceRefs: sourceRefs,
    records: records,
    relations: relations,
    functionRegistry: compiled.functionRegistry,
    functionShapes: functionShapes,
  );

  final actionOwners = _semanticActionOwners(
    parsed: parsed,
    compiled: compiled,
    sourceRefs: sourceRefs,
    sourceMap: sourceMap,
  );
  for (final definition in definitions) {
    if (definition.functionIndex case final index?) {
      final function = functions[index];
      final bodyRange = _semanticFunctionBodyRange(
        sourceText: sourceText,
        sourceMap: sourceMap,
        function: function,
      );
      final block = _semanticTypedFunctionBody(
        function,
        compiled.functionRegistry,
      );
      final cursor = _SemanticCallCursor(
        sourceText.substring(bodyRange.start, bodyRange.end),
        bodyRange.start,
      );
      var localOrder = 0;
      final variables = <String, Map<String, Object?>>{
        for (final name in function.params)
          name: _semanticValueShape('unknown'),
      };
      final ownerId = _semanticFunctionId(function.name);
      for (final statement in block.statements) {
        final expression = statement.expr;
        if (expression case ActionCallExpr(name: 'return', :final args)) {
          for (final argument in args) {
            builder.emitExpressionCalls(
              argument.value,
              ownerId: ownerId,
              cursor: cursor,
              localOrder: () => localOrder++,
              variables: variables,
              functionSurface: true,
            );
          }
          continue;
        }
        builder.emitStatement(
          expression,
          ownerId: ownerId,
          cursor: cursor,
          localOrder: () => localOrder++,
          variables: variables,
          functionSurface: true,
        );
      }
      continue;
    }

    final rulePrefix = 'edge:${_semanticRuleId(definition.ruleLabel!)}:';
    for (final owner in actionOwners.where(
      (candidate) => candidate.ownerId.startsWith(rulePrefix),
    )) {
      final cursor = _SemanticCallCursor(
        sourceText.substring(owner.source.start, owner.source.end),
        owner.source.start,
      );
      var localOrder = 0;
      final variables = <String, Map<String, Object?>>{};
      for (final statement in owner.block.statements) {
        builder.emitStatement(
          statement.expr,
          ownerId: owner.ownerId,
          cursor: cursor,
          localOrder: () => localOrder++,
          variables: variables,
          functionSurface: false,
        );
      }
    }
  }
  builder.applyEdgeShapes();
}

final class _SemanticEmittedCall {
  const _SemanticEmittedCall({
    required this.id,
    required this.source,
    required this.range,
  });

  final String id;
  final String source;
  final _SemanticSourceRange range;
}

final class _SemanticCallBuilder {
  _SemanticCallBuilder({
    required this.sourceText,
    required this.sourceMap,
    required this.logicalName,
    required this.contentDigest,
    required this.sourceRefs,
    required this.records,
    required this.relations,
    required this.functionRegistry,
    required this.functionShapes,
  });

  final String sourceText;
  final _SemanticSourceMap sourceMap;
  final String logicalName;
  final String contentDigest;
  final Map<String, Object?> sourceRefs;
  final List<Map<String, Object?>> records;
  final List<Map<String, Object?>> relations;
  final UserFunctionRegistry functionRegistry;
  final Map<String, Map<String, Object?>> functionShapes;
  final Map<String, String> _helperIds = {};
  final Map<(String, String), String> _bindingByOwnerName = {};
  final Map<(String, String), int> _bindingCounts = {};
  final Map<String, Map<String, Object?>> _edgeValueShapes = {};
  var _globalCallOrder = 0;

  void emitStatement(
    ActionExpr expression, {
    required String ownerId,
    required _SemanticCallCursor cursor,
    required int Function() localOrder,
    required Map<String, Map<String, Object?>> variables,
    required bool functionSurface,
  }) {
    if (expression case ActionAssignScalarExpr(:final name, :final value)) {
      final shape = _semanticCallExpressionShape(
        value,
        variables,
        functionShapes,
      );
      variables[name] = shape;
      final bindingKey = (ownerId, name);
      final bindingOrder = _bindingCounts.update(
        bindingKey,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final bindingId =
          'binding:$ownerId:${_semanticEscapeName(name)}:$bindingOrder';
      final emitted = emitExpressionCalls(
        value,
        ownerId: ownerId,
        cursor: cursor,
        localOrder: localOrder,
        variables: variables,
        functionSurface: functionSurface,
      );
      final source = emitted == null
          ? null
          : _registerSemanticSource(
              sourceRefs: sourceRefs,
              recordId: bindingId,
              range: emitted.range,
              sourceText: sourceText,
              sourceMap: sourceMap,
              logicalName: logicalName,
              contentDigest: contentDigest,
            );
      records.add(
        _semanticRecord(
          id: bindingId,
          kind: 'binding',
          name: name,
          ownerId: ownerId,
          order: bindingOrder,
          source: source,
          facts: {'scope': 'action', 'value_shape': shape, 'mutable': true},
        ),
      );
      _bindingByOwnerName[bindingKey] = bindingId;
      if (emitted != null) {
        relations.add(
          _semanticRelation(
            kind: 'writes',
            fromId: emitted.id,
            toId: bindingId,
            order: 0,
            source: emitted.source,
          ),
        );
      }
      return;
    }

    if (!functionSurface &&
        expression is ActionCallExpr &&
        expression.name == 'return') {
      _edgeValueShapes[ownerId] = _semanticCallExpressionShape(
        expression,
        variables,
        functionShapes,
      );
    }
    emitExpressionCalls(
      expression,
      ownerId: ownerId,
      cursor: cursor,
      localOrder: localOrder,
      variables: variables,
      functionSurface: functionSurface,
    );
  }

  _SemanticEmittedCall? emitExpressionCalls(
    ActionExpr expression, {
    required String ownerId,
    required _SemanticCallCursor cursor,
    required int Function() localOrder,
    required Map<String, Map<String, Object?>> variables,
    required bool functionSurface,
  }) {
    if (expression case ActionAssignScalarExpr(:final value)) {
      return emitExpressionCalls(
        value,
        ownerId: ownerId,
        cursor: cursor,
        localOrder: localOrder,
        variables: variables,
        functionSurface: functionSurface,
      );
    }
    if (expression is! ActionCallExpr) {
      return null;
    }

    final name = expression.name;
    final range = cursor.take(name, ownerId);
    final order = localOrder();
    final callId = 'call:$ownerId:$order';
    final source = _registerSemanticSource(
      sourceRefs: sourceRefs,
      recordId: callId,
      range: range,
      sourceText: sourceText,
      sourceMap: sourceMap,
      logicalName: logicalName,
      contentDigest: contentDigest,
    );
    final argumentShapes = [
      for (final argument in expression.args)
        _semanticCallExpressionShape(argument.value, variables, functionShapes),
    ];
    final resolution = functionRegistry.resolveCall(
      name,
      expression.args.length,
    );
    final function = resolution.entry;
    final helper = _semanticHelperContracts[name];
    final resolutionKind = function != null
        ? 'user_function'
        : helper != null
        ? 'helper'
        : 'unresolved';
    final returnShape = function != null
        ? functionShapes[name]!
        : name == 'return' && argumentShapes.isNotEmpty
        ? argumentShapes.first
        : helper != null
        ? _semanticValueShape(helper.returnKind)
        : _semanticValueShape('unknown');
    records.add(
      _semanticRecord(
        id: callId,
        kind: 'call',
        name: name,
        ownerId: ownerId,
        order: _globalCallOrder,
        source: source,
        facts: {
          'call_form': 'function',
          'resolution_kind': resolutionKind,
          'argument_shapes': argumentShapes,
          'return_shape': returnShape,
          'target_shape': _semanticValueShape(
            resolutionKind == 'unresolved' ? 'unknown' : resolutionKind,
          ),
        },
      ),
    );
    _globalCallOrder += 1;

    if (function != null) {
      _addFunctionResolution(
        callId: callId,
        source: source,
        function: function,
        argumentShapes: argumentShapes,
        returnShape: returnShape,
      );
    } else if (helper != null) {
      final helperId = _ensureHelper(name, helper);
      relations.add(
        _semanticRelation(
          kind: 'resolves_to',
          fromId: callId,
          toId: helperId,
          order: 0,
          source: source,
          evidenceIds: functionSurface ? [ownerId] : const [],
        ),
      );
    }

    if (name == 'return') {
      for (final argument in expression.args) {
        if (argument.value case ActionVariableExpr(:final name)) {
          final bindingId = _bindingByOwnerName[(ownerId, name)];
          if (bindingId != null) {
            relations.add(
              _semanticRelation(
                kind: 'reads',
                fromId: callId,
                toId: bindingId,
                order: 0,
                source: source,
              ),
            );
          }
        }
      }
    }

    for (final argument in expression.args) {
      emitExpressionCalls(
        argument.value,
        ownerId: ownerId,
        cursor: cursor,
        localOrder: localOrder,
        variables: variables,
        functionSurface: functionSurface,
      );
    }
    return _SemanticEmittedCall(id: callId, source: source, range: range);
  }

  String _ensureHelper(String name, _SemanticHelperContract contract) {
    final existing = _helperIds[name];
    if (existing != null) {
      return existing;
    }
    final id = 'helper:${_semanticEscapeName(name)}';
    final order = _helperIds.length;
    _helperIds[name] = id;
    records.add(
      _semanticRecord(
        id: id,
        kind: 'helper',
        name: name,
        ownerId: null,
        order: order,
        source: null,
        facts: {
          'signature': _semanticSignatureFromParameters(contract.parameters),
          'effects': contract.effects,
          'return_shape': _semanticValueShape(contract.returnKind),
        },
      ),
    );
    return id;
  }

  void _addFunctionResolution({
    required String callId,
    required String source,
    required UserFunctionEntry function,
    required List<Map<String, Object?>> argumentShapes,
    required Map<String, Object?> returnShape,
  }) {
    final targetId = _semanticFunctionId(function.name);
    final decisionId = 'decision:call:$callId';
    records.add(
      _semanticRecord(
        id: decisionId,
        kind: 'decision',
        name: '${function.name} call resolution',
        ownerId: callId,
        order: 0,
        source: source,
        facts: {'decision_kind': 'call_resolution', 'outcome': targetId},
      ),
    );
    final exactId = 'explanation:$decisionId:0';
    records.add(
      _semanticRecord(
        id: exactId,
        kind: 'explanation_step',
        name: null,
        ownerId: decisionId,
        order: 0,
        source: source,
        facts: {
          'rule_code': 'call_exact_user_function',
          'summary':
              'The exact user-function name ${function.name} is registered.',
          'input_ids': [callId, targetId],
          'output_fact': {
            'record_id': callId,
            'path': '/facts/resolution_kind',
            'value': 'user_function',
          },
        },
      ),
    );
    final signatureId = 'explanation:$decisionId:1';
    final count = argumentShapes.length;
    final countWords = count == 1 ? 'one' : '$count';
    final shapeWords = count == 1
        ? '${_semanticShapeKind(argumentShapes.first)} argument'
        : 'arguments';
    records.add(
      _semanticRecord(
        id: signatureId,
        kind: 'explanation_step',
        name: null,
        ownerId: decisionId,
        order: 1,
        source: source,
        facts: {
          'rule_code': 'call_signature_accepts',
          'summary':
              'The $countWords supplied $shapeWords satisfies '
              '${function.name}(${function.params.join(', ')}).',
          'input_ids': [callId, targetId],
          'output_fact': {
            'record_id': callId,
            'path': '/facts/return_shape/kind',
            'value': _semanticShapeKind(returnShape),
          },
        },
      ),
    );
    relations.addAll([
      _semanticRelation(
        kind: 'calls',
        fromId: callId,
        toId: targetId,
        order: 0,
        source: source,
      ),
      _semanticRelation(
        kind: 'resolves_to',
        fromId: callId,
        toId: targetId,
        order: 0,
        source: source,
        evidenceIds: [decisionId],
      ),
      _semanticRelation(
        kind: 'explained_by',
        fromId: decisionId,
        toId: exactId,
        order: 0,
        source: source,
        evidenceIds: [targetId],
      ),
      _semanticRelation(
        kind: 'explained_by',
        fromId: decisionId,
        toId: signatureId,
        order: 1,
        source: source,
        evidenceIds: [targetId],
      ),
    ]);
  }

  void applyEdgeShapes() {
    final ruleShapes = <String, Map<String, Object?>>{};
    for (final record in records) {
      if (record['kind'] != 'edge') {
        continue;
      }
      final id = record['id']! as String;
      final shape = _edgeValueShapes[id];
      if (shape == null) {
        continue;
      }
      final facts = record['facts']! as Map<String, Object?>;
      facts['value_shape'] = shape;
      if (_semanticShapeKind(shape) != 'unknown') {
        final owner = record['owner_id'] as String?;
        if (owner != null) {
          ruleShapes.putIfAbsent(owner, () => shape);
        }
      }
    }
    for (final record in records) {
      if (record['kind'] != 'rule') {
        continue;
      }
      final id = record['id']! as String;
      final shape = ruleShapes[id];
      if (shape == null) {
        continue;
      }
      final facts = record['facts']! as Map<String, Object?>;
      facts['value_shape'] = facts['is_repetition'] == true
          ? _semanticArrayShape(shape)
          : shape;
    }
  }
}

void _addSemanticFunction({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required String logicalName,
  required String contentDigest,
  required Map<String, Object?> sourceRefs,
  required List<Map<String, Object?>> records,
  required List<Map<String, Object?>> relations,
  required UserFunctionEntry function,
  required int functionOrder,
  required int declarationOrder,
  required _SemanticSourceRange range,
  required Map<String, Object?> returnShape,
}) {
  final id = _semanticFunctionId(function.name);
  final source = _registerSemanticSource(
    sourceRefs: sourceRefs,
    recordId: id,
    range: range,
    sourceText: sourceText,
    sourceMap: sourceMap,
    logicalName: logicalName,
    contentDigest: contentDigest,
  );
  final signature = _semanticFunctionSignature(function);
  final parameters = signature['parameters']! as List<Object?>;
  records.add(
    _semanticRecord(
      id: id,
      kind: 'function',
      name: function.name,
      ownerId: _semanticSpecId,
      order: functionOrder,
      source: source,
      facts: {
        'signature': signature,
        'parameter_kinds': [
          for (final parameter in parameters)
            (parameter! as Map<String, Object?>)['kind'],
        ],
        'return_shape': returnShape,
      },
    ),
  );
  relations.add(
    _semanticRelation(
      kind: 'declares',
      fromId: _semanticSpecId,
      toId: id,
      order: declarationOrder,
      source: source,
    ),
  );
}

List<_SemanticActionOwner> _semanticActionOwners({
  required SpecFile parsed,
  required CompiledSpec compiled,
  required Map<String, Object?> sourceRefs,
  required _SemanticSourceMap sourceMap,
}) {
  final owners = <_SemanticActionOwner>[];
  for (final label in compiled.compiledRuleOrder) {
    final parsedRule = parsed.rules.singleWhere(
      (rule) => rule.header.label == label,
    );
    final compiledRule = compiled.rulesByLabel[label]!;
    var edgeOrder = 0;
    var actionIndex = 0;
    var blindIndex = 0;

    void addOwner(CompiledActionPayload? payload) {
      final ownerId = 'edge:${_semanticRuleId(label)}:$edgeOrder';
      edgeOrder += 1;
      if (payload == null) {
        return;
      }
      if (!payload.contracts.ok) {
        throw _semanticCallCorrelationError(
          'Compiled action owner has unresolved typed contracts',
          ownerId,
        );
      }
      owners.add(
        _SemanticActionOwner(
          ownerId: ownerId,
          block: payload.actionAst,
          source: _semanticSourceCodeUnitRange(sourceRefs, sourceMap, ownerId),
        ),
      );
    }

    for (final element in parsedRule.body) {
      switch (element.kind) {
        case ActionEdgeBodyElementKind(:final targets):
          for (var index = 0; index < targets.length; index += 1) {
            if (actionIndex >= compiledRule.actionEdges.length) {
              throw _semanticCallCorrelationError(
                'Parsed action owner has no compiled edge',
                label,
              );
            }
            addOwner(compiledRule.actionEdges[actionIndex].actionPayload);
            actionIndex += 1;
          }
        case BlindEdgeBodyElementKind():
          if (blindIndex >= compiledRule.blindEdges.length) {
            throw _semanticCallCorrelationError(
              'Parsed blind owner has no compiled edge',
              label,
            );
          }
          addOwner(compiledRule.blindEdges[blindIndex].actionPayload);
          blindIndex += 1;
        case BareEdgeBodyElementKind(:final targets):
          for (var index = 0; index < targets.length; index += 1) {
            if (parsedRule.header.mode.isAnd) {
              if (blindIndex >= compiledRule.blindEdges.length) {
                throw _semanticCallCorrelationError(
                  'Parsed bare blind owner has no compiled edge',
                  label,
                );
              }
              addOwner(compiledRule.blindEdges[blindIndex].actionPayload);
              blindIndex += 1;
            } else {
              if (actionIndex >= compiledRule.actionEdges.length) {
                throw _semanticCallCorrelationError(
                  'Parsed bare action owner has no compiled edge',
                  label,
                );
              }
              addOwner(compiledRule.actionEdges[actionIndex].actionPayload);
              actionIndex += 1;
            }
          }
        default:
          break;
      }
    }
    if (actionIndex != compiledRule.actionEdges.length ||
        blindIndex != compiledRule.blindEdges.length) {
      throw _semanticCallCorrelationError(
        'Parsed and compiled action owner counts differ',
        label,
        fields: {
          'parsed_action_edges': actionIndex,
          'compiled_action_edges': compiledRule.actionEdges.length,
          'parsed_blind_edges': blindIndex,
          'compiled_blind_edges': compiledRule.blindEdges.length,
        },
      );
    }
  }
  return List.unmodifiable(owners);
}

ActionBlock _semanticTypedFunctionBody(
  UserFunctionEntry function,
  UserFunctionRegistry registry,
) {
  final block = parseActionBlock(function.bodySource);
  if (function.bodyAst == null ||
      !_plainValuesEqual(function.bodyAst, block.toJson())) {
    throw _semanticCallCorrelationError(
      'Staged function body result differs from typed ActionIR',
      function.name,
    );
  }
  final resolution = resolveActionBlockContracts(
    block,
    functionRegistry: registry,
  );
  if (!resolution.ok) {
    throw _semanticCallCorrelationError(
      'Typed function body has unresolved contracts',
      function.name,
    );
  }
  return block;
}

List<_SemanticSourceRange> _semanticFunctionRanges(
  String sourceText,
  String shell,
) {
  final result = <_SemanticSourceRange>[];
  var after = 0;
  while (after <= sourceText.length) {
    final start = sourceText.indexOf(shell, after);
    if (start < 0) {
      break;
    }
    result.add(_SemanticSourceRange(start, start + shell.length));
    after = start + 1;
  }
  return result;
}

_SemanticSourceRange _semanticFunctionRange({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required UserFunctionEntry function,
}) {
  final body = _semanticFunctionBodyRange(
    sourceText: sourceText,
    sourceMap: sourceMap,
    function: function,
  );
  final candidates = _semanticFunctionRanges(
    sourceText,
    function.definition.source,
  ).where((range) => range.start <= body.start && body.end <= range.end);
  if (candidates.length != 1) {
    throw _semanticCallCorrelationError(
      'Function shell occurrence is not uniquely owned by its staged body',
      function.name,
      fields: {'candidate_count': candidates.length},
    );
  }
  return candidates.single;
}

_SemanticSourceRange _semanticFunctionBodyRange({
  required String sourceText,
  required _SemanticSourceMap sourceMap,
  required UserFunctionEntry function,
}) {
  final payload = function.bodyPayload;
  if (payload is! Map<Object?, Object?>) {
    throw _semanticCallCorrelationError(
      'Function has no staged body payload',
      function.name,
    );
  }
  final rawSpan = payload['source_span'];
  if (rawSpan is! Map<Object?, Object?> ||
      rawSpan['start'] is! int ||
      rawSpan['end'] is! int) {
    throw _semanticCallCorrelationError(
      'Function staged body span is invalid',
      function.name,
    );
  }
  final startScalar = rawSpan['start']! as int;
  final endScalar = rawSpan['end']! as int;
  sourceMap.spanForScalarRange(startScalar, endScalar);
  final range = _SemanticSourceRange(
    sourceMap.codeUnitAtScalar(startScalar),
    sourceMap.codeUnitAtScalar(endScalar),
  );
  if (sourceText.substring(range.start, range.end) != function.bodySource) {
    throw _semanticCallCorrelationError(
      'Staged body span does not match function body source',
      function.name,
    );
  }
  return range;
}

Map<String, Map<String, Object?>> _inferSemanticFunctionShapes(
  List<UserFunctionEntry> functions,
) {
  final shapes = <String, Map<String, Object?>>{
    for (final function in functions)
      function.name: _semanticValueShape('unknown'),
  };
  for (var pass = 0; pass <= functions.length; pass += 1) {
    var changed = false;
    for (final function in functions) {
      final block = parseActionBlock(function.bodySource);
      final variables = <String, Map<String, Object?>>{
        for (final name in function.params)
          name: _semanticValueShape('unknown'),
      };
      var shape = _semanticValueShape('unknown');
      for (final statement in block.statements) {
        final expression = statement.expr;
        if (expression case ActionCallExpr(name: 'return', :final args)) {
          if (args.isNotEmpty) {
            shape = _semanticCallExpressionShape(
              args.first.value,
              variables,
              shapes,
            );
          }
          break;
        }
        if (expression case ActionAssignScalarExpr(:final name, :final value)) {
          variables[name] = _semanticCallExpressionShape(
            value,
            variables,
            shapes,
          );
        }
      }
      if (!_plainValuesEqual(shapes[function.name], shape)) {
        shapes[function.name] = shape;
        changed = true;
      }
    }
    if (!changed) {
      break;
    }
  }
  return shapes;
}

Map<String, Object?> _semanticCallExpressionShape(
  ActionExpr expression,
  Map<String, Map<String, Object?>> variables,
  Map<String, Map<String, Object?>> functionShapes,
) => switch (expression) {
  ActionStringLiteralExpr() => _semanticValueShape('string'),
  ActionNumberLiteralExpr() => _semanticValueShape('number'),
  ActionBooleanLiteralExpr() => _semanticValueShape('boolean'),
  ActionUndefExpr() => _semanticValueShape('null'),
  ActionVariableExpr(:final name) =>
    variables[name] ?? _semanticValueShape('unknown'),
  ActionAssignScalarExpr(:final value) => _semanticCallExpressionShape(
    value,
    variables,
    functionShapes,
  ),
  ActionCallExpr(:final name, :final args) =>
    functionShapes[name] ??
        (name == 'return' && args.isNotEmpty
            ? _semanticCallExpressionShape(
                args.first.value,
                variables,
                functionShapes,
              )
            : _semanticValueShape(
                _semanticHelperContracts[name]?.returnKind ?? 'unknown',
              )),
  _ => _semanticValueShape('unknown'),
};

Map<String, Object?> _semanticFunctionSignature(UserFunctionEntry function) {
  final signature = function.signature;
  final parameters = signature == null
      ? function.params
      : signature.positionalParams;
  return <String, Object?>{
    'parameters': [
      for (final name in parameters)
        <String, Object?>{'name': name, 'kind': 'value', 'required': true},
    ],
    'arity_min': signature?.minArity ?? function.arity,
    'arity_max': signature == null ? function.arity : signature.maxArity,
    'rest_parameter': signature?.restParam,
    'final_codeblock': false,
  };
}

Map<String, Object?> _semanticSignatureFromParameters(
  List<(String, String)> parameters,
) => <String, Object?>{
  'parameters': [
    for (final (name, kind) in parameters)
      <String, Object?>{'name': name, 'kind': kind, 'required': true},
  ],
  'arity_min': parameters.length,
  'arity_max': parameters.length,
  'rest_parameter': null,
  'final_codeblock': false,
};

List<_SemanticCallSite> _scanSemanticCalls(String source, int sourceStart) {
  final sites = <_SemanticCallSite>[];
  var index = 0;
  int? quote;
  var escaped = false;
  while (index < source.length) {
    final codeUnit = source.codeUnitAt(index);
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5C) {
        escaped = true;
      } else if (codeUnit == quote) {
        quote = null;
      }
      index += 1;
      continue;
    }
    if (codeUnit == 0x22 || codeUnit == 0x27) {
      quote = codeUnit;
      index += 1;
      continue;
    }
    if (!_semanticCallIdentifierStart(codeUnit)) {
      index += 1;
      continue;
    }
    final nameStart = index;
    index += 1;
    while (index < source.length &&
        _semanticCallIdentifierContinue(source.codeUnitAt(index))) {
      index += 1;
    }
    final nameEnd = index;
    while (index < source.length &&
        _semanticWhitespace(source.codeUnitAt(index))) {
      index += 1;
    }
    if (index >= source.length || source.codeUnitAt(index) != 0x28) {
      continue;
    }
    final end = _semanticMatchingParenthesis(source, index);
    if (end == null) {
      throw _semanticCallCorrelationError(
        'Authored call has no balanced closing parenthesis',
        source.substring(nameStart, nameEnd),
      );
    }
    sites.add(
      _SemanticCallSite(
        name: source.substring(nameStart, nameEnd),
        range: _SemanticSourceRange(sourceStart + nameStart, sourceStart + end),
      ),
    );
    index = nameEnd;
  }
  return List.unmodifiable(sites);
}

int? _semanticMatchingParenthesis(String source, int open) {
  var depth = 0;
  int? quote;
  var escaped = false;
  for (var index = open; index < source.length; index += 1) {
    final codeUnit = source.codeUnitAt(index);
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5C) {
        escaped = true;
      } else if (codeUnit == quote) {
        quote = null;
      }
      continue;
    }
    if (codeUnit == 0x22 || codeUnit == 0x27) {
      quote = codeUnit;
      continue;
    }
    if (codeUnit == 0x28) {
      depth += 1;
    } else if (codeUnit == 0x29) {
      depth -= 1;
      if (depth == 0) {
        return index + 1;
      }
      if (depth < 0) {
        return null;
      }
    }
  }
  return null;
}

bool _semanticCallIdentifierStart(int codeUnit) =>
    (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
    (codeUnit >= 0x61 && codeUnit <= 0x7A) ||
    codeUnit == 0x5F;

bool _semanticCallIdentifierContinue(int codeUnit) =>
    _semanticCallIdentifierStart(codeUnit) ||
    (codeUnit >= 0x30 && codeUnit <= 0x39);

int _semanticSourceStartByte(Map<String, Object?> sourceRefs, String recordId) {
  final source = sourceRefs['source_ref:$recordId'];
  if (source is! Map<Object?, Object?>) {
    throw _semanticCallCorrelationError(
      'Static source reference is missing',
      recordId,
    );
  }
  final span = source['span'];
  if (span is! Map<Object?, Object?> || span['start_byte'] is! int) {
    throw _semanticCallCorrelationError(
      'Static source reference span is invalid',
      recordId,
    );
  }
  return span['start_byte']! as int;
}

_SemanticSourceRange _semanticSourceCodeUnitRange(
  Map<String, Object?> sourceRefs,
  _SemanticSourceMap sourceMap,
  String recordId,
) {
  final source = sourceRefs['source_ref:$recordId'];
  if (source is! Map<Object?, Object?> || source['excerpt'] is! String) {
    throw _semanticCallCorrelationError(
      'Static authored source is missing',
      recordId,
    );
  }
  final span = source['span'];
  if (span is! Map<Object?, Object?> ||
      span['start_byte'] is! int ||
      span['end_byte'] is! int) {
    throw _semanticCallCorrelationError(
      'Static authored source span is invalid',
      recordId,
    );
  }
  final startByte = span['start_byte']! as int;
  final endByte = span['end_byte']! as int;
  final scalarRange = sourceMap.scalarRangeForBytes(startByte, endByte);
  return _SemanticSourceRange(
    sourceMap.codeUnitAtScalar(scalarRange.$1),
    sourceMap.codeUnitAtScalar(scalarRange.$2),
  );
}

String _semanticFunctionId(String name) =>
    'function:${_semanticEscapeName(name)}';

String _semanticShapeKind(Map<String, Object?> shape) =>
    shape['kind'] as String? ?? 'unknown';

SemanticIndexError _semanticCallCorrelationError(
  String message,
  String identity, {
  Map<String, Object?> fields = const {},
}) => SemanticIndexError(
  stage: 'project_call_semantics',
  code: 'semantic_call_correlation_failed',
  message: message,
  fields: {'identity': identity, ...fields},
);
