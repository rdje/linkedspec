import 'dart:io';

import '../ast/spec_ast.dart';
import '../compiler/compiled_spec.dart';
import '../runtime/interpreter.dart';
import '../trace/trace.dart';
import 'spec_parser.dart';
import 'staged_parser_registry.dart';

const userFunctionDefinitionSpecRelativePath =
    'specs/user_function_definition.spec';

final class UserFunctionDefinitionParserException implements Exception {
  const UserFunctionDefinitionParserException(this.message);

  final String message;

  @override
  String toString() => 'UserFunctionDefinitionParserException: $message';
}

final class UserFunctionDefinitionAstParser {
  UserFunctionDefinitionAstParser._(this._compiledSpec);

  factory UserFunctionDefinitionAstParser.fromSpecSource(
    String source, {
    LinkedSpecTraceEmitter? trace,
  }) {
    final traceScope = trace?.enterScope(
      'dart_frontend:function_parser_spec',
      'source_code_units=${source.length}',
      LinkedSpecTraceLevel.high,
    );
    try {
      final SpecFile parserSpec;
      try {
        parserSpec = parseSpec(source, trace: trace);
      } on SpecParseException catch (error) {
        throw UserFunctionDefinitionParserException(
          'failed to parse user_function_definition.spec: ${error.message}',
        );
      }

      final UserFunctionDefinitionAstParser parser;
      try {
        parser = UserFunctionDefinitionAstParser._(
          compileSpec(parserSpec, trace: trace),
        );
      } on CompiledSpecException catch (error) {
        throw UserFunctionDefinitionParserException(
          'failed to compile user_function_definition.spec: ${error.message}',
        );
      } on Object catch (error) {
        throw UserFunctionDefinitionParserException(
          'failed to compile user_function_definition.spec: $error',
        );
      }
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'ok');
      }
      return parser;
    } on Object catch (error) {
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'error=$error');
      }
      rethrow;
    }
  }

  final CompiledSpec _compiledSpec;

  List<Object?> parse(String source, {LinkedSpecTraceEmitter? trace}) {
    final traceScope = trace?.enterScope(
      'dart_frontend:function_parser_execute',
      'source_code_units=${source.length}',
      LinkedSpecTraceLevel.high,
    );
    try {
      final RuntimeParseResult result;
      try {
        result = LinkedSpecRuntimeEngine(
          _compiledSpec,
          specName: 'user_function_definition.spec',
        ).execute(source, trace: trace);
      } on RuntimeInterpreterException catch (error) {
        throw UserFunctionDefinitionParserException(
          'user_function_definition.spec execution failed: ${error.message}',
        );
      }

      final nodes = result.matched
          ? definitionNodesFromUserFunctionDefinitionOutput(result.value)
          : const <Object?>[];
      trace?.traceDecision(
        'dart_frontend:function_parser_execute:definitions',
        result.matched,
        'definition_count=${nodes.length}',
        LinkedSpecTraceLevel.medium,
      );
      if (traceScope != null) {
        trace?.exitScope(
          traceScope,
          'ok matched=${result.matched ? 1 : 0} '
          'definition_count=${nodes.length}',
        );
      }
      return nodes;
    } on Object catch (error) {
      if (traceScope != null) {
        trace?.exitScope(traceScope, 'error=$error');
      }
      rethrow;
    }
  }
}

List<Object?> parseUserFunctionDefinitionAsts(
  String source, {
  String? parserSpecSource,
  LinkedSpecTraceEmitter? trace,
}) {
  final parser = parserSpecSource == null
      ? _defaultUserFunctionDefinitionAstParser(trace: trace)
      : UserFunctionDefinitionAstParser.fromSpecSource(
          parserSpecSource,
          trace: trace,
        );
  return parser.parse(source, trace: trace);
}

SpecFile parseSpecWithStagedUserFunctionDefinitions(
  String source, {
  String? parserSpecSource,
  String sourceId = 'inline',
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_frontend:parse_spec_with_functions',
    'source_code_units=${source.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final nodes = parseUserFunctionDefinitionAsts(
      source,
      parserSpecSource: parserSpecSource,
      trace: trace,
    );
    final spec = parseSpecWithStagedUserFunctionDefinitionAsts(
      source,
      nodes,
      sourceId: sourceId,
      trace: trace,
    );
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok functions=${spec.functions.length} rules=${spec.rules.length}',
      );
    }
    return spec;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

List<Object?> definitionNodesFromUserFunctionDefinitionOutput(Object? output) {
  if (output == null) {
    return const [];
  }
  if (output is Map) {
    return List<Object?>.unmodifiable([output]);
  }
  if (output is List) {
    if (output.isEmpty) {
      return const [];
    }
    if (output.every((item) => item is Map)) {
      return List<Object?>.unmodifiable(output);
    }
    if (output.length == 1) {
      return definitionNodesFromUserFunctionDefinitionOutput(output.single);
    }
    if (output.every((item) => item is List)) {
      return List<Object?>.unmodifiable([
        for (final item in output)
          ...definitionNodesFromUserFunctionDefinitionOutput(item),
      ]);
    }
  }
  throw UserFunctionDefinitionParserException(
    'user_function_definition.spec returned unsupported output shape: $output',
  );
}

UserFunctionDefinitionAstParser? _defaultParser;

UserFunctionDefinitionAstParser _defaultUserFunctionDefinitionAstParser({
  LinkedSpecTraceEmitter? trace,
}) {
  final cached = _defaultParser;
  if (cached != null) {
    trace?.traceDecision(
      'dart_frontend:function_parser_spec:cache',
      true,
      'cache_hit=1',
      LinkedSpecTraceLevel.medium,
    );
    return cached;
  }
  trace?.traceDecision(
    'dart_frontend:function_parser_spec:cache',
    false,
    'cache_hit=0',
    LinkedSpecTraceLevel.medium,
  );
  return _defaultParser = UserFunctionDefinitionAstParser.fromSpecSource(
    _readDefaultUserFunctionDefinitionSpecSource(),
    trace: trace,
  );
}

String _readDefaultUserFunctionDefinitionSpecSource() {
  final file = _findRepoFile(userFunctionDefinitionSpecRelativePath);
  if (file == null) {
    throw const UserFunctionDefinitionParserException(
      'cannot locate specs/user_function_definition.spec from the current '
      'working directory or running script path',
    );
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    throw UserFunctionDefinitionParserException(
      'cannot read ${file.path}: ${error.message}',
    );
  }
}

File? _findRepoFile(String relativePath) {
  final anchors = <Directory>[
    Directory.current.absolute,
    _scriptDirectory().absolute,
  ];
  for (final anchor in anchors) {
    final found = _findUpward(anchor, relativePath);
    if (found != null) {
      return found;
    }
  }
  return null;
}

Directory _scriptDirectory() {
  if (Platform.script.scheme == 'file') {
    return File.fromUri(Platform.script).parent;
  }
  return Directory.current;
}

File? _findUpward(Directory start, String relativePath) {
  final normalizedRelative = relativePath.replaceAll(
    '/',
    Platform.pathSeparator,
  );
  var directory = start;
  while (true) {
    final candidate = File(
      '${directory.path}${Platform.pathSeparator}$normalizedRelative',
    );
    if (candidate.existsSync()) {
      return candidate;
    }
    final parent = directory.parent;
    if (parent.path == directory.path) {
      return null;
    }
    directory = parent;
  }
}
