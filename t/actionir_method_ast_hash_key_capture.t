use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $key = 'lower_scalar_access_key_expr';
my $name = '_lower_ast_scalar_held_hash_index_assignment_value_node';
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
 return {kind => 'assign_hash_index', name => 'item',
  key => {source => 'key_source'}, value => {source => 'value_source'}}
}
sub setup {
 my ($outcome, $event) = @_;
 my $state = {trace => [], eligible => [], helpers => [], calls => 0, key_result => 'KEY'};
 my $fatal = bless {}, 'MethodAstHashKeyFatal';
 my $actual = sub {
  ++$state->{calls};
  my $node_key = ref($state->{node}) eq 'HASH' ? $state->{node}{key} : undef;
  push @{$state->{trace}}, {args => [@_], error => $@,
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
   node_source_slot => ref($node_key) eq 'HASH' && exists($node_key->{source})
    && refaddr(\$_[0]) == refaddr(\$node_key->{source}) ? 1 : 0};
  $_[0] .= '!' if defined $_[0];
  $@ = 'successful hash key callback';
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  die $fatal if $outcome eq 'fatal';
  return undef if $outcome eq 'undefined';
  emit($event) if $event;
  return $state->{key_result}
 };
 return ({$key => $actual}, $actual, $state, $fatal)
}
sub encoded {
 my ($value, $state, $options) = @_;
 return $value unless ref($value);
 return {type => ref($value),
  same_callback_result => ref($state->{key_result}) && refaddr($value) == refaddr($state->{key_result}) ? 1 : 0,
  same_assembly_result => ref($options->{assembly}) && refaddr($value) == refaddr($options->{assembly}) ? 1 : 0}
}
sub owner {
 my ($node, $deps, $state, $options) = @_;
 $options ||= {};
 $state->{node} = $node;
 no warnings 'redefine';
 # These three secondary helpers have explicit controlled outputs. The
 # actual owner guards, source fallback, dependency call and helper order run.
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub {
  my $role = refaddr($_[0]) == refaddr($node->{key}) ? 'key' : 'value';
  push @{$state->{helpers}}, {name => 'source', role => $role,
   actual_node => refaddr($_[0]) == refaddr($node->{$role}) ? 1 : 0};
  return $options->{'source_'.$role}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {
  push @{$state->{helpers}}, {name => 'payload', input => $_[0],
   deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists($options->{payload}) ? $options->{payload} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr = sub {
  push @{$state->{helpers}}, {name => 'assembly', args => [map {encoded($_, $state, $options)} @_]};
  return exists($options->{assembly}) ? $options->{assembly} : 'VALUE'
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_scalar_held_hash_index_assignment_value_node($node, $deps)
}
sub callbacks {
 my @rows;
 for my $outcome (qw(string undefined fatal)) {
  my ($deps, $actual, $state, $fatal) = setup($outcome);
  my $node = node();
  my $before = JSON::PP->new->canonical->encode($node);
  my ($value, $error, $success_error);
  eval { $@ = 'incoming hash key error'; $value = owner($node, $deps, $state); $success_error = $@; 1 }
   or $error = $@;
  push @rows, {outcome => $outcome, value => $value, calls => $state->{calls},
   trace => $state->{trace}, helpers => $state->{helpers}, success_error => $success_error,
   node_before => $before, node_after => JSON::PP->new->canonical->encode($node),
   map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0,
   error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
 }
 return \@rows
}
sub branches {
 my @cases = (
  ['fallback', {}],
  ['extracted', {source_key => 'EXTRACTED_KEY', source_value => 'EXTRACTED_VALUE'}],
  ['empty-extracted', {source_key => '', source_value => ''}],
  ['missing-key-source', {}, undef, 'key'],
  ['missing-value-source', {}, undef, 'value'],
  ['zero-key-source', {source_key => '0'}],
  ['zero-value-source', {source_value => '0'}],
  ['empty-key-result', {}, ''],
  ['zero-key-result', {}, '0'],
  ['reference-key-result', {}, {marker => 1}],
  ['undefined-payload', {payload => undef}],
  ['empty-payload', {payload => ''}],
  ['zero-payload', {payload => '0'}],
  ['zero-assembly', {assembly => '0'}],
  ['reference-assembly', {assembly => {marker => 1}}],
 );
 my @rows;
 for my $case (@cases) {
  my ($label, $options, $key_result, $missing) = @$case;
  my ($deps, $actual, $state) = setup('string');
  $state->{key_result} = $key_result if defined $key_result;
  my $node = node();
  $node->{$missing}{source} = undef if defined $missing;
  my $before = JSON::PP->new->canonical->encode($node);
  $@ = 'incoming hash key branch';
  my $value = owner($node, $deps, $state, $options);
  push @rows, {case => $label, value => encoded($value, $state, $options),
   calls => $state->{calls}, trace => $state->{trace}, helpers => $state->{helpers},
   node_before => $before, node_after => JSON::PP->new->canonical->encode($node),
   map_identity => refaddr($deps->{$key}) == refaddr($actual) ? 1 : 0};
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
 is($row->{trace}[0]{error}, 'incoming hash key error', "$label native incoming error survives");
 is_deeply($row->{trace}[0]{args}, ['key_source'], "$label actual source fallback supplies the key callback");
 is($row->{trace}[0]{node_source_slot}, 0, "$label callback keeps local key-source scalar copy");
 is($row->{value}, $row->{outcome} eq 'string' ? 'VALUE' : undef, "$label actual ordinary result stays native");
 is_deeply([map {$_->{name}} @{$row->{helpers}}], $row->{outcome} eq 'string' ? [qw(source source payload assembly)] : [qw(source source)],
  "$label actual secondary helper order stays native");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodAstHashKeyFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  is($row->{success_error}, 'successful hash key callback', "$label native successful error effect survives");
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
 is_deeply($state->{helpers}, [], 'valid AST node validates required callback before extracting any source');
}
for my $deps (undef, [], 'not hash') {
 my $error; eval { owner(node(), $deps, {helpers => []}); 1 } or $error = $@;
 like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
  'valid AST with non-hash map retains required diagnostic');
}
for my $node (undef, [], {}, {kind => 'other', name => 'item'},
 {kind => 'assign_hash_index'}, {kind => 'assign_hash_index', name => 'bad-name'}, {kind => 'assign_hash_index', name => '9item'}) {
 my $state = {helpers => []};
 is(owner($node, undef, $state), undef, 'invalid node or target stops before dependency validation');
 is_deeply($state->{helpers}, [], 'invalid node or target stops before source extraction');
}
for my $row (@{branches()}) {
 my $label = $row->{case};
 is($row->{map_identity}, 1, "$label keeps actual public callback");
 is($row->{node_after}, $row->{node_before}, "$label keeps actual AST fields unchanged");
 my $stops_before_key = $label =~ /^missing-/;
 is($row->{calls}, $stops_before_key ? 0 : 1, "$label keeps actual key callback reachability");
 is_deeply([map {$_->{actual_node}} grep {$_->{name} eq 'source'} @{$row->{helpers}}], [1, 1],
  "$label source controls receive actual key and value nodes");
 my $expected = $label =~ /^(?:missing-|empty-key-result|undefined-payload|empty-payload)/ ? undef
  : $label eq 'zero-assembly' ? '0'
  : $label eq 'reference-assembly' ? {type => 'HASH', same_callback_result => 0, same_assembly_result => 1} : 'VALUE';
 is_deeply($row->{value}, $expected, "$label keeps bounded native result");
 if (!$stops_before_key) {
  is_deeply($row->{trace}[0]{args}, [$label eq 'extracted' ? 'EXTRACTED_KEY' : $label eq 'zero-key-source' ? '0' : 'key_source'],
   "$label preserves extracted-versus-fallback key source");
 }
 my ($payload) = grep {$_->{name} eq 'payload'} @{$row->{helpers}};
 if ($payload) {
  is_deeply($payload, {name => 'payload', input => $label eq 'extracted' ? 'EXTRACTED_VALUE' : $label eq 'zero-value-source' ? '0' : 'value_source', deps_identity => 1},
   "$label payload control receives actual source and dependency map");
 }
 my ($assembly) = grep {$_->{name} eq 'assembly'} @{$row->{helpers}};
 if ($assembly) {
  is_deeply($assembly->{args}, ['item', $label eq 'zero-key-result' ? '0' : $label eq 'reference-key-result'
    ? {type => 'HASH', same_callback_result => 1, same_assembly_result => 0} : 'KEY', $label eq 'zero-payload' ? '0' : 'VALUE'],
   "$label final assembly receives actual target and lowered values");
 }
}
done_testing;
