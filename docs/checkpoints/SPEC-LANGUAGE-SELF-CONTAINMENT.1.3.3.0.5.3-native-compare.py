"""Observe governed lazy value conditional results through documented PUC CLI."""
from pathlib import Path
import json,os,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-'
rows={r['id']:r['source'] for r in json.loads((ROOT/(PREFIX+'cases.json')).read_bytes())}
scratch=ROOT/'.linkedspec-data/scratch/codeblock-value-if/native-comparison'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.resolve().is_relative_to(ROOT/'.linkedspec-data/scratch') and scratch.stat().st_dev==ROOT.stat().st_dev
out=[]
for id in ('original','false','no_match','plain_fallback','elseif','nested'):
 fixture=scratch/(id+'.spec'); fixture.write_text(rows[id])
 command=['bash','tools/run_lua_project_data.sh','puc','lua/bin/linkedspec-lua','--spec-file',fixture.relative_to(ROOT).as_posix(),'--input','']
 run=subprocess.run(command,cwd=ROOT,env=os.environ,capture_output=True)
 out.append({'id':id,'source':rows[id],'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode()})
print(json.dumps({'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3','limits':'Public PUC CLI comparison/diagnostics only; no backend admission.','cases':out},indent=2))
