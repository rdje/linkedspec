"""Retain the failed candidate and inventory exact historical source boundaries."""
import copy
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
REVISION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')


def git(*args):
    return subprocess.check_output(['git', *args], env=ENV)


assert git('rev-parse', 'HEAD').decode().strip() == REVISION
raw_diff = git('diff', '--cached', '--binary', '--full-index')
(OUT / 'failed-candidate.diff.gz').write_bytes(gzip.compress(raw_diff, mtime=0))
names = git('diff', '--cached', '--name-only', '-z').decode().split('\0')[:-1]
assert len(names) == 267
(OUT / 'failed-candidate.json').write_text(json.dumps(dict(head=REVISION, staged_paths=names,
    staged_binary_diff_sha256=hashlib.sha256(raw_diff).hexdigest(), reported_exec_exit=1,
    canonical_log='.linkedspec-data/ram-host-size-canonical.log',
    scope='The actual failed canonical candidate; ownership edits remain unstaged. No receipt/full-pass credit.'), indent=2) + '\n')
log = Path('.linkedspec-data/ram-host-size-canonical.log').read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in log
assert b'ValueError: unreviewed current source image: dart/lib/src/runtime/interpreter.dart' in log
(OUT / 'canonical-first.log.gz').write_bytes(gzip.compress(log, mtime=0))

identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as packed:
    def retain(path):
        path = Path(path)
        name = path.as_posix()
        body = path.read_bytes()
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        if name not in identities:
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=name, recursive=False)
        else:
            assert hashlib.sha256(body).hexdigest() == identities[name]['sha256']
        return body

    for name in [Path(__file__).relative_to(ROOT), BASE / 'PLAN.md',
                 'tools/historical_objective_images.py', 'tools/test_historical_objective_images.py',
                 'tests/language-readiness/verify_objectives.py',
                 'docs/knowledge/three-objective-language-readiness.md',
                 'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
                 'tools/host_ram_usage.sh', 'tools/ram_guard.sh', 'tools/test_ram_guard.py',
                 'doctrine/project_data_storage/python_entrypoints.json',
                 'doctrine/project_data_storage/python_temporary_owners.json',
                 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.14.json']:
        retain(name)
    spec = importlib.util.spec_from_file_location('resource_image_audit', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    audit.read_relative = retain
    sources = {}
    for suffix in audit.MILESTONES:
        path = f'docs/checkpoints/{audit.PREFIX}{suffix}-verification.json'
        raw = retain(path)
        record = json.loads(raw)
        producing = audit.producing_commit(path)
        assert git('show', producing + ':' + path) == raw
        if 'audit' in record:
            current = record['audit']['current_source_hashes']
        else:
            current = {row['path']: row['current'] for row in record['source_hash_comparisons']}
        sources.update({name: dict(sha256=value, milestone=suffix) for name, value in current.items()})
    # Capture the complete actual current source set before classifying it.
    for name in sources:
        entry = git('ls-tree', '-z', REVISION, '--', name).split(b'\0')
        assert len(entry) == 2 and entry[0], 'missing parent-repository source:' + name
        header, path = entry[0].split(b'\t')
        mode, kind, blob = header.decode().split()
        assert path.decode() == name and mode in ('100644', '100755') and kind == 'blob'
        retain(name)
    images = audit.current_image_admissions(retain)
    fixture_read, fixture_evolution = audit.phase0_fixture_reader(retain, images)
    image_rows = {row['path']: row for row in images.report()}
    rows = []
    inverse = {
        'tools/run_ci_local.sh': audit.verify_governance_evolution,
        'tools/test_perl_project_data_storage.sh': audit.verify_perl_storage_evolution,
        't/phase0_regression.t': audit.verify_signature_regression_evolution,
        'perl/LinkedSpec/ActionIR/Contracts.pm': audit.verify_boundary_contract_evolution,
        'tools/check_public_aggregate_selector_surface.py': audit.verify_selector_governance_evolution,
    }
    for name, source in sorted(sources.items()):
        actual = retain(name)
        effective = fixture_read(name)
        observation = dict(path=name, historical_sha256=source['sha256'], actual_sha256=hashlib.sha256(actual).hexdigest(),
            effective_sha256=hashlib.sha256(effective).hexdigest(), bytes=len(actual),
            current_equals_activation=actual == git('show', REVISION + ':' + name))
        if name in image_rows:
            row = image_rows[name]
            observation.update(admitted=row, classification='preserved-image' if hashlib.sha256(effective).hexdigest() == row['current_sha256'] else 'changed-image')
        else:
            admitted = images.predecessor(name, effective)
            if hashlib.sha256(admitted).hexdigest() == source['sha256']:
                observation['classification'] = 'historical-exact'
            elif name.startswith('docs/') and name.endswith('.md'):
                observation['classification'] = 'documentation-evolution'
            else:
                try:
                    if name == audit.DART_SIGNED_SOURCE:
                        detail = audit.verify_dart_signed_evolution(name, admitted, source['sha256'])
                    elif name in audit.RUST_NUMERIC_IMAGES:
                        detail = audit.verify_rust_numeric_evolution(name, admitted, source['sha256'], read=retain)
                    elif name == audit.RUST_SIGNED_SOURCE:
                        detail = audit.verify_rust_signed_evolution(name, admitted, source['sha256'])
                    elif name in inverse:
                        detail = inverse[name](name, admitted, source['sha256'])
                    else:
                        raise ValueError('no registered executable inverse')
                except ValueError as error:
                    observation.update(classification='unadmitted-executable', refusal=str(error))
                else:
                    observation.update(classification='preserved-inverse', inverse=detail)
        rows.append(observation)
    # Resolve all additional prospective bindings against the original accepted
    # records, applying only the completed4.3 mode/revision qualification.
    original_query = Path('docs/checkpoints/ram-host-size-preflight-2026-11-12/publication-inputs/inputs-before-query.tar.gz')
    retain(original_query)
    with tarfile.open(original_query) as source:
        records = {member.name: json.loads(source.extractfile(member).read())
                   for member in source if member.name.startswith('docs/claims/')}
    changed = records['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json']
    leg = next(row for row in changed['claims'] if row['name'] == 'backend-task-evidence-path-scope')['durability']
    leg.update(mode='historical', revision=REVISION)
    assert changed == json.loads(retain('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'))
    targets = ['tools/historical_objective_images.py', 'tools/test_historical_objective_images.py',
        'tests/language-readiness/verify_objectives.py', 'docs/knowledge/three-objective-language-readiness.md',
        'tests/language-readiness/current-source-images.json.gz',
        'tests/language-readiness/current-source-successors.json.gz',
        'tests/language-readiness/additional-source-images.json.gz']
    hits = [dict(record=name, claim=claim['name'], path=item['path'], mode=claim['durability']['mode'],
                 revision=claim['durability'].get('revision'), sha256=item['sha256'])
            for name, record in records.items() for claim in record['claims']
            if claim['durability']['status'] == 'checked' for item in claim['durability']['inputs'] if item['path'] in targets]
    bindings = dict(targets=targets, accepted_records=len(records), intersections=hits,
                    live_intersections=[row for row in hits if row['mode'] == 'live'])

with tarfile.open(OUT / 'inputs-before-use.tar.gz') as packed:
    assert set(packed.getnames()) == identities.keys()
    for member in packed:
        assert hashlib.sha256(packed.extractfile(member).read()).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
(OUT / 'source-inventory.json').write_text(json.dumps(dict(activation_commit=REVISION, effective_images=image_rows,
    historical_sources=rows, fixture_evolution=fixture_evolution,
    scope='Source identity/inverse classification only; no new runtime execution, historical hash refresh or feature admission.'), indent=2, sort_keys=True) + '\n')
(OUT / 'bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(historical_sources=len(rows), effective_images=len(image_rows),
    changed_images=[row['path'] for row in rows if row['classification'] == 'changed-image'],
    unadmitted_executables=[row for row in rows if row['classification'] == 'unadmitted-executable'],
    live_bindings=bindings['live_intersections']), indent=2))
