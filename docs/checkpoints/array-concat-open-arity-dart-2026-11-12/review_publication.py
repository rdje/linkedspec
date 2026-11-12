"""Recover the actual Dart document publication without executing its producer."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
OUT = BASE / 'publication'


def recover(tag):
    rows = json.loads((OUT / (tag + '.json')).read_bytes()); result = {}
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert len(packed.getnames()) == len(rows)
        for member in packed:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts and member.name not in result
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication bytes'
            assert member.mode & 0o777 == row['mode'], 'publication modes'
            result[member.name] = body
    assert result.keys() == rows.keys(), 'publication census'
    return result


def validate(inputs, outputs):
    prefix = str(REL / 'launches') + '/'
    for tag in ('review', 'current', 'review-publication-query', 'review-catalog-query'):
        assert inputs[prefix + tag + '/exit.txt'] == b'0\n', 'publication report status'
        assert gzip.decompress(inputs[prefix + tag + '/stderr.log.gz']) == b'', 'publication report stderr'
    proof = json.loads(gzip.decompress(inputs[prefix + 'review/stdout.log.gz']))
    current = json.loads(gzip.decompress(inputs[prefix + 'current/stdout.log.gz']))
    assert proof['historical_recovery'] == current['current_inputs'] == 'PASS', 'publication verdict'
    assert (proof['programs'], proof['supported'], proof['separate_compatibility'], proof['preserved'], proof['direct_named_groups']) == (508, 20, 4, 484, 1155), 'publication proof counts'
    controls, identities = len(proof['corruption_controls']), current['declared_inputs']
    card = outputs['docs/knowledge/dart-open-arity-concat-result-guards.md'].decode()
    assert f'readonly{controls}/current{identities}' in card.lower(), 'publication derived counts'
    assert str(REL / 'review_publication.py') in card, 'publication reader pointer'
    memory = outputs['MEMORY.md'].decode()
    assert 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.80.3` (completed)' in memory, 'publication task status'
    assert 'in_flight_uncommitted: none;' in memory and '1,500,000,000' in memory and 'activate23.4.30' in memory, 'publication handoff'
    for name in ('publish.py', 'run_publication.py', 'review_publication.py'):
        assert inputs[str(REL / name)] == (BASE / name).read_bytes(), 'actual producer identity'
    for path in ('ROADMAP.md', 'ROADMAP_V2.md'):
        assert b'Dart80.3 focused proof' in outputs[path], 'roadmap frontier'
    assert outputs['docs/linkedspec-book/src/appendix/helper-contract-catalog.md'].count(b'id="concat_arraysa1-a2"') == 1, 'catalog anchor'


inputs, outputs = recover('inputs-before-use'), recover('outputs-after-use')
assert (OUT / 'exit.txt').read_text() == '0\n' and gzip.decompress((OUT / 'stderr.log.gz').read_bytes()) == b''
validate(inputs, outputs)
controls = []
for tag, mutation, reason in (
    ('failed report', lambda left, right: left.__setitem__(str(REL / 'launches/review/exit.txt'), b'1\n'), 'publication report status'),
    ('unfinished handoff', lambda left, right: right.__setitem__('MEMORY.md', right['MEMORY.md'].replace(b'(completed)', b'(in_progress)')), 'publication task status'),
    ('misstated count', lambda left, right: right.__setitem__('docs/knowledge/dart-open-arity-concat-result-guards.md', b'lost'), 'publication derived counts'),
):
    left, right = copy.deepcopy(inputs), copy.deepcopy(outputs); mutation(left, right)
    try:
        validate(left, right)
    except AssertionError as error:
        assert reason in str(error)
        controls.append(tag)
    else:
        raise AssertionError('ineffective publication control:' + tag)
print(json.dumps(dict(publication_recovery='PASS', inputs=len(inputs), outputs=len(outputs), corruptions=controls,
    scope='Exact historical producer/report/document bytes and modes; no current document freshness, SDK replay or full native closure.')))
