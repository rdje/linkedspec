"""One finite history admission; apply once, review the bound tree on demand."""
import argparse
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = 'e7674382295936a1d6d3dbd34272d9c6803a269d'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/changes/manifest.jsonl'
ADR = 'docs/decisions/0129-producer-residual-change-history-capacity.md'
INDEX = 'docs/decisions/INDEX.md'
NOTE = (f'## 2026-10-08 — Finite residual-repair history ({LEAF})\n\n'
        'One exact clean-record suffix moves into governed history. ADR0129 admits '
        'one archive, its measured manifest row and one indexed decision; all other '
        'controls and prior bytes remain exact. Retained producers, reconstruction '
        'and actual authority denials precede staged canonical admission.\n\n').encode()


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


def write_json(path, value):
    (ROOT / path).write_text(json.dumps(value, indent=2) + '\n')


def channel(raw):
    return {'base64': base64.b64encode(raw).decode(), 'sha256': sha(raw), 'bytes': len(raw)}


def decode(value):
    raw = base64.b64decode(value['base64'], validate=True)
    assert sha(raw) == value['sha256'] and len(raw) == value['bytes']
    return raw


def command(args, watched):
    before = {path: sha(read(path)) for path in watched}
    result = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    after = {path: sha(read(path)) for path in watched}
    return {'args': args, 'exit_code': result.returncode,
            'stdout': channel(result.stdout), 'stderr': channel(result.stderr),
            'inputs_before': before, 'inputs_after': after}


def contract(row):
    keys = ('authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner',
            'route_targets', 'state', 'verifier')
    value = {key: row[key] for key in keys}
    value['transition_owners'] = row.get('transition', {}).get('owners')
    return value


def paths_at_base(directory):
    return git('ls-tree', '-r', '--name-only', BASE, '--', directory).decode().splitlines()


