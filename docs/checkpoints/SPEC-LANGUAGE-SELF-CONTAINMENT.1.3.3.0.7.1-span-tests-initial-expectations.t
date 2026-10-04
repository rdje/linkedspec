use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(blessed);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::BootstrapSpec ();
use LinkedSpec::RuleIR ();
use LinkedSpec::RuleIR::EmitContext ();

my @forms = (
 ['eager', ' { return(i+1) } '],
 ['attached call', ' f() { return(i+1) } '],
 ['attached control', ' if(true) { return(i+1) } '],
 ['nested', ' if(true) { return({ if(true) { return(i+1) } }) } '],
 ['repeated', ' if(true) { return(i+1); return(i+1) } '],
 ['Unicode CRLF', "note(\"é😀\");\r\n if(true) {\r\nreturn(i+1)\r\n}"],
 ['callable', ' cb={|| return(i+1) } '],
 ['receiver', ' value.with() { return(i+1) } '],
 ['map callback', ' tree.map_leaves!() { return(i+1) } '],
);
for my $case (@forms) {
 subtest "$case->[0] successful child spans" => sub {
  my $source = $case->[1];
  my $ast = LinkedSpec::ActionIR::AST::parse_action_block($source, {base_start=>100});
  my (%raw, @bad);
  my $walk;
  $walk = sub {
   my ($x)=@_;
   if (ref($x) eq 'ARRAY') { $walk->($_) for @$x; return }
   return unless ref($x) eq 'HASH';
   if (ref($x->{source_span}) eq 'HASH' && defined($x->{source})) {
    my ($start,$end)=@{$x->{source_span}}{qw(start end)};
    push @bad, [$x->{kind},$start,$end] if $start<100 || $end>100+length($source)
     || substr($source,$start-100,$end-$start) ne $x->{source};
    $raw{"$start:$end"}=[$start,$end] if ($x->{kind}//'') eq 'raw_perl' && $x->{source} eq 'i+1';
   }
   $walk->($x->{$_}) for sort keys %$x;
  };
  $walk->($ast); undef $walk;
  my @expected;
  while ($source =~ /i\+1/g) { push @expected,[100+$-[0],100+$+[0]] }
  is_deeply([sort {$a->[0]<=>$b->[0]} values %raw],\@expected,'authored occurrence offsets including repetitions');
  is_deeply(\@bad,[],'every source-bearing node slices the containing Unicode-scalar source');
 };
}
for my $case (@forms) {
 subtest "$case->[0] typed rejection spans" => sub {
  my $source=$case->[1]; $source =~ s/return\(i\+1\)/tree[] = 1/g;
  my $ok=eval { LinkedSpec::ActionIR::AST::parse_action_block($source,{base_start=>100}); 1 };
  my $error=$@;
  ok(!$ok && blessed($error) && $error->isa('LinkedSpec::ActionIR::AST::Parser::Diagnostic'),'same typed rejection');
  is($error->{code},'nested_write_segment_empty','same rejection code');
  my $start=100+index($source,'[]');
  is_deeply($error->{source_span},{start=>$start,end=>$start+2,unit=>'unicode_scalar',provenance=>'authored'},'authored nonzero-base diagnostic');
 };
}
subtest 'opaque owner payload and caller error state' => sub {
 no warnings 'redefine';
 require LinkedSpec::ActionIR::RewritePipeline;
 local *LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics = sub {
  return ('rewritten_ok',{label=>'Top',raw=>'call(Leaf)'});
 };
 $@="__SAVED_ERR__\n";
 my ($code,$diag)=LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top','call(Leaf)',[]);
 is($code,'rewritten_ok','delegated source');
 is_deeply($diag,{label=>'Top',raw=>'call(Leaf)'},'opaque owner payload remains exact');
 is($@,"__SAVED_ERR__\n",'caller error state remains exact');
};
subtest 'generated lifecycle ownership is exact' => sub {
 my $source="Top::\n -> MoveTop\n\nMoveTop: /foo/ /bar/ \@mark(body_start)\n";
 my ($ok,$entries,$error)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
 ok($ok,'public bootstrap succeeds') or diag($error);
 my ($entry)=grep {ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && $_->[0][1] eq 'MoveTop'} @$entries;
 my $rule=LinkedSpec::RuleIR::_collect_rule_ir($entry);
 my $ctx=eval {LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($rule)};
 ok($ctx,'canonical mark emit context succeeds') or diag($@);
 if ($ctx) {
  is($ctx->{action_rewriter_meta}{raw_perl_dependency_count},0,'generated mark does not add authored raw');
  is($ctx->{action_rewriter_meta}{language_agnostic_action_ir_ready},1,'canonical mark retains readiness');
 }
 my $copy=LinkedSpec::RuleIR::_collect_rule_ir($entry);
 push @{$copy->{code_blocks}{LECODE}},$copy->{code_blocks}{LECODE}[0];
 my $twin=eval {LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($copy)};
 ok($twin,'authored identical later chunk compiles') or diag($@);
 if ($twin) {cmp_ok($twin->{action_rewriter_meta}{raw_perl_dependency_count},'>',0,'authored twin remains visible')}
 my $changed=LinkedSpec::RuleIR::_collect_rule_ir($entry);
 $changed->{code_blocks}{LECODE}[0]='return(i+1)';
 my $mismatch=LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($changed);
 is($mismatch->{action_rewriter_meta}{raw_perl_dependency_count},1,'changed source is never waived by old slot ownership');
 for my $marker ('move_pos','capture_slice','capture_from_here') {
  my $move="Top::\n -> MoveTop\n\nMoveTop: /foo/ /bar/ \@$marker\n";
  my $descriptor=LinkedSpec::Get(\$move,return_descriptor=>1);
  ok(ref($descriptor) eq 'HASH',"$marker descriptor succeeds");
  if (ref($descriptor) eq 'HASH') {
   my $meta=$descriptor->{spec}{MoveTop}{meta}{action_rewriter};
   is($meta->{raw_perl_dependency_count},0,"$marker compiler chunk is not authored raw");
   is($meta->{language_agnostic_action_ir_ready},1,"$marker retains readiness");
  }
 }
};
done_testing();
