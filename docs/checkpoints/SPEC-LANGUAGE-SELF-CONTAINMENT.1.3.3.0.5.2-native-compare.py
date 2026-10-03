"""Observe marker result and malformed-group boundaries through documented PUC CLI."""
from pathlib import Path
import json,os,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2-'
rows={r['id']:r['source'] for r in json.loads((ROOT/(PREFIX+'cases.json')).read_bytes())}
rows.update(missing_endif='Top:: I { cb={|| if(true); return("hit") }; return(cb()) }',duplicate_else='Top:: I { cb={|| if(true); return("hit"); else(); return("bad"); else(); return("bad"); endif() }; return(cb()) }',extra_endif='Top:: I { cb={|| if(true); return("hit"); endif(); endif() }; return(cb()) }')
scratch=ROOT/'.linkedspec-data/scratch/codeblock-marker-if/native-comparison'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.resolve().is_relative_to(ROOT/'.linkedspec-data/scratch') and scratch.stat().st_dev==ROOT.stat().st_dev
out=[]
for id in ('implicit_true','implicit_false','missing_endif','duplicate_else','extra_endif'):
 fixture=scratch/(id+'.spec'); fixture.write_text(rows[id])
 command=['bash','tools/run_lua_project_data.sh','puc','lua/bin/linkedspec-lua','--spec-file',fixture.relative_to(ROOT).as_posix(),'--input','']
 run=subprocess.run(command,cwd=ROOT,env=os.environ,capture_output=True)
 out.append({'id':id,'source':rows[id],'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode()})
print(json.dumps({'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2','limits':'Public PUC CLI comparison/diagnostics only; no backend admission.','cases':out},indent=2))
