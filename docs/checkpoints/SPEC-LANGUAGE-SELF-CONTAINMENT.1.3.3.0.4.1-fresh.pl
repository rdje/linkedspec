use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(blessed);

my $json = JSON::PP->new->canonical;
my $request = $json->decode(do { local $/; <STDIN> });
my $emitted = $request->{emitted};
my $loaded = eval "package ComposedNormalization::Fresh; $emitted\n1;";
die "independent generated source failed to load: $@" unless $loaded;

sub detachment {
    my ($actual) = @_;
    my $mapped_before = $json->encode($actual->{mapped});
    my $original_before = $json->encode($actual->{original});
    $actual->{tree}{a} = 'actual-root-probe';
    $actual->{tree}{b}{c} = 'actual-nested-probe';
    my $mapped_ok = $json->encode($actual->{mapped}) eq $mapped_before;
    my $original_ok = $json->encode($actual->{original}) eq $original_before;
    # Deliberately alias the actual returned tree, then repeat the same predicate.
    my $aliased = { %$actual, mapped => $actual->{tree} };
    my $aliased_before = $json->encode($aliased->{mapped});
    $aliased->{tree}{b}{c} = 'actual-alias-probe';
    my $alias_rejected = $json->encode($aliased->{mapped}) ne $aliased_before;
    return {mapped_unchanged => $mapped_ok ? 1 : 0,
        original_unchanged => $original_ok ? 1 : 0,
        deliberately_aliased_control_rejected => $alias_rejected ? 1 : 0};
}

my @rows;
for my $case (@{$request->{cases}}) {
    my (@events, $value, $error, $stdout, $stderr);
    $stdout = $stderr = '';
    {
        open my $capture_out, '>', \$stdout or die $!;
        open my $capture_err, '>', \$stderr or die $!;
        local *STDOUT = $capture_out;
        local *STDERR = $capture_err;
        my $input = $case->{input};
        my $options = $case->{sink} eq 'collect' ? {
            diagnostic_sink => sub { push @events, { %{$_[0]} } },
        } : undef;
        my $ok = eval { $value = ComposedNormalization::Fresh::Execute(\$input, $options); 1 };
        $error = $@ unless $ok;
    }
    my $exit_status = blessed($error) && $error->isa('LinkedSpec::RuntimeExitNow')
        ? 0 + $error->status : undef;
    my $unexpected_error = defined($error) && !defined($exit_status) ? "$error" : undef;
    # Retain the initial typed value before mutating actual returned references.
    my $initial = $json->decode($json->encode($value));
    my $detach = ref($value) eq 'HASH' ? detachment($value) : undef;
    push @rows, {id => $case->{id}, value => $initial, events => \@events,
        stdout => $stdout, stderr => $stderr, exit_status => $exit_status,
        unexpected_error => $unexpected_error, detachment => $detach};
}
print $json->encode({emitted_sha256 => sha256_hex($emitted), rows => \@rows}), "\n";
