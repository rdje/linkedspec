use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::UnicodeCaseMapping ();
use LinkedSpec::SourceLocation::Runtime ();

my $json = JSON::PP->new->canonical->allow_nonref;
my $plan = $json->decode(do { local $/; <STDIN> });
my @rows;
for my $case (@{$plan->{cases}}) {
    my ($value, $error, $code);
    if (exists $case->{manual_expected_perl}) {
        $value = eval $case->{manual_expected_perl};
        $error = $@ if $@;
    }
    if (exists $case->{historical_expected_expr}) {
        $code = eval $case->{historical_expected_expr};
        $error = "expected source: $@" if $@;
        if (!$error) {
            $code = '+' . $code if $code =~ /^\s*\{/;
            my $run = eval 'sub { ' . $case->{setup} . '; ' . $code . ' }';
            if (ref($run) ne 'CODE') {
                $error = "compile: $@";
            } else {
                my $historical;
                my $ok = eval { $historical = $run->(); 1 };
                if (!$ok) {
                    $error = "execute: $@";
                } elsif (exists $case->{manual_expected_perl}
                    && $json->encode($historical) ne $json->encode($value)) {
                    $error = "manual expectation disagrees with accepted historical source";
                } else {
                    $value = $historical;
                }
            }
        }
    }
    push @rows, {
        label => $case->{label},
        expected_json => $error ? undef : $json->encode({ value => $value }),
        error => $error,
    };
}
print $json->encode({ rows => \@rows, perl => "$^V", inc => \%INC }), "\n";
my $errors = grep { defined $_->{error} } @rows;
exit($errors ? 1 : 0);
