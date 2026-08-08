---
id: typed-source-location-runtime-rollout-plan
title: Typed source values use separate source authority and preserve helper results across admitted runtimes
answers:
  - "how will the six LinkedSpec runtimes implement typed positions and spans"
  - "does typed source location replace byte or code unit runtime cursors"
  - "where is decoded source text stored for an immutable span"
  - "does a LinkedSpec span embed copied source text or a host reference"
  - "will current capture mark entry match input and cursor helpers return new objects"
  - "which typed source location diagnostics belong to FUTURE PARITY BACKLOG 14.2"
  - "is generated source identity the same as input source identity"
  - "which backend files will implement typed source location"
  - "why were public_structure and neutral_public_recomposition still pending"
  - "is typed source location rollout immutable planning data or live admission state"
  - "which task leaves admit Perl Rust Dart Julia PUC Lua and LuaJIT typed values"
  - "does typed source location require a descriptor schema change"
  - "what exact internal API does the Perl typed source location RED consumer require"
  - "which Perl test consumes all typed source location values and diagnostics"
  - "which ActionIR interface binds the 92 Perl typed source helper projections"
  - "why are the Perl typed source location consumers not registered yet"
  - "is the immutable Perl typed source location value core implemented"
  - "how does Perl keep decoded text out of typed source values"
  - "how does Perl enforce typed source value immutability"
  - "does the Perl typed source value core route ActionIR helpers yet"
  - "where is the Perl runtime typed source authority initialized and propagated"
  - "do Perl typed source projections replace scalar mark and cursor storage"
  - "are all 92 Perl typed source helper projections implemented"
  - "does Perl generated source use the same typed source projection route"
  - "is the Perl typed source location runtime canonically admitted"
  - "what is the current typed source location rollout count"
  - "where is the dormant Rust typed source location RED consumer"
  - "why does the Rust typed source location test run zero tests ordinarily"
  - "what is the first Rust typed source location compile failure"
  - "is the immutable Rust typed source location value core implemented"
  - "does the Rust typed source value core route helpers or admit runtime support"
  - "where does Rust store decoded text for typed positions and spans"
  - "are all 92 Rust typed source helper projections implemented"
  - "does Rust typed source projection change byte cursor or mark registers"
  - "does Rust typed source projection run on reconstructed and generated plans"
  - "is the Rust typed source location runtime canonically admitted"
  - "what canonical command runs the Rust typed source location consumer"
  - "are all 92 Dart source boundary helpers implemented"
  - "does Dart execute the seven typed source compatibility aliases"
  - "what error do Dart source boundary compatibility aliases return"
  - "why must Dart alias parity precede the typed source RED"
  - "where does Dart store source cursor mark and match offsets"
  - "do Dart generated and emitted parsers use the same helper interpreter"
  - "where is the admitted Dart typed source location consumer"
  - "does ordinary Dart test discovery run the typed source location consumer"
  - "what is the first Dart typed source location load failure"
  - "is the immutable Dart typed source location value core implemented"
  - "does the Dart typed source value core route helpers or admit runtime support"
  - "where does Dart store decoded text for typed positions and spans"
  - "how does Dart convert UTF-16 code units to Unicode scalar positions"
  - "are all 92 Dart typed source helper projections implemented"
  - "does Dart typed source projection change UTF-16 cursor or mark registers"
  - "does Dart typed source projection run on reconstructed generated and emitted parsers"
  - "is the Dart typed source location runtime canonically admitted"
  - "are all 92 Julia source boundary helpers implemented"
  - "does Julia execute the seven typed source compatibility aliases"
  - "what error do Julia source boundary compatibility aliases return"
  - "why must Julia alias parity precede the typed source RED"
  - "where does Julia store source cursor mark and match offsets"
  - "do Julia loaded generated and emitted parsers use the same helper interpreter"
  - "where is the dormant Julia typed source location RED consumer"
  - "why does ordinary Julia test discovery omit the typed source location consumer"
  - "what is the first Julia typed source location RED failure"
  - "why is Julia typed source location a private namespace"
  - "what Julia projection API becomes the next RED after the immutable core"
