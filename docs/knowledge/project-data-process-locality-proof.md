---
id: project-data-process-locality-proof
title: Relocated process containment proves representative project I/O stays on repository storage
answers:
  - how is project data locality proved at process level
  - does LinkedSpec have a relocated process storage oracle
  - which backends are covered by the project data process oracle
  - how are hostile temporary and cache variables tested
  - can a symlink escape the repository storage policy
  - does the process oracle allow explicit caller input
  - why does the project data process oracle use sandbox exec
  - why does the process oracle not use fs usage
  - does Dart read telemetry configuration from developer home
  - why does LinkedSpec give Dart a repository local home
  - why does the Lua native builder call Apple clang directly
  - does xcrun write temporary compiler metadata outside the repository
  - why must the process oracle capture host temp before routing TMPDIR
  - why does getconf return project scratch after TMPDIR routing
  - how does the process oracle reject false host temporary authority
  - why does sandbox_apply fail inside a restricted agent harness
  - how should canonical CI run when nested macOS sandbox initialization is denied
date: 2026-07-27
status: current
tags: [architecture, storage, filesystem, process, sandbox, relocation, dart, lua, toolchain, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.4.2 adds tools/test_project_data_process_locality.sh and registers it in canonical local CI. On macOS it creates a collision-safe checkout view below managed repository scratch, starts from an outside-filesystem cwd with hostile TMPDIR/TMP/TEMP/Cargo/Dart/Julia/Python cache roots, and uses sandbox-exec to deny all writes outside the relocated checkout plus /dev/null and to deny data reads from developer HOME and both OS temporary roots except one exact read-only caller input. Real Perl, Rust, Dart, Julia, Lua, and Python-tool probes create nonempty traces or bytecode beneath the relocated root; the probe-set guard requires all six families. Deterministic mutations reject an old-volume write, a shared Cargo-cache read, a symlink escape, and a missing tool probe. fs_usage and dtruss require root on this host; sandbox-exec supplies non-root kernel containment in a normal local terminal. The first contained run exposed Dart's pre-command HOME telemetry read and Apple's cc shim xcrun_db temporary write. tools/run_dart_project_data.sh now gives only Dart a same-device repository-local HOME, all maintained Dart command surfaces use it, and the Lua builder invokes the active Apple clang plus SDK directly instead of the stateful cc shim. Correction PROJECT-DATA-SSD-ROOTING.6 proves post-routing getconf DARWIN_USER_TEMP_DIR can echo routed project TMPDIR, preserves inherited TMPDIR before routing, and makes the oracle reject missing or repository-device host authority. Complete canonical local CI then passes through process containment and Phase 0 1,031/1,031."
evidence_update_2026_07_29_lua_mcp: "FUTURE-PARITY-BACKLOG.10.9.6.1 makes the overlaid Lua builder consume a new uncommitted native source before the leaf commit. The first canonical run proved a HEAD archive alone cannot contain that source; the relocation fixture now overlays lua/native/mcp_system.c explicitly, the MCP checker mutation-locks the overlay, and the kernel-contained six-family driver passes."
evidence_update_2026_09_06_harness: "SESSION-STARTUP-READING.3.2.21 canonical CI reached the process-locality test, then sandbox-exec reported sandbox_apply: Operation not permitted and its driver exited 71. The same read-only sandbox-exec allow-default /usr/bin/true control exits 71 inside the restricted harness and 0 with approved execution outside it. The unchanged full process-locality test then exits 0 outside the harness, including all six families and retained containment REDs. This isolates an execution-environment prerequisite; no profile weakening, skipped test, or product repair is justified. The failed canonical attempt supplies no receipt; rerun the exact staged canonical candidate in the permitted environment."
reverify: "bash -n tools/test_project_data_process_locality.sh tools/run_dart_project_data.sh tools/build_lua_native.sh && bash tools/test_project_data_process_locality.sh && bash scripts/check_project_data_storage_locality.sh"
---

`tools/test_project_data_process_locality.sh` is the recurring process-level complement to the structural
`PROJECT-DATA-STORAGE` doctrine. It archives the current committed tree into a path containing a space below the
managed repository scratch root, overlays the current oracle/helper sources for pre-commit verification, clone-
copies the retained Dart and Julia caches plus the built Rust primary, and invokes that relocated tree while the
working directory is the runtime-derived system temporary root on another filesystem.

The per-user host temporary root must be identified before the common initializer replaces `TMPDIR`. On this host,
asking `getconf DARWIN_USER_TEMP_DIR` afterward can return the already-routed project scratch path, causing the
oracle to condemn correct SSD routing as if it were external host storage. The initializer therefore preserves the
inherited value once as invocation-local runtime authority. The oracle requires the capture marker, a nonempty
existing nonsymlink directory, and a device different from the repository; embedded mutations prove missing and
repository-device substitutions fail. That authority is read only to construct containment denials. It is neither
a project-data destination nor a persisted machine path.

The macOS sandbox profile permits normal operating-system and external-tool reads, but it makes the storage
boundary kernel-enforced: writes are denied outside the relocated checkout except `/dev/null`. Data reads from the
developer home, the system temporary root, and the per-user temporary root are denied, with one exact existing
caller-owned file admitted read-only. The driver independently resolves every initialized project-data directory,
requires it beneath the relocated checkout and on the checkout device, verifies the external interpreters against
the frozen system/tool roots, and requires the exact set `caller-input dart julia lua perl rust tool`.

The retained REDs prove the policy is mutation-sensitive. An external output cannot be created, a shared
developer Cargo cache cannot be read, a symlink inside the checkout cannot redirect a write to the old volume, and
omitting the tool-family probe fails the set guard. Successful Perl, Rust, Dart, Julia, and Lua primary invocations
each write a nonempty routed trace; the Python checker writes bytecode under the routed cache. Any denied-access or
Apple `xcrun_db-` diagnostic makes the otherwise successful driver fail.

Tracing experiments established two actionable hidden accesses. `fs_usage`/`dtruss` are root-only on the current
host, so the committed oracle uses the narrower non-root `sandbox-exec` containment available in an ordinary macOS
terminal. Dartdev consulted `HOME/.dart-tool/dart-flutter-telemetry.config` before package operations honored
`PUB_CACHE`; `tools/run_dart_project_data.sh` now sets only the Dart child's HOME to
`/.linkedspec-data/cache/dart-home/`, and the structural doctrine rejects maintained bare Dart command surfaces.
Apple's `/usr/bin/cc` shim attempted to refresh `xcrun_db-*` under the per-user OS temporary root; on macOS the Lua
native builder now resolves the active developer directory, invokes its real `clang`, and supplies the active SDK
explicitly. These are process-boundary corrections; parser/runtime semantics and user-facing CLI syntax are
unchanged.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-storage-locality-doctrine]],
[[project-data-workflow-routing]], [[dart-project-data-ssd-storage]], [[lua-project-data-ssd-storage]],
[[repository-root-path-portability]].

