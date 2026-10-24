use strict;
use warnings;
use B ();
use Config ();
use JSON::PP ();

sub flags {
    my ($value) = @_;
    my $bits = B::svref_2object(\$value)->FLAGS;
    return {integer => ($bits & B::SVp_IOK()) ? 1 : 0,
        floating => ($bits & B::SVp_NOK()) ? 1 : 0,
        string => ($bits & B::SVp_POK()) ? 1 : 0};
}

my $json = JSON::PP->new->canonical->allow_nonref;
my @rows;
for my $case (
    ['negative_whole', -1.0, '-1.0'],
    ['positive_whole', 1.0, '1.0'],
    ['positive_zero', 0.0, '0.0'],
    ['negative_zero', -0.0, '-0.0'],
    ['negative_fraction', -1.25, '-1.25'],
    ['positive_fraction', 1.25, '1.25'],
    ['large_whole', 9007199254740992.0, '9007199254740992.0'],
    ['rounded_whole', 9007199254740993.0, '9007199254740993.0'],
    ['large_fraction', 1000000000000000.5, '1000000000000000.5'],
    ['integer_control', -1, '-1'],
) {
    my ($id, $native, $spelling) = @$case;
    my $native_flags = flags($native);
    my $transport = $json->encode($native);
    my $decoded = $json->decode($transport);
    my %values = (serialized_value => 0 + $decoded,
        plus_floating_zero => $decoded + 0.0,
        times_floating_one => $decoded * 1.0,
        source_coercion => 0 + $spelling);
    my %observations;
    for my $name (sort keys %values) {
        my $value = $values{$name};
        my $observed_flags = flags($value);
        $observations{$name} = {flags => $observed_flags, value => $value,
            hexadecimal => sprintf('%a', $value)};
    }
    push @rows, {id => $id, source => $spelling, native_flags => $native_flags,
        native_hexadecimal => sprintf('%a', $native), wire => $transport, variants => \%observations};
}
print $json->encode({perl_version => "$^V", nvtype => $Config::Config{nvtype},
    nvsize => $Config::Config{nvsize}, ivsize => $Config::Config{ivsize}, rows => \@rows}), "\n";
