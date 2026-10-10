"""Render a complete supplied book and exercise missing/changed source controls."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-'
CONFIG = 'docs/linkedspec-book/book.toml'
SOURCE = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
SUMMARY = 'docs/linkedspec-book/src/SUMMARY.md'
MARKER = 'This controlled fixture does not describe current authored syntax.'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

assert not (ROOT / (PREFIX + 'book.json')).exists(), 'one-shot capture'
entries = subprocess.check_output(['git', 'ls-files', '--stage', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
files, modes = {}, {}
for entry in filter(None, entries):
    header, p = entry.split('\t')
    mode, blob, stage = header.split()
    if p != CONFIG and not p.startswith('docs/linkedspec-book/src/'):
        continue
    assert mode in ('100644', '100755') and stage == '0'
    files[p] = (ROOT / p).read_bytes()
    modes[p] = int(mode, 8) & 0o777
assert MARKER.encode() in files[SOURCE]

rows = []
for name in ('final', 'missing-summary', 'changed-chapter'):
    selected = dict(files)
    if name == 'missing-summary':
        del selected[SUMMARY]
    elif name == 'changed-chapter':
        selected[SOURCE] = selected[SOURCE].replace(MARKER.encode(), b'', 1)
    with tempfile.TemporaryDirectory(prefix='complete-book-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        for p, raw in selected.items():
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(modes[p])
        output = supplied / 'output'
        command = [os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'), 'build', 'docs/linkedspec-book', '-d', 'output']
        # Published CLI destination is tested against supplied/output; retain actual locations.
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        environment = {k: v for k, v in os.environ.items() if not k.startswith('MDBOOK_')}
        result = subprocess.run(command, cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        target = output / 'architecture/structured-format-program.html'
        html = target.read_bytes() if target.is_file() else b''
        observed = {p.relative_to(supplied).as_posix(): digest(p.read_bytes()) for p in (supplied / 'docs/linkedspec-book').rglob('*') if p.is_file()}
        inputs = {p: digest(raw) for p, raw in sorted(selected.items())}
        row = {'name': name, 'command': command,
               'returncode': result.returncode, 'inputs': inputs, 'modes': {p: modes[p] for p in selected},
               'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode(),
               'html_base64': base64.b64encode(html).decode(), 'marker_present': MARKER.encode() in html,
               'unchanged': observed == inputs,
               'output_locations': [p.relative_to(supplied).as_posix() for p in supplied.rglob('structured-format-program.html') if p.is_file()]}
        rows.append(row)
        (ROOT / (PREFIX + 'book.json')).write_text(json.dumps({'result': 'pending', 'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes())}, indent=2) + '\n')
        assert row['unchanged']
        if name == 'final':
            assert result.returncode == 0 and row['marker_present']
        elif name == 'missing-summary':
            assert result.returncode != 0 and b'SUMMARY' in result.stderr
        else:
            assert result.returncode == 0 and not row['marker_present']
report = {'result': 'PASS', 'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Complete tracked book configuration/source population and current chapter overlay, supplied on the repository volume. Read-only mdBook executable reused. Changed-chapter product RED is an absent rendered marker despite command exit0; missing-summary command fails. No cross-toolchain byte-identical HTML claim.'}
(ROOT / (PREFIX + 'book.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Complete supplied book PASS:', len(files), 'inputs; missing-summary command RED and changed-chapter rendered-marker RED retained.')
