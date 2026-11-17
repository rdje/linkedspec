"""Reproduce the failed draft derivation without replaying any writer or probe."""
import difflib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
with tarfile.open(BASE / 'instruments.tar.gz') as archive:
    original = archive.extractfile(str(BASE / 'review.py')).read().decode()
expanded = (BASE / 'used_review_expanded.py').read_text()
replacements = [('import argparse\n', 'import argparse\nimport ast\n')]
start = expanded.index('\ndef verify_probes(')
end = expanded.index('\n\ndef main():', start)
replacements.append(('\n\ndef main():', expanded[start:end] + '\n\ndef main():'))
replacements.append(("inherited_named=len(ledger['previously_named']), census=verify_census(sources), limits=ledger['limits'])",
    "inherited_named=len(ledger['previously_named']), census=verify_census(sources), probes=verify_probes(sources, ledger), limits=ledger['limits'])"))
body = original
for before, after in replacements:
    assert body.count(before) == 1
    body = body.replace(before, after, 1)
assert body != expanded, 'actual failed draft remains RED'
differences = [dict(operation=operation, reconstructed=body[start:stop], actual=expanded[other_start:other_stop])
    for operation, start, stop, other_start, other_stop in difflib.SequenceMatcher(None, body, expanded, autojunk=False).get_opcodes()
    if operation != 'equal']
assert differences == [dict(operation='insert', reconstructed='', actual='\n')], 'exact failed draft cause'
with tarfile.open(BASE / 'support-inputs.tar.gz') as archive:
    assert archive.getmembers() == [], 'failed setup left an empty archive'
assert not (BASE / 'support-identities.json').exists() and not (BASE / 'support-derivation.json').exists()
result = dict(result='PASS', original_draft='RED', cause='One omitted separator newline prevents the draft from matching the expanded body; assertion stopped before its derivation output.',
    differences=differences, following_setup='Missing derivation file leaves an empty support archive; no set-e in the grouped outer shell allows the probe producer to run. The next support reader then fails on absent identities.',
    boundary='Pure reconstruction plus retained empty archive and failed reader body/channels. First setup raw channels and separate outer probe-producer exit remain unavailable; no historical first-use credit.')
print(json.dumps(result, indent=2, sort_keys=True))
