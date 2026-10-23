"""Read-only recovery of complete CLI repair source epochs from accepted Git/images."""
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import common as c

EPOCHS = ['baseline-inputs.json.gz','qualification-inputs.json.gz','baseline2-inputs.json.gz',
    'pre-repair-inputs.json.gz','green-inputs.json.gz','inverse-inputs.json.gz',
    'restored-inputs.json.gz','documentation-inputs.json.gz','book-inputs.json.gz']

def packet(raw):
    value = c.decode(raw['base64'])
    assert c.sha(value) == raw['sha256']
    assert isinstance(raw['mode'],int) and 0 <= raw['mode'] <= 0o7777
    return value


def regular_tree():
    result = {}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name = row.split(b'\t',1)
            mode,kind,oid = metadata.decode().split()
            if mode in ('100644','100755'):
                assert kind == 'blob'
                result[name.decode()] = dict(mode=mode,oid=oid)
    return result


def git_digests(oids):
    """Read each required main-repository blob once; never traverse a Gitlink."""
    result = {}
    with tempfile.TemporaryFile(dir=os.environ['TMPDIR']) as requests, tempfile.TemporaryFile(dir=os.environ['TMPDIR']) as errors:
        requests.write(('\n'.join(sorted(oids))+'\n').encode())
        requests.seek(0)
        process = subprocess.Popen(['git','cat-file','--batch'],cwd=c.ROOT,
            stdin=requests,stdout=subprocess.PIPE,stderr=errors)
        try:
            for expected in sorted(oids):
                header = process.stdout.readline().decode().split()
                assert len(header) == 3 and header[:2] == [expected,'blob'], 'Git source object'
                remaining = int(header[2])
                digest = hashlib.sha256()
                while remaining:
                    raw = process.stdout.read(min(remaining,1024*1024))
                    assert raw, 'truncated Git source object'
                    digest.update(raw)
                    remaining -= len(raw)
                assert process.stdout.read(1) == b'\n'
                result[expected] = digest.hexdigest()
            assert process.wait() == 0
            errors.seek(0)
            assert not errors.read()
        finally:
            if process.poll() is None:
                process.kill()
            process.wait()
            process.stdout.close()
    return result


def source_epochs():
    tree = regular_tree()
    epochs = [c.load(name)['context'] for name in EPOCHS]
    objects = {tree[path]['oid'] for epoch in epochs for path in epoch['inputs']
        if path not in epoch['overrides'] and path in tree}
    digests = git_digests(objects)
    for epoch in epochs:
        assert epoch['base'] == epoch['head'] == c.BASE
        assert set(epoch['overrides']) <= set(epoch['inputs'])
        for path,item in epoch['inputs'].items():
            assert not Path(path).is_absolute() and '..' not in Path(path).parts
            assert isinstance(item['mode'],int) and 0 <= item['mode'] <= 0o7777
            if path in epoch['overrides']:
                supplied = epoch['overrides'][path]
                packet(supplied)
                assert {key:supplied[key] for key in ('sha256','mode')} == item, 'epoch override identity'
            elif path in tree:
                assert digests[tree[path]['oid']] == item['sha256'], 'Git epoch bytes: '+path
                assert bool(item['mode'] & 0o100) == (tree[path]['mode'] == '100755'), 'Git executable identity'
            else:
                assert path.startswith(c.PREFIX) and path.endswith(('.gz','.part')), 'unsupplied new input: '+path
                assert c.identity(path) == item, 'retained immutable epoch input: '+path
    return dict(epochs=len(epochs),base=c.BASE,unique_git_blobs=len(objects),
        limits='Complete conservative recorded source epochs, with full changed/new plain images and retained immutable inputs. Git identity and complete captured filesystem permissions remain distinct. No dependency implementation or minimal-I/O claim.')
