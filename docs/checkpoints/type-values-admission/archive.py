"""Archive completed admission attempts; never substitute a rerun for their channels."""
import gzip
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-admission/'
V = '.linkedspec-data/verification/type-values-'
assert sys.argv[1:] == ['--canonical-status', '1'], 'Join the first CI process before archiving its actual status'
assert (ROOT / (V + 'ordinary-phase0.status')).read_text().strip() == '0'
assert (ROOT / (V + 'admission-readonly.status')).read_text().strip() == '0'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
for path, item in preserved['inputs'].items():
    assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
assert subprocess.check_output(['git', 'diff', '--name-only'], cwd=ROOT) == b''
patch = (ROOT / (V + 'canonical1-candidate.patch')).read_bytes()
assert subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT) == patch
base = (ROOT / (V + 'canonical1-base.txt')).read_text().strip()
assert base == subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == c.BASE
candidate = dict(base_commit=base, staged_patch_sha256=c.sha(patch), staged_patch_bytes=len(patch),
                 patch=P + 'canonical1-candidate.patch.gz')
producer = c.read(P + 'archive.py')
ci = c.read(V + 'canonical.log')
assert b'task-acceptance:' in c.decode(ci['base64'])
assert b'repo-root-path-portability:' in c.decode(ci['base64'])
stdout = c.read(V + 'ordinary-phase0.stdout')
stderr = c.read(V + 'ordinary-phase0.stderr')
text = c.decode(stdout['base64']).decode()
roots = re.findall(r'^(?:not )?ok (\d+)(?: - (.*))?$', text, re.M)
assert [int(n) for n, _ in roots] == list(range(1, 1036))
assert '1..1035' in text and 'Result: PASS' in text
assert not re.search(r'^\s*not ok \d+', text, re.M)
assert not re.search(r'^ok \d+.*#\s*skip\b', text, re.M | re.I)
old = json.loads((ROOT / 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-original-run.json').read_bytes())
original = c.decode(old['combined_output_base64']).decode()
failed_before = sorted(re.findall(r'^not ok \d+ - (.*)$', original, re.M))
failed_after = sorted(re.findall(r'^not ok \d+ - (.*)$', text, re.M))
assert len(failed_before) == 52 and failed_after == []
work = ROOT / '.linkedspec-data/verification/type-values-failure-sets'
work.mkdir(exist_ok=True)
for name, values in (('before', failed_before), ('after', failed_after)):
    (work / name).write_text(''.join(value + '\n' for value in values))
environment = dict(os.environ, LC_ALL='C')
comparisons = {name: c.run(['comm', option, str((work / 'before').relative_to(ROOT)),
                           str((work / 'after').relative_to(ROOT))], env=environment)
               for name, option in (('cleared', '-23'), ('new', '-13'))}
assert all(run['returncode'] == 0 for run in comparisons.values())
assert c.decode(comparisons['new']['stdout_base64']) == b''
assert c.decode(comparisons['cleared']['stdout_base64']).decode().splitlines() == failed_before
syntax = [c.run(command) for command in (
    ['perl', '-c', '-Iperl', 'perl/LinkedSpec.pm'],
    ['perl', '-c', '-Iperl', 't/phase0_regression.t'])]
assert all(run['returncode'] == 0 for run in syntax)
for name in ('canonical1-candidate.patch.gz', 'canonical1.json.gz', 'baseline.json', 'ordinary-phase0.json.gz'):
    assert not (ROOT / (P + name)).exists(), name
with (ROOT / candidate['patch']).open('xb') as output:
    output.write(gzip.compress(patch, mtime=0))
assert gzip.decompress((ROOT / candidate['patch']).read_bytes()) == patch
c.write_new(P + 'canonical1.json.gz', dict(candidate=candidate, producer=producer,
    command=['bash', 'tools/run_ci_local.sh'], returncode=1, combined_output=ci,
    scope='Actual first approved-host CI attempt, joined before archive. No passing receipt. '
          'The exact staged binary patch reconstructs its candidate from the named real base.'), packed=True)
c.write_new(P + 'baseline.json', dict(candidate=candidate, producer=producer, returncode=0,
    command=['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/type-evaluated-values/publish.py'],
    combined_output=c.read(V + 'admission-readonly.log'),
    status=c.read(V + 'admission-readonly.status'),
    scope='Actual default readonly636 draft baseline completed before portability writes. '
          'Original preservation was captured by an inline standard-library command; its full '
          'claim/input identities/modes and changed-before bytes are retained. The staged patch '
          'and real base recover every other binding; no named initial producer is invented.'))
c.write_new(P + 'ordinary-phase0.json.gz', dict(candidate=candidate, producer=producer,
    command=['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', 't/phase0_regression.t'],
    returncode=0, stdout=stdout, stderr=stderr, status=c.read(V + 'ordinary-phase0.status'),
    roots=1035, failed_before=failed_before, failed_after=failed_after,
    comparisons=comparisons, syntax=syntax,
    scope='Actual intact ordinary entrypoint reaches every1035 root without exclusions. '
          'Separate original channels retained. Earlier52 root failures all clear; no new failure. '
          'This archives an already running command, not a fresh closed supplied-context replay; '
          'no initial environment snapshot or full per-read dependency closure is invented. '
          'Focused source snapshot and canonical candidate admission retain their separate scopes.'), packed=True)
print('Archived exact first candidate, CI1, readonly636 baseline0 and ordinary1035 PASS; comm new set empty')
