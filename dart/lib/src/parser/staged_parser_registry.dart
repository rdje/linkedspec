import '../action/action_parser.dart';
import '../ast/spec_ast.dart';
import '../trace/trace.dart';
import 'user_function_definition_shell.dart';

const String actionIrBodySpecId = 'actionir-body.spec';
const String actionIrBodyTopRule = 'action_block';
const String actionIrBodyResolvedSpecId = 'builtin:actionir-body.spec';
const String actionIrBodyAdapterDigest =
    'sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c';

const _actionIrBodyAdapterSource = 'linkedspec:staged-parser/actionir-body:v1';
const _specLanguageVersion = 'spec-language-v1';
const _helperActionContractVersion = 'actionir-v1';
const _stagedParsingContractVersion = 'staged-parsing-v1';
const _defaultCapabilities = ['actionir_ast_v1'];

final class StagedParserRegistryException implements Exception {
  const StagedParserRegistryException(this.message);

  final String message;

  @override
  String toString() => 'StagedParserRegistryException: $message';
}

final class StagedParseResult {
  const StagedParseResult({
    required this.queueIndex,
    required this.job,
    required this.resolvedSpecId,
    required this.registryProvider,
    required this.cacheKey,
    required this.compiledParser,
    required this.result,
  });

  final int queueIndex;
  final StagedParseJob job;
  final String resolvedSpecId;
  final String registryProvider;
  final JsonObject cacheKey;
  final JsonObject compiledParser;
  final Object result;

  String get jobId => job.jobId;

  JsonObject toJson() {
    return {
      'kind': 'staged_parse_result',
      'version': 1,
      'stage_depth': 1,
      'queue_index': queueIndex,
      'phases': ['resolve', 'load', 'compile', 'execute'],
      'job_id': job.jobId,
      'parent_ast_path': job.parentAstPath,
      'parser_spec_id': job.parserSpecId,
      'resolved_spec_id': resolvedSpecId,
      'registry_provider': registryProvider,
      'top_rule': job.topRule,
      'node_kind': job.nodeKind,
      'payload_kind': job.payloadKind,
      'source_span': job.sourceSpan.toJson(),
      'result_policy': job.resultPolicy,
      'result_field': job.resultField,
      'failure_policy': job.failurePolicy,
      'cache_key': cacheKey,
      'compiled_parser': compiledParser,
      'result': result,
    };
  }
}

final class StagedFunctionBodyDispatchResult {
  const StagedFunctionBodyDispatchResult({
    required this.spec,
    required this.results,
  });

  final SpecFile spec;
  final List<StagedParseResult> results;

  JsonObject toJson() {
    return {
      'kind': 'staged_function_body_dispatch',
      'spec': spec.toJson(),
      'results': [for (final result in results) result.toJson()],
    };
  }
}

Object executeStagedParseJob(
  StagedParseJob job, {
  LinkedSpecTraceEmitter? trace,
}) {
  final results = executeStagedParseJobs([job], trace: trace);
  if (results.isEmpty) {
    throw const StagedParserRegistryException(
      'staged parse dispatch produced no result',
    );
  }
  return results.single.result;
}

List<StagedParseResult> executeStagedParseJobs(
  Iterable<StagedParseJob> jobs, {
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_staged:execute_jobs',
    'start',
    LinkedSpecTraceLevel.high,
  );
  try {
    final queue = [for (final job in jobs) _normalizeJob(job)]
      ..sort(_compareJobs);
    trace?.traceDecision(
      'dart_staged:execute_jobs:queue',
      true,
      'normalized=${queue.length} sorted=1',
      LinkedSpecTraceLevel.medium,
    );

    final results = <StagedParseResult>[];
    for (var index = 0; index < queue.length; index += 1) {
      final job = queue[index];
      final jobScope = trace?.enterScope(
        'dart_staged:job',
        'queue_index=$index job_id=${job.jobId}',
        LinkedSpecTraceLevel.high,
      );
      try {
        final resolved = _resolve(job);
        trace?.traceDecision(
          'dart_staged:job:resolve',
          true,
          'job_id=${job.jobId} resolved_spec_id=${resolved.resolvedSpecId}',
          LinkedSpecTraceLevel.medium,
        );
        final loaded = _load(resolved);
        trace?.traceDecision(
          'dart_staged:job:load',
          true,
          'job_id=${job.jobId} source_kind=${loaded.sourceKind}',
          LinkedSpecTraceLevel.medium,
        );
        final compiled = _compile(loaded, job);
        trace?.traceDecision(
          'dart_staged:job:compile',
          true,
          'job_id=${job.jobId} top_rule=${compiled.topRule}',
          LinkedSpecTraceLevel.medium,
        );
        final result = _execute(compiled, job);
        trace?.traceDecision(
          'dart_staged:job:execute',
          true,
          'job_id=${job.jobId} result_field=${job.resultField}',
          LinkedSpecTraceLevel.medium,
        );
        results.add(
          StagedParseResult(
            queueIndex: index,
            job: job,
            resolvedSpecId: resolved.resolvedSpecId,
            registryProvider: resolved.provider,
            cacheKey: compiled.cacheKey,
            compiledParser: compiled.toJson(),
            result: result,
          ),
        );
        if (jobScope != null) {
          trace?.exitScope(jobScope, 'ok');
        }
      } on Object catch (error) {
        if (jobScope != null) {
          trace?.exitScope(jobScope, 'error=$error');
        }
        rethrow;
      }
    }
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'ok result_count=${results.length}');
    }
    return List.unmodifiable(results);
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

