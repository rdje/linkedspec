use strict;
use warnings;
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my $json = JSON::PP->new->canonical->pretty;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0-';
open my $input, '<', $prefix . 'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$input> });
close $input or die $!;
my @aliases;
for my $id (qw(condition_raw while_raw)) {
    my ($case) = grep { $_->{id} eq $id } @$cases;
    die 'case missing' unless $case;
    my ($action) = $case->{source} =~ /\bI\s*\{(.*)\}\s*$/s;
    my $ast = LinkedSpec::ActionIR::AST::parse_action_block($action);
    my $control = $ast->{statements}[1]{expr};
    my $condition = $control->{condition};
    my $argument = $control->{args}[0];
    die 'control condition missing' unless ref($condition) eq 'HASH' && ref($argument) eq 'HASH';
    push @aliases, {id => $id, source => $case->{source}, action => $action,
        shared_reference => refaddr($condition) == refaddr($argument) ? 1 : 0,
        condition => $condition, argument => $argument};
}
my $repeated_source = 'i=i+1; i=i+1';
my $repeated = LinkedSpec::ActionIR::AST::parse_action_block($repeated_source);
my @raw = map { $_->{expr}{value} } @{$repeated->{statements}};
die 'two repeated assignments required' unless @raw == 2;
print $json->encode({aliases => \@aliases, repeated_source => $repeated_source,
    repeated_raw => \@raw, repeated_distinct_references => refaddr($raw[0]) != refaddr($raw[1]) ? 1 : 0,
    limits => 'Two measured control sources and one extra AST-only action fragment; no additional native/fresh route.'});
