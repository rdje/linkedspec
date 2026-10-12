"""Readonly diagnostic-byte equivalence, original publication and current doc closure."""
import base64
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-parent-inputs/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
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

preserved = load(PREFIX + 'preservation.json')
claim = read(PREFIX + 'original-claim.json')
assert len(claim) == 51535 and sha(claim) == preserved['claim_sha256']
assert preserved['producer_sha256'] == sha(read(PREFIX + 'preserve.py'))
assert preserved['baseline']['returncode'] == 0 and not decode(preserved['baseline'], 'stderr')
assert decode(preserved['baseline'], 'stdout') == b'Portable Knowledge/documentation publication PASS: 198 live inputs; 51535 bytes\n'
packed = read(PREFIX + 'original-overlays.json.gz')
assert sha(packed) == preserved['capsule_sha256']
overlays = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(packed)).items()}
assert len(overlays) == 8, 'complete eight original byte overlays'
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
assert len(bindings) == 198
original = {r['path']: overlays[r['path']] if r['path'] in overlays else read(r['path']) for r in bindings}
assert all(sha(original[r['path']]) == r['sha256'] for r in bindings), 'complete original198 input identities'
assert preserved['canonical_session'] == 75557 and preserved['canonical_returncode'] == 1
canonical = gzip.decompress(read(PREFIX + 'canonical05.log.gz'))
assert sha(canonical) == preserved['canonical_log_sha256']
assert b'claim-verification: FAIL: untracked input: rgx/README.md' in canonical
assert b'Fourth publication supplied replay PASS:198 complete bindings/full51535' in checked(['python3', PREFIX + 'replay.py'])
replay = load(PREFIX + 'replay.json')
assert [r['returncode'] == 0 for r in replay['rows']] == [True, False, False, True]
assert replay['rows'][0] == dict(replay['rows'][3], name='unchanged-fourth-publication')

snapshot = read(PREFIX + 'rgx-public-readme.md')
assert sha(snapshot) == preserved['snapshot_sha256']
assert snapshot == read('rgx/README.md'), 'published public README snapshot mismatch'
assert subprocess.check_output(['git', 'ls-files', '--stage', '--', 'rgx'], cwd=ROOT).decode() == preserved['gitlink_stage'], 'unchanged public-doc gitlink'

current = load(PREFIX + 'current-final.json')
assert current['producer_sha256'] == sha(read(PREFIX + 'current-final.py'))
assert current['returncode'] == 0 and not decode(current, 'stdout')
assert decode(current, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
previous = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(original['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/original-inputs.json.gz'])).items()}
population = {p: base64.b64decode(raw, validate=True) for p, raw in json.loads(gzip.decompress(previous['docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-population.json.gz'])).items()}
paths = checked(['find', 'docs/knowledge', 'docs/decisions', '-type', 'f', '-name', '*.md']).decode().splitlines()
assert len(paths) == 1485 and sorted(paths) == sorted(population)
changed = sorted(p for p in paths if read(p) != population[p])
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
        old = overlays[p]
        old_end = old.index(b'\n---', 4) + 4
        new_end = raw.index(b'\n---', 4) + 4
        assert raw[:new_end] == old[:old_end].replace((OLD + 'publish.py').encode(), (PREFIX + 'publish.py').encode())
        assert raw[new_end:].startswith(old[old_end:]) and old[:old_end] in raw[new_end:]
assert facts == 1349
assert all(sha(read(p)) == h for p, h in current['inputs'].items())
assert b'Complete book review PASS57+32/four actual controls' in checked(['python3', PREFIX + 'book-review.py'])
book = load(PREFIX + 'book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
spec = importlib.util.spec_from_file_location('public_surface', ROOT / 'tools/check_public_aggregate_selector_surface.py')
public = importlib.util.module_from_spec(spec)
spec.loader.exec_module(public)
public_paths = public.public_markdown_paths()
assert len(public_paths) == 70 and public.check_exact_references(public_paths) == 40
assert public.check_migration_contrast_mutations(public.read(public.MIGRATION_GUIDE)) == 11
validation = load(PREFIX + 'validation.json')
assert validation['result'] == 'PASS'
assert all(sha(read(p)) == h for p, h in validation['sources'].items())
for row in validation['rows']:
    assert row['returncode'] == 0 and decode(row, 'stdout') and not decode(row, 'stderr')
assert b'public-aggregate-selector-surface: OK (70 public files; 40 classified' in decode(validation['rows'][1], 'stdout')
paths = {r['path'] for r in bindings if r['path'] != 'rgx/README.md'} | set(book['source_inputs']) | set(changed) | set(validation['sources'])
paths.add(PREFIX + 'rgx-public-readme.md')
paths.update(p for p in current['inputs'] if p not in population)
for p in (ROOT / PREFIX).iterdir():
    if p.name not in ('review.json', 'evidence.json', 'publish.py'):
        paths.add(p.relative_to(ROOT).as_posix())
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {p: sha(read(p)) for p in sorted(paths)}, 'original_bindings': 198, 'original_claim_bytes': 51535,
    'original_overlays': 8, 'public_snapshot_inputs': 1, 'markdown': 1485, 'facts': facts, 'changed_cards': 6,
    'book_inputs': 89, 'book_controls': 4, 'public_files': 70, 'public_references': 40,
    'scope': 'Complete original198 input bytes/full51535 publication replay unchanged through eight original overlays and retained files, including the published public README. The sole parent-untracked public input rgx/README.md is mapped explicitly to an exact parent-owned snapshot; current bytes and the original gitlink remain checked read-only. Current full Knowledge/six header lineages, book and unchanged public70/40 pass. All earlier diagnostic/native observations survive unchanged. No submodule implementation inspection, write, pin change, full-private/parent or canonical admission is claimed.'}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot review'
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report
print('Parent-owned current review PASS:', len(paths), 'inputs; original198/full51535; one exact public snapshot; Knowledge1485/1349; book89/4; public70/40')
