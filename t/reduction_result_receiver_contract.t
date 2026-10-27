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
sub check_consumers {
 my ($label,$source,$expected)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $actual=eval { $parser->(\$input) };
 is("$@",'',"$label native has no thrown error");
 is($context{last_error},undef,"$label native has no handler error");
 is($json->encode($actual),$json->encode($expected),"$label native values/kinds/effects");
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'reduction-results.spec');
 my $package='LinkedSpec::ReductionResultGenerated'.++$sequence;
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
check_consumers('admitted traversal',q{Top:: I { original=[1,[2]];seen=[];walked=original.walk_leaves() {seen+=join_values("/",path);return(99)};mapped=original.map_leaves() {return(value.add(1))};meta={"b":{"y":2},"a":1,"arr":[9]};paths=[];hash=meta.walk_leaves() {paths+=join_values("/",path);return(0)};return([original,walked,mapped,seen,hash,paths,[1,[2]].reduce_leaves(0) {return(acc.add(value))}]); }},
 [[1,[2]],[1,[2]],[2,[3]],['0','1/0'],{b=>{y=>2},a=>1,arr=>[9]},['a','arr','b/y'],3]);
check_consumers('reduction result',slurp('tests/fixtures/reduction_result_receiver_values.spec'),
 $json->decode(slurp('tests/fixtures/reduction_result_receiver_values.json')));
done_testing() unless caller;
1;
