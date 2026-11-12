"""Recover the original failed landing and the separate exact bounded-view repair."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()


def recover(archive, identities):
    rows = json.loads(identities.read_bytes()); result = {}
    with tarfile.open(archive) as packed:
        assert len(packed.getnames()) == len(rows)
        for member in packed:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts and member.name not in result
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    assert result.keys() == rows.keys()
    return result


def entries(body):
    recent = body.split(b'## Recent Completions\n\n', 1)[1].split(b'## History', 1)[0]
    return [line for line in recent.splitlines(keepends=True) if line.startswith(b'- ')]


def validate(before, after, rotated, failure):
    assert len(entries(before)) == 17 and len(entries(after)) == 16, 'bounded recent rows'
    assert rotated == entries(before)[-1] and before.replace(rotated, b'', 1) == after, 'exact oldest-row rotation'
    assert failure.count(b'  PASS  ') == 8 and failure.count(b'  FAIL  ') == 2, 'original doctrine counts'
    assert b'live_status current view has more than sixteen recent rows' in failure, 'original failure mechanism'


out = BASE / 'landing-pressure'
inputs = recover(out / 'inputs-before-use.tar.gz', out / 'input-identities.json')
raw = lambda name: gzip.decompress((out / name).read_bytes())
before, after, rotated, failure = (raw(name) for name in ('before-live.md.gz', 'after-live.md.gz', 'rotated-row.md.gz', 'first-failed-commit-combined.log.gz'))
validate(before, after, rotated, failure)
assert inputs['LIVE_ACHIEVEMENT_STATUS.md'] == before
assert inputs['.linkedspec-data/array-concat-open-arity-dart-commit.log'] == failure
assert inputs[REL + '/qualify_live_status.py'] == (BASE / 'qualify_live_status.py').read_bytes()
assert (ROOT / 'LIVE_ACHIEVEMENT_STATUS.md').read_bytes() == after
old_head = subprocess.check_output(['git', 'show', '1753884257bed7ce0b842bc406c665671403a828:LIVE_ACHIEVEMENT_STATUS.md'], cwd=ROOT)
assert raw('accepted-HEAD-live.md.gz') == old_head and rotated in old_head
original_publication = recover(BASE / 'publication/outputs-after-use.tar.gz', BASE / 'publication/outputs-after-use.json')
assert original_publication['LIVE_ACHIEVEMENT_STATUS.md'] == before, 'original publisher output unchanged'
supplement = BASE / 'landing-supplement'
left, right = [recover(supplement / (tag + '.tar.gz'), supplement / (tag + '.json')) for tag in ('before', 'after')]
name = REL + '/complete_landing_qualification.py'
assert left[name] == right[name] == (BASE / 'complete_landing_qualification.py').read_bytes()
assert b'(in_progress)' in left['MEMORY.md'] and b'(completed)' in right['MEMORY.md']
assert b'1,500,000,000' in right['docs/knowledge/github-size-safe-publication.md']
assert b'initial delta-base' in right[REL + '/REVIEW.md']
assert b'17-row live-status overflow' in right[REL + '/REVIEW.md']
for name in ('docs/knowledge/github-size-safe-publication.md', 'MEMORY.md', 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'):
    assert (ROOT / name).read_bytes() == right[name], 'qualified document freshness'
controls = []
for label, arguments, reason in (
    ('old overflow remains RED', (before, before, rotated, failure), 'bounded recent rows'),
    ('wrong rotated entry', (before, after, entries(before)[0], failure), 'exact oldest-row rotation'),
    ('fabricated original success', (before, after, rotated, failure.replace(b'  FAIL  ', b'  PASS  ')), 'original doctrine counts'),
):
    try:
        validate(*arguments)
    except AssertionError as error:
        assert reason in str(error)
        controls.append(label)
    else:
        raise AssertionError('ineffective landing control:' + label)
print(json.dumps(dict(landing_recovery='PASS', original_normal_exit=1, original_passes=8,
    original_failures=2, current_recent_rows=16, corruption_controls=controls,
    scope='Original combined channels/full modes and exact row rotation; immutable runtime/publisher proof retained. No SDK or repair replay.'), indent=2))
