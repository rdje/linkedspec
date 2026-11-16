"""Replay the dated pressure proof from retained inputs, without today's task view."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = 'docs/checkpoints/perl-consumer-roles-2026-11-16/'


def main():
    identities = json.loads((BASE / 'before-identities.json').read_bytes())
    own = str(BASE / 'historical_pressure.py')
    assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest() == identities[own]['sha256']
    inputs = {}
    with tarfile.open(BASE / 'before.tar.gz') as archive:
        for member in archive:
            if member.name.startswith(OLD):
                body = archive.extractfile(member).read()
                assert member.isfile() and hashlib.sha256(body).hexdigest() == identities[member.name]['sha256']
                assert member.mode == identities[member.name]['mode']
                inputs[member.name] = body
    # Execute only the retained module definitions, then its pure validator.
    # The original main's current-task assertion is preserved in its own source
    # and its observed RED; this historical route never calls that main.
    namespace = dict(__name__='retained_pressure_validator', __file__=str(ROOT / (OLD + 'review_pressure.py')))
    exec(compile(inputs[OLD + 'review_pressure.py'], OLD + 'review_pressure.py', 'exec'), namespace)
    metadata = json.loads(inputs[OLD + 'pressure.json'])
    old = gzip.decompress(inputs[OLD + 'task-activation.gz'])
    before = gzip.decompress(inputs[OLD + 'task-before.gz'])
    after = gzip.decompress(inputs[OLD + 'task-after.gz'])
    actual_old = subprocess.check_output(['git', 'show', '3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0:docs/tasks/TYPE-REFERENCE-BOOK.overview.md'])
    assert old == actual_old and hashlib.sha256(before).hexdigest() == metadata['before_sha256']
    assert b'aggregate bytes 12588670/12582912' in gzip.decompress(inputs[OLD + 'first-normal.gz'])
    validate = namespace['validate']
    validate(old, after, metadata['mode'], metadata)
    controls = {}
    for kind in ('older-prefix', 'parent-contract', 'new-node', 'mode'):
        changed, record, mode = after, copy.deepcopy(metadata), metadata['mode']
        if kind == 'older-prefix':
            changed = b'!' + after[1:]
        elif kind == 'parent-contract':
            changed = after.replace(b'Goal: Complete remaining consumer/support/dormant/fixture roles', b'Goal: Omit remaining consumer/support/dormant/fixture roles', 1)
        elif kind == 'new-node':
            changed = after.replace(b'Goal: Qualify Perl roles.', b'Goal: Unqualified roles.', 1)
        else:
            mode = 0o755
        assert changed != after or mode != metadata['mode']
        record['after_sha256'] = hashlib.sha256(changed).hexdigest()
        try:
            validate(old, changed, mode, record)
        except ValueError as error:
            controls[kind] = dict(result='RED', reason=str(error))
        else:
            raise ValueError('historical pressure control accepted')
    result = dict(result='PASS', added_task_bytes=metadata['added_task_bytes'],
                  original_contract_and_other_bytes='preserved', controls=controls)
    assert result == json.loads(inputs[OLD + 'pressure-review-stdout.json']), 'original result values unchanged'
    print(json.dumps(dict(result='PASS', historical_pressure=result,
        limits='Archived accepted task bytes/mode only. No current TYPE task identity or original command freshness is asserted; original source/result/claim fields stay unchanged.'), sort_keys=True))


if __name__ == '__main__':
    main()