StagedFunctionBodyDispatchResult dispatchFunctionBodyParseJobs(
  SpecFile spec, {
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_staged:function_body_dispatch',
    'function_count=${spec.functions.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final functions = spec.functions;
    final jobs = <StagedParseJob>[];

    for (var index = 0; index < functions.length; index += 1) {
      final function = functions[index];
      final job = function.bodyParseJob;
      if (job == null) {
        continue;
      }
      _validateFunctionBodyJob(function, index, job);
      jobs.add(job);
      trace?.traceDecision(
        'dart_staged:function_body_dispatch:job',
        true,
        'function_index=$index function_name=${function.name}',
        LinkedSpecTraceLevel.medium,
      );
    }

    final results = executeStagedParseJobs(jobs, trace: trace);
    final bodyAstByIndex = <int, Object>{};
    for (final result in results) {
      final index = _functionIndex(result.job);
      if (bodyAstByIndex.containsKey(index)) {
        throw StagedParserRegistryException(
          'duplicate staged function-body result for functions.$index.body_source',
        );
      }
      bodyAstByIndex[index] = result.result;
      trace?.traceDecision(
        'dart_staged:function_body_dispatch:stitch',
        true,
        'function_index=$index result_field=${result.job.resultField}',
        LinkedSpecTraceLevel.medium,
      );
    }

    final dispatch = StagedFunctionBodyDispatchResult(
      spec: SpecFile(
        sourceId: spec.sourceId,
        functions: [
          for (var index = 0; index < functions.length; index += 1)
            if (bodyAstByIndex.containsKey(index))
              _withBodyAst(functions[index], bodyAstByIndex[index])
            else
              functions[index],
        ],
        rules: spec.rules,
      ),
      results: results,
    );
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'ok result_count=${results.length}');
    }
    return dispatch;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

SpecFile stitchFunctionBodyParseJobs(
  SpecFile spec, {
  LinkedSpecTraceEmitter? trace,
}) {
  return dispatchFunctionBodyParseJobs(spec, trace: trace).spec;
}

SpecFile parseSpecWithStagedUserFunctionDefinitionAsts(
  String source,
  Iterable<Object?> definitionNodes, {
  String sourceId = 'inline',
  LinkedSpecTraceEmitter? trace,
}) {
  final traceScope = trace?.enterScope(
    'dart_staged:parse_spec_with_function_asts',
    'source_code_units=${source.length}',
    LinkedSpecTraceLevel.high,
  );
  try {
    final spec = parseSpecWithUserFunctionDefinitionAsts(
      source,
      definitionNodes,
      sourceId: sourceId,
      trace: trace,
    );
    final stitched = stitchFunctionBodyParseJobs(spec, trace: trace);
    if (traceScope != null) {
      trace?.exitScope(
        traceScope,
        'ok functions=${stitched.functions.length} rules=${stitched.rules.length}',
      );
    }
    return stitched;
  } on Object catch (error) {
    if (traceScope != null) {
      trace?.exitScope(traceScope, 'error=$error');
    }
    rethrow;
  }
}

final class _ResolvedParser {
  const _ResolvedParser({
    required this.parserSpecId,
    required this.resolvedSpecId,
    required this.provider,
  });

