---
id: lua-interpreter-helper-reading-and-false-delimiter-gap
title: Lua helper reading confirms false delimiter loss in receiver join and mutable split
answers:
  - what did Lua startup reading group eight cover
  - does Lua receiver join_values preserve a false delimiter
  - does Lua mutable split preserve a false delimiter
  - which task fixes Lua false delimiter function receiver parity
  - why did the Lua sorted harray reading fixture collapse its keys
  - which focused controls support Lua helper and capture reading
  - why does the public selector checker reject the existing Julia example
date: 2026-09-12
status: exact group eight read; two delimiter routes owned by pending .2.9
tags: [lua, reading, helpers, delimiter, arrays, strings, captures]
evidence: "LUA-STARTUP-READING.1.8 reads 1500 fragments /52134 bytes from f80a2bde7684d31df9655273023b179e98d64e58. Corrected native controls pass22 per installed host; separate join and split false-delimiter observations confirm two fallback errors. Existing dynamic-key semantics explain the initially incorrect fixed-key fixture. .2.9 owns bounded repair and independent verification."
reverify:
  - "Run the exact managed native replay below on both installed Lua hosts and record their identities."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
  - "bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_uniform_binding_mutation_result_surface.py"
  - "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

# Physical reading

Activation is `f80a2bde7684d31df9655273023b179e98d64e58`; frozen baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Every byte of
`lua/src/linkedspec/interpreter.lua` lines 1417–2916 was read in nine complete
untruncated windows: 1417–1586, 1587–1756, 1757–1926, 1927–2096, 2097–2266,
2267–2436, 2437–2606, 2607–2776, 2777–2916.

The 52,134-byte source range SHA-256 is
`9dad55a55c3cee5c9c1907068946cdb5e9de9de04b59e361a779ca645492ac9d`;
ordered-range SHA is
`7ddf7c6ea7587c413f14adc04d4a6c36b2d1f0ad2bea9ca73b656a3f9627b00f`.
Cumulative reading reaches 8/51 groups, 11,445 fragments /448,121 bytes.
Coverage includes fifteen complete files and a partial interpreter; .1.9
continues its suffix. Diagnostic inspection of hash-literal evaluation at lines 3599–3605
adds no reading credit outside this exact range.

# Comprehension and canonical reconciliation

Inline if/switch validate full branch structure before subject/condition evaluation
and execute only the selected payload. Bare case labels are symbolic, while
compound case expressions evaluate. String dispatch handles scalar/Unicode conversion,
literal and regex splitting, replacement, prefix/suffix operations, substring and
lexical comparisons. Coalescing remains lazy and retains false. Pure array helpers
copy source values before selection/order/filter/transform operations; harray
views use sorted keys and copy values in that order. Explicit flattening has typed
array/harray splicing rules and ordinary shapes retain nesting.

Tree callbacks traverse containers of the root's kind, treat opposite-kind
containers as leaves, copy paths/frames and share the scoped callback mechanism.
Walk returns a copy, map constructs a new tree and reduce carries a copied seed.
Scalar numeric and reducer calls delegate to their existing evaluator. Mutable
split validates the target binding and uses the shared split policy before storing
a detached update; its delimiter fallback is the confirmed exception below.

Typed position/span adapters preserve the source-location runtime as their owner.
Entry/local capture helpers distinguish absent values, typed groups/names and scalar
coordinates. Named marks are rule-local byte positions with checked writes and
public scalar projections; anonymous and named take helpers update their checkpoints
only after a valid span. Boundary capture caches compiled alternations, chooses the
earliest usable next boundary and advances the live cursor. Input/cursor slicing
and save/restore/rewind helpers retain bounds/trace behavior. Callable failure,
signature and body adapters begin the next invocation section; execute_values itself
continues after this range.

Canonical homes were retrieved first: [[lua-runtime-lazy-inline-controls]],
[[lua-string-helper-parity-closeout]], [[lua-runtime-array-selection]],
[[lua-runtime-array-helper-closeout]], [[lua-runtime-array-transform-pipelines]],
[[lua-runtime-harray-views]], [[lua-complete-named-mark-parity]],
[[lua-array-split-mutation]] and [[hash-literal-dynamic-key-contract]]. Historical
counts and former next-frontier statements remain dated evidence, not fresh claims.

# Two confirmed false-delimiter differences

| Route | Explicit false result | Equivalent pure function |
| --- | --- | --- |
| `["a","b"].join_values(false)` | `"ab"` | `join_values(false,["a","b"])` gives `"a0b"` |
| `split(parts,"a0b",false)` | `["a","0","b"]` | `split("a0b",false)` gives `["a","b"]` |

Both installed hosts reproduce the same outcomes. True, numeric zero, a nonempty
string and the empty string agree between their corresponding routes. The pure
function's shared scalar conversion maps false to `"0"`. Receiver join at lines
1930–1931 and mutable split at 2260–2261 instead use `argument and evaluate(...) or
""`, replacing a legitimate evaluated false before it reaches that conversion.

