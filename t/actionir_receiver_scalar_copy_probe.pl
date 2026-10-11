package ReceiverScalarCopyProbe;

use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();

sub spec {
 return <<'SPEC';
Top::
 /x/ -> Done {
  meta = { "k": "v", "nested": [1, 2] };
  items = [1, 2];
  empty_hash = {};
  empty_array = [];
  text = "abc";
  zero = 0;
  return([meta, meta.copy(), copy(meta), items, items.copy(), copy(items),
    empty_hash, empty_hash.copy(), empty_array, empty_array.copy(),
    meta.copy().flat_hash().count_keys(), items.copy().count(), text.copy(), zero.copy()]);
 }
Done::
 /[a-z]+/
SPEC
}

sub identity {
 my ($value) = @_;
 return {} unless ref($value) eq 'ARRAY' && @$value == 14;
 return {
  hash_distinct => ref($value->[1]) eq 'HASH' && refaddr($value->[0]) != refaddr($value->[1]) ? 1 : 0,
  hash_nested_shared => ref($value->[1]) eq 'HASH' && refaddr($value->[0]{nested}) == refaddr($value->[1]{nested}) ? 1 : 0,
  function_hash_distinct => refaddr($value->[0]) != refaddr($value->[2]) ? 1 : 0,
  function_hash_nested_shared => refaddr($value->[0]{nested}) == refaddr($value->[2]{nested}) ? 1 : 0,
  array_distinct => refaddr($value->[3]) != refaddr($value->[4]) ? 1 : 0,
  function_array_distinct => refaddr($value->[3]) != refaddr($value->[5]) ? 1 : 0,
 };
}

sub observations {
 my $spec = spec();
 my %ctx;
 my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
 my $input = 'xhello';
 my $live = $parser->(\$input);
 my $generated = LinkedSpec::emit_generated_source(\$spec, source_identity => 'receiver-scalar-copy.spec');
 my $loaded = eval "package ReceiverScalarCopyGenerated; $generated; 1";
 die $@ unless $loaded;
 $input = 'xhello';
 my $standalone = ReceiverScalarCopyGenerated::Execute(\$input);

 my ($typed_source, $typed_value, $typed_calls);
 {
  no warnings 'redefine';
  my $original = \&LinkedSpec::ActionIR::AST::parse_action_expr;
  local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
   my ($expr, @rest) = @_;
   if ($expr eq 'meta.copy()') {
    ++$typed_calls;
    return {kind => 'fluent_chain', source => '__poison_chain__()',
     receiver => {kind => 'variable', name => 'meta', source => '__poison_receiver__()'},
     calls => [{method => 'copy', args => [], source => '__poison_call__()'}]};
   }
   return $original->($expr, @rest);
  };
  $typed_source = LinkedSpec::call_spec_handler_subst('Top', 'meta = {"k":"v"}; return(meta.copy())');
  my $run = eval 'sub { my $meta; '.$typed_source.' }';
  die $@ unless $run;
  $typed_value = $run->();
 }
 return {live => $live, standalone => $standalone,
  live_identity => identity($live), standalone_identity => identity($standalone),
  live_error => $ctx{last_error}, generated_source => $generated,
  typed_source => $typed_source, typed_value => $typed_value, typed_calls => $typed_calls || 0,
  legacy_source => LinkedSpec::call_spec_handler_subst('Top', 'return(Top.copy())'),
  wrong_arity_source => LinkedSpec::call_spec_handler_subst('Top', 'meta={"k":"v"}; return(meta.copy("x"))')};
}

unless (caller) {
 die 'usage: probe.pl observe' unless @ARGV == 1 && $ARGV[0] eq 'observe';
 print JSON::PP->new->canonical->encode(observations()), "\n";
}

1;
