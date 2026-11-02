"""Retain and remove only this restoration's redundant regular scratch logs."""
import argparse
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import os
import stat
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/document-pressure-restoration'
NAMES=('map-fixture.log','metadata-catalog.log','history-catalog.log')

def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def apply():
    target=ROOT/PREFIX/'cleanup-intake.json.gz'
    if target.exists():
        raise ValueError('cleanup already recorded; capture entrypoint is one-shot')
    retained=[]
    # A scoped metadata review confers no authority to purge compiler caches.
    for directory in ('rust/target/release','rust/target/debug/incremental','rust/target/debug/deps'):
        start=ROOT/directory
        if start.is_symlink():
            raise ValueError('symbolic artifact root')
        for current,dirs,files in os.walk(start,followlinks=False):
            dirs[:]=sorted(d for d in dirs if not (Path(current)/d).is_symlink())
            if '.git' in dirs:
                raise ValueError('nested repository in artifact scope')
            for name in sorted(files):
                if name.endswith(('.bin','.log')):
                    path=Path(current)/name;info=path.lstat()
                    retained.append(dict(path=path.relative_to(ROOT).as_posix(),bytes=info.st_size,
                                         mode=info.st_mode,reason='retained cache or unresolved evidence'))
    removed=[]
    for name in NAMES:
        path=ROOT/'.linkedspec-data/normal-hook-restoration'/name
        info=path.lstat();raw=path.read_bytes()
        assert stat.S_ISREG(info.st_mode) and info.st_nlink==1
        assert subprocess.run(['git','check-ignore','--quiet',str(path.relative_to(ROOT))],cwd=ROOT).returncode==0
        removed.append(dict(path=path.relative_to(ROOT).as_posix(),sha256=sha(raw),bytes=len(raw),
                            text=raw.decode(),device=info.st_dev,inode=info.st_ino))
    report=dict(date=datetime.now(timezone.utc).isoformat(),owner='TYPE-REFERENCE-BOOK.1.2.20.1.10',
                scope='Only named restoration scratch logs are eligible; Rust metadata candidates retained.',
                removed=removed,retained=retained)
    raw=json.dumps(report,sort_keys=True,separators=(',',':')).encode()
    target.write_bytes(gzip.compress(raw,mtime=0))
    assert gzip.decompress(target.read_bytes())==raw
    for row in removed:
        path=ROOT/row['path'];info=path.lstat()
        assert info.st_dev==row['device'] and info.st_ino==row['inode'] and sha(path.read_bytes())==row['sha256']
        path.unlink()
        assert not path.exists()
    (ROOT/'docs/ARTIFACT_CLEANUP.md').write_text('# Latest artifact cleanup\n\n- Date: '+report['date']+'\n- Summary: TYPE-REFERENCE-BOOK.1.2.20.1.10 retained and verified full bytes before removing three redundant restoration scratch logs; exact named residue absent. Scoped Rust .bin/.log candidates, caches, source, retained proof and other repositories preserved. Evidence: docs/checkpoints/document-pressure-restoration/cleanup-intake.json.gz.\n')
    print('cleanup: retained complete evidence, removed only named duplicate logs, exact residue absent')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply',action='store_true',required=True)
    parser.parse_args()
    apply()
