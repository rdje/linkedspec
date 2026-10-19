"""Preserve four original observations and capture only the remaining disabled case."""
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
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
target=ROOT/(PREFIX+'selection.json');assert not target.exists()
original_source=(ROOT/(PREFIX+'capture-selection.py')).read_bytes()
original_reached=(ROOT/(PREFIX+'selection-reached.json.gz')).read_bytes()
rows=json.loads(gzip.decompress(original_reached))
assert [r['name'] for r in rows]==['healthy','missing-suite','missing-helper','duplicate-suite']
assert all(r['returncode']==0 and r['inputs_unchanged'] and r['modes_unchanged'] for r in rows)
assert all(rows[0]['oracle'].values())
assert not all(rows[3]['oracle'].values()) and rows[3]['oracle']['execution_population'] is True
assert (len(rows[3]['syntax']),rows[3]['files'],rows[3]['assertions'])==(138,91,30394)
combined=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-selection.log').read_bytes()
assert b"if name in ('missing-suite','duplicate-suite')" in combined and combined.rstrip().endswith(b'AssertionError')
packed=(ROOT/(PREFIX+'selection-inputs.json.gz')).read_bytes();capsule=json.loads(gzip.decompress(packed))
assert decode(capsule[PREFIX+'capture-selection.py']['bytes_base64'])==original_source
for p,v in capsule.items():assert (ROOT/p).read_bytes()==decode(v['bytes_base64']) and (ROOT/p).stat().st_mode&0o7777==v['mode']
failure=dict(result='RETAINED',original_producer=PREFIX+'capture-selection.py',original_producer_sha256=sha(original_source),
    original_reached_sha256=sha(original_reached),original_exit_observed=1,original_combined_base64=encode(combined),
    scope='Four actual source/channel observations remain exact. Duplicate syntax138 is RED while prove reports91/30394; the old postcondition incorrectly requires both populations to change. Only the remaining disabled case is executed by a distinct producer. No original row/source/channel is refreshed or relabeled.')
with (ROOT/(PREFIX+'selection-native-failure.json')).open('x') as output:output.write(json.dumps(failure,indent=2)+'\n')
runner=(ROOT/'tools/run_ci_local.sh').read_bytes();block=(ROOT/(PREFIX+'registration-block.sh')).read_bytes()
functions=[]
for name in ('log','fail','require_tracked_file'):
    matches=list(re.finditer(rb'^'+name.encode()+rb'\(\) \{\n.*?^\}\n',runner,re.M|re.S));assert len(matches)==1
    functions.append(matches[0].group())
payload=b'set -euo pipefail\n'+b'\n'.join(functions)+block.replace(b'PERL5OPT= prove -Iperl',b'PERL5OPT= true',1)
script=PREFIX+'selection-disabled-execution.sh'
with (ROOT/script).open('xb') as output:output.write(payload)
environment=dict(os.environ,PERL5LIB='',PERL5OPT='',LINKEDSPEC_EVENT_ORDER_BASELINE='0',LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL',None)
command=['bash',script];run=subprocess.run(command,cwd=ROOT,env=environment,capture_output=True)
syntax=[v.decode() for v in re.findall(rb'^(.+?) syntax OK\r?$',run.stderr,re.M)]
registration=json.loads((ROOT/(PREFIX+'registration.json')).read_bytes())
row=dict(name='disabled-execution',command=command,script_sha256=sha(payload),returncode=run.returncode,
    stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr),syntax=syntax,executed=[],files=None,assertions=None,
    oracle=dict(syntax_population=syntax==registration['suites']+registration['helpers'],execution_population=False,complete_summary=False,successful_prove=False),
    inputs_unchanged=all((ROOT/p).read_bytes()==decode(v['bytes_base64']) for p,v in capsule.items()),
    modes_unchanged=all((ROOT/p).stat().st_mode&0o7777==v['mode'] for p,v in capsule.items()))
rows.append(row)
reached=gzip.compress(json.dumps(rows,sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'selection-final-reached.json.gz')).open('xb') as output:output.write(reached)
assert run.returncode==0 and len(syntax)==137 and row['oracle']['syntax_population'] and row['inputs_unchanged'] and row['modes_unchanged']
assert b'Result: PASS' not in run.stdout and not re.search(rb'^Files=',run.stdout,re.M) and not re.search(rb'^\S+\.t\s+\.+\s+ok',run.stdout,re.M)
record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),first_producer_sha256=sha(original_source),
    first_reached_sha256=sha(original_reached),capsule_sha256=sha(packed),reached_sha256=sha(reached),
    reached_path=PREFIX+'selection-final-reached.json.gz',
    actors={r['name']:dict(path=PREFIX+('finish-selection.py' if r['name']=='disabled-execution' else 'capture-selection.py'),
        sha256=sha(Path(__file__).read_bytes()) if r['name']=='disabled-execution' else sha(original_source)) for r in rows},
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in capsule.items()},
    rows=[{k:v for k,v in r.items() if k not in ('stdout_base64','stderr_base64')} for r in rows],
    scope='Four original actual observations retain their unchanged original producer and full reached bytes/channels. A distinct finisher executes only disabled execution and assembles the final five-case report with per-case actors. Four actual exit-zero faults are distinguished: missing suite/helper and disabled execution, plus duplication at syntax138 while prove reports the original unique91/30394. Provisional Python auditor bytes are inert guarded context; final corrected audit/canonical proof remain separate. No fixture/runtime, original observation, source, mode or host-toolchain refresh.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
print('Selected proof finalized:four original rows/producers exact;new disabled137/0/exit0;four effective faults')