date: 2026-08-01
status: Perl, Rust, and Dart runtimes admitted; Julia, PUC Lua, and LuaJIT pending
tags: [architecture, source-location, spans, cursor, helpers, perl, rust, dart, julia, lua, rollout]
evidence: "FUTURE-PARITY-BACKLOG.14.2.0 retrieved ADR 0056, the neutral contract/checker, adjacent live-ledger contracts, TOOLBOX.md, and exact runtime source/test authorities. Perl uses decoded-string scalar offsets; Rust and Lua use UTF-8 bytes; Dart and Julia use code units. Complete named-mark consumers pass on all six runtimes. The exact contract/checker still encode completed public owners .14.1.2-.3 as pending because both leaves explicitly excluded contract changes, leaving no promotion owner. ADR 0056 section 9 and the owning task freeze the correction and implementation order."
evidence_update_2026_08_01_public_rollout: "Correction .14.2.0.1 promotes completed public owners .14.1.2-.3, re-owners runtime admissions to .14.2.1.3-.14.2.5.3, advances current truth to 3 complete / 11 pending, and locks 37 mutations including two independent completed-to-pending regressions."
evidence_update_2026_08_01_perl_red: "Perl authority/RED .14.2.1.0 freezes two unregistered consumers without implementation. typed_source_location_values.t requires LinkedSpec::SourceLocation authority plus immutable Position/Span/DerivedText values, coordinates/materialization, detached records, and the four value errors across all 3/7/6/3 fixtures. typed_source_location_perl_contract.t requires ActionIR::Contracts::typed_source_projection_rows, exact 92-row routing, seven aliases, and unchanged live/generated named-mark results. The first exits only for the missing module; the second has one failure naming only the missing catalog."
evidence_update_2026_08_01_perl_core: "Perl core .14.2.1.1 adds SourceLocation.pm. Module-private authority state snapshots decoded text and precomputes scalar-boundary line/column/UTF-8-byte evidence; monotonic authority ids plus module-private value state keep Position, Span, and DerivedText records immutable and free of text/host references. The authority alone validates, derives coordinates, and materializes direct or ordered derived text. All value fixtures and four locked structured errors pass; the projection consumer still has exactly one failure for absent typed_source_projection_rows. Definitive canonical CI passes CLI 66/66 twice, RAM 47%, and Phase 0 1,031/1,031 in 633 seconds."
evidence_update_2026_08_01_perl_projections: "Perl projection .14.2.1.2 initializes one input authority in every SpecEntry handler, propagates it through LinkedRE child match info, and routes the exact detached 92-row/four-family catalog plus seven aliases through SourceLocation::Runtime. Typed positions/spans validate and materialize source text, coordinates, mark reads/writes, capture boundaries, and cursor operations while external scalar/string/list/map/boolean/absence results and scalar mark/cursor storage remain unchanged. RuleIR, both handler IMATCH bridges, nested MethodLowering expressions, live execution, and independently emitted/loaded source share the route. The unregistered projection consumer passes all 3 top-level and 202 nested assertions; focused baselines pass 423/423. Definitive canonical CI passes repository containment, moved-root/outside-CWD execution, composed semantic/MCP admissions, CLI 66/66 twice, RAM 53%, and Phase 0 1,031/1,031 in 651 seconds before the explicit pass marker. Admission and public support remain pending under .14.2.1.3."
evidence_update_2026_08_01_perl_admission: "Perl admission .14.2.1.3 requires, syntax-checks, and unconditionally executes both committed consumers in canonical CI. Their composed run passes 10 tests across the exact immutable values, 92 helpers plus seven aliases, and live plus independently emitted/loaded generated routes. The neutral artifact/checker promotes only perl_runtime, advances live truth to 4 complete / 10 pending, and rejects 38 mutations including an independent Perl complete-to-pending regression. The sole-facing capture, project-status, local-CI, and backend-handoff pages distinguish admitted internal Perl values/projections from absent authored Position/Span values, transactions, and the five pending runtimes. No production code, external helper result, scalar mark/cursor storage, schema/identity, semantic/MCP state, DSL/facade, or root README changes. Definitive canonical CI passes all seven doctrines, containment/relocation, CLI 66/66 twice, RAM 53%, and Phase 0 1,031/1,031 in 650 seconds."
evidence_update_2026_08_07_rust_prerequisites: "Rust authority audit .14.2.2.0 finds all 92 canonical helpers but only two of seven callable aliases. Five documented aliases compile and return JSON null while Perl executes canonical behavior. The director requires Perl-equivalent Rust results. The audit also proves neutral mappings capture_from_rule_start->capture_from and capture_len_from_rule_start->capture_len_from are arity/authority wrong: exact Perl and mdBook owners require capture_slice and capture_slice_len. Children .0.1 neutral correction, .0.2 Rust parity, and .0.3 typed RED now precede Rust core/projection/admission."
evidence_update_2026_08_07_neutral_alias_correction: "Neutral prerequisite .14.2.2.0.1 corrects exactly those two compatibility mappings to capture_slice and capture_slice_len. The executable checker now proves canonical Perl diag_name, IR-node, and ordered runtime-call equivalence for non-scanner aliases and rejects the old named-mark target as one of the unchanged 38 mutations. Rollout remains 4 complete / 10 pending; no backend runtime or mdBook behavior changes."
evidence_update_2026_08_07_rust_alias_parity: "Rust prerequisite .14.2.2.0.2 routes the five missing compatibility spellings through the existing canonical Engine arms and trace classifier. One RED/GREEN consumer proves Unicode widths, boundary mutation, reversed-span undef, and alias/canonical equality across native, reconstructed, generated-plan, and independently compiled emitted source. Rust now executes all seven aliases, but typed-source rollout intentionally remains 4 complete / 10 pending until Rust admission .14.2.2.3."
evidence_update_2026_08_07_rust_red: "Rust RED .14.2.2.0.3 adds tests/typed_source_location_contract.rs behind test-local linkedspec_typed_source_red, with projections independently nested behind linkedspec_typed_source_projection_red. Ordinary Cargo runs zero tests. The core cfg exits 101 with one E0432 solely for absent linkedspec_runtime::source_location. The consumer freezes 3/7/6/3 values, four private errors, exact 92+7 projections, Unicode byte-to-scalar conversion, mark isolation/absence, capture mutation, cursor restore, and native/reconstructed/generated shapes without production, manifest, neutral, rollout, schema, or mdBook behavior change. Complete Rust proof passes all tests, 105 corpus, generated-source, 17-owner storage, and CLI 66x2. Definitive CI passes all seven doctrines, semantic/MCP and containment/relocation proof, CLI 66x2, RAM 49%, and Phase 0 1,031/1,031 in 653 seconds."
evidence_update_2026_08_07_rust_core: "Rust core .14.2.2.1 adds linkedspec-runtime/src/source_location.rs. One non-cloneable authority owns copied decoded sources and scalar-boundary line/column/UTF-8-byte tables behind a monotonic opaque id. Private Position, Span, and DerivedText fields carry only identity, scalar offsets, provenance, and policy; detached JSON projections carry no text or host reference. The authority alone validates, derives coordinates, and materializes direct or concatenate-in-order text. Base cfg passes 2/2 over exact 3/7/6/3 fixtures and four errors; ordinary discovery stays zero-test; nested projection cfg has one E0432 naming only absent typed_source_compatibility_aliases and typed_source_projection_rows. No helper route or Rust runtime admission moves, so rollout remains 4/10/38 and the sole-facing book remains exact that Rust admission is pending. Complete Rust/corpus/generated/storage/CLI 66x2 proof passes. Definitive canonical CI passes all seven doctrines, process containment and relocated execution, CLI 66x2, RAM 53%, and Phase 0 1,031/1,031 in 653 seconds."
evidence_update_2026_08_07_rust_projections: "Rust projection .14.2.2.2 initializes one immutable input authority in RuntimeContext and shares it across context clones. Existing UTF-8-byte cursor, entry/match, mark, anonymous-boundary, and cursor-stack registers remain unchanged. Exact boundary methods convert bytes to scalar Position/Span values, validate and materialize text/coordinates/lengths, and preserve compatibility mutations; capture-group and existence/delete adapters retain the same detached pass-through shapes as Perl. Fresh catalogs expose all 92 rows in 47/30/11/4 families plus seven aliases. Nested cfg passes 4/4 across native, reconstructed, and generated-plan Unicode mark/capture/cursor behavior; core-only remains 2/2, ordinary discovery zero tests, dedicated alias carrier 1/1, and the complete Rust/corpus/generated/storage/CLI 66x2 gate passes. Definitive canonical CI passes all seven doctrines, process containment, relocated five-anchor execution, CLI 66x2, RAM 51%, and Phase 0 1,031/1,031 in 654 seconds. Registration and rust_runtime rollout promotion remain exclusively .14.2.2.3, so current truth stays 4/10/38."
evidence_update_2026_08_07_rust_admission: "Rust admission .14.2.2.3 removes only the two test-local custom-cfg guards, requires the committed consumer, and executes its exact ordinary Cargo target in canonical CI. All four tests cover immutable values plus the 92 canonical helpers and seven aliases across native, reconstructed, and generated-plan carriers. The neutral artifact/checker promotes only rust_runtime, advances truth to 5 complete / 9 pending, and rejects 39 mutations including an independent Rust complete-to-pending regression. Production helper behavior, UTF-8-byte registers, results, schemas, semantic/MCP surfaces, and public DSL remain unchanged."
evidence_update_2026_08_07_dart_prerequisites: "Dart authority audit .14.2.3.0 proves all 92 canonical source-boundary names are known, but all seven neutral aliases are absent from isKnownActionIrCallName and canonicalActionHelperName. Ordinary compiled invocation of each alias fails with structured unknown_helper at callable_codeblock_invocation under dart_runtime, while canonical capture_slice succeeds. Dart retains decoded input plus cursor/match/capture/mark/stack state as UTF-16 code-unit offsets and projects scalar positions, lengths, and one-based line/column at helper boundaries. Loaded, reconstructed, generated-plan, and emitted adapters converge on LinkedSpecRuntimeEngine. Alias parity .0.1 must precede dormant typed RED .0.2; the audit changes no production, neutral rollout, or book behavior."
evidence_update_2026_08_07_dart_prerequisites_signoff: "The behavior-free Dart audit passes focused 87, complete Dart format 95/0, fatal analysis, package 375, storage 19/47, CLI 66x2, corpus 105/105, Knowledge Map 786/6417, unchanged mdBook build, all seven doctrines, and definitive canonical capability 80/0/0, typed 5/9/39 plus Rust 4/4, containment/relocation, CLI 66x2, RAM 39%, and Phase 0 1031/1031 in 666 seconds."
evidence_update_2026_08_07_dart_alias_parity: "Dart prerequisite .14.2.3.0.1 adds the exact seven neutral compatibility names at the existing known-name/canonicalization seam and routes them only through capture_slice, capture_slice_len, capture_rest_len, start_capture_slice, entry_map, and match_map. No interpreter branch is added. One four-test consumer proves exact mapping/arity, structured unrelated unknown_helper diagnostics, Unicode text and scalar widths, anonymous-boundary mutation, reversed-span absence, named maps, and canonical equality across native, reconstructed, generated-plan, and independently compiled emitted source. The shared Dart/Julia/Lua inventory stays 246 names; language coverage separately requires Dart's seven name/target pairs to equal the neutral typed-source contract. Focused 91 and complete Dart format 96/0, analysis, package 379, storage 20/47, CLI 66x2, corpus 105/105 pass. Sole-facing mdBook 79/14,152 KiB, Knowledge Map 786/6,419, all doctrines, and canonical capability 80/0/0, typed 5/9/39, containment/relocation, CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 681 seconds pass. Typed-source rollout intentionally remains 5/9/39 until Dart value/projection admission."
evidence_update_2026_08_07_dart_red: "Dart dormant RED .14.2.3.0.2 adds test_dormant/typed_source_location_contract_test.dart outside ordinary test discovery and excludes exactly that unresolved future import from fatal analysis. Its four tests consume the neutral 3/7/6/3 fixtures, four private diagnostics, detached 92+7 catalogs, complete named-mark/capture-boundary/cursor behavior, and native/reconstructed/generated-plan carriers. The repository-routed explicit test exits 1 only for absent source_location.dart and its expected SourceLocationContext, SourceAuthority, Position, Span, DerivedTextPolicy, and SourceLocationException symbols; ordinary fatal analysis and all 379 tests pass. Complete Dart passes format 97/0, storage 20/47, CLI 66x2, and corpus 105/105. No production, neutral 5/9/39, schema, or public-book behavior moves; immutable core .14.2.3.1 is next."
evidence_update_2026_08_07_dart_red_signoff: "Dart RED signoff preserves the source-unchanged sole-facing book at 79 files/14152 KiB with separate generated-HTML paragraph, list, table, and example blocks. Knowledge Map is 786/6423 and all seven doctrines pass. The approved canonical rerun passes capability 80/0/0, typed 5/9/39 plus Rust 4/4, composed semantic/MCP consumers, repository process containment and moved-root execution, CLI 66x2, RAM 39%, and Phase 0 1031/1031 in 704 seconds before the exact local-CI pass marker."
evidence_update_2026_08_07_dart_core: "Dart core .14.2.3.1 adds lib/src/runtime/source_location.dart. One authority copies decoded sources and owns scalar-to-UTF-16, line/column, and UTF-8-byte tables behind a monotonic opaque identity. Final Position, Span, and DerivedText values carry only identity, scalar offsets, provenance, and policy; all JSON records are detached. The authority validates, converts valid UTF-16 boundaries, derives coordinates, and materializes direct or concatenate-in-order text with only the four neutral private diagnostics. The first two dormant tests pass 2/2 over exact 3/7/6/3 fixtures and errors. The full dormant file advances to one NoSuchMethodError naming only absent LinkedSpecRuntimeEngine.typedSourceProjectionRows, while ordinary discovery stays 379 and the analyzer exclusion is removed. No engine/helper route or Dart runtime admission moves, so rollout remains 5/9/39 and sole-facing behavior remains unchanged."
evidence_update_2026_08_07_dart_core_signoff: "Dart core signoff passes complete Dart format 98/0, fatal analysis, ordinary 379, storage 20/47, CLI 66x2, corpus 105/105, language coverage 246/105/122, neutral typed source 5/9/39, source-unchanged mdBook 79 files/14152 KiB with separate rendered blocks, Knowledge Map 786/6427, and all seven doctrines. Definitive canonical CI preserves capability 80/0/0, executes Rust typed source 4/4 and every composed semantic/MCP admission, proves six-family project-data containment and relocated/outside-CWD execution, passes CLI 66x2, reports RAM 61%, and passes Phase 0 1031/1031 in 686 seconds before the exact local-CI pass marker."
evidence_update_2026_08_07_julia_prerequisites: "Julia authority audit .14.2.4.0 proves all 92 canonical source-boundary names are unique and known, but all seven neutral aliases are absent from is_known_action_ir_call_name and canonical_action_helper_name. Ordinary compiled invocation of each alias throws RuntimeInterpreterException at runtime_execution with unsupported runtime helper '<name>' in rule Top. Julia retains decoded input plus cursor, match, anonymous-boundary, rule-local mark, and stack state as zero-based UTF-8 code-unit offsets and projects Unicode-scalar positions/lengths plus one-based line/column at helper boundaries. Loaded, reconstructed, generated-plan, and emitted adapters converge on LinkedSpecRuntimeEngine. Alias parity .0.1 must precede dormant typed RED .0.2; the audit changes no production, neutral 6/8/40, or book behavior."
evidence_update_2026_08_07_julia_audit_signoff: "Complete Julia package, storage 18/5, primary CLI 66x2, corpus 105/105, neutral 6/8/40, and language coverage 246/105+1/122 pass. The sole-facing book already leaves Julia pending, builds 79 files/14164 KiB, and preserves separate generated paragraphs without source changes. Knowledge Map is 787/6450 and all seven doctrines pass. Definitive canonical CI exits 0 after capability 80/0/0, typed Perl 10 plus Rust/Dart 4/4, composed semantic/MCP, six-family containment, moved/outside-CWD execution, CLI 66x2, RAM 79%, Phase 0 1031/1031, and the exact local-CI pass marker."
evidence_update_2026_08_07_julia_alias_parity: "Julia prerequisite .14.2.4.0.1 adds the exact seven neutral compatibility names at the existing ActionContracts known-name/canonicalization seam and routes them only through capture_slice, capture_slice_len, capture_rest_len, start_capture_slice, entry_map, and match_map. No interpreter branch is added. One ordinary 141-assertion consumer proves exact mapping/arity, unrelated unsupported-helper diagnostics, Unicode text and scalar widths, anonymous-boundary mutation, reversed-span absence, named maps, and canonical equality across native, loaded/reconstructed, generated-plan, and independently loaded emitted source. The shared Dart/Julia/Lua inventory stays 246 names; language coverage now independently requires both Dart's and Julia's seven name/target pairs to equal the neutral typed-source contract. Typed-source rollout intentionally remains 6/8/40 until Julia value/projection admission."
evidence_update_2026_08_07_julia_alias_signoff: "Complete Julia passes byte-fresh MCP, package including aliases 141/141, storage 19/5, primary CLI, corpus 105/105, and its exact pass marker. Sole-facing book is 79 files/14168 KiB with separate rendered blocks; Knowledge Map is 787/6450 and all doctrines pass. Definitive canonical CI preserves capability 80/0/0 and typed source 6/8/40, executes Perl 10 plus Rust/Dart 4/4 and every composed semantic/MCP admission, proves relocated six-family containment and moved/outside-CWD execution, passes CLI 66x2, reports RAM 66%, and passes Phase 0 1031/1031 in 700 seconds before the exact local-CI pass marker."
evidence_update_2026_08_07_julia_red: "Julia dormant RED .14.2.4.0.2 adds julia/test/typed_source_location_contract_test.jl at its final test path while leaving it outside the explicit test/runtests.jl include list and canonical registration. Core and projection selections are explicit through LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE. Both parse completely and exit 1 at the same sole current UndefVarError because the private LinkedSpecJulia.SourceLocation namespace is absent; lookup of typed_source_projection_rows and typed_source_compatibility_aliases is ordered only after that namespace, so core .14.2.4.1 can advance projection mode to its separately owned missing API. The private namespace preserves neutral SourceLocationContext, SourceAuthority, Position, Span, DerivedTextPolicy, and SourceLocationException names without colliding with LinkedSpecJulia's existing exported parser SourceSpan or creating authored facade methods. The consumer freezes 3/7/6/3 values, four private diagnostics, detached exact 92+7 catalogs, mark isolation/absence, capture mutation, cursor restore, and native/reconstructed/generated-plan results. Production, ordinary discovery, neutral 6/8/40, schema, and sole-facing behavior remain unchanged."
evidence_update_2026_08_07_julia_red_signoff: "Julia dormant RED signoff passes full syntax parsing, both exact missing-namespace modes, alias 141/141, complete Julia with byte-fresh MCP/package/storage 19/5/CLI/corpus 105/105, neutral 6/8/40, and language 246/105+1/122. The source-unchanged sole-facing mdBook builds 79 files/14168 KiB and keeps the audited table, paragraphs, example, code, and following guidance in separate HTML blocks while leaving Julia values/projections pending. Knowledge Map is 787/6455 and all seven doctrines pass. Definitive canonical CI preserves capability 80/0/0, typed Perl 10 plus Rust/Dart 4/4, every composed semantic/MCP admission, six-family containment, relocation and outside-CWD execution, CLI 66x2, RAM 62%, and Phase 0 1031/1031 in 705 wallclock seconds before the exact local-CI pass marker."
evidence_update_2026_08_07_dart_projections: "Dart projection .14.2.3.2 initializes one copied input authority in every _RuntimeExecutionContext and routes exact source spans, positions, coordinates, materialization, source slicing, mark reads/writes, capture boundaries, and cursor controls through typed values. Existing UTF-16 code-unit cursor, match, mark, anonymous-boundary, and stack registers remain unchanged; capture-group collection/existence/delete adapters retain their detached compatibility shapes. Fresh catalogs expose all 92 rows in 47/30/11/4 families plus seven aliases. The dormant consumer passes 4/4 across immutable values, native/reconstructed/generated-plan state, and carrier behavior; the dedicated alias suite includes freshly emitted execution. Focused runtime selection passes 86, ordinary discovery remains 379, complete Dart passes format/analyzer/storage, CLI 66x2, and corpus 105/105, while neutral truth remains 5/9/39 and language coverage 246/105+1/122. Registration and dart_runtime promotion remain exclusively .14.2.3.3."
evidence_update_2026_08_07_dart_projections_signoff: "The sole-facing book documents implemented-but-unadmitted Dart projections in four current surfaces; repository-routed mdBook build produces 79 files/14164 KiB and generated HTML keeps separate paragraph/code elements. Knowledge Map is 786/6431 and all seven doctrines pass. Definitive canonical CI preserves capability 80/0/0 and typed source 5/9/39 plus Rust 4/4, executes all composed semantic/MCP admissions, proves six-family containment and moved/outside-CWD execution, passes CLI 66x2, reports RAM 68%, and passes Phase 0 1031/1031 in 677 seconds before the exact local-CI pass marker."
evidence_update_2026_08_07_dart_admission: "Dart admission .14.2.3.3 moves the unchanged four-test consumer into ordinary package discovery, requires it once in canonical CI through repository-managed Dart storage, and promotes only dart_runtime. The independently strengthened checker requires the ordinary path and exact command, rejects retained dormancy, and adds Dart's completed-to-pending regression. Current truth is 6 complete / 8 pending / 40 mutations. Focused admission passes 4/4; the complete Dart gate passes format 98/0, fatal analysis, ordinary 383, storage 20/47, CLI 66x2, and corpus 105/105. No production runtime, helper result, UTF-16 register, carrier, schema, semantic/MCP/capability surface, DSL, README, or other backend changes."
evidence_update_2026_08_07_dart_admission_signoff: "Sole-facing mdBook build is 79 files/14164 KiB with separate generated paragraph and command blocks. Knowledge Map is 786/6432 and all seven doctrines pass. Definitive canonical CI proves capability 80/0/0, typed source 6/8/40 with Perl 10 plus Rust/Dart 4/4, byte-fresh MCP bindings, all composed semantic/MCP admissions, six-family containment, moved/outside-CWD execution, CLI 66x2, RAM 73%, and Phase 0 1031/1031 in 685 seconds before the exact local-CI pass marker."
reverify: "source tools/project_data_env.sh && cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract && perl -Iperl -c perl/LinkedSpec/SourceLocation.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm && prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/complete_named_mark_contract.t t/rule_local_cursor_perl_execution.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && perl tools/check_language_capability_coverage.pl && (cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/source_boundary_compatibility_aliases_test.dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart) && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/source_boundary_compatibility_aliases_test.jl\")' && test -f julia/test/typed_source_location_contract_test.jl && ! rg -q 'typed_source_location_contract_test\\.jl' julia/test/runtests.jl && LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE=core bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\")' 2>&1 | rg -q 'UndefVarError: `SourceLocation` not defined in `LinkedSpecJulia`' && test -f dart/test/typed_source_location_contract_test.dart && test ! -e dart/test_dormant/typed_source_location_contract_test.dart"
---

