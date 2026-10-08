"""Route the complete authority teaching block to its contributor documentation owner."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
CI = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
def sha(raw): return hashlib.sha256(raw).hexdigest()
report = ROOT/(PREFIX+'book-routing.json')
assert not report.exists(), 'one-shot routing after original candidate retention'
snapshot = json.loads((ROOT/(PREFIX+'rejected-docs.json')).read_bytes())
assert snapshot['complete']
before = {path:(ROOT/path).read_bytes() for path in (CI,WORKFLOW)}
assert sha(before[CI]) == snapshot['pressure']['source_sha256']
assert before[WORKFLOW] == subprocess.check_output(['git','show','HEAD:'+WORKFLOW],cwd=ROOT)
book = before[CI].decode()
start = book.index('An authority record must contain exactly one canonical')
end = book.index('#### Bounded views over exact history',start)
block = book[start:end]
assert block.count('```') == 2 and '- Status: accepted; qualified engineering decision' in block
book = book[:start]+book[end:]
old = 'lives in `docs/knowledge/readme-stability-policy.md` and `docs/tasks/README-STABILITY-POLICY.md`.'
new = old+' See [accepted decision authority](documentation-workflow.md#accepted-decision-authority) for the Status rule and examples.'
assert book.count(old) == 1
book = book.replace(old,new,1)
workflow = before[WORKFLOW].decode()
old_counter = 'proves 62 exact routes over 20 surfaces and all 32 mutation classes before the README doctrine can pass.'
assert workflow.count(old_counter) == 1
workflow = workflow.replace(old_counter,old_counter.replace('all 32','all 40'),1)
marker = '## Public book\n'
assert workflow.count(marker) == 1 and '## Accepted decision authority\n' not in workflow
workflow = workflow.replace(marker,'## Accepted decision authority\n\n'+block+marker,1)
after = {CI:book.encode(),WORKFLOW:workflow.encode()}
assert len(after[CI].splitlines()) == 2047 and block.encode() in after[WORKFLOW]
for path,raw in after.items(): (ROOT/path).write_bytes(raw)
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),
          'before_hashes':{path:sha(raw) for path,raw in before.items()},'after_hashes':{path:sha(raw) for path,raw in after.items()},
          'moved_block_sha256':sha(block.encode()),'moved_block_bytes':len(block.encode()),
          'ci_chapter_lines_before':len(before[CI].splitlines()),'ci_chapter_lines_after':len(after[CI].splitlines()),
          'scope':'The full original authority teaching block moves byte-for-byte into the documentation-workflow chapter. The CI chapter uses a link on an existing line; no cap changes or content loss. The direct workflow counter updates32 to40 for the same repaired current oracle; historical adoption results remain unchanged. Initial rejected candidate/source/claim/channels remain independently recoverable; focused routing, render, final identity publication and fresh exact canonical admission are required.'}
report.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'ci_chapter_lines':result['ci_chapter_lines_after'],'moved_bytes':result['moved_block_bytes']}))
