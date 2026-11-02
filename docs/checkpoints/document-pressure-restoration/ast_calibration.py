"""Retain once; replay public AST fragments and distinguish semantic regressions."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

from book_review import Visible, normal

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'
DESTINATION = HERE / 'ast-calibration-evidence.json.gz'
TEST = 't/actionir_ast_parser.t'
BOOK = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'AST evidence identity'
    return raw


def capture():
    assert not DESTINATION.exists(), 'preserve completed evidence epochs'
    intake = HERE / 'ast-calibration-intake.json.gz'
    original = json.loads(gzip.decompress(intake.read_bytes()))
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.17', intake=packet(intake.read_bytes()),
                 after={name: packet((ROOT / name).read_bytes()) for name in original['inputs']},
                 channels={name: packet((SCRATCH / name).read_bytes()) for name in (
                     'ast-calibration-final.json', 'ast-after.tap', 'book-ast-build.log')},
                 producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
                     Path(__file__), HERE / 'ast_calibration_probe.pl',
                     ROOT / 'tools/project_data_run.sh', ROOT / 'tools/project_data_env.sh',
                     ROOT / 'tools/run_mdbook_local.sh')},
                 rendered=packet((ROOT / 'docs/linkedspec-book/book/development/local-ci-and-regression.html').read_bytes()),
                 limits='Three reached AST assertion layouts only. Actual public Count/key native and fresh emitted execution, exact fragment replay and six capture-bound observations with a scoped typed-span stub. Wrong-key and unguarded-span controls are isolated regressions, not historical runtime behavior. No production change, broad raw fallback, historical objective population expansion, portable admission or transitive generation-closure credit. Exact staged canonical CI and normal hooks govern integrated10 acceptance; broader custody remains23.4.2.')
    DESTINATION.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('AST calibration evidence retained')


def observations(rows):
    assert rows['counts'] == [dict(initial=[], binding=['tail'], value=1, error=''),
                              dict(initial=['seed'], binding=['seed', 'tail'], value=2, error='')]
    assert [row['fault'] for row in rows['keys']] == [0, 1]
    for row, field in zip(rows['keys'], ['first', 'later']):
        assert row['result'] == {'seed': 'kept', field: 'payload'}
        assert row['key'] == 'later' and not row['error']
    ids = ['available', 'empty', 'missing_boundary', 'missing_position', 'missing_match', 'reversed']
    assert [(r['id'], r['fault']) for r in rows['captures']] == [(name, fault) for name in ids for fault in (0, 1)]
    for number, name in enumerate(ids):
        good, bad = rows['captures'][number * 2:number * 2 + 2]
        assert good['kind'] == bad['kind'] == 'SCALAR' and not good['error'] and not bad['error']
        expected = ['ab', '', None, None, None, None][number]
        assert good['value'] == good['expected'] == expected and not good['warnings']
        calls = [{'start': 0, 'end': [2, 0][number], 'helper': 'capture_slice'}] if number < 2 else []
        assert good['calls'] == calls
        if number < 2:
            assert bad['value'] == expected and bad['calls'] == calls and not bad['warnings']
        else:
            assert len(bad['calls']) == 1 and bad['value'] != expected, 'unguarded bound control did not distinguish'
    assert [r['id'] for r in rows['public']] == ['count_once', 'key_snapshot']
    for row, value in zip(rows['public'], [[1, ['tail'], 'V'], [{'first': 'payload'}, 'later', 'V']]):
        assert row['loaded'] == 1 and row['native'] == row['fresh'] == value
        assert not row['error'] and not row['native_error'] and not row['output']


def review():
    saved = json.loads(gzip.decompress(DESTINATION.read_bytes()))
    assert saved['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.17'
    intake = json.loads(gzip.decompress(decode(saved['intake'])))
    for section in ('after', 'channels', 'producers'):
        for row in saved[section].values():
            decode(row)
    for row in intake['inputs'].values():
        decode(row)
    for name in intake['inputs']:
        if name != TEST and name != BOOK and name != 'docs/knowledge/perl-actionir-ast-parser-seam.md':
            assert decode(intake['inputs'][name]) == decode(saved['after'][name]), 'unexpected production/authority edit'
    failure = decode(intake['failure'])
    assert b'Failed 3/24 subtests' in failure and b'Result: FAIL' in failure
    tap = decode(saved['channels']['ast-after.tap'])
    assert b'Files=2, Tests=40' in tap and b'Result: PASS' in tap
    old, new = decode(intake['inputs'][TEST]), decode(saved['after'][TEST])
    for fence in (b'poison|__bad_', b'unknown return-payload call keeps diagnostic sentinel',
                  b'return payloads entered through the AST parser'):
        assert fence in old and fence in new, 'AST rejection fence lost'
    rows = json.loads(decode(saved['channels']['ast-calibration-final.json']))
    observations(rows)
    observations(json.loads(decode(intake['prototype'])))
    # Execute the retained fragments and emitted sources themselves. The native
    # API side is re-derived with this checkout; retained lowerings are not rebuilt.
    producer = decode(saved['producers'][str((HERE / 'ast_calibration_probe.pl').relative_to(ROOT))])
    replay = subprocess.run(['perl', '-Iperl', '-e', producer.decode(), '--', '--replay'],
                            cwd=ROOT, input=json.dumps(rows).encode(), capture_output=True)
    assert replay.returncode == 0 and not replay.stderr, replay.stderr
    observations(json.loads(replay.stdout))
    for mutation in ('loss', 'once', 'snapshot', 'bounds', 'empty'):
        changed = copy.deepcopy(rows)
        if mutation == 'loss':
            changed['captures'].pop()
        elif mutation == 'once':
            changed['public'][0]['fresh'][-1] = 'VV'
        elif mutation == 'snapshot':
            changed['keys'][0]['result'] = {'seed': 'kept', 'later': 'payload'}
        elif mutation == 'bounds':
            changed['captures'][4]['calls'] = [{'start': None, 'end': 2, 'helper': 'capture_slice'}]
        else:
            changed['captures'][2]['value'] = None
        try:
            observations(changed)
        except AssertionError:
            pass
        else:
            raise AssertionError('AST semantic evidence corruption admitted: ' + mutation)
    html = Visible(); html.feed(decode(saved['rendered']).decode())
    visible = normal(' '.join(html.parts))
    assert 'poisoned AST' in visible and 'missing or reversed' in visible
    return dict(groups=3, focused_tests=40, public_programs=2, capture_bounds=6,
                retained_source_replay=True, isolated_wrong_key_and_unguarded_bounds='RED',
                loss_once_snapshot_bounds_empty='RED', limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    else:
        print(json.dumps(review(), sort_keys=True))
