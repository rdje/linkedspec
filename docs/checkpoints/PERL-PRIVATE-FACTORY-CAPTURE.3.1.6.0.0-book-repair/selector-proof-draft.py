"""Execute the unchanged public classifier on original/current/inverse book text."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
CHECKER = 'tools/check_public_aggregate_selector_surface.py'
OLD = b'an AST `set(array(meta), [])` needs it after the target and shape checks, whereas\nan early primitive result or a mismatched aggregate shape does not reach it.'
NEW = b'a synthetic array-set AST targeting `meta` needs it after the target and shape\nchecks, whereas an early primitive result or a mismatched aggregate shape does\nnot reach it.'
CODE = '''import importlib.util
from pathlib import Path
spec = importlib.util.spec_from_file_location('selector', 'tools/check_public_aggregate_selector_surface.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.ROOT = Path.cwd()
print('classified references:', module.check_exact_references([module.ROOT / 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']))
'''
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
packet = json.loads(gzip.decompress((HERE / 'before.json.gz').read_bytes()))
original = base64.b64decode(packet['inputs'][BOOK]['data'], validate=True)
current = (ROOT / BOOK).read_bytes()
checker = (ROOT / CHECKER).read_bytes()
assert digest(checker) == packet['inputs'][CHECKER]['sha256'], 'classifier changed'
assert original.count(OLD) == 1 and current == original.replace(OLD, NEW, 1), 'book repair exceeded exact prose delta'
assert current.count(NEW) == 1 and current.replace(NEW, OLD, 1) == original
rows = []
for name, body in (('original', original), ('current', current), ('inverse', current.replace(NEW, OLD, 1))):
    with tempfile.TemporaryDirectory(prefix='selector-book-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        files = {BOOK: body, CHECKER: checker}
        for path, raw in files.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        command = ['python3', '-c', CODE]
        result = subprocess.run(command, cwd=supplied, capture_output=True,
                                env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'))
        row = {'name': name, 'command': command, 'returncode': result.returncode,
               'stdout_base64': base64.b64encode(result.stdout).decode(),
               'stderr_base64': base64.b64encode(result.stderr).decode(),
               'inputs': {p: digest(raw) for p, raw in files.items()},
               'unchanged': all((supplied / p).read_bytes() == raw for p, raw in files.items())}
        assert row['unchanged']
        if name == 'current':
            assert result.returncode == 0 and result.stdout == b'classified references: 0\n' and not result.stderr
        else:
            assert result.returncode != 0 and b"presents 'array(meta)' without explicit removed/rejected/migrated historical context" in result.stderr
        rows.append(row)
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'rows': rows, 'scope': 'Existing classifier on this exact private-AST chapter; original and exact inverse reject, prose repair has zero selector mentions. No full public inventory/runtime/capability admission is inferred; canonical CI separately composes those checks.'}
target = HERE / 'selectors.json'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot classifier capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'classifier proof drift'
print('Unchanged selector classifier PASS: original RED/current GREEN/exact inverse RED; chapter has zero selectors')
