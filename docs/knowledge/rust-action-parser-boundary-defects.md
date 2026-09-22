---
id: rust-action-parser-boundary-defects
title: Rust rule-block error propagation and separately owned parser boundary defects
answers:
  - why can malformed Rust lifecycle code compile successfully
  - why does a Rust rule code block disappear after a warning
  - why do Rust nested write parser errors become warnings
  - can Rust malformed expression diagnostics panic on Unicode
  - why does Rust map_leaves mutation reject whitespace inside empty parentheses
  - where are the Rust parser compiler boundary repairs tracked
  - did the whole spec Unicode CLI probe demonstrate a panic
  - why does a Rust regex assignment followed by a newline return null
  - why does adding a regex suffix flag change Rust statement parsing
date: 2026-09-22
status: .45.1 compiler correction verified; carrier closeout and .46/.47/.49 parser repairs remain
tags: [rust, parser, compiler, diagnostics, unicode, mutation, startup-reading]
evidence: "September 7 native diagnostics established warning/drop, Unicode diagnostic, mutation-whitespace and regex-boundary defects under .45/.46/.47/.49. Startup .45.1 now propagates every reported rule-code parse error. Twelve native pre-repair invalid cases wrongly compile; four new core rejection groups fail before repair and all five groups pass after it, covering 15 malformed contexts and 11 retained valid blocks. The complete Rust component gate and rebuilt native/quoted-LF controls pass; this change does not repair the separately owned parser causes."
reverify: "Run bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --test rule_code_rejection and bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --lib primary_cli::tests::malformed_rule_code_stops_before_input_loading_or_invocation. Historical diagnostic commands below intentionally describe incorrect pre-repair behavior, not current acceptance. Reconcile separate .46/.47/.49 parser repairs."
---

The first three observations came from forward source reading under the frozen `.3.2.55` canonical candidate; its commit body preserves their original commands and results. The regex CLI comparison completed during `.3.3.1`, using unchanged source after that canonical checkpoint committed. `.3.3.1` makes the pending repair owners and this retrievable record explicit; ADR0123 now permits targeted reading before repairs while preserving the separate full audit.

## Rule-block error propagation — repair .45

At the pre-repair baseline, `rust/linkedspec-core/src/compiler.rs::parse_rule_code_block` warned and returned `Ok(None)` for errors outside five recognized diagnostic prefixes. `compile_rule` discarded that missing block. Function-body parsing already propagated errors. Startup .45.1 changes the shared boundary to `Result<CodeBlock>`: every reported parse error retains its rule/block attribution and parser detail as `LinkedSpecError::Compile`. Optional absent edge code stays absent; authored code can no longer become an absent block after a parse error. Carrier proof and canonical closeout remain .45.2/.45.3; independent parser acceptance defects retain their existing owners.

Eleven historical CLI controls established five wrong acceptances: malformed ordinary E and I blocks, an empty nested-write segment, a reserved nested-write root, and nonempty mutation arguments. The process exited zero, emitted `compile:ok` and `invoke:ok`, and returned null or the surviving block's 42. Valid E, nested-write, and quoted-key mutation controls returned 42, `{"x":1}`, and `{"a":2}`. Malformed function code, removed fat-arrow hash syntax, and duplicate authored rules rejected. Do not infer an authored duplicate-rule defect from descriptor map behavior, or a mutation key-loss defect from ordinary unbound expression-key semantics.

## Unicode diagnostic excerpt can panic — repair .46

`rust/linkedspec-core/src/expr.rs` uses `unexpected_character_error` to slice `src[pos..min(pos + 40, src.len())]`. The raw byte endpoint can be inside a Unicode scalar. The isolated core program below observes an error for ASCII and an aligned Unicode boundary, parses valid Unicode, and catches a panic for `@` followed by twenty e-acute characters. The observed source location is `expr.rs:2702:22`, with byte 40 inside scalar bytes 39..41. `catch_unwind` belongs only to the diagnostic harness; it is not a production repair.

