"""Readonly closure of frozen observations and current documentation inputs."""
import base64
import gzip
import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
CHECKER = 'tools/check_public_aggregate_selector_surface.py'
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'
TARGET = ROOT / (PREFIX + 'review.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda p: (ROOT / p).read_bytes()
load = lambda p: json.loads(read(p))
decode = lambda r, k: base64.b64decode(r[k + '_base64'], validate=True)

def checked(command):
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (command, result.stderr)
    return result.stdout

def capsule(path):
    return {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(read(path))).items()}

def module(path, name):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

preserved = load(PREFIX + 'preservation.json')
claim = read(PREFIX + 'original-claim.json')
assert len(claim) == preserved['claim_bytes'] == 79329 and sha(claim) == preserved['claim_sha256']
assert preserved['producer_sha256'] == sha(read(PREFIX + 'preserve.py'))
assert sha(read(PREFIX + 'original-inputs.json.gz')) == preserved['capsule_sha256']
frozen = capsule(PREFIX + 'original-inputs.json.gz')
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
assert len(frozen) == len(bindings) == 337 and all(sha(frozen[r['path']]) == r['sha256'] for r in bindings)
assert sha(gzip.decompress(read(PREFIX + 'candidate.diff.gz'))) == preserved['candidate_sha256']
canonical = gzip.decompress(read(PREFIX + 'canonical.log.gz'))
assert sha(canonical) == preserved['canonical_log_sha256'] and len(canonical) == preserved['canonical_log_bytes']
assert preserved['actual_canonical_session'] == 25364 and preserved['actual_canonical_returncode'] == 1
assert b'without explicit removed/rejected/migrated historical context' in canonical
baseline = load(PREFIX + 'baseline.json')
assert baseline['returncode'] == 0 and not decode(baseline, 'stderr')
assert decode(baseline, 'stdout') == b'Final Knowledge publication PASS: 337 live inputs; 79329 bytes\n'
assert b'Frozen second publication replay PASS: 337 bindings/full79329' in checked(['python3', PREFIX + 'replay.py'])
replay = load(PREFIX + 'replay.json')
assert [r['returncode'] == 0 for r in replay['rows']] == [True, False, False, True]
assert replay['rows'][0] == dict(replay['rows'][3], name='unchanged-second-publication')

