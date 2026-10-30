---
id: action-regex-operands-and-runtime-kinds
title: Regex operands and pure array helper values
answers:
  - why did Dart action regex literal suffix flags disappear
  - which task owns Dart grouped dotted regex rejection
  - why did Rust action regex literal suffix flags disappear
  - how are Rust literal flags carried without a new regex value type
  - does Perl split_each evaluate variable or computed scalar delimiters
  - why do Perl array filters turn numeric entries into string selectors
  - why do nested Perl array helper functions rebind the input
  - is regex a builtin variable type in spec action code
  - does rx equals slash pattern create a reusable regex object
  - why does a regex AST node not imply a regex value kind
  - can regex patterns be used inside action blocks
  - would a first class regex type help LinkedSpec
  - why does Perl matches fail inside a callable codeblock
  - does callable matches skip pattern effects for an undefined subject
  - how are literal regex flags handled by callable matches
  - which task owns function position filter_match on Perl
  - why does a helper-only pipeline use a host array instead of a scalar fixture
  - how does call_spec_handler_subst infer a typed pipeline source
date: 2026-10-30
status: ordinary pure pipelines implemented; broad recurrence deferred; audit observations historical
tags: [regex, actionir, runtime-values, perl, rust, dart, julia, lua]
evidence: "Historical type audit .86.4.2.4 at7c318569; callable matches .87.2; ordinary filters .87.1."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/array_pipeline_value_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test string_predicate_result_receivers --test scalar_predicate_boundaries"
---

October26:87.1 added ordinary filter values;5.4.1 routes other pipeline values to pure lowering. Typed bare/emitted function slots supply values; standalone calls still rebind. The old value path emitted source assignments.

TYPE45.6 (2026-10-30) reconciles two old Phase0 collection-pipeline groups with
this authority. Value assignments preserve the capture/input Array; standalone
pipeline statements still rebind their target. Ordinary `array(pipeline)` remains
nested, including inside a Hash or pushed value. Six public native/fresh controls
distinguish these behaviors without production changes.

The compatibility helper `call_spec_handler_subst(label, code)` builds its own
bare-type memory from the supplied DSL code. It cannot infer a typed binding from
a separate host-only test setup such as `my $items=[...]`. A cold bare collection
source may therefore follow its legacy `@items` path. Supply the DSL initializer
in that same helper call to test a typed binding; retain a host Array setup only
when testing the legacy route. Public typed-prefix and legacy controls keep the
same expected pipeline values and preserve their sources. This does not repair or
admit broader absent-host-slot isolation (SESSION17). Actual diagnostics, exact
fixtures and native/fresh/harness controls are retained in
perl-phase0-collection-pipeline-intake.json.gz.

Copied predicate operands preserve numeric selectors in pure5.4.1 and standalone BindingRuntime::array_transform5.4.4. Uniqueness, regex matching and length compare temporary scalars while retaining the original entry. Null/empty-text distinction and numeric/string equality retain existing semantics. Native/fresh tests cover nested/function/computed/receiver/statement values and source effects. Broader5.4.2 remains open; no deferred-helper or regex-type admission.

## Contract and syntax

Current outcome: [[perl-multiline-helper-pattern-validation]] records the
.86.4.3 validator and .86.4.6 statement-splitting repairs with bounded public
proof. The observations below retain the audit baseline; .86.4.7 repairs the
separate physical multiline quoted-subject validator defect.
Grouped-pattern punctuation repair `.86.4.8.2` and bounded public recomposition `.86.4.4.2.2` are verified;
see [[perl-grouped-regex-operand-boundaries]]. The runtime-kind contract remains unchanged.

`capability_conformance/uniform_binding_contract.json` defines one binding holding
scalar, array, harray or codeblock. The book's value reference and formal grammar
list primitive string, number, boolean and null values. There is no governed
first-class regex type with portable construction, assignment, transport and
serialization semantics.

The book does document **pattern operands**: `matches(value, /pattern/)`,
`split(value, /delimiter/)`, `regex_subst(target, /pattern/, replacement, flags)`
and filtering. Ordinary action braces can contain these helpers. Callable values
with `{|parameters| ... }` are a distinct execution route, with the Perl gap below.

An AST node called `regex` or `RegexLiteral` identifies source syntax, not the
kind of runtime value produced. Assignment can also store the scalar result of
an expression containing regex syntax; that alone does not add a value type.

## Historical Perl audit

Exact public Get/fresh-action rows, AST/source probes and multiline reproducer at Gitd42199d00ee1f5a4712a3d8151c9dc8d1e9a2d1a for this path. Ordinary matches/split/filter/substitution operands worked; bare regex values executed against implicit host $_ rather than creating regex objects. The audit distinguished callable helper gaps and standalone filter dispatch, subsequently repaired by87.1/87.2 as recorded below. Physical multiline validation repairs86.4.3/.7 and grouped operands86.4.8.2 remain separately owned; no public regex type was introduced.

## First-party backend representations

| Backend | Source-confirmed handling of action regex syntax |
| --- | --- |
| Perl | AST `regex`; bare value lowering emits a host match expression |
| Rust | `Expr::RegexLiteral` evaluates to `RuntimeValue::Scalar(pattern)`; `types.rs` has no regex value variant |
| Dart | `ActionRegexLiteralExpr` evaluates to the pattern string |
| Julia | Private `_RuntimeRegexValue` carries pattern/flags for helpers; binding classification falls into scalar |
| Lua | Private `RuntimeHelperRegex` metatable carries pattern/flags for helpers; scalar text conversion returns pattern |

