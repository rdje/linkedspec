use strict; use warnings; use LinkedSpec (); use LinkedSpec::ActionIR::AST (); use JSON::PP ();
my $json=JSON::PP->new->canonical->pretty;
open my $in,'<','docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4-canonical-cases.json' or die $!;
my $cases=$json->decode(do {local $/;<$in>}); close $in or die $!;
print $json->encode([map { {id=>$_->{id},action=>$_->{action},substitution=>LinkedSpec::call_spec_handler_subst('Top',$_->{action}),ast=>LinkedSpec::ActionIR::AST::parse_action_expr($_->{action})} } @$cases]);
