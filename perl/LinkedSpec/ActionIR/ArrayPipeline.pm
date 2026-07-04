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
# Purpose : Build recursive array-pipeline operation plan from composable
#           method expression forms like `filter_match(uniq(array(x)), /.../)`.
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
 return $finish->({target_symbol => $target_symbol, ops => []}, 'target_symbol', { target_symbol => $target_symbol })
  if defined $target_symbol;

 my $call = $parse_method_function_expr->($trimmed);
 return $finish->(undef, 'not_method_call', { expr => $trimmed }) unless $call;
 my $method = $call->{method};
 my $args = $call->{args} || [];

 if ($method eq 'split') {
  my @effective_args = @$args;
  if ((@effective_args == 3 || @effective_args == 4) && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return $finish->(undef, 'split_bad_arity', { arg_count => scalar(@effective_args) })
   unless @effective_args == 2 || @effective_args == 3;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return $finish->(undef, 'split_target_failed', {}) unless $pipeline;

  my $source_symbol = $extract_scalar_symbol_name->($effective_args[1]);
  return $finish->(undef, 'split_source_failed', {}) unless defined $source_symbol;
  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[2], $deps);
  return $finish->(undef, 'split_delimiter_failed', {}) unless defined $delimiter_expr;

  push @{$pipeline->{ops}}, {
   op             => 'split',
   source_symbol  => $source_symbol,
   delimiter_expr => $delimiter_expr,
  };
  return $finish->($pipeline, 'append_split_op', { source_symbol => $source_symbol, delimiter_expr => $delimiter_expr })
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
# Args    : ($expr, $deps)
# Returns : lowered statement string or undef
#------------------------------------------------------------------------------
sub _lower_array_pipeline_expr {
 my ($expr, $deps) = @_;
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
   $list_expr = 'split '.$op->{delimiter_expr}.', $'.$op->{source_symbol};
  } elsif ($name eq 'split_each') {
   $list_expr = 'map { split '.$op->{delimiter_expr}.', $_ } '.$list_expr;
  } elsif ($name eq 'trim_each') {
   $list_expr = 'map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } '.$list_expr;
  } elsif ($name eq 'filter_nonempty') {
   $list_expr = 'grep { length($_) } '.$list_expr;
  } elsif ($name eq 'lowercase_each') {
   $list_expr = 'map { lc($_) } '.$list_expr;
  } elsif ($name eq 'uppercase_each') {
   $list_expr = 'map { uc($_) } '.$list_expr;
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
 return _lower_array_pipeline_expr($expr, $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_trim_each_statement
# Purpose : Lower `trim_each(...)` method helper into array map-trim form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_trim_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('trim_each('.$target.')', $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_filter_nonempty_statement
# Purpose : Lower `filter_nonempty(...)` method helper into array grep form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_nonempty_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('filter_nonempty('.$target.')', $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_lowercase_each_statement
# Purpose : Lower `lowercase_each(...)` helper into array map lowercase form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_lowercase_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('lowercase_each('.$target.')', $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_uppercase_each_statement
# Purpose : Lower `uppercase_each(...)` helper into array map uppercase form.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uppercase_each_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('uppercase_each('.$target.')', $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_uniq_statement
# Purpose : Lower `uniq(...)` helper into stable unique-filter assignment.
# Args    : ($target, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uniq_statement {
 my ($target, $deps) = @_;
 return _lower_array_pipeline_expr('uniq('.$target.')', $deps)
}

#------------------------------------------------------------------------------
# Function: _lower_filter_match_statement
# Purpose : Lower `filter_match(...)` helper into regex grep assignment.
# Args    : ($target, $pattern, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_match_statement {
 my ($target, $pattern, $deps) = @_;
 return _lower_array_pipeline_expr('filter_match('.$target.', '.$pattern.')', $deps)
}

1;
