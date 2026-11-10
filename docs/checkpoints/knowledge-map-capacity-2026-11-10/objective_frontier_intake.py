"""Inventory the complete historical source population before further admission."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'objective-frontier-intake.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row
    return raw


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


assert not OUTPUT.exists(), 'one-shot qualified population intake'
intake = json.loads(gzip.decompress((HERE / 'objective-image-intake.json.gz').read_bytes()))
audit = types.ModuleType('original_population_audit')
audit.__file__ = str(ROOT / 'tests/language-readiness/verify_objectives.py')
exec(compile(decode(intake['inputs']['tests/language-readiness/verify_objectives.py']), audit.__file__, 'exec'), audit.__dict__)
read = lambda name: (ROOT / name).read_bytes()
images = audit.current_image_admissions(read)
effective, _ = audit.phase0_fixture_reader(read, images)
sources, checkpoints = {}, {}
for suffix in audit.MILESTONES:
    name = f'docs/checkpoints/{audit.PREFIX}{suffix}-verification.json'
    raw = read(name); record = json.loads(raw); checkpoints[name] = packet(raw)
    revision = audit.producing_commit(name)
    hashes = record['audit']['current_source_hashes'] if 'audit' in record else {row['path']: row['current'] for row in record['source_hash_comparisons']}
    for path, expected in hashes.items():
        sources[path] = dict(historical_sha256=expected, historical_revision=revision, milestone=suffix)
functions = {'tools/run_ci_local.sh': audit.verify_governance_evolution,
             'tools/test_perl_project_data_storage.sh': audit.verify_perl_storage_evolution,
             't/phase0_regression.t': audit.verify_signature_regression_evolution,
             'perl/LinkedSpec/ActionIR/Contracts.pm': audit.verify_boundary_contract_evolution,
             'tools/check_public_aggregate_selector_surface.py': audit.verify_selector_governance_evolution}
rows = []
for name, metadata in sorted(sources.items()):
    current = effective(name); actual = hashlib.sha256(current).hexdigest()
    row = dict(path=name, **metadata, current=packet(current))
    if name in images.rows:
        row['classification'] = 'existing-successor' if actual != images.rows[name]['current_sha256'] else 'preserved-existing-image'
    elif actual == metadata['historical_sha256']:
        row['classification'] = 'historical-bytes-unchanged'
    elif name.startswith('docs/') and name.endswith('.md'):
        row['classification'] = 'documentation-evolution'
    else:
        fn = functions.get(name)
        if name == audit.DART_SIGNED_SOURCE: fn = audit.verify_dart_signed_evolution
        if name in audit.RUST_NUMERIC_IMAGES: fn = audit.verify_rust_numeric_evolution
        if name == audit.RUST_SIGNED_SOURCE: fn = audit.verify_rust_signed_evolution
        if fn:
            try:
                if name in audit.RUST_NUMERIC_IMAGES or name == 'tools/test_perl_project_data_storage.sh':
                    result = fn(name, current, metadata['historical_sha256'], read=read)
                else:
                    result = fn(name, current, metadata['historical_sha256'])
            except ValueError as error:
                row['existing_inverse_rejection'] = str(error)
            else:
                row.update(classification='existing-exact-inverse', inverse=result)
        if 'classification' not in row:
            prior = git('show', metadata['historical_revision'] + ':' + name)
            assert hashlib.sha256(prior).hexdigest() == metadata['historical_sha256']
            assert current == git('show', intake['activation_commit'] + ':' + name), 'uncommitted source requires its own exact inverse: ' + name
            tree = git('ls-tree', '-z', intake['activation_commit'], '--', name)
            assert tree.endswith(b'\0') and tree.count(b'\0') == 1
            header, actual_name = tree[:-1].split(b'\t'); mode, kind, blob = header.decode().split()
            assert actual_name.decode() == name and mode in ('100644', '100755') and kind == 'blob'
            row.update(classification='first-exact-image-required', historical=packet(prior),
                       current_git_entry=dict(mode=mode, kind=kind, blob=blob),
                       accepted_change_history=git('log', '--format=%H %s', metadata['historical_revision'] + '..' + intake['activation_commit'], '--', name).decode().splitlines())
            assert row['accepted_change_history']
    rows.append(row)
report = dict(activation_commit=intake['activation_commit'], rows=rows, checkpoints=checkpoints,
              producer=packet(Path(__file__).read_bytes()), original_auditor=intake['inputs']['tests/language-readiness/verify_objectives.py'],
              limits='Complete finite historical source-hash population from the retained milestone records; effective Phase0 adapter and existing exact inverse classifications. Source identity only, not new runtime/objective compatibility or full native/transitive custody.')
OUTPUT.write_bytes(gzip.compress(json.dumps(report, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
assert json.loads(gzip.decompress(OUTPUT.read_bytes())) == report
print(json.dumps(dict(result='PASS', classifications={kind: [row['path'] for row in rows if row['classification'] == kind]
                      for kind in sorted({row['classification'] for row in rows})}), sort_keys=True))
