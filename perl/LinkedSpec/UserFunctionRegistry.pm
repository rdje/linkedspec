#------------------------------------------------------------------------------
# Package: LinkedSpec::UserFunctionRegistry
# Purpose: Temporary Perl-reference bridge for top-level user function
#          definitions while specs/spec.spec remains the permanent grammar owner.
#------------------------------------------------------------------------------
package LinkedSpec::UserFunctionRegistry;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

sub empty_function_registry {
 return {
  kind => 'user_function_registry',
  version => 1,
  order => [],
  by_name => {},
 }
}

sub is_user_function_registry {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'user_function_registry';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{order}) eq 'ARRAY';
 return 0 unless ref($value->{by_name}) eq 'HASH';
 return 1
}

sub function_registry_count {
 my ($registry) = @_;
 return 0 unless is_user_function_registry($registry);
 return scalar(@{$registry->{order}})
}

sub function_registry_order {
 my ($registry) = @_;
 return [] unless is_user_function_registry($registry);
 return [@{$registry->{order}}]
}

sub function_registry_by_name {
 my ($registry) = @_;
 return {} unless is_user_function_registry($registry);
 return { %{$registry->{by_name}} }
}

sub extract_and_strip_spec_source {
 my ($spec_content_ref) = @_;
 die "(LinkedSpec::UserFunctionRegistry::extract_and_strip_spec_source) -E- expected SCALAR ref\n"
  unless ref($spec_content_ref) eq 'SCALAR';

 my $source = $$spec_content_ref;
 my $stripped = $source;
 my $registry = empty_function_registry();
 my $len = length($source);
 my $idx = 0;
 my $line_can_start_token = 1;
 my $scan = _new_top_level_scan_state();

 while ($idx < $len) {
  if ($line_can_start_token && _scan_is_clear($scan) && ($scan->{brace_depth} || 0) == 0) {
   my $candidate = $idx;
   ++$candidate while $candidate < $len && substr($source, $candidate, 1) =~ /[ \t]/o;
   if (_starts_with_function_keyword($source, $candidate)) {
    my $definition = _parse_function_definition_at($source, $candidate);
    _record_function_definition($registry, $definition);
    substr($stripped, $definition->{source_span}{start}, $definition->{source_span}{end} - $definition->{source_span}{start})
     = _blank_preserving_newlines(substr($source, $definition->{source_span}{start}, $definition->{source_span}{end} - $definition->{source_span}{start}));
    $idx = $definition->{source_span}{end};
    $line_can_start_token = 0;
    next;
   }
  }

  my ($next_idx, $next_line_can_start_token) = _advance_top_level_scan($source, $idx, $scan, $line_can_start_token);
  $idx = $next_idx;
  $line_can_start_token = $next_line_can_start_token;
 }

 return {
  stripped_source => $stripped,
  registry => $registry,
 }
}

sub validate_registry_against_rule_labels {
 my ($registry, $rule_labels) = @_;
 return 1 unless is_user_function_registry($registry);
 $rule_labels = [] unless ref($rule_labels) eq 'ARRAY';
 my %rule_label = map { defined($_) && !ref($_) && length($_) ? ($_ => 1) : () } @$rule_labels;
 foreach my $name (@{$registry->{order}}) {
  next unless $rule_label{$name};
  my $definition = $registry->{by_name}{$name};
  _die_definition_error(
   $definition,
   "User function '$name' collides with rule label '$name'",
   'Choose a function name that does not reuse a rule label',
  );
 }
 return 1
}

sub _new_top_level_scan_state {
 return {
  brace_depth => 0,
  in_single => 0,
  in_double => 0,
  in_regex => 0,
  in_comment => 0,
  escape_next => 0,
 }
}

sub _scan_is_clear {
 my ($scan) = @_;
 return !$scan->{in_single} && !$scan->{in_double} && !$scan->{in_regex} && !$scan->{in_comment}
}

sub _starts_with_function_keyword {
 my ($source, $idx) = @_;
 return 0 unless defined($idx) && $idx >= 0 && $idx < length($source);
 return 0 unless substr($source, $idx, 2) eq 'fn';
 my $next = substr($source, $idx + 2, 1);
 return (!defined($next) || $next !~ /[A-Za-z0-9_]/o) ? 1 : 0
}

