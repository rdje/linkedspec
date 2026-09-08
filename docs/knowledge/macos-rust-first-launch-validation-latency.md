---
id: macos-rust-first-launch-validation-latency
title: "A cold repository-local Rust test launch stalled in macOS validation before main"
answers:
  - "which September 8 samples locate compiler and test startup waits"
  - "why did the Rust trace controls build take 55 minutes"
  - "was trace_controls looping after the cold build"
  - "why was the Rust test binary stuck at dyld_start"
  - "what task owns macOS syspolicyd Rust launch latency"
  - "is macOS first launch validation latency tracked"
  - "why did rustc wait in dlopen during startup canonical CI"
  - "did Rust pre-main waits also occur during permitted canonical CI"
  - "which September 7 startup samples distinguish aborted and accepted CI attempts"
date: 2026-09-08
status: older controlled artifacts classified; newer OS samples locate pre-main waits without identifying their cause
tags: [rust, macos, syspolicyd, gatekeeper, verification, performance, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.19.3.3 signoff, a plain-cargo test with repository-local target but user-home registry reads finished its cold build in 55m44s after prolonged per-crate waits. More than three minutes after Cargo launched trace_controls, it had 112 KiB footprint and no test output. Process census found Cargo/test alive and macOS syspolicyd consuming substantial CPU; a one-second sample contained only _dyld_start, proving Rust test code had not begun. The exact /tmp report created by sample was consumed, deleted, and verified absent. The eventual 12/12 result is diagnostic only until rerun through LinkedSpec's managed Cargo wrapper."
evidence_update_managed_2026_09_01: "The repository-managed root-selection driver then required 117m57s for its Rust admission test build before the binary ran 1/1 in 10.33s. A later exact managed trace command rebuilt in 2m07s, remained silent for about 98 seconds after launching the test binary, and then passed 12/12 in 2.23s. All project data for those accepted runs was routed by tools/project_data_env.sh. The large cold/warm and pre-test/execution split remains an audit input for .19.3.4.0, not a causal conclusion or permission to weaken trust checks."
evidence_update_canonical_2026_09_02: "During the successful receipt-bound canonical run, a read-only census found an independent Claude-owned shell deleting this checkout's rust/target/debug/incremental, rust/target/es19_boot, rust/target/audit_notest, and rust/target/coldprobe directories and invoking cargo sweep --time 7. No tracked file changed, but this is direct concurrent invalidation of repository-local Rust artifacts. Separately, mcp_server_rust_dispatch stayed at 112 KiB in macOS _dyld_start for more than five minutes and then passed 3/3 in 2.43s. The exact /tmp sample report was consumed, deleted, and verified absent. Controlled serial reproduction must separate this interference from OS validation latency."
evidence_update_closeout_2026_09_02: "Controlled managed runs reproduced two older distinct trace_controls hashes at 45.32/0.00 and 51.75/0.00 seconds for first/warm --list launches, with zero user/system CPU, no visible Rust process, and syspolicyd at 51.1-57.8% CPU. Both binaries were provenance-tagged, ad-hoc linker-signed, and slowly rejected by spctl. Ordinary managed-run files also inherit provenance. However two fresh behavior-equivalent unique isolated builds completed in 37.18 and 23.17 seconds. The first hash's explicitly signed copy and original launched in 0.44/0.45 seconds; the second wholly unmanipulated provenance-tagged linker-signed hash first-launched in 0.41 seconds, then 0.00 warm. Fresh serial compile/link/launch is therefore healthy. The delay is external per-artifact macOS policy/cache state for older contaminated artifacts, not a persistent Linkedspec source/build/storage/signing defect. No trust, xattr, cache, coverage, or workflow repair is justified; FUTURE-PARITY-BACKLOG.19.3.4.1 is not required."
reverify: "rg -n 'Rust launch-latency finding|FUTURE-PARITY-BACKLOG.19.3.4' docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md ROADMAP.md ROADMAP_V2.md docs/TASK_TREE.md"
---

## Dated startup observation — 2026-09-06

Canonical verification for `SESSION-STARTUP-READING.3.2.5` on macOS 26.6.2 build 25G83
again separated compiler/loader waits from test execution. At 04:17:07 +0200, the pgen
compiler process (PID 75954, launched 04:12:07) had a 1.7 GiB footprint. All 798 samples
of its compiler worker ended in `__fcntl` through `rustc_metadata::creader::dlsym_proc_macros`,
`load_dylib`, dyld `dlopen`, `Loader::mapSegments`, and `SyscallDelegate::fcntl`.
This locates that interval in procedural-macro library loading; it does not identify
the underlying kernel or policy cause.

The staged-AST test binary (PID 13554, launched 04:33:41) still had a 112 KiB footprint
at 04:39:06, with all 801 samples at `_dyld_start`. Rust test code had not begun at that
sample. The wait cleared; the test subsequently built its emitted programs and passed
1/1 in 571.92 seconds. Later process censuses also found zero CPU time and
32 KiB RSS before several other test harnesses started; their eventual tests passed.

Both sample reports were created directly in `.linkedspec-data/scratch`, consumed,
hash-verified, deleted, and verified absent. Their SHA-256 values are
`9b09b3be640607333e5d525b5d684e5b80301948d8b261a5b503c3f651ffa3f9` (compiler) and
`9ed3f99007e0ad35fac8bf50cd904ee8f3d78d177ccfd5ca9675cb228e2d51b8` (test).
The full default canonical gate passed and its receipt was promoted to `6c1234cc`.
It did not enable the separately opt-in local gates or recurring matrices. No target
cleanup, re-signing, trust bypass, or off-volume scratch was used for this diagnosis.
These are new dated measurements, not a controlled repetition of the older closeout
below or proof of its exact policy/cache cause on this newer OS.

## Earlier controlled closeout

The controlled closeout is specific to macOS 26.5.2 build 25F84 / Darwin 25.5.0. It separates dependency build,
link, policy/loader wait, and test execution without deleting an existing target. The two delayed older hashes and
their instant warm twins prove a per-artifact first-use policy cache; a second wholly unmanipulated unique fresh
control proves that provenance, ad-hoc linker signing, executable size, SSD execution, and high `syspolicyd` CPU
are not sufficient to reproduce the delay. The original canonical run remains invalid as a cold/warm comparison
because independent target deletion and `cargo sweep` occurred concurrently.

The correct operational response is to preserve exact tests and project-local storage, avoid competing artifact
cleanup, and classify a silent binary with process/loader evidence before assuming a runtime loop. Do not disable
Gatekeeper, clear shared or original provenance metadata, re-sign production test artifacts, add speculative
prelaunch work, or move caches off-volume. `.19.3.4.1` is closed not-required unless new controlled evidence
contradicts the fresh unique controls.

Related: [[project-data-storage-enforcement]], [[top-rule-is-ordinary-rule-entered-first]].

## Later September 6 progressive-consumer observation

During the frozen `SESSION-STARTUP-READING.3.2.41` canonical run, the managed Rust progressive
admission binary was launched at 19:37:18.113 +0200. The one-second sample at 19:42:49.159 +0200
on macOS 26.6.2 build 25G83 found PID 91339 at 112 KiB, with all 803 samples at `_dyld_start`.
This places that sampled delay before Rust main; it does not identify a kernel or policy cause.
The wait cleared without intervention, and the consumer passed 1/1 in 332.85 test seconds after
its separate 16m40s build. These times are distinct phases, not a single measured launch duration.

The report was created at
`.linkedspec-data/scratch/startup45-progressive-launch-91339.sample.txt`; its SHA-256 was
`da395d33cb3bf7784d504c3d902b371dc3cfb9f8cd6ad80d42e8205d373e89d5`.
After full consumption and hash verification, only that exact report was deleted and its absence
verified. No target cleanup, recovery/purge, signing change, or trust bypass occurred.
The completed reading checkpoint `.3.2.42` preserves this dated observation separately from
the older controlled OS-specific conclusion.

## September 7 core trace observation

The managed locked/offline core trace target in `SESSION-STARTUP-READING.3.3.10`
finished compilation in 17m10s. Its `linkedspec_core-80ca50544de425d0` test process
(PID 47932) launched at 03:39:55.031 +0200. At 03:41:27.472, a one-second sample
on macOS 26.6.2 build 25G83 found a 112 KiB footprint and all 800 samples at
`_dyld_start`. This locates that interval before Rust main; it does not identify
the underlying OS policy or kernel cause. An earlier compiler sample attempt
failed because its target had already exited, establishing no compiler stack.

The successful command was `bash tools/project_data_run.sh /usr/bin/sample 47932
1 1 -file .linkedspec-data/scratch/startup69-core-trace-47932.sample.txt`.
The complete 32-line / 1,015-byte report was consumed; SHA-256 is
`9dd0488a4f8a6d4e3f736c1deba8fcdd7b88dcd52a6e53e7925c23fa500e6d7c`.
Only that report was deleted, and its absence was verified. The failed compiler
sample path was also absent. No build artifact, trust setting, signing state or
shared cache was changed. The wait cleared without intervention; the selected
core trace tests then passed 7/7 with 194 filtered out in 0.00 test seconds. Build,
sampled launch wait and test execution are separate phases, not one measured delay.


## September 7 canonical checkpoint: bounded observations

Reading leaf `SESSION-STARTUP-READING.3.3.13` consumes the completed verification for
`.3.3.12`. The first attempt was launched in the restricted harness despite the
existing host-execution requirement in [[project-data-process-locality-proof]].
A no-op initialization control again returned 71 there and 0 in approved host
execution. The exact project CI group was stopped with exit 143; its component
results below are diagnostics and supply no canonical receipt. No recovery/purge,
target removal, profile weakening, signing, or trust-state change was used.

The unchanged candidate then passed canonical CI in the permitted environment:
all nine doctrines, relocated process containment and five primary anchors,
CLI 66/66 in both environments, and Phase 0 1,032/1,032 in 1,142 seconds.
The staged SHA-256 `ac76420b0965d071cb2318925d1f4088e427ec2d594869517be16fbb7209f4c6`
at base `75ce8db839888a5091d25ee4e5e1c3c501daf3b8` was promoted after commit
`1d3715fc70e36e97a8c3be1b114edf9f2e706a11`. 25 optional local gates/matrices
were skipped; their earlier results are not fresh measurements.

Every sample below was taken on 2026-09-07, macOS 26.6.2 (25G83), with a 112 KiB
physical footprint and every sampled frame at `_dyld_start`. Times are local +0200.
Compilation, the sampled pre-main interval, and eventual test execution are distinct
measurements. These are not controlled cold/warm comparisons, and sampling is not
established as an intervention or workaround.

| Attempt | Target; PID / parent | Build | Launch | Sample | Frames | Eventual test pass; seconds |
| --- | --- | --- | --- | --- | --- | --- |
| aborted restricted | staged AST; 81923 / 75157 | 7m34s | 04:40:48.264 | 04:46:02.651 | 804 | 1/1; 1328.48 |
| aborted restricted | progressive dispatch; 61789 / 56582 | 21m14s | 05:33:53.033 | 05:40:25.255 | 774 | 1/1; 793.82 |
| aborted restricted | gap capture; 87559 / 76186 | 13m13s | 06:07:33.459 | 06:14:44.557 | 772 | 1/1; 37.13 |
| aborted restricted | recognition; 14710 / 2984 | 12m39s | 06:31:27.256 | 06:38:19.240 | 772 | 12/12; 30.78 |
| aborted restricted | recursive observation; 23678 / 19913 | 5m22s | 06:48:22.668 | 06:55:27.277 | 771 | 7/7; 29.15 |
| aborted restricted | typed source; 38543 / 19913 | shared5m22s | 06:56:06.857 | 07:06:50.026 | 768 | 4/4; 3.62 |
| permitted canonical | staged AST; 16853 / 96500 | 20m29s | 07:44:03.739 | 07:51:02.487 | 763 | 1/1; 1185.06 |
| permitted canonical | recognition; 4468 / 1024 | 4m03s | 08:41:05.380 | 08:44:53.630 | 890 | 12/12; 29.60 |

The two permitted-run observations separate the pre-main waits from nested-sandbox
initialization denial. They do not identify the exact OS/kernel policy cause or
extend the older macOS 26.5.2 controlled conclusion to this newer OS.

All eight reports were read completely and independently verified by byte count,
line count, SHA-256, target identity, timestamps, OS, footprint, and sampled frame.
Their repository-relative locations and exact identities are:

| Report | Bytes; lines | SHA-256 |
| --- | --- | --- |
| `.linkedspec-data/scratch/startup71-staged-ast-81923.sample.txt` | 1075; 32 | `d23beb78f70fd615bb836f6d38fbb5fbaca0aaa3adb85863033c8c049c7b28c5` |
| `.linkedspec-data/scratch/startup71-progressive-test-61789.sample.txt` | 1091; 32 | `af68e25d2ccb30b89315e3c3262366518e3b384ccfcd3452cd75cba46af56610` |
| `.linkedspec-data/scratch/startup71-gap-test-87559.sample.txt` | 1083; 32 | `fd043d41ffad6a2da5c59b3ccf21bc211a69e10de6dacacf3d00445caa5a6c41` |
| `.linkedspec-data/scratch/startup71-recognition-test-14710.sample.txt` | 1082; 32 | `ebb06ce90ac1eed94353ebd396b8b98bdb85320ff2982ca4d8a85b4e2444344f` |
| `.linkedspec-data/scratch/startup71-recursive-test-23678.sample.txt` | 1075; 32 | `174255281c596c72853a36102456e30cfa59d93fe2caac07d49cbad890246e34` |
| `.linkedspec-data/scratch/startup71-typed-source-test-38543.sample.txt` | 1075; 32 | `c8941bf13b0d92f0be665a7b77c2f0ab62a1c3e5806d89f36eaefd1f216403f7` |
| `.linkedspec-data/scratch/startup71-permitted-staged-ast-16853.sample.txt` | 1075; 32 | `de991aa5e7db247b153ecc99adc4a36d0e1d72d9cb4d5bc3568860fb0c055add` |
| `.linkedspec-data/scratch/startup71-permitted-recognition-4468.sample.txt` | 1080; 32 | `280153ecfeec69ba34ff75cd02a5aef5a504441e149d5261050f7fc635b2af76` |

The command for each PID/report pair was `bash tools/project_data_run.sh
/usr/bin/sample <pid> 1 1 -file <report>`. The earlier compiler sampling attempts
for PIDs 58148 and 97479 found their targets already exited, establishing no stack;
their intended report files were absent. They are not successful samples in this table.

Only these eight consumed reports (8,636 bytes / 256 lines) were then deleted. Exact absence,
including both failed-attempt paths, was verified; no build target, cache, recovery, or purge was touched.
The accepted full log is `.linkedspec-data/scratch/startup71-canonical-permitted.log`,
10622381 bytes, SHA-256 `21b4d050901b6e497f33223c38d2eb358cf528ab03f41057e6a99e09218de47f`. It is retained as local verification evidence.

## September 7 final-assignment probe compiler observation

During `SESSION-STARTUP-READING.3.3.19`, the task-owned rustc process 57919
(parent 57732) launched at 12:43:39.998 +0200. A one-second sample at
12:52:18.957 on macOS 26.6.2 (25G83) records all 798 compiler-worker samples
in `__fcntl`, reached through procedural-macro loading
(`dlsym_proc_macros` / `load_dylib` / dyld `dlopen` / `mapSegments`).
This locates the sampled wait and does not establish a kernel or policy cause.
The compiler later exited 0 without recovery, cleanup or trust changes; the
resulting native receiver-guard probe completed all six cases successfully.

The report is retained at
`.linkedspec-data/scratch/startup78-receiver-guard/compiler.sample.txt`:
77,430 bytes / 448 lines; SHA-256
`8e3d0ffb4571b8236d4355479137da5e28e70ed544bd031565f5878d38450b7e`.
Its header, call graph and collapsed-stack summary were inspected; the remainder
is image inventory. Symbol processing also took time after the one-second sample;
that duration is not part of the sampled interval or proof of a workaround.

## September 7 change-history capacity checkpoint

Reading leaf `SESSION-STARTUP-READING.3.3.39` consumes the completed canonical result for `.3.3.38`.
Approved host execution passed all nine doctrines, the mandatory backend consumers, managed storage/process
containment, five relocated primary anchors, both CLI environments at 66/66, and Phase 0 1,032/1,032
in 1,100 wallclock seconds. That duration belongs to Phase 0, not the whole gate.
25 optional local gates/matrices were skipped; this does not refresh their historical results.
At base `77cad4543e72ab304ce2a66b26a876b02cd6d3c4`, staged SHA-256
`b6202c0fa70e508e3af051569e50db937aebfa1642a36436befc5a0754df3d55` matched the
receipt before commit and was promoted to `eba1a0edb14463e737003025a8d66ffa4f853801`.
The accepted log is retained at `.linkedspec-data/scratch/startup97-canonical-permitted.log`:
174,745 lines / 10,622,371 bytes; SHA-256
`c17d06e44e22b42392ffe31b346e68fe5ab4fcafaf74b02a9dc6346c453b777b`.

Two one-second samples from that run were completely consumed and hash/size verified. Both record
macOS 26.6.2 (25G83), a 112 KiB footprint and every sampled frame at `_dyld_start`.
Times below are local +0200 on September 7. Build duration, sampled pre-main interval and eventual
test execution are separate measurements; no controlled cold/warm comparison or exact OS cause is established.

| Target; PID / parent | Build | Launch | Sample | Frames | Eventual test pass; seconds |
| --- | --- | --- | --- | --- | --- |
| staged AST; 49815 / 45947 | 9m38s | 19:40:46.691 | 19:47:42.943 | 765 | 1/1; 1067.48 |
| MCP dispatch; 24494 / 92950 | 7m24s | 21:16:46.190 | 21:27:57.660 | 762 | 3/3; 2.55 |

The reports remain in project-local scratch, together with their sample metadata:

| Report | Bytes; lines | SHA-256 |
| --- | --- | --- |
| `.linkedspec-data/scratch/startup97-staged-49815.sample.txt` | 1075; 32 | `57101b6788078a9b427277fa43b4e154dba976de529bb6d510aefaaab46363fe` |
| `.linkedspec-data/scratch/startup97-mcp-24494.sample.txt` | 1051; 32 | `113b1a064b59eb8431030338870f3cbe2978cc06a926f4d0f2d7515c161521af` |

Each command was `bash tools/project_data_run.sh /usr/bin/sample <pid> 1 1 -file <report>`.
The waits cleared without runtime, target, cache, signing or trust changes. Sampling is not established
as a workaround. Both sample jobs and the canonical gate are fully consumed; no background result remains
from this checkpoint.

## September 8 engineering-notes checkpoint

Reading leaf `SESSION-STARTUP-READING.3.3.62` consumes the canonical result for `.3.3.61`,
committed as `64d82792b2ff60e1cafad9a9b3f27b33596c91d8`. Approved host execution passed the mandatory consumers,
all nine doctrines, representative process locality, five relocated primary anchors, both
CLI environments at 66/66, and Phase 0 1,032/1,032 in 1155 wallclock seconds.
That duration belongs to Phase 0 only. The 25 optional local gates/matrices were skipped.
The staged receipt at base `165b74dc88cdb86c433807b0a692893a4e3998d6` bound SHA-256
`2a23474f8f879aba30adc8290120ce6cb6e28de3ea750065ea4105ebc4453254` and was checked
before landing and after promotion. The retained log is
`.linkedspec-data/ci-startup-rust61-165b74dc.log`: 174746 lines / 10622473 bytes,
SHA-256 `3b77cb7946c19fe7eaa730f4432b6d03e0fc5bedcd337ac7c32de9e789fc3aad`.

All three sampled intervals below occurred on macOS 26.6.2 (25G83), with local
times +0200 on September 8. Parent build, sampled interval and test execution are separate
measurements. These are not controlled cold/warm experiments and do not identify the
underlying kernel or policy cause for this run.

| Target; PID / parent | Launch | Sample | Observed stack | Subsequent result |
| --- | --- | --- | --- | --- |
| staged AST test; 33770 / 82585 | 12:36:07.317 | 12:40:07.520 | all 804 frames at `_dyld_start`; 112 KiB | 1/1; 802.08 test seconds, after separate 10m12s parent build |
| LinkedSpec core compiler for progressive admission; 34050 / 25353 | 13:09:16.804 | 13:12:46.406 | all 798 compiler-worker frames end at `__fcntl` through procedural-macro loading | compiler completed; combined progressive parent build 17m49s |
| progressive admission test; 40297 / 25353 | 13:16:51.100 | 13:25:20.994 | all 803 frames at `_dyld_start`; 112 KiB | 1/1; 220.33 test seconds |

The compiler chain is `rustc_metadata::creader::dlsym_proc_macros` / `load_dylib` /
dyld `dlopen` / `Loader::mapSegments` / `SyscallDelegate::fcntl`. The main compiler
thread joins the worker; other observed threads wait. This locates procedural-macro
library loading during the sample, without identifying why the system call waited.

The two complete 32-line test reports were read in full. For the 447-line compiler
report, the header, complete call graph and collapsed-stack totals were read; the
remaining binary-image inventory was not read in full. Symbol processing after that
one-second sample also took time, which is not the sampled interval or a proved
intervention. Every sampling job completed with exit zero and was consumed.

| Retained report | Bytes; lines | SHA-256 |
| --- | --- | --- |
| `.linkedspec-data/scratch/startup-rust61-staged-33770.sample.txt` | 1075; 32 | `4f6f40ed68542117a79f0d16f6cba984af2ef3959691405993fb77f2118768e3` |
| `.linkedspec-data/scratch/startup-rust61-progressive-core-34050.sample.txt` | 77191; 447 | `1de7437a3db59cb50589c15a5aa226fda9510f42e2d890cc455d8116dbf4ef8b` |
| `.linkedspec-data/scratch/startup-rust61-progressive-test-40297.sample.txt` | 1091; 32 | `e9b6759f9ff75f7096b610ef459cb2cda53726a898aac62362c87c3b85fdf772` |

A later read-only census found recursive-observation PID 18154 / Cargo 16100 alive
and sleeping at an elapsed 8m50s with 32 KiB RSS. It was not stack-sampled, so the
same stack or cause is not inferred. That consumer subsequently passed 7/7 in
43.48 test seconds after a separate shared 7m05s build.

The required PGEN → RGX → LinkedSpec Rust dependency build chain is expected.
No target cleanup, recovery/purge, cache/signing/trust change or off-volume scratch
was used. The observed waits cleared; sampling is not established as a workaround.

## September 8 capacity implementation observation

Canonical capacity implementation .7.2 lands at 4489f5e9. Its source-location test PID 10885
(parent Cargo 6216) launched at 23:44:22.283 +0200. A one-second sample at 23:51:34.433 on
macOS 26.6.2 (25G83) records 112 KiB and all 742 frames at _dyld_start. This locates only
the sampled interval before Rust main; it does not identify the OS/kernel cause or establish
sampling as a workaround. The wait cleared without intervention; the test passed 4/4 in 3.60
execution seconds. Its separate shared build took 2m50s.

The complete 32-line / 1,074-byte report was consumed and remains at
.linkedspec-data/scratch/containment72-source-location-10885.sample.txt, SHA-256
 af30dd19e4431c71e6eff12142ed436e5dcfa06952f604ac4b24630a43de381a.
A separate unsampled recursive-observation census found PID 7071 / Cargo 6216 at elapsed
3m48s, 32 KiB RSS and zero CPU time; it subsequently passed 7/7 in 36.37 test seconds.
No stack or common cause is inferred for that unsampled interval. All diagnostic and canonical
jobs were consumed; no target/cache/recovery/purge/signing/trust changes were made.

The complete canonical log is .linkedspec-data/ci-containment72-b7638e34.log: 174,746 lines /
10,622,490 bytes, SHA-256 34123c7152f50ddc4ec8f93294013ae4f98465199ef9912b00a79cf01c5cf9d9.
It passes all nine doctrines, required consumers, containment/relocation, CLI 66x2 and Phase 0
1,032/1,032 in 1,152 wallclock seconds (Phase 0 only). The 25 optional gates/matrices were skipped.
