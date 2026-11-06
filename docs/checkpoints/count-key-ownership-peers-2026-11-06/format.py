"""Capture only scoped, read-only formatting checks for the changed normals."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
commands=[('rust-format',Path('.'),['rustfmt','--edition','2024','--check','rust/linkedspec-runtime/tests/key_count_result_guard_composition.rs']),('dart-format',Path('dart'),['bash','../tools/run_dart_project_data.sh','format','--output=none','--set-exit-if-changed','test/key_count_result_guard_composition_test.dart'])]
paths=[Path(p) for p in ('rust/linkedspec-runtime/tests/key_count_result_guard_composition.rs','dart/test/key_count_result_guard_composition_test.dart')]
identities={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
for tag,cwd,argv in commands:
    output=BASE/(tag+'-command.json');assert not output.exists()
    output.write_text(json.dumps(dict(cwd=str(cwd),argv=argv,inputs=identities),indent=2)+'\n')
    with (BASE/(tag+'-stdout.log')).open('xb') as stdout,(BASE/(tag+'-stderr.log')).open('xb') as stderr:
        result=subprocess.run(argv,cwd=ROOT/cwd,stdout=stdout,stderr=stderr)
    (BASE/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode==0, 'inspect retained full formatting channels'
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in identities.items())
print('Scoped Rust/Dart format PASS; both normals byte-unchanged by checks')
