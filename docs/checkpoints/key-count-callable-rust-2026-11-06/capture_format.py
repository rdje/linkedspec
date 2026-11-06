"""One-shot scoped formatting proof without changing the accepted normal."""
import hashlib,json,subprocess
from pathlib import Path
b=Path(__file__).resolve().parent.relative_to(Path.cwd());out=b/'format';out.mkdir()
p=Path('rust/linkedspec-runtime/tests/key_count_callable_result_guard_composition.rs');body=p.read_bytes()
(out/'input.json').write_text(json.dumps({'path':str(p),'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)},indent=2)+'\n')
command=['rustfmt','--edition','2024','--check',str(p)]
(out/'command.json').write_text(json.dumps(command,indent=2)+'\n')
with (out/'stdout.log').open('xb') as stdout,(out/'stderr.log').open('xb') as stderr:
 r=subprocess.run(command,stdout=stdout,stderr=stderr)
(out/'exit.txt').write_text(str(r.returncode)+'\n')
assert r.returncode==0 and p.read_bytes()==body
print('Scoped Rust format PASS; normal bytes unchanged.')
