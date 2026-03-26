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

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one array-pipeline dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Resolve one required array-pipeline dependency callback from the
#           provided dependency map.
# Args    : ($deps, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::ArrayPipeline::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one
#           array-pipeline helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _require_pkg_cb
# Purpose : Lazy-load one array-pipeline dependency owner and resolve one
#           callback from it through the shared owner-dispatch seam.
# Args    : ($pkg, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $name)
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
 return _call_preserving_err(sub {
  return {
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   strip_literal_delimiters => _require_pkg_cb($pkg, '_strip_literal_delimiters'),
   extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
   parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
   is_bare_method_scope_token => _require_pkg_cb($pkg, '_is_bare_method_scope_token'),
   extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
  }
 })
}

#------------------------------------------------------------------------------
# Function: _normalize_split_delimiter_expr
# Purpose : Normalize split delimiter argument into a Perl regex expression.
# Args    : ($delimiter, $deps)
# Returns : Perl regex expression string or undef
#------------------------------------------------------------------------------
sub _normalize_split_delimiter_expr {
 my ($delimiter, $deps) = @_;
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $strip_literal_delimiters = _require_dep($deps, 'strip_literal_delimiters');

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $is_bare_method_scope_token = _require_dep($deps, 'is_bare_method_scope_token');
 my $extract_scalar_symbol_name = _require_dep($deps, 'extract_scalar_symbol_name');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $target_symbol = $extract_array_symbol_name->($trimmed);
 return {target_symbol => $target_symbol, ops => []} if defined $target_symbol;

 my $call = $parse_method_function_expr->($trimmed);
 return undef unless $call;
 my $method = $call->{method};
 my $args = $call->{args} || [];

 if ($method eq 'split') {
  my @effective_args = @$args;
  if ((@effective_args == 3 || @effective_args == 4) && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 2 || @effective_args == 3;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return undef unless $pipeline;

  my $source_symbol = $extract_scalar_symbol_name->($effective_args[1]);
  return undef unless defined $source_symbol;
  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[2], $deps);
  return undef unless defined $delimiter_expr;

  push @{$pipeline->{ops}}, {
   op             => 'split',
   source_symbol  => $source_symbol,
   delimiter_expr => $delimiter_expr,
  };
  return $pipeline
 }
 if ($method eq 'split_each') {
  my @effective_args = @$args;
  if (@effective_args == 3 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 2;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return undef unless $pipeline;

  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[1], $deps);
  return undef unless defined $delimiter_expr;
  push @{$pipeline->{ops}}, {
   op             => 'split_each',
   delimiter_expr => $delimiter_expr,
  };
  return $pipeline
 }

 if ($method eq 'filter_match') {
  my @effective_args = @$args;
  if (@effective_args == 3 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 2;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return undef unless $pipeline;

  my $pattern_expr = _normalize_split_delimiter_expr($effective_args[1], $deps);
  return undef unless defined $pattern_expr;
  push @{$pipeline->{ops}}, {
   op           => 'filter_match',
   pattern_expr => $pattern_expr,
  };
  return $pipeline
 }

 if ($method =~ /^(trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq)$/o) {
  my @effective_args = @$args;
  if (@effective_args == 2 && $is_bare_method_scope_token->($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1], $deps);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 1;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0], $deps);
  return undef unless $pipeline;
  push @{$pipeline->{ops}}, {op => $method};
  return $pipeline
 }

 return undef
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
 my $pipeline = _build_array_pipeline_plan_from_expr($expr, $deps);
 return undef unless $pipeline && $pipeline->{target_symbol};
 return undef unless @{$pipeline->{ops} || []};

 my $target_symbol = $pipeline->{target_symbol};
 my $list_expr = '@'.$target_symbol;
 foreach my $op (@{$pipeline->{ops}}) {
  my $name = $op->{op} // '';
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
   return undef;
  }
 }
 return '@'.$target_symbol.' = '.$list_expr
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
