#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::ValueExpr
# Purpose: Value-expression lowering owner for scalar, array, hash, and
#          composite expression normalization on the ActionIR path.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::ValueExpr;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::Trace ();

use constant ACTIONIR_TRACE_OWNER => 'value_expr';

sub _trace_value_decision {
 my (%args) = @_;
 return LinkedSpec::ActionIR::Trace::decision(
  owner => ACTIONIR_TRACE_OWNER,
  phase => $args{phase},
  label => $args{label},
  decision => $args{decision},
  taken => $args{taken},
  context => $args{context},
 );
}

sub _trace_value_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_value_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default value-expression dependency bundle for one owner
#           package.
# Args    : ($pkg)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'trim_action_ir_value',
   'lower_flow_composite_expr',
   'lower_method_value_expr',
  ],
 )
}

my %RESERVED_ARRAY_SYMBOL_NAMES = map { $_ => 1 } qw(
 undef true false
 descr STRING info minfo
 IMATCH IMATCH_HASH IINDEX IPOS
 LMATCH LMATCH_HASH LINDEX LSPOS
 CAPTURE
);

my %RESERVED_HASH_SYMBOL_NAMES = map { $_ => 1 } qw(
 undef true false
 descr STRING info minfo
 IMATCH IMATCH_LIST IINDEX IPOS
 LMATCH LMATCH_LIST LINDEX LSPOS
 CAPTURE
);

sub _is_reserved_array_symbol_name {
 my ($name) = @_;
 return defined($name) && $RESERVED_ARRAY_SYMBOL_NAMES{$name} ? 1 : 0
}

