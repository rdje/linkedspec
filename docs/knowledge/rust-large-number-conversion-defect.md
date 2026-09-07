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
