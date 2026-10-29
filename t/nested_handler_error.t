use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype refaddr);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.41.1 — actual child failures survive defined parents.
my $json=JSON::PP->new->canonical->allow_nonref;
open my $file,'<:encoding(UTF-8)','tests/fixtures/nested_handler_error.json' or die $!;
my $text;{local $/;$text=<$file>}close $file or die $!;
for my $fixture (@{$json->decode($text)}) {
 subtest $fixture->{name} => sub {
  my $source=$fixture->{source};my %context;
  my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
  ok(ref($parser) eq 'CODE','native parser builds');
  return unless ref($parser) eq 'CODE';
  for my $case (@{$fixture->{cases}}) {
   my $input=$case->{input};my ($value,$inner);
   my $ok=eval {$value=$parser->(\$input);$inner=$@;1};my $outer=$@;
   ok($ok,'handler failures retain native nonthrowing invocation surface') or diag("$outer");
   is("$outer",'','no outer exception');
   if (exists $case->{error_rule}) {
    ok(!defined($value),'actual handler failure returns no successful parent value');
    my $error=$context{last_error};
    ok(ref($error) eq 'HASH','actual failure keeps structured context');
    $error={} unless ref($error) eq 'HASH';
    is($error->{type},'runtime_handler','original error owner');
    is($error->{stage},'rule_handler_eval','original failure stage');
    is($error->{rule_label},$case->{error_rule},'failing child rule retained');
    is($error->{top_rule},'Top','entry identity retained');
    like($error->{handler_source_label}//'',qr/^LinkedSpec::generated_handler:\Q$case->{error_rule}\E:/,'original handler source identity');
    my $detail=$error->{detail};
    ok((reftype($detail)//'') eq 'HASH','original typed error detail');
    $detail={} unless (reftype($detail)//'') eq 'HASH';
    is($detail->{code},'unknown_helper','excluded vocabulary stays excluded');
    is($detail->{name},$fixture->{helper},'authored helper name retained');
    ok(ref($inner) && ref($error->{detail}) && refaddr($inner)==refaddr($error->{detail}),
      'inner eval error and diagnostic retain the same original object');
   } else {
    is($json->encode($value),$json->encode($case->{expected}),'healthy value and null/container kinds');
    is("$inner",'','healthy invocation has no inner error');
    ok(!exists($context{last_error}),'healthy invocation clears prior failure');
   }
   ok(!grep(/^_runtime_handler_failure/,keys %context),'private invocation provenance does not leak after return');
  }
 };
}
done_testing();
