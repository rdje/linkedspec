"""Execute only frozen optional branch text with inert shell command recorders."""
import gzip
import importlib.util
import json
import os
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    assert not (BASE / 'branches.json').exists(), 'one-shot branch observation'
    spec = importlib.util.spec_from_file_location('native_route_epoch', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, _ = module.recover()
    block = module.optional_block(sources['tools/run_ci_local.sh'].decode())
    preamble = 'set -euo pipefail\nREPO_ROOT=.\nlog(){ :; }\nrequire_tracked_file(){ :; }\nbash(){ printf "%s\\n" "$1"; }\n'
    folder = BASE / 'branches'
    folder.mkdir()
    rows = []
    for name in ('default', 'all', *module.BACKENDS, 'missing', 'duplicate', 'disabled'):
        flags = {f'LINKEDSPEC_RUN_{backend.upper()}': ('0' if name == 'default' or name in module.BACKENDS and name != backend else '1')
                 for backend in module.BACKENDS}
        source = block
        command = 'bash "$REPO_ROOT/tools/run_rust_local.sh"'
        if name == 'missing':
            source = source.replace(command, ':', 1)
        elif name == 'duplicate':
            source = source.replace(command, command + '\n ' + command, 1)
        elif name == 'disabled':
            source = source.replace('${LINKEDSPEC_RUN_RUST:-0}" == "1"', '${LINKEDSPEC_RUN_RUST:-0}" == "never"', 1)
        script = (preamble + source).encode()
        stem = folder / name
        argv = ['bash', '--noprofile', '--norc', '-s']
        stem.with_suffix('.json').write_text(json.dumps(dict(argv=argv, cwd='.', flags=flags), indent=2) + '\n')
        stem.with_suffix('.stdin.gz').write_bytes(gzip.compress(script, mtime=0))
        result = subprocess.run(argv, input=script, cwd='.', env=dict(os.environ, **flags),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for channel in ('stdout', 'stderr'):
            stem.with_suffix('.' + channel + '.gz').write_bytes(gzip.compress(getattr(result, channel), mtime=0))
        stem.with_suffix('.exit.txt').write_text(str(result.returncode) + '\n')
        assert result.returncode == 0 and result.stderr == b'', 'actual branch command failure'
        actual = result.stdout.decode().splitlines()
        expected = ['./tools/run_' + backend + '_local.sh' for backend in module.BACKENDS if flags['LINKEDSPEC_RUN_' + backend.upper()] == '1']
        outcome = 'RED' if actual != expected else 'PASS'
        assert outcome == ('RED' if name in ('missing', 'duplicate', 'disabled') else 'PASS'), 'branch oracle'
        rows.append(dict(name=name, expected=expected, actual=actual, result=outcome))
    (BASE / 'branches.json').write_text(json.dumps(rows, indent=2) + '\n')
    print(json.dumps(module.branch_proof(sources), sort_keys=True))


if __name__ == '__main__':
    main()
