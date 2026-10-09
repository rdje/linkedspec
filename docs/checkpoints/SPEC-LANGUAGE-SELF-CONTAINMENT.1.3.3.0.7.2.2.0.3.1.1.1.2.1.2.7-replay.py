"""Exercise actual historical/corrected publishers in complete disposable fixtures.

Default retains full command channels and Git input identities. --check reruns the
same observations and requires an exact match without rewriting retained outputs.
Run through tools/run_python_project_data.sh for repository-volume scratch.
"""
import copy
import hashlib
import json
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '31fe4fd3655466018a509d894fc6bca3a331944d'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7'
PREVIOUS = LEAF[:-1] + '6'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
PUBLISHER = 'docs/checkpoints/' + PREVIOUS + '-publish.py'
CLAIM = 'docs/claims/' + PREVIOUS + '.json'
TASK = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
LIVE = 'LIVE_ACHIEVEMENT_STATUS.md'
FACT = 'docs/knowledge/finite-engineering-notes-aggregate.md'
REFUSAL = 'one-shot publisher requires an unpublished uniquely active leaf; use retained reviewers'
assert sys.argv[1:] in ([], ['--check'])


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def task_part(text):
    start = text.index('- ID: `' + PREVIOUS + '`')
    end = text.index('\n- ID:', start + 1)
    return start, end, text[start:end]


def snapshot(directory):
    return {p.relative_to(directory).as_posix(): {
        'sha256': digest(p.read_bytes()), 'mode': stat.S_IMODE(p.stat().st_mode)}
        for p in sorted(directory.rglob('*')) if p.is_file()}


def counts(directory):
    _, _, node = task_part((directory / TASK).read_text())
    return {
        'result': len(re.findall(r'^  Result:', node, re.MULTILINE)),
        'tool_evidence': len(re.findall(r'^  LinkedSpec-tool evidence:', node, re.MULTILINE)),
        'recent': sum(line.startswith('- `' + PREVIOUS + '`')
                      for line in (directory / LIVE).read_text().splitlines()),
    }


original_claim = json.loads(blob(CLAIM))
inputs = {entry['path']: entry for entry in original_claim['claims'][0]['durability']['inputs']}
assert len(inputs) == 249
for path in (CLAIM, TASK, LIVE, 'MEMORY.md', 'docs/TASK_TREE.md'):
    assert path not in inputs
    inputs[path] = {'path': path, 'sha256': digest(blob(path)), 'role': 'input'}
raw_inputs = {path: blob(path) for path in sorted(inputs)}
for path, raw in raw_inputs.items():
    assert digest(raw) == inputs[path]['sha256'], path
