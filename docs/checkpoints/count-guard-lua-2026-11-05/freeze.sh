#!/usr/bin/env bash
# Freeze independently observed host fences before any production edit.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
git diff --quiet HEAD -- lua/src
bash tools/project_data_run.sh python3 - <<'PY'
import hashlib,json,subprocess
from pathlib import Path
out=Path('docs/checkpoints/count-guard-lua-2026-11-05')
record=out/'frozen-observations.json';assert not record.exists()
observations={}
for host in ['puc','luajit']:
 lines=(out/f'baseline-{host}-stdout.log').read_text().splitlines()
 def observed(marker):
  rows=[json.loads(line.split(marker,1)[1]) for line in lines if line.startswith(marker)]
  assert len(rows)==1,marker
  return rows[0]
 routes=observed('COUNT_GUARD_LUA_VALUE source_domain_diagnostic ')
 assert all(row==routes['native'] for row in routes.values())
 observations[host]={'domain':routes['native']['value'],'ast':observed('COUNT_GUARD_LUA_SHAPES '),'errors':{'needed_source_error':observed('COUNT_GUARD_LUA_ERROR needed_source_error ')}}
assert observations['puc']==observations['luajit'], 'host fences differ; assess before selecting shared expectations'
outputs={}
for name,value in observations['puc'].items():
 p=Path('tests/fixtures/count_result_guard_lua_'+name+'.json')
 assert not p.exists() or json.loads(p.read_text()) is None
 p.write_text(json.dumps(value,ensure_ascii=False,sort_keys=True,indent=2)+'\n');outputs[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
p=Path('lua/test/count_result_guard_composition_test.lua');s=p.read_text();old='      verify(actual.compile_error==nil,row.id .. " compiles")\n';assert s.count(old)==1
s=s.replace(old,old+'''      local file=assert(io.open("tests/fixtures/count_result_guard_lua_errors.json","r"))
      local frozen=json.decode(file:read("*a"));file:close()
      verify(json.encode(actual)==json.encode(frozen[row.id]),row.id .. " observed error fields stay frozen")
''');p.write_text(s);outputs[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
inputs=[out/'freeze.sh',out/'baseline-inputs.tar.gz',out/'baseline-head.txt',*[out/f'baseline-{h}-{c}.log' for h in ['puc','luajit'] for c in ['stdout','stderr','version-stdout','version-stderr']]]
result={'activation_commit':(out/'baseline-head.txt').read_text().strip(),'production_blob':subprocess.check_output(['git','rev-parse','HEAD:lua/src/linkedspec/interpreter.lua'],text=True).strip(),'inputs':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs},'outputs':outputs,'qualification':'Null AST/domain placeholders are observer bootstrap only. Both hosts were independently observed before selecting shared fences; message/flags/codes/selected diagnostic fields are preserved, not a full diagnostic schema or declared5.4 admission.'}
record.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print('Frozen both actual Lua hosts:',observations['puc']['domain'])
PY
