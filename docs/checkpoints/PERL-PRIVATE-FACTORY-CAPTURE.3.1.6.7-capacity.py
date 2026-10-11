"""Readonly finite-member reconstruction. Original applied/draft producers remain retained."""
import argparse
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '6392b8a6512a639265d150acb11b0e9a8451ea3d'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REG = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
ADR = 'docs/decisions/0134-finite-change-history-member.md'
MANIFEST = 'docs/history/changes/manifest.jsonl'
CHANGE_RECORD = ('## 2026-10-11 — One finite change-history archive member\n\n'
        'ADR0134 admits one measured change-history archive member and its exact manifest '
        'growth. The next complete record crosses the line rollover threshold; production '
        'pressure and old admission reject before the finite proposal is admitted. '
        'All accepted immutable bytes and329 array-end publication bindings remain preserved. '
        'Independent reconstruction, production threshold/authority and evidence controls '
        'precede exact staged canonical admission; required hash-index callbacks follow. '
        'No future member reserve or root/aggregate increase is granted.\n\n').encode()
ENGINEERING_RECORD = ('## 2026-10-11 — Finite change-history member capacity\n\n'
          'ADR0134 admits one archive member, exact manifest growth and sole decision overhead '
          'before required hash-index callbacks. Preserve all accepted immutable history and329 '
          'prior array-end publication inputs. Actual pressure/admission REDs, independent '
          'reconstruction, production authority controls and complete book rendering precede '
          'exact staged canonical admission.\n\n').encode()
INDEX_ROW = ('| [0134](0134-finite-change-history-member.md) | One finite change-history '
             'member and exact manifest/decision overhead | 2026-10-11 | accepted engineering '
             'maintenance; canonical admission required | history, capacity, verification |\n').encode()
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


def indexed():
    raw = old(INDEX)
    marker = b'\n## How to add a record'
    assert raw.count(marker) == 1 and INDEX_ROW not in raw
    return raw.replace(marker, INDEX_ROW + marker, 1)


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
    text = ('# ADR 0134: One finite change-history archive member\n\n'
            '- Date: 2026-10-11\n'
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
            'The next complete change record crosses the mandatory line rollover threshold; '
            'the existing finite member and manifest limits reject its required new archive. '
            'The accepted array-end callback slice stayed below the boundary; this canonical prerequisite '
            'resolves the exact next capacity obligation. ADR0132 grants no further reserve.\n\n'
            'Under the current full-PNT instruction and ADR0128/0129/0131/0132/0133 engineering-maintenance '
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
            'Existing book authority and chronology contracts remain accurate; parser/runtime, tests, '
            'checker implementations, dependency pins and other repositories are unchanged. '
            f'Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `{PREFIX}capacity.py review` '
            'through tools/run_python_project_data.sh. Required hash-index callbacks .3.1.6.5 resume after commit.\n').encode()


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


def verify_preservation():
    target = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4.json'
    original = old(target)
    before = json.loads(original)
    expected = copy.deepcopy(before)
    bindings = []
    for claim in expected['claims']:
        d = claim['durability']
        if d.get('mode') == 'live':
            bindings += d['inputs']
            d.update(mode='historical', revision=BASE)
    assert len(bindings) == 329 and len({x['path'] for x in bindings}) == 329
    for entry in bindings:
        assert sha(old(entry['path'])) == entry['sha256'], 'preserved array-end input: ' + entry['path']
    assert read(PREFIX + 'before-array-end.json') == original, 'exact original array-end claim'
    after = (json.dumps(expected, indent=2) + '\n').encode()
    assert read(target) == after, 'array-end claim mode/revision-only preservation'
    freeze = load('freeze.json')
    assert freeze['base'] == BASE and freeze['claim'] == target
    assert freeze['before'] == PREFIX + 'before-array-end.json'
    assert freeze['original_sha256'] == sha(original) and freeze['after_sha256'] == sha(after)
    assert freeze['producer_sha256'] == sha(read(PREFIX + 'freeze.py'))
    assert freeze['intersections'] == [{'claim': target, 'name': 'array-end-required-callback-isolation',
        'bindings': 329, 'intersections': ['docs/linkedspec-book/src/development/documentation-workflow.md']}]
    baseline = load('baseline.json')
    assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-publish-claim.py']
    assert baseline['returncode'] == 0 and not base64.b64decode(baseline['stderr_base64'])
    assert b'PASS' in base64.b64decode(baseline['stdout_base64'])
    assert baseline['producer_sha256'] == sha(read(PREFIX + 'freeze.py'))