`LUA-STARTUP-READING.2.9` owns both routes. Child .2.9.1 must distinguish an absent
expression from an explicit false value and retain single evaluation, default,
copy and helper semantics. Child .2.9.2 independently verifies literal/computed
false through supported native, reconstructed and applicable generated/emitted
carriers. This is distinct from .2.8, where a false iteration count is invalid
and must reject. All nine local repair roots remain pending behind startup
reading/book/policy and declared PUC runtime prerequisites.

# Resolved fixture mistake

The initial native script used `{b:2,a:false}` as if a and b were fixed names.
Its AST retains both keys as variable expressions. The runtime therefore reads
two absent bindings, stringifies both as the same `json.null` key and replaces
the first value. The resulting one-field harray and `[false]` sorted view do not
establish lost false values. Direct harray, function/receiver views and true/zero
controls isolated the key collision before any classification.

The accepted dynamic-key contract explicitly requires quoting fixed field names.
Changing only the fixture to `{"b":2,"a":false}` produces `[false,2]` on both
hosts. No production change or repair owner is warranted for this fixture mistake.
Diagnostic source inspection shows key evaluation then tostring at lines 3602–3603;
no broader key-coercion parity claim is inferred. The corrected exact replay below
is authoritative; initial failing runs are not counted as passing suites.

# Focused proof

The corrected managed native script passes 22 valid controls per installed host,
44 total: function/receiver and pure/mutable non-false delimiter agreement, lazy
false/null controls, coalesce false, Unicode substring/input slicing, copied array
selection, sorted harray false values, root-kind tree traversal and named mark
position/clear behavior. The two false-delimiter outcomes are printed separately
as defect observations. Hosts are PUC 5.5.1 and LuaJIT 2.1.1788460057, not a new
PUC 5.4 proof. Both corrected runs and cleanup outcomes are consumed.

Complete named-mark proof passes seven helpers, the exact Unicode/rule-local
fixture and three mutations. Uniform mutation-result public proof passes 54 files,
12 current anchors and nine classified historical cards. Public aggregate-selector
proof fails on unchanged committed inputs as detailed below. No full gate or
complete corpus execution is claimed.

# Baseline public-check failure and concrete repair ownership

The additional production public-selector check exits 1 at the existing Julia
callable-body negative example, project-status.md line 857 at activation. Before
any public-file update, all 62 discovered files match activation Git bytes, including
rgx/README.md against the recorded gitlink 8763a0e6bea97879f027237439d57725f83ead23.
This comparison is read-only; no rgx build or broader source reading is involved.
An initial parent-Git-only comparison stopped at that submodule file; the corrected
comparison resolves the gitlink explicitly and succeeds.

Independent use of the production matchers finds 35 distinct references, 34
classified and one unclassified, against the pinned total 32. The rejected fenced
example is already introduced as invalid/rejected in its surrounding paragraph.
`sentence_at` stops at blank-line boundaries, so that context is absent from the
fence's own window. Merely changing that context would still leave the count
mismatch. The diagnostic does not establish a new executable-selector defect.

`SESSION-STARTUP-READING.28.7` now owns both dimensions with bounded repair .28.7.1
and independent verification .28.7.2. Existing .28.2 concerns a distinct false
current-status claim. Both retain startup source/book/policy prerequisites. The
reading slice records this failed baseline check; it does not claim a public
selector gate pass, delete the negative example, change a counter or modify the
checker. The selected helper/mark/mutation checks passed separately. Future
canonical admission must resolve this failure through its repair owner.

This replay uses dated committed public bytes and the exact unchanged checker;
its saved 35-row inventory includes each context for the repair audit:

