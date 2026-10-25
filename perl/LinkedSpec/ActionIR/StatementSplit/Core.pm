package LinkedSpec::ActionIR::StatementSplit::Core;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $statement_split_dir = File::Basename::dirname($module_dir);
 my $action_ir_dir = File::Basename::dirname($statement_split_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();
use Scalar::Util ();

our $_source_statement_recorder;

# The canonical splitter publishes its original array and aligned source frames
# only inside a private invocation. A callback is still called exactly once with
# its original arguments; opaque or copied returns never borrow another array's
# provenance. Nested private calls restore the enclosing collector.
sub _split_with_source_frames {
 my ($callback, @args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my @recorded;
  local $_source_statement_recorder = sub { push @recorded, $_[0] };
  my $statements = $callback->(@args);
  my @frames;
  if (ref($statements) eq 'ARRAY') {
   foreach my $batch (@recorded) {
    next unless Scalar::Util::refaddr($batch->{statements})
     == Scalar::Util::refaddr($statements);
    for my $idx (0 .. $#$statements) {
     my $frame = $batch->{source_frames}[$idx];
     my $value = $statements->[$idx];
     # A custom callback may change a produced entry before returning its array.
     # Keep that result, but decline a frame for changed or non-scalar text.
     push @frames, defined($frame) && defined($value) && !ref($value)
      && $frame->{raw} eq $value ? $frame : undef;
    }
    last;
   }
  }
  return {statements => $statements, source_frames => \@frames}
 })
}


#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::StatementSplit::Core
# Purpose : Core ActionIR statement-splitting owner that tracks parser state
#           and lazily loads the helper packages needed for split heuristics.
#------------------------------------------------------------------------------

sub _require_statement_split_mode_pkg {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::StatementSplit::Mode');
 return 'LinkedSpec::ActionIR::StatementSplit::Mode'
}

sub _require_method_expr_pkg {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::MethodExpr');
 return 'LinkedSpec::ActionIR::MethodExpr'
}

sub _build_initial_state {
 my ($source) = @_;
 return {
  source => $source,
  statement_start => 0,
  next_position => 0,
  statement => '',
  paren_depth => 0,
  brace_depth => 0,
  bracket_depth => 0,
  in_single_quote => 0,
  in_double_quote => 0,
  in_backtick_quote => 0,
  in_slash_quote => 0,
  slash_quote_segments_remaining => 0,
  slash_quote_escape_next => 0,
  in_angle_quote => 0,
  angle_quote_segments_remaining => 0,
  angle_quote_depth => 0,
  angle_quote_escape_next => 0,
  in_pipe_quote => 0,
  in_callable_signature => 0,
  pipe_quote_segments_remaining => 0,
  pipe_quote_escape_next => 0,
  in_line_comment => 0,
  escape_next => 0,
 }
}

sub _is_bare_zero_arg_flow_marker_statement {
 my ($statement, $trim_action_ir_value) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 return 0 unless defined($trimmed) && length($trimmed);
 return 1 if $trimmed =~ /^(?:else|otherwise|endif|default|endcase|endswitch|next)$/o;
 return 0
}

