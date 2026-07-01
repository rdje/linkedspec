package LinkedSpec::ActionIR::AST::Parser;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $ast_dir = File::Basename::dirname($module_dir);
 my $action_ir_dir = File::Basename::dirname($ast_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::ActionIR::AST ();
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::AST::Parser
# Purpose : Parse ActionIR helper/action text into typed AST nodes without
#           changing the existing text-lowering pipeline. Later migration leaves
#           can switch consumers to these nodes family by family.
#------------------------------------------------------------------------------

sub _fallback_trim {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s+//o;
 $value =~ s/\s+$//o;
 return $value
}

sub _trim_cb {
 my ($deps) = @_;
 return $deps->{trim_action_ir_value}
  if ref($deps) eq 'HASH' && ref($deps->{trim_action_ir_value}) eq 'CODE';
 return \&_fallback_trim
}

sub _trim_with_offsets {
 my ($text, $base_start) = @_;
 $text = '' unless defined $text;
 $base_start = 0 unless defined $base_start;
 my $leading = 0;
 if ($text =~ /\A(\s+)/s) {
  $leading = length($1);
 }
 my $trailing = 0;
 if ($text =~ /(\s+)\z/s) {
  $trailing = length($1);
 }
 my $start = $base_start + $leading;
 my $end = $base_start + length($text) - $trailing;
 my $trimmed = substr($text, $leading, length($text) - $leading - $trailing);
 return ($trimmed, $start, $end)
}

sub _span {
 my ($start, $end) = @_;
 return LinkedSpec::ActionIR::AST::source_span($start, $end)
}

sub _node {
 my ($kind, $source, $start, $end, %fields) = @_;
 return LinkedSpec::ActionIR::AST::node(
  $kind,
  source => $source,
  source_span => _span($start, $end),
  %fields,
 )
}

sub _raw_node {
 my ($source, $start, $end, $reason) = @_;
 $reason = 'unsupported_expression' unless defined($reason) && length($reason);
 return _node('raw_perl', $source, $start, $end, reason => $reason)
}

sub _require_method_expr_pkg {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::MethodExpr');
 return 'LinkedSpec::ActionIR::MethodExpr'
}

sub _split_top_level_csv {
 my ($payload) = @_;
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv($payload)
}

sub _parse_method_function_expr {
 my ($expr) = @_;
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($expr)
}

sub _find_piece_offset {
 my ($haystack, $needle, $search_pos) = @_;
 $search_pos = 0 unless defined $search_pos;
 return undef unless defined($haystack) && defined($needle);
 my $idx = index($haystack, $needle, $search_pos);
 return $idx >= 0 ? $idx : undef
}

sub parse_action_block {
 my ($code, $deps) = @_;
 $code = '' unless defined $code;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _trim_cb($deps);

 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::StatementSplit');
 my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
  $code,
  { trim_action_ir_value => $trim_action_ir_value },
 );
 $parts = [] unless ref($parts) eq 'ARRAY';

 my @statement_spans;
 my $search_pos = 0;
 foreach my $statement (@$parts) {
  my $pos = _find_piece_offset($code, $statement, $search_pos);
  $pos = $search_pos unless defined $pos;
  my $end = $pos + length($statement);
  push @statement_spans, @{_split_ast_newline_statement_text($statement, $pos)};
  $search_pos = $end;
 }

 my @statements = map {
  parse_action_statement($_->{source}, { base_start => $_->{start}, deps => $deps })
 } @statement_spans;

 return _node(
  'action_block',
  $code,
  0,
  length($code),
  statements => \@statements,
 )
}

