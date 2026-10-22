"""Read-only accepted10 custody before the due maintenance leaf's tracked writes."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-array-count-first'))
import common as c
import publish

BASE = '79c68715c04f06379bb18673b09d44dd90611439'
OWNER = 'REPO-HYGIENE.20'
PLANNED = ['MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/REPO-HYGIENE.md', 'docs/ARTIFACT_CLEANUP.md',
 'docs/knowledge/terse-type-method-surface-inventory.md', 'KNOWLEDGE_MAP.md',
 'docs/linkedspec-book/src/development/documentation-workflow.md',
 'docs/checkpoints/type-array-count-first/README.md', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json']


def save(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    with (ROOT / '.linkedspec-data/verification' / name).open('xb') as output:
        output.write(gzip.compress(raw, mtime=0))


def main():
    actor = Path(__file__).resolve().relative_to(ROOT).as_posix()
    producer = c.read(actor)
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip()
    status = c.run(['git', 'status', '--porcelain'])
    assert head == BASE and status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    baseline = c.run(['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'])
    save('hygiene20-baseline.json.gz', dict(base=BASE, owner=OWNER, producer=producer,
        status=status, baseline=baseline))
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64'])
    inputs = {path:c.identity(path) for path in publish.input_paths()}
    publish.validate_inputs(c.load(publish.MANIFEST_NAME)['inputs'], inputs)
    entries = {}
    for row in subprocess.check_output(['git', 'ls-tree', '-rz', BASE], cwd=ROOT).split(b'\0'):
        if row:
            metadata, name = row.split(b'\t', 1)
            mode, kind, oid = metadata.decode().split()
            entries[name.decode()] = dict(mode=mode, kind=kind, oid=oid)
    images, excluded = {}, []
    for path, entry in entries.items():
        if entry['mode'] not in ('100644', '100755'):
            excluded.append(dict(path=path, git=entry, reason='Uninspected Gitlink/symlink boundary'))
            continue
        images[path] = dict(**c.identity(path), git=entry)
    assert len(images) == len(inputs) + 3
    assert all({key:images[path][key] for key in ('sha256', 'mode')} == item for path,item in inputs.items())
    verified = c.run(['git', 'hash-object', '--stdin-paths'],
        input=('\n'.join(sorted(images))+'\n').encode())
    assert verified['returncode'] == 0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines() == [images[path]['git']['oid'] for path in sorted(images)]
    logical = c.load('prior.json.gz')['logical_inputs']
    assert all(c.identity(path) == {key:item[key] for key in ('sha256', 'mode')}
        and c.source(path).stat().st_size == item['size'] for path,item in logical.items())
    live, direct = {}, {}
    for file in sorted((ROOT / 'docs/claims').glob('*.json')):
        record = json.loads(file.read_bytes())
        matches = []
        for index, claim in enumerate(record.get('claims', [])):
            durability = claim.get('durability', {})
            if durability.get('mode', 'live') == 'live' and durability.get('status') == 'checked':
                paths = {item['path'] for item in durability.get('inputs', [])}
                matches.append(dict(index=index, name=claim.get('name'),
                    direct_planned_intersection=sorted(paths & set(PLANNED))))
        if matches:
            path = file.relative_to(ROOT).as_posix()
            live[path] = dict(packet=c.read(path), claims=matches)
            if any(row['direct_planned_intersection'] for row in matches):
                direct[path] = matches
    assert c.run(['git', 'status', '--porcelain']) == status
    assert inputs == {path:c.identity(path) for path in publish.input_paths()}
    save('hygiene20-prior10.json.gz', dict(owner=OWNER, base=BASE, producer=producer,
        baseline=baseline, status=status, inputs=inputs, images=images, excluded=excluded,
        logical_inputs=logical, git_verification=verified,
        claim=c.read(publish.CLAIM), publication=c.read(publish.PUBLICATION),
        manifest=c.read(publish.MANIFEST), gateway=c.read(c.PREFIX+'publish.py'),
        live_claims=live, direct_intersections=direct,
        planned_before={path:c.read(path) for path in PLANNED},
        scope='Whole accepted10 publication4 and actual clean readonly0 precede every maintenance tracked write. All physical bytes/full modes independently match real committed Git; three older logical aliases stay available through their existing tracked chunks. The complete checked-live declaration census records direct shared-surface intersections; accepted10 also binds the complete physical input manifest. Gitlinks/other repositories remain uninspected read-only black boxes. No recursive copying of immutable gzip/chunk payloads.'))
    print('Accepted10 preserved:', len(inputs), 'physical inputs /', len(images),
        'Git-verified full-mode images; clean readonly0; live declaration census retained')
    print('Direct shared-surface intersections:', ', '.join(direct) or 'none')


if __name__ == '__main__':
    main()