def apply():
    assert git('rev-parse', 'HEAD').decode().strip() == BASE
    assert not (ROOT / (PREFIX + 'plan.json')).exists(), 'one-shot producer already ran'
    for path in ('CHANGES.md', MANIFEST, REGISTRY, INDEX):
        assert read(path) == original(path), 'unmodified bound input: ' + path
    old_root = read('CHANGES.md')
    first = re.search(rb'^## ', old_root, re.M).start()
    (ROOT / 'CHANGES.md').write_bytes(old_root[:first] + NOTE + old_root[first:])
    watched = ['tools/roll_document_history.pl', 'CHANGES.md', MANIFEST]
    red = command(['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check'], watched)
    assert red['exit_code'] != 0 and b'rollover required' in decode(red['stderr'])
    assert red['inputs_before'] == red['inputs_after']
    rollover = command(['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--apply'], watched)
    assert rollover['exit_code'] == 0 and decode(rollover['stderr']) == b''
    rows = [json.loads(line) for line in read(MANIFEST).splitlines()]
    old_rows = [json.loads(line) for line in original(REGISTRY).splitlines()]
    new_rows = copy.deepcopy(old_rows)
    old_change = next(row for row in old_rows if row.get('id') == 'change_history')
    new_change = next(row for row in new_rows if row.get('id') == 'change_history')
    new_change['limits']['max_files'] += 1
    new_change['member_limits'][MANIFEST] = {'max_bytes': len(read(MANIFEST)), 'max_lines': len(rows)}
    old_decisions = next(row for row in old_rows if row.get('id') == 'decisions')
    new_decisions = next(row for row in new_rows if row.get('id') == 'decisions')
    new_decisions['limits']['max_files'] += 1
    new_decisions['limits']['max_total_lines'] = old_decisions['limits']['max_total_lines']
    index_row = ('| [0129](0129-producer-residual-change-history-capacity.md) | One finite '
                 'change-history rollover before producer-bound residual repair | 2026-10-08 | '
                 'accepted engineering maintenance; canonical admission required | history, capacity, verification |\n')
    (ROOT / INDEX).write_bytes(original(INDEX) + index_row.encode())

    def decision_text():
        return ('# ADR 0129: Finite change-history capacity for producer-bound residual repair\n\n'
                '- Date: 2026-10-08\n'
                f'- Status: accepted engineering maintenance under `{LEAF}`; exact canonical admission required\n'
                '- Tags: history, capacity, continuity, verification\n\n'
                '## Exact change-history authorization\n\n'
                '- Routed surface: `change_history`\n'
                f'- Previous routed limits: `{compact(old_change["limits"])}`\n'
                f'- New routed limits: `{compact(new_change["limits"])}`\n'
                f'- Previous routed contract: `{compact(contract(old_change))}`\n'
                f'- New routed contract: `{compact(contract(new_change))}`\n\n'
                '## Exact decision-store prerequisite\n\n'
                '- Routed surface: `decisions`\n'
                f'- Previous routed limits: `{compact(old_decisions["limits"])}`\n'
                f'- New routed limits: `{compact(new_decisions["limits"])}`\n\n'
                '## Context and decision\n\n'
                'The clean change root is 58,959 bytes, 23 bytes below mandatory rollover. '
                'The admitted 47-member collection and 46-row manifest are full. '
                'The next complete maintenance record requires rollover under ADR0069. '
                'Routing already points to the correct canonical owner. Removing or rewriting '
                'accepted history cannot meet its retention contract.\n\n'
                'Under the current autonomous full-PNT instruction, follow ADR0128 and admit '
                'one archive member, the actual manifest row and this one indexed decision. '
                'This is an engineering maintenance decision, not a new explicit director grant. '
                'The exact old/new objects above authorize only five scalar changes. '
                'Root, per-segment and aggregate history ceilings, thresholds, ownership, '
                'lifecycle and every other registry value remain unchanged.\n\n'
                f'The governed rollover archives clean `{BASE}` lines '
                f'{rows[1]["source_start_line"]}–{rows[1]["source_end_line"]}, '
                f'{rows[1]["line_count"]} lines / {rows[1]["byte_count"]} bytes, '
                f'SHA-256 `{rows[1]["sha256"]}`. All prior archives, row bytes and accepted '
                'decisions remain exact. Stable responsibility remains '
                '`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` under ADR0069.\n\n'
                '## Verification and consequences\n\n'
                'Actual pressure RED precedes governed rollover GREEN. Independent clean Git '
                'line/suffix/manifest reconstruction, effective evidence corruptions and actual '
                'production threshold/accepted-authority denials verify the finite admission. '
                'Normal doctrines, exact staged canonical CI, receipt and hooks are mandatory. '
                'No future reserve, runtime change, dependency write or verification waiver is granted. '
                'Public parser teaching is unchanged. Producer-bound residual selection follows '
                'only after a clean commit; interval mapping and independent replacement admission remain open.\n\n'
                f'Exact producer and channels: `{PREFIX}capacity.py`, `{PREFIX}plan.json`, '
                f'`{PREFIX}verification.json`; owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`.\n')

    (ROOT / ADR).write_text(decision_text())
    decision_paths = [p for p in (ROOT / 'docs/decisions').glob('*.md')]
    new_decisions['limits']['max_total_lines'] = sum(p.read_bytes().count(b'\n') for p in decision_paths)
    (ROOT / ADR).write_text(decision_text())
    assert sum(p.read_bytes().count(b'\n') for p in decision_paths) == new_decisions['limits']['max_total_lines']
    (ROOT / REGISTRY).write_text(''.join(compact(row) + '\n' for row in new_rows))
    prior = {row['target_path']: sha(original(row['target_path']))
             for row in [json.loads(line) for line in original(MANIFEST).splitlines()][1:]}
    decisions = {path: sha(original(path)) for path in paths_at_base('docs/decisions')
                 if path.endswith('.md') and path != INDEX}
    write_json(PREFIX + 'plan.json', {
        'base': BASE, 'source_blob': git('rev-parse', BASE + ':CHANGES.md').decode().strip(),
        'base_inputs': {path: channel(original(path)) for path in ('CHANGES.md', MANIFEST, REGISTRY, INDEX)},
        'prior_archives': prior, 'prior_decisions': decisions, 'note': channel(NOTE),
        'new_row': rows[1], 'red': red, 'rollover': rollover,
        'old_change': old_change, 'new_change': new_change,
        'old_decisions': old_decisions, 'new_decisions': new_decisions,
        'producer_sha256': sha(Path(__file__).read_bytes())})
    print('Actual rollover RED/GREEN retained; exact finite ADR and registry created.')


