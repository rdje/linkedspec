"""Allocated metadata census, excluding Git boundaries before traversal."""
import datetime
import json
import os
from pathlib import Path
import stat
import subprocess
import common as c

EXCLUDED={'.git','docs/checkpoints/REPO-HYGIENE.23',
    '.linkedspec-data/verification/hygiene23'}


def gitlinks():
    return {row.split(b'\t',1)[1].decode() for row in subprocess.check_output(
        ['git','ls-files','--stage','-z'],cwd=c.ROOT).split(b'\0') if row.startswith(b'160000 ')}


def scan(root,start,protected,*,retain_rows=False,excluded=EXCLUDED):
    root=Path(root);start=Path(start)
    assert start.is_relative_to(root),'outside root'
    device=root.stat().st_dev
    for parent in reversed([start,*start.parents]):
        if not parent.is_relative_to(root):continue
        assert not parent.is_symlink(),'symbolic ancestor'
        if parent!=root:
            assert parent.relative_to(root).as_posix() not in protected,'protected ancestor'
            assert not os.path.lexists(parent/'.git'),'nested repository ancestor'
    pending=[start];seen=set();rows=[];skipped=[];buckets={}
    total=dict(entries=0,regular_files=0,logical_bytes=0,allocated_bytes=0)
    while pending:
        path=pending.pop();relative=path.relative_to(root).as_posix()
        if relative in excluded or relative in protected:
            skipped.append(dict(path=relative,reason='protected_or_excluded'));continue
        info=path.lstat()
        if info.st_dev!=device:
            skipped.append(dict(path=relative,reason='other_volume'));continue
        directory=stat.S_ISDIR(info.st_mode)
        if directory and path!=root and os.path.lexists(path/'.git'):
            skipped.append(dict(path=relative,reason='nested_repository'));continue
        key=(info.st_dev,info.st_ino)
        charged=key not in seen;seen.add(key)
        allocated=info.st_blocks*512 if charged else 0
        regular=stat.S_ISREG(info.st_mode)
        record=dict(path=relative,kind='directory' if directory else 'file' if regular else 'symlink' if stat.S_ISLNK(info.st_mode) else 'special',
            mode=info.st_mode & 0o7777,logical_bytes=info.st_size,allocated_bytes=allocated,
            device=info.st_dev,inode=info.st_ino,links=info.st_nlink,mtime_ns=info.st_mtime_ns)
        if retain_rows:rows.append(record)
        parts=Path(relative).parts
        depth=3 if parts[:2]==('.linkedspec-data','scratch') else 2 if parts and parts[0] in ('.linkedspec-data','rust') else 1
        bucket='/'.join(parts[:depth])
        totals=buckets.setdefault(bucket,dict(entries=0,regular_files=0,logical_bytes=0,allocated_bytes=0))
        for sums in (total,totals):
            sums['entries']+=1;sums['regular_files']+=int(regular)
            sums['logical_bytes']+=info.st_size if regular and charged else 0
            sums['allocated_bytes']+=allocated
        if directory:
            with os.scandir(path) as stream:
                pending.extend(Path(item.path) for item in sorted(stream,key=lambda item:item.name,reverse=True))
        elif not regular:
            skipped.append(dict(path=relative,reason='unfollowed_'+record['kind']))
    return dict(total=total,buckets=buckets,skipped=sorted(skipped,key=lambda row:row['path']),rows=rows)


def main():
    supplied=c.snapshot(['.gitmodules','.gitignore','rust/.gitignore','rust/Cargo.toml','rust/Cargo.lock',
        'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_cargo_local.sh',
        'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
        'docs/knowledge/project-data-liveness-permission-denial.md'])
    c.save('inventory-before-inputs.json.gz',supplied)
    protected=gitlinks()
    at=datetime.datetime.now(datetime.timezone.utc).isoformat()
    result=scan(c.ROOT,c.ROOT,protected)
    c.save('inventory-before.json.gz',dict(owner=c.OWNER,at_utc=at,protected_gitlinks=sorted(protected),
        observation=result,inputs_unchanged=c.unchanged(supplied['inputs']),
        scope='Dated parent-owned working-tree allocated metadata, with hardlink inode deduplication. '
            'Root Git metadata, every submodule/nested repository, active evidence prefix and '
            'active measurement scratch are excluded before traversal. Symlinks are charged only '
            'for their own inode and never followed; other devices are excluded. This is not '
            'disposal authority, liveness proof, an atomic filesystem snapshot or a full total '
            'including protected repositories/Git metadata. No artifact is removed.'))
    print(json.dumps(dict(at_utc=at,total=result['total'],largest=sorted(result['buckets'].items(),
        key=lambda item:item[1]['allocated_bytes'],reverse=True)[:28],
        skipped_boundaries=len(result['skipped'])),sort_keys=True),flush=True)


if __name__=='__main__':main()
