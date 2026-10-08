"""Independently verify the explicit instrument corrections and their preserved rejections."""
from pathlib import Path
import copy
import gzip
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('instrument-review.py')
spec = importlib.util.spec_from_file_location('replacement_review', Path(PREFIX + 'review.py'))
review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)


def check(bundle):
    initial, current = bundle['cases'], bundle['corrected_cases']
    assert [c for c in initial if c['id'] != 'generated_data'] == [c for c in current if c['id'] != 'generated_data'], 'thirteen exact original source oracles'
    old = next(c for c in initial if c['id'] == 'generated_data')
    new = next(c for c in current if c['id'] == 'generated_data')
    expected = copy.deepcopy(old)
    expected['segments'][2]['text'] = "', ''); "
    action = ''; spans = []
    for piece in expected['segments']:
        start = len(action); action += piece['text']
        if piece['role'] in ('real', 'literal_twin'):
            spans.append({'role': piece['role'], 'raw': piece['text'], 'start': start, 'end': len(action)})
    expected.update(action=action, source='Top:: I { ' + action + ' }', spans=spans,
                    scope='Corrected accepted two-argument cat; original one-argument rejection is preserved separately.')
    assert new == expected, 'sole cat arity correction and exact interval translation'
    relative = Path(PREFIX).relative_to(ROOT).as_posix()
    text = bundle['corrected_probe'].replace("'" + relative + "corrected-'", "'" + relative + "'")
    new_block = ('        $unobserved_substitution = LinkedSpec::call_spec_handler_subst(\'Top\', $action);\n'
                 '        die \'observer changed actual facade substitution\' unless $unobserved_substitution eq $substitution;\n'
                 '        ($owner_substitution, $diagnostics) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(\'Top\', $action, undef);')
    old_block = ('        my $plain;\n'
                 '        ($plain, $diagnostics) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(\'Top\', $action, undef);\n'
                 '        die \'observer changed actual substitution\' unless $plain eq $substitution;')
    assert text.count(new_block) == 1, 'same-facade comparison and separate owner channel'
    text = text.replace(new_block, old_block)
    text = text.replace('\nmy ($unobserved_substitution, $owner_substitution);', '')
    text = text.replace('    substitution => $substitution, unobserved_substitution => $unobserved_substitution,\n'
                        '    owner_substitution => $owner_substitution, diagnostics => project($diagnostics),',
                        '    substitution => $substitution, diagnostics => project($diagnostics),')
    assert text == bundle['probe'], 'exact probe correction inverse'
    for suffix in ('capture.py', 'trace-capture.py'):
        assert Path(PREFIX + suffix).read_bytes() == Path(PREFIX + 'corrected-' + suffix).read_bytes(), 'unchanged capture producers'
    for suffix in ('red-fixture.t', 'trace.pl'):
        assert Path(PREFIX + suffix).read_text() == Path(PREFIX + 'corrected-' + suffix).read_text().replace(
            "'" + relative + "corrected-'", "'" + relative + "'"), 'prefix-only fixture/trace correction'
    original = bundle['initial_inspect']
    assert original.count("event['event']['contract_id'] == case['contract']") == 1
    assert bundle['inspect'] == original.replace("event['event']['contract_id'] == case['contract']",
        "event['event']['raw'] in {span['raw'] for span in case['spans']}"), 'sole display schema correction'
    error = bundle['inspect_error']
    assert error['exit'] == 1 and review.sha(original.encode()) == error['source_sha256'], 'actual display source/error identity'
    assert b"KeyError: 'contract_id'" in review.decode(error['stderr']), 'actual display rejection recurrence'
    assert b"event['event']['contract_id']" in review.decode(error['stderr']), 'actual traceback original source context'
    review.decode(error['stdout'])
    before = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    after = json.loads(Path(PREFIX + 'corrected-observations.json').read_bytes())
    for seed in (0, 1, 42):
        for name in ('deferred_body', 'generated_data'):
            get = lambda report: json.loads(review.decode(next(run['stdout'] for run in report['runs']
                if run['seed'] == seed and run['kind'] == 'public:' + name)))
            first, final = get(before), get(after)
            if name == 'deferred_body':
                assert first['substitution'] == final['substitution'] == final['unobserved_substitution'], 'source-identical valid facade output'
                assert 'observer changed actual substitution' in first['native']['compile_exception'], 'actual wrong-context rejection'
                assert 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:cb' in final['owner_substitution'], 'actual direct-owner binding distinction'
                assert final['native']['value'] == final['fresh']['value'] == new['expected_value'], 'actual corrected deferred routes'
            else:
                assert first['metadata']['unresolved_helper_hits'] == {'cat': 1}, 'actual initial cat arity rejection'
                assert first['native']['value'] == [None, 1] and final['native']['value'] is None, 'distinguished instrument and product failures'
    initial_meta = json.loads(Path(PREFIX + 'initial.json').read_bytes())
    packed = Path(PREFIX + 'initial-tool-return.json.gz').read_bytes(); raw = gzip.decompress(packed)
    assert review.sha(packed) == initial_meta['artifact_sha256'] and review.sha(raw) == initial_meta['raw_sha256'] and len(raw) == initial_meta['raw_bytes'], 'exact original Toolbox capsule'
    observed = json.loads(raw)['tool_return']
    assert observed['exit_code'] == 0
    lines = [line for line in observed['output'].splitlines() if line.startswith('{"action"')]
    assert len(lines) == 1
    initial_tool = json.loads(lines[0])
    first = json.loads(review.decode(before['runs'][0]['stdout']))
    assert initial_tool['action'] == first['action'] and initial_tool['substitution'] == first['substitution'], 'actual initial Toolbox source/substitution recurrence'


def main():
    bundle = {name.replace('-', '_').replace('.', '_'): Path(PREFIX + name).read_text()
              for name in ('probe.pl', 'corrected-probe.pl', 'initial-inspect.py', 'inspect.py')}
    bundle = {'probe': bundle['probe_pl'], 'corrected_probe': bundle['corrected_probe_pl'],
              'initial_inspect': bundle['initial_inspect_py'], 'inspect': bundle['inspect_py'],
              'cases': json.loads(Path(PREFIX + 'cases.json').read_bytes()),
              'corrected_cases': json.loads(Path(PREFIX + 'corrected-cases.json').read_bytes()),
              'inspect_error': json.loads(Path(PREFIX + 'inspect-error.json').read_bytes())}
    check(bundle); controls = []
    for name, mutate in (
        ('changed original source', lambda b: b['corrected_cases'][0].update(action='changed')),
        ('lost cat interval', lambda b: b['corrected_cases'][6]['spans'].pop()),
        ('lost same-facade guard', lambda b: b.update(corrected_probe=b['corrected_probe'].replace('observer changed actual facade substitution', 'guard removed'))),
        ('unrelated display edit', lambda b: b.update(inspect=b['inspect'] + '\n# extra edit\n')),
        ('forged display source', lambda b: b['inspect_error'].update(source_sha256='0' * 64)),
    ):
        candidate = copy.deepcopy(bundle); mutate(candidate); assert candidate != bundle
        try:
            check(candidate)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected instrument control: ' + name)
    report = {'complete': True, 'unchanged_source_oracles': 13, 'controls': controls,
              'producer_sha256': review.sha(Path(__file__).read_bytes()),
              'scope': 'Exact source inverses and actual retained wrong-context/invalid-arity/display rejections. '
                       'These are instrument controls; no production repair or additional runtime population.'}
    Path(PREFIX + 'instrument-verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
