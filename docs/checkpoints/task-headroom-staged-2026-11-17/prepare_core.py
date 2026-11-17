"""Retain prior instruments and prepare this epoch's capture/reviewer before use."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/task-headroom-perl-ast-2026-11-17')
changes = {}


def revise(leaf, replacements):
    original = (PRIOR / leaf).read_text()
    body = original
    rows = []
    for old, new in replacements:
        count = body.count(old)
        assert count > 0, (leaf, old)
        body = body.replace(old, new)
        rows.append(dict(old=old, new=new, count=count))
    with (BASE / leaf).open('xb') as stream:
        stream.write(body.encode())
    changes[leaf] = dict(template_sha256=hashlib.sha256(original.encode()).hexdigest(),
        actual_sha256=hashlib.sha256(body.encode()).hexdigest(), substitutions=rows)


common = [
    ('08c39a2dfb4be628af24a445a7fdbb98a82e962f', '873003e8901e2b48fd0a289db2540e94bc4d5039'),
    ('TYPE-REFERENCE-BOOK.1.2.23.4.35', 'TYPE-REFERENCE-BOOK.1.2.23.4.36'),
    ('PERL-ACTIONIR-AST-MIGRATION', 'STAGED-LINKED-PARSING'),
    ('[main 08c39a2df]', '[main 873003e89]')]
with tarfile.open(BASE / 'core-composition-before.tar.gz', 'x:gz') as archive:
    for path in (PRIOR / 'capture.py', PRIOR / 'review.py', BASE / 'prepare_core.py'):
        archive.add(path, arcname=str(path), recursive=False)
bindings_code = '''    bindings, binding_paths = [], []
    for record_path in sorted(Path('docs/claims').glob('*.json')):
        for claim in json.loads(record_path.read_bytes())['claims']:
            leg = claim['durability']
            for item in leg.get('inputs', []):
                if item.get('path') == TARGET:
                    assert leg.get('mode') == 'historical', 'live target claim requires preservation before migration'
                    bindings.append(dict(record=str(record_path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
                    binding_paths.append(str(record_path))
    (BASE / 'prior-target-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + chr(10))
'''
revise('capture.py', common + [
    ("PRESSURE = Path('docs/checkpoints/rust-loader-qualification-2026-11-16')", "PRESSURE = Path('docs/checkpoints/perl-literal-open-qualification-2026-11-17')"),
    ("chosen['ids'] == 28 and len(chosen['selected']) == 23 and chosen['proposed_saved_bytes'] == 13074", "chosen['ids'] == 15 and len(chosen['selected']) == 13 and chosen['proposed_saved_bytes'] == 11972"),
    ("    paths = [TARGET,", bindings_code + "    paths = [TARGET,"),
    ("    paths += [str(PRESSURE / 'pressure_repair.py')] + [str(path) for path in (PRESSURE / 'pressure').iterdir() if path.is_file()]", "    paths += binding_paths + [str(BASE / 'prior-target-bindings.json')]\n    paths += [str(PRESSURE / name) for name in ('repair_pressure.py', 'review_pressure.py', 'pressure-before.tar.gz', 'pressure-before-identities.json', 'pressure-after.tar.gz', 'pressure-failed-normal.log.gz', 'pressure-repair.json')]\n    paths += [str(path) for path in BASE.glob('*composition*') if path.is_file()]"),
    ('.linkedspec-data/rust-loader-commit.log', '.linkedspec-data/perl-literal-open-commit-retry.log'),
    ('20261117T000920.514071Z', '20261117T053734.081477Z'),
    ("str(PRESSURE / 'pressure_repair.py'), '--review'", "str(PRESSURE / 'review_pressure.py')"),
    ("assert json.loads(old_pressure)['headroom_bytes'] == 227", "assert json.loads(old_pressure)['result'] == 'PASS'")])
revise('review.py', common + [
    ("            label = b'  Status: `done`' if kind == 'status' else b'  Goal: '\n            altered = after.replace(label, b'  Status: `pending`' if kind == 'status' else b'  Goal: altered ', 1)",
     "            key = manifest['selected'][0]\n            label = 'Status' if kind == 'status' else 'Goal'\n            original = fields(split(after)[1][key])[label]\n            replacement = b'  Status: `pending`\\n' if kind == 'status' else b'  Goal: altered\\n'\n            altered = after.replace(original, replacement, 1)"),
    ("    normal = gzip.decompress((BASE / 'prior-normal.log.gz').read_bytes())", "    bindings = json.loads(before_inputs[str(BASE / 'prior-target-bindings.json')][0])\n    for row in bindings:\n        require(row['mode'] == 'historical', 'prior target claim mode')\n        record = json.loads(before_inputs[row['record']][0])\n        claim = next(c for c in record['claims'] if c['name'] == row['claim'])\n        require(claim['durability']['mode'] == row['mode'] and claim['durability']['revision'] == row['revision'] and row['input'] in claim['durability']['inputs'], 'prior target claim preserved')\n    result['prior_historical_target_bindings'] = len(bindings)\n    normal = gzip.decompress((BASE / 'prior-normal.log.gz').read_bytes())")])
(BASE / 'core-composition.json').write_text(json.dumps(dict(files=changes,
    limits='New source-bound capture and reviewer; old writers are never replayed. Actual template and preparer bodies retained before new instrument use. Outer-first-use/native/per-read/physical closure remains4.2/SESSION5.'), indent=2) + chr(10))
print('Prepared exact new capture/reviewer; no migration performed')
