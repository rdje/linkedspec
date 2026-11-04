"""Read-only publication predicates; recorded push commands are never executed."""
import ast
import base64
import contextlib
from functools import lru_cache
import hashlib
import io
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
INITIAL = 'cd3b6adc3e58fb64283ae4ae4a5a37823eabd891'
BASE = '2ac834913d85c32f532be9b0aab63644838a577a'
PUBLISHED = 'd3a26a94f5c2efba736806ac13911155e3739995'
BUDGET = 1536 * 1024 * 1024
TEMPORARY = 'refs/heads/codex/upload-backlog-' + PUBLISHED[:12]
PREFIX = 'docs/checkpoints/task-acceptance-backend-scope/'


def require(condition, reason):
    if not condition:
        raise ValueError(reason)


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(),
            'base64': base64.b64encode(raw).decode()}


def decode(image):
    raw = base64.b64decode(image['base64'])
    require(packet(raw) == image, 'packet identity')
    return raw


def git(*args):
    require(args[0] in ('rev-list', 'rev-parse', 'cat-file', 'merge-base', 'ls-remote', 'version'),
            'non-readonly Git command')
    return subprocess.check_output(['git', *args], cwd=ROOT)


@lru_cache(maxsize=8)
def first_parents(base, target):
    return tuple(git('rev-list', '--first-parent', '--reverse', base + '..' + target).decode().splitlines())


def bounded_size(value):
    require(type(value) is int and 0 < value < BUDGET, 'strict pack budget')


def initial_plan(plan):
    require(plan['remote_base'] == BASE and plan['head'] == INITIAL, 'initial endpoint identity')
    require(type(plan['limit_bytes']) is int and plan['limit_bytes'] == BUDGET, 'budget identity')
    sequence = first_parents(BASE, INITIAL)
    positions = {oid: number for number, oid in enumerate((BASE, *sequence))}
    previous, at = BASE, 0
    require(bool(plan['batches']), 'empty batch population')
    for row in plan['batches']:
        require(row['base'] == previous, 'broken batch chain')
        require(row['target'] in positions and positions[row['target']] > at, 'nonforward target')
        next_at = positions[row['target']]
        require(type(row['commits']) is int and row['commits'] == next_at - at, 'initial group count')
        bounded_size(row['pack_bytes'])
        previous, at = row['target'], next_at
    require(previous == INITIAL and at == len(sequence), 'incomplete initial endpoint')
    return len(sequence)


def final_plan(initial, final):
    """Preserve raw historical fields; derive current execution fields separately."""
    initial_plan(initial)
    require(final['remote_base'] == BASE and final['head'] == INITIAL, 'raw initial anchor identity')
    require(final['limit_bytes'] == BUDGET, 'budget identity')
    require(len(final['batches']) == len(initial['batches']), 'final batch population')
    sequence = first_parents(BASE, PUBLISHED)
    positions = {oid: number for number, oid in enumerate((BASE, *sequence))}
    previous, at, rows = BASE, 0, []
    for number, (old, raw) in enumerate(zip(initial['batches'], final['batches'])):
        last = number == len(initial['batches']) - 1
        require(raw['base'] == old['base'] == previous, 'broken final chain')
        require(raw['target'] == (PUBLISHED if last else old['target']), 'final target identity')
        require(type(raw['commits']) is int and raw['commits'] == old['commits'],
                'raw original grouping identity')
        bounded_size(raw['pack_bytes'])
        require(raw['target'] in positions and positions[raw['target']] > at, 'nonforward final target')
        next_at = positions[raw['target']]
        rows.append({'base': previous, 'target': raw['target'],
                     'original_group_commits': old['commits'],
                     'runtime_range_commits': next_at - at,
                     'raw_plan_pack_bytes': raw['pack_bytes']})
        previous, at = raw['target'], next_at
    require(previous == PUBLISHED and at == len(sequence), 'incomplete published endpoint')
    return {'published_head': PUBLISHED, 'initial_head_anchor': INITIAL,
            'runtime_commits': len(sequence), 'ranges': rows}


