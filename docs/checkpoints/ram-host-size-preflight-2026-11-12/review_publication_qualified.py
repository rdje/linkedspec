"""Qualify one literal policy assertion; preserve the original reader and failure."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
old_path = BASE / 'review_publication.py'
proof = BASE / 'proofs/review-publication'
assert (proof / 'exit.txt').read_text().strip() == '1'
assert b'AssertionError: current RAM policy' in gzip.decompress((proof / 'stderr.gz').read_bytes())
rows = json.loads((proof / 'input-identities.json').read_bytes())
name = old_path.relative_to(BASE.parents[2]).as_posix()
with tarfile.open(proof / 'inputs-before-use.tar.gz') as archive:
    member = archive.getmember(name)
    original = archive.extractfile(member).read()
    assert member.mode & 0o777 == rows[name]['mode']
assert hashlib.sha256(original).hexdigest() == rows[name]['sha256']
assert old_path.read_bytes() == original
card_name = 'docs/knowledge/shared-host-ram-budget.md'
meta = json.loads((BASE / 'publication/outputs-after-use.json').read_bytes())
with tarfile.open(BASE / 'publication/outputs-after-use.tar.gz') as archive:
    member = archive.getmember(card_name)
    card = archive.extractfile(member).read()
assert hashlib.sha256(card).hexdigest() == meta[card_name]['sha256']
assert member.mode & 0o777 == meta[card_name]['mode']
sentence = b"it is not\nmemory_pressure's free indicator, a peak bound or continuous trend monitoring."


def policy(text):
    assert sentence in text, 'complete negative policy sentence'


policy(card)
assert b'not continuous trend monitoring' not in card
rejected = []
for old, new in ((b'it is not\n', b'it is\n'),
                 (b"memory_pressure's free indicator", b'another indicator'),
                 (b'or continuous trend monitoring.', b'and performs continuous trend monitoring.')):
    changed = card.replace(old, new)
    assert changed != card
    try:
        policy(changed)
    except AssertionError as error:
        assert str(error) == 'complete negative policy sentence'
        rejected.append(old.decode())
    else:
        raise AssertionError('ineffective policy control')
needle = b"b'not continuous trend monitoring'"
assert original.count(needle) == 1
qualified = original.replace(needle, b"b'continuous trend monitoring'", 1)
exec(compile(qualified, str(old_path), 'exec'), {'__file__': str(old_path), '__name__': '__main__'})
print(json.dumps(dict(policy_assertion_qualification='PASS', rejected_policy_controls=rejected,
    scope='One literal predicate plus complete negative-sentence gate; original reader/source/failure/publication images unchanged.')))
