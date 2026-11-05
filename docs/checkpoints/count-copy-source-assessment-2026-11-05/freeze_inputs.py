"""One-shot direct evidence identity catalog; no SDK execution or broad inventory."""
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).parent.resolve()
ROOT = HERE.parents[2]
OUTPUT = HERE / 'input-index.json'
assert not OUTPUT.exists(), 'historical input catalog is immutable'
activation = 'f469ef370ee5a27a52e97b6dbd0c341c738c269a'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == activation
subprocess.run(['git', 'diff', '--quiet', 'HEAD', '--', 'perl', 'rust/linkedspec-core/src',
                'rust/linkedspec-runtime/src', 'dart/lib', 'julia/src', 'lua/src'], cwd=ROOT, check=True)
inputs = {}
for path in sorted(HERE.rglob('*')):
    if (not path.is_file() or path.suffix == '.md' or '__pycache__' in path.parts
            or path.name.startswith(('assessment', 'frozen-', 'freeze-inputs-result', 'input-index'))):
        continue
    assert not path.is_symlink()
    inputs[path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
record = {'activation_commit': activation,
          'activation_tree': subprocess.check_output(['git', 'rev-parse', activation + '^{tree}'], cwd=ROOT, text=True).strip(),
          'direct_evidence_inputs': inputs,
          'limits': 'Direct retained evidence and owned SDK Git identity only. No full transitive/native/toolchain closure or isolation claim; repair owner TYPE-REFERENCE-BOOK.1.2.23.4.2.'}
OUTPUT.write_text(json.dumps(record, sort_keys=True, indent=2) + '\n')
print('Frozen direct evidence identities and unchanged SDK activation.')