def publication(record):
    initial = json.loads(decode(record['initial_plan']))
    final = json.loads(decode(record['final_plan']))
    session = json.loads(decode(record['session']))
    require(session == {'head': PUBLISHED, 'temporary_ref': TEMPORARY, 'initial_main': BASE},
            'publication session identity')
    normalized = final_plan(initial, final)
    events = [json.loads(line) for line in decode(record['events']).splitlines()]
    targets = [('seed', BASE, TEMPORARY)]
    targets += [(f'batch-{number:02}', row['target'], TEMPORARY)
                for number, row in enumerate(final['batches'], 1)]
    targets += [('main', PUBLISHED, 'refs/heads/main'), ('cleanup', None, TEMPORARY)]
    require(len(events) == len(targets), 'event population')
    command_prefix = ['git', '-c', 'push.followTags=false', 'push', '--porcelain', '--recurse-submodules=no']
    for event, (label, tip, ref) in zip(events, targets):
        require(event['label'] == label and event['returncode'] == 0, 'event order/outcome')
        require(event['remote_ref'] == ref and event['remote_tip'] == tip, 'observed remote identity')
        if label == 'cleanup':
            command = command_prefix + ['--force-with-lease=' + TEMPORARY + ':' + PUBLISHED,
                                        'origin', ':' + TEMPORARY]
        else:
            command = command_prefix + ['origin', tip + ':' + ref]
        require(event['command'] == command, 'actual push command identity')
        raw = decode(record['logs'][event['log']])
        require(hashlib.sha256(raw).hexdigest() == event['sha256'], 'actual push log identity')
        require(b'pre-push: reusing canonical local-CI receipt for exact committed HEAD' in raw
                and b'pre-push: canonical boundary verified' in raw, 'normal push hook evidence')
        if label.startswith('batch-'):
            bounded_size(event['measured_non_thin_pack_bytes'])
        else:
            require(event['measured_non_thin_pack_bytes'] is None, 'nondata size declaration')
    receipt = ['version=1', 'state=committed', 'head=' + PUBLISHED,
               'content=' + git('rev-parse', PUBLISHED + '^{tree}').decode().strip(),
               'gate=tools/run_ci_local.sh']
    require(decode(record['canonical_receipt']) == ('\n'.join(receipt) + '\n').encode(),
            'historical canonical receipt identity')
    remote = record['fresh_remote']
    require(remote['command'] == ['git', 'ls-remote', '--refs', 'origin', 'refs/heads/main', TEMPORARY]
            and remote['returncode'] == 0, 'fresh remote command/outcome')
    require(decode(remote['stdout']).decode().splitlines() == [PUBLISHED + '\trefs/heads/main'],
            'fresh final remote identity')
    return normalized


def original_equality_red():
    """Execute only the original split function, with controlled measurement IO."""
    source = (HERE / 'original-planner.py.txt').read_text()
    tree = ast.parse(source)
    function, = [node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == 'split']
    isolated = ast.Module(body=[function], type_ignores=[])
    scope = {'limit': BUDGET, 'plan': [], 'json': json,
             'measure': lambda previous, target: BUDGET}
    exec(compile(isolated, 'original-planner.py.txt:split', 'exec'), scope)
    with contextlib.redirect_stdout(io.StringIO()) as output:
        scope['split']('controlled-base', ['controlled-target'])
    require(len(scope['plan']) == 1 and scope['plan'][0]['pack_bytes'] == BUDGET,
            'original equality control did not reach legacy acceptance')
    try:
        bounded_size(scope['plan'][0]['pack_bytes'])
    except ValueError as error:
        require(str(error) == 'strict pack budget', 'unrelated equality refusal')
    else:
        raise ValueError('strict equality defect remains')
    return {'legacy_accepted_equal_budget': True, 'current_validator_rejected': True,
            'original_stdout': output.getvalue(), 'actual_network_operation': False}
