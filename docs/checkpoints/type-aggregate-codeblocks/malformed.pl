use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
my $record = LinkedSpec::ActionIR::AST::parse_action_expr('{|| return(items.sum()) }');
my $chain = $record->{body_ast}{statements}[0]{expr}{args}[0];
die 'Expected fluent fixture' unless $chain->{kind} eq 'fluent_chain' && @{$chain->{calls}} == 1;
$chain->{calls}[0] = 'not-a-call';
my $items = [3,1,8];
my $error;
eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {items => \$items}, 'malformed'); 1 }
    or $error = $@;
my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
print JSON::PP->new->canonical->encode({class => ref($error),
    $typed ? (fields => {%$error}) : (text => "$error"),
    items => $items, loaded => $INC{'LinkedSpec/CodeblockRuntime.pm'}}), "\n";
