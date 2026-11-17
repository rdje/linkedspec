"""Recover the original method-name refusal and separately qualified reader."""
import importlib.util
import contextlib
import io
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
identities = json.loads((BASE / 'qualifier-identities.json').read_bytes())
with tarfile.open(BASE / 'qualifier-inputs.tar.gz') as archive:
    assert len(archive.getmembers()) == len(identities) == 2
    for member in archive:
        assert member.isfile() and member.name in identities
        data = archive.extractfile(member).read()
        row = identities[member.name]
        assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
        assert stat.S_IMODE(member.mode) == row['mode']
        assert Path(member.name).read_bytes() == data and stat.S_IMODE(Path(member.name).stat().st_mode) == row['mode']
spec = importlib.util.spec_from_file_location('retained_original_generated', BASE / 'review.py')
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
sources, _ = original.recover()
plan = json.loads(sources[str(BASE / 'plan.json')])
source = sources[plan['consumer']].decode()
assert source.count('    fn new(') == 2
try:
    original.functions(source)
except AssertionError as error:
    assert str(error) == 'unique parent function'
else:
    raise AssertionError('original scoped-name refusal was not reproduced')
qualified = json.loads((BASE / 'qualification.json').read_bytes())
body = sources[str(BASE / 'review.py')].decode()
for before, after in qualified['replacements']:
    assert body.count(before) == 1
    body = body.replace(before, after, 1)
assert body == qualified['derived_source'], 'full derived reader bytes'
module = dict(__file__=str(BASE / 'review.py'), __name__='retained_qualified_generated')
exec(compile(body, str(BASE / 'review.py'), 'exec'), module)
_, funcs = module['functions'](source)
assert 'CaseFailure::new' in funcs and 'TempProject::new' in funcs
assert 'stage' in funcs['CaseFailure::new']['body']
assert 'std::env::temp_dir()' in funcs['TempProject::new']['body']
refusal = dict(original_refusal='RED unique parent function', actual_victims={
    name: dict(line=funcs[name]['line']) for name in ('CaseFailure::new', 'TempProject::new')},
    qualification='Implementation-scoped method names; original source/capture/exit1 channels unchanged.')
output = io.StringIO()
with contextlib.redirect_stdout(output):
    module['main']()
result = json.loads(output.getvalue())
result.update(refusal)
print(json.dumps(result, indent=2, sort_keys=True))
