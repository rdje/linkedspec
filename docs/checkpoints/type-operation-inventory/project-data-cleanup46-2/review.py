"""Read-only retained review; no source swapping, quarantine, deletion or old build."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import stat
import tempfile

ROOT = Path(__file__).resolve().parents[4]
PREFIX = Path(__file__).parent
record = json.loads(gzip.decompress((PREFIX / 'intake.json.gz').read_bytes()))
sha = lambda raw: hashlib.sha256(raw).hexdigest()
rows = {row['path']: row for row in record['inputs']}
assert len(rows) == len(record['inputs'])
for alias in record['aliases']:
    assert alias['path'] not in rows and alias['target'] in rows
    source = rows[alias['target']]
    assert alias['bytes'] == source['bytes'] and alias['sha256'] == source['sha256']
    rows[alias['path']] = dict(source, path=alias['path'])
for row in rows.values():
    raw = base64.b64decode(row['base64'])
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    path = Path(row['path'])
    assert not path.is_absolute() and '..' not in path.parts
for path in PREFIX.glob('*.py'):
    assert sha(path.read_bytes()) == rows[path.relative_to(ROOT).as_posix()]['sha256']


def captured(name):
    return base64.b64decode(rows['.linkedspec-data/verification/project-data-cleanup46-2/' + name]['base64'])


def assemble(value, output):
    digest = hashlib.sha256()
    size = 0
    for part in value['parts']:
        relative = Path(part['path'])
        assert not relative.is_absolute() and '..' not in relative.parts
        path = ROOT / relative
        assert path.is_file() and not path.is_symlink()
        raw = path.read_bytes()
        assert len(raw) == part['bytes'] and sha(raw) == part['sha256']
        digest.update(raw)
        size += len(raw)
        output.write(raw)
    assert size == value['bytes'] and digest.hexdigest() == value['sha256']


plan = json.loads(captured('plan.json'))
disposal = json.loads(captured('disposal.json'))
build = json.loads(captured('current-build.json'))
preflight = json.loads(gzip.decompress(captured('preflight-final.json.gz')))
assert not preflight['live_intersections'] and not preflight['recent_production_intersections']
assert preflight['scanner_control']['legacy_false_negative'] == []
assert preflight['scanner_control']['current_detected'] == ['bound']
assert disposal['deleted_objects'] == plan['totals']['selected_files']
assert disposal['source_restored'] and disposal['quarantine_absent']
source_review = json.loads(base64.b64decode(rows['.linkedspec-data/verification/project-data-cleanup46-2-review.log']['base64']))
assert source_review['planned_objects_absent'] == plan['totals']['selected_files']
assert source_review['retained_entries_exact'] == plan['totals']['retained_entries']
assert source_review['quarantine_absent']
control_raw = base64.b64decode(rows['.linkedspec-data/verification/project-data-cleanup46-2-controls-final2.log']['base64'])
controls = json.loads(control_raw.splitlines()[-1])['controls']
assert len(controls) == 7 and sum(row.get('rejected', False) for row in controls) == 6
assert 'initial guard admitted existing sibling' in controls[-1]['label']
live_refusal = base64.b64decode(rows['.linkedspec-data/verification/project-data-cleanup46-2-liveness-while-plan.stderr']['base64'])
assert b'AssertionError:' in live_refusal and b"'pid':" in live_refusal and b'/debug/deps' in live_refusal
assert json.loads(captured('liveness.json'))['candidate_hits'] == []
assert build['exit'] == 0 and build['source_absent'] and build['quarantine_present'] and build['input_identities_unchanged']
assert b'6 passed; 0 failed; 0 ignored' in captured('current-build.stdout')
for row in json.loads(gzip.decompress(captured('current-build-inputs.json.gz'))).values():
    assert sha(base64.b64decode(row['base64'])) == row['sha256']
totals = dict(selected_files=0, selected_logical_bytes=0, selected_allocated_bytes=0, retained_entries=0)
with tempfile.TemporaryDirectory(prefix='cleanup46-retained-') as folder:
    manifest = Path(folder) / 'entries.jsonl.gz'
    with manifest.open('xb') as output:
        assemble(record['manifest'], output)
    assert record['manifest']['sha256'] == plan['manifest_sha256']
    with gzip.open(manifest, 'rt') as stream:
        for line in stream:
            name, selected, info = json.loads(line)
            assert '/' not in name and name not in ('.', '..') and len(info) == 8
            mode, device, inode, size, mtime, ctime, blocks, links = info
            expected = (name.endswith('.rcgu.o') and stat.S_ISREG(mode) and mode & 0o111 == 0
                        and links == 1 and device == plan['source_identity'][1]
                        and mtime < 1790467200000000000)
            assert selected == expected
            if selected:
                totals['selected_files'] += 1
                totals['selected_logical_bytes'] += size
                totals['selected_allocated_bytes'] += blocks * 512
            else:
                totals['retained_entries'] += 1
    binary = Path(folder) / 'test.gz'
    with binary.open('xb') as output:
        assemble(record['current_test_executable'], output)
    digest = hashlib.sha256()
    size = 0
    with gzip.open(binary, 'rb') as stream:
        while raw := stream.read(1024 * 1024):
            digest.update(raw)
            size += len(raw)
    assert digest.hexdigest() == build['actual_test_executable']['sha256']
    assert size == build['actual_test_executable']['bytes']
assert totals == plan['totals']
assert record['observed_exits']['controls_initial'] == 1 and record['observed_exits']['live_owner_refusal'] == 1
print(json.dumps(dict(owner=record['owner'], totals=totals, retained_inputs=len(rows),
                      current_rust_tests=6, limits=record['limits']), sort_keys=True))
