"""Readonly review of current execution and complete retained repair epochs."""
import json
import re
import subprocess
import common as c
import doc_check
import git_inputs
import oracle


def prior():
    saved = c.load('prior.json.gz')
    old_path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json'
    raw = subprocess.check_output(['git', 'show', c.BASE + ':' + old_path], cwd=c.ROOT)
    assert raw == c.decode(saved['original']['base64'])
    old = json.loads(raw)
    bindings = old['claims'][0]['durability']['inputs']
    assert {item['path']: item['sha256'] for item in bindings} == {
        path: item['sha256'] for path, item in saved['inputs'].items()}
    receipt_raw = subprocess.check_output(['git', 'show', c.BASE + ':'
        + 'docs/checkpoints/type-evaluated-values/publication-selector.json'], cwd=c.ROOT)
    assert c.sha(receipt_raw) == saved['receipt']['sha256']
    receipt = json.loads(receipt_raw)
    assert receipt['record_base64'] == saved['original']['base64']
    assert {path: item['mode'] for path, item in saved['inputs'].items()} == receipt['input_modes']
    old['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
    assert json.loads((c.ROOT / old_path).read_bytes()) == old
    assert c.decode(saved['baseline']['status']['base64']).strip() == b'0'
    assert b'publication PASS: 845 inputs; 130759 bytes;' in c.decode(saved['baseline']['log']['base64'])
    assert saved['producer'] == c.read(c.PREFIX + 'preserve.py')
    assert saved['primitives'] == c.read(c.PREFIX + 'common.py')
    return len(bindings)


def source_inputs(epoch):
    plan = c.load(epoch + '-inputs.json')
    assert plan['source']['sha256'] == plan['inputs'][c.SOURCE]['sha256']
    assert c.sha(c.decode(plan['source']['base64'])) == plan['source']['sha256']
    for path, item in plan['inputs'].items():
        if path == c.SOURCE:
            continue
        assert c.identity(path) == item, path
    if epoch.startswith('red'):
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + c.SOURCE], cwd=c.ROOT)
        assert c.sha(raw) == plan['source']['sha256']
    else:
        assert c.read(c.SOURCE) == plan['source']
    return plan


def span(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    literal = '{|| return("yes") }'
    start = value['expression'].index(literal)
    assert value['expected'] == dict(start=start, end=start + len(literal))
    return value['expected'] == value['native'] == value['generated']


def docs():
    proposals = c.load('docs-proposals.json.gz')
    refinement = c.load('doc-refinement.json.gz')
    assert proposals['producer'] == c.read(c.PREFIX + 'docs.py')
    assert refinement['producer'] == c.read(c.PREFIX + 'doc_final.py')
    expected = {}
    for path, item in proposals['proposals'].items():
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert raw == c.decode(item['before']['base64'])
        expected[path] = c.decode(item['after'])
    for path, item in refinement['before'].items():
        if path in expected:
            assert c.decode(item['base64']) == expected[path]
        expected[path] = c.decode(refinement['after'][path])
    assert all((c.ROOT / path).read_bytes() == raw for path, raw in expected.items())


def review(fresh=True):
    git_inputs.verify()
    prior_count = prior()
    red = source_inputs('red-channel')
    green = source_inputs('green')
    assert red['plan'] == green['plan']
    assert c.load('red-channel-run.json.gz')['inputs_unchanged']
    assert c.load('green-run.json.gz')['inputs_unchanged']
    bad = oracle.mismatches(c.load('red-channel-run.json.gz')['run'], red['plan'], red['inputs'])
    assert bad == c.load('red-review.json')['failures'] and len(bad) == 19
    assert c.load('red-review.json')['oracle'] == c.read(c.PREFIX + 'oracle.py')
    assert not oracle.mismatches(c.load('green-run.json.gz')['run'], green['plan'], green['inputs'])
    if fresh:
        run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(green['plan']).encode())
        assert not oracle.mismatches(run, green['plan'], green['inputs'])
        assert span(c.run(['perl', '-Iperl', c.PREFIX + 'span.pl']))
    faults = c.load('fault-inputs.json')
    assert c.unchanged(faults['inputs'])
    assert faults['source'] == c.read(c.SOURCE)
    original = c.decode(faults['source']['base64'])
    effects = {}
    for edit in faults['changes']:
        name = edit['name']
        before, after = c.decode(edit['before']), c.decode(edit['after'])
        assert original.count(before) == 1
        result = c.load('fault-' + name + '.json.gz')
        observed = c.load('fault-' + name + '-observed.json.gz')
        assert result['mutant_sha256'] == observed['mutant_sha256'] == c.sha(original.replace(before, after, 1))
        rejected = oracle.mismatches(result['run'], green['plan'], green['inputs'])
        assert rejected == result['failures'] == observed['failures']
        assert result['run'] == observed['run'] and result['span'] == observed['span']
        assert result['span_red'] == observed['span_red'] == (not span(result['span']))
        assert rejected or result['span_red']
        assert result['inputs_restored']
        assert not oracle.mismatches(result['restored'], green['plan'], green['inputs'])
        assert span(result['restored_span'])
        effects[name] = dict(cases=len(rejected), spans=result['span_red'])
    assert c.load('fault-review.json')['faults'] == list(effects)
    focused = c.load('focused-inputs.json')
    retained = c.load('focused-run.json.gz')
    assert c.unchanged(focused['inputs']) and retained['inputs_unchanged']
    assert [run['command'] for run in retained['runs']] == focused['commands']
    assert all(run['returncode'] == 0 for run in retained['runs'])
    tap = c.decode(retained['runs'][2]['stdout_base64']).decode()
    totals = re.search(r'Files=(\d+), Tests=(\d+),', tap)
    assert totals and int(totals[1]) == len(focused['selected'])
    assert not c.decode(retained['runs'][2]['stderr_base64']) and 'Result: PASS' in tap
    docs()
    book = doc_check.check(fresh)
    return dict(result='PASS', runtime_cases=len(green['plan']['cases']), baseline_red=len(bad),
        baseline_controls=len(green['plan']['cases']) - len(bad), faults=effects,
        retained_suites=len(focused['selected']), retained_tap_tests=int(totals[2]),
        test_inputs=len(focused['inputs']), book_inputs=book['book_inputs'], prior_inputs=prior_count,
        limits='Finite Perl scoped-with repair. Fresh native/generated values, spans and book; '
               '14 direct suites are retained executions from their complete supplied input snapshot. '
               'Canonical receipt separately admits the exact candidate. Numeric5/drop6 and startup32/35 '
               'remain owned; no exhaustive inventory, other-backend or private-parent admission.')
