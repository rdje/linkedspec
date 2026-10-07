"""Freeze the completed callable repair at its exact committed input boundary."""
from pathlib import Path
import copy
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('freeze.py')
REVISION = '0f31461d696186775585e19355a0bc5c41849dfb'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def expected():
    old = json.loads(subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT))
    result = copy.deepcopy(old)
    paths = {}
    for claim in result['claims']:
        durability = claim['durability']
        assert durability['mode'] == 'live'
        for item in durability['inputs']:
            raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
            assert sha(raw) == item['sha256'], 'original historical hash'
            paths[item['path']] = item['sha256']
        durability.update(mode='historical', revision=REVISION)
    return result, paths


def check(document):
    wanted, paths = expected()
    assert document == wanted, 'exact mode/revision-only checkpoint freeze'
    return len(paths)


def main():
    path = ROOT / CLAIM
    current = json.loads(path.read_bytes())
    wanted, paths = expected()
    if current['claims'][0]['durability']['mode'] == 'live':
        for name, digest in paths.items():
            assert sha((ROOT / name).read_bytes()) == digest, 'unmodified original root input before freeze'
        # Verify the complete original document before changing only its boundary.
        original = json.loads(subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT))
        assert current == original
        path.write_text(json.dumps(wanted, indent=2) + '\n')
        current = wanted
    count = check(current)
    controls = []
    for name, mutate in (
        ('refreshed hash', lambda d: d['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64)),
        ('lost input', lambda d: d['claims'][0]['durability']['inputs'].pop()),
        ('changed statement', lambda d: d['claims'][0].update(statement='forged checkpoint')),
        ('wrong boundary', lambda d: d['claims'][0]['durability'].update(revision='864b1a93934ab7fd4b059b0a7cb9d4b417e33c66')),
        ('refreshed live', lambda d: d['claims'][0]['durability'].update(mode='live')),
    ):
        changed = copy.deepcopy(current); mutate(changed); assert changed != current
        try:
            check(changed)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected history control: ' + name)
    report = {'complete': True, 'revision': REVISION, 'bound_inputs': count, 'controls': controls,
              'claim_sha256': sha(path.read_bytes()), 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'freeze.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Original checkpoint frozen:', count, 'exact inputs;', len(controls), 'rejected controls')


if __name__ == '__main__':
    main()
