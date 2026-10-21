"""Correct the rejected shadow by installing old owned inputs and checking every loaded owner."""
import json
from pathlib import Path
import subprocess
import common as c
import context


def main():
    old=c.load('kind-library-inputs.json.gz')
    entries=old['entries']
    current={}
    for path in entries:
        target=c.ROOT/path
        assert not target.is_symlink(),path
        assert target.resolve().is_relative_to(c.ROOT.resolve()),path
        for parent in target.parents:
            if parent==c.ROOT:break
            assert not (parent/'.git').exists(),path
        current[path]=c.read(path) if target.exists() else None
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(current=current,revision=old['revision'],entries=entries,plan=old['plan'],
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')},
        scope='Initial shadow attempt is rejected because loaded-owner paths were not constrained. '
              'This controlled fresh replay installs real old regular main-repository inputs only, '
              'validates every loaded LinkedSpec byte identity, then restores full current modes/bytes. '
              'Current system/dependency prerequisites remain explicit; no other Git repository is written.')
    c.write_new('library-actual-inputs.json.gz',snapshot)
    created=[]
    try:
        for path,item in entries.items():
            target=c.ROOT/path
            missing=[];parent=target.parent
            while not parent.exists():missing.append(parent);parent=parent.parent
            for directory in reversed(missing):directory.mkdir();created.append(directory)
            target.write_bytes(c.decode(item['base64']));target.chmod(int(item['mode'],8)&0o777)
        run=c.run(['perl','-Iperl',c.PREFIX+'kinds.pl'],input=json.dumps(old['plan']).encode())
        c.write_new('library-actual-observed.json.gz',dict(run=run))
        value=json.loads(c.decode(run['stdout_base64'])) if run['returncode']==0 else None
        loaded={}
        if value is not None:
            for name,path in value['inc'].items():
                if not name.startswith('LinkedSpec'):continue
                target=(c.ROOT/path).resolve() if not path.startswith('/') else Path(path).resolve()
                relative=target.relative_to(c.ROOT.resolve()).as_posix()
                assert relative in entries,(name,relative)
                actual=c.read(relative)
                assert actual['sha256']==entries[relative]['sha256'],(name,relative)
                loaded[name]=dict(path=relative,sha256=actual['sha256'],mode=actual['mode'])
        c.write_new('library-actual-run.json.gz',dict(run=run,loaded=loaded,
            installed_unchanged=all((c.ROOT/path).read_bytes()==c.decode(item['base64']) for path,item in entries.items())))
    finally:
        for path,packet in current.items():
            target=c.ROOT/path
            if packet is None:
                assert target.read_bytes()==c.decode(entries[path]['base64'])
                target.unlink()
            else:target.write_bytes(c.decode(packet['base64']));target.chmod(packet['mode'])
        for directory in reversed(created):directory.rmdir()
        restored=all(c.read(path)==packet if packet is not None else not (c.ROOT/path).exists()
            for path,packet in current.items())
        c.write_new('library-actual-restoration.json.gz',dict(restored=restored))
    assert restored and c.unchanged(snapshot['inputs'])
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    assert not c.decode(run['stderr_base64']) and loaded
    print('Verified actual historical library:',len(entries),'installed inputs;',len(loaded),'loaded LinkedSpec owners')
    print([(row['id'],row['native']['value_json'],row['generated']['value_json']) for row in value['rows']])


if __name__=='__main__':main()
