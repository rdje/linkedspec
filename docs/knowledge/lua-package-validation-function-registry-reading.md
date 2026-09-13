---
id: lua-package-validation-function-registry-reading
title: Lua package validation function and registry proof preserves exact metadata and scoped execution
answers:
  - "what exact Lua source did startup reading child 39 cover"
  - "which Lua validation and function package groups pass during startup reading"
  - "does Lua package proof preserve fixed variadic and final codeblock metadata"
  - "does Lua currently parse option equals true as a named argument"
  - "what does Lua package proof establish about variadic rest array isolation"
  - "which Lua validation and registry guidance remains stale after reading child 39"
  - "what focused evidence passed for Lua reading child 39"
date: 2026-09-13
status: exact source reading and selected proof complete; remaining package source and prior repairs stay open
tags: [lua, package, validation, functions, registry, ActionIR, startup, evidence]
evidence: "LUA-STARTUP-READING.1.39 activates from 155f31eab03c03964666be1b8dea5928f486f050. Eight complete windows read 1397 fragments /65503 bytes. Both installed hosts pass 34 complete package groups each, including 102 rule-only corpus validations and exact function/registry state. Existing .2.1 guidance extends; no production change or new repair node."
reverify: "Run LUA_PACKAGE_FUNCTION_READING_39 and the managed commands below; selected complete groups1940-3340 use original preamble1-199 and helpers1718-1753."
---

# Exact reading

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/run.lua | 1956–3352 | 1397 /65503 | 223192ef4b4d629b39d5044718161a75a00082620631e090a791ed26bb8dcd27 |

Complete credited windows are 1956–2150, 2151–2325, 2326–2500, 2501–2675,
2676–2850, 2851–3025, 3026–3200 and 3201–3352. Ordered range SHA-256 is
`dd857ba1f7f956526551f9f512ea5be0248837876dc7d4e14b62dd3a9da5c673`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 39/51 groups,
54,040 fragments /2,043,401 bytes and 77 complete files. The package runner
remains partial, ending inside the staged-registry group that starts at 3341.

# Source validation and reservations

Nine complete validation groups accept a markerless nonempty spec, reject zero
rules with exact code/stage, reject duplicate labels and validate edge-family
ownership, undefined targets, indexed slots and grouped-edge requirements.
Raw fallback and lightweight regex structure reject before native compilation;
the regex fixture exercises the already-read validator scanner. Strict mode
retains unused-rule behavior, including its treatment of the authored top rule.

The exact current call-name inventory is 250, sorted and queried through shared
APIs. All seven complete named-mark helpers are read from the neutral fixture,
reserved in the shared inventory and resolved to family capture_mark.
Function declarations reject duplicates, rule/helper collisions, duplicate or
reserved parameters and arity mismatch. Every shipped source validates, as do
exactly 102 rule-only corpus sources; automatic function shells are excluded from
that rule-only loop. No full corpus execution is inferred from validation.

# Function projection, metadata and failure ownership

Test constructors calculate Unicode-scalar spans from known valid text and build
spec-owned fixed definitions with matching source slices, payloads and parse jobs.
The variadic helper removes top-level params/arity and installs one identical
signature in definition/payload/job. The final-codeblock helper carries raw fixed
parameters, one final name and exact parameter-kind metadata for canonicalization.

Fixed-v1 and variadic-v2 tests project source-owned nodes, preserve parameter order,
round-trip typed signatures, dispatch bodies, validate and compile. They compare
the exact outward variadic field set/version with the shared descriptor contract.
Mixed signature storage, extra fields, bounded variadic maximum and sidecar drift
reject, as do duplicate or reserved rest names.

Final-codeblock tests canonicalize raw fixed_params/codeblock_param into fixed
params/arity plus parameter_kinds, removing raw fields from definition and both
sidecars. Typed AST, staged body, compiled registry and outward v3 descriptor keep
the exact metadata. Incorrect sidecar kinds reject. Four explicit error-node
examples check final-position, forbidden declaration argument list, missing name
and unknown type diagnostics. These examples project error nodes; they do not
claim a fresh parser-grammar rejection route for every invalid declaration.

