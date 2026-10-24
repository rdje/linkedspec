use strict;
use warnings;
use B ();
use JSON::PP ();
use LinkedSpec ();

my @rows;
my $index = 0;
for my $body (
    'return(1000000000000000.5)',
    'cb={|| return(1000000000000000.5) }; return(cb())',
    'return(-1.0)',
    'cb={|| return(-1.0) }; return(cb())',
) {
    my $source = "Top: /x/\n I { $body }\n";
    for my $route (qw(native generated)) {
        my (%context, $dump, $value, $emitted);
        if ($route eq 'native') {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
                dump_parser_source => 1, parser_source_ref => \$dump);
            die 'Native parser did not build' unless ref($parser) eq 'CODE';
            my $input = 'x';
            $value = $parser->(\$input);
        } else {
            $emitted = LinkedSpec::emit_generated_source(\$source,
                source_identity => 'deferred-literal-precision.spec');
            my $package = 'LiteralPrecisionGenerated' . $index++;
            eval "package $package; $emitted; 1" or die $@;
            my $input = 'x';
            no strict 'refs';
            $value = &{"${package}::Execute"}(\$input);
        }
        die 'Unexpected parser failure' if $context{last_error};
        my $bits = B::svref_2object(\$value)->FLAGS;
        my $flags = {integer => ($bits & B::SVp_IOK()) ? 1 : 0,
            floating => ($bits & B::SVp_NOK()) ? 1 : 0,
            string => ($bits & B::SVp_POK()) ? 1 : 0};
        my $hexadecimal = sprintf('%a', $value);
        push @rows, {body => $body, route => $route, flags => $flags,
            hexadecimal => $hexadecimal, value => $value, source => $source,
            defined($dump) ? (dump => $dump) : (), defined($emitted) ? (emitted => $emitted) : ()};
    }
}
print JSON::PP->new->canonical->allow_nonref->encode({rows => \@rows, inc => \%INC}), "\n";
