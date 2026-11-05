"""Preserve the dependent publication claim at the clean pre-edit Git boundary.

Default is read-only. --apply is a one-shot mode/revision-only writer following
the existing task-acceptance-backend-scope/preserve_claim.py contract.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
REVISION = 'eda3c81fe6ca9264f0ba96f3f90525d96d79626c'
RECORD = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.7.json'
NAME = 'dated-publication-and-logical-object-custody'
DEPENDENCY = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'


def expected_record():
    raw = subprocess.check_output(['git', 'show', REVISION + ':' + RECORD], cwd=ROOT)
    original = json.loads(raw)
    expected = copy.deepcopy(original)
    selected = [c for c in expected['claims'] if c['name'] == NAME]
    assert len(selected) == 1
    leg = selected[0]['durability']
    assert leg['status'] == 'checked' and leg['mode'] == 'live' and 'revision' not in leg
    inputs = leg['inputs']
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    verified = []
    try:
        for row in inputs:
            process.stdin.write((REVISION + ':' + row['path'] + '\n').encode())
            process.stdin.flush()
            header = process.stdout.readline().split()
            assert len(header) == 3 and header[1] == b'blob', row['path']
            remaining = size = int(header[2])
            digest = hashlib.sha256()
            while remaining:
                block = process.stdout.read(min(remaining, 1024 * 1024))
                assert block
                digest.update(block)
                remaining -= len(block)
            assert process.stdout.read(1) == b'\n'
            assert digest.hexdigest() == row['sha256'], row['path']
            verified.append(dict(path=row['path'], oid=header[0].decode(),
                                 bytes=size, sha256=digest.hexdigest()))
    finally:
        process.stdin.close()
        assert process.wait() == 0
    leg.update(mode='historical', revision=REVISION)
    return raw, expected, verified


def validate(candidate, expected):
    assert candidate == expected, 'original fields/input hashes or selected boundary changed'


def controls(expected):
    rejected = []
    selected = next(i for i, c in enumerate(expected['claims']) if c['name'] == NAME)
    for name in ('original-statement', 'original-input-hash', 'wrong-revision',
                 'omitted-input', 'unselected-claim'):
        changed = copy.deepcopy(expected)
        target = changed['claims'][selected]
        if name == 'original-statement': target['statement'] += ' altered'
        elif name == 'original-input-hash': target['durability']['inputs'][0]['sha256'] = '0' * 64
        elif name == 'wrong-revision': target['durability']['revision'] = '0' * 40
        elif name == 'omitted-input': target['durability']['inputs'].pop()
        else: changed['claims'][next(i for i in range(len(changed['claims'])) if i != selected)]['statement'] += ' altered'
        try:
            validate(changed, expected)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective preservation control: ' + name)
    return rejected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    before, expected, verified = expected_record()
    path = ROOT / RECORD
    old_dependency = next(row for row in verified if row['path'] == DEPENDENCY)
    current_dependency = hashlib.sha256((ROOT / DEPENDENCY).read_bytes()).hexdigest()
    report = dict(revision=REVISION, record=RECORD, selected_claim=NAME,
                  verified_inputs=verified, unchanged_original_input_count=len(verified),
                  changed_fields=['durability.mode', 'durability.revision'],
                  original_dependency_sha256=old_dependency['sha256'],
                  edited_dependency_sha256=current_dependency,
                  original_live_dependency_binding_rejects_edit=current_dependency != old_dependency['sha256'],
                  rejected_controls=controls(expected))
    if args.apply:
        assert path.read_bytes() == before, 'writer requires the exact committed predecessor'
        assert report['original_live_dependency_binding_rejects_edit'], 'missing actual stale-dependency RED'
        assert not (HERE / 'publication-preservation-result.json').exists(), 'one-shot writer already ran'
        path.write_text(json.dumps(expected, indent=2) + '\n')
        (HERE / 'publication-preservation-result.json').write_text(json.dumps(report, indent=2) + '\n')
    validate(json.loads(path.read_bytes()), expected)
    retained = json.loads((HERE / 'publication-preservation-result.json').read_text())
    assert retained == report, 'preservation evidence changed'
    print(json.dumps(dict(result='PASS', original_input_count=len(verified),
        only_mode_revision_changed=True, stale_live_dependency_red=report['original_live_dependency_binding_rejects_edit'],
        rejected_controls=report['rejected_controls']), sort_keys=True))


if __name__ == '__main__':
    main()
