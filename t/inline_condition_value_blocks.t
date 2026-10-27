use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.26.0: existing inline conditions are values.
my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub packet {
 my ($name) = @_;
 open my $file, '<', 'docs/checkpoints/type-operation-inventory/'.$name.'.json' or die $!;
 local $/; return $json->decode(<$file>);
}
sub check_source {
 my ($label, $source, $expected) = @_;
 subtest $label => sub {
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  my $native = eval { $parser->(\$input) };
  is("$@", '', 'native has no thrown error');
  is($context{last_error}, undef, 'native has no handler error');
  is($json->encode($native), $json->encode($expected), 'native exact value and effect order');
  my $emitted = LinkedSpec::emit_generated_source(\$source,
   source_identity => 'inline-condition-value-blocks.spec');
  my $package = 'LinkedSpec::InlineConditionValueBlocks'.++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh parser compiles') or diag($@);
  if ($loaded) {
   my $input = 'x'; no strict 'refs';
   my $actual = eval { &{$package.'::Execute'}(\$input) };
   is("$@", '', 'fresh has no thrown error');
   is($json->encode($actual), $json->encode($expected), 'fresh exact value and effect order');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
  is($metadata->{raw_perl_dependency_count}, 0, 'value blocks stay typed');
  is($metadata->{unresolved_helper_count}, 0, 'no unresolved helper');
  ok($metadata->{language_agnostic_action_ir_ready}, 'working lowering satisfies ready metadata');
 };
}

for my $case (@{packet('conditional-result-composition-intake')->{cases}}) {
 next unless $case->{id} =~ /\A(?:lazy_producer|direct_methods|scalar_methods)\z/;
 check_source($case->{id}, $case->{source}, $case->{expected});
}
for my $case (@{packet('conditional-result-condition-controls')->{cases}}) {
 check_source($case->{id}, $case->{source}, $case->{expected});
}
check_source('false and ordered elseif conditions with local returns', q{Top:: I {
 order="";
 result=if({order=cat(order,"A");return(false);order="bad"},"bad",
   elseif({order=cat(order,"B");false},"bad"),
   elseif({order=cat(order,"C");true},{order=cat(order,"D");return("ok");order="bad"}),
   else({order=cat(order,"E");"bad"}));
 return([result,order]);
}}, ['ok','ABCD']);
check_source('function condition locals stay in the invocation', q{
 fn choose(flag) {
  result=if({scratch="inner";flag},{chosen="then";chosen},else("fallback"));
  return([result,scratch]);
 }
 Top:: I {scratch="outer";return([choose(true),choose(false),scratch]);}
}, [['then','inner'],['fallback','inner'],'outer']);
check_source('existing predicate logical and numeric conditions', q{Top:: I {
 return([if(and(true,true),"ok","bad"),if(is_defined(false),"defined","bad"),
 if(num_gt(2,1),"greater","bad"),if(false,"bad",elseif(num_eq(1,1),"equal"),else("bad")),
 if(if(true,false,true),"bad","nested"),switch(if(true,"k","bad"),case("k",if(false,"bad","nested-switch")))]);
}}, ['ok','defined','greater','equal','nested','nested-switch']);
done_testing() unless caller;
1;
