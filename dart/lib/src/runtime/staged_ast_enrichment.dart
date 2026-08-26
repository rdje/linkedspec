/// Private caller-frozen authority for one staged-AST marker depth.
///
/// The trusted host supplies a completed immutable resolution snapshot and
/// already-compiled callbacks. Dispatch performs no loading, compilation,
/// provider query, filesystem access, registry mutation, or recursive rescan.
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import '../semantic/sha256.dart' show sha256Hex;

const _errorPrefix = 'LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:';
const _markerKind = 'STAGED_PARSE_JOB_MARKER';
const _sidecarKind = 'staged_parse_job_v2';
const _sourceDetails = <String>['none', 'identity', 'span', 'text'];
const _liveResultKeys = <String>{
  r'$ref',
  'parser',
  'parser_handle',
  'registry',
  'source_authority',
  'frame',
  'transaction',
  'cancellation',
  'callback',
  'host',
  'path',
  'live_handle',
};

/// One detached private staged-enrichment failure.
final class StagedAstEnrichmentException implements Exception {
  StagedAstEnrichmentException._(
    String code,
    String phase,
    Map<String, Object?> fields,
  ) : _record = Map<String, Object?>.unmodifiable(<String, Object?>{
        'code': code,
        'phase': phase,
        ..._copyRecord(fields),
      });

  factory StagedAstEnrichmentException.snapshot(String component) =>
      StagedAstEnrichmentException._(
        'staged_registry_snapshot_invalid',
        'prepare',
        <String, Object?>{'snapshot_component': component},
      );

  final Map<String, Object?> _record;

  String get code => _record['code']! as String;

  /// Returns a fresh detached diagnostic record.
  Map<String, Object?> toJson() => _copyRecord(_record);

  @override
  String toString() => '$_errorPrefix$code';
}

/// Explicit success/failure result returned by one already-compiled callback.
final class StagedChildExecution {
  StagedChildExecution._({required this.succeeded, this.value});

  factory StagedChildExecution.success(Object? value) =>
      StagedChildExecution._(succeeded: true, value: value);

  factory StagedChildExecution.failure(Object? diagnostic) =>
      StagedChildExecution._(succeeded: false, value: diagnostic);

  final bool succeeded;
  final Object? value;
}

/// One already-compiled opaque child parser callback.
typedef StagedCompiledAuthority =
    StagedChildExecution Function(
      Map<String, Object?> request,
      StagedRuntimeContext context,
    );

/// Fresh mutable parser state supplied to exactly one sibling callback.
final class StagedRuntimeContext {
  int cursor = 0;
  final Map<String, Object?> marks = <String, Object?>{};
  final Map<String, Object?> captures = <String, Object?>{};
  final Map<String, Object?> variables = <String, Object?>{};
}

final class _DirectCandidate {
  const _DirectCandidate({
    required this.declaringSpecId,
    required this.authoredId,
    required this.resolvedSpecId,
  });

  final String declaringSpecId;
  final String authoredId;
  final String resolvedSpecId;
}

final class _Candidate {
  const _Candidate({required this.authoredId, required this.resolvedSpecId});

  final String authoredId;
  final String resolvedSpecId;
}

final class _OrderedCandidates {
  const _OrderedCandidates({
    required this.identity,
    required this.order,
    required this.candidates,
  });

  final String identity;
  final int order;
  final List<_Candidate> candidates;
}

final class _Ceilings {
  const _Ceilings({
    required this.sourceDetail,
    required this.maxSteps,
    required this.maxResultNodes,
    required this.maxDiagnosticBytes,
  });

  final String sourceDetail;
  final int maxSteps;
  final int maxResultNodes;
  final int maxDiagnosticBytes;
}

final class _Versions {
  const _Versions({
    required this.specLanguageVersion,
    required this.helperContractVersion,
    required this.stagedContractVersion,
  });

  final int specLanguageVersion;
  final String helperContractVersion;
  final int stagedContractVersion;
}

final class _RegistryEntry {
  const _RegistryEntry({
    required this.compiledAuthority,
    required this.contentDigest,
    required this.importGraphFingerprint,
    required this.defaultTopRule,
    required this.allowedTopRules,
    required this.versions,
    required this.capabilities,
    required this.policyModes,
    required this.ceilings,
  });

  final StagedCompiledAuthority compiledAuthority;
  final String contentDigest;
  final String importGraphFingerprint;
  final String defaultTopRule;
  final Set<String> allowedTopRules;
  final _Versions versions;
  final Set<String> capabilities;
  final Set<String> policyModes;
  final _Ceilings ceilings;
}

final class _CachedPlan {
  const _CachedPlan({
    required this.compiledAuthority,
    required this.resolvedSpecId,
    required this.topRule,
    required this.effectiveCapabilities,
  });

  final StagedCompiledAuthority compiledAuthority;
  final String resolvedSpecId;
  final String topRule;
  final List<String> effectiveCapabilities;
}

/// Detached plan-cache counters for one frozen registry instance.
final class StagedCacheStats {
  const StagedCacheStats({
    required this.snapshotId,
    required this.entries,
    required this.hits,
    required this.misses,
  });

  final String snapshotId;
  final int entries;
  final int hits;
  final int misses;

  Map<String, Object?> toJson() => <String, Object?>{
    'snapshot_id': snapshotId,
    'entries': entries,
    'hits': hits,
    'misses': misses,
  };
}

/// Immutable caller-prepared registry plus its invocation-local plan cache.
final class FrozenStagedRegistry {
  factory FrozenStagedRegistry.fromSnapshot({
    required Object? snapshot,
    required Map<String, StagedCompiledAuthority> compiledAuthorities,
  }) {
    final object = _snapshotObject(snapshot, 'shape');
    if (object['immutable'] != true ||
        object['prepared_before_authored_execution'] != true ||
        object['filesystem_access_during_dispatch'] != false) {
      throw StagedAstEnrichmentException.snapshot('authority_boundary');
    }

    final remainingCallbacks = <String, StagedCompiledAuthority>{
      ...compiledAuthorities,
    };
    final entries = <String, _RegistryEntry>{};
    final logicalSnapshot = _copyPlain(snapshot);
    final logicalEntries = _snapshotList(
      _snapshotObject(logicalSnapshot, 'shape')['entries'],
      'entries',
    );
    final entryRows = _snapshotList(object['entries'], 'entries');
    if (entryRows.isEmpty || logicalEntries.length != entryRows.length) {
      throw StagedAstEnrichmentException.snapshot('entries');
    }
    for (var index = 0; index < entryRows.length; index += 1) {
      final row = _snapshotObject(entryRows[index], 'entries');
      final resolvedSpecId = _requiredSnapshotString(row, 'resolved_spec_id');
      if (!_validParserIdentity(resolvedSpecId) ||
          entries.containsKey(resolvedSpecId)) {
        throw StagedAstEnrichmentException.snapshot('resolved_spec_id');
      }
      final authorityName = _requiredSnapshotString(row, 'compiled_authority');
      final callback = remainingCallbacks.remove(authorityName);
      if (callback == null) {
        throw StagedAstEnrichmentException.snapshot('compiled_authority');
      }
      final contentDigest = _requiredDigest(row, 'content_digest');
      final importGraphFingerprint = _requiredDigest(
        row,
        'import_graph_fingerprint',
      );
      final defaultTopRule = _requiredTopRule(row, 'default_top_rule');
      final allowedTopRules = _snapshotStringSet(
        row['allowed_top_rules'],
        'allowed_top_rules',
      );
      if (!allowedTopRules.contains(defaultTopRule)) {
        throw StagedAstEnrichmentException.snapshot('default_top_rule');
      }
      final versions = _Versions(
        specLanguageVersion: _positiveSnapshotInt(row, 'spec_language_version'),
        helperContractVersion: _requiredSnapshotString(
          row,
          'helper_contract_version',
        ),
        stagedContractVersion: _positiveSnapshotInt(
          row,
          'staged_contract_version',
        ),
      );
      entries[resolvedSpecId] = _RegistryEntry(
        compiledAuthority: callback,
        contentDigest: contentDigest,
        importGraphFingerprint: importGraphFingerprint,
        defaultTopRule: defaultTopRule,
        allowedTopRules: allowedTopRules,
        versions: versions,
        capabilities: _snapshotStringSet(row['capabilities'], 'capabilities'),
        policyModes: _snapshotStringSet(row['policy_modes'], 'policy_modes'),
        ceilings: _parseCeilings(row['ceilings'], 'ceilings'),
      );
      final logicalEntry = logicalEntries[index];
      if (logicalEntry is! Map ||
          logicalEntry['compiled_authority'] is! String) {
        throw StagedAstEnrichmentException.snapshot('compiled_authority');
      }
      logicalEntry['compiled_authority'] = 'opaque:compiled:callback';
    }
    if (remainingCallbacks.isNotEmpty) {
      throw StagedAstEnrichmentException.snapshot('compiled_authority');
    }

    final frozenEntries = Map<String, _RegistryEntry>.unmodifiable(entries);
    return FrozenStagedRegistry._(
      aliases: _directCandidates(object['aliases'], frozenEntries, 'aliases'),
      declaringRelative: _directCandidates(
        object['declaring_relative'],
        frozenEntries,
        'declaring_relative',
      ),
      searchRoots: _orderedCandidates(
        object['search_roots'],
        frozenEntries,
        identityField: 'root_id',
        component: 'search_roots',
      ),
      providers: _orderedCandidates(
        object['providers'],
        frozenEntries,
        identityField: 'provider_id',
        component: 'providers',
      ),
      entries: frozenEntries,
      snapshotId: 'registry-snapshot:${_digest(logicalSnapshot)}',
    );
  }

