#------------------------------------------------------------------------------
# Package: LinkedSpec::RuleIR::EmitContext
# Purpose: Build the rule-emission context that bridges RuleIR planning into
#          ActionIR scanning, diagnostics, and lowering.
#------------------------------------------------------------------------------
package LinkedSpec::RuleIR::EmitContext;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $rule_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($rule_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

use constant {
 DUMP_LOW => 100,
 DUMP_DEBUG => 500,
};

our $__ls_current_function_registry;
our $__ls_current_bare_type_memory;

sub _trace_should_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return 0 unless defined &LinkedSpec::Trace::should_dump;
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _trace_enter {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless defined &LinkedSpec::Trace::trace_enter;
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless defined &LinkedSpec::Trace::trace_exit;
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return 0 unless defined &LinkedSpec::Trace::trace_decision;
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_emit_context_token {
 my ($value, $fallback) = @_;
 $value = $fallback unless defined($value) && length($value);
 $value = '<unknown>' unless defined($value) && length($value);
 $value =~ s/[^A-Za-z0-9_.:-]+/_/go;
 return $value
}

sub _trace_emit_context_value {
 my ($value) = @_;
 return '<undef>' unless defined $value;
 return ref($value) if ref($value);
 $value =~ s/\s+/ /go;
 return $value
}

sub _trace_emit_context_decision {
 my (%args) = @_;
 my $taken = $args{taken} ? 1 : 0;
 my $level = exists($args{level}) ? $args{level} : DUMP_DEBUG;
 return $taken unless _trace_should_dump($level);

 my $phase = _trace_emit_context_token($args{phase}, 'bridge');
 my $label = _trace_emit_context_token($args{label}, '<unknown>');
 my $decision = _trace_emit_context_token($args{decision}, 'decision');
 my @reason = (
  'phase=' . $phase,
  'label=' . $label,
  'decision=' . $decision,
 );
 if (ref($args{context}) eq 'HASH') {
  push @reason, map { $_ . '=' . _trace_emit_context_value($args{context}{$_}) } sort keys %{$args{context}};
 }

 return _trace_decision(
  "emit_context:$phase:$label:$decision",
  $taken,
  join("\n", @reason),
  $level,
 )
}

sub _trace_emit_context_enter {
 my ($phase, $label, $details) = @_;
 return undef unless _trace_should_dump(DUMP_DEBUG);
 my $phase_token = _trace_emit_context_token($phase, 'bridge');
 my $label_token = _trace_emit_context_token($label, '<unknown>');
 return _trace_enter(
  "LinkedSpec::RuleIR::EmitContext::$phase_token:$label_token",
  $details,
  DUMP_DEBUG,
 )
}

sub _trace_emit_context_exit {
 my ($scope, $details) = @_;
 return _trace_exit($scope, $details, DUMP_DEBUG)
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_package
# Purpose : Resolve one local ActionIR owner key to its package name and
#           lazy-load it through the shared owner-dispatch seam.
# Args    : ($owner_key)
# Returns : loaded package name
#------------------------------------------------------------------------------
sub _actionir_owner_package {
 my ($owner_key) = @_;
 state $owner_pkgs = {
  rewrite_pipeline => 'LinkedSpec::ActionIR::RewritePipeline',
  method_expr => 'LinkedSpec::ActionIR::MethodExpr',
  scanner => 'LinkedSpec::ActionIR::Scanner',
  canonical_events => 'LinkedSpec::ActionIR::CanonicalEvents',
  diagnostics => 'LinkedSpec::ActionIR::Diagnostics',
  statement_split => 'LinkedSpec::ActionIR::StatementSplit',
  contracts => 'LinkedSpec::ActionIR::Contracts',
  flow_expr => 'LinkedSpec::ActionIR::FlowExpr',
  array_pipeline => 'LinkedSpec::ActionIR::ArrayPipeline',
  control_flow => 'LinkedSpec::ActionIR::ControlFlow',
  method_lowering => 'LinkedSpec::ActionIR::MethodLowering',
  declare_method => 'LinkedSpec::ActionIR::DeclareMethod',
  value_expr => 'LinkedSpec::ActionIR::ValueExpr',
  trace => 'LinkedSpec::Trace',
 };

 my $pkg = $owner_pkgs->{$owner_key};
 unless (defined($pkg) && length($pkg)) {
  _trace_emit_context_decision(
   phase => 'owner_package',
   label => defined($owner_key) ? $owner_key : '<undef>',
   decision => 'unknown_owner_key',
   taken => 0,
   context => { owner_key => defined($owner_key) ? $owner_key : '<undef>' },
  );
  die "(LinkedSpec::RuleIR::EmitContext::_actionir_owner_package) -E- unknown owner key '$owner_key'";
 }
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 _trace_emit_context_decision(
  phase => 'owner_package',
  label => $owner_key,
  decision => 'resolve',
  taken => 1,
  context => {
   owner_key => $owner_key,
   package => $pkg,
  },
 );
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_callback
# Purpose : Resolve one callback from a local ActionIR owner through the shared
#           owner-dispatch callback loader.
# Args    : ($owner_key, $method)
# Returns : coderef
#------------------------------------------------------------------------------
sub _actionir_owner_callback {
 my ($owner_key, $method) = @_;
 my $pkg = _actionir_owner_package($owner_key);
 my $code = LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $method);
 _trace_emit_context_decision(
  phase => 'owner_callback',
  label => $owner_key,
  decision => $method,
  taken => ref($code) eq 'CODE',
  context => {
   owner_key => $owner_key,
   package => $pkg,
   method => $method,
  },
 );
 return $code
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_default_deps
# Purpose : Ask one local ActionIR owner for its default dependency bundle as
#           seen from this emit-context package.
# Args    : ($owner_key)
# Returns : hashref dependency map
#------------------------------------------------------------------------------
sub _actionir_owner_default_deps {
 my ($owner_key) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $scope = _trace_emit_context_enter(
   'owner_deps',
   $owner_key,
   { owner_key => $owner_key },
  );
  my $code = _actionir_owner_callback($owner_key, 'default_deps_for_package');
  my $owner_deps = $code->(__PACKAGE__);
  my $dep_keys = ref($owner_deps) eq 'HASH' ? join(',', sort keys %$owner_deps) : '';
  _trace_emit_context_decision(
   phase => 'owner_deps',
   label => $owner_key,
   decision => 'default_bundle',
   taken => ref($owner_deps) eq 'HASH',
   context => {
    owner_key => $owner_key,
    dep_count => ref($owner_deps) eq 'HASH' ? scalar(keys %$owner_deps) : 0,
    dep_keys => $dep_keys,
    dep_ref => ref($owner_deps) || '',
   },
  );
  my $inject_function_registry = (
   ($owner_key eq 'method_lowering' || $owner_key eq 'canonical_events')
   && ref($__ls_current_function_registry) eq 'HASH'
   && ref($owner_deps) eq 'HASH'
  ) ? 1 : 0;
  _trace_emit_context_decision(
   phase => 'owner_deps',
   label => $owner_key,
   decision => 'inject_function_registry',
   taken => $inject_function_registry,
   context => {
    owner_key => $owner_key,
    registry_ref => ref($__ls_current_function_registry) || '',
    registry_count => ref($__ls_current_function_registry) eq 'HASH'
     ? scalar(keys %$__ls_current_function_registry)
     : 0,
   },
  );
  if ($inject_function_registry) {
   $owner_deps = {
    %$owner_deps,
    user_function_registry => $__ls_current_function_registry,
   };
  }
  my $inject_bare_symbol_kind = (
   ref($owner_deps) eq 'HASH' && ref($__ls_current_bare_type_memory) eq 'HASH'
  ) ? 1 : 0;
  _trace_emit_context_decision(
   phase => 'owner_deps',
   label => $owner_key,
   decision => 'inject_bare_symbol_kind',
   taken => $inject_bare_symbol_kind,
   context => {
    owner_key => $owner_key,
    bare_type_memory_ref => ref($__ls_current_bare_type_memory) || '',
    bare_type_memory_count => ref($__ls_current_bare_type_memory) eq 'HASH'
     ? scalar(keys %$__ls_current_bare_type_memory)
     : 0,
   },
  );
  if ($inject_bare_symbol_kind) {
   $owner_deps = {
    %$owner_deps,
    bare_symbol_kind => \&_bare_symbol_kind,
   };
  }
  _trace_emit_context_exit(
   $scope,
   {
    status => 'ok',
    owner_key => $owner_key,
    dep_count => ref($owner_deps) eq 'HASH' ? scalar(keys %$owner_deps) : 0,
   },
  );
  return $owner_deps
 })
}

#------------------------------------------------------------------------------
# Function: _call_actionir_owner
# Purpose : Dispatch one helper callback to a local ActionIR owner without
#           appending that owner's default dependency bundle.
# Args    : ($owner_key, $method, @args)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _call_actionir_owner {
 my ($owner_key, $method, @args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $wantarray = wantarray;
  my $scope = _trace_emit_context_enter(
   'owner_call',
   $owner_key,
   {
    owner_key => $owner_key,
    method => $method,
    arg_count => scalar(@args),
   },
  );
  my $code = _actionir_owner_callback($owner_key, $method);
  if ($wantarray) {
   my @ret = $code->(@args);
   _trace_emit_context_exit(
    $scope,
    { status => 'ok', owner_key => $owner_key, method => $method, return_count => scalar(@ret) },
   );
   return @ret
  }
  if (defined $wantarray) {
   my $ret = $code->(@args);
   _trace_emit_context_exit(
    $scope,
    { status => 'ok', owner_key => $owner_key, method => $method, return_ref => ref($ret) || '' },
   );
   return $ret
  }
  $code->(@args);
  _trace_emit_context_exit(
   $scope,
   { status => 'ok', owner_key => $owner_key, method => $method, context => 'void' },
  );
  return
 })
}

