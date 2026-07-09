import 'dart:io';

import '../ast/spec_ast.dart';
import '../compiler/compiled_spec.dart';
import '../runtime/interpreter.dart';
import '../runtime/matching.dart';
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

  factory UserFunctionDefinitionAstParser.fromSpecSource(String source) {
    final SpecFile parserSpec;
    try {
      parserSpec = parseSpec(source);
    } on SpecParseException catch (error) {
      throw UserFunctionDefinitionParserException(
        'failed to parse user_function_definition.spec: ${error.message}',
      );
    }

    try {
      return UserFunctionDefinitionAstParser._(compileSpec(parserSpec));
    } on CompiledSpecException catch (error) {
      throw UserFunctionDefinitionParserException(
        'failed to compile user_function_definition.spec: ${error.message}',
      );
    } on Object catch (error) {
      throw UserFunctionDefinitionParserException(
        'failed to compile user_function_definition.spec: $error',
      );
    }
  }

  final CompiledSpec _compiledSpec;

  List<Object?> parse(String source) {
    final RuntimeParseResult result;
    try {
      result = LinkedSpecRuntimeEngine(
        _compiledSpec,
        parseMode: LinkedSpecParseMode.seek,
        specName: 'user_function_definition.spec',
      ).execute(source);
    } on RuntimeInterpreterException catch (error) {
      throw UserFunctionDefinitionParserException(
        'user_function_definition.spec execution failed: ${error.message}',
      );
    }

    if (!result.matched && !_hasOnlyIgnorableRemainder(source, result)) {
      throw UserFunctionDefinitionParserException(
        'user_function_definition.spec did not match input; '
        'cursor_code_unit=${result.cursorCodeUnit}',
      );
    }
    return definitionNodesFromUserFunctionDefinitionOutput(result.value);
  }
}

List<Object?> parseUserFunctionDefinitionAsts(
  String source, {
  String? parserSpecSource,
}) {
  final parser = parserSpecSource == null
      ? _defaultUserFunctionDefinitionAstParser()
      : UserFunctionDefinitionAstParser.fromSpecSource(parserSpecSource);
  return parser.parse(source);
}

SpecFile parseSpecWithStagedUserFunctionDefinitions(
  String source, {
  String? parserSpecSource,
}) {
  final nodes = parseUserFunctionDefinitionAsts(
    source,
    parserSpecSource: parserSpecSource,
  );
  return parseSpecWithStagedUserFunctionDefinitionAsts(source, nodes);
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

UserFunctionDefinitionAstParser _defaultUserFunctionDefinitionAstParser() {
  return _defaultParser ??= UserFunctionDefinitionAstParser.fromSpecSource(
    _readDefaultUserFunctionDefinitionSpecSource(),
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

bool _hasOnlyIgnorableRemainder(String source, RuntimeParseResult result) {
  if (result.cursorCodeUnit >= source.length) {
    return true;
  }
  return source.substring(result.cursorCodeUnit).trim().isEmpty;
}
