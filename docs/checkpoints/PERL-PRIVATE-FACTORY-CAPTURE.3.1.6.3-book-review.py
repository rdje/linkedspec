"""Check the entire supplied book population and actual rendered controls."""
import base64
import gzip
import re
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3-'
CONFIG = 'docs/linkedspec-book/book.toml'
CHAPTER = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
SUMMARY = 'docs/linkedspec-book/src/SUMMARY.md'
MARKER = b'Required hash receiver callbacks retain'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
entries = subprocess.check_output(['git', 'ls-files', '--stage', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
files, modes = {}, {}
for entry in filter(None, entries):
    header, path = entry.split('\t')
    mode, blob, stage = header.split()
    if path != CONFIG and not path.startswith('docs/linkedspec-book/src/'):
        continue
    assert mode in ('100644', '100755') and stage == '0'
    files[path] = (ROOT / path).read_bytes()
    modes[path] = int(mode, 8) & 0o777
assert len(files) == 57 and files[CHAPTER].count(MARKER) == 1
book_paths = set(files)
# Independently enumerate the local recursive include graph, including anchors.
seen = set()
while set(files) - seen:
    relative = sorted(set(files) - seen)[0]
    seen.add(relative)
    for directive in re.findall(rb'\{\{#include\s+([^}]+)\}\}', files[relative]):
        spelling = directive.strip().decode().split(':')[0]
        path = ((ROOT / relative).parent / spelling).resolve().relative_to(ROOT).as_posix()
        if path not in files:
            assert subprocess.run(['git', 'ls-files', '--error-unmatch', '--', path], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
            files[path] = (ROOT / path).read_bytes()
            modes[path] = (ROOT / path).stat().st_mode & 0o777
assert len(files) == 89 and len(set(files) - book_paths) == 32
book_raw = (ROOT / (PREFIX + 'book.json')).read_bytes()
packed = json.loads(book_raw)
assert packed['producer_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes())
raw = gzip.decompress(base64.b64decode(packed['data'], validate=True))
assert packed['encoding'] == 'gzip-base64' and packed['bytes'] == len(raw) and packed['sha256'] == digest(raw)
assert gzip.compress(raw, mtime=0) == base64.b64decode(packed['data'], validate=True)
book = json.loads(raw)
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes())
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'missing-include']
for row in book['rows']:
    expected = dict(files)
    if row['name'] == 'missing-summary':
        del expected[SUMMARY]
    elif row['name'] == 'changed-chapter':
        expected[CHAPTER] = expected[CHAPTER].replace(MARKER, b'', 1)
    elif row['name'] == 'missing-include':
        del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: digest(raw) for path, raw in expected.items()}, 'wrong book input population/content'
    assert row['modes'] == {path: modes[path] for path in expected}
    assert row['unchanged'] is True
    assert row['command'][1:] == ['build', 'docs/linkedspec-book', '-d', 'output']
    out = base64.b64decode(row['stdout_base64'], validate=True)
    err = base64.b64decode(row['stderr_base64'], validate=True)
    html = base64.b64decode(row['html_base64'], validate=True)
    assert row['marker_present'] == (MARKER in html)
    if row['name'] == 'missing-summary':
        assert row['returncode'] != 0 and b'SUMMARY' in err and not html
    else:
        assert row['returncode'] == 0 and bool(html)
        assert row['output_locations'] == ['output/dsl/actionir-lowering-mental-model.html']
        assert (MARKER in html) == (row['name'] != 'changed-chapter'), 'wrong rendered teaching oracle'
        if row['name'] == 'missing-include':
            assert b'Error updating' in err and b'examples/integration/word.spec' in err
        else:
            assert b'ERROR' not in err, 'healthy complete book must resolve every include'
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'book_capture_sha256': digest(book_raw), 'book_producer_sha256': book['producer_sha256'],
          'source_inputs': {path: digest(raw) for path, raw in files.items()},
          'source_count': len(files), 'book_source_count': len(book_paths), 'include_source_count': 32, 'actual_controls': 3,
          'scope': 'Exact full book source/config/recursive include population, actual retained command channels, input preservation and rendered marker controls. The known caller-relative CLI destination is checked in actual output locations; no immutable toolchain or cross-version HTML claim.'}
target = ROOT / (PREFIX + 'book-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Complete book review PASS57+32/three actual controls; exact input and rendered teaching identities')
