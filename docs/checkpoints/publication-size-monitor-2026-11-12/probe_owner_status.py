"""Exercise the unchanged production repair-owner parser on exact before/after images."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tarfile

sys.dont_write_bytecode = True
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'owner-status'
OUT.mkdir()
TOOL = Path('tools/check_claim_verification.py')
TREE = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.30'
before = gzip.decompress((BASE / 'landing-pressure/overview-before.md.gz').read_bytes())
after = Path(TREE).read_bytes()
paths = [TOOL, Path(TREE), BASE / 'landing-pressure/overview-before.md.gz',
    BASE / 'landing-pressure/checker-before.py.gz', Path(__file__).resolve().relative_to(ROOT)]
identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as packed:
    for path in paths:
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as packed:
    assert set(packed.getnames()) == identities.keys()
    for member in packed:
        body = packed.extractfile(member).read(); row = identities[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
assert TOOL.read_bytes() == gzip.decompress((BASE / 'landing-pressure/checker-before.py.gz').read_bytes())
spec = importlib.util.spec_from_file_location('monitor_owner_contract', TOOL)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def observe(body):
    blob = hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest()
    def fixture_git(*arguments):
        assert arguments == ('cat-file', 'blob', blob), 'unexpected production lookup'
        return body
    snapshot = module.InputSnapshot({TREE: ('100644', blob)}, git_reader=fixture_git)
    try:
        snapshot.check_owner(OWNER)
        result = dict(accepted=True)
    except ValueError as error:
        result = dict(accepted=False, error=str(error))
    result['owner_matches'] = snapshot.owners[OWNER]
    return result


def parent(body):
    start = body.index(('- ID: `' + OWNER + '`').encode())
    end = body.index(b'\n- ID:', start + 1)
    return start, end, body[start:end]


first, last, parent_after = parent(after)
_, _, parent_before = parent(before)
assert parent_after == parent_before.replace(b'  Status: `in_progress`', b'  Status: `active`', 1)
closed = after[:first] + parent_after.replace(b'  Status: `active`', b'  Status: `completed`', 1) + after[last:]
observations = dict(original_in_progress=observe(before), corrected_active=observe(after), closed_control=observe(closed))
expected = 'gap repair owner is not open: ' + OWNER
assert observations['original_in_progress'] == dict(accepted=False, error=expected, owner_matches=[False])
assert observations['corrected_active'] == dict(accepted=True, owner_matches=[True])
assert observations['closed_control'] == dict(accepted=False, error=expected, owner_matches=[False])
result = dict(actual_production_parser='PASS', observations=observations,
    scope='Unchanged production InputSnapshot.check_owner on retained whole-task fixtures through its explicit git_reader seam. Original RED/fixed GREEN/closed RED; no real index scan, measurement, SDK or policy change.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))
