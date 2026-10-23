use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
my @rows;
for my $target ('segment', 'rhs') {
 my $record = LinkedSpec::ActionIR::AST::parse_action_expr('{|| document[key()][key()] = rhs() }');
 my $write = $record->{body_ast}{statements}[0]{expr};
 if ($target eq 'rhs') { $write->{value} = {} }
 else { $write->{segments}[1]{expression} = {} }
 my ($document, $seen) = ({}, '');
 my $key = LinkedSpec::ActionIR::AST::parse_action_expr('{|| seen = cat(seen,"k"); return("x") }');
 my $rhs = LinkedSpec::ActionIR::AST::parse_action_expr('{|| seen = cat(seen,"r"); return(2) }');
 my $error;
 eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {
  document => \$document, seen => \$seen, key => \$key, rhs => \$rhs,
 }, 'malformed-operand'); 1 } or $error = $@;
 push @rows, {target => $target, seen => $seen, document => $document,
  class => ref($error), code => ref($error) ? $error->{code} : undef};
}
print JSON::PP->new->canonical->encode(\@rows), "\n";
