"""Preserve the complete second staged source image without duplicating immutable archives."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[2] / 'type-numeric-codeblocks'))
import common as c
PREFIX = 'docs/checkpoints/type-numeric-admission/recurrence/'
MUTABLE = (
    'tests/language-readiness/verify_objectives.py',
    'tools/check_executable_aggregate_selector_sources.py',
    'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md',
    'KNOWLEDGE_MAP.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json',
    'docs/checkpoints/type-numeric-codeblocks/README.md',
    'docs/checkpoints/type-numeric-admission/README.md',
    'docs/language-readiness/objective-reconciliation.md',
    'docs/checkpoints/type-numeric-codeblocks/publish_final.py',
    'docs/checkpoints/type-numeric-codeblocks/review_final.py',
)


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'],cwd=c.ROOT).decode().strip() == c.BASE
    manifest = c.load('publication-final-inputs.json')
    assert len(manifest['inputs']) == 10162 and c.unchanged(manifest['inputs'])
    baseline = {name: c.read('.linkedspec-data/verification/type-numeric-canonical2-readonly.' + name)
                for name in ('log','status')}
    assert c.decode(baseline['status']['base64']).strip() == b'0'
    assert b'10162 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(baseline['log']['base64'])
    index = subprocess.check_output(['git','ls-files','--stage','-z'],cwd=c.ROOT)
    images, excluded, paths = {}, [], []
    for row in index.split(b'\0'):
        if not row:
            continue
        metadata,name = row.split(b'\t',1)
        mode,oid,stage = metadata.decode().split()
        assert stage == '0'
        path=name.decode()
        if mode not in ('100644','100755'):
            excluded.append(dict(path=path,git_mode=mode,oid=oid,
                scope='Index metadata only; no Gitlink/symlink implementation or target read.'))
            continue
        assert '\n' not in path
        paths.append(path)
        images[path]=dict(**c.identity(path),git_mode=mode,oid=oid)
    verification=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(paths)+'\n').encode())
    assert verification['returncode']==0 and not c.decode(verification['stderr_base64'])
    actual=c.decode(verification['stdout_base64']).decode().splitlines()
    assert actual==[images[path]['oid'] for path in paths]
    assert c.unchanged(manifest['inputs'])
    assert all(c.identity(path)=={key:item[key] for key in ('sha256','mode')} for path,item in images.items())
    value=dict(base=c.BASE,producer=c.read(PREFIX+'preserve2.py'),primitives=c.read(c.PREFIX+'common.py'),
        original={name:c.read(c.PREFIX+name) for name in ('publication-final-inputs.json','publication-final.json')},
        claim=c.read('docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json'),inputs=manifest['inputs'],
        before={path:c.read(path) for path in MUTABLE},baseline=baseline,index_base64=c.encode(index),
        images=images,excluded=excluded,git_hash_verification=verification,
        canonical={name:c.read('.linkedspec-data/verification/type-numeric-canonical2.'+name) for name in ('log','status')},
        scope='Whole second uncommitted claim/publication/10162-input manifest and actual default readonly0. '
              'The complete actual staged source image is every regular index path, SHA256/full filesystem mode '
              'and independently checked Git blob identity, plus exact index metadata for excluded Gitlinks/symlinks. '
              'Unchanged source/artifact bytes stay at their immutable tracked primary paths; every planned changed '
              'input has a full before packet. Recovery verifies those primary bytes or the explicit before packet. '
              'This stores source images rather than another duplicate binary-patch stream. No accepted draft Git '
              'revision is invented; real base203cde315 and the actual staged index are distinct authorities.')
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (c.ROOT/(PREFIX+'canonical2.json.gz')).open('xb') as out:
        out.write(gzip.compress(raw,mtime=0))
    print('Second whole draft preserved:10162 inputs; readonly0;',len(images),'Git-verified staged source images; explicit full before packets')


if __name__=='__main__':
    main()
