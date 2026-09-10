---
id: rust-ci-pgen-missing-input-rebuilds
title: PGEN watches absent optional parser files during repeated Rust CI builds
answers:
  - "why does PGEN rebuild when its source has not changed"
  - "can LinkedSpec skip RGX and PGEN builds until the submodule revision changes"
  - "which missing PGEN parser inputs cause repeated build-script invalidation"
  - "does local CI already retain a shared Rust target directory"
  - "which recurring drivers discard their Rust dependency targets"
  - "what task owns correct PGEN and RGX build reuse"
  - "how much Rust build time was observed during containment 10"
date: 2026-09-10
status: observed source and metadata mechanism; repair and measured warm reuse pending
tags: [rust, pgen, rgx, cargo, ci, performance, startup]
evidence: "SESSION-STARTUP-READING.80.0; clean capacity commit bef5dafd; exact build.rs bytes, saved Cargo metadata, eight file observations and eleven completed build stages"
reverify: "Replay CI_BUILD_REUSE_OBSERVATION below for the dated source and retained evidence. New Cargo fingerprint tracing and controlled warm measurements belong to SESSION-STARTUP-READING.80.1."
---

## Observed mechanism and limits

During canonical verification of containment .10, PGEN was visibly compiled eleven times.
The inspected `rgx/subs/pgen/rust/build.rs` is 200 lines / 8,653 bytes, SHA-256
`be5af81a20aa976f3016adba63117c386121e9e0ff0333357fecc754352e0128`.
It emits all eight `cargo:rerun-if-changed` paths unconditionally before later
`is_file()` checks enable the corresponding generated-parser cfg and include environment.
The saved build output emits only the EBNF and regex availability cfgs.

All files below are relative to the repository root:

| Watched input | Observed state |
| --- | --- |
| `rgx/subs/pgen/generated/ebnf.rs` | present |
| `rgx/subs/pgen/generated/regex_parser.rs` | present |
| `rgx/subs/pgen/generated/json_parser.rs` | absent |
| `rgx/subs/pgen/generated/systemverilog_parser.rs` | absent |
| `rgx/subs/pgen/generated/systemverilog_preprocessor_parser.rs` | absent |
| `rgx/subs/pgen/generated/vhdl_parser.rs` | absent |
| `rgx/subs/pgen/generated/rtl_const_expr_parser.rs` | absent |
| `rgx/subs/pgen/generated/rtl_frontend_parser.rs` | absent |

