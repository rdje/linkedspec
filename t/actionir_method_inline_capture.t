use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @families = (
 ['_lower_inline_if_value_expr', [qw(normalize_method_args_with_optional_scope parse_method_function_expr lower_flow_composite_expr)]],
 ['_lower_inline_switch_value_expr', [qw(normalize_method_args_with_optional_scope parse_method_function_expr)]],
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
 return 'do { my $__ls_if_value; if (COND) { $__ls_if_value = VALUE; } elsif (COND) { $__ls_if_value = VALUE; } else { $__ls_if_value = VALUE; } $__ls_if_value }'
  if $owner eq '_lower_inline_if_value_expr';
 return 'do { my $__ls_switch_source = VALUE; my $__ls_switch_value; my $__ls_switch_done = 0; if (!$__ls_switch_done) { my $__ls_switch_case = CASE; if ((defined($__ls_switch_source) ? $__ls_switch_source : "") eq (defined($__ls_switch_case) ? $__ls_switch_case : "")) { $__ls_switch_value = VALUE; $__ls_switch_done = 1; } } if (!$__ls_switch_done) { $__ls_switch_value = VALUE; $__ls_switch_done = 1; } $__ls_switch_value }'
}
sub setup {
 my ($role, $outcome, $event) = @_;
 my ($owner, $target, $keys) = @$role;
 my $is_if = $owner eq '_lower_inline_if_value_expr';
 my $state = {trace => [], eligible => [], calls => {},
  branch_args => $is_if ? [['COND2','THEN2'],['FALLBACK']] : [['CASE','CASE_BODY'],['FALLBACK']],
  input => {method => $is_if ? 'if' : 'switch',
   args => $is_if ? ['COND','THEN','elseif','else'] : ['SUBJECT','case','default']}};
 my $fatal = bless {}, 'MethodInlineFatal';
 my (%deps, %actual);
 for my $key (@$keys) {
  my $callback = sub {
   ++$state->{calls}{$key};
   push @{$state->{trace}}, {key => $key,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    args => [map {ref($_) eq 'ARRAY' ? [@$_] : $_} @_],
    actual_args => ref($_[0]) eq 'ARRAY'
     ? (grep({refaddr($_[0]) == refaddr($_)} @{$state->{branch_args}}) ? 1 : 0) : undef};
   my $first = $_[0];
   if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'effect' }
   elsif (defined($_[0])) { $_[0] .= '!' }
   $@ = 'successful '.$key;
   if ($key eq $target) {
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    emit($event, expected($owner)) if $event && $state->{calls}{$key} == 1;
   }
   return $first if $key eq 'normalize_method_args_with_optional_scope';
   if ($key eq 'parse_method_function_expr') {
    my $index = $state->{calls}{$key} - 1;
    return {method => $is_if ? ($index ? 'else' : 'elseif') : ($index ? 'default' : 'case'),
     args => $state->{branch_args}[$index]};
   }
   return 'COND' if $key eq 'lower_flow_composite_expr';
   die 'unknown fixture callback'
  };
  $deps{$key} = $actual{$key} = $callback;
 }
 return (\%deps, \%actual, $state, $fatal)
}
sub owner {
 my ($name, $input, $deps) = @_;
 no warnings 'redefine';
 # Explicit constant secondary helpers bound this matrix to the two actual
 # inline caller bodies, without admitting their branch/truthiness helpers.
 local *LinkedSpec::ActionIR::MethodLowering::_runtime_typed_truthiness_expr = sub { return 'COND' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_inline_value_branch_payload_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_inline_switch_case_value_expr = sub { return 'CASE' };
 return LinkedSpec::ActionIR::MethodLowering->can($name)->($input, $deps)
}
sub observations {
 my @rows;
 for my $role (@roles) {
  my ($name, $key, $keys) = @$role;
  for my $outcome (qw(string undefined fatal)) {
   my ($deps, $actual, $state, $fatal) = setup($role, $outcome);
   my $input = $state->{input};
   my ($value, $error, $success_error);
   eval { $@ = 'incoming inline error'; $value = owner($name, $input, $deps); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {owner => $name, key => $key, outcome => $outcome,
    input => $input,
    trace => $state->{trace}, calls => $state->{calls}, branch_args => $state->{branch_args},
    success_error => $success_error, value => $value,
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
 my $is_if = $row->{owner} eq '_lower_inline_if_value_expr';
 my $unused_flow = $row->{key} eq 'lower_flow_composite_expr';
 is_deeply($row->{map_identity}, [(1) x ($is_if ? 3 : 2)], "$label actual public callback references stay exact");
 is_deeply($row->{input}{args}, $is_if ? ['COND','THEN','elseif','else']
  : ['SUBJECT','case!', $row->{outcome} eq 'string' ? 'default!' : 'default'],
  "$label native copied and shared caller scalar arguments stay exact");
 ok(@{$row->{trace}} && !grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls retain scalar context");
 is($row->{trace}[0]{error}, 'incoming inline error', "$label native incoming error survives");
 is($row->{calls}{$row->{key}} // 0, $unused_flow ? 0 : $row->{outcome} eq 'string' ? 2 : 1,
  "$label current target invocation count is explicit");
 if ($row->{outcome} eq 'fatal' && !$unused_flow) {
  is_deeply($row->{error}, {type => 'MethodInlineFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  ok(defined($row->{success_error}) && $row->{success_error} =~ /^successful /, "$label native successful error effect survives");
 }
 is($row->{value}, $unused_flow || $row->{outcome} eq 'string' ? expected($row->{owner}) : undef,
  "$label current caller result survives without invoking the former flow role");
 if ($row->{key} eq 'normalize_method_args_with_optional_scope') {
  my @traces = grep {$_->{key} eq $row->{key}} @{$row->{trace}};
  is_deeply([map {$_->{actual_args}} @traces], [(1) x @traces], "$label normalizer receives actual parser-returned arrays");
  my $first = $is_if ? ['COND2','THEN2','effect'] : ['CASE','CASE_BODY','effect'];
  is_deeply($row->{branch_args}, [$first, $row->{outcome} eq 'string' ? ['FALLBACK','effect'] : ['FALLBACK']],
   "$label normalizer mutates actual shared branch arrays");
 }
}
for my $role (@roles) {
 my ($name, $key, $keys) = @$role;
 my $unused_flow = $key eq 'lower_flow_composite_expr';
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($role, 'string', $event);
   my $outer = sub { return owner($name, $state->{input}, $deps) };
   producers($known ? [$outer, $actual->{$key}] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, expected($name), "$name/$key/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$key/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, $unused_flow ? [] : [($known) x 2], "$name/$key/$known current invocation authority stays exact");
    is($state->{calls}{$key} // 0, $unused_flow ? 0 : 2, "$name/$key/$known current effect count survives");
    is_deeply([map {refaddr($deps->{$_})} @$keys], [map {refaddr($actual->{$_})} @$keys],
     "$name/$key/$known original public map keeps all actual callbacks");
   });
  });
 }
 for my $bad (undef, 'not code') {
  my ($deps, $actual, $state) = setup($role, 'string'); $deps->{$key} = $bad;
  my ($error, $value); eval { $value = owner($name, $state->{input}, $deps); 1 } or $error = $@;
  if ($unused_flow) {
   is($error, undef, "$name no longer validates the former flow dependency");
   is($value, expected($name), "$name uses typed condition/payload lowering without the former flow dependency");
  } else {
   like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
    "$name/$key required dependency diagnostic remains exact");
  }
 }
}
done_testing;
