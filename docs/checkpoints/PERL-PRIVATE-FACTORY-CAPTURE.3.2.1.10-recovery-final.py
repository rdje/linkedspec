"""One-shot accepted-publication recovery and effective claim-population controls."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ACCEPTED = 'fc96936fb64d27e692e66377b2e332641c2674fd'
BASE = '16c70eaab688a877053b1addde8f07bc548e1cbf'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json'
EXTRA = 'docs/claims/REPO-HYGIENE.16.json'
BODY = PREFIX + 'corrected-body.py'
EXECUTOR = PREFIX + 'execute.py'
TARGET = ROOT / (PREFIX + 'recovery-final.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
old = lambda revision, p: subprocess.check_output(['git', 'show', revision + ':' + p], cwd=ROOT)
assert not TARGET.exists() and not (ROOT / (PREFIX + 'recovery-final-reached.json')).exists()
raw_claim = old(ACCEPTED, CLAIM)
claim = json.loads(raw_claim)
assert len(claim['claims'][0]['durability']['inputs']) == 366 and len(raw_claim) == 85779
files = {entry['path']: old(ACCEPTED, entry['path']) for entry in claim['claims'][0]['durability']['inputs']}
assert all(sha(files[entry['path']]) == entry['sha256'] for entry in claim['claims'][0]['durability']['inputs'])
namespace = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ACCEPTED, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
for path in namespace:
    raw = old(ACCEPTED, path)
    assert path not in files or files[path] == raw
    files[path] = raw
assert files[CLAIM] == raw_claim and EXTRA not in files
published = json.loads(old(ACCEPTED, 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'))['claims'][0]['durability']
assert published['mode'] == 'historical' and published['revision'] == '61cca1cccff6027461e120e4236431d1bc7d20b1' and len(published['inputs']) == 339
supplemental = [entry for entry in published['inputs'] if entry['path'] not in files]
assert len(supplemental) == 33
for entry in supplemental:
    raw = old(published['revision'], entry['path'])
    assert sha(raw) == entry['sha256'], 'published historical replay input'
    files[entry['path']] = raw
original = files[OLD + 'review.py']
before = b"for path in sorted((ROOT / 'docs/claims').glob('*.json')):\n    relative = path.relative_to(ROOT).as_posix()"
after = b"original_claim_paths = subprocess.check_output(\n    ['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()\nfor relative in sorted(original_claim_paths):"
assert original.count(before) == 1
fixed = original.replace(before, after, 1)
assert (ROOT / BODY).read_bytes() == fixed, 'sole fixed historical population correction'
files[EXECUTOR] = (ROOT / EXECUTOR).read_bytes()
files[BODY] = fixed
extra_raw = old(BASE, EXTRA)
mode_lines = subprocess.check_output(['git', 'ls-tree', '-r', ACCEPTED], cwd=ROOT, text=True).splitlines()
git_modes = {line.split('\t')[1]: int(line.split()[0], 8) & 0o777 for line in mode_lines if line.split()[0] != '160000'}
cases = ('accepted', 'original-extra', 'fixed-extra', 'stale-body', 'omitted-origin', 'added-new', 'restored')
rows = []
for name in cases:
    selected = dict(files)
    if name != 'accepted':
        selected[EXTRA] = extra_raw
    if name == 'stale-body':
        selected[BODY] = original
    elif name == 'omitted-origin':
        selected[BODY] = fixed.replace(b'for relative in sorted(original_claim_paths):', b"for relative in sorted(p for p in original_claim_paths if p != 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'):", 1)
    elif name == 'added-new':
        selected[BODY] = fixed.replace(b'for relative in sorted(original_claim_paths):', b"original_claim_paths.append('docs/claims/REPO-HYGIENE.16.json')\nfor relative in sorted(original_claim_paths):", 1)
    inputs = {path: sha(raw) for path, raw in selected.items()}
    modes = {path: git_modes.get(path, 0o644) for path in selected}
    command = ['python3', OLD + 'publish-claim.py'] if name == 'accepted' else (
        ['python3', OLD + 'review.py'] if name == 'original-extra' else ['python3', EXECUTOR, sha(selected[BODY])])
    with tempfile.TemporaryDirectory(prefix='accepted-kind-review-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in selected.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(modes[path])
        environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied), GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
        syntax_command = ['python3', '-c', 'from pathlib import Path; compile(Path("' + BODY + '").read_bytes(), "retained-review-body", "exec")']
        syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, capture_output=True)
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == inputs
    row = {'name': name, 'command': command, 'inputs': inputs, 'modes': modes, 'unchanged': unchanged,
           'returncode': result.returncode, 'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr),
           'body_base64': b64(selected[BODY]), 'syntax': {'command': syntax_command, 'returncode': syntax.returncode, 'stdout_base64': b64(syntax.stdout), 'stderr_base64': b64(syntax.stderr)}}
    rows.append(row)
    (ROOT / (PREFIX + 'recovery-final-reached.json')).write_text(json.dumps({'rows': rows}, indent=2) + '\n')
    assert syntax.returncode == 0 and not syntax.stdout and not syntax.stderr and unchanged
    if name in ('original-extra', 'stale-body', 'added-new'):
        assert result.returncode != 0 and EXTRA.encode() in result.stderr and b'not in' in result.stderr, ('actual namespace RED', name)
    elif name == 'omitted-origin':
        assert result.returncode != 0 and b'complete original live intersection census' in result.stderr, 'actual omitted-original membership RED'
    else:
        assert result.returncode == 0 and not result.stderr, ('actual historical recovery PASS', name, result.stderr)
        assert (b'366 live inputs; 85779 bytes' if name == 'accepted' else b'Executed review body SHA256') in result.stdout
    print(name + ' retained: ' + str(len(selected)) + ' supplied inputs; actual exit' + str(result.returncode), flush=True)
report = {'producer_sha256': sha(Path(__file__).read_bytes()), 'accepted': ACCEPTED, 'base': BASE, 'rows': rows,
          'namespace': namespace, 'published_historical_inputs': supplemental, 'original_claim_sha256': sha(raw_claim), 'extra_claim_sha256': sha(extra_raw),
          'scope': 'Every366 accepted publication binding plus complete accepted claim namespace, original full claim,33 separately published historical inputs and two explicit new instruments; new unrelated claim only in extended cases. Owning Git object database read-only/optional locks disabled; no Git-free or toolchain immutability claim. Actual original accepted publisher PASS, original unrelated-claim RED, sole corrected body PASS, three syntax-valid semantic population faults and restored PASS. Historical report retains its original producer identity; executed corrected body has its separate retained source/hash/command identity. No retired source, report, native observation or input hash is refreshed.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Accepted publication recovery and fixed-Git population controls PASS')
