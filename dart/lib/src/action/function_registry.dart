import '../ast/spec_ast.dart';

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

  factory UserFunctionRegistry.fromSpec(SpecFile spec) {
    return UserFunctionRegistry.fromFunctions(spec.functions);
  }

  factory UserFunctionRegistry.fromFunctions(
    Iterable<FunctionDefinition> functions,
  ) {
    final entries = <UserFunctionEntry>[];
    final byName = <String, List<UserFunctionEntry>>{};

    var index = 0;
    for (final function in functions) {
      final existing = byName[function.name];
      if (existing != null) {
        throw UserFunctionRegistryException(
          "duplicate user function '${function.name}'",
        );
      }
      final entry = UserFunctionEntry(index: index, definition: function);
      entries.add(entry);
      byName[function.name] = [entry];
      index += 1;
    }

    return UserFunctionRegistry._(
      entries: List.unmodifiable(entries),
      byName: Map<String, List<UserFunctionEntry>>.unmodifiable({
        for (final item in byName.entries)
          item.key: List<UserFunctionEntry>.unmodifiable(item.value),
      }),
    );
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
      );
    }
    for (final entry in entries) {
      if (entry.arity == arity) {
        return UserFunctionCallResolution._(
          name: name,
          requestedArity: arity,
          expectedArities: expectedAritiesFor(name),
          entry: entry,
        );
      }
    }
    return UserFunctionCallResolution._(
      name: name,
      requestedArity: arity,
      expectedArities: expectedAritiesFor(name),
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
  String get bodySource => definition.bodySource;
  Object? get bodyPayload => definition.bodyPayload;
  StagedParseJob? get bodyParseJob => definition.bodyParseJob;
  Object? get bodyAst => definition.bodyAst;
  SourceSpan get sourceSpan => definition.sourceSpan;
  SourceSpan get bodySpan => definition.bodySpan;

  JsonObject toJson() {
    return {'index': index, ...definition.toJson()};
  }
}

final class UserFunctionCallResolution {
  const UserFunctionCallResolution._({
    required this.name,
    required this.requestedArity,
    required this.expectedArities,
    this.entry,
  });

  final String name;
  final int requestedArity;
  final List<int> expectedArities;
  final UserFunctionEntry? entry;

  bool get nameKnown => expectedArities.isNotEmpty;
  bool get matched => entry != null;
  bool get arityMismatch => nameKnown && entry == null;
}
