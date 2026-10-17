"""Retain the actual history refusal and complete malformed current input once."""
import base64,gzip,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/REPO-HYGIENE.18-'
sha=lambda b:hashlib.sha256(b).hexdigest()
original=(ROOT/'CHANGES.md').read_bytes()
command=['perl','tools/roll_document_history.pl','--surface','change_history','--check']
p=subprocess.run(command,cwd=ROOT,capture_output=True)
report=dict(owner='REPO-HYGIENE.18',producer_sha256=sha(Path(__file__).read_bytes()),command=command,returncode=p.returncode,
            stdout_base64=base64.b64encode(p.stdout).decode(),stderr_base64=base64.b64encode(p.stderr).decode(),
            root_base64=base64.b64encode(original).decode(),root_sha256=sha(original),
            checker_sha256=sha((ROOT/'tools/roll_document_history.pl').read_bytes()),
            cause='Insertion selected inline ## in the introductory paragraph rather than an anchored heading. Later own-record rewrite removed the manifest preamble. Restore the entire accepted preamble from Git and insert only at a multiline anchored heading. The unexecuted final reader is corrected before execution; original failed publisher remains unchanged.')
with (ROOT/(PREFIX+'history-refusal.json.gz')).open('xb') as f:f.write(gzip.compress(json.dumps(report,sort_keys=True).encode(),mtime=0))
assert p.returncode!=0 and not p.stdout and p.stderr==b'change_history current preamble omits its history manifest\n'
assert (ROOT/'CHANGES.md').read_bytes()==original
print('History refusal retained:',p.returncode,'complete original root and both channels')
