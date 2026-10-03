use strict; use warnings; use LinkedSpec (); use LinkedSpec::ActionIR::AST (); use JSON::PP ();
my @exprs=(q{while(false) { "bad" }},q{while(matches(text,/^x{0,2}$/)) { text=cat(text,"x") }},q{while(matches(effects,/^x{0,9999}$/)) { effects=cat(effects,"x") }},q{while(true) { effects=cat(effects,"x") }});
print JSON::PP->new->canonical->pretty->encode([map { {expression=>$_,substitution=>LinkedSpec::call_spec_handler_subst('Top',$_),ast=>LinkedSpec::ActionIR::AST::parse_action_expr($_)} } @exprs]);
