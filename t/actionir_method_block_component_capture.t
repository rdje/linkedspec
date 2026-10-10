use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @families = (
 ['_lower_block_value_component_expr', [qw(trim_action_ir_value lower_primitive_literal_expr lower_flow_composite_expr lower_direct_nested_access_value_expr)],
  [qw(trim_action_ir_value lower_primitive_literal_expr lower_direct_nested_access_value_expr)]],
 ['_lower_block_side_effect_statement', [qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)],
  [qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)]],
);
my @roles = map {my ($owner, $keys, $invoked) = @$_; map {[$owner, $_, $keys]} @$invoked} @families;
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub event {
 my $event = {raw => 'same'};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => 'same', source_span => {start => 0, end => 4}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'VALUE');
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub setup {
 my ($role, $outcome, $event) = @_;
 my ($owner, $target, $keys) = @$role;
 my $state = {trace => [], eligible => [], calls => {}, args => ['target','value'], returned => {marker => 'actual'}};
 my $call = {method => 'set', args => $state->{args}};
 my $fatal = bless {}, 'MethodBlockComponentFatal';
 my (%deps, %actual);
 for my $key (@$keys) {
  my $callback = sub {
   ++$state->{calls}{$key};
   push @{$state->{trace}}, {key => $key,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    args => [map {ref($_) eq 'ARRAY' ? [@$_] : $_} @_],
    actual_args => ref($_[0]) eq 'ARRAY' ? (refaddr($_[0]) == refaddr($state->{args}) ? 1 : 0) : undef};
   my $first = $_[0];
   if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'effect' }
   elsif (defined($_[0])) { $_[0] .= '!' }
   $@ = 'successful '.$key;
   if ($key eq $target) {
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    emit($event) if $event;
    return $state->{returned} if $outcome eq 'reference';
   }
   return $first if $key eq 'trim_action_ir_value';
   return $target eq 'lower_direct_nested_access_value_expr' ? undef : 'VALUE' if $key eq 'lower_primitive_literal_expr';
   return 'VALUE' if $key eq 'lower_direct_nested_access_value_expr';
   return $call if $key eq 'parse_method_function_expr';
   return $state->{args} if $key eq 'normalize_method_args_with_optional_scope';
   die 'validation-only flow callback unexpectedly invoked' if $key eq 'lower_flow_composite_expr';
   die 'unknown fixture callback'
  };
  $deps{$key} = $actual{$key} = $callback;
 }
 return (\%deps, \%actual, $state, $fatal)
}
sub owner {
 my ($name, $input, $deps) = @_;
 no warnings 'redefine';
 # Explicit constant/undef secondary controls isolate the two actual required
 # resolvers, including their native undefined-result fallback branches.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_expr = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_scalar_assignment_operator_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_array_append_operator_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_array_end_mutation_method_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_hash_index_assignment_operator_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_set_key_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_push_statement = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement = sub { return 'VALUE' };
 my $callback = LinkedSpec::ActionIR::MethodLowering->can($name);
 if ($name eq '_lower_block_side_effect_statement') {
  local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub { return 'VALUE' };
  return $callback->($input, $deps)
 }
 return $callback->($input, $deps)
}
sub observations {
 my @rows;
 for my $role (@roles) {
  my ($name, $key, $keys) = @$role;
  my @outcomes = qw(string undefined fatal);
  push @outcomes, 'reference' if $key eq 'lower_primitive_literal_expr' || $key eq 'lower_direct_nested_access_value_expr';
  for my $outcome (@outcomes) {
   my ($deps, $actual, $state, $fatal) = setup($role, $outcome);
   my $input = $name eq '_lower_block_value_component_expr' ? 'source' : 'set(target,value)';
   my ($value, $error, $success_error);
   eval { $@ = 'incoming block component error'; $value = owner($name, $input, $deps); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {owner => $name, key => $key, outcome => $outcome, input => $input,
    trace => $state->{trace}, calls => $state->{calls}, args => $state->{args}, success_error => $success_error,
    value => ref($value) ? {type => ref($value), same_actual => refaddr($value) == refaddr($state->{returned}) ? 1 : 0} : $value,
    error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error,
    map_identity => [map {refaddr($deps->{$_}) == refaddr($actual->{$_}) ? 1 : 0} @$keys]};
  }
 }
 return \@rows
}
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
for my $row (@{observations()}) {
 my $label = join '/', @{$row}{qw(owner key outcome)};
 my $component = $row->{owner} eq '_lower_block_value_component_expr';
 is_deeply($row->{map_identity}, [(1) x ($component ? 4 : 3)], "$label actual public callback references stay exact");
 is($row->{input}, $component ? 'source' : 'set(target,value)', "$label top-level scalar input keeps existing copy behavior");
 ok(@{$row->{trace}} && !grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls retain scalar context");
 is($row->{trace}[0]{error}, 'incoming block component error', "$label native incoming error survives");
 is($row->{calls}{$row->{key}}, 1, "$label target callback keeps native invocation count");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodBlockComponentFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  ok(defined($row->{success_error}) && $row->{success_error} =~ /^successful /, "$label native successful error effect survives");
 }
 my $value = $row->{outcome} eq 'reference' ? {type => 'HASH', same_actual => 1}
  : $row->{outcome} eq 'fatal' || ($row->{outcome} eq 'undefined'
    && ($row->{key} eq 'trim_action_ir_value' || $row->{key} eq 'normalize_method_args_with_optional_scope')) ? undef : 'VALUE';
 is_deeply($row->{value}, $value, "$label actual caller ordinary fallback result stays native");
 if ($row->{key} eq 'normalize_method_args_with_optional_scope') {
  my ($trace) = grep {$_->{key} eq $row->{key}} @{$row->{trace}};
  is($trace->{actual_args}, 1, "$label normalizer receives the actual parser-returned array");
  is_deeply($row->{args}, ['target','value','effect'], "$label normalizer mutates the actual shared argument array");
 }
}
for my $role (@roles) {
 my ($name, $key, $keys) = @$role;
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($role, 'string', $event);
   my $input = $name eq '_lower_block_value_component_expr' ? 'source' : 'set(target,value)';
   my $outer = sub { return owner($name, $input, $deps) };
   producers($known ? [$outer, $actual->{$key}] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, 'VALUE', "$name/$key/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$key/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$name/$key/$known actual callback has its own identity boundary");
    is($state->{calls}{$key}, 1, "$name/$key/$known actual native effect count survives");
    is_deeply([map {refaddr($deps->{$_})} @$keys], [map {refaddr($actual->{$_})} @$keys],
     "$name/$key/$known original public map keeps all actual callbacks");
   });
  });
 }
}
for my $family (@families) {
 my ($name, $keys) = @$family;
 for my $key (@$keys) {
  for my $bad (undef, 'not code') {
   my ($deps) = setup([$name, $key, $keys], 'string'); $deps->{$key} = $bad;
   my $error; eval { owner($name, 'source', $deps); 1 } or $error = $@;
   like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
    "$name/$key required dependency diagnostic remains exact");
  }
 }
}
{
 my ($name, $keys) = @{$families[0]};
 my ($deps, $actual, $state) = setup([$name, 'trim_action_ir_value', $keys], 'string');
 is(owner($name, 'source', $deps), 'VALUE', 'validation-only flow requirement leaves native component value intact');
 is($state->{calls}{lower_flow_composite_expr} // 0, 0, 'validated flow callback is never invoked by component owner');
 is(refaddr($deps->{lower_flow_composite_expr}), refaddr($actual->{lower_flow_composite_expr}),
  'validation-only flow keeps actual public callback identity');
}
done_testing;
