---
id: lua-readme-reading-and-status-drift
title: Lua README reading separates stable contracts from a stale staged gate claim
answers:
  - what did Lua startup reading group one cover
  - which exact windows were read in Lua README group one
  - does Lua README still present the old help failure as current
  - which task owns the stale Lua README gate status
  - does the first Lua reading slice claim a complete runtime gate
date: 2026-09-12
status: reading group one complete; documentation repair .2.1 pending
tags: [lua, reading, documentation, claims, continuity]
evidence: "LUA-STARTUP-READING.1.1 physically reads README lines 1-945 in six untruncated windows from clean 0bf9218e359fda81ff5a4ed412ebe014546f12ee: 945 fragments / 65532 bytes. Root selection 139 and logical helpers 359 pass on each ABI; neutral root 54 and logical 26 mutations pass. README lines 656-657 retain an obsolete present-tense 176/177 help failure; canonical July 19 and August 1 records already supersede it. Repair .2.1 owns correction and independent verification after startup prerequisites."
reverify:
  - "Run the dated LUA_README_GROUP_ONE recipe below through tools/project_data_run.sh."
  - "bash tools/run_lua_project_data.sh puc lua/test/root_rule_selection_admission_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/root_rule_selection_admission_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/logical_helper_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/logical_helper_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py"
---

# Physical coverage

