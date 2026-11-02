use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @eager = qw(trim_action_ir_value split_action_ir_statements parse_method_function_expr
 normalize_method_args_with_optional_scope lower_direct_nested_access_value_expr
 extract_array_symbol_name extract_hash_symbol_name extract_scalar_symbol_name
 lower_scalar_access_key_expr lower_primitive_literal_expr infer_scalar_container_kind
 split_top_level_csv lower_array_pipeline_expr strip_literal_delimiters);
my @invoked = grep { $_ ne 'infer_scalar_container_kind' } @eager;
push @invoked, 'lower_declare_initializer_expr';
my $owner_name = '_lower_method_value_expr';
my $json = JSON::PP->new->canonical;
{
 package MethodValueDependencyReads;
 sub TIEHASH { bless {values => $_[1], reads => $_[2]}, $_[0] }
 sub FETCH {push @{$_[0]{reads}}, $_[1]; return $_[0]{values}{$_[1]}}
}
sub identity { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub copied {
 my ($value) = @_;
 return $value unless ref($value);
 return [map { copied($_) } @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => copied($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub node {
 my ($which) = @_;
 return {kind => 'assign_hash_index', name => 'meta',
  key => {kind => 'raw_perl', source => 'key'}, value => {kind => 'raw_perl', source => 'payload'},
  source_span => {start => 17, end => 99}} if $which eq 'key';
 return {kind => 'call', name => 'set', source => 'SET',
  args => [{kind => 'call', name => $which eq 'hash' ? 'hash' : 'array',
   args => [{kind => 'variable', name => 'meta'}]},
   {kind => $which eq 'hash' ? 'hash_literal' : 'array_literal', items => [], entries => [], source => 'SHAPE'}],
  source_span => {start => 17, end => 99}};
}
sub scenario {
 my ($role) = @_;
 return 'trim' if $role eq 'trim_action_ir_value';
 return 'block' if $role eq 'split_action_ir_statements';
 return 'entry' if $role eq 'parse_method_function_expr' || $role eq 'normalize_method_args_with_optional_scope';
 return 'array' if $role eq 'extract_array_symbol_name';
 return 'hash' if $role eq 'extract_hash_symbol_name';
 return 'scalar' if $role eq 'extract_scalar_symbol_name';
 return 'key' if $role eq 'lower_scalar_access_key_expr';
 return 'shape' if $role eq 'split_top_level_csv';
 return 'strip' if $role eq 'strip_literal_delimiters';
 return 'initializer' if $role eq 'lower_declare_initializer_expr';
 return 'plain';
}
sub setup {
 my ($role, $outcome, $options) = @_;
 $options ||= {};
 my $which = $options->{scenario} || scenario($role);
 my %inputs = (trim => 'TRIM', entry => 'ENTRY', array => 'COUNT', hash => 'KEYS', scalar => 'EMPTY',
  key => 'AST_KEY', shape => '[LIT]', strip => 'RECORDS', initializer => 'AST_SET', block => 'BLOCK_EMPTY', plain => 'PLAIN');
 my $state = {role => $role, outcome => $outcome, scenario => $which, options => $options,
  input => exists($options->{input}) ? $options->{input} : $inputs{$which}, trace => [], helpers => [], eligible => [], calls => 0,
  args => [], items => ['LIT'], statements => ['RETURN'], span => {start => 3, end => 8},
  node => node($which eq 'key' ? 'key' : $options->{hash} ? 'hash' : 'array')};
 # Emptiness now delegates to the generic value owner. Exercise statement
 # splitting through the still-active flat/block classification path instead.
 if ($role eq 'split_action_ir_statements' || $options->{statement_path}) {
  $state->{input} = '[FLAT_BLOCK]';
  $state->{items} = ['FLAT_BLOCK'];
 }
 $state->{input} = 'FILTER' if $role eq 'strip_literal_delimiters';
 # Bare scalar reads no longer call the legacy extractor. Its active AST
 # declaration fallback still selects the actual required callback.
 if ($role eq 'extract_scalar_symbol_name') {
  $state->{input} = 'AST_SCALAR';
  $state->{node} = {kind => 'call', name => 'set', source => 'AST_SCALAR', args => [
   {kind => 'raw_perl', source => 'value'}, {kind => 'array_literal', items => [], source => '[]'}]};
 }
 my $fatal = bless {}, 'MethodValueFatal';
 my %deps;
 my $ordinary = sub {
  my ($name, @args) = @_;
  return $args[0] if $name eq 'trim_action_ir_value';
  return $state->{statements} if $name eq 'split_action_ir_statements';
  if ($name eq 'parse_method_function_expr') {
   my %calls = (ENTRY => ['entry_text', []], COUNT => ['count', ['items']], KEYS => ['count_keys', ['meta']],
    EMPTY => ['is_empty', ['value']], RECORDS => ['split_tagged_records', ['LIT', 'sep', 'TAG']],
    BLOCK_EMPTY => ['is_empty', ['{BLOCK}']], RETURN => ['return', ['array(items)']],
    HAS => ['has_key', ['meta', 'BAD_KEY']], BAD_KEY => ['count', []],
    FLAT_BLOCK => ['flat', ['{BLOCK}']],
    FILTER => ['filter_match', ['LIT', '"needle"']]);
   $calls{PROFILE} = [$options->{method}, $options->{args}] if $options->{method};
   return undef unless exists $calls{$args[0] // ''};
   my ($method, $values) = @{$calls{$args[0]}};
   my $call = {method => $method, args => [@$values]};
   $state->{args} = $call->{args} unless $args[0] eq 'RETURN';
   return $call;
  }
  return $args[0] if $name eq 'normalize_method_args_with_optional_scope';
  return 'VALUE' if $name eq 'lower_direct_nested_access_value_expr' && $role eq $name;
  return 'items' if $name eq 'extract_array_symbol_name' && $which eq 'array';
  return 'meta' if $name eq 'extract_hash_symbol_name' && ($which eq 'hash' || $which eq 'legacy-key');
  return 'value' if $name eq 'extract_scalar_symbol_name' && $which eq 'scalar';
  return 'KEY' if $name eq 'lower_scalar_access_key_expr';
  if ($name eq 'lower_primitive_literal_expr') {
   return 'VALUE' if $which eq 'trim' || $role eq $name || ($args[0] // '') eq 'LIT';
   return '[VALUE]' if ($args[0] // '') eq '{BLOCK}';
   return 'FALLBACK' if $which eq 'initializer';
   return undef;
  }
  die 'locally validation-only inference was invoked' if $name eq 'infer_scalar_container_kind';
  return $state->{items} if $name eq 'split_top_level_csv';
  return 'VALUE' if $name eq 'lower_array_pipeline_expr' && $role eq $name;
  return 'sep' if $name eq 'strip_literal_delimiters';
  return 'INIT' if $name eq 'lower_declare_initializer_expr';
  return undef;
 };
 for my $name (@eager, 'lower_declare_initializer_expr') {
  my $actual = sub {
   my @args = map {copied($_)} @_;
   my $context = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
   my $target = $name eq $role;
   my @readonly = map {Internals::SvREADONLY($_) ? 1 : 0} @_;
   push @{$state->{trace}}, {role => $name, context => $context, args => \@args, error => $@, readonly => \@readonly,
    original_input_slot => @_ ? identity(\$_[0], \$state->{input}) : 0,
    parser_array => @_ ? identity($_[0], $state->{args}) : 0,
    parser_slot => @_ && @{$state->{args}} ? identity(\$_[0], \$state->{args}[0]) : 0,
    csv_slot => @_ ? identity(\$_[0], \$state->{items}[0]) : 0,
    statement_slot => @_ ? identity(\$_[0], \$state->{statements}[0]) : 0,
    actual_span => @_ > 1 ? identity($_[1], $state->{span}) : 0};
   my $result = $ordinary->($name, @_);
   if ($target) {
    $result = $options->{callback_result} if exists $options->{callback_result};
    ++$state->{calls};
    $_[0] .= '!' if @_ && defined($_[0]) && !ref($_[0]) && !$readonly[0];
    $_[1] .= '!' if $name eq 'lower_declare_initializer_expr' && @_ > 1 && !$readonly[1];
    $_[0][0] .= '!' if @_ && ref($_[0]) eq 'ARRAY' && @{$_[0]};
    $state->{mutation} = @_ ? copied($_[0]) : undef;
    $@ = 'successful method value callback';
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    if ($state->{event} && $state->{calls} == 1) {
     my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $state->{publication});
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   if ($name eq 'trim_action_ir_value' && exists($options->{replace_key}) && !$state->{key_replaced}++) {
    $deps{lower_scalar_access_key_expr} = $options->{replace_key} eq 'bad' ? 'not code' : sub {
     ++$state->{replacement_calls}; return 'NEW';
    };
   }
   return $result;
  };
  $deps{$name} = $actual;
 }
 $deps{actionir_source_span} = $state->{span};
 $deps{__actionir_ast_value_lowering_compat_bridge} = 1 unless $which eq 'key' || $which eq 'initializer';
 delete $deps{__actionir_ast_value_lowering_compat_bridge} if $role eq 'extract_scalar_symbol_name';
 $state->{actual} = $deps{$role};
 $state->{node} = $options->{node} if exists $options->{node};
 return (\%deps, $state, $fatal);
}
sub owner {
 my ($deps, $state) = @_;
 no warnings 'redefine';
 # Explicit secondary-helper controls leave all acquisition, invocation,
 # local adapters, guards and generated text in the actual production owner.
 my $helper = sub {
  my ($name, @args) = @_;
  push @{$state->{helpers}}, {name => $name, args => [map {copied($_)} grep {!ref($_) || ref($_) ne 'HASH'} @args],
   actual_map => scalar(grep {identity($_, $deps)} @args) ? 1 : 0};
  return undef;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  $helper->('ast', @_);
  return $state->{node} if $state->{scenario} eq 'key' || $state->{scenario} eq 'initializer'
   || $state->{role} eq 'extract_scalar_symbol_name';
  return undef;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr = sub {$helper->('hash_receiver', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_string_receiver_value_chain_expr = sub {$helper->('string_receiver', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_number_receiver_value_chain_expr = sub {$helper->('number_receiver', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_array_receiver_value_chain_expr = sub {$helper->('array_receiver', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {$helper->('scalar_read', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_user_function_scalar_value_name = sub {return 0};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_expr = sub {$helper->('block', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_infer_assignment_source_container_kind = sub {$helper->('infer', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_scalar_held_hash_index_assignment_value_node = sub {
  $helper->('scalar_held', @_); return $state->{options}{scalar_held};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {$helper->('payload', @_); return 'VALUE'};
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked = sub {$helper->('tracked', @_); return 1};
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {
  $helper->('guard', @_); $state->{guard_span} = copied($_[2]);
  $state->{new_guard_span} = !identity($_[2], $state->{node}{source_span}) ? 1 : 0;
  return 'VALUE';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_method_tag_expr = sub {$helper->('tag', @_); return 'TAG'};
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_first_unknown_value_call_name = sub {$helper->('unknown', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_unsupported_helper_expr = sub {return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_contextual_codeblock_call_node = sub {return {node => $_[2]}};
 local *LinkedSpec::ActionIR::MethodLowering::_extract_outer_brace_payload = sub {
  $helper->('brace', $_[0]);
  return $_[1]->('RETURN');
 };
 local *LinkedSpec::ActionIR::MethodLowering::_has_top_level_fat_arrow = sub {return 0};
 return LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr($state->{input}, $deps);
}
sub observe {
 my ($role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup($role, $outcome, $options);
 my ($value, $error, $success_error);
 eval {$@ = 'incoming method value error'; $value = owner($deps, $state); $success_error = $@; 1} or $error = $@;
 return {role => $role, outcome => $outcome, value => copied($value), calls => $state->{calls},
  trace => $state->{trace}, helpers => $state->{helpers}, mutation => $state->{mutation},
  input_after => $state->{input}, args_after => $state->{args}, items_after => $state->{items},
  statements_after => $state->{statements}, node_after => $state->{node}, span_after => $state->{span},
  success_error => $success_error, map_identity => identity($deps->{$role}, $state->{actual}),
  guard_span => $state->{guard_span}, new_guard_span => $state->{new_guard_span},
  replacement_calls => $state->{replacement_calls} || 0,
  error => ref($error) ? {type => ref($error), same_fatal => identity($error, $fatal)} : $error};
}
sub branch_cases {
 my @cases = (
  ['trim-parser-slot', 'trim_action_ir_value', {scenario => 'array'}],
  ['trim-csv-slot', 'trim_action_ir_value', {scenario => 'shape'}],
  ['trim-constructor-slot', 'trim_action_ir_value', {scenario => 'plain', input => 'array(LIT)'}],
  ['trim-statement-slot', 'trim_action_ir_value', {scenario => 'block', statement_path => 1}],
  ['initializer-hash', 'lower_declare_initializer_expr', {hash => 1}],
  ['key-reacquired', 'lower_scalar_access_key_expr', {replace_key => 'new'}],
  ['key-lazy-invalid', 'lower_scalar_access_key_expr', {replace_key => 'bad'}],
  ['key-eager-retained', 'lower_scalar_access_key_expr', {scenario => 'legacy-key', input => 'HAS', replace_key => 'new'}],
  ['key-fast-path', 'lower_scalar_access_key_expr', {scalar_held => 'FAST'}],
 );
 for my $method (['entry_text', [], [0, 0]], ['count', ['items'], [1, 1]],
  ['substr', ['LIT', '0', '1'], [2, 3, 1]], ['cat', ['LIT', 'LIT'], [2, undef, 1]],
  ['take', ['items', '1'], [1, 2, 1]]) {
  push @cases, ['normalize-'.$method->[0], 'normalize_method_args_with_optional_scope',
   {scenario => 'plain', input => 'PROFILE', method => $method->[0], args => $method->[1], arity => $method->[2]}];
 }
 for my $role (qw(lower_primitive_literal_expr lower_scalar_access_key_expr lower_declare_initializer_expr)) {
  push @cases, [$role.'/empty', $role, {callback_result => ''}], [$role.'/zero', $role, {callback_result => '0'}];
 }
 my $mismatch = node('array'); $mismatch->{args}[1]{kind} = 'hash_literal';
 push @cases, ['initializer-type-mismatch', 'lower_declare_initializer_expr', {node => $mismatch}];
 my $bad_target = node('array'); $bad_target->{args}[0]{args}[0]{name} = 'bad target';
 push @cases, ['initializer-invalid-target', 'lower_declare_initializer_expr', {node => $bad_target}];
 my $bad_value = node('array'); $bad_value->{args}[1] = undef;
 push @cases, ['initializer-missing-value', 'lower_declare_initializer_expr', {node => $bad_value}];
 return \@cases;
}
sub observations {
 return {callbacks => [map {my $role = $_; map {observe($role, $_)} qw(string undefined fatal)} @invoked],
  branches => [map {{case => $_->[0], %{observe($_->[1], 'string', $_->[2])}}} @{branch_cases()}]};
}
if (@ARGV && $ARGV[0] eq 'observe') {print $json->encode(observations()), "\n"; exit 0}

for my $role (@invoked) {
 for my $outcome (qw(string undefined fatal)) {
  my $row = observe($role, $outcome);
  my $title = "$role/$outcome";
  ok($row->{calls} >= 1, "$title reaches actual required callback");
  is($row->{map_identity}, 1, "$title keeps actual public callback");
  my @calls = grep {$_->{role} eq $role} @{$row->{trace}};
  is_deeply([map {$_->{context}} @calls], [map {'scalar'} @calls], "$title keeps native scalar context");
  is_deeply([map {$_->{original_input_slot}} @calls], [map {0} @calls], "$title keeps local expression copy");
  if ($outcome eq 'fatal') {
   is_deeply($row->{error}, {type => 'MethodValueFatal', same_fatal => 1}, "$title preserves actual fatal object");
  } else {
   is($row->{error}, undef, "$title native route completes");
   is($row->{success_error}, 'successful method value callback', "$title preserves successful error effect");
  }
 }
 my $baseline = observe($role, 'string');
 ok(defined($baseline->{value}) && length($baseline->{value}), "$role ordinary baseline can distinguish publication");
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my ($deps, $state) = setup($role, 'string');
   $state->{event} = $event; $state->{publication} = $baseline->{value};
   my $outer = sub {return owner($deps, $state)};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(
    $known ? [$outer, $state->{actual}] : [$outer], sub {
     my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
     is($result->{value}, $baseline->{value}, "$role/$known ordinary value survives");
     ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
      "$role/$known required dependency cannot donate nested publication");
     is($state->{eligible}[0], $known, "$role/$known actual callback has its own identity boundary");
     is($state->{calls}, $baseline->{calls}, "$role/$known native effect count survives");
     is(identity($deps->{$role}, $state->{actual}), 1, "$role/$known public callback stays actual");
    });
  });
 }
}
for my $name (@eager) {
 for my $bad (undef, 'not code') {
  my ($deps, $state) = setup('lower_primitive_literal_expr', 'string');
  $deps->{$name} = $bad; $state->{input} = undef;
  my $error; eval {owner($deps, $state); 1} or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$name\E'/,
   "$name eager diagnostic precedes undefined-input guard");
  is_deeply($state->{trace}, [], "$name eager validation precedes all required invocation");
 }
}
for my $input (undef, '') {
 my ($deps, $state) = setup('lower_primitive_literal_expr', 'string');
 $state->{input} = $input; $deps->{lower_declare_initializer_expr} = 'not code';
 is(owner($deps, $state), undef, 'unreachable lazy initializer is not validated');
 is($state->{calls}, 0, 'empty input stops before primitive invocation');
}
{
 my ($deps, $state) = setup('lower_primitive_literal_expr', 'string');
 $state->{input} = undef;
 my @reads; tie my %read_map, 'MethodValueDependencyReads', $deps, \@reads;
 is(owner(\%read_map, $state), undef, 'valid eager callbacks precede undefined-input return');
 is_deeply([@reads[0..$#eager]], \@eager, 'eager acquisition order remains exact');
 is_deeply($state->{trace}, [], 'undefined input invokes none of the validated callbacks');
 my $row = observe('lower_primitive_literal_expr', 'string');
 is(scalar(grep {$_->{role} eq 'infer_scalar_container_kind'} @{$row->{trace}}), 0,
  'locally unused inference is validated without local invocation');
}
for my $bad (undef, 'not code') {
 my ($deps, $state) = setup('lower_declare_initializer_expr', 'string');
 $deps->{lower_declare_initializer_expr} = $bad;
 my $error; eval {owner($deps, $state); 1} or $error = $@;
 like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback 'lower_declare_initializer_expr'/,
  'lazy initializer diagnostic follows valid aggregate target and shape');
}
my $observed = observations();
for my $row (@{$observed->{branches}}) {
 my $label = $row->{case};
 my @target = grep {$_->{role} eq $row->{role}} @{$row->{trace}};
 is_deeply([map {$_->{context}} @target], [map {'scalar'} @target], "$label retains native callback contexts");
 if ($label =~ /^trim-(parser|constructor|statement)-slot$/) {
  my $field = $1 eq 'parser' ? 'parser_slot' : $1 eq 'constructor' ? 'csv_slot' : 'statement_slot';
  ok(grep($_->{$field}, @target), "$label keeps actual returned-array scalar alias");
 }
 if ($label eq 'trim-csv-slot') {
  ok(!grep($_->{csv_slot}, @target), 'shape member trimming keeps local scalar copy of CSV slot');
  is_deeply($row->{items_after}, ['LIT'], 'shape member trim mutation leaves actual CSV array unchanged');
 }
 if ($label =~ /^normalize-/) {
  my ($case) = grep {$_->[0] eq $label} @{branch_cases()};
  is($target[0]{parser_array}, 1, "$label receives actual parser-returned array");
  is_deeply([@{$target[0]{args}}[1..$#{$target[0]{args}}]], $case->[2]{arity}, "$label keeps arity and scope flag");
  is_deeply($row->{args_after}, @{$case->[2]{args}} ? [($case->[2]{args}[0].'!'), @{$case->[2]{args}}[1..$#{$case->[2]{args}}]] : [],
   "$label preserves shared parser-array mutation");
 }
 if ($label eq 'key-reacquired') {
  is($row->{calls}, 0, 'AST adapter does not invoke stale eager key callback');
  is($row->{replacement_calls}, 1, 'AST adapter reacquires actual changed key callback');
  is($row->{value}, 'VALUE', 'AST key reacquisition preserves guard result');
  is_deeply($row->{guard_span}, {start => 17, end => 21}, 'main AST key adapter builds target-only span');
  is($row->{new_guard_span}, 1, 'main AST key adapter keeps original span distinct');
 } elsif ($label eq 'key-eager-retained') {
  is($row->{calls}, 1, 'legacy key path retains original eager callback');
  is($row->{replacement_calls}, 0, 'legacy key path does not reacquire changed callback');
 } elsif ($label eq 'key-lazy-invalid') {
  like($row->{error}, qr/missing dependency callback 'lower_scalar_access_key_expr'/,
   'main AST key reacquisition revalidates changed callback');
 } elsif ($label eq 'initializer-hash') {
  is_deeply($target[0]{args}, ['hash', '{}'], 'lazy hash initializer keeps native kind/source arguments');
 } elsif ($label =~ /^initializer-(?:type-mismatch|invalid-target|missing-value)$/) {
  is($row->{calls}, 0, "$label stops before lazy initializer invocation");
 } elsif ($label eq 'key-fast-path') {
  is($row->{calls}, 0, 'scalar-held AST path bypasses local key invocation');
 }
}
{
 my $row = observe('lower_declare_initializer_expr', 'string');
 my ($call) = grep {$_->{role} eq 'lower_declare_initializer_expr'} @{$row->{trace}};
 is_deeply($call->{readonly}, [1, 0], 'initializer keeps read-only kind literal and writable local source copy');
 is_deeply($call->{args}, ['array', '[]'], 'initializer receives actual local shape source');
 is($row->{node_after}{args}[1]{source}, 'SHAPE', 'initializer source mutation leaves actual AST field unchanged');
 my $pipeline = observe('lower_array_pipeline_expr', 'string');
 my ($pipeline_call) = grep {$_->{role} eq 'lower_array_pipeline_expr'} @{$pipeline->{trace}};
 is($pipeline_call->{actual_span}, 1, 'pipeline callback retains actual source-span reference');
}
done_testing;
