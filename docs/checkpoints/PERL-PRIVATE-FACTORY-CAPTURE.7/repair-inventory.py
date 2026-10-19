"""Preserve the first path-scope refusal; accept the supplied checkpoint fixture."""
import base64
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
sha=lambda v:hashlib.sha256(v).hexdigest()
source=(ROOT/(PREFIX+'inventory.py')).read_bytes()
channel=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-inventory-first.log').read_bytes()
assert b"assert len(suites)==len(set(suites))==91 and all(p.startswith('t/')" in channel and channel.rstrip().endswith(b'AssertionError')
old=b"all(p.startswith('t/') and p.endswith('.t') for p in suites)"
new=b"all(p.endswith('.t') and not Path(p).is_absolute() and '..' not in Path(p).parts for p in suites)"
assert source.count(old)==1
corrected=source.replace(old,new).replace(b"PREFIX+'inventory.py'",b"PREFIX+'inventory-final.py'")
corrected=corrected.replace(b"('inventory.py','runner-original.sh'",b"('inventory-final.py','runner-original.sh'")
target=ROOT/(PREFIX+'inventory-final.py');assert not target.exists()
with (ROOT/(PREFIX+'inventory-repair.json')).open('x') as output:
    output.write(json.dumps(dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
        original_source_sha256=sha(source),original_exit_observed=1,
        original_combined_base64=base64.b64encode(channel).decode(),old_base64=base64.b64encode(old).decode(),
        new_base64=base64.b64encode(new).decode(),corrected_sha256=sha(corrected),
        scope='The first inventory assumes every supplied suite lives under t/. The unchanged accepted91 distinct suites include one docs/checkpoints origin fixture. Refusal occurs before original runner/auditor/report writes. Preserve the full redirected combined channel and actual tool-observed exit1; only require a repository-relative .t path instead. No accepted fixture, input, command or runner changes.'),indent=2)+'\n')
target.write_bytes(corrected)
print('Inventory correction PASS: retained original refusal; supplied checkpoint suite included')
