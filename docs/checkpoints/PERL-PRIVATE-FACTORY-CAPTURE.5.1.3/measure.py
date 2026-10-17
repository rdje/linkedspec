"""One-shot actual history pressure/rollover and old-cap denial, before choosing deltas."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
REG = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
TARGET = ROOT / (PREFIX + 'measurement.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert not TARGET.exists(), 'one-shot measurement'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())['result'] == 'PASS'
CHANGE = ("## 2026-10-17 — PERL-PRIVATE-FACTORY-CAPTURE.5.1.3 — Finite engineering-history prerequisite\n\n"
    "One required engineering-history rollover is measured before selecting any finite allowance. "
    "Preserve the complete449-input callback publication and its actual readonly baseline, every "
    "accepted immutable history/decision byte and complete queryable source content. Exact source "
    "suffix, old-cap denial, sole indexed authority overhead, production controls and supplied "
    "evidence precede receipt-bound canonical admission. No runtime change or future archive reserve.\n\n").encode()
NOTE = ("## 2026-10-17 — PERL-PRIVATE-FACTORY-CAPTURE.5.1.3 — Finite history capacity\n\n"
    "The next complete engineering note crosses the existing rollover trigger. Measure the actual "
    "clean-source suffix and resulting member/manifest census before choosing exact registry and "
    "sole decision/index overhead. Preserve all old callback producers, observations and archive "
    "bytes; derive current facts from the measured inputs, retain observed old-cap rejection, "
    "and require exact staged canonical proof. No future reserve or runtime change is admitted here.\n\n").encode()
rows = [json.loads(line) for line in old(REG).splitlines()]
originals = {p: old(p) for p in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', REG, MANIFEST, 'docs/decisions/INDEX.md')}
assert all((ROOT / p).read_bytes() == value for p, value in originals.items())
immutable = {}
for directory in ('docs/history/development-notes', 'docs/history/changes', 'docs/decisions'):
    for path in subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', directory], cwd=ROOT, text=True).splitlines():
        if path not in (MANIFEST, 'docs/decisions/INDEX.md'):
            value = old(path)
            assert (ROOT / path).read_bytes() == value
            immutable[path] = sha(value)

def capsule(name):
    paths = {REG, 'README.md', 'README_POLICY.md', 'scripts/check_readme_routing_pressure.pl',
        'tools/roll_document_history.pl', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
        'tools/run_python_project_data.sh', PREFIX + 'measure.py'}
    for row in rows:
        for pattern in row.get('members', []):
            for path in ROOT.glob(pattern):
                if path.is_file() and not path.is_symlink():
                    paths.add(path.relative_to(ROOT).as_posix())
        for spelling in row.get('route_targets', []):
            path = ROOT / spelling
            if path.is_file() and not path.is_symlink():
                paths.add(spelling)
    result = {}
    for path in sorted(paths):
        source = ROOT / path
        value = source.read_bytes()
        result[path] = {'sha256': sha(value), 'mode': source.stat().st_mode & 0o7777, 'bytes_base64': encode(value)}
    value = gzip.compress(json.dumps(result, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
    with (ROOT / (PREFIX + name)).open('xb') as output:
        output.write(value)
    return {'path': PREFIX + name, 'sha256': sha(value), 'files': len(result)}

record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'result': 'pending',
    'original_inputs': {p: {'sha256': sha(v), 'bytes_base64': encode(v)} for p, v in originals.items()},
    'records': {'changes_base64': encode(CHANGE), 'engineering_base64': encode(NOTE)},
    'preserved': immutable, 'captures': {}, 'commands': []}

def retain():
    TARGET.write_text(json.dumps(record, indent=2) + '\n')

def run(command):
    tracked = subprocess.check_output(['git', 'ls-files', '--cached', '-z'], cwd=ROOT)
    others = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=ROOT)
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    row = {'command': command, 'returncode': result.returncode,
        'stdout_base64': encode(result.stdout), 'stderr_base64': encode(result.stderr),
        'tracked_namespace_base64': encode(tracked), 'untracked_namespace_base64': encode(others)}
    record['commands'].append(row)
    retain()
    return result

record['captures']['original'] = capsule('original-inputs.json.gz')
for path, addition in (('CHANGES.md', CHANGE), ('DEVELOPMENT_NOTES.md', NOTE)):
    value = originals[path]
    marker = re.search(rb'^## ', value, re.M)
    assert marker, 'complete heading boundary'
    (ROOT / path).write_bytes(value[:marker.start()] + addition + value[marker.start():])
record['captures']['unrolled'] = capsule('unrolled-inputs.json.gz')
retain()
pressure = run(['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--check'])
assert pressure.returncode != 0 and b'rollover required for engineering_notes' in pressure.stderr
rollover = run(['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--apply'])
assert rollover.returncode == 0 and b'archived' in rollover.stdout
record['captures']['rolled'] = capsule('rolled-inputs.json.gz')
retain()
admission = run(['perl', 'scripts/check_readme_routing_pressure.pl', '--report'])
assert admission.returncode != 0 and b'surface engineering_notes exceeds control' in admission.stderr
assert (ROOT / REG).read_bytes() == originals[REG], 'no allowance is chosen by measurement'
assert (ROOT / 'docs/decisions/INDEX.md').read_bytes() == originals['docs/decisions/INDEX.md']
assert all(sha((ROOT / p).read_bytes()) == identity for p, identity in immutable.items()), 'all original immutable inputs retained'
record['result'] = 'PASS'
record['scope'] = ('Actual complete-record pressure, public production rollover and old routing-cap rejection '
    'before selecting deltas. All registered file members, file route targets, checker/roller, wrappers, '
    'actual Git path namespaces and original mutable bytes are retained per stage. The unaffected other '
    'history manifest and all prior history/decision files remain exact. Project-local snapshots share '
    'the repository volume; no other repository or runtime source changes. System Perl/stdlib are '
    'reused read-only without an immutable portable toolchain claim. This does not admit any allowance.')
retain()
print('Finite history measurement PASS:', len(immutable), 'unchanged prior files; actual pressure/old-cap RED; one rollover')
