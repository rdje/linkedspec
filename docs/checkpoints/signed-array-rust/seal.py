"""One-shot artifact manifest and actual readonly publication result."""
import json
import common as c
import publish


def main():
    paths=sorted(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir()
        if path.is_file() and path.name not in publish.RESERVED)
    assert paths and c.PREFIX+'README.md' in paths
    c.write_new('artifacts.json',dict(version=1,owner=c.OWNER,
        inputs={path:c.identity(path) for path in paths},
        scope='All physical publication inputs except the three explicitly reserved publication/control envelopes. Actual recorded source/executable epochs supply dated runtime inputs; no current runtime rebuild is performed by the reader. The claim record separately gates every final file, including these envelopes.'))
    run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()[-3000:]
    result=json.loads(c.decode(run['stdout_base64']))
    c.write_new('publication.json',dict(producer=c.read(c.PREFIX+'seal.py'),run=run,result=result))
    print('Actual readonly publication PASS:',len(paths),'bound physical inputs.',flush=True)


if __name__=='__main__':main()
