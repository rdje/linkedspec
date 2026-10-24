use strict;
use warnings;
use utf8;
use B ();
use JSON::PP ();
use Scalar::Util qw(blessed reftype);
use LinkedSpec ();

sub data {
    my ($value) = @_;
    return $value unless ref($value);
    return $value if blessed($value) && $value->isa('JSON::PP::Boolean');
    return [map { data($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map { $_ => data($value->{$_}) } keys %$value}
        if (reftype($value) // '') eq 'HASH';
    die 'Unrecognized observed reference: ' . ref($value);
}

sub scalar_flags {
    my ($value) = @_;
    return {kind => 'null'} unless defined $value;
    return {kind => 'boolean'} if JSON::PP::is_bool($value);
    return {kind => 'array', items => [map { scalar_flags($_) } @$value]}
        if (reftype($value) // '') eq 'ARRAY';
    return {kind => 'harray', entries => {map { $_ => scalar_flags($value->{$_}) } keys %$value}}
        if (reftype($value) // '') eq 'HASH';
    return {kind => ref($value)} if ref($value);
    my $flags = B::svref_2object(\$value)->FLAGS;
    return {kind => 'scalar', integer_flag => ($flags & B::SVp_IOK()) ? 1 : 0,
        float_flag => ($flags & B::SVp_NOK()) ? 1 : 0,
        string_flag => ($flags & B::SVp_POK()) ? 1 : 0};
}

sub detail {
    my ($error) = @_;
    return undef unless defined($error) && length("$error");
    return {class => ref($error), fields => data($error)}
        if (reftype($error) // '') eq 'HASH';
    return {class => '', text => "$error"};
}

my $route = shift @ARGV;
die "Expected descriptor, native or generated route\n"
    unless defined($route) && $route =~ /\A(?:descriptor|native|generated)\z/ && !@ARGV;
local $/;
my $plan = JSON::PP->new->utf8->decode(<STDIN>);
my @rows;
my $index = 0;
for my $case (@{$plan->{cases}}) {
    my $source = $case->{source};
    die "Case source is missing\n" unless defined($source) && !ref($source);
    my (@warnings, %context, $value, $exception, $emitted, $diagnostics, $dump);
    open my $capture, '>', \$diagnostics or die "Capture output: $!";
    {
        local *STDOUT = $capture;
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        my $ok = eval {
            if ($route eq 'descriptor') {
                my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%context);
                die "Descriptor did not build\n" unless ref($descriptor) eq 'HASH';
                my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
                $value = {map { $_ => data($metadata->{$_}) }
                    qw(canonical_action_ir_nodes canonical_action_ir_fallback_count raw_perl_dependency_count)};
            } elsif ($route eq 'native') {
                my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
                    dump_parser_source => 1, parser_source_ref => \$dump);
                die "Native parser did not build\n" unless ref($parser) eq 'CODE';
                my $input = $case->{input} // 'x';
                $value = $parser->(\$input);
            } else {
                $emitted = LinkedSpec::emit_generated_source(\$source,
                    source_identity => 'signed-array-perl.spec');
                my $package = 'SignedPerlGenerated' . $index++;
                eval "package $package; $emitted; 1" or die $@;
                my $input = $case->{input} // 'x';
                no strict 'refs';
                $value = &{$package . '::Execute'}(\$input);
            }
            1;
        };
        $exception = $@ unless $ok;
        push @rows, {
            id => $case->{id}, completed => $ok ? JSON::PP::true : JSON::PP::false,
            scalar_flags => scalar_flags($value), value => data($value),
            exception => detail($exception), last_error => data($context{last_error}),
            runtime_detail => detail($context{last_error}{detail}),
            generated_cause => (reftype($exception) // '') eq 'HASH' ? detail($exception->{detail}) : undef,
            warnings => \@warnings, stdout => $diagnostics // '',
            defined($emitted) ? (source => $emitted) : (),
            defined($dump) ? (dump => $dump) : (),
        };
    }
    close $capture or die "Close captured output: $!";
}
print JSON::PP->new->utf8->canonical->allow_nonref->encode({route => $route, rows => \@rows, inc => \%INC}), "\n";
