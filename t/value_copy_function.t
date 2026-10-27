use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub observations {
 my ($body, $prefix) = @_;
 my $source = ($prefix // '') . 'Top:: I {' . $body . '}';
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $value = eval { $parser->(\$input) };
 my $thrown = $@;
 my $native_error = $context{last_error} || $thrown;
 my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'value-copy-function.spec');
 my $package = 'LinkedSpec::ValueCopyFunctionGenerated' . ++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh function-copy parser compiles') or diag($@);
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = 'x';
  no strict 'refs';
  $fresh = eval { &{$package . '::Execute'}(\$input) };
  $fresh_error = $@;
 }
 return ([native => $value, $native_error], [fresh => $fresh, $fresh_error]);
}

for my $case (
 ['literals', q{return([copy(true),copy(false),copy(0),copy(7),copy(-2.5),copy("0"),copy(""),copy("🙂"),copy(undef),copy(missing)])},
  [JSON::PP::true, JSON::PP::false, 0, 7, -2.5, '0', '', '🙂', undef, undef]],
 ['bindings', q{t=true;f=false;n=0;s="0";u=undef;return([copy(t),copy(f),copy(n),copy(s),copy(u)])},
  [JSON::PP::true, JSON::PP::false, 0, '0', undef]],
 ['computed values', q{return([copy(and(false)),copy(num_add(1,2)),copy(["x"].first()),copy([].first()),copy([false][0])])},
  [JSON::PP::false, 3, 'x', undef, JSON::PP::false]],
 ['actual-kind consumers', q{order="";a=copy({order=cat(order,"S");false}).cat({order=cat(order,"C");"!"});b=copy({order=cat(order,"R");false}).take({order=cat(order,"A");1});return([a,b,order])},
  ['0!', undef, 'SCR']],
 ['source once and snapshot', q{source=0;counter=0;r=copy({counter=num_add(counter,1);source}).cat({source=7;counter=num_add(counter,1);"!"});return([r,source,counter])},
  ['0!', 7, 2]],
 ['repeated copy and recovery', q{return([copy(false).copy().coalesce("late").cat("!"),copy(undef).coalesce([7]).first(),copy({"a":1}).count_keys()])},
  ['0!', 7, 1]],
 ['numeric selector before JSON', q{items=["zero"];items[copy(0)]="changed";return(items)}, ['changed']],
 ['function-local result', q{scratch="outer";return([duplicate(false),scratch])}, [JSON::PP::false, 'outer'],
  q{fn duplicate(value) { scratch="inner";return(copy(value)) }
}],
) {
 subtest $case->[0] => sub {
  for my $row (observations($case->[1], $case->[3])) {
   my ($route, $value, $error) = @$row;
   ok(!$error, "$route has no runtime error") or diag("$error");
   is($json->encode($value), $json->encode($case->[2]), "$route preserves values, kinds and effects");
  }
 };
}

sub error_detail {
 my ($error) = @_;
 return {} unless (reftype($error) // '') eq 'HASH';
 return $error->{detail} if (reftype($error->{detail}) // '') eq 'HASH';
 return $error;
}
for my $case (
 ['String selector remains String', q{items=["zero"];items[copy("0")]="changed";return(items)},
  'nested_write_kind_conflict', 'expected_kind', 'harray'],
 ['source error propagates', q{return(copy(and()))}, 'helper_arity_mismatch', 'helper_name', 'and'],
) {
 subtest $case->[0] => sub {
  for my $row (observations($case->[1])) {
   my ($route, $value, $error) = @$row;
   is($value, undef, "$route error has no value");
   my $detail = error_detail($error);
   is($detail->{code}, $case->[2], "$route retains typed diagnostic");
   is($detail->{$case->[3]}, $case->[4], "$route retains diagnostic source");
  }
 };
}

subtest 'ordinary container depth is unchanged' => sub {
 for my $row (observations(q{a=[[1],false,undef];h={"nested":[1],"f":false};return([a,copy(a),h,copy(h),copy([]),copy({})])})) {
  my ($route, $value, $error) = @$row;
  ok(!$error, "$route container copy has no error");
  is($json->encode($value), $json->encode([[[1],JSON::PP::false,undef],[[1],JSON::PP::false,undef],
   {nested=>[1],f=>JSON::PP::false},{nested=>[1],f=>JSON::PP::false},[],{}]), "$route container values and kinds");
  isnt(refaddr($value->[0]), refaddr($value->[1]), "$route Array outer copy detaches");
  is(refaddr($value->[0][0]), refaddr($value->[1][0]), "$route Array nested reference stays shared");
  isnt(refaddr($value->[2]), refaddr($value->[3]), "$route Hash outer copy detaches");
  is(refaddr($value->[2]{nested}), refaddr($value->[3]{nested}), "$route Hash nested reference stays shared");
 }
};

subtest 'retired selector stays rejected before copy' => sub {
 my $source = q{Top:: I {items=[1];return(copy(array(items)))}};
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref=>\%context) };
 ok(!ref($parser), 'native rejects the retired selector');
 like(($context{last_error} || {})->{detail} // "$@", qr/aggregate_selector_removed/, 'native retains selector diagnostic');
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source) };
 ok(!defined($emitted), 'fresh emission rejects retired source');
 my $error = $@;
 like((reftype($error) // '') eq 'HASH' ? ($error->{detail} // '') : "$error",
  qr/aggregate_selector_removed/, 'fresh retains selector diagnostic');
};
done_testing();
