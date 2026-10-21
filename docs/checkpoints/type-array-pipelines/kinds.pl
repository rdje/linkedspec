use strict;
use warnings;
use B ();
use Storable qw(dclone);
use JSON::PP ();
use LinkedSpec ();
use Scalar::Util qw(blessed reftype);
sub data {
    my ($value) = @_;
    return $value unless ref($value);
    return $value if blessed($value) && $value->isa('JSON::PP::Boolean');
    return [map { data($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map { $_ => data($value->{$_}) } keys %$value}
        if (reftype($value) // '') eq 'HASH';
    return "$value";
}
local $/;
my $plan = JSON::PP->new->decode(<STDIN>);
my @rows;
my $index = 0;
for my $case (@{$plan->{cases}}) {
    my $source = "Top: /x/\n I { $case->{body} }\n";
    for my $route (qw(native generated)) {
        my ($value, %ctx, $error, @warnings);
        my $ok;
        my $diagnostic = '';
        open my $fh, '>', \$diagnostic or die $!;
        {
            local *STDOUT = $fh;
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            $ok = eval {
                my $input = 'x';
                if ($route eq 'native') {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
                    $value = $parser->(\$input);
                } else {
                    my $emitted = LinkedSpec::emit_generated_source(\$source);
                    my $package = 'PipelineKinds' . $index++;
                    eval "package $package; $emitted; 1" or die $@;
                    no strict 'refs';
                    $value = &{$package . '::Execute'}(\$input);
                }
                1;
            };
            $error = "$@" unless $ok;
        }
        my $selected = $value;
        $selected = $selected->[$_] for @{$case->{path} || []};
        my $copy = ref($selected) ? dclone($selected) : $selected;
        my $flags = sub {
            my ($array) = @_;
            return [] unless ref($array) eq 'ARRAY';
            return [map {
                my $bits = B::svref_2object(\$_)->FLAGS;
                {pOK => ($bits & B::SVp_POK()) ? 1 : 0,
                 iOK => ($bits & B::SVp_IOK()) ? 1 : 0,
                 nOK => ($bits & B::SVp_NOK()) ? 1 : 0}
            } @$array];
        };
        push @rows, {id => $case->{id}, route => $route, flags => $flags->($selected),
            cloned_flags => $flags->($copy), value => $value, cloned_value => $copy,
            completed => $ok ? JSON::PP::true : JSON::PP::false, error => $error,
            runtime_error => data($ctx{last_error}), warnings => \@warnings, stdout => $diagnostic};
    }
}
print JSON::PP->new->canonical->allow_nonref->encode({rows => \@rows,
    perl => "$^V", json => $JSON::PP::VERSION, storable => $Storable::VERSION}), "\n";
