package LinkedSpec::BootstrapSpec::Core;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname(File::Basename::dirname($module_dir));
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Package : LinkedSpec::BootstrapSpec::Core
# Purpose : Hardcoded bootstrap grammar core for `.spec` parsing, including
#           bootstrap regex helper access and method-chain preprocessing.
#------------------------------------------------------------------------------

sub _linkedre_or {
 my (@args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedRE');
  return LinkedRE::or(@args)
 })
}

sub _linkedre_ored_re {
 my (@args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedRE');
  return LinkedRE::oredRE(@args)
 })
}

sub _trim_bootstrap_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

#------------------------------------------------------------------------------
# Function: _parse_method_call_chain
# Purpose : Parse `.method(args).method2(args2)` chains into ordered call
#           descriptors while preserving nested-parenthesis argument payloads.
# Args    : ($chain)
# Returns : arrayref of { method => ..., args => ... } or undef on parse error
#------------------------------------------------------------------------------
sub _parse_method_call_chain {
 my ($chain) = @_;
 return [] unless defined($chain) && length($chain);

 my @calls;
 pos($chain) = 0;
 while ($chain =~ /\G\s*\.\s*(?<method>\w+)(?<args>\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\)))?/gc) {
  my $args = $+{args};
  if (defined $args) {
   $args =~ s/^\s*\(//o;
   $args =~ s/\)\s*$//o;
  }
  push @calls, {
   method => $+{method},
   args   => $args,
  };
 }

 return \@calls if $chain =~ /\G\s*$/gc;
 return undef
}

