"""Current document review with exact accepted-publication recovery; default readonly."""
import base64
import copy
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'd95a25c8b5904bfbc893aee5249dbaf278496eb3'
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
ADR = 'docs/decisions/0133-finite-engineering-notes-member.md'
CARD = 'docs/knowledge/finite-engineering-notes-member-0131.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
OLD_COMMAND = b'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-capacity.py review'
NEW_COMMAND = (DIR + 'review.py').encode()
BOOK_NOTE = b'''A historical review command requires its original logical inputs.
Use the current Knowledge card's readonly entrypoint when documents have changed;
it should preserve and check the accepted publication separately. Updating a
command must not refresh an earlier observation or silently change its boundary.

'''
QUESTIONS = b'''  - "why does the ADR0133 capacity review command fail against current notes"
  - "where is the current ADR0133 readonly review command"
  - "how is the accepted ADR0133 publication recovered after its pointer repair"
'''
CONTEXT = b'''## Current review-command repair

ADR0133 was accepted at d95a25c8b with canonical CI and all normal hooks passing.
Its old command selected an instrument that requires the original logical draft,
so current notes failed its exact root check. The current reviewer checks the
sole ADR pointer correction and related guidance, preserves the accepted claim
at that Git boundary, and validates an actual supplied original-publication replay.
The dated admission accounts below retain their original bodies and measurements.

'''
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def documents():
    adr = old(ADR)
    assert adr.count(OLD_COMMAND) == 1
    card = old(CARD)
    status = next(line for line in card.splitlines(keepends=True) if line.startswith(b'status:'))
    reverify = next(line for line in card.splitlines(keepends=True) if line.startswith(b'reverify:'))
    card = card.replace(b'date: 2026-10-11\n', QUESTIONS + b'date: 2026-10-11\n', 1)
    card = card.replace(status, b'status: ADR0131 and ADR0133 evidence historical; current review-command repair verified\n', 1)
    card = card.replace(reverify, b'reverify: "bash tools/run_python_project_data.sh ' + NEW_COMMAND +
                        b' (readonly default). Accepted admission instruments require their recorded Git inputs; current review retains their original publication and channels. One-shot capture/freezer writers are not resume commands."\n', 1)
    card = card.replace(b'# The next finite admission: ADR0133\n', CONTEXT + b'# The next finite admission: ADR0133\n', 1)
    book = old(BOOK)
    assert book.count(b'## Public book\n') == 1
    return {ADR: adr.replace(OLD_COMMAND, NEW_COMMAND, 1), CARD: card,
            BOOK: book.replace(b'## Public book\n', BOOK_NOTE + b'## Public book\n', 1)}


def accepted():
    raw = old(CLAIM)
    record = json.loads(raw)
    entries = record['claims'][0]['durability']['inputs']
    assert len(entries) == len({entry['path'] for entry in entries}) == 377
    files = {entry['path']: old(entry['path']) for entry in entries}
    assert all(sha(files[entry['path']]) == entry['sha256'] for entry in entries), 'every accepted binding'
    files[CLAIM] = raw
    return raw, record, files


def channels(result):
    return {'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}


assert sys.argv[1:] in ([], ['--apply-documents'], ['--capture-original'])
mode = sys.argv[1:]
if mode == ['--apply-documents']:
    for path, expected in documents().items():
        assert read(path) == old(path), 'one-shot unchanged document: ' + path
    for path, expected in documents().items():
        (ROOT / path).write_bytes(expected)
    print('Exact ADR pointer and related current guidance applied; original bodies retained')
    sys.exit(0)

original_raw, original, files = accepted()
freeze = json.loads(read(DIR + 'freeze.json'))
assert freeze['base'] == BASE and freeze['producer_sha256'] == sha(read(DIR + 'freeze.py'))
assert len(freeze['records']) == 1
row = freeze['records'][0]
assert row['claim'] == CLAIM and row['bindings'] == 377
assert row['names'] == ['finite-engineering-history-member']
assert row['original_sha256'] == sha(original_raw)
assert read(row['before']) == original_raw, 'exact original accepted claim'
expected = copy.deepcopy(original)
expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(expected, indent=2) + '\n').encode()
assert read(CLAIM) == after and row['after_sha256'] == sha(after), 'mode/revision-only predecessor preservation'
diagnosis = json.loads(read(DIR + 'diagnosis.json'))
assert diagnosis['base'] == BASE and diagnosis['producer_sha256'] == sha(read(DIR + 'freeze.py'))
assert diagnosis['stale']['command'] == ['python3', OLD[:-1] + '-capacity.py', 'review']
assert diagnosis['stale']['returncode'] != 0
assert b'complete current root reconstruction' in base64.b64decode(diagnosis['stale']['stderr_base64'], validate=True)
assert diagnosis['guarded']['command'] == ['python3', OLD + 'publish.py']
assert diagnosis['guarded']['returncode'] == 0 and not base64.b64decode(diagnosis['guarded']['stderr_base64'], validate=True)
for path, expected in documents().items():
    assert read(path) == expected, 'exact current ADR review pointer' if path == ADR else 'exact related guidance: ' + path

