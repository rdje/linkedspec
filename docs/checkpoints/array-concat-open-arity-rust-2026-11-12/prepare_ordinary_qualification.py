"""Prepare exact ordinary legacy source questions and a private old/current SDK."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
CONTROL = REL / 'ordinary-qualification-owner'
assert not CONTROL.exists()
assert not (BASE / 'ordinary-cases.json').exists()
profile = Path('tests/fixtures/array_transform_result_guard_rust_profiles.json')
body = profile.read_bytes()
assert body == subprocess.check_output(['git', 'show', 'HEAD:' + str(profile)], cwd=ROOT)
(BASE / 'ordinary-profile-original.json.gz').write_bytes(gzip.compress(body, mtime=0))
rows = json.loads(body)
cases = []
tail = '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")}'
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    source = rows[key]['source']
    assert source.count(tail) == 1
    for kind in ('terminal', 'composed'):
        cases.append(dict(id=key + '_' + kind, source=source.replace(tail, '', 1) if kind == 'terminal' else source,
            input=rows[key]['input'], rule='Value', origin='legacy-ordinary195', question=kind, profile_only=True))
(BASE / 'ordinary-cases.json').write_text(json.dumps(cases, indent=2) + '\n')
observer = (BASE / 'observer.rs').read_text()
old = '''    let identity_prefix = if row["origin"].as_str() == Some("legacy312") {
        "array-transform-callable-result"
    } else {
        "array-concat-open-arity-result"
    };'''
assert observer.count(old) == 1
observer = observer.replace(old, '    let identity_prefix = "array-transform-result";', 1)
(BASE / 'ordinary-observer.rs').write_text(observer)
prefix = str(REL / 'direct')
packet, = [row for row in json.loads((BASE / 'direct/custody.json').read_bytes())
    if row['archive'].endswith('/root-inputs.tar.gz')]
for name, row in packet['files'].items():
    if not name.startswith(('rust/', 'tests/', 'specs/', 'cli_conformance/')):
        continue
    path = ROOT / name
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    target = ROOT / CONTROL / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, target)
manifest = ROOT / CONTROL / 'rust/Cargo.toml'
original = manifest.read_text()
assert original.count('path = "../rgx/rgx-core"') == 1
dependency = os.path.relpath(ROOT / 'rgx/rgx-core', manifest.parent)
manifest.write_text(original.replace('path = "../rgx/rgx-core"', 'path = "' + dependency + '"', 1))
(ROOT / CONTROL / 'rust/linkedspec-runtime/src/engine.rs').write_bytes(gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes()))

capture = (BASE / 'capture_intake.py').read_text()
capture = capture.replace('import re\n', 'import re\nimport sys\n')
capture = capture.replace("OUT = BASE / 'intake'", "phase = sys.argv[1]\nassert phase in ('ordinary-old', 'ordinary-fixed')\nOUT = BASE / phase\nCONTROL = BASE / 'ordinary-qualification-owner'")
capture = capture.replace("BASE / 'cases.json'", "BASE / 'ordinary-cases.json'")
capture = capture.replace("BASE / 'observer.rs'", "BASE / 'ordinary-observer.rs'")
capture = capture.replace('== 504', '== 4').replace('Independent504', 'Exact ordinary4')
capture = capture.replace("ROOT / 'rust/linkedspec-runtime'", "ROOT / CONTROL / 'rust/linkedspec-runtime'")
capture = capture.replace("ROOT / 'rust/linkedspec-core'", "ROOT / CONTROL / 'rust/linkedspec-core'")
anchor = "    freeze('root', paths)"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, "    paths += [p for p in CONTROL.rglob('*') if p.is_file()]\n" + anchor, 1)
anchor = 'def main():\n'
setup = '''def main():
    if phase == 'ordinary-fixed':
        packet, = [row for row in json.loads((BASE / 'ordinary-old/custody.json').read_bytes()) if row['archive'].endswith('/root-inputs.tar.gz')]
        for name, row in packet['files'].items():
            if name.startswith(str(CONTROL) + '/'):
                path = Path(name)
                assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
        (CONTROL / 'rust/linkedspec-runtime/src/engine.rs').write_bytes(Path('rust/linkedspec-runtime/src/engine.rs').read_bytes())
'''
assert capture.count(anchor) == 1
capture = capture.replace(anchor, setup, 1)
compile(capture, 'capture_ordinary.py', 'exec')
(BASE / 'capture_ordinary.py').write_text(capture)
print('Prepared exact ordinary four source questions and same private old/current SDK; root producer/profile unchanged')
