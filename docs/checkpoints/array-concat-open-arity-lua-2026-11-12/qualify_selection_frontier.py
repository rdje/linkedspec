"""Correct a stale current selection pointer while retaining its original evidence."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'selection-frontier'
OUT.mkdir()
ACTIVATION = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
CARD = 'docs/knowledge/array-concat-open-arity-result-selection.md'
prior = Path(CARD).read_bytes()
assert prior == subprocess.check_output(['git', 'show', ACTIVATION + ':' + CARD])
records = {}
for name in subprocess.check_output(['git', 'ls-files', 'docs/claims'], text=True).splitlines():
    if name.endswith('.json'):
        body = Path(name).read_bytes()
        assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
        records[name] = body.decode()
# Capture exact logical inputs before the publication decision and card edit.
packet = dict(source_commit=ACTIVATION, card=CARD, before=prior.decode(), records=records)
raw = (json.dumps(packet, indent=2, sort_keys=True) + '\n').encode()
(OUT / 'inputs.json.gz').write_bytes(gzip.compress(raw, mtime=0))
assert gzip.decompress((OUT / 'inputs.json.gz').read_bytes()) == raw
hits = []
for name, body in records.items():
    for claim in json.loads(body)['claims']:
        durability = claim['durability']
        if durability['status'] == 'checked':
            for item in durability['inputs']:
                if item['path'] == CARD:
                    hits.append(dict(record=name, claim=claim['name'], mode=durability['mode']))
assert not any(hit['mode'] == 'live' for hit in hits), 'live selection-card binding'
result = dict(claim_records=len(records), intersections=hits, source_commit=ACTIVATION,
    issue='Current selection card still says independent peers pending and Rust80.2 next after all five backend outcomes are present.',
    impact='A session following this current pointer could select already completed work; original selection evidence itself remains correct.')
(OUT / 'binding-result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
text = prior.decode()
old_status = 'status: focused selection42 frozen; Perl80.1 focused-complete, independent peers pending'
old_next = 'Independent Rust80.2 is next; the selection evidence above is historical.'
assert text.count(old_status) == text.count(old_next) == 1
text = text.replace(old_status, 'status: focused selection42 frozen; all five bounded80 backend outcomes recorded; full admission separate', 1)
text = text.replace(old_next, '''Rust80.2, Dart80.3, Julia80.4 and installed Lua80.5 now have independent focused
outcomes too. See [[rust-open-arity-concat-result-guards]],
[[dart-open-arity-concat-result-guards]], [[julia-open-arity-concat-result-guards]]
and [[lua-open-arity-concat-result-guards]]. Remeasure committed outgoing bytes,
then inspect remaining coverage/current canonical discovery before admission or
size-driven publication. Raw-error4.28 remains before admission AND push. The
selection evidence above is historical.''', 1)
(OUT / 'before.md.gz').write_bytes(gzip.compress(prior, mtime=0))
(OUT / 'after.md.gz').write_bytes(gzip.compress(text.encode(), mtime=0))
assert gzip.decompress((OUT / 'before.md.gz').read_bytes()) == prior
assert gzip.decompress((OUT / 'after.md.gz').read_bytes()) == text.encode()
assert Path(CARD).read_bytes() == prior
Path(CARD).write_text(text)
print(json.dumps(dict(selection_frontier='CORRECTED', claim_records=len(records), checked_intersections=len(hits), live_intersections=0, before_sha256=hashlib.sha256(prior).hexdigest(), after_sha256=hashlib.sha256(text.encode()).hexdigest(), scope='Current status and next-action prose only; every original selection observation/hash remains unchanged.')))
