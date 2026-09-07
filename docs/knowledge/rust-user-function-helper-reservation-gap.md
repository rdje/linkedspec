---
id: rust-user-function-helper-reservation-gap
title: Rust permits current gap helpers to be shadowed by user-defined functions
answers:
  - "can a Rust user function be named gap_text"
  - "can a Rust user function replace entry_slot"
  - "why does Perl reject a gap_text function that Rust accepts"
  - "is the Rust built-in function reservation list complete"
  - "which task owns current helper name reservation drift"
date: 2026-09-07
status: confirmed defect; SESSION-STARTUP-READING.56 owns repair
tags: [rust, perl, user-functions, registry, helpers, gap-capture, defect]
evidence: "SESSION-STARTUP-READING.3.3.12 at activation 75ce8db839888a5091d25ee4e5e1c3c501daf3b8; four paired public native controls; rust/linkedspec-core/src/validation.rs check_function_registry/is_known_actionir_call_name; rust/linkedspec-runtime/src/engine.rs eval_expr; perl/LinkedSpec/UserFunctionRegistry.pm _validate_function_name/_known_actionir_call_name."
reverify: "Run the exact managed comparison below after building the primary CLI with bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --bin linkedspec-rust."
---

Four same-shape definitions return `"sentinel"` through an ordinary user-function
call in a real explicit-edge spec. The custom name and an established forbidden
name control for definition syntax and reservation behavior.

| Function name | Rust primary CLI | Perl public Get |
| --- | --- | --- |
| `custom_value` | Compiles and returns `"sentinel"` | Compiles and returns `"sentinel"` |
| `trim` | Compilation failure, exit 1 | Registry rejects built-in helper/control collision |
| `gap_text` | Compiles and returns `"sentinel"` | Registry rejects built-in helper/control collision |
| `entry_slot` | Compiles and returns `"sentinel"` | Registry rejects built-in helper/control collision |

Accepted Rust runs exit zero with `compile:ok`/`invoke:ok` and empty stderr.
Perl subprocesses exit zero; the invalid definitions return no parser and retain
`type=compiler_pipeline`, `stage=function_registry` and
`owner_stage=compiler_pipeline:function_registry` in `last_error`. Each detail
names the exact colliding helper. None of the eight subprocesses times out.

Rust's `check_function_registry` consults a manually copied helper/control-name
list that omits these two current helpers. `Engine::eval_expr` checks registered
functions before ordinary eager-helper fallback, so the admitted definition
actually replaces the helper at the observed call. Earlier special dispatch and
arity checks still exist; this is not a claim that every reserved name can be
overridden. Perl delegates reservation to MethodLowering's current known-value-call
resolver through `UserFunctionRegistry::_known_actionir_call_name`.

`SESSION-STARTUP-READING.56.1` owns complete reference-authority comparison and
exact diagnostic fixtures; `.56.2` owns Rust repair and mechanically maintained
coverage; `.56.3` owns supported backend/carrier recurrence and public closeout.
No other omitted helper, method-only name, parameter collision or generated route
is asserted freshly measured. The existing 21 core validation tests pass, including
their older trim/numeric-alias controls; they do not cover these two names.

Exact managed comparison:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'SLICE71_FUNCTION_NAMES'
import subprocess,json
perl_program=r'''use JSON::PP;my $s=$ARGV[0];my %ctx;my $p=eval{LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx)};my $ce="$@";my $in="xhello";my $v;my $ie="";if(ref($p)eq"CODE"){$v=eval{$p->(\$in)};$ie="$@"}print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error}}),"\n";'''
for name in ['custom_value','trim','gap_text','entry_slot']:
 source='fn '+name+'() { return("sentinel") }\nTop::\n I { return('+name+'()) }\n /x/ -> Done\nDone:\n /[a-z]+/\n'
 row={'function':name,'source':source}
 for route,args in [('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello','--trace','low']),('perl',['perl','-Iperl','-MLinkedSpec','-e',perl_program,source])]:
  try:
   p=subprocess.run(args,capture_output=True,text=True,timeout=30)
   row[route]={'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
  except subprocess.TimeoutExpired:row[route]={'timeout_seconds':30}
 print(json.dumps(row),flush=True)
SLICE71_FUNCTION_NAMES
```

Related: [[rust-user-function-registry-parity]], [[rust-user-function-runtime-parity]],
[[terse-user-function-registry-seam]], [[inter-match-gap-rust-implementation-plan]].
