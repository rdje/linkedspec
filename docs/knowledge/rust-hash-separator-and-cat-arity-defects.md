---
id: rust-hash-separator-and-cat-arity-defects
title: Rust hash separator tokenization and cat minimum arity diverge from their reference boundaries
answers:
  - why does Rust return null for a compact dynamic hash key
  - why does adding a space before a Rust hash colon change execution
  - does Rust cat accept one argument while Perl requires two
  - which tasks own the Rust hash separator and cat arity repairs
  - why were no-edge Perl E probes excluded from cat arity evidence
date: 2026-09-07
status: confirmed bounded defects; repairs pending under SESSION-STARTUP-READING.50 and .51
tags: [rust, perl, parser, hash, cat, arity, diagnostics, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.7 runs six asserted Rust CLI/Perl Toolbox lowering controls for dynamic hash separators, plus three paired explicit-edge Rust CLI/Perl public Get controls for cat arity. Both source mechanisms are inspected; no implementation or complete-backend signoff is claimed."
reverify: "Run the two repository-managed diagnostic commands below; their observed pre-repair differences are not green repair acceptance criteria."
---

## Dynamic hash-key separator

The current dynamic-key contract evaluates keys; it does not autoquote bare names.
With `key = "a"`, the following initialization expressions were tested through the
Rust CLI. All invocations exit zero and report compile:ok/invoke:ok:

| Expression | Rust result | Rust stderr |
| --- | --- | --- |
| `{ key : 7 }` | `{"a":7}` | empty |
| `{ key :7 }` | `{"a":7}` | empty |
| `{ key: 7 }` | `null` | expected colon at position 24 |
| `{key:7}` | `null` | expected colon at position 23 |
| `{"a":7}` | `{"a":7}` | empty |
| `{cat(key,""):7}` | `{"a":7}` | empty |

`LinkedSpec::call_spec_handler_subst` successfully lowers all six; the first four
produce the same `$key => 7` association. This is Perl lowering evidence, not six
fresh Perl runtime executions. The two failing Rust forms let `parse_name`
(`rust/linkedspec-core/src/expr.rs` 3556–3568) consume a single colon as part of the
name. `parse_hash_literal` then cannot find its separator; the separate `.45`
malformed-block fallback drops the initializer after warning. `.50` owns lexical
correction, preserved dynamic/quoted key semantics, and recurrence across supported
carriers, with namespace/keyword negative controls.

An initial computed-key control used one-argument `cat(key)`. Perl lowered that to
an unsupported-helper marker, so it was excluded and replaced with the valid
`cat(key, "")` control above. That observation led to the separate arity probe.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'HASH_COLON_BOUNDARY'
import subprocess,json
forms=[('bare_spaced','{ key : 7 }'),('bare_left_space','{ key :7 }'),('bare_right_space','{ key: 7 }'),('bare_compact','{key:7}'),('quoted_compact','{"a":7}'),('computed_compact','{cat(key,""):7}')]
for name,form in forms:
 action='key = "a"; out = '+form
 source='Top::\n I { '+action+' }\n /x/ E { return(out) }\n'
 rust=subprocess.run(['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','x','--trace','low'],capture_output=True,text=True,timeout=30)
 perl=subprocess.run(['perl','-Iperl','-MLinkedSpec','-e','my $s=$ARGV[0]; my $r=eval { LinkedSpec::call_spec_handler_subst("Top",$s) }; if($@){print STDERR $@;exit 1} print $r;',action],capture_output=True,text=True,timeout=30)
 bad=name in ('bare_right_space','bare_compact')
 assert rust.returncode==0 and '[linkedspec][low] compile:ok\n' in rust.stdout and '[linkedspec][low] invoke:ok\n' in rust.stdout,(name,rust)
 assert json.loads(rust.stdout.splitlines()[-1])==(None if bad else {'a':7}),(name,rust.stdout)
 assert ('expected \':\' in hash literal' in rust.stderr) if bad else not rust.stderr,(name,rust.stderr)
 assert perl.returncode==0 and not perl.stderr and 'UNSUPPORTED' not in perl.stdout,(name,perl.stdout,perl.stderr)
 print(json.dumps({'case':name,'source':source,'rust_exit':rust.returncode,'rust_stdout':rust.stdout,'rust_stderr':rust.stderr,'perl_lowering_exit':perl.returncode,'perl_lowering':perl.stdout,'perl_stderr':perl.stderr}))
HASH_COLON_BOUNDARY
```

## Cat minimum arity

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
not completion credit for their broader queued source-reading leaves. The earlier
`.49` regex-newline defect remains independent and pending.

Related: [[hash-literal-dynamic-key-contract]], [[hash-literal-colon-rust-parity]],
[[rust-action-parser-boundary-defects]], [[startup-public-teaching-checker-blind-spots]].
