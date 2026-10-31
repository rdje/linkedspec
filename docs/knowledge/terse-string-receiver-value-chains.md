---
id: terse-string-receiver-value-chains
title: String receiver chains and predicate result flow
answers:
  - "why does rm_prefix numeric JSON still fail an Array-index write on Perl"
  - "can scalar String helpers preserve Number or Boolean identity kinds"
  - "why do starts_with ends_with contains_substr and matches stop before cat"
  - "how do string receiver-dot value chains work"
  - "does raw.trim().lowercase work"
  - "does raw.split().join_values work"
  - "does string literal receiver-dot work"
  - "does receiver-dot substr work"
  - "can string terminal methods continue"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.3"
  - "are block-valued receiver chains task-tree owned"
date: 2026-10-30
status: five bounded scalar String19 and predicate backends targeted-checked; bounded argument20 repairs targeted-checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, string, rust-parity, mdbook]
evidence: "String2.3.5.3 historical detail/commands at Gite19f3ce83543d8befff3abc381d85a6b6285da15 for this path; Length23.3.3 and predicate23.2.9 public native/fresh distinctions."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test scalar_string_results --test scalar_null_propagation --test scalar_predicate_boundaries --test default_selected_receivers"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/scalar_string_result_receiver_contract.t t/scalar_text_contract.t t/default_selected_receiver_contract.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_predicate_result_receiver_contract.t t/emptiness_result_receiver_contract.t"
---

String chains compose trim/case/replace/substr/cat and split-to-Array helpers; Length23.3.3 feeds scalar/number methods. Current bare bindings/cat supersede historical scalar()/concat. Original details and historical next2.3.5.4/block2.3.5.5 ownership remain at the Git pointer above.

TYPE45.8 (2026-10-30) reconciles four old exact-source assertions with the
existing String normalization/inspect-a-copy affix authority. Original helper
and flow expressions now check normalized values, preserved sources and literal
dot affixes with matching/nonmatching controls. The two semantic Hash projections
stay exact; all6 and the direct native/fresh String consumer7 pass. No production,
kind/Unicode/null/affix or matching contract changes. The group's private owner
is explicitly required for isolated selection; its initial cold no-tests failure
receives no semantic RED credit. See [[phase0-private-owner-focused-selection]];
actual source/RED-GREEN/producer inputs are retained in
perl-phase0-scalar-boundary-intake.json.gz. Other frozen failures remain owned45.

TYPE23.2.9 public native/fresh producer/boundary/SOC controls work, but fluent predicates stopped at null because MethodLowering labeled them terminal. Perl23.3.10.1 now uses scalar_result/one-operand preflight for starts_with/ends_with/contains_substr/matches. Native/fresh result/direct checks pass after RED; source families, false retention/generic/bridges/scalar guards, no malformed effects and SOC/SC snapshots remain correct. Bodies/kinds/regex/source/copy unchanged.

Rust23.3.10.2 adds scalar/preflight lists and repairs dropped action-literal suffix flags in Core parse_regex. Native/restored/plan result/flag/split/filter, direct boundary and focused Core regex checks pass after null/SO/S/12-effect and suffix-flag RED. Preserve numeric substring/Boolean matches, existing pattern-string schema and domains. Rebuild old derived artifacts from source; details: [[action-regex-operands-and-runtime-kinds]]. Dart23.3.10.3 adds scalar/preflight guards, rejects null text operands and retains literal i/m/s modes. Shared/direct emptiness and native/restored/plan mode/split/filter checks pass; actual kinds and SOC/SC snapshots remain correct. Julia23.3.10.4 adds scalar/one-operand guards and null operand false; native/plan/fresh/direct emptiness pass with actual kinds/SOC/SC preserved. Lua23.3.10.5 removes terminal fences, adds scalar/shape guards and null operand false; safe native/plan/fresh/direct checks pass on5.5.1/JIT. Dart23.3.10.6 fixes complete grouped dotted literal priority; broader scanners/full admission and Perl registration23.4.1 remain open.

TYPE23.2.19 freezes scalar-string-results.md for eight ordinary transforms/text
helpers. Public native/fresh eight fluent/nested texts/bridges, SONC snapshots,
Unicode and sources pass; container/malformed tails retain raw DSL and fail.
Actual identity kinds matter: free/fluent/named rm_prefix/rm_suffix numeric0
Array-index writes fail even though JSON prints0. Before JSON, their values have
IOK+POK; empty-old replacement/literal0 retain IOK only, String0 POK only.
Substitution inspects original affix values with index/length/substr, while
BindingRuntime correctly prioritizes POK. Perl19.1 owns inspect-a-copy repair
and scalar flow/shapes before independent19.2-.5; reducer95 remains separate
([[perl-numeric-reducer-string-result-kinds]]). Existing free domains/Unicode/
strict cat/null/callback policy stay. Frozen scalar-text rejects null; the stale
catalog undef-as-empty line is corrected here, not a producer policy change.