#------------------------------------------------------------------------------
# Function: _call_actionir_owner_with_deps
# Purpose : Dispatch one helper callback to a local ActionIR owner and append
#           that owner's default dependency bundle automatically.
# Args    : ($owner_key, $method, @args)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _call_actionir_owner_with_deps {
 my ($owner_key, $method, @args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $wantarray = wantarray;
  my $scope = _trace_emit_context_enter(
   'owner_call_with_deps',
   $owner_key,
   {
    owner_key => $owner_key,
    method => $method,
    arg_count => scalar(@args),
   },
  );
  my $code = _actionir_owner_callback($owner_key, $method);
  my $deps = _actionir_owner_default_deps($owner_key);
  if ($wantarray) {
   my @ret = $code->(@args, $deps);
   _trace_emit_context_exit(
    $scope,
    { status => 'ok', owner_key => $owner_key, method => $method, return_count => scalar(@ret) },
   );
   return @ret
  }
  if (defined $wantarray) {
   my $ret = $code->(@args, $deps);
   _trace_emit_context_exit(
    $scope,
    { status => 'ok', owner_key => $owner_key, method => $method, return_ref => ref($ret) || '' },
   );
   return $ret
  }
  $code->(@args, $deps);
  _trace_emit_context_exit(
   $scope,
   { status => 'ok', owner_key => $owner_key, method => $method, context => 'void' },
  );
  return
 })
}

sub _trace_log_output {
 my @args = @_;
 return _call_actionir_owner('trace', 'log_output', @args)
}

sub _build_rewrite_diag_acc {
 return {
  unresolved_helper_hits  => {},
  unresolved_helper_count => 0,
  unresolved_helper_events => [],
  helper_action_ir_hits   => {},
  helper_action_ir_count  => 0,
  helper_action_ir_events => [],
  canonical_action_ir_hits   => {},
  canonical_action_ir_count  => 0,
  canonical_action_ir_events => [],
  canonical_action_ir_fallback_count => 0,
 }
}

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

sub _preserve_terminal_block_statement_separator {
 my ($original, $rewritten) = @_;
 return $rewritten unless defined($original) && defined($rewritten);
 return $rewritten unless $original =~ /;\s*\}$/o;
 return $rewritten if $rewritten =~ /;\s*\}$/o;
 $rewritten =~ s/\s*\}$/; }/o;
 return $rewritten
}

sub _parse_method_function_expr {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_parse_method_function_expr', @args)
}

sub _is_bare_method_scope_token {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_is_bare_method_scope_token', @args)
}

sub _normalize_method_args_with_optional_scope {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_normalize_method_args_with_optional_scope', @args)
}

sub _split_top_level_csv {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_split_top_level_csv', @args)
}

sub _statement_split_deps {
 return _actionir_owner_default_deps('statement_split')
}

sub _split_action_ir_statements {
 my @args = @_;
 return _call_actionir_owner_with_deps('statement_split', '_split_action_ir_statements', @args)
}

sub _flow_expr_deps {
 return _actionir_owner_default_deps('flow_expr')
}

sub _value_expr_deps {
 return _actionir_owner_default_deps('value_expr')
}

sub _method_lowering_deps {
 return _actionir_owner_default_deps('method_lowering')
}

sub _declare_method_deps {
 return _actionir_owner_default_deps('declare_method')
}

sub _array_pipeline_deps {
 return _actionir_owner_default_deps('array_pipeline')
}

sub _control_flow_deps {
 return _actionir_owner_default_deps('control_flow')
}

sub _scan_contract_ir_event_deps {
 return _actionir_owner_default_deps('scanner')
}

sub _diagnostics_deps {
 return _actionir_owner_default_deps('diagnostics')
}

sub _canonical_event_deps {
 return _actionir_owner_default_deps('canonical_events')
}

sub _action_contract_deps {
 return _actionir_owner_default_deps('contracts')
}

sub _rewrite_pipeline_deps {
 return _actionir_owner_default_deps('rewrite_pipeline')
}

sub _lower_flow_composite_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('flow_expr', '_lower_flow_composite_expr', @args)
}

sub _extract_scalar_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_scalar_symbol_name', @args)
}

sub _extract_array_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_array_symbol_name', @args)
}

sub _extract_hash_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_hash_symbol_name', @args)
}

sub _lower_scalar_access_key_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_scalar_access_key_expr', @args)
}

sub _lower_primitive_literal_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_primitive_literal_expr', @args)
}

sub _split_nested_access_path_segments {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_split_nested_access_path_segments', @args)
}

sub _lower_direct_nested_access_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_direct_nested_access_value_expr', @args)
}

sub _infer_scalar_container_kind {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_infer_scalar_container_kind', @args)
}

sub _lower_assignment_source_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_assignment_source_expr', @args)
}

sub _strip_literal_delimiters {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_strip_literal_delimiters', @args)
}

sub _split_declare_symbol_names {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_split_declare_symbol_names', @args)
}

sub _parse_declare_binding_entry {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_parse_declare_binding_entry', @args)
}

sub _lower_declare_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_value_expr', @args)
}

sub _lower_declare_initializer_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_initializer_expr', @args)
}

sub _lower_typed_declare_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_typed_declare_statement', @args)
}

sub _declare_alias_to_type {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_declare_alias_to_type', @args)
}

sub _lower_assign_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_assign_statement', @args)
}

sub _lower_scalar_assignment_operator_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_scalar_assignment_operator_statement', @args)
}

sub _lower_array_append_operator_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_array_append_operator_statement', @args)
}

sub _parse_array_end_mutation_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_parse_array_end_mutation_method_statement', @args)
}

sub _lower_array_end_mutation_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_array_end_mutation_method_statement', @args)
}

sub _lower_hash_index_assignment_operator_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_hash_index_assignment_operator_statement', @args)
}

sub _parse_hash_index_assignment_operator_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_parse_hash_index_assignment_operator_statement', @args)
}

sub _lower_set_key_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_set_key_statement', @args)
}

sub _lower_method_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_method_value_expr', @args)
}

sub _lower_dropped_value_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_dropped_value_statement', @args)
}

sub _infer_direct_shape_literal_sigil {
 my ($expr) = @_;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed) >= 2;
 my $open = substr($trimmed, 0, 1);
 my $close = $open eq '[' ? ']' : $open eq '{' ? '}' : undef;
 return undef unless defined($close) && substr($trimmed, -1, 1) eq $close;
 my $lowered = _lower_method_value_expr($trimmed);
 return undef unless defined($lowered) && length($lowered);
 return '@' if $open eq '[' && $lowered =~ /^\[.*\]$/s;
 return '%' if $open eq '{' && $lowered =~ /^\{.*\}$/s;
 return undef
}

sub _bare_symbol_kind {
 my ($name) = @_;
 return undef unless defined($name) && length($name);
 return undef unless ref($__ls_current_bare_type_memory) eq 'HASH';
 return $__ls_current_bare_type_memory->{$name}
}

sub _bare_symbol_kind_from_sigil {
 my ($sigil) = @_;
 return 'array' if defined($sigil) && $sigil eq '@';
 return 'hash' if defined($sigil) && $sigil eq '%';
 return 'scalar' if defined($sigil) && $sigil eq '$';
 return undef
}

sub _bare_symbol_kind_from_decl_type {
 my ($type) = @_;
 return undef unless defined($type) && length($type);
 return 'array' if $type =~ /^(?:array|a)$/o;
 return 'hash' if $type =~ /^(?:hash|h)$/o;
 return 'scalar' if $type =~ /^(?:scalar|s)$/o;
 return undef
}

sub _bare_symbol_kind_from_target_expr {
 my ($target_expr, $source_expr) = @_;
 my $target = _trim_action_ir_value($target_expr);
 return unless defined($target) && length($target);
 return ($1, 'scalar') if $target =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o;
 return ($1, 'array') if $target =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;
 return ($1, 'hash') if $target =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;
 return unless $target =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o;
 my $name = $1;
 my $source_sigil = _infer_direct_shape_literal_sigil($source_expr);
 return ($name, _bare_symbol_kind_from_sigil($source_sigil) // 'scalar')
}

sub _bare_type_memory_reserved_name {
 my ($name) = @_;
 return 0 unless defined($name) && length($name);
 state $reserved = { map { $_ => 1 } qw(
  undef true false
  descr STRING info minfo
  IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS
  LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS
  CAPTURE
 ) };
 return $reserved->{$name} ? 1 : 0
}

sub _collect_bare_identifier_type_memory {
 my ($rule_ir) = @_;
 return {} unless ref($rule_ir) eq 'HASH';

 my @raw_blocks;
 my $code_blocks = (ref($rule_ir->{code_blocks}) eq 'HASH') ? $rule_ir->{code_blocks} : {};
 for my $key (qw(ICODE ECODE EXCODE ITCODE LXCODE LSCODE LECODE)) {
  push @raw_blocks, @{$code_blocks->{$key} || []};
 }
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{acode_entries} || []};
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{bcode_entries} || []};
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{and_icode_entries} || []};

 my %kind_by_name;
 my $record = sub {
  my ($name, $kind) = @_;
  return unless defined($name) && $name =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  return unless defined($kind) && $kind =~ /^(?:scalar|array|hash)$/o;
  return if _bare_type_memory_reserved_name($name);
  $kind_by_name{$name} = $kind;
 };

 for my $block (@raw_blocks) {
  next unless defined($block) && length($block);
  for my $statement (@{_split_action_ir_statements($block)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);

   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\+=\s*/s) {
    $record->($1, 'array');
    next;
   }
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\[/s) {
    $record->($1, 'hash');
    next;
   }
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=|>)\s*(.+)$/s) {
    my ($name, $kind) = _bare_symbol_kind_from_target_expr($1, $2);
    $record->($name, $kind);
    next;
   }
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*(?:push_back|push_front|pop_back|pop_front)\s*\(/s) {
    $record->($1, 'array');
    next;
   }

   my $call = _parse_method_function_expr($trimmed);
   next unless $call;
   my $method = $call->{method} // '';
   my $args = $call->{args} || [];
   next unless ref($args) eq 'ARRAY';

   if ($method eq 'declare') {
    my $type = _trim_action_ir_value($args->[0]);
    my $kind = _bare_symbol_kind_from_decl_type($type);
    next unless defined($kind);
    for my $arg (@{$args}[1 .. $#$args]) {
     my $name = _trim_action_ir_value($arg);
     $record->($name, $kind);
    }
   next;
  }
  if ($method =~ /^declare_(?:s|scalar|a|array|h|hash)$/o) {
    my $decl_type = $method;
    $decl_type =~ s/^declare_//o;
    my $kind = _bare_symbol_kind_from_decl_type($decl_type);
    next unless defined($kind);
    for my $arg (@$args) {
     my $name = _trim_action_ir_value($arg);
     $record->($name, $kind);
    }
    next;
   }
   if ($method eq 'assign' && $trimmed =~ /^\s*set\s*\(/o && @$args >= 2) {
    my ($name, $kind) = _bare_symbol_kind_from_target_expr($args->[0], $args->[1]);
    $record->($name, $kind);
    next;
   }
   if (($method eq 'push' || $method eq 'push_value' || $method eq 'push_nonempty' || $method eq 'split') && @$args) {
    my $target = _trim_action_ir_value($args->[0]);
    if (defined($target) && $target =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
     $record->($1, 'array');
    } elsif (defined($target) && $target =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
     $record->($1, 'array');
    }
    next;
   }
   if ($method eq 'set_key' && @$args) {
    my $target = _trim_action_ir_value($args->[0]);
    if (defined($target) && $target =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
     $record->($1, 'hash');
    } elsif (defined($target) && $target =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
     $record->($1, 'hash');
    }
    next;
   }
  }
 }

 return \%kind_by_name
}

