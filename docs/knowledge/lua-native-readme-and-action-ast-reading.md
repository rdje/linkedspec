---
id: lua-native-readme-and-action-ast-reading
title: Lua native and ActionIR reading identifies formatter crash and documentation drift
answers:
  - what did Lua startup reading group two cover
  - which PUC Lua version was measured during September twelve reading
  - do unversioned Lua wrapper passes establish PUC 5.4 conformance
  - where did the September twelve Lua native module load wait occur
  - which task owns the Lua runtime and header version mismatch with policy
  - why can malformed native regex patterns crash PUC Lua 5.5.1
  - why does the Lua README diagnostic example produce zero events
  - where is the September twelve Lua crash report retained
date: 2026-09-12
status: group two read; confirmed defects owned; source repairs remain pending
tags: [lua, native, actionir, reading, toolchain, diagnostics, macos]
evidence: "LUA-STARTUP-READING.1.2 reads 1500 fragments /54,321 bytes from clean af2ca27ed4a9bea0d4141121153240ced9e2eb3b. The README is now fully read; all sources remain baseline-identical. Actual PUC process and pkg-config identity are 5.5.1, while policy requires 5.4.8; .2.2 owns restoration and matching identity enforcement. Samples locate native import waits inside dyld dlopen/mapSegments/fcntl. After import, the exact README diagnostic assertion fails on both measured runtimes; native invalid-pattern formatting loses detail on LuaJIT and crashes PUC 5.5.1. All four probe outcomes are consumed; .2.3/.2.4 own concrete repair and verification."
reverify:
  - "Run the exact group-two scope and safe README diagnostic recipes below through repository-managed wrappers."
  - "bash tools/project_data_run.sh lua -v"
  - "bash tools/project_data_run.sh luajit -v"
  - "bash tools/project_data_run.sh pkg-config --modversion lua luajit"
  - "bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py"
  - "perl tools/check_native_spec_resolution_contract.pl"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Exact physical reading

