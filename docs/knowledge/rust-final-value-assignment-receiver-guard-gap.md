---
id: rust-final-value-assignment-receiver-guard-gap
title: "Rust final value-block assignments bypass the active map_leaves receiver guard"
answers:
  - "why does a final Rust map_leaves callback assignment bypass the receiver guard"
  - "does Rust reject final same-receiver nested writes inside map_leaves bang"
  - "which task owns the Rust final-expression receiver guard repair"
  - "why does adding return value change Rust map_leaves receiver-write rejection"
date: 2026-09-07
status: confirmed defect; repair owned by SESSION-STARTUP-READING.58.1-.3 after startup prerequisites
tags: [rust, mutation, map-leaves, assignment, guard, value-block, diagnostics]
evidence: "SESSION-STARTUP-READING.3.3.19 compares six exact fixtures through the verified Rust primary CLI and Perl Get at clean activation acbadc0fce4abdc03585c0fd26c9a1f7545958e2. Rust accepts final scalar/nested writes to the active tree receiver; Perl rejects both with receiver_mutation_reentrant. Nonfinal and explicit-return controls reject on both, while unrelated final assignment agrees. Complete engine reading locates the final-assignment bypass around eval_expr's guard."
reverify: "Recreate the six fixtures below and run the current managed Rust primary command and Perl Get/runtime_ctx_ref as described below; .58.1 owns exact native diagnostic and state assertions at repair time."
---

# Final value-block receiver-write guard gap

Use input `xhello` and this complete source, replacing `BODY` with one table row:

```text
Top::
 I { tree = { "a" : "A" }; result = tree.map_leaves!() { BODY }; return([tree, result]) }
 /x/ -> Done
Done:
 /[a-z]+/
```

| Fixture | BODY | Rust primary CLI | Perl Get |
| --- | --- | --- | --- |
| assign_final | `tree = {}` | exit 0; `[{"a":{}},{"a":{}}]` | receiver_mutation_reentrant / assign |
| assign_nonfinal | `tree = {}; return(value)` | exit 1; generic invocation failure | receiver_mutation_reentrant / assign |
| nested_final | `tree["x"] = value` | exit 0; `[{"a":{"a":"A","x":"A"}},{"a":{"a":"A","x":"A"}}]` | receiver_mutation_reentrant / nested_write |
| nested_nonfinal | `tree["x"] = value; return(value)` | exit 1; generic invocation failure | receiver_mutation_reentrant / nested_write |
| assign_return | `return(tree = {})` | exit 1; generic invocation failure | receiver_mutation_reentrant / assign |
| unrelated_final | `other = {}` | exit 0; `[{"a":{}},{"a":{}}]` | same successful value; no last_error |

Rust successes have empty stderr; failures have empty stdout and only
`linkedspec: parser invocation failed` on stderr. That CLI message alone does not
identify an internal diagnostic code. All six Perl parsers are constructed;
build/call exception strings and warning arrays are empty. Its five rejected
calls return null and record a typed detail under `last_error`; the successful
control has no last_error. Existing failure trace output is captured separately.

## Mechanism and repair ownership

`rust/linkedspec-runtime/src/engine.rs`'s `eval_block_value` (7601) sends the last active statement to
`eval_block_final_expr` (7740). Its scalar-assignment and nested-write branches
evaluate/store directly instead of calling the guarded `eval_expr` entry (5544).
Nonfinal statements pass through `execute_block_statement_expr`'s guard (4263);
an explicit return evaluates its payload through `eval_expr`, so those controls
reject. The nested-write coordinator (4733) and `RuntimeContext::set_scalar`
in `rust/linkedspec-runtime/src/runtime.rs` (2038)
do not supply a replacement receiver guard. Supporting runtime source reading
is limited to that setter and neighboring scoped-binding implementation.

The bang coordinator still commits its rebuild after callback success, but an
unguarded final write can modify the active receiver during rebuilding and feed
that modified root into the callback result. The observed success values above
are the evidence; this is not a claim about every write form or failure sequence.

`SESSION-STARTUP-READING.58.1` owns the shared final-expression fix, exact typed
diagnostics, pre-evaluation segment/RHS rejection, state rollback/guard cleanup,
and legal unrelated/shadow controls. `.58.2` owns other callback routes and
native/reconstructed/generated/emitted carrier recurrence; `.58.3` owns public
teaching and canonical closeout. No runtime repair is claimed by this reading.

The existing native contract's authored assignment/nested-write cases at
`rust/linkedspec-runtime/tests/map_leaves_mutation_contract.rs` 540–546 include
a following `return(value)`. Passing those cases, or the neutral 167 base and
592 composition mutations, does not prove the missing final-expression route.

