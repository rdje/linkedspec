"""Calibrate only twenty obsolete terminal expectations against current ordinary contracts."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import statistics

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'
FILES = ['tests/numeric-codeblocks/' + name + '.json' for name in (
    'cases', 'effects', 'stability', 'receiver-invalid', 'terminals', 'pipelines',
    'sort-kinds', 'count-first', 'registered-pipelines')]
INTAKE = HERE / 'numeric-calibration-intake.json.gz'
TARGET = HERE / 'numeric-calibration-target.json'
EVIDENCE = HERE / 'numeric-calibration-evidence.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'numeric packet identity'
    return raw


def expected_values():
    values, reducer_values = [2, 10, 1], [3, 1, 8]
    lexical = sorted(values, key=str)
    result = {
        'outside/effect/comparison-terminal': int(3 > 1) + 2,
        'outside/stability/terminal-skips-receiver': [int(3 > 1) + 2, 'r'],
        'ordinary/chain/terminal': abs(sum(lexical[:2])),
        'ordinary/effect/terminal': [abs(sum(lexical[:2])), 'sn'],
        'ordinary/count/receiver/abs': abs(len(values)),
        'ordinary/count/receiver/comparison': int(len(values) > 0),
        'ordinary/first/receiver/cat': str(values[0]) + '!',
        'ordinary/first/receiver/array-continuation': lexical,
        'ordinary/count/effects/receiver/continuation': [abs(len(values)), 'r'],
        'ordinary/first/effects/receiver/continuation': [abs(values[0]), 'r'],
        'ordinary/function/terminal': abs(len(lexical)),
        'deferred/function/terminal': abs(len(lexical)),
        'ordinary/effect/length-terminal': [abs(len(lexical[:2])), 'sn'],
        'ordinary/effect/direct-terminal': [abs(len(values)), 's'],
    }
    reducers = dict(sum=sum(reducer_values), avg=statistics.mean(reducer_values),
                    median=statistics.median(reducer_values), range=max(reducer_values) - min(reducer_values),
                    min=min(reducer_values), max=max(reducer_values))
    result.update({'aggregate7/ordinary/' + name + '/terminal': abs(value) for name, value in reducers.items()})
    assert len(result) == 20
    return result


def nested_cases():
    result = {
        'outside/effect/comparison-terminal': dict(body='score=3; out=num_add(num_gt(score,1),2); return(out)'),
        'outside/stability/terminal-skips-receiver': dict(body='trace=""; read={|| trace=cat(trace,"r"); return(3) }; out=num_add(num_gt(read(),1),2); return([out,trace])'),
        'ordinary/chain/terminal': dict(body='items=[2,10,1]; return(num_abs(sum(take(sorted(items),2))))'),
        'ordinary/effect/terminal': dict(body='trace=""; source={|| trace=cat(trace,"s"); return([2,10,1]) }; limit={|| trace=cat(trace,"n"); return(2) }; out=num_abs(sum(take(sorted(source()),limit()))); return([out,trace])'),
        'ordinary/count/receiver/abs': dict(body='items=[2,10,1]; return(num_abs(count(items)))'),
        'ordinary/count/receiver/comparison': dict(body='items=[2,10,1]; return(num_gt(count(items),0))'),
        'ordinary/first/receiver/cat': dict(body='items=[2,10,1]; return(cat(first(items),"!"))'),
        'ordinary/first/receiver/array-continuation': dict(body='items=[[2,10,1],[]]; return(sorted(first(items)))'),
        'ordinary/count/effects/receiver/continuation': dict(body='seen=""; items=[2,10,1]; tap={|tag,value| seen=cat(seen,tag); return(value) }; return([num_abs(count(tap("r",items))),seen])'),
        'ordinary/first/effects/receiver/continuation': dict(body='seen=""; items=[2,10,1]; tap={|tag,value| seen=cat(seen,tag); return(value) }; return([num_abs(first(tap("r",items))),seen])'),
        'ordinary/function/terminal': dict(body='return(select_items([2,10,1]))', functions='fn select_items(items) { return(num_abs(length(sorted(items)))) }\n'),
        'deferred/function/terminal': dict(body='cb={|| return(select_items([2,10,1])) }; return(cb())', functions='fn select_items(items) { return(num_abs(length(sorted(items)))) }\n'),
        'ordinary/effect/length-terminal': dict(body='seen=""; source={|| seen=cat(seen,"s"); return([2,10,1]) }; limit={|| seen=cat(seen,"n"); return(2) }; out=num_abs(length(take(sorted(source()),limit()))); return([out,seen])'),
        'ordinary/effect/direct-terminal': dict(body='seen=""; source={|| seen=cat(seen,"s"); return([2,10,1]) }; limit={|| seen=cat(seen,"n"); return(2) }; out=num_abs(length(source())); return([out,seen])'),
    }
    for name in ('sum', 'avg', 'median', 'range', 'min', 'max'):
        result['aggregate7/ordinary/' + name + '/terminal'] = dict(body='items=[3,1,8]; return(num_abs(' + name + '(items)))')
    assert set(result) == set(expected_values())
    return result


def intake():
    assert not INTAKE.exists() and not TARGET.exists(), 'keep original numeric intake immutable'
    expected, twins = expected_values(), nested_cases()
    failure = (SCRATCH / 'canonical-ci.log').read_bytes()
    failed_ids = set(re.findall(rb"#   Failed test '([^']*/[^']*)'", failure))
    assert failed_ids == {name.encode() for name in expected}, 'actual failure membership differs'
    inputs = {name: packet((ROOT / name).read_bytes()) for name in FILES}
    cases = []
    for name in FILES:
        for row in json.loads(decode(inputs[name]))['cases']:
            if row['id'] in expected:
                twin = twins[row['id']]
                cases.append(dict(id=row['id'], fixture=name, original=row, expected=expected[row['id']],
                                  nested_body=twin['body'], **({'nested_functions': twin['functions']} if 'functions' in twin else {})))
    assert len(cases) == 20 and {row['id'] for row in cases} == set(expected)
    authorities = [
        'docs/checkpoints/type-operation-inventory/numeric-comparison-results.md',
        'docs/checkpoints/type-operation-inventory/aggregate-numeric-results.md',
        'docs/checkpoints/type-operation-inventory/count-length-results.md',
        'docs/checkpoints/type-operation-inventory/selected-values.md',
        'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
        'capability_conformance/scalar_numeric_contract.json', 't/scalar_numeric_contract.t',
    ]
    target = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.16', cases=cases,
                  authorities=authorities, limits='Only these twenty current ordinary-result expectations; deferred receiver boundaries and every other case/source stay unchanged. Existing sorted is lexicographic, so sorted([2,10,1]) begins[1,10], whose sum is11.')
    TARGET.write_text(json.dumps(target, sort_keys=True, indent=2) + '\n')
    saved = dict(inputs=inputs, authorities={name: packet((ROOT / name).read_bytes()) for name in authorities},
                 failure=packet(failure), target=packet(TARGET.read_bytes()),
                 producer=packet(Path(__file__).read_bytes()))
    INTAKE.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('twenty-case numeric intake and independent nested targets retained')


def observations(rows, target):
    expected = expected_values()
    assert len(rows) == 40 and len({(row['id'], row['variant']) for row in rows}) == 40
    assert {(row['id'], row['variant']) for row in rows} == {(name, variant) for name in expected for variant in ('fluent', 'nested')}
    originals = {row['id']: row for row in target['cases']}
    red = 0
    for row in rows:
        encoded = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
        assert row['loaded'] == 1
        assert encoded(row['native']) == encoded(row['fresh']) == encoded(expected[row['id']])
        assert not any(row[key] for key in ('native_error', 'native_context_error', 'native_output', 'warnings', 'load_error', 'fresh_error'))
        source = originals[row['id']]
        body = source['original']['body'] if row['variant'] == 'fluent' else source['nested_body']
        functions = source['original'].get('functions', '') if row['variant'] == 'fluent' else source.get('nested_functions', source['original'].get('functions', ''))
        assert row['source'] == functions + 'Top: /x/\n I { ' + body + ' }\n'
        if row['variant'] == 'fluent':
            assert row['native'] != source['original']['expected']
            red += 1
    assert red == 20


def repaired_inputs(saved, target):
    values = expected_values()
    result = {}
    changed = 0
    for name, row in saved['inputs'].items():
        raw = decode(row)
        data = json.loads(raw)
        assert (json.dumps(data, sort_keys=True, separators=(',', ':')) + '\n').encode() == raw, 'unexpected fixture serialization'
        for case in data['cases']:
            if case['id'] in values:
                match = next(item for item in target['cases'] if item['id'] == case['id'])
                assert case == match['original'] and name == match['fixture']
                case['expected'] = values[case['id']]
                changed += 1
        result[name] = (json.dumps(data, sort_keys=True, separators=(',', ':')) + '\n').encode()
    assert changed == 20
    return result


def apply():
    saved = json.loads(gzip.decompress(INTAKE.read_bytes()))
    target = json.loads(decode(saved['target']))
    observations(json.loads((SCRATCH / 'numeric-observations.json').read_bytes()), target)
    result = repaired_inputs(saved, target)
    for name, row in saved['inputs'].items():
        assert (ROOT / name).read_bytes() == decode(row), 'fixture changed before calibration'
    for name, raw in result.items():
        if raw != (ROOT / name).read_bytes():
            (ROOT / name).write_bytes(raw)
    print('only twenty expected values updated; every source and other field retained')


def capture():
    assert not EVIDENCE.exists(), 'keep completed numeric evidence immutable'
    saved = json.loads(gzip.decompress(INTAKE.read_bytes()))
    target = json.loads(decode(saved['target']))
    result = repaired_inputs(saved, target)
    for name, raw in result.items():
        assert (ROOT / name).read_bytes() == raw
    book = 'docs/linkedspec-book/src/appendix/formal-grammar.md'
    import subprocess
    old_book = subprocess.check_output(['git', 'show', ':' + book], cwd=ROOT)
    record = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.16', intake=packet(INTAKE.read_bytes()),
                  after={name: packet(raw) for name, raw in result.items()},
                  observations=packet((SCRATCH / 'numeric-observations.json').read_bytes()),
                  after_tap=packet((SCRATCH / 'numeric-after.tap').read_bytes()),
                  book=dict(path=book, before=packet(old_book), after=packet((ROOT / book).read_bytes()),
                            rendered=packet((ROOT / 'docs/linkedspec-book/book/appendix/formal-grammar.html').read_bytes())),
                  producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
                      Path(__file__), HERE / 'numeric_calibration_probe.pl', ROOT / 'tools/project_data_run.sh', ROOT / 'tools/project_data_env.sh')},
                  limits=target['limits'] + ' Original numeric-v1 authority and runtime are unchanged. This is authored calibration, not full domain/context/portable or transitive-generation admission; broader custody remains23.4.2. Canonical CI and normal hooks govern landing.')
    EVIDENCE.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('numeric calibration and complete focused TAP retained')


def review():
    saved = json.loads(gzip.decompress(EVIDENCE.read_bytes()))
    assert saved['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.16'
    before = json.loads(gzip.decompress(decode(saved['intake'])))
    target = json.loads(decode(before['target']))
    assert {row['id']: row['expected'] for row in target['cases']} == expected_values()
    for row in before['authorities'].values():
        decode(row)
    decode(before['producer'])
    for row in saved['producers'].values():
        decode(row)
    assert b'failed 20 tests of 1008' in decode(before['failure'])
    result = repaired_inputs(before, target)
    assert set(result) == set(FILES) == set(saved['after'])
    assert sum(len(json.loads(decode(row))['cases']) for row in before['inputs'].values()) == 1008
    for name, raw in result.items():
        assert decode(saved['after'][name]) == raw, 'extra numeric fixture change'
    rows = json.loads(decode(saved['observations']))
    observations(rows, target)
    for mutation in ('loss', 'effect', 'sort', 'number', 'kind'):
        changed = copy.deepcopy(rows)
        if mutation == 'loss':
            changed.pop()
        else:
            name = {'effect': 'ordinary/effect/terminal', 'sort': 'ordinary/chain/terminal', 'number': 'ordinary/count/receiver/comparison', 'kind': 'ordinary/count/receiver/comparison'}[mutation]
            row = next(row for row in changed if row['id'] == name and row['variant'] == 'fluent')
            row['native'] = {'effect': [11, ''], 'sort': 3, 'number': None, 'kind': True}[mutation]
        try:
            observations(changed, target)
        except AssertionError:
            pass
        else:
            raise AssertionError('numeric observation mutation admitted: ' + mutation)
    tap = decode(saved['after_tap'])
    assert b'1..1008' in tap and b'Files=1, Tests=10' in tap and b'Result: PASS' in tap
    assert not re.search(rb'^\s*not ok\b', tap, re.M)
    book = saved['book']
    old_book, new_book = decode(book['before']), decode(book['after'])
    start = new_book.index(b'Existing ordinary Perl result transitions include:')
    end = new_book.index(b'### 7.4 Hash Helpers')
    assert new_book[:start] + new_book[end:] == old_book, 'unreviewed numeric book change'
    from book_review import Visible, normal
    visible = Visible(); visible.feed(decode(book['rendered']).decode())
    assert 'Sorting remains lexicographic' in normal(''.join(visible.parts))
    return 'twenty exact ordinary cases agree with nested native/fresh oracles; only expected fields change; all1008 cases retained; complete TAP and loss/effect/lexical-order/value/Boolean-kind denials PASS'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--intake', action='store_true')
    mode.add_argument('--apply', action='store_true')
    mode.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.intake:
        intake()
    elif args.apply:
        apply()
    elif args.capture:
        capture()
    else:
        print(review())
