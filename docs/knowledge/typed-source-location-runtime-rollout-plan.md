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
date: 2026-08-01
status: Perl and Rust runtimes admitted; Dart, Julia, PUC Lua, and LuaJIT pending
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
reverify: "source tools/project_data_env.sh && cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract && perl -Iperl -c perl/LinkedSpec/SourceLocation.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm && prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/complete_named_mark_contract.t t/rule_local_cursor_perl_execution.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
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
`.14.2.1.3-.14.2.5.3`. Perl admission `.14.2.1.3` and Rust admission `.14.2.2.3` have promoted only their own
runtime rows; current truth is 5 complete / 9 pending, protected by 39 mutations including one completed-to-pending
regression per completed public/runtime row.

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
dormancy, requires the exact ordinary consumer in canonical CI, and promotes only `rust_runtime`; rollout is now
5 complete / 9 pending / 39 mutations.

Dart's current production baseline has all 92 canonical helpers but not the seven compatibility aliases. Its public
ActionIR known-name/canonicalization seam leaves every alias unchanged and unknown; ordinary runtime invocation
returns structured `unknown_helper` at `callable_codeblock_invocation`. This is a prerequisite parity gap, not a
typed-value difference. Dart continues to store the decoded input and all cursor, match, anonymous-boundary, mark,
and cursor-stack positions as UTF-16 code-unit offsets, converting to Unicode-scalar positions/lengths and one-based
line/column at helper boundaries. Loaded, reconstructed, generated-plan, and emitted paths all instantiate the same
`LinkedSpecRuntimeEngine`. Therefore `.14.2.3.0.1` adds canonical-equivalent alias routing before `.14.2.3.0.2`
freezes the dormant 92+7 typed RED; neither audit nor split changes rollout 5/9/39 or the sole-facing book.

## Links

- Decision: `docs/decisions/0056-typed-source-location-and-cursor-algebra.md`, especially section 9.
- Neutral artifact: `capability_conformance/typed_source_location_contract.json`.
- Neutral inventory card: [[typed-source-location-neutral-contract-plan]].
- Current helper taxonomy: [[spec-capture-mark-family-taxonomy]].
- Current cross-runtime mark baseline: [[complete-named-mark-perl-rust-parity]].