The canonical design remains ADR `0056`; the exact implementation plan and rollout correction live under
`FUTURE-PARITY-BACKLOG.14.2.0-.14.2.7` in `docs/tasks/FUTURE-PARITY-BACKLOG.md`.

One runtime-internal source authority owns decoded text by opaque input `source_id`. Immutable positions and spans
carry only that identity, Unicode-scalar offsets, and direct-span provenance; derived text carries an ordered span
sequence plus explicit `concatenate_in_order` policy. The authority validates and materializes. Values never embed
the text, a path, regex state, parser state, or a host reference.

Efficient host registers remain unchanged: Perl uses decoded-string scalar offsets, Rust and Lua use UTF-8 bytes,
and Dart and Julia use code units. Each backend converts at the typed boundary. Existing generated-spec artifact
identity is separate from input-source identity.

The 92 canonical source-boundary helpers and seven callable aliases project through typed values internally while
preserving their current strings, numbers, collections, absence values, and cursor/mark mutation behavior. No DSL
spelling, top-level typed facade, descriptor schema, semantic/MCP projection, parse-result shape, or span-native
dispatch is admitted by `.14.2`.

This slice owns only the four value diagnostics: source mismatch, position out of range, reversed span, and invalid
derived provenance. Later leaves retain mark-lifetime, transaction, recursion/progress, gap, and dispatch errors.

