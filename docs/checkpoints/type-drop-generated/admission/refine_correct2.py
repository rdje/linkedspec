"""Retain the final seven-byte size rejection and remove duplicate wording."""
import ast
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

path=c.PREFIX+'admission/correct.py'
before=c.read(path)
run=c.run(['bash','tools/run_python_project_data.sh',path])
assert run['returncode']!=0 and b'AssertionError: (3052, 3045)' in c.decode(run['stderr_base64'])
text=c.decode(before['base64']).decode()
old='Numeric owner5 inverses21 value assertions/shared frame before old70 (hunk3\noverlaps), reconstructing real accepted203cde315 bytes.'
new='Numeric5 inverses21 value assertions/shared frame before old70 (hunk3 overlaps),\nfrom accepted203cde315 bytes.'
assert text.count(old)==1
text=text.replace(old,new,1)
facts=[ast.literal_eval(node.value) for node in ast.walk(ast.parse(text)) if isinstance(node,ast.Assign)
       and any(isinstance(target,ast.Name) and target.id=='fact' for target in node.targets)]
assert len(facts)==1 and len(facts[0].encode())<=3045
c.write_new('admission/correction-size-preparation2.json.gz',dict(before=before,after_base64=c.encode(text.encode()),run=run,
 producer=c.read(c.PREFIX+'admission/refine_correct2.py'),fact_bytes=len(facts[0].encode()),
 scope='Second size guard stopped before bound writes at3052/3045. Preserve actual source/run; '
       'remove duplicated owner/reconstruction wording without removing any fact or raising a limit.'))
(c.ROOT/path).write_text(text)
print('Second size rejection retained; final fact bytes',len(facts[0].encode()))
