"""Readonly exact chronology correction plus preserved original publication."""
import importlib.util
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
DIR='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
spec=importlib.util.spec_from_file_location('original_replay',ROOT/(DIR+'replay.py'))
# Importing the readonly replay also validates its entire supplied population/channels.
m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
original=m.read(DIR+'original-root.md')
old=b'pressure and old admission reject before the exact clean-Git suffix is archived.'
assert original.count(old)==1
current=m.read('DEVELOPMENT_NOTES.md')
assert current==original.replace(old,old.replace(b'archived',b'admitted'),1), 'exact chronological wording correction'
assert len(current)==len(original) and current.count(b'\n')==original.count(b'\n'), 'unchanged measured root dimensions'
card=m.read(DIR+'original-card.md')
expected=card.replace(b'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-publish-claim.py',b'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/publish.py')
assert expected!=card and m.read('docs/knowledge/finite-engineering-notes-member-0131.md')==expected, 'only current readonly entrypoint correction'
assert json.loads(m.read(DIR+'preservation.json')) == {
    'bindings_verified':347,'original_claim_sha256':m.sha(m.read(DIR+'original-claim.json')),
    'original_root_sha256':m.sha(original),'original_card_sha256':m.sha(card),
    'correction':'Only archive-admission chronology wording changes; archived becomes admitted with equal byte length. Old production roller/controls/native observations and metrics stay fixed. Original uncommitted347-input publication remains supplied/replayable; current root/card differ only through authorized wording and readonly-entrypoint correction.'}
print('Chronology correction review PASS: exact archived-to-admitted/root dimensions and readonly pointer; original347 instruments/observations remain fixed')
