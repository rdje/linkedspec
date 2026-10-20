"""Admit only the exact numeric successors of two frozen recurring consumers."""
import json
import subprocess
import common as c

WHILE = 't/codeblock_while_perl.t'
SCALAR = 't/actionir_scalar_receiver_required_capture.t'
CASES = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-cases.json'
NATIVE = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-native.json'
FIXTURE = 'tests/numeric-codeblocks/legacy-consumers.json'


def main():
    before = {path: c.read(path) for path in (WHILE, SCALAR)}
    assert all(c.decode(item['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
               for path, item in before.items())
    cases = json.loads((c.ROOT / CASES).read_bytes())
    original = next(case for case in cases if case['id'] == 'numeric_excluded')
    native = json.loads(c.decode(json.loads((c.ROOT / NATIVE).read_bytes())['stdout_base64']))
    names = ('number-unary-excess', 'number-binary-missing', 'number-binary-excess',
             'number-clamp-missing', 'number-clamp-excess', 'number-variadic-missing')
    shapes = {row['name']: row['caller_after'] for row in native['branches'] if row['name'] in names}
    assert len(shapes) == len(names)
    numeric = next(row for row in native['public'] if row['name'] == 'number-decimal')
    fixture = dict(while_case=dict(original=original, current=dict(id=original['id'], source=original['source'],
        expected='hit', current_name='numeric_scalar_admitted')),
        scalar_shapes=shapes, scalar_public=dict(original=numeric, expected=4),
        boundaries='Only scalar numeric admission: exact old source/case identity is required. '
                   'All historical fixture files and all other observations remain unchanged.')
    raw_fixture = (json.dumps(fixture, sort_keys=True, separators=(',', ':')) + '\n').encode()
    text = c.decode(before[WHILE]['base64']).decode()
    anchor = 'close $cases_file or die $!;\n'
    assert text.count(anchor) == 1
    overlay = r'''open my $successor_file, '<', 'tests/numeric-codeblocks/legacy-consumers.json' or die $!;
my $successor = JSON::PP->new->decode(do { local $/; <$successor_file> })->{while_case};
close $successor_file or die $!;
unless (grep { $_ eq '--baseline' } @ARGV) {
 my $json = JSON::PP->new->canonical;
 my @matches = grep { $_->{id} eq $successor->{original}{id} } @$cases;
 die 'numeric while successor requires the exact original case' unless @matches == 1
  && $json->encode($matches[0]) eq $json->encode($successor->{original});
 $cases = [map { $_->{id} eq $successor->{original}{id} ? $successor->{current} : $_ } @$cases];
}
'''
    text = text.replace(anchor, anchor + overlay, 1)
    assert text.count(' subtest $case->{id} => sub {') == 1
    text = text.replace(' subtest $case->{id} => sub {', ' my $case_name = $case->{current_name} // $case->{id};\n subtest $case_name => sub {', 1)
    after = {WHILE: text.encode()}
    text = c.decode(before[SCALAR]['base64']).decode()
    anchor = 'my $current=LinkedSpecTest::MethodLocations::original_coordinates(ScalarReceiverRequiredProbe::observations());\n'
    assert text.count(anchor) == 1
    admission = r'''open my $numeric_file, '<', 'tests/numeric-codeblocks/legacy-consumers.json' or die $!;
my $numeric_contract = JSON::PP->new->decode(do { local $/; <$numeric_file> });
close $numeric_file or die $!;
'''
    text = text.replace(anchor, anchor + admission, 1)
    anchor = ' my $label=\'scalar branch \'.$case->{name};\n'
    assert text.count(anchor) == 1
    shapes_code = r''' if (exists $numeric_contract->{scalar_shapes}{$case->{name}}) {
  die 'numeric shape admission requires its original source/null result'
   unless $expected->{caller_after} eq $numeric_contract->{scalar_shapes}{$case->{name}}
    && !defined($expected->{value}) && !defined($expected->{error});
  # A recognized invalid shape is a complete null expression, not unhandled.
  $expected = {%$expected, value => 'undef'};
 }
'''
    text = text.replace(anchor, anchor + shapes_code, 1)
    old = "is_deeply($current->{public},$native->{public},'four public Toolbox generated-source controls remain exact');\n"
    assert text.count(old) == 1
    public = r'''require LinkedSpec::Numeric;
require './t/lib/LinkedSpecTest/EmittedValues.pm';
my $current_public = [map {+{%$_}} @{$current->{public}}];
my $native_public = [map {+{%$_}} @{$native->{public}}];
my @numeric_rows = grep { $native_public->[$_]{name} eq 'number-decimal' } 0..$#$native_public;
die 'numeric public admission requires one exact frozen row' unless @numeric_rows == 1;
my $numeric_index = $numeric_rows[0];
die 'numeric public admission requires original source and metadata'
 unless JSON::PP->new->canonical->encode($native_public->[$numeric_index])
     eq JSON::PP->new->canonical->encode($numeric_contract->{scalar_public}{original});
my $numeric_golden = {value => $numeric_contract->{scalar_public}{expected}};
is_deeply(LinkedSpecTest::EmittedValues::return_value($native_public->[$numeric_index]{value}),
 $numeric_golden, 'frozen numeric Toolbox source executes the independent value golden');
$current_public->[$numeric_index]{value} = LinkedSpecTest::EmittedValues::return_value($current_public->[$numeric_index]{value});
$native_public->[$numeric_index]{value} = $numeric_golden;
is_deeply($current_public,$native_public,'four public Toolbox controls retain complete metadata and contractual results');
'''
    text = text.replace(old, public, 1)
    after[SCALAR] = text.encode()
    with (c.ROOT / FIXTURE).open('xb') as output:
        output.write(raw_fixture)
    c.write_new('legacy-consumer-proposals.json.gz', dict(before=before,
        after={path: c.encode(raw) for path, raw in after.items()}, fixture=c.read(FIXTURE),
        historical_inputs={path: c.read(path) for path in (CASES, NATIVE)},
        producer=c.read(c.PREFIX + 'legacy_consumers.py'),
        scope='Original historical fixtures remain byte-identical. Only the exact numeric while source, '
              'six recognized invalid scalar shapes and one numeric public source row receive explicit '
              'current successors. All callback/error/identity metadata and other public rows stay exact.'))
    for path, raw in after.items():
        (c.ROOT / path).write_bytes(raw)
    print('Legacy numeric consumers updated: one while case, six null-expression shapes, one executed public numeric row')


if __name__ == '__main__':
    main()
