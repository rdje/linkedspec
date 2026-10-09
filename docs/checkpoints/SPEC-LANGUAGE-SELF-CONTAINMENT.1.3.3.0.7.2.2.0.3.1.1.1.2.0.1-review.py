"""Independently review supplied bytes, TAP completion, inverses and freeze."""
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1'
PREFIX = 'docs/checkpoints/' + OWNER
BASE = 'a367b66f06b1deacefc172484834b7cd9b1093d1'
ORIGINS = 'perl/LinkedSpec/ActionIR/SourceOrigins.pm'
EMISSIONS = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_source_emissions.t'


def read(path):
    return (ROOT / path).read_bytes()


def load(suffix):
    return json.loads(read(PREFIX + '-' + suffix + '.json'))


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def channels(row):
    return tuple(base64.b64decode(row[name + '_base64'], validate=True).decode(errors='replace')
                 for name in ('stdout', 'stderr'))


def complete_tap(row):
    out, err = channels(row)
    plans = re.findall(r'^1\.\.(\d+)$', out, re.M)
    tests = re.findall(r'^ok (\d+) - ', out, re.M)
    assert row['returncode'] == 0 and len(plans) == 1 and tests == [str(i) for i in range(1, int(plans[0])+1)]
    assert not re.search(r'^not ok|Bail out!', out, re.M) and 'Failed test' not in err
    return int(plans[0])


def review():
    initial = read(PREFIX + '-fixture-initial.t')
    original = load('original')
    assert original['returncode'] != 0
    assert "Can't locate LinkedSpec/ActionIR/SourceEmissions.pm" in channels(original)[1]
    original_bytes = {ORIGINS: git(ORIGINS), TEST: initial}
    assert {x['path']: x['sha256'] for x in original['inputs']} == {p: sha(v) for p,v in original_bytes.items()}
    draft = load('draft')
    draft_count = complete_tap(draft)
    current = {p: read(p) for p in (ORIGINS, EMISSIONS, TEST)}
    snapshot = json.loads(read(PREFIX.replace('.0.1', '.0.0') + '-crash.json'))
    recovered = {x['path']: x for x in snapshot['entries']}
    assert sha(current[ORIGINS]) == recovered[ORIGINS]['sha256']
    assert current[EMISSIONS] == base64.b64decode(recovered[EMISSIONS]['content_base64'], validate=True)
    assert {x['path']: x['sha256'] for x in draft['inputs']} == {
        ORIGINS: sha(current[ORIGINS]), EMISSIONS: sha(current[EMISSIONS]), TEST: sha(initial)}
    final = load('final')
    count = complete_tap(final)
    assert {x['path']: x['sha256'] for x in final['inputs']} == {p: sha(v) for p,v in current.items()}
    inverses = load('inverses')
    expected_names = {'no-known-identity', 'no-call', 'list-context', 'copy-capture',
                      'foreign-callback', 'foreign-event', 'no-source-fragments',
                      'shifted-coordinates', 'generated-as-source', 'no-consumption',
                      'no-builder-validation', 'shared-packet', 'shared-source-token',
                      'copied-arguments', 'double-callback', 'no-call-unwind'}
    assert len(inverses) == len(expected_names) and {x['name'] for x in inverses} == expected_names
    for row in inverses:
        source = row['source']
        assert source in (EMISSIONS, ORIGINS) and current[source].count(row['old'].encode()) == 1
        inverse = current[source].replace(row['old'].encode(), row['new'].encode(), 1)
        expected = dict(current, **{source: inverse})
        assert {x['path']: x['sha256'] for x in row['inputs']} == {p:sha(v) for p,v in expected.items()}
        out, err = channels(row)
        assert row['returncode'] != 0 and row['required_failure'] in err and re.search('^not ok ', out, re.M)
        assert 'syntax error' not in err and 'Compilation failed' not in err
    initial_failure = load('inverse-initial-channels')
    assert initial_failure['returncode'] != 0 and "('copy-capture', '')" in channels(initial_failure)[1]
    expanded_failure = load('inverse-expanded-initial-channels')
    assert expanded_failure['returncode'] != 0 and 'double-callback' in channels(expanded_failure)[1]
    unwind_failure = load('inverse-unwind-initial-channels')
    assert unwind_failure['returncode'] != 0 and "('no-call-unwind', '')" in channels(unwind_failure)[1]
    freeze = load('freeze')
    assert freeze['revision'] == BASE and len(freeze['records']) == 1
    for row in freeze['records']:
        original = git(row['path'])
        assert sha(original) == row['original_sha256']
        expected = json.loads(original)
        for claim in expected['claims']:
            leg = claim['durability']
            assert leg['mode'] == 'live'
            for entry in leg['inputs']:
                assert sha(git(entry['path'])) == entry['sha256']
            leg.update(mode='historical', revision=BASE)
        assert json.loads(read(row['path'])) == expected and sha(read(row['path'])) == row['preserved_sha256']
    consumer = load('consumers')
    assert consumer['returncode'] == 0 and 'Result: PASS' in channels(consumer)[0]
    # Guarded parent source bytes must still match. A changed publication surface
    # is intentionally not part of this live focused consumer record.
    assert all(sha(read(p)) == h for p,h in consumer['inputs'].items())
    return {'owner': OWNER, 'result': 'PASS', 'draft_assertions': draft_count,
            'final_assertions': count, 'effective_source_inverses': len(inverses),
            'original_red': 'missing module only; semantic inverses supply distinguishing RED',
            'limits': 'Private standalone protocol only; no production callback/family integration, replacement mapping, complete immutable Phase0 or public runtime acceptance.'}


if __name__ == '__main__':
    result = review()
    (ROOT / (PREFIX + '-review.json')).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
