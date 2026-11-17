"""Preserve the actual live-state refusal, then bind historical recovery to its epoch."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
TARGET = Path('docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py')
EPOCH = '36428fa1288d9da3fe00628ca0ab734b940bc023'
old = TARGET.read_bytes()
assert old == subprocess.check_output(['git', 'show', EPOCH + ':' + str(TARGET)])
assert not (BASE / 'plan-reader-before.tar.gz').exists()
with tarfile.open(BASE / 'plan-reader-before.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'qualify_plan_reader.py', TARGET, Path('MEMORY.md'),
            Path('docs/tasks/TYPE-REFERENCE-BOOK.md'), Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')):
        archive.add(path, arcname=str(path), recursive=False)


def run(label, current=False):
    argv = ['bash', 'tools/run_python_project_data.sh', str(TARGET)]
    if current:
        argv.append('--current')
    (BASE / (label + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    (BASE / (label + '-exit.txt')).write_text(str(child.returncode) + '\n')
    return child


refused = run('old-plan-reader')
assert refused.returncode == 1 and b'AssertionError' in refused.stderr
assert b'Status: `pending`' in refused.stderr, 'retain the exact current-state refusal'
source = old.decode()
substitutions = []


def replace(before, after):
    global source
    assert source.count(before) == 1, before
    source = source.replace(before, after)
    substitutions.append(dict(before=before, after=after))


replace('import hashlib\n', 'import argparse\nimport hashlib\n')
replace("PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'\n", """PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
EPOCH = '36428fa1288d9da3fe00628ca0ab734b940bc023'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--current', action='store_true', help='Check the original live plan boundary instead of its accepted historical epoch.')
CURRENT = parser.parse_args().current


def state_text(name):
    if CURRENT:
        return Path(name).read_text()
    return subprocess.check_output(['git', 'show', EPOCH + ':' + name]).decode()

""")
replace('current = Path(PART).read_text()', 'current = state_text(PART)')
replace("Path('docs/tasks/TYPE-REFERENCE-BOOK.md').read_text()", "state_text('docs/tasks/TYPE-REFERENCE-BOOK.md')")
replace("Path('MEMORY.md').read_text()", "state_text('MEMORY.md')")
replace('current_frontier_agrees=True, git_inputs_recover=True,', "state_mode='current-boundary' if CURRENT else 'historical', input_epoch='worktree' if CURRENT else EPOCH,\n    frontier_agrees_in_selected_epoch=True, git_inputs_recover=True,")
TARGET.write_text(source)
(BASE / 'plan-reader-after.py.gz').write_bytes(gzip.compress(source.encode(), mtime=0))
healthy = run('historical-plan-reader')
assert healthy.returncode == 0 and not healthy.stderr
result = json.loads(healthy.stdout)
assert result['result'] == 'PASS' and result['state_mode'] == 'historical' and result['input_epoch'] == EPOCH
current = run('current-plan-reader', True)
assert current.returncode == 1 and b'Status: `pending`' in current.stderr
qualified = dict(result='PASS', accepted_epoch=EPOCH, old_default='RED: actual pending-to-blocked source handoff',
    historical_default='GREEN at accepted epoch', explicit_current='RED: original live boundary no longer holds',
    old_sha256=hashlib.sha256(old).hexdigest(), new_sha256=hashlib.sha256(source.encode()).hexdigest(), substitutions=substitutions,
    limits='Historical plan input/state qualification only. Original accepted source, checks and claims retained; no runtime/native/publication admission.')
(BASE / 'plan-reader-qualification.json').write_text(json.dumps(qualified, indent=2) + '\n')
path = Path('docs/checkpoints/perl-helper-path-plan-2026-11-17/REVIEW.md')
text = path.read_text()
text += '''
November17 handoff qualification: the original reader at accepted36428fa1 checks
the live task status/frontier/MEMORY and refuses after ordinary pointer movement.
The actual source/inputs/refusal are retained under
`docs/checkpoints/artifact-review-2026-11-17/`. Historical recovery now defaults
to that accepted epoch; optional `--current` checks whether the original live
boundary still holds. Old default RED/new historical GREEN/current RED remain
distinct. Original producer, before-images, observations and claim values stay
unchanged; this is a recovery-reader scope correction, not a new plan/runtime
verdict. See the later checkpoint's `plan-reader-qualification.json`.
'''
path.write_text(text)
claim_path = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.37.json')
record = json.loads(claim_path.read_bytes())
record['claims'].append(dict(name='historical-helper-plan-reader-scope',
    statement='The original plan reader refuses the real pending-to-blocked handoff. Default recovery now passes at accepted36428fa1 while explicit current-boundary mode remains RED; original inputs and claims are preserved.',
    scope='Only historical plan/source/status/frontier/MEMORY scope. No new source classification, runtime, native, graph or publication admission.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py',
        granularity='Actual original refusal, exact old/new reader bodies, accepted historical plan state and distinct current-boundary check.', result=json.dumps({k: v for k, v in qualified.items() if k != 'substitutions'}, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Historical plan recovery requires the current task/MEMORY to retain its old status, or historical success could silently bless the changed live boundary.',
        oracle='Accepted Git plan state versus actual current blocked source status; unchanged original reader and explicit current calibration.',
        red_control='Actual original default refuses at the pending-status assertion. New historical default passes; --current retains the same RED instead of treating current state as historical success.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Actual original reader/current inputs frozen before the refusal; exact qualified reader before new use, commands/full channels, accepted Git inputs and old/new hashes retained. Full external Python/Git/library/native/physical/outer-first-use/per-read/source-origin closure remains4.2/SESSION5.')))
claim_path.write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({k: v for k, v in qualified.items() if k != 'substitutions'}, sort_keys=True))
