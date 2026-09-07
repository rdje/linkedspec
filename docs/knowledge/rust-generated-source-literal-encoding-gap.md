---
id: rust-generated-source-literal-encoding-gap
title: Rust generated source accepts identities whose JSON escapes are invalid Rust literals
answers:
  - "why does generated Rust fail to compile a control character source identity"
  - "is serde_json string encoding valid for every Rust string literal"
  - "which task repairs generated Rust source identity escaping"
date: 2026-09-07
status: dated native compiler counterexamples; repair pending under SESSION-STARTUP-READING.71
tags: [rust, generated-source, literals, identity, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.34 emitted seven nonempty identities through emit_rust_source_v2, then compiled each module with the verified native runtime and serde libraries."
reverify:
  - "bash tools/project_data_run.sh perl tools/check_generated_source_contract.pl"
  - "rg -n 'rust_string_literal|source_identity_literal|label_literal' rust/linkedspec-runtime/src/source_emitter.rs"
---

# Accepted identity strings can produce uncompilable source

The public emitter rejects an empty source identity with generated_source_emit_failed at emit_source,
but accepts all seven nonempty native controls. ASCII, quote/backslash plus LF/TAB, and Unicode é modules
compile successfully. NUL, backspace, formfeed and U+0001 modules fail in the generated identity constant.

The common encoder in `rust/linkedspec-runtime/src/source_emitter.rs` 1464–1466 calls
`serde_json::to_string`. Its caller at 428 encodes source_identity and writes that result as Rust source at
459–460. JSON's backspace/formfeed escapes and four-hex-digit Unicode escapes are not valid Rust string
literal spellings. The compiler reports unknown character escapes for backspace/formfeed and incorrect
Unicode escape sequences for NUL/U+0001. These are source compilation failures after successful emission,
not parser execution, filesystem-name restrictions, or a failed contract check.

The same helper also encodes rule labels; the compiled JSON literal separately uses serde_json at 419.
Those literal boundaries need review under .71; this
measurement does not claim each has an independently reachable failing input. In particular nested JSON
has a separate encoding layer, and label grammar bounds caller-controlled label strings. A repair must
preserve accepted values exactly, including a literal backslash followed by u; blindly replacing escape
substrings would not establish that property.

Scratch `.linkedspec-data/scratch/startup93-generated-boundaries/` retains identities, public-loader
specifications, emitter probe, emitted sources, native commands, compiler outputs and per-phase exit statuses.
Source reading is baseline-identical; no implementation repair has been made. Fresh neutral generated proof
passes ten families and strict Rust105/105, with capability census100/0/0. The neutral fixtures do not cover
these source-identity controls. Metadata compilation alone does not establish successful value round trips;
.71 requires native execution of repaired emitted modules as well.

The shared final artifact manifest and independent assertion identities are recorded in
[[rust-generated-recognition-parse-adapter-gap]]; all seven module compilation results were consumed.