sub _advance_top_level_scan {
 my ($source, $idx, $scan, $line_can_start_token) = @_;
 my $ch = substr($source, $idx, 1);

 if ($scan->{in_comment}) {
  if ($ch eq "\n") {
   $scan->{in_comment} = 0;
   return ($idx + 1, 1);
  }
  return ($idx + 1, $line_can_start_token);
 }

 if ($scan->{in_single} || $scan->{in_double} || $scan->{in_regex}) {
  if ($scan->{escape_next}) {
   $scan->{escape_next} = 0;
  } elsif ($ch eq '\\') {
   $scan->{escape_next} = 1;
  } elsif ($scan->{in_single} && $ch eq "'") {
   $scan->{in_single} = 0;
  } elsif ($scan->{in_double} && $ch eq '"') {
   $scan->{in_double} = 0;
  } elsif ($scan->{in_regex} && $ch eq '/') {
   $scan->{in_regex} = 0;
  } elsif ($scan->{in_regex} && $ch eq "\n") {
   $scan->{in_regex} = 0;
   return ($idx + 1, 1);
  }
  return ($idx + 1, $line_can_start_token);
 }

 if ($ch eq '#') {
  $scan->{in_comment} = 1;
  return ($idx + 1, 0);
 }
 if ($ch eq "'") {
  $scan->{in_single} = 1;
  return ($idx + 1, 0);
 }
 if ($ch eq '"') {
  $scan->{in_double} = 1;
  return ($idx + 1, 0);
 }
 if ($ch eq '/') {
  my $regex_end = _scan_slash_construct_end($source, $idx);
  if (defined($regex_end)) {
   return ($regex_end + 1, 0);
  }
 }
 if ($ch eq '{') {
  ++$scan->{brace_depth};
 } elsif ($ch eq '}') {
  --$scan->{brace_depth} if $scan->{brace_depth} > 0;
 }

 if ($ch eq "\n") {
  return ($idx + 1, 1);
 }
 if ($line_can_start_token && ($ch eq ' ' || $ch eq "\t")) {
  return ($idx + 1, 1);
 }
 return ($idx + 1, 0)
}

sub _parse_function_definition_at {
 my ($source, $start) = @_;
 my $cursor = $start;
 my $len = length($source);

 _die_parse_error($source, $start, 'expected function keyword fn')
  unless _starts_with_function_keyword($source, $cursor);
 $cursor += 2;
 _die_parse_error($source, $start, 'expected whitespace after fn')
  unless $cursor < $len && substr($source, $cursor, 1) =~ /\s/o;
 $cursor = _skip_ws($source, $cursor);

 my $name_start = $cursor;
 ++$cursor while $cursor < $len && substr($source, $cursor, 1) =~ /[A-Za-z0-9_]/o;
 my $name = substr($source, $name_start, $cursor - $name_start);
 _die_parse_error($source, $start, 'expected function name after fn')
  unless _is_identifier($name);
 $cursor = _skip_ws($source, $cursor);

 _die_parse_error($source, $start, "expected '(' after function name '$name'")
  unless $cursor < $len && substr($source, $cursor, 1) eq '(';
 my $params_open = $cursor;
 my $params_close = _scan_matching_delimiter($source, $params_open, '(', ')');
 _die_parse_error($source, $start, "unterminated parameter list for function '$name'")
  unless defined $params_close;
 my $params_source = substr($source, $params_open + 1, $params_close - $params_open - 1);
 my $params = _parse_parameter_list($source, $start, $name, $params_source);
 $cursor = _skip_ws($source, $params_close + 1);

 _die_parse_error($source, $start, "expected body block after function '$name' parameter list")
  unless $cursor < $len && substr($source, $cursor, 1) eq '{';
 my $body_open = $cursor;
 my $body_close = _scan_matching_delimiter($source, $body_open, '{', '}');
 _die_parse_error($source, $start, "unterminated body block for function '$name'")
  unless defined $body_close;

 my $end = $body_close + 1;
 my $body_source = substr($source, $body_open + 1, $body_close - $body_open - 1);
 my $body_ast = _parse_function_body_ast($name, $body_source, $source, $start);
 my $line_start = _line_number_at($source, $start);
 my $line_end = _line_number_at($source, $end);

 my $definition = {
  kind => 'user_function_definition',
  version => 1,
  name => $name,
  params => $params,
  arity => scalar(@$params),
  source_span => {
   start => 0 + $start,
   end => 0 + $end,
   line_start => 0 + $line_start,
   line_end => 0 + $line_end,
  },
  body_span => {
   start => 0 + ($body_open + 1),
   end => 0 + $body_close,
  },
  body_source => $body_source,
  body_ast => $body_ast,
 };

 _validate_function_name($definition);
 foreach my $param (@$params) {
  _validate_parameter_name($definition, $param);
 }
 return $definition
}

