"""Run the actual canonical block and distinguish green-but-incomplete selections."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'selection.json');assert not target.exists()
registration=json.loads((ROOT/(PREFIX+'registration.json')).read_bytes())
seed=json.loads((ROOT/(SEED+'consumers.json')).read_bytes())
suites=registration['suites'];helpers=registration['helpers']
assert suites==seed['command'][3:] and len(suites)==91 and len(helpers)==46
source=(ROOT/'tools/run_ci_local.sh').read_bytes()
block=(ROOT/(PREFIX+'registration-block.sh')).read_bytes()
assert source.count(block)==1 and sha(source)==registration['runner_after_sha256']
functions=[]
for name in ('log','fail','require_tracked_file'):
    matches=list(re.finditer(rb'^'+name.encode()+rb'\(\) \{\n.*?^\}\n',source,re.M|re.S))
    assert len(matches)==1;functions.append(matches[0].group())
prefix=b'set -euo pipefail\n'+b'\n'.join(functions)
cases=[('healthy',block),
    ('missing-suite',block.replace(b' t/actionir_array_receiver_required_capture.t\n',b'',1)),
    ('missing-helper',block.replace(b' t/actionir_receiver_scalar_copy_probe.pl\n',b'',1)),
    ('duplicate-suite',block.replace(b' t/actionir_array_receiver_required_capture.t\n',b' t/actionir_array_receiver_required_capture.t\n'*2,1)),
    ('disabled-execution',block.replace(b'PERL5OPT= prove -Iperl',b'PERL5OPT= true',1))]
assert all(value!=block for name,value in cases[1:])
paths=set(seed['inputs'])|{SEED+n for n in ('consumers.json','consumers-inputs.json.gz','consumers-channels.json.gz')}
paths.update({'tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py',
    'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',
    PREFIX+'capture-selection.py',PREFIX+'registration.json',PREFIX+'registration-block.sh'})
capsule={}
for p in sorted(paths):
    source_path=ROOT/p;value=source_path.read_bytes()
    if p in seed['inputs']:
        assert sha(value)==seed['inputs'][p] and source_path.stat().st_mode&0o7777==seed['modes'][p]
    capsule[p]=dict(sha256=sha(value),mode=source_path.stat().st_mode&0o7777,bytes_base64=encode(value))
packed=gzip.compress(json.dumps(capsule,sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'selection-inputs.json.gz')).open('xb') as output:output.write(packed)
environment=dict(os.environ,PERL5LIB='',PERL5OPT='',LINKEDSPEC_EVENT_ORDER_BASELINE='0',LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL',None)
rows=[]
for name,value in cases:
    script=PREFIX+'selection-'+name+'.sh'
    payload=prefix+value
    with (ROOT/script).open('xb') as output:output.write(payload)
    before={p:sha((ROOT/p).read_bytes()) for p in paths}
    command=['bash',script]
    run=subprocess.run(command,cwd=ROOT,env=environment,capture_output=True)
    syntax=[v.decode() for v in re.findall(rb'^(.+?) syntax OK\r?$',run.stderr,re.M)]
    executed=[v.decode() for v in re.findall(rb'^(\S+\.t)\s+\.+\s+ok\b',run.stdout,re.M)]
    summary=re.findall(rb'^Files=([0-9]+), Tests=([0-9]+),',run.stdout,re.M)
    files,assertions=(tuple(map(int,summary[0])) if len(summary)==1 else (None,None))
    oracle=dict(syntax_population=syntax==suites+helpers,
        execution_population=executed==suites,complete_summary=(files==91 and assertions==30394),
        successful_prove=b'Result: PASS' in run.stdout)
    row=dict(name=name,command=command,script_sha256=sha(payload),returncode=run.returncode,
        stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr),syntax=syntax,executed=executed,
        files=files,assertions=assertions,oracle=oracle,
        inputs_unchanged=before=={p:sha((ROOT/p).read_bytes()) for p in paths},
        modes_unchanged=all((ROOT/p).stat().st_mode&0o7777==v['mode'] for p,v in capsule.items()))
    rows.append(row)
    reached=gzip.compress(json.dumps(rows,sort_keys=True).encode(),mtime=0)
    (ROOT/(PREFIX+'selection-reached.json.gz')).write_bytes(reached)
    assert run.returncode==0 and row['inputs_unchanged'] and row['modes_unchanged'],('actual selected command/input custody',name,run.stderr)
    if name=='healthy':assert all(oracle.values()),('complete actual selected population',oracle,executed,syntax)
    else:
        assert not all(oracle.values()),('effective selection oracle RED',name)
        if name in ('missing-suite','duplicate-suite'):assert not oracle['syntax_population'] and not oracle['execution_population']
        elif name=='missing-helper':assert not oracle['syntax_population'] and oracle['execution_population'] and oracle['complete_summary']
        else:assert oracle['syntax_population'] and not oracle['execution_population'] and not oracle['successful_prove']
    print('Actual selection case retained:',name,'exit',run.returncode,'files',files,'assertions',assertions,'complete',all(oracle.values()),flush=True)
report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
    capsule_sha256=sha(packed),reached_sha256=sha((ROOT/(PREFIX+'selection-reached.json.gz')).read_bytes()),
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in capsule.items()},
    rows=[{k:v for k,v in row.items() if k not in ('stdout_base64','stderr_base64')} for row in rows],
    scope='Exact real runner log/fail/tracked functions and complete explicit Bash block execute in the original project. Healthy137 syntax paths/91 suites/30394 assertions pass. Four actual exit-zero counterfactuals distinguish missing suite/helper, duplicate suite and disabled execution using independent ordered syntax/prove populations and full harness summary. All actual command channels/scripts and complete supplied inputs/modes remain retained; no fixture/runtime changes, copied-root, arbitrary-shell or full immutable host-toolchain claim.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
print('Actual selected-block proof PASS:137 syntax paths;91 suites/30394 assertions;four effective exit-zero faults')
