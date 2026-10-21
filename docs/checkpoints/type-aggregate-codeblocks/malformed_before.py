"""Compare malformed public invoke diagnostics without mutating the candidate."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import common as c
import context


def main():
    path=c.SOURCE
    old=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(accepted_source=c.encode(old),current=c.read(path),
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')})
    c.write_new('malformed-before-inputs.json.gz',snapshot)
    current=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    with tempfile.TemporaryDirectory(prefix='aggregate-malformed-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==c.ROOT.stat().st_dev
        target=root/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(old)
        accepted=c.run(['perl','-I'+str(root/'perl'),'-Iperl',c.PREFIX+'malformed.pl'])
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('malformed-before-run.json.gz',dict(current=current,accepted=accepted,inputs_unchanged=stable))
    assert stable and current['returncode']==accepted['returncode']==0
    assert not c.decode(current['stderr_base64']) and not c.decode(accepted['stderr_base64'])
    new,old=[json.loads(c.decode(run['stdout_base64'])) for run in (current,accepted)]
    print('Current malformed diagnosis:',json.dumps(new,sort_keys=True))
    print('Accepted malformed diagnosis:',json.dumps(old,sort_keys=True))
    assert new['class']=='' and old['class']=='LinkedSpec::CodeblockRuntime::Error'
    assert old['fields']['code']=='invalid_codeblock_body' and old['fields']['detail']=='invalid fluent call'


if __name__=='__main__':main()
