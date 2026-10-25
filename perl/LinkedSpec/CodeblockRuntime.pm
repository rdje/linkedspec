package LinkedSpec::CodeblockRuntime;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed reftype refaddr);
use Storable qw(dclone);
use Hash::Util::FieldHash qw(fieldhash);
use JSON::PP ();
use LinkedSpec::RuntimeLogical ();
use LinkedSpec::BindingRuntime ();
use LinkedSpec::CallableContract ();
use LinkedSpec::Numeric ();

# Execute version-1 callable-codeblock records as typed data. Generated handlers
# provide explicit references to caller working slots; this module never captures
# a lexical environment and never stores a host coderef in the record.
fieldhash my %codeblock_origins;
# A forwarded callable can introduce a working slot unknown to its compiled
# caller. Its presence must survive the next invocation through that same slot.
# Weak keys follow the slot lifetime without capturing a callable environment.
fieldhash my %binding_presence_by_slot;

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
 my ($value, $copies) = @_;
 return $value unless ref($value);
 $copies ||= {};
 my $identity = refaddr($value);
 return $copies->{$identity} if exists $copies->{$identity};
 my $kind = ref($value);
 my $copy;
 if ($kind eq 'ARRAY' || $kind eq 'HASH') {
  # Storable can normalize whole floats and populate caches in the source.
  # Copy typed scalar leaves directly, retaining aliases and cycles by identity.
  $copy = $kind eq 'ARRAY' ? [] : {};
  $copies->{$identity} = $copy;
  if ($kind eq 'ARRAY') {
   push @$copy, _copy_value($_, $copies) for @$value;
  } else {
   $copy->{$_} = _copy_value($value->{$_}, $copies) for keys %$value;
   _inherit_codeblock_origin($value, $copy)
    if ($value->{kind} // '') eq 'codeblock_literal';
  }
 } else {
  # Keep the existing copy behavior for opaque host references.
  $copy = dclone($value);
  $copies->{$identity} = $copy;
  _copy_codeblock_origins($value, $copy, {});
 }
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

sub _read_array_entry {
 my ($value, $key, $expression) = @_;
 return undef unless defined $key;
 # Number literals retain their spelling even when the serialized AST value
 # has lost its float flag. Extend only integer negatives; preserve old reads.
 my $integer_literal = ref($expression) ne 'HASH'
  || ($expression->{kind} // '') ne 'number'
  || (defined($expression->{source}) && $expression->{source} =~ /\A-?\d+\z/);
 if ($integer_literal && LinkedSpec::BindingRuntime::_runtime_kind($key) eq 'integer' && $key < 0) {
  my $position = @$value + $key;
  return $position >= 0 ? $value->[$position] : undef;
 }
 return $value->[$key] if $key =~ /\A\d+\z/;
 return undef
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
  if (ref($value) eq 'ARRAY') {
   $value = _read_array_entry($value, $key);
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
 if (_is_scalar_binding_ref($binding)) {
  my $present = $ctx->{presence}{$name};
  if (_is_scalar_binding_ref($present)) {
   $binding_presence_by_slot{$binding} = $present;
  } elsif (exists $binding_presence_by_slot{$binding}) {
   $ctx->{presence}{$name} = $binding_presence_by_slot{$binding};
  }
  return $binding;
 }
 my $value;
 $ctx->{bindings}{$name} = \$value;
 # A compiled caller can know the presence flag before a deferred body
 # introduces its value slot. Keep that shared flag rather than detaching it.
 my $present = $ctx->{presence}{$name};
 unless (_is_scalar_binding_ref($present)) {
  my $absent = 0;
  $present = \$absent;
 }
 $ctx->{presence}{$name} = $present;
 $binding_presence_by_slot{$ctx->{bindings}{$name}} = $present;
 return $ctx->{bindings}{$name}
}

sub _presence_ref {
 my ($ctx, $name) = @_;
 my $present = $ctx->{presence}{$name};
 return $present if _is_scalar_binding_ref($present);
 my $value = 0;
 $ctx->{presence}{$name} = \$value;
 my $binding = $ctx->{bindings}{$name};
 $binding_presence_by_slot{$binding} = \$value if _is_scalar_binding_ref($binding);
 return $ctx->{presence}{$name}
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
 ${_presence_ref($ctx, $name)} = 1;
 return $value
}

sub _write_operand_is_typed {
 my ($node) = @_;
 return ref($node) eq 'HASH' && defined($node->{kind})
  && !ref($node->{kind}) && length($node->{kind}) ? 1 : 0
}

sub _write_span {
 my ($span, $ctx) = @_;
 _error('invalid_codeblock_body', detail => 'invalid nested write span')
  unless ref($span) eq 'HASH'
   && defined($span->{start}) && !ref($span->{start}) && $span->{start} =~ /\A\d+\z/
   && defined($span->{end}) && !ref($span->{end}) && $span->{end} =~ /\A\d+\z/
   && $span->{end} >= $span->{start};
 return { source_id => $ctx->{invocation}{action_source_id} // 'action:<action>',
  start => $span->{start}, end => $span->{end},
  unit => 'unicode_scalar', provenance => 'authored' }
}

sub _eval_nested_write {
 my ($node, $ctx) = @_;
 my ($base, $segments) = @{$node}{qw(base segments)};
 _error('invalid_codeblock_body', detail => 'invalid nested write')
  unless defined($base) && !ref($base) && $base =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/
   && ref($segments) eq 'ARRAY' && @$segments && _write_operand_is_typed($node->{value});
 my $span = _write_span($node->{source_span}, $ctx);
 my @spans;
 foreach my $segment (@$segments) {
  _error('invalid_codeblock_body', detail => 'invalid nested write segment')
   unless ref($segment) eq 'HASH' && ($segment->{kind} // '') eq 'path_segment'
    && _write_operand_is_typed($segment->{expression});
  push @spans, _write_span($segment->{source_span}, $ctx);
 }
 my $binding = _binding_ref($ctx, $base);
 LinkedSpec::BindingRuntime::assert_receiver_writable(
  $binding, $base, 'nested_write', { %$span, end => $span->{start} + length($base) });
 my @evaluated;
 for (my $index = 0; $index < @$segments; ++$index) {
  my $expression = $segments->[$index]{expression};
  my $kind = $expression->{kind} // '';
  my $hint = $kind eq 'string' ? 'string'
   : $kind eq 'number' ? (defined($expression->{source})
    && $expression->{source} =~ /\A-?\d+\z/ ? 'integer' : 'number')
   : $kind eq 'boolean' ? 'boolean' : $kind eq 'undef' ? 'null'
   : $kind eq 'array_literal' ? 'array' : $kind eq 'hash_literal' ? 'harray'
   : $kind eq 'codeblock_literal' ? 'codeblock' : 'dynamic';
  push @evaluated, { value => _eval_expr($expression, $ctx),
   kind_hint => $hint, source_span => $spans[$index] };
 }
 my $rhs = _eval_expr($node->{value}, $ctx);
 # Segment/RHS calls may rebind this slot. Snapshot only after their effects.
 my $present = _presence_ref($ctx, $base);
 my ($updated, $result) = LinkedSpec::BindingRuntime::nested_write(
  $$binding, (defined($$binding) || $$present) ? 1 : 0, $base, \@evaluated, $rhs);
 $$binding = $updated;
 $$present = 1;
 return $result
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

sub _eval_if_value {
 my ($node, $ctx) = @_;
 my $args = $node->{args};
 _error('helper_arity_mismatch', helper_name => 'if',
  actual_arity => scalar(@$args), expected_arity => 'at least 2',
  arguments_evaluated => 0,
 ) unless @$args >= 2;

 my @branches = ([$args->[0], $args->[1]]);
 my $fallback_seen = 0;
 # Validate the whole typed branch list before evaluating any operands.
 for (my $index = 2; $index < @$args; ++$index) {
  my $branch = $args->[$index];
  _error('invalid_codeblock_body', detail => 'invalid conditional branch')
   unless ref($branch) eq 'HASH';
  my $name = ($branch->{kind} // '') eq 'call'
   ? ($branch->{name} // '') : '';
  _error('invalid_codeblock_control', detail => 'branch after fallback',
   source_span => $branch->{source_span},
  ) if $fallback_seen;
  if ($name eq 'elseif' || $name eq 'else') {
   my $values = $branch->{args};
   _error('invalid_codeblock_body', detail => 'branch arguments must be an array')
    unless ref($values) eq 'ARRAY';
   my $arity = $name eq 'elseif' ? 2 : 1;
   my @effective = @$values;
   # Match the existing inline lowerer's optional leading bare scope label.
   shift @effective if @effective == $arity + 1
    && ref($effective[0]) eq 'HASH'
    && ($effective[0]{kind} // '') eq 'variable';
   _error('helper_arity_mismatch', helper_name => $name,
    actual_arity => scalar(@$values), expected_arity => 'exactly '.$arity,
    arguments_evaluated => 0,
   ) unless @effective == $arity;
   if ($name eq 'elseif') {
    push @branches, [@effective];
   } else {
    push @branches, [undef, $effective[0]];
    $fallback_seen = 1;
   }
   next;
  }
  _error('invalid_codeblock_control', detail => 'fallback must be the final branch',
   source_span => $branch->{source_span},
  ) unless $index == $#$args;
  push @branches, [undef, $branch];
  $fallback_seen = 1;
 }
 foreach my $branch (@branches) {
  return _eval_expr($branch->[1], $ctx)
   if !defined($branch->[0])
    || LinkedSpec::RuntimeLogical::truthy(_eval_expr($branch->[0], $ctx));
 }
 return undef
}

sub _eval_call {
 my ($node, $ctx) = @_;
 my $name = $node->{name} // '';
 my $args = $node->{args};
 _error('invalid_codeblock_body', detail => 'call arguments must be an array')
  unless ref($args) eq 'ARRAY';

 return _eval_if_value($node, $ctx) if $name eq 'if';

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
   $failure =~ s/ at \Q$runtime_file\E line \d+(?:, <[^>\n]+> line \d+)?\.?\n?\z//;
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

 if ($name eq 'count' || $name eq 'first' || $name eq 'last') {
  return undef unless @$args == 1;
  my $value = _eval_expr($args->[0], $ctx);
  return _array_selection($name, $value)
 }

 if ($name eq 'sorted' || $name eq 'take') {
  return undef unless ($name eq 'sorted' ? @$args == 1 : @$args >= 1 && @$args <= 2);
  my $value = _eval_expr($args->[0], $ctx);
  return [] unless ref($value) eq 'ARRAY';
  return LinkedSpec::BindingRuntime::array_transform($value, '<value>', 'sorted')
   if $name eq 'sorted';
  # Like the compiled helper, a non-array source skips the count operand.
  my $count = @$args == 2 ? _eval_expr($args->[1], $ctx) : 1;
  return _take_array($value, $count)
 }

 my $aggregate = LinkedSpec::Numeric::array_helper_name($name);
 if (defined($aggregate) && ($aggregate !~ /\Anum_(?:min|max)\z/ || @$args == 1)) {
  return undef unless @$args == 1;
  return LinkedSpec::Numeric::evaluate_array($aggregate, _eval_expr($args->[0], $ctx))
 }

 my $numeric = LinkedSpec::Numeric::scalar_helper_name($name);
 if (defined($numeric)) {
  return undef unless LinkedSpec::Numeric::arity_is_valid($numeric, scalar(@$args));
  my @numbers;
  foreach my $arg (@$args) {
   my $value = _eval_expr($arg, $ctx);
   push @numbers, $value;
  }
  return LinkedSpec::Numeric::evaluate($numeric, @numbers)
 }

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
  $ctx->{presence},
 )
}

# Both call spellings use the stored element unchanged, including false/null
# and callable values. Invocation/container boundaries retain their own copying.
sub _array_selection {
 my ($name, $value) = @_;
 return ref($value) eq 'ARRAY' ? scalar(@$value) : 0 if $name eq 'count';
 return ref($value) eq 'ARRAY' && @$value
  ? $value->[$name eq 'last' ? -1 : 0] : undef
}

sub _numeric_receiver_helper_name {
 my ($method) = @_;
 return undef unless defined($method) && $method =~ /\A[a-z]+\z/;
 return LinkedSpec::Numeric::scalar_helper_name($method)
}

sub _take_array {
 my ($value, $count) = @_;
 # Keep the existing Perl selection policy, separate from numeric helpers.
 $count = 0 unless defined($count) && $count =~ /\A-?\d+\z/;
 return [] unless $count > 0 && @$value;
 my $end = $count < @$value ? $count - 1 : $#$value;
 return [@$value[0 .. $end]]
}

sub _eval_fluent_chain {
 my ($node, $ctx) = @_;
 my $calls = $node->{calls} || [];
 my @numeric = map { ref($_) eq 'HASH' ? _numeric_receiver_helper_name($_->{method}) : undef } @$calls;
 # Validate numeric call shapes before any receiver or operands run, including
 # comparison terminals followed by a different family. Single min/max selects
 # its overload at runtime.
 for (my $index = 0; $index < @$calls; ++$index) {
  next unless ref($calls->[$index]) eq 'HASH';
  my $method = $calls->[$index]{method} // '';
  my $args = $calls->[$index]{args};
  _error('invalid_codeblock_body', detail => 'fluent arguments must be an array')
   unless ref($args) eq 'ARRAY';
  return undef if $method eq 'sorted' && @$args;
  return undef if $method eq 'take' && @$args > 1;
  if ($method eq 'count' || $method eq 'first' || $method eq 'last' || $method eq 'length') {
   return undef if @$args || $index < $#$calls;
  }
  if ($method =~ /\A(?:sum|avg|median|range)\z/) {
   return undef if @$args || $index < $#$calls;
  }
  return undef if ($method eq 'min' || $method eq 'max') && !@$args && $index < $#$calls;
  my $helper = $numeric[$index];
  next unless defined($helper);
  my $argc = 1 + @{$calls->[$index]{args} || []};
  return undef if $helper =~ /\Anum_(?:eq|ne|gt|ge|lt|le)\z/ && $index < $#$calls;
  next if ($helper eq 'num_min' || $helper eq 'num_max') && $argc == 1;
  return undef unless LinkedSpec::Numeric::arity_is_valid($helper, $argc);
 }
 my $value = _eval_expr($node->{receiver}, $ctx);
 foreach my $call (@$calls) {
  _error('invalid_codeblock_body', detail => 'invalid fluent call')
   unless ref($call) eq 'HASH';
  my $method = $call->{method} // '';
  if ($method eq 'count' || $method eq 'first' || $method eq 'last') {
   $value = _array_selection($method, $value);
   next;
  }
  if ($method eq 'sorted') {
   $value = ref($value) eq 'ARRAY'
    ? LinkedSpec::BindingRuntime::array_transform($value, '<receiver>', 'sorted') : [];
   next;
  }
  if ($method eq 'take') {
   if (ref($value) eq 'ARRAY') {
    my $args = $call->{args} || [];
    my $count = @$args ? _eval_expr($args->[0], $ctx) : 1;
    $value = _take_array($value, $count);
   } else {
    $value = [];
   }
   next;
  }
  my $aggregate = $method =~ /\A[a-z]+\z/ ? LinkedSpec::Numeric::array_helper_name($method) : undef;
  if (defined($aggregate) && ($method !~ /\A(?:min|max)\z/ || !@{$call->{args} || []})) {
   return undef if @{$call->{args} || []};
   $value = LinkedSpec::Numeric::evaluate_array($aggregate, $value);
   next;
  }
  my $numeric = _numeric_receiver_helper_name($method);
  if (defined($numeric)) {
   my $args = $call->{args} || [];
   my $array_overload = ($numeric eq 'num_min' || $numeric eq 'num_max') && !@$args;
   return undef unless $array_overload || LinkedSpec::Numeric::arity_is_valid($numeric, 1 + @$args);
   my @numbers = ($value);
   foreach my $arg (@$args) {
    my $operand = _eval_expr($arg, $ctx);
    push @numbers, $operand;
   }
   $value = LinkedSpec::Numeric::evaluate($numeric, @numbers);
   next;
  }
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

 if ($kind eq 'number') {
  # JSON can round a literal's numeric payload and erase its floating flag.
  # Reconstruct supported decimal tokens with the AST parser's conversion.
  # Older source-less records retain their numeric-payload fallback.
  my $source = $node->{source};
  return 0 + substr($source, 0) if defined($source) && !ref($source)
   && $source =~ /\A-?[0-9]+(?:\.[0-9]+)?\z/;
  return 0 + $node->{value};
 }
 return $node->{value} if $kind eq 'string';
 return undef if $kind eq 'undef';
 return $node->{value} ? JSON::PP::true : JSON::PP::false if $kind eq 'boolean';
 return _read_binding($ctx, $node->{name}) if $kind eq 'variable';
 return dclone($node) if $kind eq 'codeblock_literal';
 _error($node->{code} // 'invalid_codeblock_literal')
  if $kind eq 'codeblock_literal_error';

 if ($kind eq 'assign_scalar') {
  my $value = _eval_expr($node->{value}, $ctx);
  return _write_binding($ctx, $node->{name}, $value)
 }
 return _eval_nested_write($node, $ctx) if $kind eq 'assign_nested_access';
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
  return _read_array_entry($value, $key, $node->{index}) if ref($value) eq 'ARRAY';
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
   if (ref($value) eq 'ARRAY') {
    $value = _read_array_entry($value, $key, $segment->{expr});
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

sub _execute_attached_if {
 my ($statements, $index, $ctx) = @_;
 my @branches = ($statements->[$index]{expr});
 my $has_else = 0;
 my $next = $index + 1;
 while ($next < @$statements) {
  my $statement = $statements->[$next];
  last unless ref($statement) eq 'HASH' && ($statement->{kind} // '') eq 'action_stmt';
  my $branch = $statement->{expr};
  last unless ref($branch) eq 'HASH';
  my $kind = $branch->{kind} // '';
  last unless ($kind eq 'control_if' && ($branch->{branch_role} // '') eq 'elseif')
   || $kind eq 'control_else';
  # Marker controls have a separate owner; do not mix them into an attached group.
  _error('unsupported_codeblock_actionir', kind => $kind) unless ref($branch->{body}) eq 'HASH';
  _error('invalid_codeblock_control', detail => 'attached branch follows else') if $has_else;
  $has_else = 1 if $kind eq 'control_else';
  push @branches, $branch;
  $next++;
 }
 foreach my $branch (@branches) {
  next unless ($branch->{kind} // '') eq 'control_else'
   || LinkedSpec::RuntimeLogical::truthy(_eval_expr($branch->{condition}, $ctx));
  my ($value, $returned) = _execute_sequence($branch->{body}, $ctx);
  return ($next, $value, 1) if $returned;
  last;
 }
 # Attached controls are statements: only an explicit return carries a value out.
 return ($next, undef, 0)
}

sub _execute_marker_if {
 my ($statements, $index, $ctx) = @_;
 my $opening = $statements->[$index]{expr};
 my @branches = ({condition => $opening->{condition}, statements => []});
 my ($depth, $has_else) = (1, 0);
 for (my $next = $index + 1; $next < @$statements; $next++) {
  my $statement = $statements->[$next];
  _error('invalid_codeblock_body', detail => 'body statement must be action_stmt')
   unless ref($statement) eq 'HASH' && ($statement->{kind} // '') eq 'action_stmt';
  my $expr = $statement->{expr};
  my $kind = ref($expr) eq 'HASH' ? ($expr->{kind} // '') : '';
  if ($kind eq 'control_if' && ($expr->{branch_role} // '') eq 'if' && ref($expr->{body}) eq 'HASH') {
   # Attached sibling arms belong to this nested statement, not the marker group.
   push @{$branches[-1]{statements}}, $statement;
   while ($next + 1 < @$statements) {
    my $arm_statement = $statements->[$next + 1];
    last unless ref($arm_statement) eq 'HASH' && ($arm_statement->{kind} // '') eq 'action_stmt';
    my $arm = $arm_statement->{expr};
    last unless ref($arm) eq 'HASH' && ref($arm->{body}) eq 'HASH';
    last unless (($arm->{kind} // '') eq 'control_if' && ($arm->{branch_role} // '') eq 'elseif')
     || ($arm->{kind} // '') eq 'control_else';
    push @{$branches[-1]{statements}}, $arm_statement;
    $next++;
   }
   next;
  }
  if ($kind eq 'control_if' && ($expr->{branch_role} // '') eq 'if') {
   $depth++;
  } elsif ($kind eq 'control_endif') {
   if (--$depth == 0) {
    foreach my $branch (@branches) {
     next if exists($branch->{condition})
      && !LinkedSpec::RuntimeLogical::truthy(_eval_expr($branch->{condition}, $ctx));
     my ($value, $returned) = _execute_sequence({kind => 'action_block', statements => $branch->{statements}}, $ctx);
     return ($next + 1, $value, 1) if $returned;
     last;
    }
    return ($next + 1, undef, 0)
   }
  } elsif ($depth == 1 && (($kind eq 'control_if' && ($expr->{branch_role} // '') eq 'elseif')
   || $kind eq 'control_else')) {
   _error('unsupported_codeblock_actionir', kind => $kind) if ref($expr->{body}) eq 'HASH';
   _error('invalid_codeblock_control', detail => 'marker branch follows else', source_span => $expr->{source_span}) if $has_else;
   $has_else = 1 if $kind eq 'control_else';
   push @branches, {statements => [], $has_else ? () : (condition => $expr->{condition})};
   next;
  }
  push @{$branches[-1]{statements}}, $statement;
 }
 _error('invalid_codeblock_control', detail => 'marker if missing endif', source_span => $opening->{source_span})
}

sub _execute_sequence {
 my ($body, $ctx) = @_;
 _error('invalid_codeblock_body', detail => 'body must be an action_block')
  unless ref($body) eq 'HASH' && ($body->{kind} // '') eq 'action_block';
 my $result;
 my $statements = $body->{statements} || [];
 for (my $index = 0; $index < @$statements; $index++) {
  my $statement = $statements->[$index];
  _error('invalid_codeblock_body', detail => 'body statement must be action_stmt')
   unless ref($statement) eq 'HASH' && ($statement->{kind} // '') eq 'action_stmt';
  my $expr = $statement->{expr};
  if (ref($expr) eq 'HASH' && ($expr->{kind} // '') eq 'control_while'
   && ref($expr->{body}) eq 'HASH') {
   my $iterations = 0;
   while (LinkedSpec::RuntimeLogical::truthy(_eval_expr($expr->{condition}, $ctx))) {
    # Match the canonical guard: check only after a true condition, before body.
    _error('while_iteration_limit_exceeded', iteration_limit => 10000,
     iterations_executed => $iterations - 1, source_span => $expr->{source_span},
     detail => 'LinkedSpec while iteration safety limit exceeded after 10000 iterations',
    ) if ++$iterations > 10000;
    my ($value, $returned) = _execute_sequence($expr->{body}, $ctx);
    return ($value, 1) if $returned;
   }
   $result = undef;
   next;
  }
  if (ref($expr) eq 'HASH' && ($expr->{kind} // '') eq 'control_if'
   && ($expr->{branch_role} // '') eq 'if' && !exists($expr->{body})) {
   my ($next, $value, $returned) = _execute_marker_if($statements, $index, $ctx);
   return ($value, 1) if $returned;
   $index = $next - 1;
   $result = undef;
   next;
  }
  if (ref($expr) eq 'HASH' && !exists($expr->{body})
   && (($expr->{kind} // '') eq 'control_endif' || ($expr->{kind} // '') eq 'control_else'
    || (($expr->{kind} // '') eq 'control_if' && ($expr->{branch_role} // '') eq 'elseif'))) {
   _error('invalid_codeblock_control', detail => 'marker control without matching if', source_span => $expr->{source_span})
  }
  if (ref($expr) eq 'HASH' && ($expr->{kind} // '') eq 'control_if'
   && ($expr->{branch_role} // '') eq 'if' && ref($expr->{body}) eq 'HASH') {
   my ($next, $value, $returned) = _execute_attached_if($statements, $index, $ctx);
   return ($value, 1) if $returned;
   $index = $next - 1;
   $result = undef;
   next;
  }
  if (ref($expr) eq 'HASH' && ($expr->{kind} // '') eq 'call'
   && (($expr->{name} // '') eq 'return' || ($expr->{name} // '') eq 'return_undef')) {
   my $args = $expr->{args};
   my @effective = ref($args) eq 'ARRAY' ? @$args : ();
   my $null_return = $expr->{name} eq 'return_undef';
   # The canonical null-return helper permits one optional bare scope label.
   shift @effective if $null_return && @effective == 1
    && ref($effective[0]) eq 'HASH' && ($effective[0]{kind} // '') eq 'variable';
   my $max = $null_return ? 0 : 1;
   _error('invalid_codeblock_return', expected => $null_return ? 'exactly 0' : '0 or 1',
    got => ref($args) eq 'ARRAY' ? scalar(@$args) : 0,
   ) unless ref($args) eq 'ARRAY' && @effective <= $max;
   return (@effective ? _eval_expr($effective[0], $ctx) : undef, 1)
  }
  $result = _eval_expr($expr, $ctx);
 }
 return ($result, 0)
}

sub _execute_body {
 my ($body, $ctx) = @_;
 # Callable and eager-expression blocks consume their own return boundary.
 my ($value) = _execute_sequence($body, $ctx);
 return $value
}

sub invoke {
 my ($record, $args, $bindings, $identity, $active_codeblocks, $invocation, $presence) = @_;
 $args = [] unless defined $args;
 $bindings = {} unless defined $bindings;
 $identity = '<codeblock>' unless defined($identity) && length($identity);
 $invocation = {} unless defined $invocation;
 _error('invalid_codeblock_arguments') unless ref($args) eq 'ARRAY';
 _error('invalid_codeblock_bindings') unless ref($bindings) eq 'HASH';
 if (!defined($presence)) {
  # Explicit runtime callers supplied existing slots, including bound null.
  # Generated callers instead supply references to their presence flags.
  $presence = {};
  foreach my $name (keys %$bindings) {
   my $present = 1;
   $presence->{$name} = \$present;
  }
 }
 _error('invalid_codeblock_presence') unless ref($presence) eq 'HASH'
  && !grep { !_is_scalar_binding_ref($_) } values %$presence;
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
  push @saved, [$name, $binding, exists($presence->{$name}), $presence->{$name}];
  # A parameter shadows the caller slot rather than borrowing its identity.
  # Receiver guards therefore protect caller mutations without rejecting a
  # mutation of this independent, copied parameter value.
  my $parameter_value;
  $bindings->{$name} = \$parameter_value;
  my $parameter_present = 1;
  $presence->{$name} = \$parameter_present;
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
  presence => $presence,
 };
 my ($result, $failure);
 my $ok = eval {
  $result = _execute_body($record->{body_ast}, $ctx);
  1
 };
 $failure = $@ unless $ok;
 foreach my $saved (@saved) {
  $bindings->{$saved->[0]} = $saved->[1];
  if ($saved->[2]) { $presence->{$saved->[0]} = $saved->[3] }
  else { delete $presence->{$saved->[0]} }
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