An earlier whole-spec CLI attempt timed out at 30 seconds on a long malformed ASCII body before reaching any Unicode cases. It was reaped by the subprocess timeout; a later help command completed in 0.011 seconds. Neither fact establishes the timeout's cause or a public CLI Unicode panic. Repair .46 must resolve that route separately.

## Empty mutation arguments disagree across validation — repair .47

The core parser accepts `tree.map_leaves!() { value }`, `tree.map_leaves!( ) { value }`, and the tab-only equivalent because it uses `trim().is_empty()`. Compilation accepts only the exact `()` projection; the other two produce `receiver_mutation_serialized_state_invalid` with reason `mutation_call_invalid`. Repair must reconcile semantic emptiness while retaining authored source/spans and rejecting nonempty arguments.

## Reproduce the bounded observations

These commands diagnose the pre-repair baseline; assertions that reproduce incorrect acceptance are not implementation signoff. Rebuild through the managed command above before using current results. Source baseline at diagnosis was `baeb984e36a94a15951cd23d4c52def5064cdaca`, with the read ranges unchanged.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUST_RULE_BLOCK_DIAGNOSIS'
import subprocess,json
cases=[
 ('valid_e','Top::\n /x/ E { return(42) }\n',0,42,''),
 ('invalid_e','Top::\n /x/ E { return(@invalid) }\n',0,None,"unexpected character '@'"),
 ('invalid_i','Top::\n I { return(@invalid) }\n /x/ E { return(42) }\n',0,42,"unexpected character '@'"),
 ('invalid_function','fn bad(value) { return(@invalid) }\nTop::\n /x/ E { return(42) }\n',1,None,''),
 ('governed_removed_hash','Top::\n /x/ E { return({ old => value }) }\n',1,None,''),
 ('duplicate_rule','Top::\n /x/ E { return(1) }\nTop:\n /x/ E { return(2) }\n',1,None,''),
 ('valid_nested','Top::\n I { tree["x"] = 1 }\n /x/ E { return(tree) }\n',0,{'x':1},''),
 ('invalid_empty_segment','Top::\n I { tree[] = 1 }\n /x/ E { return(42) }\n',0,42,'nested_write_segment_empty'),
 ('invalid_reserved_root','Top::\n I { retv["x"] = 1 }\n /x/ E { return(42) }\n',0,42,'nested_write_root_reserved'),
 ('valid_mutation','Top::\n I { tree = { "a" : 1 }; tree.map_leaves!() { add(value, 1) } }\n /x/ E { return(tree) }\n',0,{'a':2},''),
 ('invalid_mutation_argument','Top::\n I { tree = { "a" : 1 }; tree.map_leaves!(1) { value } }\n /x/ E { return(42) }\n',0,42,'map_leaves_mutation_arguments_invalid'),
]
for name,source,status,value,warning in cases:
 p=subprocess.run(['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','x','--trace','low'],capture_output=True,text=True,timeout=30)
 assert p.returncode==status,(name,p.returncode,p.stdout,p.stderr)
 if status==0:
  assert '[linkedspec][low] compile:ok\n' in p.stdout and '[linkedspec][low] invoke:ok\n' in p.stdout,name
  assert json.loads(p.stdout.splitlines()[-1])==value,(name,p.stdout)
  assert (warning in p.stderr and p.stderr.startswith('warning:')) if warning else not p.stderr,(name,p.stderr)
 else:
  assert p.stdout=='[linkedspec][low] compile:start\n[linkedspec][low] compile:error\n',(name,p.stdout)
  assert p.stderr=='linkedspec: parser compilation failed\n',(name,p.stderr)
 print(json.dumps({'case':name,'observed_exit':status,'observed_value':value,'warning':warning,'diagnosis_assertions':'PASS'}))