sub _parse_parameter_list {
 my ($source, $definition_start, $name, $params_source) = @_;
 my $trimmed = _trim($params_source);
 return [] unless defined($trimmed) && length($trimmed);
 my @params = split /\s*,\s*/, $trimmed, -1;
 my %seen;
 foreach my $param (@params) {
  $param = _trim($param);
  _die_parse_error($source, $definition_start, "invalid parameter in function '$name'")
   unless _is_identifier($param);
  _die_parse_error($source, $definition_start, "duplicate parameter '$param' in function '$name'")
   if $seen{$param}++;
 }
 return \@params
}

sub _parse_function_body_ast {
 my ($name, $body_source, $source, $definition_start) = @_;
 my $body_ast = eval {
  return LinkedSpec::OwnerDispatch::dispatch_owner_call(
   __PACKAGE__,
   'LinkedSpec::ActionIR::AST',
   'parse_action_block',
   $body_source,
  )
 };
 my $error = $@;
 if ($error) {
  _die_parse_error($source, $definition_start, "could not parse body AST for function '$name': $error");
 }
 return $body_ast
}

sub _record_function_definition {
 my ($registry, $definition) = @_;
 die "(LinkedSpec::UserFunctionRegistry::_record_function_definition) -E- invalid registry\n"
  unless is_user_function_registry($registry);
 die "(LinkedSpec::UserFunctionRegistry::_record_function_definition) -E- invalid function definition\n"
  unless ref($definition) eq 'HASH' && ($definition->{kind} // '') eq 'user_function_definition';
 my $name = $definition->{name};
 if (exists $registry->{by_name}{$name}) {
  _die_definition_error(
   $definition,
   "Duplicate user function definition '$name'",
   'Remove the duplicate function or rename one of them',
  );
 }
 push @{$registry->{order}}, $name;
 $registry->{by_name}{$name} = $definition;
 return 1
}

sub _validate_function_name {
 my ($definition) = @_;
 my $name = $definition->{name};
 _die_definition_error($definition, "Invalid user function name '$name'", 'Use a valid identifier')
  unless _is_identifier($name);
 if (_is_reserved_runtime_symbol($name)) {
  _die_definition_error($definition, "User function '$name' uses a reserved runtime symbol", 'Choose a non-reserved function name');
 }
 if (_is_lifecycle_marker_name($name)) {
  _die_definition_error($definition, "User function '$name' collides with lifecycle marker '$name'", 'Choose a non-lifecycle function name');
 }
 my $known = _known_actionir_call_name($name);
 if (defined($known) && length($known)) {
  _die_definition_error($definition, "User function '$name' collides with built-in helper/control name '$name'", 'Choose a function name outside the built-in helper surface');
 }
 return 1
}

sub _validate_parameter_name {
 my ($definition, $param) = @_;
 _die_definition_error($definition, "User function '$definition->{name}' has invalid parameter '$param'", 'Use valid parameter identifiers')
  unless _is_identifier($param);
 if (_is_reserved_runtime_symbol($param) || _is_lifecycle_marker_name($param) || _is_function_keyword($param)) {
  _die_definition_error($definition, "User function '$definition->{name}' parameter '$param' is reserved", 'Choose a non-reserved parameter name');
 }
 return 1
}

sub _known_actionir_call_name {
 my ($name) = @_;
 return undef unless defined($name) && length($name);
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::MethodLowering');
  no strict 'refs';
  return LinkedSpec::ActionIR::MethodLowering::_actionir_ast_known_value_call_method($name);
 })
}

sub _is_function_keyword {
 my ($name) = @_;
 return 0 unless defined($name);
 state %reserved = map { $_ => 1 } qw(fn return);
 return $reserved{$name} ? 1 : 0
}

