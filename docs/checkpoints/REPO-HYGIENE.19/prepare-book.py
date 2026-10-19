"""Prepare one workflow overlay from actual dated metadata and reported summaries."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
CHAPTER='docs/linkedspec-book/src/development/documentation-workflow.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'book-preparation.json');assert not target.exists()
old=subprocess.check_output(['git','show',BASE+':'+CHAPTER],cwd=ROOT)
assert (ROOT/CHAPTER).read_bytes()==old
metadata=json.loads((ROOT/(PREFIX+'actual-review.json')).read_bytes())
warning=json.loads((ROOT/(PREFIX+'warning-review.json')).read_bytes())
assert metadata['result']==warning['result']=='PASS'
text=old.decode()
start=text.index('The current verification entrypoint checks this finite continuity admission and\n')
end=text.index('The complete initial546-input logical draft',start)
replacement=('The current verification entrypoint checks this dated retention and reported-output\n'
    'review and preserves the complete 550-input finite-capacity publication and its actual\n'
    'successful baseline at `e953f69a9`. The complete 565-input mixed-default/package-object\n'
    'publication remains at `54bb5eb65`, retaining native observations, exact definition-owned\n'
    'selection, full-source faults, supplied consumers and the public Perl diagnostic contract.\n'
    'Administrative maintenance refreshes none of those observations.\n')
text=text[:start]+replacement+text[end:]
old_scope='refreshed. Only the finite allowances above change; all other budgets stay fixed:'
new_scope='refreshed. The finite example above changes only its listed allowances; this dated\nretention review changes no budget:'
assert text.count(old_scope)==1;text=text.replace(old_scope,new_scope,1)
old_route='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/publish.py'
assert text.count(old_route)==1;text=text.replace(old_route,PREFIX+'publish.py',1)
incremental=metadata['rust']['rust/target/debug/incremental']
example=('### Dated retention and reported-output example\n\n'
    'The current dated review retained '+str(metadata['parent_files'])+' parent artifact rows and '
    +str(incremental['files'])+' Rust incremental rows, with zero removals. Independent live\n'
    'census and per-file metadata checks ran before publication. Keep the dated snapshot,\n'
    'complete command channels and reusable caches; a retention review supplies no\n'
    'content-ownership, disposability or liveness permission.\n\n'
    '| Public compiler summary | Occurrences in captured log | Reported count per summary |\n'
    '| --- | --- | --- |\n')
for crate in ('pgen','rgx-core'):
    assert len(warning['reported_values'][crate])==1
    example+='| '+crate+' | '+str(warning['counts_by_crate'][crate])+' | '+str(warning['reported_values'][crate][0])+' |\n'
example+=('\nEach row records compiler reports from the warranted canonical run. Distinct\n'
    'diagnostics, defects, comparable configurations and internal causes remain unassessed.\n'
    'The earlier dated 1870/26 account stays preserved. The upstream-owned warning census\n'
    'and reporting tasks remain open; this observation introduces no new dependency build,\n'
    'implementation inspection, pin change or warning suppression.\n\n')
anchor='Preserve any live evidence that binds the root or book before changing them.\n'
assert text.count(anchor)==1;text=text.replace(anchor,example+anchor,1)
new=text.encode()
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
    chapter=CHAPTER,original_base64=base64.b64encode(old).decode(),original_sha256=sha(old),current_sha256=sha(new),
    oracle_inputs={PREFIX+n:sha((ROOT/(PREFIX+n)).read_bytes()) for n in ('actual-review.json','warning-review.json')},
    scope='One workflow overlay preserves the whole accepted chapter, changes the current readonly entrypoint and derives dated metadata/compiler-summary teaching from actual independently reviewed observations. Existing finite allowances and native ActionIR teaching remain unchanged; no new feature or budget admission.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
(ROOT/CHAPTER).write_bytes(new)
print('Book workflow overlay prepared from actual dated metadata and compiler-summary observations')
