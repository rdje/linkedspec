"""Resume the preserved registration suffix with one uniquely scoped metadata anchor."""
import base64
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
RUNNER='tools/run_ci_local.sh'
AUDITOR='tests/language-readiness/verify_objectives.py'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'registration.json');assert not target.exists()
source=(ROOT/(PREFIX+'register.py')).read_bytes()
channel=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-register.log').read_bytes()
assert b'line 59' in channel and b'assert auditor.count(old)==1' in channel and channel.rstrip().endswith(b'AssertionError')
inventory=json.loads((ROOT/(PREFIX+'inventory.json')).read_bytes())
suites=inventory['suites'];helpers=inventory['helpers']
old_runner=(ROOT/(PREFIX+'runner-original.sh')).read_bytes()
old_auditor=(ROOT/(PREFIX+'auditor-original.py')).read_bytes()
block=(ROOT/(PREFIX+'registration-block.sh')).read_bytes()
anchor=b'PERL5LIB= prove -Iperl t/actionir_raw_dependency_metadata.t t/actionir_raw_dependency_provenance.t t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n'
runner=old_runner.replace(anchor,anchor+block,1)
assert (ROOT/RUNNER).read_bytes()==runner and (ROOT/AUDITOR).read_bytes()==old_auditor
baseline=json.loads((ROOT/(PREFIX+'audit-original-baseline.json')).read_bytes())
rejected=json.loads((ROOT/(PREFIX+'audit-original-red.json')).read_bytes())
assert baseline['returncode']==0 and rejected['returncode']!=0
assert b'unreviewed governance drift: tools/run_ci_local.sh' in base64.b64decode(rejected['stderr_base64'])
assert old_auditor.count(b'            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\n')==2
old=b'''old=b'            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\\n'\n'''
new=b'''old=b'            "scalar_receiver_copy_owner": SCALAR_RECEIVER_COPY_OWNER,\\n            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\\n'\n'''
assert source.count(old)==1
suffix=b'constant=('+source.split(b'\nconstant=(',1)[1]
assert suffix.count(old)==1
corrected=suffix.replace(old,new,1)
old_inputs=b"('register.py','inventory-final.py'"
new_inputs=b"('register.py','finish-registration.py','registration-repair.json','inventory-final.py'"
assert corrected.count(old_inputs)==1
corrected=corrected.replace(old_inputs,new_inputs,1)
with (ROOT/(PREFIX+'registration-repair.json')).open('x') as output:
    output.write(json.dumps(dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
        original_source_sha256=sha(source),original_exit_observed=1,original_combined_base64=encode(channel),
        old_base64=encode(old),new_base64=encode(new),original_suffix_sha256=sha(suffix),
        corrected_suffix_sha256=sha(corrected),
        scope='Original metadata anchor occurs in two functions. The preceding scalar receiver-copy owner narrows it to the governance return. Resume the exact original suffix after runner insertion and saved baseline/RED; add this actual repair source/report to inputs. No original file/channel, runner insertion, fixture, runtime or limit is changed or replayed.'),indent=2)+'\n')
exec(compile(corrected,str(Path(__file__)), 'exec'),globals())
