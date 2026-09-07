---
id: rust-large-number-conversion-defect
title: Rust direct JSON conversion saturates large finite numbers and scalar text differs at 1e20
answers:
  - "why does Rust return 9223372036854775807 for 100000000000000000000"
  - "does Rust preserve large finite numbers in direct JSON results"
  - "does cat stringify 1e20 identically on Rust and Perl"
  - "does the scalar text fixture cover scientific notation"
  - "which task owns Rust large number saturation"
  - "is numeric JSON value preservation the same as scalar text formatting"
  - "why does a Rust nested write report an index smaller than 18446744073709551616"
  - "does Rust nested write classification saturate its maximum usize index"
date: 2026-09-07
status: current
tags: [rust, perl, numeric, scalar-text, json, reading, defect]
evidence: "SESSION-STARTUP-READING.3.3.10; four paired native controls at 236aa4d7a3ebd29a669bf653aacd204abfbb3a5b; rust/linkedspec-core/src/types.rs; rust/linkedspec-runtime/src/engine.rs execute_value_with_context; rust/linkedspec-runtime/src/primary_cli.rs; capability_conformance/scalar_text_contract.json; repair owners SESSION-STARTUP-READING.55.1-.55.3."
reverify: "Run the exact managed native comparison below after building the primary CLI with bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --bin linkedspec-rust."
---

Reading checkpoint `SESSION-STARTUP-READING.3.3.10` finds two distinct boundaries.
All four controls use a real explicit match edge, public Perl `Get`, and the existing
Rust primary CLI with low trace. All eight subprocesses exit zero with empty
stderr; Rust reports `compile:ok` and `invoke:ok`, while Perl reports a coderef,
empty compile/invoke exceptions and null `last_error`.

| Returned expression | Rust JSON result | Perl JSON result |
| --- | --- | --- |
| `42` | `42` | `42` |
| `100000000000000000000` | `9223372036854775807` | `1e+20` |
| `-100000000000000000000` | `-9223372036854775808` | `-1e+20` |
| `cat(100000000000000000000,"")` | `"100000000000000000000"` | `"1e+20"` |

The numeric rows change value, not merely JSON spelling. `RuntimeValue::Number`
stores `f64`. Its `to_json` finite integral branch casts directly to `i64`; this
saturates values beyond that integer range. `Engine::execute_value_with_context`
calls `value.to_json()` before staged completion, and the primary CLI serializes
that already-converted JSON value. Successful invocation therefore does not prove
correct numeric output. `.55.1` owns repair and exact finite-value boundary proof.

`to_str`, numeric `len` and `Display` also contain integral-number casts. Their
complete consumers, nested values, raw serde and generated routes were not
executed by this four-case probe. They are explicitly in the repair audit, not
additional measured public failures. Retained `f64` storage also does not promise
arbitrary-precision integer arithmetic.

The string row instead follows `to_scalar_text`, whose finite-number branch uses
direct `f64` formatting; Perl `cat` lowering uses host stringification. The neutral
scalar-text authority says "shortest stable decimal text" but its numeric samples
are only `-0.0`, `1.0` and `1.25`. Those examples cannot establish spelling at this
magnitude. `.55.2` owns reference-policy reconciliation and supported consumer
repair before frozen authority changes; `.55.3` owns public examples and recurring
backend/carrier closeout. This is separate from `cat` arity defect `.51` and strict
scalar numeric helper input authority `.20`.

Fresh neutral scalar-numeric proof remains 55 cases / 18 helpers. That passing
fixture does not close either conversion defect. No other backend, generated
route, arbitrary integer, NaN/infinity or i64-adjacent case is claimed measured.

