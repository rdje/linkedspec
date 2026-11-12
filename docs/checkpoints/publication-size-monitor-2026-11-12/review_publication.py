"""Recover actual monitor publication without executing a producer or current-state check."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
OUT = BASE / 'publication'


def recover(tag):
    identities = json.loads((OUT / (tag + '.json')).read_bytes()); result = {}
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert len(packed.getnames()) == len(identities)
        for member in packed:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts and member.name not in result
            body = packed.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication bytes'
            assert member.mode & 0o777 == row['mode'], 'publication mode'
            result[member.name] = body
    assert result.keys() == identities.keys()
    return result


def validate(inputs, outputs):
    prefix = REL + '/launches/'
    for tag in ('review', 'current', 'review-publication-query'):
        assert inputs[prefix + tag + '/exit.txt'] == b'0\n', 'publication report status'
        assert gzip.decompress(inputs[prefix + tag + '/stderr.log.gz']) == b'', 'publication report stderr'
    proof = json.loads(gzip.decompress(inputs[prefix + 'review/stdout.log.gz']))
    identity = json.loads(gzip.decompress(inputs[prefix + 'current/stdout.log.gz']))
    assert proof['historical_metadata_recovery'] == identity['current_monitor_inputs'] == 'PASS', 'publication verdict'
    assert (proof['pack_bytes'], proof['logical_objects'], proof['packed_objects'], proof['actual_falsification_controls']) == (1_257_281_519, 45549, 45549, 12), 'publication counts'
    assert proof['original_validator_exit'] == 1 and proof['qualified_validator_exit'] == 0, 'original failure preserved'
    memory = outputs['MEMORY.md']
    assert b'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.4.30.1` (completed)' in memory, 'publication task status'
    assert b'in_flight_uncommitted: none;' in memory and b'Julia80.4' in memory and b'1,500,000,000' in memory, 'publication handoff'
    view = outputs['LIVE_ACHIEVEMENT_STATUS.md'].split(b'## Recent Completions\n\n', 1)[1].split(b'## History', 1)[0]
    assert len([line for line in view.splitlines() if line.startswith(b'- ')]) == 16, 'bounded recent rows'
    for path in ('ROADMAP.md', 'ROADMAP_V2.md'):
        assert b'Publication monitor30.1' in outputs[path] and b'1,257,281,519' in outputs[path], 'roadmap frontier'
    chapter = outputs['docs/linkedspec-book/src/development/local-ci-and-regression.md']
    assert (REL + '/measure.py').encode() in chapter and b'1,500,000,000' in chapter and b'1,400,000,000' in chapter, 'book command and budgets'
    claim = json.loads(inputs['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.30.1.json'])['claims'][0]
    assert claim['rederive']['status'] == claim['falsify']['status'] == 'checked' and claim['durability']['status'] == 'gap', 'measurement leg disclosure'


inputs, outputs = recover('inputs-before-use'), recover('outputs-after-use')
assert (OUT / 'exit.txt').read_text() == '0\n' and gzip.decompress((OUT / 'stderr.log.gz').read_bytes()) == b''
validate(inputs, outputs)
controls = []
for label, mutation, reason in (
    ('failed proof report', lambda i, o: i.__setitem__(REL + '/launches/review/exit.txt', b'1\n'), 'publication report status'),
    ('unfinished handoff', lambda i, o: o.__setitem__('MEMORY.md', o['MEMORY.md'].replace(b'(completed)', b'(in_progress)')), 'publication task status'),
    ('lost measurement gap', lambda i, o: i.__setitem__('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.30.1.json', i['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.30.1.json'].replace(b'"status": "gap"', b'"status": "checked"')), 'measurement leg disclosure'),
):
    left, right = copy.deepcopy(inputs), copy.deepcopy(outputs); mutation(left, right)
    try:
        validate(left, right)
    except AssertionError as error:
        assert str(error) == reason
        controls.append(label)
    else:
        raise AssertionError('ineffective publication control:' + label)
print(json.dumps(dict(publication_recovery='PASS', inputs=len(inputs), outputs=len(outputs), corruption_controls=controls,
    scope='Historical document/report/claim/source byte and full-mode custody; no current document freshness, pack/SDK replay or native durability closure.'), indent=2))
