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

sub _normalize_method_name {
 my ($method) = @_;
 return undef unless defined $method;
 return $method
}

sub _slash_literal_end {
 my ($text, $start) = @_;
 my $len = length($text);
 for (my $pos = $start + 1; $pos < $len; ++$pos) {
  my $char = substr($text, $pos, 1);
  if ($char eq '\\') { ++$pos; next }
  next unless $char eq '/';
  ++$pos;
  ++$pos while $pos < $len && substr($text, $pos, 1) =~ /[A-Za-z]/o;
  return $pos;
 }
 return undef;
}

sub _pattern_stays_in_operand {
 my ($text, $start, $end) = @_;
 my $call_end = _slash_symbol_call_end_at($text, $start);
 return 1 unless defined $call_end;
 my $close = $end - 1;
 --$close while substr($text, $close, 1) =~ /[A-Za-z]/o;
 return 0 if $close < $call_end;
 my $after = $call_end;
 ++$after while $after < length($text) && substr($text, $after, 1) =~ /\s/o;
 return 0 if $after == length($text) || substr($text, $after, 1) =~ /[;\)\]]/o;
 return 1 unless substr($text, $after, 1) =~ /[,\.]/o;
 my @closers;
 my %closer = ('(' => ')', '[' => ']', '{' => '}');
 for (my $pos = $call_end; $pos < $close; ++$pos) {
  my $char = substr($text, $pos, 1);
  if ($char eq '\\') { ++$pos; next }
  if ($char eq '"' || $char eq "'") {
   my $quote_end = $pos + 1;
   while ($quote_end < length($text)) {
    my $quoted = substr($text, $quote_end, 1);
    if ($quoted eq '\\') { $quote_end += 2; next }
    last if $quoted eq $char;
    ++$quote_end;
   }
   if ($quote_end < length($text) && $quote_end > $close) {
    my $after_quote = $quote_end + 1;
    ++$after_quote while $after_quote < length($text) && substr($text, $after_quote, 1) =~ /\s/o;
    # The opening quote of a later replacement is not a numeric string's
    # terminator when the resulting token runs straight into its contents.
    return 0 if $after_quote == length($text)
     || substr($text, $after_quote, 1) =~ /[,\)\]\};.\-+*\/%&|^?:]/o;
   }
   $pos = $quote_end if $quote_end < $close;
   next;
  }
  if (exists $closer{$char}) { push @closers, $closer{$char}; next }
  return 0 if $char =~ /[\)\]\}]/o && (!@closers || pop(@closers) ne $char);
 }
 return 1;
}

# Do not discover DSL calls inside an explicit host quote operator. Parenthesis
# delimiters remain with ordinary call parsing; the host forms protected here
# have an unambiguous non-call delimiter (q|...|, qr/.../, s{...}{...}, etc.).
sub _host_quote_end {
 my ($text, $start) = @_;
 my $open = substr($text, $start, 1);
 # Square brackets belong to DSL indexed reads, including q[index], m[index]
 # and qr[index]. Treating those names as host quote operators hides calls in
 # the index expression from the helper-context scan.
 return undef unless $open =~ m{[/|\{<]}o;
 my $prefix = substr($text, 0, $start);
 return undef unless $prefix =~ /(?:\A|[^\w\$:\.])(?<op>q[qwxr]?|m|s|tr|y)\s*\z/o;
 my $segments = $+{op} =~ /\A(?:s|tr|y)\z/o ? 2 : 1;
 my %paired = ('{' => '}', '<' => '>');
 my $close = $paired{$open} // $open;
 my $pos = $start;
 for my $segment (1 .. $segments) {
  my $depth = 1;
  while (++$pos < length($text)) {
   my $char = substr($text, $pos, 1);
   if ($char eq '\\') { ++$pos; next }
   ++$depth if exists($paired{$open}) && $char eq $open;
   last if $char eq $close && --$depth == 0;
  }
  if ($segment < $segments && exists($paired{$open})) {
   ++$pos while $pos + 1 < length($text) && substr($text, $pos + 1, 1) =~ /\s/o;
   return length($text) unless substr($text, $pos + 1, 1) eq $open;
   ++$pos;
  }
 }
 return $pos + 1;
}

# This recognizer admits a complete regex token in a helper's pattern position.
# In particular, an array argument may contain both /(14,2) and host arithmetic
# such as 14/cos; merging those into one /.../cos token changes accepted values.
sub _helper_pattern_tail {
 my ($text, $end, $frame) = @_;
 return 0 unless $frame && $frame->{open} eq '(';
 my $method = $frame->{method} // '';
 $method =~ s/\A__array_value_(split_each|filter_match)\z/$1/o;
 my $argument = scalar(@{$frame->{args}});
 my $receiver = $frame->{receiver};
 my $tail = substr($text, $end);
 if ($method eq 'matches') {
  return $argument == ($receiver ? 0 : 1) && $tail =~ /\A\s*\)/o;
 }
 if ($method eq 'split' || $method eq 'split_each' || $method eq 'filter_match') {
  my $position = $receiver ? $argument == 0 : ($argument == 1 || $argument == 2);
  return $position && $tail =~ /\A\s*\)/o;
 }
 if ($method eq 'regex_subst' || $method eq 'substr') {
  return 0 if $receiver || ($argument != 1 && $argument != 2);
  return 0 if grep { $_ !~ /\A:?\w+\z/o } @{$frame->{args}};
  # The existing substitution contract requires a literal replacement and a
  # separate flags argument. A slash in another numeric argument cannot supply
  # the pattern terminator by consuming that replacement.
  return $tail =~ /\A\s*,\s*(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/)\s*,\s*\w*\s*\)/so;
 }
 return 0;
}

