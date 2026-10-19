"""Readonly complete selected-block source/channel/population review."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(n):return json.loads(raw(PREFIX+n))
seed_raw=raw(SEED+'consumers.json');seed=json.loads(seed_raw)
assert seed_raw==subprocess.check_output(['git','show',BASE+':'+SEED+'consumers.json'],cwd=ROOT)
original_packed=raw(SEED+'consumers-inputs.json.gz')
assert sha(original_packed)==seed['capsule_sha256']
original=json.loads(gzip.decompress(original_packed))
assert set(original)==set(seed['inputs']) and len(original)==363
suites=seed['command'][3:]
helpers=sorted(p for p in original if p.startswith('t/') and p.endswith('.pl'))
assert len(suites)==len(set(suites))==91 and len(helpers)==46
old_channels=json.loads(gzip.decompress(raw(SEED+'consumers-channels.json.gz')))
assert old_channels['returncode']==0 and old_channels['command']==seed['command']
old_stdout=decode(old_channels['stdout_base64'])
old_summary=re.search(rb'^Files=([0-9]+), Tests=([0-9]+),',old_stdout,re.M)
assert old_summary and tuple(map(int,old_summary.groups()))==(91,30394)
record=load('selection.json');packed=raw(PREFIX+'selection-inputs.json.gz')
assert record['result']=='PASS' and record['producer_sha256']==sha(raw(PREFIX+'finish-selection.py'))
assert record['first_producer_sha256']==sha(raw(PREFIX+'capture-selection.py'))
assert record['capsule_sha256']==sha(packed)
capsule=json.loads(gzip.decompress(packed))
assert set(capsule)==set(record['inputs']) and set(original)<=set(capsule),'complete supplied selection input population'
for p,row in original.items():
    value=decode(row['bytes_base64'])
    assert row['sha256']==seed['inputs'][p]==sha(value)
    assert raw(p)==value and (ROOT/p).stat().st_mode&0o7777==row['mode']==seed['modes'][p]
    assert capsule[p]==row,'all363 original supplied selection bytes and modes'
for p,row in capsule.items():
    value=decode(row['bytes_base64'])
    assert sha(value)==row['sha256'] and record['inputs'][p]==dict(sha256=sha(value),mode=row['mode'])
    if p=='tests/language-readiness/verify_objectives.py':
        # Bash never executes this Python source; it was an observed source guard.
        assert value==raw(PREFIX+'auditor-first.py'),'retained provisional non-executed auditor context'
    else:
        assert raw(p)==value and (ROOT/p).stat().st_mode&0o7777==row['mode'],'actual selected input custody'
runner=raw('tools/run_ci_local.sh');block=raw(PREFIX+'registration-block.sh')
registration=load('registration.json')
assert registration['suites']==suites and registration['helpers']==helpers
assert sha(runner)==registration['runner_after_sha256'] and runner.count(block)==1
functions=[]
for name in ('log','fail','require_tracked_file'):
    matches=list(re.finditer(rb'^'+name.encode()+rb'\(\) \{\n.*?^\}\n',runner,re.S|re.M))
    assert len(matches)==1;functions.append(matches[0].group())
prefix=b'set -euo pipefail\n'+b'\n'.join(functions)
variants=dict(healthy=block,
    **{'missing-suite':block.replace(b' t/actionir_array_receiver_required_capture.t\n',b'',1),
       'missing-helper':block.replace(b' t/actionir_receiver_scalar_copy_probe.pl\n',b'',1),
       'duplicate-suite':block.replace(b' t/actionir_array_receiver_required_capture.t\n',b' t/actionir_array_receiver_required_capture.t\n'*2,1),
       'disabled-execution':block.replace(b'PERL5OPT= prove -Iperl',b'PERL5OPT= true',1)})
assert record['reached_path']==PREFIX+'selection-final-reached.json.gz'
reached_raw=raw(record['reached_path'])
assert sha(reached_raw)==record['reached_sha256']
rows=json.loads(gzip.decompress(reached_raw))
assert [v['name'] for v in rows]==list(variants) and len(record['rows'])==5,'complete actual selected case population'
first_raw=raw(PREFIX+'selection-reached.json.gz')
assert sha(first_raw)==record['first_reached_sha256'] and json.loads(gzip.decompress(first_raw))==rows[:4],'four unchanged original observations'
failure=load('selection-native-failure.json')
assert failure['original_reached_sha256']==sha(first_raw) and failure['original_producer_sha256']==record['first_producer_sha256']
assert failure['original_exit_observed']==1 and b"if name in ('missing-suite','duplicate-suite')" in decode(failure['original_combined_base64'])
for row,index in zip(rows,record['rows']):
    name=row['name'];assert {k:v for k,v in row.items() if k not in ('stdout_base64','stderr_base64')}==index
    actor='finish-selection.py' if name=='disabled-execution' else 'capture-selection.py'
    assert record['actors'][name]==dict(path=PREFIX+actor,sha256=sha(raw(PREFIX+actor))),'actual per-case producer custody'
    script=PREFIX+'selection-'+name+'.sh';payload=raw(script)
    assert payload==prefix+variants[name] and sha(payload)==row['script_sha256'],'exact actual selected script'
    assert row['command']==['bash',script] and row['returncode']==0
    assert row['inputs_unchanged'] and row['modes_unchanged']
    stdout=decode(row['stdout_base64']);stderr=decode(row['stderr_base64'])
    syntax=[]
    for line in stderr.splitlines():
        if line.endswith(b' syntax OK'):syntax.append(line[:-len(b' syntax OK')].decode())
    executed=[match[1].decode() for match in re.finditer(rb'^(\S+\.t)[ \t]+[.]+[ \t]+ok(?:[ \t]|$)',stdout,re.M)]
    matches=list(re.finditer(rb'^Files=([0-9]+), Tests=([0-9]+),',stdout,re.M))
    assert len(matches)<=1
    files,assertions=tuple(map(int,matches[0].groups())) if matches else (None,None)
    assert syntax==row['syntax'] and executed==row['executed'] and (files,assertions)==(row['files'],row['assertions'])
    expected_suites=list(suites);expected_helpers=list(helpers)
    if name=='missing-suite':expected_suites.remove('t/actionir_array_receiver_required_capture.t')
    if name=='missing-helper':expected_helpers.remove('t/actionir_receiver_scalar_copy_probe.pl')
    if name=='duplicate-suite':
        i=expected_suites.index('t/actionir_array_receiver_required_capture.t');expected_suites.insert(i,expected_suites[i])
    assert syntax==expected_suites+expected_helpers,'complete expected syntax population'
    expected_execution=[] if name=='disabled-execution' else (suites if name=='duplicate-suite' else expected_suites)
    assert executed==expected_execution,'complete expected execution population'
    oracle=dict(syntax_population=syntax==suites+helpers,execution_population=executed==suites,
        complete_summary=(files,assertions)==tuple(map(int,old_summary.groups())),successful_prove=b'Result: PASS' in stdout)
    assert row['oracle']==oracle
    if name=='healthy':assert all(oracle.values()),'positive complete supplied population'
    else:assert not all(oracle.values()),'effective actual selected fault'
    if name!='disabled-execution':assert oracle['successful_prove'] and files==len(expected_execution)
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review-selection.py')),
    suites=91,helpers=46,supplied_inputs=363,assertions=30394,actual_faults=4,
    rows=[dict(name=v['name'],files=v['files'],assertions=v['assertions'],syntax_paths=len(v['syntax']),exit=v['returncode'],oracle=v['oracle']) for v in rows],
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Complete original supplied command363 byte/mode inputs, exact actual Bash helper/block/scripts and five full-channel observations. Independent native ordered syntax/test populations and original harness summary distinguish four exit-zero faults. Provisional auditor bytes were captured as inert guarded context and remain in auditor-first.py; Bash never executes them. Final corrected auditor has separate full proof/canonical ownership. No new fixture/runtime behavior, arbitrary-shell, copied-root or immutable host-toolchain claim.')
target=ROOT/(PREFIX+'selection-review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Selected block review PASS:363 original inputs;137 syntax/91 suites/30394 assertions;four actual exit-zero faults')
