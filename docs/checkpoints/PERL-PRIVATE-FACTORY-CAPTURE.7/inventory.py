"""Inventory the complete supplied fixture population against literal CI commands."""
import base64
import gzip
import hashlib
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
RUNNER='tools/run_ci_local.sh'
AUDITOR='tests/language-readiness/verify_objectives.py'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)

def population():
    seed_raw=(ROOT/(SEED+'consumers.json')).read_bytes();seed=json.loads(seed_raw)
    packed=(ROOT/(SEED+'consumers-inputs.json.gz')).read_bytes()
    capsule=json.loads(gzip.decompress(packed))
    assert seed_raw==old(SEED+'consumers.json') and packed==old(SEED+'consumers-inputs.json.gz')
    assert seed['result']=='PASS' and seed['returncode']==0 and seed['unchanged']
    assert seed['capsule_sha256']==sha(packed) and len(seed['inputs'])==len(capsule)==363
    assert seed['command'][:3]==['prove','-v','-Iperl']
    suites=seed['command'][3:]
    assert len(suites)==len(set(suites))==91 and all(p.startswith('t/') and p.endswith('.t') for p in suites)
    helpers=sorted(p for p in capsule if p.startswith('t/') and p.endswith('.pl'))
    for p,row in capsule.items():
        value=decode(row['bytes_base64'])
        assert sha(value)==row['sha256']==seed['inputs'][p]
        assert (ROOT/p).read_bytes()==value,'unchanged complete supplied fixture input'
        assert (ROOT/p).stat().st_mode&0o7777==row['mode']==seed['modes'][p]
    assert set(suites)<=set(capsule)
    return seed,suites,helpers

def selected(source,suites,helpers):
    paths=set(suites+helpers);tracked=set();syntax=set();execution=set()
    for line in source.decode().replace('\\\n',' ').splitlines():
        line=line.strip()
        if not (line.startswith('require_tracked_file ') or line.startswith('perl -c ') or
                line.startswith('prove ') or re.match(r'(?:[A-Z][A-Z0-9_]*=[^ ]* +)+prove ',line)):continue
        words=shlex.split(line,comments=True)
        if words[0]=='require_tracked_file':
            assert len(words)==2
            tracked.update(set(words[1:]) & paths)
        elif words[0]=='perl':syntax.update(set(words[1:]) & paths)
        else:execution.update(set(words[words.index('prove')+1:]) & set(suites))
    return dict(tracked=sorted(tracked),syntax=sorted(syntax),execution=sorted(execution))

def main():
    assert sys.argv[1:] in (['--capture'],['--require-complete'],[])
    seed,suites,helpers=population()
    source=(ROOT/RUNNER).read_bytes();selection=selected(source,suites,helpers)
    missing={k:sorted(set(suites+helpers if k!='execution' else suites)-set(v)) for k,v in selection.items()}
    if sys.argv[1:]==['--require-complete']:
        assert not any(missing.values()),('complete supplied fixture selection',missing)
        print('Literal canonical fixture selection PASS:',len(suites),'suites;',len(helpers),'helpers')
        return
    target=ROOT/(PREFIX+'inventory.json')
    if not sys.argv[1:]:
        value=json.loads(target.read_bytes())
        assert value['producer_sha256']==sha(Path(__file__).read_bytes())
        assert value['suites']==suites and value['helpers']==helpers
        original=(ROOT/(PREFIX+'runner-original.sh')).read_bytes()
        assert original==old(RUNNER) and value['original_runner_sha256']==sha(original)
        assert value['original_selection']==selected(original,suites,helpers)
        for p,identity in value['inputs'].items():assert sha((ROOT/p).read_bytes())==identity
        assert value['original_red']['returncode']!=0
        assert b'complete supplied fixture selection' in decode(value['original_red']['stderr_base64'])
        print('Original fixture inventory PASS:',len(suites),'supplied suites;',len(helpers),'helpers;original omission RED retained')
        return
    assert not target.exists() and source==old(RUNNER)
    assert any(missing.values()),'actual original selection gap'
    for path,name in ((RUNNER,'runner-original.sh'),(AUDITOR,'auditor-original.py')):
        value=(ROOT/path).read_bytes();assert value==old(path)
        with (ROOT/(PREFIX+name)).open('xb') as output:output.write(value)
    command=['python3',PREFIX+'inventory.py','--require-complete']
    run=subprocess.run(command,cwd=ROOT,capture_output=True)
    assert run.returncode!=0 and b'complete supplied fixture selection' in run.stderr
    paths=[SEED+n for n in ('consumers.json','consumers-inputs.json.gz','consumers-channels.json.gz')]
    paths += [PREFIX+n for n in ('inventory.py','runner-original.sh','auditor-original.py')]
    paths += ['tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
    report=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
        original_runner_sha256=sha(source),suites=suites,helpers=helpers,supplied_inputs=363,
        original_selection=selection,original_missing=missing,
        original_red=dict(command=command,returncode=run.returncode,
            stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode()),
        supplied_input_identities=seed['inputs'],supplied_input_modes=seed['modes'],
        inputs={p:sha((ROOT/p).read_bytes()) for p in paths},
        scope='Complete accepted91-suite/363-input consumer population and every supplied t/*.pl helper; every current supplied byte/mode is unchanged. Original literal tracked/syntax/prove commands are inventoried at their exact paths, with actual omission RED. This direct-command baseline reader does not infer selection from filenames, links or incidental text, nor certify arbitrary shell evaluation. New explicit registration has its own source/behavior oracle. No original test or runtime implementation changes.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
    print('Original canonical omissions retained:',{k:len(v) for k,v in missing.items()},';91 suites;',len(helpers),'helpers;363 exact supplied inputs')

if __name__=='__main__':main()