TYPE23.3.19.1 repairs Perl scalar result/shape composition through existing typed
actual-value/host dispatch, retaining dedicated mutation/traversal routes and
authored Hash checks. Affix inspection now copies the source before text tests,
returning original identities or actual matched text. Public flags are IOK-only
for numeric prefix/suffix/replacement/literal0 and POK-only for String0; strict
free/fluent/named Array writes and Hash text keys pass. New7/direct12 focused
checks retain eight helper results/bridges/scalar bounds/empty/null/Unicode,
source roots, identity kinds, SONC-SC-selectedS snapshots, eager null operands,
rejected prefix effects/skipped operands and12 malformed no-effects. Syntax
passes; no Unicode/free/selector/callback policy change or reducer95 repair.
Current book limitation is removed; Rust19.2 independently assesses next.

TYPE23.3.19.2 confirms Rust producers, then repairs eight result/shape metadata
omissions through existing selected dispatch. Shared RED has SCA/selectedSA/[]
and malformed effects; native/restored/plan GREEN retains complete bounded data.
Ordinary substring null/fractional source/index defects are independently
reproduced against retained native/fresh Perl controls and repaired after
mutation dispatch; details: [[rust-scalar-helper-null-and-empty-drift]]. New4/
direct3 focused tests plus offline compile/rustfmt/probe syntax pass, including
SIL and both named-target mutation aliases. No standalone/portable admission;
Dart19.3 independently assesses next.

TYPE23.3.19.3 independently repairs Dart coerced Number/Boolean identities and
explicit null operands, then eight-method scalar/shape and fractional guards.
New7/direct3 native/restored/plan plus format/fatal selected analysis pass with
shared kinds/indices/Unicode/snapshots/rejection and mutation controls. Existing
Dart null-width-as-omitted/Bool-invalid0 differ from Perl/Rust; preserve them in
this result slice and reconcile under P2 TYPE23.2.20 before portable admission.
Details: [[dart-runtime-string-numeric-helpers]]. Julia19.4 independently follows.

TYPE23.3.19.4 independently repairs Julia original Number/Bool identities,
explicit null operands and eight-method scalar/shape metadata. Registered
new54/direct9 strict native/plan/fresh assertions pass, retaining exact kinds/
indices/Unicode/snapshots/rejection and mutation controls. Existing null-width-
as-omitted/Bool1 differs from Dart/Perl/Rust combinations and stays under20.
Details: [[julia-runtime-string-numeric-helpers]]. Safe Lua19.5 follows.

TYPE23.3.19.5 independently repairs Lua identities/null operands/scalar/shape
flow on safe PUC5.5.1/LuaJIT, preserving false without and/or loss. PUC large-end
substring wrap is reproduced/fixed by clipping before addition. Strict native/
plan/fresh eight-group/shared/direct-default/source checks pass both hosts.
Details: [[lua-string-helper-parity-closeout]]. Width-omitted/Bool0 conventions
join20; all five bounded String implementations are targeted-checked, with
input-domain20 frozen from existing Perl-reference authority before portable admission. See [[substring-optional-arguments]]; Dart20.1/Julia20.2/safe Lua20.3 now pass their concrete local repair checks, with full admission separate.

TYPE45.11.2 reconciles the original String18 after the bounded sorted_values
producer repair45.11.1:3 obsolete assertions/15 healthy ->18 GREEN. Literal
substring/case yields BCD; initialized Length/trim yields3 and original paired
Length/trim + matches/lowercase runtime yields[3,"1"]. Original runtime sources
and other15 assertions stay exact; production unchanged in this oracle slice.
Prior child1 native/fresh six-case evidence is reused with exact input/producer
identities, not rerun. On Perl5.34.1, paired Length/trim values remain dual IOK/POK;
JSON3 is not a new strict selector-kind promise. Incompatible-tail policies
remain helper-specific; see [[perl-sorted-values-scalar-host-isolation]].

Selection31 separately freezes four String-predicate source/prefix guards70: [[string-predicate-result-source-guards]]. Current compatible result handoff remains; public reference gaps are free fallback, with normalization and receiver bridge readiness. Producer kinds/regex/source-operand SOC snapshots stay; independent backend guards/full admission remain separate.