  final String parserSpecId;
  final String resolvedSpecId;
  final String provider;
}

final class _LoadedParser {
  const _LoadedParser({
    required this.parserSpecId,
    required this.resolvedSpecId,
    required this.sourceKind,
    required this.adapterContract,
    required this.contentDigest,
    required this.importGraphFingerprint,
  });

  final String parserSpecId;
  final String resolvedSpecId;
  final String sourceKind;
  final String adapterContract;
  final String contentDigest;
  final String importGraphFingerprint;
}

final class _CompiledParser {
  const _CompiledParser({
    required this.parserSpecId,
    required this.resolvedSpecId,
    required this.topRule,
    required this.sourceKind,
    required this.capabilities,
    required this.cacheKey,
  });

  final String parserSpecId;
  final String resolvedSpecId;
  final String topRule;
  final String sourceKind;
  final List<String> capabilities;
  final JsonObject cacheKey;

  JsonObject toJson() {
    return {
      'kind': 'staged_compiled_parser',
      'version': 1,
      'parser_spec_id': parserSpecId,
      'resolved_spec_id': resolvedSpecId,
      'top_rule': topRule,
      'source_kind': sourceKind,
      'capabilities': capabilities,
    };
  }
}

StagedParseJob _normalizeJob(StagedParseJob job) {
  if (job.jobId.isEmpty) {
    throw const StagedParserRegistryException(
      'staged parse job job_id must be non-empty',
    );
  }
  final span = job.sourceSpan;
  if (span.start > span.end ||
      span.lineStart == 0 ||
      span.lineEnd == 0 ||
      span.lineStart > span.lineEnd) {
    throw const StagedParserRegistryException(
      'staged parse job source_span has invalid range',
    );
  }
  return job;
}

int _compareJobs(StagedParseJob left, StagedParseJob right) {
  final pathOrder = _compareStringLists(
    left.parentAstPath,
    right.parentAstPath,
  );
  if (pathOrder != 0) {
    return pathOrder;
  }
  final startOrder = left.sourceSpan.start.compareTo(right.sourceSpan.start);
  if (startOrder != 0) {
    return startOrder;
  }
  final endOrder = left.sourceSpan.end.compareTo(right.sourceSpan.end);
  if (endOrder != 0) {
    return endOrder;
  }
  return left.jobId.compareTo(right.jobId);
}

int _compareStringLists(List<String> left, List<String> right) {
  final shared = left.length < right.length ? left.length : right.length;
  for (var index = 0; index < shared; index += 1) {
    final itemOrder = left[index].compareTo(right[index]);
    if (itemOrder != 0) {
      return itemOrder;
    }
  }
  return left.length.compareTo(right.length);
}

_ResolvedParser _resolve(StagedParseJob job) {
  if (job.parserSpecId != actionIrBodySpecId) {
    throw StagedParserRegistryException(
      _dispatchError(
        phase: 'resolve',
        job: job,
        detail: "unsupported parser spec id '${job.parserSpecId}'",
      ),
    );
  }
  return const _ResolvedParser(
    parserSpecId: actionIrBodySpecId,
    resolvedSpecId: actionIrBodyResolvedSpecId,
    provider: 'builtin',
  );
}

_LoadedParser _load(_ResolvedParser resolved) {
  if (resolved.resolvedSpecId != actionIrBodyResolvedSpecId) {
    throw StagedParserRegistryException(
      "unsupported resolved spec id '${resolved.resolvedSpecId}'",
    );
  }
  return _LoadedParser(
    parserSpecId: resolved.parserSpecId,
    resolvedSpecId: resolved.resolvedSpecId,
    sourceKind: 'builtin_adapter',
    adapterContract: _actionIrBodyAdapterSource,
    contentDigest: actionIrBodyAdapterDigest,
    importGraphFingerprint: 'none',
  );
}

