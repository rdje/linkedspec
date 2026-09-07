---
id: rust-generated-recognition-parse-adapter-gap
title: Rust recognition emission changes plain parse projection while inert-option siblings keep the accumulator
answers:
  - "why does generated recognition parse return a different shape with default options"
  - "does disabled tracing change generated Rust recognition parse results"
  - "which task repairs generated recognition parse sibling result coherence"
  - "why does a generated recognition module have an unused execute_generated_parser import"
date: 2026-09-07
status: dated native emitted-module counterexample; repair pending under SESSION-STARTUP-READING.72
tags: [rust, generated-source, recognition, result-shape, options, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.34 compiles and executes two actual emitted modules with five entrypoints each; all runtime calls succeed and stderr is empty."
reverify:
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup93-generated-boundaries/runner"
  - "rg -n 'compiled_spec_contains_recognition_runtime_intrinsic|compatibility_parse|direct_parse' rust/linkedspec-runtime/src/source_emitter.rs"
---

# Inert adapter options change recognition result shape

The same input c and initial action returning "ok" produce these fresh native results:

| Emitted module | execute | parse | parse_with_options(default) | parse_with_trace(disabled) | parse_with_diagnostic_output(None) |
| --- | --- | --- | --- | --- | --- |
| ordinary initial return | "ok" | ["ok"] | ["ok"] | ["ok"] | ["ok"] |
| checkpoint / recognize_once Child / rollback / initial return | "ok" | "ok" | ["ok"] | ["ok"] | ["ok"] |

The recognition control is the legal return-value twin in [[rust-recognition-token-variable-use-gap]]:
return("ok") follows rollback, Top has /never/, and Child has /c/. It is accepted and executes normally.
No forbidden token use or parser-warning/drop path is involved.

`rust/linkedspec-runtime/src/source_emitter.rs` 712–720 detects a recognition intrinsic anywhere in compiled
functions or rule lifecycle/action/blind blocks, then rewrites only the emitted plain `parse(input)` body
to call typed `execute`. Its options/trace/sink siblings retain the accumulator-returning compatibility
adapters. This explains the measured shape change; no runtime unwrap or JSON conversion inference is needed.
The detection scans all compiled functions/rules, not only the selected entry. Unused-intrinsic and alternate
entry controls remain repair acceptance, not fresh measurements.

The rewrite also leaves the generated execute_generated_parser import unused: native rustc reports that
single unused-import warning in recognition_module.rs. The harness makes both modules private and calls only
five public roles; its 34 dead-code warnings are separately explained by those intentionally uncalled roles.
The executable compiles successfully with 35 warnings, then runs successfully without stderr.

.72 owns coherent accepted projections across sibling APIs, emitted import accuracy, recurrence and public
teaching. The intentional ordinary typed-value versus compatibility-accumulator distinction remains valid.
[[rust-generated-source-v1-result-projection]] must be read with this recognition exception.

All inputs, emitted modules, native sources/commands/statuses and compiler output are retained under
`.linkedspec-data/scratch/startup93-generated-boundaries/`. Its final manifest covers 66 files/68,030,768 bytes;
the manifest itself is 13,446 bytes, SHA-256 `efca34731a315b8f34dbd92d02d9be4ffd00f172fb3b40ef91abda228f795580`.
Independent assertions are 689 bytes, SHA-256
`33d25d8edb7bb7c799465e949ab0c5c94e722a55c10da99fee5609df1e585f64`.
The emitter probe compile/run take 283.710/10.529 seconds; runner compile/run take 110.168/1.373 seconds.
The linked runtime and serde library hashes are independently rechecked against the recorded prior identities.
These are dated binaries; rebuild against the current runtime for repair proof. No compiler delay cause is inferred.
