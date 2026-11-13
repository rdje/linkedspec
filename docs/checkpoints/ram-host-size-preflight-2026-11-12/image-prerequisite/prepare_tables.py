"""Create one later-image table and the exact owned RAM CI inverse."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'table-preparation'
OUT.mkdir()
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.14'
REVISION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
LATEST = Path('tests/language-readiness/current-source-successors-2026-11-12.json.gz')
RAM = Path('tests/language-readiness/ram-preflight-ci-evolution.json.gz')
assert not LATEST.exists() and not RAM.exists()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == REVISION
inventory = BASE / 'intake/source-inventory.json'
support = ['tools/host_ram_usage.sh', 'tools/ram_guard.sh', 'tools/test_ram_guard.py',
           'doctrine/project_data_storage/python_entrypoints.json', 'doctrine/project_data_storage/python_temporary_owners.json']
old_tables = [Path('tests/language-readiness') / name for name in (
    'current-source-images.json.gz', 'current-source-successors.json.gz', 'additional-source-images.json.gz')]
paths = [Path(__file__).relative_to(ROOT), inventory, Path('tools/run_ci_local.sh')] + old_tables + [Path(name) for name in support]
identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as packed:
    for path in paths:
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as packed:
    assert set(packed.getnames()) == identities.keys()
    for member in packed:
        assert hashlib.sha256(packed.extractfile(member).read()).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
for path in old_tables:
    assert path.read_bytes() == subprocess.check_output(['git', 'show', REVISION + ':' + str(path)])
data = json.loads(inventory.read_bytes())
changed = [row for row in data['historical_sources'] if row['classification'] == 'changed-image']
prior = json.loads(gzip.decompress(old_tables[1].read_bytes()))
assert {row['path'] for row in changed} == {row['path'] for row in prior['images']}
rows = []
for row in changed:
    name = row['path']
    body = Path(name).read_bytes()
    assert row['current_equals_activation'] and body == subprocess.check_output(['git', 'show', REVISION + ':' + name])
    assert hashlib.sha256(body).hexdigest() == row['actual_sha256']
    old = row['admitted']
    rows.append(dict(path=name, historical_sha256=row['historical_sha256'],
        prior_revision=old['activation_commit'], prior_sha256=old['current_sha256'], current_sha256=row['actual_sha256']))
later = dict(schema_version=1, owner=OWNER, activation_commit=REVISION, images=sorted(rows, key=lambda row: row['path']))
LATEST.write_bytes(gzip.compress(json.dumps(later, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
ci = Path('tools/run_ci_local.sh')
before = subprocess.check_output(['git', 'show', REVISION + ':' + str(ci)]).decode()
current = ci.read_text()
anchor = 'require_tracked_file tests/language-readiness/current-source-images.json.gz\n'
added = anchor + 'require_tracked_file ' + str(LATEST) + '\nrequire_tracked_file ' + str(RAM) + '\n'
assert current.count(anchor) == 1 and added not in current
current = current.replace(anchor, added, 1)
end = 'log "RAM ${GUARD_PCT}% used — within threshold (${DANGER_PCT}%)"\n'


def memory_block(text, start):
    assert text.count(start) == text.count(end) == 1
    at = text.index(start)
    return text[at:text.index(end, at) + len(end)]


old_block = memory_block(before, '# Memory guard — bail if system RAM is critically low before running the heavy suite\n')
new_block = memory_block(current, '# Snapshot admission is separate from live host-wide trend monitoring.\n')
hunks = [dict(before=anchor, after=added), dict(before=old_block, after=new_block)]
restored = current
for hunk in reversed(hunks):
    assert restored.count(hunk['after']) == 1
    restored = restored.replace(hunk['after'], hunk['before'], 1)
assert restored == before
ci.write_text(current)
ram = dict(schema_version=1, owner=OWNER, activation_commit=REVISION, path=str(ci),
    current_stage='owned candidate bytes; activation identifies committed precursor only',
    before_sha256=hashlib.sha256(before.encode()).hexdigest(), after_sha256=hashlib.sha256(current.encode()).hexdigest(),
    hunks=hunks, support=[dict(path=name, sha256=hashlib.sha256(Path(name).read_bytes()).hexdigest()) for name in sorted(support)])
RAM.write_bytes(gzip.compress(json.dumps(ram, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
result = dict(later_table=str(LATEST), later_sha256=hashlib.sha256(LATEST.read_bytes()).hexdigest(),
    ram_table=str(RAM), ram_sha256=hashlib.sha256(RAM.read_bytes()).hexdigest(),
    ci_after_sha256=ram['after_sha256'], ci_precursor_sha256=ram['before_sha256'], changed_paths=[row['path'] for row in later['images']],
    scope='Exact later committed identities and exact owned candidate inverse; original tables, runtime bodies and historical results unchanged.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, indent=2, sort_keys=True))
