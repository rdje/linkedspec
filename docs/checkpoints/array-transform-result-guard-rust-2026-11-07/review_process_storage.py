"""Readonly original-byte recovery and unchanged-oracle RED/GREEN storage proof."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent


def recover(phase):
    out = BASE / ('process-storage-' + phase)
    rows = json.loads((out / 'input-identities.json').read_bytes())
    files = {}
    with tarfile.open(out / 'inputs-before-run.tar.gz') as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in files
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert hashlib.sha256(body).hexdigest() == row['sha256']
            assert len(body) == row['bytes'] and member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == rows.keys()
    return rows, files


def validate(mapping, original, carrier):
    expected = str(BASE.relative_to(ROOT) / 'commit-correction/processes-before-termination.json')
    assert mapping['logical_path'] == expected, 'logical identity'
    assert mapping['physical_path'] == expected + '.gz', 'physical identity'
    body = gzip.decompress(carrier)
    assert hashlib.sha256(body).hexdigest() == mapping['sha256'], 'original hash'
    assert len(body) == mapping['bytes'] and body == original, 'original bytes'
    assert hashlib.sha256(carrier).hexdigest() == mapping['carrier_sha256'], 'carrier hash'


before_rows, before = recover('before')
after_rows, after = recover('after')
mapping_path = BASE / 'commit-correction/process-storage.json'
mapping = json.loads(mapping_path.read_bytes())
original = before[mapping['logical_path']]
carrier = (ROOT / mapping['physical_path']).read_bytes()
validate(mapping, original, carrier)
assert mapping['original_mode'] == before_rows[mapping['logical_path']]['mode']
assert (ROOT / mapping['physical_path']).stat().st_mode & 0o777 == mapping['original_mode']
assert not (ROOT / mapping['logical_path']).exists()
assert after[mapping['physical_path']] == carrier
assert after[str(mapping_path.relative_to(ROOT))] == mapping_path.read_bytes()
for name in before.keys() & after.keys():
    assert before[name] == after[name] and before_rows[name] == after_rows[name]
for phase, code in (('before', 1), ('after', 0)):
    out = BASE / ('process-storage-' + phase)
    assert (out / 'exit.txt').read_text() == str(code) + '\n'
    command = json.loads((out / 'command.json').read_bytes())
    assert command == dict(argv=['bash', 'scripts/check_repo_root_path_portability.sh'], cwd='.')
stderr = gzip.decompress((BASE / 'process-storage-before/stderr.log.gz').read_bytes())
assert b'processes-before-termination.json' in stderr and b'current checkout identity' in stderr
checks = 0
for key, value, reason in (('logical_path', 'wrong.json', 'logical identity'), ('sha256', '0' * 64, 'original hash')):
    broken = copy.deepcopy(mapping)
    broken[key] = value
    try:
        validate(broken, original, carrier)
    except AssertionError as error:
        assert str(error) == reason
        checks += 1
    else:
        raise AssertionError('ineffective process-storage corruption')
print('exact raw process bytes/mode recovered; unchanged portability oracle1RED to0GREEN; two effective corruptions rejected')
