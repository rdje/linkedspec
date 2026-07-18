import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../ast/spec_ast.dart' show SpecFile;
import '../compiler/compiled_spec.dart';
import '../parser/user_function_definition_parser.dart';
import '../runtime/interpreter.dart';
import '../trace/trace.dart';
import '../validation/spec_validator.dart';

enum SpecRequestKind { name, path }

final class SpecRequest {
  const SpecRequest.named(String name)
    : kind = SpecRequestKind.name,
      requested = name;

  const SpecRequest.path(String path)
    : kind = SpecRequestKind.path,
      requested = path;

  final SpecRequestKind kind;
  final String requested;
}

final class SpecLoadOptions {
  SpecLoadOptions({required this.cwd, List<Directory> searchRoots = const []})
    : searchRoots = List.unmodifiable(searchRoots);

  final Directory cwd;
  final List<Directory> searchRoots;
}

enum SpecPipelineStage {
  validateSpecName('validate_spec_name'),
  validateSpecPath('validate_spec_path'),
  resolveSpecPath('resolve_spec_path'),
  loadSpecContent('load_spec_content'),
  decodeSpecContent('decode_spec_content'),
  parseSpec('parse_spec'),
  validateSpec('validate_spec'),
  compileSpec('compile_spec');

  const SpecPipelineStage(this.contractName);

  final String contractName;
}

enum SpecPipelineCode {
  invalidSpecName('invalid_spec_name'),
  invalidSpecPath('invalid_spec_path'),
  specPathNotFound('spec_path_not_found'),
  specPathNotFile('spec_path_not_file'),
  specReadFailed('spec_read_failed'),
  invalidUtf8('invalid_utf8'),
  specParseFailed('spec_parse_failed'),
  noRulesDefined('no_rules_defined'),
  specValidationFailed('spec_validation_failed'),
  specCompileFailed('spec_compile_failed');

  const SpecPipelineCode(this.contractName);

  final String contractName;
}

final class SpecPipelineException implements Exception {
  const SpecPipelineException({
    required this.stage,
    required this.code,
    required this.summary,
    required this.requestKind,
    required this.requested,
    this.resolvedPath,
    this.detail,
  });

  final SpecPipelineStage stage;
  final SpecPipelineCode code;
  final String summary;
  final SpecRequestKind requestKind;
  final String requested;
  final String? resolvedPath;
  final String? detail;

  Map<String, Object?> toJson() => {
    'type': 'spec_pipeline_error',
    'stage': stage.contractName,
    'code': code.contractName,
    'summary': summary,
    'request_kind': requestKind.name,
    'requested': requested,
    if (resolvedPath != null) 'resolved_path': resolvedPath,
    if (detail != null) 'detail': detail,
  };

  @override
  String toString() => 'SpecPipelineException: $summary';
}

final class SpecCandidateOrigin {
  const SpecCandidateOrigin._(this.contractName);

  const SpecCandidateOrigin.cwdExact() : this._('cwd_exact');

  const SpecCandidateOrigin.cwdSpecSuffix() : this._('cwd_spec_suffix');

  SpecCandidateOrigin.searchRoot(int index) : this._('search_root:$index');

  const SpecCandidateOrigin.pathExact() : this._('path_exact');

  final String contractName;
}

final class ResolvedSpec {
  const ResolvedSpec({
    required this.request,
    required this.file,
    required this.origin,
  });

  final SpecRequest request;
  final File file;
  final SpecCandidateOrigin origin;
}

final class LoadedSpec {
  const LoadedSpec({required this.resolved, required this.sourceText});

  final ResolvedSpec resolved;
  final String sourceText;
}

final class LoadedCompiledSpec {
  const LoadedCompiledSpec({required this.loaded, required this.compiled});

  final LoadedSpec loaded;
  final CompiledSpec compiled;

  LinkedSpecRuntimeEngine createEngine({int maxIterations = 10000}) =>
      LinkedSpecRuntimeEngine(
        compiled,
        maxIterations: maxIterations,
        specName: loaded.resolved.request.kind == SpecRequestKind.name
            ? loaded.resolved.request.requested
            : null,
        specPath: loaded.resolved.file.path,
      );
}

void validateSpecRequest(SpecRequest request) {
  if (request.kind == SpecRequestKind.name) {
    _validateName(request);
  } else {
    _validatePath(request);
  }
}

