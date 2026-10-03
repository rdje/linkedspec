use strict; use warnings; use LinkedSpec (); use LinkedSpec::ActionIR::AST (); use JSON::PP ();
my @values=('if(true,"hit",else("miss"))','if(false,"bad")','if(false,"bad","hit")','if(false,"bad",elseif(true,"hit"),else("miss"))','i(false,"bad",elif(true,"hit"),else("miss"))','if(false,"bad",elseif(Top,true,"hit"),else(Top,"miss"))');
my @out;
for my $value (@values) { my $source="Top:: I { return($value) }"; my ($result,$error); my $ok=eval { my $parser=LinkedSpec::Get(\$source); my $input=''; $result=$parser->(\$input); 1 }; $error="$@" unless $ok;
 push @out,{expression=>$value,substitution=>LinkedSpec::call_spec_handler_subst('Top',"return($value)"),ast=>LinkedSpec::ActionIR::AST::parse_action_expr($value),value=>$result,error=>$error}; }
print JSON::PP->new->canonical->pretty->encode(\@out);