sub _lower_return_general_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_general_statement', @args)
}

sub _lower_push_value_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_push_value_statement', @args)
}

sub _lower_push_nonempty_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_push_nonempty_statement', @args)
}

sub _lower_regex_subst_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_regex_subst_statement', @args)
}

sub _lower_return_undef_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_undef_statement', @args)
}

1;

sub _extract_declare_statement_from_method_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_extract_declare_statement_from_method_expr', @args)
}

sub _lower_declare_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_method_statement', @args)
}

sub _lower_assign_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_assign_method_statement', @args)
}

sub _build_array_pipeline_plan_from_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('array_pipeline', '_build_array_pipeline_plan_from_expr', @args)
}

sub _lower_array_pipeline_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('array_pipeline', '_lower_array_pipeline_expr', @args)
}

sub _lower_if_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_if_flow_statement', @args)
}

sub _lower_elseif_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_elseif_flow_statement', @args)
}

sub _lower_else_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_else_flow_statement', @args)
}

sub _lower_endif_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endif_flow_statement', @args)
}

sub _lower_while_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_while_flow_statement', @args)
}

sub _lower_switch_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_switch_flow_statement', @args)
}

sub _lower_case_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_case_flow_statement', @args)
}

sub _lower_default_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_default_flow_statement', @args)
}

sub _lower_endcase_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endcase_flow_statement', @args)
}

sub _lower_endswitch_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endswitch_flow_statement', @args)
}

sub _lower_say_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_say_statement', @args)
}

sub _lower_print_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_print_statement', @args)
}

sub _lower_print_each_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_print_each_statement', @args)
}

sub _normalize_method_tag_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_normalize_method_tag_expr', @args)
}

sub _build_action_lowering_contracts {
 my ($label) = @_;
 return _call_actionir_owner_with_deps('contracts', 'build_action_lowering_contracts', $label)
}

sub _scan_contract_ir_events {
 my @args = @_;
 return _call_actionir_owner_with_deps('scanner', 'scan_contract_ir_events', @args)
}

sub _find_unresolved_action_helpers {
 my @args = @_;
 return _call_actionir_owner_with_deps('diagnostics', '_find_unresolved_action_helpers', @args)
}

sub _collect_action_helper_ir_nodes {
 my @args = @_;
 return _call_actionir_owner_with_deps('diagnostics', '_collect_action_helper_ir_nodes', @args)
}

sub _build_canonical_action_ir_events {
 my @args = @_;
 return _call_actionir_owner_with_deps('canonical_events', '_build_canonical_action_ir_events', @args)
}

sub _canonicalize_helper_action_ir_event {
 my @args = @_;
 return _call_actionir_owner_with_deps('canonical_events', '_canonicalize_helper_action_ir_event', @args)
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;
 my $scope = _trace_emit_context_enter(
  'rewrite_action_code_with_diagnostics',
  $label,
  {
   label => $label,
   code_len => defined($code) ? length($code) : 0,
   rewrite_rule_count => ref($rewrite_rules) eq 'ARRAY' ? scalar(@$rewrite_rules) : 0,
   rewrite_rules_supplied => ref($rewrite_rules) eq 'ARRAY' ? 1 : 0,
  },
 );
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = _call_actionir_owner_with_deps('rewrite_pipeline', '_rewrite_action_code_with_diagnostics', $label, $code, $rewrite_rules);
  my $diag = $ret[1];
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_with_diagnostics',
   label => $label,
   decision => 'canonical_raw_perl_fallback',
   taken => ref($diag) eq 'HASH' && ($diag->{canonical_action_ir_fallback_count} || 0) > 0,
   context => {
    fallback_count => ref($diag) eq 'HASH' ? ($diag->{canonical_action_ir_fallback_count} || 0) : 0,
    unresolved_helper_count => ref($diag) eq 'HASH' ? ($diag->{unresolved_helper_count} || 0) : 0,
    helper_action_ir_count => ref($diag) eq 'HASH' ? ($diag->{helper_action_ir_count} || 0) : 0,
    canonical_action_ir_count => ref($diag) eq 'HASH' ? ($diag->{canonical_action_ir_count} || 0) : 0,
   },
  );
  _trace_emit_context_exit(
   $scope,
   {
    status => 'ok',
    label => $label,
    return_count => scalar(@ret),
    rewritten_len => defined($ret[0]) ? length($ret[0]) : 0,
   },
  );
  return @ret
 }
 if (defined $wantarray) {
  my $ret = _call_actionir_owner_with_deps('rewrite_pipeline', '_rewrite_action_code_with_diagnostics', $label, $code, $rewrite_rules);
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_with_diagnostics',
   label => $label,
   decision => 'canonical_raw_perl_fallback',
   taken => ref($ret) eq 'HASH' && ($ret->{canonical_action_ir_fallback_count} || 0) > 0,
   context => {
    fallback_count => ref($ret) eq 'HASH' ? ($ret->{canonical_action_ir_fallback_count} || 0) : 0,
    unresolved_helper_count => ref($ret) eq 'HASH' ? ($ret->{unresolved_helper_count} || 0) : 0,
    helper_action_ir_count => ref($ret) eq 'HASH' ? ($ret->{helper_action_ir_count} || 0) : 0,
    canonical_action_ir_count => ref($ret) eq 'HASH' ? ($ret->{canonical_action_ir_count} || 0) : 0,
   },
  );
  _trace_emit_context_exit(
   $scope,
   {
    status => 'ok',
    label => $label,
    return_ref => ref($ret) || '',
   },
  );
  return $ret
 }
 _call_actionir_owner_with_deps('rewrite_pipeline', '_rewrite_action_code_with_diagnostics', $label, $code, $rewrite_rules);
 _trace_emit_context_exit(
  $scope,
  {
   status => 'ok',
   label => $label,
   context => 'void',
  },
 );
 return
}

sub _accumulate_action_rewrite_diagnostics {
 my @args = @_;
 return _call_actionir_owner('diagnostics', '_accumulate_action_rewrite_diagnostics', @args)
}

sub _lower_action_code_from_canonical_ir {
 my @args = @_;
 return _call_actionir_owner('rewrite_pipeline', '_lower_action_code_from_canonical_ir', @args)
}

sub _build_action_rewrite_rules {
 my @args = @_;
 return _call_actionir_owner_with_deps('rewrite_pipeline', '_build_action_rewrite_rules', @args)
}

