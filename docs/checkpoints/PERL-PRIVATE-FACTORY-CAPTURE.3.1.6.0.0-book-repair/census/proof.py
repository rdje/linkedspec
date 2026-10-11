"""Source-bound public census, exact historical additions and actual count controls."""
import base64
import gzip
import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
CHECKER = 'tools/check_public_aggregate_selector_surface.py'
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
GUIDE = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
BASE = '268891fdf948b1ccf875087416b62100e0ddc059'
CODE = '''import importlib.util
from pathlib import Path
spec = importlib.util.spec_from_file_location('surface', 'tools/check_public_aggregate_selector_surface.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.ROOT = Path.cwd()
paths = module.public_markdown_paths()
if len(paths) != module.EXPECTED_PUBLIC_FILE_COUNT:
    module.fail('public markdown inventory mismatch')
mutations = module.check_migration_contrast_mutations(module.read(module.MIGRATION_GUIDE))
count = module.check_exact_references(paths)
if count != module.EXPECTED_CLASSIFIED_REFERENCE_COUNT:
    module.fail(f'classified reference inventory has {count} occurrences, expected {module.EXPECTED_CLASSIFIED_REFERENCE_COUNT}')
module.check_stale_status(paths)
module.require_public_anchors()
module.check_capability_admission()
print(f'Public documentation PASS: files={len(paths)} historical={count} current=0 migration_controls={mutations}')
'''
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
spec = importlib.util.spec_from_file_location('surface', ROOT / CHECKER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.ROOT = ROOT
paths = [p.relative_to(ROOT).as_posix() for p in module.public_markdown_paths()]
assert len(paths) == 70
current = {p: (ROOT / p).read_bytes() for p in paths}
current['capability_conformance/manifest.json'] = (ROOT / 'capability_conformance/manifest.json').read_bytes()
current[CHECKER] = (ROOT / CHECKER).read_bytes()
before = json.loads(gzip.decompress((HERE / 'before.json.gz').read_bytes()))
assert before['producer_sha256'] == digest((HERE / 'capture-before.py').read_bytes())
original_checker = base64.b64decode(before['mutable_before'][CHECKER], validate=True)
old = b'EXPECTED_CLASSIFIED_REFERENCE_COUNT = 36\n'
new = b'EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\n'
assert original_checker.count(old) == 1 and current[CHECKER] == original_checker.replace(old, new, 1), 'foreign classifier change'

def locations(text):
    found = {(m.start(), m.end()) for m in module.EXACT_SELECTOR.finditer(text)}
    for c in re.finditer(r'`([^`\n]+)`', text):
        found.update((c.start(1)+m.start(), c.start(1)+m.end()) for m in module.CODE_SELECTOR.finditer(c.group(1)))
    for c in re.finditer(r'```[^\n]*\n(.*?)```', text, re.S):
        found.update((c.start(1)+m.start(), c.start(1)+m.end()) for m in module.CODE_SELECTOR.finditer(c.group(1)))
    return [{'line': text.count('\n', 0, a)+1, 'spelling': text[a:b],
             'context': module.sentence_at(text, a, b)} for a,b in sorted(found)]

history = {}
for path in paths:
    tracked = subprocess.run(['git', 'ls-files', '--error-unmatch', '--', path], cwd=ROOT, capture_output=True)
    if tracked.returncode:
        # Published RGX README is a read-only integration document, never implementation.
        assert path == 'rgx/README.md' and not locations(current[path].decode())
        continue
    history[path] = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert len(history) == 69
old_rows = {p: locations(raw.decode()) for p,raw in history.items()}
new_rows = {p: locations(raw.decode()) for p,raw in current.items() if p in paths}
assert sum(map(len, old_rows.values())) == 36 and sum(map(len, new_rows.values())) == 40
changes = {p: [len(old_rows[p]), len(new_rows[p])] for p in history if len(old_rows[p]) != len(new_rows[p])}
assert changes == {BOOK: [0, 3], GUIDE: [11, 12]}, 'unexpected historical census delta'
assert [r['spelling'] for r in new_rows[BOOK]] == ['array(items)', 'hash(meta)', 'hash(meta)']
assert new_rows[GUIDE][0]['spelling'] == 'array(Top)'
assert all(module.NEGATIVE_CONTEXT.search(r['context']) for r in new_rows[BOOK] + new_rows[GUIDE][:1])
rows = []
for name in ('current', 'original-count', 'missing-reference', 'unclassified-example'):
    supplied_files = dict(current)
    if name == 'original-count':
        supplied_files[CHECKER] = original_checker
    elif name == 'missing-reference':
        supplied_files[BOOK] = supplied_files[BOOK].replace(b'array(items)', b'items', 1)
    elif name == 'unclassified-example':
        supplied_files[BOOK] += b'\n\nAn example is `array(new_binding)`.\n'
    with tempfile.TemporaryDirectory(prefix='selector-census-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path,raw in supplied_files.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        result = subprocess.run(['python3', '-c', CODE], cwd=supplied, capture_output=True,
                                env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'))
        row = {'name': name, 'command': ['python3', '-c', CODE], 'returncode': result.returncode,
               'stdout_base64': base64.b64encode(result.stdout).decode(),
               'stderr_base64': base64.b64encode(result.stderr).decode(),
               'inputs': {p: digest(raw) for p,raw in supplied_files.items()},
               'unchanged': all((supplied / p).read_bytes() == raw for p,raw in supplied_files.items())}
        assert row['unchanged']
        if name == 'current':
            assert result.returncode == 0 and result.stdout == b'Public documentation PASS: files=70 historical=40 current=0 migration_controls=11\n' and not result.stderr
        else:
            reason = {'original-count': b'40 occurrences, expected 36',
                      'missing-reference': b'39 occurrences, expected 40',
                      'unclassified-example': b"presents 'array(new_binding)' without explicit"}[name]
            assert result.returncode != 0 and reason in result.stderr
        rows.append(row)
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'inputs': {p: {'sha256': digest(raw), 'data': base64.b64encode(raw).decode()} for p,raw in current.items()},
          'parent_history': {p: {'sha256': digest(raw), 'data': base64.b64encode(raw).decode()} for p,raw in history.items()},
          'base': BASE, 'changes': changes, 'current_locations': new_rows, 'historical_locations': old_rows, 'rows': rows,
          'scope': 'Complete current70 public documents plus manifest/checker;69 parent-owned historical documents at268891fdf have36 references and current70 have40. Read-only current RGX published README has0; historical submodule document bytes are not reconstructed. Exactly four rejected examples explain the parent-source delta. Only expected count changes; classifiers/migration11 remain exact. No composed runtime/capability execution admission is inferred.'}
raw = (json.dumps(report, indent=2) + '\n').encode()
target = HERE / 'proof.json.gz'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot census proof'
    target.write_bytes(gzip.compress(raw, mtime=0))
else:
    assert gzip.decompress(target.read_bytes()) == raw, 'census proof drift'
print('Public census PASS: current70/40/0; parent69/36; exact additions3+1; migration11; three actual RED controls')