The source baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`; reading
activates from clean `0bf9218e359fda81ff5a4ed412ebe014546f12ee`. Every scoped
byte was displayed and read, with no output truncation in these six reads.
The later README suffix and implementation files retain their later reading owners.

| Inclusive LF lines | Bytes | SHA-256 |
| --- | ---: | --- |
| 1–160 | 9690 | `ecb9a61ffcd8886fe73f4ab5f4de5a76e21fa1594c76fc6c9b5284190c8495f4` |
| 161–320 | 13637 | `c47d1d6226e5e79693284677131f5e6e6ad7557a20201cd9432f8eb68917bf62` |
| 321–480 | 12649 | `815145a0b519962bba721e96c7e1d17c05bb644627c6b3800b8b8cd941718dc5` |
| 481–640 | 13275 | `767be9be1c3e70aaaf483f26677ea72df287824b511a5079dcedbdf12bdd84b9` |
| 641–800 | 9381 | `91dadfca584d72d97e561805ed1c204783b0d13e95bb709a0d600a642c71423b` |
| 801–945 | 6900 | `68db5053e3d0755d7abca12cce9c3d598dfac3ac8e5da2667eec2de74da9a6e2` |

The concatenation is 65,532 bytes with SHA-256
`ac6176bb87a5c39cc13cbad39a5c4c0a6d2450872e68b0db92993c0d06f136d0`.
The frozen task range-record digest remains
`cd9b7c3a88e7a87a74155f4c7f14b8a3fbf260dcbb0a1ff196a03769e59c505b`.
Checksums verify the retained scope; they do not replace physical reading.

# Comprehension and canonical reconciliation

Lines 1–160 introduce standalone lifecycle `I`, rule-local cursor policy,
repeated action-edge returns, structured failures and caller-owned tracing.
AND derives consume/sequence and OR derives seek/choice at each entered rule;
global cursor overrides are rejected. Semantic queries use an immutable index,
while execution observation is a separate invocation-local typed event channel.
The stable semantic admission owner is [[lua-semantic-introspection-admission]].

Lines 161–320 distinguish observed-index derivation from execution and describe
MCP as a same-process capability/query server over already-created indexes.
Its strict wire admission retains integer-token spelling on both ABIs, bounded
frames, caller-owned streams, and cleanup on I/O failure. The same section
recounts staged functions, native loading, corpus and generated-source rollout;
its successive counts describe different historical slices, not one current run.

Lines 321–480 explain explicit native load/compile/engine composition and one
caller-owned full-pipeline emitter. Spec-owned function parsing supplies staged
body ASTs. Copied value helpers, statement mutation, eager blocks, lazy controls,
dynamic callback stores, and Unicode-facing cursor/capture boundaries are distinct
contracts; array/harray continuation and return ownership cannot be collapsed.

Lines 481–640 cover named and anonymous marks, slot-timed placement markers,
quiet diagnostic sinks and historical helper/native admission. Explicit callable
values are inert typed data, not Lua closures. Parameters temporarily replace
matching stores while other caller state stays live; generated/emitted routes
retain the same executor. [[lua-callable-codeblock-emitted-route-identity]] owns
the callback-before-scoped-value order and named-versus-anonymous recursion rule.

Lines 641–800 separate eager logical operands from lazy controls, contextual
final-block intent from eager brace values, and the parser CLI from the developer
corpus runner. [[lua-logical-helper-execution]] owns truthiness and pre-effect
arity; [[lua-global-cursor-option-removal]] owns retired global-option rejection.
The repository wrappers build selected native modules in disposable local storage;
they do not install global Lua packages. Historical two-module wording is followed
by the explicit MCP system-module addition in this same README range.

Lines 801–945 describe complete-manifest validation before selected execution,
copied structured fixture results, explicit JSON-kind AST construction, Unicode
source validation and staged function projection. Entry precedence is exact
selector, first authored top marker, then first authored rule. Entry lifecycle
`I` is stronger selection evidence than a later matching `E` result; the fixed
request-trace fixture retains its canonical bytes. Follow
[[lua-root-rule-selection-admission]] rather than re-deriving the resolver.

# Confirmed documentation defect and repair owner

At this dated activation, README lines 656–657 still say the complete local gate
“remains at the staged 176/177 per-ABI help boundary.” That current-status wording
is obsolete. [[lua-root-rule-selection-preflight]] explicitly records its July 19
superseding admission at package 177/177 per ABI, and
[[lua-callable-codeblock-emitted-route-identity]] records the later complete
177/177 package with CLI66x2. The fault is retained current-tense pre-admission
prose after its underlying cursor/help issue was resolved; no new runtime failure
or current full-gate pass is inferred from this documentation comparison.

`LUA-STARTUP-READING.2.1` owns correction, `.2.1.1` the bounded wording repair,
and `.2.1.2` independent verification. They remain pending behind startup .3/.4/.5
and the complete README read. The public project-status page exposes this limit.
Nearby historical counts must retain their dates and proof scope rather than be
silently replaced with an unmeasured contemporary total.

Fresh selected proof on September 12 passes root selection 139 and logical helpers
359 assertions on each ABI: 996 total. The neutral root checker passes 8 selection,
3 failure and 3 strict cases, 7/0 rollout, 24 public documents, 18 forbidden claims
and 54 mutations. Logical governance passes 17 truthiness, 10 helper, 3 effect
cases, 8/0 rollout, 19 public documents, 14 forbidden claims and 26 mutations.
These selected checks do not replace a complete package, CLI matrix or canonical gate.

# Dated evidence replay

This recipe verifies the original reading snapshot even after the later repair.
The independent all-source/current-range recipe remains in
[[lua-startup-reading-coverage]]. No historical card is rewritten here.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_README_GROUP_ONE'
import subprocess, hashlib
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
ACT='0bf9218e359fda81ff5a4ed412ebe014546f12ee'
def get(ref,path):return subprocess.check_output(['git','show',ref+':'+path])
raw=get(ACT,'lua/README.md');assert raw==get(BASE,'lua/README.md')
lines=raw.splitlines(keepends=True)
windows=[
 (1,160,9690,'ecb9a61ffcd8886fe73f4ab5f4de5a76e21fa1594c76fc6c9b5284190c8495f4'),
 (161,320,13637,'c47d1d6226e5e79693284677131f5e6e6ad7557a20201cd9432f8eb68917bf62'),
 (321,480,12649,'815145a0b519962bba721e96c7e1d17c05bb644627c6b3800b8b8cd941718dc5'),
 (481,640,13275,'767be9be1c3e70aaaf483f26677ea72df287824b511a5079dcedbdf12bdd84b9'),
 (641,800,9381,'91dadfca584d72d97e561805ed1c204783b0d13e95bb709a0d600a642c71423b'),
 (801,945,6900,'68db5053e3d0755d7abca12cce9c3d598dfac3ac8e5da2667eec2de74da9a6e2')]
parts=[];end=0
for a,z,size,digest in windows:
 assert a==end+1;part=b''.join(lines[a-1:z]);part.decode('utf-8')
 assert len(part)==size and hashlib.sha256(part).hexdigest()==digest
 parts.append(part);end=z
joined=b''.join(parts);assert end==945 and joined==b''.join(lines[:945])
assert len(joined)==65532 and joined.count(b'\n')==945
assert hashlib.sha256(joined).hexdigest()=='ac6176bb87a5c39cc13cbad39a5c4c0a6d2450872e68b0db92993c0d06f136d0'
assert b'gate remains at the staged 176/177 per-ABI help boundary' in lines[656]
preflight=get(ACT,'docs/knowledge/lua-root-rule-selection-preflight.md')
assert b'evidence_update_2026_07_19_admission:' in preflight
assert b'package 177/177x2' in preflight
later=get(ACT,'docs/knowledge/lua-callable-codeblock-emitted-route-identity.md')
assert b'complete Lua passes 177 TAP groups per ABI with CLI 66x2' in later
print('PASS six exact dated windows /945 LF fragments /65532 bytes; obsolete current-status statement and both superseding canonical records located')
LUA_README_GROUP_ONE
```