def verify_census_repair(plan):
    repair = load('census-repair.json')
    assert repair['base'] == BASE and repair['producer_sha256'] == sha(read(PREFIX + 'census-repair.py'))
    for path, digest in repair['drafts'].items():
        assert sha(read(path)) == digest, 'exact original census draft: ' + path
    draft = load('draft-plan.json')
    assert len(draft['preserved']) == 180
    expected = copy.deepcopy(draft)
    expected['preserved'] = {p: sha(old(p)) for p in population()}
    expected['reviewer_sha256'] = sha(read(PREFIX + 'draft-census-review.py'))
    assert plan == expected, 'only complete census and corrected reviewer identity change'
    missing = set(expected['preserved']) - set(draft['preserved'])
    assert len(missing) == 46 and all(p.startswith('docs/history/development-notes/') for p in missing)
    assert repair['added'] == {p: sha(old(p)) for p in sorted(missing)}, 'exact46 accepted engineering-history inputs'
    assert len(plan['preserved']) == 226 and len(population()) == 226, 'unique complete prior history census'
    assert b"('docs/history/changes', 'docs/history/changes', 'docs/decisions')" in read(PREFIX + 'draft-capacity.py')
    assert repair['plan_sha256'] == sha(read(PREFIX + 'plan.json'))


def verify_base():
    plan = load('plan.json')
    assert plan['base'] == BASE and plan['producer_sha256'] == sha(read(PREFIX + 'draft-capacity.py')), 'actual applied producer identity'
    assert plan['reviewer_sha256'] == sha(read(PREFIX + 'draft-census-review.py')), 'first corrected reviewer identity retained'
    assert set(plan['preserved']) == set(population()), 'complete prior immutable population'
    for p in population():
        assert plan['preserved'][p] == sha(old(p)) == sha(read(p)), 'original immutable identity: ' + p
    assert plan['original_inputs'] == {p: sha(old(p)) for p in MUTABLE + SUPPORT}, 'original input identities'
    root, archive = rolled()
    assert read('CHANGES.md') == root, 'complete current root reconstruction'
    assert read('DEVELOPMENT_NOTES.md') == insert(old('DEVELOPMENT_NOTES.md'), ENGINEERING_RECORD), 'complete change record insertion'
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
    assert read(ADR) == adr and read(INDEX) == indexed(), 'sole exact indexed decision'
    assert plan['resulting_inputs'] == {p: sha(read(p)) for p in MUTABLE + SUPPORT + [ADR, target]}, 'resulting input identities'
    assert plan['measured'] == census(), 'actual complete census'
    assert plan['old_limits'] == {s: before[s]['limits'] for s in ('change_history', 'decisions')}, 'exact old limits'
    assert plan['new_limits'] == {s: after[s]['limits'] for s in ('change_history', 'decisions')}, 'exact new limits'
    assert plan['old_contract'] == contract(before['change_history']) and plan['new_contract'] == contract(after['change_history']), 'exact contract objects'
    unrolled = load('unrolled.json')
    assert unrolled == {'inputs': {p: channel(insert(old(p), addition)) for p, addition in [('CHANGES.md', CHANGE_RECORD), ('DEVELOPMENT_NOTES.md', ENGINEERING_RECORD)]}}, 'exact next-record pressure inputs'
    pressure = load('pressure.json')
    assert pressure['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']
    assert pressure['exit_code'] != 0 and b'rollover required' in base64.b64decode(pressure['stderr']['base64']), 'actual pressure RED'
    admission = load('old-admission.json')
    assert admission['args'] == ['perl', 'scripts/check_readme_routing_pressure.pl']
    assert admission['exit_code'] != 0 and b'surface change_history exceeds control' in base64.b64decode(admission['stderr']['base64']), 'actual old admission RED'
    for observed in (pressure, admission):
        for c in (observed['stdout'], observed['stderr']):
            assert channel(base64.b64decode(c['base64'])) == c, 'complete pressure/admission channels'
    verify_census_repair(plan)
    verify_preservation()
    roll = load('rollover.json')
    assert roll['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--apply']
    assert roll['exit_code'] == 0 and b'archived' in base64.b64decode(roll['stdout']['base64']), 'actual rollover channel'
    for c in (roll['stdout'], roll['stderr']):
        raw = base64.b64decode(c['base64']); assert channel(raw) == c, 'complete rollover channel identity'
    return plan


def run_controls():
    return command(['perl', PREFIX + 'controls.pl'])


def review():
    plan = verify_base()
    stored = load('controls.json')
    assert stored == run_controls(), 'complete actual production control replay'
    controls = json.loads(base64.b64decode(stored['stdout']['base64']))
    assert controls['measured'] == plan['measured'], 'actual control census'
    assert len(controls['thresholds']) == 30 and len(controls['authority']) == 23, 'complete distinguishing control population'
    print('Finite capacity review PASS:', len(plan['preserved']), 'immutable files;30 thresholds/23 authority REDs.')


parser = argparse.ArgumentParser()
parser.add_argument('mode', choices=['review'], nargs='?', default='review')
if __name__ == '__main__':
    review()
