package LinkedSpec::CodeblockRuntime;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed reftype refaddr);
use Storable qw(dclone);
use Hash::Util::FieldHash qw(fieldhash);
use LinkedSpec::RuntimeLogical ();
use LinkedSpec::BindingRuntime ();
use LinkedSpec::CallableContract ();

# Execute version-1 callable-codeblock records as typed data. Generated handlers
# provide explicit references to caller working slots; this module never captures
# a lexical environment and never stores a host coderef in the record.
fieldhash my %codeblock_origins;

sub _codeblock_origin {
 my ($record) = @_;
 my $key = ref($record->{body_ast}) eq 'HASH' ? $record->{body_ast} : $record;
 return $codeblock_origins{$key} ||= {};
}

sub _inherit_codeblock_origin {
 my ($source, $copy) = @_;
 my $key = ref($copy->{body_ast}) eq 'HASH' ? $copy->{body_ast} : $copy;
 $codeblock_origins{$key} = _codeblock_origin($source);
}

sub _copy_codeblock_origins {
 my ($source, $copy, $seen) = @_;
 return unless ref($source) && ref($copy);
 return if $seen->{refaddr($source)}++;
 my $kind = reftype($source) // '';
 if ($kind eq 'HASH') {
  _inherit_codeblock_origin($source, $copy) if ($source->{kind} // '') eq 'codeblock_literal';
  _copy_codeblock_origins($source->{$_}, $copy->{$_}, $seen) for keys %$source;
 } elsif ($kind eq 'ARRAY') {
  _copy_codeblock_origins($source->[$_], $copy->[$_], $seen) for 0 .. $#$source;
 }
}

sub _error {
 my ($code, %fields) = @_;
 die LinkedSpec::CodeblockRuntime::Error->new(
  code => $code,
  %fields,
 )
}

sub _copy_value {
 my ($value) = @_;
 return $value unless ref($value);
 my $copy = dclone($value);
 # Weak AST keys carry only an opaque identity marker. Copies remain the
 # same callable, while independently constructed equal records stay distinct.
 _copy_codeblock_origins($value, $copy, {});
 return $copy
}

sub _value_kind {
 my ($value) = @_;
 return 'codeblock'
  if ref($value) eq 'HASH' && ($value->{kind} // '') eq 'codeblock_literal';
 return 'array' if ref($value) eq 'ARRAY';
 return 'harray' if ref($value) eq 'HASH';
 return 'scalar'
}

sub _is_scalar_binding_ref {
 my ($value) = @_;
 my $type = reftype($value) // '';
 return ($type eq 'SCALAR' || $type eq 'REF') ? 1 : 0
}

sub read_path {
 my ($value, $segments) = @_;
 _error('invalid_codeblock_access_path') unless ref($segments) eq 'ARRAY';
 foreach my $key (@$segments) {
  return undef unless defined $value;
  if (ref($value) eq 'HASH') {
   $value = $value->{$key};
   next;
  }
  if (ref($value) eq 'ARRAY' && defined($key) && $key =~ /\A\d+\z/) {
   $value = $value->[$key];
   next;
  }
  return undef;
 }
 return $value
}

sub reject_keyword_arguments {
 my ($got) = @_;
 $got = 1 unless defined($got) && $got =~ /\A\d+\z/;
 _error(
  'codeblock_keyword_arguments_unsupported',
  expected => 'positional arguments',
  got => 0 + $got,
 )
}

sub require_codeblock_value {
 my ($value) = @_;
 _error('final_argument_not_codeblock', value_kind => _value_kind($value))
  unless ref($value) eq 'HASH' && ($value->{kind} // '') eq 'codeblock_literal';
 return $value
}

sub _binding_ref {
 my ($ctx, $name) = @_;
 _error('invalid_codeblock_binding', name => defined($name) ? $name : '')
  unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/;
 my $binding = $ctx->{bindings}{$name};
 return $binding if _is_scalar_binding_ref($binding);
 my $value;
 $ctx->{bindings}{$name} = \$value;
 return $ctx->{bindings}{$name}
}

sub _read_binding {
 my ($ctx, $name) = @_;
 my $binding = _binding_ref($ctx, $name);
 return $$binding
}

sub _write_binding {
 my ($ctx, $name, $value) = @_;
 my $binding = _binding_ref($ctx, $name);
 $$binding = $value;
 return $value
}

sub _scalar_text {
 my ($value) = @_;
 return undef unless defined $value;
 if (ref($value)) {
  return $value ? '1' : '0'
   if blessed($value) && $value->isa('JSON::PP::Boolean');
  return undef;
 }
 my $text = "$value";
 $text = '0' if $text =~ /\A-0(?:\.0+)?\z/;
 return $text
}

sub enter_function {
 my ($invocation, $name) = @_;
 my $active = $invocation->{active_functions} || [];
 _error('invalid_codeblock_invocation_context') unless ref($active) eq 'ARRAY';
 for (my $idx = 0; $idx < @$active; ++$idx) {
  next unless $active->[$idx] eq $name;
  _error('user_function_recursion_unsupported', function_name => $name,
   cycle => [@$active[$idx .. $#$active], $name]);
 }
 return [@$active, $name]
}

sub _eval_registered_function {
 my ($node, $ctx, $entry) = @_;
 my $name = $node->{name};
 my $args = $node->{args};
 my $signature = $entry->{signature};
 _error('invalid_registered_function', function_name => $name)
  unless ref($signature) eq 'HASH' && ref($signature->{positional_params}) eq 'ARRAY';
 my $keywords = grep {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq 'raw_perl'
   && ($_->{source} // '') =~ /\A\s*[A-Za-z_][A-Za-z0-9_]*\s*:/s
 } @$args;
 _error('user_function_keyword_arguments_unsupported', function_name => $name,
  got => 0 + $keywords, arguments_evaluated => 0) if $keywords;
 my $argc = scalar @$args;
 my ($min, $max) = @{$signature}{qw(min_arity max_arity)};
 if (!defined($min) || $argc < $min || (defined($max) && $argc > $max)) {
  my $expected = defined($max) && $max == $min ? "exactly $min" : "at least $min";
  _error('user_function_arity_mismatch', function_name => $name,
   expected => $expected, got => $argc, arguments_evaluated => 0);
 }
 # Check active calls before operands; the compiled central lowerer installs
 # and localizes the new function frame for both dynamic and nested static calls.
 enter_function($ctx->{invocation}, $name);
 if (ref($entry->{lowering_error}) eq 'HASH') {
  my %failure = %{$entry->{lowering_error}};
  my $code = delete $failure{code};
  _error($code, %failure);
 }
 _error('invalid_registered_function', function_name => $name)
  unless ref($entry->{call}) eq 'CODE';

 my @arguments = @$args;
 my $contract = $entry->{final_codeblock_contract};
 if (ref($contract) eq 'HASH' && @arguments
  && ref($arguments[-1]) eq 'HASH' && ($arguments[-1]{kind} // '') eq 'block_value') {
  _error('final_argument_not_codeblock', value_kind => 'block')
   unless LinkedSpec::CallableContract::accepts_argument_count($contract, $#arguments);
  $arguments[-1] = LinkedSpec::CallableContract::contextual_argument_from_block($arguments[-1]);
  _error('invalid_codeblock_body') unless ref($arguments[-1]) eq 'HASH';
 }
 my @values = map {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq 'codeblock_argument'
   ? _copy_value(LinkedSpec::CallableContract::runtime_record_from_argument($_))
   : _eval_expr($_, $ctx)
 } @arguments;
 require_codeblock_value($values[-1]) if ref($contract) eq 'HASH';
 return $entry->{call}->(\@values, $ctx->{invocation})
}

sub _eval_call {
 my ($node, $ctx) = @_;
 my $name = $node->{name} // '';
 my $args = $node->{args};
 _error('invalid_codeblock_body', detail => 'call arguments must be an array')
  unless ref($args) eq 'ARRAY';

 if ($name eq 'matches') {
  _error('helper_arity_mismatch', helper_name => $name,
   actual_arity => scalar(@$args), expected_arity => 'exactly 2',
   arguments_evaluated => 0,
  ) unless @$args == 2;
  my $value = _eval_expr($args->[0], $ctx);
  # The compiled helper skips its pattern operand for an undefined subject.
  return 0 unless defined $value;
  my $operand = $args->[1];
  my $pattern;
  if (ref($operand) eq 'HASH' && ($operand->{kind} // '') eq 'regex') {
   $pattern = $operand->{pattern};
   my $flags = $operand->{flags} // '';
   # Global/continue flags cannot change this first-match boolean on a fresh
   # subject. Compile-once and capture-preservation flags expose no value here.
   $flags =~ s/[gcop]//g;
   $pattern = '(?'.$flags.')'.$pattern if length $flags;
  } else {
   $pattern = _eval_expr($operand, $ctx);
  }
  my ($result, $failure);
  my $ok = eval { $result = ($value =~ /$pattern/) ? 1 : 0; 1 };
  unless ($ok) {
   $failure = $@;
   my $runtime_file = __FILE__;
   $failure =~ s/ at \Q$runtime_file\E line \d+\.?\n?\z//;
   _error('invalid_matches_pattern', detail => $failure,
    source_span => $operand->{source_span});
  }
  return $result
 }

 if ($name eq 'push') {
  _error(
   'helper_arity_mismatch', helper_name => $name,
   actual_arity => scalar(@$args), expected_arity => 'exactly 2',
   arguments_evaluated => 0,
  ) unless @$args == 2;
  my ($target, $item) = @$args;
  _error('unknown_helper', name => $name)
   unless ref($target) eq 'HASH' && ($target->{kind} // '') eq 'variable';

  # Evaluate operands before taking the publication snapshot. The item may
  # rebind the target, so the first operand's value is deliberately not reused.
  _eval_expr($target, $ctx);
  my $value = _eval_expr($item, $ctx);
  my $target_name = $target->{name};
  my $invocation = $ctx->{invocation};
  if (ref($item) eq 'HASH' && ($item->{kind} // '') eq 'variable'
   && ref($invocation->{descriptor}) eq 'HASH') {
   my $entry = $invocation->{descriptor}{spec}{$target_name};
   my $handler = ref($entry) eq 'CODE' ? $entry
    : ref($entry) eq 'HASH' ? $entry->{handler} : undef;
   if (ref($handler) eq 'CODE') {
    $value = $handler->(
     $invocation->{descriptor}, $invocation->{input}, $invocation->{match_info},
    );
    $target_name = $item->{name};
   }
  }
  my $binding = _binding_ref($ctx, $target_name);
  LinkedSpec::BindingRuntime::assert_receiver_writable(
   $binding, $target_name, 'push', $node->{source_span},
  );
  $$binding = LinkedSpec::BindingRuntime::push_value($$binding, $target_name, $value);
  return $$binding
 }

 if ($name eq 'and' || $name eq 'or' || $name eq 'not') {
  my $argc = scalar @$args;
  _error(
   'helper_arity_mismatch',
   helper_name => $name,
   actual_arity => $argc,
   expected_arity => LinkedSpec::RuntimeLogical::expected_arity($name),
   arguments_evaluated => 0,
  ) unless LinkedSpec::RuntimeLogical::arity_is_valid($name, $argc);
  my @logical_values;
  foreach my $arg (@$args) {
   push @logical_values, _eval_expr($arg, $ctx);
  }
  return LinkedSpec::RuntimeLogical::evaluate($name, \@logical_values)
 }

 my $functions = $ctx->{invocation}{registered_functions};
 my $function = ref($functions) eq 'HASH' ? $functions->{$name} : undef;
 return _eval_registered_function($node, $ctx, $function) if ref($function) eq 'HASH';

 my @values = map { _eval_expr($_, $ctx) } @$args;

 # Governed helpers retain precedence over same-named codeblock variables.
 if ($name eq 'cat') {
  _error('unknown_helper', name => $name) if @values < 2;
  my @parts = map { _scalar_text($_) } @values;
  return undef if grep { !defined($_) } @parts;
  return join('', @parts)
 }
 if ($name eq 'length') {
  _error('unknown_helper', name => $name) unless @values == 1;
  return undef unless defined $values[0];
  return scalar(@{$values[0]}) if ref($values[0]) eq 'ARRAY';
  return scalar(keys %{$values[0]}) if ref($values[0]) eq 'HASH';
  my $text = _scalar_text($values[0]);
  return defined($text) ? length($text) : undef
 }
 if ($name eq 'copy') {
  _error('unknown_helper', name => $name) unless @values == 1;
  return _copy_value($values[0])
 }
 if ($name eq 'array') {
  return [map { _copy_value($_) } @values]
 }
 if ($name eq 'hash') {
  _error('unknown_helper', name => $name) if @values % 2;
  my %value;
  while (@values) {
   my $key = shift @values;
   my $item = shift @values;
   my $text = _scalar_text($key);
   return undef unless defined $text;
   $value{$text} = _copy_value($item);
  }
  return \%value
 }
 if ($name eq 'is_defined') {
  _error('unknown_helper', name => $name) unless @values == 1;
  return defined($values[0]) ? 1 : 0
 }
 if ($name eq 'is_undefined') {
  _error('unknown_helper', name => $name) unless @values == 1;
  return defined($values[0]) ? 0 : 1
 }

 my $binding = $ctx->{bindings}{$name};
 _error('unknown_helper', name => $name) unless _is_scalar_binding_ref($binding);
 return invoke(
  $$binding,
  \@values,
  $ctx->{bindings},
  $name,
  $ctx->{active_codeblocks},
  $ctx->{invocation},
 )
}

sub _eval_fluent_chain {
 my ($node, $ctx) = @_;
 my $value = _eval_expr($node->{receiver}, $ctx);
 foreach my $call (@{$node->{calls} || []}) {
  _error('invalid_codeblock_body', detail => 'invalid fluent call')
   unless ref($call) eq 'HASH';
  my $method = $call->{method} // '';
  my @args = map { _eval_expr($_, $ctx) } @{$call->{args} || []};
  if ($method eq 'length' && !@args) {
   $value = ref($value) eq 'ARRAY' ? scalar(@$value)
    : ref($value) eq 'HASH' ? scalar(keys %$value)
    : defined($value) ? length(_scalar_text($value) // '')
    : undef;
   next;
  }
  if ($method eq 'cat') {
   my @parts = map { _scalar_text($_) } ($value, @args);
   $value = grep({ !defined($_) } @parts) ? undef : join('', @parts);
   next;
  }
  _error('unknown_helper', name => $method)
 }
 return $value
}

sub _eval_expr {
 my ($node, $ctx) = @_;
 _error('invalid_codeblock_body', detail => 'expression is not a typed ActionIR node')
  unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 return 0 + $node->{value} if $kind eq 'number';
 return $node->{value} if $kind eq 'string';
 return undef if $kind eq 'undef';
 return $node->{value} ? 1 : 0 if $kind eq 'boolean';
 return _read_binding($ctx, $node->{name}) if $kind eq 'variable';
 return dclone($node) if $kind eq 'codeblock_literal';
 _error($node->{code} // 'invalid_codeblock_literal')
  if $kind eq 'codeblock_literal_error';

 if ($kind eq 'assign_scalar') {
  my $value = _eval_expr($node->{value}, $ctx);
  return _write_binding($ctx, $node->{name}, $value)
 }
 if ($kind eq 'array_literal') {
  return [map { _copy_value(_eval_expr($_, $ctx)) } @{$node->{items} || []}]
 }
 if ($kind eq 'hash_literal') {
  my %value;
  foreach my $entry (@{$node->{entries} || []}) {
   _error('invalid_codeblock_body', detail => 'invalid harray entry')
    unless ref($entry) eq 'HASH';
   my $key = _scalar_text(_eval_expr($entry->{key}, $ctx));
   return undef unless defined $key;
   $value{$key} = _copy_value(_eval_expr($entry->{value}, $ctx));
  }
  return \%value
 }
 if ($kind eq 'indexed_var') {
  my $value = _read_binding($ctx, $node->{name});
  my $key = _eval_expr($node->{index}, $ctx);
  return undef unless defined $value;
  return $value->[$key] if ref($value) eq 'ARRAY' && defined($key) && $key =~ /\A\d+\z/;
  return $value->{$key} if ref($value) eq 'HASH';
  return undef
 }
 if ($kind eq 'nested_access') {
  my $value = _read_binding($ctx, $node->{base});
  foreach my $segment (@{$node->{segments} || []}) {
   return undef unless defined $value && ref($segment) eq 'HASH';
   my $key = ($segment->{kind} // '') eq 'key'
    ? $segment->{value}
    : _eval_expr($segment->{expr}, $ctx);
   if (ref($value) eq 'ARRAY' && defined($key) && $key =~ /\A\d+\z/) {
    $value = $value->[$key];
   } elsif (ref($value) eq 'HASH') {
    $value = $value->{$key};
   } else {
    return undef;
   }
  }
  return $value
 }
 return _eval_call($node, $ctx) if $kind eq 'call';
 return _eval_fluent_chain($node, $ctx) if $kind eq 'fluent_chain';
 if ($kind eq 'block_value') {
  return _execute_body($node->{block}, $ctx)
 }
 if ($kind eq 'action_stmt') {
  return _eval_expr($node->{expr}, $ctx)
 }

 _error('unsupported_codeblock_actionir', kind => $kind)
}

sub _execute_body {
 my ($body, $ctx) = @_;
 _error('invalid_codeblock_body', detail => 'body must be an action_block')
  unless ref($body) eq 'HASH' && ($body->{kind} // '') eq 'action_block';
 my $result;
 foreach my $statement (@{$body->{statements} || []}) {
  _error('invalid_codeblock_body', detail => 'body statement must be action_stmt')
   unless ref($statement) eq 'HASH' && ($statement->{kind} // '') eq 'action_stmt';
  my $expr = $statement->{expr};
  if (ref($expr) eq 'HASH' && ($expr->{kind} // '') eq 'call' && ($expr->{name} // '') eq 'return') {
   my $args = $expr->{args};
   _error('invalid_codeblock_return', expected => 'exactly 1', got => ref($args) eq 'ARRAY' ? scalar(@$args) : 0)
    unless ref($args) eq 'ARRAY' && @$args == 1;
   return _eval_expr($args->[0], $ctx)
  }
  $result = _eval_expr($expr, $ctx);
 }
 return $result
}

sub invoke {
 my ($record, $args, $bindings, $identity, $active_codeblocks, $invocation) = @_;
 $args = [] unless defined $args;
 $bindings = {} unless defined $bindings;
 $identity = '<codeblock>' unless defined($identity) && length($identity);
 $invocation = {} unless defined $invocation;
 _error('invalid_codeblock_arguments') unless ref($args) eq 'ARRAY';
 _error('invalid_codeblock_bindings') unless ref($bindings) eq 'HASH';
 _error('invalid_codeblock_invocation_context') unless ref($invocation) eq 'HASH';
 $active_codeblocks = $invocation->{active_codeblocks} || [] unless defined $active_codeblocks;
 _error('value_not_callable', value_kind => _value_kind($record))
  unless ref($record) eq 'HASH'
      && ($record->{kind} // '') eq 'codeblock_literal'
      && ($record->{version} // 0) == 1;

 my $signature = $record->{signature};
 _error('invalid_codeblock_signature')
  unless ref($signature) eq 'HASH'
      && ($signature->{kind} // '') eq 'callable_signature'
      && ($signature->{version} // 0) == 1
      && ref($signature->{positional_params}) eq 'ARRAY';
 my $min = $signature->{min_arity};
 my $max = $signature->{max_arity};
 my $argc = scalar @$args;
 if (!defined($min) || $argc < $min || (defined($max) && $argc > $max)) {
  my $expected = defined($max) && $max == $min ? "exactly $min" : "at least $min";
  _error('codeblock_arity_mismatch', expected => $expected, got => $argc)
 }

 my @active = @$active_codeblocks;
 # Parameter transfer copies records. Preserve their actual origin outside the
 # eight-field record, distinguishing equal independent literals from aliases.
 my $record_origin = _codeblock_origin($record);
 my $active_records = $invocation->{active_codeblock_records} || [];
 _error('invalid_codeblock_invocation_context') unless ref($active_records) eq 'ARRAY';
 for (my $idx = 0; $idx < @active; ++$idx) {
  my $same = ref($active_records->[$idx]) ? refaddr($active_records->[$idx]) == refaddr($record_origin)
   : defined($active[$idx]) && $active[$idx] eq $identity;
  next unless $same;
  _error('codeblock_recursion_unsupported', cycle => [@active[$idx .. $#active], $identity])
 }
 my @record_keys = (map { $active_records->[$_] } 0 .. $#active);
 push @record_keys, $record_origin;
 push @active, $identity;
 $invocation = { %$invocation, active_codeblocks => \@active, active_codeblock_records => \@record_keys };

 my @param_names = @{$signature->{positional_params}};
 push @param_names, $signature->{rest_param} if defined($signature->{rest_param});
 my @copied_args = map { _copy_value($_) } @$args;
 my @saved;
 foreach my $name (@param_names) {
  my $binding = $bindings->{$name};
  unless (_is_scalar_binding_ref($binding)) {
   my $value;
   $bindings->{$name} = \$value;
   $binding = $bindings->{$name};
  }
  push @saved, [$name, $binding];
  # A parameter shadows the caller slot rather than borrowing its identity.
  # Receiver guards therefore protect caller mutations without rejecting a
  # mutation of this independent, copied parameter value.
  my $parameter_value;
  $bindings->{$name} = \$parameter_value;
 }

 for (my $idx = 0; $idx < @{$signature->{positional_params}}; ++$idx) {
  ${$bindings->{$signature->{positional_params}[$idx]}} = $copied_args[$idx];
 }
 if (defined($signature->{rest_param})) {
  my @rest = @copied_args[@{$signature->{positional_params}} .. $#copied_args];
  ${$bindings->{$signature->{rest_param}}} = \@rest;
 }

 my $ctx = {
  bindings => $bindings,
  active_codeblocks => \@active,
  invocation => $invocation,
 };
 my ($result, $failure);
 my $ok = eval {
  $result = _execute_body($record->{body_ast}, $ctx);
  1
 };
 $failure = $@ unless $ok;
 foreach my $saved (@saved) {
  $bindings->{$saved->[0]} = $saved->[1];
 }
 die $failure unless $ok;
 return $result
}

package LinkedSpec::CodeblockRuntime::Error;

use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 return bless {
  kind => 'codeblock_runtime_error',
  %fields,
 }, $class
}

sub as_string {
 my ($self) = @_;
 my $code = $self->{code} // 'codeblock_runtime_error';
 return "LINKEDSPEC_CODEBLOCK_RUNTIME_ERROR:$code"
}

1;