print('11 diagnostic controls pass: five malformed rule blocks wrongly accepted, three valid controls, three rejecting controls; repair pending.')
RUST_RULE_BLOCK_DIAGNOSIS
```

The isolated core program linked `rust/target/debug/deps/liblinkedspec_core-8ccc70b6cbac494c.rlib`, SHA-256 `00ae49cb86c41019a424f69eb488373d0d4caef0bbdb34f9c11642fbb10789df`. The build and harness exited zero; the harness ran in 0.631 seconds. Scratch was created under managed repository-local `TMPDIR`, checked on the repository device, removed, and its absence verified. The command records the actual library identity on each new run.

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'CORE_DIAGNOSTIC'
from pathlib import Path
import os,tempfile,subprocess,json,time,hashlib
root=Path.cwd(); deps=Path('rust/target/debug/deps')
libs=list(deps.glob('liblinkedspec_core-*.rlib')); assert libs
library=max(libs,key=lambda p:p.stat().st_mtime_ns)
print(json.dumps({'library':library.as_posix(),'sha256':hashlib.sha256(library.read_bytes()).hexdigest()}),flush=True)
with tempfile.TemporaryDirectory(prefix='startup-core-diagnosis-',dir=os.environ['TMPDIR']) as scratch:
 work=Path(scratch); src=work/'probe.rs'; binary=work/'probe';src.write_text(r'''use linkedspec_core::{expr::CodeBlock, parser::parse_spec, compiler::compile};
fn main() {
    for (name, source) in [("ascii_error", "@invalid".to_string()), ("unicode_boundary", format!("@{}a", "é".repeat(19))), ("unicode_split", format!("@{}", "é".repeat(20))), ("unicode_valid", "return(\"é\")".to_string())] {
        let result = std::panic::catch_unwind(|| CodeBlock::parse(&source));
        match result {
            Ok(Ok(_)) => println!("{name}: parsed"),
            Ok(Err(error)) => println!("{name}: error={error}"),
            Err(_) => println!("{name}: panicked"),
        }
    }
    for (name, inside) in [("empty", ""), ("space", " "), ("tab", "\t")] {
        let body = format!("tree.map_leaves!({inside}) {{ value }}");
        println!("mutation_{name}: parsed={}", CodeBlock::parse_with_callable_candidates(&body).is_ok());
        let source = format!("Top::\n I {{ {body} }}\n /x/\n");
        let ast = parse_spec(&source).expect("outer parser control");
        match compile(&ast) {
            Ok(_) => println!("mutation_{name}: compiled"),
            Err(error) => println!("mutation_{name}: compile_error={error}"),
        }
    }
}
''')
 assert work.stat().st_dev==root.stat().st_dev
 command=['rustc','--edition=2024','--crate-name','startup_core_diagnosis','--extern','linkedspec_core='+library.as_posix(),'-L','dependency='+deps.as_posix(),str(src),'-o',str(binary)]
 build=subprocess.run(command,capture_output=True,text=True,timeout=180);print(json.dumps({'build_exit':build.returncode,'build_stderr':build.stderr.replace(str(root)+'/', '')}),flush=True);assert build.returncode==0
 start=time.monotonic();run=subprocess.run([str(binary)],capture_output=True,text=True,timeout=120)
 print(json.dumps({'exit':run.returncode,'seconds':round(time.monotonic()-start,3),'stdout':run.stdout,'stderr':run.stderr.replace(str(root)+'/', '')}),flush=True)
assert not Path(scratch).exists();print('Exact diagnostic workspace removed and absence verified.')
CORE_DIAGNOSTIC
```

## Regex suffix scan consumes the following statement — repair .49

The four native controls below compare `rx = /x/; out = 7`, the newline-separated equivalent, an adjacent `i` suffix before the newline, and a string assignment before the newline. Three return seven without warnings; only the unflagged newline form warns that I-block parsing expected a statement separator at byte 13 and returns null, while reporting compile/invoke success. `parse_regex` in `rust/linkedspec-core/src/expr.rs` calls `skip_whitespace` before consuming ASCII alphabetic suffix flags, so it consumes the following `out` identifier. Repair .45 separately owns the warning/drop fallback exposed by this invalidated block.

