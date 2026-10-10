"""Render a complete supplied book and exercise missing/changed source controls."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-'
CONFIG = 'docs/linkedspec-book/book.toml'
SOURCE = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
SUMMARY = 'docs/linkedspec-book/src/SUMMARY.md'
MARKER = 'Generalized-return required callbacks now have separate private capture boundaries.'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def retain(report):
    raw = (json.dumps(report, indent=2) + '\n').encode()
    envelope = {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': digest(raw),
                'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode(),
                'producer_sha256': digest(Path(__file__).read_bytes())}
    (ROOT / (PREFIX + 'book.json')).write_text(json.dumps(envelope, indent=2) + '\n')

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
assert len(files) == 57 and MARKER.encode() in files[SOURCE]
book_paths = set(files)
tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0'))
pending = list(files)
while pending:
    relative = pending.pop()
    for spelling in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', files[relative]):
        name = spelling.decode().split(':', 1)[0]
        path = ((ROOT / relative).parent / name).resolve().relative_to(ROOT).as_posix()
        assert path in tracked and (ROOT / path).is_file(), 'tracked local include: ' + path
        if path not in files:
            files[path] = (ROOT / path).read_bytes()
            modes[path] = (ROOT / path).stat().st_mode & 0o777
            pending.append(path)
include_paths = set(files) - book_paths
assert 'examples/integration/word.spec' in include_paths

rows = []
for name in ('final', 'missing-summary', 'changed-chapter', 'missing-include'):
    selected = dict(files)
    if name == 'missing-summary':
        del selected[SUMMARY]
    elif name == 'changed-chapter':
        selected[SOURCE] = selected[SOURCE].replace(MARKER.encode(), b'', 1)
    elif name == 'missing-include':
        del selected['examples/integration/word.spec']
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
        target = output / 'dsl/actionir-lowering-mental-model.html'
        html = target.read_bytes() if target.is_file() else b''
        observed = {p: digest((supplied / p).read_bytes()) for p in selected}
        inputs = {p: digest(raw) for p, raw in sorted(selected.items())}
        row = {'name': name, 'command': command,
               'returncode': result.returncode, 'inputs': inputs, 'modes': {p: modes[p] for p in selected},
               'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode(),
               'html_base64': base64.b64encode(html).decode(), 'marker_present': MARKER.encode() in html,
               'unchanged': observed == inputs,
               'output_locations': [p.relative_to(supplied).as_posix() for p in supplied.rglob('actionir-lowering-mental-model.html') if p.is_file()]}
        rows.append(row)
        retain({'result': 'pending', 'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes())})
        assert row['unchanged']
        if name == 'final':
            assert result.returncode == 0 and row['marker_present'] and b'ERROR' not in result.stderr
        elif name == 'missing-summary':
            assert result.returncode != 0 and b'SUMMARY' in result.stderr
        elif name == 'changed-chapter':
            assert result.returncode == 0 and not row['marker_present'] and b'ERROR' not in result.stderr
        else:
            assert result.returncode == 0 and b'Error updating' in result.stderr and b'examples/integration/word.spec' in result.stderr
report = {'result': 'PASS', 'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'book_sources': len(book_paths), 'include_sources': len(include_paths),
          'scope': 'Complete tracked book configuration/source and recursive include population and current chapter overlay, supplied on the repository volume. Read-only mdBook executable reused. Changed-chapter product RED is an absent rendered marker despite command exit0; missing-summary command fails. No cross-toolchain byte-identical HTML claim.'}
retain(report)
print('Complete supplied book PASS:', len(files), 'inputs; missing-summary command, changed-chapter rendered-marker and missing-include error REDs retained.')