# Compatibility rewriter entry point. Runs the canonical rewrite pipeline and falls
# back to direct value-expr lowering for bare canonical wrapper calls that no contract
# recognizes (these are malformed as standalone statements — value accessors belong
# inside value-returning contracts — but historically tolerated).
sub rewrite_action_code_for_compat {
 my ($label, $code) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $scope = _trace_emit_context_enter(
   'rewrite_action_code_for_compat',
   $label,
   {
    label => $label,
    code_len => defined($code) ? length($code) : 0,
   },
  );
  my $compat_rule_ir = {
   label => $label,
   code_blocks => {},
   acode_entries => [{ code => $code }],
   bcode_entries => [],
   and_icode_entries => [],
  };
  my $compat_bare_type_memory = _collect_bare_identifier_type_memory($compat_rule_ir);
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_for_compat',
   label => $label,
   decision => 'compat_bare_type_memory',
   taken => ref($compat_bare_type_memory) eq 'HASH',
   context => {
    bare_type_memory_count => ref($compat_bare_type_memory) eq 'HASH'
     ? scalar(keys %$compat_bare_type_memory)
     : 0,
   },
  );
  local $__ls_current_bare_type_memory = $compat_bare_type_memory;
  my $trimmed = _trim_action_ir_value($code);
  if (defined($trimmed) && $trimmed =~ /^:[A-Za-z_][A-Za-z0-9_]*$/o) {
   my $lowered = _lower_method_value_expr($trimmed);
   if (defined($lowered) && length($lowered)) {
    _trace_emit_context_decision(
     phase => 'rewrite_action_code_for_compat',
     label => $label,
     decision => 'scalar_slot_fallback',
     taken => 1,
     context => {
      raw => $trimmed,
      lowered => $lowered,
     },
    );
    _trace_emit_context_exit(
     $scope,
     { status => 'ok', label => $label, path => 'scalar_slot_fallback', rewritten_len => length($lowered) },
    );
    return $lowered
   }
  }
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_for_compat',
   label => $label,
   decision => 'scalar_slot_fallback',
   taken => 0,
   context => {
    raw => defined($trimmed) ? $trimmed : '<undef>',
   },
  );
  if (
   defined($trimmed) &&
   length($trimmed) &&
   $trimmed =~ /^(?:array|hash)\s*\(/o
  ) {
   my $call = _parse_method_function_expr($trimmed);
   if ($call && ($call->{method} // '') =~ /^(?:array|hash)$/o) {
    my $lowered = _lower_method_value_expr($trimmed);
    if (defined($lowered) && length($lowered)) {
     _trace_emit_context_decision(
      phase => 'rewrite_action_code_for_compat',
      label => $label,
      decision => 'aggregate_wrapper_fallback',
      taken => 1,
      context => {
       raw => $trimmed,
       lowered => $lowered,
       method => $call->{method},
      },
     );
     _trace_emit_context_exit(
      $scope,
      { status => 'ok', label => $label, path => 'aggregate_wrapper_fallback', rewritten_len => length($lowered) },
     );
     return $lowered
    }
   }
  }
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_for_compat',
   label => $label,
   decision => 'aggregate_wrapper_fallback',
   taken => 0,
   context => {
    raw => defined($trimmed) ? $trimmed : '<undef>',
   },
  );
  my ($rewritten) = _rewrite_action_code_with_diagnostics($label, $code, undef);
  _trace_emit_context_decision(
   phase => 'rewrite_action_code_for_compat',
   label => $label,
   decision => 'canonical_rewrite_pipeline',
   taken => 1,
   context => {
    raw_len => defined($code) ? length($code) : 0,
    rewritten_len => defined($rewritten) ? length($rewritten) : 0,
   },
  );
  _trace_emit_context_exit(
   $scope,
   { status => 'ok', label => $label, path => 'canonical_rewrite_pipeline', rewritten_len => defined($rewritten) ? length($rewritten) : 0 },
  );
  return $rewritten
 })
}

sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten = _preserve_terminal_block_statement_separator($chunk, $rewritten);
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

