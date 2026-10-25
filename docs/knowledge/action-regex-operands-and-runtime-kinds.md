---
id: action-regex-operands-and-runtime-kinds
title: Regex operands and pure array helper values
answers:
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
date: 2026-10-26
status: ordinary pure pipelines implemented; broad recurrence deferred; audit observations historical
tags: [regex, actionir, runtime-values, perl, rust, dart, julia, lua]
evidence: "Historical type audit .86.4.2.4 at7c318569; callable matches .87.2; ordinary filters .87.1."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/array_pipeline_value_contract.t"
---

October26:87.1 added ordinary filter values;5.4.1 routes other pipeline values to pure lowering. Typed bare/emitted function slots supply values; standalone calls still rebind. The old value path emitted source assignments.

Copied predicate operands preserve numeric selectors. Native/fresh tests cover nested/function/computed/receiver/statement values and source effects. Broader5.4.2 remains open; no deferred-helper or regex-type admission.

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

## Measured Perl behavior

`docs/checkpoints/SESSION-STARTUP-READING.86.4.2.4.pl` runs public `Get` on a
zero-regex `Top:: -> Done` parent with matching `Done: /x/`, records
`runtime_ctx_ref->{last_error}`, and independently executes the generated action
with host `$_` set to `abc` and `zzz`. Each case has fresh state.

| Action | Observed result |
| --- | --- |
| `return(matches("abc", /b/))` | `1`; the helper explicitly matches its first argument |
| `rx = "b"; return(matches("abc", rx))` | `1`; a reusable string pattern works |
| `return(split("a,b", /,/))` | `["a","b"]` |
| `return(["ax","by"].filter_match(/^a/))` | `["ax"]` |
| `text = "abc"; regex_subst(text, /b/, "B", g); return(text)` | `"aBc"` |
| `rx = /b/; return(rx)` or `return(/b/)` | Independent action returns `1` for host `abc`, `""` for `zzz`; public case returns `""`. No regex object is returned. |
| `rx = /b/; return(matches("abc", rx))` | Independent action returns `0`/`1` for those host subjects: it reuses the match result, not the pattern |
| `return(filter_match(["ax","by"], /^a/))` | Undefined host subroutine; receiver twin succeeds |
| Callable body `return(matches(text, /b/))` | `unsupported_codeblock_actionir` |
| Callable body `return(matches(text, "b"))` | `unknown_helper`; changing only the operand spelling does not fix it |

`MethodLowering.pm` preserves bare `/.../` in standalone value positions, which
Perl executes as a match against implicit `$_`. Its `matches` branch instead
emits an explicit subject `=~` pattern operation. `BindingRuntime::_kind` has
only the four binding categories. The AST probe records `kind=regex`, pattern
`b` and source span `0..3`; it does not change that runtime contract.

The `matches_multiline` case is a supported helper use:

```text
return(matches(cat("x", "\n", "y"), /(x)
y/))
```

At the audit baseline, independent lowering executed to `1`, but public validation
rejected the following `Done:` rule as if the action were still open. Verified
`.86.4.3` repairs that case. It does not require regex-valued variables or a new
division-versus-regex precedence decision.

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
Four retained-native Rust CLI controls additionally confirm the two revised book
examples return7, standalone `/b/` returns string `b`, and a string pattern in
`matches` returns true. Executable SHA-256:
`bbf40b8165ce72764668b7a02e16c84ddabfcf4b1097d690f5b99956ab38e05d`.
The other native backends were inspected, not executed in this audit.

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

September23 recommendation: add a first-class regex type only for a concrete unmet use case; no approval or roadmap admission. Potential benefits are carrying pattern/flags, construction validation and reusable backend compilation, not measured performance. Caching itself needs no public type. Costs include shared flags, copy/equality/serialization, callable transport and cross-backend conformance. Strings and contextual operands cover observed uses; a type would not settle lexical slash ambiguity.

## October 3 callable matches repair

`SESSION-STARTUP-READING.87.2` adds only helper dispatch and contextual literal pattern
handling in `CodeblockRuntime::_eval_call`. Subject evaluation occurs once before pattern
evaluation; an undefined subject returns numeric0 without evaluating the pattern. Otherwise
string patterns evaluate once, or the existing typed regex payload/flags supply a private
pattern. No generic `_eval_expr(regex)` arm or new runtime value/record field is introduced.
Static helper dispatch precedes a same-named callable slot. Arity rejects before actual operand
effects; invalid compiled string patterns raise typed `invalid_matches_pattern`, while an
operand's existing typed failure is rethrown unchanged. Caller parameter slots restore.

The38-source native/fresh matrix includes16 direct/deferred pairs, copied parameters and
four rejection controls plus an operand-failure control. Literal/string true/false, dynamic
caller patterns, i/m/s/x/g, escaped slash, empty/undefined subject, ordered effects and
same-named slot controls retain exact numeric0/1 or complete values. Public invoke observers
check actual original reference/error identity and deliberately distinct equal-value slots.
The new regression passes39 tests. The read-only reviewer loads the exact activation module
for matched RED on both routes; it does not replace working production. Full source/generated
bytes and raw observations survive in red.json/green.json; only anchored failure-trace dates
project for equality, and residual metadata ordering stays with self-containment .0.6.

The first flag controls used textual \n in a quoted subject. After helper repair only those
two deferred values differed: typed AST stores backslash+n, while inline compiled Perl expands
LF. This is the previously documented SUPPORTING-SOURCE-READING.2.4 string-fidelity defect.
Initial cases/red and repaired failure logs remain retained; final paired flag controls use
physical LF and leave decoding untouched. Attached/marker/value conditionals, numeric helpers,
readiness/metadata, dispatcher/full16 and other backends remain independently owned.

The prelanding portability gate found a host module location in the new regex compiler
error detail. Final diagnostics retain the regex reason and existing operand source span,
removing only the exact current module suffix and optional fresh-child filehandle line.
Both public routes prove the selected22..25 span and retain thrown-object identity.
Six self-describing capsules preserve original complete streams byte-exact in memory;
old reviewer/claim hashes independently cross-check their links, and three actual
byte/metadata/path corruptions reject. Observed historical paths are opaque data and
never filesystem operands. Raw TAP trailing spaces survive in those capsules; current
tracked text passes whitespace and relocation checks.
