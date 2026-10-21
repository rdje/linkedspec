"""Repair the root boundary after the five retained pre-guard chunk controls."""
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def probe():
    run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'admission/portable/guard_probe.py'])
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    return run,json.loads(c.decode(run['stdout_base64']))


def main():
    path=c.PREFIX+'large_inputs.py';before=c.read(path)
    assert before==c.load('admission/portable/proof-run.json.gz')['helper']
    old_run,old=probe()
    assert old['helper']==before and all(item['accepted'] for item in old['roots'].values())
    text=c.decode(before['base64']).decode()
    needle='    current=root\n'
    assert text.count(needle)==1
    after=text.replace(needle,
        "    ancestor=root\n    while ancestor!=c.ROOT:\n"
        "        if (ancestor/'.git').exists():raise ValueError('Nested repository boundary')\n"
        "        ancestor=ancestor.parent\n"+needle,1)
    compile(after,path,'exec')
    c.write_new('admission/portable/guard-change.json.gz',dict(before=before,after=c.encode(after.encode()),
        old_probe=old_run,producer=c.read(c.PREFIX+'admission/portable/guard.py'),
        scope='Actual non-writing path routing accepted an existing Gitlink as the alternate root. '
              'Reject that root/ancestors before any output; preserve all five pre-guard controls '
              'and follow with fresh final-helper cold reconstruction. No submodule write or '
              'implementation inspection occurs.'))
    (ROOT/path).write_text(after)
    new_run,new=probe()
    assert new['roots']['.']['accepted']
    assert all(not value['accepted'] and value['error']=='Nested repository boundary'
        for name,value in new['roots'].items() if name!='.')
    assert new['helper']==c.read(path)
    positive=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'admission/portable/guard_positive.py'])
    assert positive['returncode']==0 and not c.decode(positive['stderr_base64'])
    data=json.loads(c.decode(positive['stdout_base64']))
    assert data['helper']==new['helper'] and len(data['aliases'])==3
    c.write_new('admission/portable/guard-run.json.gz',dict(old_probe=old_run,new_probe=new_run,
        final_cold=positive,helper=c.read(path),producer=c.read(c.PREFIX+'admission/portable/guard.py'),
        scope='One actual read-only nested-root RED; final producer rejects it, allows the project '
              'root and cold-reconstructs all three full-byte/full-mode aliases on this volume. '
              'The five chunk/alias faults remain at the exact pre-guard source epoch.'))
    print('Final output-root guard PASS:actual metadata-only boundary RED/rejection;3 final cold aliases;no other repository writes')


if __name__=='__main__':main()
