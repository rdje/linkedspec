"""Replay exact95 fixtures with its accepted owned Perl library, without repository mutation."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import common as c

REVISION='35c00924cf0add082e94213da3d01394cb5993df'


def main():
    old=json.loads((c.ROOT/'docs/checkpoints/SESSION-STARTUP-READING.95-numeric-result-kinds.json').read_bytes())
    plan=dict(cases=[dict(id='catalog/'+str(index),source=row['source'],input=row['input'])
        for index,row in enumerate(old['observations'])])
    entries={}
    for row in subprocess.check_output(['git','ls-tree','-rz',REVISION,'--','perl','specs','conf','tablescript'],cwd=c.ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
        if mode not in ('100644','100755') or kind!='blob':continue
        path=name.decode();raw=subprocess.check_output(['git','cat-file','blob',oid],cwd=c.ROOT)
        entries[path]=dict(mode=mode,oid=oid,sha256=c.sha(raw),base64=c.encode(raw))
    producer=c.read(c.PREFIX+'recheck_historical_library.py')
    instrument=c.read(c.PREFIX+'kinds.pl')
    c.write_new('kind-library-inputs.json.gz',dict(revision=REVISION,entries=entries,plan=plan,
        producer=producer,instrument=instrument,scope='Whole owned regular Perl library and published syntax/config '
            'inputs at real accepted91, with current installed system Perl/JSON and published dependency outputs. '
            'Gitlinks/symlinks are excluded. This is a controlled fresh replay, not reconstruction of the '
            'unretained historical instrument/process environment. No other repository is written.'))
    with tempfile.TemporaryDirectory(prefix='aggregate95-library-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory)
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for path,item in entries.items():
            target=root/path;target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(c.decode(item['base64']));target.chmod(int(item['mode'],8)&0o777)
        (root/'kinds.pl').write_bytes(c.decode(instrument['base64']))
        # Current fallback supplies only documented dependency integration outputs.
        command=['perl','-Iperl','-I'+str(c.ROOT/'perl'),'kinds.pl']
        result=subprocess.run(command,cwd=root,input=json.dumps(plan).encode(),capture_output=True)
        run=dict(command=['perl','-I<same-volume historical perl>','-I<current published dependency integration>','kinds.pl'],
            returncode=result.returncode,stdout_base64=c.encode(result.stdout),stderr_base64=c.encode(result.stderr))
        c.write_new('kind-library-run.json.gz',dict(run=run,
            inputs_unchanged=all((root/path).read_bytes()==c.decode(item['base64']) for path,item in entries.items())))
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    assert not c.decode(run['stderr_base64'])
    actual=json.loads(c.decode(run['stdout_base64']))
    print('Accepted91 library direct JSON:',[(row['id'],row['native']['value_json'],row['generated']['value_json']) for row in actual['rows']])
    for name,path in actual['inc'].items():
        if path.startswith('perl/'):
            assert path in entries,(name,path)
    print('Historical owned inputs:',len(entries))


if __name__=='__main__':main()
