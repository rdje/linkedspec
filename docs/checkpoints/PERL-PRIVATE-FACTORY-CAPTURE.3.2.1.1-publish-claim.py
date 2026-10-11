"""Readonly dropped-value trim publication; --capture writes its record once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'evidence.py', 'consumer-review.py', 'book-review.py', 'compatibility/run.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', tail, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert len(evidence['rows']) == 6
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix()
             for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.update(p.relative_to(ROOT).as_posix()
             for p in (ROOT / (PREFIX + 'compatibility')).rglob('*') if p.is_file())
assert PREFIX + 'publish-claim.py' in paths
assert PREFIX + 'compatibility/result.json' in paths
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for p in sorted(paths)]
statement = ('Isolate exactly one inline-required trim invocation in _lower_dropped_value_statement. '
    'First213-input native observation retains6 callback cases,33 guard cases,2 authority rows and3 cold '
    'cases. Original authority rows equal the earlier accepted gap diagnosis. Identical298 TAP retains '
    '3 original isolation REDs and295 passing controls; all298 current assertions pass. Six syntax-valid '
    'whole-source faults fail3/1/2/14/9/4 assertions for their named reasons. Complete supplied68 suites, '
    '215 inputs and13958 assertions pass. Six semantic/population/original-input evidence REDs reject '
    'beyond updated immediate hashes and restore exactly. Complete89-input book and three controls pass. '
    'All339 original inventory bindings/full78574-byte publication and actual accepted baseline remain '
    'preserved. Supplemental standard syntax/public Phase0 passes1035 with complete channels.')
scope = ('One private required callback boundary, preserving both actual map reads and CODE validation, '
    'undefined-input early return, actual local argument versus returned slot aliases, reference identity, '
    'scalar context, callback/map replacement, effects, incoming/success/fatal errors, AST/unknown-helper/ '
    'lowered-value guards and fallback/equality against the actual current returned slot. Native die '
    'IO-context suffixes remain complete through fresh subprocess probes; no diagnostic normalization. '
    'Secondary AST/unknown/method helpers are explicit controls, so this is not complete helper or '
    'authored-language admission. Only the callback invocation changes, preserving original source line '
    'count and all211 accepted predecessor runtime inputs except that module. Six retained full-source '
    'counterfactuals include the exact original raw invocation, wrapper identity, reference coercion, '
    'CODE/input guards and wrong equality slot. The argument control establishes observable reference/ '
    'zero-value behavior, not every potentially invisible local scalar copy. Original inventory claim '
    'retains every339 binding historically at354c15530fd1445ebfa8c6c0683e7b8d066caced; this record reuses '
    'that complete claim rather than duplicating its input list. No original capture or input hash is '
    'refreshed. Standard live-worktree compatibility is supplemental, with no full transitive capsule, '
    'runtime benchmark or output-volume comparison. OS Perl/toolchain immutability and cross-version '
    'identity are not claimed. Sixteen remaining MethodLowering ingress sites, FlowExpr/ControlFlow, '
    'fixture registration .7 before pipeline .6, full-private/output/mapping/parent/canonical admissions '
    'and TYPE-REFERENCE-BOOK retain their separate owners.')
claim = {'name': 'inline-required-dropped-value-trim-isolation', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; readonly defaults '
            'also available for review.py, evidence.py, consumer-review.py, book-review.py and compatibility/run.py. '
            'All --capture/native/freeze/fault/book writers are one-shot retired producers.',
        'granularity': 'Each native callback/guard/authority/cold row, complete298 paired TAP labels, six full '
            'syntax-valid source counterfactuals and their actual complete215-input capsules/channels; ordered '
            '68-suite/13958-assertion consumer population; six exact damaged-evidence records and restoration '
            'channels; original339 bindings/full78574 bytes/actual publisher baseline; all89 book inputs and '
            'three controls; supplemental three standard command results including1035 public assertions.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'The inline-required raw callback already isolates child publication, or a wrapper '
            'may replace the actual map callback, coerce input, remove native guards or compare the caller '
            'slot without the native and paired oracles detecting it. Forged evidence can pass after '
            'updating its immediate metadata hashes.',
        'oracle': 'Immutable pre-edit native rows and exact earlier accepted gap diagnosis, independently '
            'reconstructed one-call source change and full mutants, complete identical TAP labels, accepted '
            'Git originals/full publication, independently parsed consumer commands/plans/members and '
            'complete rendered book input/marker/include population.',
        'red_control': 'Actual original3 RED/295 controls; six syntax-valid source mutants fail3/1/2/14/9/4 '
            'with named reasons. Six evidence controls reject failed-positive, censored fault label, false '
            'native map identity, omitted checkpoint command, forged original beyond the freeze hash and '
            'changed book beyond report hashes, each followed by actual exact-restored healthy review. '
            'Book missing SUMMARY, removed marker despite exit0 and missing include retain three controls.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, 'bounded claim record'
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact readonly publication'
print('Dropped trim publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
