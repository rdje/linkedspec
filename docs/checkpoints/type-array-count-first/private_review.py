"""Verify the three-row private guard admission and its independent falsifiers."""
import subprocess
import common as c
from repair_private import IDS, OLD, NEW, TEST, LOWERING


def check(fresh=True):
    draft = c.load('draft3.json.gz')
    assert draft['inputs_unchanged'] and draft['baseline']['returncode'] == 0
    assert not c.decode(draft['baseline']['stderr_base64'])
    assert draft['private']['returncode'] != 0
    assert b'Failed 3/230 subtests' in c.decode(draft['private']['stdout_base64'])
    for key, name in [('publication', 'publication3.json'), ('manifest', 'publication3-inputs.json.gz')]:
        assert c.read(c.PREFIX + name) == draft['packets'][key]
    repair = c.load('private-repair.json.gz')
    inputs = c.load('private-repair-inputs.json.gz')
    assert repair['ids'] == inputs['plan']['ids'] == IDS
    assert inputs['plan']['old'] == OLD and inputs['plan']['new'] == NEW
    assert repair['before'] == inputs['before'][TEST]
    original = subprocess.check_output(['git', 'show', c.BASE + ':' + TEST], cwd=c.ROOT)
    assert c.decode(repair['before']['base64']) == original
    assert repair['after'] == c.read(TEST) and repair['production'] == c.read(LOWERING)
    assert repair['sources_restored'] and repair['native'] and c.unchanged(repair['native'])
    assert all(item == draft['context']['inputs'][path] for path, item in repair['native'].items())
    text = c.decode(repair['after']['base64'])
    selection = ('    $expected->{value} = q~' + NEW + '~;').encode()
    assert text.count(selection) == 1
    expected_tests = {
        'green': text,
        'translation-fault': text.replace(selection, b'    # Deliberately omit current source expectation.', 1),
        'semantic-fault': text.replace(selection, ('    $expected->{value} = q~' + OLD + '~;').encode(), 1),
        'restored': text,
    }
    source = c.decode(repair['production']['base64'])
    guard = b"ref($__ls_count) eq \\'ARRAY\\'"
    assert source.count(guard) == 1
    for stem, expected in expected_tests.items():
        observation = c.load('private-' + stem + '.json.gz')
        assert observation['inputs_unchanged']
        assert observation['context']['overrides'][TEST]['base64'] == c.encode(expected)
        assert observation['context']['overrides'][TEST]['mode'] == repair['after']['mode']
        expected_source = source.replace(guard, b'defined($__ls_count)', 1) if stem == 'semantic-fault' else source
        assert observation['context']['overrides'][LOWERING]['base64'] == c.encode(expected_source)
        run = observation['run']
        key = {'translation-fault': 'omission', 'semantic-fault': 'semantic'}.get(stem, stem)
        assert run == repair[key]
        output, errors = c.decode(run['stdout_base64']), c.decode(run['stderr_base64'])
        if stem in ('green', 'restored'):
            assert run['returncode'] == 0 and not errors
            assert b'Tests=236' in output and b'Result: PASS' in output
        else:
            assert run['returncode'] != 0 and b'Failed 3/236 subtests' in output
            if stem == 'semantic-fault':
                assert errors.count(b'emitted count handles array and nonarray operands') == 3
                assert b'preserves complete native row' not in errors
    if fresh:
        run = c.run(['prove', '-v', '-Iperl', TEST])
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        assert b'Tests=236' in c.decode(run['stdout_base64'])
    return dict(rows=3, assertions=236, execution_inputs_per_row=7, effective_faults=2,
        scope='Original native records remain exact; current expectations change only the three reviewed count guards. Matched old source fails solely through independent execution.')


if __name__ == '__main__':
    import json
    print(json.dumps(check(), sort_keys=True))