#------------------------------------------------------------------------------
# Function: _method_chain_return_uses_general_payload
# Purpose : Detect method-chain `.return(...)` payloads that should be emitted
#           as `return(payload)` without implicit scope-label injection.
# Args    : ($args)
# Returns : boolean
#------------------------------------------------------------------------------
sub _method_chain_return_uses_general_payload {
 my ($args) = @_;
 return 0 unless defined $args;
 my $trimmed = _trim_bootstrap_value($args);
 return 0 unless defined($trimmed) && length($trimmed);
 return $trimmed =~ /^(?:\[|\{|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|(?:scalar|s)\s*\(|(?:array|a)\s*\(|(?:hash|h)\s*\(|trim\s*\(|lowercase\s*\(|uppercase\s*\(|length\s*\(|replace_substr\s*\(|rm_prefix\s*\(|rm_suffix\s*\(|concat\s*\(|num_abs\s*\(|num_floor\s*\(|num_ceil\s*\(|num_round\s*\(|num_sum\s*\(|num_avg\s*\(|num_median\s*\(|num_range\s*\(|num_add\s*\(|num_sub\s*\(|num_mul\s*\(|num_div\s*\(|num_mod\s*\(|num_clamp\s*\(|num_min\s*\(|num_max\s*\(|starts_with\s*\(|ends_with\s*\(|contains_substr\s*\(|matches\s*\(|coalesce_nonempty\s*\(|is_empty\s*\(|is_nonempty\s*\(|count\s*\(|first\s*\(|last\s*\(|tail\s*\(|take\s*\(|slice\s*\(|take_last\s*\(|drop_last\s*\(|drop_back\s*\(|drop_front\s*\(|concat_arrays\s*\(|sorted\s*\(|reversed\s*\(|contains\s*\(|index_of\s*\(|count_keys\s*\(|sorted_keys\s*\(|sorted_values\s*\(|has_key\s*\(|merge_hash\s*\(|set_key\s*\(|rename_key\s*\(|drop_keys\s*\(|pick_keys\s*\(|join_values\s*\(|coalesce\s*\(|flat_array\s*\(|flat_hash\s*\(|flatten\s*\(|flat\s*\()/o ? 1 : 0
}

sub _method_chain_uses_bare_zero_arg_flow_marker {
 my ($method, $args) = @_;
 return 0 unless defined($method) && $method =~ /^(?:else|endif|default|endcase|endswitch)$/o;
 return 1 unless defined $args;
 my $trimmed = _trim_bootstrap_value($args);
 return (!defined($trimmed) || !length($trimmed)) ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _render_method_call_chain
# Purpose : Render parsed method-chain calls into semicolon-joined helper-style
#           calls with entry label injected as first argument, optionally
#           preserving an attached block on the final fluent call.
# Args    : ($entry_label, $chain, $attached_block)
# Returns : rendered code string or undef
#------------------------------------------------------------------------------
sub _render_method_call_chain {
 my ($entry_label, $chain, $attached_block) = @_;
 my $calls = _parse_method_call_chain($chain);
 return undef unless $calls && @$calls;
 my $normalized_attached_block = _trim_bootstrap_value($attached_block);
 my @rendered;
 for my $idx (0 .. $#$calls) {
  my $call = $calls->[$idx];
  my $method = $call->{method};
  my $args = $call->{args};
  my $rendered;
  # Keep rendering the whole fluent chain even when a general-payload
  # return(...) appears in the middle of control-flow branch bodies.
  if (_method_chain_uses_bare_zero_arg_flow_marker($method, $args)) {
   $rendered = $method . '()';
  } elsif ($method eq 'return' && _method_chain_return_uses_general_payload($args)) {
   $rendered = $method . '(' . $args . ')';
  } else {
   $rendered = $method . "($entry_label" . ((defined($args) && length($args)) ? ",$args" : '') . ')';
  }
  if (defined($normalized_attached_block) && length($normalized_attached_block) && $idx == $#$calls) {
   $rendered .= ' ' . $normalized_attached_block;
  }
  push @rendered, $rendered;
 }
 return join '; ', @rendered
}

sub _parse_action_edge_targets {
 my ($targets_text) = @_;
 my $trimmed = _trim_bootstrap_value($targets_text);
 return undef unless defined($trimmed) && length($trimmed);

 my @targets;
 pos($trimmed) = 0;
 while ($trimmed =~ /\G\s*(\w+)\s*(?:\[\s*(\d+)\s*\]\s*)?\s*(?:\||\z)/gc) {
  push @targets, {
   label => $1,
   reidx => defined($2) ? $2 : 0,
  };
 }

 return undef unless @targets;
 return undef unless defined(pos($trimmed)) && pos($trimmed) == length($trimmed);
 return \@targets
}

sub _build_action_edge_entries {
 my ($targets, $code) = @_;
 return undef unless ref($targets) eq 'ARRAY' && @$targets;

 my @entries = map {
  ['ACODE', { relabel => $_->{label}, reidx => $_->{reidx}, code => $code }]
 } @$targets;

 return @entries == 1 ? $entries[0] : \@entries
}

#------------------------------------------------------------------------------
# Function: _parse_optional_attached_if_clause_tail
# Purpose : Parse trailing attached `elseif(...) { ... }` / `else { ... }`
#           clauses that continue an attached-block fluent `if(...)` chain.
# Args    : ($string_ref, $start_pos)
# Returns : ($tail_text, $new_pos)
#------------------------------------------------------------------------------
sub _parse_optional_attached_if_clause_tail {
 my ($string_ref, $start_pos) = @_;
 return ('', $start_pos) unless ref($string_ref) eq 'SCALAR' && defined $start_pos;

 my $source = $$string_ref;
 my $source_len = length($source);
 my $pos = $start_pos;
 my $tail = '';
 my $else_seen = 0;
 my $needs_explicit_endif = 0;

 my $skip_ws = sub {
  my ($scan_pos) = @_;
  ++$scan_pos while $scan_pos < $source_len && substr($source, $scan_pos, 1) =~ /\s/o;
  return $scan_pos
 };

 my $parse_balanced = sub {
  my ($scan_pos, $open, $close) = @_;
  return (undef, $scan_pos) unless $scan_pos < $source_len && substr($source, $scan_pos, 1) eq $open;

  my $depth = 0;
  my $in_single_quote = 0;
  my $in_double_quote = 0;
  my $in_slash_quote = 0;
  my $slash_escape_next = 0;
  my $escape_next = 0;

  for (my $idx = $scan_pos; $idx < $source_len; ++$idx) {
   my $char = substr($source, $idx, 1);

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
    my $prefix = substr($source, $scan_pos, $idx - $scan_pos);
    $prefix =~ s/\s+$//o;
    if (!length($prefix)) {
     $in_slash_quote = 1;
     $slash_escape_next = 0;
     next;
    }
   }

   if ($char eq $open) {
    ++$depth;
    next;
   }

   next unless $char eq $close;
   --$depth if $depth > 0;
   return (substr($source, $scan_pos, $idx - $scan_pos + 1), $idx + 1) if $depth == 0;
  }

  return (undef, $scan_pos)
 };

 my $parse_method_stmt = sub {
  my ($scan_pos) = @_;
  $scan_pos = $skip_ws->($scan_pos);
  return (undef, $scan_pos) if $scan_pos >= $source_len;

  return (undef, $scan_pos) unless substr($source, $scan_pos) =~ /\A(?<method>\w+)/o;
  my $method = $+{method};
  my $stmt_start = $scan_pos;
  $scan_pos += length($method);
  my $has_paren = 0;
  my $has_block = 0;

  my $next_pos = $skip_ws->($scan_pos);
  if ($next_pos < $source_len && substr($source, $next_pos, 1) eq '(') {
   my ($segment, $segment_end) = $parse_balanced->($next_pos, '(', ')');
   return (undef, $stmt_start) unless defined $segment;
   $scan_pos = $segment_end;
   $has_paren = 1;
   $next_pos = $skip_ws->($scan_pos);
  }

  if ($next_pos < $source_len && substr($source, $next_pos, 1) eq '{') {
   my ($segment, $segment_end) = $parse_balanced->($next_pos, '{', '}');
   return (undef, $stmt_start) unless defined $segment;
   $scan_pos = $segment_end;
   $has_block = 1;
  }

  my $text = _trim_bootstrap_value(substr($source, $stmt_start, $scan_pos - $stmt_start));
  return (undef, $stmt_start) unless defined($text) && length($text);

  return ({
   text      => $text,
   method    => $method,
   has_paren => $has_paren,
   has_block => $has_block,
  }, $scan_pos)
 };

 my $is_if_clause_boundary = sub {
  my ($stmt) = @_;
  return 0 unless ref($stmt) eq 'HASH';
  my $method = $stmt->{method} // '';
  return ($method eq 'elseif' || $method eq 'elif' || $method eq 'else' || $method eq 'endif') ? 1 : 0
 };

 while (1) {
  my ($head_stmt, $head_end) = $parse_method_stmt->($pos);
  last unless $head_stmt;

  my $head_method = $head_stmt->{method} // '';
  last unless $head_method eq 'elseif' || $head_method eq 'elif' || $head_method eq 'else';

  return ('', $start_pos) if $else_seen;
  $else_seen = 1 if $head_method eq 'else';

  $tail .= ' ' if length($tail);
  $tail .= $head_stmt->{text};
  $pos = $head_end;

  next if $head_stmt->{has_block};

  $needs_explicit_endif = 1;
  while (1) {
   my ($body_stmt, $body_end) = $parse_method_stmt->($pos);
   last if $body_stmt && $is_if_clause_boundary->($body_stmt);
   last unless $body_stmt;
   $tail .= ' ' . $body_stmt->{text};
   $pos = $body_end;
  }
 }

 if ($needs_explicit_endif) {
  my ($end_stmt, $end_pos) = $parse_method_stmt->($pos);
  if ($end_stmt && ($end_stmt->{method} // '') eq 'endif') {
   $tail .= ' ' if length($tail);
   $tail .= $end_stmt->{text};
   $pos = $end_pos;
  }
 }

 return ($tail, $pos)
}

sub _build_bootstrap_node_type_map {
 return {
  '&' => 'AND',
  '|' => 'OR',
  '+' => 'REP_PLUS',
  '*' => 'REP_STAR',
  '?' => 'REP_OPT'
 }
}

sub _parse_group_mode {
 my ($mode) = @_;
 return undef unless defined $mode;
 if ($mode =~ /\AOR\z/o) {
  return {
   node_type => 'REP_OR_EXPLICIT',
   rep_min   => 1,
   rep_max   => 10**9,
  }
 }
 if ($mode =~ /\AOR\+\z/o) {
  return {
   node_type => 'REP_OR_PLUS',
   rep_min   => 1,
   rep_max   => 10**9,
  }
 }
 if ($mode =~ /\AAND\+\z/o) {
  return {
   node_type => 'REP_AND_PLUS',
   rep_min   => 1,
   rep_max   => 10**9,
  }
 }
 if ($mode =~ /\AAND\z/o) {
  return {
   node_type => 'AND_EXPLICIT',
  }
 }
 return undef unless $mode =~ /\A(?<KIND>OR|AND)\s*\{\s*(?<BODY>[^}]*)\s*\}\z/o;

 my $kind = $+{KIND};
 my $body = $+{BODY};
 my ($rep_min, $rep_max);

 if ($body =~ /\A\s*(?<COUNT>\d+)\s*\z/o) {
  $rep_min = $+{COUNT};
  $rep_max = $+{COUNT};
 } elsif ($body =~ /\A\s*(?<MIN>\d*)\s*,\s*(?<MAX>\d*)\s*\z/o) {
  return undef unless length($+{MIN}) || length($+{MAX});
  $rep_min = length($+{MIN}) ? $+{MIN} : 0;
  $rep_max = length($+{MAX}) ? $+{MAX} : 10**9;
 } else {
  return undef
 }

 return undef if $rep_max < $rep_min;

 return {
  node_type => $kind eq 'AND' ? 'REP_AND_BOUNDED' : 'REP_OR_BOUNDED',
  rep_min   => 0 + $rep_min,
  rep_max   => 0 + $rep_max,
 }
}

sub _parse_entry_label_token {
 my ($text, $ctx) = @_;
 return undef unless defined $text;
 return undef unless ref($ctx) eq 'HASH';
 return undef unless $text =~ /\A(?<LABEL>\w+)\s*(?<COLON>::|:)\s*(?<MODE>(?:[&|\+\*\?]|OR(?:\+|\s*\{[^}]+\})?|AND(?:\+|\s*\{[^}]+\})?)?)\z/o;

 my ($label, $colons, $mode) = @+{qw/LABEL COLON MODE/};
 my $target = $colons eq '::' ? '_INITIAL' : '';
 my $node_type = 'default';
 my ($rep_min, $rep_max);

 if (defined($mode) && length($mode)) {
  if (exists $ctx->{node_type}{$mode}) {
   $node_type = $ctx->{node_type}{$mode};
  } else {
   my $group_mode = _parse_group_mode($mode);
   return undef unless ref($group_mode) eq 'HASH';
   $node_type = $group_mode->{node_type};
   $rep_min = $group_mode->{rep_min};
   $rep_max = $group_mode->{rep_max};
  }
 }

 return {
  label     => $label,
  target    => $target,
  node_type => $node_type,
  rep_min   => $rep_min,
  rep_max   => $rep_max,
 }
}

sub _dispatch_curly_brace_handler {
 my ($ctx, $minfo, $rule_descriptors, $string, $dispatch_state) = @_;
 my $brace_rule_idx = $ctx->{bootstrap_rule_index}{CURLY_BRACE};
 return undef unless defined $brace_rule_idx;
 return undef unless ref($rule_descriptors->[$brace_rule_idx]) eq 'HASH';
 return undef unless ref($rule_descriptors->[$brace_rule_idx]{handler}) eq 'CODE';
 return &{$rule_descriptors->[$brace_rule_idx]{handler}}($minfo, $rule_descriptors, $string, $dispatch_state)
}

sub _build_spec_root_rule {
 my ($ctx) = @_;
 return {
  id => 'SPEC_ROOT',
  tags => { root => 1 },
  handler => sub {
   my ($rule_descriptors, $string, $dispatch_state) = @_;
   my @specentry;
   my @specs;
   while (1) {
    my $minfo = _linkedre_or($string, $dispatch_state->{start_token_re});
    unless($minfo) {
     push @specs, [@specentry] if @specentry;
     return [@specs]
    }

    my $dispatch_idx = $dispatch_state->{start_rule_dispatch}[$$minfo{index}];
    return undef unless defined $dispatch_idx;

    my $retv = &{$$rule_descriptors[$dispatch_idx]{handler}}($minfo, $rule_descriptors, $string, $dispatch_state);
    return undef unless $retv;

    my @ret_entries = ref($$retv[0]) eq 'ARRAY' ? @$retv : ($retv);
    for my $entry (@ret_entries) {
     next if $$entry[0] eq 'COMMENT';
     if ($$entry[0] =~ /ELABEL/o) {
      if (@specentry) {
       push @specs, [@specentry];
       @specentry = ($entry)
      } else {
       push @specentry, $entry;
      }
     } else {
      push @specentry, $entry;
     }
    }

   }
  },
 }
}

sub _build_entry_label_rule {
 my ($ctx) = @_;
 return {
  id => 'ENTRY_LABEL',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*::?\s*(?:(?:&|\||\+|\*|\?|OR(?:\+|\s*\{[^}]+\})?|AND(?:\+|\s*\{[^}]+\})?)|(?!(?:OR|AND)\b))/o],
  handler=> sub {
   my ($info, undef, undef, $dispatch_state) = @_;
   my $parsed = _parse_entry_label_token($$info{match}, $ctx);
   return undef unless ref($parsed) eq 'HASH';

   $dispatch_state->{current_rule_label} = $parsed->{label};
   return [
    "ELABEL$parsed->{target}",
    $parsed->{label},
    $parsed->{node_type},
    $parsed->{rep_min},
    $parsed->{rep_max},
   ]
  },
 }
}

sub _build_re_pattern_rule {
 return {
  id => 'RE_PATTERN',
  tags => { start_token => 1 },
  re=> [qr/(?<!\\)\/.+?(?<!\\)\//o],
  handler=> sub {
   my ($info) = @_;
   $$info{match} =~ s/^\/|\/$//g;
   return ['RE', $$info{match}]
  },
 }
}

sub _build_action_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*(?<TARGETS>(?:\w+\s*(?:\[\s*\d+\s*\]\s*)?)(?:\s*\|\s*\w+\s*(?:\[\s*\d+\s*\]\s*)?)*)\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $rule_descriptors, $string, $dispatch_state) = @_;

   my $ipos = pos($$string);
   my $targets = _parse_action_edge_targets($$info{match_hash}{TARGETS});
   return undef unless ref($targets) eq 'ARRAY' && @$targets;

   while (1) {
    my $minfo = _linkedre_or($string, $dispatch_state->{brace_scanner_re});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return _build_action_edge_entries($targets, substr($$string, $ipos, pos($$string) - $ipos - 1))
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $rule_descriptors, $string, $dispatch_state);
    } else {
    }
   }
  },
 }
}

sub _build_method_empty_action_code_block_rule {
 return {
  id => 'METHOD_EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*(?<ENTRY_LABEL>\w+)\s*(?:\[\s*(?<INDEX>\d+)\s*\]\s*)?(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))?)+)(?<BLOCK>\s*(?<BRACE>\{(?:[^{}\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&BRACE))*\}))?/o],
  handler=> sub {
   my ($info, undef, $string) = @_;
   my ($entry_label, $reidx, $chain, $block) = @{$$info{match_hash}}{qw/ENTRY_LABEL INDEX CHAIN BLOCK/};
   my $code = _render_method_call_chain($entry_label, $chain, $block);
   return undef unless defined $code;
   my $calls = _parse_method_call_chain($chain);
   if ($calls && @$calls && defined($block) && length($block)) {
    my $tail_method = $calls->[-1]{method} || '';
    if ($tail_method eq 'if' || $tail_method eq 'i') {
     my ($tail, $new_pos) = _parse_optional_attached_if_clause_tail($string, pos($$string));
     if (defined($tail) && length($tail)) {
      $code .= ' ' . $tail;
      pos($$string) = $new_pos;
     }
    }
   }
   return ['ACODE', {relabel=>$entry_label, reidx=> $reidx // 0, code=>$code}]
  },
 }
}

sub _build_empty_action_code_block_rule {
 return {
  id => 'EMPTY_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/->\s*\w+(?:\[0\])?/o],
  handler=> sub {
   my ($info) = @_;

   my ($entry_label) = $$info{match} =~ /(\w+)/o;
   return ['ACODE', {relabel=>$entry_label, reidx=>0, code=>"call($entry_label)"}]
  },
 }
}

sub _build_non_action_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $rule_descriptors, $string, $dispatch_state) = @_;

   my $ipos = pos($$string);
   my ($type) = $$info{match} =~ /(\w+)/o;

   while (1) {
    my $minfo = _linkedre_or($string, $dispatch_state->{brace_scanner_re});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return ["${type}CODE", substr($$string, $ipos, pos($$string) - $ipos - 1)]
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $rule_descriptors, $string, $dispatch_state);
    } else {
    }
   }
  },
 }
}

sub _build_comment_rule {
 return {
  id => 'COMMENT',
  tags => { start_token => 1 },
  re=> [qr/[ \t]*#.*/o],
  handler=> sub {return ['COMMENT']},
 }
}

sub _build_blind_call_code_block_rule {
 my ($ctx) = @_;
 return {
  id => 'BLIND_CALL_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+\s*\{/o, qr/\}/o],
  handler=> sub {
   my ($info, $rule_descriptors, $string, $dispatch_state) = @_;

   my $ipos = pos($$string);
   my ($call) = $$info{match} =~ /(\w+)/o;

   while (1) {
    my $minfo = _linkedre_or($string, $dispatch_state->{brace_scanner_re});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return ['BCODE', {call=>$call, code=>"\$$dispatch_state->{current_rule_label} = call($call);\n".substr($$string, $ipos, pos($$string) - $ipos - 1)}]
    } elsif ($$minfo{index} == 0) {
     _dispatch_curly_brace_handler($ctx, $minfo, $rule_descriptors, $string, $dispatch_state);
    } else {
    }
   }
  },
 }
}

sub _build_method_empty_blind_code_block_rule {
 return {
  id => 'METHOD_EMPTY_BLIND_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*(?<CALL>\w+)(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))?)+)(?<BLOCK>\s*(?<BRACE>\{(?:[^{}\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&BRACE))*\}))?/o],
  handler=> sub {
   my ($info, undef, $string, $dispatch_state) = @_;
   my ($call, $chain, $block) = @{$$info{match_hash}}{qw/CALL CHAIN BLOCK/};
   my $code = _render_method_call_chain($dispatch_state->{current_rule_label}, $chain, $block);
   return undef unless defined $code;
   my $calls = _parse_method_call_chain($chain);
   if ($calls && @$calls && defined($block) && length($block)) {
    my $tail_method = $calls->[-1]{method} || '';
    if ($tail_method eq 'if' || $tail_method eq 'i') {
     my ($tail, $new_pos) = _parse_optional_attached_if_clause_tail($string, pos($$string));
     if (defined($tail) && length($tail)) {
      $code .= ' ' . $tail;
      pos($$string) = $new_pos;
     }
    }
   }
   return ['BCODE', {call=>$call, code=>"\$$dispatch_state->{current_rule_label} = call($call);\n" . $code}]
  },
 }
}

sub _build_split_like_code_rule {
 return {
  id => 'SPLIT_LIKE_CODE',
  tags => { start_token => 1 },
  re=> [qr/@\s*(?:(?:capture_slice|capture_from_here|move_pos)\b|mark\s*\(\s*(?<MARK>\w+)\s*\))/o],
  handler=> sub {
   my ($info) = @_;
   my $mark = $info->{match_hash}{MARK};
   return (defined($mark) && length($mark))
    ? ['MARK_POS', {name => $mark}]
    : ['MOVE_POS']
  },
 }
}

sub _build_empty_blind_code_block_rule {
 return {
  id => 'EMPTY_BLIND_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/=>\s*\w+/o],
  handler=> sub {
   my ($info, undef, undef, $dispatch_state) = @_;

   my ($call) = $$info{match} =~ /(\w+)/o;
   return ['BCODE', {call=>$call, code=>"\$$dispatch_state->{current_rule_label} = call($call)"}]
  },
 }
}

sub _build_method_empty_non_action_code_block_rule {
 return {
  id => 'METHOD_EMPTY_NON_ACTION_CODE_BLOCK',
  tags => { start_token => 1 },
  re=> [qr/(?<TYPE>\w+)(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&PAREN))*\))?)+)(?<BLOCK>\s*(?<BRACE>\{(?:[^{}\"']++|\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|(?&BRACE))*\}))?/o],
  handler=> sub {
   my ($info, undef, $string, $dispatch_state) = @_;
   my ($type, $chain, $block) = @{$$info{match_hash}}{qw/TYPE CHAIN BLOCK/};
   my $code = _render_method_call_chain($dispatch_state->{current_rule_label}, $chain, $block);
   return undef unless defined $code;
   my $calls = _parse_method_call_chain($chain);
   if ($calls && @$calls && defined($block) && length($block)) {
    my $tail_method = $calls->[-1]{method} || '';
    if ($tail_method eq 'if' || $tail_method eq 'i') {
     my ($tail, $new_pos) = _parse_optional_attached_if_clause_tail($string, pos($$string));
     if (defined($tail) && length($tail)) {
      $code .= ' ' . $tail;
      pos($$string) = $new_pos;
     }
    }
   }
   return ["${type}CODE", $code]
  },
 }
}

sub _build_curly_brace_rule {
 my ($ctx) = @_;
 return {
  id => 'CURLY_BRACE',
  tags => { start_token => 1, brace_scanner => 1 },
  re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o, qr/(?<!\\)\".*?(?<!\\)\"/o, qr/(?<!\\)'.*?(?<!\\)'/o],
  handler=> sub {
   my ($info, $rule_descriptors, $string, $dispatch_state) = @_;

   my $ipos = pos($$string);

   while (1) {
    my $minfo = _linkedre_or($string, $dispatch_state->{brace_scanner_re});
    return undef unless $minfo;

    if ($$minfo{index} == 1) {
     return 1
    } elsif ($$minfo{index} == 0)  {
     _dispatch_curly_brace_handler($ctx, $minfo, $rule_descriptors, $string, $dispatch_state);
    } else {
    }
   }
  },
 }
}

sub _build_bootstrap_rule_descriptors {
 my ($ctx) = @_;
 return [
  _build_spec_root_rule($ctx),
  _build_entry_label_rule($ctx),
  _build_re_pattern_rule(),
  _build_action_code_block_rule($ctx),
  _build_method_empty_action_code_block_rule(),
  _build_empty_action_code_block_rule(),
  _build_non_action_code_block_rule($ctx),
  _build_comment_rule(),
  _build_blind_call_code_block_rule($ctx),
  _build_method_empty_blind_code_block_rule(),
  _build_split_like_code_rule(),
  _build_empty_blind_code_block_rule(),
  _build_method_empty_non_action_code_block_rule(),
  _build_curly_brace_rule($ctx),
 ]
}

sub _build_bootstrap_dispatch_metadata {
 my ($rule_descriptors) = @_;

 my %bootstrap_rule_index = map {
  my $id = $rule_descriptors->[$_]{id};
  defined $id ? ($id => $_) : ()
 } 0 .. $#$rule_descriptors;

 for my $required_rule_id (qw/SPEC_ROOT CURLY_BRACE/) {
  die "(LinkedSpec.pm) -E- Missing required bootstrap rule id '$required_rule_id'"
   unless defined $bootstrap_rule_index{$required_rule_id};
 }

 my @start_token_res;
 my @start_rule_dispatch;
 for my $idx (0 .. $#$rule_descriptors) {
  my $rule = $rule_descriptors->[$idx];
  next unless ref($rule) eq 'HASH';
  next unless exists $rule->{tags} && ref($rule->{tags}) eq 'HASH' && $rule->{tags}{start_token};
  next unless exists $rule->{re} && ref($rule->{re}) eq 'ARRAY' && @{$rule->{re}};
  push @start_token_res, $rule->{re}[0];
  push @start_rule_dispatch, $idx;
 }

 die "(LinkedSpec.pm) -E- Bootstrap start-token registry is empty"
  unless @start_token_res && @start_rule_dispatch;

 my @brace_scanner_res = ();
 if (defined $bootstrap_rule_index{CURLY_BRACE}
     && exists $rule_descriptors->[$bootstrap_rule_index{CURLY_BRACE}]{re}
     && ref($rule_descriptors->[$bootstrap_rule_index{CURLY_BRACE}]{re}) eq 'ARRAY') {
  @brace_scanner_res = @{$rule_descriptors->[$bootstrap_rule_index{CURLY_BRACE}]{re}};
 }

 my $dispatch_state = {
  start_token_re      => _linkedre_ored_re(@start_token_res),
  start_rule_dispatch => \@start_rule_dispatch,
  brace_scanner_re    => _linkedre_ored_re(@brace_scanner_res),
  current_rule_label  => undef,
 };

 return (\%bootstrap_rule_index, $dispatch_state);
}

#------------------------------------------------------------------------------
# Function: build_bootstrap_spec
# Purpose : Build and return the hardcoded bootstrap grammar descriptor and its
#           bootstrap rule index plus parser dispatch state.
# Args    : none
# Returns : ($rule_descriptors, $bootstrap_rule_index_ref, $dispatch_state)
#------------------------------------------------------------------------------
sub build_bootstrap_spec {
 my $ctx = {
  bootstrap_rule_index => {},
  node_type => _build_bootstrap_node_type_map(),
 };

 my $rule_descriptors = _build_bootstrap_rule_descriptors($ctx);
 my ($bootstrap_rule_index_ref, $dispatch_state) = _build_bootstrap_dispatch_metadata($rule_descriptors);
 %{$ctx->{bootstrap_rule_index}} = %$bootstrap_rule_index_ref;

 return ($rule_descriptors, $bootstrap_rule_index_ref, $dispatch_state)
}

1;
