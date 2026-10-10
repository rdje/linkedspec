"""Guarded metadata-only repair; default review never writes publication bytes."""
import argparse
import base64
import copy
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
CHECKER = 'tools/check_claim_verification.py'
PRODUCERS = {'scripts/check_readme_routing_pressure.pl', 'tools/roll_document_history.pl'}
EXTRA = [PREFIX + tail for tail in ('draft1-claim.json', 'schema.py', 'schema.json', 'repair-publication.py')] + [CHECKER]
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def expected():
    before = json.loads(read(PREFIX + 'draft1-claim.json'))
    result = copy.deepcopy(before)
    historical = result['claims'][1]['durability']['inputs']
    assert len(historical) == 9 and {r['role'] for r in historical} == {'input'}, 'exact original metadata defect'
    changed = []
    for item in historical:
        if item['path'] in PRODUCERS:
            item['role'] = 'producer'; changed.append(item['path'])
    assert set(changed) == PRODUCERS, 'only actual unchanged original production checker/roller labels'
    live = result['claims'][0]['durability']['inputs']
    assert len(live) == 240 and not ({r['path'] for r in live} & set(EXTRA)), 'exact initial live population'
    for path in EXTRA:
        live.append({'path': path, 'sha256': sha(read(path)), 'role': 'producer' if path.endswith('.py') else 'input'})
    result['claims'][0]['rederive']['command'] += '; bash tools/run_python_project_data.sh ' + PREFIX + 'repair-publication.py review'
    result['claims'][0]['statement'] += (' Initial publication was rejected for missing historical producer roles. '
        'The exact rejected record and actual schema RED are retained; a guarded metadata-only repair labels '
        'unchanged original checker/roller bytes as producers. No original input hash or measured proof is refreshed.')
    return result


def check_schema_red():
    data = json.loads(read(PREFIX + 'schema.json'))
    assert data['draft_sha256'] == sha(read(PREFIX + 'draft1-claim.json'))
    assert data['validator_sha256'] == sha(read(CHECKER)) and data['producer_sha256'] == sha(read(PREFIX + 'schema.py'))
    assert data['reason'] == 'checked durability requires a tracked producer input' and data['observed'] == 'RED'
    for key in ('stdout', 'stderr'):
        raw = base64.b64decode(data[key]['base64'])
        assert data[key] == {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': sha(raw)}
    p = subprocess.run(data['args'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert p.returncode == data['exit_code'] != 0 and p.stdout == base64.b64decode(data['stdout']['base64'])
    assert p.stderr == base64.b64decode(data['stderr']['base64']), 'actual retained schema RED replay'


def review():
    assert json.loads(read(CLAIM)) == expected(), 'only exact role labels/disclosure and retained repair inputs change'
    check_schema_red()
    spec = importlib.util.spec_from_file_location('schema_capture', ROOT / (PREFIX + 'schema.py'))
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    validator = m.validator()
    assert validator.validate(validator.strict_json(read(CLAIM)), CLAIM, m.read_input, lambda owner: None) == (2, 0)
    print('Publication metadata repair PASS: all original hashes exact;245 live/nine historical inputs; actual schema GREEN.')


def apply():
    assert read(CLAIM) == read(PREFIX + 'draft1-claim.json'), 'one-shot repair starts at exact rejected publication'
    check_schema_red()
    raw = (json.dumps(expected(), indent=2) + '\n').encode()
    assert len(raw) <= 131072, 'bounded repaired claim'
    (ROOT / CLAIM).write_bytes(raw)
    review()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('mode', choices=['apply', 'review'], nargs='?', default='review')
    globals()[parser.parse_args().mode]()
