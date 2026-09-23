---
id: rust-symbol-call-newline-boundary
title: Rust symbol-call lookahead loses the newline after closing parentheses
answers:
  - why does a Rust division call followed by a newline fail
  - why does slash arithmetic report an unterminated regex
  - which task owns Rust symbol-call newline boundaries
  - why were arithmetic newline controls separated from regex suffix repair
  - why does Rust subtraction before a newline return null
  - why does a Rust subtraction call have an empty callee name
date: 2026-09-23
status: Rust .86.1/.86.2 repaired with focused proof; Perl .86.4/.86.5 remain open
tags: [rust, parser, arithmetic, regex, newline]
evidence: "Untouched .49 core RED reports unterminated regex literal for a slash call before another statement. Six native controls show EOF/semicolon and named div plus newline return 7; slash LF, CRLF and spaced slash plus newline reject compilation. Exact sources/traces: .linkedspec-data/scratch/regex-boundary49/slash-before.jsonl. Division was still unrepaired at that .49 boundary; .86.2 proof below supersedes that status."
reverify: "Run the public CLI probes below through tools/project_data_run.sh. Non-slash proof: bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core -p linkedspec-runtime --test symbol_statement_boundaries; Emitted proof: bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test map_leaves_mutation_contract. Division proof: bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --test division_statement_boundaries."
---

The first `.49` core regression has five failures: four expose regex suffix
whitespace consumption, while the arithmetic compatibility control fails in a
different function before any production change. At discovery, `.86` was the
immediate next owner; `.49` retained working EOF/semicolon arithmetic controls. The original
failure remains in `core-red.log`, with its unchanged required result here:

```rust
CodeBlock::parse("out = /(14, 2)\nreturn(out)")
// Required: two statements. Before .86.2: Err("unterminated regex literal").
```

`rust/linkedspec-core/src/expr.rs::symbol_call_paren_has_expression_boundary`
skips all ASCII whitespace after the matching closing parenthesis, then accepts
only EOF or selected punctuation. A newline followed by an identifier therefore
fails its call-boundary test. Slash falls through to regex parsing. This is
separate from `parse_regex` consuming whitespace before suffix letters.

The established distinction is deliberately narrow and preserves regex literals
with parenthesized content. See [[spec-arithmetic-call-surface-ground-truth]].
Repair must retain escaped, quoted and multiline regex controls rather than
blindly classifying every slash plus parenthesis as division.

These pre-repair Rust public controls all use input `x`:

```bash
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = /(14, 2)\nnote = 1 }\n /x/ E { return(out) }\n' --input x --trace low
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = /(14, 2); note = 1 }\n /x/ E { return(out) }\n' --input x --trace low
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = div(14, 2)\nnote = 1 }\n /x/ E { return(out) }\n' --input x --trace low
```

Before .86.2 the first rejects at compilation; the latter two return 7. CRLF and horizontal
space before the slash-call parentheses retain the failure. The EOF arithmetic
control returns 7 on Rust, but the equivalent Perl outer block reports unclosed
rule syntax. That separate Perl scanner boundary remains under investigation in
`.86`; it must not be inferred fixed by the Rust repair.

Initial no-edge Perl arithmetic probes return the last I assignment (1) despite
`E { return(out) }`, matching the already owned `.27` lifecycle problem in
[[perl-lifecycle-final-value-e-drift]]. They are excluded as arithmetic result
authority. Six public explicit-action-edge controls independently return 7 with
no error, including all three newline forms. Their exact sources/results are in
`perl-edge-before.jsonl`. These establish the newline call's reference acceptance;
they do not establish bare slash-call EOF acceptance in the rejected outer block.

The pre-repair explicit-edge replay has 12 independently authored cases: Perl
returns 7 for all 12; Rust rejects exactly the three regex-newline cases owned by
`.49` and three symbol-call-newline cases owned by `.86`. Other controls return 7.
Logs: `perl-edge-all-before.jsonl` and `native-edge-before.jsonl` in the same
scratch directory. All probe jobs are consumed.

After the separately verified `.49` repair, the same 12-case native replay
returns 7 for all nine regex/compatibility controls and still rejects exactly
the three symbol-call newline forms. The 22-case combined replay passes with
binary SHA256 `2675f2ffb467b123ef6e866b3765c68232a519aac42f6771ed620eef8e0e4e24`;
`native-after.jsonl` records the exact source and trace. This isolates the next
repair without crediting `.49` with a symbol-call fix.