sub _is_lifecycle_marker_name {
 my ($name) = @_;
 return 0 unless defined($name);
 state %markers = map { $_ => 1 } qw(I LS LE E EX IT LX);
 return $markers{$name} ? 1 : 0
}

sub _is_reserved_runtime_symbol {
 my ($name) = @_;
 return 0 unless defined($name);
 state %reserved = map { $_ => 1 } qw(
  STRING descr minfo LSPOS LEPOS LMATCH LSMATCH IMATCH
  IMATCH_LIST LMATCH_LIST IMATCH_HASH LMATCH_HASH
  SELF this ctx runtime_ctx
 );
 return $reserved{$name} ? 1 : 0
}

sub _is_identifier {
 my ($value) = @_;
 return defined($value) && !ref($value) && $value =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o ? 1 : 0
}

sub _trim {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s+//o;
 $value =~ s/\s+\z//o;
 return $value
}

sub _skip_ws {
 my ($source, $idx) = @_;
 my $len = length($source);
 ++$idx while $idx < $len && substr($source, $idx, 1) =~ /\s/o;
 return $idx
}

sub _scan_matching_delimiter {
 my ($source, $open_idx, $open, $close) = @_;
 return undef unless defined($open_idx) && substr($source, $open_idx, 1) eq $open;
 my $len = length($source);
 my $depth = 1;
 my $idx = $open_idx + 1;
 my $in_single = 0;
 my $in_double = 0;
 my $escape_next = 0;

 while ($idx < $len) {
  my $ch = substr($source, $idx, 1);
  if ($in_single || $in_double) {
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($ch eq '\\') {
    $escape_next = 1;
   } elsif ($in_single && $ch eq "'") {
    $in_single = 0;
   } elsif ($in_double && $ch eq '"') {
    $in_double = 0;
   }
   ++$idx;
   next;
  }

  if ($ch eq "'") {
   $in_single = 1;
   ++$idx;
   next;
  }
  if ($ch eq '"') {
   $in_double = 1;
   ++$idx;
   next;
  }
  if ($ch eq '/') {
   my $regex_end = _scan_slash_construct_end($source, $idx);
   if (defined($regex_end)) {
    $idx = $regex_end + 1;
    next;
   }
  }
  if ($ch eq $open) {
   ++$depth;
  } elsif ($ch eq $close) {
   --$depth;
   return $idx if $depth == 0;
  }
  ++$idx;
 }
 return undef
}

sub _scan_slash_construct_end {
 my ($source, $slash_idx) = @_;
 return undef unless defined($slash_idx) && substr($source, $slash_idx, 1) eq '/';
 my $idx = $slash_idx + 1;
 my $len = length($source);
 my $escape_next = 0;
 while ($idx < $len) {
  my $ch = substr($source, $idx, 1);
  return undef if $ch eq "\n";
  if ($escape_next) {
   $escape_next = 0;
  } elsif ($ch eq '\\') {
   $escape_next = 1;
  } elsif ($ch eq '/') {
   return $idx;
  }
  ++$idx;
 }
 return undef
}

sub _blank_preserving_newlines {
 my ($text) = @_;
 $text = '' unless defined $text;
 $text =~ s/[^\n]/ /go;
 return $text
}

sub _line_number_at {
 my ($source, $idx) = @_;
 $idx = 0 unless defined $idx;
 $idx = 0 if $idx < 0;
 $idx = length($source) if $idx > length($source);
 my $prefix = substr($source, 0, $idx);
 return 1 + ($prefix =~ tr/\n//)
}

sub _die_parse_error {
 my ($source, $definition_start, $reason) = @_;
 my $line = _line_number_at($source, $definition_start);
 die "Invalid user function definition at line $line: $reason\n";
}

sub _die_definition_error {
 my ($definition, $summary, $suggestion) = @_;
 my $line = (ref($definition) eq 'HASH' && ref($definition->{source_span}) eq 'HASH')
  ? ($definition->{source_span}{line_start} || 0)
  : 0;
 my $detail = $summary;
 $detail .= " at line $line" if $line;
 $detail .= ". $suggestion" if defined($suggestion) && length($suggestion);
 die "$detail\n";
}

1;
