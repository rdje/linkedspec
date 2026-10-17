"""Read-only, non-following artifact census; this instrument never deletes files."""
import argparse, datetime, hashlib, json, os, subprocess
from pathlib import Path

EXCLUDED = {'.git','.agents','.claude','.codex','.aws','.linkedspec-data/cache',
            '.linkedspec-data/scratch/runs','.linkedspec-data/scratch/hygiene7',
            '.linkedspec-data/scratch/hygiene8','.linkedspec-data/scratch/hygiene9','.linkedspec-data/scratch/hygiene10','.linkedspec-data/scratch/hygiene11','.linkedspec-data/scratch/hygiene13','.linkedspec-data/scratch/hygiene14','.linkedspec-data/scratch/hygiene18',
            'dart/.dart_tool','docs/linkedspec-book/book','rust/target'}
EXCLUDED.update('.linkedspec-data/scratch/hygiene' + str(n) for n in range(1, 19))
SUFFIXES = ('.log','.bin','.DS_Store')

def scan(root, start, excluded, submodules):
    assert not root.is_symlink(), 'root symlink'
    root=root.resolve(); start=start.absolute()
    assert start.is_relative_to(root), 'outside root'
    rows=[];nested=[];symlinks=[];other_volumes=[]
    # Validate the supplied start and every ancestor before os.walk can open it.
    current=root
    for component in start.relative_to(root).parts:
        current=current/component; relative=current.relative_to(root).as_posix()
        if relative in excluded or relative in submodules:return rows,nested,symlinks,other_volumes
        if current.is_symlink():return rows,nested,[relative],other_volumes
        if not current.exists():return rows,nested,symlinks,other_volumes
        if current.stat().st_dev != root.stat().st_dev:return rows,nested,symlinks,[relative]
        if (current/'.git').exists():return rows,[relative],symlinks,other_volumes
    if not start.is_dir():return rows,nested,symlinks,other_volumes
    for folder,dirs,files in os.walk(start,followlinks=False):
        current=Path(folder)
        keep=[]
        for name in sorted(dirs):
            p=current/name;relative=p.relative_to(root).as_posix()
            if relative in excluded or relative in submodules:continue
            if p.is_symlink():symlinks.append(relative);continue
            if p.stat().st_dev != root.stat().st_dev:other_volumes.append(relative);continue
            if (p/'.git').exists():nested.append(relative);continue
            keep.append(name)
        dirs[:]=keep
        for name in sorted(files):
            suffix=next((s for s in SUFFIXES if name.endswith(s)),None)
            if suffix is None:continue
            p=current/name;relative=p.relative_to(root).as_posix()
            if p.is_symlink():symlinks.append(relative);continue
            stat=p.stat()
            if stat.st_dev != root.stat().st_dev:other_volumes.append(relative);continue
            rows.append({'path':relative,'suffix':suffix,'bytes':stat.st_size})
    return sorted(rows,key=lambda r:r['path']),sorted(nested),sorted(symlinks),sorted(other_volumes)

def census(root):
    stages=subprocess.check_output(['git','ls-files','--stage','-z'],cwd=root).decode().split('\0')
    submodules={r.split('\t',1)[1] for r in stages if r.startswith('160000 ')}
    rows,nested,symlinks,other=scan(root,root,EXCLUDED,submodules)
    rust={}
    for name in ['rust/target/release','rust/target/debug/incremental','rust/target/debug/deps']:
        extra,ignored,links,volumes=scan(root,root/name,set(),submodules)
        rust[name]={'exists':(root/name).is_dir(),'files':len(extra),'bytes':sum(r['bytes'] for r in extra),'rows':extra,'nested_repositories_excluded':ignored,'symlinks_excluded':links,'other_volumes_excluded':volumes}
    return {'rows':rows,'artifact_files':len(rows),'artifact_bytes':sum(r['bytes'] for r in rows),
            'by_suffix':{s:{'files':sum(r['suffix']==s for r in rows),'bytes':sum(r['bytes'] for r in rows if r['suffix']==s)} for s in SUFFIXES},
            'excluded_paths':sorted(EXCLUDED|submodules),'nested_repositories_excluded':nested,'symlinks_excluded':symlinks,'other_volumes_excluded':other,'rust_log_bin':rust}

if __name__=='__main__':
    root=Path(__file__).resolve().parents[2]
    result=census(root)
    result.update(owner='REPO-HYGIENE.18',at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  activation_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
                  scope='dated metadata census; retained caches/runs/book/Dart outputs excluded; three explicit Rust log/bin locations inspected separately',
                  removed_files=0,removed_bytes=0,
                  disposition='Retention only: no exact deletion target proved disposable; verification inputs/logs and reusable outputs retained. No liveness/recovery/purge operation.')
    print(json.dumps(result,indent=2,sort_keys=True))