  FrozenStagedRegistry._({
    required this.aliases,
    required this.declaringRelative,
    required this.searchRoots,
    required this.providers,
    required this.entries,
    required this.snapshotId,
  });

  final List<_DirectCandidate> aliases;
  final List<_DirectCandidate> declaringRelative;
  final List<_OrderedCandidates> searchRoots;
  final List<_OrderedCandidates> providers;
  final Map<String, _RegistryEntry> entries;
  final String snapshotId;
  final Map<String, _CachedPlan> _cache = <String, _CachedPlan>{};
  int _hits = 0;
  int _misses = 0;

  /// Runtime registry mutation is never authored authority.
  Never register(String parserSpecId) {
    throw StagedAstEnrichmentException._(
      'staged_registry_mutation_forbidden',
      'resolve',
      <String, Object?>{
        'job_id': '<host>',
        'parser_spec_id': parserSpecId,
        'operation': 'register',
      },
    );
  }

  /// Runtime path/provider loading is never authored authority.
  Never load(String parserSpecId) {
    throw StagedAstEnrichmentException._(
      'staged_implicit_load_forbidden',
      'resolve',
      <String, Object?>{
        'job_id': '<host>',
        'parser_spec_id': parserSpecId,
        'operation': 'load',
      },
    );
  }

  /// Selects one identity only from caller-completed candidate outcomes.
  String resolvePreRegistered({
    required String declaringSpecId,
    required String parserSpecId,
    required String jobId,
  }) {
    if (!_validParserIdentity(parserSpecId)) {
      throw StagedAstEnrichmentException._(
        'staged_parser_identity_invalid',
        'resolve',
        <String, Object?>{'origin': 'post_ast', 'parser_spec_id': parserSpecId},
      );
    }
    final aliasMatches = _directMatches(aliases, declaringSpecId, parserSpecId);
    final relativeMatches = _directMatches(
      declaringRelative,
      declaringSpecId,
      parserSpecId,
    );
    if (aliasMatches.isNotEmpty && relativeMatches.isNotEmpty) {
      throw StagedAstEnrichmentException._(
        'staged_registry_collision',
        'resolve',
        <String, Object?>{
          'job_id': jobId,
          'parser_spec_id': parserSpecId,
          'aliases': aliasMatches,
          'relative_candidates': relativeMatches,
        },
      );
    }
    if (aliasMatches.length > 1 || relativeMatches.length > 1) {
      final ambiguous = aliasMatches.length > 1
          ? ('alias', aliasMatches)
          : ('declaring_relative', relativeMatches);
      throw StagedAstEnrichmentException._(
        'staged_registry_ambiguous',
        'resolve',
        <String, Object?>{
          'job_id': jobId,
          'parser_spec_id': parserSpecId,
          'priority': ambiguous.$1,
          'candidates': ambiguous.$2,
        },
      );
    }
    if (aliasMatches.isNotEmpty || relativeMatches.isNotEmpty) {
      return aliasMatches.isNotEmpty
          ? aliasMatches.single
          : relativeMatches.single;
    }
    for (final group in <_OrderedCandidates>[...searchRoots, ...providers]) {
      final matches = <String>[
        for (final candidate in group.candidates)
          if (candidate.authoredId == parserSpecId) candidate.resolvedSpecId,
      ];
      if (matches.length > 1) {
        throw StagedAstEnrichmentException._(
          'staged_registry_ambiguous',
          'resolve',
          <String, Object?>{
            'job_id': jobId,
            'parser_spec_id': parserSpecId,
            'priority': group.identity,
            'candidates': matches,
          },
        );
      }
      if (matches.isNotEmpty) {
        return matches.single;
      }
    }
    throw StagedAstEnrichmentException._(
      'staged_registry_missing',
      'resolve',
      <String, Object?>{
        'job_id': jobId,
        'parser_spec_id': parserSpecId,
        'declaring_spec_id': declaringSpecId,
      },
    );
  }

  /// Evaluates one neutral authority-intersection case.
  Map<String, Object?> evaluateAuthorityCase({
    required Object? authorityCase,
    required String jobId,
  }) {
    final object = _snapshotObject(authorityCase, 'authority_case');
    final requirements = _AuthorityRequirements(
      callerCapabilities: _snapshotStringSet(
        object['caller_capabilities'],
        'caller_capabilities',
      ),
      requiredCapabilities: _snapshotStringSet(
        object['required_capabilities'],
        'required_capabilities',
      ),
      callerPolicyModes: _snapshotStringSet(
        object['caller_policy_modes'],
        'caller_policy_modes',
      ),
      requiredPolicyModes: _snapshotStringSet(
        object['required_policy_modes'],
        'required_policy_modes',
      ),
      callerCeilings: _parseCeilings(
        object['caller_ceilings'],
        'caller_ceilings',
      ),
      requiredSourceDetail: _requiredSnapshotString(
        object,
        'required_source_detail',
      ),
      requiredVersions: _parseVersions(
        object['required_versions'],
        'required_versions',
      ),
    );
    return _effectiveAuthority(
      entryId: _requiredSnapshotString(object, 'entry_id'),
      topRule: _requiredTopRule(object, 'top_rule'),
      jobId: jobId,
      requirements: requirements,
    );
  }

  StagedCacheStats get cacheStats => StagedCacheStats(
    snapshotId: snapshotId,
    entries: _cache.length,
    hits: _hits,
    misses: _misses,
  );