Owners: `perl/LinkedSpec/ActionIR/AST/Parser.pm`,
`perl/LinkedSpec/ActionIR/MethodLowering.pm`, `perl/LinkedSpec/BindingRuntime.pm`,
`rust/linkedspec-core/src/{expr,types}.rs`,
`rust/linkedspec-runtime/src/engine.rs`, `dart/lib/src/runtime/interpreter.dart`,
`julia/src/runtime/Interpreter.jl`, and `lua/src/linkedspec/interpreter.lua`.
Historical Rust CLI controls/hash and audit limits remain at Git5bf0009e421a35f99aaa4b4fae5c08c2e5f8bf74 for this path; that audit did not execute other backends.

Private carriers are implementation details, not evidence of a common public
regex-variable contract. No dependency implementation was inspected.

## Repair ownership and corrected decision

`.86.4.2.2`'s precedence question and `.86.4.2.3`'s assignment-position splitter
expansion are superseded by this audit. Existing observations and rejected patches
remain in [[perl-multiline-regex-scanner-boundaries]]. Their successful host
compilation did not prove both interpretations were required portable DSL behavior.
In particular, the formal grammar excludes comments inside rule paragraphs;
the comment counterexample proved observed Perl compatibility, not an admitted
portable comment/regex ambiguity.

At the audit baseline, `.87.1` owned the direct `filter_match` failure: the receiver route synthesizes
`__array_value_filter_match`, but the failing direct form is left as a host call.
Coordinate the pre-existing pipeline caveats and `FUTURE-PARITY-BACKLOG.5`.
`.87.2` owns `matches` in callable bodies: `CodeblockRuntime::_eval_expr` has no
regex operand case and `_eval_call` has no `matches` branch. These are existing
helper execution gaps, not a reason to invent a runtime type. Current finite
callable fixtures do not cover them.

## Recommendation discussed with the director

A first-class regex type remains unadmitted. The September23 recommendation, use cases and tradeoffs remain at the Git pointer above; existing contextual operands do not establish public regex-variable transport/copy semantics.

## Callable matches and dynamic array delimiters

`SESSION-STARTUP-READING.87.2` added contextual regex operands and matches dispatch to CodeblockRuntime::_eval_call, without a generic regex value kind. Subject evaluation precedes pattern evaluation; undefined subjects return numeric0 and skip the pattern. Other string patterns evaluate once, while literals retain payload/flags. Static helper dispatch precedes same-named callable slots; arity rejects before effects. Invalid string patterns report invalid_matches_pattern; existing operand exceptions retain identity and caller parameters restore. The owning leaf retains its finite native/fresh matrix, observed RED and capsules. Detailed historical proof chronology remains in Git at a1c6202c364dd12b7e2923a6a49b02959469d512; no new admission is inferred. Physical LF controls leave separately owned quoted-escape fidelity unchanged.

`FUTURE-PARITY-BACKLOG.5.5.1` evaluates dynamic scalar split_each delimiters once after snapshotting the array source, even when empty. Runtime text is quoted literally; authored quoted/slash literals retain their existing path and trailing-field behavior. Native/fresh regression covers direct/receiver/nested/function parameters, source-before-delimiter effects, metacharacters and flags. The former static normalizer escaped expression source and skipped effects. Standalone5.5.2 uses the value callback for dynamic delimiter lowering and BindingRuntime::array_snapshot to validate/copy before effects. Empty/absent targets still evaluate the operand once; wrong kinds reject first. The legacy list path also captures the delimiter outside its per-item map. This does not admit regex variables or deferred helpers.

Rust23.3.10.2: Core parse_regex consumed suffix flags but kept only body; free /^a/i and /^a/ serialized identically, while public inline imsx controls worked. Encode imsx as leading modes in the existing pattern string, deduplicate modes, ignore go and encode unknown flags as an invalid pattern for existing helper failure handling. Runtime regex values remain Scalar(pattern); no first-class type/schema field or dependency change. Native/restored/plan match/split/filter controls pass after RED, preserving actual Bool matches. Recompile old derived artifacts from source to recover intended modes; historical artifacts retain original recorded patterns/results. Full regex/context admission remains separate.

Dart23.3.10.3 preserves literal i/m/s suffixes as inline modes in the existing pattern string, including contextual array-helper operands. AST flags were already serialized; evaluation previously discarded them. Native/restored/plan matches/split/filter controls pass after RED. The existing inline bridge remains unchanged; no public type/schema change. 23.3.10.6 recognizes complete slash literals before assignment/fluent scanning, fixing grouped /(?s)^a.b$/ invalid_fluent_chain. Public AST/native/restored/plan, symbolic division/ordinary receiver and direct parser checks pass after RED. Broader grouped-brace scanner/validator/collector repairs remain DART-STARTUP-READING.2.2.1/.2.2.2; TYPE23.2.12 now adds suffix-x class/escape/comment-aware normalization, unknown-mode rejection and matches FormatException-to-false; native/restored/plan/direct tests pass. TYPE23.3.10.7 now preserves complete grouped/whitespace slash operand boundaries, including invalid-group false/empty helpers, exact spans and symbolic division; public AST/native probe and targeted native/restored/plan/direct checks pass. Broad brace validators/full admission remain open.
