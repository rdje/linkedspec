use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @families = (
 ['_infer_assignment_source_container_kind', [qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)]],
 ['_lower_value_binding_source_expr', [qw(trim_action_ir_value lower_assignment_source_expr)]],
 ['_lower_typed_declare_statement', [qw(split_declare_symbol_names parse_declare_binding_entry lower_declare_initializer_expr)]],
);
my @roles = map { my ($owner, $keys) = @$_; map { [$owner, $_, $keys] } @$keys } @families;
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
 my ($event, $text) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $text);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub expected {
 my ($owner) = @_;
 return $owner eq '_infer_assignment_source_container_kind' ? 'array'
  : $owner eq '_lower_value_binding_source_expr' ? 'same' : 'my $target = same'
}
sub setup {
 my ($role, $outcome, $event, $known) = @_;
 my ($owner, $target, $keys) = @$role;
 my $state = {trace => [], eligible => [], calls => {}, args => ['array(x)'], entries => ['entry'],
  binding => {name => 'target', init => 'value'}, returned => {marker => 'actual'}};
 my $call = {method => 'copy', args => $state->{args}};
 my $fatal = bless {}, 'MethodInferenceFatal';
 my (%deps, %actual);
 for my $key (@$keys) {
  my $callback = sub {
   ++$state->{calls}{$key};
   push @{$state->{trace}}, {key => $key,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    args => [map { ref($_) eq 'ARRAY' ? [@$_] : $_ } @_],
    actual_args => ref($_[0]) eq 'ARRAY' ? (refaddr($_[0]) == refaddr($state->{args}) ? 1 : 0) : undef};
   my $first = $_[0];
   # Preserve native local scalar copies while exercising their actual aliases.
   # The normalizer mutates the actual parser-returned argument array instead.
   if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'effect' }
   elsif (defined($_[0])) { $_[0] .= '!' }
   $@ = 'successful '.$key;
   if ($key eq $target) {
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    emit($event, expected($owner)) if $event && $state->{calls}{$key} == 1;
    return $state->{returned} if $outcome eq 'reference';
   }
   return $first if $key eq 'trim_action_ir_value';
   return $call if $key eq 'parse_method_function_expr';
   return $state->{args} if $key eq 'normalize_method_args_with_optional_scope';
   return 'same' if $key eq 'lower_assignment_source_expr' || $key eq 'lower_declare_initializer_expr';
   return $state->{entries} if $key eq 'split_declare_symbol_names';
   return $state->{binding} if $key eq 'parse_declare_binding_entry';
   die 'unknown fixture callback'
  };
  $deps{$key} = $actual{$key} = $callback;
 }
 return (\%deps, \%actual, $state, $fatal)
}
sub owner {
 my ($name, $input, $deps) = @_;
 no warnings 'redefine';
 # Explicit constant secondary helpers keep this bounded matrix on the three
 # actual required-resolution owners rather than later value/source-slot work.
 local *LinkedSpec::ActionIR::MethodLowering::_infer_direct_shape_literal_kind = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub { return undef };
 my $callback = LinkedSpec::ActionIR::MethodLowering->can($name);
 return $name eq '_lower_typed_declare_statement'
  ? $callback->('scalar', $input, $deps) : $callback->($input, $deps)
}
sub observations {
 my @rows;
 for my $role (@roles) {
  my ($name, $key, $keys) = @$role;
  my @outcomes = (qw(string undefined fatal));
  push @outcomes, 'reference' if $key eq 'lower_assignment_source_expr';
  for my $outcome (@outcomes) {
   my ($deps, $actual, $state, $fatal) = setup($role, $outcome);
   my $input = $name eq '_infer_assignment_source_container_kind' ? 'copy(array(x))' : 'source';
   my ($value, $error, $success_error);
   eval { $@ = 'incoming inference error'; $value = owner($name, $input, $deps); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {owner => $name, key => $key, outcome => $outcome, input => $input,
    trace => $state->{trace}, calls => $state->{calls}, args => $state->{args}, entries => $state->{entries},
    binding => $state->{binding}, success_error => $success_error,
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
 my $keys = $row->{owner} eq '_lower_value_binding_source_expr' ? 2 : 3;
 is_deeply($row->{map_identity}, [(1) x $keys], "$label actual public callback references stay exact");
 is($row->{input}, $row->{owner} eq '_infer_assignment_source_container_kind' ? 'copy(array(x))' : 'source',
  "$label top-level scalar input keeps existing copy behavior");
 ok(@{$row->{trace}} && !grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls retain scalar context");
 is($row->{trace}[0]{error}, 'incoming inference error', "$label native incoming error survives");
 is($row->{calls}{$row->{key}}, $row->{key} eq 'trim_action_ir_value' && $row->{owner} eq '_infer_assignment_source_container_kind' && $row->{outcome} eq 'string' ? 2 : 1,
  "$label target callback keeps native invocation count");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodInferenceFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  ok(defined($row->{success_error}) && $row->{success_error} =~ /^successful /, "$label native successful error effect survives");
 }
 my $value = $row->{outcome} eq 'string' ? expected($row->{owner})
  : $row->{outcome} eq 'reference' ? {type => 'HASH', same_actual => 1} : undef;
 is_deeply($row->{value}, $value, "$label actual caller ordinary result stays native");
 if ($row->{key} eq 'normalize_method_args_with_optional_scope') {
  my ($trace) = grep {$_->{key} eq $row->{key}} @{$row->{trace}};
  is($trace->{actual_args}, 1, "$label normalizer receives the actual parser-returned array");
  is_deeply($row->{args}, [$row->{outcome} eq 'string' ? 'array(x)!' : 'array(x)', 'effect'], "$label normalizer mutates the actual shared argument array");
 }
}
for my $role (@roles) {
 my ($name, $key, $keys) = @$role;
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($role, 'string', $event, $known);
   my $input = $name eq '_infer_assignment_source_container_kind' ? 'copy(array(x))' : 'source';
   my $outer = sub { return owner($name, $input, $deps) };
   producers($known ? [$outer, $actual->{$key}] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, expected($name), "$name/$key/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$key/$known required dependency cannot donate nested publication");
    my $calls = $key eq 'trim_action_ir_value' && $name eq '_infer_assignment_source_container_kind' ? 2 : 1;
    is_deeply($state->{eligible}, [($known) x $calls], "$name/$key/$known actual callback has its own identity boundary");
    is($state->{calls}{$key}, $calls, "$name/$key/$known actual native effect count survives");
    is_deeply([map {refaddr($deps->{$_})} @$keys], [map {refaddr($actual->{$_})} @$keys],
     "$name/$key/$known original public map keeps all actual callbacks");
   });
  });
 }
 for my $bad (undef, 'not code') {
  my ($deps) = setup($role, 'string'); $deps->{$key} = $bad;
  my $error; eval { owner($name, 'source', $deps); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
   "$name/$key required dependency diagnostic remains exact");
 }
}
done_testing;