  Map<String, Object?> _effectiveAuthority({
    required String entryId,
    required String topRule,
    required String jobId,
    required _AuthorityRequirements requirements,
  }) {
    final entry = entries[entryId];
    if (entry == null) {
      throw StagedAstEnrichmentException._(
        'staged_registry_missing',
        'resolve',
        <String, Object?>{
          'job_id': jobId,
          'parser_spec_id': entryId,
          'declaring_spec_id': '<prepared-snapshot>',
        },
      );
    }
    final versions = <(String, Object, Object)>[
      (
        'spec_language_version',
        requirements.requiredVersions.specLanguageVersion,
        entry.versions.specLanguageVersion,
      ),
      (
        'helper_contract_version',
        requirements.requiredVersions.helperContractVersion,
        entry.versions.helperContractVersion,
      ),
      (
        'staged_contract_version',
        requirements.requiredVersions.stagedContractVersion,
        entry.versions.stagedContractVersion,
      ),
    ];
    for (final (kind, required, actual) in versions) {
      if (required != actual) {
        throw StagedAstEnrichmentException._(
          'staged_version_mismatch',
          'compile',
          <String, Object?>{
            'job_id': jobId,
            'resolved_spec_id': entryId,
            'version_kind': kind,
            'required': required,
            'actual': actual,
          },
        );
      }
    }
    if (!entry.allowedTopRules.contains(topRule)) {
      throw StagedAstEnrichmentException._(
        'staged_top_rule_forbidden',
        'compile',
        <String, Object?>{
          'job_id': jobId,
          'resolved_spec_id': entryId,
          'top_rule': topRule,
        },
      );
    }

    final capabilities =
        entry.capabilities
            .intersection(requirements.callerCapabilities)
            .toList()
          ..sort(_compareUnicodeScalarStrings);
    for (final capability in requirements.requiredCapabilities) {
      if (!capabilities.contains(capability)) {
        throw StagedAstEnrichmentException._(
          'staged_capability_denied',
          'compile',
          <String, Object?>{
            'job_id': jobId,
            'resolved_spec_id': entryId,
            'capability': capability,
          },
        );
      }
    }
    final policyModes =
        entry.policyModes.intersection(requirements.callerPolicyModes).toList()
          ..sort(_compareUnicodeScalarStrings);
    for (final policy in requirements.requiredPolicyModes) {
      if (!policyModes.contains(policy)) {
        throw StagedAstEnrichmentException._(
          'staged_policy_denied',
          'compile',
          <String, Object?>{
            'job_id': jobId,
            'resolved_spec_id': entryId,
            'policy': policy,
          },
        );
      }
    }
    final sourceRank = math.min(
      _sourceDetailRank(requirements.callerCeilings.sourceDetail),
      _sourceDetailRank(entry.ceilings.sourceDetail),
    );
    final requiredSourceRank = _sourceDetailRank(
      requirements.requiredSourceDetail,
    );
    if (sourceRank < requiredSourceRank) {
      throw StagedAstEnrichmentException._(
        'staged_source_detail_denied',
        'compile',
        <String, Object?>{
          'job_id': jobId,
          'resolved_spec_id': entryId,
          'required': requirements.requiredSourceDetail,
          'effective': _sourceDetails[sourceRank],
        },
      );
    }
    return <String, Object?>{
      'capabilities': capabilities,
      'policy_modes': policyModes,
      'source_detail': _sourceDetails[sourceRank],
      'max_steps': math.min(
        requirements.callerCeilings.maxSteps,
        entry.ceilings.maxSteps,
      ),
      'max_result_nodes': math.min(
        requirements.callerCeilings.maxResultNodes,
        entry.ceilings.maxResultNodes,
      ),
      'max_diagnostic_bytes': math.min(
        requirements.callerCeilings.maxDiagnosticBytes,
        entry.ceilings.maxDiagnosticBytes,
      ),
    };
  }

  _CachedPlan _cachedPlan(_PreparedPlan plan) {
    final cached = _cache[plan.cacheKey];
    if (cached != null) {
      _hits += 1;
      return cached;
    }
    final entry = entries[plan.resolvedSpecId]!;
    final created = _CachedPlan(
      compiledAuthority: entry.compiledAuthority,
      resolvedSpecId: plan.resolvedSpecId,
      topRule: plan.topRule,
      effectiveCapabilities: List<String>.unmodifiable(
        _stringList(plan.effective['capabilities'], 'capabilities'),
      ),
    );
    _cache[plan.cacheKey] = created;
    _misses += 1;
    return created;
  }
}

final class _AuthorityRequirements {
  const _AuthorityRequirements({
    required this.callerCapabilities,
    required this.requiredCapabilities,
    required this.callerPolicyModes,
    required this.requiredPolicyModes,
    required this.callerCeilings,
    required this.requiredSourceDetail,
    required this.requiredVersions,
  });

  final Set<String> callerCapabilities;
  final Set<String> requiredCapabilities;
  final Set<String> callerPolicyModes;
  final Set<String> requiredPolicyModes;
  final _Ceilings callerCeilings;
  final String requiredSourceDetail;
  final _Versions requiredVersions;
}

final class _EnrichmentOptions {
  const _EnrichmentOptions({
    required this.declaringSpecId,
    required this.callerCapabilities,
    required this.callerPolicyModes,
    required this.callerCeilings,
    required this.requiredSourceDetail,
    required this.requiredVersions,
  });

  factory _EnrichmentOptions.parse(Object? value) {
    final object = _snapshotObject(value, 'enrichment_options');
    final declaringSpecId = _requiredSnapshotString(
      object,
      'declaring_spec_id',
    );
    if (!_validParserIdentity(declaringSpecId)) {
      throw StagedAstEnrichmentException.snapshot('declaring_spec_id');
    }
    final requiredSourceDetail = _requiredSnapshotString(
      object,
      'required_source_detail',
    );
    _sourceDetailRank(requiredSourceDetail);
    return _EnrichmentOptions(
      declaringSpecId: declaringSpecId,
      callerCapabilities: _snapshotStringSet(
        object['caller_capabilities'],
        'caller_capabilities',
      ),
      callerPolicyModes: _snapshotStringSet(
        object['caller_policy_modes'],
        'caller_policy_modes',
      ),
      callerCeilings: _parseCeilings(
        object['caller_ceilings'],
        'caller_ceilings',
      ),
      requiredSourceDetail: requiredSourceDetail,
      requiredVersions: _parseVersions(
        object['required_versions'],
        'required_versions',
      ),
    );
  }

  final String declaringSpecId;
  final Set<String> callerCapabilities;
  final Set<String> callerPolicyModes;
  final _Ceilings callerCeilings;
  final String requiredSourceDetail;
  final _Versions requiredVersions;
}

final class _DiscoveredMarker {
  const _DiscoveredMarker({required this.path, required this.marker});

  final List<Object?> path;
  final Map<String, Object?> marker;
}

final class _PreparedPlan {
  _PreparedPlan({
    required this.path,
    required this.marker,
    required this.sidecar,
    required this.resolvedSpecId,
    required this.topRule,
    required this.cacheKey,
    required this.effective,
    required this.provenanceOrder,
  });

  final List<Object?> path;
  final Map<String, Object?> marker;
  final Map<String, Object?> sidecar;
  final String resolvedSpecId;
  final String topRule;
  final String cacheKey;
  final Map<String, Object?> effective;
  final List<Object> provenanceOrder;
}

