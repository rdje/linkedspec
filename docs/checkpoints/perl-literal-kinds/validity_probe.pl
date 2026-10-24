use strict;
use warnings;
use B ();
use JSON::PP ();
use Storable qw(dclone);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();

sub bits {
    my ($value) = @_;
    my $flags = B::svref_2object(\$value)->FLAGS;
    return {public => [map { ($flags & $_) ? 1 : 0 } (B::SVf_IOK(), B::SVf_NOK(), B::SVf_POK())],
        private => [map { ($flags & $_) ? 1 : 0 } (B::SVp_IOK(), B::SVp_NOK(), B::SVp_POK())]};
}

my $node = LinkedSpec::ActionIR::AST::parse_action_expr('1.0');
my $evaluated = LinkedSpec::CodeblockRuntime::_eval_expr($node, {});
my $fresh = 0 + substr($node->{source}, 0);
my @numbers = (-1.0, 0.0, 1.25);
my @before = map { bits($_) } @numbers;
my $clone = dclone(\@numbers);
my @after = map { bits($_) } @numbers;
my @cloned = map { bits($_) } @$clone;

my ($chosen, $items, $seen) = (undef, [10,20,30], '');
my $record = LinkedSpec::ActionIR::AST::parse_action_expr('{|| chosen=1.0; items[chosen]=rhs() }');
my $rhs = LinkedSpec::ActionIR::AST::parse_action_expr('{|| seen=cat(seen,"r"); return(99) }');
my (@kinds, $error);
my $original_kind = \&LinkedSpec::BindingRuntime::_runtime_kind;
{
    no warnings 'redefine';
    local *LinkedSpec::BindingRuntime::_runtime_kind = sub {
        my $before = bits($_[0]);
        my $kind = $original_kind->(@_);
        push @kinds, {before => $before, result => $kind};
        return $kind;
    };
    eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {
        chosen => \$chosen, items => \$items, seen => \$seen, rhs => \$rhs,
    }, 'validity-delegate'); 1 } or $error = $@;
}
my $chosen_flags = bits($chosen);

my @public;
my $serial = 0;
for my $body (
    'items=[10,20,30]; cb={|| index=num_sub(-1.5,-1); return([index,items[index]]) }; return(cb())',
    'items=[10,20,30]; cb={|index| return([index,items[index]]) }; return(cb(num_sub(-1.5,-1)))',
) {
    my $source = "Top: /x/\n I { $body }\n";
    for my $route (qw(native generated)) {
        my ($value, %context, $dump, $emitted);
        if ($route eq 'native') {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
                dump_parser_source => 1, parser_source_ref => \$dump);
            die 'No native parser' unless ref($parser) eq 'CODE';
            my $input = 'x';
            $value = $parser->(\$input);
        } else {
            $emitted = LinkedSpec::emit_generated_source(\$source,
                source_identity => 'literal-validity-diagnosis.spec');
            my $package = 'LiteralValidityGenerated' . $serial++;
            eval "package $package; $emitted; 1" or die $@;
            my $input = 'x';
            no strict 'refs';
            $value = &{"${package}::Execute"}(\$input);
        }
        die 'Unexpected runtime failure' if $context{last_error};
        push @public, {body => $body, route => $route, value => $value,
            index_flags => bits($value->[0]), defined($dump) ? (dump => $dump) : (),
            defined($emitted) ? (emitted => $emitted) : ()};
    }
}
print JSON::PP->new->canonical->allow_nonref->encode({perl_version => "$^V", inc => \%INC,
    parsed_source => bits($node->{source}), evaluated => bits($evaluated), fresh => bits($fresh),
    copies => {before => \@before, after => \@after, cloned => \@cloned},
    delegated_kinds => \@kinds, chosen => $chosen_flags, receiver => $items, rhs_effects => $seen,
    error => defined($error) ? "$error" : undef, public => \@public}), "\n";
