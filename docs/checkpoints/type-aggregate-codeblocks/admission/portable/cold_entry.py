"""Exercise a fresh gateway process with all three logical aliases absent."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import context
import large_inputs


def main():
    args=sys.argv[1:];normal=bool(args and args[0]=='--normal')
    if normal:args=args[1:]
    assert len(args)<=1 and (not args or args[0].isdigit())
    ordinal=int(args[0]) if args else 1;assert 1<=ordinal<=99
    stem='cold-entry'+str(ordinal)
    if normal:
        folder=ROOT/('.linkedspec-data/verification/type-aggregate-cold-normal'+str(ordinal));folder.mkdir()
        def save(name,value):
            raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
            with (folder/(name+'.json.gz')).open('xb') as output:output.write(gzip.compress(raw,mtime=0))
    else:
        def save(name,value):c.write_new('admission/portable/'+stem+'-'+name+'.json.gz',value)
    manifest=large_inputs.manifest()
    extras=[path.relative_to(ROOT).as_posix() for path in (ROOT/c.PREFIX).rglob('*')
        if path.is_file() and not path.is_symlink()]
    snapshot=context.snapshot(extras)
    assert not any(path.endswith(('.gz','.part')) for path in snapshot['overrides'])
    snapshot['producer']=c.read(c.PREFIX+'admission/portable/cold_entry.py')
    save('inputs',snapshot)
    backup=ROOT/('.linkedspec-data/verification/type-aggregate-'+('normal-' if normal else '')+stem+'-old')
    backup.mkdir();moved=[];complete=False
    try:
        for index,item in enumerate(manifest['objects']):
            original=ROOT/item['path'];saved=backup/str(index)
            assert large_inputs.identity(original)=={key:item[key] for key in ('sha256','size','mode')}
            original.rename(saved);moved.append((item,saved))
        assert all(not (ROOT/item['path']).exists() for item in manifest['objects'])
        command=['bash','tools/run_python_project_data.sh',c.PREFIX+'publish_portable.py']
        if not normal:command.append('--check')
        run=c.run(command)
        save('run',dict(run=run,aliases_absent_at_process_start=True,
            producer=c.read(c.PREFIX+'admission/portable/cold_entry.py')))
        assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
        for item,saved in moved:
            expected={key:item[key] for key in ('sha256','size','mode')}
            assert large_inputs.identity(ROOT/item['path'])==large_inputs.identity(saved)==expected
        stable=c.unchanged(snapshot['inputs']);assert stable
        for item,saved in moved:saved.unlink()
        assert not list(backup.iterdir());backup.rmdir()
        save('cleanup',dict(verified_files=3,verified_bytes=1171950805,full_modes=True,
            actual_gateway_exit=0,backup_residue=False,inputs_unchanged=stable,
            producer=c.read(c.PREFIX+'admission/portable/cold_entry.py')))
        complete=True
    finally:
        if not complete:
            for index,(item,saved) in enumerate(moved):
                target=ROOT/item['path']
                if saved.exists():
                    if target.exists():
                        assert large_inputs.identity(target)=={key:item[key] for key in ('sha256','size','mode')}
                        target.rename(backup/(str(index)+'.generated'))
                    saved.rename(target)
    print('Cold gateway PASS:',('normal' if normal else 'check'),'fresh process;3 exact aliases;verified use/deletion;residue0')


if __name__=='__main__':main()