/// One detached current-depth enrichment result.
final class StagedEnrichmentOutcome {
  const StagedEnrichmentOutcome({
    required this.ast,
    required this.sidecars,
    required this.diagnostics,
    required this.cache,
  });

  final Object? ast;
  final List<Map<String, Object?>> sidecars;
  final List<Map<String, Object?>> diagnostics;
  final StagedCacheStats cache;

  Map<String, Object?> toJson() => <String, Object?>{
    'ast': _copyPlain(ast),
    'sidecars': <Object?>[for (final sidecar in sidecars) _copyRecord(sidecar)],
    'diagnostics': <Object?>[
      for (final diagnostic in diagnostics) _copyRecord(diagnostic),
    ],
    'cache': cache.toJson(),
  };
}

/// Executes exactly one complete marker depth through caller-frozen authority.
StagedEnrichmentOutcome enrichStagedCurrentDepth({
  required FrozenStagedRegistry registry,
  required Object? ast,
  required Object? options,
}) {
  final parsedOptions = _EnrichmentOptions.parse(options);
  var working = _copyAst(ast);
  final discovered = <_DiscoveredMarker>[];
  _discoverMarkers(working, <Object?>[], discovered);
  final plans = <_PreparedPlan>[
    for (final marker in discovered)
      _preparePlan(registry, marker, parsedOptions),
  ]..sort(_comparePlans);

  final seenJobIds = <String, List<Object?>>{};
  for (final plan in plans) {
    final jobId = plan.sidecar['job_id']! as String;
    final earlier = seenJobIds[jobId];
    if (earlier != null) {
      throw StagedAstEnrichmentException._(
        'staged_duplicate_job_id',
        'prepare',
        <String, Object?>{'job_id': jobId, 'parent_ast_path': plan.path},
      );
    }
    seenJobIds[jobId] = plan.path;
    _validateStitchTarget(working, plan);
  }

  final diagnostics = <Map<String, Object?>>[];
  for (final plan in plans) {
    _validateStitchTarget(working, plan);
    final cached = registry._cachedPlan(plan);
    if (cached.resolvedSpecId != plan.resolvedSpecId ||
        cached.topRule != plan.topRule ||
        !_sameStringLists(
          cached.effectiveCapabilities,
          _stringList(plan.effective['capabilities'], 'capabilities'),
        )) {
      throw StagedAstEnrichmentException.snapshot('plan_cache');
    }
    final context = StagedRuntimeContext();
    StagedChildExecution execution;
    try {
      execution = cached.compiledAuthority(_childRequest(plan), context);
    } on Object {
      execution = StagedChildExecution.failure(<String, Object?>{
        'code': 'staged_child_exception',
      });
    }
    if (execution.succeeded) {
      try {
        final detached = _detachResult(
          execution.value,
          maximum: plan.effective['max_result_nodes']! as int,
          sidecar: plan.sidecar,
        );
        working = _stitchValue(working, plan, detached);
        plan.sidecar['state'] = 'succeeded';
      } on _DetachedResultFailure catch (failure) {
        working = _settleFailure(
          working,
          plan,
          failure.diagnostic,
          diagnostics,
        );
      }
    } else {
      working = _settleFailure(
        working,
        plan,
        _childFailureDiagnostic(plan.sidecar, execution.value),
        diagnostics,
      );
    }
  }
  return StagedEnrichmentOutcome(
    ast: _copyPlain(working),
    sidecars: List<Map<String, Object?>>.unmodifiable(<Map<String, Object?>>[
      for (final plan in plans) _copyRecord(plan.sidecar),
    ]),
    diagnostics: List<Map<String, Object?>>.unmodifiable(<Map<String, Object?>>[
      for (final diagnostic in diagnostics) _copyRecord(diagnostic),
    ]),
    cache: registry.cacheStats,
  );
}

/// Constructs the deterministic neutral v2 job identity.
String stagedJobIdentity(Object? fields) {
  final object = _exactObject(fields, const <String>[
    'declaring_spec_id',
    'parent_ast_path',
    'node_kind',
    'payload_kind',
    'parser_spec_id',
    'top_rule',
    'provenance',
  ], 'job_identity');
  final identity = <String, Object?>{
    'contract_version': 2,
    'declaring_spec_id': object['declaring_spec_id'],
    'parent_ast_path': object['parent_ast_path'],
    'node_kind': object['node_kind'],
    'payload_kind': object['payload_kind'],
    'parser_spec_id': object['parser_spec_id'],
    'top_rule': object['top_rule'],
    'provenance': object['provenance'],
  };
  return 'parse_job:v2:${_digest(identity)}';
}

/// Constructs the normalized immutable compiled-plan cache identity.
String stagedCacheIdentity(Object? fields) {
  late final Map<String, Object?> object;
  try {
    object = _exactObject(fields, const <String>[
      'normalized_spec_id',
      'content_digest',
      'import_graph_fingerprint',
      'top_rule',
      'spec_language_version',
      'helper_contract_version',
      'staged_contract_version',
      'backend_capabilities',
    ], 'cache_identity');
  } on StagedAstEnrichmentException {
    throw _cacheIdentityError(fields, '<shape>');
  }
  final normalizedSpecId = object['normalized_spec_id'];
  if (normalizedSpecId is! String || !_validParserIdentity(normalizedSpecId)) {
    throw _cacheIdentityError(object, 'normalized_spec_id');
  }
  for (final field in <String>['content_digest', 'import_graph_fingerprint']) {
    if (object[field] is! String || !_validDigest(object[field]! as String)) {
      throw _cacheIdentityError(object, field);
    }
  }
  if (object['top_rule'] is! String ||
      !_validTopRule(object['top_rule']! as String)) {
    throw _cacheIdentityError(object, 'top_rule');
  }
  for (final field in <String>[
    'spec_language_version',
    'staged_contract_version',
  ]) {
    if (object[field] is! int || (object[field]! as int) <= 0) {
      throw _cacheIdentityError(object, field);
    }
  }
  if (object['helper_contract_version'] is! String ||
      (object['helper_contract_version']! as String).isEmpty) {
    throw _cacheIdentityError(object, 'helper_contract_version');
  }
  late final List<String> capabilities;
  try {
    capabilities = _stringSet(
      object['backend_capabilities'],
      'backend_capabilities',
    ).toList()..sort(_compareUnicodeScalarStrings);
  } on StagedAstEnrichmentException {
    throw _cacheIdentityError(object, 'backend_capabilities');
  }
  return _digest(<String, Object?>{
    ...object,
    'backend_capabilities': capabilities,
  });
}

/// Orders a neutral inventory by depth, typed path/provenance, then job id.
List<String> stagedCurrentDepthOrder(Object? jobs) {
  if (jobs is! List) {
    throw StagedAstEnrichmentException.snapshot('current_depth_jobs');
  }
  final rows =
      <({int depth, List<Object> path, List<Object> provenance, String id})>[];
  for (final value in jobs) {
    final object = _snapshotObject(value, 'current_depth_job');
    rows.add((
      depth: _positiveSnapshotInt(object, 'stage_depth'),
      path: _typedOrderComponents(
        _snapshotList(object['parent_ast_path'], 'parent_ast_path'),
      ),
      provenance: _typedOrderComponents(
        _snapshotList(object['provenance_order'], 'provenance_order'),
      ),
      id: _requiredSnapshotString(object, 'job_id'),
    ));
  }
  rows.sort((left, right) {
    var order = left.depth.compareTo(right.depth);
    order = order != 0 ? order : _compareComponents(left.path, right.path);
    order = order != 0
        ? order
        : _compareComponents(left.provenance, right.provenance);
    return order != 0 ? order : _compareUnicodeScalarStrings(left.id, right.id);
  });
  return <String>[for (final row in rows) row.id];
}