Cargo documents repeated build-script execution when a watched file remains missing.
This observed condition is a concrete freshness trigger; the exact active fingerprint reasons
and controlled repair measurements are still required before attributing every rebuild to it.
The build script selects existing generated inputs; this observation does not establish
repeated parser generation. [Cargo FAQ](https://doc.rust-lang.org/cargo/faq.html?highlight=rebuild),
[build-script directives](https://doc.rust-lang.org/cargo/reference/build-scripts.html).

Correct reuse must preserve actual source/generated-file changes, file creation/deletion,
environment overrides, compiler, target, profile, feature and flag invalidation.
A submodule revision alone does not describe all those inputs.
Use Cargo's compatible artifacts and freshness checks. No cache bypass or source fix was
implemented by the intake. [Cargo build cache](https://doc.rust-lang.org/cargo/reference/build-cache.html).

## Existing target lifecycles

`tools/project_data_env.sh` defaults `CARGO_TARGET_DIR` to repository `rust/target`;
`tools/run_cargo_local.sh` preserves the managed environment and invokes Cargo.
The mandatory staged/progressive emitted-caller tests also share this target while
creating fresh caller source. Fresh caller source does not imply a fresh dependency target.

The semantic and MCP six-runtime drivers and duplicate-slot five-backend driver instead
create a fresh task-local Rust target and remove their owned artifact root on exit:
`tools/check_semantic_introspection_six_runtime.sh`,
`tools/check_mcp_six_runtime.sh` and
`tools/check_duplicate_regex_slot_identity_five_backend.sh`.
Their retention opportunity is separate from the main gate's repeated builds.
Preserve deliberately fresh isolation and relocation scenarios.

The installed Cargo reports `1.95.0 (f2d3ce0bd 2026-03-21)`. Ordinary and progressive
fingerprint variants coexist; the main gate changes global flags for progressive admission.
Same-profile ordinary pairs also differ in dependency identity. These observations do not
prove that flag switching alone caused the repeated invalidation.
`bash tools/run_cargo_local.sh report rebuilds` rejected on this stable toolchain as nightly-only; no toolchain
change followed. Use supported `CARGO_LOG=cargo::core::compiler::fingerprint=trace`
under .80.1, without competing Cargo work.
The current internal fingerprint documentation describes a later Cargo version and is
supporting context, not a version-specific diagnosis of the installed binary.
[Cargo fingerprint documentation](https://doc.rust-lang.org/stable/nightly-rustc/cargo/core/compiler/fingerprint/index.html).

## Bounded build baseline

These are elapsed Cargo test-build stages, including compiler/link startup and waits.
They exclude the subsequent test-process startup and execution, and nested emitted-caller
builds captured inside tests. They are observed costs, not measured repair savings.

| Consumer | Build elapsed |
| --- | ---: |
| staged AST | 8m31s |
| progressive dispatch | 7m08s |
| inter-match gap | 4m04s |
| recognition | 3m59s |
| recursive plus typed source | 4m27s |
| MCP selected library tests | 4m54s |
| MCP decoded dispatch | 5m23s |
| MCP strict stdio | 5m33s |
| MCP exact admission | 10m12s |
| semantic exact admission | 4m24s |
| repository-root relocation | 19m27s |
| **Total** | **78m02s / 4,682 seconds** |

The exact canonical log is `.linkedspec-data/ci-containment10-e55f7703.log`:
174,745 lines / 10,622,374 bytes, SHA-256
`635803e368f329f50ad3a76b3a4af7b5879120a1235612780641988fd419d602`.
It completed successfully: all nine doctrines, mandatory consumers, storage/relocation,
CLI 66x2 and Phase 0 1,032/1,032 in 1,163 seconds (Phase 0 only).
The 25 optional gates/matrices were skipped. Its receipt was promoted to `bef5dafd`.

## Ownership and replay

Startup .80.1 owns exact tracing and controls; .80.2 owns the PGEN repair and reviewed
dependency integration; .80.3 owns recurring-target assessment; .80.4 owns measured admission.
File creation/deletion, wholly absent generated directories, parser availability and avoidance
of self-invalidating output watches are required controls. Preserve pre-existing nested work.
The separate newer-OS wait belongs to .81 and [[macos-rust-first-launch-validation-latency]];
an observed pre-main frame does not establish an OS cause or a remedy.
All implementation prerequisites remain; Dart reading resumes at .1.37.

This replay checks the dated observation against current source/input state and retained
receipts. A later source/input change requires its owning repair to update current claims;
do not interpret a changed historical precondition as a newly discovered bug.

```bash
bash tools/project_data_run.sh python3 - <<'CI_BUILD_REUSE_OBSERVATION'
from pathlib import Path
import hashlib,json
root=Path.cwd().resolve()
base=Path('.linkedspec-data/scratch')
def checked(path,digest):
    data=Path(path).read_bytes()
    assert hashlib.sha256(data).hexdigest()==digest,str(path)
    return data
src=checked('rgx/subs/pgen/rust/build.rs',
 'be5af81a20aa976f3016adba63117c386121e9e0ff0333357fecc754352e0128')
assert len(src)==8653 and len(src.splitlines())==200
text=src.decode()
assert text.count('cargo:rerun-if-changed=')==8
assert text.rindex('cargo:rerun-if-changed=')<text.index('if ebnf_resolved.is_file()')
rows=json.loads((base/'ci-build-reuse-watched-inputs.json').read_text())
assert len(rows)==8 and len({r['path'] for r in rows})==8
present={'rgx/subs/pgen/generated/ebnf.rs','rgx/subs/pgen/generated/regex_parser.rs'}
assert {r['path'] for r in rows if r['is_file']}==present
for row in rows:
    p=Path(row['path'])
    assert p.exists()==row['exists'] and p.is_file()==row['is_file'],row
out=(base/'ci-build-reuse-latest-pgen-output.txt').read_text().splitlines()
watched=[(root/line.split('=',1)[1]).resolve().relative_to(root).as_posix()
         for line in out if line.startswith('cargo:rerun-if-changed=')]
assert len(watched)==8 and set(watched)=={r['path'] for r in rows}
assert {line for line in out if line.startswith('cargo:rustc-cfg=')}=={
 'cargo:rustc-cfg=has_generated_ebnf_parser','cargo:rustc-cfg=has_generated_regex_parser'}
for name,digest in {
 'ci-build-reuse-build-script-metadata.json':
 '942e9deffb656862b386ed2bf27cd7391afc3aa47ca41616382d679954bfbaa1',
 'ci-build-reuse-fingerprints.json':
 'a83b17ad7ba06e7f472fb2a2b6bc55370eec394de0baacb7347dcfae607c655a',
 'ci-build-reuse-build-baseline.json':
 '83f5e081c4b7d6b88d8e7d9f001db6a299d570b6c9f97573dd9133a769e69f33'
}.items(): checked(base/name,digest)
bench=json.loads(checked(base/'ci-build-reuse-relocation-baseline.json',
 'b416406b13c74791651bf1a75e984307b2f973886f72ef90cd423e43166bc224'))
assert len(bench['builds'])==bench['visible_pgen_compilations']==11
assert sum(r['build_seconds'] for r in bench['builds'])==bench['total_build_seconds']==4682
log=checked('.linkedspec-data/ci-containment10-e55f7703.log',
 '635803e368f329f50ad3a76b3a4af7b5879120a1235612780641988fd419d602')
assert len(log)==10622374 and len(log.splitlines())==174745
assert log.count(b'[cli-conformance] 66/66 case(s) passed for perl bin/linkedspec')==2
assert b'Tests=1032, 1163 wallclock secs' in log
assert sum(l.startswith(b'[ci] skipping optional ') for l in log.splitlines())==25
assert b'[ci] local CI gate passed' in log
print('PASS: dated source; 8 watches / 2 present / 6 absent; 2 cfgs; retained metadata;')
print('11 build stages / 4682 seconds; exact successful canonical log / 25 optional skips.')
CI_BUILD_REUSE_OBSERVATION
```
