"""Exercise the unchanged original auditor with its accepted canonical hash oracle."""
import gzip
import hashlib
import importlib.util
import json
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
LOG='docs/checkpoints/REPO-HYGIENE.19/canonical.log.gz'
text=gzip.decompress((ROOT/LOG).read_bytes()).decode()
found=list(re.finditer(r'"audit_report"\s*:\s*(\{)',text))
assert len(found)==1,'complete accepted canonical historical audit report'
report,_=json.JSONDecoder().raw_decode(text,found[0].start(1))
row=next(v for v in report['governance_updates'] if v['path']=='tools/run_ci_local.sh')
original=(ROOT/(PREFIX+'runner-original.sh')).read_bytes()
assert row['current']==hashlib.sha256(original).hexdigest(),'actual accepted runner oracle'
spec=importlib.util.spec_from_file_location('original_objective_auditor',ROOT/(PREFIX+'auditor-original.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
result=module.verify_governance_evolution('tools/run_ci_local.sh',(ROOT/'tools/run_ci_local.sh').read_bytes(),row['historical'])
print(json.dumps(result,sort_keys=True))
