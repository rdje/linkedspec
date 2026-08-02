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
date: 2026-08-01
status: Perl immutable value core, projections, and canonical runtime admission complete; other runtimes pending
tags: [architecture, source-location, spans, cursor, helpers, perl, rust, dart, julia, lua, rollout]
evidence: "FUTURE-PARITY-BACKLOG.14.2.0 retrieved ADR 0056, the neutral contract/checker, adjacent live-ledger contracts, TOOLBOX.md, and exact runtime source/test authorities. Perl uses decoded-string scalar offsets; Rust and Lua use UTF-8 bytes; Dart and Julia use code units. Complete named-mark consumers pass on all six runtimes. The exact contract/checker still encode completed public owners .14.1.2-.3 as pending because both leaves explicitly excluded contract changes, leaving no promotion owner. ADR 0056 section 9 and the owning task freeze the correction and implementation order."
evidence_update_2026_08_01_public_rollout: "Correction .14.2.0.1 promotes completed public owners .14.1.2-.3, re-owners runtime admissions to .14.2.1.3-.14.2.5.3, advances current truth to 3 complete / 11 pending, and locks 37 mutations including two independent completed-to-pending regressions."
evidence_update_2026_08_01_perl_red: "Perl authority/RED .14.2.1.0 freezes two unregistered consumers without implementation. typed_source_location_values.t requires LinkedSpec::SourceLocation authority plus immutable Position/Span/DerivedText values, coordinates/materialization, detached records, and the four value errors across all 3/7/6/3 fixtures. typed_source_location_perl_contract.t requires ActionIR::Contracts::typed_source_projection_rows, exact 92-row routing, seven aliases, and unchanged live/generated named-mark results. The first exits only for the missing module; the second has one failure naming only the missing catalog."
evidence_update_2026_08_01_perl_core: "Perl core .14.2.1.1 adds SourceLocation.pm. Module-private authority state snapshots decoded text and precomputes scalar-boundary line/column/UTF-8-byte evidence; monotonic authority ids plus module-private value state keep Position, Span, and DerivedText records immutable and free of text/host references. The authority alone validates, derives coordinates, and materializes direct or ordered derived text. All value fixtures and four locked structured errors pass; the projection consumer still has exactly one failure for absent typed_source_projection_rows. Definitive canonical CI passes CLI 66/66 twice, RAM 47%, and Phase 0 1,031/1,031 in 633 seconds."
evidence_update_2026_08_01_perl_projections: "Perl projection .14.2.1.2 initializes one input authority in every SpecEntry handler, propagates it through LinkedRE child match info, and routes the exact detached 92-row/four-family catalog plus seven aliases through SourceLocation::Runtime. Typed positions/spans validate and materialize source text, coordinates, mark reads/writes, capture boundaries, and cursor operations while external scalar/string/list/map/boolean/absence results and scalar mark/cursor storage remain unchanged. RuleIR, both handler IMATCH bridges, nested MethodLowering expressions, live execution, and independently emitted/loaded source share the route. The unregistered projection consumer passes all 3 top-level and 202 nested assertions; focused baselines pass 423/423. Definitive canonical CI passes repository containment, moved-root/outside-CWD execution, composed semantic/MCP admissions, CLI 66/66 twice, RAM 53%, and Phase 0 1,031/1,031 in 651 seconds before the explicit pass marker. Admission and public support remain pending under .14.2.1.3."
evidence_update_2026_08_01_perl_admission: "Perl admission .14.2.1.3 requires, syntax-checks, and unconditionally executes both committed consumers in canonical CI. Their composed run passes 10 tests across the exact immutable values, 92 helpers plus seven aliases, and live plus independently emitted/loaded generated routes. The neutral artifact/checker promotes only perl_runtime, advances live truth to 4 complete / 10 pending, and rejects 38 mutations including an independent Perl complete-to-pending regression. The sole-facing capture, project-status, local-CI, and backend-handoff pages distinguish admitted internal Perl values/projections from absent authored Position/Span values, transactions, and the five pending runtimes. No production code, external helper result, scalar mark/cursor storage, schema/identity, semantic/MCP state, DSL/facade, or root README changes. Definitive canonical CI passes all seven doctrines, containment/relocation, CLI 66/66 twice, RAM 53%, and Phase 0 1,031/1,031 in 650 seconds."
reverify: "perl -Iperl -c perl/LinkedSpec/SourceLocation.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm && prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/complete_named_mark_contract.t t/rule_local_cursor_perl_execution.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
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
`.14.2.1.3-.14.2.5.3`. Perl admission `.14.2.1.3` has now promoted only `perl_runtime`; current truth is 4 complete /
10 pending, protected by 38 mutations including one completed-to-pending regression per completed public/runtime
row.

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

## Links

- Decision: `docs/decisions/0056-typed-source-location-and-cursor-algebra.md`, especially section 9.
- Neutral artifact: `capability_conformance/typed_source_location_contract.json`.
- Neutral inventory card: [[typed-source-location-neutral-contract-plan]].
- Current helper taxonomy: [[spec-capture-mark-family-taxonomy]].
- Current cross-runtime mark baseline: [[complete-named-mark-perl-rust-parity]].