target = ROOT / (DIR + 'original-replay.json')
entries = subprocess.check_output(['git', 'ls-tree', '-r', BASE], cwd=ROOT).decode().splitlines()
all_modes = {line.split('\t', 1)[1]: int(line.split()[0], 8) & 0o777 for line in entries}
modes = {path: all_modes[path] for path in files}
assert len(files) == 378
reason = b'original logical input: ' + ADR.encode()
if mode == ['--capture-original']:
    assert not target.exists() and not (ROOT / (DIR + 'original-replay-reached.json')).exists()
    rows = []
    for name in ('accepted', 'current-adr', 'restored'):
        selected = dict(files)
        if name == 'current-adr':
            selected[ADR] = documents()[ADR]
        inputs = {path: sha(raw) for path, raw in sorted(selected.items())}
        with tempfile.TemporaryDirectory(prefix='accepted-capacity-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, raw in selected.items():
                destination = supplied / path
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(raw)
                destination.chmod(modes[path])
            command = ['python3', OLD + 'publish.py']
            environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied),
                               GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
            result = subprocess.run(command, cwd=supplied, env=environment,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            observed = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
                        for path in supplied.rglob('*') if path.is_file()}
            rows.append({'name': name, 'command': command, 'inputs': inputs, 'modes': modes,
                         'unchanged': observed == inputs, **channels(result)})
            (ROOT / (DIR + 'original-replay-reached.json')).write_text(json.dumps({'rows': rows}, indent=2) + '\n')
            assert rows[-1]['unchanged'], 'supplied original input preservation'
            if name == 'current-adr':
                assert result.returncode != 0 and reason in result.stderr, 'actual original-boundary RED'
            else:
                assert result.returncode == 0 and not result.stderr, 'actual accepted publication PASS'
    target.write_text(json.dumps({'producer_sha256': sha(Path(__file__).read_bytes()), 'rows': rows,
        'scope': 'Actual original accepted377-input publication plus its exact claim, supplied with Git modes. Healthy/current-ADR named boundary RED/restored full channels; no original observation or input hash refreshed. Git object reads use only the owning repository with optional locks disabled.'}, indent=2) + '\n')
replay = json.loads(target.read_bytes())
assert replay['producer_sha256'] == sha(Path(__file__).read_bytes())
assert json.loads(read(DIR + 'original-replay-reached.json')) == {'rows': replay['rows']}
assert [row['name'] for row in replay['rows']] == ['accepted', 'current-adr', 'restored']
for row in replay['rows']:
    selected = dict(files)
    if row['name'] == 'current-adr':
        selected[ADR] = documents()[ADR]
    assert row['inputs'] == {path: sha(raw) for path, raw in selected.items()}
    assert row['modes'] == modes and row['unchanged'] is True
    assert row['command'] == ['python3', OLD + 'publish.py']
    stdout = base64.b64decode(row['stdout_base64'], validate=True)
    stderr = base64.b64decode(row['stderr_base64'], validate=True)
    if row['name'] == 'current-adr':
        assert row['returncode'] != 0 and reason in stderr
    else:
        assert row['returncode'] == 0 and not stderr and b'377 live inputs' in stdout
assert replay['rows'][0]['stdout_base64'] == replay['rows'][2]['stdout_base64']
print('Current review PASS: exact pointer/guidance; accepted377 bindings/378 supplied original inputs; actual original publication PASS/RED/restored')