ResolvedSpec resolveSpec(SpecRequest request, SpecLoadOptions options) {
  validateSpecRequest(request);
  File? firstNonRegular;

  for (final candidate in _candidates(request, options)) {
    final FileSystemEntityType type;
    try {
      type = FileSystemEntity.typeSync(candidate.file.path, followLinks: true);
    } on FileSystemException catch (error) {
      throw _error(
        request,
        stage: SpecPipelineStage.resolveSpecPath,
        code: SpecPipelineCode.specReadFailed,
        summary: 'Unable to inspect spec path',
        resolvedPath: candidate.file.path,
        detail: error.message,
      );
    }
    if (type == FileSystemEntityType.file) {
      return ResolvedSpec(
        request: request,
        file: candidate.file,
        origin: candidate.origin,
      );
    }
    if (type != FileSystemEntityType.notFound) {
      firstNonRegular ??= candidate.file;
    }
  }

  if (firstNonRegular != null) {
    throw _error(
      request,
      stage: SpecPipelineStage.resolveSpecPath,
      code: SpecPipelineCode.specPathNotFile,
      summary: 'Spec path is not a file',
      resolvedPath: firstNonRegular.path,
    );
  }
  throw _error(
    request,
    stage: SpecPipelineStage.resolveSpecPath,
    code: SpecPipelineCode.specPathNotFound,
    summary: 'Spec path not found',
  );
}

LoadedSpec loadSpec(SpecRequest request, SpecLoadOptions options) {
  final resolved = resolveSpec(request, options);
  final Uint8List bytes;
  try {
    bytes = resolved.file.readAsBytesSync();
  } on FileSystemException catch (error) {
    throw _error(
      request,
      stage: SpecPipelineStage.loadSpecContent,
      code: SpecPipelineCode.specReadFailed,
      summary: 'Unable to read spec file',
      resolvedPath: resolved.file.path,
      detail: error.message,
    );
  }

  final String sourceText;
  try {
    var decoded = utf8.decode(bytes, allowMalformed: false);
    if (_startsWithUtf8Bom(bytes) && !decoded.startsWith('\uFEFF')) {
      decoded = '\uFEFF$decoded';
    }
    sourceText = decoded;
  } on FormatException catch (error) {
    throw _error(
      request,
      stage: SpecPipelineStage.decodeSpecContent,
      code: SpecPipelineCode.invalidUtf8,
      summary: 'Spec file is not valid UTF-8',
      resolvedPath: resolved.file.path,
      detail: error.message,
    );
  }
  return LoadedSpec(resolved: resolved, sourceText: sourceText);
}

LoadedCompiledSpec loadAndCompileSpec(
  SpecRequest request,
  SpecLoadOptions options, {
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_io:load_and_compile_spec',
    'request_kind=${request.kind.name} requested=${request.requested}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final result = _loadAndCompileSpec(request, options, trace);
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok path=${result.loaded.resolved.file.path}',
      );
    }
    return result;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

LoadedCompiledSpec _loadAndCompileSpec(
  SpecRequest request,
  SpecLoadOptions options,
  LinkedSpecTraceEmitter? trace,
) {
  final loaded = loadSpec(request, options);
  trace?.traceDecision(
    'dart_io:load_and_compile_spec:loaded',
    true,
    'origin=${loaded.resolved.origin.contractName} '
        'path=${loaded.resolved.file.path} '
        'source_code_units=${loaded.sourceText.length}',
    LinkedSpecTraceLevel.medium,
  );
  if (loaded.sourceText.startsWith('\uFEFF')) {
    throw _error(
      request,
      stage: SpecPipelineStage.parseSpec,
      code: SpecPipelineCode.specParseFailed,
      summary: 'Unable to parse spec',
      resolvedPath: loaded.resolved.file.path,
      detail: 'leading source BOM is preserved and not valid rule syntax',
    );
  }

  final spec = _parseLoadedSpec(request, loaded, trace);
  try {
    validateSpec(spec, trace: trace);
  } on SpecValidationException catch (error) {
    throw _error(
      request,
      stage: SpecPipelineStage.validateSpec,
      code: error.diagnostic?.code == 'no_rules_defined'
          ? SpecPipelineCode.noRulesDefined
          : SpecPipelineCode.specValidationFailed,
      summary: 'Spec validation failed',
      resolvedPath: loaded.resolved.file.path,
      detail: error.message,
    );
  }

  final CompiledSpec compiled;
  try {
    compiled = compileSpec(spec, validateSource: false, trace: trace);
  } on Object catch (error) {
    throw _error(
      request,
      stage: SpecPipelineStage.compileSpec,
      code: SpecPipelineCode.specCompileFailed,
      summary: 'Spec compilation failed',
      resolvedPath: loaded.resolved.file.path,
      detail: error.toString(),
    );
  }
  return LoadedCompiledSpec(loaded: loaded, compiled: compiled);
}

