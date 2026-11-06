"""Prepare a separate direct epoch after the evidence-backed oracle correction."""
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
target = BASE / 'capture_qualified.py'
assert not target.exists(), 'one-shot qualified producer preparation'
source = (BASE / 'capture.py').read_text()
source = source.replace("assert phase in ('before', 'after', 'direct', 'profile-before', 'profile-after')",
                        "assert phase == 'direct-qualified'")
source = source.replace("if phase == 'direct':", "if phase == 'direct-qualified':")
source = source.replace("('capture.py', 'prepare.py', 'observe_profiles.pl', 'profiles.json')",
                        "('capture_qualified.py', 'prepare_qualified.py', 'prepare.py', 'observe_profiles.pl', 'profiles.json')")
target.write_text(source)
print('Separate direct-qualified writer prepared; original failed direct epoch and producer unchanged')
