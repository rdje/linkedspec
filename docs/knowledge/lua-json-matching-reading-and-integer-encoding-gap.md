---
id: lua-json-matching-reading-and-integer-encoding-gap
title: Lua JSON and matching reading isolates represented integer loss and false cursor defaults
answers:
  - what did Lua startup reading group eleven cover
  - does PUC Lua JSON encoding preserve integers above double precision
  - why does Lua encode 9007199254740993 as 9007199254740992
  - does LuaJIT have the same newly observed integer encoder loss
  - do Lua matching cursors reject explicitly false values
  - which tasks own Lua integer serialization and matching default repairs
date: 2026-09-12
status: exact group eleven read; integer repair .2.11 and matching validation .2.8.5/.6 pending
tags: [lua, reading, json, integer, matching, cursor, validation]
evidence: "LUA-STARTUP-READING.1.11 reads 704 fragments /22026 bytes from adb79b644aa920d7b39403f140b0010f6c210063. Corrected native probes pass60 per host and unchanged duplicate-slot consumers pass112 per host,344 assertions total. Three PUC integer-format comparisons isolate JSON floating-format loss; LuaJIT's already-rounded input is qualified separately. Matching false defaults extend existing .2.8; .2.11 owns bounded integer repair/proof."
reverify:
  - "Run both exact managed replays below; preserve the PUC versus LuaJIT representation distinction."
  - "bash tools/run_lua_project_data.sh puc lua/test/duplicate_regex_slot_identity_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/duplicate_regex_slot_identity_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact reading

