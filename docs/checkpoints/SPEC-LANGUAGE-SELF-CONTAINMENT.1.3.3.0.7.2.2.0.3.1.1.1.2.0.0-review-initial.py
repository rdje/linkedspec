"""Verify a crash-recovery checkpoint without admitting the unfinished draft."""
import base64
import copy
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '58a11ae80cc55f8d19a0a7a4f0203ae491d11383'
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0'
FOUNDATION = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0-'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.json'
TRACKED = {'MEMORY.md', CLAIM, 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md',
           'perl/LinkedSpec/ActionIR/SourceOrigins.pm'}
UNTRACKED = {FOUNDATION + 'before-' + Path(CLAIM).name, FOUNDATION + 'freeze.json',
             FOUNDATION + 'preserve.py', 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'}

def require(ok, message):
    if not ok:
        raise ValueError(message)

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def git(*args, env=None, data=None):
    return subprocess.run(['git', '-C', str(ROOT), *args], env=env, input=data,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True).stdout

def decode(value):
    return base64.b64decode(value, validate=True)

def reconstruct(snapshot):
    require(snapshot['base_revision'] == BASE, 'foreign activation revision')
    entries = snapshot['entries']
    require(len(entries) == 8 and {e['path'] for e in entries} == TRACKED | UNTRACKED,
            'incomplete or duplicate crash inventory')
    expected_status = ''.join(e['status'] + ' ' + e['path'] + '\n' for e in entries)
    require(snapshot['status'] == expected_status, 'crash inventory/status mismatch')
    require({e['path'] for e in entries if e['status'] == ' M'} == TRACKED
            and {e['path'] for e in entries if e['status'] == '??'} == UNTRACKED,
            'unexpected crash path status')
    raw = {}
    # Use only an isolated index; never apply the draft to the live worktree.
    with tempfile.TemporaryDirectory(prefix='crash-index-', dir=os.environ['TMPDIR']) as scratch:
        env = dict(os.environ, GIT_INDEX_FILE=str(Path(scratch) / 'index'))
        git('read-tree', BASE, env=env)
        patch = decode(snapshot['tracked_diff_base64'])
        git('apply', '--cached', '--binary', '-', env=env, data=patch)
        changed = set(git('diff', '--cached', '--name-only', BASE, env=env).decode().splitlines())
        require(changed == TRACKED, 'unexpected recovered tracked delta')
        for entry in entries:
            path = entry['path']
            if path in TRACKED:
                original = git('show', BASE + ':' + path)
                require(digest(original) == entry['base_sha256'], 'wrong baseline bytes: ' + path)
                raw[path] = git('show', ':' + path, env=env)
            else:
                raw[path] = decode(entry['content_base64'])
            require(len(raw[path]) == entry['bytes'] and digest(raw[path]) == entry['sha256'],
                    'changed crash bytes: ' + path)
    # Independently establish historical preservation from original immutable Git.
    original = json.loads(git('show', BASE + ':' + CLAIM))
    expected = copy.deepcopy(original)
    bindings = 0
    for claim in expected['claims']:
        durability = claim['durability']
        require(durability['mode'] == 'live', 'unexpected original claim mode')
        for entry in durability['inputs']:
            require(digest(git('show', BASE + ':' + entry['path'])) == entry['sha256'],
                    'original claim binding mismatch: ' + entry['path'])
            bindings += 1
        durability.update(mode='historical', revision=BASE)
    require(json.loads(raw[CLAIM]) == expected, 'historical claim changed beyond mode/revision')
    require(raw[FOUNDATION + 'before-' + Path(CLAIM).name] == git('show', BASE + ':' + CLAIM),
            'original claim snapshot mismatch')
    freeze = json.loads(raw[FOUNDATION + 'freeze.json'])
    require(freeze['revision'] == BASE and len(freeze['records']) == 1,
            'foreign historical freeze')
    row = freeze['records'][0]
    require(row['path'] == CLAIM and row['before'] == FOUNDATION + 'before-' + Path(CLAIM).name
            and row['original_sha256'] == digest(git('show', BASE + ':' + CLAIM))
            and row['after_sha256'] == digest(raw[CLAIM])
            and row['verified_bindings'] == bindings
            and freeze['producer_sha256'] == digest(raw[FOUNDATION + 'preserve.py']),
            'historical freeze binding mismatch')
    return raw, bindings

def main():
    snapshot = json.loads((ROOT / (PREFIX + '-crash.json')).read_bytes())
    real_index_before = git('diff', '--cached', '--binary', '--full-index')
    raw, bindings = reconstruct(snapshot)
    mutations = []
    controls = []

    bad = copy.deepcopy(snapshot)
    bad['entries'].pop()
    controls.append(('missing-survivor', bad, 'incomplete or duplicate crash inventory'))

    bad = copy.deepcopy(snapshot)
    bad['base_revision'] = '0' * 40
    controls.append(('foreign-activation', bad, 'foreign activation revision'))

    bad = copy.deepcopy(snapshot)
    patch = decode(bad['tracked_diff_base64'])
    needle = b'return ref($_invocation)'
    require(patch.count(needle) == 1, 'source inverse needle is not unique')
    bad['tracked_diff_base64'] = base64.b64encode(patch.replace(needle, b'return !ref($_invocation)')).decode()
    controls.append(('source-inverse', bad, 'changed crash bytes: perl/LinkedSpec/ActionIR/SourceOrigins.pm'))

    bad = copy.deepcopy(snapshot)
    entry = next(e for e in bad['entries'] if e['path'].endswith('/SourceEmissions.pm'))
    entry['content_base64'] = base64.b64encode(decode(entry['content_base64']) + b'\n').decode()
    controls.append(('changed-draft', bad, 'changed crash bytes: perl/LinkedSpec/ActionIR/SourceEmissions.pm'))

    bad = copy.deepcopy(snapshot)
    next(e for e in bad['entries'] if e['path'] == 'MEMORY.md')['base_sha256'] = '0' * 64
    controls.append(('wrong-baseline', bad, 'wrong baseline bytes: MEMORY.md'))

    bad = copy.deepcopy(snapshot)
    entry = next(e for e in bad['entries'] if e['path'] == FOUNDATION + 'freeze.json')
    freeze = json.loads(decode(entry['content_base64']))
    freeze['revision'] = '0' * 40
    altered = (json.dumps(freeze, indent=2) + '\n').encode()
    entry.update(content_base64=base64.b64encode(altered).decode(),
                 sha256=digest(altered), bytes=len(altered))
    controls.append(('rehashed-foreign-freeze', bad, 'foreign historical freeze'))

    for name, altered, expected in controls:
        try:
            reconstruct(altered)
        except ValueError as error:
            require(str(error) == expected, 'wrong RED reason for ' + name + ': ' + str(error))
            mutations.append({'name': name, 'result': 'RED', 'reason': str(error)})
        else:
            raise ValueError('control unexpectedly passed: ' + name)

    plan = json.loads(git('show', BASE + ':docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json'))
    owners = plan['bounded_owners']
    for path, expected in owners.items():
        baseline = git('show', BASE + ':' + path)
        require(digest(baseline) == expected and (ROOT / path).read_bytes() == baseline,
                'production not restored: ' + path)
    require(not (ROOT / 'perl/LinkedSpec/ActionIR/SourceEmissions.pm').exists(),
            'unverified draft remains in production')
    require((ROOT / CLAIM).read_bytes() == raw[CLAIM], 'current historical claim differs from recovered freeze')
    for path in UNTRACKED - {'perl/LinkedSpec/ActionIR/SourceEmissions.pm'}:
        require((ROOT / path).read_bytes() == raw[path], 'surviving preservation file changed: ' + path)
    require(git('diff', '--cached', '--binary', '--full-index') == real_index_before,
            'review changed real index')
    result = {'owner': 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0', 'base_revision': BASE,
              'recovered_files': len(raw), 'tracked_delta_files': len(TRACKED),
              'untracked_files': len(UNTRACKED), 'original_claim_bindings': bindings,
              'restored_production_owners': len(owners), 'controls': mutations,
              'result': 'PASS',
              'limits': snapshot['limit'] + ' No foundation behavior proof, Phase0 run, replacement admission or push is claimed.'}
    (ROOT / (PREFIX + '-review.json')).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()