assert raw_inputs[PUBLISHER] == (ROOT / (PREFIX + 'before-publisher.py')).read_bytes()
assert blob(CLAIM) == (ROOT / (PREFIX + 'before-' + Path(CLAIM).name)).read_bytes()
expected_claim = copy.deepcopy(original_claim)
expected_claim['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert json.loads((ROOT / CLAIM).read_bytes()) == expected_claim

fixed_source = (ROOT / PUBLISHER).read_bytes()
rows = []


def populate(directory, source, fresh=False):
    for path, raw in raw_inputs.items():
        destination = directory / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    (directory / PUBLISHER).write_bytes(source)
    if not fresh:
        return
    text = (directory / TASK).read_text()
    start, end, node = task_part(text)
    node = node.replace('  Status: `done`', '  Status: `active`', 1)
    node = re.sub(r'^  (?:Result|LinkedSpec-tool evidence):.*\n', '', node, flags=re.MULTILINE)
    node = re.sub(r'^  Verification:.*$', '  Verification: `pending`', node, flags=re.MULTILINE)
    node = re.sub(r'^  Commit:.*$', '  Commit: `pending`', node, flags=re.MULTILINE)
    text = text[:start] + node + text[end:]
    row = re.compile(r'^.*\| `' + re.escape(PREVIOUS) + r'` \| `done` \|.*$', re.MULTILINE)
    assert len(row.findall(text)) == 1
    text = row.sub('| `' + PREVIOUS + '` | `active` | Finite canonical engineering-notes capacity admission before event joining. |', text)
    (directory / TASK).write_text(text)
    text = (directory / LIVE).read_text()
    (directory / LIVE).write_text(''.join(line for line in text.splitlines(keepends=True)
                                         if not line.startswith('- `' + PREVIOUS + '`')))
    (directory / FACT).unlink()
    (directory / CLAIM).unlink()
    assert counts(directory) == {'result': 0, 'tool_evidence': 0, 'recent': 0}


def observe(directory, name, expectation):
    before = snapshot(directory)
    before_counts = counts(directory)
    command = ['python3', PUBLISHER]
    completed = subprocess.run(command, cwd=directory, capture_output=True, text=True, check=False)
    after = snapshot(directory)
    after_counts = counts(directory)
    changed = sorted(path for path in before.keys() | after.keys() if before.get(path) != after.get(path))
    if expectation == 'baseline-red':
        assert completed.returncode == 0, completed.stderr
        assert before_counts == {'result': 2, 'tool_evidence': 2, 'recent': 2}
        assert after_counts == {'result': 3, 'tool_evidence': 3, 'recent': 3}
        assert changed and TASK in changed and LIVE in changed
        observed = 'RED'
    elif expectation == 'publish':
        assert completed.returncode == 0, completed.stderr
        assert after_counts == {'result': 1, 'tool_evidence': 1, 'recent': 1}
        assert '  Status: `done`' in task_part((directory / TASK).read_text())[2]
        assert (directory / FACT).is_file() and (directory / CLAIM).is_file()
        observed = 'GREEN'
    else:
        assert expectation == 'refuse'
        assert completed.returncode != 0 and completed.stdout == ''
        assert completed.stderr == REFUSAL + '\n', completed.stderr
        assert before == after and before_counts == after_counts
        observed = 'GREEN'
    rows.append({'case': name, 'args': command, 'exit': completed.returncode,
                 'stdout': completed.stdout, 'stderr': completed.stderr,
                 'program_sha256': before[PUBLISHER]['sha256'],
                 'before_counts': before_counts, 'after_counts': after_counts,
                 'before_population_sha256': digest(json.dumps(before, sort_keys=True).encode()),
                 'after_population_sha256': digest(json.dumps(after, sort_keys=True).encode()),
                 'changed_paths': changed, 'observed': observed})


with tempfile.TemporaryDirectory(prefix='capacity-publisher-replay-') as temporary:
    scratch = Path(temporary)
    assert scratch.stat().st_dev == ROOT.stat().st_dev
    original = scratch / 'original'
    populate(original, raw_inputs[PUBLISHER])
    observe(original, 'original-completed-replay', 'baseline-red')

    fixed = scratch / 'fixed-completed'
    populate(fixed, fixed_source)
    observe(fixed, 'fixed-completed-replay', 'refuse')

    fresh = scratch / 'fresh'
    populate(fresh, fixed_source, fresh=True)
    observe(fresh, 'fixed-first-publication', 'publish')
    observe(fresh, 'fixed-second-publication', 'refuse')

    for case in ('duplicate-status', 'existing-result', 'existing-tool-evidence',
                 'existing-fact', 'existing-claim', 'existing-recent-row'):
        fixture = scratch / case
        populate(fixture, fixed_source, fresh=True)
        if case in ('duplicate-status', 'existing-result', 'existing-tool-evidence'):
            text = (fixture / TASK).read_text()
            start, end, node = task_part(text)
            additions = {'duplicate-status': '  Status: `active`\n',
                         'existing-result': '  Result: already partially published\n',
                         'existing-tool-evidence': '  LinkedSpec-tool evidence: already partially published\n'}
            node += additions[case]
            (fixture / TASK).write_text(text[:start] + node + text[end:])
        elif case == 'existing-fact':
            (fixture / FACT).write_bytes(raw_inputs[FACT])
        elif case == 'existing-claim':
            (fixture / CLAIM).write_bytes(raw_inputs[CLAIM])
        else:
            with (fixture / LIVE).open('a') as output:
                output.write('- `' + PREVIOUS + '` — already partially published\n')
        observe(fixture, case, 'refuse')

report = {
    'result': 'PASS', 'revision': BASE, 'producer_sha256': digest(Path(__file__).read_bytes()),
    'historical_inputs': [inputs[path] for path in sorted(inputs)],
    'historical_input_count': len(inputs), 'original_capacity_bindings': 249,
    'fixture_construction': 'Exact Git blobs plus the explicitly described published/fresh/partial-state overlays. Fresh removes only own result/evidence rows, restores own active/pending fields and active frontier row, removes own recent rows/fact/claim. Entire fixture path/content/mode population is the no-write oracle. Disposable scratch is on the repository device; no historical writer runs in the real checkout.',
    'rows': rows,
    'scope': 'One original semantic RED, one successful corrected first publication and eight exact reason-sensitive no-write denials. This private checkpoint repair does not alter capacity authority, parser/runtime, public book teaching or canonical admission results.'}
target = ROOT / (PREFIX + 'replay.json')
if sys.argv[1:]:
    assert json.loads(target.read_bytes()) == report, 'retained replay observations changed'
    print('Publisher replay review PASS; exact producer, 254 historical inputs and ten actual command observations')
else:
    assert not target.exists(), 'capture is one-shot; use --check'
    target.write_text(json.dumps(report, indent=2) + '\n')
    print('Publisher replay PASS; original RED, first publication GREEN, eight no-write denials; 254 Git inputs')
