"""Apply the owner21 fixture stage ahead of unchanged historical image checks."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
p = ROOT / 'tests/language-readiness/verify_objectives.py'
before = p.read_text()
s = before
edits = []

def replace(old, new):
    global s
    assert s.count(old) == 1, 'reader anchor not unique'
    s = s.replace(old, new, 1)
    edits.append(dict(before=old, after=new))

replace("_IMAGE_MODULE = None\n", """PHASE0_FIXTURE_OWNER = 'TYPE-REFERENCE-BOOK.1.2.20.1.21'
PHASE0_FIXTURE = 't/phase0_regression.t'
PHASE0_FIXTURE_TABLE = 'tests/language-readiness/phase0-fixture-calibration.json.gz'
PHASE0_FIXTURE_SHA256 = '4d16bd8b938d30f5f5fa7885931242ea195ed8316be60e36d54d282b452ef45e'
_IMAGE_MODULE = None
""")
new_function = '''def phase0_fixture_reader(read, images, expected_table=PHASE0_FIXTURE_SHA256):
    """Restore only the owned six-assertion fixture edit, before image admission.

    The returned view is an explicit committed activation stage. Actual current
    bytes and table are observed first and have separate reported provenance.
    """
    raw = read(PHASE0_FIXTURE_TABLE)
    require(digest(raw) == expected_table, 'unreviewed Phase0 fixture table')
    require(len(raw) <= 32768, 'Phase0 fixture table bound')
    data = _IMAGE_MODULE.strict_json(gzip.decompress(raw))
    require(isinstance(data, dict) and set(data) == {
        'schema_version', 'owner', 'path', 'activation_commit',
        'before_sha256', 'after_sha256', 'hunks'}, 'Phase0 fixture table schema')
    require(type(data['schema_version']) is int and data['schema_version'] == 1,
            'Phase0 fixture table version')
    require(data['owner'] == PHASE0_FIXTURE_OWNER and data['path'] == PHASE0_FIXTURE,
            'Phase0 fixture owner or path')
    row = images.rows[PHASE0_FIXTURE]
    require(data['activation_commit'] == images.data['activation_commit'] and
            data['before_sha256'] == row['current_sha256'], 'Phase0 fixture committed boundary')
    committed = images.image(data['activation_commit'], PHASE0_FIXTURE, data['before_sha256'])
    actual = read(PHASE0_FIXTURE)
    require(digest(actual) == data['after_sha256'], 'unreviewed current Phase0 fixture')
    hunks = data['hunks']
    require(isinstance(hunks, list) and len(hunks) == 6, 'Phase0 fixture hunk population')
    restored = actual
    for hunk in hunks:
        require(isinstance(hunk, dict) and set(hunk) == {'before', 'after'} and
                all(isinstance(hunk[k], str) and hunk[k] for k in hunk) and
                hunk['before'] != hunk['after'], 'Phase0 fixture hunk schema')
        old, new = hunk['before'].encode(), hunk['after'].encode()
        require(restored.count(new) == 1 and committed.count(old) == 1,
                'Phase0 fixture hunk anchor')
        restored = restored.replace(new, old, 1)
    require(restored == committed, 'Phase0 fixture inverse mismatch')
    def committed_stage(name):
        return restored if name == PHASE0_FIXTURE else read(name)
    return committed_stage, dict(owner=PHASE0_FIXTURE_OWNER, path=PHASE0_FIXTURE,
        activation_commit=data['activation_commit'], preserved_committed_sha256=digest(committed),
        actual_current_sha256=digest(actual), table_sha256=digest(raw), exact_assertion_edits=6,
        source_stage='actual current fixture; exact inverse precedes preserved committed image admission',
        scope='Fixture calibration only; historical runtime results unchanged; no fresh objective admission')


def falsify_phase0_fixture(images):
    raw = read_relative(PHASE0_FIXTURE_TABLE)
    data = _IMAGE_MODULE.strict_json(gzip.decompress(raw))
    rejected = []
    def reject(label, reader, expected, table_sha=PHASE0_FIXTURE_SHA256):
        try:
            phase0_fixture_reader(reader, images, table_sha)
        except ValueError as error:
            require(str(error) == expected, 'unrelated Phase0 fixture rejection: ' + label)
            rejected.append(label)
        else:
            raise ValueError('Phase0 fixture corruption admitted: ' + label)
    for label, value in (('source-appended', read_relative(PHASE0_FIXTURE) + b'# unreviewed\\n'),
                         ('source-missing', b''),
                         ('prior-committed-stage', images.image(data['activation_commit'],
                            PHASE0_FIXTURE, data['before_sha256']))):
        reject(label, lambda name: value if name == PHASE0_FIXTURE else read_relative(name),
               'unreviewed current Phase0 fixture')
    reject('table-bytes', lambda name: raw + b' ' if name == PHASE0_FIXTURE_TABLE else read_relative(name),
           'unreviewed Phase0 fixture table')
    for label, field, value, expected in (
            ('owner', 'owner', 'TYPE-REFERENCE-BOOK.1.2.20.1.11', 'Phase0 fixture owner or path'),
            ('path', 'path', '../outside', 'Phase0 fixture owner or path'),
            ('revision', 'activation_commit', '0' * 40, 'Phase0 fixture committed boundary'),
            ('before-hash', 'before_sha256', '0' * 64, 'Phase0 fixture committed boundary'),
            ('after-hash', 'after_sha256', '0' * 64, 'unreviewed current Phase0 fixture'),
            ('hunk-omission', 'hunks', data['hunks'][:-1], 'Phase0 fixture hunk population')):
        changed = dict(data)
        changed[field] = value
        candidate = gzip.compress(json.dumps(changed, sort_keys=True).encode(), mtime=0)
        reject(label, lambda name: candidate if name == PHASE0_FIXTURE_TABLE else read_relative(name),
               expected, digest(candidate))
    changed = json.loads(json.dumps(data))
    changed['hunks'][0]['before'] += '# unreviewed'
    candidate = gzip.compress(json.dumps(changed, sort_keys=True).encode(), mtime=0)
    reject('hunk-rebinding', lambda name: candidate if name == PHASE0_FIXTURE_TABLE else read_relative(name),
           'Phase0 fixture hunk anchor', digest(candidate))
    return rejected


'''
replace('def audit_evidence(read=read_relative):\n', new_function + 'def audit_evidence(read=read_relative):\n')
replace('''    source_image_evolutions = images.verify(sources, read)
''','''    fixture_read, fixture_evolution = phase0_fixture_reader(read, images)
    source_image_evolutions = images.verify(sources, fixture_read)
    for evolution in source_image_evolutions:
        if evolution['path'] == PHASE0_FIXTURE:
            evolution['source_stage'] = 'preserved committed activation image before owner21 fixture calibration'
''')
replace('''        observed = read(source)
        admitted = images.predecessor(source, observed)
''','''        observed = fixture_read(source)
        admitted = images.predecessor(source, observed)
''')
replace('''            "source_image_evolutions": source_image_evolutions,
''','''            "source_image_evolutions": source_image_evolutions,
            "fixture_source_evolutions": [fixture_evolution],
''')
replace('''    images.verify(report['latest_source_inputs'], read_relative)
    def evolution_source(path):
        return images.read_predecessor(path, read_relative)
''','''    fixture_read, _ = phase0_fixture_reader(read_relative, images)
    images.verify(report['latest_source_inputs'], fixture_read)
    def evolution_source(path):
        return images.read_predecessor(path, fixture_read)
''')
replace('''            "current_image_mutations_rejected": images.falsify(report["latest_source_inputs"], read_relative)}
''','''            "current_image_mutations_rejected": images.falsify(report["latest_source_inputs"], fixture_read),
            "phase0_fixture_mutations_rejected": falsify_phase0_fixture(images)}
''')
output = HERE / 'phase0-reader-evolution.json.gz'
assert not output.exists()
output.write_bytes(gzip.compress(json.dumps(dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.21',path=str(p.relative_to(ROOT)),before_sha256=hashlib.sha256(before.encode()).hexdigest(),after_sha256=hashlib.sha256(s.encode()).hexdigest(),edits=edits),sort_keys=True,separators=(',',':')).encode(),mtime=0))
p.write_text(s)
print('exact reader evolution:', len(edits), 'changes')
