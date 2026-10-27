use strict;use warnings;use JSON::PP ();use LinkedSpec ();use LinkedSpec::ActionIR::AST::Parser ();
my @cases=(
 [value=>q{meta={"old":1};order="";result=set_key(meta,{order=cat(order,"K");"k"},{order=cat(order,"V");2});return([result,meta,order])}],
 [fluent=>q{meta={"old":1};order="";result=meta.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");2});return([result,meta,order])}],
 [statement=>q{meta={"old":1};order="";set_key(meta,{order=cat(order,"K");"k"},{order=cat(order,"V");2});return([meta,order])}],
 [key_snapshot=>q{meta={"old":1};key="before";result=set_key(meta,key,{key="after";2});return([result,key])}],
);
my @out=map{{label=>$_->[0],action=>$_->[1],ast=>LinkedSpec::ActionIR::AST::Parser::parse_action_block($_->[1]),substitution=>LinkedSpec::call_spec_handler_subst('Top',$_->[1])}}@cases;
print JSON::PP->new->canonical->encode({scope=>'four authored set_key block/order source distinctions; not a completeness claim',cases=>\@out}),"\n";