Activation is `adb79b644aa920d7b39403f140b0010f6c210063`; frozen baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`.

| File under lua/src/linkedspec | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| json.lua | 283–480 | 5313 | f08d96cacedbe6ca962dc54bfef72707703deda8a8e6bb8ef164402786db8014 |
| matching.lua | 1–500 | 16453 | b95884c4bb18f55d1b747ccf3c5f2d297f7d8dd58cbfcb8e97313f1ca5559e74 |
| mcp_contract.lua | 1–6 | 260 | 80ba55e93b01fb3c78ad4da155cf3597505ed431c065d9b96efe2ef477f14b74 |

Six full untruncated windows cover JSON 283–400,401–480; matching 1–170,171–340,
341–500; MCP 1–6. This is 704 fragments /22,026 bytes, with ordered-range SHA
`493407d9e0e434460bfe168384c2086a5cce4e67003aaea21a222c5aa28b1073`.
Cumulative coverage is 11/51 groups, 15,149 fragments /580,277 bytes. Eighteen
files are complete; the generated MCP payload remains unread behind .1.12/.1.13.
The six-line prefix identifies binding format 1, the generator, and bundle digest
`a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001`.
Header reading does not certify or claim physical reading of the payload.

# Comprehension and canonical reconciliation

JSON completes strict array/object parsing, separate duplicate-key tracking,
primitive tokens and full-input consumption. Decode validates UTF-8 before grammar
work. Encoding validates strings, escapes controls, rejects nonfinite values,
normalizes zero, requires explicit array/harray identities, detects cycles,
checks dense array indexes and sorts string object keys. Its integral-number
floating formatter causes the new PUC integer loss below.

Matching wraps the native PCRE2 module with typed alternatives, matches and
registers. Input validation separates UTF-8 byte coordinates from character and
line/column projections. Numeric offsets clamp to input bounds but must lie on a
character boundary. Pattern lists are dense; compilation retains authored indexes.
Ordinary seek chooses earliest start then first authored alternative; consume
anchors at the cursor. Required-slot matching selects the existing alternative,
while the legacy reindex helper copies provenance without recompiling.

Typed matches retain source, captures and capture provenance. Zero-width presence
and progress are explicit. Registers validate input identity, separate entry/local
matches, seed child entry from caller local state and retain optional capture
anchors. Copies and projections preserve typed group/null values. Several optional
cursor/table defaults replace false before reaching these validators, as below.

Canonical retrieval preceded diagnosis: [[lua-runtime-matching-state]],
[[lua-duplicate-regex-slot-identity-admission]],
[[duplicate-regex-slot-identity-contract]], [[lua-scalar-numeric-runtime]] and
[[lua-numeric-helper-preflight]]. Earlier admission counts remain dated evidence.
The first matching card's broad invalid-pattern typed-error claim is bounded by
already owned native formatter defect .2.3. These probes compile only valid small
patterns and never repeat the known PUC malformed-pattern failure.

# PUC represented integers lose precision during JSON encoding

| PUC-decoded exact integer | Encoded decimal |
| --- | --- |
| 9007199254740993 | 9007199254740992 |
| 9223372036854775807 | 9223372036854775808 |
| -9223372036854775807 | -9223372036854775808 |

On installed PUC 5.5.1, math.type reports integer and tostring retains each original
input. All three decode/encode/decode comparisons differ. A separate pure-JSON
probe confirms integer `%d` formatting preserves the exact decimal, while the
encoder output equals `%.0f` and the explicit floating projection. The source
owner is json.lua's integral-number branch at 429–430, which selects floating
formatting even when the runtime already holds an exact integer.

LuaJIT has already rounded these decimal inputs into its numeric representation
before encoding. Its measured encode/decode preserves that represented value;
this is a different boundary and no new LuaJIT encoder-loss claim follows. Exact
small/representable integer and fractional controls pass on both hosts.

`.2.11.1` owns preserving the already represented integer while retaining Lua 5.1
compatibility, finite floating behavior and zero normalization. `.2.11.2`
independently verifies exact decimal/value identity, nested containers and the
affected public/stored carrier census. The repair does not promise arbitrary
precision or recovering bits already lost during LuaJIT decode. Declared PUC
proof remains gated by .2.2; no unexecuted PUC 5.4 result is inferred.

# Matching false defaults skip explicit validation

Seek, consume, required-slot matching, register cursor construction and the
register cursor setter all accept false as zero. False register option tables
also become defaults. Omitted/zero controls pass; true/string/fractional cursors
and true/number/string option tables reject typed errors. In contrast, explicitly
false capture_start_byte correctly rejects through the direct offset validator.

The causes are byte_cursor-or-zero in matching 254/272/296 and the options/table
and cursor defaults at 371/373. The setter inherits register construction. Existing
`.2.8` now decomposes matching correction into .2.8.5 and independent proof into
.2.8.6. Keep negative/end clamping, Unicode boundaries, explicit null capture
clearing, choice/required-slot identity and child-register behavior unchanged.
Parent closeout now waits for all six configuration-validation children.

# Focused proof and resolved fixture error

The corrected native replay passes 60 valid controls on each installed host,
covering matching defaults/type errors, duplicate-slot versus choice selection,
seek/consume, present zero width, Unicode spans/line-column/named capture,
foreign-input rejection and child register separation; JSON container roundtrips,
decoded duplicate keys, malformed structure, ambiguous/cyclic/sparse/nonfinite
values and representable-number controls. False-default and large-number outputs
are observations, not counted successful contract cases.

The initial script had one incorrectly escaped JSON Unicode-key fixture in a Lua
quoted string. Both hosts stopped at Lua parse time before any controls ran.
Escaping that single backslash delivers the intended JSON escape; the corrected
runs pass and their exact payload below is authoritative. This is a fixture fix,
not a production JSON parser defect or omitted failed suite.

The unchanged duplicate-slot consumer passes 112 assertions per host, for 344 native
assertions together. Three separate PUC integer-format comparisons establish the
additional cause without a native build. All runs and cleanup outcomes are
consumed. Neutral duplicate-slot proof passes 5 fixtures/2 diagnostics/6 runtime
rows/21 public documents/11 current-claim denials and 59 mutations, at 7 complete/0
pending. No full component/corpus/canonical gate is claimed. Startup .28.7 retains
the earlier public-selector baseline failure; all eleven Lua repair roots remain
startup-gated.

# Exact corrected native replay

Payload size 4746 bytes; SHA-256 `f5b627a3c47e171082b0c0093d789d3e64a400e788458099fdabaf9275635381`.

```bash
bash tools/project_data_run.sh python3 - <<'LUA111_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua111/json-matching-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''local l=require("linkedspec")
local j=l.json
local m=require("linkedspec.matching")
local checks=0
local function check(v,label) assert(v,label);checks=checks+1 end
print("RUNTIME ".._VERSION..(jit and " "..jit.version or ""))
local alt=m.compile_runtime_regex_alternation({"a","a"})
local routes={
 {"seek",function(cursor) return m.seek_match(alt,"a",cursor).byte_start end},
 {"consume",function(cursor) return m.consume_match(alt,"a",cursor).byte_start end},
 {"slot",function(cursor) return m.match_runtime_regex_slot(alt,1,"a",cursor,"consume").byte_start end},
 {"register_cursor",function(cursor) return m.runtime_match_registers("a",{cursor_byte=cursor}).cursor_byte end},
 {"register_setter",function(cursor) return m.runtime_match_registers("a"):with_cursor_byte(cursor).cursor_byte end},
}
for _,route in ipairs(routes) do
 check(route[2](nil)==0,route[1].." omitted cursor")
 check(route[2](0)==0,route[1].." zero cursor")
 for _,bad in ipairs({true,"0",0.5}) do
  local ok,err=pcall(route[2],bad)
  check(not ok and m.is_runtime_regex_error(err),route[1].." typed invalid cursor")
 end
 local ok,value=pcall(route[2],false)
 print("OBSERVED false cursor "..route[1].." accepted="..tostring(ok).." value="..tostring(value))
end
for _,option in ipairs({{}, {cursor_byte=0}}) do
 check(m.runtime_match_registers("a",option).cursor_byte==0,"valid register options")
end
for _,bad in ipairs({true,0,"options"}) do
 local ok,err=pcall(m.runtime_match_registers,"a",bad)
 check(not ok and m.is_runtime_regex_error(err),"typed invalid register options")
