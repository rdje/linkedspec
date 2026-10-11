"""Readonly exact private-fixture admission and strict negative controls."""
import base64
import gzip
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-selector-'
PUB = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/publish.py'
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'
FIXTURES = {
    't/actionir_array_end_required_probe.pl':
        'd7c252a466ecee426ed0a8e0ab264b66d550419fffa7dcdf55d17b22a65e1d80',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-native-draft-probe.pl':
        '3c342cb0dc647a573922305d3d2e94e697de4cf18c504ad29eef25a1cbf75d36',
}
SHA = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
assert sys.argv[1:] in ([], ['--capture'])
original_claim = read(PREFIX + 'before-claim.json')
assert SHA(original_claim) == 'e7791186aedfe22cd0638a9c55faec842e934657b9efbb07071e4909ddb9bafe'
old_pub = read(PREFIX + 'before-publish.py')
assert SHA(old_pub) == 'bb98766f19cb7ea7c5b49855b2de1be3ab180cb2043d48d40299e936908b6075'
old_scanner = read(PREFIX + 'before-scanner.py')
assert SHA(old_scanner) == 'ac92c88f12d48522c66276dfea6c3dbdd936cbc1898976c9e1298e1511b1be64'
bindings = json.loads(original_claim)['claims'][0]['durability']['inputs']
assert len(bindings) == 380
for entry in bindings:
    raw = old_pub if entry['path'] == PUB else read(entry['path'])
    assert SHA(raw) == entry['sha256'], ('original380 input', entry['path'])

insertion = b"""    # Private array-end parser injection controls, including the compile-failed
    # native draft. These do not exercise public authoring acceptance.
    't/actionir_array_end_required_probe.pl':
        'd7c252a466ecee426ed0a8e0ab264b66d550419fffa7dcdf55d17b22a65e1d80',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-native-draft-probe.pl':
        '3c342cb0dc647a573922305d3d2e94e697de4cf18c504ad29eef25a1cbf75d36',
"""
needle = b'HISTORICAL_DIAGNOSTIC_INPUTS = {\n'
assert old_scanner.count(needle) == 1
assert read(SCANNER) == old_scanner.replace(needle, needle + insertion, 1), 'only two exact classifications'
replacements = [
    (b"    assert target.read_bytes() == original and not report.exists(), 'one-shot guarded publication'\n    report.write_text(json.dumps(proof, indent=2) + '\\n')",
     b"    assert target.read_bytes() == m.read(PREFIX + 'selector-before-claim.json'), 'one-shot selector extension'\n    assert json.loads(report.read_bytes()) == proof, 'retained complete proof unchanged'"),
    (b"paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / DIR).iterdir() if p.is_file())\n",
     b"paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / DIR).iterdir() if p.is_file())\npaths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob('PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-selector-*') if p.is_file())\npaths.update(['tools/check_executable_aggregate_selector_sources.py', 't/actionir_array_end_required_probe.pl', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-native-draft-probe.pl', 'docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md'])\n"),
    (b"primary['durability']['inputs'] = inputs\n",
     b"primary['durability']['inputs'] = inputs\nselector = m.command(['python3', PREFIX + 'selector-proof.py'])\nassert selector['exit_code'] == 0 and not selector['stderr']['bytes'], selector\ndata['claims'].append(json.loads(m.read(PREFIX + 'selector-claim.json')))\n"),
]
expected = old_pub
for old, new in replacements:
    assert expected.count(old) == 1
    expected = expected.replace(old, new, 1)
assert read(PUB) == expected, 'bounded publication extension'
boundary = json.loads(read(PREFIX + 'boundary.json'))
assert boundary['before_claim_sha256'] == SHA(original_claim)
assert boundary['before_publisher_sha256'] == SHA(old_pub)
assert boundary['before_scanner_sha256'] == SHA(old_scanner)
assert boundary['original380_publisher']['returncode'] == 0
assert not base64.b64decode(boundary['original380_publisher']['stderr_base64'], validate=True)
red = boundary['original_scanner_red']
assert red['returncode'] == 1
assert b'positive selector source remains' in base64.b64decode(red['stderr_base64'], validate=True)
failure = boundary['canonical02']
raw_log = gzip.decompress(read(failure['log']))
assert len(raw_log) == failure['log_bytes'] and SHA(raw_log) == failure['log_sha256']
assert failure['exit_code'] == 1 and b'composed aggregate-selector scanner concurrency check failed' in raw_log

def load(path, name):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

before = load(PREFIX + 'before-scanner.py', 'before_selector')
current = load(SCANNER, 'current_selector')
assert current.HISTORICAL_DIAGNOSTIC_INPUTS == {**before.HISTORICAL_DIAGNOSTIC_INPUTS, **FIXTURES}
rows = []
with tempfile.TemporaryDirectory(prefix='selector-controls-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    before.ROOT = current.ROOT = supplied
    for relative, digest in FIXTURES.items():
        raw = read(relative)
        assert SHA(raw) == digest
        target = supplied / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)

    def observe(name, module, paths, positives, classified):
        found, count = module.scan_files(paths)
        assert len(found) == positives and count == classified, (name, found, count)
        rows.append({'name': name, 'paths': paths, 'positive': found, 'classified': count})

    paths = list(FIXTURES)
    observe('original-six-positive', before, paths, 6, 0)
    observe('current-six-private', current, paths, 0, 6)
    for relative, digest in FIXTURES.items():
        target = supplied / relative
        raw = target.read_bytes()
        target.write_bytes(raw + b'\n# edited private probe\n')
        observe('edited-' + relative, current, [relative], 3, 0)
        target.write_bytes(raw)
        copy = relative + '.copied.pl'
        (supplied / copy).write_bytes(raw)
        observe('copied-' + relative, current, [copy], 3, 0)
        target.write_bytes(raw + b"\nmy $positive = '" + b'array' + b"(items)';\n")
        observe('appended-positive-' + relative, current, [relative], 4, 0)
        target.write_bytes(raw)
        current.HISTORICAL_DIAGNOSTIC_INPUTS[relative] = '0' * 64
        observe('wrong-digest-' + relative, current, [relative], 3, 0)
        del current.HISTORICAL_DIAGNOSTIC_INPUTS[relative]
        observe('missing-entry-' + relative, current, [relative], 3, 0)
        current.HISTORICAL_DIAGNOSTIC_INPUTS[relative] = digest
        observe('restored-' + relative, current, [relative], 0, 3)
        assert target.read_bytes() == raw
    positive = 'positive.pl'
    (supplied / positive).write_bytes(b"my $positive = '" + b'array' + b"(items)';\n")
    observe('ordinary-positive', current, [positive], 1, 0)
    observe('final-restored', current, paths, 0, 6)

report = {'result': 'PASS', 'producer_sha256': SHA(Path(__file__).read_bytes()),
          'original380_claim_sha256': SHA(original_claim), 'fixtures': FIXTURES,
          'rows': rows, 'scope': 'Exact scanner classification only; both native probe bytes and all original380 logical inputs/full publication are preserved. Eleven strict positive/edited/copied/missing-entry/wrong-hash denials, original six-site RED and restored exact-byte controls execute the real scan_files function in same-volume supplied files. Original publisher ran successfully before its bounded extension; no fresh replay of that original uncommitted publication is claimed. Fresh whole-repository/concurrency/public admission and canonical CI are separate.'}
target = ROOT / (PREFIX + 'result.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot selector proof'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'selector proof drift'
print('Private selector classification PASS: original6 RED; exact6 classified;11 strict denials; original380 inputs/full publication preserved')