sub _looks_like_complete_method_statement {
 my ($statement, $trim_action_ir_value) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 return 0 unless defined($trimmed) && length($trimmed);
 return 1 if _is_bare_zero_arg_flow_marker_statement($trimmed, $trim_action_ir_value);
 _require_method_expr_pkg();
 my $call = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($trimmed);
 return 1 if $call;

 my @chars = split //, $trimmed;
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_slash_quote = 0;
 my $slash_escape_next = 0;
 my $escape_next = 0;

 for (my $idx = 0; $idx < @chars; ++$idx) {
  my $char = $chars[$idx];

  if ($in_slash_quote) {
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
  if ($char eq '/') {
   my $prefix = substr($trimmed, 0, $idx);
   $prefix =~ s/\s+$//o;
   if (!length($prefix)) {
    $in_slash_quote = 1;
    $slash_escape_next = 0;
    next;
   }
  }
  if ($char eq '(') {
   ++$paren_depth;
   next;
  }
  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   next;
  }
  if ($char eq '[') {
   ++$bracket_depth;
   next;
  }
  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   next;
  }
  next unless $char eq '{';
  next if $paren_depth || $brace_depth || $bracket_depth;

  my $head = $trim_action_ir_value->(substr($trimmed, 0, $idx));
  next unless defined($head) && length($head);
  $call = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($head);
  next unless $call || _is_bare_zero_arg_flow_marker_statement($head, $trim_action_ir_value);

  my $body_depth = 0;
  my $body_in_single_quote = 0;
  my $body_in_double_quote = 0;
  my $body_in_slash_quote = 0;
  my $body_slash_escape_next = 0;
  my $body_escape_next = 0;

  for (my $body_idx = $idx; $body_idx < @chars; ++$body_idx) {
   my $body_char = $chars[$body_idx];

   if ($body_in_slash_quote) {
    if ($body_slash_escape_next) {
     $body_slash_escape_next = 0;
    } elsif ($body_char eq '\\') {
     $body_slash_escape_next = 1;
    } elsif ($body_char eq '/') {
     $body_in_slash_quote = 0;
    }
    next;
   }

   if ($body_in_single_quote) {
    if ($body_escape_next) {
     $body_escape_next = 0;
    } elsif ($body_char eq '\\') {
     $body_escape_next = 1;
    } elsif ($body_char eq "'") {
     $body_in_single_quote = 0;
    }
    next;
   }

   if ($body_in_double_quote) {
    if ($body_escape_next) {
     $body_escape_next = 0;
    } elsif ($body_char eq '\\') {
     $body_escape_next = 1;
    } elsif ($body_char eq '"') {
     $body_in_double_quote = 0;
    }
    next;
   }

   if ($body_char eq "'") {
    $body_in_single_quote = 1;
    next;
   }
   if ($body_char eq '"') {
    $body_in_double_quote = 1;
    next;
   }
   if ($body_char eq '/') {
    my $body_prefix = substr($trimmed, $idx, $body_idx - $idx);
    $body_prefix =~ s/\s+$//o;
    if ($body_depth == 0 || !length($body_prefix)) {
     $body_in_slash_quote = 1;
     $body_slash_escape_next = 0;
     next;
    }
   }
   if ($body_char eq '{') {
    ++$body_depth;
    next;
   }
   if ($body_char eq '}') {
    --$body_depth if $body_depth > 0;
    next unless $body_depth == 0;
    my $tail = $trim_action_ir_value->(substr($trimmed, $body_idx + 1));
    return (!defined($tail) || !length($tail)) ? 1 : 0;
   }
  }
 }

 return 0
}

sub _looks_like_attached_if_branch_statement {
 my ($statement, $trim_action_ir_value) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 return 0 unless defined($trimmed) && length($trimmed);
 return 0 unless $trimmed =~ /\A(?:if|i|when|elseif|elif)\b/o;
 return 0 unless $trimmed =~ /\}\s*\z/s;
 return 1
}