_CompiledParser _compile(_LoadedParser loaded, StagedParseJob job) {
  final topRule = job.topRule;
  if (loaded.resolvedSpecId != actionIrBodyResolvedSpecId) {
    throw StagedParserRegistryException(
      _dispatchError(
        phase: 'compile',
        job: job,
        resolvedSpecId: loaded.resolvedSpecId,
        detail: "unsupported resolved spec id '${loaded.resolvedSpecId}'",
      ),
    );
  }
  if (topRule != actionIrBodyTopRule) {
    throw StagedParserRegistryException(
      _dispatchError(
        phase: 'compile',
        job: job,
        resolvedSpecId: loaded.resolvedSpecId,
        detail: "unsupported top rule '$topRule'",
      ),
    );
  }
  final capabilities = _normalizeCapabilities(null);
  return _CompiledParser(
    parserSpecId: loaded.parserSpecId,
    resolvedSpecId: loaded.resolvedSpecId,
    topRule: topRule,
    sourceKind: loaded.sourceKind,
    capabilities: capabilities,
    cacheKey: _cacheKey(loaded, topRule, capabilities),
  );
}

Object _execute(_CompiledParser compiled, StagedParseJob job) {
  if (compiled.resolvedSpecId != actionIrBodyResolvedSpecId ||
      compiled.topRule != actionIrBodyTopRule) {
    throw StagedParserRegistryException(
      _dispatchError(
        phase: 'execute',
        job: job,
        resolvedSpecId: compiled.resolvedSpecId,
        detail: 'compiled parser identity is unsupported',
      ),
    );
  }
  try {
    return parseActionBlock(job.text).toJson();
  } on Object catch (error) {
    throw StagedParserRegistryException(
      _dispatchError(
        phase: 'execute',
        job: job,
        resolvedSpecId: compiled.resolvedSpecId,
        detail: 'action block parse failed: $error',
      ),
    );
  }
}

JsonObject _cacheKey(
  _LoadedParser loaded,
  String topRule,
  List<String> capabilities,
) {
  final capabilityText = capabilities.join(',');
  final fingerprint = [
    loaded.resolvedSpecId,
    loaded.contentDigest,
    loaded.importGraphFingerprint,
    topRule,
    _specLanguageVersion,
    _helperActionContractVersion,
    _stagedParsingContractVersion,
    capabilityText,
  ].join('|');
  return {
    'kind': 'staged_parser_cache_key',
    'version': 1,
    'normalized_spec_identity': loaded.resolvedSpecId,
    'content_digest': loaded.contentDigest,
    'import_graph_fingerprint': loaded.importGraphFingerprint,
    'top_rule': topRule,
    'spec_language_version': _specLanguageVersion,
    'helper_action_contract_version': _helperActionContractVersion,
    'staged_parsing_contract_version': _stagedParsingContractVersion,
    'backend_capabilities': capabilities,
    'fingerprint': fingerprint,
    'source_kind': loaded.sourceKind,
    'adapter_contract': loaded.adapterContract,
  };
}

List<String> _normalizeCapabilities(Iterable<String>? capabilitySet) {
  if (capabilitySet == null) {
    return List.unmodifiable(_defaultCapabilities);
  }
  final capabilities = <String>[];
  for (final capability in capabilitySet) {
    if (capability.isNotEmpty && !capabilities.contains(capability)) {
      capabilities.add(capability);
    }
  }
  if (capabilities.isEmpty) {
    capabilities.addAll(_defaultCapabilities);
  }
  return List.unmodifiable(capabilities);
}

