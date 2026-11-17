"""Retain the observed book log and check rendered text and claim-owner correction."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
plan = json.loads((BASE / 'plan.json').read_bytes())
claim_path = Path('docs/claims/' + plan['owner'] + '.json')
correction = json.loads((BASE / 'claim-owner-correction.json').read_bytes())
before = gzip.decompress((BASE / 'claim-owner-draft.json.gz').read_bytes())
after = claim_path.read_bytes()
assert hashlib.sha256(before).hexdigest() == correction['before_sha256']
assert hashlib.sha256(after).hexdigest() == correction['after_sha256']
original, current = json.loads(before), json.loads(after)
assert original['claims'][0]['falsify']['repair_owner'] == correction['old']
original['claims'][0]['falsify']['repair_owner'] = correction['new']
assert current == original and correction['new'] == plan['owner'].rsplit('.', 3)[0] + '.2'
log = Path('.linkedspec-data/perl-named-includes-book.log').read_bytes()
assert b'HTML book written' in log and b'ERROR' not in log
with (BASE / 'book.log.gz').open('xb') as stream:
    stream.write(gzip.compress(log, mtime=0))
render = Path('docs/linkedspec-book/book/development/documentation-workflow.html')
text = render.read_text()
start = text.index('<p>Named Perl includes need caller roles')
paragraph = text[start:text.index('</p>', start) + len('</p>')]
assert 'twelve suite files and two package probe libraries' in paragraph
assert 'unless caller;' in paragraph and 'unless (caller)' in paragraph and 'Source-derived paths' in paragraph
(BASE / 'book-rendered-paragraph.html').write_text(paragraph + '\n')
(BASE / 'book-review.json').write_text(json.dumps(dict(result='PASS', command='bash tools/run_mdbook_local.sh',
    observed_build_exit=0, source_log='.linkedspec-data/perl-named-includes-book.log',
    raw_log_bytes=len(log), raw_log_sha256=hashlib.sha256(log).hexdigest(), rendered_path=str(render),
    rendered_sha256=hashlib.sha256(render.read_bytes()).hexdigest(), claim_owner_correction='Only new claim follow-up owner changed; actual used publisher/draft retained.',
    recording='After-use log/render copies; no fresh first-use/whole-book semantic/native closure claim.'), indent=2) + '\n')
print('book paragraph and exact claim-owner correction PASS')
