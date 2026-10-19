"""Supply the fixed claim namespace omitted by the original625 binding declaration."""
import gzip
import json
import subprocess
from pathlib import Path
from common import ROOT, PREFIX, OLD, BASE, load, sha, encode

original = load()
target = ROOT / (PREFIX + 'namespace.json.gz')
assert not target.exists()
names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE,
                                 '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
selected = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json'
inputs = {}
for path in names:
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    value = source.read_bytes()
    old = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    if path == selected:
        expected = json.loads(old)
        expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
        assert json.loads(value) == expected
    else:
        assert value == old, path
    inputs[path] = dict(base64=encode(value), sha256=sha(value), mode=source.stat().st_mode & 0o7777)
command = ['python3', OLD + 'publish.py']
run = subprocess.run(command, cwd=ROOT, capture_output=True)
assert run.returncode == 0 and not run.stderr
assert run.stdout == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
for path, item in {**original['inputs'], **inputs}.items():
    source = ROOT / path
    assert sha(source.read_bytes()) == item['sha256'] and source.stat().st_mode & 0o7777 == item['mode']
record = dict(result='PASS', base=BASE, inputs=inputs, fixed_names=names,
              original_declared_count=625, added_names=sorted(set(inputs) - set(original['inputs'])),
              producer_base64=encode(Path(__file__).read_bytes()),
              original_claim_sha256=original['claim_sha256'],
              command=command, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              scope='Actual fixed-Git namespace and selected .7 mode/revision-only freeze, before bound '
                    'writes. This supplements an omitted actual input population; it does not invent '
                    'a revision for the uncommitted625 draft or refresh native/capture observations.')
with target.open('xb') as output:
    output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
print('Actual namespace supplement PASS:', len(inputs), 'fixed claim inputs;', len(record['added_names']), 'added')