sub _split_ast_newline_statement_text {
 my ($statement, $base_start) = @_;
 $statement = '' unless defined $statement;
 $base_start = 0 unless defined $base_start;
 my @pieces;
 my $segment_start = 0;
 my $len = length($statement);
 my $state = _new_scan_state();

 for (my $idx = 0; $idx < $len; ++$idx) {
  my $ch = substr($statement, $idx, 1);
  if (_consume_scan_char($state, $statement, $idx, $ch)) {
   next;
  }
  next unless ($ch eq "\n" || $ch eq "\r") && _scan_is_top_level($state);
  my $candidate = substr($statement, $segment_start, $idx - $segment_start);
  my ($trimmed, $start, $end) = _trim_with_offsets($candidate, $base_start + $segment_start);
  next unless length($trimmed) && _looks_like_ast_statement($trimmed);
  push @pieces, {
   source => $trimmed,
   start => $start,
   end => $end,
  };
  $segment_start = _next_nonspace_index($statement, $idx + 1);
  $idx = $segment_start - 1;
 }

 my $tail = substr($statement, $segment_start);
 my ($trimmed, $start, $end) = _trim_with_offsets($tail, $base_start + $segment_start);
 push @pieces, {
  source => $trimmed,
  start => $start,
  end => $end,
 } if length($trimmed);
 return \@pieces
}

sub _next_nonspace_index {
 my ($text, $idx) = @_;
 my $len = length($text);
 while ($idx < $len && substr($text, $idx, 1) =~ /\s/o) {
  ++$idx;
 }
 return $idx
}