sub _looks_like_attached_switch_branch_statement {
 my ($statement, $trim_action_ir_value) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 return 0 unless defined($trimmed) && length($trimmed);
 return 0 unless $trimmed =~ /\A(?:case\b\s*\(|default\b\s*\{)/o;
 return 0 unless $trimmed =~ /\}\s*\z/s;
 return 1
}

sub _next_nonspace_char_index {
 my ($chars, $start_idx) = @_;
 my $idx = $start_idx;
 while ($idx < @$chars && $chars->[$idx] =~ /\s/o) {
  ++$idx;
 }
 return $idx < @$chars ? $idx : undef
}

sub _next_token_is_attached_if_continuation {
 my ($chars, $start_idx) = @_;
 return 0 unless defined $start_idx && $start_idx < @$chars;
 my $tail = join('', @{$chars}[$start_idx .. $#$chars]);
 return 1 if $tail =~ /\A(?:elseif|elif)\b\s*\(/o;
 return 1 if $tail =~ /\A(?:else|otherwise)\b\s*\{/o;
 return 0
}

sub _next_token_is_attached_switch_continuation {
 my ($chars, $start_idx) = @_;
 return 0 unless defined $start_idx && $start_idx < @$chars;
 my $tail = join('', @{$chars}[$start_idx .. $#$chars]);
 return 1 if $tail =~ /\Acase\b\s*\(/o;
 return 1 if $tail =~ /\Adefault\b\s*\{/o;
 return 0
}

sub _span_contains_line_break {
 my ($chars, $start_idx, $end_idx) = @_;
 return 0 unless defined($start_idx) && defined($end_idx);
 for (my $idx = $start_idx; $idx < $end_idx && $idx < @$chars; ++$idx) {
  return 1 if $chars->[$idx] eq "\n" || $chars->[$idx] eq "\r";
 }
 return 0
}

sub _is_assigned_raw_multiline_pattern {
 my ($state, $code, $idx) = @_;
 return 0 unless $state->{statement} =~ /\A\s*[A-Za-z_][A-Za-z0-9_]*\s*=\s*\z/o;
 my $tail = substr($code, $idx);
 return 0 unless $tail =~ /\A([^\r\n]*)[\r\n]/;
 my $first_line = $1;
 _require_method_expr_pkg();
 my $end = LinkedSpec::ActionIR::MethodExpr::_slash_literal_end($tail, 0);
 return 0 unless defined($end) && $end > length($first_line);
 # A complete first-line DSL expression keeps its established newline boundary,
 # especially /(14,2) followed by a quote operator on the next line.
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST');
 my $first = LinkedSpec::ActionIR::AST::parse_action_expr($first_line);
 return ref($first) eq 'HASH' && ($first->{kind} // '') eq 'raw_perl' ? 1 : 0
}

sub _should_split_on_method_boundary {
 my ($state, $chars, $idx, $trim_action_ir_value) = @_;
 return 0 if $state->{paren_depth} || $state->{brace_depth} || $state->{bracket_depth};
 return 0 unless _looks_like_complete_method_statement($state->{statement}, $trim_action_ir_value);
 my $next_idx = _next_nonspace_char_index($chars, $idx + 1);
 return 0 unless defined $next_idx;
 return 1
  if _looks_like_attached_if_branch_statement($state->{statement}, $trim_action_ir_value)
  && _next_token_is_attached_if_continuation($chars, $next_idx);
 return 1
  if _looks_like_attached_switch_branch_statement($state->{statement}, $trim_action_ir_value)
  && _next_token_is_attached_switch_continuation($chars, $next_idx);
 return 0 unless _span_contains_line_break($chars, $idx + 1, $next_idx);
 return ($chars->[$next_idx] =~ /[A-Za-z_]/o) ? 1 : 0
}

# Derive coordinates from the accumulated original statement and its boundary,
# never by locating equal trimmed text elsewhere in the action. The existing trim
# callback runs once at the existing site. Only exact edge trimming can publish a
# contiguous frame; custom interior transformations retain their result without
# invented source coordinates.
sub _frame_for_trimmed_statement {
 my ($state, $trimmed) = @_;
 return undef unless defined($trimmed) && !ref($trimmed)
  && defined($state->{source}) && !ref($state->{source});
 my $statement = $state->{statement};
 my ($leading) = $statement =~ /\A(\s*)/;
 my ($trailing) = $statement =~ /(\s*)\z/;
 my $left = length($leading);
 my $right = length($statement) - length($trailing);
 return undef if $left > $right;
 return undef unless substr($statement, $left, $right - $left) eq $trimmed;
 my $start = $state->{statement_start} + $left;
 my $end = $state->{statement_start} + $right;
 return undef unless substr($state->{source}, $start, $end - $start) eq $trimmed;
 return {
  source => $state->{source},
  raw => $trimmed,
  source_span => {start => $start, end => $end},
 }
}

sub _push_trimmed_statement {
 my ($statements, $trim_action_ir_value, $statement, $state) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 if (defined($trimmed) && length($trimmed)) {
  push @$statements, $trimmed;
  if (ref($_source_statement_recorder) eq 'CODE') {
   push @{$state->{source_frames}}, _frame_for_trimmed_statement($state, $trimmed);
  }
 }
 return
}

sub _consume_top_level_line_break {
 my ($state, $char, $statements, $trim_action_ir_value) = @_;
 return 0 unless $char eq "\n" || $char eq "\r";
 return 0 if $state->{paren_depth} || $state->{brace_depth} || $state->{bracket_depth};
 _push_trimmed_statement($statements, $trim_action_ir_value, $state->{statement}, $state);
 $state->{statement} = '';
 $state->{statement_start} = $state->{next_position};
 return 1
}

sub _consume_nesting_or_terminator {
 my ($state, $char, $statements, $trim_action_ir_value) = @_;
 if ($char eq '(') {
  ++$state->{paren_depth};
  $state->{statement} .= $char;
  return 1;
 }

 if ($char eq ')') {
  --$state->{paren_depth} if $state->{paren_depth} > 0;
  $state->{statement} .= $char;
  return 1;
 }

 if ($char eq '{') {
  ++$state->{brace_depth};
  $state->{statement} .= $char;
  return 1;
 }

 if ($char eq '}') {
  --$state->{brace_depth} if $state->{brace_depth} > 0;
  $state->{statement} .= $char;
  return 1;
 }

 if ($char eq '[') {
  ++$state->{bracket_depth};
  $state->{statement} .= $char;
  return 1;
 }

 if ($char eq ']') {
  --$state->{bracket_depth} if $state->{bracket_depth} > 0;
  $state->{statement} .= $char;
  return 1;
 }

 if (
  $char eq ';' &&
  $state->{paren_depth} == 0 &&
  $state->{brace_depth} == 0 &&
  $state->{bracket_depth} == 0
 ) {
  _push_trimmed_statement($statements, $trim_action_ir_value, $state->{statement}, $state);
  $state->{statement} = '';
  $state->{statement_start} = $state->{next_position};
  return 1;
 }

 return 0
}

sub split_action_ir_statements {
 my ($code, $trim_action_ir_value) = @_;
 _require_statement_split_mode_pkg();
 my $state = _build_initial_state($code // '');
 my @statements;
 my @chars = split //, ($code // '');

 for (my $idx = 0; $idx < @chars; ++$idx) {
  my $char = $chars[$idx];
  $state->{next_position} = $idx + 1;
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_line_comment($state, $char)) {
   _consume_top_level_line_break($state, $char, \@statements, $trim_action_ir_value)
    unless $state->{in_line_comment};
   next;
  }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_single_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_double_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_slash_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_angle_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_pipe_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_single_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_backtick_quote($state, $char)) { next; }
  # Exact {| opens a callable signature in unquoted source. Its closing pipe
  # belongs to that signature even when the final parameter is named y, q, etc.
  # Protect only those two delimiters; the body and existing host quote modes
  # resume their ordinary lexical ownership after the signature closes.
  if ($char eq '|') {
   if ($state->{in_callable_signature}) {
    $state->{in_callable_signature} = 0;
    $state->{statement} .= $char;
    next;
   }
   if ($state->{statement} =~ /\{\z/o) {
    $state->{in_callable_signature} = 1;
    $state->{statement} .= $char;
    next;
   }
  }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_double_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_backtick_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_line_comment($state, $char)) { next; }
  # Protect helper patterns and incomplete raw assignment payloads. Complete
  # first-line DSL expressions retain their existing slash/newline precedence.
  my $helper_pattern = 0;
  if ($char eq '/' && $state->{paren_depth} > 0
      && $state->{statement} =~ /[(,]\s*$/o) {
   _require_method_expr_pkg();
   $helper_pattern = !LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($code, $idx);
  }
  $helper_pattern ||= _is_assigned_raw_multiline_pattern($state, $code, $idx)
   if $char eq '/' && !$state->{paren_depth};
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_slash_quote($state, $char, $helper_pattern)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_angle_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_pipe_quote($state, $char)) { next; }
  if (_consume_top_level_line_break($state, $char, \@statements, $trim_action_ir_value)) { next; }
  if (_consume_nesting_or_terminator($state, $char, \@statements, $trim_action_ir_value)) {
   if (_should_split_on_method_boundary($state, \@chars, $idx, $trim_action_ir_value)) {
    _push_trimmed_statement(\@statements, $trim_action_ir_value, $state->{statement}, $state);
    $state->{statement} = '';
    $state->{statement_start} = $state->{next_position};
   }
   next;
  }
  $state->{statement} .= $char;
  if (_should_split_on_method_boundary($state, \@chars, $idx, $trim_action_ir_value)) {
   _push_trimmed_statement(\@statements, $trim_action_ir_value, $state->{statement}, $state);
   $state->{statement} = '';
   $state->{statement_start} = $state->{next_position};
  }
 }

 _push_trimmed_statement(\@statements, $trim_action_ir_value, $state->{statement}, $state);
 if (ref($_source_statement_recorder) eq 'CODE') {
  $_source_statement_recorder->({
   statements => \@statements,
   source_frames => $state->{source_frames} // [],
  });
 }
 return \@statements
}

1;
