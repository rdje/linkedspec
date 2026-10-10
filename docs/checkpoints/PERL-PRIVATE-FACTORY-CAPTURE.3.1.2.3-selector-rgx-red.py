"""Reproduce the actual claim validator's tracked-file reader against the rejected record."""
import ast,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
path=ROOT/'tools/check_claim_verification.py'
spec=importlib.util.spec_from_file_location('actual_claims',path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
tree=ast.parse(path.read_bytes())
run=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run_check')
reader=next(n for n in run.body if isinstance(n,ast.FunctionDef) and n.name=='read_input')
namespace=dict(m.__dict__,files=m.index_files())
exec(compile(ast.Module(body=[reader],type_ignores=[]),str(path),'exec'),namespace)
raw=(ROOT/(PREFIX+'selector-claim-before-rgx.json')).read_bytes()
m.validate(m.strict_json(raw),'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json',namespace['read_input'],lambda owner:None)
