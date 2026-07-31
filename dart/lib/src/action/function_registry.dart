import '../ast/spec_ast.dart';
import '../trace/trace.dart';

final class UserFunctionRegistryException implements Exception {
  const UserFunctionRegistryException(this.message);

  final String message;

  @override
  String toString() => 'UserFunctionRegistryException: $message';
}

final class UserFunctionRegistry {
  const UserFunctionRegistry._({
    required this.entries,
    required Map<String, List<UserFunctionEntry>> byName,
  }) : _byName = byName;

  factory UserFunctionRegistry.fromSpec(
    SpecFile spec, {
    LinkedSpecTraceEmitter? trace,
  }) {
    return UserFunctionRegistry.fromFunctions(spec.functions, trace: trace);
  }

  factory UserFunctionRegistry.fromFunctions(
    Iterable<FunctionDefinition> functions, {
    LinkedSpecTraceEmitter? trace,
  }) {
    final functionList = functions.toList(growable: false);
    final traceScope = trace?.enterScope(
      'dart_compiler:function_registry',
      'function_count=${functionList.length}',
      LinkedSpecTraceLevel.high,
    );
    try {
      final entries = <UserFunctionEntry>[];
      final byName = <String, List<UserFunctionEntry>>{};

      var index = 0;
      for (final function in functionList) {
        final existing = byName[function.name];
        if (existing != null) {
          throw UserFunctionRegistryException(
            "duplicate user function '${function.name}'",
          );
        }
        final entry = UserFunctionEntry(index: index, definition: function);
        entries.add(entry);
        byName[function.name] = [entry];
        trace?.traceDecision(
          'dart_compiler:function_registry:definition',
          true,
          'index=$index name=${function.name} arity=${function.arity}',
          LinkedSpecTraceLevel.medium,
        );
        index += 1;
      }

      final registry = UserFunctionRegistry._(
        entries: List.unmodifiable(entries),
        byName: Map<String, List<UserFunctionEntry>>.unmodifiable({
          for (final item in byName.entries)
            item.key: List<UserFunctionEntry>.unmodifiable(item.value),
        }),
      );
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'ok function_count=${entries.length}');
      }
      return registry;
    } on Object catch (error) {
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'error=$error');
      }
      rethrow;
    }
  }

  static const empty = UserFunctionRegistry._(
    entries: [],
    byName: <String, List<UserFunctionEntry>>{},
  );

  final List<UserFunctionEntry> entries;
  final Map<String, List<UserFunctionEntry>> _byName;

  Iterable<String> get names => _byName.keys;

  List<StagedParseJob> get bodyParseJobs {
    return [
      for (final entry in entries)
        if (entry.bodyParseJob != null) entry.bodyParseJob!,
    ];
  }

  bool hasName(String name) => _byName.containsKey(name);

  List<int> expectedAritiesFor(String name) {
    final entries = _byName[name];
    if (entries == null) {
      return const [];
    }
    return List.unmodifiable([for (final entry in entries) entry.arity]);
  }

  UserFunctionEntry? lookup(String name) {
    final entries = _byName[name];
    if (entries == null || entries.isEmpty) {
      return null;
    }
    return entries.single;
  }

  UserFunctionEntry? resolveExact(String name, int arity) {
    final entries = _byName[name];
    if (entries == null) {
      return null;
    }
    for (final entry in entries) {
      if (entry.arity == arity) {
        return entry;
      }
      if (entry.signature != null && entry.acceptsArity(arity)) {
        return entry;
      }
    }
    return null;
  }

  UserFunctionCallResolution resolveCall(String name, int arity) {
    final entries = _byName[name];
    if (entries == null) {
      return UserFunctionCallResolution._(
        name: name,
        requestedArity: arity,
        expectedArities: const [],
        expectedArityDescriptions: const [],
      );
    }
    for (final entry in entries) {
      if (entry.acceptsArity(arity)) {
        return UserFunctionCallResolution._(
          name: name,
          requestedArity: arity,
          expectedArities: expectedAritiesFor(name),
          expectedArityDescriptions: [
            for (final candidate in entries) candidate.arityExpectation,
          ],
          entry: entry,
        );
      }
    }
    return UserFunctionCallResolution._(
      name: name,
      requestedArity: arity,
      expectedArities: expectedAritiesFor(name),
      expectedArityDescriptions: [
        for (final candidate in entries) candidate.arityExpectation,
      ],
    );
  }

  JsonObject toJson() {
    return {
      'functions': [for (final entry in entries) entry.toJson()],
      'body_parse_jobs': [for (final job in bodyParseJobs) job.toJson()],
    };
  }
}

final class UserFunctionEntry {
  const UserFunctionEntry({required this.index, required this.definition});

  final int index;
  final FunctionDefinition definition;

  String get name => definition.name;
  List<String> get params => definition.params;
  int get arity => definition.arity;
  Map<String, String> get parameterKinds => definition.parameterKinds;
  CallableSignature? get signature => definition.signature;
  String get bodySource => definition.bodySource;
  Object? get bodyPayload => definition.bodyPayload;
  StagedParseJob? get bodyParseJob => definition.bodyParseJob;
  Object? get bodyAst => definition.bodyAst;
  SourceSpan get sourceSpan => definition.sourceSpan;
  SourceSpan get bodySpan => definition.bodySpan;

  bool acceptsArity(int actual) {
    final callable = signature;
    if (callable == null) {
      return actual == arity;
    }
    return actual >= callable.minArity &&
        (callable.maxArity == null || actual <= callable.maxArity!);
  }

  String get arityExpectation {
    final callable = signature;
    if (callable == null) {
      return '$arity';
    }
    return callable.maxArity == null
        ? 'at least ${callable.minArity}'
        : 'exactly ${callable.minArity}';
  }

  JsonObject toJson() {
    return {'index': index, ...definition.toJson()};
  }

  JsonObject toDescriptorJson() {
    return {
      'index': index,
      'kind': 'user_function_definition',
      'version': parameterKinds.isNotEmpty ? 3 : (signature == null ? 1 : 2),
      'name': name,
      if (signature == null) 'params': params,
      if (signature == null) 'arity': arity,
      if (parameterKinds.isNotEmpty) 'parameter_kinds': parameterKinds,
      if (signature != null) 'signature': signature!.toJson(),
      'source_text': definition.source,
      'source_span': sourceSpan.toJson(),
      'body_span': bodySpan.toJson(),
      'body_source': bodySource,
      if (bodyPayload != null) 'body_payload': bodyPayload,
      if (bodyParseJob != null) 'body_parse_job': bodyParseJob!.toJson(),
      if (bodyAst != null) 'body_ast': bodyAst,
    };
  }
}

final class UserFunctionCallResolution {
  const UserFunctionCallResolution._({
    required this.name,
    required this.requestedArity,
    required this.expectedArities,
    required this.expectedArityDescriptions,
    this.entry,
  });

  final String name;
  final int requestedArity;
  final List<int> expectedArities;
  final List<String> expectedArityDescriptions;
  final UserFunctionEntry? entry;

  bool get nameKnown => expectedArities.isNotEmpty;
  bool get matched => entry != null;
  bool get arityMismatch => nameKnown && entry == null;
}