A standalone core reproduction attempted first timed out during `rustc` compilation after 180 seconds and never ran. Its subprocess was reaped; the exact owned scratch directory was confirmed absent. That timeout is not the evidence for the parser defect. The native commands completed in 2.095, 1.230, 1.246, and 1.230 seconds respectively; all exited zero. Group .3.3.7's read range remains baseline-identical (1,497 lines / 56,871 bytes, SHA-256 `83ff42b72d5dd9222751deb14c81e889da99c2c937ceb0b0e388f32e3f180788`).

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUST_REGEX_CLI_BOUNDARY'
import subprocess,json,time
cases=[('semicolon','rx = /x/; out = 7'),('newline','rx = /x/\nout = 7'),('flagged_newline','rx = /x/i\nout = 7'),('string_newline','rx = "x"\nout = 7')]
for name,body in cases:
 source='Top::\n I { '+body+' }\n /x/ E { return(out) }\n'
 started=time.monotonic()
 p=subprocess.run(['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','x','--trace','low'],capture_output=True,text=True,timeout=30)
 print(json.dumps({'case':name,'exit':p.returncode,'seconds':round(time.monotonic()-started,3),'stdout':p.stdout,'stderr':p.stderr}),flush=True)
RUST_REGEX_CLI_BOUNDARY
```

Related facts: [[rust-aggregate-selector-compile-rejection]], [[rust-generic-final-codeblock-normalization]], [[map-leaves-mutation-rust-runtime]], [[rust-project-data-ssd-storage]].

## September 7 newline-copy recurrence

The exact bare-variable copy/newline case in [[rust-bare-variable-newline-consumption]] reached .45's
pre-repair warning/drop fallback: semantic construction reported compiled and the CLI returned null despite discarding the I block.
The semicolon twin avoided that parse failure. Task .69 owns the variable-lookahead separator cause; .45 retains
compiler rejection ownership. This control is not evidence that the intended copied-token body ran.

## September 22 strict-document prototype recurrence

Startup .83.1 independently reproduced the same .45 boundary on a fresh native
primary binary. Nonportable infix comparison in an LX block produced a parse
warning, yet the process exited 0 and the block was absent. The supported spelling
is num_ne(cursor_pos(), input_end_pos()); operator symbols are ordinary calls,
not an infix authoring grant. Correcting the prototype does not fix the compiler.
At clean design activation 8259719f8, compiler.rs:1075-1088 returned Ok(None)
for this parse error, and compile_rule:1303-1310 discarded it. The exact fresh record is
.linkedspec-data/scratch/sexpr-contract/compiler-drop-reproduction.json.
Bounded .45.1 owns rejection at the common boundary, .45.2 owns supported carrier
proof, and .45.3 owns canonical/public closeout before strict grammar delivery.

## Shared-boundary correction under startup .45.1

`rust/linkedspec-core/tests/rule_code_rejection.rs` exercises the public compiler:
all seven lifecycle blocks, explicit and bare action/blind edges, the malformed
document guard and three invalid write/mutation contexts. Four rejection groups
fail before the repair; all five groups pass after it, including preservation of
eleven valid lifecycle/edge blocks. The primary CLI test in `rust/linkedspec-runtime/src/primary_cli.rs`
checks rejection before both literal-input execution and deferred file loading.
The complete Rust component gate passes, including 228 core tests, runtime/shipped/corpus tests, CLI conformance in both environments and managed storage. The rebuilt primary command rejects all 12 invalid controls before input/invocation, preserves three valid values and passes all three committed quoted-LF fixtures. Raw logs and binary identity are under `.linkedspec-data/scratch/compiler-rejection45`.
