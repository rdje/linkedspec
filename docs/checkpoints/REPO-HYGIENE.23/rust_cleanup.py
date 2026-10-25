"""Reversible old-target quarantine, fresh public build/use, then native cleanup."""
import gzip
import json
import os
from pathlib import Path
import stat
import subprocess
import common as c

TARGET='rust/target'
WORK='.linkedspec-data/verification/hygiene23'
OLD=WORK+'/old-rust-target'
PRIMARY=TARGET+'/debug/linkedspec-rust'
EXAMPLES={
    'examples/negative-array-current-perl.spec':[30,[10,20,30]],
    'examples/negative-array-current-callable-perl.spec':[30,[10,20,30]],
    'examples/negative-array-write-perl.spec':[30,[10,99,30]],
    'examples/negative-array-write-callable-perl.spec':{'rows':[[1],[99,3]]},
}


def same(actual,expected):
    if type(actual) is not type(expected):return False
    if isinstance(expected,dict):return actual.keys()==expected.keys() and all(same(actual[key],value) for key,value in expected.items())
    if isinstance(expected,list):return len(actual)==len(expected) and all(map(same,actual,expected))
    return actual==expected


def generated_root(name):
    path=c.ROOT/name
    assert path.is_relative_to(c.ROOT) and path!=c.ROOT
    for parent in [path,*path.parents]:
        if not parent.is_relative_to(c.ROOT):continue
        assert not parent.is_symlink(),'symbolic target ancestor'
        if parent!=c.ROOT:assert not os.path.lexists(parent/'.git'),'nested Git target ancestor'
    assert path.stat().st_dev==c.ROOT.stat().st_dev and stat.S_ISDIR(path.lstat().st_mode)
    return path


def allocated(name):
    run=c.run(['du','-skx',name])
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    return dict(bytes=int(c.decode(run['stdout_base64']).split()[0])*1024,run=run)


def archive_primary():
    path=c.source(PRIMARY);raw=path.read_bytes();packed=gzip.compress(raw,mtime=0)
    limit=32*1024*1024-1024;parts=[]
    for offset in range(0,len(packed),limit):
        name='rust-primary-'+str(len(parts)+1).zfill(3)+'.part'
        block=packed[offset:offset+limit]
        with (c.ROOT/c.PREFIX/name).open('xb') as output:output.write(block)
        parts.append(dict(path=c.PREFIX+name,bytes=len(block),**c.identity(c.PREFIX+name)))
    restored=gzip.decompress(b''.join(c.source(row['path']).read_bytes() for row in parts))
    assert restored==raw
    record=dict(path=PRIMARY,bytes=len(raw),sha256=c.sha(raw),mode=path.stat().st_mode & 0o7777,parts=parts)
    c.save('rust-primary-binary.json',record)
    return record


