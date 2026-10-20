use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::Numeric ();

my $plan = do { local $/; JSON::PP->new->decode(<STDIN>) };
my $json = JSON::PP->new->canonical->allow_nonref;
my @rows;
foreach my $case (@{$plan->{cases}}) {
    my (@warnings, $value, $error);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $execute = eval 'sub { ' . $plan->{setup} . '; ' . $case->{source} . ' }';
    if (ref($execute) eq 'CODE') {
        my $ok = eval { $value = $execute->(); 1 };
        $error = 'execute: ' . $@ unless $ok;
    } else {
        $error = 'compile: ' . $@;
    }
    my $observation = defined($error) ? {error => $error, warnings => \@warnings}
                                    : {value => $value, warnings => \@warnings};
    push @rows, {id => $case->{id}, observation => $observation, json => $json->encode($observation)};
}
print $json->encode({rows => \@rows, numeric_module => $INC{'LinkedSpec/Numeric.pm'}}), "\n";
