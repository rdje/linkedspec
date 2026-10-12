"""One-shot before/after public classifier and actual private-label examples."""
import base64
import contextlib
import gzip
import hashlib
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
CHECKER = 'tools/check_public_aggregate_selector_surface.py'
HELPER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
OLD = 'de02b83a1a794370b4071bb53677ab675745acc2'
assert sys.argv[1:] in (['before'], ['after'])
phase = sys.argv[1]
target = ROOT / (PREFIX + 'document-' + phase + '.json')
assert not target.exists(), 'one-shot documentation capture'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
inputs = {}
def retain(path, raw=None):
    inputs[path] = (ROOT / path).read_bytes() if raw is None else raw

retain(PREFIX + 'document.py')
retain(PREFIX + 'labels.pl')
retain(CHECKER)
spec = importlib.util.spec_from_file_location('public_surface', ROOT / CHECKER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
paths = module.public_markdown_paths()
assert len(paths) == module.EXPECTED_PUBLIC_FILE_COUNT == 70
for path in paths:
    retain(path.relative_to(ROOT).as_posix())
stdout, stderr = io.StringIO(), io.StringIO()
try:
    with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
        count = module.check_exact_references(paths)
    classifier = {'returncode': 0, 'count': count}
except SystemExit as error:
    classifier = {'returncode': error.code, 'count': None}
classifier.update(stdout=stdout.getvalue(), stderr=stderr.getvalue())
if phase == 'before':
    assert classifier['returncode'] != 0 and 'actionir-lowering-mental-model.md:1547' in classifier['stderr']
else:
    assert classifier == {'returncode': 0, 'count': 40, 'stdout': '', 'stderr': ''}
    assert module.check_migration_contrast_mutations(module.read(module.MIGRATION_SOURCE)) == 11

native = []
if phase == 'before':
    old = subprocess.check_output(['git', 'show', OLD + ':' + HELPER], cwd=ROOT)
    retain('historical/' + HELPER, old)
    retain(HELPER)
    def body(raw):
        return raw.split(b'sub _uniform_binding_target_symbol {', 1)[1].split(b'\nsub ', 1)[0]
    assert body(old).replace(b'*)\\s*\\)$/o;', b'*)\\s*\\)$/;') == body(inputs[HELPER]), 'sole interpolated regex flag repair'
    with tempfile.TemporaryDirectory(prefix='private-labels-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        old_path = supplied / 'LinkedSpec/ActionIR/MethodLowering.pm'
        old_path.parent.mkdir(parents=True)
        old_path.write_bytes(old)
        for version in ('old', 'current'):
            for order in (('bag', 'record'), ('record', 'bag')):
                command = ['perl'] + (['-I', str(supplied)] if version == 'old' else []) + ['-Iperl', PREFIX + 'labels.pl', *order]
                result = subprocess.run(command, cwd=ROOT, capture_output=True)
                row = {'version': version, 'order': order, 'returncode': result.returncode,
                    'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode()}
                native.append(row)
                assert result.returncode == 0 and not result.stderr, row
                observation = json.loads(result.stdout)
                assert len(observation['rows']) == 10
                expected = ['item', 'item', 'item', None, None, 'item', None, 'item', 'item', None]
                calls = [1, 1, 1, 0, 0, 1, 0, 0, 1, 1]
                if version == 'current':
                    assert [r['value'] for r in observation['rows']] == expected
                    assert [len(r['calls']) for r in observation['rows']] == calls
                else:
                    assert observation['rows'][0]['value'] == 'item' and observation['rows'][1]['value'] is None
                for path in observation['loaded_files']:
                    absolute = Path(path).resolve()
                    if absolute == old_path:
                        continue
                    try:
                        relative = absolute.relative_to(ROOT).as_posix()
                    except ValueError:
                        continue  # Read-only operating-system Perl distribution; no runtime portability claim.
                    retain(relative)
else:
    previous = json.loads((ROOT / (PREFIX + 'document-before.json')).read_bytes())
    assert previous['producer_sha256'] == sha(Path(__file__).read_bytes())
    native = previous['native']

capsule = gzip.compress(json.dumps({p: base64.b64encode(raw).decode() for p, raw in sorted(inputs.items())}, sort_keys=True).encode(), mtime=0)
capsule_path = PREFIX + 'document-' + phase + '-inputs.json.gz'
(ROOT / capsule_path).write_bytes(capsule)
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'phase': phase, 'classifier': classifier, 'public_files': [p.relative_to(ROOT).as_posix() for p in paths],
    'inputs': {p: sha(raw) for p, raw in sorted(inputs.items())}, 'capsule': capsule_path,
    'capsule_sha256': sha(capsule), 'native': native,
    'scope': 'Unchanged primary public documentation classifier, complete70 public file bytes, local before RED/after40 classified references; current private labels have20 native rows and two old cached-second-target REDs. Project-loaded native module bytes are retained; system Perl distribution is reused read-only. This does not claim a new runtime or complete composed public admission.'}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Documentation', phase, 'PASS: unchanged classifier; complete70 files;', len(native), 'retained native processes')
