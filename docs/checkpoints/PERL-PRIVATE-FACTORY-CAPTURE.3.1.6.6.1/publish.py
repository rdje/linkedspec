"""Publish or readonly-check the bounded review-command repair and historical closure."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'd95a25c8b5904bfbc893aee5249dbaf278496eb3'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1'
DIR = 'docs/checkpoints/' + LEAF + '/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
PREDECESSOR = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
assert sys.argv[1:] in ([], ['--capture'])


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


for name in ('review.py', 'evidence.py', 'book-review.py'):
    result = subprocess.run(['python3', DIR + name], cwd=ROOT,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert result.returncode == 0 and not result.stderr, (name, result.returncode, result.stdout, result.stderr)
invocation_raw = read(DIR + 'recovery-invocation.json')
invocation = json.loads(invocation_raw)
assert json.loads(read(DIR + 'recovery-invocation-reached.json')) == invocation
assert invocation['producer_sha256'] == sha(read(DIR + 'run-recovery.py'))
assert [row['name'] for row in invocation['rows']] == ['population-draft-recurrence', 'corrected']
for row, name in zip(invocation['rows'], ('review-population-draft.py', 'review.py')):
    assert row['command'] == ['python3', DIR + name, '--capture-original']
    assert row['source_sha256'] == sha(read(DIR + name))
    stdout = base64.b64decode(row['stdout_base64'], validate=True)
    stderr = base64.b64decode(row['stderr_base64'], validate=True)
    if name == 'review-population-draft.py':
        assert row['returncode'] != 0 and b"assert row['original_sha256'] == sha(original_raw)" in stderr
    else:
        assert row['returncode'] == 0 and not stderr and b'395 supplied inputs' in stdout

book = json.loads(read(DIR + 'book-review.json'))
paths = set(book['source_inputs']) | {
    'docs/decisions/0133-finite-engineering-notes-member.md',
    'docs/knowledge/finite-engineering-notes-member-0131.md', PREDECESSOR,
}
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / DIR).iterdir() if path.is_file())
inputs = [{'path': path, 'sha256': sha(read(path)),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
original_raw = old(PREDECESSOR)
original = json.loads(original_raw)
historical = {entry['path']: dict(entry) for entry in original['claims'][0]['durability']['inputs']}
assert len(historical) == 377
hygiene = json.loads(old(OLD + 'before-hygiene.json'))['claims'][0]['durability']['inputs']
assert len(hygiene) == 19
additional = [entry for entry in hygiene if entry['path'] not in historical]
assert len(additional) == 17
for entry in additional:
    assert sha(old(entry['path'])) == entry['sha256']
    historical[entry['path']] = dict(entry)
historical[PREDECESSOR] = {'path': PREDECESSOR, 'sha256': sha(original_raw), 'role': 'input'}
assert len(historical) == 395
assert all(sha(old(entry['path'])) == entry['sha256'] for entry in historical.values())
assert historical[OLD + 'publish.py']['role'] == 'producer'
statement = ('ADR0133 now names a readonly reviewer that passes against the current documents. '
             'Independent Git comparison allows only its review-command replacement, with capacity authorization and all other ADR bytes unchanged. '
             'The related existing Knowledge card preserves dated bodies and teaches the current boundary; the book adds historical-command guidance. '
             'All377 accepted predecessor bindings and original claim fields remain historical without hash refresh. '
             'Actual supplied recovery of the accepted publication uses395 files:377 live bindings,17 additional published historical hygiene inputs and the original claim. '
             'The original publisher passes, rejects the changed ADR and an omitted historical input, then passes after restoration. '
             'Three current-reviewer corruptions each reject for their named reason and restore; full book89 inputs and three rendered/command controls pass.')
limits = ('Documentation/recovery only: no capacity limit, registry, runtime, dependency or original hygiene/native/book observation changes. '
          'Supplied recovery uses the owning repository Git object database read-only with optional locks disabled;395 is its supplied filesystem population, not a Git-free capsule. '
          'The first378-input replay omitted17 historical inputs and exited1 at missing .gitignore; its complete reached channels and exact draft remain retained. '
          'The next population draft shadowed the original claim variable and exited1 before publisher execution or a report. Its exact source and original tool-return boundary are disclosed; '
          'a separately identified fresh recurrence captures the actual preflight denial, and the corrected outer invocation passes with complete channels. No unavailable original outer capsule or partial success is inferred. '
          'No new Knowledge slot or broader factory/canonical admission is claimed. The parent canonical receipt belongs to accepted d95a25c8b; this ordinary repair uses focused checks.')
record = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'current-admission-review-command', 'statement': statement, 'scope': limits,
     'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + DIR + 'publish.py (readonly default). Current review.py, evidence.py and book-review.py are readonly defaults; capture/freezer/apply/retention/recovery writers are one-shot.',
                 'granularity': 'Exact ADR byte comparison, full related card/book reconstruction, every377 original binding and full predecessor claim; actual395-input original replay and its two named REDs/restoration,15-file current-reviewer populations and three RED/restorations,89 recursive book/config/include inputs with three actual controls. Complete failed drafts and corrected outer recurrence are retained separately.',
                 'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A stale command, forged original binding hidden by updated immediate SHA metadata, missing guidance or omitted historical input might appear accepted.',
                 'oracle': 'Accepted Git ADR/full claim and every original input; exact sole-command successor; actual preserved publisher in supplied accepted inputs; independent recursive book population and retained rendered HTML; actual current reviewer subprocesses.',
                 'red_control': 'Original command actually fails current root reconstruction before edits while its guarded baseline passes. The accepted publisher rejects a changed ADR and omitted .gitignore, then restores PASS. Current reviewer rejects stale-command, forged-original-binding beyond updated immediate freeze SHA, and missing-guidance; each exact restoration passes. Book rejects missing SUMMARY, loses the changed guidance marker in HTML, and diagnoses a missing include despite exit0. Full channels and changed input populations are retained before assertions.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'accepted-admission-publication-recovery',
     'statement': 'The accepted d95a25c8b publication remains recoverable with its original377 live bindings,17 historical hygiene inputs and exact full claim,395 supplied files. Original producers, hashes and observations remain exact.',
     'scope': limits,
     'rederive': {'status': 'checked', 'command': 'Readonly ' + DIR + 'review.py through tools/run_python_project_data.sh; retained actual accepted publisher recovery uses its complete supplied input state and owning Git object database.',
                 'granularity': 'Every395 supplied path/hash and Git mode, full accepted claim, actual original publisher and healthy/two RED/restored channels.',
                 'result': 'Original publisher PASS; current-ADR original-binding RED; missing historical .gitignore RED; exact accepted restoration PASS. First incomplete draft and population-shadow preflight remain separately retained/disclosed.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A later document or an incomplete live-only population might substitute for the accepted publication boundary.',
                 'oracle': 'Actual unchanged accepted producer, Git-backed complete binding reconstruction and original historical hygiene claim.',
                 'red_control': 'The actual unchanged producer rejects both current ADR bytes and a missing historical .gitignore. Exact395-input restoration passes with identical healthy output.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE,
                    'inputs': [historical[path] for path in sorted(historical)]}},
]}
serialized = (json.dumps(record, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('bounded claim bytes', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'current publication/inputs drift'
print('Current command publication PASS:', len(inputs), 'live inputs;', len(historical),
      'historical recovery inputs;', len(serialized), 'bytes')
