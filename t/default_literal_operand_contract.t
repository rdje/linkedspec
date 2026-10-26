use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
my $source=<<'SPEC';
Top:: I {
 number=7;
 direct=coalesce_nonempty("",{"b":"y","a":"x"});
 plain=coalesce(undef,{"items":[number,{"n":number}],"flag":false});
 nested=coalesce_nonempty("",[{"n":number},number]);
 empty=coalesce_nonempty("",{}, {"late":1});
 selected=[].join_values(",").coalesce_nonempty({"b":"y","a":"x"}).sorted_values().join_values(":").uppercase();
 order="";
 effected=coalesce_nonempty({order=cat(order,"S");""},{order=cat(order,"D");{"n":number}},{order=cat(order,"L");{"late":1}});
 skipped=coalesce({order=cat(order,"K");0},{order=cat(order,"L");{"late":1}});
 zero=coalesce_nonempty("",0,{"late":1}); false_value=coalesce_nonempty("",false,{"late":1});
 return([direct,plain,nested,empty,selected,effected,skipped,zero,false_value,order,number]);
}
SPEC
my $json=JSON::PP->new->canonical;
my $expected=$json->decode('[{"a":"x","b":"y"},{"flag":false,"items":[7,{"n":7}]},[{"n":7},7],{},"X:Y",{"n":7},0,0,false,"SDK",7]');
my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=$parser->(\$input);
is($context{last_error},undef,'native lazy literal operands have no handler error') or diag($json->encode($context{last_error}));
is($json->encode($actual),$json->encode($expected),'native Hash/nested operands retain values, kinds and lazy order');
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'default-literal-operands.spec');
my $loaded=eval "package LinkedSpec::DefaultLiteralOperandGenerated; $emitted; 1";
ok($loaded,'fresh literal-default parser compiles') or diag($@);
if($loaded){my $fresh_input='x';my $fresh=eval {LinkedSpec::DefaultLiteralOperandGenerated::Execute(\$fresh_input)};
 is("$@",'','fresh literal-default execution has no thrown error');
 is($json->encode($fresh),$json->encode($expected),'fresh Hash/nested operands retain values, kinds and lazy order');}
my $retired=LinkedSpec::call_spec_handler_subst('Top',q{return(coalesce_nonempty("",{"key" => 7}))});
like($retired,qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon/,'authored retired fat-arrow Hash remains rejected');
done_testing() unless caller;
1;
