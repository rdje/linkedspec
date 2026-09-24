---
id: rust-hash-separator-and-cat-arity-defects
title: Rust compact hash-key repair and separately owned cat arity boundary
answers:
  - why does Rust return null for a compact dynamic hash key
  - why does adding a space before a Rust hash colon change execution
  - does Rust cat accept one argument while Perl requires two
  - which tasks own the Rust hash separator and cat arity repairs
  - why were no-edge Perl E probes excluded from cat arity evidence
date: 2026-09-24
status: compact hash separator verified under SESSION-STARTUP-READING.50; cat arity remains .51-owned
tags: [rust, perl, parser, hash, cat, arity, diagnostics, SESSION-STARTUP-READING]
evidence: "September7 .3.3.7 established the hash separator and cat arity mechanisms. September24 .50 reverifies thirteen public hash controls: Perl accepts all, baseline Rust accepts eight and rejects five at compile time; rebuilt Rust now returns all thirteen exact expected values. The parser repair, exact AST/source tests, native/reconstructed/generated recurrence and shared emitted book example are owned by .50. Cat observations retain their September7 date and .51 repair owner; single-index reads are independently owned by .88."
reverify: "Run the hash-key tests below for current acceptance. The separately dated cat diagnostic remains an observation, not a repair acceptance criterion."
---

## Dynamic hash-key separator

The dynamic-key contract evaluates keys; it does not autoquote bare names.
On September7, `{key:7}` and `{key: 7}` returned null after a parser warning.
Malformed-block propagation repair `.45` subsequently made those failures reject
compilation. The September24 `.50` RED controls establish five compile failures
among thirteen public sources: compact/right-space bare keys, nested pairs,
Unicode-valued dynamic keys, and a bare `.trim` receiver key. Eight spaced,
parenthesized, computed, quoted, and parenthesized-receiver controls already pass.
All thirteen sources return their expected values through Perl public `Get` with
no handler errors. After the fix, the rebuilt Rust CLI also returns all thirteen
expected values with compile:ok/invoke:ok and empty stderr. Exact before/after
sources, results and binary identities are retained in
`docs/checkpoints/SESSION-STARTUP-READING.50-hash-separator.json`.

`parse_name` in `rust/linkedspec-core/src/expr.rs` previously consumed every colon.
The `.50` repair stops at an isolated colon while preserving existing namespace
colon runs, matching brace classification. Keys still parse as expressions and
values retain their exact authored source and scalar spans. Keyword arguments,
namespace names, and retired hash `=>` rejection remain separate boundaries.

Current recurrence is `rust/linkedspec-core/tests/hash_key_separator.rs` and
`rust/linkedspec-runtime/tests/hash_key_separator.rs`. The public book includes
`examples/compact-hash-keys.spec` verbatim; Perl native/emitted tests and the Rust
emitted-source test execute that same file. Focused verification passes full core258, selected runtime226, keyword policy1,
final compact/emitted2 and Perl book26. Exact commands and source/log identities
are in `docs/checkpoints/SESSION-STARTUP-READING.50-verification.json`.
Correct expectations cover dynamic,
quoted, nested, computed and Unicode-valued keys rather than accepting the former
null results. Single indexed reads exposed an independent typed-binding defect,
owned for immediate repair by `.88`; see [[rust-single-index-read-bypasses-typed-binding]].
Unicode binding identifiers are not admitted by this repair.

```bash
env PERL5LIB= bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --test hash_key_separator
env PERL5LIB= bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test hash_key_separator
env PERL5LIB= bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test source_emitter emitted_compact_hash_key_book_example_preserves_evaluated_keys
env PERL5LIB= bash tools/project_data_run.sh prove -Iperl t/compact_hash_keys_book.t
```

An initial September7 computed-key control used one-argument `cat(key)`. Perl
lowered that to an unsupported-helper marker, so it was excluded and replaced
with valid `cat(key, "")`. That observation led to the separate arity probe.

## Cat minimum arity — September7 evidence

A constant and two-argument control prove that the explicit action-edge body runs
on both routes. Rust CLI and Perl public `Get` exit zero, have empty stderr, and
Perl reports no compilation/invocation exception or `last_error`:

| Action result expression | Rust value | Perl value |
| --- | --- | --- |
| `"control"` | `"control"` | `"control"` |
| `cat("a")` | `"a"` | `null` |
| `cat("a", "")` | `"a"` | `"a"` |

Perl's lowering requires at least two arguments at
`perl/LinkedSpec/ActionIR/MethodLowering.pm` 5330–5332. Rust's `cat` branch at
`rust/linkedspec-runtime/src/engine.rs` 8213–8222 converts scalar arguments and
concatenates without an arity guard. The public helper table in
`docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md` spells
`cat(value, value, ...)`. `.51` owns reconciling the portable invalid-arity boundary
and repairing Rust, including zero/one/two/variadic, type, effect, and carrier cases.
Zero-argument native behavior was not measured here. No other backend is classified
from these two routes.

An earlier no-edge own-regex E probe returned zero on Perl for both one and two
arguments. It therefore failed to isolate helper behavior and is excluded from
arity evidence. Existing `.27` owns that lifecycle/E-handler debt; the corrected
explicit-edge control above demonstrates the actual helper difference.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'CAT_ARITY_BOUNDARY'
import subprocess,json
perl_program=r'''use JSON::PP; my $s=$ARGV[0]; my %ctx; my $p=eval { LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx) }; my $compile_exception="$@"; my $in="xhello"; my $v; my $invoke_exception=""; if(ref($p) eq "CODE") {$v=eval {$p->(\$in)};$invoke_exception="$@"} print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p) eq "CODE" ? 1:0,value=>$v,compile_exception=>$compile_exception,invoke_exception=>$invoke_exception,last_error=>$ctx{last_error}}),"\n";'''
for expr in ['"control"','cat("a")','cat("a","")']:
 source='Top::\n /x/ -> Done { return('+expr+') }\nDone::\n /[a-z]+/\n'
 rust=subprocess.run(['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low'],capture_output=True,text=True,timeout=30)
 perl=subprocess.run(['perl','-Iperl','-MLinkedSpec','-e',perl_program,source],capture_output=True,text=True,timeout=30)
 print(json.dumps({'expression':expr,'source':source,'rust_exit':rust.returncode,'rust_stdout':rust.stdout,'rust_stderr':rust.stderr,'perl_exit':perl.returncode,'perl_stdout':perl.stdout,'perl_stderr':perl.stderr}))
CAT_ARITY_BOUNDARY
```

The bounded Rust engine and Perl lowering source reads are diagnostic coverage,
not completion credit for their broader queued source-reading leaves. The independent
`.49` regex-newline repair and scanner parent `.86` are now verified; `.51` remains open.

Related: [[hash-literal-dynamic-key-contract]], [[hash-literal-colon-rust-parity]],
[[rust-action-parser-boundary-defects]], [[startup-public-teaching-checker-blind-spots]].
