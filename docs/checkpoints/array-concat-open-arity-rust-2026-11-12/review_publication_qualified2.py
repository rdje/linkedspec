"""Recover actual publication inputs/outputs without executing their producer."""
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
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        for member in archive:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            assert member.name not in result
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication bytes'
            assert member.mode & 0o777 == row['mode'], 'publication modes'
            result[member.name] = body
    assert result.keys() == rows.keys(), 'publication census'
    return result


def validate(inputs, outputs):
    prefix = str(REL / 'launches') + '/'
    for tag in ('review-qualified2', 'current-qualified', 'format', 'review-publication'):
        assert inputs[prefix + tag + '/exit.txt'] == b'0\n', 'publication report status'
        assert gzip.decompress(inputs[prefix + tag + '/stderr.log.gz']) == b'', 'publication report stderr'
    for tag, status in (('direct', 1), ('remaining', 1), ('prepare-publication-qualified', 1),
        ('prepare-publication-qualified2', 0), ('review-qualified', 1)):
        assert inputs[prefix + tag + '/exit.txt'] == (str(status) + chr(10)).encode(), 'original publication failure status'
    assert b'SyntaxError: unterminated string literal' in gzip.decompress(inputs[prefix + 'prepare-publication-qualified/stderr.log.gz']), 'original preparer failure mechanism'
    assert b'AssertionError: supported terminal' in gzip.decompress(inputs[prefix + 'review-qualified/stderr.log.gz']), 'original reader failure mechanism'
    report = json.loads(gzip.decompress(inputs[prefix + 'review-qualified2/stdout.log.gz']))
    identity = json.loads(gzip.decompress(inputs[prefix + 'current-qualified/stdout.log.gz']))
    assert report['readonly'] == identity['current_inputs'] == 'PASS', 'publication report verdict'
    assert (report['programs'], report['supported'], report['compatibility'], report['preserved'], report['direct']) == (504, 16, 2, 486, 1205), 'publication report counts'
    assert report['original_direct_exit'] == 1 and report['original_ordinary_passed'] == 193 and report['qualified_missing_checks'] == 508, 'publication qualification'
    controls = len(report['corruption_controls']); current = identity['declared_inputs']
    card = outputs['docs/knowledge/rust-open-arity-concat-result-guards.md'].decode()
    assert f'qualified2 readonly{controls}/current{current}' in card, 'publication derived counts'
    assert str(REL / 'review_publication_qualified2.py') in card, 'publication reader pointer'
    memory = outputs['MEMORY.md'].decode()
    assert 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.80.2` (completed)' in memory, 'publication task status'
    assert 'in_flight_uncommitted: none;' in memory and 'Activate independent Dart80.3' in memory, 'publication next action'
    for name in ('publish_qualified2.py', 'run_publication_qualified2.py', 'review_publication_qualified2.py'):
        assert inputs[str(REL / name)] == (BASE / name).read_bytes(), 'publication producer identity'


inputs, outputs = recover('inputs-before-use'), recover('outputs-after-use')
assert (OUT / 'exit.txt').read_text() == '0\n' and gzip.decompress((OUT / 'stderr.log.gz').read_bytes()) == b''
validate(inputs, outputs)
controls = []
for tag, mutation, reason in (
    ('failed report', lambda left, right: left.__setitem__(str(REL / 'launches/review-qualified2/exit.txt'), b'1\n'), 'publication report status'),
    ('unfinished handoff', lambda left, right: right.__setitem__('MEMORY.md', right['MEMORY.md'].replace(b'(completed)', b'(in_progress)')), 'publication task status'),
    ('misstated count', lambda left, right: right.__setitem__('docs/knowledge/rust-open-arity-concat-result-guards.md', b'lost'), 'publication derived counts'),
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
    scope='Exact historical producer/report/document byte and mode recovery; no current document freshness, SDK replay or full native closure.')))
