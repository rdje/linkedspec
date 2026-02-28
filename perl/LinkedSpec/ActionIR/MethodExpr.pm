package LinkedSpec::ActionIR::MethodExpr;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _trim_method_expr_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

#------------------------------------------------------------------------------
# Function: _split_top_level_csv
# Purpose : Split comma-separated argument lists while honoring nested scopes
#           and quoted-string regions.
# Args    : ($text)
# Returns : arrayref of trimmed argument strings
#------------------------------------------------------------------------------
sub _split_top_level_csv {
 my ($text) = @_;
 return [] unless defined $text;

 my @parts;
 my $current = '';
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_slash_quote = 0;
 my $slash_escape_next = 0;
 my $escape_next = 0;

 foreach my $char (split //, $text) {
  if ($in_slash_quote) {
   $current .= $char;
   if ($slash_escape_next) {
    $slash_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_escape_next = 1;
   } elsif ($char eq '/') {
    $in_slash_quote = 0;
   }
   next;
  }
  if ($in_single_quote) {
   $current .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq "'") {
    $in_single_quote = 0;
   }
   next;
  }

  if ($in_double_quote) {
   $current .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($char eq "'") {
   $in_single_quote = 1;
   $current .= $char;
   next;
  }
  if ($char eq '"') {
   $in_double_quote = 1;
   $current .= $char;
   next;
  }
  if ($char eq '/') {
   my $current_context = $current;
   $current_context =~ s/\s+$//o;
   if (!length($current_context)) {
    $in_slash_quote = 1;
    $slash_escape_next = 0;
    $current .= $char;
    next;
   }
  }
  if ($char eq '(') {
   ++$paren_depth;
   $current .= $char;
   next;
  }
  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq '{') {
   ++$brace_depth;
   $current .= $char;
   next;
  }
  if ($char eq '}') {
   --$brace_depth if $brace_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq '[') {
   ++$bracket_depth;
   $current .= $char;
   next;
  }
  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq ',' && $paren_depth == 0 && $brace_depth == 0 && $bracket_depth == 0) {
   my $trimmed = _trim_method_expr_value($current);
   push @parts, $trimmed if defined($trimmed) && length($trimmed);
   $current = '';
   next;
  }
  $current .= $char;
 }

 my $trimmed = _trim_method_expr_value($current);
 push @parts, $trimmed if defined($trimmed) && length($trimmed);
 return \@parts
}

#------------------------------------------------------------------------------
# Function: _parse_method_function_expr
# Purpose : Parse `method(arg1, arg2, ...)` expressions with nested-paren args.
# Args    : ($expr)
# Returns : hashref { method => ..., args => [...] } or undef
#------------------------------------------------------------------------------
sub _parse_method_function_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_method_expr_value($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return undef unless $trimmed =~ /^(?<method>\w+)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))$/o;
 my $method = $+{method};

 my $payload = $+{PAREN};
 $payload =~ s/^\(|\)$//go;
 return {
  method => $method,
  args   => _split_top_level_csv($payload),
 }
}

#------------------------------------------------------------------------------
# Function: _is_bare_method_scope_token
# Purpose : Check whether token is a bare scope label candidate.
# Args    : ($token)
# Returns : boolean
#------------------------------------------------------------------------------
sub _is_bare_method_scope_token {
 my ($token) = @_;
 return 0 unless defined $token;
 $token = _trim_method_expr_value($token);
 return defined($token) && $token =~ /^\w+$/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _normalize_method_args_with_optional_scope
# Purpose : Normalize method argument lists by stripping optional leading scope
#           token when present and validating min/max arity.
# Args    : ($args, $min_arity, $max_arity)
# Returns : arrayref effective args or undef
#------------------------------------------------------------------------------
sub _normalize_method_args_with_optional_scope {
 my ($args, $min_arity, $max_arity) = @_;
 return undef unless ref($args) eq 'ARRAY';

 $min_arity = 0 unless defined $min_arity;
 $max_arity = 10**9 unless defined $max_arity;

 my @effective = @$args;
 if (
  @effective >= ($min_arity + 1) &&
  @effective <= ($max_arity + 1) &&
  _is_bare_method_scope_token($effective[0])
 ) {
  my @without_scope = @effective;
  shift @without_scope;
  if (@without_scope >= $min_arity && @without_scope <= $max_arity) {
   @effective = @without_scope;
  }
 }

 return undef unless @effective >= $min_arity && @effective <= $max_arity;
 return \@effective
}

1;
