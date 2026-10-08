"""Preserve the initial population; create only the two diagnosed instrument corrections."""
from pathlib import Path
import copy
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('corrected-prepare.py')
CORRECTED = PREFIX + 'corrected-'


def main():
    initial = json.loads(Path(PREFIX + 'cases.json').read_bytes()); cases = copy.deepcopy(initial)
    generated = next(case for case in cases if case['id'] == 'generated_data')
    segment = next(piece for piece in generated['segments'] if piece['text'] == "'); ")
    segment['text'] = "', ''); "
    action = ''; spans = []
    for piece in generated['segments']:
        start = len(action); action += piece['text']
        if piece['role'] in ('literal_twin', 'real'):
            spans.append({'role': piece['role'], 'raw': piece['text'], 'start': start, 'end': len(action)})
    generated.update(action=action, source='Top:: I { ' + action + ' }', spans=spans)
    generated['scope'] = 'Corrected accepted two-argument cat; original one-argument rejection is preserved separately.'
    assert [case for case in initial if case['id'] != 'generated_data'] == [
        case for case in cases if case['id'] != 'generated_data']
    target = Path(CORRECTED + 'cases.json'); assert not target.exists()
    target.write_text(json.dumps(cases, ensure_ascii=False, indent=2) + '\n')
    before = Path(PREFIX + 'probe.pl').read_text()
    old = ('        my $plain;\n'
           '        ($plain, $diagnostics) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(\'Top\', $action, undef);\n'
           '        die \'observer changed actual substitution\' unless $plain eq $substitution;')
    new = ('        $unobserved_substitution = LinkedSpec::call_spec_handler_subst(\'Top\', $action);\n'
           '        die \'observer changed actual facade substitution\' unless $unobserved_substitution eq $substitution;\n'
           '        ($owner_substitution, $diagnostics) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(\'Top\', $action, undef);')
    assert before.count(old) == 1
    after = before.replace(old, new)
    declaration = 'my ($substitution, $diagnostics, $ast, $dump, $emitted, $descriptor);'
    assert after.count(declaration) == 1
    after = after.replace(declaration, declaration + '\nmy ($unobserved_substitution, $owner_substitution);')
    field = '    substitution => $substitution, diagnostics => project($diagnostics),'
    assert after.count(field) == 1
    after = after.replace(field, '    substitution => $substitution, unobserved_substitution => $unobserved_substitution,\n'
                                '    owner_substitution => $owner_substitution, diagnostics => project($diagnostics),')
    base = Path(PREFIX).relative_to(ROOT).as_posix()
    assert after.count("'" + base + "'") == 1
    after = after.replace("'" + base + "'", "'" + base + "corrected-'")
    Path(CORRECTED + 'probe.pl').write_text(after)
    for suffix in ('red-fixture.t', 'capture.py'):
        source = Path(PREFIX + suffix).read_text()
        if suffix == 'red-fixture.t':
            assert source.count("'" + base + "'") == 1
            source = source.replace("'" + base + "'", "'" + base + "corrected-'")
        Path(CORRECTED + suffix).write_text(source)
    report = {'complete': True, 'unchanged_source_oracles': 13,
              'corrected_source': generated['source'],
              'scope': 'Exactly one cat-arity source correction, observed/unobserved same-facade comparison, '
                       'separate direct-owner channel and output/prefix declarations. All original producers '
                       'and actual captures remain unchanged; no production change.',
              'inputs': {suffix: hashlib.sha256(Path(PREFIX + suffix).read_bytes()).hexdigest()
                         for suffix in ('cases.json', 'probe.pl', 'red-fixture.t', 'capture.py')}}
    Path(PREFIX + 'corrections.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Explicit corrected population prepared; thirteen original source oracles unchanged')


if __name__ == '__main__':
    main()