sub _looks_like_ast_statement {
 my ($statement) = @_;
 my $node = _parse_expr($statement, 0, length($statement));
 return (ref($node) eq 'HASH' && ($node->{kind} // '') ne 'raw_perl') ? 1 : 0
}

sub parse_action_statement {
 my ($statement, $opts) = @_;
 $opts = {} unless ref($opts) eq 'HASH';
 my $base_start = defined($opts->{base_start}) ? $opts->{base_start} : 0;
 my ($trimmed, $start, $end) = _trim_with_offsets($statement, $base_start);
 my $expr = parse_action_expr($trimmed, { base_start => $start, deps => $opts->{deps} || {} });
 return _node(
  'action_stmt',
  $trimmed,
  $start,
  $end,
  expr => $expr,
  drops_value => 1,
 )
}

sub parse_action_expr {
 my ($expr, $opts) = @_;
 $opts = {} unless ref($opts) eq 'HASH';
 my $base_start = defined($opts->{base_start}) ? $opts->{base_start} : 0;
 my ($trimmed, $start, $end) = _trim_with_offsets($expr, $base_start);
 return _raw_node($trimmed, $start, $end, 'empty_expression')
  unless length($trimmed);
 return _parse_expr($trimmed, $start, $end)
}

sub _parse_expr {
 my ($trimmed, $start, $end) = @_;
 my $assignment = _parse_assignment_expr($trimmed, $start, $end);
 return $assignment if $assignment;

 my $chain = _parse_fluent_chain_expr($trimmed, $start, $end);
 return $chain if $chain;

 return _parse_expr_without_chain($trimmed, $start, $end)
}

sub _parse_expr_without_chain {
 my ($trimmed, $start, $end) = @_;
 my $literal = _parse_literal_expr($trimmed, $start, $end);
 return $literal if $literal;

 my $shape = _parse_shape_or_block_expr($trimmed, $start, $end);
 return $shape if $shape;

 my $call = _parse_call_expr($trimmed, $start, $end);
 return $call if $call;

 my $var_or_access = _parse_variable_or_access_expr($trimmed, $start, $end);
 return $var_or_access if $var_or_access;

 return _raw_node($trimmed, $start, $end, 'unsupported_expression')
}

sub _parse_literal_expr {
 my ($trimmed, $start, $end) = @_;
 return _node('number', $trimmed, $start, $end, value => 0 + $trimmed)
  if $trimmed =~ /\A-?\d+(?:\.\d+)?\z/o;
 return _node('undef', $trimmed, $start, $end)
  if $trimmed eq 'undef';
 return _node('boolean', $trimmed, $start, $end, value => 1)
  if $trimmed eq 'true';
 return _node('boolean', $trimmed, $start, $end, value => 0)
  if $trimmed eq 'false';
 if ($trimmed =~ /\A(['"])((?:\\.|(?!\1).)*)\1\z/s) {
  my ($quote, $payload) = ($1, $2);
  return _node(
   'string',
   $trimmed,
   $start,
   $end,
   value => _unescape_string_payload($payload, $quote),
   quote => $quote,
  )
 }
 if ($trimmed =~ m{\A/((?:\\.|[^/])*)/([A-Za-z]*)\z}s) {
  return _node('regex', $trimmed, $start, $end, pattern => $1, flags => $2)
 }
 return undef
}

sub _unescape_string_payload {
 my ($payload, $quote) = @_;
 $payload = '' unless defined $payload;
 $payload =~ s/\\([\\'"])/$1/go;
 return $payload
}

sub _parse_call_expr {
 my ($trimmed, $start, $end) = @_;
 my $call = _parse_method_function_expr($trimmed);
 return undef unless ref($call) eq 'HASH' && defined($call->{method});
 my $open_idx = index($trimmed, '(');
 my $payload = substr($trimmed, $open_idx + 1, length($trimmed) - $open_idx - 2);
 my @args = _parse_arg_exprs($payload, $start + $open_idx + 1);
 return _node(
  'call',
  $trimmed,
  $start,
  $end,
  name => $call->{method},
  args => \@args,
 )
}

sub _parse_arg_exprs {
 my ($payload, $payload_start) = @_;
 my $parts = _split_top_level_csv($payload);
 my @args;
 my $cursor = 0;
 foreach my $arg (@$parts) {
  my $arg_offset = _find_piece_offset($payload, $arg, $cursor);
  $arg_offset = $cursor unless defined $arg_offset;
  push @args, parse_action_expr($arg, { base_start => $payload_start + $arg_offset });
  $cursor = $arg_offset + length($arg);
 }
 return @args
}

sub _parse_shape_or_block_expr {
 my ($trimmed, $start, $end) = @_;
 return _parse_array_literal_expr($trimmed, $start, $end)
  if substr($trimmed, 0, 1) eq '[';
 return _parse_brace_expr($trimmed, $start, $end)
  if substr($trimmed, 0, 1) eq '{';
 return undef
}

sub _parse_array_literal_expr {
 my ($trimmed, $start, $end) = @_;
 return undef unless _outer_delimiter_is_balanced($trimmed, '[', ']');
 my $payload = substr($trimmed, 1, length($trimmed) - 2);
 my @items = _parse_arg_exprs($payload, $start + 1);
 return _node('array_literal', $trimmed, $start, $end, items => \@items)
}

sub _parse_brace_expr {
 my ($trimmed, $start, $end) = @_;
 return undef unless _outer_delimiter_is_balanced($trimmed, '{', '}');
 my $payload = substr($trimmed, 1, length($trimmed) - 2);
 if (_fallback_trim($payload) eq '' || _has_top_level_fat_arrow($payload)) {
  return _parse_hash_literal_expr($trimmed, $payload, $start, $end);
 }
 my $block = parse_action_block($payload);
 return _node('block_value', $trimmed, $start, $end, block => $block)
}

sub _parse_hash_literal_expr {
 my ($trimmed, $payload, $start, $end) = @_;
 my $parts = _split_top_level_csv($payload);
 my @entries;
 my $cursor = 0;
 foreach my $entry (@$parts) {
  my $entry_offset = _find_piece_offset($payload, $entry, $cursor);
  $entry_offset = $cursor unless defined $entry_offset;
  my $arrow_idx = _find_top_level_fat_arrow($entry);
  return _raw_node($trimmed, $start, $end, 'invalid_hash_literal')
   unless defined $arrow_idx;
  my $key_text = substr($entry, 0, $arrow_idx);
  my $value_text = substr($entry, $arrow_idx + 2);
  my ($key_trimmed, $key_start) = _trim_with_offsets($key_text, $start + 1 + $entry_offset);
  my ($value_trimmed, $value_start) = _trim_with_offsets($value_text, $start + 1 + $entry_offset + $arrow_idx + 2);
  push @entries, {
   key => parse_action_expr($key_trimmed, { base_start => $key_start }),
   value => parse_action_expr($value_trimmed, { base_start => $value_start }),
  };
  $cursor = $entry_offset + length($entry);
 }
 return _node('hash_literal', $trimmed, $start, $end, entries => \@entries)
}

sub _parse_variable_or_access_expr {
 my ($trimmed, $start, $end) = @_;
 return undef unless $trimmed =~ /\A([A-Za-z_][A-Za-z0-9_]*)/o;
 my $name = $1;
 my $pos = length($name);
 while ($pos < length($trimmed) && substr($trimmed, $pos, 1) =~ /\s/o) {
  ++$pos;
 }
 if ($pos == length($trimmed)) {
  return _node('variable', $trimmed, $start, $end, name => $name)
 }
 return undef unless substr($trimmed, $pos, 1) eq '[';

 my $segments = _parse_access_segments($trimmed, $pos, $start);
 return undef unless ref($segments) eq 'ARRAY';
 if (@$segments == 1 && $segments->[0]{kind} eq 'index') {
  return _node(
   'indexed_var',
   $trimmed,
   $start,
   $end,
   name => $name,
   index => $segments->[0]{expr},
  )
 }
 return _node(
  'nested_access',
  $trimmed,
  $start,
  $end,
  base => $name,
  segments => $segments,
 )
}

sub _parse_access_segments {
 my ($trimmed, $pos, $base_start) = @_;
 my @segments;
 my $len = length($trimmed);
 while ($pos < $len) {
  while ($pos < $len && substr($trimmed, $pos, 1) =~ /\s/o) {
   ++$pos;
  }
  return \@segments if $pos == $len;
  return undef unless substr($trimmed, $pos, 1) eq '[';
  my $close = _find_matching_delim($trimmed, $pos, '[', ']');
  return undef unless defined $close;
  my $payload = substr($trimmed, $pos + 1, $close - $pos - 1);
  my ($payload_trimmed, $payload_start) = _trim_with_offsets($payload, $base_start + $pos + 1);
  my $expr = parse_action_expr($payload_trimmed, { base_start => $payload_start });
  if (($expr->{kind} // '') eq 'string') {
   push @segments, {
    kind => 'key',
    value => $expr->{value},
    source => substr($trimmed, $pos, $close - $pos + 1),
    source_span => _span($base_start + $pos, $base_start + $close + 1),
   };
  } else {
   push @segments, {
    kind => 'index',
    expr => $expr,
    source => substr($trimmed, $pos, $close - $pos + 1),
    source_span => _span($base_start + $pos, $base_start + $close + 1),
   };
  }
  $pos = $close + 1;
 }
 return \@segments
}

sub _parse_assignment_expr {
 my ($trimmed, $start, $end) = @_;
 my $append_idx = _find_top_level_token($trimmed, '+=');
 if (defined $append_idx) {
  my $left = _fallback_trim(substr($trimmed, 0, $append_idx));
  return undef unless defined($left) && $left =~ /\A([A-Za-z_][A-Za-z0-9_]*)\z/o;
  my $value_text = substr($trimmed, $append_idx + 2);
  my ($value_trimmed, $value_start) = _trim_with_offsets($value_text, $start + $append_idx + 2);
  return _node(
   'assign_array_append',
   $trimmed,
   $start,
   $end,
   name => $1,
   value => parse_action_expr($value_trimmed, { base_start => $value_start }),
  )
 }

 my $eq_idx = _find_top_level_assignment_eq($trimmed);
 return undef unless defined $eq_idx;
 my $left_text = substr($trimmed, 0, $eq_idx);
 my $right_text = substr($trimmed, $eq_idx + 1);
 my ($left_trimmed, $left_start, $left_end) = _trim_with_offsets($left_text, $start);
 my ($right_trimmed, $right_start) = _trim_with_offsets($right_text, $start + $eq_idx + 1);
 my $value = parse_action_expr($right_trimmed, { base_start => $right_start });

 if ($left_trimmed =~ /\A([A-Za-z_][A-Za-z0-9_]*)\z/o) {
  return _node('assign_scalar', $trimmed, $start, $end, name => $1, value => $value)
 }

 my $left = _parse_variable_or_access_expr($left_trimmed, $left_start, $left_end);
 if (ref($left) eq 'HASH') {
  if (($left->{kind} // '') eq 'indexed_var') {
   return _node(
    'assign_hash_index',
    $trimmed,
    $start,
    $end,
    name => $left->{name},
    key => $left->{index},
    value => $value,
   )
  }
  if (($left->{kind} // '') eq 'nested_access' && @{$left->{segments} || []} == 1) {
   my $segment = $left->{segments}[0];
   my $key = $segment->{kind} eq 'key'
    ? _node('string', $segment->{source}, $segment->{source_span}{start}, $segment->{source_span}{end}, value => $segment->{value})
    : $segment->{expr};
   return _node(
    'assign_hash_index',
    $trimmed,
    $start,
    $end,
    name => $left->{base},
    key => $key,
    value => $value,
   )
  }
 }

 return undef
}

sub _parse_fluent_chain_expr {
 my ($trimmed, $start, $end) = @_;
 my $segments = _split_top_level_fluent_segments($trimmed);
 return undef unless ref($segments) eq 'ARRAY' && @$segments > 1;

 my $receiver_seg = $segments->[0];
 my $receiver = _parse_expr_without_chain(
  $receiver_seg->{text},
  $start + $receiver_seg->{start},
  $start + $receiver_seg->{end},
 );

 my @calls;
 for (my $idx = 1; $idx < @$segments; ++$idx) {
  my $seg = $segments->[$idx];
  my $call = _parse_method_function_expr($seg->{text});
  return _raw_node($trimmed, $start, $end, 'invalid_fluent_chain')
   unless ref($call) eq 'HASH' && defined($call->{method});
  my $open_idx = index($seg->{text}, '(');
  my $payload = substr($seg->{text}, $open_idx + 1, length($seg->{text}) - $open_idx - 2);
  my @args = _parse_arg_exprs($payload, $start + $seg->{start} + $open_idx + 1);
  push @calls, {
   method => $call->{method},
   args => \@args,
   source => $seg->{text},
   source_span => _span($start + $seg->{start}, $start + $seg->{end}),
  };
 }

 return _node(
  'fluent_chain',
  $trimmed,
  $start,
  $end,
  receiver => $receiver,
  calls => \@calls,
 )
}

sub _split_top_level_fluent_segments {
 my ($text) = @_;
 my @segments;
 my $segment_start = 0;
 my $len = length($text);
 my $state = _new_scan_state();
 for (my $idx = 0; $idx < $len; ++$idx) {
  my $ch = substr($text, $idx, 1);
  if (_consume_scan_char($state, $text, $idx, $ch)) {
   next;
  }
  next unless $ch eq '.';
  next unless _scan_is_top_level($state);
  if ($idx > 0 && $idx + 1 < $len) {
   my $prev = substr($text, $idx - 1, 1);
   my $next = substr($text, $idx + 1, 1);
   next if $prev =~ /\d/o && $next =~ /\d/o;
  }
  my $segment = substr($text, $segment_start, $idx - $segment_start);
  my ($trimmed, $seg_start, $seg_end) = _trim_with_offsets($segment, $segment_start);
  push @segments, { text => $trimmed, start => $seg_start, end => $seg_end };
  $segment_start = $idx + 1;
 }
 return undef unless @segments;
 my $segment = substr($text, $segment_start);
 my ($trimmed, $seg_start, $seg_end) = _trim_with_offsets($segment, $segment_start);
 push @segments, { text => $trimmed, start => $seg_start, end => $seg_end };
 return \@segments
}

sub _outer_delimiter_is_balanced {
 my ($text, $open, $close) = @_;
 return 0 unless defined($text) && length($text) >= 2;
 return 0 unless substr($text, 0, 1) eq $open && substr($text, -1, 1) eq $close;
 my $match = _find_matching_delim($text, 0, $open, $close);
 return defined($match) && $match == length($text) - 1 ? 1 : 0
}

sub _find_matching_delim {
 my ($text, $open_idx, $open, $close) = @_;
 my $len = length($text);
 my $depth = 0;
 my $state = _new_scan_state();
 for (my $idx = $open_idx; $idx < $len; ++$idx) {
  my $ch = substr($text, $idx, 1);
  if ($idx == $open_idx) {
   return undef unless $ch eq $open;
   ++$depth;
   next;
  }
  if (_consume_quote_only_scan_char($state, $text, $idx, $ch)) {
   next;
  }
  if ($ch eq $open) {
   ++$depth;
   next;
  }
  if ($ch eq $close) {
   --$depth if $depth > 0;
   return $idx if $depth == 0;
   next;
  }
 }
 return undef
}

sub _has_top_level_fat_arrow {
 my ($text) = @_;
 return defined(_find_top_level_fat_arrow($text)) ? 1 : 0
}

sub _find_top_level_fat_arrow {
 my ($text) = @_;
 return _find_top_level_token($text, '=>')
}

sub _find_top_level_assignment_eq {
 my ($text) = @_;
 my $state = _new_scan_state();
 my $len = length($text);
 for (my $idx = 0; $idx < $len; ++$idx) {
  my $ch = substr($text, $idx, 1);
  if (_consume_scan_char($state, $text, $idx, $ch)) {
   next;
  }
  next unless $ch eq '=';
  next unless _scan_is_top_level($state);
  my $prev = $idx > 0 ? substr($text, $idx - 1, 1) : '';
  my $next = $idx + 1 < $len ? substr($text, $idx + 1, 1) : '';
  next if $next eq '>' || $next eq '=';
  next if $prev eq '<' || $prev eq '>' || $prev eq '!' || $prev eq '=';
  return $idx;
 }
 return undef
}

sub _find_top_level_token {
 my ($text, $token) = @_;
 return undef unless defined($text) && defined($token) && length($token);
 my $state = _new_scan_state();
 my $len = length($text);
 my $token_len = length($token);
 for (my $idx = 0; $idx <= $len - $token_len; ++$idx) {
  my $ch = substr($text, $idx, 1);
  if (_consume_scan_char($state, $text, $idx, $ch)) {
   next;
  }
  next unless _scan_is_top_level($state);
  return $idx if substr($text, $idx, $token_len) eq $token;
 }
 return undef
}

sub _new_scan_state {
 return {
  paren_depth => 0,
  brace_depth => 0,
  bracket_depth => 0,
  in_single_quote => 0,
  in_double_quote => 0,
  in_slash_quote => 0,
  escape_next => 0,
  slash_escape_next => 0,
 }
}

sub _scan_is_top_level {
 my ($state) = @_;
 return $state->{paren_depth} == 0 && $state->{brace_depth} == 0 && $state->{bracket_depth} == 0
}

sub _consume_quote_only_scan_char {
 my ($state, $text, $idx, $ch) = @_;
 if ($state->{in_slash_quote}) {
  if ($state->{slash_escape_next}) { $state->{slash_escape_next} = 0; }
  elsif ($ch eq '\\') { $state->{slash_escape_next} = 1; }
  elsif ($ch eq '/') { $state->{in_slash_quote} = 0; }
  return 1;
 }
 if ($state->{in_single_quote}) {
  if ($state->{escape_next}) { $state->{escape_next} = 0; }
  elsif ($ch eq '\\') { $state->{escape_next} = 1; }
  elsif ($ch eq "'") { $state->{in_single_quote} = 0; }
  return 1;
 }
 if ($state->{in_double_quote}) {
  if ($state->{escape_next}) { $state->{escape_next} = 0; }
  elsif ($ch eq '\\') { $state->{escape_next} = 1; }
  elsif ($ch eq '"') { $state->{in_double_quote} = 0; }
  return 1;
 }
 if ($ch eq "'") {
  $state->{in_single_quote} = 1;
  return 1;
 }
 if ($ch eq '"') {
  $state->{in_double_quote} = 1;
  return 1;
 }
 if ($ch eq '/') {
  my $prefix = substr($text, 0, $idx);
  $prefix =~ s/\s+$//o;
  if (!length($prefix) || substr($prefix, -1, 1) =~ /[\(\[,=>]/o) {
   $state->{in_slash_quote} = 1;
   $state->{slash_escape_next} = 0;
   return 1;
  }
 }
 return 0
}

sub _consume_scan_char {
 my ($state, $text, $idx, $ch) = @_;
 return 1 if _consume_quote_only_scan_char($state, $text, $idx, $ch);
 if ($ch eq '(') { ++$state->{paren_depth}; return 1; }
 if ($ch eq ')') { --$state->{paren_depth} if $state->{paren_depth} > 0; return 1; }
 if ($ch eq '{') { ++$state->{brace_depth}; return 1; }
 if ($ch eq '}') { --$state->{brace_depth} if $state->{brace_depth} > 0; return 1; }
 if ($ch eq '[') { ++$state->{bracket_depth}; return 1; }
 if ($ch eq ']') { --$state->{bracket_depth} if $state->{bracket_depth} > 0; return 1; }
 return 0
}

1;
