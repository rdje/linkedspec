"""Readonly original37 preservation plus activation SDK/source-input qualification."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import runpy
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-source-perl-2026-11-07')
PRIOR = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
proof = runpy.run_path(str(ROOT / BASE / 'review.py'))


def main():
    proof['main']()
    directory = ROOT / BASE / 'preserved_results'
    assert (directory / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((directory / 'stderr.log.gz').read_bytes()) == b''
    identities = json.loads((directory / 'input-identities.json').read_bytes())
    inputs = {}
    with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            assert member.isfile() and member.name not in inputs
            raw = archive.extractfile(member).read()
            expected = identities[member.name]
            assert len(raw) == expected['bytes'] and hashlib.sha256(raw).hexdigest() == expected['sha256']
            assert member.mode & 0o777 == expected['mode']
            inputs[member.name] = raw
    assert inputs.keys() == identities.keys()
    before = proof['recover']('before')[0]
    after = proof['recover']('after')[0]
    git_tar = subprocess.check_output(['git', 'archive', '--format=tar', proof['ACTIVATION'], 'perl',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'], cwd=ROOT)
    git_inputs = {}
    with tarfile.open(fileobj=io.BytesIO(git_tar)) as archive:
        for member in archive:
            if member.isdir():
                continue
            assert member.isfile()
            git_inputs[member.name] = archive.extractfile(member).read()
            assert before[member.name] == git_inputs[member.name], 'activation-sdk-input'
            assert inputs[member.name] == after[member.name], 'preservation-sdk-input'
    selected = {p for p in before if p.startswith(('perl/', 'specs/'))}
    assert git_inputs.keys() == selected
    fixture = 'tests/fixtures/array_transform_result_guard_cases.json'
    cases = json.loads(inputs[fixture])
    assert len(cases) == 37 and inputs[fixture] == (ROOT / fixture).read_bytes()
    original = gzip.decompress((ROOT / PRIOR / 'preflight/stdout.log.gz').read_bytes())
    current = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
    frames = proof['frames']
    old_rows = frames(original, 'ARRAY_TRANSFORM_PERL')
    rows = frames(current, 'ARRAY_TRANSFORM_PERL')
    supplied = frames(current, 'ARRAY_TRANSFORM_INPUT')
    assert list(rows) == list(supplied) == [c['id'] for c in cases]
    red = {name + '_' + route + '_hash_guard' for name in proof['ROLES'] for route in ('free', 'receiver')} | {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
    for case in cases:
        identifier = case['id']
        row = rows[identifier]
        assert proof['same'](proof['projection'](row), proof['projection'](old_rows[identifier])), 'original-public-projection'
        if identifier in red:
            assert isinstance(row['native_error'], dict)
            if '_receiver_hash_guard' in identifier:
                assert row['loaded'] == 0 and 'fresh_error' not in row
            else:
                assert isinstance(row['fresh_error'], dict) and 'Not a HASH reference' in row['native_error']['detail']
        for field, payload, suffix in (('module_input', 'emitted', 'pm'), ('handler_input', 'handler', 'handler.pl')):
            record = row[field]
            assert record['path'] == str(BASE / 'preserved_results' / (identifier + '.' + suffix + '.gz'))
            raw = gzip.decompress((ROOT / record['path']).read_bytes())
            assert len(raw) == record['bytes'] and hashlib.sha256(raw).hexdigest() == record['sha256']
            assert record['sha256'] == old_rows[identifier][field]['sha256'], 'original-artifact-drift'
            assert raw.decode() == supplied[identifier][payload]
        assert supplied[identifier]['source'] == case['source']
    print(json.dumps(dict(result='PASS', preservation='unchanged37/19 expected result RED/18 healthy; all37 actual module/handler pairs and public projections exact',
                          input_boundary='all captured own Perl/three grammars equal activation Git before source edit; later SDK differs only by tested owner',
                          limit='Result composition78.1.1 remains pending; no complete native/transitive/context admission'), indent=2))


if __name__ == '__main__':
    main()
