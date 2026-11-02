use strict;
use warnings;
require './t/lib/LinkedSpecTest/EmittedValues.pm';
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $owner = '_lower_ast_call_statement';
my @roles = qw(normalize_method_args_with_optional_scope trim_action_ir_value extract_hash_symbol_name lower_scalar_access_key_expr extract_array_symbol_name lower_primitive_literal_expr);
my %route = ($roles[0] => 'return_undef', $roles[1] => 'return', $roles[2] => 'set_key', $roles[3] => 'set_key', $roles[4] => 'push', $roles[5] => 'push');
my %args = (return_undef => [], return => ['LABEL', 'payload'], set_key => ['target', 'key', 'value'], push => ['items', 'payload'], set => ['target', 'value']);
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
sub setup {
 my ($target, $outcome, $options) = @_;
 $options ||= {};
 my $method = $options->{method} // $route{$target};
 my $state = {target => $target, options => $options, trace => [], helpers => [], eligible => [],
  args => [@{$options->{args} // $args{$method} // []}], calls => 0};
 $state->{node} = {kind => 'call', name => $method, source => 'untrusted source', source_span => {start => 2, end => 9}};
 my $fatal = bless {}, 'MethodAstCallFatal';
 my %deps;
 for my $role (@roles) {
  $deps{$role} = sub {
   my $selected = $role eq $target;
   my @before = map {ref($_) eq 'ARRAY' ? [@$_] : $_} @_;
   my $slot = !ref($_[0]) && grep {refaddr(\$_[0]) == refaddr(\$state->{args}[$_])} 0 .. $#{$state->{args}};
   push @{$state->{trace}}, {role => $role, args => \@before,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    error => $@, source_slot => $slot ? 1 : 0,
    actual_args => ref($_[0]) eq 'ARRAY' && refaddr($_[0]) == refaddr($state->{args}) ? 1 : 0};
   if ($selected) {
    ++$state->{calls};
    if (!$options->{no_mutation}) {
     if (ref($_[0]) eq 'ARRAY') { push @{$_[0]}, 'effect' }
     elsif (defined($_[0])) { $_[0] .= '!' }
    }
    $@ = 'successful AST call callback';
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    emit($options->{event}, $options->{publication}) if $options->{event};
   }
   return $options->{$role} if exists $options->{$role};
   return $_[0] if $role eq $roles[0];
   return $before[0] if $role eq $roles[1];
   return 'meta' if $role eq $roles[2];
   return 'KEY' if $role eq $roles[3];
   return 'items' if $role eq $roles[4];
   return 'LITERAL'
  };
 }
 return (\%deps, $deps{$target}, $state, $fatal)
}
sub invoke {
 my ($node, $deps, $state, $expected) = @_;
 my $options = $state->{options};
 no warnings 'redefine';
 # Secondary helpers are explicit controls: the actual call-statement owner,
 # its guards/branches, required calls, aliases and validation order execute.
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  push @{$state->{helpers}}, {name => 'parse', input => $_[0]}; return $options->{parsed}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_call_arg_sources = sub {
  push @{$state->{helpers}}, {name => 'args', actual_node => refaddr($_[0]) == refaddr($state->{node}) ? 1 : 0};
  return $options->{arg_source} if exists $options->{arg_source};
  return $state->{args}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_unsupported_helper_expr = sub {
  push @{$state->{helpers}}, {name => 'unsupported', method => $_[0]}; return 'UNSUPPORTED:'.$_[0]
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub {
  push @{$state->{helpers}}, {name => 'return_payload', input => $_[0],
   source_slot => scalar(grep {refaddr(\$_[0]) == refaddr(\$state->{args}[$_])} 0 .. $#{$state->{args}}),
   deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists($options->{payload}) ? $options->{payload} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement = sub {
  push @{$state->{helpers}}, {name => 'assign', args => [@_[0,1]], deps_identity => refaddr($_[2]) == refaddr($deps) ? 1 : 0};
  return exists($options->{assignment}) ? $options->{assignment} : 'ASSIGN'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {
  push @{$state->{helpers}}, {name => 'mutation', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists($options->{payload}) ? $options->{payload} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  push @{$state->{helpers}}, {name => 'value', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists($options->{payload}) ? $options->{payload} : 'VALUE'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {
  push @{$state->{helpers}}, {name => 'binding', args => [@_[0,1]], deps_identity => refaddr($_[2]) == refaddr($deps) ? 1 : 0};
  return $options->{binding}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr = sub {
  push @{$state->{helpers}}, {name => 'hash_assembly', args => [@_]}; return 'HASH_INNER'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr = sub {
  push @{$state->{helpers}}, {name => 'array_assembly', args => [@_]}; return 'ARRAY_INNER'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_ambiguous_push_expr = sub {
  push @{$state->{helpers}}, {name => 'ambiguous_assembly', args => [@_]}; return 'AMBIGUOUS'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {
  push @{$state->{helpers}}, {name => 'guard', args => [@_[0,1], $_[4]],
   span_identity => refaddr($_[2]) == refaddr($state->{node}{source_span}) ? 1 : 0,
   deps_identity => refaddr($_[3]) == refaddr($deps) ? 1 : 0};
  return $options->{guard} if exists $options->{guard};
  return $_[4]
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement($node, $expected, $deps)
}
sub run_case {
 my ($role, $outcome, $options) = @_;
 my ($deps, $actual, $state, $fatal) = setup($role, $outcome, $options);
 my ($value, $error, $success_error);
 eval { $@ = 'incoming AST call error'; $value = invoke($state->{node}, $deps, $state); $success_error = $@; 1 }
  or $error = $@;
 return {role => $role, outcome => $outcome, value => $value, calls => $state->{calls},
  args_after => $state->{args}, trace => $state->{trace}, helpers => $state->{helpers}, success_error => $success_error,
  node => $state->{node}, map_identity => refaddr($deps->{$role}) == refaddr($actual) ? 1 : 0,
  error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error}
}
sub callbacks {
 return [map {my $role = $_; map {run_case($role, $_)} qw(string undefined fatal)} @roles]
}
sub branch_cases {
 return (
  ['single-return', {method => 'return', args => ['payload']}],
  ['empty-return', {method => 'return', args => []}],
  ['invalid-label', {method => 'return', args => ['bad-label', 'payload']}],
  ['return-payload-fallback', {method => 'return', payload => undef}],
  ['return-payload-empty', {method => 'return', args => ['payload'], payload => ''}],
  ['return-payload-zero', {method => 'return', args => ['payload'], payload => '0'}],
  ['multiple-return-payloads', {method => 'return', args => ['LABEL', 'one', 'two']}],
  ['return-undef-rejected', {method => 'return_undef', $roles[0] => undef}],
  ['set', {method => 'set'}],
  ['set-rejected', {method => 'set', $roles[0] => undef}],
  ['set-empty-assignment', {method => 'set', assignment => ''}],
  ['set-zero-assignment', {method => 'set', assignment => '0'}],
  ['set-invalid-target', {method => 'set', args => ['bad-target', 'value']}],
  ['set-guard-fallback', {method => 'set', guard => ''}],
  ['set-zero-guard', {method => 'set', guard => '0'}],
  ['set-key', {method => 'set_key'}],
  ['set-key-rejected', {method => 'set_key', $roles[0] => undef}],
  ['set-key-empty-target', {method => 'set_key', args => ['', 'key', 'value']}],
  ['set-key-empty-key', {method => 'set_key', args => ['target', '', 'value']}],
  ['set-key-empty-value', {method => 'set_key', args => ['target', 'key', '']}],
  ['set-key-empty-hash', {method => 'set_key', $roles[2] => ''}],
  ['set-key-zero-hash', {method => 'set_key', $roles[2] => '0'}],
  ['set-key-empty-lowered-key', {method => 'set_key', $roles[3] => ''}],
  ['set-key-zero-lowered-key', {method => 'set_key', $roles[3] => '0'}],
  ['set-key-empty-payload', {method => 'set_key', payload => ''}],
  ['set-key-zero-payload', {method => 'set_key', payload => '0'}],
  ['set-key-binding', {method => 'set_key', binding => 'BOUND'}],
  ['set-key-zero-binding', {method => 'set_key', binding => '0'}],
  ['set-key-empty-guard', {method => 'set_key', binding => 'BOUND', guard => ''}],
  ['push', {method => 'push'}],
  ['scoped-push', {method => 'push', args => ['scope', 'items', 'payload']}],
  ['invalid-push-arity', {method => 'push', args => []}],
  ['empty-scoped-push-target', {method => 'push', args => ['scope', '', 'payload']}],
  ['invalid-scoped-push-target', {method => 'push', args => ['scope', 'bad-target', 'payload'], $roles[4] => undef}],
  ['bare-scoped-push-fallback', {method => 'push', args => ['scope', 'items', 'payload'], $roles[4] => undef}],
  ['ambiguous-push', {method => 'push', $roles[5] => undef}],
  ['bare-push-fallback', {method => 'push', $roles[4] => undef}],
  ['empty-push-target', {method => 'push', args => ['', 'payload']}],
  ['empty-push-value', {method => 'push', args => ['items', '']}],
  ['push-value-fallback', {method => 'push', payload => undef}],
  ['push-zero-value', {method => 'push', payload => '0'}],
  ['push-binding', {method => 'push', binding => 'BOUND'}],
  ['push-empty-guard', {method => 'push', binding => 'BOUND', guard => ''}],
  ['unsupported-method', {method => 'other', args => []}],
 )
}
sub branches {
 return [map {my ($label, $options) = @$_; $options = {%$options, no_mutation => 1};
  {case => $label, %{run_case($roles[1], 'string', $options)}}} branch_cases()]
}
sub observations { return {callbacks => callbacks(), branches => branches()} }
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
my %native_string = ($roles[0] => 'return undef', $roles[1] => "return ['?LABEL:',  VALUE]", $roles[2] => '$meta{KEY} = VALUE', $roles[3] => '$meta{KEY} = VALUE', $roles[4] => 'push @items, VALUE', $roles[5] => 'push @items, VALUE');
for my $row (@{callbacks()}) {
 my $label = "$owner/$row->{role}/$row->{outcome}";
 my @selected = grep {$_->{role} eq $row->{role}} @{$row->{trace}};
 is($row->{map_identity}, 1, "$label actual public callback reference stays exact");
 is($row->{calls}, 1, "$label target callback keeps native invocation count");
 is($selected[0]{context}, 'scalar', "$label actual required call retains scalar context");
 is($selected[0]{error}, 'incoming AST call error', "$label native incoming error survives");
 is($selected[0]{actual_args}, $row->{role} eq $roles[0] ? 1 : 0, "$label retains helper-returned ARRAY identity");
 is($selected[0]{source_slot}, $row->{role} eq $roles[1] ? 1 : 0, "$label retains actual ARRAY slot alias versus local scalar copy");
 my $expected = $row->{outcome} eq 'fatal' ? undef : $row->{outcome} eq 'string' || $row->{role} eq $roles[5]
  ? $native_string{$row->{role}} : 'UNSUPPORTED:'.$route{$row->{role}};
 is_deeply(@{LinkedSpecTest::EmittedValues::compare_hash_write($row->{value}, $expected)},
  "$label actual ordinary result preserves current key evaluation");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodAstCallFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else { is($row->{success_error}, 'successful AST call callback', "$label native successful error effect survives") }
 my @expected_args = @{$args{$route{$row->{role}}}};
 push @expected_args, 'effect' if $row->{role} eq $roles[0];
 $expected_args[0] .= '!' if $row->{role} eq $roles[1];
 is_deeply($row->{args_after}, \@expected_args, "$label actual source ARRAY mutation stays native");
 is_deeply($row->{node}, {kind => 'call', name => $route{$row->{role}}, source => 'untrusted source', source_span => {start => 2, end => 9}},
  "$label AST node remains unchanged under explicit source control");
 my @expected_input = $row->{role} eq $roles[0] ? ([], 0, 0)
  : ($row->{role} eq $roles[1] ? 'LABEL' : $row->{role} eq $roles[2] ? 'target' : $row->{role} eq $roles[3] ? 'key' : $row->{role} eq $roles[4] ? 'items' : 'payload');
 is_deeply($selected[0]{args}, \@expected_input, "$label actual callback input/count arguments stay native");
 my @call_order = $row->{role} eq $roles[0] || $row->{role} eq $roles[1] ? ($row->{role})
  : $row->{role} eq $roles[2] || $row->{role} eq $roles[3] ? ($roles[0], ($roles[1]) x 3, $roles[2], $roles[3])
  : ($roles[1], $roles[1], $roles[5], $roles[1], $roles[4], $roles[1]);
 if ($row->{outcome} eq 'fatal' || $row->{outcome} eq 'undefined' && $row->{role} ne $roles[5]) {
  my $target_index = 0; ++$target_index while $call_order[$target_index] ne $row->{role};
  @call_order = @call_order[0 .. $target_index];
 }
 is_deeply([map {$_->{role}} @{$row->{trace}}], \@call_order, "$label required invocation order and short circuit stay native");
}
for my $role (@roles) {
 my $ordinary = run_case($role, 'string')->{value};
 is_deeply(@{LinkedSpecTest::EmittedValues::compare_hash_write($ordinary, $native_string{$role})},
  "$owner/$role current ordinary publication value is independently checked");
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($role, 'string', {event => $event, publication => $ordinary});
   my $outer = sub { return invoke($state->{node}, $deps, $state) };
   producers($known ? [$outer, $actual] : [$outer], sub {
    my $result = capture($outer);
    my $label = "$owner/$role/$known";
    is($result->{value}, $ordinary, "$label equal current ordinary publication value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event), "$label required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$label actual callback has its own identity boundary");
    is($state->{calls}, 1, "$label actual native effect count survives");
    is(refaddr($deps->{$role}), refaddr($actual), "$label original public map keeps actual callback");
   });
  });
 }
}
for my $role (@roles) {
 for my $bad (undef, 'not code') {
  my ($deps, $actual, $state) = setup($role, 'string'); $deps->{$role} = $bad;
  my $error; eval { invoke($state->{node}, $deps, $state); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
   "$owner/$role required dependency diagnostic remains exact");
  is($state->{calls}, 0, "$role invalid dependency is never invoked");
 }
}
for my $bad (undef, [], 'not hash') {
 my ($deps, $actual, $state) = setup($roles[0], 'string');
 my $error; eval { invoke($state->{node}, $bad, $state); 1 } or $error = $@;
 like($error, qr/missing dependency callback 'normalize_method_args_with_optional_scope'/, 'non-HASH map retains first eager required diagnostic');
}
for my $case (
 ['non-node', undef, undef, {}], ['non-call', {kind => 'other'}, undef, {}],
 ['missing-method', {kind => 'call'}, undef, {}], ['empty-method', {kind => 'call', name => ''}, undef, {}],
 ['wrong-method', {kind => 'call', name => 'return'}, 'set', {}],
 ['missing-args', {kind => 'call', name => 'return'}, undef, {arg_source => undef}],
 ['false-args', {kind => 'call', name => 'return'}, undef, {arg_source => '0'}]) {
 my ($label, $node, $expected, $options) = @$case;
 my ($deps, $actual, $state) = setup($roles[1], 'string', $options);
 is(invoke($node, undef, $state, $expected), undef, "$label stops before eager dependency validation");
 is_deeply($state->{trace}, [], "$label invokes no dependency callback");
}
# Lazy requirements retain their actual branch guards, rather than moving into
# a global preflight. Deliberately invalid unused callbacks must stay unused.
for my $case (
 ['return-eager-trim', 'return', ['payload'], $roles[1], undef, 'trim_action_ir_value'],
 ['set-key-normalizer-stop', 'set_key', ['target','key','value'], $roles[2], undef, undef],
 ['push-array-before-arity', 'push', [], $roles[4], undef, 'extract_array_symbol_name'],
 ['push-arity-before-primitive', 'push', [], $roles[5], undef, undef],
 ['push-scoped-guard-before-primitive', 'push', ['scope','','payload'], $roles[5], undef, undef]) {
 my ($label, $method, $arguments, $invalid, $bad, $diagnostic) = @$case;
 my $options = {method => $method, args => $arguments, no_mutation => 1};
 $options->{$roles[0]} = undef if $label eq 'set-key-normalizer-stop';
 my ($deps, $actual, $state) = setup($roles[0], 'string', $options);
 $deps->{$invalid} = $bad;
 my ($value, $error); eval { $value = invoke($state->{node}, $deps, $state); 1 } or $error = $@;
 if (defined $diagnostic) { like($error, qr/missing dependency callback '\Q$diagnostic\E'/, "$label preserves lazy required validation order") }
 else { is($error, undef, "$label preserves lazy required validation order") }
}
my %branch_expected = (
 'single-return' => 'return VALUE', 'empty-return' => 'UNSUPPORTED:return', 'invalid-label' => 'UNSUPPORTED:return',
 'return-payload-fallback' => "return ['?LABEL:',  payload]", 'return-payload-empty' => 'UNSUPPORTED:return', 'return-payload-zero' => 'return 0',
 'multiple-return-payloads' => "return ['?LABEL:',  VALUE, VALUE]", 'return-undef-rejected' => 'UNSUPPORTED:return_undef',
 'set' => 'ASSIGN', 'set-rejected' => 'UNSUPPORTED:set', 'set-empty-assignment' => 'UNSUPPORTED:set', 'set-zero-assignment' => '0',
 'set-invalid-target' => 'ASSIGN', 'set-guard-fallback' => 'ASSIGN', 'set-zero-guard' => '0',
 'set-key' => '$meta{KEY} = VALUE', 'set-key-rejected' => 'UNSUPPORTED:set_key',
 'set-key-empty-target' => 'UNSUPPORTED:set_key', 'set-key-empty-key' => 'UNSUPPORTED:set_key', 'set-key-empty-value' => 'UNSUPPORTED:set_key',
 'set-key-empty-hash' => 'UNSUPPORTED:set_key', 'set-key-zero-hash' => '$0{KEY} = VALUE',
 'set-key-empty-lowered-key' => 'UNSUPPORTED:set_key', 'set-key-zero-lowered-key' => '$meta{0} = VALUE',
 'set-key-empty-payload' => 'UNSUPPORTED:set_key', 'set-key-zero-payload' => '$meta{KEY} = 0',
 'set-key-binding' => 'HASH_INNER', 'set-key-zero-binding' => 'HASH_INNER', 'set-key-empty-guard' => '',
 'push' => 'push @items, VALUE', 'scoped-push' => 'push @items, VALUE', 'invalid-push-arity' => 'UNSUPPORTED:push',
 'empty-scoped-push-target' => undef, 'invalid-scoped-push-target' => undef, 'bare-scoped-push-fallback' => 'push @items, VALUE',
 'ambiguous-push' => 'AMBIGUOUS', 'bare-push-fallback' => 'push @items, VALUE',
 'empty-push-target' => 'UNSUPPORTED:push', 'empty-push-value' => 'UNSUPPORTED:push',
 'push-value-fallback' => 'push @items, payload', 'push-zero-value' => 'push @items, 0',
 'push-binding' => 'ARRAY_INNER', 'push-empty-guard' => '', 'unsupported-method' => undef,
);
for my $row (@{branches()}) {
 my $label = $row->{case};
 is_deeply(@{LinkedSpecTest::EmittedValues::compare_hash_write($row->{value}, $branch_expected{$label})},
  "$label keeps bounded branch semantics and operand order");
 is($row->{error}, undef, "$label retains successful bounded caller path");
 is($row->{map_identity}, 1, "$label keeps actual public callback");
 ok(!grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls keep scalar contexts");
 ok(!grep({!$_->{deps_identity}} grep {exists $_->{deps_identity}} @{$row->{helpers}}), "$label actual downstream dependency map stays exact");

 for my $normalizer (grep {$_->{role} eq $roles[0]} @{$row->{trace}}) {
  my $count = $row->{node}{name} eq 'set_key' ? 3 : $row->{node}{name} eq 'set' ? 2 : 0;
  is_deeply([@{$normalizer->{args}}[1,2]], [$count, $count], "$label normalizer keeps exact branch count contract");
  is($normalizer->{actual_args}, 1, "$label normalizer receives actual source-helper ARRAY");
 }
 for my $payload (grep {$_->{name} eq 'return_payload'} @{$row->{helpers}}) {
  is($payload->{source_slot}, 1, "$label return payload keeps actual ARRAY slice slot alias");
 }
 for my $guard (grep {$_->{name} eq 'guard'} @{$row->{helpers}}) {
  is($guard->{span_identity}, 1, "$label receiver guard retains actual source-span object");
 }
 for my $call (grep {$_->{role} eq $roles[1]} @{$row->{trace}}) {
  is($call->{source_slot}, $label eq 'scoped-push' || $label eq 'bare-scoped-push-fallback' ? ($call == $row->{trace}[0] ? 1 : 0) : 1,
   "$label trim retains actual source ARRAY slot or scoped copy");
 }
}
done_testing;
