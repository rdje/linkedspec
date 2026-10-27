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
sub check_methods {
 my ($label,$source,$expected)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $actual=eval { $parser->(\$input) };
 is("$@",'',"$label native has no thrown error");
 is($context{last_error},undef,"$label native has no handler error");
 is($json->encode($actual),$json->encode($expected),"$label native values/kinds/effects");
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'logical-receiver-methods.spec');
 my $package='LinkedSpec::LogicalReceiverMethodGenerated'.++$sequence;
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
check_methods('logical receiver methods',slurp('tests/fixtures/logical_receiver_method_values.spec'),
 $json->decode(slurp('tests/fixtures/logical_receiver_method_values.json')));
check_methods('ordinary method shapes before effects',q{Top:: I { order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});d={order=cat(order,"S");false}.not(fail("must-not-run"));return([a,b,c,d,order]); }},[undef,undef,undef,undef,'']);
check_methods('valid prefix survives incompatible consumers',q{Top:: I { order="";a={order=cat(order,"S");false}.and({order=cat(order,"R");true}).take({order=cat(order,"A");1});first=[a,order];order="";b={order=cat(order,"S");false}.or({order=cat(order,"R");true}).cat({order=cat(order,"C");"!"}).set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});return([first,[b,order]]); }},[[undef,'SR'],[undef,'SRC']]);
for my $case (
 ['and',0,'and().not()'],
 ['not',2,'not({fail("must-not-run")},{fail("must-not-run")}).or(true)'],
) {
 my ($helper,$arity,$expression)=@$case;
 subtest "$helper invalid source retains typed error through new methods" => sub {
  my $source='Top:: I { return('.$expression.') }';
  my $native=LinkedSpec::Get(\$source);
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'logical-method-source-error.spec');
  my $package='LinkedSpec::LogicalMethodSourceError'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'source-error fresh parser compiles') or diag($@);
  my $fresh;
  if ($loaded) { no strict 'refs'; $fresh=\&{$package.'::Execute'}; }
  for my $route ([native=>$native],[fresh=>$fresh]) {
   next unless ref($route->[1]) eq 'CODE';
   my $input='x';my $ok=eval { $route->[1]->(\$input);1 };my $error=$@;
   ok(!$ok,"$route->[0] rejects original helper arity");
   isa_ok($error,'LinkedSpec::RuntimeDiagnosticOutput::Error');
   if (ref($error) eq 'LinkedSpec::RuntimeDiagnosticOutput::Error') {
    is($error->{code},'helper_arity_mismatch','typed helper error unchanged');
    is($error->{helper_name},$helper,'original helper identified');
    is($error->{actual_arity},$arity,'original argument count identified');
    is($error->{arguments_evaluated},0,'invalid source operands do not run');
   }
  }
 };
}
done_testing() unless caller;
1;
