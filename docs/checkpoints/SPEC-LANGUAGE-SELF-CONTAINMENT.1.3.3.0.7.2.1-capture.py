"""Preserve complete process streams in lossless envelopes; no observed-field projection."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw),
            'sha256': hashlib.sha256(raw).hexdigest(),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode('ascii')}


def unpack(value):
    assert value['encoding'] == 'gzip-base64'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes']
    assert hashlib.sha256(raw).hexdigest() == value['sha256']
    return raw


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else 'observations'
    assert mode in ('observations', 'trace')
    cases = json.loads((ROOT / (PREFIX + 'cases.json')).read_bytes())
    rows = []
    for case in cases:
        for seed in ([0, 1, 2] if mode == 'observations' else [0]):
            command = ['perl', '-Iperl', PREFIX + ('probe.pl' if mode == 'observations' else 'trace.pl'), case['id']]
            env = dict(os.environ, PERL5LIB='', PERL_HASH_SEED=str(seed), PERL_PERTURB_KEYS='2')
            result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=120)
            rows.append({'id': case['id'], 'seed': seed, 'command': command,
                         'exit': result.returncode, 'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr)})
            print(f"{mode}: {case['id']} seed{seed} exit{result.returncode}", file=sys.stderr, flush=True)
    target = ROOT / (PREFIX + mode + '.json')
    target.write_text(json.dumps({'mode': mode, 'cases': rows}, indent=2) + '\n')
    failed = [row for row in rows if row['exit'] or unpack(row['stderr'])]
    print(json.dumps({'mode': mode, 'rows': len(rows), 'process_failures': [r['id'] for r in failed]}))
    return bool(failed)


if __name__ == '__main__':
    raise SystemExit(main())
