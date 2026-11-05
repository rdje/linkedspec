"""Read-only formatter proof for the owned fluent loop; preserve unrelated members."""
import hashlib
import json
from pathlib import Path
import subprocess

root = Path.cwd()
base = Path(__file__).resolve().parent.relative_to(root)
source = Path('dart/lib/src/runtime/interpreter.dart')
original = source.read_bytes()
text = original.decode()
begin = text.index('  Object? _evaluateFluentCallsWithValue(')
end = text.index('\n  Object? _evaluateFluentCall(', begin)
member = text[begin:end]
probe = 'class Probe {\n' + member + '\n}\n'
(base / 'scoped-format-before.txt').write_text(probe)
command = ['bash', '../tools/run_dart_project_data.sh', 'format', '--output=show',
           '--summary=none', '--stdin-name', 'lib/src/runtime/interpreter.dart']
result = subprocess.run(command, cwd=root / 'dart', input=probe, text=True, capture_output=True)
(base / 'scoped-format-after.txt').write_text(result.stdout)
(base / 'scoped-format-stderr.txt').write_text(result.stderr)
assert result.returncode == 0 and not result.stderr
prefix, suffix = 'class Probe {\n', '\n}\n'
assert result.stdout.startswith(prefix) and result.stdout.endswith(suffix)
formatted_member = result.stdout[len(prefix):-len(suffix)].rstrip('\n') + '\n'
assert formatted_member == member.rstrip('\n') + '\n', 'owned Count loop is not formatted'
assert source.read_bytes() == original, 'formatter proof mutated runtime owner'
(base / 'scoped-format.json').write_text(json.dumps({
    'source': str(source), 'sha256': hashlib.sha256(original).hexdigest(),
    'command': command, 'cwd': 'dart', 'member': '_evaluateFluentCallsWithValue',
    'formatted_member_equal': True, 'source_unchanged': True,
}, sort_keys=True, indent=2) + '\n')
print('PASS: owned Count fluent loop formatted; complete runtime owner byte-unchanged')