def review():
    plan = json.loads(read(PREFIX + 'plan.json'))
    for path, snapshot in plan['base_inputs'].items():
        assert decode(snapshot) == original(path), 'recoverable original input: ' + path
    assert plan['producer_sha256'] == sha(Path(__file__).read_bytes())
    watched = [PREFIX + 'controls.pl', PREFIX + 'plan.json', ADR, INDEX,
               'scripts/check_readme_routing_pressure.pl']
    actual_controls = command(['perl', PREFIX + 'controls.pl'], watched)
    write_json(PREFIX + 'controls-command.json', actual_controls)
    assert actual_controls['exit_code'] == 0 and decode(actual_controls['stderr']) == b''
    assert actual_controls['inputs_before'] == actual_controls['inputs_after']
    observed = {path: read(path) for path in ['CHANGES.md', MANIFEST, REGISTRY, ADR, INDEX,
                plan['new_row']['target_path'], *plan['prior_archives'], *plan['prior_decisions']]}

    def verify(value):
        for path, digest in {**plan['prior_archives'], **plan['prior_decisions']}.items():
            assert sha(value[path]) == digest, 'prior immutable bytes: ' + path
        manifest = value[MANIFEST].splitlines(keepends=True)
        old_manifest = original(MANIFEST).splitlines(keepends=True)
        assert manifest[2:] == old_manifest[1:], 'prior manifest bytes/order'
        metadata = json.loads(manifest[0])
        old_metadata = json.loads(old_manifest[0])
        old_metadata['segment_count'] += 1
        assert metadata == old_metadata, 'single metadata count change'
        row = json.loads(manifest[1])
        assert row == plan['new_row'], 'actual row identity'
        source = original('CHANGES.md')
        lines = source.splitlines(keepends=True)
        archive = value[row['target_path']]
        assert archive == b''.join(lines[row['source_start_line'] - 1:row['source_end_line']]), 'exact source range'
        assert row['source_end_line'] == len(lines) and source.endswith(archive), 'complete clean suffix'
        assert sha(archive) == row['sha256'] and len(archive) == row['byte_count']
        assert archive.count(b'\n') == row['line_count']
        assert archive.startswith(b'## '), 'whole-record boundary'
        prefix = source[:-len(archive)]
        first = re.search(rb'^## ', prefix, re.M).start()
        expected = (prefix[:first] + NOTE + prefix[first:]).rstrip(b'\n') + b'\n'
        assert value['CHANGES.md'] == expected, 'exact retained prefix and new note'
        assert len(expected) <= 32768 and expected.count(b'\n') <= 256
        restored = value['CHANGES.md'].replace(NOTE, b'', 1)
        omitted = prefix[len(restored):]
        assert omitted.strip(b'\n') == b'' and restored + omitted + archive == source, 'full original reconstruction'
        registry = [json.loads(line) for line in value[REGISTRY].splitlines()]
        expected_rows = [json.loads(line) for line in original(REGISTRY).splitlines()]
        expected_changes = {'change_history': plan['new_change'], 'decisions': plan['new_decisions']}
        expected_rows = [expected_changes.get(row.get('id'), row) for row in expected_rows]
        assert registry == expected_rows, 'exact five finite scalars only'
        assert value[INDEX] == original(INDEX) + value[INDEX][len(original(INDEX)):]
        assert value[INDEX][len(original(INDEX)):].count(b'\n') == 1 and b'(0129-producer-residual-change-history-capacity.md)' in value[INDEX][len(original(INDEX)):]
        assert re.findall(rb'^- Status:(.*)$', value[ADR], re.M) == [
            f' accepted engineering maintenance under `{LEAF}`; exact canonical admission required'.encode()]
        for surface, old, new in [('change_history', plan['old_change'], plan['new_change']),
                                  ('decisions', plan['old_decisions'], plan['new_decisions'])]:
            assert f'- Routed surface: `{surface}`'.encode() in value[ADR]
            for name, limits in [('Previous', old['limits']), ('New', new['limits'])]:
                assert f'- {name} routed limits: `{compact(limits)}`'.encode() in value[ADR]
        for name, route in [('Previous', plan['old_change']), ('New', plan['new_change'])]:
            assert f'- {name} routed contract: `{compact(contract(route))}`'.encode() in value[ADR]
        for command_record in (plan['red'], plan['rollover']):
            decode(command_record['stdout'])
            decode(command_record['stderr'])

    verify(observed)
    controls = []
    for name, path, mutation in [
        ('root_byte', 'CHANGES.md', lambda raw: raw + b'x'),
        ('archive_byte', plan['new_row']['target_path'], lambda raw: b'x' + raw[1:]),
        ('prior_archive_byte', next(iter(plan['prior_archives'])), lambda raw: raw + b'x'),
        ('prior_decision_byte', next(iter(plan['prior_decisions'])), lambda raw: raw + b'x'),
        ('manifest_row_order', MANIFEST, lambda raw: b''.join(raw.splitlines(keepends=True)[:2] + list(reversed(raw.splitlines(keepends=True)[2:])))),
        ('missing_new_row', MANIFEST, lambda raw: b''.join(raw.splitlines(keepends=True)[:1] + raw.splitlines(keepends=True)[2:])),
        ('unaccepted_decision', ADR, lambda raw: raw.replace(b'- Status: accepted', b'- Status: proposed', 1)),
        ('missing_index', INDEX, lambda raw: original(INDEX)),
        ('extra_registry_scalar', REGISTRY, lambda raw: raw.replace(b'"max_files":48', b'"max_files":49', 1))]:
        mutant = dict(observed)
        mutant[path] = mutation(mutant[path])
        assert mutant[path] != observed[path], 'effective mutation: ' + name
        try:
            verify(mutant)
        except (AssertionError, KeyError, ValueError) as error:
            controls.append({'name': name, 'observed': 'RED', 'reason': str(error)})
        else:
            raise AssertionError('mutation admitted: ' + name)
    metrics = lambda population: {'files': len(population), 'lines': sum(raw.count(b'\n') for raw in population), 'bytes': sum(map(len, population))}
    history = metrics([observed['CHANGES.md'], observed[MANIFEST], observed[plan['new_row']['target_path']], *[observed[p] for p in plan['prior_archives']]])
    decisions = metrics([observed[ADR], observed[INDEX], *[observed[p] for p in plan['prior_decisions']]])
    assert decisions['files'] == plan['new_decisions']['limits']['max_files']
    assert decisions['lines'] == plan['new_decisions']['limits']['max_total_lines']
    assert history['files'] == plan['new_change']['limits']['max_files']
    assert history['lines'] <= plan['old_change']['limits']['max_total_lines']
    assert history['bytes'] <= plan['old_change']['limits']['max_total_bytes']
    write_json(PREFIX + 'verification.json', {'complete': True, 'base': BASE, 'history': history,
               'decisions': decisions, 'archive': plan['new_row'], 'evidence_red': controls,
               'input_hashes': {path: sha(raw) for path, raw in observed.items()},
               'producer_sha256': sha(Path(__file__).read_bytes())})
    print(f'Independent exact reconstruction PASS; {len(controls)} effective evidence RED; history {history}; decisions {decisions}.')


parser = argparse.ArgumentParser()
parser.add_argument('action', choices=('apply', 'review'))
args = parser.parse_args()
if args.action == 'apply':
    apply()
else:
    review()
