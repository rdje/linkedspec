"""Prepare the one-source public inverse/restoration observer without SDK use."""
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
target = BASE / 'observe_control.pl'
assert not target.exists(), 'one-shot observer preparation'
source = Path('docs/checkpoints/copy-result-guard-perl-2026-11-06/observe_control.pl').read_text()
source = source.replace('copy-logical-control.spec', 'hash-view-guard-control.spec')
source = source.replace('CopyLogicalControlProbe', 'HashViewGuardControlProbe')
source = source.replace('COPY_CONTROL', 'HASH_VIEW_CONTROL')
target.write_text(source)
print('Same-path Hash-view guard observer prepared')
