"""Observe frozen Bash operand selection with inert Lua command functions only."""
import gzip
import importlib.util
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    assert not (BASE / 'probes.json').exists(), 'one-shot operand observation'
    spec = importlib.util.spec_from_file_location('lua_named_selection', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, _ = module.recover()
    ledger = module.scan(sources)
    (BASE / 'selection.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
    chunks = module.blocks(sources['tools/run_lua_local.sh'].decode())
    folder = BASE / 'probes'
    folder.mkdir()
    rows = []
    preamble = '''set -euo pipefail
log(){ :; }
record(){ printf '%s\\0' "$@"; }
LUA_CMD=record
LUAJIT_CMD=record
secondary_native=unused
'''
    for label in ('primary', 'secondary', 'missing-runner', 'duplicate-runner'):
        block = chunks['secondary'] if label == 'secondary' else chunks['primary']
        if label in ('missing-runner', 'duplicate-runner'):
            lines = block.splitlines(keepends=True)
            chosen = [line for line in lines if line.rstrip().endswith('"$LUA_CMD" lua/test/run.lua')]
            assert len(chosen) == 1
            block = block.replace(chosen[0], '' if label == 'missing-runner' else chosen[0] * 2, 1)
        script = (preamble + block).encode()
        stem = folder / label
        stem.with_suffix('.stdin.gz').write_bytes(gzip.compress(script, mtime=0))
        argv = ['bash', '--noprofile', '--norc', '-s']
        stem.with_suffix('.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
        result = subprocess.run(argv, input=script, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for channel in ('stdout', 'stderr'):
            stem.with_suffix('.' + channel + '.gz').write_bytes(gzip.compress(getattr(result, channel), mtime=0))
        stem.with_suffix('.exit.txt').write_text(str(result.returncode) + '\n')
        assert result.returncode == 0 and not result.stderr
        values = result.stdout.decode().split('\0')
        assert values.pop() == ''
        expected = ledger['primary']
        outcome = 'PASS' if values == expected else 'RED'
        assert outcome == ('RED' if label in ('missing-runner', 'duplicate-runner') else 'PASS')
        rows.append(dict(name=label, result=outcome, actual=values, expected=expected,
            limits='Only isolated frozen command blocks; inert functions execute no Lua, native build, test body or other driver stage.'))
    (BASE / 'probes.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', primary_commands=len(ledger['primary']), shared_dofile=len(ledger['shared_dofile_calls']),
        dynamic_dofile=ledger['shared_dynamic_dofile'], candidates=ledger['candidates']), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