def main():
    prior=c.load('inventory-before.json.gz')
    assert prior['inputs_unchanged']
    assert not [row for row in prior['observation']['skipped'] if row['path']==TARGET or row['path'].startswith(TARGET+'/')]
    paths=subprocess.check_output(['git','ls-files','--stage','-z','rust','specs'],cwd=c.ROOT).split(b'\0')
    names=[]
    for row in paths:
        if not row:continue
        metadata,name=row.split(b'\t',1)
        if metadata.split()[0] in (b'100644',b'100755'):names.append(name.decode())
    assert not any(name==TARGET or name.startswith(TARGET+'/') for name in names)
    supplied=c.snapshot(names+list(EXAMPLES)+['tools/run_cargo_local.sh','tools/project_data_env.sh',
        'tools/project_data_run.sh','.gitmodules','rgx/docs/INTEGRATION.md'])
    c.save('rust-before-inputs.json.gz',dict(context=supplied,
        scope='Complete regular first-party Rust/spec sources, exact example inputs, wrappers, '
            'lockfile and published RGX integration contract before build. Installed Rust/OS, '
            'locked repository-local Cargo packages and already-prepared published RGX dependency '
            'outputs are retained read-only prerequisites. No dependency implementation census '
            'or bootstrap runs; every other Git repository and pin remains unchanged.'))
    target=generated_root(TARGET)
    assert not (c.ROOT/OLD).exists()
    (c.ROOT/WORK).mkdir(exist_ok=True)
    ignored=c.run(['git','check-ignore','-v','--',TARGET])
    tracked=c.run(['git','ls-files','--',TARGET])
    assert ignored['returncode']==tracked['returncode']==0 and not c.decode(tracked['stdout_base64'])
    before=allocated(TARGET)
    assert before['bytes']==prior['observation']['buckets'][TARGET]['allocated_bytes'],'fresh native target allocation'
    # A nonzero lsof result is absence only for this exact empty, diagnostic-free result.
    opened=c.run(['lsof','-nP','+D',TARGET,'-Fpcftn'])
    c.save('rust-quiescence.json.gz',dict(open_files=opened,ignored=ignored,tracked=tracked,
        before=before,host_reference=c.PREFIX+'host-before.json.gz',
        scope='Candidate-specific permitted open-file query, prior non-following topology and '
            'fresh native allocation/ownership. Unknown/denied inspection cannot authorize the rename.'))
    assert opened['returncode']==1 and not c.decode(opened['stdout_base64']) and not c.decode(opened['stderr_base64']), 'target still open or inspection unavailable'
    before_inode=(target.stat().st_dev,target.stat().st_ino)
    lease=c.ROOT/WORK/'rust-lease.json'
    assert not lease.exists()
    state=dict(owner=c.OWNER,source=TARGET,quarantine=OLD,old_device=before_inode[0],
        old_inode=before_inode[1],pid=os.getpid(),process_group=os.getpgrp(),state='before_rename',closed=False)
    def journal():lease.write_text(json.dumps(state,sort_keys=True)+'\n')
    journal()
    c.save('rust-cleanup-plan.json.gz',dict(lease=state.copy(),before=before,
        producer=c.read(c.PREFIX+'rust_cleanup.py'),
        policy='Rename old same-volume generated target reversibly. Delete it only after an '
            'offline locked primary build and all four exact public examples succeed in the '
            'new target and actual fresh executable bytes are retained. Native cargo clean '
            'receives only the exact old quarantine target; package/dependency stores stay.'))
    target.rename(c.ROOT/OLD)
    assert (c.ROOT/OLD).stat().st_dev==before_inode[0] and (c.ROOT/OLD).stat().st_ino==before_inode[1]
    state.update(state='old_target_quarantined');journal()
    try:
        build=c.run(['bash','tools/run_cargo_local.sh','build','--manifest-path','rust/Cargo.toml',
            '--locked','--offline','--target-dir',TARGET,'-p','linkedspec-runtime','--bin','linkedspec-rust'])
        c.save('rust-fresh-build.json.gz',build)
        assert build['returncode']==0,'fresh public build failed; preserve both targets'
        binary=archive_primary()
        runs=[]
        for path,expected in EXAMPLES.items():
            run=c.run([PRIMARY,'--spec-file',path,'--input','x'])
            runs.append(dict(path=path,expected=expected,run=run))
        stable=c.unchanged(supplied['inputs']) and c.identity(PRIMARY)=={
            key:binary[key] for key in ('sha256','mode')}
        c.save('rust-fresh-use.json.gz',dict(runs=runs,inputs_and_binary_unchanged=stable))
        assert stable
        for row in runs:
            run=row['run'];assert run['returncode']==0 and not c.decode(run['stderr_base64'])
            assert same(json.loads(c.decode(run['stdout_base64'])),row['expected'])
        state.update(state='fresh_target_and_public_examples_verified');journal()
        help_run=c.run(['bash','tools/run_cargo_local.sh','clean','--help'])
        c.save('rust-clean-help.json.gz',help_run)
        assert help_run['returncode']==0 and b'--target-dir' in c.decode(help_run['stdout_base64'])
        generated_root(OLD)
        old_open=c.run(['lsof','-nP','+D',OLD,'-Fpcftn'])
        c.save('rust-quarantine-recheck.json.gz',old_open)
        assert old_open['returncode']==1 and not c.decode(old_open['stdout_base64']) and not c.decode(old_open['stderr_base64'])
        cleanup=c.run(['bash','tools/run_cargo_local.sh','clean','--manifest-path','rust/Cargo.toml',
            '--target-dir',OLD])
        c.save('rust-native-clean.json.gz',cleanup)
        assert cleanup['returncode']==0
        if (c.ROOT/OLD).exists():
            assert not list((c.ROOT/OLD).iterdir());(c.ROOT/OLD).rmdir()
        assert not (c.ROOT/OLD).exists()
        assert c.identity(PRIMARY)=={key:binary[key] for key in ('sha256','mode')}
        after=allocated(TARGET)
        c.save('rust-cleanup-result.json.gz',dict(before=before,after=after,
            allocated_bytes_reclaimed=before['bytes']-after['bytes'],quarantine_absent=True,
            fresh_examples=len(runs),inputs_unchanged=c.unchanged(supplied['inputs']),
            scope='Dated allocated target-tree reduction after fresh locked/offline primary '
                'build/use, not a whole-environment cold bootstrap. Global volume free-space '
                'movement is reported separately and may include other host activity.'))
        state.update(state='native_cleanup_complete',closed=True);journal()
        print('Rust target allocated bytes:',before['bytes'],'->',after['bytes'],flush=True)
    except BaseException:
        # Before native cleanup the complete old cache remains available for exact rollback.
        if (c.ROOT/OLD).exists() and state['state']!='fresh_target_and_public_examples_verified':
            if (c.ROOT/TARGET).exists():
                failed=c.ROOT/WORK/'failed-fresh-rust-target';assert not failed.exists()
                (c.ROOT/TARGET).rename(failed)
            (c.ROOT/OLD).rename(c.ROOT/TARGET)
            state.update(state='old_target_restored_after_failure',closed=True);journal()
        raise


if __name__=='__main__':main()
