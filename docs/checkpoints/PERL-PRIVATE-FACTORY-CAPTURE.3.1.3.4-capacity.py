"""Finite one-member admission. Default review is readonly; writers are one-shot."""
import argparse
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '9085eb1e5075146ca00dab52304f85937cf7ea05'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REG = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
ADR = 'docs/decisions/0132-finite-change-history-member.md'
MANIFEST = 'docs/history/changes/manifest.jsonl'
CHANGE_RECORD = """## 2026-10-10 — One finite change-history rollover

ADR0132 admits one actual archive member, its exact manifest growth and only the sole new decision
overhead. Preserve every old immutable byte and the exact clean-source suffix; root, per-file and
aggregate limits remain unchanged. Restore accepted 0130/0131 index rows to the existing table with
their exact text; add only 0132. Independent reconstruction, actual threshold/authority REDs and
displaced-row/evidence controls precede exact staged canonical admission. Original 279 AST-call
inputs stay historical at 9085eb1e5; no runtime proof/hash refresh or future reserve. Guarded array end .3.1.3.2 resumes after the clean canonical commit.

""".encode()
NOTE_RECORD = """## 2026-10-10 — Bound the next change-history generation

The full change-history member/manifest limits and near-rollover root require one finite canonical
prerequisite. Keep exact clean-source suffix reconstruction and all older immutable bytes. Two
accepted index rows were appended below authoring instructions; move their unchanged text into the
table and reject a displaced-row counterfactual. Original 279 AST-call bindings remain historical
at 9085eb1e5. Canonical detail: docs/knowledge/guarded-ast-change-history-capacity.md.

""".encode()
INDEX_ROW = b'| [0132](0132-finite-change-history-member.md) | One finite change-history member and exact manifest/decision overhead | 2026-10-10 | accepted engineering maintenance; canonical admission required | history, capacity, verification |\n'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
TEACHING = """A new archive slot admits only one measured rollover.
Keep root, per-file and aggregate limits unchanged unless their own accepted authority changes.
Add decision-index rows inside the existing table, before its authoring instructions.
When repairing placement, retain accepted row text and decision files exactly.

""".encode()
MUTABLE = [REG, INDEX, MANIFEST, 'CHANGES.md', 'DEVELOPMENT_NOTES.md']
SUPPORT = ['scripts/check_readme_routing_pressure.pl', 'tools/roll_document_history.pl',
           'docs/linkedspec-book/src/development/documentation-workflow.md',
           'docs/linkedspec-book/src/development/local-ci-and-regression.md']


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return (ROOT / path).read_bytes()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def old(path):
    return git('show', BASE + ':' + path)


def compact(obj):
    return json.dumps(obj, sort_keys=True, separators=(',', ':'))


def save(tail, obj):
    (ROOT / (PREFIX + tail)).write_text(json.dumps(obj, indent=2) + '\n')


def load(tail):
    return json.loads(read(PREFIX + tail))


