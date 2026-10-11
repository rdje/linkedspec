"""Readonly static-inventory publisher; --capture creates its record once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'evidence-review.py', 'book-review.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('readonly proof', tail, result.stderr)
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert evidence['result'] == 'PASS' and len(evidence['rows']) == 2
assert evidence['producer_sha256'] == sha((ROOT / (PREFIX + 'evidence.py')).read_bytes())
assert evidence['review_sha256'] == sha((ROOT / (PREFIX + 'evidence-review.py')).read_bytes())
assert evidence['healthy']['returncode'] == 0 and not base64.b64decode(evidence['healthy']['stderr_base64'])
for row in evidence['rows']:
    assert row['denied']['returncode'] != 0 and row['reason'].encode() in base64.b64decode(row['denied']['stderr_base64'])
    assert row['restored']['returncode'] == 0 and not base64.b64decode(row['restored']['stderr_base64'])
    originals = {tail: (ROOT / (PREFIX + tail)).read_bytes() for tail in row['original_sha256']}
    assert {tail: sha(raw) for tail, raw in originals.items()} == row['original_sha256']
    changed = {tail: json.loads(raw) for tail, raw in originals.items()}
    if row['name'] == 'forged-original-beyond-freeze-sha':
        changed['before-package-flow.json']['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        raw = (json.dumps(changed['before-package-flow.json'], indent=2) + '\n').encode()
        changed['freeze.json']['original_sha256'] = sha(raw)
    else:
        assert row['name'] == 'false-native-diagnosis'
        native = json.loads(base64.b64decode(changed['gap.json']['stdout_base64']))
        native['rows'][0]['parent_packet'] = 0
        changed['gap.json']['stdout_base64'] = base64.b64encode(json.dumps(native).encode()).decode()
    assert {tail: base64.b64encode((json.dumps(value, indent=2) + '\n').encode()).decode()
            for tail, value in changed.items()} == row['mutated_base64'], 'exact damaged evidence recurrence'

paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file()}
for label in ('native', 'optree', 'gap'):
    paths.update(json.loads((ROOT / (PREFIX + label + '.json')).read_bytes())['inputs'])
paths.update(json.loads((ROOT / (PREFIX + 'book-review.json')).read_bytes())['source_inputs'])
paths.update(('docs/knowledge/perl-method-trim-capture.md',
              'docs/knowledge/perl-method-slot-required-capture.md',
              'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0.json'))
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'} for p in sorted(paths)]
statement = ('Read-only MethodLowering inventory at accepted91e972cfa0 retains108 named source/compiled '
    'functions,218 named/anonymous CVs,812 executable CODE sites and207 lexical bindings. The810 lexical calls '
    'match independent B::Deparse population; one direct map and one already-bound returned CODE call complete '
    'the inventory. Thirteen of823 raw arrow candidates are generated-string text. Exactly17 remaining ingress '
    'sites are assigned to eight bounded implementation owners. Three syntax-valid compiled-source and three '
    'member/binding/family controls reject with exact reasons and six restored reviews pass. Two beyond-immediate '
    'evidence controls reject and restore; full book89/three controls passes. The original212-input inline-required '
    'trim diagnosis retains both actual known/opaque eligibility[1] and parent-publication rows. All211 accepted '
    'consumer inputs stay unchanged; original355 bindings/full120239-byte publication and both172 prior '
    'historical bindings remain preserved.')
scope = ('Static source/compiled syntax and exact lexical ingress only, with read-only OS Perl v5.34.1/core B '
    'and B::Deparse. All native products/channels and supplied inputs precede census assertions; no callback '
    'execution, transitive call graph or complete helper/language admission is inferred from that census. '
    'The explicit controlled dropped-value diagnosis executes one required trim with held AST/method helpers '
    'and schedules P2 .3.2.1.1 first; it establishes no authored-language failure.359 bound dependencies,1 bound '
    'direct call,1 cold boundary fallback,96 local resolver calls,338 literal local-helper calls and17 remaining '
    'ingress sites exhaust812. Same-spelled bare_symbol_kind bindings remain distinct; selected but unused kind '
    'and infer callbacks do not imply invocations. Source and runtime tests are unchanged, so accepted .3.2.0 '
    'standard compatibility is reused without claiming a new runtime gate. Original independent reviewer '
    'undercounted a returned-CODE callee; exact first source, actual merged shell failure and sole correction '
    'are retained and independently reconstructed. Separate stdout/stderr for that failed shell invocation '
    'were unavailable. No original observation/hash was refreshed. The predecessor historical claim gates '
    'every original355 input at91e and retains both earlier historical records; this record reuses that '
    'complete retained claim rather than duplicating its input lists. Actual accepted publisher baseline '
    'precedes bound docs, and only one old live mode/revision pair changes. Core/toolchain immutability or '
    'cross-version optree/HTML identity is not claimed. FlowExpr/ControlFlow, fixture registration .7 before '
    'pipeline .6, output/mapping/full-private/parent/canonical and TYPE-REFERENCE-BOOK remain independent.')
claim = {'name': 'remaining-method-callback-ingress-inventory', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX +
        'publish-claim.py; separately review.py, evidence-review.py and book-review.py under the same prefix/wrapper. '
        'Readonly defaults; native/census/freezer/control captures and --capture are one-shot retired writers.',
        'granularity': 'Every108 source/compiled function,218 CV,812 native call/member,207 lexical binding,17 ingress '
            'site and13 compiler-excluded generated-string candidates; actual213-input source variants, six semantic '
            'RED/restorations, two evidence RED/restorations, original212-input gap rows,211 unchanged runtime inputs, '
            '355 original accepted bindings/full120239 publication and89 book inputs/three controls.',
        'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'A raw regex or name-only grouping is complete; direct/map/returned '
        'calls can be omitted, the shadow binding conflated, a resolver unbound or source/book/original fields forged '
        'without the independent reviewer noticing.',
        'oracle': 'Separate core B::Deparse and B optree observations, actual source definitions/parent pad slots, '
            'exact manual ingress contracts, actual syntax-valid full-source counterfactuals, accepted Git originals '
            'and complete rendered book marker/include population.',
        'red_control': 'Three compiled-source variants omit direct ingress/add a formal call/unbind a required resolver; '
            'three inventory variants omit a member/conflate shadow binding/change ingress family. All actual oracle '
            'commands fail with named reasons, each restored review passes. Forged original fields beyond an updated '
            'freeze SHA and false original native publication reject, then restore. Full book missing SUMMARY, '
            'removed rendered marker despite exit0 and missing include retain three distinguishing controls. '
            'Original reviewer dynamic-population rejection reproduces before its sole correction.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
record = {'version': 1, 'owner': LEAF, 'claims': [claim]}
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072, 'bounded record'
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact readonly publication'
print('Remaining-call inventory publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
