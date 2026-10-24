use strict;
use warnings;
use B ();
use JSON::PP ();
use Storable qw(dclone);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();

sub snapshot {
    my ($value) = @_;
    return {kind => 'null'} unless defined $value;
    return {kind => 'boolean'} if JSON::PP::is_bool($value);
    return {kind => 'array', items => [map { snapshot($_) } @$value]} if ref($value) eq 'ARRAY';
    my $bits = B::svref_2object(\$value)->FLAGS;
    return {flags => [map { ($bits & $_) ? 1 : 0 } (B::SVp_IOK(), B::SVp_NOK(), B::SVp_POK())],
        value => $value};
}

my $node = LinkedSpec::ActionIR::AST::parse_action_expr('1.0');
my $source_flags = snapshot($node->{source});
my $cached = 0 + $node->{source};
my $fresh = 0 + substr($node->{source}, 0);
my $value = [[-1.0, 0.0, 1.25, JSON::PP::false]];
my %copies = (
    original => snapshot($value),
    storable => snapshot(dclone($value)),
    codeblock => snapshot(LinkedSpec::CodeblockRuntime::_copy_value($value)),
    binding => snapshot(LinkedSpec::BindingRuntime::_clone_value($value)),
);
my @programs = (
    'items=[10,20,30]; cb={|| index=num_sub(-1.5,-1); return([index,items[index]]) }; return(cb())',
    'items=[10,20,30]; cb={|index| return([index,items[index]]) }; return(cb(num_sub(-1.5,-1)))',
);
my (@public, $serial);
for my $body (@programs) {
    my $source = "Top: /x/\n I { $body }\n";
    for my $route (qw(native generated)) {
        my ($result, %context, $dump, $emitted);
        if ($route eq 'native') {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
                dump_parser_source => 1, parser_source_ref => \$dump);
            die 'No parser' unless ref($parser) eq 'CODE';
            my $input = 'x';
            $result = $parser->(\$input);
        } else {
            $emitted = LinkedSpec::emit_generated_source(\$source,
                source_identity => 'literal-copy-diagnosis.spec');
            my $package = 'LiteralCopyDiagnosis' . $serial++;
            eval "package $package; $emitted; 1" or die $@;
            my $input = 'x';
            no strict 'refs';
            $result = &{"${package}::Execute"}(\$input);
        }
        die 'Unexpected runtime error' if $context{last_error};
        push @public, {body => $body, route => $route, result => $result,
            flags => snapshot($result), defined($dump) ? (dump => $dump) : (),
            defined($emitted) ? (emitted => $emitted) : ()};
    }
}
print JSON::PP->new->canonical->allow_nonref->encode({source => $source_flags,
    cached_conversion => snapshot($cached), fresh_conversion => snapshot($fresh),
    copies => \%copies, public => \@public, inc => \%INC}), "\n";
