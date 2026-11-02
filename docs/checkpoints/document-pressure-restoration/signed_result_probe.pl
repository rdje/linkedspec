use strict;
use warnings;
use utf8;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->utf8->canonical->allow_nonref;
open my $fh, '<:raw', 'tests/numeric-codeblocks/signed-array-selectors.json' or die $!;
my $plan = do { local $/; $json->decode(<$fh>) };
my @results;
my $serial = 0;
for my $case (@{$plan->{cases}}) {
    next unless $case->{id} =~ m{^control/result_path_};
    my $source = $case->{source};
    my (%context, $native, $native_error, $native_output);
    {
        open my $capture, '>', \$native_output or die $!;
        local *STDOUT = $capture;
        eval {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
            die 'No native parser' unless ref($parser) eq 'CODE';
            my $input = $case->{input} // 'x';
            $native = $parser->(\$input);
            1;
        } or $native_error = "$@";
    }
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
        source_identity => 'signed-array-perl.spec') };
    my $emit_error = "$@";
    my $package = 'SignedResultProbe' . $serial++;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    my $load_error = "$@";
    my ($generated, $execute_error);
    if ($loaded) {
        eval {
            no strict 'refs';
            my $input = $case->{input} // 'x';
            $generated = &{$package . '::Execute'}(\$input);
            1;
        } or $execute_error = "$@";
    }
    push @results, {case => $case, native => $native,
        native_error => $native_error, native_output => $native_output,
        emitted => $emitted, emit_error => $emit_error,
        loaded => $loaded ? JSON::PP::true : JSON::PP::false,
        load_error => $load_error, generated => $generated,
        execute_error => $execute_error};
}
print $json->encode(\@results), "\n";
