"""Retain the initial book composition and mutable inputs before census repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
CLAIM = 'docs/claims/' + LEAF + '.json'
PREFIX = 'docs/checkpoints/' + LEAF + '-book-repair/'
MUTABLE = ['tools/check_public_aggregate_selector_surface.py', PREFIX + 'review.py',
           PREFIX + 'publish-claim.py', 'docs/knowledge/perl-receiver-copy-book-prerequisite.md']
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert not (HERE / 'before.json.gz').exists(), 'one-shot census boundary'
claim = (ROOT / CLAIM).read_bytes()
rows = [r for c in json.loads(claim)['claims'] if c['durability']['mode'] == 'live' for r in c['durability']['inputs']]
for row in rows:
    assert digest((ROOT / row['path']).read_bytes()) == row['sha256'], 'initial composition drift: ' + row['path']
packet = {'claim_base64': base64.b64encode(claim).decode(), 'claim_sha256': digest(claim),
          'live_declarations': len(rows), 'unique_inputs': len({r['path'] for r in rows}),
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'mutable_before': {p: base64.b64encode((ROOT / p).read_bytes()).decode() for p in MUTABLE},
          'channels': {name: base64.b64encode((ROOT / '.linkedspec-data/verification' / LEAF / ('book-selector.' + name + '.log')).read_bytes()).decode() for name in ('stdout', 'stderr')},
          'actual_exit_code': 1,
          'provenance': 'Full redirected channels; exit1 transcribed from actual tool completion, not original transport envelope. Every521 initial live binding verified before any mutable input write; immutable other inputs remain retained by the original snapshot and tracked artifacts.'}
assert b'classified reference inventory has 40 occurrences, expected 36' in base64.b64decode(packet['channels']['stderr'])
(HERE / 'before.json.gz').write_bytes(gzip.compress((json.dumps(packet, indent=2) + '\n').encode(), mtime=0))
print('Initial composed census boundary retained:', len(rows), 'bindings;', packet['unique_inputs'], 'distinct paths')
