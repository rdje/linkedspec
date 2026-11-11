"""Author bounded first-call arity controls; retain the original instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
INTAKE = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
FIXTURE = Path('tests/fixtures/array_pipeline_callable_arity_perl_cases.json')
NORMAL = Path('t/array_pipeline_callable_arity.t')
assert not FIXTURE.exists() and not NORMAL.exists()


def template(path, name):
    raw = path.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', 'HEAD:' + str(path)])
    target = BASE / name
    assert not target.exists()
    target.write_bytes(gzip.compress(raw, mtime=0))
    return raw.decode()


cases = json.loads((INTAKE / 'cases.json').read_bytes())
terminal = json.loads((INTAKE / 'arity-cases.json').read_bytes())
classification = json.loads((INTAKE / 'classification.json').read_bytes())
profiles = []
for case in terminal:
    helper = re.fullmatch(r'arity_(?:extra|missing)_(.*)_(?:free|receiver)', case['id'])[1]
    profiles.append(dict(case=case, expected=[None, ''], ready=0, helper=helper))
initial = [case for case in cases[41:] if case.get('question') in ('initial-terminal', 'initial-first-with')]
assert len(initial) == 84
for case in initial:
    expected = [] if case['question'] == 'initial-terminal' else [0, 'W']
    profiles.append(dict(case=case, expected=expected, ready=1))
composed = [case for case in cases if classification['roles'][case['id']] == 'arity-prerequisite-observation'
            and case['id'].endswith('_receiver')]
assert len(composed) == 9
for case in composed:
    helper = re.fullmatch(r'own_(?:extra|missing)_(.*)_receiver', case['id'])[1]
    profiles.append(dict(case=case, expected=[None, ''], ready=0, helper=helper))

valid = {
    'split_each': ('["head:tail"]', [':'], ['head', 'tail']),
    'trim_each': ('[" head "," tail "]', [], ['head', 'tail']),
    'filter_nonempty': ('["head","",undef,"tail"]', [], ['head', 'tail']),
    'lowercase_each': ('["HEAD","TAIL"]', [], ['head', 'tail']),
    'uppercase_each': ('["head","tail"]', [], ['HEAD', 'TAIL']),
    'uniq': ('["head","head","tail"]', [], ['head', 'tail']),
    'filter_match': ('["head","tail"]', ['/^head/'], ['head']),
}
for helper, (array, args, expected) in valid.items():
    arguments = [json.dumps(arg) if arg == ':' else arg for arg in args]
    source = 'yield_items({order=cat(order,"S");' + array + '})'
    for form in ('free', 'receiver'):
        expression = helper + '(' + ','.join([source] + arguments) + ')' if form == 'free' else source + '.' + helper + '(' + ','.join(arguments) + ')'
        body = 'order="";out=' + expression + ';return([out,order])'
        case = dict(id='valid_' + helper + '_' + form, body=body, rule='Value', input='x',
            source='fn yield_items(payload) {return(payload)}\n\nValue:: I {' + body + '}\n')
        profiles.append(dict(case=case, expected=[expected, 'S'], ready=1))
assert len(profiles) == len({row['case']['id'] for row in profiles}) == 125
FIXTURE.write_text(json.dumps(profiles, indent=2) + '\n')

old = template(Path('t/array_pipeline_result_guard_composition.t'), 'normal-template.t.gz')
prefix = old[:old.index('sub normalize_serials {')]
replacements = [
    ('LINKEDSPEC_ARRAY_PIPELINE_COMPOSITION_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE'),
    ('docs/checkpoints/array-pipeline-composition-perl-2026-11-10', str(BASE)),
    ('ARRAY_PIPELINE_COMPOSITION_INPUT', 'CALLABLE_PIPELINE_ARITY_INPUT'),
    ('array-pipeline-selection.spec', 'callable-pipeline-arity.spec'),
    ('LinkedSpec::ArrayPipelineSelectionProbe', 'LinkedSpec::CallablePipelineArityProbe'),
]
for source, target in replacements:
    assert prefix.count(source) == 1, source
    prefix = prefix.replace(source, target)
tail = r'''open my $file,'<:raw','tests/fixtures/array_pipeline_callable_arity_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>}); close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('CALLABLE_PIPELINE_ARITY_ROW '.$case->{id}.' '.$json->encode($row));
  ok($row->{native_callable}, 'native parser builds');
  ok($row->{loaded}, 'fresh emitted module loads');
  for my $field (qw(descriptor_error emission_error build_error native_error load_error fresh_error)) {
   is_deeply($row->{$field}, undef, $field.' absent');
  }
  is($json->encode($row->{native}), $json->encode($profile->{expected}), 'native values and effects');
  is($json->encode($row->{fresh}), $json->encode($profile->{expected}), 'fresh values and effects');
  is_deeply($row->{warnings}, [], 'no host warnings');
  is_deeply($row->{host_after}, $row->{host_before}, 'host source Arrays preserved');
  my $ready=$profile->{ready};
  is_deeply($row->{metadata}, {
   language_agnostic_action_ir_ready=>$ready,
   raw_perl_dependency_count=>0, canonical_action_ir_fallback_count=>0,
   unresolved_helper_count=>$ready?0:1,
   unresolved_helpers=>$ready?[]:[$profile->{helper}],
  }, 'canonical eligibility or public signature rejection');
 };
}
done_testing();
'''
NORMAL.write_text(prefix + tail)

observer = template(INTAKE / 'observer.pl', 'preservation-observer-template.pl.gz')
source = r'\Adocs/checkpoints/array-pipeline-callable-perl-2026-11-11/[a-z_]+'
assert observer.count(source) == 1
observer = observer.replace(source, r'\A' + str(BASE) + '/[a-z_]+')
(BASE / 'preservation_observer.pl').write_text(observer)
(BASE / 'prepared-identities.json').write_text(json.dumps({str(path): hashlib.sha256(path.read_bytes()).hexdigest()
    for path in (FIXTURE, NORMAL, BASE / 'preservation_observer.pl')}, indent=2) + '\n')
print('125 independent arity/valid-producer groups authored; original178 remain a separate observation epoch')
