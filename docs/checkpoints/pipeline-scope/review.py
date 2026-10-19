"""Readonly current transport/closure admission over an exact original draft."""
import json
import re
import subprocess
import sys
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, NATIVE, load, load_namespace, verify_native, sha, encode, decode

assert sys.argv[1:] in ([], ['--capture'], ['--transport-only'])
original = load()
namespace = load_namespace(original)
verify_native(original)
projection = json.loads((ROOT / (PREFIX + 'projection-preflight.json')).read_bytes())
knowledge = json.loads((ROOT / (PREFIX + 'knowledge.json')).read_bytes())
assert projection['original_claim_sha256'] == original['claim_sha256']
assert projection['original_declared_inputs'] == 625 and projection['supplied_claim_namespace'] == 161
assert len(projection['changed_cards']) == 15
changed = dict(projection['proposed'])
changed['KNOWLEDGE_MAP.md'] = knowledge['inputs']['KNOWLEDGE_MAP.md']
assert len(changed) == 18
current = {}
for path, before in original['inputs'].items():
    source = ROOT / path
    actual = source.read_bytes()
    expected = changed[path] if path in changed else before
    assert sha(actual) == expected['sha256'], ('current original-draft surface', path)
    assert source.stat().st_mode & 0o7777 == before['mode']
    current[path] = dict(sha256=sha(actual), mode=source.stat().st_mode & 0o7777)
assert {path.relative_to(ROOT).as_posix() for path in (ROOT / OLD).iterdir()
        if path.is_file() and path.name not in ('publication-preflight.json', 'continuity.json')} == {
            path for path in original['inputs'] if path.startswith(OLD)}, 'complete original prefix namespace'
repair = json.loads((ROOT / (PREFIX + 'replay-repair.json')).read_bytes())
for path, item in repair['originals'].items():
    if path.startswith(PREFIX):
        assert (ROOT / path).read_bytes() == decode(item['base64'])
for name, expected in repair['current'].items():
    assert sha((ROOT / (PREFIX + name)).read_bytes()) == expected
failed = json.loads((ROOT / (PREFIX + 'replay.json')).read_bytes())
assert failed['returncode'] == 1 and failed['original_inputs_unchanged']
assert b'review-runtime-final.py' in decode(failed['stderr_base64']) and b'line 67' in decode(failed['stderr_base64'])
runtime = json.loads((ROOT / (PREFIX + 'current-runtime.json')).read_bytes())
assert runtime['returncode'] == 0 and not decode(runtime['stderr_base64']) and runtime['inputs_unchanged']
assert runtime['input_count'] == 426 and runtime['changed_from_original'] == [NATIVE]
assert decode(runtime['current_view_base64']) == (ROOT / NATIVE).read_bytes()
for path, item in runtime['inputs'].items():
    assert current[path] == item
stdout = decode(runtime['stdout_base64'])
assert re.findall(rb'^1\.\.(\d+)\s*$', stdout, re.M) == [b'2065']
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', stdout, re.M) == [(b'1', b'2065')]
assert not re.search(rb'^not ok\b', stdout, re.M)
assert [int(value) for value in re.findall(rb'^ok (\d+)\b', stdout, re.M)] == list(range(1, 2066))
if sys.argv[1:] == ['--transport-only']:
    print('Current transport and supplied closure PASS:625 declared;161 supplied claims;2065 current assertions')
    raise SystemExit(0)

children = []
for name in ('replay-final.py', 'review-docs.py'):
    command = ['python3', PREFIX + name]
    run = subprocess.run(command, cwd=ROOT, capture_output=True)
    children.append(dict(command=command, returncode=run.returncode,
                         stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr)))
    assert run.returncode == 0 and not run.stderr, ('actual readonly supplied review', name, run.stdout, run.stderr)
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()), children=children,
              inputs=current, changed_original_inputs=sorted(changed),
              population=dict(original_declared_inputs=625, original_claim_bytes=123401,
                              supplied_claim_namespace=len(namespace['inputs']),
                              supplied_overlay_count=len(set(original['inputs']) | set(namespace['inputs'])),
                              current_assertions=2065, current_runtime_inputs=426,
                              markdown=1487, facts=1349, question_keys=10450,
                              knowledge_bytes=8384959, routes=15, changed_bodies_from_draft=1,
                              book_inputs=89, render_controls=4),
              scope='Original whole declared625 draft stays exact in supplied custody, with161 '
                    'previously undeclared actual fixed-namespace claim inputs. Unchanged original '
                    'readers recur over that complete supplied context; no Git revision is invented '
                    'for the draft. Current production/tests and all original artifacts stay exact '
                    'except one lossless JSON transport, fifteen routes/one body, workflow prose and '
                    'derived map. Current2065 fixture and whole supplied Knowledge re-derivation plus '
                    'full book/four controls pass. Every original rendered table is exact. Original '
                    'native/runtime/source-fault and failed-reader epochs remain distinct and immutable '
                    'in archival custody. No retired native writer or lifecycle/recovery proof is run.')
target = ROOT / (PREFIX + 'current-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
print('Current pipeline proof PASS:625 declared+161 supplied;2065 current;Knowledge1487/15;book89/4')
