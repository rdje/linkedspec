package LinkedSpec::CodeblockRuntime;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed reftype);
use Storable qw(dclone);

# Execute version-1 callable-codeblock records as typed data. Generated handlers
# provide explicit references to caller working slots; this module never captures
# a lexical environment and never stores a host coderef in the record.

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
 return dclone($value)
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

sub _eval_call {
 my ($node, $ctx) = @_;
 my $name = $node->{name} // '';
 my $args = $node->{args};
 _error('invalid_codeblock_body', detail => 'call arguments must be an array')
  unless ref($args) eq 'ARRAY';

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
 return _copy_value($node) if $kind eq 'codeblock_literal';
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
 my ($record, $args, $bindings, $identity, $active_codeblocks) = @_;
 $args = [] unless defined $args;
 $bindings = {} unless defined $bindings;
 $identity = '<codeblock>' unless defined($identity) && length($identity);
 $active_codeblocks = [] unless defined $active_codeblocks;
 _error('invalid_codeblock_arguments') unless ref($args) eq 'ARRAY';
 _error('invalid_codeblock_bindings') unless ref($bindings) eq 'HASH';
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
 for (my $idx = 0; $idx < @active; ++$idx) {
  next unless defined($active[$idx]) && $active[$idx] eq $identity;
  _error('codeblock_recursion_unsupported', cycle => [@active[$idx .. $#active], $identity])
 }
 push @active, $identity;

 my @param_names = @{$signature->{positional_params}};
 push @param_names, $signature->{rest_param} if defined($signature->{rest_param});
 my @saved;
 foreach my $name (@param_names) {
  my $binding = $bindings->{$name};
  unless (_is_scalar_binding_ref($binding)) {
   my $value;
   $bindings->{$name} = \$value;
   $binding = $bindings->{$name};
  }
  push @saved, [$binding, $$binding];
 }

 my @copied_args = map { _copy_value($_) } @$args;
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
 };
 my ($result, $failure);
 my $ok = eval {
  $result = _execute_body($record->{body_ast}, $ctx);
  1
 };
 $failure = $@ unless $ok;
 foreach my $saved (@saved) {
  ${$saved->[0]} = $saved->[1];
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