before = load(PREFIX + 'document-before.json')
after = load(PREFIX + 'document-after.json')
assert before['producer_sha256'] == sha(read(PREFIX + 'document-final.py'))
assert after['producer_sha256'] == sha(read(PREFIX + 'document-closure.py'))
assert before['classifier']['returncode'] == 1 and 'actionir-lowering-mental-model.md:1547' in before['classifier']['exception']
assert after['classifier'] == {'returncode': 0, 'count': 40, 'stdout': '', 'stderr': ''}, 'false classifier observation'
public = module(CHECKER, 'public_surface')
public_paths = public.public_markdown_paths()
assert len(public_paths) == 70 and public.check_exact_references(public_paths) == 40
assert public.check_migration_contrast_mutations(public.read(public.MIGRATION_GUIDE)) == 11
native_inputs = {}
for report in (before, after):
    assert report['result'] == 'PASS' and len(report['public_files']) == 70
    assert sha(read(report['capsule'])) == report['capsule_sha256']
    files = capsule(report['capsule'])
    assert {p: sha(raw) for p, raw in files.items()} == report['inputs']
    assert files[CHECKER] == read(CHECKER)
    assert report['public_files'] == [p.relative_to(ROOT).as_posix() for p in public_paths]
    if report is after:
        assert all(read(p) == raw for p, raw in files.items()), 'changed current public inputs'
    else:
        with tempfile.TemporaryDirectory(prefix='public-before-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for p in report['public_files']:
                target = supplied / p
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(files[p])
            old_root = public.ROOT
            public.ROOT = supplied
            try:
                try:
                    public.check_exact_references([supplied / p for p in report['public_files']])
                except SystemExit as error:
                    assert str(error) == before['classifier']['exception']
                else:
                    raise AssertionError('missing original documentation RED')
            finally:
                public.ROOT = old_root
        for p, raw in files.items():
            if p not in report['public_files'] and not p.startswith('historical/') and not p.startswith(PREFIX):
                assert read(p) == raw
                native_inputs[p] = sha(raw)
assert before['native'] == after['native'] and len(before['native']) == 4
for row in before['native']:
    assert row['returncode'] == 0 and not decode(row, 'stderr')
    observations = json.loads(decode(row, 'stdout'))['rows']
    assert len(observations) == 10
    if row['version'] == 'current':
        assert [r['value'] for r in observations] == ['item', 'item', 'item', None, None, 'item', None, 'item', 'item', None], 'false private-label native observation'
        assert [len(r['calls']) for r in observations] == [1, 1, 1, 0, 0, 1, 0, 0, 1, 1]
    else:
        assert observations[0]['value'] == 'item' and observations[1]['value'] is None

registration = load(PREFIX + 'scanner.json')
assert registration['result'] == 'PASS' and registration['producer_sha256'] == sha(read(PREFIX + 'scanner.py'))
assert all(sha(read(p)) == h for p, h in registration['inputs'].items())
scanner_files = capsule(PREFIX + 'scanner-inputs.json.gz')
assert len(scanner_files) == 8
old_source = read(PREFIX + 'scanner-before.py')
assert old_source.replace(b'HISTORICAL_DIAGNOSTIC_INPUTS = {\n', b'HISTORICAL_DIAGNOSTIC_INPUTS = {\n' + read(PREFIX + 'scanner-addition.txt'), 1) == read(SCANNER)
old_scanner = module(PREFIX + 'scanner-before.py', 'before_scanner')
scanner = module(SCANNER, 'scanner')
with tempfile.TemporaryDirectory(prefix='scanner-review-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for p, raw in scanner_files.items():
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    old_scanner.ROOT = scanner.ROOT = supplied
    assert old_scanner.scan_files(sorted(scanner_files)) == (registration['old']['positive'], registration['old']['classified'])
    assert len(registration['old']['positive']) == 14
    assert scanner.scan_files(sorted(scanner_files)) == ([], registration['current']['classified'])
    assert registration['current']['classified'] == registration['old']['classified'] + 14
    assert len(registration['rows']) == 24
    for row in registration['rows']:
        p = row['path']
        target = supplied / p
        copy = supplied / ('copy-' + Path(p).name)
        try:
            if row['name'] == 'copied-path':
                copy.write_bytes(scanner_files[p])
                selected = copy.relative_to(supplied).as_posix()
            else:
                selected = p
                assert row['name'] in ('changed-byte', 'added-selector')
                target.write_bytes(scanner_files[p] + (b'\n' if row['name'] == 'changed-byte' else b'\n' + b'array' + b'(new_probe);\n'))
            assert scanner.scan_files([selected]) == (row['positive'], row['classified']) and row['positive'], 'false scanner denial'
        finally:
            target.write_bytes(scanner_files[p])
            copy.unlink(missing_ok=True)
        assert scanner.scan_files([p])[0] == []

current = load(PREFIX + 'current-final.json')
assert current['producer_sha256'] == sha(read(PREFIX + 'current-final.py'))
assert current['returncode'] == 0 and not decode(current, 'stdout')
assert decode(current, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
original_population = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(frozen[OLD + 'population.json.gz'])).items()}
paths = checked(['find', 'docs/knowledge', 'docs/decisions', '-type', 'f', '-name', '*.md']).decode().splitlines()
assert sorted(paths) == sorted(original_population) and len(paths) == 1485
changed = sorted(p for p in paths if read(p) != original_population[p])
assert changed == current['changed_cards'] and len(changed) == 6
facts = 0
for p in paths:
    raw = read(p)
    assert sha(raw) == current['inputs'][p]
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        continue
    owner, fact = None, False
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            assert owner is not None, ('orphan current header', p, number)
            fact |= owner == 'answers'
        elif re.match(r'^[A-Za-z_][A-Za-z_0-9]*\s*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                fact = True
    facts += fact
    if p in changed:
        old = frozen[p]
        old_end = old.index(b'\n---', 4) + 4
        new_end = raw.index(b'\n---', 4) + 4
        assert raw[new_end:].startswith(old[old_end:]), 'original body prefix changed'
        assert old[:old_end] in raw[new_end:], 'full second-candidate header not retained'
        assert (PREFIX + 'publish.py').encode() in raw[:new_end]
assert facts == 1349
assert all(sha(read(p)) == h for p, h in current['inputs'].items())
assert b'Complete book review PASS57+32/four actual controls' in checked(['python3', PREFIX + 'book-review.py'])
book = load(PREFIX + 'book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
composed = load(PREFIX + 'composed-public-final.json')
assert composed['returncode'] == 0 and composed['session'] == 31927
assert composed['source_sha256'] == sha(read(CHECKER)) and composed['scanner_sha256'] == sha(read(SCANNER))
assert b'public-aggregate-selector-surface: OK (70 public files; 40 classified' in decode(composed, 'stdout_log')

registration_sources = ('knowledge-map/scripts/check_knowledge_map.sh', 't/knowledge_map_header_lists.t', 'tools/run_ci_local.sh', 'tools/test_perl_project_data_storage.sh', 'tests/language-readiness/verify_objectives.py')
assert all(read(p) == frozen[p] for p in registration_sources), 'unchanged original repair and registration sources'
paths = set(registration_sources) | set(book['source_inputs']) | set(after['inputs']) | set(native_inputs) | set(registration['inputs'])
paths.update(changed)
paths.update(p for p in current['inputs'] if p not in original_population)
for p in (ROOT / PREFIX).iterdir():
    if p.name not in ('review.json', 'evidence.json', 'publish.py'):
        paths.add(p.relative_to(ROOT).as_posix())
for tail in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh'):
    paths.add('tools/' + tail)
inputs = {p: sha(read(p)) for p in sorted(paths)}
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs,
    'frozen_bindings': 337, 'frozen_claim_bytes': 79329, 'current_markdown': 1485, 'current_facts': facts,
    'public_files': 70, 'public_references': 40, 'private_rows': 20, 'private_old_reds': 2,
    'scanner_files': 8, 'scanner_original_reds': 14, 'scanner_controls': 24, 'book_inputs': 89, 'book_controls': 4,
    'scope': 'Frozen second publication and all337 input bytes/full79329 record retain prior first136/full35512 and accepted534/full123810 runtime proof. Current complete Knowledge population/six full header lineages, unchanged primary public classifier/70-file byte capsule, actual native literal-label observations, exact eight-input scanner registration/24 denials, and full rendered book are independently checked. Composed focused public result is retained; full project dependencies are admitted only by the exact staged canonical receipt. Original runtime/native/failure observations are not refreshed; no parent/private/new syntax or cross-runtime admission.'}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot review capture'
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact current review'
print('Current Knowledge/documentation review PASS:', len(inputs), 'inputs; frozen337/full79329; public70/40; private20; scanner8/14/24; book89/4')
