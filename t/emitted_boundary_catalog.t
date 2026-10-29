use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.37. Separate-process emitted proof is retained
# by the owning intake; this ordinary test uses isolated package evaluation.
my $json = JSON::PP->new->canonical->allow_nonref->utf8;
open my $file, '<:raw', 'tests/fixtures/emitted_boundary_catalog.json' or die $!;
my $text; { local $/; $text = <$file>; }
close $file or die $!;
my $fixtures = $json->decode($text);
my $sequence = 0;

for my $fixture (@$fixtures) {
    subtest $fixture->{name} => sub {
        my $source = $fixture->{source};
        my %context;
        my $native = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        ok(ref($native) eq 'CODE', 'native parser builds') or return;
        my $emitted = LinkedSpec::emit_generated_source(
            \$source, source_identity => 'perl-boundary-catalog.spec',
        );
        my $package = 'LinkedSpec::BoundaryCatalogTest'.++$sequence;
        my $loaded = eval "package $package;\n$emitted\n1;";
        my $load_error = $@;
        ok($loaded, 'emitted parser loads in an arbitrary package') or do {
            diag($load_error);
            return;
        };
        my $execute = $package->can('Execute');
        ok(ref($execute) eq 'CODE', 'published handler dispatch remains callable');
        my $metadata = $package->can('LinkedSpecGeneratedMetadata')->();
        is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'contract unchanged');
        is($metadata->{format_version}, 2, 'format unchanged');
        is_deeply([sort keys %$metadata], [sort qw(
            contract_id format_version source_identity plan entry_rule_contract entry_rules
        )], 'regex catalog remains private');
        for my $row (@{$metadata->{plan}}) {
            is_deeply([sort keys %$row], [qw(family label)], 'plan remains minimal');
        }
        for my $case (@{$fixture->{cases}}) {
            for my $route (['native', $native], ['emitted', $execute]) {
                my ($label, $parser) = @$route;
                my $input = $case->{input};
                pos($input) = 0;
                my $value = eval { $parser->(\$input) };
                my $error = $@;
                ok(!$error, "$label executes without error") or diag("$error");
                is($json->encode($value), $json->encode($case->{expected}),
                    "$label exact value and String kind");
                is(pos($input), $case->{expected_cursor}, "$label non-consuming boundary cursor");
            }
            ok(!defined($context{last_error}), 'native helper retains successful error state');
        }
    };
}
done_testing;
