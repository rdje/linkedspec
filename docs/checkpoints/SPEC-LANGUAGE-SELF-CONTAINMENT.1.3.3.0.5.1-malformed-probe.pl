use strict;
use warnings;
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
my @sources=(
 '{|| if(true) { return("hit") } else { return("bad") } elseif(true) { return("bad") } }',
 '{|| if(true) { return("hit") } else { return("bad") } else { return("bad") } }',
);
print JSON::PP->new->canonical->pretty->encode({sources=>[map { {source=>$_,ast=>LinkedSpec::ActionIR::AST::parse_action_expr($_)} } @sources]});