The rollout ledger is live admission state. It became stale because public owner `.14.1.2` explicitly excluded the
contract and no-change recomposition `.14.1.3` required it unchanged. Correction `.14.2.0.1` has promoted those
two completed public rows and re-owned the five runtime rows to exact admission leaves
`.14.2.1.3-.14.2.5.3`. Perl admission `.14.2.1.3`, Rust admission `.14.2.2.3`, and Dart admission `.14.2.3.3`
have promoted only their own runtime rows; current truth is 6 complete / 8 pending, protected by 40 mutations
including one completed-to-pending regression per completed public/runtime row.

Perl core `.14.2.1.1` now implements `LinkedSpec::SourceLocation`. Module-private authority state snapshots decoded
text and precomputes scalar-boundary line, column, and UTF-8 byte evidence. Positions, direct spans, and derived
text are opaque token objects backed by separate private immutable records and monotonic authority ids; they retain
neither decoded text nor a live authority/parser reference. Detached `as_record` projections cannot mutate those
records. The authority alone validates, derives `coordinates`, and `materialize`s direct or ordered derived text;
the four exact structured value errors are locked and privacy-filtered.

Perl projection `.14.2.1.2` now supplies the exact detached
`ActionIR::Contracts::typed_source_projection_rows` interface and routes all 92 neutral helper rows plus seven
aliases through `LinkedSpec::SourceLocation::Runtime`. Every handler establishes one `input` authority before
capture-boundary initialization; child calls reuse it through `LinkedRE` match-info propagation. Typed positions
and spans validate/materialize source operations at the ActionIR, RuleIR, handler-bridge, nested-method, mark, and
cursor seams, while compatibility storage and results remain the existing Perl scalars, strings, lists, maps,
booleans, and absence values. Independently emitted/loaded source uses the same route.

