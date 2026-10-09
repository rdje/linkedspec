"""One finite aggregate admission; preserve prior policy and history bytes."""
import argparse
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = 'bece12874183477b6e601dd122cb1c39119b613e'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
ADR = 'docs/decisions/0130-finite-engineering-notes-aggregate.md'
NOTE = ('## 2026-10-09 — Finite engineering-notes aggregate admission\n\n'
        'ADR0130 admits one bounded hot-shard allowance of512 aggregate lines. Root, '
        'per-file, bytes, membership and immutable history remain exact; no archive '
        'reserve is granted. The indexed decision accounts for its own exact collection '
        'overhead. Retained independent reconstruction and actual threshold/authority '
        'controls precede exact staged canonical admission.\n\n').encode()
CHANGE = ('## 2026-10-09 — Finite engineering-notes aggregate capacity\n\n'
          'Admit engineering_notes aggregate29000→29512 under ADR0130, plus only '
          'the new decision and its exact aggregate-line overhead. Existing history '
          'and all other controls remain exact; retained independent/production '
          'controls and canonical receipt govern admission.\n\n').encode()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return (ROOT / path).read_bytes()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def original(path):
    return git('show', BASE + ':' + path)


def compact(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def write(path, value):
    (ROOT / path).write_text(json.dumps(value, indent=2) + '\n')


def base_paths(directory):
    return git('ls-tree', '-r', '--name-only', BASE, '--', directory).decode().splitlines()


def metrics(paths, fetch):
    raw = {p: fetch(p) for p in paths}
    return {'files': len(raw), 'lines': sum(b.count(b'\n') for b in raw.values()),
            'bytes': sum(map(len, raw.values()))}


def apply():
    assert git('rev-parse', 'HEAD').decode().strip() == BASE
    assert not (ROOT / ADR).exists() and not (ROOT / (PREFIX + 'plan.json')).exists()
    for path, note in [('DEVELOPMENT_NOTES.md', NOTE), ('CHANGES.md', CHANGE)]:
        raw = original(path)
        assert read(path) == raw
        first = re.search(rb'^## ', raw, re.M).start()
        (ROOT / path).write_bytes(raw[:first] + note + raw[first:])
    assert read(REGISTRY) == original(REGISTRY) and read(INDEX) == original(INDEX)
    old = [json.loads(line) for line in original(REGISTRY).splitlines()]
    new = copy.deepcopy(old)
    old_by_id = {r['id']: r for r in old if 'id' in r}
    by_id = {r['id']: r for r in new if 'id' in r}
    by_id['engineering_notes']['limits']['max_total_lines'] += 512
    by_id['decisions']['limits']['max_files'] += 1
    index_row = ('| [0130](0130-finite-engineering-notes-aggregate.md) | One bounded '
                 'hot-shard aggregate allowance; exact decision overhead | 2026-10-09 | '
                 'accepted engineering maintenance; canonical admission required | '
                 'history, capacity, verification |\n').encode()
    (ROOT / INDEX).write_bytes(original(INDEX) + index_row)

    def decision():
        text = ('# ADR 0130: Finite engineering-notes aggregate capacity\n\n'
                '- Date: 2026-10-09\n'
                f'- Status: accepted engineering maintenance under `{LEAF}`; exact canonical admission required\n'
                '- Tags: history, capacity, continuity, verification\n\n')
        for surface in ('engineering_notes', 'decisions'):
            text += (f'## Exact {surface} authorization\n\n'
                     f'- Routed surface: `{surface}`\n'
                     f'- Previous routed limits: `{compact(old_by_id[surface]["limits"])}`\n'
                     f'- New routed limits: `{compact(by_id[surface]["limits"])}`\n\n')
        return (text + '## Context and decision\n\n'
                'The clean engineering-notes collection uses all29,000 admitted aggregate lines. '
                'Removing two redundant mutable separators admitted the preceding correction; '
                'further required records need an explicit finite decision. Existing routing '
                'already reaches the canonical owner, and immutable accepted history cannot '
                'be shortened, rewritten or repacked to manufacture space.\n\n'
                'Under the current full-PNT engineering instruction, following ADR0128/0129, '
                'admit exactly512 aggregate lines: one existing bounded hot-shard line allowance. '
                'This is an engineering maintenance decision, not a reused or newly asserted '
                'director grant. The decision collection admits only this one file and the '
                'exact lines of this record plus its index row.\n\n'
                'Every other registry value stays exact, including engineering-note membership, '
                'manifest, byte, per-file and root limits. No new archive member is admitted. '
                'Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under '
                'ADR0069. A future rollover or exhausted allowance requires its own finite '
                'decision; this does not authorize unlimited PNT growth.\n\n'
                '## Verification\n\n'
                'Independent Git-backed reconstruction preserves every prior history and decision '
                'byte. Actual unchanged production threshold functions reject the new note under '
                'the old aggregate ceiling and reject a value above the new ceiling. Exact indexed '
                'accepted-authority controls distinguish missing and mismatched decisions. '
                'Normal doctrines and exact staged canonical CI/receipt govern landing. '
                'Existing public documentation already describes these authority rules; parser, '
                'runtime, tests, dependencies and checker implementations are unchanged.\n\n'
                f'Owner: docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md. Retained producer/review: `{PREFIX}capacity.py`; '
                f'plan and actual controls: `{PREFIX}plan.json`, `{PREFIX}controls.json`.\n').encode()

    prior_decisions = base_paths('docs/decisions')
    prior_lines = metrics(prior_decisions, original)['lines']
    for _ in range(5):
        raw = decision()
        target = prior_lines + raw.count(b'\n') + index_row.count(b'\n')
        if by_id['decisions']['limits']['max_total_lines'] == target:
            break
        by_id['decisions']['limits']['max_total_lines'] = target
    else:
        raise AssertionError('decision overhead did not converge')
    (ROOT / ADR).write_bytes(raw)
    (ROOT / REGISTRY).write_text(''.join(compact(row) + '\n' for row in new))
    preserved = base_paths('docs/history/development-notes') + base_paths('docs/history/changes')
    preserved += [p for p in prior_decisions if p != INDEX]
    plan = {'base': BASE, 'old_registry_sha256': sha(original(REGISTRY)),
            'new_registry_sha256': sha(read(REGISTRY)),
            'old_limits': {s: old_by_id[s]['limits'] for s in ('engineering_notes', 'decisions')},
            'new_limits': {s: by_id[s]['limits'] for s in ('engineering_notes', 'decisions')},
            'preserved': {p: sha(original(p)) for p in preserved},
            'index_row': index_row.decode(), 'producer_sha256': sha(read(PREFIX + 'capacity.py'))}
    write(PREFIX + 'plan.json', plan)
    print('Finite plan published: exactly three registry scalars; no archive or immutable byte changed.')


def review():
    plan = json.loads(read(PREFIX + 'plan.json'))
    old = [json.loads(line) for line in original(REGISTRY).splitlines()]
    new = [json.loads(line) for line in read(REGISTRY).splitlines()]
    expected = copy.deepcopy(old)
    rows = {r['id']: r for r in expected if 'id' in r}
    rows['engineering_notes']['limits']['max_total_lines'] = 29512
    rows['decisions']['limits']['max_files'] = 131
    decisions = base_paths('docs/decisions') + [ADR]
    rows['decisions']['limits']['max_total_lines'] = metrics(decisions, read)['lines']
    assert new == expected, 'only exact three scalar admission changes'
    assert plan['base'] == BASE and sha(original(REGISTRY)) == plan['old_registry_sha256']
    assert sha(read(REGISTRY)) == plan['new_registry_sha256'], 'retained new registry identity'
    assert plan['producer_sha256'] == sha(read(PREFIX + 'capacity.py')), 'retained actual producer identity'
    preserved = base_paths('docs/history/development-notes') + base_paths('docs/history/changes')
    preserved += [p for p in base_paths('docs/decisions') if p != INDEX]
    assert set(plan['preserved']) == set(preserved), 'complete prior immutable population'
    for p in preserved:
        assert sha(read(p)) == sha(original(p)) == plan['preserved'][p], p
    assert read(INDEX) == original(INDEX) + plan['index_row'].encode(), 'exact index addition'
    for p, note in [('DEVELOPMENT_NOTES.md', NOTE), ('CHANGES.md', CHANGE)]:
        raw = original(p)
        first = re.search(rb'^## ', raw, re.M).start()
        assert read(p) == raw[:first] + note + raw[first:], 'lossless current record insertion'
    notes = ['DEVELOPMENT_NOTES.md'] + base_paths('docs/history/development-notes')
    measured = {'engineering_notes': metrics(notes, read), 'decisions': metrics(decisions, read)}
    assert measured['engineering_notes']['lines'] == 29000 + NOTE.count(b'\n')
    args = ['perl', PREFIX + 'controls.pl']
    result = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    channel = lambda raw: {'base64': base64.b64encode(raw).decode(), 'sha256': sha(raw), 'bytes': len(raw)}
    write(PREFIX + 'control-command.json', {'args': args, 'exit_code': result.returncode,
          'stdout': channel(result.stdout), 'stderr': channel(result.stderr)})
    assert result.returncode == 0 and not result.stderr, result.stderr
    controls = json.loads(read(PREFIX + 'controls.json'))
    assert controls['production_sha256'] == sha(read('scripts/check_readme_routing_pressure.pl'))
    assert controls['instrument_sha256'] == sha(read(PREFIX + 'controls.pl'))
    assert controls['measured'] == measured
    write(PREFIX + 'verification.json', {'result': 'PASS', 'base': BASE,
          'preserved_files': len(preserved), 'preserved_bytes': sum(len(read(p)) for p in preserved),
          'measured': measured, 'controls': controls, 'producer_sha256': sha(read(PREFIX + 'capacity.py'))})
    print('Independent finite reconstruction PASS:', len(preserved), 'preserved files;', measured)


parser = argparse.ArgumentParser()
parser.add_argument('mode', choices=['apply', 'review'])
globals()[parser.parse_args().mode]()
