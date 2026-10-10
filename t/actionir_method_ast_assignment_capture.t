use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $key = 'lower_scalar_access_key_expr';
my $name = '_lower_ast_assignment_operator_statement';
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
sub node {
 my ($kind) = @_;
 return {kind => $kind || 'assign_hash_index', name => 'meta', base => 'meta',
  key => {kind => 'raw', source => 'key'}, value => {kind => 'raw', source => 'payload'},
  source_span => {start => 17, end => 99}}
}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => ref($value), marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)}
}
sub setup {
 my ($outcome, $event) = @_;
 my $state = {trace => [], eligible => [], helpers => [], calls => 0, key_result => 'KEY'};
 my $fatal = bless {}, 'MethodAstAssignmentFatal';
 my $actual = sub {
  ++$state->{calls};
  push @{$state->{trace}}, {args => [@_], error => $@,
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
   source_slot_alias => refaddr(\$_[0]) == refaddr(\$state->{node}{key}{source}) ? 1 : 0};
  $_[0] .= '!' if defined $_[0];
  $state->{mutated_key} = $_[0];
  $@ = 'successful assignment callback';
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  die $fatal if $outcome eq 'fatal';
  return undef if $outcome eq 'undefined';
  emit($event) if $event;
  return $state->{key_result}
 };
 return ({$key => $actual}, $actual, $state, $fatal)
}
sub owner {
 my ($node, $deps, $state, $options, $expected) = @_;
 $options ||= {};
 $expected = $node->{kind} if @_ < 5 && ref($node) eq 'HASH';
 $state->{node} = $node;
 my $result = sub { exists($options->{$_[0]}) ? $options->{$_[0]} : $_[1] };
 my $identity = sub { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 };
 no warnings 'redefine';
 # The actual owner controls all guards, copies, invocation and assembly text.
 # Secondary helpers return explicit results; their complete implementations
 # and authored AST parsing are outside this required-callback admission.
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub {
  my $role = $identity->($_[0], $node->{key}) ? 'key' : 'value';
  push @{$state->{helpers}}, {name => 'source', role => $role,
   actual_node => $identity->($_[0], $node->{$role})};
  return $result->('source_'.$role, $_[0]{source})
 };
 local *LinkedSpec::ActionIR::MethodLowering::_user_function_scalar_value_name = sub {
  push @{$state->{helpers}}, {name => 'user_fn', value => $_[1], deps_identity => $identity->($_[0], $deps)};
  return $result->('user_fn', 1)
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {
  push @{$state->{helpers}}, {name => 'scalar_read', value => $_[0], deps_identity => $identity->($_[1], $deps)};
  return $result->('scalar_read', 'FAST_READ')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_value_binding_source_expr = sub {
  push @{$state->{helpers}}, {name => 'binding', input => $_[0], deps_identity => $identity->($_[1], $deps)};
  return $result->('binding', 'BOUND')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr = sub {
  push @{$state->{helpers}}, {name => 'scalar_assembly', target => $_[0], input => $_[1],
   deps_identity => $identity->($_[2], $deps), mode => $_[3]};
  return $result->('assembly', 'SCALAR')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {
  push @{$state->{helpers}}, {name => 'payload', input => $_[0], deps_identity => $identity->($_[1], $deps)};
  return $result->('payload', 'VALUE')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr = sub {
  push @{$state->{helpers}}, {name => 'array_assembly', target => $_[0], input => $_[1]};
  return $result->('assembly', 'ARRAY')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_scalar_held_hash_index_assignment_value_node = sub {
  push @{$state->{helpers}}, {name => 'scalar_held', actual_node => $identity->($_[0], $node),
   deps_identity => $identity->($_[1], $deps)};
  return $result->('scalar_held', undef)
 };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked = sub {
  push @{$state->{helpers}}, {name => 'tracked', target => $_[0], deps_identity => $identity->($_[1], $deps)};
  return $result->('tracked', 1)
 };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {
  push @{$state->{helpers}}, {name => 'guard', target => $_[0], attempt => $_[1],
   span => {%{$_[2]}}, new_span => !$identity->($_[2], $node->{source_span}) ? 1 : 0,
   deps_identity => $identity->($_[3], $deps), inner => encoded($_[4])};
  return $result->('guard', 'VALUE')
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_nested_access_assignment_value_node = sub {
  push @{$state->{helpers}}, {name => 'nested', actual_node => $identity->($_[0], $node),
   deps_identity => $identity->($_[1], $deps)};
  return $result->('nested', 'NESTED')
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement($node, $deps, $expected)
}
sub callbacks {
 my @rows;
 for my $outcome (qw(string undefined fatal)) {
  my ($deps, $actual, $state, $fatal) = setup($outcome);
  my $node = node();
  my $before = JSON::PP->new->canonical->encode($node);
  my ($value, $error, $success_error);
  eval { $@ = 'incoming assignment error'; $value = owner($node, $deps, $state); $success_error = $@; 1 }
   or $error = $@;
  push @rows, {outcome => $outcome, value => encoded($value), calls => $state->{calls},
   trace => $state->{trace}, helpers => $state->{helpers}, mutated_key => $state->{mutated_key},
   success_error => $success_error, node_before => $before, node_after => JSON::PP->new->canonical->encode($node),
   map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0,
   error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
 }
 return \@rows
}
sub cases {
 my @cases;
 my @scalar = qw(source binding scalar_assembly tracked guard);
 my @append = qw(source payload array_assembly tracked guard);
 my @hash = qw(scalar_held source source payload tracked guard);
 for my $kind (qw(assign_scalar assign_array_append assign_hash_index)) {
  my $helpers = $kind eq 'assign_scalar' ? \@scalar : $kind eq 'assign_array_append' ? \@append : \@hash;
  push @cases, [$kind, 'baseline', {}, 'VALUE', $helpers];
  push @cases, [$kind, 'untracked', {tracked => 0},
   $kind eq 'assign_scalar' ? 'SCALAR' : $kind eq 'assign_array_append' ? 'ARRAY' : '$meta{KEY} = VALUE',
   [@$helpers[0..$#$helpers-1]]];
  for my $guard (undef, '', '0', {marker => 'guard'}) {
   my $label = !defined($guard) ? 'undefined' : ref($guard) ? 'reference' : length($guard) ? 'zero' : 'empty';
   push @cases, [$kind, 'guard-'.$label, {guard => $guard}, $guard, $helpers];
  }
  for my $label (qw(missing-span malformed-span)) {
   push @cases, [$kind, $label, {}, undef, [@$helpers[0..$#$helpers-1]]];
  }
 }
 for my $kind (qw(assign_scalar assign_array_append)) {
  my $binding = $kind eq 'assign_scalar' ? 'binding' : 'payload';
  my $assembly = $kind eq 'assign_scalar' ? 'scalar_assembly' : 'array_assembly';
  for my $label (qw(undefined empty zero)) {
   my $value = $label eq 'undefined' ? undef : $label eq 'empty' ? '' : '0';
   push @cases, [$kind, 'source-'.$label, {source_value => $value}, $label eq 'zero' ? 'VALUE' : undef,
    $label eq 'zero' ? ['source', $binding, $assembly, 'tracked', 'guard'] : ['source']];
   push @cases, [$kind, $binding.'-'.$label, {$binding => $value}, $label eq 'zero' ? 'VALUE' : undef,
    $label eq 'zero' ? ['source', $binding, $assembly, 'tracked', 'guard'] : ['source', $binding]];
   push @cases, [$kind, 'assembly-'.$label, {assembly => $value}, $label eq 'zero' ? 'VALUE' : undef,
    $label eq 'zero' ? ['source', $binding, $assembly, 'tracked', 'guard'] : ['source', $binding, $assembly]];
  }
 }
 for my $role (qw(key value)) {
  for my $label (qw(undefined empty zero)) {
   my $value = $label eq 'undefined' ? undef : $label eq 'empty' ? '' : '0';
   push @cases, ['assign_hash_index', 'source-'.$role.'-'.$label, {'source_'.$role => $value},
    $label eq 'zero' ? 'VALUE' : undef, $label eq 'zero' ? \@hash : [qw(scalar_held source source)]];
  }
 }
 for my $role (qw(key-result payload)) {
  for my $label (qw(undefined empty zero)) {
   my $value = $label eq 'undefined' ? undef : $label eq 'empty' ? '' : '0';
   push @cases, ['assign_hash_index', $role.'-'.$label, {$role => $value}, $label eq 'zero' ? 'VALUE' : undef,
    $label eq 'zero' ? \@hash : $role eq 'payload' ? [qw(scalar_held source source payload)] : [qw(scalar_held source source)]];
  }
 }
 for my $label (qw(empty zero string)) {
  my $value = $label eq 'empty' ? '' : $label eq 'zero' ? '0' : 'FAST';
  push @cases, ['assign_hash_index', 'scalar-held-'.$label, {scalar_held => $value}, 'VALUE',
   $label eq 'empty' ? \@hash : [qw(scalar_held tracked guard)]];
 }
 push @cases, ['assign_hash_index', 'scalar-held-untracked', {scalar_held => 'FAST', tracked => 0}, 'FAST', [qw(scalar_held tracked)]];
 for my $label (qw(fast empty zero not-user-function)) {
  my $options = $label eq 'empty' ? {scalar_read => ''} : $label eq 'zero' ? {scalar_read => '0'}
   : $label eq 'not-user-function' ? {user_fn => 0} : {};
  push @cases, ['assign_scalar', 'variable-'.$label, $options, 'VALUE',
   $label eq 'not-user-function' ? [qw(user_fn source binding scalar_assembly tracked guard)]
    : $label eq 'empty' ? [qw(user_fn scalar_read source binding scalar_assembly tracked guard)]
    : [qw(user_fn scalar_read binding scalar_assembly tracked guard)]];
 }
 for my $value (undef, '', '0', {marker => 'nested'}) {
  my $label = !defined($value) ? 'undefined' : ref($value) ? 'reference' : length($value) ? 'zero' : 'empty';
  push @cases, ['assign_nested_access', 'nested-'.$label, {nested => $value}, $value, ['nested']];
 }
 return \@cases
}
sub branches {
 my @rows;
 for my $case (@{cases()}) {
  my ($kind, $label, $options) = @$case;
  my ($deps, $actual, $state) = setup('string');
  $state->{key_result} = $options->{'key-result'} if exists $options->{'key-result'};
  my $node = node($kind);
  delete $node->{source_span} if $label eq 'missing-span';
  $node->{source_span} = [] if $label eq 'malformed-span';
  $node->{value} = {kind => 'variable', name => 'arg', source => 'payload'} if $label =~ /^variable-/;
  my $before = JSON::PP->new->canonical->encode($node);
  $@ = 'incoming assignment branch';
  my $value = owner($node, $deps, $state, $options);
  my $success_error = $@;
  push @rows, {case => $kind.'/'.$label, kind => $kind, label => $label,
   value => encoded($value), calls => $state->{calls}, trace => $state->{trace}, helpers => $state->{helpers},
   success_error => $success_error, mutated_key => $state->{mutated_key},
   node_before => $before, node_after => JSON::PP->new->canonical->encode($node),
   map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0,
   direct_result_identity => ref($value) && (ref($options->{guard}) || ref($options->{nested}))
    && refaddr($value) == refaddr($options->{guard} || $options->{nested}) ? 1 : 0};
 }
 return \@rows
}
sub observations { return {callbacks => callbacks(), branches => branches()} }
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
for my $row (@{callbacks()}) {
 my $label = "$name/$row->{outcome}";
 is($row->{map_identity}, 1, "$label actual public callback reference stays exact");
 is($row->{node_after}, $row->{node_before}, "$label actual AST input remains unchanged");
 is($row->{calls}, 1, "$label target callback keeps native invocation count");
 is($row->{trace}[0]{context}, 'scalar', "$label actual required call retains scalar context");
 is($row->{trace}[0]{error}, 'incoming assignment error', "$label native incoming error survives");
 is_deeply($row->{trace}[0]{args}, ['key'], "$label actual key source supplies callback");
 is($row->{trace}[0]{source_slot_alias}, 0, "$label callback keeps local key scalar copy");
 is($row->{mutated_key}, 'key!', "$label native callback mutation survives locally");
 is($row->{value}, $row->{outcome} eq 'string' ? 'VALUE' : undef, "$label actual ordinary result stays native");
 is_deeply([map {$_->{name}} @{$row->{helpers}}],
  $row->{outcome} eq 'string' ? [qw(scalar_held source source payload tracked guard)] : [qw(scalar_held source source)],
  "$label actual secondary helper order stays native");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodAstAssignmentFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  is($row->{success_error}, 'successful assignment callback', "$label native successful error effect survives");
 }
}
for my $known (0, 1) {
 scope(sub {
  my $event = event();
  my ($deps, $actual, $state) = setup('string', $event);
  my $outer = sub { return owner(node(), $deps, $state) };
  producers($known ? [$outer, $actual] : [$outer], sub {
   my $result = capture($outer);
   is($result->{value}, 'VALUE', "$name/$known actual ordinary value survives");
   ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
    "$name/$known required dependency cannot donate nested publication");
   is_deeply($state->{eligible}, [$known], "$name/$known actual callback has its own identity boundary");
   is($state->{calls}, 1, "$name/$known actual native effect count survives");
   is(refaddr($deps->{$key}), refaddr($actual), "$name/$known original public map keeps actual callback");
  });
 });
}
for my $bad (undef, 'not code') {
 my ($deps, $actual, $state) = setup('string'); $deps->{$key} = $bad;
 my $error; eval { owner(node(), $deps, $state); 1 } or $error = $@;
 like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
  "$name required dependency diagnostic remains exact");
 is_deeply([map {$_->{name}} @{$state->{helpers}}], [qw(scalar_held source source)],
  'required validation follows scalar-held fallback and both source extractions');
}
for my $deps (undef, [], 'not hash') {
 my $state = {helpers => []}; my $error;
 eval { owner(node(), $deps, $state); 1 } or $error = $@;
 like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
  'non-hash map keeps required diagnostic');
}
for my $node (undef, [], {}, {kind => 'other'}, node('assign_scalar'), node('assign_hash_index')) {
 my $state = {helpers => []};
 is(owner($node, undef, $state, {}, 'different-kind'), undef, 'node/expected-kind guard precedes dependency validation');
 is_deeply($state->{helpers}, [], 'node/expected-kind guard precedes every secondary helper');
}
{
 my $state = {helpers => []};
 is(owner(node(), undef, $state, {}, undef), undef, 'undefined expected kind stops before required validation');
 is_deeply($state->{helpers}, [], 'undefined expected kind stops before secondary helpers');
}
for my $kind (qw(assign_scalar assign_array_append assign_hash_index)) {
 for my $target (undef, '', 'not a name', '0') {
  my $node = node($kind); $node->{name} = $target;
  my $state = {helpers => []};
  is(owner($node, undef, $state), undef, "$kind invalid target precedes required validation");
  is_deeply($state->{helpers}, [], "$kind invalid target precedes secondary helpers");
 }
}
for my $kind (qw(assign_scalar assign_array_append assign_hash_index assign_nested_access other)) {
 my $state = {helpers => []};
 my $options = $kind eq 'assign_hash_index' ? {scalar_held => 'FAST'} : {};
 my $result = owner(node($kind), undef, $state, $options);
 is($result, $kind eq 'other' ? undef : $kind eq 'assign_nested_access' ? 'NESTED' : 'VALUE',
  "$kind branch bypasses missing required callback when unreachable");
}
my @rows = @{branches()};
my @cases = @{cases()};
for my $index (0..$#cases) {
 my ($kind, $label, $options, $expected, $helpers) = @{$cases[$index]};
 my $row = $rows[$index]; my $title = $row->{case};
 is_deeply($row->{value}, encoded($expected), "$title keeps bounded native branch result");
 is($row->{map_identity}, 1, "$title keeps actual public callback");
 is($row->{node_after}, $row->{node_before}, "$title keeps actual AST fields unchanged");
 is_deeply([map {$_->{name}} @{$row->{helpers}}], $helpers, "$title preserves actual guard/helper order");
 my $expected_calls = $kind eq 'assign_hash_index' && $label !~ /^scalar-held-(?:zero|string|untracked)$/
  && $label !~ /^source-(?:key|value)-(?:undefined|empty)$/ ? 1 : 0;
 is($row->{calls}, $expected_calls, "$title preserves required callback reachability");
 is($row->{direct_result_identity}, $label =~ /^(?:guard|nested)-reference$/ ? 1 : 0,
  "$title preserves direct reference result identity");
 is_deeply([map {$_->{actual_node}} grep {exists $_->{actual_node}} @{$row->{helpers}}],
  [map {1} grep {exists $_->{actual_node}} @{$row->{helpers}}], "$title secondary helpers receive actual nodes");
 my $map_rows = [grep {exists $_->{deps_identity}} @{$row->{helpers}}];
 is_deeply([map {$_->{deps_identity}} @$map_rows], [map {1} @$map_rows], "$title secondary helpers retain actual map");
 if ($expected_calls) {
  is_deeply($row->{trace}[0]{args}, [$label eq 'source-key-zero' ? '0' : 'key'], "$title keeps original callback argument");
  is($row->{trace}[0]{source_slot_alias}, 0, "$title retains local key scalar copy");
 }
 my ($guard) = grep {$_->{name} eq 'guard'} @{$row->{helpers}};
 if ($guard) {
  is($guard->{target}, 'meta', "$title guard keeps actual target");
  is($guard->{attempt}, $kind eq 'assign_scalar' ? 'assign' : $kind eq 'assign_array_append' ? 'append' : 'nested_write',
   "$title guard keeps actual attempt");
  is_deeply($guard->{span}, {start => 17, end => 21}, "$title builds target-only span from original start");
  is($guard->{new_span}, 1, "$title guard receives new span reference");
  my $inner = $kind eq 'assign_scalar' ? $label eq 'assembly-zero' ? '0' : 'SCALAR'
   : $kind eq 'assign_array_append' ? $label eq 'assembly-zero' ? '0' : 'ARRAY'
   : $label eq 'scalar-held-zero' ? '0' : $label eq 'scalar-held-string' ? 'FAST'
   : '$meta{'.($label eq 'key-result-zero' ? '0' : 'KEY').'} = '.($label eq 'payload-zero' ? '0' : 'VALUE');
  is($guard->{inner}, $inner, "$title forwards native inner expression to guard");
 }
 my ($binding) = grep {$_->{name} eq 'binding'} @{$row->{helpers}};
 if ($binding) {
  is($binding->{input}, $label eq 'variable-fast' ? 'FAST_READ' : $label eq 'variable-zero' || $label eq 'source-zero' ? '0' : 'payload',
   "$title binding receives actual selected source");
 }
 my ($payload) = grep {$_->{name} eq 'payload'} @{$row->{helpers}};
 is($payload->{input}, $label eq 'source-zero' || $label eq 'source-value-zero' ? '0' : 'payload',
  "$title payload receives actual selected source") if $payload;
}
done_testing;
