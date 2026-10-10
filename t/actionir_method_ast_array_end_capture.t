use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $key = 'extract_array_symbol_name';
my $name = '_lower_ast_array_end_mutation_method_statement';
my @methods = qw(push_back push_front pop_back pop_front);
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
 my ($method) = @_;
 return {kind => 'fluent_chain',
  receiver => {source => 'items', source_span => {start => 7, end => 12}},
  calls => [{method => $method, args => $method =~ /^push_/ ? [{source => 'payload'}] : []}]}
}
sub setup {
 my ($outcome, $event) = @_;
 my $state = {trace => [], eligible => [], helpers => [], calls => 0,
  target_result => 'target', mutate_receiver => 1};
 my $fatal = bless {}, 'MethodAstArrayEndFatal';
 my $actual = sub {
  ++$state->{calls};
  my $receiver = $state->{node}{receiver};
  push @{$state->{trace}}, {args => [@_], error => $@,
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
   receiver_source_slot_alias => refaddr(\$_[0]) == refaddr(\$receiver->{source}) ? 1 : 0};
  $_[0] .= '!' if $state->{mutate_receiver} && defined $_[0];
  $@ = 'successful array-end callback';
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  die $fatal if $outcome eq 'fatal';
  return undef if $outcome eq 'undefined';
  emit($event) if $event;
  return $state->{target_result}
 };
 return ({$key => $actual}, $actual, $state, $fatal)
}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => ref($value), marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)}
}
sub owner {
 my ($node, $deps, $state, $options) = @_;
 $options ||= {};
 $state->{node} = $node;
 no warnings 'redefine';
 # Secondary source/payload/binding/assembly/guard/error helpers have explicit
 # outputs. The actual owner guards, callback, fallback and branch order run.
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub {
  my $role = refaddr($_[0]) == refaddr($node->{receiver}) ? 'receiver' : 'value';
  my $expected = $role eq 'receiver' ? $node->{receiver} : $node->{calls}[0]{args}[0];
  push @{$state->{helpers}}, {name => 'source', role => $role,
   actual_node => refaddr($_[0]) == refaddr($expected) ? 1 : 0};
  return exists($options->{'source_'.$role}) ? $options->{'source_'.$role} : $_[0]{source}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {
  push @{$state->{helpers}}, {name => 'payload', input => $_[0],
   deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists($options->{payload}) ? $options->{payload} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {
  push @{$state->{helpers}}, {name => 'binding', receiver => $_[0], kind => $_[1],
   deps_identity => refaddr($_[2]) == refaddr($deps) ? 1 : 0};
  return exists($options->{binding}) ? $options->{binding} : 'BINDING'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_end_expr = sub {
  push @{$state->{helpers}}, {name => 'assembly', args => [map {encoded($_)} @_]};
  return exists($options->{assembly}) ? $options->{assembly} : 'INNER'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {
  my $span = $node->{receiver}{source_span};
  push @{$state->{helpers}}, {name => 'guard', binding => encoded($_[0]), method => $_[1],
   span_identity => ref($span) && ref($_[2]) && refaddr($_[2]) == refaddr($span) ? 1 : 0,
   deps_identity => refaddr($_[3]) == refaddr($deps) ? 1 : 0, inner => encoded($_[4])};
  return exists($options->{guard}) ? $options->{guard} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_unsupported_helper_expr = sub {
  push @{$state->{helpers}}, {name => 'unsupported', method => $_[0]};
  return 'UNSUPPORTED:'.$_[0]
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_array_end_mutation_method_statement($node, $deps)
}
sub callbacks {
 my @rows;
 for my $method (@methods) {
  for my $outcome (qw(string undefined fatal)) {
   my ($deps, $actual, $state, $fatal) = setup($outcome);
   my $node = node($method);
   my $before = JSON::PP->new->canonical->encode($node);
   my ($value, $error, $success_error);
   eval { $@ = 'incoming array-end error'; $value = owner($node, $deps, $state); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {method => $method, outcome => $outcome, value => $value,
    calls => $state->{calls}, trace => $state->{trace}, helpers => $state->{helpers},
    success_error => $success_error, node_before => $before,
    node_after => JSON::PP->new->canonical->encode($node),
    map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0,
    error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
  }
 }
 return \@rows
}
sub cases {
 my @cases;
 for my $method (@methods) {
  push @cases, [$method, 'baseline', {}], [$method, 'host', {binding => undef}];
 }
 for my $case (
  ['receiver-undefined', {source_receiver => undef}],
  ['receiver-empty', {source_receiver => ''}],
  ['receiver-zero', {source_receiver => '0'}],
  ['target-empty', {}, ''],
  ['target-zero', {}, '0'],
  ['undefined-bare-fallback', {}, undef, 0, 'undefined'],
  ['undefined-mutated', {}, undef, 1, 'undefined'],
  ['binding-empty', {binding => ''}],
  ['binding-zero', {binding => '0'}],
  ['guard-undefined', {guard => undef}],
  ['guard-empty', {guard => ''}],
  ['guard-zero', {guard => '0'}],
  ['guard-reference', {guard => {marker => 'guard'}}],
  ['assembly-undefined', {assembly => undef}],
  ['assembly-empty', {assembly => ''}],
  ['missing-span', {}],
 ) { push @cases, ['push_back', @$case] }
 for my $method (qw(push_back push_front)) {
  for my $case (
   ['value-undefined', {source_value => undef}], ['value-empty', {source_value => ''}],
   ['value-zero', {source_value => '0'}], ['payload-undefined', {payload => undef}],
   ['payload-empty', {payload => ''}], ['payload-zero', {payload => '0'}],
  ) { push @cases, [$method, @$case] }
 }
 for my $case (
  ['binding-empty', {binding => ''}], ['binding-zero', {binding => '0'}],
  ['guard-zero', {guard => '0'}], ['guard-reference', {guard => {marker => 'guard'}}],
 ) { push @cases, ['pop_front', @$case] }
 for my $method (qw(push_back pop_front)) {
  push @cases, [$method, 'undefined-nonbare', {source_receiver => '@items'}, undef, 0, 'undefined'];
 }
 for my $method (qw(pop_back pop_front)) { push @cases, [$method, 'missing-args', {}] }
 return \@cases
}
sub branches {
 my @rows;
 for my $case (@{cases()}) {
  my ($method, $label, $options, $target, $mutate, $outcome) = @$case;
  my ($deps, $actual, $state) = setup($outcome || 'string');
  $state->{target_result} = $target if @$case >= 4;
  $state->{mutate_receiver} = $mutate if defined $mutate;
  my $node = node($method);
  delete $node->{receiver}{source_span} if $label eq 'missing-span';
  delete $node->{calls}[0]{args} if $label eq 'missing-args';
  my $before = JSON::PP->new->canonical->encode($node);
  $@ = 'incoming array-end branch';
  my $value = owner($node, $deps, $state, $options);
  my $success_error = $@;
  push @rows, {case => $method.'/'.$label, method => $method, label => $label,
   value => encoded($value), calls => $state->{calls}, trace => $state->{trace},
   helpers => $state->{helpers}, success_error => $success_error,
   node_before => $before, node_after => JSON::PP->new->canonical->encode($node),
   map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0,
   guard_result_identity => ref($value) && ref($options->{guard}) && refaddr($value) == refaddr($options->{guard}) ? 1 : 0};
 }
 return \@rows
}
sub observations { return {callbacks => callbacks(), branches => branches()} }
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
for my $row (@{callbacks()}) {
 my $label = "$name/$row->{method}/$row->{outcome}";
 is($row->{map_identity}, 1, "$label actual public callback reference stays exact");
 is($row->{node_after}, $row->{node_before}, "$label actual AST input remains unchanged");
 is($row->{calls}, 1, "$label target callback keeps native invocation count");
 is($row->{trace}[0]{context}, 'scalar', "$label actual required call retains scalar context");
 is($row->{trace}[0]{error}, 'incoming array-end error', "$label native incoming error survives");
 is_deeply($row->{trace}[0]{args}, ['items'], "$label actual receiver source supplies callback");
 is($row->{trace}[0]{receiver_source_slot_alias}, 0, "$label callback keeps local receiver scalar copy");
 is($row->{value}, $row->{outcome} eq 'string' ? 'VALUE' : $row->{outcome} eq 'undefined' ? 'UNSUPPORTED:'.$row->{method} : undef,
  "$label actual ordinary result stays native");
 my $helpers = $row->{outcome} eq 'fatal' ? ['source'] : $row->{outcome} eq 'undefined' ? [qw(source unsupported)]
  : $row->{method} =~ /^push_/ ? [qw(source source payload binding assembly guard)] : [qw(source binding assembly guard)];
 is_deeply([map {$_->{name}} @{$row->{helpers}}], $helpers, "$label actual secondary helper order stays native");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodAstArrayEndFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  is($row->{success_error}, 'successful array-end callback', "$label native successful error effect survives");
 }
}
for my $method (@methods) {
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup('string', $event);
   my $outer = sub { return owner(node($method), $deps, $state) };
   producers($known ? [$outer, $actual] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, 'VALUE', "$name/$method/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$method/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$name/$method/$known actual callback has its own identity boundary");
    is($state->{calls}, 1, "$name/$method/$known actual native effect count survives");
    is(refaddr($deps->{$key}), refaddr($actual), "$name/$method/$known original public map keeps actual callback");
   });
  });
 }
}
for my $method (@methods) {
 for my $bad (undef, 'not code') {
  my ($deps, $actual, $state) = setup('string'); $deps->{$key} = $bad;
  my $error; eval { owner(node($method), $deps, $state); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
   "$name/$method required dependency diagnostic remains exact");
  is_deeply($state->{helpers}, [], "$method validates required callback before source extraction");
 }
 for my $deps (undef, [], 'not hash') {
  my $state = {helpers => []}; my $error;
  eval { owner(node($method), $deps, $state); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
   "$method non-hash map keeps required diagnostic");
  is_deeply($state->{helpers}, [], "$method non-hash map fails before source extraction");
 }
}
my @invalid = (undef, [], {}, {kind => 'other'}, {kind => 'fluent_chain'},
 {kind => 'fluent_chain', calls => {}}, {kind => 'fluent_chain', calls => []},
 {kind => 'fluent_chain', calls => [{}, {}]}, {kind => 'fluent_chain', calls => ['not hash']},
 {kind => 'fluent_chain', calls => [{}]}, {kind => 'fluent_chain', calls => [{method => 'other'}]});
for my $node (@invalid) {
 my $state = {helpers => []};
 is(owner($node, undef, $state), undef, 'invalid node/calls/method stops before required dependency validation');
 is_deeply($state->{helpers}, [], 'invalid node/calls/method stops before any secondary helper');
}
for my $method (@methods) {
 for my $count ($method =~ /^push_/ ? (0, 2) : (1)) {
  my $node = node($method); $node->{calls}[0]{args} = [map {{source => 'payload'}} 1..$count];
  my $state = {helpers => []};
  is(owner($node, undef, $state), 'UNSUPPORTED:'.$method, "$method/$count arity guard precedes dependency validation");
  is_deeply($state->{helpers}, [{name => 'unsupported', method => $method}], "$method/$count rejected arity calls only unsupported helper");
 }
}
for my $row (@{branches()}) {
 my ($method, $label) = @{$row}{qw(method label)};
 my $title = $row->{case};
 my $receiver_stops = $label =~ /^receiver-(?:undefined|empty)$/;
 my $target_stops = $label =~ /^(?:target-empty|undefined-mutated|undefined-nonbare)$/;
 my $value_stops = $label =~ /^value-(?:undefined|empty)$/;
 my $payload_stops = $label =~ /^payload-(?:undefined|empty)$/;
 my $expected = $receiver_stops || $target_stops || $value_stops || $payload_stops ? 'UNSUPPORTED:'.$method
  : $label eq 'host' ? $method eq 'push_back' ? 'push @target, VALUE' : $method eq 'push_front' ? 'unshift @target, VALUE'
   : $method eq 'pop_back' ? 'pop @target' : 'shift @target'
  : $label eq 'guard-undefined' ? undef : $label eq 'guard-empty' ? '' : $label eq 'guard-zero' ? '0'
  : $label eq 'guard-reference' ? {type => 'HASH', marker => 'guard'} : 'VALUE';
 is_deeply($row->{value}, $expected, "$title keeps bounded native branch result");
 is($row->{map_identity}, 1, "$title keeps actual public callback");
 is($row->{node_after}, $row->{node_before}, "$title keeps actual AST fields unchanged");
 is($row->{calls}, $receiver_stops ? 0 : 1, "$title preserves callback reachability");
 is($row->{guard_result_identity}, $label eq 'guard-reference' ? 1 : 0, "$title preserves direct guard result identity");
 my $helpers = $receiver_stops || $target_stops ? [qw(source unsupported)]
  : $value_stops ? [qw(source source unsupported)] : $payload_stops ? [qw(source source payload unsupported)]
  : $label eq 'host' ? $method =~ /^push_/ ? [qw(source source payload binding)] : [qw(source binding)]
  : $method =~ /^push_/ ? [qw(source source payload binding assembly guard)] : [qw(source binding assembly guard)];
 is_deeply([map {$_->{name}} @{$row->{helpers}}], $helpers, "$title preserves actual guard/helper order");
 is_deeply([map {$_->{actual_node}} grep {$_->{name} eq 'source'} @{$row->{helpers}}],
  [map {1} grep {$_->{name} eq 'source'} @{$row->{helpers}}], "$title source helpers receive actual AST nodes");
 is_deeply([map {$_->{deps_identity}} grep {exists $_->{deps_identity}} @{$row->{helpers}}],
  [map {1} grep {exists $_->{deps_identity}} @{$row->{helpers}}], "$title secondary helpers retain actual dependency map");
 if (!$receiver_stops) {
  my $source = $label eq 'receiver-zero' ? '0' : $label eq 'undefined-nonbare' ? '@items' : 'items';
  is_deeply($row->{trace}[0]{args}, [$source], "$title keeps original callback argument");
  is($row->{trace}[0]{receiver_source_slot_alias}, 0, "$title retains local scalar copy");
 }
 my ($binding) = grep {$_->{name} eq 'binding'} @{$row->{helpers}};
 if ($binding) {
  my $source = $label eq 'receiver-zero' ? '0' : 'items';
  $source .= '!' unless $label eq 'undefined-bare-fallback';
  is($binding->{receiver}, $source, "$title binding helper observes callback local-scalar mutation");
  is($binding->{kind}, 'array', "$title binding helper keeps array kind");
 }
 my ($payload) = grep {$_->{name} eq 'payload'} @{$row->{helpers}};
 is($payload->{input}, $label eq 'value-zero' ? '0' : 'payload', "$title payload helper keeps actual source") if $payload;
 my ($assembly) = grep {$_->{name} eq 'assembly'} @{$row->{helpers}};
 if ($assembly) {
  is_deeply($assembly->{args}, [$label eq 'binding-empty' ? '' : $label eq 'binding-zero' ? '0' : 'BINDING',
   $method, $method =~ /^push_/ ? $label eq 'payload-zero' ? '0' : 'VALUE' : undef], "$title assembly keeps native arguments");
 }
 my ($guard) = grep {$_->{name} eq 'guard'} @{$row->{helpers}};
 if ($guard) {
  is($guard->{method}, $method, "$title guard keeps actual method");
  is($guard->{span_identity}, $label eq 'missing-span' ? 0 : 1, "$title guard keeps actual receiver span");
  is($guard->{inner}, $label eq 'assembly-undefined' ? undef : $label eq 'assembly-empty' ? '' : 'INNER',
   "$title forwards assembly result directly to guard");
 }
}
done_testing;