_PreparedPlan _preparePlan(
  FrozenStagedRegistry registry,
  _DiscoveredMarker discovered,
  _EnrichmentOptions options,
) {
  final sidecar = _markerSidecar(discovered.marker);
  final parserSpecId = _requiredSidecarString(sidecar, 'parser_spec_id');
  final provisionalTop = sidecar['top_rule'] is String
      ? sidecar['top_rule']! as String
      : '<unresolved-default>';
  final provisionalJobId = stagedJobIdentity(
    _jobFields(
      options.declaringSpecId,
      discovered.path,
      sidecar,
      provisionalTop,
    ),
  );
  final resolvedSpecId = registry.resolvePreRegistered(
    declaringSpecId: options.declaringSpecId,
    parserSpecId: parserSpecId,
    jobId: provisionalJobId,
  );
  final entry = registry.entries[resolvedSpecId]!;
  final topRule = sidecar['top_rule'] is String
      ? sidecar['top_rule']! as String
      : entry.defaultTopRule;
  final jobId = stagedJobIdentity(
    _jobFields(options.declaringSpecId, discovered.path, sidecar, topRule),
  );
  final requiredPolicyModes = <String>{
    _requiredSidecarString(sidecar, 'result_policy'),
    _requiredSidecarString(sidecar, 'failure_policy'),
  };
  final effective = registry._effectiveAuthority(
    entryId: resolvedSpecId,
    topRule: topRule,
    jobId: jobId,
    requirements: _AuthorityRequirements(
      callerCapabilities: options.callerCapabilities,
      requiredCapabilities: _stringSet(
        sidecar['required_capabilities'],
        'required_capabilities',
        allowEmpty: true,
      ),
      callerPolicyModes: options.callerPolicyModes,
      requiredPolicyModes: requiredPolicyModes,
      callerCeilings: options.callerCeilings,
      requiredSourceDetail: options.requiredSourceDetail,
      requiredVersions: options.requiredVersions,
    ),
  );
  final cacheKey = stagedCacheIdentity(<String, Object?>{
    'normalized_spec_id': resolvedSpecId,
    'content_digest': entry.contentDigest,
    'import_graph_fingerprint': entry.importGraphFingerprint,
    'top_rule': topRule,
    'spec_language_version': entry.versions.specLanguageVersion,
    'helper_contract_version': entry.versions.helperContractVersion,
    'staged_contract_version': entry.versions.stagedContractVersion,
    'backend_capabilities': effective['capabilities'],
  });
  final prepared = _copyRecord(sidecar)
    ..addAll(<String, Object?>{
      'state': 'prepared',
      'declaring_spec_id': options.declaringSpecId,
      'parent_ast_path': <Object?>[...discovered.path],
      'resolved_spec_id': resolvedSpecId,
      'top_rule': topRule,
      'job_id': jobId,
      'cache_key': cacheKey,
      'stage_depth': 1,
      'stage_chain': <Object?>[],
      'effective': _copyRecord(effective),
    });
  return _PreparedPlan(
    path: List<Object?>.unmodifiable(discovered.path),
    marker: _copyRecord(discovered.marker),
    sidecar: prepared,
    resolvedSpecId: resolvedSpecId,
    topRule: topRule,
    cacheKey: cacheKey,
    effective: effective,
    provenanceOrder: _provenanceOrder(prepared['provenance']),
  );
}

Map<String, Object?> _childRequest(_PreparedPlan plan) {
  final sidecar = plan.sidecar;
  return _copyRecord(<String, Object?>{
    'stage_depth': sidecar['stage_depth'],
    'stage_chain': sidecar['stage_chain'],
    'job_id': sidecar['job_id'],
    'parent_ast_path': sidecar['parent_ast_path'],
    'node_kind': sidecar['node_kind'],
    'payload_kind': sidecar['payload_kind'],
    'parser_spec_id': sidecar['parser_spec_id'],
    'resolved_spec_id': sidecar['resolved_spec_id'],
    'top_rule': sidecar['top_rule'],
    'text': sidecar['text'],
    'source_provenance': sidecar['provenance'],
    'result_policy': sidecar['result_policy'],
    'failure_policy': sidecar['failure_policy'],
    'effective': sidecar['effective'],
  });
}

Object? _settleFailure(
  Object? working,
  _PreparedPlan plan,
  Map<String, Object?> diagnostic,
  List<Map<String, Object?>> diagnostics,
) {
  final owned = _copyRecord(diagnostic);
  diagnostics.add(owned);
  plan.sidecar['diagnostic'] = _copyRecord(owned);
  switch (plan.sidecar['failure_policy']) {
    case 'fail':
      throw StagedAstEnrichmentException._(
        owned['code']! as String,
        owned['phase']! as String,
        <String, Object?>{
          for (final entry in owned.entries)
            if (entry.key != 'code' && entry.key != 'phase')
              entry.key: entry.value,
        },
      );
    case 'keep_text':
      plan.sidecar['state'] = 'failed_keep_text';
      return _materializeMarkerText(working, plan);
    case 'diagnostic_node':
      plan.sidecar['state'] = 'failed_diagnostic_node';
      return _stitchValue(working, plan, <String, Object?>{
        'kind': 'staged_parse_diagnostic',
        'diagnostic': _copyRecord(owned),
      });
    default:
      throw _markerError('staged_failure_policy_invalid', plan.sidecar);
  }
}

Map<String, Object?> _childFailureDiagnostic(
  Map<String, Object?> sidecar,
  Object? child,
) {
  final portable = _portableChildDiagnostic(child);
  return <String, Object?>{
    'code': 'staged_child_failed',
    'phase': 'execute',
    'stage_chain': _copyPlain(sidecar['stage_chain']),
    'job_id': sidecar['job_id'],
    'parent_ast_path': _copyPlain(sidecar['parent_ast_path']),
    'node_kind': sidecar['node_kind'],
    'payload_kind': sidecar['payload_kind'],
    'parser_spec_id': sidecar['parser_spec_id'],
    'resolved_spec_id': sidecar['resolved_spec_id'],
    'top_rule': sidecar['top_rule'],
    'cache_key': sidecar['cache_key'],
    'source_provenance': _copyPlain(sidecar['provenance']),
    'result_policy': sidecar['result_policy'],
    'failure_policy': sidecar['failure_policy'],
    'child_diagnostic': portable,
  };
}

Map<String, Object?> _portableChildDiagnostic(Object? value) {
  try {
    final detached = _detachPlain(value, maximum: 256, allowMarkers: false);
    if (detached.value is Map<String, Object?>) {
      return _copyRecord(detached.value! as Map<String, Object?>);
    }
  } on _DetachFailure {
    // Normalize all live, cyclic, or oversized child diagnostics below.
  }
  return <String, Object?>{'code': 'staged_child_exception'};
}

Object? _detachResult(
  Object? value, {
  required int maximum,
  required Map<String, Object?> sidecar,
}) {
  try {
    return _detachPlain(value, maximum: maximum, allowMarkers: true).value;
  } on _DetachFailure catch (failure) {
    if (failure.reason == 'node_limit') {
      throw _DetachedResultFailure(<String, Object?>{
        'code': 'staged_result_node_limit_exceeded',
        'phase': 'execute',
        'stage_chain': _copyPlain(sidecar['stage_chain']),
        'job_id': sidecar['job_id'],
        'nodes': failure.nodes,
        'maximum': maximum,
      });
    }
    throw _DetachedResultFailure(<String, Object?>{
      'code': 'staged_result_not_detached',
      'phase': 'execute',
      'stage_chain': _copyPlain(sidecar['stage_chain']),
      'job_id': sidecar['job_id'],
      'field': failure.reason,
    });
  }
}

