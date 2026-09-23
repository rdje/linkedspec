---
id: action-regex-operands-and-runtime-kinds
title: Regex helper operands do not establish a portable regex runtime type
answers:
  - is regex a builtin variable type in spec action code
  - does rx equals slash pattern create a reusable regex object
  - why does a regex AST node not imply a regex value kind
  - can regex patterns be used inside action blocks
  - would a first class regex type help LinkedSpec
  - why does Perl matches fail inside a callable codeblock
  - which task owns function position filter_match on Perl
date: 2026-09-23
status: current audit; helper repairs remain open
tags: [regex, actionir, runtime-values, perl, rust, dart, julia, lua]
evidence: "SESSION-STARTUP-READING.86.4.2.4 reads the neutral binding contract, relevant mdBook sections and first-party AST/evaluator owners. The tracked diagnostic measures thirteen action cases plus an AST probe on accepted production at 7c318569. Source inspection of other backends is not a fresh five-backend execution claim."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.4.2.4.pl; inspect values, generated source and both error channels, not process exit alone."
---

## Contract and syntax

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

Independent lowering executes to `1`, but public whole-spec validation rejects
the following `Done:` rule as if the action were still open. This is the concrete
remaining `.86.4.3` repair. It does not require regex-valued variables or a new
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

`.87.1` owns the direct `filter_match` failure: the receiver route synthesizes
`__array_value_filter_match`, but the failing direct form is left as a host call.
Coordinate the pre-existing pipeline caveats and `FUTURE-PARITY-BACKLOG.5`.
`.87.2` owns `matches` in callable bodies: `CodeblockRuntime::_eval_expr` has no
regex operand case and `_eval_call` has no `matches` branch. These are existing
helper execution gaps, not a reason to invent a runtime type. Current finite
callable fixtures do not cover them.

## Recommendation discussed with the director

Do not add a first-class regex type without a concrete unmet use case. Its possible
benefits are carrying pattern and flags together, validating at construction, and
reusing a compiled representation when a backend permits it. Those are potential
design benefits, not measured performance claims or current behavior guarantees.
Caching does not inherently require a public value type. The cost includes shared
flag semantics, copying, equality, serialization, callable transport and five-backend
conformance. Strings and documented helper operands cover the examples established
here. A type would not itself resolve lexical slash ambiguity.

This is an engineering recommendation in response to the September23 discussion,
not approval, roadmap admission, or a new implementation task.
