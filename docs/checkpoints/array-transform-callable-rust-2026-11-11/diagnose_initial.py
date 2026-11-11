"""Distinguish unchanged initial producers from three later guard movements."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]

def frames(phase, stream, tag):
    body = gzip.decompress((BASE / phase / (stream + '.log.gz')).read_bytes()).decode()
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body, re.M):
        assert key not in result
        result[key] = json.loads(value)
    return result

def routes(phase):
    rows = frames(phase, 'native-stdout', 'CALLABLE_TRANSFORM_RUST')
    fresh = frames(phase, 'fresh-stdout', 'CALLABLE_TRANSFORM_RUST_FRESH')
    assert rows.keys() == fresh.keys()
    return {key: dict(row, fresh=fresh[key]) for key, row in rows.items()}

def same(left, right):
    return json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))

before, after = routes('intake'), routes('after')
cases = json.loads((BASE / 'cases.json').read_bytes())
profiles = json.loads((ROOT / 'tests/fixtures/array_transform_callable_result_guard_rust_profiles.json').read_bytes())
unexpected = {key for key, profile in profiles.items()
    if not same(after[key], {route: profile[route] for route in ('native', 'restored', 'plan', 'fresh')})}
assert unexpected == {'initial_' + kind + '_composed' for kind in ('number', 'null', 'hash')}
checks = {}
for kind in ('number', 'null', 'hash'):
    terminal = 'initial_' + kind + '_terminal'
    immediate = 'own_initial_' + kind + '_take_receiver_with'
    composed = 'initial_' + kind + '_composed'
    assert before[terminal] == after[terminal] and all(row == {'value': []} for row in after[terminal].values())
    assert before[immediate] == after[immediate] and all(row == {'value': [0, 'W']} for row in after[immediate].values())
    assert all(row == {'value': ['ran', 'KVW']} for row in before[composed].values())
    assert all(row == {'value': [None, '']} for row in after[composed].values())
    checks[composed] = dict(initial_terminal=after[terminal], immediate_with=after[immediate],
        original=before[composed], repaired=after[composed])
initial = [case['id'] for case in cases if case.get('question') in ('initial-terminal', 'initial-first-with')]
assert len(initial) == 96 and all(same(before[key], after[key]) for key in initial)
empty_terminal = before['own_signature_variadic_empty_terminal']
assert all(row == {'value': [[], '']} for row in empty_terminal.values())
assert all(row == {'value': [None, '']} for row in after['own_signature_variadic_empty_composed'].values())
traced = frames('trace', 'trace-stdout', 'CALLABLE_TRANSFORM_TRACE')
assert traced['initial_number_composed'] == before['initial_number_composed']['native']
old = gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
current = (ROOT / 'rust/linkedspec-runtime/src/engine.rs').read_bytes()
# Both unchanged evaluator bodies prove the fallback is restricted to index0;
# the actual returned Array then reaches the existing Hash guard before calls.
start = current.index(b'    fn eval_receiver_with_trailing_block_chain(')
end = current.index(b'\n    fn ', start + 1)
body = current[start:end]
old_start = old.index(b'    fn eval_receiver_with_trailing_block_chain(')
old_end = old.index(b'\n    fn ', old_start + 1)
assert old[old_start:old_end] == body
assert b'&& !(index == 0' in body and b'|| array_transform_source_prefix' in body
assert body.index(b'(hash_only') < body.index(b'return Ok(RuntimeValue::Undef)') < body.index(b'current = self.eval_receiver_dynamic_value_chain_call(')
failure = gzip.decompress((BASE / 'launches/check-after/stderr.log.gz').read_bytes())
assert (BASE / 'launches/check-after/exit.txt').read_text() == '1\n'
assert b'AssertionError: initial_hash_composed' in failure
result = dict(diagnosis='PASS', unexpected_three=sorted(unexpected), initial_policies_exact=96,
    complete_contrasts=checks, valid_empty_terminal=empty_terminal,
    cause='The original freeze conflated the producer fallback with a later broken Hash continuation. First take still returns the same empty Array and immediate with still runs; existing index0 fallback then yields to actual Array kind rejection before K/V/W.',
    disposition='Retain20 supported product targets; qualify these three composed off-contract inputs as separate compatibility movements, preserving all original profiles/normal20RED/failed comparison1 and actual data. No production change or portable initial-input admission.',
    unchanged_evaluator_sha256=hashlib.sha256(body).hexdigest(),
    limits='Public trace has lifecycle/output granularity. Source-order plus exact terminal contrasts establish this bounded cause; no finer expression event was emitted.')
target = BASE / 'initial-policy-diagnosis.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
