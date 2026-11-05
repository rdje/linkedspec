#!/usr/bin/env bash
# Format only the changed caller fragment and members; retain the exact probes.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
bash tools/project_data_run.sh python3 - "${1:?phase required}" <<'PY'
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

phase = sys.argv[1]
assert re.fullmatch('[a-z][a-z0-9-]*', phase)
root = Path.cwd()
out = root / 'docs/checkpoints/count-guard-dart-2026-11-05'
record = out / f'{phase}-format.json'
assert not record.exists(), 'refusing to overwrite a format observation'
source = root / 'dart/lib/src/runtime/interpreter.dart'
text = source.read_text()
before_sha = hashlib.sha256(text.encode()).hexdigest()
observed = {}
def format_probe(name, content):
    before = out / f'{phase}-{name}-before.txt'
    after = out / f'{phase}-{name}-after.txt'
    assert not before.exists() and not after.exists()
    before.write_text(content)
    command = ['bash', '../tools/run_dart_project_data.sh', 'format',
               '--output=show', '--summary=none', '--stdin-name',
               'lib/src/runtime/interpreter.dart']
    result = subprocess.run(command, cwd=root / 'dart', input=content,
                            text=True, capture_output=True)
    (out / f'{phase}-{name}-stderr.txt').write_text(result.stderr)
    after.write_text(result.stdout)
    assert result.returncode == 0 and not result.stderr, result.stderr
    observed[name] = {'command': command,
        'before': hashlib.sha256(content.encode()).hexdigest(),
        'after': hashlib.sha256(result.stdout.encode()).hexdigest()}
    return result.stdout

start = text.index('        var value = _evaluateFluentReceiver(')
end = text.index('      case ActionBlockValueExpr(:final block):', start)
old = text[start:end]
probe = 'class Probe {\n  Object? probe() {\n    switch (0) {\n      case 0:\n' + old + '    }\n  }\n}\n'
formatted = format_probe('caller', probe)
new_start = formatted.index('        var value = _evaluateFluentReceiver(')
new_end = formatted.rindex('\n    }\n  }\n}')
text = text[:start] + formatted[new_start:new_end] + '\n' + text[end:]

for name, begin, finish in [
    ('role', '  bool _isOrdinaryCountResultChain(', '\n  // Canonical index sources retain numeric zero'),
    ('loop', '  Object? _evaluateFluentCallsWithValue(', '\n  Object? _evaluateFluentCall('),
]:
    start = text.index(begin)
    end = text.index(finish, start)
    old = text[start:end]
    formatted = format_probe(name, 'class Probe {\n' + old + '\n}\n')
    prefix = 'class Probe {\n'
    assert formatted.startswith(prefix) and formatted.endswith('\n}\n')
    new = formatted[len(prefix):-len('\n}\n')].rstrip('\n') + '\n'
    text = text[:start] + new + text[end:]
source.write_text(text)
record.write_text(json.dumps({
    'source': 'dart/lib/src/runtime/interpreter.dart',
    'before': before_sha,
    'after': hashlib.sha256(text.encode()).hexdigest(),
    'probes': observed,
    'producer': hashlib.sha256((out / 'format.sh').read_bytes()).hexdigest(),
}, sort_keys=True, indent=2) + '\n')
print('Scoped Dart caller/role/loop formatting completed; unrelated members retained.')
PY