sub _helper_pattern_ranges {
 my ($text) = @_;
 my @ranges;
 return \@ranges if index($text, '/') < 0
  || $text !~ /\b(?:matches|split|(?:__array_value_)?(?:split_each|filter_match)|regex_subst|substr)\s*\(/o;
 my @scopes;
 my $len = length($text);
 for (my $pos = 0; $pos < $len; ++$pos) {
  my $char = substr($text, $pos, 1);
  my $host_end = _host_quote_end($text, $pos);
  if (defined($host_end)) { $pos = $host_end - 1; next }
  if ($char eq '"' || $char eq "'" || $char eq '`') {
   my $quote = $char;
   while (++$pos < $len) {
    my $quoted = substr($text, $pos, 1);
    if ($quoted eq '\\') { ++$pos; next }
    last if $quoted eq $quote;
   }
   next;
  }
  if ($char eq '#') {
   ++$pos while $pos < $len && substr($text, $pos, 1) ne "\n";
   next;
  }
  if ($char eq '/') {
   my $frame = @scopes ? $scopes[-1] : undef;
   my $at_argument = $frame && $frame->{open} eq '('
    && substr($text, $frame->{argument_start}, $pos - $frame->{argument_start}) =~ /\A\s*\z/o;
   my $end = _slash_literal_end($text, $pos);
   if ($at_argument && defined($end) && _helper_pattern_tail($text, $end, $frame)
       && _pattern_stays_in_operand($text, $pos, $end)) {
    push @ranges, [$pos, $end];
    $pos = $end - 1;
    next;
   }
   my $prefix = substr($text, 0, $pos);
   if (defined($end) && !_looks_like_slash_symbol_call_at($text, $pos, 1)
       && $prefix =~ /(?:\A\s*|[\(\[,=~!]\s*)\z/o) {
    $pos = $end - 1;
    next;
   }
  }
  if ($char =~ /[\(\[\{]/o) {
   my $prefix = substr($text, 0, $pos);
   my ($receiver, $method) = $prefix =~ /(\.\s*)?([A-Za-z_]\w*)\s*\z/o;
   push @scopes, { open => $char, method => $method, receiver => defined($receiver),
    argument_start => $pos + 1, args => [] };
   next;
  }
  if ($char =~ /[\)\]\}]/o) {
   my %opening = (')' => '(', ']' => '[', '}' => '{');
   if (@scopes && $scopes[-1]{open} eq $opening{$char}) { pop @scopes }
   else { @scopes = () }
   next;
  }
  if ($char eq ',' && @scopes && $scopes[-1]{open} eq '(') {
   my $frame = $scopes[-1];
   push @{$frame->{args}}, _trim_method_expr_value(
    substr($text, $frame->{argument_start}, $pos - $frame->{argument_start}));
   $frame->{argument_start} = $pos + 1;
  }
 }
 return \@ranges;
}

sub _helper_pattern_view {
 my ($text) = @_;
 my $view = $text;
 for my $range (@{_helper_pattern_ranges($text)}) {
  my ($start, $end) = @$range;
  my $mask = substr($text, $start, $end - $start);
  $mask =~ s/[^\r\n]/ /g;
  substr($mask, 0, 1) = '0';
  substr($view, $start, $end - $start) = $mask;
 }
 return $view;
}

sub _slash_symbol_call_end_at {
 my ($text, $idx) = @_;
 return undef unless defined $text;
 my $len = length($text);
 return undef if $idx < 0 || $idx >= $len || substr($text, $idx, 1) ne '/';

 my $cursor = $idx + 1;
 ++$cursor while $cursor < $len && substr($text, $cursor, 1) =~ /\s/o;
 return undef unless $cursor < $len && substr($text, $cursor, 1) eq '(';

 my $depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $escape_next = 0;

 for (my $pos = $cursor; $pos < $len; ++$pos) {
  my $char = substr($text, $pos, 1);

  if ($in_single_quote) {
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
   next;
  }
  if ($char eq '"') {
   $in_double_quote = 1;
   next;
  }
  if ($char eq '\\') {
   ++$pos;
   next;
  }
  if ($char eq '(') {
   ++$depth;
   next;
  }
  if ($char eq ')') {
   --$depth if $depth > 0;
   next unless $depth == 0;

   return $pos + 1;
  }
 }

 return undef
}

sub _looks_like_slash_symbol_call_at {
 my ($text, $idx, $numeric_only) = @_;
 my $after = _slash_symbol_call_end_at($text, $idx);
 return 0 unless defined $after;
 my $len = length($text);
 ++$after while $after < $len && substr($text, $after, 1) =~ /\s/o;
 if (!$numeric_only && $after < $len && substr($text, $after, 1) =~ /[,\.]/o) {
  return 0 if grep { $_->[0] == $idx } @{_helper_pattern_ranges($text)};
 }
 return 1 if $after >= $len || substr($text, $after, 1) =~ /[,;\.\)\]]/o;
 return 0;
}

#------------------------------------------------------------------------------
# Function: _split_top_level_csv
# Purpose : Split comma-separated argument lists while honoring nested scopes
#           and quoted-string regions.
# Args    : ($text, $method?) — a leading dot marks receiver-call context
# Returns : arrayref of trimmed argument strings
#------------------------------------------------------------------------------
sub _split_top_level_csv {
 my ($text, $method) = @_;
 return [] unless defined $text;

 my $prefix = defined($method) ? "$method(" : '';
 my $view = _helper_pattern_view($prefix . $text . (length($prefix) ? ')' : ''));
 $view = substr($view, length($prefix), length($text));

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
 my $idx = -1;
 my $piece_start = 0;

 foreach my $char (split //, $view) {
  ++$idx;
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
   if (!length($current_context) && !_looks_like_slash_symbol_call_at($text, $idx)) {
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
   my $trimmed = _trim_method_expr_value(substr($text, $piece_start, $idx - $piece_start));
   push @parts, $trimmed if defined($trimmed) && length($trimmed);
   $piece_start = $idx + 1;
   $current = '';
   next;
  }
  $current .= $char;
 }

 my $trimmed = _trim_method_expr_value(substr($text, $piece_start));
 push @parts, $trimmed if defined($trimmed) && length($trimmed);
 return \@parts
}

#------------------------------------------------------------------------------
# Function: _parse_method_function_expr
# Purpose : Parse `method(arg1, arg2, ...)` expressions with nested-paren args.
# Args    : ($expr, $receiver?)
# Returns : hashref { method => ..., args => [...] } or undef
#------------------------------------------------------------------------------
sub _parse_method_function_expr {
 my ($expr, $receiver) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_method_expr_value($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $view = _helper_pattern_view(($receiver ? '.' : '') . $trimmed);
 $view = substr($view, 1) if $receiver;
 return undef unless $view =~ /^(?<method>\w+|==|!=|>=|<=|=|[+\-*\/%<>])\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))$/o;
 my $source_method = $+{method};
 my $method = _normalize_method_name($source_method);

 my $payload = substr($trimmed, $-[2], $+[2] - $-[2]);
 $payload =~ s/^\(|\)$//go;
 return {
  method        => $method,
  source_method => $source_method,
  source        => $trimmed,
  args          => _split_top_level_csv($payload, ($receiver ? '.' : '') . $method),
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
 return defined($token) && $token =~ /^[A-Za-z_]\w*$/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _normalize_method_args_with_optional_scope
# Purpose : Normalize method argument lists by stripping optional leading scope
#           token when present and validating min/max arity. Current value
#           helpers may request authored-value precedence: an already-valid
#           argument list is then returned intact before scope fallback.
# Args    : ($args, $min_arity, $max_arity, $authored_values_take_precedence)
# Returns : arrayref effective args or undef
#------------------------------------------------------------------------------
sub _normalize_method_args_with_optional_scope {
 my ($args, $min_arity, $max_arity, $authored_values_take_precedence) = @_;
 return undef unless ref($args) eq 'ARRAY';

 $min_arity = 0 unless defined $min_arity;
 $max_arity = 10**9 unless defined $max_arity;

 my $authored_count = scalar(@$args);
 if (
  $authored_values_take_precedence
  && $authored_count >= $min_arity
  && $authored_count <= $max_arity
 ) {
  return [@$args];
 }

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