Exact September 7 managed probe:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUST_LARGE_NUMBERS'
import subprocess,json
perl_program=r'''use JSON::PP;my $s=$ARGV[0];my %ctx;my $p=eval{LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx)};my $ce="$@";my $in="xhello";my $v;my $ie="";if(ref($p)eq"CODE"){$v=eval{$p->(\$in)};$ie="$@"}print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error}}),"\n";'''
for expr in ['42','100000000000000000000','-100000000000000000000','cat(100000000000000000000,"")']:
 source='Top::\n I { return('+expr+') }\n /x/ -> Done\nDone:\n /[a-z]+/\n'
 row={'expression':expr,'source':source}
 for route,args in [('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low']),('perl',['perl','-Iperl','-MLinkedSpec','-e',perl_program,source])]:
  try:
   p=subprocess.run(args,capture_output=True,text=True,timeout=30)
   row[route]={'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
  except subprocess.TimeoutExpired as e:row[route]={'timeout_seconds':30}
 print(json.dumps(row),flush=True)
RUST_LARGE_NUMBERS
```

Related facts: [[rust-native-direct-value-execution]],
[[scalar-to-text-coercion-cross-backend-gap]], [[cross-backend-scalar-numeric-drift]],
[[rust-hash-separator-and-cat-arity-defects]].

## September 7 nested-write index saturation

`SESSION-STARTUP-READING.3.3.17` extends `.55.1` with a measured unsigned
index conversion boundary. The current CLI rejects all three failing writes with
its deliberately generic invocation error. A repository-local Rust embedding then
loads four complete fixtures through `load_and_compile_spec` and calls
`execute_value_with_diagnostics`. The probe exits zero with empty stderr:

| Index in `items[index] = "x"`, after `items = []` | Native result |
| --- | --- |
| `0` | `["x"]` |
| `1` | `nested_write_array_gap`, index `1`, length `0` |
| `18446744073709551616` | `nested_write_array_gap`, index **`18446744073709551615`**, length `0` |
| `18446744073709555712` | `nested_write_segment_invalid`, reason `kind_not_path_selector` |

The third authored number is exactly representable as f64. On the measured 64-bit
target, `classify_write_path_segments` compares it with `usize::MAX as f64`,
which rounds upward to that same power of two. The accepted cast then saturates to
`usize::MAX`; the later dense-array gap diagnostic reports the changed index.
The next representable larger f64 fails the classifier instead. This is a bounded
diagnostic-identity defect; these controls do not show a successful out-of-range
write or establish a portable arbitrary-integer contract.

Existing `.55.1` now explicitly owns this classifier alongside signed JSON/text
conversion, with adjacent representable values and dense append/gap controls.
Other runtimes, generated carriers, nested segments and a complete numeric-range
census are not freshly measured. The recursive writer body remains a later reading
window; the coordinator/classifier range is engine lines 4733–4852.

Retained evidence, all under `.linkedspec-data/scratch/`:

- `startup76-write-index-boundary.jsonl`: 392 bytes; SHA-256 `3215cefb20fc025b915e98d605b500a038af1e4a2fe20b1d0b3f0782e814e2ce`.
- `startup76-write-index-native/probe.rs`: 831 bytes; SHA-256 `fa79c8362941695cf6ddc0a4f6ab549e8aaf38a4420f6d98ba75fee9f1865da3`.
- `startup76-write-index-native/probe`: 34,839,096 bytes; SHA-256 `4c02cd8627716261aefad33700e1e6b28bbb041e2dc1982b033a4795690cf957`.
- `startup76-write-index-native/stdout.log`: 3,612 bytes; SHA-256 `1648142c99b333ef672fae429667777fa07a62591727a8b220f546961c40c208`; stderr is zero bytes.

The probe links the existing managed-build runtime archive
`rust/target/debug/deps/liblinkedspec_runtime-3d20e574f9bdf113.rlib`,
51,910,968 bytes, SHA-256
`7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`.
The runtime source is unchanged from the preceding build. The initial harness
compile omitted handling the diagnostic serializer's Result; correcting that
harness produced the successful comparison without a runtime edit.

Exact retained probe source:

```rust
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
fn main() {
    let root = std::env::current_dir().expect("repository cwd");
    let options = SpecLoadOptions::new(&root);
    for name in ["append", "small_gap", "rounded_boundary", "above_boundary"] {
        let path = format!(".linkedspec-data/scratch/startup76-write-index-native/{name}.spec");
        let loaded = load_and_compile_spec(&SpecRequest::path(path), &options).expect("valid fixture");
        match loaded.into_engine().execute_value_with_diagnostics("xhello", &ExecutionOptions::new()) {
            Ok(value) => println!("{name} OK {value}"),
            Err(error) => println!("{name} ERROR {}", error.to_json().expect("serializable diagnostic")),
        }
    }
}
```

To reproduce from current source, build the library with
`bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline --jobs 1 -p linkedspec-runtime --lib`.
Recreate the four named fixtures below the probe directory with this common source,
substituting the table's exact index for `INDEX`:

```text
Top::
 I { items = []; items[INDEX] = "x"; return(items) }
 /x/ -> Done
Done:
 /[a-z]+/
```

Save the retained Rust source as that directory's `probe.rs`, then use the current
build's stable library artifact instead of assuming the recorded hashed archive exists:

```bash
bash tools/project_data_run.sh rustc --edition=2024 --crate-name startup76_write_index_probe .linkedspec-data/scratch/startup76-write-index-native/probe.rs -L dependency=rust/target/debug/deps --extern linkedspec_runtime=rust/target/debug/liblinkedspec_runtime.rlib -o .linkedspec-data/scratch/startup76-write-index-native/probe &&
bash tools/project_data_run.sh .linkedspec-data/scratch/startup76-write-index-native/probe
```
