use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.40.1.1. Match lexicals have one declaration owner.
my $json=JSON::PP->new->canonical->ascii->allow_nonref;
open my $fh,'<:raw','tests/fixtures/perl_match_local_declarations.json' or die $!;
my $raw;{local $/;$raw=<$fh>}close $fh or die $!;
my $fixtures=JSON::PP->new->utf8->decode($raw);
my $number=0;
for my $fixture(@$fixtures) {
 subtest $fixture->{name} => sub {
  my($source,%context,@build,@emission,@load,$parser,$emitted,$loaded,$load_error)=($fixture->{source});
  {local $SIG{__WARN__}=sub{push @build,@_};$parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context)}
  ok(ref($parser) eq 'CODE','native parser builds') or return;
  is_deeply(\@build,[],'native build has no warnings');
  {local $SIG{__WARN__}=sub{push @emission,@_};$emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'match-locals.spec')}
  is_deeply(\@emission,[],'emission has no warnings');
  my $package='LinkedSpec::MatchLocalDeclarationTest'.++$number;
  {local $SIG{__WARN__}=sub{push @load,@_};$loaded=eval "package $package; $emitted; 1";$load_error=$@}
  ok($loaded,'warning-enabled emitted source loads') or do{diag($load_error);return};
  is_deeply(\@load,[],'emitted loading has no warnings');
  is($json->encode($package->can('LinkedSpecGeneratedMetadata')->()),$json->encode($fixture->{expected_metadata}),'full generated metadata unchanged');
  for my $route(['native',$parser],['emitted',$package->can('Execute')]) {
   my($input,$value,$error,@warnings,$output)=($fixture->{input});
   {local *STDOUT;open STDOUT,'>:encoding(UTF-8)',\$output or die $!;
    local $SIG{__WARN__}=sub{push @warnings,@_};$value=eval{$route->[1]->(\$input)};$error=$@}
   is_deeply(\@warnings,[],"$route->[0] run has no warnings");
   is($json->encode($value),$json->encode($fixture->{expected}),"$route->[0] value and kinds preserved");
   is(pos($input),$fixture->{expected_cursor},"$route->[0] cursor preserved");
   if($fixture->{expected_error_code}) {
    my $record=$route->[0] eq 'native'?$context{last_error}:$error;
    ok(ref($record) eq 'HASH',"$route->[0] retains typed error record");
    is($record->{detail}{code},$fixture->{expected_error_code},"$route->[0] unsupported callback stays fail closed");
   } else {
    is("$error",'',"$route->[0] has no exception");
    ok(!$context{last_error},"$route->[0] has no context failure");
   }
  }
 };
}
done_testing();