Unicode projection preserves comments/rules, strips only supplied function spans,
normalizes source-order paths and job IDs, and leaves bodies undispatched until
the staged API is used. Empty supplied nodes do not trigger a hidden raw-function
scanner. Error nodes, mismatched sidecar text and overlapping spans reject;
direct and nested output wrappers normalize to the same definition node.

The automatic function parser loads the bundled exact-path grammar, handles fixed,
variadic and final-codeblock declarations, preserves Unicode line attribution and
reuses one compiled parser build across metadata/parse/staged calls. Negative
fixtures distinguish parser-spec parsing, validation, execution, output-shape,
source projection and staged-body ownership. A controlled staged failure uses a
temporarily substituted dispatcher that is restored before assertions.
Existing .2.31 metadata, .2.32 caller-mutation and false-option limitations remain
open; these accepted/selected rejection cases do not cover every malformed carrier.

# ActionIR and registry behavior

ActionIR tests cover LF/CRLF/CR statement boundaries, same-line semicolons, dropped
statement values, primitive/regex/array/harray/block literals, quoted strings,
nested reads and unified nested writes, append/scalar assignments, nested calls,
attached controls and raw fallback. Unicode spans are scalar offsets; malformed
UTF-8 rejects. Generic trailing blocks and explicit final positional blocks have
equivalent structure for function and receiver calls.

The concrete expression `helper(value, option=true)` still parses its second
argument as positional assign_scalar. A programmatic keyword_argument constructor
exists and has a typed keyword/name record. This is the current distinction;
it does not implement the approved named-argument syntax. The parked authoring
tree is unchanged and no implementation pivot occurs.

Recursive contract resolution canonicalizes numeric/helper aliases, tracks
control/receiver surfaces, maps authored nested writes to nested_access_assignment
and omits retired []= mapping. Unknown helper and raw fallback diagnostics remain
distinct. Shared name queries and typed JSON projection agree. A small registered
resolver demonstrates registry-before-helper behavior, exact arity rejection and
the count of a trailing codeblock as one argument; invalid registry interfaces reject.

Four registry groups preserve order, zero-based indices, job order, source/AST
snapshots and neutral descriptors. Registered contextual calls normalize both
attached and parenthesized structural blocks into zero-argument callable values
while preserving the source AST. A harray stays a hash literal and is not promoted.
Variadic resolution accepts its minimum or more, reports at-least-N failures, and
binds all surplus values into fresh typed rest arrays. The fixture includes scalar,
array, nested harray, false, null and a codeblock. Mutation of frame copies leaves
caller arrays/harrays/blocks and the separate typed store unchanged. Independent
empty calls receive distinct rest arrays. These are valid dense values, not the
malformed tagged-array members owned by .2.33.

Body stitching returns a new spec, preserves rules and copies the supplied AST.
The resulting concrete registry resolves before helpers; missing job IDs reject.
The staged-registry group beginning at 3341 is only partially read here and is
excluded from execution. Its exact continuation belongs to child 40.

# Knowledge and bounded proof

Retrieved [[lua-frontend-validation]], [[lua-actionir-ast-parser]],
[[lua-actionir-contract-resolver]], [[lua-outward-function-descriptor-union]],
[[lua-user-function-registry]], [[lua-variadic-v2-signature-state]] and
[[lua-final-codeblock-metadata]]. Earlier source-parser, function-projection,
registry-invocation and callable reading facts remain available with their precise
repair qualifications; no source fact is reopened without that existing ownership.

Existing .2.1 gains the validator's unqualified top-marker/239-name wording and
the resolver's current239 sentence, plus registry blanket nested-copy/cycle
guarantees that need the already-measured .2.33 limitation. Historical60/239 counts
remain preserved. Earlier future descriptor/generated/callable wording is already
owned. No old Knowledge card or historical task node is rewritten.

