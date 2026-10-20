"""Supply the documented caller presence map to three isolated nested-write fixtures."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
path = 't/phase0_regression.t'
card = 'docs/knowledge/write-vivification-perl-reference.md'
proposed = json.loads(gzip.decompress((ROOT / (P + 'proposals-final.json.gz')).read_bytes()))
failed = json.loads(gzip.decompress((ROOT / (P + 'focused-run.json.gz')).read_bytes()))
assert failed['run']['returncode'] != 0 and failed['inputs_bytes_modes_unchanged']
assert c.read(path) == proposed['after'][path]
before = {item: c.read(item) for item in (path, card)}
texts = {item: c.decode(value['base64']).decode() for item, value in before.items()}
old = 'q{my $meta = {}; my $key = "field"; my $value = "payload";}'
new = 'q{my $meta = {}; my $key = "field"; my $value = "payload"; my %__ls_binding_presence = (meta => 1);}'
assert texts[path].count(old) == 3
texts[path] = texts[path].replace(old, new)
marker = 'date: 2026-09-24\n'
assert texts[card].count(marker) == 1
texts[card] = texts[card].replace(marker,
    '  - "what VM state must a lowered nested write fragment fixture declare"\ndate: 2026-10-19\n', 1)
marker = 'Invalid selectors, kind conflicts, and gaps throw'
assert texts[card].count(marker) == 1
texts[card] = texts[card].replace(marker, (
    'October19 isolated-fragment reminder: declare §my %__ls_binding_presence§\n'
    'alongside value lexicals; a fixture with bound §meta = {}§ marks meta present.\n'
    'Native rule/function bodies supply that invocation-local map. Three standalone\n'
    'compile failures are retained by TYPE-REFERENCE-BOOK.1.2.3 before its fixture repair.\n\n'
    + marker).replace('§', chr(96)), 1)
after = {}
for item, text in texts.items():
    raw = text.encode()
    after[item] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before[item]['mode'])
c.write_new(P + 'fixture-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'fixture_fix.py'), helper=c.read(c.PREFIX + 'common.py'),
    original_focus=c.read(P + 'focused-run.json.gz'),
    scope='Only three explicit caller fixture declarations change; all130 value/diagnostic '
          'goldens and every plan remain exact. The existing canonical presence-map fact receives '
          'one retrieval question/reminder. Original aligned source and full failed focused run '
          'stay immutable. No production, error suppression or warning policy change.'), packed=True)
assert c.unchanged(before)
for item, value in after.items():
    (ROOT / item).write_bytes(c.decode(value['base64']))
    assert c.read(item) == value
print('Three isolated nested-write fixtures now declare their existing caller VM presence map')
