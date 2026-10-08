use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-corrected-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->utf8->decode(do { local $/; <$file> }); close $file or die $!;

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my $source = $case->{source};
        my (%context, $dump, $value);
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
            dump_parser_source => 1, parser_source_ref => \$dump,
            generated_source_identity => $case->{id}.'.spec');
        my $input = ''; my $ran = eval { $value = $parser->(\$input); 1 };
        ok($ran && !$context{last_error}, 'native execution succeeds');
        is_deeply($value, $case->{expected_value}, 'native independent literal/value oracle');
        my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => $case->{id}.'.spec');
        is($dump, $emitted, 'public dump is independently emitted source');
        my $package = 'ReplacementDiagnosis::'.$case->{id};
        my $loaded = eval "package $package; $emitted\n1;";
        ok($loaded, 'emitted source independently loads');
        no strict 'refs';
        $input = ''; $value = undef;
        $ran = $loaded ? eval { $value = &{$package.'::Execute'}(\$input); 1 } : 0;
        ok($ran, 'independent emitted execution succeeds');
        is_deeply($value, $case->{expected_value}, 'fresh independent literal/value oracle');
    };
}

done_testing;