final class _DetachedResultFailure implements Exception {
  const _DetachedResultFailure(this.diagnostic);

  final Map<String, Object?> diagnostic;
}

final class _DetachFailure implements Exception {
  const _DetachFailure(this.nodes, this.reason);

  final int nodes;
  final String reason;
}

({Object? value, int nodes}) _detachPlain(
  Object? value, {
  required int maximum,
  required bool allowMarkers,
}) {
  var nodes = 0;
  final active = HashSet<Object>.identity();

  Object? walk(Object? current, String path) {
    nodes += 1;
    if (nodes > maximum) {
      throw _DetachFailure(nodes, 'node_limit');
    }
    if (current == null || current is bool || current is String) {
      return current;
    }
    if (current is num) {
      if (current.isFinite) {
        return current;
      }
      throw _DetachFailure(nodes, path);
    }
    if (current is List) {
      if (!active.add(current)) {
        throw _DetachFailure(nodes, path);
      }
      try {
        return <Object?>[
          for (var index = 0; index < current.length; index += 1)
            walk(current[index], '$path/$index'),
        ];
      } finally {
        active.remove(current);
      }
    }
    if (current is Map) {
      if (!active.add(current)) {
        throw _DetachFailure(nodes, path);
      }
      try {
        final copy = <String, Object?>{};
        for (final entry in current.entries) {
          final key = entry.key;
          if (key is! String) {
            throw _DetachFailure(nodes, path);
          }
          if ((!allowMarkers || !_isMarker(current)) &&
              _liveResultKeys.contains(key)) {
            throw _DetachFailure(nodes, '$path/$key');
          }
          copy[key] = walk(entry.value, '$path/$key');
        }
        return copy;
      } finally {
        active.remove(current);
      }
    }
    throw _DetachFailure(nodes, path);
  }

  return (value: walk(value, '<result>'), nodes: nodes);
}

Object? _copyAst(Object? value) {
  try {
    return _detachPlain(value, maximum: 1 << 30, allowMarkers: true).value;
  } on _DetachFailure {
    throw StagedAstEnrichmentException.snapshot('parent_ast');
  }
}

void _discoverMarkers(
  Object? value,
  List<Object?> path,
  List<_DiscoveredMarker> found,
) {
  if (_isMarker(value)) {
    found.add(
      _DiscoveredMarker(
        path: List<Object?>.unmodifiable(path),
        marker: _copyRecord((value! as Map).cast<String, Object?>()),
      ),
    );
    return;
  }
  if (value is Map<String, Object?>) {
    for (final entry in value.entries) {
      _discoverMarkers(entry.value, <Object?>[...path, entry.key], found);
    }
  } else if (value is List) {
    for (var index = 0; index < value.length; index += 1) {
      _discoverMarkers(value[index], <Object?>[...path, index], found);
    }
  }
}

Map<String, Object?> _markerSidecar(Map<String, Object?> marker) {
  if (!_isMarker(marker)) {
    throw StagedAstEnrichmentException.snapshot('marker');
  }
  final sidecar = _copyRecord(
    (marker[_sidecarKind]! as Map).cast<String, Object?>(),
  );
  if (sidecar['kind'] != _sidecarKind ||
      sidecar['version'] != 2 ||
      sidecar['state'] != 'declared') {
    throw StagedAstEnrichmentException.snapshot('sidecar');
  }
  return sidecar;
}

bool _isMarker(Object? value) =>
    value is Map &&
    value['kind'] == _markerKind &&
    value['version'] == 2 &&
    value['sidecar_kind'] == _sidecarKind &&
    value[_sidecarKind] is Map;

Map<String, Object?> _jobFields(
  String declaringSpecId,
  List<Object?> path,
  Map<String, Object?> sidecar,
  String topRule,
) {
  final nodeKind = _requiredSidecarString(sidecar, 'node_kind');
  final payloadKind = _requiredSidecarString(sidecar, 'payload_kind');
  final parserSpecId = _requiredSidecarString(sidecar, 'parser_spec_id');
  if (topRule != '<unresolved-default>' && !_validTopRule(topRule)) {
    throw _markerError('staged_top_rule_invalid', sidecar);
  }
  return <String, Object?>{
    'declaring_spec_id': declaringSpecId,
    'parent_ast_path': <Object?>[...path],
    'node_kind': nodeKind,
    'payload_kind': payloadKind,
    'parser_spec_id': parserSpecId,
    'top_rule': topRule,
    'provenance': _copyPlain(sidecar['provenance']),
  };
}

void _validateStitchTarget(Object? ast, _PreparedPlan plan) {
  final actual = _valueAt(ast, plan.path);
  if (actual == _missing ||
      !_isMarker(actual) ||
      !_deepEqual(actual, plan.marker)) {
    throw _stitchError(plan, 'staged_marker_mismatch', <String, Object?>{
      'actual_marker': _markerDiagnostic(actual),
    });
  }
  final policy = plan.sidecar['result_policy'];
  if (policy == 'replace_marker') {
    return;
  }
  final into = plan.sidecar['into'];
  final parent = _parentAt(ast, plan.path);
  if (into is! String || into.isEmpty || parent is! Map<String, Object?>) {
    throw _stitchError(plan, 'staged_stitch_target_missing', <String, Object?>{
      'into': into ?? '<missing>',
    });
  }
  switch (policy) {
    case 'replace_field' when !parent.containsKey(into):
      throw _stitchError(
        plan,
        'staged_stitch_target_missing',
        <String, Object?>{'into': into},
      );
    case 'sibling_field' when parent.containsKey(into):
      throw _stitchError(
        plan,
        'staged_stitch_target_collision',
        <String, Object?>{'into': into},
      );
    case 'append_child' when parent[into] is! List:
      throw _stitchError(
        plan,
        'staged_append_target_invalid',
        <String, Object?>{'into': into},
      );
    case 'replace_field' || 'sibling_field' || 'append_child':
      return;
    default:
      throw _markerError('staged_result_policy_invalid', plan.sidecar);
  }
}

Object? _stitchValue(Object? ast, _PreparedPlan plan, Object? result) {
  _validateStitchTarget(ast, plan);
  final policy = plan.sidecar['result_policy']! as String;
  if (policy == 'replace_marker') {
    return _setAt(ast, plan.path, result);
  }
  final textAst = _setAt(ast, plan.path, plan.sidecar['text']);
  final parent = _parentAt(textAst, plan.path)! as Map<String, Object?>;
  final into = plan.sidecar['into']! as String;
  switch (policy) {
    case 'replace_field' || 'sibling_field':
      parent[into] = result;
    case 'append_child':
      (parent[into]! as List).add(result);
  }
  return textAst;
}

Object? _materializeMarkerText(Object? ast, _PreparedPlan plan) {
  _validateStitchTarget(ast, plan);
  return _setAt(ast, plan.path, plan.sidecar['text']);
}

const _missing = Object();

Object? _valueAt(Object? root, List<Object?> path) {
  var current = root;
  for (final component in path) {
    if (component is String && current is Map<String, Object?>) {
      if (!current.containsKey(component)) {
        return _missing;
      }
      current = current[component];
    } else if (component is int &&
        component >= 0 &&
        current is List &&
        component < current.length) {
      current = current[component];
    } else {
      return _missing;
    }
  }
  return current;
}

