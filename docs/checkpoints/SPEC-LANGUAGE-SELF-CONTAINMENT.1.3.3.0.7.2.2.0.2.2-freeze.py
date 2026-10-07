"""Verify the existing historical compiler claim without refreshing its hashes."""
from pathlib import Path
import base64
import gzip
import hashlib
import copy
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('freeze.py')
REVISION = 'af5d19971a1682f6895901fb769ff41b69842672'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(document):
    original = json.loads(subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT))
    expected = copy.deepcopy(original)
    paths = set()
    for claim in expected['claims']:
        durability = claim['durability']
        assert durability['mode'] == 'live', 'original compiler claim live boundary'
        for item in durability['inputs']:
            raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
            assert sha(raw) == item['sha256'], 'original historical input identity'
            paths.add(item['path'])
        durability.update(mode='historical', revision=REVISION)
    assert document == expected, 'exact existing historical claim; only original mode/revision changed'
    return len(paths)


def main():
    current = json.loads((ROOT / CLAIM).read_bytes())
    count = check(current)
    initial = Path(PREFIX + 'initial-freeze.py').relative_to(ROOT).as_posix()
    command = ['python3', initial]
    rejected = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert rejected.returncode == 1 and b'original live claim boundary' in rejected.stderr, 'actual original instrument rejection'
    def envelope(raw):
        return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
                'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}
    controls = []
    for name, mutate in [
        ('changed hash', lambda d: d['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64)),
        ('lost input', lambda d: d['claims'][0]['durability']['inputs'].pop()),
        ('changed statement', lambda d: d['claims'][0].update(statement='forged acceptance')),
        ('changed historical boundary', lambda d: d['claims'][0]['durability'].update(revision='864b1a93934ab7fd4b059b0a7cb9d4b417e33c66')),
        ('refreshed live claim', lambda d: d['claims'][0]['durability'].update(mode='live')),
    ]:
        candidate = copy.deepcopy(current)
        mutate(candidate)
        assert candidate != current, 'effective historical control'
        try:
            check(candidate)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected historical control: ' + name)
    summary = {'complete': True, 'revision': REVISION, 'bound_inputs': count,
               'current_claim_sha256': sha((ROOT / CLAIM).read_bytes()),
               'instrument_sha256': sha(Path(__file__).read_bytes()), 'controls': controls,
               'initial_instrument_rejection': {'command': command, 'exit': rejected.returncode,
                    'stdout': envelope(rejected.stdout), 'stderr': envelope(rejected.stderr),
                    'instrument_sha256': sha((ROOT / initial).read_bytes())},
               'scope': 'The due hygiene leaf already froze this compiler claim. Verify its exact '
                        'historical boundary and every original hash; no claim mutation or re-freeze.'}
    Path(PREFIX + 'freeze.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