void _validateFunctionBodyJob(
  FunctionDefinition function,
  int index,
  StagedParseJob job,
) {
  _normalizeJob(job);
  final expectedPath = ['functions', '$index', 'body_source'];
  if (!_stringListsEqual(job.parentAstPath, expectedPath)) {
    throw StagedParserRegistryException(
      'function ${function.name} body_parse_job parent_ast_path must target '
      'functions.$index.body_source',
    );
  }
  if (job.nodeKind != 'function_definition') {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job node_kind must be "
      "'function_definition'",
    );
  }
  if (job.payloadKind != 'function_body') {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job payload_kind must be "
      "'function_body'",
    );
  }
  if (job.functionName != null && job.functionName != function.name) {
    throw StagedParserRegistryException(
      'function ${function.name} body_parse_job function_name does not match',
    );
  }
  final signature = function.signature;
  if (function.parameterKinds.isNotEmpty) {
    final finalParam = function.params.last;
    final fixedParams = function.params.sublist(0, function.params.length - 1);
    if (job.params != null || job.arity != null || job.signature != null) {
      throw StagedParserRegistryException(
        'function ${function.name} typed body_parse_job must store '
        'fixed_params plus codeblock_param',
      );
    }
    if (job.fixedParams == null ||
        !_stringListsEqual(job.fixedParams!, fixedParams) ||
        job.codeblockParam != finalParam ||
        !_stringMapsEqual(job.parameterKinds, function.parameterKinds)) {
      throw StagedParserRegistryException(
        'function ${function.name} body_parse_job final-codeblock metadata '
        'does not match',
      );
    }
  } else if (signature != null) {
    if (job.params != null || job.arity != null || job.signature == null) {
      throw StagedParserRegistryException(
        'function ${function.name} body_parse_job must store variadic arity '
        'only in signature',
      );
    }
    if (!_callableSignaturesEqual(job.signature!, signature)) {
      throw StagedParserRegistryException(
        'function ${function.name} body_parse_job signature does not match',
      );
    }
  } else {
    if (job.signature != null) {
      throw StagedParserRegistryException(
        'function ${function.name} fixed body_parse_job must not contain '
        'signature',
      );
    }
    if (job.params != null &&
        !_stringListsEqual(job.params!, function.params)) {
      throw StagedParserRegistryException(
        'function ${function.name} body_parse_job params do not match',
      );
    }
    if (job.arity != null && job.arity != function.arity) {
      throw StagedParserRegistryException(
        'function ${function.name} body_parse_job arity does not match',
      );
    }
  }
  if (job.text != function.bodySource) {
    throw StagedParserRegistryException(
      'function ${function.name} body_parse_job text does not match body_source',
    );
  }
  if (job.parserSpecId != actionIrBodySpecId) {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job parser_spec_id must be "
      "'$actionIrBodySpecId'",
    );
  }
  if (job.topRule != actionIrBodyTopRule) {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job top_rule must be "
      "'$actionIrBodyTopRule'",
    );
  }
  if (job.resultPolicy != 'replace_field') {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job result_policy must be "
      "'replace_field'",
    );
  }
  if (job.resultField != 'body_ast') {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job result_field must be "
      "'body_ast'",
    );
  }
  if (job.failurePolicy != 'fail') {
    throw StagedParserRegistryException(
      "function ${function.name} body_parse_job failure_policy must be 'fail'",
    );
  }
}

int _functionIndex(StagedParseJob job) {
  if (job.parentAstPath.length != 3 ||
      job.parentAstPath[0] != 'functions' ||
      job.parentAstPath[2] != 'body_source') {
    throw StagedParserRegistryException(
      'staged parse result parent_ast_path must target functions[*].body_source',
    );
  }
  final index = int.tryParse(job.parentAstPath[1]);
  if (index == null) {
    throw StagedParserRegistryException(
      "staged parse result parent_ast_path has non-numeric function index "
      "'${job.parentAstPath[1]}'",
    );
  }
  return index;
}

FunctionDefinition _withBodyAst(FunctionDefinition function, Object? bodyAst) {
  return FunctionDefinition(
    name: function.name,
    params: function.params,
    arity: function.arity,
    parameterKinds: function.parameterKinds,
    signature: function.signature,
    bodySource: function.bodySource,
    bodyPayload: function.bodyPayload,
    bodyParseJob: function.bodyParseJob,
    bodyAst: bodyAst,
    source: function.source,
    sourceSpan: function.sourceSpan,
    bodySpan: function.bodySpan,
  );
}

bool _stringListsEqual(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

bool _stringMapsEqual(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

bool _callableSignaturesEqual(CallableSignature left, CallableSignature right) {
  return left.kind == right.kind &&
      left.version == right.version &&
      _stringListsEqual(left.positionalParams, right.positionalParams) &&
      left.restParam == right.restParam &&
      left.minArity == right.minArity &&
      left.maxArity == right.maxArity;
}

String _dispatchError({
  required String phase,
  required StagedParseJob job,
  required String detail,
  String? resolvedSpecId,
}) {
  final parentPath = job.parentAstPath.isEmpty
      ? '<unknown>'
      : job.parentAstPath.join('.');
  final span = '${job.sourceSpan.start}-${job.sourceSpan.end}';
  return 'staged parse dispatch failed: phase=$phase; '
      'job_id=${job.jobId}; '
      'parent_ast_path=$parentPath; '
      'parser_spec_id=${job.parserSpecId}; '
      'resolved_spec_id=${resolvedSpecId ?? "<unresolved>"}; '
      'top_rule=${job.topRule}; '
      'payload_kind=${job.payloadKind}; '
      'source_span=$span; '
      'failure_policy=${job.failurePolicy}; '
      'detail=$detail';
}
