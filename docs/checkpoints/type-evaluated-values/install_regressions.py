"""Add recurring integration cases to the existing canonically selected callable suite."""
import json
import subprocess
import common as c

old = json.loads((c.ROOT / c.OLD_CLAIM).read_bytes())
assert old['claims'][0]['durability']['mode'] == 'historical'
assert old['claims'][0]['durability']['revision'] == c.BASE
path = 't/callable_codeblock_literal_contract.t'
before = c.read(path)
assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == c.decode(before['base64'])
source = c.decode(before['base64'])
needle = b'\ndone_testing();\n'
assert source.count(needle) == 1
addition = r'''
subtest 'constructed values and callable arguments retain evaluated values' => sub {
    my $fixture_path = File::Spec->catfile(
        $repo_root, 'tests', 'evaluated-values', 'cases.json',
    );
    open my $fixture_fh, '<:raw', $fixture_path
        or die "Could not read $fixture_path: $!";
    my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fixture_fh> });
    close $fixture_fh or die "Could not close $fixture_path: $!";
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $index = 0;
    foreach my $case (@{$fixture->{cases}}) {
        my $package = 'EvaluatedValueOrder' . $index++;
        subtest $case->{id} => sub {
            my $source = ($case->{functions} // '')
                . "Top: /x/\n I { $case->{body} }\n";
            my ($actual, $context) = run_spec_with_context($source, 'x');
            is($json->encode($actual), $json->encode($case->{expected}),
                'native values and primitive kinds match the independent expectation');
            ok(!defined($context->{last_error}), 'native execution has no runtime error');

            my $emitted = eval {
                LinkedSpec::emit_generated_source(
                    \$source, source_identity => 'evaluated-value-order.spec',
                );
            };
            ok(defined($emitted) && length($emitted), 'independent parser source emits');
            diag($@) if $@;
            my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
            ok($loaded, 'independently emitted parser source loads');
            diag($@) if $@;
            return unless $loaded;
            my $input = 'x';
            my $generated;
            my $ok = eval {
                no strict 'refs';
                my $function = $package . '::Execute';
                $generated = &{$function}(\$input);
                1;
            };
            ok($ok, 'independently emitted parser executes without an error');
            diag($@) unless $ok;
            is($json->encode($generated), $json->encode($case->{expected}),
                'generated values and primitive kinds match the independent expectation');
        };
    }
};
'''
after = source.replace(needle, addition.encode() + needle, 1)
c.write_new(c.PREFIX + 'regression-inputs.json.gz', dict(before=before,
    after=dict(base64=c.encode(after), sha256=c.sha(after), mode=before['mode']),
    fixture=c.read('tests/evaluated-values/cases.json'),
    producer=c.read(c.PREFIX + 'install_regressions.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Existing selected suite receives one integration subtest before done_testing. No canonical '
          'selection/fixture-admission machinery is changed. Initial impact data remains immutable.'), packed=True)
(c.ROOT / path).write_bytes(after)
print('Recurring evaluated-value regressions installed in the already selected callable suite')
