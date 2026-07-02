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

my $__function_definition_parser;
my $__loading_function_definition_parser = 0;

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
 my $registry = empty_function_registry();
 return { stripped_source => $source, registry => $registry }
  if $__loading_function_definition_parser;

 my $definitions = _parse_function_definition_asts($spec_content_ref);
 my $stripped = $source;
 foreach my $node (@$definitions) {
  _die_function_definition_error_node($source, $node)
   if _is_function_definition_error_node($node);
  my $definition = _normalize_function_definition_ast($source, $node, scalar(@{$registry->{order}}));
  _record_function_definition($registry, $definition);
  my $span = $definition->{source_span};
  substr($stripped, $span->{start}, $span->{end} - $span->{start})
   = _blank_preserving_newlines(substr($source, $span->{start}, $span->{end} - $span->{start}));
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

sub _parse_function_definition_asts {
 my ($spec_content_ref) = @_;
 my $parser = _function_definition_parser();
 my $input = $$spec_content_ref;
 my $ast = eval { $parser->(\$input) };
 my $error = $@;
 if ($error) {
  die "Invalid user function definition parser failure: $error";
 }
 return [] unless defined $ast;
 die "Invalid user function definition parser result: expected ARRAY AST\n"
  unless ref($ast) eq 'ARRAY';
 return $ast
}

sub _function_definition_parser {
 return $__function_definition_parser
  if ref($__function_definition_parser) eq 'CODE';
 die "Recursive user function definition parser load\n"
  if $__loading_function_definition_parser;

 my $previous_loading_state = $__loading_function_definition_parser;
 $__loading_function_definition_parser = 1;
 my ($spec_source, $parser);
 my $load_ok = eval {
  $spec_source = _load_function_definition_spec_source();
  $parser = LinkedSpec::OwnerDispatch::dispatch_owner_call(
   __PACKAGE__,
   'LinkedSpec',
   'Get',
   \$spec_source,
   top_rule => 'user_function_definitions',
  );
  1
 };
 my $load_error = $@;
 $__loading_function_definition_parser = $previous_loading_state;
 die $load_error unless $load_ok;
 die "Could not compile specs/user_function_definition.spec into a parser\n"
  unless ref($parser) eq 'CODE';
 $__function_definition_parser = $parser;
 return $__function_definition_parser
}

sub _load_function_definition_spec_source {
 my $path = _function_definition_spec_path();
 open my $fh, '<', $path
  or die "Could not read user function definition spec '$path': $!\n";
 local $/;
 return <$fh>
}

sub _function_definition_spec_path {
 require Cwd;
 require File::Basename;
 require File::Spec;
 my $module_file = Cwd::abs_path(__FILE__) || __FILE__;
 my $module_dir = (File::Basename::fileparse($module_file))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 my $repo_root = File::Basename::dirname($perl_root);
 return File::Spec->catfile($repo_root, 'specs', 'user_function_definition.spec')
}

sub _normalize_function_definition_ast {
 my ($source, $node, $ordinal) = @_;
 die "Invalid user function definition AST: expected HASH node\n"
  unless ref($node) eq 'HASH';
 die "Invalid user function definition AST: expected type=function_definition\n"
  unless ($node->{type} // '') eq 'function_definition';
 die "Invalid user function definition AST: expected kind=user_function_definition\n"
  unless ($node->{kind} // '') eq 'user_function_definition';

 my $name = _require_identifier_field($node, 'name');
 my $params = _require_identifier_array_field($node, 'params');
 my $arity = _require_integer_field($node, 'arity');
 die "Invalid user function definition AST for '$name': arity does not match params\n"
  unless $arity == scalar(@$params);

 my $source_span = _require_span_field($node, 'source_span');
 my $body_span = _require_span_field($node, 'body_span');
 my $body_source = _require_string_field($node, 'body_source');
 my $body_payload = _normalize_body_payload($node->{body_payload}, $name, $params, $arity, $body_source, $body_span, $ordinal);

 my %seen;
 foreach my $param (@$params) {
  _die_parse_error_at_span($source, $source_span, "duplicate parameter '$param' in function '$name'")
   if $seen{$param}++;
 }

 my $definition = {
  kind => 'user_function_definition',
  version => 1,
  name => $name,
  params => [@$params],
  arity => $arity,
  source_text => defined($node->{source_text}) && !ref($node->{source_text}) ? $node->{source_text} : '',
  source_span => $source_span,
  body_span => $body_span,
  body_source => $body_source,
  body_ast => _parse_function_body_ast($name, $body_source, $source, $source_span),
  body_payload => $body_payload,
 };

 _validate_function_name($definition);
 foreach my $param (@$params) {
  _validate_parameter_name($definition, $param);
 }
 return $definition
}

sub _normalize_body_payload {
 my ($payload, $name, $params, $arity, $body_source, $body_span, $ordinal) = @_;
 die "Invalid user function definition AST: body_payload must be HASH\n"
  unless ref($payload) eq 'HASH';
 die "Invalid user function definition AST: body_payload.kind must be staged_payload\n"
  unless ($payload->{kind} // '') eq 'staged_payload';
 die "Invalid user function definition AST: body_payload.node_kind must be function_definition\n"
  unless ($payload->{node_kind} // '') eq 'function_definition';
 die "Invalid user function definition AST: body_payload.payload_kind must be function_body\n"
  unless ($payload->{payload_kind} // '') eq 'function_body';

 my $payload_name = _require_string_field($payload, 'function_name');
 die "Invalid user function definition AST: body_payload function name mismatch\n"
  unless $payload_name eq $name;
 my $payload_params = _require_identifier_array_field($payload, 'params');
 die "Invalid user function definition AST: body_payload params mismatch\n"
  unless _arrays_equal($payload_params, $params);
 my $payload_arity = _require_integer_field($payload, 'arity');
 die "Invalid user function definition AST: body_payload arity mismatch\n"
  unless $payload_arity == $arity;
 my $payload_text = _require_string_field($payload, 'text');
 die "Invalid user function definition AST: body_payload text mismatch\n"
  unless $payload_text eq $body_source;
 my $payload_span = _require_span_field($payload, 'source_span');
 die "Invalid user function definition AST: body_payload span mismatch\n"
  unless _spans_equal($payload_span, $body_span);

 my $out = _clone_plain($payload);
 $out->{parent_ast_path} = ['functions', "$ordinal", 'body_source'];
 return $out
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

sub _parse_function_body_ast {
 my ($name, $body_source, $source, $source_span) = @_;
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
  _die_parse_error_at_span($source, $source_span, "could not parse body AST for function '$name': $error");
 }
 return $body_ast
}

sub _is_function_definition_error_node {
 my ($node) = @_;
 return ref($node) eq 'HASH' && ($node->{type} // '') eq 'function_definition_error'
}

sub _die_function_definition_error_node {
 my ($source, $node) = @_;
 my $span = ref($node->{source_span}) eq 'HASH'
  ? _span_or_default($node->{source_span})
  : { start => 0, end => 0, line_start => 1, line_end => 1 };
 my $message = defined($node->{message}) && !ref($node->{message}) && length($node->{message})
  ? $node->{message}
  : 'invalid user function definition';
 _die_parse_error_at_span($source, $span, $message);
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

sub _require_identifier_field {
 my ($node, $field) = @_;
 my $value = _require_string_field($node, $field);
 die "Invalid user function definition AST: field '$field' is not an identifier\n"
  unless _is_identifier($value);
 return $value
}

sub _require_string_field {
 my ($node, $field) = @_;
 die "Invalid user function definition AST: missing field '$field'\n"
  unless ref($node) eq 'HASH' && exists($node->{$field});
 die "Invalid user function definition AST: field '$field' must be scalar text\n"
  if ref($node->{$field});
 return defined($node->{$field}) ? "$node->{$field}" : ''
}

sub _require_integer_field {
 my ($node, $field) = @_;
 die "Invalid user function definition AST: missing integer field '$field'\n"
  unless ref($node) eq 'HASH' && exists($node->{$field});
 my $value = $node->{$field};
 die "Invalid user function definition AST: field '$field' must be integer\n"
  unless defined($value) && !ref($value) && $value =~ /\A\d+\z/o;
 return 0 + $value
}

sub _require_identifier_array_field {
 my ($node, $field) = @_;
 die "Invalid user function definition AST: missing array field '$field'\n"
  unless ref($node) eq 'HASH' && exists($node->{$field});
 die "Invalid user function definition AST: field '$field' must be ARRAY\n"
  unless ref($node->{$field}) eq 'ARRAY';
 my @values;
 foreach my $value (@{$node->{$field}}) {
  die "Invalid user function definition AST: field '$field' contains a non-identifier\n"
   unless _is_identifier($value);
  push @values, "$value";
 }
 return \@values
}

sub _require_span_field {
 my ($node, $field) = @_;
 die "Invalid user function definition AST: missing span field '$field'\n"
  unless ref($node) eq 'HASH' && exists($node->{$field});
 die "Invalid user function definition AST: field '$field' must be HASH span\n"
  unless ref($node->{$field}) eq 'HASH';
 return _span_or_default($node->{$field}, $field)
}

sub _span_or_default {
 my ($span, $field) = @_;
 my %out;
 foreach my $key (qw(start end line_start line_end)) {
  die "Invalid user function definition AST: span '$field' missing '$key'\n"
   unless exists($span->{$key});
  die "Invalid user function definition AST: span '$field' '$key' must be integer\n"
   unless defined($span->{$key}) && !ref($span->{$key}) && $span->{$key} =~ /\A\d+\z/o;
  $out{$key} = 0 + $span->{$key};
 }
 return \%out
}

sub _arrays_equal {
 my ($left, $right) = @_;
 return 0 unless ref($left) eq 'ARRAY' && ref($right) eq 'ARRAY';
 return 0 unless @$left == @$right;
 for (my $i = 0; $i < @$left; ++$i) {
  return 0 unless (defined($left->[$i]) ? $left->[$i] : '') eq (defined($right->[$i]) ? $right->[$i] : '');
 }
 return 1
}

sub _spans_equal {
 my ($left, $right) = @_;
 return 0 unless ref($left) eq 'HASH' && ref($right) eq 'HASH';
 foreach my $key (qw(start end line_start line_end)) {
  return 0 unless ($left->{$key} // '') eq ($right->{$key} // '');
 }
 return 1
}

sub _clone_plain {
 my ($value) = @_;
 return [map { _clone_plain($_) } @$value] if ref($value) eq 'ARRAY';
 if (ref($value) eq 'HASH') {
  my %copy;
  foreach my $key (keys %$value) {
   $copy{$key} = _clone_plain($value->{$key});
  }
  return \%copy
 }
 return $value
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

sub _die_parse_error_at_span {
 my ($source, $span, $reason) = @_;
 my $line = (ref($span) eq 'HASH' && $span->{line_start})
  ? $span->{line_start}
  : _line_number_at($source, 0);
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
