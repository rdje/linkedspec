"""Recover retained resource publication images without reading future prose."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.14'


def images(directory, name):
    rows = json.loads((BASE / directory / (name + '.json')).read_bytes())
    bodies = {}
    with tarfile.open(BASE / directory / (name + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys() and len(archive.getnames()) == len(rows)
        for member in archive:
            raw = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            bodies[member.name] = raw
    return bodies


def node_bounds(raw):
    marker = ('- ID: `' + OWNER + '`').encode()
    at = raw.index(marker)
    end = raw.find(b'\n- ID:', at + 1)
    return at, len(raw) if end < 0 else end


def validate(model):
    before, after = model['before'], model['after']
    book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
    assert after[book].startswith(before[book]), 'prior book bytes'
    extra = after[book][len(before[book]):]
    assert b'bash tools/host_ram_usage.sh' in extra and b'--danger-pct 88' in extra and b'keeps increasing' in extra, 'RAM command and trend recipe'
    for card in ('restricted-macos-ram-host-size-fallback.md', 'canonical-ci-ram-fallback-prerequisite.md'):
        name = 'docs/knowledge/' + card
        old_body = before[name].split(b'---\n', 2)[2]
        assert old_body in after[name] and b'Original diagnosis (historical)' in after[name], 'original diagnosis bytes'
    name = 'docs/knowledge/shared-host-ram-budget.md'
    assert all(value in after[name] for value in (b'exceeds90%', b'keeps increasing', b'Never stop another', b'not continuous trend monitoring')), 'current RAM policy'
    name = 'docs/claims/' + OWNER + '.json'
    claim = json.loads(after[name])
    pack_path = next(path for path in before if path.endswith('/push-monitor/20261112T194221.101324Z/result.json'))
    pack = json.loads(before[pack_path])
    first = claim['claims'][0]
    assert claim['owner'] == OWNER and str(pack['estimated_non_thin_pack_bytes']) in first['statement'], 'bound pack observation'
    assert first['falsify']['repair_owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.30' and first['durability']['repair_owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.2', 'published gaps'
    memory = after['MEMORY.md']
    assert b'activation_commit: `b370de8d31e3f38da6abf8ed4702a523aa3d6d97`' in memory and OWNER.encode() in memory, 'handoff ownership'
    assert b'current canonical discovery4.1' in memory and b'before-push raw-error4.28' in memory and b'exact staged canonical admission' in memory, 'handoff prerequisites'
    part = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
    old_start, old_end = node_bounds(before[part])
    new_start, new_end = node_bounds(after[part])
    assert before[part][:old_start] == after[part][:new_start] and before[part][old_end:] == after[part][new_end:], 'unrelated task bytes'
    for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
        heading = ('## 2026-11-12 — ' + OWNER + ':').encode()
        assert after[name].count(heading) == 1, 'dated history record'
    live = 'LIVE_ACHIEVEMENT_STATUS.md'
    old_history = before[live].split(b'## History\n', 1)[1]
    assert after[live].split(b'## History\n', 1)[1] == old_history, 'history authority'
    recent = after[live].split(b'## Recent Completions\n\n', 1)[1].split(b'\n## History', 1)[0]
    rows = [line for line in recent.splitlines() if line.startswith(b'- ')]
    assert len(rows) == 16 and OWNER.encode() in rows[0], 'bounded recent rows'


before = images('publication', 'inputs-before-use')
before.update(images('handoff', 'inputs-before-use'))
after = images('publication', 'outputs-after-use')
after.update(images('handoff', 'outputs-after-use'))
model = dict(before=before, after=after)
validate(model)
controls = [
    ('changed-command', 'RAM command and trend recipe', 'docs/linkedspec-book/src/development/documentation-workflow.md', b'--danger-pct 88', b'--danger-pct 99'),
    ('erased-original-diagnosis', 'original diagnosis bytes', 'docs/knowledge/restricted-macos-ram-host-size-fallback.md', b'Original diagnosis (historical)', b'erased'),
    ('skipped-raw-error', 'handoff prerequisites', 'MEMORY.md', b'before-push raw-error4.28', b'raw errors optional'),
    ('undated-record', 'dated history record', 'CHANGES.md', ('## 2026-11-12 — ' + OWNER).encode(), ('## ' + OWNER).encode()),
]
rejected = []
for name, reason, path, old, new in controls:
    changed = copy.deepcopy(model)
    assert old in changed['after'][path]
    changed['after'][path] = changed['after'][path].replace(old, new)
    try:
        validate(changed)
    except AssertionError as error:
        assert str(error) == reason
        rejected.append(name)
    else:
        raise AssertionError('ineffective publication control: ' + name)
print(json.dumps(dict(publication_recovery='PASS', rejected_controls=rejected,
    scope='Historical producer/report/document images; not current-file freshness or canonical completion.')))
