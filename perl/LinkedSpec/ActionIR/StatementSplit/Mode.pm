package LinkedSpec::ActionIR::StatementSplit::Mode;

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

sub _trim_context_suffix {
 my ($statement) = @_;
 my $context = defined($statement) ? $statement : '';
 $context =~ s/\s+$//o;
 return $context
}

sub consume_line_comment {
 my ($state, $char) = @_;
 return 0 unless $state->{in_line_comment};
 $state->{statement} .= $char;
 if ($char eq "\n") {
  $state->{in_line_comment} = 0;
 }
 return 1
}

sub consume_single_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_single_quote};
 $state->{statement} .= $char;
 if ($state->{escape_next}) {
  $state->{escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{escape_next} = 1;
 } elsif ($char eq "'") {
  $state->{in_single_quote} = 0;
 }
 return 1
}

sub consume_double_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_double_quote};
 $state->{statement} .= $char;
 if ($state->{escape_next}) {
  $state->{escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{escape_next} = 1;
 } elsif ($char eq '"') {
  $state->{in_double_quote} = 0;
 }
 return 1
}

sub consume_slash_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_slash_quote};
 $state->{statement} .= $char;
 if ($state->{slash_quote_escape_next}) {
  $state->{slash_quote_escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{slash_quote_escape_next} = 1;
 } elsif ($char eq '/') {
  --$state->{slash_quote_segments_remaining} if $state->{slash_quote_segments_remaining} > 0;
  $state->{in_slash_quote} = 0 if $state->{slash_quote_segments_remaining} == 0;
 }
 return 1
}

sub consume_angle_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_angle_quote};
 $state->{statement} .= $char;
 if ($state->{angle_quote_escape_next}) {
  $state->{angle_quote_escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{angle_quote_escape_next} = 1;
 } elsif ($char eq '<') {
  ++$state->{angle_quote_depth};
 } elsif ($char eq '>') {
  --$state->{angle_quote_depth} if $state->{angle_quote_depth} > 0;
  if ($state->{angle_quote_depth} == 0) {
   --$state->{angle_quote_segments_remaining} if $state->{angle_quote_segments_remaining} > 0;
   $state->{in_angle_quote} = 0 if $state->{angle_quote_segments_remaining} == 0;
  }
 }
 return 1
}

sub consume_pipe_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_pipe_quote};
 $state->{statement} .= $char;
 if ($state->{pipe_quote_escape_next}) {
  $state->{pipe_quote_escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{pipe_quote_escape_next} = 1;
 } elsif ($char eq '|') {
  --$state->{pipe_quote_segments_remaining} if $state->{pipe_quote_segments_remaining} > 0;
  $state->{in_pipe_quote} = 0 if $state->{pipe_quote_segments_remaining} == 0;
 }
 return 1
}

sub maybe_enter_single_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq "'";
 $state->{in_single_quote} = 1;
 $state->{statement} .= $char;
 return 1
}

sub consume_backtick_quote {
 my ($state, $char) = @_;
 return 0 unless $state->{in_backtick_quote};
 $state->{statement} .= $char;
 if ($state->{escape_next}) {
  $state->{escape_next} = 0;
 } elsif ($char eq '\\') {
  $state->{escape_next} = 1;
 } elsif ($char eq '`') {
  $state->{in_backtick_quote} = 0;
 }
 return 1
}

sub maybe_enter_double_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq '"';
 $state->{in_double_quote} = 1;
 $state->{statement} .= $char;
 return 1
}

sub maybe_enter_backtick_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq '`';
 $state->{in_backtick_quote} = 1;
 $state->{statement} .= $char;
 return 1
}

sub maybe_enter_line_comment {
 my ($state, $char) = @_;
 return 0 unless $char eq '#';
 $state->{in_line_comment} = 1;
 $state->{statement} .= $char;
 return 1
}

sub maybe_enter_slash_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq '/';
 my $slash_context = _trim_context_suffix($state->{statement});

 if ($slash_context =~ /(?:^|[^\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
  my $op = $+{op};
  $state->{in_slash_quote} = 1;
  $state->{slash_quote_segments_remaining} = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
  $state->{slash_quote_escape_next} = 0;
  $state->{statement} .= $char;
  return 1;
 } elsif ($slash_context =~ /(?:=~|!~)\s*$/o) {
  $state->{in_slash_quote} = 1;
  $state->{slash_quote_segments_remaining} = 1;
  $state->{slash_quote_escape_next} = 0;
  $state->{statement} .= $char;
  return 1;
 }
 return 0
}

sub maybe_enter_angle_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq '<';
 my $angle_context = _trim_context_suffix($state->{statement});
 return 0 unless $angle_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q)\s*$/o;

 my $op = $+{op};
 $state->{in_angle_quote} = 1;
 $state->{angle_quote_segments_remaining} = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
 $state->{angle_quote_depth} = 1;
 $state->{angle_quote_escape_next} = 0;
 $state->{statement} .= $char;
 return 1
}

sub maybe_enter_pipe_quote {
 my ($state, $char) = @_;
 return 0 unless $char eq '|';
 my $pipe_context = _trim_context_suffix($state->{statement});

 if ($pipe_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
  my $op = $+{op};
  $state->{in_pipe_quote} = 1;
  $state->{pipe_quote_segments_remaining} = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
  $state->{pipe_quote_escape_next} = 0;
  $state->{statement} .= $char;
  return 1;
 } elsif ($pipe_context =~ /(?:=~|!~)\s*m?\s*$/o) {
  $state->{in_pipe_quote} = 1;
  $state->{pipe_quote_segments_remaining} = 1;
  $state->{pipe_quote_escape_next} = 0;
  $state->{statement} .= $char;
  return 1;
 }
 return 0
}

1;