The original preamble1–199 and shared helpers1718–1753 are reused exactly, followed
by complete helpers/groups1940–3340. The selector initially asserted an incorrect
expected group count of33 and stopped before native execution; enumeration showed
34 complete groups. Only that scratch count was corrected. Both managed native
jobs then exit0 with exact34-group logs,68 groups total. No individual assertion
total is invented and no later package test is included. The hosts are installed
PUC5.5 and LuaJIT, not certification of unavailable supported PUC5.4. All33 repair
roots, prior nil-error and public-selector failures, startup gates and parked
named arguments remain open. No full CI, primary matrix, PGEN/RGX build or push occurs.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_PACKAGE_FUNCTION_READING_39'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua139')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\nimport re\n\np=Path(\'.linkedspec-data/scratch/lua139\')\nsource=Path(\'lua/test/run.lua\').read_text().splitlines(keepends=True)\nassert source[1717].startswith(\'local function body_kind(\')\nassert source[1753].startswith(\'test(\')\nassert source[1939].startswith(\'local function assert_validation_error(\')\nassert source[3340].startswith(\'test("staged parser registry \')\nbody=\'\'.join(source[1939:3340])\nnames=re.findall(r\'^test\\("([^"\\n]+)"\',body,re.M)\nassert len(names)==34,len(names)\n(p/\'package-selection.lua\').write_text(\'\'.join(source[:199])+\'\'.join(source[1717:1753])+body+\'\\nassert(total == 34, "package selection count drift: " .. total)\\nassert(failed == 0, "package selection failures: " .. failed)\\nprint("package selection: " .. total .. " test groups passed")\\n\')\nprint(\'Selected preamble1-199, shared helpers1718-1753 and complete groups/helpers1940-3340: 34 groups\')\n')
(p / 'verify.py').write_text('from pathlib import Path\nimport hashlib,json,re\n\np=Path(\'.linkedspec-data/scratch/lua139\')\nfor row in json.loads((p/\'scope.json\').read_text()):\n    data=b\'\'.join(Path(row[\'path\']).read_bytes().splitlines(keepends=True)[row[\'start\']-1:row[\'end\']])\n    assert len(data)==row[\'bytes\'] and hashlib.sha256(data).hexdigest()==row[\'sha256\']\nsource=Path(\'lua/test/run.lua\').read_text().splitlines(keepends=True)\nbody=\'\'.join(source[1939:3340])\nnames=re.findall(r\'^test\\("([^"\\n]+)"\',body,re.M)\nassert len(names)==34\nexpected=\'\'.join(f\'ok {i} - {name}\\n\' for i,name in enumerate(names,1))+\'package selection: 34 test groups passed\\n\'\nfor host in [\'puc\',\'luajit\']:\n    assert (p/f\'package-{host}.log\').read_text()==expected,host\nprint(\'PASS: exact source range and 34 complete package groups per host, 68 total; validation, function variants, ActionIR and registry proof preserve selected scope\')\n')
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/run.lua",\n    "start": 1956,\n    "end": 3352,\n    "bytes": 65503,\n    "sha256": "223192ef4b4d629b39d5044718161a75a00082620631e090a791ed26bb8dcd27"\n  }\n]\n')
LUA_PACKAGE_FUNCTION_READING_39
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua139/select-tests.py
for host in puc luajit; do
  bash tools/run_lua_project_data.sh "$host" .linkedspec-data/scratch/lua139/package-selection.lua > ".linkedspec-data/scratch/lua139/package-$host.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua139/verify.py
```

Related: [[lua-package-pipeline-corpus-frontend-reading]],
[[lua-startup-reading-coverage]], [[lua-invocation-and-callable-consumer-reading]].

# Preservation and final focused checks

Independent audit preserves 1,415 baseline source/Knowledge/decision/history/policy
files and 2,579 of 2,582 existing task nodes byte-for-byte. Only this reading leaf,
existing guidance owner .2.1 and startup .3.6 change; no node is added. The parked
authoring tree, all 90 existing Known headings, both prior live-document suffixes
and indexed live-status History remain exact. All three embedded replay payloads
match their executed scratch files. Independent inventory reconstruction confirms
all 99 source files, all 51 groups and exact 39-child reading credit.

Document-history checks pass 34 mutation controls across three surfaces and 67
segments; no rollover is needed. Explicit memory architecture and diff whitespace
checks pass. The book builds successfully; its 10,148,494-byte search-index warning
remains under startup .41.9. The generated map has 1,125 facts and 8,994 question
keys. These are focused pre-commit observations; normal commit hooks remain required.

The first commit attempt passed eight doctrines and stopped at verification
cadence because the leaf described its proof under Verification tier rather than
providing the required Focused checks field. The current leaf now uses the exact
activation/tier/focused-checks/canonical-trigger schema. Only the record changed;
the selected native tests were already complete and were not needlessly repeated.
The commit is retried through the unchanged normal hooks.
