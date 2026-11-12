"""Recover the failed landing, exact book routing and unchanged owner-schema proof."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
CI = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
TREE = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
CHECKER = 'tools/check_claim_verification.py'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.30'


def recover(path, identities):
    result = {}
    with tarfile.open(path) as packed:
        assert len(packed.getnames()) == len(identities)
        for member in packed:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts and member.name not in result
            body = packed.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive bytes'
            assert member.mode & 0o777 == row['mode'], 'archive full mode'
            result[member.name] = body
    assert result.keys() == identities.keys()
    return result


def parent(body):
    start = body.index(('- ID: `' + OWNER + '`').encode())
    end = body.index(b'\n- ID:', start + 1)
    return body[start:end]


def validate(before, after, log, observations):
    assert len(before[CI].splitlines()) == 2074 and len(after[CI].splitlines()) == 2048, 'CI line boundary'
    start = before[CI].index(b'### Outgoing publication byte budget\n')
    end = before[CI].index(b'### Task-evidence coverage\n', start)
    section = before[CI][start:end]
    assert len(section.splitlines()) == 26
    routed = section.replace(b'### Outgoing publication byte budget', b'## Outgoing publication byte budget', 1)
    assert routed in after[WORKFLOW], 'complete routed section'
    assert b'documentation-workflow.md#outgoing-publication-byte-budget' in after[CI], 'CI navigation'
    pointer = b' Publish earlier when the [outgoing byte budget](documentation-workflow.md#outgoing-publication-byte-budget) requires it.'
    assert after[CI].replace(pointer, b'', 1) == before[CI][:start] + before[CI][end:], 'only CI routing change'
    expected_workflow = before[WORKFLOW].replace(b'## Publishing a measured result\n', routed + b'## Publishing a measured result\n', 1)
    note = 'A claim’s repair task uses status `pending`, `active`, or `blocked`. Use `active`\nwhile that repair work is in progress.\n\n'.encode()
    assert after[WORKFLOW].replace(note, b'', 1) == expected_workflow, 'only workflow routing and schema note'
    assert parent(after[TREE]) == parent(before[TREE]).replace(b'  Status: `in_progress`', b'  Status: `active`', 1), 'only parent status change'
    assert before[CHECKER] == after[CHECKER] and before[REGISTRY] == after[REGISTRY], 'contracts unchanged'
    assert log.count(b'  PASS  ') == 8 and log.count(b'  FAIL  ') == 2, 'original failure custody'
    assert b'local-ci-and-regression.md lines 2074/2048' in log and b'gap repair owner is not open: TYPE-REFERENCE-BOOK.1.2.23.4.30' in log
    assert observations['original_in_progress']['accepted'] is False and observations['original_in_progress']['owner_matches'] == [False], 'original owner RED'
    assert observations['corrected_active'] == dict(accepted=True, owner_matches=[True]), 'fixed owner GREEN'
    assert observations['closed_control']['accepted'] is False and observations['closed_control']['owner_matches'] == [False], 'closed owner RED'


repair = BASE / 'landing-repair'
before = recover(repair / 'before.tar.gz', json.loads((repair / 'before.json').read_bytes()))
after = recover(repair / 'after.tar.gz', json.loads((repair / 'after.json').read_bytes()))
original = recover(BASE / 'landing-pressure/inputs-before-repair.tar.gz', json.loads((BASE / 'landing-pressure/identities.json').read_bytes()))
assert original[CI] == before[CI] and original[WORKFLOW] == before[WORKFLOW]
log = original['.linkedspec-data/publication-size-monitor-commit.log']
assert log == gzip.decompress((BASE / 'landing-pressure/first-failed-commit-combined.log.gz').read_bytes())
probe = BASE / 'owner-status'
inputs = recover(probe / 'inputs-before-use.tar.gz', json.loads((probe / 'identities.json').read_bytes()))
assert inputs[CHECKER] == before[CHECKER] == original[CHECKER]
result = json.loads((probe / 'result.json').read_bytes())
assert result['actual_production_parser'] == 'PASS'
assert result == json.loads(gzip.decompress((BASE / 'launches/probe-owner-status/stdout.log.gz').read_bytes()))
observations = result['observations']
validate(before, after, log, observations)
routes = [json.loads(line) for line in after[REGISTRY].splitlines()]
diagnostics = next(row for row in routes if row.get('id') == 'diagnostics')
for name in diagnostics['members']:
    assert len(after[name].splitlines()) <= diagnostics['limits']['max_lines_per_file']
    assert len(after[name]) <= diagnostics['limits']['max_bytes_per_file']
assert sum(len(after[name].splitlines()) for name in diagnostics['members']) <= diagnostics['limits']['max_total_lines']
assert sum(len(after[name]) for name in diagnostics['members']) <= diagnostics['limits']['max_total_bytes']
public = next(row for row in routes if row.get('id') == 'public_reference')
assert len(after[WORKFLOW].splitlines()) <= public['limits']['max_lines_per_file']
for tag in ('capture-landing', 'workflow-bindings', 'review-workflow-bindings', 'repair-landing', 'probe-owner-status'):
    folder = BASE / 'launches' / tag
    retained = recover(folder / 'inputs.tar.gz', json.loads((folder / 'identities.json').read_bytes()))
    command = json.loads((folder / 'command.json').read_bytes())
    assert all(name in retained for name in command['argv'] if name.endswith('.py'))
    assert (folder / 'exit.txt').read_text() == '0\n' and gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
controls = []
for label, mutation, reason in (
    ('lost routed command', lambda left, right, failed, observed: right.__setitem__(WORKFLOW, right[WORKFLOW].replace(b'/measure.py', b'/lost.py', 1)), 'complete routed section'),
    ('owner still in_progress', lambda left, right, failed, observed: observed.__setitem__('corrected_active', dict(accepted=False, owner_matches=[False])), 'fixed owner GREEN'),
    ('erased first failure', lambda left, right, failed, observed: failed.replace(b'  FAIL  ', b'  PASS  '), 'original failure custody'),
):
    left, right, observed = copy.deepcopy(before), copy.deepcopy(after), copy.deepcopy(observations)
    altered = mutation(left, right, log, observed)
    try:
        validate(left, right, altered if isinstance(altered, bytes) else log, observed)
    except AssertionError as error:
        assert str(error) == reason, 'wrong recovery rejection:' + label
        controls.append(label)
    else:
        raise AssertionError('ineffective recovery control:' + label)
print(json.dumps(dict(landing_recovery='PASS', original_normal_exit=1, original_passes=8, original_failures=2,
    ci_lines=2048, workflow_lines=len(after[WORKFLOW].splitlines()), complete_routed_lines=26,
    parent_status='active', unchanged_checker=True, unchanged_registry=True, recovery_controls=controls,
    scope='Historical exact source/log/full-mode routing and real parser RED/GREEN recovery. No current document freshness, measurement, SDK or checker replay.'), indent=2, sort_keys=True))