sub _is_reserved_hash_symbol_name {
 my ($name) = @_;
 return defined($name) && $RESERVED_HASH_SYMBOL_NAMES{$name} ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _lower_primitive_literal_expr
# Purpose : Lower primitive DSL literals to backend-visible Perl values.
# Args    : ($expr, $deps)
# Returns : Perl expression string for a literal, or undef for non-literals
#------------------------------------------------------------------------------
sub _lower_primitive_literal_expr {
 my ($expr, $deps) = @_;
 my $scope = _trace_value_enter(
  'lower_primitive_literal_expr',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_value_decision(
   phase => 'lower_primitive_literal_expr',
   label => 'expr',
   decision => $decision,
   taken => defined($result) ? 1 : 0,
   context => $context,
  );
  _trace_value_exit($scope, { status => defined($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return $finish->(undef, 'missing_expr', {}) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', {}) unless defined($trimmed) && length($trimmed);

 return $finish->($trimmed, 'number_literal', { expr => $trimmed }) if $trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return $finish->($trimmed, 'string_literal', { expr => $trimmed }) if $trimmed =~ /^\"(?:\\.|[^\"])*\"$/s || $trimmed =~ /^'(?:\\.|[^'])*'$/s;
 return $finish->('undef', 'undef_literal', { expr => $trimmed }) if $trimmed eq 'undef';
 return $finish->('do { require JSON::PP; JSON::PP::true }', 'true_literal', { expr => $trimmed }) if $trimmed eq 'true';
 return $finish->('do { require JSON::PP; JSON::PP::false }', 'false_literal', { expr => $trimmed }) if $trimmed eq 'false';
 return $finish->(undef, 'not_literal', { expr => $trimmed })
}

#------------------------------------------------------------------------------
# Function: _extract_scalar_symbol_name
# Purpose : Resolve scalar variable symbol name from DSL method token surface.
# Args    : ($token, $deps)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_scalar_symbol_name {
 my ($token, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 return undef unless defined $token;
 $token = $trim_action_ir_value->($token);
 return undef unless defined($token) && length($token);
 return $1 if $token =~ /^(\w+)$/o;
 return undef
}

#------------------------------------------------------------------------------
# Function: _extract_array_symbol_name
# Purpose : Resolve array variable symbol name from DSL method token surface.
# Args    : ($token, $deps)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_array_symbol_name {
 my ($token, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 return undef unless defined $token;
 $token = $trim_action_ir_value->($token);
 return undef unless defined($token) && length($token);
 if ($token =~ /^array\s*\(\s*(\w+)\s*\)$/o) {
  return undef if _is_reserved_array_symbol_name($1);
  return $1;
 }
 if ($token =~ /^(\w+)$/o) {
  return undef if _is_reserved_array_symbol_name($1);
  return $1;
 }
 return undef
}

#------------------------------------------------------------------------------
# Function: _extract_hash_symbol_name
# Purpose : Resolve hash variable symbol name from DSL method token surface.
# Args    : ($token, $deps)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_hash_symbol_name {
 my ($token, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 return undef unless defined $token;
 $token = $trim_action_ir_value->($token);
 return undef unless defined($token) && length($token);
 if ($token =~ /^hash\s*\(\s*(\w+)\s*\)$/o) {
  return undef if _is_reserved_hash_symbol_name($1);
  return $1;
 }
 if ($token =~ /^(\w+)$/o) {
  return undef if _is_reserved_hash_symbol_name($1);
  return $1;
 }
 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_scalar_access_key_expr
# Purpose : Lower scalar index/key expressions used for array/hash entry access.
# Args    : ($expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalar_access_key_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $literal = _lower_primitive_literal_expr($trimmed, $deps);
 return $literal if defined($literal);
 return $trimmed if $trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return $trimmed if $trimmed =~ /^\"(?:\\.|[^\"])*\"$/s || $trimmed =~ /^'(?:\\.|[^'])*'$/s;

 my $lowered = $lower_flow_composite_expr->($trimmed);
 $lowered = $lower_method_value_expr->($trimmed) unless defined($lowered) && length($lowered);
 $lowered = $trimmed unless defined($lowered) && length($lowered);

 return '$'.$lowered if $lowered =~ /^\w+$/o;
 return $lowered
}

#------------------------------------------------------------------------------
# Function: _split_nested_access_path_segments
# Purpose : Parse direct bracket path payloads like `[A][B]["C"][D]` into
#           ordered segments while preserving nested expression payloads.
# Args    : ($path_expr, $deps)
# Returns : arrayref of { kind => 'index'|'key', expr => ... } or undef
#------------------------------------------------------------------------------
sub _split_nested_access_path_segments {
 my ($path_expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 return undef unless defined $path_expr;
 my $path = $trim_action_ir_value->($path_expr);
 return undef unless defined($path) && length($path);

 my @segments;
 my $len = length($path);
 my $idx = 0;
 while ($idx < $len) {
  while ($idx < $len && substr($path, $idx, 1) =~ /\s/o) {
   ++$idx;
  }
  last if $idx >= $len;

  my $open = substr($path, $idx, 1);
  return undef unless $open eq '[' || $open eq '{';
  my $close = $open eq '[' ? ']' : '}';
  ++$idx;

  my @stack = ($close);
  my $payload = '';
  my $in_single_quote = 0;
  my $in_double_quote = 0;
  my $escape_next = 0;
  while ($idx < $len && @stack) {
   my $char = substr($path, $idx, 1);
   if ($in_single_quote) {
    $payload .= $char;
    if ($escape_next) {
     $escape_next = 0;
    } elsif ($char eq '\\') {
     $escape_next = 1;
    } elsif ($char eq "'") {
     $in_single_quote = 0;
    }
    ++$idx;
    next;
   }
   if ($in_double_quote) {
    $payload .= $char;
    if ($escape_next) {
      $escape_next = 0;
    } elsif ($char eq '\\') {
      $escape_next = 1;
    } elsif ($char eq '"') {
      $in_double_quote = 0;
    }
    ++$idx;
    next;
   }
   if ($char eq "'") {
    $in_single_quote = 1;
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '"') {
    $in_double_quote = 1;
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '[') {
    push @stack, ']';
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '{') {
    push @stack, '}';
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq ']' || $char eq '}') {
    my $expected = $stack[-1];
    return undef unless $char eq $expected;
    pop @stack;
    ++$idx;
    $payload .= $char if @stack;
    next;
   }
   $payload .= $char;
   ++$idx;
  }
  return undef if @stack;

  my $segment_expr = $trim_action_ir_value->($payload);
  return undef unless defined($segment_expr) && length($segment_expr);
  push @segments, {
   kind => ($open eq '[' ? 'index' : 'key'),
   expr => $segment_expr,
  };
 }

 return undef unless @segments;
 return \@segments
}

#------------------------------------------------------------------------------
# Function: _lower_nested_access_segment_expr
# Purpose : Lower one direct-access path segment expression while preserving
#           literal bareword index atoms when no lowering applies.
# Args    : ($segment_expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_nested_access_segment_expr {
 my ($segment_expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');

 return undef unless defined $segment_expr;
 my $trimmed = $trim_action_ir_value->($segment_expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $lowered = $lower_flow_composite_expr->($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 $lowered = $lower_method_value_expr->($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_direct_nested_access_value_expr
# Purpose : Lower direct bracket access such as `foo["a"][0][i]`.
# Args    : ($expr, $deps)
# Returns : Perl dereference expression string or undef
#------------------------------------------------------------------------------
sub _lower_direct_nested_access_value_expr {
 my ($expr, $deps) = @_;
 my $scope = _trace_value_enter(
  'lower_direct_nested_access_value_expr',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_value_decision(
   phase => 'lower_direct_nested_access_value_expr',
   label => 'expr',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_value_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return $finish->(undef, 'missing_expr', {}) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', {}) unless defined($trimmed) && length($trimmed);
 return $finish->(undef, 'not_direct_access', { expr => $trimmed })
  unless $trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*(\[.*)$/s;

 my ($base_symbol, $path_expr) = ($1, $2);
 return $finish->(undef, 'reserved_base', { base => $base_symbol }) if $base_symbol =~ /^(?:undef|true|false)$/o;

 my $segments = _split_nested_access_path_segments($path_expr, $deps);
 return $finish->(undef, 'segment_parse_failed', { base => $base_symbol }) unless $segments && @$segments;
 return $finish->(undef, 'unsupported_segment_kind', { base => $base_symbol }) if grep { ($_->{kind} // '') ne 'index' } @$segments;

 my $lowered = '$'.$base_symbol;
 foreach my $segment (@$segments) {
  my $segment_source = $trim_action_ir_value->($segment->{expr});
  return $finish->(undef, 'empty_segment', { base => $base_symbol }) unless defined($segment_source) && length($segment_source);
  if ($segment_source =~ /^[A-Za-z_][A-Za-z0-9_]*$/o) {
   return $finish->(undef, 'reserved_segment_symbol', { base => $base_symbol, segment => $segment_source })
    if $segment_source =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o;
   _trace_value_decision(
    phase => 'lower_direct_nested_access_value_expr',
    label => 'expr',
    decision => 'bare_index_segment',
    taken => 1,
    context => { base => $base_symbol, segment => $segment_source },
   );
   $lowered .= '->[$'.$segment_source.']';
   next;
  }

  my $segment_expr = _lower_nested_access_segment_expr($segment_source, $deps);
  return $finish->(undef, 'segment_lowering_failed', { base => $base_symbol, segment => $segment_source })
   unless defined($segment_expr) && length($segment_expr);

  if ($segment_source =~ /^\"(?:\\.|[^\"])*\"$/s || $segment_source =~ /^'(?:\\.|[^'])*'$/s) {
   _trace_value_decision(
    phase => 'lower_direct_nested_access_value_expr',
    label => 'expr',
    decision => 'literal_key_segment',
    taken => 1,
    context => { base => $base_symbol, segment => $segment_source },
   );
   $lowered .= '->{'.$segment_expr.'}';
  } else {
   _trace_value_decision(
    phase => 'lower_direct_nested_access_value_expr',
    label => 'expr',
    decision => 'expression_index_segment',
    taken => 1,
    context => { base => $base_symbol, segment => $segment_source },
   );
   $lowered .= '->['.$segment_expr.']';
  }
 }

 return $finish->($lowered, 'direct_access_lowered', { base => $base_symbol, segment_count => scalar(@$segments) })
}

#------------------------------------------------------------------------------
# Function: _infer_scalar_container_kind
# Purpose : Infer whether a nested scalar access should resolve through array
#           index or hash key syntax when container kind is not explicit.
# Args    : ($container_symbol, $key_expr, $deps)
# Returns : 'array' or 'hash'
#------------------------------------------------------------------------------
sub _infer_scalar_container_kind {
 my ($container_symbol, $key_expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return 'hash' if defined($container_symbol) && $container_symbol =~ /(hash|map|dict)/io;
 return 'array' if defined($container_symbol) && $container_symbol =~ /(arr|array|list|vec|vector)/io;

 my $key_trimmed = $trim_action_ir_value->($key_expr // '');
 return 'hash' if defined($key_trimmed) && ($key_trimmed =~ /^\"(?:\\.|[^\"])*\"$/s || $key_trimmed =~ /^'(?:\\.|[^'])*'$/s);
 return 'array' if defined($key_trimmed) && $key_trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return 'array'
}

#------------------------------------------------------------------------------
# Function: _lower_source_slot_bare_scalar_read_expr
# Purpose : Lower one accepted bare scalar source-slot identifier to `$NAME`.
# Args    : ($expr, $deps)
# Returns : Perl scalar read expression, or undef for non-source-slot bare reads
#------------------------------------------------------------------------------
sub _lower_source_slot_bare_scalar_read_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return undef if $trimmed =~ /^:[A-Za-z_][A-Za-z0-9_]*$/o;
 my $name;
 if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
  $name = $1;
 } else {
  return undef;
 }
 return undef if $name =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o;
 return '$'.$name
}

#------------------------------------------------------------------------------
# Function: _lower_assignment_source_expr
# Purpose : Map assignment source tokens from method DSL to Perl expressions.
# Args    : ($source, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_assignment_source_expr {
 my ($source, $deps) = @_;
 my $scope = _trace_value_enter(
  'lower_assignment_source_expr',
  'source',
  { source => defined($source) ? $source : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_value_decision(
   phase => 'lower_assignment_source_expr',
   label => 'source',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_value_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');

 return $finish->(undef, 'missing_source', {}) unless defined $source;
 $source = $trim_action_ir_value->($source);
 return $finish->('substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)', 'capture_source', {}) if $source eq 'CAPTURE';
 return $finish->('$IMATCH', 'imatch_source', {}) if $source eq 'IMATCH';
 return $finish->('$LMATCH', 'lmatch_source', {}) if $source eq 'LMATCH';

 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($source, $deps);
 return $finish->($bare_scalar_read, 'bare_scalar_read', { source => $source })
  if defined($bare_scalar_read) && length($bare_scalar_read);

 my $method_value = $lower_method_value_expr->($source);
 return $finish->($method_value, 'call_method_value', { source => $source })
  if defined($method_value) && length($method_value) && $source =~ /^call\s*\(/o;
 return $finish->($method_value, 'input_slice_method_value', { source => $source })
  if defined($method_value) && length($method_value) && $method_value ne $source && $source =~ /^input_slice\s*\(/o;
 return $finish->($method_value, 'method_value', { source => $source })
  if defined($method_value) && length($method_value) && $method_value ne $source;

 my $lowered = $lower_flow_composite_expr->($source);
 return $finish->($lowered, 'flow_composite_value', { source => $source }) if defined($lowered) && length($lowered);
 $lowered = $method_value;
 $lowered = $lower_method_value_expr->($source);
 return $finish->($lowered, 'method_value_retry', { source => $source }) if defined($lowered) && length($lowered);

 return $finish->($source, 'source_passthrough', { source => $source })
}

#------------------------------------------------------------------------------
# Function: _strip_literal_delimiters
# Purpose : Strip outer literal delimiters for quoted/regex literal arguments.
# Args    : ($value, $deps)
# Returns : unwrapped scalar string or undef
#------------------------------------------------------------------------------
sub _strip_literal_delimiters {
 my ($value, $deps) = @_;
 my $scope = _trace_value_enter(
  'strip_literal_delimiters',
  'value',
  { value => defined($value) ? $value : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_value_decision(
   phase => 'strip_literal_delimiters',
   label => 'value',
   decision => $decision,
   taken => defined($result) ? 1 : 0,
   context => $context,
  );
  _trace_value_exit($scope, { status => defined($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ValueExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return $finish->(undef, 'missing_value', {}) unless defined $value;
 $value = $trim_action_ir_value->($value);
 return $finish->(undef, 'empty_value', {}) unless defined($value) && length($value);
 return $finish->('', 'empty_regex_literal', { value => $value }) if $value eq '//';
 return $finish->($1, 'regex_literal', { value => $value }) if $value =~ m{^/(.*)/$}s;
 return $finish->($1, 'double_quoted_literal', { value => $value }) if $value =~ /^\"(.*)\"$/s;
 return $finish->($1, 'single_quoted_literal', { value => $value }) if $value =~ /^'(.*)'$/s;
 return $finish->($value, 'passthrough', { value => $value })
}

1;
