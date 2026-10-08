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
    # Repeat the already documented correction for the authored LF variant.
    lf = next(case for case in cases if case['id'] == 'lf_generated_data')
    piece = next(piece for piece in lf['segments'] if piece['text'] == "')\n")
    piece['text'] = "', '')\n"
    action = ''; spans = []
    for piece in lf['segments']:
        start = len(action); action += piece['text']
        if piece['role'] in ('literal_twin', 'real'):
            spans.append({'role': piece['role'], 'raw': piece['text'], 'start': start, 'end': len(action)})
    lf.update(action=action, source='Top:: I { ' + action + ' }', spans=spans)
    target.write_text(json.dumps(cases, ensure_ascii=False, indent=2) + '\n')
    Path(CORRECTED + 'replacement-fixture.t').write_bytes(Path(PREFIX + 'replacement-fixture.t').read_bytes())
    capture = Path(PREFIX + 'capture.py').read_text()
    assert capture.count('PUBLIC = '+repr(base)) == 1
    capture = capture.replace('PUBLIC = '+repr(base), 'PUBLIC = '+repr(base+'corrected-'))
    Path(CORRECTED + 'capture.py').write_text(capture)
    report = {'complete': True, 'unchanged_source_oracles': 16,
              'corrected_source': generated['source'],
              'scope': 'Exactly the established cat-arity source correction and its LF variant, observed/unobserved same-facade comparison, '
                       'separate direct-owner channel and output/prefix declarations. All original producers '
                       'and actual captures remain unchanged; no production change.',
              'inputs': {suffix: hashlib.sha256(Path(PREFIX + suffix).read_bytes()).hexdigest()
                         for suffix in ('cases.json', 'probe.pl', 'replacement-fixture.t', 'capture.py')}}
    Path(PREFIX + 'corrections.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Explicit corrected population prepared; sixteen original source oracles unchanged; same established cat correction covers LF variant')


if __name__ == '__main__':
    main()
