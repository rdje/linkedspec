"""Promote complete warranted public-output evidence; no dependency source is read."""
import base64
import datetime
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
ORIGIN='.linkedspec-data/verification/'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'warning.json');assert not target.exists()
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()==BASE
copies={
    'warning-partial.json':'RUST-DEPENDENCY-WARNING-ZERO.1-canonical-observation.json',
    'warning-final.json':'RUST-DEPENDENCY-WARNING-ZERO.1-final-canonical-observation.json',
    'canonical.log.gz':'PERL-PRIVATE-FACTORY-CAPTURE.5.8-canonical-attempt1.log.gz',
    'canonical-staged.receipt':'PERL-PRIVATE-FACTORY-CAPTURE.5.8-staged-canonical.receipt',
    'canonical-committed.receipt':'canonical-v1.receipt',
}
inputs={}
for name,origin in copies.items():
    source=ROOT/(ORIGIN+origin);data=source.read_bytes()
    assert source.is_file() and not source.is_symlink() and source.stat().st_dev==ROOT.stat().st_dev
    with (ROOT/(PREFIX+name)).open('xb') as output:output.write(data)
    inputs[PREFIX+name]=sha(data)
partial=json.loads((ROOT/(PREFIX+'warning-partial.json')).read_bytes())
final=json.loads((ROOT/(PREFIX+'warning-final.json')).read_bytes())
assert partial['log_complete'] is False and final['log_complete'] is True
packed=(ROOT/(PREFIX+'canonical.log.gz')).read_bytes();log=gzip.decompress(packed)
assert sha(packed)==final['archive_sha256'] and sha(log)==final['log_sha256'] and len(log)==final['log_bytes']
assert log.rstrip().endswith(b'[ci] local CI gate passed')
lines=log.decode('utf-8').splitlines();phase=None;rows=[]
for number,line in enumerate(lines,1):
    if line.startswith('[ci] '):phase=line
    matched=re.fullmatch(r'warning: `(pgen|rgx-core)` \(lib\) generated (\d+) warnings(?:.*)',line)
    if matched:rows.append(dict(log_line=number,phase=phase,crate=matched[1],reported_warnings=int(matched[2]),summary=line))
assert rows==final['summaries']
lookup={v['log_line']:v for v in rows}
for value in partial['summaries']:
    full=lookup[value['log_line']]
    assert all(full[k]==v for k,v in value.items())
def receipt(name):
    raw=(ROOT/(PREFIX+name)).read_bytes()
    fields=[v.split('=',1) for v in raw.decode().splitlines()]
    assert len(fields)==5 and len({v[0] for v in fields})==5
    return raw,dict(fields)
staged_raw,staged=receipt('canonical-staged.receipt')
committed_raw,committed=receipt('canonical-committed.receipt')
parent=subprocess.check_output(['git','rev-parse',BASE+'^1'],cwd=ROOT,text=True).strip()
tree=subprocess.check_output(['git','rev-parse',BASE+'^{tree}'],cwd=ROOT,text=True).strip()
delta=subprocess.check_output(['git','diff','--binary','--full-index','--no-ext-diff',parent,BASE],cwd=ROOT)
assert staged==dict(version='1',state='staged',head=parent,content=sha(delta),gate='tools/run_ci_local.sh')
assert committed==dict(version='1',state='committed',head=BASE,content=tree,gate='tools/run_ci_local.sh')
assert sha(staged_raw)==final['staged_receipt_sha256'] and base64.b64decode(final['staged_receipt_base64'],validate=True)==staged_raw
assert ('verification-receipt: wrote staged canonical receipt for HEAD '+parent+' and candidate '+sha(delta)).encode() in log
card='docs/knowledge/rust-dependency-warning-baseline.md'
old=subprocess.check_output(['git','show',BASE+':'+card],cwd=ROOT)
with (ROOT/(PREFIX+'warning-historical-card.md')).open('xb') as output:output.write(old)
inputs[PREFIX+'warning-historical-card.md']=sha(old)
prior=re.search(rb'Completed Rust builds repeatedly reported ([0-9,]+) warnings for `pgen` and ([0-9,]+) for\s+`rgx-core`',old)
assert prior
baseline=dict(pgen=int(prior[1].replace(b',',b'')),**{'rgx-core':int(prior[2].replace(b',',b''))})
values={name:sorted({v['reported_warnings'] for v in rows if v['crate']==name}) for name in baseline}
assert all(values.values())
record=dict(result='PASS',owner='RUST-DEPENDENCY-WARNING-ZERO.1',maintenance_owner='REPO-HYGIENE.19',base=BASE,
    producer_sha256=sha(Path(__file__).read_bytes()),inputs=inputs,
    log_bytes=len(log),log_sha256=sha(log),staged_candidate_sha256=sha(delta),committed_tree=tree,
    rows=rows,reported_values=values,historical_reported_values=baseline,
    tool_versions_observed_in_partial={k:partial[k] for k in ('rustc','cargo')},
    scope='Per-occurrence compiler-reported summary counts in one complete successful warranted canonical output. Independent review must retain every raw line/nearest public CI phase and distinguish omission, wrong crate/count or forged log/receipt. These are not distinct diagnostics/bugs, comparable build configurations or internal causes. CLI tool identities are observed, not an immutable compiler/environment closure. Old1870/26 evidence stays dated. RUST-DEPENDENCY-WARNING-ZERO.1/.2 retain the non-blocking fuller census and upstream-report/evaluation schedule; this partial public-output account closes neither. No dependency implementation is inspected or changed and no warning-suppressing/source-changing cargo suggestion is executed.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
print('Public warning-output evidence retained:',len(rows),'summary occurrences;',json.dumps(values,sort_keys=True))