## Reproduction and retained evidence

All six fixtures and collectors are under
`.linkedspec-data/scratch/startup78-receiver-guard/`. Recreate each named
`.spec` from the template/table if that disposable directory is absent.
Build the current CLI with
`bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml -p linkedspec-runtime --bin linkedspec-rust`,
then invoke it through the project environment, for example:

```bash
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --spec-file .linkedspec-data/scratch/startup78-receiver-guard/assign_final.spec --input xhello
```

The recorded CLI run used `--inline-spec` with the exact fixture text, not a
different source. Its binary is 34,992,496 bytes, SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`,
from the preceding managed build; runtime source remains baseline-identical.
Perl uses `LinkedSpec::Get(\$source, runtime_ctx_ref => \%context)` then invokes
the parser with a reference to `xhello` and reads `$context{last_error}`.
The retained collector recursively projects blessed hash/array error details
before JSON encoding. Its first attempt failed to serialize that object; the
initial source/stdout/stderr are retained separately and provide no completed
six-case evidence.

Related: [[map-leaves-mutation-rust-runtime]],
[[rust-callable-codeblock-dynamic-invocation]], and
[[write-map-leaves-neutral-composition]].

## Direct native diagnostic confirmation

A fresh small Rust harness loads the same six source files through
`load_and_compile_spec` and calls `execute_value_with_diagnostics`.
It exits 0 with empty stderr. Three successful values exactly match the CLI;
the three failures have `runtime_execution` / rule `Top` envelopes with
`receiver_mutation_reentrant`, binding `tree`, and the expected assign or
nested_write attempt. Their authored Unicode-scalar spans are [52,56) for
nonfinal writes and [59,63) for the explicit-return control. The outer diagnostic
detail equals the serialized error message. Independent assertions check every
case and these fields; they do not infer generated-carrier or other-backend results.

Exact native source:

```rust
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
fn main() {
    let root = std::env::current_dir().expect("repository cwd");
    let options = SpecLoadOptions::new(&root);
    for name in ["assign_final", "assign_nonfinal", "nested_final", "nested_nonfinal", "assign_return", "unrelated_final"] {
        let path = format!(".linkedspec-data/scratch/startup78-receiver-guard/{name}.spec");
        let loaded = load_and_compile_spec(&SpecRequest::path(path), &options).expect("valid fixture");
        match loaded.into_engine().execute_value_with_diagnostics("xhello", &ExecutionOptions::new()) {
            Ok(value) => println!("{name} OK {value}"),
            Err(error) => println!("{name} ERROR {}", error.to_json().expect("serializable diagnostic")),
        }
    }
}
```

After recreating the fixtures and saving that source as `probe.rs`, build the
current stable library with
`bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib`
and compile/run the probe:

```bash
bash tools/project_data_run.sh rustc --edition=2024 --crate-name startup78_receiver_guard_probe .linkedspec-data/scratch/startup78-receiver-guard/probe.rs -L dependency=rust/target/debug/deps --extern linkedspec_runtime=rust/target/debug/liblinkedspec_runtime.rlib -o .linkedspec-data/scratch/startup78-receiver-guard/probe &&
bash tools/project_data_run.sh .linkedspec-data/scratch/startup78-receiver-guard/probe
```

The recorded compilation instead reused the verified prior managed archive
`rust/target/debug/deps/liblinkedspec_runtime-3d20e574f9bdf113.rlib`,
51,910,968 bytes, SHA-256
`7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`.
Its source was unchanged. Retained evidence under the same scratch directory:

| File | Bytes | SHA-256 |
| --- | --- | --- |
| rust-cli.jsonl | 629 | 4a407217c9cccc6c2fb6988dd6f918be2d3c3dab1d11136c98c457dad1b0389c |
| perl-results.jsonl | 3981 | f3a60fddbc9089d3eb389a7167c139ab3bfb9956da479f7f41c6e62debbf24eb |
| perl_probe.pl | 1446 | b673a5df79bd9ce1554a4144acc341db275dd229d951f5db75f1af5f86653af6 |
| probe.rs | 873 | 138d060271116c04229ceebf79592a56d490f1e43d3f8e115944912cf46e632c |
| probe | 34838536 | 4e675cb5d0894bf094f618346eb7c55c25e1618b867e06539f5458676d6cbdf9 |
| stdout.log | 3371 | c160222cc4f7c4160c285845cce01f2a25a4830477629032a487a8ca7e895bac |

Native `stderr.log` and corrected Perl `perl-stderr.log` are empty. Raw runtime
diagnostics retain their resolved source-path attribution; the fixtures, commands
and tracked references derive all project paths from the current repository root.
