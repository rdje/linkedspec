use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

my $json=JSON::PP->new->canonical;
my $sequence=0;
sub observations {
 my ($source)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $value=eval { $parser->(\$input) };
 my $native_error=$context{last_error} || $@;
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'value-copy-interpreted.spec');
 my $package='LinkedSpec::ValueCopyInterpretedGenerated'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,'fresh interpreted-copy parser compiles') or diag($@);
 my ($fresh,$error);
 if ($loaded) {
  my $input='x';
  no strict 'refs';
  $fresh=eval { &{$package.'::Execute'}(\$input) };
  $error=$@;
 }
 return ([native=>$value,$native_error],[fresh=>$fresh,$error]);
}
my $source=<<'SPEC';
Top:: I {
 thunk={||
  f=false;n=0;s="0";u=undef;
  literals=[copy(true),copy(false),copy(0),copy("0"),copy(""),copy("🙂"),copy(undef),copy(missing)];
  named=[copy(f),copy(n),copy(s),copy(u)];
  results=[copy(and(false)),copy(num_add(1,2)),copy(first(["x"])),copy(first([]))];
  source=0;counter=0;
  snapshot=cat(copy({counter=num_add(counter,1);source}),{source=7;counter=num_add(counter,1);"!"});
  order="";wrong=copy({order=cat(order,"S");false}).take({order=cat(order,"A");1});
  items=["zero"];items[copy(0)]="changed";
  return([literals,named,results,[snapshot,source,counter],[wrong,order],items,copy([[1],false,undef]),copy({"a":[1]})]);
 };
 return(thunk());
}
SPEC
my $expected=[
 [JSON::PP::true,JSON::PP::false,0,'0','','🙂',undef,undef],
 [JSON::PP::false,0,'0',undef], [JSON::PP::false,3,'x',undef],
 ['0!',7,2],[[],'S'],['changed'],[[1],JSON::PP::false,undef],{a=>[1]},
];
for my $row (observations($source)) {
 my ($route,$value,$error)=@$row;
 ok(!$error,"$route supported interpreted copying has no error") or diag("$error");
 is($json->encode($value),$json->encode($expected),"$route existing free copy preserves primitive kinds, snapshots and guards");
}

sub detail {
 my ($error)=@_;
 return {} unless (reftype($error)//'') eq 'HASH';
 return $error->{detail} if (reftype($error->{detail})//'') eq 'HASH';
 return $error;
}
for my $case (
 ['method vocabulary remains bounded',q{Top:: I {thunk={|| return(false.copy())};return(thunk())}},
  {code=>'unknown_helper',name=>'copy'}],
 ['malformed free signature remains bounded',q{Top:: I {thunk={|| return(copy(false,true))};return(thunk())}},
  {code=>'unknown_helper',name=>'copy'}],
 ['source error is retained',q{Top:: I {thunk={|| return(copy(and()))};return(thunk())}},
  {code=>'helper_arity_mismatch',helper_name=>'and',arguments_evaluated=>0}],
 ['copied callable retains recursion origin',q{Top:: I {thunk={|| alias=copy(thunk);return(alias())};return(thunk())}},
  {code=>'codeblock_recursion_unsupported'}],
 ['String copy remains a String selector',q{Top:: I {thunk={|| items=["zero"];items[copy("0")]="changed";return(items)};return(thunk())}},
  {code=>'nested_write_kind_conflict',expected_kind=>'harray',actual_kind=>'array'}],
) {
 subtest $case->[0]=>sub {
  for my $row (observations($case->[1])) {
   my ($route,$value,$error)=@$row;
   is($value,undef,"$route rejected operation has no value");
   my $actual=detail($error);
   for my $field (sort keys %{$case->[2]}) {
    is($actual->{$field},$case->[2]{$field},"$route retains $field");
   }
  }
 };
}
done_testing();
