"""Exercise actual chunk faults and recover the three original logical inputs cold."""
import copy
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import context
import large_inputs
import review
import publish_final
from admission.collection import verify as collection


def rejected(name,action,expected):
    try:action()
    except ValueError as error:
        assert str(error)==expected,(name,str(error))
        return dict(name=name,rejected=True,error=str(error))
    raise AssertionError('Fault admitted: '+name)


def main():
    manifest=large_inputs.manifest()
    extras=[path.relative_to(ROOT).as_posix() for path in (ROOT/c.PREFIX).rglob('*')
        if path.is_file() and not path.is_symlink()]
    snapshot=context.snapshot(extras)
    assert not any(path.endswith(('.gz','.part')) for path in snapshot['overrides'])
    snapshot.update(helper=c.read(c.PREFIX+'large_inputs.py'),producer=c.read(c.PREFIX+'admission/portable/proof.py'))
    c.write_new('admission/portable/proof-inputs.json.gz',snapshot)
    item=manifest['objects'][0];parts=item['parts'][:2]
    paths=[ROOT/part['path'] for part in parts]
    original=[path.read_bytes() for path in paths]
    identities=[c.identity(part['path']) for part in parts]
    controls=[]
    with tempfile.TemporaryDirectory(prefix='aggregate-chunk-controls-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==ROOT.stat().st_dev
        def fresh(name):
            target=root/name;target.mkdir();return target
        absent=paths[0].with_name(paths[0].name+'.owned-backup')
        assert not absent.exists()
        paths[0].rename(absent)
        try:controls.append(rejected('missing-chunk',lambda:large_inputs.ensure_all(destination_root=fresh('missing')),'Missing proof chunk'))
        finally:absent.rename(paths[0])
        try:
            with paths[0].open('r+b') as output:output.write(bytes([original[0][0]^1]))
            controls.append(rejected('chunk-byte',lambda:large_inputs.ensure_all(destination_root=fresh('byte')),'Proof chunk bytes mismatch'))
        finally:
            with paths[0].open('r+b') as output:output.write(original[0][:1])
        shadow=copy.deepcopy(manifest)
        shadow['objects'][0]['parts'][0]['sha256']=parts[1]['sha256']
        shadow['objects'][0]['parts'][1]['sha256']=parts[0]['sha256']
        try:
            paths[0].write_bytes(original[1]);paths[1].write_bytes(original[0])
            controls.append(rejected('whole-order',lambda:large_inputs.ensure_all(shadow,fresh('order')),'Reassembled logical proof mismatch'))
        finally:
            paths[0].write_bytes(original[0]);paths[1].write_bytes(original[1])
        assert [c.identity(part['path']) for part in parts]==identities
        complete=fresh('complete')
        restored=large_inputs.ensure_all(destination_root=complete)
        assert set(restored)==large_inputs.LOGICAL_PATHS
        cache=complete/item['path'];mode=item['mode']
        try:
            cache.chmod(mode^0o100)
            controls.append(rejected('logical-mode',lambda:large_inputs.ensure_all(destination_root=complete),'Existing logical proof bytes or mode mismatch'))
        finally:cache.chmod(mode)
        try:
            with cache.open('r+b') as output:
                first=output.read(1);output.seek(0);output.write(bytes([first[0]^1]))
            controls.append(rejected('logical-byte',lambda:large_inputs.ensure_all(destination_root=complete),'Existing logical proof bytes or mode mismatch'))
        finally:
            with cache.open('r+b') as output:output.write(first)
        for entry in manifest['objects']:
            assert large_inputs.identity(complete/entry['path'])=={key:entry[key] for key in ('sha256','size','mode')}
    backup=ROOT/'.linkedspec-data/verification/type-aggregate-portable-originals'
    backup.mkdir()
    moved=[];use=None
    try:
        for index,entry in enumerate(manifest['objects']):
            old=ROOT/entry['path'];saved=backup/str(index)
            assert large_inputs.identity(old)=={key:entry[key] for key in ('sha256','size','mode')}
            old.rename(saved);moved.append((entry,saved))
        try:c.load('admission/doc-inputs.json.gz')
        except FileNotFoundError:cold_red=dict(rejected=True,error='FileNotFoundError')
        else:raise AssertionError('Cold logical aliases were not absent')
        recovered=large_inputs.ensure_all()
        assert set(recovered)==large_inputs.LOGICAL_PATHS
        third=c.load('admission/portable/third.json.gz')
        git=c.run(['git','hash-object','--no-filters','--']+[entry['path'] for entry in manifest['objects']])
        assert git['returncode']==0 and not c.decode(git['stderr_base64'])
        assert c.decode(git['stdout_base64']).decode().splitlines()==[
            third['images'][entry['path']]['git']['oid'] for entry in manifest['objects']]
        use=dict(review=review.check(False,doc_stem='admission/doc'),
            admission=publish_final.admission.check(),collection=collection.check())
        for entry,saved in moved:
            expected={key:entry[key] for key in ('sha256','size','mode')}
            assert large_inputs.identity(ROOT/entry['path'])==large_inputs.identity(saved)==expected
            saved.unlink()
        assert not list(backup.iterdir());backup.rmdir()
    finally:
        for entry,saved in moved:
            target=ROOT/entry['path']
            if saved.exists() and not target.exists():saved.rename(target)
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('admission/portable/proof-run.json.gz',dict(controls=controls,cold_red=cold_red,
        reconstructed=recovered,git_logical_identity=git,use=use,inputs_unchanged=stable,
        helper=c.read(c.PREFIX+'large_inputs.py'),producer=c.read(c.PREFIX+'admission/portable/proof.py'),
        backup_residue=backup.exists(),scope='Actual missing/byte/colluding-order/logical-mode/logical-byte '
            'faults restore. Original aliases are absent before fresh chunk-only recovery; exact SHA256, '
            'full modes and historical Git blob identities match. Actual maintained readers consume '
            'the recovered files before exactly three verified old backups are removed. No other data deleted.'))
    assert stable and use is not None and len(controls)==5
    print('Portable proof PASS:37 chunks/3 exact cold aliases;5 actual faults;historical readers use recovered bytes;zero backup residue')


if __name__=='__main__':main()
