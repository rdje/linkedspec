"""Preserve the entire first unpublished pipeline publication before its report-label correction."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(root/'docs/checkpoints/type-array-pipelines'))
import common as c
import context
import publish

def main():
    paths=publish.input_paths();inputs={p:c.identity(p) for p in paths}
    declared=c.load('publication-inputs.json.gz');assert inputs==declared['inputs'] and len(inputs)==10716
    status=c.run(['git','status','--porcelain'])
    baseline=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    assert baseline['returncode']==0 and not c.decode(baseline['stderr_base64'])
    assert b'10716 closed physical inputs;85 values/41 accepted RED/6 restored faults' in c.decode(baseline['stdout_base64'])
    assert inputs=={p:c.identity(p) for p in publish.input_paths()} and c.run(['git','status','--porcelain'])==status
    images=paths+[publish.MANIFEST,publish.PUBLICATION,publish.CLAIM]
    saved=context.snapshot(images)
    tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0'))
    saved['new_inputs']={p:c.read(p) for p in images if p not in tracked and not p.endswith(('.gz','.part'))}
    assert len(saved['inputs'])==10719
    record=c.load('publication.json');assert len(record['result']['faults'])==7
    value=dict(context=saved,claim=c.read(publish.CLAIM),publication=c.read(publish.PUBLICATION),
        manifest=c.read(publish.MANIFEST),publisher=c.read(c.PREFIX+'publish.py'),
        producer=c.read(Path(__file__).resolve().relative_to(root).as_posix()),baseline=baseline,status=status,
        scope='Whole first unpublished10716-input publication/claim/full modes/10719 source images and actual source-readonly0 precede report correction. Its structured result has seven faults; its console label undercounts as six. No runtime/test/book result changes and no draft Git revision is invented. Every plain source recovers from whole packets or real49ce; immutable artifacts stay at exact byte/mode identities without recursive copying.')
    target=root/'.linkedspec-data/verification/type-pipeline-report-first.json.gz'
    with target.open('xb') as output:output.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    print('First pipeline publication preserved:10716 inputs/10719 full-mode images/actual readonly0; structured7 versus printed6 retained')

if __name__=='__main__':main()