sub _rewrite_acode_entries {
 my ($label, $acode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @ACODEs;
 my @dependency_refs;
 foreach my $acode_entry (@$acode_entries) {
  my ($rewritten_acode, $diag) = _rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @dependency_refs, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 return (\@ACODEs, \@dependency_refs)
}

sub _rewrite_bcode_entries {
 my ($label, $bcode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @BCALLs;
 my %BCODEs;
 foreach my $bcode_entry (@$bcode_entries) {
  my ($rewritten_bcode, $diag) = _rewrite_action_code_with_diagnostics($label, $bcode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @BCALLs, $bcode_entry->{call};
  $BCODEs{$bcode_entry->{call}} = $rewritten_bcode;
 }

 return (\@BCALLs, \%BCODEs)
}

sub _normalize_rule_lifecycle_code {
 my ($label, $code_blocks, $rewrite_diag_acc, $rewrite_rules) = @_;
 return {
  icode  => _normalize_rule_code_chunks($label, $code_blocks->{ICODE},  $rewrite_diag_acc, $rewrite_rules),
  ecode  => _normalize_rule_code_chunks($label, $code_blocks->{ECODE},  $rewrite_diag_acc, $rewrite_rules),
  excode => _normalize_rule_code_chunks($label, $code_blocks->{EXCODE}, $rewrite_diag_acc, $rewrite_rules),
  itcode => _normalize_rule_code_chunks($label, $code_blocks->{ITCODE}, $rewrite_diag_acc, $rewrite_rules),
  lxcode => _normalize_rule_code_chunks($label, $code_blocks->{LXCODE}, $rewrite_diag_acc, $rewrite_rules),
  lscode => _normalize_rule_code_chunks($label, $code_blocks->{LSCODE}, $rewrite_diag_acc, $rewrite_rules),
  lecode => _normalize_rule_code_chunks($label, $code_blocks->{LECODE}, $rewrite_diag_acc, $rewrite_rules),
 }
}

sub _collect_unresolved_helper_statements {
 my ($rewrite_diag_acc) = @_;

 my @unresolved_helper_statements;
 my %seen_unresolved_helper_statement;
 foreach my $event (@{$rewrite_diag_acc->{unresolved_helper_events}}) {
  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_unresolved_helper_statement{$raw_code}++;
  push @unresolved_helper_statements, $raw_code;
 }
 return @unresolved_helper_statements
}

sub _collect_raw_perl_dependency_statements {
 my ($rewrite_diag_acc) = @_;

 my @raw_perl_dependency_statements;
 my %seen_raw_perl_dependency_statement;
 foreach my $event (@{$rewrite_diag_acc->{canonical_action_ir_events}}) {
  next unless ($event->{kind} // '') eq 'RAW_PERL';
  my $raw_code = (ref($event->{args}) eq 'HASH') ? $event->{args}{code} : $event->{raw};
  $raw_code = _trim_action_ir_value($raw_code);
  next unless defined($raw_code) && length($raw_code);
  next if $seen_raw_perl_dependency_statement{$raw_code}++;
  push @raw_perl_dependency_statements, $raw_code;
 }
 return @raw_perl_dependency_statements
}

sub _build_compatibility_surface_diag {
 my ($rewrite_rules, $rewrite_diag_acc) = @_;

 my %compatibility_contract_ids = map {
  my $id = $_->{id};
  defined($id) && length($id) ? ($id => 1) : ()
 } grep { $_->{compatibility_surface} } @$rewrite_rules;

 my %compatibility_surface_hits;
 my @compatibility_surface_events;
 my @compatibility_surface_statements;
 my %seen_compatibility_surface_statement;

 foreach my $event (@{$rewrite_diag_acc->{helper_action_ir_events}}) {
  my $contract_id = $event->{contract_id} // '';
  next unless length($contract_id) && $compatibility_contract_ids{$contract_id};

  push @compatibility_surface_events, $event;
  ++$compatibility_surface_hits{$contract_id};

  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_compatibility_surface_statement{$raw_code}++;
  push @compatibility_surface_statements, $raw_code;
 }

 my @compatibility_surface_contract_ids = sort keys %compatibility_surface_hits;
 return {
  compatibility_surface_count => scalar(@compatibility_surface_events),
  compatibility_surface_contract_ids => \@compatibility_surface_contract_ids,
  compatibility_surface_hits => \%compatibility_surface_hits,
  compatibility_surface_events => [@compatibility_surface_events],
  compatibility_surface_statement_count => scalar(@compatibility_surface_statements),
  compatibility_surface_statements => \@compatibility_surface_statements,
 };
}

sub _build_language_agnostic_blocker_statements {
 my ($raw_perl_dependency_statements, $unresolved_helper_statements) = @_;

 my @language_agnostic_action_ir_blocker_statements;
 my %seen_language_agnostic_action_ir_blocker_statement;
 foreach my $statement (@$raw_perl_dependency_statements, @$unresolved_helper_statements) {
  next unless defined($statement) && length($statement);
  next if $seen_language_agnostic_action_ir_blocker_statement{$statement}++;
  push @language_agnostic_action_ir_blocker_statements, $statement;
 }
 return @language_agnostic_action_ir_blocker_statements
}

sub _build_action_rewriter_meta {
 my ($label, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @rewrite_contract_ids = map { $_->{id} } @$rewrite_rules;
 my @unresolved_helper_statements = _collect_unresolved_helper_statements($rewrite_diag_acc);
 my @raw_perl_dependency_statements = _collect_raw_perl_dependency_statements($rewrite_diag_acc);
 my $raw_perl_dependency_count = $rewrite_diag_acc->{canonical_action_ir_fallback_count} || 0;
 my @language_agnostic_action_ir_blocker_statements = _build_language_agnostic_blocker_statements(
 \@raw_perl_dependency_statements,
  \@unresolved_helper_statements,
 );
 my $compatibility_surface_diag = _build_compatibility_surface_diag($rewrite_rules, $rewrite_diag_acc);
 my $language_agnostic_action_ir_blocker_statement_count = scalar @language_agnostic_action_ir_blocker_statements;
 my $language_agnostic_action_ir_ready = (
  $raw_perl_dependency_count == 0 &&
  ($rewrite_diag_acc->{unresolved_helper_count} || 0) == 0
 ) ? 1 : 0;

 my $action_rewriter_meta = {
  unresolved_helper_count => $rewrite_diag_acc->{unresolved_helper_count},
  unresolved_helpers      => [sort keys %{$rewrite_diag_acc->{unresolved_helper_hits}}],
  unresolved_helper_hits  => {%{$rewrite_diag_acc->{unresolved_helper_hits}}},
  unresolved_helper_events => [@{$rewrite_diag_acc->{unresolved_helper_events}}],
  unresolved_helper_statements => \@unresolved_helper_statements,
  helper_action_ir_count  => $rewrite_diag_acc->{helper_action_ir_count},
  helper_action_ir_nodes  => [sort keys %{$rewrite_diag_acc->{helper_action_ir_hits}}],
  helper_action_ir_hits   => {%{$rewrite_diag_acc->{helper_action_ir_hits}}},
  helper_action_ir_events => [@{$rewrite_diag_acc->{helper_action_ir_events}}],
  canonical_action_ir_count => $rewrite_diag_acc->{canonical_action_ir_count},
  canonical_action_ir_nodes => [sort keys %{$rewrite_diag_acc->{canonical_action_ir_hits}}],
  canonical_action_ir_hits  => {%{$rewrite_diag_acc->{canonical_action_ir_hits}}},
  canonical_action_ir_events => [@{$rewrite_diag_acc->{canonical_action_ir_events}}],
  canonical_action_ir_fallback_count => $rewrite_diag_acc->{canonical_action_ir_fallback_count},
  raw_perl_dependency_count => $raw_perl_dependency_count,
  raw_perl_dependency_statements => \@raw_perl_dependency_statements,
  compatibility_surface_count => $compatibility_surface_diag->{compatibility_surface_count},
  compatibility_surface_contract_ids => [@{$compatibility_surface_diag->{compatibility_surface_contract_ids}}],
  compatibility_surface_hits => {%{$compatibility_surface_diag->{compatibility_surface_hits}}},
  compatibility_surface_events => [@{$compatibility_surface_diag->{compatibility_surface_events}}],
  compatibility_surface_statement_count => $compatibility_surface_diag->{compatibility_surface_statement_count},
  compatibility_surface_statements => [@{$compatibility_surface_diag->{compatibility_surface_statements}}],
  language_agnostic_action_ir_blocker_statement_count => $language_agnostic_action_ir_blocker_statement_count,
  language_agnostic_action_ir_blocker_statements => \@language_agnostic_action_ir_blocker_statements,
  language_agnostic_action_ir_ready => $language_agnostic_action_ir_ready,
  rewrite_contract_ids    => \@rewrite_contract_ids,
 };

 if ($action_rewriter_meta->{unresolved_helper_count}) {
  _trace_log_output(
   DUMP_LOW,
   "Rule '$label': unresolved action helper(s) after rewrite pipeline",
   "helpers=" . join(', ', @{$action_rewriter_meta->{unresolved_helpers}})
  );
 }

 return $action_rewriter_meta
}

# Wrapper-helper -> Perl sigil for auto-existing working variables (SPEC-FORMAT-TERSE.1.1.1).
# scalar -> $, array -> @, hash -> %. Used for the WRAPPED-form references; the
# sigil is taken from the wrapper. Bare (un-wrapped) names in type-implying helper arg
# positions take a POSITION-implied sigil instead — SPEC-FORMAT-TERSE.1.2.1, Channel 1.
# Bare aggregate value reads take their lowering-implied sigil — SPEC-FORMAT-TERSE.1.2.3.1,
# Channel 2 aggregate subset. Full scalar RHS-shape / value-position bare-word inference is a
# later Channel 2 leaf, not these.
my %AUTO_WORKING_VAR_WRAPPER_SIGIL = (
 scalar => '$',
 array  => '@',
 hash   => '%',
);

# Names that must NEVER be auto-declared as working variables. Two groups:
#  (1) DSL literals — `array(undef)` is the array constructor wrapping the
#      undef literal, NOT a reference to a variable named "undef" (likewise true/false).
#  (2) Engine-reserved handler locals declared by the preamble template
#      (_build_handler_preamble) and the variant scaffolding ($descr/$STRING/$info, the
#      $IMATCH*/$IPOS/$IINDEX set, the per-iteration $minfo/$LMATCH*/$LSPOS/$LINDEX set,
#      and the CAPTURE source token). These are declared outside the action code this
#      collector scans, so injecting a `my` for them would double-declare. Case-sensitive.
my %AUTO_WORKING_VAR_RESERVED = map { $_ => 1 } qw(
 undef true false
 descr STRING info minfo
 IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS
 LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS
 CAPTURE
);

#------------------------------------------------------------------------------
# Function: _mask_action_code_literals
# Purpose : Blank the *contents* of single-quoted, double-quoted, and /regex/
#           literals (keeping the delimiters, length, and newlines) so a literal
#           that happens to contain wrapper-call-looking text (e.g. a string
#           "... s(x) ...") cannot produce a spurious working-variable collection.
#           An unmatched delimiter is treated as an ordinary character (no runaway
#           masking). The rule's regex `re` slots are never scanned, so this only
#           guards literals embedded inside action code.
# Args    : ($code)
# Returns : masked code string
#------------------------------------------------------------------------------
sub _mask_action_code_literals {
 my ($code) = @_;
 return '' unless defined $code;
 my $len = length $code;
 my $out = '';
 my $i = 0;
 while ($i < $len) {
  my $ch = substr($code, $i, 1);
  if ($ch eq '"' || $ch eq "'" || $ch eq '/') {
   # Look ahead for the matching close, honoring backslash escapes.
   my $j = $i + 1;
   my $found = -1;
   while ($j < $len) {
    my $c = substr($code, $j, 1);
    if ($c eq '\\') { $j += 2; next; }
    if ($c eq $ch) { $found = $j; last; }
    ++$j;
   }
   if ($found >= 0) {
    my $inner = substr($code, $i + 1, $found - $i - 1);
    $inner =~ s/[^\n]/ /g;   # blank content, preserve newlines (and length)
    $out .= $ch . $inner . $ch;
    $i = $found + 1;
    next;
   }
   # No closing delimiter: treat the opener as an ordinary character.
   $out .= $ch;
   ++$i;
   next;
  }
  $out .= $ch;
  ++$i;
 }
 return $out
}

#------------------------------------------------------------------------------
# Function: _collect_auto_working_var_decls
# Purpose : Auto-existing working variables. Scan every RAW (pre-lowering)
#           action-code block of a rule for working-variable references and return
#           the preamble `my $NAME`/`@NAME`/`%NAME` declarations the engine must
#           supply so each variable is a per-invocation lexical rather than a leaky
#           package global (generated handlers are non-strict — see KM card
#           working-vars-no-strict-need-my-lexical). Three reference forms are collected:
#             (a) SPEC-FORMAT-TERSE.1.1.1 — WRAPPED aggregate-wrapper refs
#                 array(NAME)/hash(NAME) with a single bare-identifier argument.
#                 Sigil taken from the wrapper. Scalar slots now use `:NAME`.
#             (b) SPEC-FORMAT-TERSE.1.2.1, Channel 1 — BARE (un-wrapped) names in a
#                 type-implying helper arg position: the scalar/array/hash target
#                 of set(NAME, VALUE) depending on direct RHS shape
#                 inference, the hash target of statement-level
#                 set_key(NAME, KEY, VALUE), and the array target of push_value(NAME, ...) /
#                 push(NAME, nonbare-value) / push_nonempty(NAME, ...). Such a bare name already LOWERS to the
#                 correctly-sigil'd variable but otherwise gets no `my` (leaky global).
#                 Sigil implied by the position ($ for non-shape set, @/% for
#                 direct []/{} set RHS shapes, @ for the push family).
#                 The child-append push(Rule[, target]) / fluent .push(target) target
#                 (all-bare child-call shape) and bare hash value-position reads
#                 are deliberately NOT collected here.
#             (c) SPEC-FORMAT-TERSE.1.2.3.1, Channel 2 aggregate subset — BARE
#                 aggregate value reads that already lower to a sigiled aggregate:
#                 array_copy(NAME) / copy(NAME) -> @NAME and hash_copy(NAME) -> %NAME.
#             (d) SPEC-FORMAT-TERSE.1.2.3.3.1, Channel 2 scalar source-slot subset —
#                 BARE scalar reads in return/assignment-like source slots:
#                 return(NAME), set(out, NAME), and `out = NAME` -> $NAME.
#             (e) SPEC-FORMAT-TERSE.1.2.3.3.2, Channel 2 mutation key/RHS subset —
#                 BARE scalar reads in mutation slots:
#                 items += VALUE, set_key(meta, KEY, VALUE), and meta[KEY] = VALUE.
#             (f) SPEC-FORMAT-TERSE.1.2.3.3.3, Channel 2 direct-access subset —
#                 BARE path atoms in accepted direct access value slots:
#                 foo["a"][INDEX] -> $foo->{"a"}->[$INDEX].
#             (g) SPEC-FORMAT-TERSE.1.2.3.5.1, Channel 2 shape-literal subset —
#                 BARE scalar reads directly inside accepted [] / {} value literals:
#                 [VALUE] -> [$VALUE], { KEY => VALUE } -> {$KEY => $VALUE}.
#             (h) SPEC-FORMAT-TERSE.1.2.3.5.2, Channel 2 RHS-shape subset —
#                 BARE assignment targets infer @/% from direct [] / {} RHS
#                 literals: NAME = [VALUE] -> @NAME, NAME = {KEY => VALUE} -> %NAME.
#             (i) SPEC-FORMAT-TERSE.1.6 — receiver-dot array end mutations:
#                 NAME.push_back(VALUE), NAME.push_front(VALUE), NAME.pop_back(), NAME.pop_front().
#             (j) SPEC-FORMAT-TERSE.2.3.4.2 — inline value-control payloads:
#                 return(if(...)) / set(out, switch(...)) branches recurse through the
#                 same scalar-read, shape-literal, direct-access, and block-value discovery.
#           Deduped against (1) the per-rule accumulator @<label> and (2) any name
#           already declared with the same sigil in the LOWERED handler code
#           (declare(...) or raw `my`), so a spec that already declares/wraps its
#           working vars emits byte-identical generated source (no double `my`).
# Args    : ($rule_ir, $lowered_text)  # $lowered_text = concatenated lowered code
# Returns : arrayref of "my <sigil><name>;" declaration strings (possibly empty)
#------------------------------------------------------------------------------
sub _collect_auto_working_var_decls {
 my ($rule_ir, $lowered_text) = @_;
 return [] unless ref($rule_ir) eq 'HASH';
 my $label = defined($rule_ir->{label}) ? $rule_ir->{label} : '';

 # Gather every RAW action-code block of the rule (NOT the regex `re` slots).
 my @raw_blocks;
 my $code_blocks = (ref($rule_ir->{code_blocks}) eq 'HASH') ? $rule_ir->{code_blocks} : {};
 for my $key (qw(ICODE ECODE EXCODE ITCODE LXCODE LSCODE LECODE)) {
  push @raw_blocks, @{$code_blocks->{$key} || []};
 }
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{acode_entries} || []};
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{bcode_entries} || []};
 push @raw_blocks, map { (ref($_) eq 'HASH') ? $_->{code} : () } @{$rule_ir->{and_icode_entries} || []};

 # Collect ordered-unique (sigil, name) working-variable references from the
 # literal-masked code. $record adds one ref, skipping DSL literals / engine-reserved
 # locals and de-duplicating by sigil+name.
 my @collected;
 my %seen;
 my $record = sub {
  my ($sigil, $name) = @_;
  return unless defined($sigil) && defined($name);
  return if $AUTO_WORKING_VAR_RESERVED{$name};   # DSL literal or engine-reserved local
  my $dedup_key = $sigil . $name;
  return if $seen{$dedup_key}++;
  push @collected, { sigil => $sigil, name => $name };
 };
 my $record_scalar_slot_read = sub {
  my ($expr) = @_;
  my $value = _trim_action_ir_value($expr);
  return 0 unless defined($value) && $value =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o;
  $record->('$', $1);
  return 1;
 };
 my $record_direct_access_bare_path_atoms = sub {
  my ($expr) = @_;
  my $trimmed = _trim_action_ir_value($expr);
  return unless defined($trimmed) && length($trimmed);
  my $lowered_direct = _lower_direct_nested_access_value_expr($trimmed);
  return unless defined($lowered_direct) && length($lowered_direct);
  return unless $trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*\s*(\[.*)$/s;
  my $segments = _split_nested_access_path_segments($1);
  return unless $segments && @$segments;
  for my $segment (@$segments) {
   next unless ($segment->{kind} // '') eq 'index';
   my $atom = _trim_action_ir_value($segment->{expr});
   $record->('$', $atom) if defined($atom) && $atom =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  }
 };
 my (
  $collect_shape_literal_scalar_reads,
  $collect_shape_member_scalar_reads,
  $collect_block_value_scalar_reads,
  $collect_inline_control_value_scalar_reads,
  $collect_value_position_scalar_reads,
  $collect_flow_expr_scalar_reads,
  $collect_ast_value_refs,
 );
 my $split_top_level_fat_arrow = sub {
  my ($text) = @_;
  return undef unless defined $text;

  my ($paren_depth, $brace_depth, $bracket_depth) = (0, 0, 0);
  my ($in_single_quote, $in_double_quote, $escape_next) = (0, 0, 0);
  my $len = length($text);
  for (my $idx = 0; $idx < $len - 1; ++$idx) {
   my $char = substr($text, $idx, 1);
   if ($in_single_quote) {
    if ($escape_next) { $escape_next = 0; }
    elsif ($char eq '\\') { $escape_next = 1; }
    elsif ($char eq "'") { $in_single_quote = 0; }
    next;
   }
   if ($in_double_quote) {
    if ($escape_next) { $escape_next = 0; }
    elsif ($char eq '\\') { $escape_next = 1; }
    elsif ($char eq '"') { $in_double_quote = 0; }
    next;
   }
   if ($char eq "'") { $in_single_quote = 1; next; }
   if ($char eq '"') { $in_double_quote = 1; next; }
   if ($char eq '(') { ++$paren_depth; next; }
   if ($char eq ')') { --$paren_depth if $paren_depth > 0; next; }
   if ($char eq '{') { ++$brace_depth; next; }
   if ($char eq '}') { --$brace_depth if $brace_depth > 0; next; }
   if ($char eq '[') { ++$bracket_depth; next; }
   if ($char eq ']') { --$bracket_depth if $bracket_depth > 0; next; }
   next unless $char eq '=' && substr($text, $idx + 1, 1) eq '>';
   next unless $paren_depth == 0 && $brace_depth == 0 && $bracket_depth == 0;
   my $lhs = _trim_action_ir_value(substr($text, 0, $idx));
   my $rhs = _trim_action_ir_value(substr($text, $idx + 2));
   return undef unless defined($lhs) && length($lhs);
   return undef unless defined($rhs) && length($rhs);
   return [$lhs, $rhs];
  }
  return undef;
 };
 $collect_shape_member_scalar_reads = sub {
  my ($member_expr) = @_;
  my $member = _trim_action_ir_value($member_expr);
  return unless defined($member) && length($member);
  return if $record_scalar_slot_read->($member);
  $record->('$', $member) if $member =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  $record_direct_access_bare_path_atoms->($member);
  $collect_shape_literal_scalar_reads->($member);
  $collect_block_value_scalar_reads->($member);
  $collect_inline_control_value_scalar_reads->($member);
 };
 $collect_shape_literal_scalar_reads = sub {
  my ($shape_expr) = @_;
  my $shape = _trim_action_ir_value($shape_expr);
  return unless defined($shape) && length($shape) >= 2;
  my $open = substr($shape, 0, 1);
  my $close = $open eq '[' ? ']' : $open eq '{' ? '}' : undef;
  return unless defined($close) && substr($shape, -1, 1) eq $close;
  my $lowered_shape = _lower_method_value_expr($shape);
  return unless defined($lowered_shape) && length($lowered_shape);

  my $payload = _trim_action_ir_value(substr($shape, 1, length($shape) - 2));
  return unless defined($payload) && length($payload);
  my $entries = _split_top_level_csv($payload);
  return unless $entries;

  if ($open eq '[') {
   $collect_shape_member_scalar_reads->($_) for @$entries;
   return;
  }

  for my $entry (@$entries) {
   my $pair = $split_top_level_fat_arrow->($entry);
   next unless $pair;
   $collect_shape_member_scalar_reads->($pair->[0]);
   $collect_shape_member_scalar_reads->($pair->[1]);
  }
 };
 $collect_block_value_scalar_reads = sub {
  my ($block_expr) = @_;
  my $block = _trim_action_ir_value($block_expr);
  return unless defined($block) && length($block) >= 2;
  return unless substr($block, 0, 1) eq '{' && substr($block, -1, 1) eq '}';
  my $lowered_block = _lower_method_value_expr($block);
  return unless defined($lowered_block) && $lowered_block =~ /^\s*do\s*\{/s;

  my $payload = _trim_action_ir_value(substr($block, 1, length($block) - 2));
  return unless defined($payload) && length($payload);
  my $statements = _split_action_ir_statements($payload);
  return unless ref($statements) eq 'ARRAY' && @$statements;

  my $last = _trim_action_ir_value($statements->[-1]);
  return unless defined($last) && length($last);
  my $call = _parse_method_function_expr($last);
  if ($call && ($call->{method} // '') eq 'return') {
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   return unless $args;
   $last = _trim_action_ir_value($args->[0]);
   return unless defined($last) && length($last);
  }

  return if $record_scalar_slot_read->($last);
  $record->('$', $last) if $last =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  $record_direct_access_bare_path_atoms->($last);
  $collect_shape_literal_scalar_reads->($last);
  $collect_block_value_scalar_reads->($last);
  $collect_inline_control_value_scalar_reads->($last);
 };
 $collect_value_position_scalar_reads = sub {
  my ($value_expr) = @_;
  my $value = _trim_action_ir_value($value_expr);
  return unless defined($value) && length($value);
  $collect_ast_value_refs->($value) if ref($collect_ast_value_refs) eq 'CODE';
  return if $record_scalar_slot_read->($value);
  $record->('$', $value) if $value =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  $record_direct_access_bare_path_atoms->($value);
  $collect_shape_literal_scalar_reads->($value);
  $collect_block_value_scalar_reads->($value);
  $collect_inline_control_value_scalar_reads->($value);
 };
 $collect_flow_expr_scalar_reads = sub {
  my ($flow_expr) = @_;
  my $flow = _trim_action_ir_value($flow_expr);
  return unless defined($flow) && length($flow);
  my $call = _parse_method_function_expr($flow);
  return unless $call;
  my $method = $call->{method} // '';

  if ($method eq 'and' || $method eq 'or') {
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   return unless $args;
   $collect_flow_expr_scalar_reads->($_) for @$args;
   return;
  }

  if ($method eq 'not') {
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   return unless $args;
   $collect_flow_expr_scalar_reads->($args->[0]);
   return;
  }

  if ($method =~ /^(?:is_empty|is_nonempty|is_defined|is_undefined)$/o) {
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   return unless $args;
   $collect_value_position_scalar_reads->($args->[0]);
   return;
  }
 };
 $collect_inline_control_value_scalar_reads = sub {
  my ($control_expr) = @_;
  my $control = _trim_action_ir_value($control_expr);
  return unless defined($control) && length($control);
  my $call = _parse_method_function_expr($control);
  return unless $call;
  my $method = $call->{method} // '';

  if ($method eq 'if') {
   my $args = $call->{args} || [];
   return unless ref($args) eq 'ARRAY' && @$args >= 2;
   $collect_flow_expr_scalar_reads->($args->[0]);
   $collect_value_position_scalar_reads->($args->[1]);

   for (my $idx = 2; $idx < @$args; ++$idx) {
    my $branch_call = _parse_method_function_expr($args->[$idx]);
    my $branch_method = $branch_call ? ($branch_call->{method} // '') : '';
    if ($branch_method eq 'elseif') {
     my $branch_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 2, 2);
     next unless $branch_args;
     $collect_flow_expr_scalar_reads->($branch_args->[0]);
     $collect_value_position_scalar_reads->($branch_args->[1]);
     next;
    }
    if ($branch_method eq 'else') {
     my $branch_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 1, 1);
     next unless $branch_args;
     $collect_value_position_scalar_reads->($branch_args->[0]);
     next;
    }
    $collect_value_position_scalar_reads->($args->[$idx]);
   }
   return;
  }

  if ($method eq 'switch') {
   my $args = $call->{args} || [];
   return unless ref($args) eq 'ARRAY' && @$args >= 1;
   $collect_value_position_scalar_reads->($args->[0]);
   for my $branch (@{$args}[1 .. $#$args]) {
    my $branch_call = _parse_method_function_expr($branch);
    next unless $branch_call;
    my $branch_method = $branch_call->{method} // '';
    if ($branch_method eq 'case') {
     my $branch_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 2, 2);
     next unless $branch_args;
     $collect_value_position_scalar_reads->($branch_args->[0]);
     $collect_value_position_scalar_reads->($branch_args->[1]);
     next;
    }
    if ($branch_method eq 'default') {
     my $branch_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 1, 1);
     next unless $branch_args;
     $collect_value_position_scalar_reads->($branch_args->[0]);
     next;
    }
   }
   return;
  }
 };
 my $record_assignment_target_for_source = sub {
  my ($target_expr, $source_expr) = @_;
  my $target = _trim_action_ir_value($target_expr);
  return unless defined($target) && length($target);
  if ($target =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
   $record->('$', $1);
   return;
  }
  return unless $target =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  my $source = _trim_action_ir_value($source_expr);
  return unless defined($source) && length($source);
  my $shape_sigil = _infer_direct_shape_literal_sigil($source);
  $record->($shape_sigil // '$', $target);
 };
 my $direct_shape_sigil_for_ast_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $kind = $node->{kind} // '';
  return '@' if $kind eq 'array_literal';
  return '%' if $kind eq 'hash_literal';
  return undef
 };
 my $record_ast_assignment_target = sub {
  my ($target_node, $value_node) = @_;
  return unless ref($target_node) eq 'HASH';
  my $shape_sigil = $direct_shape_sigil_for_ast_node->($value_node);
  my $target_kind = $target_node->{kind} // '';

  if ($target_kind eq 'variable') {
   $record->($shape_sigil // '$', $target_node->{name});
   return;
  }

  return unless $target_kind eq 'call';
  my $target_name = $target_node->{name} // '';
  my $target_args = $target_node->{args} || [];
  return unless ref($target_args) eq 'ARRAY'
             && @$target_args == 1
             && ref($target_args->[0]) eq 'HASH'
             && ($target_args->[0]{kind} // '') eq 'variable';
  my $name = $target_args->[0]{name};
	  if ($target_name eq 'array') {
   return if defined($shape_sigil) && $shape_sigil ne '@';
   $record->('@', $name);
   return;
  }
  if ($target_name eq 'hash') {
   return if defined($shape_sigil) && $shape_sigil ne '%';
   $record->('%', $name);
   return;
  }
 };
 my $parse_ast_value_expr = sub {
  my ($expr) = @_;
  return undef unless defined($expr) && length($expr);
  my $node;
  eval {
   LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST');
   $node = LinkedSpec::ActionIR::AST::parse_action_expr($expr, {});
   1;
  } or return undef;
  return ref($node) eq 'HASH' ? $node : undef
 };
 my $collect_ast_node_refs;
 $collect_ast_node_refs = sub {
  my ($node, $bare_scalar_ok) = @_;
  return unless ref($node) eq 'HASH';
  my $kind = $node->{kind} // '';

  if ($kind eq 'variable') {
   $record->('$', $node->{name}) if $bare_scalar_ok;
   return;
  }

  if ($kind eq 'assign_scalar') {
   $record->($direct_shape_sigil_for_ast_node->($node->{value}) // '$', $node->{name});
   $collect_ast_node_refs->($node->{value}, 1);
   return;
  }

  if ($kind eq 'assign_array_append') {
   $record->('@', $node->{name});
   $collect_ast_node_refs->($node->{value}, 1);
   return;
  }

  if ($kind eq 'assign_hash_index') {
   $record->('%', $node->{name});
   $collect_ast_node_refs->($node->{key}, 1);
   $collect_ast_node_refs->($node->{value}, 1);
   return;
  }

  if ($kind eq 'array_literal') {
   $collect_ast_node_refs->($_, 1) for @{$node->{items} || []};
   return;
  }

  if ($kind eq 'hash_literal') {
   foreach my $entry (@{$node->{entries} || []}) {
    next unless ref($entry) eq 'HASH';
    $collect_ast_node_refs->($entry->{key}, 1);
    $collect_ast_node_refs->($entry->{value}, 1);
   }
   return;
  }

  if ($kind eq 'indexed_var') {
   $record->('%', $node->{name});
   $collect_ast_node_refs->($node->{index}, 1);
   return;
  }

  if ($kind eq 'nested_access') {
   $record->('$', $node->{base});
   foreach my $segment (@{$node->{segments} || []}) {
    next unless ref($segment) eq 'HASH' && ($segment->{kind} // '') eq 'index';
    $collect_ast_node_refs->($segment->{expr}, 1);
   }
   return;
  }

  if ($kind eq 'call') {
   my $name = $node->{name} // '';
   my $args = $node->{args} || [];
	   my $is_assignment_call = ($name eq '=' || $name eq 'set')
	    || ($name eq 'assign' && (($node->{source} // '') !~ /^\s*assign\s*\(/o));
	   if ($is_assignment_call && ref($args) eq 'ARRAY' && @$args == 2) {
    $record_ast_assignment_target->($args->[0], $args->[1]);
    $collect_ast_node_refs->($args->[1], 1);
    return;
   }
	   if (($name eq 'array' || $name eq 'hash')
    && ref($args) eq 'ARRAY'
    && @$args == 1
    && ref($args->[0]) eq 'HASH'
    && ($args->[0]{kind} // '') eq 'variable') {
	    my $sigil = $name eq 'array' ? '@' : '%';
    $record->($sigil, $args->[0]{name});
    return;
   }
   $collect_ast_node_refs->($_, 0) for @$args;
   return;
  }

  if ($kind eq 'fluent_chain') {
   $collect_ast_node_refs->($node->{receiver}, 0);
   foreach my $call (@{$node->{calls} || []}) {
    next unless ref($call) eq 'HASH';
    $collect_ast_node_refs->($_, 0) for @{$call->{args} || []};
   }
   return;
  }

  if ($kind eq 'block_value') {
   my $block = $node->{block};
   return unless ref($block) eq 'HASH';
  foreach my $stmt (@{$block->{statements} || []}) {
   next unless ref($stmt) eq 'HASH';
   $collect_ast_node_refs->($stmt->{expr}, 0);
  }
  return;
 }

 if ($kind eq 'action_stmt') {
  $collect_ast_node_refs->($node->{expr}, 0);
  return;
 }
 };
 $collect_ast_value_refs = sub {
  my ($expr) = @_;
  my $node = $parse_ast_value_expr->($expr);
  $collect_ast_node_refs->($node, 1) if ref($node) eq 'HASH';
 };
 for my $block (@raw_blocks) {
  next unless defined($block) && length($block);
  my $masked = _mask_action_code_literals($block);

	  # (a) SPEC-FORMAT-TERSE.1.1.1 — WRAPPED aggregate-wrapper refs (sigil from the wrapper).
	  while ($masked =~ /\b(array|hash)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)/g) {
	   $record->($AUTO_WORKING_VAR_WRAPPER_SIGIL{$1}, $2);
	  }

  # (b) SPEC-FORMAT-TERSE.1.2.1, Channel 1 — BARE working var in a type-implying helper
  #     arg position. The bare name already lowers to the correctly-sigil'd variable
	  #     (set -> $NAME, or @NAME/%NAME for direct shape RHS inference;
  #     push_value/push/push_nonempty -> @NAME) but otherwise gets no preamble `my`. The
	  #     `\s*,` after the name means a WRAPPED target (array(x), whose name is
  #     followed by `(`) is not matched here — it stays on path (a); both dedup to one `my`.
	  # A bare `set(NAME, ...)` target follows the same source-driven inference as operator
	  # assignment. The scalar assignment
  # operator (`NAME = VALUE`, SPEC-FORMAT-TERSE.1.3.4.1) is likewise statement-level
  # and now infers @/% for direct shape RHS literals. The array append operator
  # (`NAME += VALUE`) and hash-index assignment operator (`NAME[KEY] = VALUE`)
  # are statement-level array/hash mutations; `.1.2.3.3.2` additionally collects
  # the accepted bare scalar key/RHS reads in those mutation slots.
  while ($masked =~ /\b(?:push_value|push_nonempty)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,/g) {
   $record->('@', $1);   # push_value / push_nonempty target lowers to an array
  }
  # (c) SPEC-FORMAT-TERSE.1.2.3.1 / .6.2.3.2, Channel 2 aggregate subset — BARE
  #     aggregate value reads. `array_copy(NAME)` is explicit array storage, while
  #     terse `copy(NAME)` follows remembered bare-name kind before the legacy
  #     untyped array fallback.
  while ($masked =~ /\barray_copy\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)/g) {
   $record->('@', $1);
  }
  while ($masked =~ /\bcopy\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)/g) {
   my $kind = _bare_symbol_kind($1);
   $record->(defined($kind) && $kind eq 'hash' ? '%' : '@', $1);
  }
  while ($masked =~ /\bhash_copy\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)/g) {
   $record->('%', $1);
  }
  # (d) SPEC-FORMAT-TERSE.1.2.3.3.1 — BARE scalar source-slot reads.
  #     These forms now lower to `$NAME`; collect the matching scalar lexical.
  while ($masked =~ /\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && ($call->{method} // '') eq 'return';
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $args;
   my $payload = _trim_action_ir_value($args->[0]);
   $collect_value_position_scalar_reads->($payload);
  }
	  while ($masked =~ /\b(?<expr>set\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
	   my $call = _parse_method_function_expr($+{expr});
	   next unless $call && (($call->{method} // '') eq 'assign');
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
   next unless $args;
   $record_assignment_target_for_source->($args->[0], $args->[1]);
   my $source_expr = _trim_action_ir_value($args->[1]);
   $collect_value_position_scalar_reads->($source_expr);
  }
  foreach my $statement (@{_split_action_ir_statements($block)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\+=\s*(.+)$/s) {
    my $target_expr = $1;
    my $value_expr = _trim_action_ir_value($2);
    my $lowered_append = _lower_array_append_operator_statement($trimmed);
    next unless defined($lowered_append) && length($lowered_append);
    $record->('@', $target_expr);
    $collect_value_position_scalar_reads->($value_expr);
    next;
   }
   my $parsed_array_end = _parse_array_end_mutation_method_statement($trimmed);
   if ($parsed_array_end) {
    my $lowered_array_end = _lower_array_end_mutation_method_statement($trimmed);
    next unless defined($lowered_array_end) && length($lowered_array_end);
    $record->('@', $parsed_array_end->{target});
    if (defined($parsed_array_end->{value})) {
     my $value_expr = _trim_action_ir_value($parsed_array_end->{value});
     $collect_value_position_scalar_reads->($value_expr);
    }
    next;
   }
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\[/s) {
    my $target_expr = $1;
    my $lowered_hash_index = _lower_hash_index_assignment_operator_statement($trimmed);
    if (defined($lowered_hash_index) && length($lowered_hash_index)) {
     my $parsed_hash_index = _parse_hash_index_assignment_operator_statement($trimmed);
     $record->('%', $parsed_hash_index->{target} // $target_expr) if $parsed_hash_index;
     if ($parsed_hash_index) {
      for my $slot (qw(key value)) {
       my $slot_expr = _trim_action_ir_value($parsed_hash_index->{$slot});
       $collect_value_position_scalar_reads->($slot_expr);
      }
     }
     next;
    }
   }
   if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=|>)\s*(.+)$/s) {
   my $source_expr = _trim_action_ir_value($2);
   $record_assignment_target_for_source->($1, $source_expr);
    $collect_value_position_scalar_reads->($source_expr);
    next;
   }
   my $call = _parse_method_function_expr($trimmed);
   next unless $call && ($call->{method} // '') eq 'set_key';
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 3, 3);
   next unless $args;
   my $lowered_set_key = _lower_set_key_statement($trimmed);
   next unless defined($lowered_set_key) && length($lowered_set_key);
   my $target_expr = _trim_action_ir_value($args->[0]);
   $record->('%', $target_expr) if defined($target_expr) && $target_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   for my $slot_index (1, 2) {
   my $slot_expr = _trim_action_ir_value($args->[$slot_index]);
   $collect_value_position_scalar_reads->($slot_expr);
   }
  }
  while ($masked =~ /\b(?<expr>(?:push_value|push_nonempty)\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && (($call->{method} // '') eq 'push_value' || ($call->{method} // '') eq 'push_nonempty');
   my $args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
   next unless $args;
   my $value_expr = _trim_action_ir_value($args->[1]);
   $collect_value_position_scalar_reads->($value_expr);
  }
  while ($masked =~ /\b(?<expr>push\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && ($call->{method} // '') eq 'push';
   my $args = $call->{args} || [];
   next unless @$args == 2;
   my $target_expr = _trim_action_ir_value($args->[0]);
   my $value_expr = _trim_action_ir_value($args->[1]);
   next unless defined($target_expr) && $target_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   next if defined($value_expr) && $value_expr =~ /^\w+$/o;   # all-bare child-call form
   $record->('@', $target_expr);
   $collect_value_position_scalar_reads->($value_expr);
  }
 }
 return [] unless @collected;

 # Dedup against the accumulator @<label> and anything already declared (same sigil)
 # in the lowered handler code, then emit one `my` per surviving working variable.
 my @decls;
 for my $var (@collected) {
  my ($sigil, $name) = ($var->{sigil}, $var->{name});
  next if $sigil eq '@' && $name eq $label;   # the auto `my @<label>` accumulator
  next if defined($lowered_text) && length($lowered_text)
       && $lowered_text =~ /\bmy\s+\Q$sigil$name\E\b/;
  push @decls, "my $sigil$name;";
 }
 return \@decls
}

#------------------------------------------------------------------------------
# Function: build_rule_ir_emit_context
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/dependency_refs/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $scope = _trace_emit_context_enter(
  'build_rule_ir_emit_context',
  $label,
  {
   label => $label,
   node_type => $rule_ir->{node_type},
   regex_count => ref($rule_ir->{REs}) eq 'ARRAY' ? scalar(@{$rule_ir->{REs}}) : 0,
   acode_count => ref($rule_ir->{acode_entries}) eq 'ARRAY' ? scalar(@{$rule_ir->{acode_entries}}) : 0,
   bcode_count => ref($rule_ir->{bcode_entries}) eq 'ARRAY' ? scalar(@{$rule_ir->{bcode_entries}}) : 0,
   and_icode_count => ref($rule_ir->{and_icode_entries}) eq 'ARRAY' ? scalar(@{$rule_ir->{and_icode_entries}}) : 0,
   function_registry_count => ref($rule_ir->{function_registry}) eq 'HASH'
    ? scalar(keys %{$rule_ir->{function_registry}})
    : 0,
  },
 );
 local $__ls_current_function_registry = ref($rule_ir->{function_registry}) eq 'HASH'
  ? $rule_ir->{function_registry}
  : undef;
 local $__ls_current_bare_type_memory = _collect_bare_identifier_type_memory($rule_ir);
 _trace_emit_context_decision(
  phase => 'build_rule_ir_emit_context',
  label => $label,
  decision => 'function_registry_available',
  taken => ref($__ls_current_function_registry) eq 'HASH',
  context => {
   function_registry_count => ref($__ls_current_function_registry) eq 'HASH'
    ? scalar(keys %$__ls_current_function_registry)
    : 0,
  },
 );
 _trace_emit_context_decision(
  phase => 'build_rule_ir_emit_context',
  label => $label,
  decision => 'bare_type_memory_collected',
  taken => ref($__ls_current_bare_type_memory) eq 'HASH',
  context => {
   bare_type_memory_count => ref($__ls_current_bare_type_memory) eq 'HASH'
    ? scalar(keys %$__ls_current_bare_type_memory)
    : 0,
  },
 );
 my $rewrite_rules = _build_action_rewrite_rules($label);
 _trace_emit_context_decision(
  phase => 'build_rule_ir_emit_context',
  label => $label,
  decision => 'rewrite_rules_built',
  taken => ref($rewrite_rules) eq 'ARRAY',
  context => {
   rewrite_rule_count => ref($rewrite_rules) eq 'ARRAY' ? scalar(@$rewrite_rules) : 0,
  },
 );
 my $rewrite_diag_acc = _build_rewrite_diag_acc();

 my ($acodes, $dependency_refs) = _rewrite_acode_entries(
  $label,
  $rule_ir->{acode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 my ($bcalls, $bcodes) = _rewrite_bcode_entries(
  $label,
  $rule_ir->{bcode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 # AND rules: rewrite per-regex I-block code from and_icode_entries into a single
 # and_icode string.  The handler places it after regex match (IMATCH bridge +
 # return->assignment) instead of the preamble.  Avoids MIXED_ACTIONS with bcodes.
 my $and_icode;
 if (ref($rule_ir->{and_icode_entries}) eq 'ARRAY' && @{$rule_ir->{and_icode_entries}}) {
  for my $entry (@{$rule_ir->{and_icode_entries}}) {
   my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $entry->{code}, $rewrite_rules);
   _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
   $and_icode = $rewritten unless defined($and_icode);
  }
 }
 my $lifecycle_code = _normalize_rule_lifecycle_code(
  $label,
  $rule_ir->{code_blocks},
  $rewrite_diag_acc,
  $rewrite_rules,
 );

  my %ab_count = (
  ACODE => scalar(@{$rule_ir->{acode_entries}}),
  BCODE => scalar(@{$rule_ir->{bcode_entries}}),
 );
 my $action_rewriter_meta = _build_action_rewriter_meta(
  $label,
  $rewrite_rules,
  $rewrite_diag_acc,
 );

 # SPEC-FORMAT-TERSE.1.1.1 — auto-existing working variables. Collect typed-wrapper
 # references across the rule's RAW blocks and emit one preamble `my` per working
 # variable that is not already declared (deduped against the LOWERED handler code so
 # specs that use declare(...) stay byte-identical). See _collect_auto_working_var_decls.
 my $lowered_text = join("\n",
  grep { defined && length }
  (
   $lifecycle_code->{icode}, $lifecycle_code->{ecode}, $lifecycle_code->{excode},
   $lifecycle_code->{itcode}, $lifecycle_code->{lxcode}, $lifecycle_code->{lscode},
   $lifecycle_code->{lecode}, $and_icode,
   @{$acodes || []}, values %{$bcodes || {}},
  )
 );
 my $auto_var_decls = _collect_auto_working_var_decls($rule_ir, $lowered_text);

 my $emit_context = {
  label     => $label,
  node_type => $rule_ir->{node_type},
  REs       => $rule_ir->{REs},
  ACODEs    => $acodes,
  BCODEs    => $bcodes,
  BCALLs    => $bcalls,
  DEPENDENCY_REFS => $dependency_refs,
  ab_count  => \%ab_count,
  and_icode => $and_icode,
  auto_var_decls => $auto_var_decls,
  icode     => $lifecycle_code->{icode},
  ecode     => $lifecycle_code->{ecode},
  excode    => $lifecycle_code->{excode},
  itcode    => $lifecycle_code->{itcode},
  lxcode    => $lifecycle_code->{lxcode},
  lscode    => $lifecycle_code->{lscode},
  lecode    => $lifecycle_code->{lecode},
  action_rewriter_meta => $action_rewriter_meta,
 };
 _trace_emit_context_exit(
  $scope,
  {
   status => 'ok',
   label => $label,
   acode_count => scalar(@{$acodes || []}),
   bcode_count => scalar(keys %{$bcodes || {}}),
   dependency_ref_count => scalar(@{$dependency_refs || []}),
   auto_var_decl_count => scalar(@{$auto_var_decls || []}),
   language_agnostic_action_ir_ready => $action_rewriter_meta->{language_agnostic_action_ir_ready},
  },
 );
 return $emit_context
}

1;
