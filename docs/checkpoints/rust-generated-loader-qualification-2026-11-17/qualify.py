"""Derive implementation-scoped names without replaying or editing capture."""
import gzip
import importlib.util
import json
from pathlib import Path
import subprocess
import stat
import tarfile
import hashlib

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    assert not (BASE / 'qualification.json').exists(), 'one-shot qualification'
    identities = {}
    with tarfile.open(BASE / 'qualifier-inputs.tar.gz', 'x:gz') as archive:
        for leaf in ('qualify.py', 'review_qualified.py'):
            path = BASE / leaf
            data = path.read_bytes()
            identities[str(path)] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=str(path), recursive=False)
    (BASE / 'qualifier-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    spec = importlib.util.spec_from_file_location('original_generated_reader', BASE / 'review.py')
    original = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    sources, _ = original.recover()
    body = sources[str(BASE / 'review.py')].decode()
    assert body == (BASE / 'review.py').read_text()
    old = "    found = {}\n    for hit in re.finditer(r'\\bfn\\s+(\\w+)\\s*\\(', code):"
    new = """    found = {}
    implementations = []
    for owner in re.finditer(r'\\bimpl\\s+(?:Drop\\s+for\\s+)?(\\w+)\\s*\\{', code):
        depth, end = 1, owner.end()
        while depth:
            depth += (code[end] == '{') - (code[end] == '}')
            end += 1
        implementations.append((owner.start(), end, owner[1]))
    for hit in re.finditer(r'\\bfn\\s+(\\w+)\\s*\\(', code):"""
    replacements = [(old, new),
        ("        assert hit[1] not in found, 'unique parent function'\n        found[hit[1]] = dict(",
         "        owners = [owner for start, stop, owner in implementations if start < hit.start() < stop]\n        assert len(owners) <= 1, 'bounded implementation scope'\n        key = (owners[0] + '::' if owners else '') + hit[1]\n        assert key not in found, 'unique scoped parent function'\n        found[key] = dict("),
        ("funcs['cargo']", "funcs['TempProject::cargo']"),
        ("funcs['new']", "funcs['TempProject::new']"),
        ("funcs['drop']", "funcs['TempProject::drop']")]
    for before, after in replacements:
        assert body.count(before) == 1, before
        body = body.replace(before, after, 1)
    (BASE / 'qualification.json').write_text(json.dumps(dict(replacements=replacements, derived_source=body,
        scope='Only implementation-scoped method lookup; original graph construction and capture inputs remain unchanged.'), indent=2) + '\n')
    module = dict(__file__=str(BASE / 'review.py'), __name__='qualified_generated_reader')
    exec(compile(body, str(BASE / 'review.py'), 'exec'), module)
    ledger = module['scan'](sources)
    (BASE / 'loaders.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_qualified.py'), '--current']
    (BASE / 'qualified-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / ('qualified-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / 'qualified-exit.txt').write_text(str(result.returncode) + '\n')
    print(result.stdout.decode(), end='')
    assert result.returncode == 0, result.stderr.decode()


if __name__ == '__main__':
    main()
