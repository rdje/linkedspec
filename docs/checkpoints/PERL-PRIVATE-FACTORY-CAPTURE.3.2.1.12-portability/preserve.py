"""Preserve the failed staged draft before changing either bound input."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

HOME = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12-portability/'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == c.BASE
preflight = json.loads((ROOT / (c.HOME + 'publication-preflight.json')).read_bytes())
claim_bytes = (ROOT / c.CLAIM).read_bytes()
assert c.sha(claim_bytes) == preflight['draft_sha256'] == '73873a928b1e85cb080a19777a8a712e869ca0cb8781796a8aa35b18371e3cfe'
assert len(claim_bytes) == 35922 and c.decode(preflight['draft_base64']) == claim_bytes
bindings = json.loads(claim_bytes)['claims'][0]['durability']['inputs']
assert len(bindings) == 196
inputs = {}
for binding in bindings:
    item = c.read(binding['path'])
    assert item['sha256'] == binding['sha256']
    assert item['mode'] == preflight['input_modes'][binding['path']]
    inputs[binding['path']] = {key: item[key] for key in ('sha256', 'mode')}
changed = [c.HOME + name for name in ('publish.py', 'render-build.json')]
index = subprocess.check_output(['git', 'diff', '--cached', '--name-only', '-z'], cwd=ROOT).split(b'\0')
staged, supplement = {}, {}
for raw_path in filter(None, index):
    path = raw_path.decode()
    entry = subprocess.check_output(['git', 'ls-files', '--stage', '--', path], cwd=ROOT).decode().strip()
    mode, oid, rest = entry.split(' ', 2)
    assert rest.startswith('0\t')
    value = subprocess.check_output(['git', 'show', ':' + path], cwd=ROOT)
    staged[path] = dict(git_mode=mode, git_oid=oid, sha256=c.sha(value), bytes=len(value))
    if path in inputs:
        assert inputs[path]['sha256'] == c.sha(value)
    else:
        supplement[path] = dict(base64=c.encode(value), mode=(ROOT / path).stat().st_mode & 0o7777)
assert len(staged) == 108
process = subprocess.Popen(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT, stdout=subprocess.PIPE)
digest, size = hashlib.sha256(), 0
for chunk in iter(lambda: process.stdout.read(1048576), b''):
    digest.update(chunk)
    size += len(chunk)
assert process.wait() == 0
record = dict(base_commit=c.BASE, draft_state='uncommitted exact failed staged candidate; no invented revision',
    claim=c.read(c.CLAIM), preflight=c.read(c.HOME + 'publication-preflight.json'), inputs=inputs,
    before_images={path: c.read(path) for path in changed}, staged=staged, staged_supplement=supplement,
    staged_binary_full_index_diff=dict(sha256=digest.hexdigest(), bytes=size),
    prior_continuity=c.read(c.HOME + 'continuity.json'),
    canonical_failure=dict(observed_exit=1, log=c.read('.linkedspec-data/verification/knowledge-fields-canonical-attempt1.log')),
    root_worktree_reopen={path: c.read(path) for path in ('MEMORY.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md')})
c.write_new(HOME + 'original.json.gz', record, packed=True)
run = c.run(['python3', c.HOME + 'publish.py'])
assert run['returncode'] == 0 and c.decode(run['stderr_base64']) == b'', run
assert c.decode(run['stdout_base64']) == b'Metadata publication PASS: 196 inputs; 35922 bytes;1487/1349/10455;897/248\n'
assert c.unchanged(inputs) and c.read(c.CLAIM) == record['claim']
c.write_new(HOME + 'baseline.json', dict(result='PASS', command=run, all196_bytes_modes_unchanged=True,
    whole_claim_bytes_mode_unchanged=True, original_sha256=c.sha((ROOT / (HOME + 'original.json.gz')).read_bytes())))
print('Original uncommitted196/full35922 and exact failed108-file candidate preserved; actual readonly baseline PASS')