## Pre-repair forty-case diagnosis and safe repair split

At clean 4f79298f9, all twelve Perl symbol callees accept LF and retain the
semicolon values: arithmetic/assignment return 7, numeric comparisons return 1.
Rust rejects eleven LF forms but accepts subtraction with the wrong null result.
The public CodeBlock probe shows an empty-name Call where '-' belongs.
In expr.rs, failed symbol lookahead reaches the negative-number arm's bare-minus
fallback: it advances past '-', then parse_var_or_call sees '(' after an empty
parse_name and builds that unnamed call. This is a value-corruption consequence
of the same newline guard, not an ordinary expected compile rejection.

Non-slash .86.1 fixes eleven symbols without changing the slash discriminator.
Division .86.2 retains the measured LF/CRLF/spaced/nested/before-regex failures and
all seven successful Rust regex controls. Rust currently retains exact multiline
patterns `(x)\ny`, `(14,2)\ntext`, `(14,2)\nnext = ` and the CRLF twin; blindly
treating their first newline as a call boundary would regress them. Quoted and
escaped parenthesized controls also remain owned compatibility requirements.
These unused-regex controls establish parsing and source retention, not successful
matching of every supplied pattern.

Some Perl quoted/multiline controls return null or no parser; bare slash-call
EOF and its whitespace twin reject, while semicolon and named-div twins return 7.
These are observations requiring their own diagnostic classification under .86.2;
no common scanner cause or repair is inferred. The existing no-edge .27 caveat
still applies, and explicit-edge results remain the symbol-call value authority.

Exact source and results are in .linkedspec-data/scratch/symbol-boundary86/:
cases.json, native-before.jsonl, perl-before.jsonl, core-before.tsv and
core-library.json. Public Get diagnostics share the original Perl stdout log;
JSON records can be read independently of those diagnostic lines. All three
probe jobs exited 0 and are consumed. The diagnostic library SHA256 is
d13ff3af22b0efa7a58a65f7e26932d100e2426c1a03bc80f8a9f73fea8c2bb4.
The initial probe's expected_rust boolean annotations were provisional; observed
comparison results are numeric 1 on both backends, not JSON booleans. Permanent
regressions must use that established helper representation.

## Verified non-slash repair under .86.1

Only non-slash symbol lookahead now recognizes authored LF/CR before skipping
whitespace. The existing slash discriminator and EOF/punctuation rules remain
unchanged. Subtraction therefore reaches parse_symbol_call with its '-' intact;
its former empty-name fallback is not used for these valid calls.

The corrected core RED has two failures and two passes. The original test had
incorrectly expected the '=' call to be normalized in the CodeBlock parser;
public AST evidence corrected that assertion before the production change.
Permanent tests require exact callee names, subsequent assignments, Unicode
source/spans, negative literals and the original slash/regex controls.

PASS: 247 core tests and 401 selected runtime tests; the new core target covers 110 symbol/separator/parser combinations, 22 following-write source/span cases and retained compatibility. Three new runtime groups cover 33 symbol assignments, a Unicode-source write and five compatibility cases through source-AST/compiled serde and generated plans. All 14 mutation tests pass, including independent emitted execution after subtraction. Native 44 passes: 39 exact numeric values and five unchanged division rejections owned by .86.2. The exact book example returns 7. Binary SHA-256: 80227ab43b9ef73f56c7884d28151f83f2c6562d0c98bdab35a45bd2255129e5.

Exact logs are focused-green.log and native-after.jsonl under the same scratch
root. The primary executable was rebuilt by the managed runtime test selection;
its identity is checked again after all tests. The 40 initial cases remain
unchanged diagnostic evidence. The new 44-case replay repairs only non-slash
behavior, keeps all seven previously accepted Rust regex forms, and retains all
five measured division failures for immediate .86.2. The Perl quoted/multiline
and bare-EOF observations are not declared repaired.

## .86.2 diagnostic classification and repair constraints

The twelve captured public Perl probes in
`.linkedspec-data/scratch/division-boundary86-2/perl-context.jsonl` include
`runtime_ctx_ref` and each `last_error`. The invalid quoted regex reports
`runtime_handler:rule_handler_compile` with `Unmatched ) in regex`; the numeric
multiline pattern reports the same owner with a generated-handler syntax error.
These are documented structured failure channels, not silent success. Other
multiline patterns and bare slash-call EOF fail outer validation. Lowering the
isolated EOF action succeeds, separating that scanner failure from the numeric
helper. The retained multiline and EOF discrepancies are owned by immediate
`.86.4` and `.86.5` before parent `.86.3` closes; the invalid regex is a negative control.

