"""Readonly proof that one stale source field predates the callable repair."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
METHOD = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
FIXTURE = 'tests/fixtures/count_result_guard_excluded_ast.json'
ACTIVATION = '7289836f28e4873463ad1c50d354d8e66c77af8d'


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'packet identity'
    return raw


def check(original, current, before, after):
    assert len(original) == len(current) == len(before['rows']) == 18
    assert before['rows'] == after['rows'] == current, 'activation/current source behavior differs'
    assert before['excluded'] == after['excluded'], 'excluded native/emitted/metadata behavior differs'
    changed = [(i, key) for i, (a, b) in enumerate(zip(original, current)) for key in a if a[key] != b[key]]
    assert changed == [(0, 'lowered')], 'unreviewed fixture cell'
    assert current[0]['source'] == 'count().take(1).with(){return("x")}'
    assert original[0]['lowered'] != current[0]['lowered']
    assert '__ls_free_default_rejected' in current[0]['lowered']
    meta = after['excluded']['metadata']
    assert meta['language_agnostic_action_ir_ready'] == 0
    assert meta['unresolved_helper_count'] == 1 and meta['unresolved_helpers'] == ['count'], 'unsupported Count ownership changed'
    assert after['excluded']['loaded'] == 1 and not after['excluded']['load_error']


def review():
    capture = json.loads(gzip.decompress((HERE / 'count-fence-qualified.json.gz').read_bytes()))
    raw_bundle = (ROOT / capture['source_bundle']['path']).read_bytes()
    assert hashlib.sha256(raw_bundle).hexdigest() == capture['source_bundle']['sha256']
    bundle = json.loads(gzip.decompress(raw_bundle))
    members = {name: row for name, row in bundle['sources'].items()
               if name.startswith(('perl/', 'specs/', 'conf/', 'tablescript/', 'ebnf/'))}
    assert capture['source_members'] == {name: row['sha256'] for name, row in members.items()}
    old = decode(capture['methods']['activation']); new = decode(capture['methods']['repaired'])
    assert old == subprocess.check_output(['git', 'show', ACTIVATION + ':' + METHOD], cwd=ROOT)
    assert old == decode(members[METHOD]) and new == (ROOT / METHOD).read_bytes()
    for name, row in members.items():
        assert (ROOT / name).read_bytes() == (new if name == METHOD else decode(row)), 'project source drift: ' + name
    original_raw = gzip.decompress((HERE / 'count-fence-original.json.gz').read_bytes())
    assert original_raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + FIXTURE], cwd=ROOT)
    for name, row in capture['inputs'].items():
        assert decode(row) == (original_raw if name == FIXTURE else (ROOT / name).read_bytes())
    frames = {}
    for name, row in capture['commands'].items():
        assert row['exit'] == 0 and decode(row['stderr']) == b''
        assert decode(row['stdout']).splitlines(keepends=True)[-1] == decode(row['frame'])
        frames[name] = json.loads(decode(row['frame']))
        assert frames[name]['module']['sha256'] == capture['methods'][name]['sha256'], 'wrong module image'
    original = json.loads(original_raw); current = json.loads((ROOT / FIXTURE).read_bytes())
    before, after = frames['activation'], frames['repaired']
    check(original, current, before, after)
    rejected = []
    for label in ('old-snapshot', 'extra-cell', 'unsupported-owner'):
        candidate = copy.deepcopy(current); changed = copy.deepcopy(after)
        if label == 'old-snapshot': candidate = copy.deepcopy(original)
        elif label == 'extra-cell': candidate[1]['warnings'] = ['unreviewed']
        else: changed['excluded']['metadata']['unresolved_helpers'] = []
        try: check(original, candidate, before, changed)
        except AssertionError: rejected.append(label)
        else: raise AssertionError('source/ownership corruption admitted: ' + label)
    return dict(result='PASS', same_activation_and_repaired_rows=18, changed_cells=[[0, 'lowered']],
                excluded_native_emitted_and_metadata='identical; Count remains unresolved/non-ready', rejected_controls=rejected,
                limits='Finite retained source/diagnostic comparison. Initial overlay loaded current module and failed its identity check; no activation credit. Shared SDK/cache/OS/transitive closure remains TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