end
local ok,value=pcall(m.runtime_match_registers,"a",false)
print("OBSERVED false register options accepted="..tostring(ok).." cursor="..tostring(ok and value.cursor_byte or value))
local capture_ok,capture_error=pcall(m.runtime_match_registers,"a",{capture_start_byte=false})
check(not capture_ok and m.is_runtime_regex_error(capture_error),"false capture start rejects")
local slot=m.match_runtime_regex_slot(alt,1,"a",0,"consume")
check(slot.alternative_index==1 and slot:text()=="a","required duplicate slot")
check(alt:seek_match("a").alternative_index==0,"choice tie order")
check(alt:consume_match("ba")==nil and alt:seek_match("ba").byte_start==1,"consume versus seek")
local z=m.compile_runtime_regex_alternation({"(?=a)"}):consume_match("a")
check(z~=nil and z:is_zero_width() and z.byte_start==0,"present zero-width match")
local unicode=m.compile_runtime_regex_alternation({"(?<letter>é)"}):seek_match("\néa")
check(unicode.byte_start==1 and unicode.byte_end==3 and unicode:char_length()==1,"Unicode spans")
check(unicode:start_line_column().line==2 and unicode:start_line_column().column==1,"Unicode line column")
check(unicode:named_capture("letter")=="é","named capture")
local boundary_ok,boundary_error=pcall(m.byte_offset_to_char_offset,"é",1)
check(not boundary_ok and m.is_runtime_regex_error(boundary_error),"interior byte rejects")
local parent=m.runtime_match_registers("a"):with_local_match(slot)
local child=parent:enter_child()
check(child.entry_match==slot and child.local_match==nil and child.cursor_byte==1,"child register separation")
check(m.runtime_match_registers("a",{capture_start_byte=j.null}).capture_start_byte==nil,"explicit cleared capture")
local foreign_ok,foreign_error=pcall(m.runtime_match_registers,"b",{entry_match=slot})
check(not foreign_ok and m.is_runtime_regex_error(foreign_error),"foreign match rejects")
for _,source in ipairs({'[]','{}','[true,false,null]','{"z":null,"a":[false]}','{"é":"😀"}'}) do
 local value=j.decode(source);check(j.encode(j.decode(j.encode(value)))==j.encode(value),"container roundtrip")
end
for _,source in ipairs({'{"k":false,"k":true}','{"a":1,"\\u0061":2}','[1,]','{"k":1,}','true false'}) do
 local valid,err=pcall(j.decode,source);check(not valid and tostring(err):find("JSON error",1,true),"invalid JSON structure")
end
local cycle=j.array();cycle[1]=cycle
local sparse=j.array();sparse[2]=true
for _,bad in ipairs({{},cycle,sparse,math.huge}) do
 local valid,err=pcall(j.encode,bad);check(not valid and tostring(err):find("JSON error",1,true),"invalid JSON value")
end
for _,text in ipairs({"9007199254740992","9007199254740994","-9007199254740992","1.25"}) do
 local number=j.decode(text);check(j.decode(j.encode(number))==number,"representable numeric control")
end
for _,text in ipairs({"9007199254740993","9223372036854775807","-9223372036854775807"}) do
 local number=j.decode(text);local encoded=j.encode(number)
 print("OBSERVED large number input="..text.." subtype="..tostring(math.type and math.type(number) or "number")..
  " host="..tostring(number).." encoded="..encoded.." roundtrip_equal="..tostring(j.decode(encoded)==number))
end
print("PASS "..checks.." valid controls")
''')
LUA111_REPLAY
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua111/json-matching-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua111/json-matching-proof.lua
```

# Exact PUC integer-format comparison

Payload size606 bytes; SHA-256 `2258c02ce14ceec79e515fe710aa52eb8b0b73c3ef316f195210aedce422350d`.
This host-only comparison asserts integer subtype before drawing its conclusion.

```bash
bash tools/project_data_run.sh lua - <<'LUA111_INTEGER'
package.path="lua/src/?.lua;lua/src/?/init.lua;"..package.path
local j=require("linkedspec.json")
print("RUNTIME ".._VERSION)
for _,text in ipairs({"9007199254740993","9223372036854775807","-9223372036854775807"}) do
 local n=j.decode(text)
 assert(math.type(n)=="integer" and tostring(n)==text)
 assert(string.format("%d",n)==text)
 assert(j.encode(n)==string.format("%.0f",n))
 assert(j.encode(n)==j.encode(n+0.0) and j.decode(j.encode(n))~=n)
 print("integer="..text.." exact_format="..string.format("%d",n).." float_format="..string.format("%.0f",n))
end
print("PASS 3 integer projection comparisons")
LUA111_INTEGER
```

# Continuity

This task-owned reading preserves source, prior cards/decisions and immutable
history while extending repair ownership and current book/frontier evidence.
Exact coverage, preservation, memory, Knowledge, histories and rendering checks
precede its ordinary doctrine-governed commit.

Independent reconstruction passes all 99 sources/51 groups/149 ranges and both exact replay payloads. Preservation retains 1,383 prior source/card/decision/history files, 2,462 unchanged prior task nodes and all 62 prior Known headings; exactly five pending repair nodes are added. Knowledge 1097/8810, memory 60, histories 291/438 (notes warning, no rollover) and rendered book pass. The existing 10,047,337-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
