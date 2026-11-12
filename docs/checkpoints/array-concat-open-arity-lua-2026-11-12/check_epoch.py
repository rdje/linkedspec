"""Check each host's full Lua records, source/artifact pairs and native images."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
phase = sys.argv[1]
assert phase in ('before', 'after', 'direct', 'inverse', 'restored')
target = BASE / (phase + '-check.json')
assert not target.exists()
assert (BASE / phase / 'complete.txt').is_file()
baseline = json.loads((BASE / 'baseline.json').read_bytes())

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def archive(path, rows):
    result = {}
    with tarfile.open(path) as stream:
        assert set(stream.getnames()) == rows.keys()
        for member in stream:
            assert member.isfile() and member.name not in result
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = stream.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    return result

result = {}
for host in ('puc', 'luajit'):
    out = BASE / phase / host
    cold = baseline[host]['observed']
    expected = baseline[host]['expected']
    old = phase in ('before', 'inverse')
    records = {}
    stdout = gzip.decompress((out / 'normal-stdout.log.gz').read_bytes())
    for line in stdout.decode().splitlines():
        if line.startswith('ARRAY_CONCAT_LUA_NORMAL '):
            _, key, raw = line.split(' ', 2)
            assert key not in records
            records[key] = json.loads(raw)
    assert len(records) == 508 and encoded(records) == encoded(cold if old else expected)
    assert (out / 'normal-exit.txt').read_text() == ('1\n' if old else '0\n')
    assert len(baseline[host]['preserved']) == 484 and len(baseline[host]['initial_policies']) == 80
    for key in baseline[host]['preserved'] + baseline[host]['initial_policies']:
        assert encoded(records[key]) == encoded(cold[key])
    original = BASE / 'intake' / host
    original_rows = json.loads((original / 'artifact-identities.json').read_bytes())
    current_rows = json.loads((out / 'artifact-identities.json').read_bytes())
    artifacts = archive(original / 'actual-emitted-parsed.tar.gz', original_rows)
    current = archive(out / 'actual-emitted-parsed.tar.gz', current_rows)
    assert len(artifacts) == len(current) == 1016
    for key in records:
        for folder, suffix in (('parsed', '.json'), ('emitted', '.lua')):
            assert artifacts[str(REL / 'intake' / host / folder / (key + suffix))] == current[str(REL / phase / host / folder / (key + suffix))]
    originals = json.loads((original / 'native-identities.json').read_bytes())
    natives = json.loads((out / 'native-identities.json').read_bytes())
    assert len(originals) == len(natives) == 3
    images = archive(out / 'native-before-first-run.tar.gz', natives)
    for name, row in natives.items():
        assert row == originals[str(REL / 'intake' / host / 'native' / Path(name).name)]
    stderr = gzip.decompress((out / 'normal-stderr.log.gz').read_bytes())
    if old:
        assert b'function_1_free_hash' in stderr
    else:
        assert stderr == b'', 'Unexpected SDK/launcher stderr needs explicit root-cause review, never suppression'
    result[host] = dict(programs=508, routes=4, supported_targets=20, separate_legacy_operand_compatibility=4,
        preserved=484, initial_policies_exact=80, actual_parsed_module_pairs_exact=508,
        opaque_native_images_exact=3, full_wire_records='PASS',
        actual_stderr=dict(bytes=len(stderr), sha256=hashlib.sha256(stderr).hexdigest()),
        limits='Finite own installed-host proof; no complete native/VM/cache/transitive/toolchain/OS4.2/SESSION5 or declared5.4/full23.4 admission. Older direct normals are semantic only.')
if phase == 'before':
    assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'lua/src', 'lua/test/run.lua'], cwd=ROOT) == b''
target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, indent=2, sort_keys=True))
