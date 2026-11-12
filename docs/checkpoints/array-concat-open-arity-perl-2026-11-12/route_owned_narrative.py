"""Route only this new leaf's commentary after the rejected pressure candidate."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'landing-pressure'
OUT.mkdir()
PART = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
MARK = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.1`'
raw = PART.read_bytes()
assert raw == subprocess.check_output(['git', 'show', ':' + str(PART)])
text = raw.decode()
assert text.count(MARK) == 1
start = text.index(MARK)
end = text.index('\n- ID:', start + 1)
leaf = text[start:end]
headers = leaf.splitlines()[:5]
assert headers[1] == '  Status: `completed` / bounded focused proof; full admission separate'
for number, field in ((2, 'Goal'), (3, 'Dependencies'), (4, 'Acceptance')):
    assert headers[number].startswith('  ' + field + ':')
fields = []
for field in ('Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification'):
    matches = [line for line in leaf.splitlines() if line.startswith('  ' + field + ':')]
    assert len(matches) == 1
    fields += matches
checklist = leaf[leaf.index('  Acceptance Checklist\n'):leaf.index('  Outcome:')]
assert checklist.count('  - [x] **') == 6
review = (BASE / 'REVIEW.md').read_text()
for word in ('474', 'SX', 'TU', '3024', 'signature', 'qualification', '25', '186'):
    assert word in leaf and word in review
compact = '\n'.join(headers + fields) + '''
  Activation: Cleanb15ca562e8044d9a8a369e613926bf016598f708; full scoped recovery/progression is retained in REVIEW.md and landing-pressure/.
''' + checklist + '''  Outcome: docs/checkpoints/array-concat-open-arity-perl-2026-11-12/REVIEW.md.504/26 supported/four separate compatibility/474 full preservation/80 initial policies; SDK result-role5/4 only. Exact-old30/current504/direct1028/first strict readonly25/qualified archive reader25/current186 pass.3024 epoch pairs/four original-owner oracle pairs remain. Original before28/after2-capture1/comparator1/qualification1 and first cached whitespace2 stay explicit; exact patch gzip/use/retirement changes no SDK observation or policy.
  Landing: Book/Knowledge/reference scope1948 and memory/history checks pass; first mandatory commit fails task_evidence12590016/12582912. Preserve the complete rejected task candidate/log and route only this leaf's new commentary, with contracts/all other nodes exact. Normal retry follows; planned headroom29 precedes Rust80.2. No cap or SDK/proof source change.
  Narrative: docs/checkpoints/array-concat-open-arity-perl-2026-11-12/REVIEW.md; exact whole pre-route part/leaf/candidate/log/producers and independent recovery in landing-pressure/.
  Remaining: Full23.4/native4.2/SESSION5/source/context/isolation/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/shadowing32/literal/excluded/declared5.4/formatter stay owned. Older direct transient strings gain no custody credit; no peer verdict.
'''
assert len(compact.encode()) <= 4500 and len(leaf.encode()) - len(compact.encode()) >= 10500
after = (text[:start] + compact + text[end:]).encode()
assert after[:len(text[:start].encode())] == raw[:len(text[:start].encode())]
assert after.endswith(text[end:].encode())
log_path = Path('.linkedspec-data/array-concat-open-arity-perl-commit.log')
log = log_path.read_bytes()
assert b'FAIL: surface task_evidence exceeds control: aggregate bytes 12590016/12582912' in log
assert log.count(b'  PASS  ') == 9 and log.count(b'  FAIL  README-STABILITY') == 1
paths = [PART, Path('docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl'), Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'),
    Path('MEMORY.md'), Path('README_POLICY.md'), Path('doctrine/readme_stability/routes.jsonl'),
    BASE / 'route_owned_narrative.py', BASE / 'review_owned_narrative.py', log_path]
rows = {}
with tarfile.open(OUT / 'inputs-before-route.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'inputs-before-route.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        body = archive.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
for name, body in (('part-before.md.gz', raw), ('leaf-before.md.gz', leaf.encode()), ('part-after.md.gz', after), ('complete-first-hook.log.gz', log)):
    target = OUT / name
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
patch = subprocess.check_output(['git', 'diff', '--cached', '--full-index', '--binary', '--', 'docs/tasks', 'MEMORY.md'])
(OUT / 'rejected-task-candidate.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
record = dict(surface='task_evidence', actual_bytes=12590016, limit_bytes=12582912, excess_bytes=7104,
    observed_commit_exit=1, observation='Actual exec session57070; complete combined hook log retained, not complete hook PASS',
    original_leaf_bytes=len(leaf.encode()), compact_leaf_bytes=len(compact.encode()), bytes_routed=len(raw)-len(after),
    scope='Only own new80.1 progress narrative routed; Goal/Dependencies/Acceptance, actual verification fields/checklist and every other node/prefix/full future tail stay exact. No cap/SDK/test/expectation/proof source changes.')
(OUT / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
mode = PART.stat().st_mode & 0o777
PART.write_bytes(after)
assert PART.stat().st_mode & 0o777 == mode and PART.read_bytes() == after
print(json.dumps(record, indent=2))
