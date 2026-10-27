use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub check_source {
 my ($label, $source, $expected) = @_;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $actual = eval { $parser->(\$input) };
 is("$@", '', "$label native has no thrown error");
 is($context{last_error}, undef, "$label native has no handler error");
 is($json->encode($actual), $json->encode($expected), "$label native values, kinds and effects");
 my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity=>'value-copy-receiver.spec');
 my $package = 'LinkedSpec::ValueCopyReceiverGenerated' . ++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, "$label fresh parser compiles") or diag($@);
 if ($loaded) {
  my $input = 'x';
  no strict 'refs';
  my $value = eval { &{$package.'::Execute'}(\$input) };
  is("$@", '', "$label fresh has no thrown error");
  is($json->encode($value), $json->encode($expected), "$label fresh values, kinds and effects");
 }
}

my $expected = [
 [JSON::PP::true,JSON::PP::false,0,'0','','🙂',undef,undef],
 [JSON::PP::false,0,'0',undef],
 [JSON::PP::false,4,'A','0!',7,JSON::PP::true],
 [undef,undef,'SR'], ['0!',7,2],
 [JSON::PP::false,'outer',9],
 [[2,1],[2,1],{a=>1},{a=>1}],
 ['changed'], [{a=>1},'K'],
];
check_source('primitive receiver flows', <<'SPEC', $expected);
fn duplicate(value) { scratch="inner";counter=1;return(value.copy().copy()) }
Top:: I {
 literal=[true.copy(),false.copy(),0.copy(),"0".copy(),"".copy(),"🙂".copy(),undef.copy(),missing.copy()];
 f=false;n=0;s="0";u=undef;
 named=[f.copy().copy(),n.copy().copy(),s.copy().copy(),u.copy().copy()];
 results=[and(false).copy(),num_add(1,2).copy().add(1)," a ".trim().copy().uppercase(),false.copy().coalesce("late").cat("!"),[].first().copy().coalesce([7]).first(),"x".with() {return(false)}.not().copy()];
 order="";
 wrong_array={order=cat(order,"S");false}.copy().trim().take({order=cat(order,"A");1});
 wrong_hash={order=cat(order,"R");0}.copy().set_key({order=cat(order,"K");"a"},{order=cat(order,"V");1});
 guards=[wrong_array,wrong_hash,order];
 source=0;counter=0;
 snapshot={counter=num_add(counter,1);source}.copy().cat({source=7;counter=num_add(counter,1);"!"});
 saved=[snapshot,source,counter];
 scratch="outer";counter=9;scoped=[duplicate(false),scratch,counter];
 a=[2,1];h={"a":1};containers=[a,a.copy().copy(),h,h.copy().copy()];
 items=["zero"];items[0.copy()]="changed";
 key_order="";key_copy={}.copy().set_key({key_order=cat(key_order,"K");"a"},1);
 return([literal,named,results,guards,saved,scoped,containers,items,[key_copy,key_order]]);
}
SPEC

check_source('malformed copy shape before effects', q{Top:: I {
 order="";
 a={order=cat(order,"S");false}.copy({order=cat(order,"A");1}).cat({order=cat(order,"C");"!"});
 b={order=cat(order,"R");[1]}.copy(fail("must-not-run"));
 c={order=cat(order,"T");false}.not().copy(1);
 return([a,b,c,order]);
}}, [undef,undef,undef,'']);

my $source = q{Top:: I { return(and().copy().cat("!")) }};
my $native = LinkedSpec::Get(\$source);
my $emitted = LinkedSpec::emit_generated_source(\$source,source_identity=>'copy-source-error.spec');
my $loaded = eval "package LinkedSpec::CopyReceiverSourceError; $emitted; 1";
ok($loaded, 'fresh source-error parser compiles') or diag($@);
for my $route ([native=>$native], [fresh=>$loaded ? \&LinkedSpec::CopyReceiverSourceError::Execute : undef]) {
 next unless $route->[1];
 my $input='x';
 my $ok=eval { $route->[1]->(\$input);1 };
 my $error=$@;
 ok(!$ok, "$route->[0] retains source failure");
 isa_ok($error,'LinkedSpec::RuntimeDiagnosticOutput::Error');
 if (ref($error) eq 'LinkedSpec::RuntimeDiagnosticOutput::Error') {
  is($error->{code}, 'helper_arity_mismatch', 'source diagnostic retained');
  is($error->{helper_name}, 'and', 'source helper identified');
  is($error->{arguments_evaluated}, 0, 'invalid source operands do not run');
 }
}
done_testing();
