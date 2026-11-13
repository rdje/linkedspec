"""Recover exact qualified publication and preserve the original failed attempt."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
PREFIX = 'docs/checkpoints/lua-raw-error-observation-2026-11-13/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.28'
BOOK = 'docs/linkedspec-book/src/appendix/runtime-semantics.md'
REFERENCE = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'


def require(valid, reason):
    if not valid: raise ValueError(reason)


def recover(folder, stem):
    identities = json.loads((BASE / folder / (stem + '.json')).read_bytes())
    bodies = {}
    with tarfile.open(BASE / folder / (stem + '.tar.gz')) as archive:
        for member in archive:
            require(member.isfile() and member.name not in bodies, 'publication membership')
            body = archive.extractfile(member).read()
            require(dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode) == identities[member.name], 'publication identity')
            bodies[member.name] = body.decode()
    require(bodies.keys() == identities.keys(), 'publication population')
    return bodies


def validate(model):
    before, after = model['before'], model['after']
    insertion = before[PREFIX + 'book-section.md']
    require(after[BOOK] == before[BOOK].replace('### 10.3 Input Validation', insertion + '\n### 10.3 Input Validation'), 'book exact insertion')
    old = 'with raw-table4.28/declared5.4/full admission separate.'
    new = 'with selected raw-field4.28 focused coverage and broader native4.2/declared5.4/full admission separate.'
    require(before[REFERENCE].count(old) == 2 and after[REFERENCE] == before[REFERENCE].replace(old, new), 'both known references')
    memory = after['MEMORY.md']
    require('Stopped at the director-requested' in memory and 'do not resume PNT without an explicit request' in memory
        and 'active_work_unit: `' + OWNER + '` (completed)' in memory and 'in_flight_uncommitted: none;' in memory, 'stopped handoff')
    require('discovery4.1' in memory and 'publication30.2' in memory and '1,500,000,000' in memory, 'publication next action')
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        require('November13 current fluent frontier:' in after[name] and 'Director requested stop' in after[name], 'roadmap stop')
    old_rows = before['LIVE_ACHIEVEMENT_STATUS.md'].split('## Recent Completions\n\n', 1)[1].split('## History', 1)[0]
    new_rows = after['LIVE_ACHIEVEMENT_STATUS.md'].split('## Recent Completions\n\n', 1)[1].split('## History', 1)[0]
    old_rows = [row for row in old_rows.splitlines() if row.startswith('- ')]
    new_rows = [row for row in new_rows.splitlines() if row.startswith('- ')]
    require(len(old_rows) == len(new_rows) == 16 and new_rows[1:] == old_rows[:15]
        and json.loads(after[PREFIX + 'publication-qualified/retired-recent-rows.json']) == old_rows[15:], 'exact recent window')
    require(after['docs/knowledge/lua-raw-error-observation-scope.md'] == before[PREFIX + 'fact-card.md'], 'new canonical fact')
    old_index = next(line for line in before['docs/TASK_TREE.md'].splitlines() if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    new_index = next(line for line in after['docs/TASK_TREE.md'].splitlines() if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    require('Dart78.6.3 next' in old_index and 'director stop' in new_index and 'discovery4.1' in new_index, 'global index next action')
    old_parts, new_parts = old_index.split('|'), new_index.split('|')
    require(old_parts[:4] == new_parts[:4] and old_parts[5:] == new_parts[5:]
        and before['docs/TASK_TREE.md'].replace(old_index, new_index) == after['docs/TASK_TREE.md'], 'only index summary changes')
    claim = json.loads(after['docs/claims/' + OWNER + '.json'])
    require(claim['owner'] == OWNER and len(claim['claims']) == 2, 'new claim structure')
    require(claim['claims'][0]['falsify']['status'] == 'gap' and claim['claims'][0]['durability']['status'] == 'gap', 'pack gaps remain')
    require(claim['claims'][1]['durability']['status'] == 'gap'
        and claim['claims'][1]['durability']['repair_owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.2', 'native gap remains')
    require(model['original_exit'] == '1\n' and b'count(old_phrase) == 1' in model['original_stderr'], 'original publisher failure')
    original = before[PREFIX + 'publish.py']
    execution = original.replace("OUT = BASE / 'publication'", "OUT = BASE / 'publication-qualified'").replace(
        'assert buffers[REFERENCE].count(old_phrase) == 1', 'assert buffers[REFERENCE].count(old_phrase) == 2')
    require(model['execution'] == execution, 'only two qualification changes')


before = recover('publication-qualified', 'inputs-before-use')
after = recover('publication-qualified', 'outputs-after-use')
failed = recover('publication', 'inputs-before-use')
for name in after:
    if name in failed and name in before:
        require(failed[name] == before[name], 'failed publication made no shared writes')
model = dict(before=before, after=after, original_exit=(BASE / 'proofs/publish/exit.txt').read_text(),
    original_stderr=gzip.decompress((BASE / 'proofs/publish/stderr.gz').read_bytes()),
    execution=gzip.decompress((BASE / 'publish-qualified-execution.py.gz').read_bytes()).decode())
require((BASE / 'proofs/publish-qualified/exit.txt').read_text() == '0\n', 'actual qualified publisher exit')
validate(model)
rejected = []
controls = [
    ('erase-book-section', 'book exact insertion', lambda m: m['after'].update({BOOK:m['before'][BOOK]})),
    ('leave-one-old-reference', 'both known references', lambda m: m['after'].update({REFERENCE:m['before'][REFERENCE]})),
    ('resume-without-director', 'stopped handoff', lambda m: m['after'].update({'MEMORY.md':m['after']['MEMORY.md'].replace('Stopped at the director-requested', 'Full PNT continues')})),
    ('restore-stale-index', 'global index next action', lambda m: m['after'].update({'docs/TASK_TREE.md':m['before']['docs/TASK_TREE.md']})),
    ('erase-original-failure', 'original publisher failure', lambda m: m.update(original_exit='0\n')),
    ('expand-qualified-code', 'only two qualification changes', lambda m: m.update(execution=m['execution'] + '\n# unreviewed\n')),
]
for label, reason, mutate in controls:
    changed = copy.deepcopy(model)
    mutate(changed)
    try:
        validate(changed)
    except ValueError as error:
        require(str(error) == reason, 'unrelated publication rejection: ' + label)
        rejected.append(label)
    else:
        raise ValueError('ineffective publication control: ' + label)
print(json.dumps(dict(publication='PASS', outputs=len(after), original_failure_retained=True,
    rejected_controls=rejected, scope='Historical publication images, not future current-document freshness or SDK execution.')))