Object? _parentAt(Object? root, List<Object?> path) {
  if (path.isEmpty) {
    return null;
  }
  return _valueAt(root, path.sublist(0, path.length - 1));
}

Object? _setAt(Object? root, List<Object?> path, Object? replacement) {
  if (path.isEmpty) {
    return replacement;
  }
  final parent = _parentAt(root, path);
  final component = path.last;
  if (component is String && parent is Map<String, Object?>) {
    if (!parent.containsKey(component)) {
      return root;
    }
    parent[component] = replacement;
    return root;
  }
  if (component is int &&
      component >= 0 &&
      parent is List &&
      component < parent.length) {
    parent[component] = replacement;
    return root;
  }
  return root;
}

int _comparePlans(_PreparedPlan left, _PreparedPlan right) {
  var order = _compareComponents(
    _typedOrderComponents(left.path),
    _typedOrderComponents(right.path),
  );
  order = order != 0
      ? order
      : _compareComponents(left.provenanceOrder, right.provenanceOrder);
  return order != 0
      ? order
      : _compareUnicodeScalarStrings(
          left.sidecar['job_id']! as String,
          right.sidecar['job_id']! as String,
        );
}

List<Object> _provenanceOrder(Object? value) {
  final object = _snapshotObject(value, 'provenance');
  final segments = object['kind'] == 'direct_span'
      ? <Object?>[object]
      : _snapshotList(object['segments'], 'provenance');
  final order = <Object>[];
  for (final value in segments) {
    final segment = _snapshotObject(value, 'provenance');
    final sourceId = segment['source_id'];
    final start = segment['start'];
    final end = segment['end'];
    final provenance = segment['provenance'];
    if (sourceId is! String ||
        sourceId.isEmpty ||
        start is! int ||
        start < 0 ||
        end is! int ||
        end < start ||
        provenance is! String ||
        provenance.isEmpty) {
      throw StagedAstEnrichmentException.snapshot('provenance');
    }
    order.addAll(<Object>[sourceId, start, end, provenance]);
  }
  return order;
}

List<Object> _typedOrderComponents(Iterable<Object?> values) {
  final result = <Object>[];
  for (final value in values) {
    if (value is String || (value is int && value >= 0)) {
      result.add(value!);
    } else {
      throw StagedAstEnrichmentException.snapshot('typed_order_component');
    }
  }
  return result;
}

int _compareComponents(List<Object> left, List<Object> right) {
  final length = math.min(left.length, right.length);
  for (var index = 0; index < length; index += 1) {
    final a = left[index];
    final b = right[index];
    int order;
    if (a is String && b is String) {
      order = _compareUnicodeScalarStrings(a, b);
    } else if (a is int && b is int) {
      order = a.compareTo(b);
    } else {
      order = a is String ? -1 : 1;
    }
    if (order != 0) {
      return order;
    }
  }
  return left.length.compareTo(right.length);
}

int _compareUnicodeScalarStrings(String left, String right) {
  final a = left.runes.iterator;
  final b = right.runes.iterator;
  while (true) {
    final hasA = a.moveNext();
    final hasB = b.moveNext();
    if (!hasA || !hasB) {
      return hasA == hasB ? 0 : (hasA ? 1 : -1);
    }
    final order = a.current.compareTo(b.current);
    if (order != 0) {
      return order;
    }
  }
}

Map<String, Object?> _exactObject(
  Object? value,
  List<String> expected,
  String component,
) {
  final object = _snapshotObject(value, component);
  if (object.length != expected.length ||
      expected.any((field) => !object.containsKey(field))) {
    throw StagedAstEnrichmentException.snapshot(component);
  }
  return object;
}

Map<String, Object?> _snapshotObject(Object? value, String component) {
  if (value is! Map) {
    throw StagedAstEnrichmentException.snapshot(component);
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw StagedAstEnrichmentException.snapshot(component);
    }
    result[entry.key! as String] = entry.value;
  }
  return result;
}

List<Object?> _snapshotList(Object? value, String component) {
  if (value is! List) {
    throw StagedAstEnrichmentException.snapshot(component);
  }
  return <Object?>[...value];
}

String _requiredSnapshotString(Map<String, Object?> object, String field) {
  final value = object[field];
  if (value is! String || value.isEmpty) {
    throw StagedAstEnrichmentException.snapshot(field);
  }
  return value;
}

String _requiredSidecarString(Map<String, Object?> sidecar, String field) {
  final value = sidecar[field];
  if (value is! String || value.isEmpty) {
    throw _markerError('staged_registry_snapshot_invalid', sidecar);
  }
  return value;
}

String _requiredTopRule(Map<String, Object?> object, String field) {
  final value = _requiredSnapshotString(object, field);
  if (!_validTopRule(value)) {
    throw StagedAstEnrichmentException.snapshot(field);
  }
  return value;
}

String _requiredDigest(Map<String, Object?> object, String field) {
  final value = _requiredSnapshotString(object, field);
  if (!_validDigest(value)) {
    throw StagedAstEnrichmentException.snapshot(field);
  }
  return value;
}

int _positiveSnapshotInt(Map<String, Object?> object, String field) {
  final value = object[field];
  if (value is! int || value <= 0) {
    throw StagedAstEnrichmentException.snapshot(field);
  }
  return value;
}

Set<String> _snapshotStringSet(Object? value, String component) {
  try {
    return _stringSet(value, component);
  } on StagedAstEnrichmentException {
    rethrow;
  } on Object {
    throw StagedAstEnrichmentException.snapshot(component);
  }
}

Set<String> _stringSet(
  Object? value,
  String component, {
  bool allowEmpty = false,
}) {
  if (value is! List ||
      (!allowEmpty && value.isEmpty) ||
      value.any((item) => item is! String || item.isEmpty)) {
    throw StagedAstEnrichmentException.snapshot(component);
  }
  final values = <String>[for (final item in value) item! as String];
  if (values.toSet().length != values.length) {
    throw StagedAstEnrichmentException.snapshot(component);
  }
  return Set<String>.unmodifiable(values);
}

List<String> _stringList(Object? value, String component) =>
    _stringSet(value, component).toList()..sort(_compareUnicodeScalarStrings);

_Ceilings _parseCeilings(Object? value, String component) {
  final object = _snapshotObject(value, component);
  final sourceDetail = _requiredSnapshotString(object, 'source_detail');
  _sourceDetailRank(sourceDetail);
  return _Ceilings(
    sourceDetail: sourceDetail,
    maxSteps: _positiveSnapshotInt(object, 'max_steps'),
    maxResultNodes: _positiveSnapshotInt(object, 'max_result_nodes'),
    maxDiagnosticBytes: _positiveSnapshotInt(object, 'max_diagnostic_bytes'),
  );
}

_Versions _parseVersions(Object? value, String component) {
  final object = _snapshotObject(value, component);
  return _Versions(
    specLanguageVersion: _positiveSnapshotInt(object, 'spec_language_version'),
    helperContractVersion: _requiredSnapshotString(
      object,
      'helper_contract_version',
    ),
    stagedContractVersion: _positiveSnapshotInt(
      object,
      'staged_contract_version',
    ),
  );
}

