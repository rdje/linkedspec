"""Recover retained Lua publication without executing its producer or SDK."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'publication'


def recover(tag):
    rows = json.loads((OUT / (tag + '.json')).read_bytes())
    bodies = {}
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert len(archive.getnames()) == len(rows) and set(archive.getnames()) == rows.keys()
        for member in archive:
            path = Path(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in bodies
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication bytes'
            assert member.mode & 0o777 == row['mode'], 'publication full modes'
            bodies[member.name] = body
    return bodies


def validate(inputs, outputs):
    prefix = str(BASE / 'launches') + '/'
    for tag in ('review', 'current', 'review-publication-query'):
        assert inputs[prefix + tag + '/exit.txt'] == b'0\n', 'publication report status'
        assert gzip.decompress(inputs[prefix + tag + '/stderr.log.gz']) == b'', 'publication report stderr'
    proof, current, query = [json.loads(gzip.decompress(inputs[prefix + tag + '/stdout.log.gz']))
        for tag in ('review', 'current', 'review-publication-query')]
    assert proof['historical_recovery'] == current['current_inputs'] == 'PASS', 'publication verdict'
    assert (proof['programs_per_host'], proof['supported_per_host'], proof['separate_compatibility_per_host'], proof['preserved_per_host'], proof['direct_checks_per_host']) == (508, 20, 4, 484, 6987), 'publication proof counts'
    assert query['live_intersections'] == 0 and len(query['rejected_live_binding_controls']) == 9, 'accepted claim bindings'
    controls, identities = len(proof['reason_sensitive_controls']), current['declared_inputs']
    card = outputs['docs/knowledge/lua-open-arity-concat-result-guards.md'].decode()
    assert f'{controls}/current{identities}' in card.lower(), 'publication derived counts'
    assert str(BASE / 'review_publication.py') in card and str(BASE / 'review.py') in card, 'historical reader pointers'
    memory = outputs['MEMORY.md'].decode()
    assert 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.80.5` (completed)' in memory, 'publication task status'
    assert 'in_flight_uncommitted: none;' in memory and '1,500,000,000' in memory and 'discovery23.4.1' in memory, 'publication handoff'
    for name in ('publish.py', 'run_publication.py', 'review_publication.py'):
        assert inputs[str(BASE / name)] == (BASE / name).read_bytes(), 'retained actual producer identity'
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        assert b'All five bounded concat80 backend implementations have focused outcomes' in outputs[name], 'current roadmap frontier'
        assert b'1,500,000,000' in outputs[name] and b'Lua80.5' in outputs[name], 'publication frontier'
    handoff = outputs['docs/linkedspec-book/src/appendix/backend-handoff.md']
    assert len(handoff.splitlines()) == 4999 and b'Installed Lua80.5 now has a one-line' in handoff, 'bounded backend handoff'
    catalog = outputs['docs/linkedspec-book/src/appendix/helper-contract-catalog.md']
    assert catalog.count(b'id="concat_arraysa1-a2"') == 1, 'catalog anchor'
    assert b'Perl, Rust, Dart, Julia and installed Lua result guards now cover' in catalog, 'catalog behavior'
    flow = outputs['docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md']
    assert b'Installed Lua independently passes508 programs/four routes' in flow, 'independent Lua boundary'
    assert b'raw-table4.28/declared5.4/full admission separate' in flow, 'Lua flow qualification'
    before = inputs['LIVE_ACHIEVEMENT_STATUS.md'].decode()
    after = outputs['LIVE_ACHIEVEMENT_STATUS.md'].decode()
    def rows(source):
        return source.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0].strip().splitlines()
    assert len(rows(before)) == len(rows(after)) == 16, 'bounded live view'
    assert rows(after)[1:] == rows(before)[:15], 'preserved recent rows'
    assert outputs[str(OUT / 'rotated-live-row.txt')].decode() == rows(before)[-1] + '\n', 'retained rotated row'
    assert before.split('## History', 1)[1] == after.split('## History', 1)[1], 'exact history pointer'
    claim = json.loads(inputs['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.3.80.5.json'])['claims'][0]
    assert claim['rederive']['status'] == 'checked' and claim['falsify']['status'] == claim['durability']['status'] == 'gap', 'operational claim disclosure'


inputs, outputs = recover('inputs-before-use'), recover('outputs-after-use')
assert (OUT / 'exit.txt').read_text() == '0\n' and gzip.decompress((OUT / 'stderr.log.gz').read_bytes()) == b''
command = json.loads((OUT / 'command.json').read_bytes())
assert command['cwd'] == '.' and command['argv'][-1] == str(BASE / 'publish.py')
validate(inputs, outputs)
controls = []
for label, mutation, reason in (
    ('failed consumed report', lambda left, right: left.__setitem__(str(BASE / 'launches/review/exit.txt'), b'1\n'), 'publication report status'),
    ('unfinished handoff', lambda left, right: right.__setitem__('MEMORY.md', right['MEMORY.md'].replace(b'(completed)', b'(active)')), 'publication task status'),
    ('lost derived counts', lambda left, right: right.__setitem__('docs/knowledge/lua-open-arity-concat-result-guards.md', b'lost'), 'publication derived counts'),
):
    left, right = copy.deepcopy(inputs), copy.deepcopy(outputs)
    mutation(left, right)
    try:
        validate(left, right)
    except AssertionError as failure:
        assert reason in str(failure)
    else:
        raise AssertionError('publication corruption accepted:' + label)
    controls.append(label)
print(json.dumps(dict(publication_recovery='PASS', inputs=len(inputs), outputs=len(outputs), corruptions=controls,
    scope='Historical producer/report/document bytes and full archived modes. No current document freshness, SDK replay or complete native closure.')))