Both Perl consumers are now required, syntax-checked, and unconditionally executed by canonical CI under exact
admission `.14.2.1.3`. This admits the internal Perl runtime and its preserved helper projections; it makes no
public authored-value/transaction, descriptor/schema, semantic/MCP, DSL/facade, generated-plan-format, or other-
backend claim.

Rust core `.14.2.2.1` implements the same immutable authority/value algebra in
`rust/linkedspec-runtime/src/source_location.rs`. One authority snapshots caller-supplied decoded sources and owns
the scalar-boundary conversion tables. Its opaque values retain no text or live authority/parser reference; only
detached records cross the API.

Rust projection `.14.2.2.2` gives each execution input one authority and routes all 92 canonical helpers plus seven
aliases through typed boundary methods. Existing UTF-8-byte registers and public results remain unchanged; native,
reconstructed, generated-plan, and emitted paths use the same engine. Admission `.14.2.2.3` removes the test-local
dormancy, requires the exact ordinary consumer in canonical CI, and promotes only `rust_runtime`; at that admission
boundary the rollout advanced to 5 complete / 9 pending / 39 mutations.

Dart has all 92 canonical helpers and now executes the seven compatibility aliases through its existing ActionIR
known-name/canonicalization adapter. The aliases select no separate interpreter behavior: they resolve to the same
canonical routes, while unrelated invented names retain structured `unknown_helper` at
`callable_codeblock_invocation`. Dart continues to store decoded input and all cursor, match, anonymous-boundary,
mark, and cursor-stack positions as UTF-16 code-unit offsets, converting to Unicode-scalar positions/lengths and
one-based line/column at helper boundaries. Loaded, reconstructed, generated-plan, and emitted paths all instantiate
the same `LinkedSpecRuntimeEngine`. The seven spellings live in a dedicated compatibility inventory so the shared
246-name Dart/Julia/Lua capability contract remains exact. Dormant boundary `.14.2.3.0.2` froze one four-test
3/7/6/3 + 92+7 consumer outside ordinary discovery; its explicit repository-routed command failed only for the
absent immutable core/projection API while
all current Dart tests stay green. Immutable core `.14.2.3.1` now adds one copied decoded-source authority with
scalar-to-UTF-16, line/column, and UTF-8-byte boundary tables plus opaque immutable positions, direct spans, and
ordered derived text. The authority alone validates, converts, and materializes; detached records carry no source
text or engine reference. Projection `.14.2.3.2` now gives each execution context one input authority and routes
all 92 canonical helpers plus seven aliases through typed construction, validation, coordinates, slicing,
materialization, mark/capture state, and cursor-control boundaries. Existing UTF-16 code-unit registers and every
external result or mutation shape remain unchanged; native, reconstructed, generated-plan, and freshly emitted
execution converge on the same engine. Admission `.14.2.3.3` moves that unchanged 4/4 consumer into ordinary
discovery, requires its exact target once in canonical CI, and promotes only `dart_runtime`. The checker rejects
retained dormancy and completed-to-pending regression; rollout is now 6/8/40.

## Links

- Decision: `docs/decisions/0056-typed-source-location-and-cursor-algebra.md`, especially section 9.
- Neutral artifact: `capability_conformance/typed_source_location_contract.json`.
- Neutral inventory card: [[typed-source-location-neutral-contract-plan]].
- Current helper taxonomy: [[spec-capture-mark-family-taxonomy]].
- Current cross-runtime mark baseline: [[complete-named-mark-perl-rust-parity]].
