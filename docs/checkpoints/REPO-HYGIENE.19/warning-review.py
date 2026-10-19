"""Readonly independent raw-line/phase/count and accepted-receipt review."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(name):inputs.add(PREFIX+name);return (ROOT/(PREFIX+name)).read_bytes()
def parse_receipt(name):
    data=raw(name);pairs=[v.split('=',1) for v in data.decode().splitlines()]
    assert len(pairs)==5 and len({v[0] for v in pairs})==5
    return data,dict(pairs)
record=json.loads(raw('warning.json'))
assert record['result']=='PASS' and record['base']==BASE
assert record['producer_sha256']==sha(raw('warning.py'))
partial=json.loads(raw('warning-partial.json'));final=json.loads(raw('warning-final.json'))
assert partial['log_complete'] is False and final['log_complete'] is True
packed=raw('canonical.log.gz');log=gzip.decompress(packed)
assert sha(packed)==final['archive_sha256'] and len(log)==record['log_bytes']==final['log_bytes']
assert sha(log)==record['log_sha256']==final['log_sha256'],'actual complete canonical log custody'
assert log.rstrip().endswith(b'[ci] local CI gate passed')
parent=subprocess.check_output(['git','rev-parse',BASE+'^1'],cwd=ROOT,text=True).strip()
tree=subprocess.check_output(['git','rev-parse',BASE+'^{tree}'],cwd=ROOT,text=True).strip()
delta=subprocess.check_output(['git','diff','--binary','--full-index','--no-ext-diff',parent,BASE],cwd=ROOT)
staged_raw,staged=parse_receipt('canonical-staged.receipt')
committed_raw,committed=parse_receipt('canonical-committed.receipt')
assert staged==dict(version='1',state='staged',head=parent,content=sha(delta),gate='tools/run_ci_local.sh'),'actual staged canonical receipt'
assert committed==dict(version='1',state='committed',head=BASE,content=tree,gate='tools/run_ci_local.sh'),'actual committed canonical receipt'
assert record['staged_candidate_sha256']==sha(delta) and record['committed_tree']==tree
assert sha(staged_raw)==final['staged_receipt_sha256'] and decode(final['staged_receipt_base64'])==staged_raw
assert ('verification-receipt: wrote staged canonical receipt for HEAD '+parent+' and candidate '+sha(delta)).encode() in log

# Independent bytes/partition parser: preserve every occurrence rather than deduplicating phases.
expected=[];phase=None
for number,line in enumerate(log.splitlines(),1):
    if line.startswith(b'[ci] '):phase=line.decode('utf-8')
    if not line.startswith(b'warning: `'):continue
    crate,separator,rest=line[len(b'warning: `'):].partition(b'` (lib) generated ')
    if not separator or crate not in (b'pgen',b'rgx-core'):continue
    value,separator,tail=rest.partition(b' warnings')
    assert separator and value.isdigit()
    expected.append(dict(log_line=number,phase=phase,crate=crate.decode(),reported_warnings=int(value),summary=line.decode('utf-8')))
actual=record['rows']
assert len(actual)==len(expected)==24,'complete compiler-summary occurrence population'
assert [v['log_line'] for v in actual]==[v['log_line'] for v in expected],'exact compiler-summary line population'
for left,right in zip(actual,expected):
    assert left['crate']==right['crate'] and left['reported_warnings']==right['reported_warnings'],'raw compiler-summary crate/count association'
    assert left['phase']==right['phase'],'nearest public phase association'
    assert left['summary']==right['summary'],'exact original compiler-summary line'
assert final['summaries']==expected,'complete final observation ledger'
by_line={v['log_line']:v for v in expected}
for row in partial['summaries']:assert all(by_line[row['log_line']][k]==v for k,v in row.items()),'unchanged partial observation'
assert record['tool_versions_observed_in_partial']=={k:partial[k] for k in ('rustc','cargo')}
values={name:sorted({v['reported_warnings'] for v in expected if v['crate']==name}) for name in ('pgen','rgx-core')}
assert record['reported_values']==values
old=raw('warning-historical-card.md')
accepted=subprocess.check_output(['git','show',BASE+':docs/knowledge/rust-dependency-warning-baseline.md'],cwd=ROOT)
assert old==accepted,'whole dated historical warning account'
prior=re.search(rb'Completed Rust builds repeatedly reported ([0-9,]+) warnings for `pgen` and ([0-9,]+) for\s+`rgx-core`',old)
assert prior
baseline={'pgen':int(prior[1].replace(b',',b'')),'rgx-core':int(prior[2].replace(b',',b''))}
assert record['historical_reported_values']==baseline
for p,identity in record['inputs'].items():
    assert p.startswith(PREFIX) and sha(raw(p[len(PREFIX):]))==identity
raw('warning-review.py')
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw('warning-review.py')),
    summary_occurrences=len(expected),reported_values=values,historical_reported_values=baseline,
    counts_by_crate={name:sum(v['crate']==name for v in expected) for name in values},
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Independent complete raw compiler-summary occurrence/line/crate/count/nearest-phase reconstruction. Both actual canonical receipts derive from the accepted parent/diff/tree, and separate partial/final observations remain exact. CLI versions are observed, not immutable compiler/configuration claims. Counts are reported summaries, not distinct warnings/bugs or established causes; no dependency implementation or new build is read/run.')
target=ROOT/(PREFIX+'warning-review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Public warning review PASS:',len(expected),'raw summary occurrences;actual receipt/tree;dated baseline retained')
