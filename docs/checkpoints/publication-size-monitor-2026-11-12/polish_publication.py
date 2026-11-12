"""Copyedit the new public monitor prose while retaining exact before/after images."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OUT = BASE / 'polish'
OUT.mkdir()
names = ['docs/linkedspec-book/src/development/local-ci-and-regression.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md', 'docs/knowledge/github-size-safe-publication.md',
    str(Path(__file__).resolve().relative_to(ROOT))]


def freeze(tag):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as packed:
        for name in names:
            path = ROOT / name; body = path.read_bytes()
            rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=name, recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert set(packed.getnames()) == rows.keys()
        for member in packed:
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('before')
path = ROOT / names[0]; source = path.read_text()
start = source.index('### Outgoing publication byte budget\n'); end = source.index('### Task-evidence coverage\n', start)
old = source[start:end]
new = old.replace('The director1,500,000,000-byte early-push trigger', 'The director’s 1,500,000,000-byte early push trigger')
new = new.replace('with one pack worker and64m window memory.', 'with one pack worker and a `64m` window-memory limit.')
new = new.replace('around1,400,000,000', 'around 1,400,000,000').replace('this100MB', 'this 100 MB').replace('around1.5GB', 'around 1.5 GB').replace('is2GiB.', 'is 2 GiB.')
new = new.replace('Parent30/publication30.2 owns actual publication.', 'The publication task owns the required checks and transfer.')
assert 'measure.py' in new and all(token in new for token in ('1,500,000,000', '1,400,000,000', '2 GiB'))
assert old.split('```sh\n')[1].split('```')[0] == new.split('```sh\n')[1].split('```')[0]
path.write_text(source[:start] + new + source[end:])
path = ROOT / names[1]; source = path.read_text()
old = 'Bounded monitor23.4.30.1 now records HEAD102ec3446/cached origin4683555e at1,257,281,519 bytes,242,718,481 below trigger; actual native index/qualified verify and12 corruption controls pass, with original filename failure retained. Full native/raw/toolchain durability remains4.2/SESSION5. Remeasure after the monitor commit, then independent Julia/Lua while margin permits; canonical publication preempts cadence near the budget.'
new = 'The outgoing pack monitor (23.4.30.1) measures committed HEAD `102ec3446` against cached `origin/main` at `4683555e`: 1,257,281,519 bytes, leaving 242,718,481 bytes below the early push trigger. Its native index and qualified verification pass 12 corruption controls; the original filename failure is retained. Native/raw/toolchain custody remains open (4.2/SESSION5). Remeasure after the monitor commit, then continue Julia/Lua while margin permits; canonical publication takes priority as the budget approaches.'
assert source.count(old) == 1
path.write_text(source.replace(old, new, 1))
path = ROOT / names[2]; source = path.read_text()
start = source.index('The bounded reusable monitor30.1 is now retained'); end = source.index('The November4 workflow below', start)
new = '''The bounded reusable monitor (30.1) is retained at
docs/checkpoints/publication-size-monitor-2026-11-12/measure.py. Run it after every
committed leaf and before large growth. It prints actual refs, packed bytes, the
trigger margin and the advisory 1.4 GB preparation state. At committed HEAD
`102ec3446` and cached base `4683555e`, 102 commits estimate 1,257,281,519 bytes,
leaving 242,718,481 bytes before the 1.5 GB trigger. Explicit no-sparse output
contains exactly 45,549 required objects. The original validator exits 1 because
its index and pack stems differ. Qualified verification reuses the successful
native index with a matching stem and passes 12 controls. Git pairs an index with
its corresponding pack: https://git-scm.com/docs/git-verify-pack.
Historical reverify: bash tools/project_data_run.sh env PYTHONPATH= python3 -P
docs/checkpoints/publication-size-monitor-2026-11-12/review.py. Current identity
is separate. Native/physical/raw-artifact durability remains a disclosed gap owned
by 23.4.2/SESSION5; remote freshness and wire size remain unassessed. Source and
proof: docs/checkpoints/publication-size-monitor-2026-11-12/REVIEW.md.

'''
path.write_text(source[:start] + new + source[end:])
freeze('after')
print('Copyedited only the new monitor prose; exact command, budgets and evidence remain')
