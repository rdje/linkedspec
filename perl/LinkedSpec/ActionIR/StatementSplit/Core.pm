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

sub _require_pkg {
 my ($pkg) = @_;
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
}

sub _require_statement_split_mode_pkg {
 return _require_pkg('LinkedSpec::ActionIR::StatementSplit::Mode')
}

sub _build_initial_state {
 return {
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
  pipe_quote_segments_remaining => 0,
  pipe_quote_escape_next => 0,
  in_line_comment => 0,
  escape_next => 0,
 }
}

sub _push_trimmed_statement {
 my ($statements, $trim_action_ir_value, $statement) = @_;
 my $trimmed = $trim_action_ir_value->($statement);
 push @$statements, $trimmed if defined($trimmed) && length($trimmed);
 return
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
  _push_trimmed_statement($statements, $trim_action_ir_value, $state->{statement});
  $state->{statement} = '';
  return 1;
 }

 return 0
}

sub split_action_ir_statements {
 my ($code, $trim_action_ir_value) = @_;
 _require_statement_split_mode_pkg();
 my $state = _build_initial_state();
 my @statements;

 foreach my $char (split //, $code) {
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_line_comment($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_single_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_double_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_slash_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_angle_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_pipe_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_single_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::consume_backtick_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_double_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_backtick_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_line_comment($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_slash_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_angle_quote($state, $char)) { next; }
  if (LinkedSpec::ActionIR::StatementSplit::Mode::maybe_enter_pipe_quote($state, $char)) { next; }
  if (_consume_nesting_or_terminator($state, $char, \@statements, $trim_action_ir_value)) { next; }
  $state->{statement} .= $char;
 }

 _push_trimmed_statement(\@statements, $trim_action_ir_value, $state->{statement});
 return \@statements
}

1;
