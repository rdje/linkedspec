use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.48.1 — written edge ownership, not root privilege.
my $json=JSON::PP->new->canonical->allow_nonref;
open my $f,'<:encoding(UTF-8)','tests/fixtures/referenced_blind_intermediate.json' or die $!;
my $raw;{local $/;$raw=<$f>}close $f or die $!;
my $sequence=0;
for my $fixture(@{$json->decode($raw)}) {
 subtest $fixture->{name} => sub {
  my $source=$fixture->{source};my(%context,@warnings,$parser,$error,$build_stdout,$build_stderr);
  {local *STDOUT;local *STDERR;
   open STDOUT,'>',\$build_stdout or die $!;open STDERR,'>',\$build_stderr or die $!;
   local $SIG{__WARN__}=sub{push @warnings,@_};
   $parser=eval{LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context)};$error=$@;
  }
  is(ref($parser) eq 'CODE'?1:0,$fixture->{expected_builds}?1:0,'compile respects written action/blind ownership');
  is("$error",'','public build reports its structured context without escaping');
  if(!$fixture->{expected_builds}) {
   is($context{last_error}{type},'compiler_pipeline','missing action slot retains compiler diagnostic');
   is($context{last_error}{rule_label},'Top','diagnostic owns the referring rule');
   if($fixture->{name} eq 'indexed_action_no_regex') {
    like($context{last_error}{detail},qr/Regex-slot selector index is out of range/,'indexed action retains its earlier selector diagnostic');
   } else {
    like($context{last_error}{detail},qr/referenced rule 'Middle' regex list.*ARRAY ref; got undef/,'strict missing catalog is not coerced to a blind call');
   }
   is_deeply(\@warnings,[],'rejected source adds no host warning');
   return;
  }
  return unless ref($parser) eq 'CODE';
  ok(!defined($context{last_error}),'valid blind/direct target has no build error');
  my($emitted,$loaded,$load_error);my $package='LinkedSpec::ReferencedIntermediateTest'.++$sequence;
  {local $SIG{__WARN__}=sub{push @warnings,@_};
   $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'referenced-intermediate.spec');
   $loaded=eval "package $package; $emitted; 1";$load_error=$@;
  }
  ok($loaded,'valid source loads independently') or diag("$load_error");return unless $loaded;
  my $metadata=$package->can('LinkedSpecGeneratedMetadata')->();
  is($metadata->{format_version},2,'public generated format remains two');
  is($metadata->{source_identity},'referenced-intermediate.spec','public source identity retained');
  my $valid=eval{$package->can('ValidateGeneratedPlan')->();1};ok($valid,'emitted plan validates') or diag("$@");
  for my $case(@{$fixture->{cases}}) {
   for my $route(qw(native emitted)) {
    my $input=$case->{input};my($value,$inner,$outer,$ok);
    {local $SIG{__WARN__}=sub{push @warnings,@_};
     $ok=eval{$value=$route eq 'native'?$parser->(\$input):$package->can('Execute')->(\$input);$inner=$@;1};$outer=$@ unless $ok;
    }
    ok($ok&&!$inner&&!$outer&&!defined($context{last_error}),"$route runtime succeeds");
    is($json->encode($value),$json->encode($case->{expected}),"$route preserves collection/direct/literal value kinds");
    is(pos($input),$case->{expected_cursor},"$route consumes the expected input");
   }
  }
  is_deeply(\@warnings,[],'valid source and runtime add no warning');
 };
}
done_testing();
