use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

sub slurp {
 my ($path)=@_;
 open my $file,'<',$path or die "$path: $!";
 local $/;
 return <$file>;
}
my $json=JSON::PP->new->canonical;
my $sequence=0;
sub check_records {
 my ($label,$source,$expected)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $actual=eval { $parser->(\$input) };
 is("$@",'',"$label native has no thrown error");
 is($context{last_error},undef,"$label native has no handler error");
 is($json->encode($actual),$json->encode($expected),"$label native values/kinds/effects");
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'tagged-record-producer.spec');
 my $package='LinkedSpec::TaggedRecordProducerGenerated'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,"$label fresh parser compiles") or diag($@);
 if ($loaded) {
  my $input='x';
  no strict 'refs';
  my $value=eval { &{$package.'::Execute'}(\$input) };
  is("$@",'',"$label fresh has no thrown error");
  is($json->encode($value),$json->encode($expected),"$label fresh values/kinds/effects");
 }
}
check_records('once and trailing',q{Top:: I { counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)));return([records,counter,split("a,b,",",")]); }},
 [[['row','a',1],['row','b',1],['row','',1]],1,['a','b','']]);
check_records('empty still evaluates fields',q{Top:: I { counter=0;records=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,counter,split("",",")]); }},[[],1,[]]);
check_records('eager arguments and snapshots',q{Top:: I { source="a,b";delimiter=",";tag="row";order="";counter=0;records=split_tagged_records({order=cat(order,"S");source},{order=cat(order,"D");source="changed";delimiter},{order=cat(order,"T");delimiter="wrong";tag},{order=cat(order,"F");tag="changed";counter=num_add(counter,1);counter});return([records,order,source,tag,counter]); }},
 [[['row','a',1],['row','b',1]],'SDTF','changed','changed',1]);
check_records('delimiter and pure split controls',q{Top:: I { delimiter=".";return([split_tagged_records("a.b.",delimiter,row),split_tagged_records("aXbx",/x/i,"r"),split("aXbx",/x/i),split("a.b.",delimiter),split_tagged_records("a",",",7)]); }},
 [[['row','a'],['row','b'],['row','']],[['r','a'],['r','b'],['r','']],['a','b',''],['a','b',''],[['7','a']]]);
check_records('field kinds and copy bounds',q{Top:: I { carried=["x"];records=split_tagged_records("a,b",",","row",7,true,false,null,carried,{"key":"v"});carried+="source";records[0][6][0]="changed";return([records,carried]); }},
 [[['row','a',7,JSON::PP::true,JSON::PP::false,undef,['changed'],{key=>'v'}],['row','b',7,JSON::PP::true,JSON::PP::false,undef,['x'],{key=>'v'}]],['x','source']]);
check_records('earlier carried arguments survive rebinding',q{Top:: I { carried=["x"];number=7;records=split_tagged_records("a,b",",","row",carried,number,{carried+="later";number=9;number});return([records,carried,number]); }},
 [[['row','a',['x'],7,9],['row','b',['x'],7,9]],['x','later'],9]);
done_testing() unless caller;
1;