The Rust repair must prefer every currently successful complete-block parse.
On failure, ambiguous slash calls with a newline after balanced parentheses may
be retried as division. Retry needs statement-level backtracking: a misleading
regex can finish one statement before a later statement fails. Use an explicit
work stack and memoize failed continuation positions, rather than recursing for
each sequential statement or enumerating every combination of earlier choices.
Nested blocks retain their own parser and source base. Preserve the existing
exclusion of `}` from slash call boundaries. Regression proof must cover mixed
regex/division, quoted slashes, late failures, long statement chains, both parser
modes, exact Unicode source/spans and generated/emitted carriers.

The Perl follow-ups are reproducible without the ignored diagnostic logs. Use
input `x` and this explicit-edge source, replacing `ACTION` with each action
below; `\n` and `\r\n` in the table mean literal line breaks:

```text
Top::
 -> Done { ACTION }
Done:
 /x/
```

| Action | Observed Perl result before .86.4 |
| --- | --- |
| `out = /(14,2)\nnote = 1; return(out)` | 7, no last_error |
| `rx = /(x)/; return(7)` | 7, no last_error |
| `rx = /(\))/; return(7)` | 7, no last_error |
| `rx = /(")")/; return(7)` | null, rule_handler_compile: unmatched `)` |
| `rx = /(x)\ny/; return(7)` | no parser, validate_dsl_syntax: rule inside open block |
| `rx = /(14,2)\ntext/; return(7)` | null, rule_handler_compile: syntax error at EOF |
| `rx = /(14,2)\nnext = /; return(7)` | no parser, validate_dsl_syntax: rule inside open block |
| `rx = /(x)\r\ny/; return(7)` | no parser, validate_dsl_syntax: rule inside open block |

For .86.5 use `Top::\n I { ACTION }\n /x/ E { return(out) }\n`.
Actions `out = /(14,2)` and its trailing-space twin fail validation with
`Unclosed rule block before end of file`; `out = /(14,2);` and
`out = div(14,2)` return 7. Call `LinkedSpec::Get(\$source,
runtime_ctx_ref => \%ctx)`, invoke a returned coderef with `\$input`, and inspect
`$ctx{last_error}` as well as `$@`. Independently call
`LinkedSpec::call_spec_handler_subst('Top', $action)` to reproduce the premature
multiline division lowering and the successful isolated EOF lowering.

## Verified division repair under .86.2

The old slash lookahead discarded LF/CR after balanced parentheses, then parsed division as a regex. Accepting every such newline would steal existing multiline regex patterns. Preserve the default parse first. parse_statement_step retains the previous attached-control and separator behavior; parse_block keeps source-position retry frames and failed-continuation memoization. Each trial can force one newline-only slash call; nested bodies use their own parser and character base. Regex/division alternatives can finish a misleading first statement and fail later, so retry spans the continuation rather than only the immediate expression. Sequential statements use a heap stack, not recursive continuation calls. Exhausted alternatives retain the first diagnostic.

PASS: 254 core tests and 404 selected runtime tests. Seven division core groups cover 24 call/separator combinations in both parser modes, exact retained regex patterns, late-statement retries, Unicode write spans, nested controls/callable candidates, and 1500-statement valid/invalid chains. Runtime coverage includes 12 division/separator combinations, nine mixed/nested cases, exact Unicode writes and the ambiguous regex through source-AST/compiled serde and generated plans. All 15 mutation tests pass, including independently compiled emitted division execution. Native 56 passes: 53 exact integer values and 3 malformed rejections; both book examples pass. Binary SHA-256: bbf40b8165ce72764668b7a02e16c84ddabfcf4b1097d690f5b99956ab38e05d.

Exact RED, initial initializer failure, corrected GREEN, named/public Perl controls and native replay are retained under .linkedspec-data/scratch/division-boundary86-2/. The quoted regex control is invalid and reports runtime_handler:rule_handler_compile through documented last_error. Multiline and bare outer EOF discrepancies have immediate owners .86.4/.86.5. No dependency implementation/build internals were consulted. Focused component proof does not substitute for parent .86.3 canonical acceptance.
