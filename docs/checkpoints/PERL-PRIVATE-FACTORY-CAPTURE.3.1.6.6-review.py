"""Readonly full finite-admission review, including exact card and book inputs."""
import base64
import importlib.util
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
for tail, mode in [('capacity.py', 'final'), ('book-review.py', None), ('preservation-controls.py', None)]:
    args = ['python3', PREFIX + tail] + ([mode] if mode else [])
    observed = m.command(args)
    assert observed['exit_code'] == 0 and observed['stderr']['bytes'] == 0, observed
card = 'docs/knowledge/finite-engineering-notes-member-0131.md'
old = m.old(card); current = m.read(card)
old_front, old_body = old.split(b'\n---\n', 1)
front, body = current.split(b'\n---\n', 1)
assert body.endswith(old_body), 'exact historical capacity card body'
answers = lambda raw: re.findall(rb'^  - "(.*)"$', raw, re.M)
assert answers(front) == answers(old_front) + [
    b'which decision admits engineering notes segment 4961',
    b'how are scalar callback bindings preserved before ADR0133',
    b'does ADR0133 admit another future archive member'], 'complete existing/new card questions'
assert b'id: finite-engineering-notes-member-0131' in front
print('Finite admission full review PASS:224 immutable/337 preserved;30 threshold/23 authority/3 reviewer/2 preservation REDs; book89/3; exact existing card retained')