List<_DirectCandidate> _directCandidates(
  Object? value,
  Map<String, _RegistryEntry> entries,
  String component,
) {
  final rows = <_DirectCandidate>[];
  for (final value in _snapshotList(value, component)) {
    final row = _snapshotObject(value, component);
    final declaringSpecId = _requiredSnapshotString(row, 'declaring_spec_id');
    final authoredId = _requiredSnapshotString(row, 'authored_id');
    final resolvedSpecId = _requiredSnapshotString(row, 'resolved_spec_id');
    if (!_validParserIdentity(declaringSpecId) ||
        !_validParserIdentity(authoredId) ||
        !entries.containsKey(resolvedSpecId)) {
      throw StagedAstEnrichmentException.snapshot(component);
    }
    rows.add(
      _DirectCandidate(
        declaringSpecId: declaringSpecId,
        authoredId: authoredId,
        resolvedSpecId: resolvedSpecId,
      ),
    );
  }
  return List<_DirectCandidate>.unmodifiable(rows);
}

List<_OrderedCandidates> _orderedCandidates(
  Object? value,
  Map<String, _RegistryEntry> entries, {
  required String identityField,
  required String component,
}) {
  final rows = <_OrderedCandidates>[];
  final orders = <int>{};
  for (final value in _snapshotList(value, component)) {
    final row = _snapshotObject(value, component);
    final identity = _requiredSnapshotString(row, identityField);
    final order = _positiveSnapshotInt(row, 'order');
    if (!orders.add(order)) {
      throw StagedAstEnrichmentException.snapshot(component);
    }
    final candidates = <_Candidate>[];
    for (final candidateValue in _snapshotList(
      row['candidates'],
      'candidates',
    )) {
      final candidate = _snapshotObject(candidateValue, 'candidates');
      final authoredId = _requiredSnapshotString(candidate, 'authored_id');
      final resolvedSpecId = _requiredSnapshotString(
        candidate,
        'resolved_spec_id',
      );
      if (!_validParserIdentity(authoredId) ||
          !entries.containsKey(resolvedSpecId)) {
        throw StagedAstEnrichmentException.snapshot(component);
      }
      candidates.add(
        _Candidate(authoredId: authoredId, resolvedSpecId: resolvedSpecId),
      );
    }
    rows.add(
      _OrderedCandidates(
        identity: identity,
        order: order,
        candidates: List<_Candidate>.unmodifiable(candidates),
      ),
    );
  }
  rows.sort((left, right) => left.order.compareTo(right.order));
  return List<_OrderedCandidates>.unmodifiable(rows);
}

List<String> _directMatches(
  List<_DirectCandidate> candidates,
  String declaringSpecId,
  String parserSpecId,
) => <String>[
  for (final candidate in candidates)
    if (candidate.declaringSpecId == declaringSpecId &&
        candidate.authoredId == parserSpecId)
      candidate.resolvedSpecId,
];

int _sourceDetailRank(String value) {
  final index = _sourceDetails.indexOf(value);
  if (index < 0) {
    throw StagedAstEnrichmentException.snapshot('source_detail');
  }
  return index;
}

StagedAstEnrichmentException _markerError(
  String code,
  Map<String, Object?> sidecar,
) => StagedAstEnrichmentException._(code, 'prepare', <String, Object?>{
  'origin': sidecar['origin'] ?? '<marker>',
});

StagedAstEnrichmentException _stitchError(
  _PreparedPlan plan,
  String code,
  Map<String, Object?> fields,
) => StagedAstEnrichmentException._(code, 'stitch', <String, Object?>{
  'stage_chain': _copyPlain(plan.sidecar['stage_chain']),
  'job_id': plan.sidecar['job_id'],
  'parent_ast_path': <Object?>[...plan.path],
  ...fields,
});

StagedAstEnrichmentException _cacheIdentityError(
  Object? fields,
  String component,
) => StagedAstEnrichmentException._(
  'staged_cache_identity_invalid',
  'compile',
  <String, Object?>{
    'job_id': '<cache-identity>',
    'resolved_spec_id': fields is Map
        ? fields['normalized_spec_id'] ?? '<invalid>'
        : '<invalid>',
    'cache_component': component,
  },
);

Object _markerDiagnostic(Object? value) {
  if (value == _missing) {
    return '<missing>';
  }
  if (value is Map) {
    return <String, Object?>{
      'kind': value['kind'],
      'version': value['version'],
    };
  }
  return value?.runtimeType.toString() ?? 'null';
}

bool _validParserIdentity(String value) {
  if (value.isEmpty || value.startsWith('/') || value.contains('..')) {
    return false;
  }
  var segmentStart = true;
  for (final rune in value.runes) {
    final character = String.fromCharCode(rune);
    if ('. _:/-'.replaceAll(' ', '').contains(character)) {
      if (segmentStart) {
        return false;
      }
      segmentStart = true;
    } else if (_isAsciiLower(rune) || (!segmentStart && _isAsciiDigit(rune))) {
      segmentStart = false;
    } else {
      return false;
    }
  }
  return !segmentStart;
}

bool _validTopRule(String value) =>
    RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value);

bool _validDigest(String value) =>
    RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(value);

bool _isAsciiLower(int rune) => rune >= 0x61 && rune <= 0x7a;

bool _isAsciiDigit(int rune) => rune >= 0x30 && rune <= 0x39;

String _digest(Object? value) =>
    'sha256:${sha256Hex(utf8.encode(jsonEncode(_canonicalValue(value))))}';

Object? _canonicalValue(Object? value) {
  final active = HashSet<Object>.identity();

  Object? walk(Object? current) {
    if (current is List) {
      if (!active.add(current)) {
        throw StagedAstEnrichmentException.snapshot('canonical_json');
      }
      try {
        return <Object?>[for (final item in current) walk(item)];
      } finally {
        active.remove(current);
      }
    }
    if (current is Map) {
      if (!active.add(current)) {
        throw StagedAstEnrichmentException.snapshot('canonical_json');
      }
      try {
        final keys = <String>[];
        for (final key in current.keys) {
          if (key is! String) {
            throw StagedAstEnrichmentException.snapshot('canonical_json');
          }
          keys.add(key);
        }
        keys.sort(_compareUnicodeScalarStrings);
        return <String, Object?>{
          for (final key in keys) key: walk(current[key]),
        };
      } finally {
        active.remove(current);
      }
    }
    if (current == null || current is bool || current is String) {
      return current;
    }
    if (current is num && current.isFinite) {
      return current;
    }
    throw StagedAstEnrichmentException.snapshot('canonical_json');
  }

  return walk(value);
}

Object? _copyPlain(Object? value) {
  final active = HashSet<Object>.identity();

  Object? walk(Object? current) {
    if (current is List) {
      if (!active.add(current)) {
        throw StagedAstEnrichmentException.snapshot('plain_value');
      }
      try {
        return <Object?>[for (final item in current) walk(item)];
      } finally {
        active.remove(current);
      }
    }
    if (current is Map) {
      if (!active.add(current)) {
        throw StagedAstEnrichmentException.snapshot('plain_value');
      }
      try {
        final copy = <String, Object?>{};
        for (final entry in current.entries) {
          final key = entry.key;
          if (key is! String) {
            throw StagedAstEnrichmentException.snapshot('plain_value');
          }
          copy[key] = walk(entry.value);
        }
        return copy;
      } finally {
        active.remove(current);
      }
    }
    if (current == null || current is bool || current is String) {
      return current;
    }
    if (current is num && current.isFinite) {
      return current;
    }
    throw StagedAstEnrichmentException.snapshot('plain_value');
  }

  return walk(value);
}

Map<String, Object?> _copyRecord(Map<String, Object?> value) =>
    (_copyPlain(value)! as Map).cast<String, Object?>();

bool _deepEqual(Object? left, Object? right) {
  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (!_deepEqual(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_deepEqual(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}

bool _sameStringLists(List<String> left, List<String> right) {
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
