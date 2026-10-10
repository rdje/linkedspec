use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @keys = qw(trim_action_ir_value split_declare_symbol_names parse_declare_binding_entry lower_declare_initializer_expr parse_method_function_expr normalize_method_args_with_optional_scope lower_direct_nested_access_value_expr extract_array_symbol_name extract_hash_symbol_name extract_scalar_symbol_name lower_scalar_access_key_expr lower_primitive_literal_expr infer_scalar_container_kind split_top_level_csv split_action_ir_statements lower_array_pipeline_expr lower_assignment_source_expr lower_flow_composite_expr strip_literal_delimiters);
sub defaults { LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $_[0]) }
sub selected {
 my ($callback) = @_;
 my $state = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 return 0 unless ref($state) eq 'HASH'
  && LinkedSpec::ActionIR::SourceEmissions::_same_reference(
   $state->{source_token}, LinkedSpec::ActionIR::SourceEmissions::_current_source_token());
 return LinkedSpec::ActionIR::SourceEmissions::_same_reference(
  $state->{known}{refaddr($callback)}, $callback) ? 1 : 0
}
sub observations {
 # Retain both actual maps while normalizing identities, avoiding address reuse.
 my @maps = map { defaults('LinkedSpec::RuleIR::EmitContext') } 1..2;
 my (%seen, @rows);
 for my $map (@maps) {
  push @rows, {type => ref($map), keys => [sort keys %$map], callbacks => [map {
   my $callback = $map->{$_};
   {key => $_, type => ref($callback), actual_native => refaddr($callback) ==
    refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$_)) ? 1 : 0,
    identity => $seen{refaddr($callback)} //= scalar(keys %seen)}
  } @keys]};
 }
 return \@rows
}
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n";
 exit 0
}

my $build_map = \&LinkedSpec::OwnerDispatch::build_dep_map;
my $register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
my ($factory_map, @registered);
{
 no warnings 'redefine';
 local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
  $factory_map = $build_map->(@_); return $factory_map
 };
 local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
  push @registered, $_[0]; return $register->(@_)
 };
 scope(sub { producers(sub {
  my $map = defaults('LinkedSpec::RuleIR::EmitContext');
  is(refaddr($map), refaddr($factory_map), 'default factory returns the exact actual OwnerDispatch map');
  is_deeply([sort keys %$map], [sort @keys], 'native default map retains exactly the original keys');
  is_deeply([sort {$a <=> $b} map {refaddr($_)} @registered],
   [sort {$a <=> $b} map {refaddr($map->{$_})} @keys], 'native default selects each actual reference exactly once');
  for my $key (@keys) {
   my $actual = $map->{$key};
   is(refaddr($actual), refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$key)), "$key public callback retains exact native reference");
   ok(selected($actual), "$key actual native reference is selected in current scope");
   is(refaddr(LinkedSpec::RuleIR::EmitContext::_register_builtin_method_emission_callback($actual)),
    refaddr($actual), "$key selector returns the same actual native callback");
  }
  scope(sub { for my $key (@keys) {
   is(refaddr(LinkedSpec::RuleIR::EmitContext::_register_builtin_method_emission_callback($map->{$key})),
    refaddr($map->{$key}), "$key nested equal-source registration returns actual callback");
   ok(!selected($map->{$key}), "$key nested equal-source scope cannot borrow registration");
  } });
  producers(sub { for my $key (@keys) {
   ok(!selected($map->{$key}), "$key nested producer scope cannot borrow registration");
  } });
  for my $key (@keys) { ok(selected($map->{$key}), "$key enclosing producer selection restores") }
 }); });
}

for my $key (@keys) {
 my $opaque = sub { return 'same' };
 my $actual = LinkedSpec::RuleIR::EmitContext->can('_'.$key);
 {
  no strict 'refs'; no warnings 'redefine';
  local *{'LinkedSpec::RuleIR::EmitContext::_'.$key} = $opaque;
  scope(sub { producers(sub {
   my $map = defaults('LinkedSpec::RuleIR::EmitContext');
   is(refaddr($map->{$key}), refaddr($opaque), "$key same-name replacement keeps actual public reference");
   ok(!selected($opaque), "$key same-name replacement remains opaque");
   ok(!selected($actual), "$key replaced native callback is not selected by this factory");
   my @unchanged = grep { $_ ne $key } @keys;
   is_deeply([map {selected($map->{$_})} @unchanged], [(1) x @unchanged], "$key unchanged native defaults remain selected");
   is(refaddr(LinkedSpec::RuleIR::EmitContext::_register_builtin_method_emission_callback($opaque)),
    refaddr($opaque), "$key selector preserves actual opaque reference");
   ok(!selected($opaque), "$key direct selector cannot select an opaque callback");
   LinkedSpec::RuleIR::EmitContext::_register_builtin_method_emission_callback($actual);
   ok(selected($actual), "$key retained actual native reference survives symbol replacement");
  }); });
 }
}

{
 no strict 'refs'; no warnings 'redefine';
 for my $key (@keys) {
  *{'MethodDefaultCustom::_'.$key} = LinkedSpec::RuleIR::EmitContext->can('_'.$key);
 }
 scope(sub { producers(sub {
  my $map = defaults('MethodDefaultCustom');
  is_deeply([sort keys %$map], [sort @keys], 'custom target keeps original key population');
  for my $key (@keys) {
   is(refaddr($map->{$key}), refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$key)), "$key custom target preserves actual native alias");
   ok(!selected($map->{$key}), "$key custom target cannot register its native alias");
  }
 }); });
}

# An opaque replacement actually attempts publication and returns equal text.
# Its ordinary value survives, but factory selection cannot authorize the packet.
for my $key (@keys) {
 scope(sub { producers(sub {
  my $event = {raw => 'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => 'same', source_span => {start => 0, end => 4}});
  my ($calls, $eligible) = (0, undef);
  my $opaque = sub {
   ++$calls; $eligible = LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'same');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   return 'same'
  };
  no strict 'refs'; no warnings 'redefine';
  local *{'LinkedSpec::RuleIR::EmitContext::_'.$key} = $opaque;
  my $map = defaults('LinkedSpec::RuleIR::EmitContext');
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($map->{$key});
  is($capture->{value}, 'same', "$key opaque equal ordinary value survives");
  is($calls, 1, "$key actual opaque callback executes once");
  is($eligible, 0, "$key opaque actual invocation stays ineligible");
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $opaque, $event),
   "$key opaque equal text cannot publish a selected packet");
 }); });
}

scope(sub { producers(sub {
 my $before = defaults('LinkedSpec::RuleIR::EmitContext');
 my $opaque = sub { return 'same' };
 no warnings 'redefine';
 local *LinkedSpec::RuleIR::EmitContext::_trim_action_ir_value = $opaque;
 defaults('LinkedSpec::RuleIR::EmitContext');
 ok(selected($before->{trim_action_ir_value}), 'later replacement cannot revoke an already selected actual native callback');
 ok(!selected($opaque), 'later replacement cannot inherit existing selection');
}); });
scope(sub { producers(sub {
 for my $callback (values %{defaults('MethodDefaultCustom')}) {
  ok(!selected($callback), 'new producer scope retains no expired native registration');
 }
}); });
my $outside = defaults('LinkedSpec::RuleIR::EmitContext');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_producers), 'outside factory creates no global producer scope');
for my $key (@keys) { ok(!selected($outside->{$key}), "$key outside registration grants no authority") }
is_deeply(observations()->[0], observations()->[1], 'repeated native maps retain complete key/ref reuse observations');
done_testing;
