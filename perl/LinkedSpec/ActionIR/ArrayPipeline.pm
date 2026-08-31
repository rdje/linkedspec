#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::ArrayPipeline
# Purpose: Array-pipeline lowering owner for split/filter/transform plan
#          extraction and pipeline expression assembly.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::ArrayPipeline;

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
use LinkedSpec::UnicodeCaseMapping ();

use constant ACTIONIR_TRACE_OWNER => 'array_pipeline';

sub _trace_array_pipeline_decision {
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

sub _trace_array_pipeline_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_array_pipeline_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default array-pipeline dependency bundle for one owner
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
   'strip_literal_delimiters',
   'extract_array_symbol_name',
   'parse_method_function_expr',
   'is_bare_method_scope_token',
   'extract_scalar_symbol_name',
  ],
 )
}

#------------------------------------------------------------------------------
# Function: _normalize_split_delimiter_expr
# Purpose : Normalize split delimiter argument into a Perl regex expression.
# Args    : ($delimiter, $deps)
# Returns : Perl regex expression string or undef
#------------------------------------------------------------------------------
sub _normalize_split_delimiter_expr {
 my ($delimiter, $deps) = @_;
 my $trim_action_ir_value = (ref($deps->{trim_action_ir_value}) eq 'CODE')
  ? $deps->{trim_action_ir_value}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'trim_action_ir_value'"
  unless ref($trim_action_ir_value) eq 'CODE';
 my $strip_literal_delimiters = (ref($deps->{strip_literal_delimiters}) eq 'CODE')
  ? $deps->{strip_literal_delimiters}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'strip_literal_delimiters'"
  unless ref($strip_literal_delimiters) eq 'CODE';

 $delimiter = $trim_action_ir_value->($delimiter // '');
 return '/\s*,\s*/' unless defined($delimiter) && length($delimiter);
 return $delimiter if $delimiter =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;

 my $literal = $strip_literal_delimiters->($delimiter);
 return undef unless defined $literal;
 my $quoted = quotemeta($literal);
 return '/'.$quoted.'/'
}

#------------------------------------------------------------------------------
# Function: _build_array_pipeline_plan_from_expr
# Purpose : Build recursive array-pipeline operation plans from composable
#           method expressions over bare typed bindings.
# Args    : ($expr, $deps)
# Returns : hashref { target_symbol => ..., ops => [...] } or undef
#------------------------------------------------------------------------------
sub _build_array_pipeline_plan_from_expr {
 my ($expr, $deps) = @_;
 my $scope = _trace_array_pipeline_enter(
  'build_array_pipeline_plan_from_expr',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_array_pipeline_decision(
   phase => 'build_array_pipeline_plan_from_expr',
   label => 'expr',
   decision => $decision,
   taken => ref($result) eq 'HASH' ? 1 : 0,
   context => $context,
  );
  _trace_array_pipeline_exit(
   $scope,
   {
    status => ref($result) eq 'HASH' ? 'ok' : 'undef',
    decision => $decision,
    op_count => ref($result) eq 'HASH' && ref($result->{ops}) eq 'ARRAY' ? scalar(@{$result->{ops}}) : 0,
   },
  );
  return $result
 };
 my $trim_action_ir_value = (ref($deps->{trim_action_ir_value}) eq 'CODE')
  ? $deps->{trim_action_ir_value}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'trim_action_ir_value'"
  unless ref($trim_action_ir_value) eq 'CODE';
 my $extract_array_symbol_name = (ref($deps->{extract_array_symbol_name}) eq 'CODE')
  ? $deps->{extract_array_symbol_name}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'extract_array_symbol_name'"
  unless ref($extract_array_symbol_name) eq 'CODE';
 my $parse_method_function_expr = (ref($deps->{parse_method_function_expr}) eq 'CODE')
  ? $deps->{parse_method_function_expr}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'parse_method_function_expr'"
  unless ref($parse_method_function_expr) eq 'CODE';
 my $is_bare_method_scope_token = (ref($deps->{is_bare_method_scope_token}) eq 'CODE')
  ? $deps->{is_bare_method_scope_token}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'is_bare_method_scope_token'"
  unless ref($is_bare_method_scope_token) eq 'CODE';
 my $extract_scalar_symbol_name = (ref($deps->{extract_scalar_symbol_name}) eq 'CODE')
  ? $deps->{extract_scalar_symbol_name}
  : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback 'extract_scalar_symbol_name'"
  unless ref($extract_scalar_symbol_name) eq 'CODE';
 return $finish->(undef, 'missing_expr', {}) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', {}) unless defined($trimmed) && length($trimmed);

 my $target_symbol = $extract_array_symbol_name->($trimmed);
 my $target_plan = { target_symbol => $target_symbol, ops => [] };
 my $binding_target = (
  $trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*$/o
  && $trimmed !~ /^(?:IMATCH_LIST|LMATCH_LIST)$/o
 ) ? 1 : 0;
 if (!$binding_target && $trimmed =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
  my $bare_symbol_kind = (ref($deps->{bare_symbol_kind}) eq 'CODE')
   ? $deps->{bare_symbol_kind}
   : sub { return undef };
  $binding_target = 1 if (($bare_symbol_kind->($1) // '') eq 'scalar');
 }
 $target_plan->{binding_target} = 1 if $binding_target;
 return $finish->(
  $target_plan,
  'target_symbol',
  { target_symbol => $target_symbol },
 )
  if defined $target_symbol;

 my $call = $parse_method_function_expr->($trimmed);
 return $finish->(undef, 'not_method_call', { expr => $trimmed }) unless $call;
 my $method = $call->{method};
 my $args = $call->{args} || [];

 if ($method eq 'split') {
  my @effective_args = @$args;
  if (@effective_args == 4 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return $finish->(undef, 'split_bad_arity', { arg_count => scalar(@effective_args) })
   unless @effective_args == 2 || @effective_args == 3;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return $finish->(undef, 'split_target_failed', {}) unless $pipeline;

  my $source_expr = $trim_action_ir_value->($effective_args[1]);
  if (defined($source_expr) && $source_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   $source_expr = '$'.$1;
  }
  return $finish->(undef, 'split_source_failed', {}) unless defined($source_expr) && length($source_expr);
  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[2], $deps);
  return $finish->(undef, 'split_delimiter_failed', {}) unless defined $delimiter_expr;

  push @{$pipeline->{ops}}, {
   op             => 'split',
   source_expr    => $source_expr,
   delimiter_expr => $delimiter_expr,
  };
  return $finish->($pipeline, 'append_split_op', { source_expr => $source_expr, delimiter_expr => $delimiter_expr })
 }
 if ($method eq 'split_each') {
  my @effective_args = @$args;
  if (@effective_args == 3 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return $finish->(undef, 'split_each_bad_arity', { arg_count => scalar(@effective_args) }) unless @effective_args == 2;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return $finish->(undef, 'split_each_target_failed', {}) unless $pipeline;

  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[1], $deps);
  return $finish->(undef, 'split_each_delimiter_failed', {}) unless defined $delimiter_expr;
  push @{$pipeline->{ops}}, {
   op             => 'split_each',
   delimiter_expr => $delimiter_expr,
  };
  return $finish->($pipeline, 'append_split_each_op', { delimiter_expr => $delimiter_expr })
 }

 if ($method eq 'filter_match') {
  my @effective_args = @$args;
  if (@effective_args == 3 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return $finish->(undef, 'filter_match_bad_arity', { arg_count => scalar(@effective_args) }) unless @effective_args == 2;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return $finish->(undef, 'filter_match_target_failed', {}) unless $pipeline;

  my $pattern_expr = _normalize_split_delimiter_expr($effective_args[1], $deps);
  return $finish->(undef, 'filter_match_pattern_failed', {}) unless defined $pattern_expr;
  push @{$pipeline->{ops}}, {
   op           => 'filter_match',
   pattern_expr => $pattern_expr,
  };
  return $finish->($pipeline, 'append_filter_match_op', { pattern_expr => $pattern_expr })
 }

 if ($method =~ /^(trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq)$/o) {
  my @effective_args = @$args;
  if (@effective_args == 2 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return $finish->(undef, 'unary_bad_arity', { method => $method, arg_count => scalar(@effective_args) })
   unless @effective_args == 1;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return $finish->(undef, 'unary_target_failed', { method => $method }) unless $pipeline;
  push @{$pipeline->{ops}}, {op => $method};
  return $finish->($pipeline, 'append_unary_op', { method => $method })
 }

 return $finish->(undef, 'unsupported_method', { method => defined($method) ? $method : '<undef>' })
}

#------------------------------------------------------------------------------
# Function: _lower_array_pipeline_expr
# Purpose : Lower recursive composable array method expressions into ordered
#           Perl statements over a stable target array symbol.
# Args    : ($expr, $source_span, $deps)
# Returns : lowered statement string or undef
#------------------------------------------------------------------------------
sub _lower_array_pipeline_expr {
 my ($expr, $source_span, $deps) = @_;
 if (ref($source_span) eq 'HASH' && !defined($deps)) {
  # The owner-dispatch seam appends dependencies after the caller's arguments.
  # Preserve compatibility with the historical direct `(expr, deps)` form.
  $deps = $source_span;
  $source_span = undef;
 }
 my $scope = _trace_array_pipeline_enter(
  'lower_array_pipeline_expr',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_array_pipeline_decision(
   phase => 'lower_array_pipeline_expr',
   label => 'expr',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_array_pipeline_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $pipeline = _build_array_pipeline_plan_from_expr($expr, $deps);
 return $finish->(undef, 'plan_missing_target', {}) unless $pipeline && $pipeline->{target_symbol};
 return $finish->(undef, 'plan_has_no_ops', { target_symbol => $pipeline->{target_symbol} }) unless @{$pipeline->{ops} || []};

 my $target_symbol = $pipeline->{target_symbol};
 if ($pipeline->{binding_target}) {
  my @statements = ('require LinkedSpec::BindingRuntime');
  my $receiver_mutation_target = ref($deps->{receiver_mutation_target}) eq 'CODE'
   ? $deps->{receiver_mutation_target}
   : undef;
  my $receiver_guarded = ref($receiver_mutation_target) eq 'CODE'
   && $receiver_mutation_target->($target_symbol) ? 1 : 0;
  if ($receiver_guarded) {
   my $span = ref($source_span) eq 'HASH' ? $source_span : {
    start => 0,
    end => length($expr // ''),
   };
   my $start = defined($span->{start}) && $span->{start} =~ /\A\d+\z/o
    ? $span->{start}
    : 0;
   my $end = defined($span->{end}) && $span->{end} =~ /\A\d+\z/o
    ? $span->{end}
    : $start + length($expr // '');
   my $rule_label = defined($deps->{rule_label}) && !ref($deps->{rule_label})
    ? $deps->{rule_label}
    : '<action>';
   $rule_label =~ s/([\\"])/\\$1/go;
   my $attempt = 'helper:'.($pipeline->{ops}[0]{op} // 'array_pipeline');
   $attempt =~ s/([\\"])/\\$1/go;
   push @statements,
    'LinkedSpec::BindingRuntime::assert_receiver_writable(\$'.$target_symbol.', "'.$target_symbol.'", "'.$attempt.'", '
    .'{ source_id => "action:'.$rule_label.'", start => '.$start.', end => '.$end
    .', unit => "unicode_scalar", provenance => "authored" })';
  }
  foreach my $op (@{$pipeline->{ops}}) {
   my $name = $op->{op} // '';
   if ($name eq 'split') {
    my $delimiter_expr = $op->{delimiter_expr};
    $delimiter_expr = 'qr'.$delimiter_expr
     if defined($delimiter_expr) && $delimiter_expr =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;
    push @statements,
     '$'.$target_symbol.' = LinkedSpec::BindingRuntime::split_value($'.$target_symbol.', "'.$target_symbol.'", '
     .$op->{source_expr}.', '.$delimiter_expr.')';
    next;
   }
   my @args;
   if ($name eq 'split_each') {
    my $delimiter_expr = $op->{delimiter_expr};
    $delimiter_expr = 'qr'.$delimiter_expr
     if defined($delimiter_expr) && $delimiter_expr =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;
    push @args, $delimiter_expr;
   }
   if ($name eq 'filter_match') {
    my $pattern_expr = $op->{pattern_expr};
    $pattern_expr = 'qr'.$pattern_expr
     if defined($pattern_expr) && $pattern_expr =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;
    push @args, $pattern_expr;
   }
   my $suffix = @args ? ', '.join(', ', @args) : '';
   push @statements,
    '$'.$target_symbol.' = LinkedSpec::BindingRuntime::array_transform($'.$target_symbol.', "'.$target_symbol.'", "'.$name.'"'.$suffix.')';
  }
  push @statements, $receiver_guarded
   ? 'my $__ls_receiver_guarded_pipeline_result = $'.$target_symbol
   : '$'.$target_symbol;
  return $finish->(
   'do { '.join('; ', @statements).' }',
   'binding_pipeline_lowered',
   { target_symbol => $target_symbol, op_count => scalar(@{$pipeline->{ops}}) },
  )
 }
 my $list_expr = '@'.$target_symbol;
 foreach my $op (@{$pipeline->{ops}}) {
  my $name = $op->{op} // '';
  _trace_array_pipeline_decision(
   phase => 'lower_array_pipeline_expr',
   label => 'expr',
   decision => 'lower_op_'.$name,
   taken => 1,
   context => { target_symbol => $target_symbol, op => $name },
  );
  if ($name eq 'split') {
   $list_expr = 'split '.$op->{delimiter_expr}.', '.$op->{source_expr};
  } elsif ($name eq 'split_each') {
   $list_expr = 'map { split '.$op->{delimiter_expr}.', $_ } '.$list_expr;
  } elsif ($name eq 'trim_each') {
   $list_expr = 'map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } '.$list_expr;
  } elsif ($name eq 'filter_nonempty') {
   $list_expr = 'grep { length($_) } '.$list_expr;
  } elsif ($name eq 'lowercase_each') {
   $list_expr = 'map { LinkedSpec::UnicodeCaseMapping::lowercase($_) } '.$list_expr;
  } elsif ($name eq 'uppercase_each') {
   $list_expr = 'map { LinkedSpec::UnicodeCaseMapping::uppercase($_) } '.$list_expr;
  } elsif ($name eq 'uniq') {
   $list_expr = 'do { my %seen; grep { !$seen{$_}++ } '.$list_expr.' }';
  } elsif ($name eq 'filter_match') {
   $list_expr = 'grep { $_ =~ '.$op->{pattern_expr}.' } '.$list_expr;
  } else {
   return $finish->(undef, 'unsupported_plan_op', { target_symbol => $target_symbol, op => $name });
  }
 }
 return $finish->('@'.$target_symbol.' = '.$list_expr, 'pipeline_lowered', { target_symbol => $target_symbol, op_count => scalar(@{$pipeline->{ops}}) })
}

#------------------------------------------------------------------------------
# Function: _lower_split_statement
# Purpose : Lower `split(...)` method helper into array-assignment form.
# Args    : ($target, $source, $delimiter, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_split_statement {
 my ($target, $source, $delimiter, $deps) = @_;
 my $expr = 'split('.$target.', '.$source;
 $expr .= ', '.$delimiter if defined($delimiter) && length($delimiter);
 $expr .= ')';
 return _lower_array_pipeline_expr($expr, undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_trim_each_statement
# Purpose : Lower `trim_each(...)` method helper into array map-trim form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_trim_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('trim_each('.$target.')', undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_filter_nonempty_statement
# Purpose : Lower `filter_nonempty(...)` method helper into array grep form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_nonempty_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('filter_nonempty('.$target.')', undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_lowercase_each_statement
# Purpose : Lower `lowercase_each(...)` helper into array map lowercase form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_lowercase_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('lowercase_each('.$target.')', undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_uppercase_each_statement
# Purpose : Lower `uppercase_each(...)` helper into array map uppercase form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uppercase_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('uppercase_each('.$target.')', undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_uniq_statement
# Purpose : Lower `uniq(...)` helper into stable unique-filter assignment.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uniq_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('uniq('.$target.')', undef, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_filter_match_statement
# Purpose : Lower `filter_match(...)` helper into regex grep assignment.
# Args    : ($target, $pattern, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_match_statement {
 my ($target, $pattern, $deps) = @_;
 return _lower_array_pipeline_expr('filter_match('.$target.', '.$pattern.')', undef, $deps)
}

1;