## Restricted harness execution requirement — 2026-09-06

A restricted agent harness can deny installation of a nested macOS sandbox before the contained command starts.
The diagnostic `sandbox-exec: sandbox_apply: Operation not permitted` therefore needs an initialization control,
not an inference that a backend attempted forbidden project I/O:

```sh
/usr/bin/sandbox-exec -p '(version 1) (allow default)' /usr/bin/true
```

This no-op returned 71 inside the restricted harness and 0 outside it. Running the unchanged
`bash tools/test_project_data_process_locality.sh` outside the harness then passed its relocated six-family
driver and containment assertions. Use approved execution outside the harness for this oracle and for canonical
CI that includes it. Keep the oracle's own sandbox profile and all denials intact. A focused pass does not replace
the full staged-candidate receipt required by `COMMIT.md`.

## September 7 canonical reconfirmation

`SESSION-STARTUP-READING.3.3.13` records the completed `.3.3.12` gate. The initial
restricted-harness attempt repeated the already documented execution mistake;
the same no-op returned 71 there and 0 in approved host execution. That attempt
was safely stopped with exit 143 and supplied no receipt. The unchanged full
canonical candidate then passed in the permitted environment, including the
six-family relocated containment test and all retained denials. Commit
`1d3715fc70e36e97a8c3be1b114edf9f2e706a11` received the promoted exact receipt.

Canonical CI must therefore be launched with approved host execution from the
start. This is the existing execution prerequisite, not a new permission to
weaken the test or skip its profile. Separate newer-OS pre-main samples are
bounded in [[macos-rust-first-launch-validation-latency]].
