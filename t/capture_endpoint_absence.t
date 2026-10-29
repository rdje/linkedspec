use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.40.1. Separate-process execution is retained
# by the intake; this normal consumer evaluates each arbitrary package locally.
my $json = JSON::PP->new->canonical->allow_nonref->utf8;
open my $fh, '<:raw', 'tests/fixtures/capture_endpoint_absence.json' or die $!;
my $text; { local $/; $text = <$fh>; }
close $fh or die $!;
my $cases = $json->decode($text);
my $number = 0;
for my $case (@$cases) {
    subtest $case->{name} => sub {
        my $source = $case->{source};
        my %context;
        my $native = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        ok(ref($native) eq 'CODE', 'native parser builds') or return;
        my $emitted = LinkedSpec::emit_generated_source(\$source,
            source_identity => 'capture-endpoint-absence.spec');
        my $package = 'LinkedSpec::CaptureEndpointTest' . ++$number;
        my $loaded = eval "package $package;\n$emitted\n1;";
        my $load_error = $@;
        ok($loaded, 'emitted source loads') or do { diag("$load_error"); return };
        my $execute = $package->can('Execute');
        my $metadata = $package->can('LinkedSpecGeneratedMetadata')->();
        is_deeply([sort keys %$metadata], [sort qw(
            contract_id format_version source_identity plan entry_rule_contract entry_rules
        )], 'public metadata remains minimal');
        is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'v2 contract unchanged');
        is($metadata->{format_version}, 2, 'format unchanged');
        for my $route (['native', $native], ['emitted clean', $execute], ['emitted seeded', $execute]) {
            my ($label, $parser) = @$route;
            my $seeded = $label eq 'emitted seeded';
            no strict 'refs';
            local ${"${package}::LMATCH"} = $seeded ? 'zz' : undef;
            local ${"${package}::LSPOS"} = $seeded ? 4 : undef;
            my @warnings;
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            my $input = $case->{input};
            pos($input) = $case->{entry_cursor};
            my $value = eval { $parser->(\$input) };
            my $error = $@;
            ok(!$error, "$label has no execution error") or diag("$error");
            is($json->encode($value), $json->encode($case->{expected}),
                "$label preserves exact value kinds, absence, zero and take effects");
            is(pos($input), $case->{expected_cursor}, "$label preserves live cursor");
            is_deeply(\@warnings, [], "$label has no uninitialized-state warning");
            ok(!defined($context{last_error}), 'native error state remains clear')
                if $label eq 'native';
        }
    };
}
done_testing;