SpecFile _parseLoadedSpec(
  SpecRequest request,
  LoadedSpec loaded,
  LinkedSpecTraceEmitter? trace,
) {
  try {
    return parseSpecWithStagedUserFunctionDefinitions(
      loaded.sourceText,
      trace: trace,
    );
  } on Object catch (error) {
    throw _error(
      request,
      stage: SpecPipelineStage.parseSpec,
      code: SpecPipelineCode.specParseFailed,
      summary: 'Unable to parse spec',
      resolvedPath: loaded.resolved.file.path,
      detail: error.toString(),
    );
  }
}

void _validateName(SpecRequest request) {
  final name = request.requested;
  final runes = name.runes.toList(growable: false);
  final components = name.split('/');
  final invalid =
      name.isEmpty ||
      runes.every(_isUnicodeWhitespace) ||
      _isUnicodeWhitespace(runes.first) ||
      _isUnicodeWhitespace(runes.last) ||
      runes.any(_isControl) ||
      name.startsWith('/') ||
      RegExp(r'^[A-Za-z]:/').hasMatch(name) ||
      name.contains('\\') ||
      components.any(
        (component) =>
            component.isEmpty || component == '.' || component == '..',
      );
  if (invalid) {
    throw _error(
      request,
      stage: SpecPipelineStage.validateSpecName,
      code: SpecPipelineCode.invalidSpecName,
      summary: 'Invalid spec name',
    );
  }
}

void _validatePath(SpecRequest request) {
  if (request.requested.isEmpty || request.requested.contains('\u0000')) {
    throw _error(
      request,
      stage: SpecPipelineStage.validateSpecPath,
      code: SpecPipelineCode.invalidSpecPath,
      summary: 'Invalid spec path',
    );
  }
}

List<_Candidate> _candidates(SpecRequest request, SpecLoadOptions options) {
  final raw = <_Candidate>[];
  if (request.kind == SpecRequestKind.path) {
    final file = File(request.requested);
    raw.add(
      _Candidate(
        file.isAbsolute
            ? file
            : _fileBelow(options.cwd.path, request.requested),
        const SpecCandidateOrigin.pathExact(),
      ),
    );
  } else {
    final filename = request.requested.endsWith('.spec')
        ? request.requested
        : '${request.requested}.spec';
    raw
      ..add(
        _Candidate(
          _fileBelow(options.cwd.path, request.requested),
          const SpecCandidateOrigin.cwdExact(),
        ),
      )
      ..add(
        _Candidate(
          _fileBelow(options.cwd.path, filename),
          const SpecCandidateOrigin.cwdSpecSuffix(),
        ),
      );
    for (var index = 0; index < options.searchRoots.length; index += 1) {
      raw.add(
        _Candidate(
          _fileBelow(options.searchRoots[index].path, filename),
          SpecCandidateOrigin.searchRoot(index),
        ),
      );
    }
  }
  final seen = <String>{};
  return List.unmodifiable([
    for (final candidate in raw)
      if (seen.add(candidate.file.path)) candidate,
  ]);
}

File _fileBelow(String base, String portableRelativePath) {
  var path = base;
  for (final component in portableRelativePath.split('/')) {
    path = _joinPath(path, component);
  }
  return File(path);
}

String _joinPath(String left, String right) {
  if (left.endsWith(Platform.pathSeparator)) {
    return '$left$right';
  }
  return '$left${Platform.pathSeparator}$right';
}

bool _startsWithUtf8Bom(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xEF &&
    bytes[1] == 0xBB &&
    bytes[2] == 0xBF;

bool _isControl(int rune) =>
    (rune >= 0x0000 && rune <= 0x001F) || (rune >= 0x007F && rune <= 0x009F);

bool _isUnicodeWhitespace(int rune) =>
    (rune >= 0x0009 && rune <= 0x000D) ||
    rune == 0x0020 ||
    rune == 0x0085 ||
    rune == 0x00A0 ||
    rune == 0x1680 ||
    (rune >= 0x2000 && rune <= 0x200A) ||
    rune == 0x2028 ||
    rune == 0x2029 ||
    rune == 0x202F ||
    rune == 0x205F ||
    rune == 0x3000;

SpecPipelineException _error(
  SpecRequest request, {
  required SpecPipelineStage stage,
  required SpecPipelineCode code,
  required String summary,
  String? resolvedPath,
  String? detail,
}) => SpecPipelineException(
  stage: stage,
  code: code,
  summary: summary,
  requestKind: request.kind,
  requested: request.requested,
  resolvedPath: resolvedPath,
  detail: detail,
);

final class _Candidate {
  const _Candidate(this.file, this.origin);

  final File file;
  final SpecCandidateOrigin origin;
}
