"""Preserve the first complete audit refusal and scope mutations to the owned block."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
AUDITOR='tests/language-readiness/verify_objectives.py'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'controls-repair.json');assert not target.exists()
registration=json.loads((ROOT/(PREFIX+'registration.json')).read_bytes())
source=(ROOT/AUDITOR).read_bytes();runner=(ROOT/'tools/run_ci_local.sh').read_bytes()
assert sha(source)==registration['auditor_after_sha256']
assert sha(runner)==registration['runner_after_sha256']
channels_raw=(ROOT/(PREFIX+'audit-channels.json.gz')).read_bytes()
channels=json.loads(gzip.decompress(channels_raw))
assert channels['returncode']!=0 and b'private fixture path is not unique' in base64.b64decode(channels['stderr_base64'])
assert not channels['stdout_base64']
# The caller joins selection capture before applying this source correction.
selection=json.loads((ROOT/(PREFIX+'selection.json')).read_bytes())
assert selection['result']=='PASS' and len(selection['rows'])==5
block=(ROOT/(PREFIX+'registration-block.sh')).read_bytes()
paths=registration['suites']+registration['helpers']
census={p:dict(whole_runner=runner.count((' '+p+'\n').encode()),owned_block=block.count((' '+p+'\n').encode())) for p in paths}
assert all(v['owned_block']==1 for v in census.values())
collisions={p:v for p,v in census.items() if v['whole_runner']!=1}
assert len(collisions)==6 and {v['whole_runner'] for v in collisions.values()}=={3,4}
old=b'''            for path in PRIVATE_FACTORY_FIXTURE_PATHS:
                line = b" " + path.encode() + b"\\n"
                require(current.count(line) == 1, "private fixture path is not unique")
                altered += (current.replace(line, b"", 1),
                            current.replace(line, line * 2, 1))
'''
new=b'''            block = PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS[0][1]
            for path in PRIVATE_FACTORY_FIXTURE_PATHS:
                line = b" " + path.encode() + b"\\n"
                require(block.count(line) == 1, "private fixture path is not unique in its block")
                altered += (current.replace(block, block.replace(line, b"", 1), 1),
                            current.replace(block, block.replace(line, line * 2, 1), 1))
'''
assert source.count(old)==1
corrected=source.replace(old,new,1)
with (ROOT/(PREFIX+'auditor-first.py')).open('xb') as output:output.write(source)
capture=(ROOT/(PREFIX+'capture-audit.py')).read_bytes()
final_capture=capture.replace(b"PREFIX+'audit.json'",b"PREFIX+'audit-final.json'")
final_capture=final_capture.replace(b'audit-channels.json.gz',b'audit-final-channels.json.gz')
final_capture=final_capture.replace(b'audit-inputs.json.gz',b'audit-final-inputs.json.gz')
final_capture=final_capture.replace(b"PREFIX+'capture-audit.py'",b"PREFIX+'capture-audit-final.py'")
with (ROOT/(PREFIX+'capture-audit-final.py')).open('xb') as output:output.write(final_capture)
record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
    original_auditor_sha256=sha(source),corrected_auditor_sha256=sha(corrected),
    first_capture_sha256=sha(capture),final_capture_sha256=sha(final_capture),
    actual_failed_channels_sha256=sha(channels_raw),old_base64=encode(old),new_base64=encode(new),
    path_census=census,collisions=collisions,selection_sha256=sha((ROOT/(PREFIX+'selection.json')).read_bytes()),
    scope='Full original registered auditor and actual failed complete-proof command/channels remain unchanged. Six path suffixes also occur in older commands; all137 occur once in the exact owned block. Replace only omission/duplication control generation with block-scoped replacements, preserving outside bytes. Selection capture completes first: it runs Bash and guards but never executes the provisional auditor. Final fresh canonical proof still governs admission; first and final complete-audit epochs stay separate.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
(ROOT/AUDITOR).write_bytes(corrected)
print('Audit-control correction PASS:six collisions localized;all137 paths scoped to owned block;original failure retained')
