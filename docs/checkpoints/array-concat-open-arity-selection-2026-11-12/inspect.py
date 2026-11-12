"""Classify actual finite public concat records against authored valid-Array intents."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
assert (OUT / 'complete.txt').is_file() and not (BASE / 'assessment.json').exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(cases) == 84
inputs = json.loads((OUT / 'input-identities.json').read_bytes())
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == inputs.keys()
    for member in archive:
        row = inputs[member.name]; body = archive.extractfile(member).read()
        assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
for tag in ('memory', 'version', 'syntax', 'observer'):
    assert (OUT / (tag + '-exit.txt')).read_text() == '0\n'
    stderr = gzip.decompress((OUT / (tag + '-stderr.log.gz')).read_bytes())
    assert stderr == ((str(BASE / 'observer.pl') + ' syntax OK\n').encode() if tag == 'syntax' else b'')
records, products = {}, {}
for line in gzip.decompress((OUT / 'observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith(('ARRAY_CONCAT_OPEN_PERL ', 'ARRAY_CONCAT_OPEN_INPUT ')):
        prefix, key, raw = line.split(' ', 2)
        target = records if prefix == 'ARRAY_CONCAT_OPEN_PERL' else products
        assert key not in target
        target[key] = json.loads(raw)
assert list(records) == list(products) == [row['id'] for row in cases]


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def ready(row):
    meta = row['metadata']
    assert set(meta) == {'language_agnostic_action_ir_ready', 'raw_perl_dependency_count',
        'canonical_action_ir_fallback_count', 'unresolved_helper_count', 'unresolved_helpers'}
    return meta['language_agnostic_action_ir_ready'] == 1 and all(meta[key] == 0 for key in (
        'raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')) and not meta['unresolved_helpers']


def behavior(case, row):
    for route, flag in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row[flag] != 1 or route not in row:
            return False
        error = row[route + '_error']
        if 'expected_error' in case:
            if not error or case['expected_error'] not in wire(error):
                return False
        elif error or wire(row[route]) != wire(case['expected']):
            return False
    return not row['warnings']


passing, differences, guarded_targets, producer_questions, groups = [], [], [], [], {}
artifact_count = 0
for case in cases:
    key = case['id']; row = records[key]
    assert products[key]['source'] == case['source']
    for field, product in (('module_input', 'emitted'), ('handler_input', 'handler')):
        identity, body = row[field], products[key][product]
        if identity is None:
            assert body is None
            continue
        assert isinstance(body, str)
        raw = body.encode()
        assert len(raw) == identity['bytes'] and hashlib.sha256(raw).hexdigest() == identity['sha256']
        path = Path(identity['path'])
        assert path.parent == OUT and path.is_file() and not path.is_symlink()
        assert gzip.decompress(path.read_bytes()) == raw
        artifact_count += 1
    verdict = ready(row) and behavior(case, row)
    (passing if verdict else differences).append(key)
    label = case['source_kind'] + '/' + str(case['array_count'])
    group = groups.setdefault(label, dict(programs=0, contract_pass=0, differences=0))
    group['programs'] += 1
    group['contract_pass' if verdict else 'differences'] += 1
    if not verdict:
        assert key.endswith(case['tail'])
        terminal_key = key[:-len(case['tail'])] + 'terminal'
        if case['tail'] != 'terminal' and terminal_key in records:
            terminal_case = next(item for item in cases if item['id'] == terminal_key)
            if ready(records[terminal_key]) and behavior(terminal_case, records[terminal_key]):
                guarded_targets.append(key)
            else:
                producer_questions.append(key)
        else:
            producer_questions.append(key)
result = dict(programs=len(cases), artifact_files=artifact_count, contract_pass=passing,
    contract_differences=differences, terminal_supported_composition_targets=guarded_targets,
    producer_or_terminal_questions=producer_questions, groups=groups, observed=records,
    limits='Own finite Perl valid-Array selection, not peer/portable/completeness admission. Readiness is independent from values; a matching null with unresolved DSL is not PASS. Native standalone dumps follow internal Get compilation, and complete native4.2/SESSION5 remains open.')
(BASE / 'assessment.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({key: value for key, value in result.items() if key != 'observed'}, indent=2, sort_keys=True))
