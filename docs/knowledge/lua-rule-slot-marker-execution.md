---
id: lua-rule-slot-marker-execution
title: Lua executes split-boundary and named-mark rule members as typed post-action slot events
answers:
  - does Lua execute @capture_slice rule members
  - does Lua execute @capture_from_here and @move_pos
  - does Lua execute @mark name rule members
  - when are Lua split marker effects visible
  - how does Lua compile split markers
  - does an inline @move_pos have a Lua rule slot owner
  - are malformed Lua marker names typed
date: 2026-09-21
status: current
tags: [lua, capture, marks, compiler, runtime, timing, unicode, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.4 adds CompiledRuleSlotEvent records in lua/src/linkedspec/compiled_spec.lua and post-action/pre-LE execution in lua/src/linkedspec/interpreter.lua. lua/test/run.lua locks all three anonymous spellings, two named marks, same-slot versus later-slot timing, Unicode positions, native and serialized-source execution, typed malformed authored/manual AST markers, and inline @move_pos ownership (now tested with a LinkedSpec-authored fixture). Historical July15 proof: tools/run_lua_local.sh passed 121/121 on PUC Lua and LuaJIT; canonical CI passes capability 64/0/0, coverage 246/105+1/122, selector admission 57/27/0, CLI 61x2, and Phase 0 1..1031 in 633 seconds."
evidence_update_2026_09_21: "BACKEND-INTEGRATION-GUIDES.8.6 replaces a dependency-owned input with Pair:AND /a/ /b/ @move_pos. The selected existing test fails with dependency access denied before opening on both retained ABIs, then passes 1/1 with zero denied opens on PUC5.5.1 and LuaJIT2.1.1788460057. All surrounding test bytes and six native product hashes/mtimes stay exact; empty stderr, no builds or dependency-source inspection. This is fixture isolation, not a full-suite or Lua5.4 admission."
reverify: "Use the retained-product selected recheck below. The historical full-suite command is bash tools/run_lua_local.sh; .8.6 did not rerun that suite."
---

# Lua Rule-Slot Marker Execution

`LUA-BACKEND-PARITY.4.3.7.4` turns each valid `SplitMarkerBodyElementKind` into a typed
`CompiledRuleSlotEvent` attached to the preceding regex index. Preferred `@capture_slice` and compatibility
`@capture_from_here` / `@move_pos` canonicalize to `capture_boundary`; `@mark(name)` canonicalizes to
`named_mark` while preserving its identifier, source, and line. The events survive dependency resolution and
appear in both compiled-state and outward descriptor serialization.

After one regex slot matches, Lua first dispatches its action edges and child calls, then executes that slot's
events, then runs `LE`. A same-slot action therefore observes the old boundary/mark state; an action at a later
slot observes the update. Capture events call the existing anonymous-boundary setter, and named events write the
existing parse-scoped `rule label -> mark name -> UTF-8 byte offset` store. There is no marker-only shadow state.

The focused input `é(α🙂,βγ)` makes UTF-8 byte offsets diverge from public character positions and proves the
timing through native execution plus reconstruction from public source AST JSON. The test uses the locally
authored `Pair:AND /a/ /b/ @move_pos` rule and proves one event with preserved spelling at regex slot1.
The September21 fixture supersedes its former dependency-owned input; dependency grammar content is not an
authority for LinkedSpec marker behavior. Empty, digit-leading, hyphenated, trailing-fragment, and prefix-typo
authored markers fail typed validation; a malformed validation-bypassed AST fails with stable compiled error
fields.

## Selected marker recheck

Run from the repository root with the already prepared PUC and LuaJIT products from
`examples/integration/lua/`. This selects the existing test in a scratch copy, rejects dependency
file access before opening, and leaves the maintained suite and native products unchanged.
The full-suite counts above are dated July15 evidence. The known PUC malformed-regex formatter
issue and unverified declared Lua5.4 target retain their separate owners.

```sh
bash tools/project_data_run.sh python3 - <<'PY_RECHECK'
from pathlib import Path
import hashlib, os, shutil, subprocess
root = Path.cwd()
work = root / '.linkedspec-data/scratch/lua-marker-recheck'
work.mkdir(parents=True, exist_ok=True)
name = 'runtime split and named-mark rule-slot events execute after their matched action sites'
source = (root / 'lua/test/run.lua').read_text()
needle = 'local function test(name, operation)\n'
assert source.count(needle) == 1
assert source.count('test("' + name + '", function()') == 1
source = source.replace(needle, needle + '  if name ~= "' + name + '" then return end\n', 1)
prelude = r'''local root = assert(os.getenv("LINKEDSPEC_REPO_ROOT"))
package.path = root .. "/lua/src/?.lua;" .. root .. "/lua/src/?/init.lua"
package.cpath = assert(os.getenv("LINKEDSPEC_LUA_NATIVE_ROOT")) .. "/?.so"
local original_open = io.open
io.open = function(path, ...)
  local relative = tostring(path):gsub("^%./", "")
  assert(relative ~= "rgx" and relative:sub(1, 4) ~= "rgx/"
    and relative ~= root .. "/rgx"
    and relative:sub(1, #root + 5) ~= root .. "/rgx/",
    "selected marker proof rejects dependency-file access before opening")
  return original_open(path, ...)
end
'''
harness = work / 'selected.lua'
harness.write_text(prelude + source)
products = sorted((root / 'examples/integration/lua/build/native').glob('*/*.so'))
assert len(products) == 6
def identity(path):
    return hashlib.sha256(path.read_bytes()).hexdigest(), path.stat().st_mtime_ns
before = [identity(path) for path in products]
for abi, command in [('puc', 'lua'), ('luajit', 'luajit')]:
    runtime = shutil.which(command)
    assert runtime
    native = root / 'examples/integration/lua/build/native' / abi
    env = dict(os.environ, LINKEDSPEC_REPO_ROOT=str(root),
               LINKEDSPEC_LUA_NATIVE_ROOT=str(native), LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
    result = subprocess.run(['bash', 'tools/project_data_run.sh', runtime, '-E', str(harness)],
                            env=env, capture_output=True, text=True, timeout=180)
    assert result.returncode == 0 and not result.stderr, (result.returncode, result.stdout, result.stderr)
    assert result.stdout == 'ok 1 - ' + name + '\n1..1\n', result.stdout
    print(abi + ': PASS selected marker test, no dependency input or native build')
assert before == [identity(path) for path in products]
PY_RECHECK
```

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.7.4`.
- Timing contract: [[split-boundary-marker-action-timing]].
- State taxonomy: [[spec-capture-mark-family-taxonomy]].
- Runtime-family audit: [[lua-capture-cursor-runtime-audit]].