```bash
bash tools/project_data_run.sh python3 - <<'LUA18_SELECTOR_BASELINE'
import hashlib, importlib.util, json, re, subprocess
from pathlib import Path
base = "f80a2bde7684d31df9655273023b179e98d64e58"
checker = Path("tools/check_public_aggregate_selector_surface.py")
assert hashlib.sha256(checker.read_bytes()).hexdigest() == "e51bc0fd45472b844f72d8778c70f96424216306d91822be33e83e48e5d0ecec"
spec = importlib.util.spec_from_file_location("selector_check", checker)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
paths = m.public_markdown_paths()
references = []
for path in paths:
    relative = path.relative_to(m.ROOT).as_posix()
    if relative.startswith("rgx/"):
        link = subprocess.check_output(["git", "rev-parse", base + ":rgx"], text=True).strip()
        raw = subprocess.check_output(["git", "-C", "rgx", "show", link + ":" + relative[4:]])
    else:
        raw = subprocess.check_output(["git", "show", base + ":" + relative])
    source = raw.decode("utf-8")
    bounds = m.migration_section_bounds(source) if relative == m.MIGRATION_GUIDE else None
    locations = {(v.start(), v.end()) for v in m.EXACT_SELECTOR.finditer(source)}
    for pattern, flags in [(r"`([^`\n]+)`", 0), (r"```[^\n]*\n(.*?)```", re.S)]:
        for code in re.finditer(pattern, source, flags):
            locations.update((code.start(1) + v.start(), code.start(1) + v.end())
                             for v in m.CODE_SELECTOR.finditer(code.group(1)))
    for start, end in sorted(locations):
        context = m.sentence_at(source, start, end)
        classified = bool(m.NEGATIVE_CONTEXT.search(context) or
                          (bounds and bounds[0] <= start < bounds[1]))
        references.append(dict(path=relative, line=source.count("\n", 0, start) + 1,
                               text=source[start:end], classified=classified, context=context))
result = dict(base=base, public_files=len(paths), references=references,
              expected=m.EXPECTED_CLASSIFIED_REFERENCE_COUNT)
output = Path(".linkedspec-data/scratch/lua18/public-selector-references.json")
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(result, indent=2) + "\n")
bad = [r for r in references if not r["classified"]]
assert len(paths) == 62 and len(references) == 35 and len(bad) == 1
assert bad[0]["path"] == "docs/linkedspec-book/src/overview/project-status.md"
assert bad[0]["line"] == 857
print("baseline selector census: 62 files, 35 references, expected32; one unclassified example at line857")
LUA18_SELECTOR_BASELINE
```

# Exact native replay

The corrected 2477-byte payload SHA-256 is
`e4c08519ff8ba488bf16bdbc5d91f61c99cb46e122984eee39af8ab8328e4632`.
Run from repository root; the managed wrapper builds and cleans native adapters.

```bash
bash tools/project_data_run.sh python3 - <<'LUA18_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua18/helper-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''local l=require("linkedspec")
local j=l.json
local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
local function run(code,input)
 local spec=l.parse_spec('Top::\n /x/\n E { '..code..' }\n')
 return l.runtime_parse(l.runtime_engine(l.compile_spec(spec)),input or "").value
end
print("RUNTIME",_VERSION,jit and jit.version or "PUC")
for _,delimiter in ipairs({'false','true','0','"-"','""'}) do
 local direct=run('return(join_values('..delimiter..', ["a", "b"]))')
 local receiver=run('return(["a", "b"].join_values('..delimiter..'))')
 if delimiter=='false' then
  assert(direct=="a0b" and receiver=="ab")
  print("FALSE_JOIN_OBSERVATION",direct,receiver)
 else check(direct==receiver,"join function/receiver agreement") end
 local pure=run('return(split("a0b", '..delimiter..'))')
 local mutable=run('split(parts, "a0b", '..delimiter..'); return(parts)')
 if delimiter=='false' then
  assert(j.encode(pure)=='["a","b"]' and j.encode(mutable)=='["a","0","b"]')
  print("FALSE_SPLIT_OBSERVATION",j.encode(pure),j.encode(mutable))
 else check(j.encode(pure)==j.encode(mutable),"split pure/mutable agreement") end
end
check(run('return(if(true, false, 7))')==false,"selected false inline-if")
check(run('return(if(false, 7))')==j.null,"unmatched inline-if")
check(run('return(switch("b", case(a, 1), case(b, false), default(9)))')==false,"symbolic case and false result")
check(run('return(coalesce(false, 9))')==false,"coalesce retains false")
check(run('return(coalesce_nonempty("", false, 9))')==false,"nonempty coalesce retains false")
check(run('return("é🙂z".substr(1, 1))')=="🙂","scalar-based substring")
check(j.encode(run('return([1, 2, 3].take_last(2))'))=='[2,3]',"copied tail selection")
check(j.encode(run('return([1, 2, 3].slice(1, 1))'))=='[2]',"zero-based array slice")
check(j.encode(run('return({"b": 2, "a": false}.sorted_values())'))=='[false,2]',"sorted harray values preserve false")
check(j.encode(run('return([1, [2, 3]].map_leaves() { return(value) })'))=='[1,[2,3]]',"root-kind callback traversal")
check(run('return(input_len())','é🙂')==2,"Unicode input length")
check(run('return(input_slice(1, 1))','é🙂')=="🙂","Unicode input slice")
check(run('mark_input_end(endmark); return(mark_pos(endmark))','é🙂')==2,"named mark scalar position")
check(run('mark_input_end(endmark); clear_mark(endmark); return(mark_exists(endmark))','é🙂')==0,"clear current mark")
print("VALID_HELPER_CONTROLS",checks)
''')
LUA18_REPLAY
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua18/helper-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua18/helper-proof.lua
```

# Continuity

The reading leaf preserves all source and prior evidence, owns both confirmed
helper defects before implementation, synchronizes the book and next-action
frontiers, and runs source/range, preservation, Knowledge, memory, histories and
rendering checks before its normal doctrine-governed commit. Independent coverage
passes 99 files /51 groups /149 ranges. Preservation confirms 1,380 prior source,
card, decision and history files; 2,452 unchanged prior task nodes; exactly six new
pending nodes; all 59 prior Known headings; exact chronology suffixes and both
executed replay payloads. Knowledge is 1,094 facts /8,792 keys, memory60 lines,
histories270/417 lines (notes warning, no rollover) and rendered book passes.
The existing 10,041,602-byte search-index warning retains startup .41.9 ownership.
The production public-selector baseline failure above remains explicitly open.