Activation is `af2ca27ed4a9bea0d4141121153240ced9e2eb3b`; source baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Every byte in the following eight ranges
was read. The thirteen untruncated viewing windows were README 946–1125,
1126–1260, 1261–1377; each command and the filesystem/system C file in full;
regex C 1–150, 151–233; ActionIR AST 1–185, 186–371; call names 1–120, 121–239.
The remaining call-name suffix belongs to .1.3 and has no reading credit here.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/README.md` | 946–1377 | 21462 | `75f017ded20443b53f055384629ff2553b8ac908dfc8706dfb273d93578bd5a0` |
| `lua/bin/corpus_runner.lua` | 1–17 | 680 | `a229736e8d6d653e870eaa1d1cca374df98a37d2b49f8e60722ddec4cd0981ba` |
| `lua/bin/linkedspec-lua` | 1–31 | 1308 | `2b04a57dd599122334db130523f88fd013ab13d6ca144e5fc54c67a658c9e796` |
| `lua/native/filesystem_native.c` | 1–92 | 2741 | `947965d5847f1f8441eade4d4e6e35836639edbff51bcd96c4f8024cd4c32a67` |
| `lua/native/mcp_system.c` | 1–85 | 2569 | `ed9fa3e71bd71cfcbe994312ae4fa1c43da03765d0efdf3a1998db57e1130c7e` |
| `lua/native/regex_pcre2.c` | 1–233 | 7513 | `120a7a96c4b1618b7862f2a3de009c12cdb68ebece26689e4350e263a4386e0a` |
| `lua/src/linkedspec/action_ast.lua` | 1–371 | 12084 | `5900fa7f3bb883a7bb3d5c987e840945edea97155e257257e8103f3a832668d5` |
| `lua/src/linkedspec/action_call_names.lua` | 1–239 | 5964 | `1dd980f1bf3d78652e35d333ca52c8f651eec504afffdda56e453757ead657bc` |

The group totals 1,500 fragments /54,321 bytes, with frozen ordered range digest
`edbc6d329884611882069b9d24de3a8f4eae4764b9f8f66306fab982cef67934`.
Together with .1.1 this physically covers 2,445 fragments /119,853 bytes and
finishes seven files; action_call_names.lua remains partial.

# Comprehension and canonical owners

The README suffix explains registry-first staged user functions, copied invocation
frames, exact outward descriptor variants and generated v2 modules over the ordinary
runtime. It distinguishes byte cursor positions from Unicode projections, immutable
match registers, opt-in diagnostic sinks and copied four-kind values. A second
obsolete current 176/177 statement appears at lines 1136–1137, and lines
1333–1334 still describe admitted callable syntax as future backlog; .2.1
already owns this documentation mechanism and its correction/independent review.

The two command files are thin adapters. The corpus entrypoint derives its module
path from its own script location; the primary additionally obtains native cwd,
forms an absolute script origin, passes explicit cwd/repository/display identity,
and emits the returned stdout/stderr/exit tuple. These are separate CLI contracts.

The filesystem binding rejects empty/NUL paths, reports stat-based file/non-regular/
missing/error classes, and grows its cwd buffer from 256 bytes through 1 MiB while freeing
failed allocations. The MCP system binding supplies exactly 32 strong OS-random
bytes and monotonic milliseconds bounded to the shared exact integer range, with
no weak entropy or wall-clock fallback. Both select platform/ABI seams explicitly.

The PCRE2 binding owns userdata lifetime, UTF/UCP/duplicate-name compilation,
anchored versus seeking byte offsets, full group slots, compact participating
captures/spans, named captures and an intended Lua error boundary with the confirmed formatter defect below. Unset full groups become empty
strings while compact groups omit them. Unicode positions and higher-level policy
remain in [[lua-runtime-matching-state]], not the C binding.

ActionIR constructors retain structural metatable identities for arguments, access,
write paths, receiver mutations, staged text plans, signatures and deferred bodies.
The removed-selector walker distinguishes expression/control families and skips
explicit inert callable bodies; [[lua-aggregate-selector-compile-rejection]] owns
whole-compiled/runtime admission. JSON projection unwraps positional arguments,
retains keyword name/value and emits the exact eight-field codeblock literal.
The read call-name prefix contains canonical helper/control families and numeric
symbol/word aliases; its remaining table and accessors are .1.3-owned.

Canonical retrieval preceded diagnosis: [[lua-actionir-ast-parser]],
[[lua-runtime-matching-state]], [[lua-native-spec-resolution]],
[[lua-diagnostic-output-events]], [[lua-aggregate-selector-compile-rejection]],
[[lua-toolchain-package-policy]] and [[macos-rust-first-launch-validation-latency]].

# Declared primary versus measured toolchain

The canonical policy declares PUC 5.4.8 primary plus LuaJIT 2.1. During .1.2, both
`lua -v` and `pkg-config --modversion lua` report 5.5.1; the sampled process loads
liblua.5.5.1. LuaJIT reports 2.1.1788460057. The inspected command paths, versioned
pkg-config names and installed system Lua locations contain no 5.4 alternative.
These are read-only OS/toolchain dependency observations; no global state is changed.

The mechanism is concrete: tools/run_lua_project_data.sh defaults its PUC command
to unversioned lua, while tools/build_lua_native.sh independently selects the
unversioned pkg-config lua package. Neither guards the declared target version
or matches an overridden executable to the selected headers. Current runtime and
headers agree with each other at 5.5.1, so this is policy/proof drift, not a reproduced
binary ABI crash. Earlier unversioned passing results did not record 5.4 identity
and cannot establish 5.4 conformance.

Lua .2.2/.2.2.1/.2.2.2 own declared-primary selection, mismatch checks and exact
conformance restoration after startup prerequisites. No implicit 5.5 target upgrade
is made. Reading coverage remains separate from supported-runtime admission.

# Native-loader observation

At 17:49:52+0200 on macOS 26.6.2 build 25G83, both one-second samples contained 890
samples ending in dyld __fcntl through dlopen, Loader::mapSegments and
SyscallDelegate::fcntl. PUC had 2,960 KiB footprint; LuaJIT 2,496 KiB. Both processes
had launched at 17:47:57 and remained inside require, before the probe body.
Read-only open-file inspection identifies the respective project-local
linkedspec_regex_pcre2.so as the library being mapped.

Reports are retained in .linkedspec-data/scratch/lua12:

- puc.sample.log: 17,665 bytes, SHA-256
  `63c2ce24f2a1255180553a03b5081e44f790e8ba81db33a488ebb874cc6d7b10`.
- luajit.sample.log: 12,242 bytes, SHA-256
  `661d67095ef4a959a0c62e6fdf5d5d6ec63a37fc72e261a7e788ef639d6e0c05`.

This locates a loader wait; it does not prove a kernel/policy cause or a parser
loop. Startup .81.1 retains controlled newer-OS loader diagnosis and conditional
repair. No trust setting, signature, provenance, source or reusable cache changes.
All four outcomes are consumed: original PUC exits 139 with the crash below;
original and host LuaJIT exit 0 with the same diagnostic observations; host PUC
is explicitly terminated (exit 143) after the first crash to avoid duplicating it.
The original PUC crash timestamp is 18:06:52 +0200, after a roughly 19-minute import
wait. Long import latency is separate from the later deterministic error-path crash.

The host PUC comparison at 18:06:49 +0200 likewise samples 890 stacks at the same
require/dlopen/mapSegments/fcntl boundary. Its report, puc-host.sample.log, is 17666 bytes
with SHA-256 `7a6b5ee625f2808503e1f7bbcec496bbbfa111dc0905dcb9b9ef05581ef11cf7`. The separate system-log
query for the project PCRE2 basename returned only its own invocation record; it
provides no causal event. A contemporaneous syspolicyd census showed 56.7% CPU,
which is correlation rather than proof that it owns this particular wait.

# Focused verification

The selector scanner passes zero positives /20 classified occurrences, native
resolution 14/9/4 cases pass and MCP admission remains 5/5 implementations,
6/6 runtimes with 141 rejected mutations. The executable observations below identify defects, not passing native-error
conformance. No fresh complete component or canonical gate is claimed.

# Native malformed-pattern crash: located mechanism

The exact probe first compiles `a` and verifies an anchored match ending at byte 1.
It then calls the raw C binding through `pcall` for `[`, `(` and `(?<`. Both LuaJIT
runs return `PCRE2 compile error at byte ?` for all three, losing the byte offset
and provider detail. PUC 5.5.1 crashes on the first invalid pattern, before printing
an error. A Lua-level `pcall` cannot catch this native memory fault.

`lua/native/regex_pcre2.c` lines 55 and 62 pass `%lu` to `luaL_error`. That API uses
Lua's limited formatter, which does not accept C length modifiers. In the normal
error branch, an unsigned-long offset argument precedes the provider string.
The exact Lua 5.5.1 formatter leaves the unknown `%l` unconsumed; its following
`%s` therefore consumes that numeric offset as a string pointer. Offset 1 reaches
`strlen(1)`. This is a source-supported causal explanation, not an ABI-mismatch
inference. Primary references: [Lua error API](https://www.lua.org/manual/5.5/manual.html#luaL_error),
[allowed formats](https://www.lua.org/manual/5.5/manual.html#lua_pushfstring), and
[exact 5.5.1 formatter source](https://www.lua.org/source/5.5/lobject.c.html#luaO_pushvfstring).

The copied crash report confirms PID 10570, SIGSEGV / EXC_BAD_ACCESS, with register
x0 equal to 1 and stack `_platform_strlen` → `luaO_pushvfstring` →
`lua_pushvfstring` → `luaL_error` → `compile_regex`. The unsupported conversion
also affects the fallback format. The published
[5.4.9 formatter source](https://www.lua.org/source/5.4/lobject.c.html#luaO_pushvfstring)
rejects an unknown format; this is a source comparison, not execution of the
unavailable declared 5.4.8 runtime. No 5.4 crash or conformance result is claimed.

Lua .2.3.1 owns safe offset/provider formatting and raw/public valid/invalid
controls; .2.3.2 owns independent supported-runtime verification. Preserve wide
byte offsets without passing unsupported modifiers to Lua. Source repair follows
startup prerequisites and .2.2 primary identity restoration. Do not rerun the
known crashing raw-PUC probe merely to reconfirm this evidence.

The OS generated the unique `lua-2026-09-12-180652.ips` report in its diagnostic
report directory. Under the same-volume policy, it was copied to
`.linkedspec-data/scratch/lua12/puc-crash.ips`, byte-compared, parsed and used there,
then the exact old file was deleted. Identity was checked against PID 10570,
process name and project PCRE2 module before deletion. The matching-PID old-report
census is zero and no corresponding core dump exists. The retained report is
8,845 bytes, SHA-256 `517ef658a5041b584eebc92cbe1c165793bab23210a41cf22b07bcf6032c6b9e`.
No shared diagnostic history was deleted; paths were derived at runtime.

# README diagnostic example: missing source operation

The exact consecutive README engine and sink blocks execute a child whose only
body operation returns `child`. Neither block calls a diagnostic helper. On both
measured runtimes the result remains `child`, events is empty and line 1208's
`RuntimeDiagnosticOutputEvent` assertion fails. A controlled source substitution
adding only `say("diagnostic")` before that return yields exactly one event:
helper_name `say`, rule_label `Child`, message `diagnostic` plus LF; the result is
unchanged. This identifies a missing documentation precondition, not a broken sink.
Lua .2.4.1 owns the executable example repair; .2.4.2 independently executes the
exact corrected documentation on supported runtimes after startup prerequisites.

The original combined probe is retained at
`.linkedspec-data/scratch/lua12/readme-native-probe.lua` (SHA-256
`1a10b8fd9b6ab715ba0667f6061c9c3c258b35eb9af6c26c84a823311fa4a617`).
Its trailing raw invalid-regex loop is the known crash reproducer. The following
self-contained recipe reconstructs only the safe README diagnostic comparison
from exact source blocks, excluding that loop. It fails closed if the old example
changes; after repair, use the new owning verification instead.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_README_DIAGNOSTIC'
from pathlib import Path
import re
readme=Path('lua/README.md').read_text()
def block_after(marker):
    tail=readme.split(marker,1)[1]
    return re.search(r'```lua\n(.*?)\n```',tail,re.S)[1]
engine=block_after('Execute compiled rules directly in the host process:')
sink=block_after('Diagnostic helpers are opt-in at the embedding boundary:')
assertion='assert(linkedspec.interpreter.node_type(events[1]) == "RuntimeDiagnosticOutputEvent")'
assert sink.count(assertion)==1
sink=sink.replace(assertion,'local ok = pcall(function() '+assertion+' end)\nassert(not ok and #events == 0 and result.value == "child")')
positive='''
local changed, edits = source:gsub('return%("child"%)', 'say("diagnostic"); return("child")')
assert(edits == 1)
local emitted = {}
local e = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(changed)))
local r = linkedspec.runtime_parse(e, "ab", {diagnostic_sink=function(v) emitted[#emitted+1]=v end})
assert(r.value == "child" and #emitted == 1)
assert(linkedspec.interpreter.node_type(emitted[1]) == "RuntimeDiagnosticOutputEvent")
assert(emitted[1].helper_name == "say" and emitted[1].rule_label == "Child")
assert(emitted[1].message == "diagnostic\\n")
print("PASS exact old README failure and one-operation positive diagnostic control")
'''
out=Path('.linkedspec-data/scratch/lua12/readme-diagnostic-only.lua')
out.parent.mkdir(parents=True,exist_ok=True)
out.write_text('local linkedspec = require("linkedspec")\n'+engine+'\n'+sink+'\n'+positive)
LUA_README_DIAGNOSTIC
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua12/readme-diagnostic-only.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua12/readme-diagnostic-only.lua
```

These commands may still encounter the separately measured OS import wait.
Record executable and pkg-config identities with every replay; an unversioned
PUC invocation does not establish declared 5.4 conformance.

# Exact scope replay

Use the independent LUA_READING_COVERAGE recipe in
[[lua-startup-reading-coverage]] to reconstruct every owned range against current
source and the frozen baseline; .1.2 must remain 1,500 fragments /54,321 bytes with
the digest above. Hashes verify scope and never substitute for physical reading.
