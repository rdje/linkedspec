use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical;
open my $fh, '<', 'tests/fixtures/sorted_values_scalar_isolation.json' or die $!;
my $text;
{ local $/; $text = <$fh> }
my $sequence = 0;

for my $case (@{$json->decode($text)}) {
    subtest $case->{name} => sub {
        my $source = $case->{source};
        my (%context, @warnings);
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        my $native = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        ok(ref($native) eq 'CODE', 'native parser builds') or return;

        my $emitted = LinkedSpec::emit_generated_source(
            \$source, source_identity => 'sorted-values-scalar-isolation.spec',
        );
        my $package = 'LinkedSpec::SortedValuesIsolation'.++$sequence;
        my $loaded = eval "package $package; $emitted; 1";
        ok($loaded, 'fresh emitted source loads') or do { diag($@); return };

        for my $seed (0, 1) {
            no strict 'refs';
            # Numeric symbolic hashes resolve in main; ordinary names use the module package.
            local %{'main::3'} = $seed ? (probe => 'HOST_MAIN') : ();
            local %{$package.'::3'} = $seed ? (probe => 'HOST_PACKAGE') : ();
            local %{'main::probe_name'} = $seed ? (probe => 'HOST_MAIN_NAME') : ();
            local %{$package.'::probe_name'} = $seed ? (probe => 'HOST_PACKAGE_NAME') : ();
            local %{$package.'::n'} = $seed ? (probe => 'HOST_N') : ();
            local %{$package.'::meta'} = $seed ? (probe => 'HOST_META') : ();

            for my $route (['native', $native], ['fresh', $package->can('Execute')]) {
                my ($name, $parser) = @$route;
                my $input = $case->{input};
                my $value = eval { $parser->(\$input) };
                is("$@", '', "$name seed$seed has no thrown error");
                is($json->encode($value), $json->encode($case->{expected}),
                    "$name seed$seed uses only the evaluated DSL value");
                is(pos($input), $case->{expected_cursor}, "$name seed$seed preserves cursor");
                is($context{last_error}, undef, "$name seed$seed leaves native context clear");
            }
        }
        is_deeply(\@warnings, [], 'all build/load/run channels remain warning-free');
    };
}

subtest 'legitimate legacy Hash binding remains supported' => sub {
    my $body = LinkedSpec::call_spec_handler_subst('Top', 'return(sorted_values(meta))');
    my $run = eval 'sub { my %meta=(b=>"B",a=>"A");'.$body.' }';
    ok(ref($run) eq 'CODE', 'compatibility Hash source compiles') or do { diag($@); return };
    is_deeply($run->(), ['A','B'], 'legacy typed Hash storage retains its ordered values');
};
done_testing;
