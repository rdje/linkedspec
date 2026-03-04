package LinkedSpec::ActionIR::StatementSplit;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::StatementSplit::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _split_action_ir_statements {
 my ($code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 my @statements;
 my $statement = '';
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_backtick_quote = 0;
 my $in_slash_quote = 0;
 my $slash_quote_segments_remaining = 0;
 my $slash_quote_escape_next = 0;
 my $in_angle_quote = 0;
 my $angle_quote_segments_remaining = 0;
 my $angle_quote_depth = 0;
 my $angle_quote_escape_next = 0;
 my $in_pipe_quote = 0;
 my $pipe_quote_segments_remaining = 0;
 my $pipe_quote_escape_next = 0;
 my $in_line_comment = 0;
 my $escape_next = 0;

 foreach my $char (split //, $code) {
  if ($in_line_comment) {
   $statement .= $char;
   if ($char eq "\n") {
    $in_line_comment = 0;
   }
   next;
  }
  if ($in_single_quote) {
   $statement .= $char;
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
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($in_slash_quote) {
   $statement .= $char;
   if ($slash_quote_escape_next) {
    $slash_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_quote_escape_next = 1;
   } elsif ($char eq '/') {
    --$slash_quote_segments_remaining if $slash_quote_segments_remaining > 0;
    $in_slash_quote = 0 if $slash_quote_segments_remaining == 0;
   }
   next;
  }
  if ($in_angle_quote) {
   $statement .= $char;
   if ($angle_quote_escape_next) {
    $angle_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $angle_quote_escape_next = 1;
   } elsif ($char eq '<') {
    ++$angle_quote_depth;
   } elsif ($char eq '>') {
    --$angle_quote_depth if $angle_quote_depth > 0;
    if ($angle_quote_depth == 0) {
     --$angle_quote_segments_remaining if $angle_quote_segments_remaining > 0;
     $in_angle_quote = 0 if $angle_quote_segments_remaining == 0;
    }
   }
   next;
  }
  if ($in_pipe_quote) {
   $statement .= $char;
   if ($pipe_quote_escape_next) {
    $pipe_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $pipe_quote_escape_next = 1;
   } elsif ($char eq '|') {
    --$pipe_quote_segments_remaining if $pipe_quote_segments_remaining > 0;
    $in_pipe_quote = 0 if $pipe_quote_segments_remaining == 0;
   }
   next;
  }
  if ($char eq "'") {
   $in_single_quote = 1;
   $statement .= $char;
   next;
  }
  if ($in_backtick_quote) {
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '`') {
    $in_backtick_quote = 0;
   }
   next;
  }

  if ($char eq '"') {
   $in_double_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '`') {
   $in_backtick_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '#') {
   $in_line_comment = 1;
   $statement .= $char;
   next;
  }
  if ($char eq '/') {
   my $slash_context = $statement;
   $slash_context =~ s/\s+$//o;

   if ($slash_context =~ /(?:^|[^\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($slash_context =~ /(?:=~|!~)\s*$/o) {
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '<') {
   my $angle_context = $statement;
   $angle_context =~ s/\s+$//o;

   if ($angle_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q)\s*$/o) {
    my $op = $+{op};
    $in_angle_quote = 1;
    $angle_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $angle_quote_depth = 1;
    $angle_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '|') {
   my $pipe_context = $statement;
   $pipe_context =~ s/\s+$//o;

   if ($pipe_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($pipe_context =~ /(?:=~|!~)\s*m?\s*$/o) {
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }

  if ($char eq '(') {
   ++$paren_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '{') {
   ++$brace_depth;
   $statement .= $char;
   next;
  }

  if ($char eq '}') {
   --$brace_depth if $brace_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '[') {
   ++$bracket_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   $statement .= $char;
   next;
  }

  if (
   $char eq ';' &&
   $paren_depth == 0 &&
   $brace_depth == 0 &&
   $bracket_depth == 0
  ) {
   my $trimmed = $trim_action_ir_value->($statement);
   push @statements, $trimmed if defined($trimmed) && length($trimmed);
   $statement = '';
   next;
  }

  $statement .= $char;
 }

 my $trimmed = $trim_action_ir_value->($statement);
 push @statements, $trimmed if defined($trimmed) && length($trimmed);
 return \@statements
}

1;
