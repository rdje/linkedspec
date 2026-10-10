"""Retain the actual missing-producer schema RED for the first publication."""
import argparse
import base64
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
CHECKER = 'tools/check_claim_verification.py'
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def validator():
    spec = importlib.util.spec_from_file_location('actual_claim_validator', ROOT / CHECKER)
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    return m


def read_input(path, revision):
    if revision:
        return subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)
    return (ROOT / path).read_bytes()


def probe():
    m = validator()
    raw = (ROOT / (PREFIX + 'draft1-claim.json')).read_bytes()
    m.validate(m.strict_json(raw), CLAIM, read_input, lambda owner: None)


def capture():
    target = ROOT / (PREFIX + 'schema.json')
    assert not target.exists(), 'one-shot actual schema capture'
    args = ['python3', PREFIX + 'schema.py', 'probe']
    p = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    reason = 'checked durability requires a tracked producer input'
    assert p.returncode != 0 and reason.encode() in p.stderr, (p.returncode, p.stderr)
    channel = lambda r: {'base64': base64.b64encode(r).decode(), 'bytes': len(r), 'sha256': sha(r)}
    result = {'observed': 'RED', 'reason': reason, 'args': args, 'exit_code': p.returncode,
              'stdout': channel(p.stdout), 'stderr': channel(p.stderr),
              'validator_sha256': sha((ROOT / CHECKER).read_bytes()),
              'producer_sha256': sha(Path(__file__).read_bytes()),
              'draft_sha256': sha((ROOT / (PREFIX + 'draft1-claim.json')).read_bytes())}
    target.write_text(json.dumps(result, indent=2) + '\n')
    print('Actual missing historical-producer schema RED retained.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('mode', choices=['probe', 'capture'])
    globals()[parser.parse_args().mode]()
