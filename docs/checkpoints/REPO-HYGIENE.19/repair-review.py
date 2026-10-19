"""Retain the original reader refusal and repair only evidence-expression comparison."""
import base64
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
sha=lambda v:hashlib.sha256(v).hexdigest()
source=(ROOT/(PREFIX+'review-current.py')).read_bytes()
channel=(ROOT/'.linkedspec-data/verification/REPO-HYGIENE.19-review-first.log').read_bytes()
assert b'assert len(source_lines)==len(final_lines)' in channel and channel.rstrip().endswith(b'AssertionError')
old=b'''source_lines=source.splitlines();final_lines=final.splitlines()
assert len(source_lines)==len(final_lines)
differences=[(a,b) for a,b in zip(source_lines,final_lines) if a!=b]
assert len(differences)==2 and differences[0][0].startswith(b'target=') and differences[1][0].startswith(b'evidence=')'''
new=b'''before,evidence=source.split(b'\\nevidence=',1)
old_expression,after=evidence.split(b'\\nheader=re.sub',1)
current_before,current_evidence=final.split(b'\\nevidence=',1)
new_expression,current_after=current_evidence.split(b'\\nheader=re.sub',1)
assert before.replace(b"knowledge-preparation.json",b"knowledge-preparation-final.json")==current_before
assert after==current_after and old_expression!=new_expression
assert b'\\n' in old_expression and b'\\n' not in new_expression'''
assert source.count(old)==1
corrected=source.replace(old,new).replace(b"PREFIX+'review-current.py'",b"PREFIX+'review-final.py'")
corrected=corrected.replace(b"PREFIX+'review-current.json'",b"PREFIX+'review-final.json'")
corrected=corrected.replace(b"{'review-current.json','evidence.py'",b"{'review-current.json','review-final.json','evidence.py'")
target=ROOT/(PREFIX+'review-final.py');assert not target.exists()
with (ROOT/(PREFIX+'review-repair.json')).open('x') as output:
    output.write(json.dumps(dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
        original_source_sha256=sha(source),original_returncode=1,original_stdout_base64='',
        original_stderr_base64=base64.b64encode(channel).decode(),
        old_base64=base64.b64encode(old).decode(),new_base64=base64.b64encode(new).decode(),
        corrected_sha256=sha(corrected),
        scope='The original independent reader incorrectly required equal physical line counts for a four-line evidence expression condensed to one line. Exact actual failed command stderr and source remain unchanged; compare complete expression boundaries and exact prefix/suffix instead. Capture producers, observations, cards and limits stay unchanged.'),indent=2)+'\n')
target.write_bytes(corrected)
print('Reader repair PASS: original refusal retained; exact expression-boundary correction only')