def channel(raw):
    return {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': sha(raw)}


def command(args):
    p = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return {'args': args, 'exit_code': p.returncode, 'stdout': channel(p.stdout), 'stderr': channel(p.stderr)}


def paths(directory):
    return git('ls-tree', '-r', '--name-only', BASE, '--', directory).decode().splitlines()


def population():
    return sorted(p for directory in ('docs/history/development-notes', 'docs/history/changes', 'docs/decisions')
                  for p in paths(directory) if p not in (INDEX, MANIFEST))


def metrics(names):
    raws = [read(p) for p in names]
    return {'files': len(raws), 'lines': sum(r.count(b'\n') for r in raws), 'bytes': sum(map(len, raws))}


def census():
    return {'change_history': metrics(['CHANGES.md', MANIFEST] +
                sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/history/changes').glob('*.md'))),
            'decisions': metrics(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/decisions').glob('*.md'))),
            'manifest': {'lines': read(MANIFEST).count(b'\n'), 'bytes': len(read(MANIFEST))}}


def contract(row):
    names = ('authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner', 'route_targets', 'state', 'verifier')
    return {**{k: row.get(k) for k in names}, 'transition_owners': row.get('transition', {}).get('owners')}


def insert(raw, addition):
    first = re.search(rb'^## ', raw, re.M).start()
    return raw[:first] + addition + raw[first:]


def expected_index():
    original = old(INDEX)
    marker = b'## How to add a record\n'
    assert original.count(marker) == 1
    begin = original.index(marker)
    misplaced = []
    for ident, basename in [('0130', '0130-finite-engineering-notes-aggregate.md'),
                            ('0131', '0131-finite-engineering-notes-member.md')]:
        rows = [line for line in original.splitlines(keepends=True)
                if line.startswith(('| [' + ident + '](' + basename + ') |').encode())]
        assert len(rows) == 1 and rows[0] in original[begin:], 'exact displaced accepted row'
        misplaced.append(rows[0])
    remaining = original
    for line in misplaced:
        remaining = remaining.replace(line, b'', 1)
    begin = remaining.index(marker)
    return remaining[:begin] + b''.join(misplaced) + INDEX_ROW + b'\n' + remaining[begin:]


def expected_book():
    raw = old(BOOK)
    marker = b'## Public book\n'
    assert raw.count(marker) == 1 and TEACHING not in raw
    return raw.replace(marker, TEACHING + marker, 1)


def rolled():
    """Independent complete-record selection from Git, without importing the roller."""
    raw = old('CHANGES.md')
    chunks = re.split(rb'(?=^## )', raw, flags=re.M)
    preamble, records = chunks[0], chunks[1:]
    keep = len(records)
    while keep:
        candidate = preamble + CHANGE_RECORD + b''.join(records[:keep])
        if len(candidate) <= 32768 and candidate.count(b'\n') <= 256:
            break
        keep -= 1
    assert keep, 'retain a current clean record'
    prefix = preamble + CHANGE_RECORD + b''.join(records[:keep])
    archive = b''.join(records[keep:])
    assert archive and raw.endswith(archive), 'exact clean source suffix'
    return re.sub(rb'\n{2,}\Z', b'\n', prefix), archive


def decision(before, after):
    text = ('# ADR 0132: One finite change-history archive member\n\n'
            '- Date: 2026-10-10\n'
            f'- Status: accepted engineering maintenance under `{LEAF}`; exact canonical admission required\n'
            '- Tags: history, capacity, continuity, verification\n\n')
    for surface in ('change_history', 'decisions'):
        text += (f'## Exact {surface} authorization\n\n- Routed surface: `{surface}`\n'
                 f'- Previous routed limits: `{compact(before[surface]["limits"])}`\n'
                 f'- New routed limits: `{compact(after[surface]["limits"])}`\n\n')
        if surface == 'change_history':
            text += (f'- Previous routed contract: `{compact(contract(before[surface]))}`\n'
                     f'- New routed contract: `{compact(contract(after[surface]))}`\n\n')
    return (text + '## Context and decision\n\n'
            'The clean change root is 58706 bytes, 276 bytes below mandatory rollover. The 48-member '
            'collection and 47-line/26831-byte manifest are full. The next complete maintenance '
            'record requires rollover under ADR0069; this separately owned canonical prerequisite '
            'retains that actual pressure RED before one exact generation.\n\n'
            'Under the current full-PNT instruction and ADR0128/0129/0131 engineering-maintenance '
            'precedent, admit exactly one additional archive member and only its measured manifest '
            'line/byte growth. This is an engineering decision, not a newly asserted or reused director '
            'grant. Existing routes already reach the correct owner; deleting, repacking or shortening '
            'immutable accepted history cannot lawfully create the missing slot.\n\n'
            'The decision collection admits only this sole new file and its exact line overhead plus '
            'one index row. Every other registry field stays exact: root, per-file, aggregate, byte '
            'and all unrelated surface controls. Stable storage responsibility remains '
            'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. No future member reserve is granted.\n\n'
            '## Verification and consequences\n\n'
            'Independently reconstruct the entire clean-source suffix, source blob/range/digest, '
            'current root and prior manifest rows. Preserve all prior immutable history/decision bytes. '
            'Execute unchanged production threshold and accepted/indexed/exact-object authority '
            'functions with actual measured inputs and distinguishing RED controls. Retain actual '
            'reviewer-corruption channels and all producer/input identities. Exact staged canonical '
            'CI/receipt and normal hooks govern landing; focused evidence alone admits no capacity.\n\n'
            'Move unchanged accepted 0130/0131 rows from below the index authoring instructions into its table, then add only 0132; retain all old prose and row bytes. Book teaching clarifies finite capacity and table placement. Parser/runtime, tests, '
            'checker implementations, dependency pins and other repositories are unchanged. '
            f'Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `{PREFIX}capacity.py review` '
            'through tools/run_python_project_data.sh. Guarded AST array-end .3.1.3.2 resumes after commit.\n').encode()


def expected_rows():
    rows = [json.loads(r) for r in old(REG).splitlines()]
    before = {r['id']: r for r in rows if 'id' in r}
    result = copy.deepcopy(rows)
    after = {r['id']: r for r in result if 'id' in r}
    after['change_history']['limits']['max_files'] += 1
    # Only exact canonical max_* fields are admitted, never measured-key aliases.
    after['change_history']['member_limits'][MANIFEST] = {
        'max_bytes': len(read(MANIFEST)), 'max_lines': read(MANIFEST).count(b'\n')}
    after['decisions']['limits']['max_files'] += 1
    prior_lines = sum(old(p).count(b'\n') for p in paths('docs/decisions'))
    for _ in range(5):
        raw = decision(before, after)
        target = prior_lines + raw.count(b'\n') + 1
        if after['decisions']['limits']['max_total_lines'] == target:
            return rows, result, before, after, raw
        after['decisions']['limits']['max_total_lines'] = target
    raise AssertionError('finite decision overhead did not converge')


def registry_bytes(before, after):
    return b''.join(raw if json.loads(raw) == row else (compact(row) + '\n').encode()
                    for raw, row in zip(before.splitlines(keepends=True), after))


def apply():
    assert git('rev-parse', 'HEAD').decode().strip() == BASE, 'exact clean activation'
    assert not (ROOT / ADR).exists() and not (ROOT / (PREFIX + 'plan.json')).exists(), 'one-shot admission'
    for p in MUTABLE:
        assert read(p) == old(p), 'apply starts before governed input writes: ' + p
    for p, addition in [('CHANGES.md', CHANGE_RECORD), ('DEVELOPMENT_NOTES.md', NOTE_RECORD)]:
        (ROOT / p).write_bytes(insert(old(p), addition))
    assert len(read('CHANGES.md')) > 58982, 'actual mandatory rollover'
    pressure = command(['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check'])
    save('pressure.json', pressure)
    assert pressure['exit_code'] != 0 and b'document-history rollover required for change_history:' in base64.b64decode(pressure['stdout']['base64']) + base64.b64decode(pressure['stderr']['base64']), 'actual pressure RED before rollover'
    roll = command(['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--apply'])
    save('rollover.json', roll)
    assert roll['exit_code'] == 0, roll
    old_rows, new_rows, before, after, adr = expected_rows()
    assert read(BOOK) == old(BOOK), 'book edit follows original preservation'
    (ROOT / BOOK).write_bytes(expected_book())
    (ROOT / ADR).write_bytes(adr)
    (ROOT / INDEX).write_bytes(expected_index())
    (ROOT / REG).write_bytes(registry_bytes(old(REG), new_rows))
    segment = json.loads(read(MANIFEST).splitlines()[1])['target_path']
    save('plan.json', {'base': BASE, 'preserved': {p: sha(old(p)) for p in population()},
         'original_inputs': {p: sha(old(p)) for p in MUTABLE + SUPPORT},
         'resulting_inputs': {p: sha(read(p)) for p in MUTABLE + SUPPORT + [ADR, segment]},
         'old_limits': {s: before[s]['limits'] for s in ('change_history', 'decisions')},
         'new_limits': {s: after[s]['limits'] for s in ('change_history', 'decisions')},
         'old_contract': contract(before['change_history']), 'new_contract': contract(after['change_history']),
         'segment': segment, 'measured': census(), 'producer_sha256': sha(Path(__file__).read_bytes())})
    print('One finite member/manifest decision prepared; canonical admission remains required.')


def verify_base():
    plan = load('plan.json')
    assert plan['base'] == BASE and plan['producer_sha256'] == sha(read(PREFIX + 'applied-capacity.py')), 'actual producer identity'
    assert set(plan['preserved']) == set(population()), 'complete prior immutable population'
    for p in population():
        assert plan['preserved'][p] == sha(old(p)) == sha(read(p)), 'original immutable identity: ' + p
    assert plan['original_inputs'] == {p: sha(old(p)) for p in MUTABLE + SUPPORT}, 'original input identities'
    root, archive = rolled()
    assert read('CHANGES.md') == root, 'complete current root reconstruction'
    assert read('DEVELOPMENT_NOTES.md') == insert(old('DEVELOPMENT_NOTES.md'), NOTE_RECORD), 'complete change record insertion'
    manifest = read(MANIFEST).splitlines(keepends=True)
    prior = old(MANIFEST).splitlines(keepends=True)
    header = json.loads(prior[0]); header['segment_count'] += 1
    assert json.loads(manifest[0]) == header and manifest[2:] == prior[1:], 'all prior manifest rows exact'
    segment = json.loads(manifest[1]); source = old('CHANGES.md')
    start = source[:-len(archive)].count(b'\n') + 1
    ident = f"{int(json.loads(prior[1])['segment_id']) - 1:04d}"
    target = 'docs/history/changes/segment-' + ident + '-' + sha(archive)[:12] + '.md'
    expected = {'byte_count': len(archive), 'current_path': 'CHANGES.md', 'immutable': True,
        'line_count': archive.count(b'\n'), 'retrieval_command': 'perl tools/read_document_history.pl --surface change_history --segment ' + ident,
        'segment_id': ident, 'sha256': sha(archive), 'source_blob': git('rev-parse', BASE + ':CHANGES.md').decode().strip(),
        'source_commit': BASE, 'source_end_line': start + archive.count(b'\n') - 1, 'source_path': 'CHANGES.md',
        'source_start_line': start, 'surface': 'change_history', 'target_path': target, 'type': 'segment'}
    assert segment == expected and read(target) == archive and plan['segment'] == target, 'exact clean source segment'
    assert len(manifest) == len(prior) + 1, 'exact one-member manifest growth'
    rows, new, before, after, adr = expected_rows()
    assert read(REG) == registry_bytes(old(REG), new), 'only exact finite registry changes'
    assert read(ADR) == adr and read(INDEX) == expected_index(), 'sole indexed decision and exact accepted row placement'
    assert plan['resulting_inputs'] == {p: sha(read(p)) for p in MUTABLE + SUPPORT + [ADR, target]}, 'resulting input identities'
    assert plan['measured'] == census(), 'actual complete census'
    assert plan['old_limits'] == {s: before[s]['limits'] for s in ('change_history', 'decisions')}, 'exact old limits'
    assert plan['new_limits'] == {s: after[s]['limits'] for s in ('change_history', 'decisions')}, 'exact new limits'
    assert plan['old_contract'] == contract(before['change_history']) and plan['new_contract'] == contract(after['change_history']), 'exact contract objects'
    assert read(BOOK) == expected_book(), 'exact finite-capacity and index-placement teaching'
    pressure = load('pressure.json')
    assert pressure['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']
    assert pressure['exit_code'] != 0 and b'document-history rollover required for change_history:' in base64.b64decode(pressure['stdout']['base64']) + base64.b64decode(pressure['stderr']['base64']), 'actual pre-rollover pressure RED'
    for c in (pressure['stdout'], pressure['stderr']):
        assert channel(base64.b64decode(c['base64'])) == c
    roll = load('rollover.json')
    assert roll['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--apply']
    assert roll['exit_code'] == 0 and b'archived' in base64.b64decode(roll['stdout']['base64']), 'actual rollover channel'
    for c in (roll['stdout'], roll['stderr']):
        raw = base64.b64decode(c['base64']); assert channel(raw) == c, 'complete rollover channel identity'
    return plan


def run_controls():
    return command(['perl', PREFIX + 'controls.pl'])


def capture():
    assert not (ROOT / (PREFIX + 'controls.json')).exists(), 'one-shot capture'
    verify_base()
    result = run_controls()
    save('controls.json', result)
    assert result['exit_code'] == 0 and result['stderr']['bytes'] == 0, result
    print('Actual production threshold/authority channels retained.')


def review():
    plan = verify_base()
    stored = load('controls.json')
    assert stored == run_controls(), 'complete actual production control replay'
    controls = json.loads(base64.b64decode(stored['stdout']['base64']))
    assert controls['measured'] == plan['measured'], 'actual control census'
    assert len(controls['thresholds']) == 30 and len(controls['authority']) == 23, 'complete distinguishing control population'
    print('Finite capacity review PASS:', len(plan['preserved']), 'immutable files;30 thresholds/23 authority REDs.')


def evidence():
    assert not (ROOT / (PREFIX + 'evidence.json')).exists(), 'one-shot reviewer evidence'
    original = read(PREFIX + 'plan.json'); original_index = read(INDEX); plan = json.loads(original); rows = []
    try:
        for name in ('missing_history_member', 'forged_original_hash', 'forged_resulting_hash', 'displaced_index_row'):
            mutant = copy.deepcopy(plan)
            if name == 'missing_history_member':
                del mutant['preserved'][next(iter(mutant['preserved']))]; reason = 'complete prior immutable population'
            elif name == 'forged_original_hash':
                mutant['preserved'][next(iter(mutant['preserved']))] = '0' * 64; reason = 'original immutable identity'
            elif name == 'forged_resulting_hash':
                mutant['resulting_inputs'][REG] = '0' * 64; reason = 'resulting input identities'
            else:
                line = next(line for line in original_index.splitlines(keepends=True)
                            if line.startswith(b'| [0131]('))
                displaced = original_index.replace(line, b'', 1) + line
                (ROOT / INDEX).write_bytes(displaced)
                mutant['resulting_inputs'][INDEX] = sha(displaced)
                reason = 'sole indexed decision and exact accepted row placement'
            raw = (json.dumps(mutant, indent=2) + '\n').encode()
            (ROOT / (PREFIX + 'plan.json')).write_bytes(raw)
            observed = command(['python3', PREFIX + 'capacity.py', 'review'])
            assert observed['exit_code'] != 0 and reason.encode() in base64.b64decode(observed['stderr']['base64']), name
            rows.append({'name': name, 'reason': reason, 'mutant': channel(raw),
                         'index_mutant': channel(read(INDEX)) if name == 'displaced_index_row' else None, 'observed': observed})
            (ROOT / INDEX).write_bytes(original_index)
    finally:
        (ROOT / (PREFIX + 'plan.json')).write_bytes(original)
        (ROOT / INDEX).write_bytes(original_index)
    restored = command(['python3', PREFIX + 'capacity.py', 'review'])
    assert restored['exit_code'] == 0 and read(PREFIX + 'plan.json') == original and read(INDEX) == original_index, 'actual restoration PASS'
    save('evidence.json', {'producer_sha256': sha(Path(__file__).read_bytes()), 'plan_sha256': sha(original), 'rows': rows, 'restored': restored})
    print('Four actual reviewer corruption REDs/restored PASS retained.')


def final():
    review()
    data = load('evidence.json')
    assert data['producer_sha256'] == sha(Path(__file__).read_bytes()) and data['plan_sha256'] == sha(read(PREFIX + 'plan.json'))
    assert [r['name'] for r in data['rows']] == ['missing_history_member', 'forged_original_hash', 'forged_resulting_hash', 'displaced_index_row']
    for row in data['rows']:
        result = row['observed']
        assert result['exit_code'] != 0 and row['reason'].encode() in base64.b64decode(result['stderr']['base64'])
        for key in ('stdout', 'stderr'):
            raw = base64.b64decode(result[key]['base64']); assert channel(raw) == result[key]
        mutant = base64.b64decode(row['mutant']['base64']); assert channel(mutant) == row['mutant']
        if row['name'] == 'displaced_index_row':
            line = next(line for line in read(INDEX).splitlines(keepends=True) if line.startswith(b'| [0131]('))
            displaced = read(INDEX).replace(line, b'', 1) + line
            assert channel(displaced) == row['index_mutant'], 'exact displaced-row counterfactual'
        else:
            assert row['index_mutant'] is None
    assert data['restored'] == command(['python3', PREFIX + 'capacity.py', 'review']), 'restored actual reviewer replay'
    print('Complete finite capacity review/evidence PASS; canonical receipt governs landing.')


parser = argparse.ArgumentParser()
parser.add_argument('mode', choices=['apply', 'capture', 'review', 'evidence', 'final'], nargs='?', default='final')
if __name__ == '__main__':
    globals()[parser.parse_args().mode]()
