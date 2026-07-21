#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticCallProjection
# Purpose: Project clone-safe function, call, binding, staged, and generated
#          semantic facts from compiled descriptor and typed ActionIR authority.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticCallProjection;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(encode FB_CROAK LEAVE_SRC);
use JSON::PP ();

use LinkedSpec::OwnerDispatch ();

# This is the semantic-v1 projection vocabulary for the helper rows that can
# appear in the governed calls snapshot. Runtime dispatch remains owned by the
# ActionIR/helper implementation; unsupported calls stay explicitly unknown.
my %HELPER_CONTRACT = (
 trim => {
  parameters => [{ name => 'value', kind => 'value', required => 1 }],
  effects => [],
  return_kind => 'string',
 },
 match_text => {
  parameters => [],
  effects => ['reads_runtime_match'],
  return_kind => 'string',
 },
 return => {
  parameters => [{ name => 'value', kind => 'value', required => 1 }],
  effects => ['returns_owner'],
  return_kind => 'unknown',
 },
);

sub build {
 my (%args) = @_;
 my $descriptor = $args{descriptor};
 my $source_map = $args{source_map};
 die "(LinkedSpec::SemanticCallProjection::build) -E- descriptor must be HASH\n"
  unless ref($descriptor) eq 'HASH';
 die "(LinkedSpec::SemanticCallProjection::build) -E- source_map is required\n"
  unless ref($source_map) && $source_map->can('span_from_byte_range');

 my $meta = ref($descriptor->{meta}) eq 'HASH' ? $descriptor->{meta} : {};
 my @rule_order = @{$args{rule_order} || []};
 my $rule_ids = ref($args{rule_ids}) eq 'HASH' ? $args{rule_ids} : {};
 my $components = ref($args{components}) eq 'HASH' ? $args{components} : {};
 my @function_names = ref($meta->{function_order}) eq 'ARRAY'
  ? @{$meta->{function_order}}
  : sort keys %{$descriptor->{functions} || {}};
 my %functions = map {
  $_ => ref($descriptor->{functions}{$_}) eq 'HASH' ? $descriptor->{functions}{$_} : {}
 } @function_names;

 my @definition_rows;
 foreach my $label (@rule_order) {
  my $range = $components->{$label}{header};
  push @definition_rows, {
   id => $rule_ids->{$label},
   start_character => ref($range) eq 'HASH' ? $range->{start} : undef,
   type => 'rule',
   name => $label,
  };
 }
 foreach my $name (@function_names) {
  my $span = $functions{$name}{source_span};
  # Function registry spans and typed ActionIR spans are character offsets.
  # SemanticSourceMap performs the only character-to-byte conversion when a
  # public source reference is assembled.
  push @definition_rows, {
   id => _function_id($name),
   start_character => ref($span) eq 'HASH' ? $span->{start} : undef,
   type => 'function',
   name => $name,
  };
 }
 @definition_rows = sort {
  (defined($a->{start_character}) ? $a->{start_character} : 9_999_999_999)
   <=> (defined($b->{start_character}) ? $b->{start_character} : 9_999_999_999)
   || $a->{id} cmp $b->{id}
 } @definition_rows;

 my $empty = {
  definition_order_ids => [map { $_->{id} } @definition_rows],
  edge_value_shapes => {},
  source_refs => {},
  records => [],
  relations => [],
 };
 return $empty unless @function_names;

 my (@records, @relations);
 my %source_refs;
 my %function_shapes = map { $_ => _value_shape('unknown') } @function_names;
 for (1 .. scalar(@function_names) + 1) {
  my $changed = 0;
  foreach my $name (@function_names) {
   my $shape = _function_return_shape($functions{$name}, \%function_shapes);
   if ($shape->{kind} ne $function_shapes{$name}{kind}) {
    $function_shapes{$name} = $shape;
    $changed = 1;
   }
  }
  last unless $changed;
 }

 my %function_ids = map { $_ => _function_id($_) } @function_names;
 foreach my $index (0 .. $#function_names) {
  my $name = $function_names[$index];
  my $definition = $functions{$name};
  my $function_id = $function_ids{$name};
  my $source = _register_character_source(
   \%source_refs,
   "source_ref:$function_id",
   $definition->{source_span},
   \%args,
  );
  my $signature = _function_signature($definition);
  push @records, _record(
   id => $function_id,
   kind => 'function',
   name => $name,
   owner_id => 'spec:0',
   order => $index,
   source => $source,
   facts => {
    signature => $signature,
    parameter_kinds => [map { $_->{kind} } @{$signature->{parameters}}],
    return_shape => $function_shapes{$name},
   },
  );
  push @relations, _relation(
   'declares', 'spec:0', $function_id, scalar(@rule_order) + $index, $source, [],
  );
  _add_staged_records(
   records => \@records,
   relations => \@relations,
   function_id => $function_id,
   function_name => $name,
   function_source => $source,
   definition => $definition,
  );
 }

 my %helper_ids;
 my %binding_by_owner_name;
 my %edge_value_shapes;
 my $global_call_order = 0;
 foreach my $definition_row (@definition_rows) {
  if ($definition_row->{type} eq 'function') {
   my $name = $definition_row->{name};
   my $definition = $functions{$name};
   my $function_id = $function_ids{$name};
   my $body_ast = $definition->{body_ast};
   next unless ref($body_ast) eq 'HASH';
   my %context = map { $_ => _value_shape('unknown') } @{$definition->{params} || []};
   my $offset = ref($definition->{body_span}) eq 'HASH'
    ? 0 + ($definition->{body_span}{start} // 0)
    : 0;
   my $local_order = 0;
   foreach my $statement (@{$body_ast->{statements} || []}) {
    my $expr = ref($statement) eq 'HASH' ? $statement->{expr} : undef;
    next unless ref($expr) eq 'HASH';
    if (($expr->{kind} // '') eq 'call' && ($expr->{name} // '') eq 'return') {
     foreach my $arg (@{$expr->{args} || []}) {
      _emit_expr_calls(
       expr => $arg,
       owner_id => $function_id,
       owner_surface => 'function',
       span_offset => $offset,
       context => \%context,
       functions => \%functions,
       function_ids => \%function_ids,
       function_shapes => \%function_shapes,
       helper_ids => \%helper_ids,
       binding_by_owner_name => \%binding_by_owner_name,
       source_refs => \%source_refs,
       source_args => \%args,
       records => \@records,
       relations => \@relations,
       local_order_ref => \$local_order,
       global_order_ref => \$global_call_order,
      );
     }
     next;
    }
    _emit_expr_calls(
     expr => $expr,
     owner_id => $function_id,
     owner_surface => 'function',
     span_offset => $offset,
     context => \%context,
     functions => \%functions,
     function_ids => \%function_ids,
     function_shapes => \%function_shapes,
     helper_ids => \%helper_ids,
     binding_by_owner_name => \%binding_by_owner_name,
     source_refs => \%source_refs,
     source_args => \%args,
     records => \@records,
     relations => \@relations,
     local_order_ref => \$local_order,
     global_order_ref => \$global_call_order,
    );
   }
   next;
  }

  my $label = $definition_row->{name};
  my $rule_id = $rule_ids->{$label};
  foreach my $edge (@{$components->{$label}{edges} || []}) {
   my $block = $edge->{action_block};
   next unless ref($block) eq 'HASH';
   my $ast = LinkedSpec::OwnerDispatch::dispatch_owner_call(
    __PACKAGE__,
    'LinkedSpec::ActionIR::AST',
    'parse_action_block',
    $block->{text},
    { base_start => $block->{start} },
   );
   my $owner_id = "edge:$rule_id:$edge->{order}";
   my (%context, %binding_order);
   my $local_order = 0;
   foreach my $statement (@{$ast->{statements} || []}) {
    my $expr = ref($statement) eq 'HASH' ? $statement->{expr} : undef;
    next unless ref($expr) eq 'HASH';
    if (($expr->{kind} // '') eq 'assign_scalar') {
     my $name = $expr->{name};
     my $value = $expr->{value};
     my $shape = _infer_expr_shape($value, \%context, \%function_shapes);
     my $order = $binding_order{$name} // 0;
     ++$binding_order{$name};
     my $binding_id = "binding:$owner_id:" . _escape_name($name) . ":$order";
     my $binding_source = _register_node_source(
      \%source_refs, "source_ref:$binding_id", $value, 0, \%args,
     );
     push @records, _record(
      id => $binding_id,
      kind => 'binding',
      name => $name,
      owner_id => $owner_id,
      order => $order,
      source => $binding_source,
      facts => { scope => 'action', value_shape => $shape, mutable => _boolean(1) },
     );
     $context{$name} = $shape;
     $binding_by_owner_name{"$owner_id\0$name"} = $binding_id;
     my $call_id = _emit_expr_calls(
      expr => $value,
      owner_id => $owner_id,
      owner_surface => 'edge',
      span_offset => 0,
      context => \%context,
      functions => \%functions,
      function_ids => \%function_ids,
      function_shapes => \%function_shapes,
      helper_ids => \%helper_ids,
      binding_by_owner_name => \%binding_by_owner_name,
      source_refs => \%source_refs,
      source_args => \%args,
      records => \@records,
      relations => \@relations,
      local_order_ref => \$local_order,
      global_order_ref => \$global_call_order,
     );
     push @relations, _relation(
      'writes', $call_id, $binding_id, 0, $binding_source, [],
     ) if defined $call_id;
     next;
    }
    if (($expr->{kind} // '') eq 'call' && ($expr->{name} // '') eq 'return') {
     $edge_value_shapes{$owner_id} = _infer_expr_shape($expr, \%context, \%function_shapes);
    }
    _emit_expr_calls(
     expr => $expr,
     owner_id => $owner_id,
     owner_surface => 'edge',
     span_offset => 0,
     context => \%context,
     functions => \%functions,
     function_ids => \%function_ids,
     function_shapes => \%function_shapes,
     helper_ids => \%helper_ids,
     binding_by_owner_name => \%binding_by_owner_name,
     source_refs => \%source_refs,
     source_args => \%args,
     records => \@records,
     relations => \@relations,
     local_order_ref => \$local_order,
     global_order_ref => \$global_call_order,
    );
   }
  }
 }

 _add_generated_plan(
  records => \@records,
  relations => \@relations,
  descriptor => $descriptor,
  selected_rule => $args{selected_rule},
 );

 return {
  definition_order_ids => [map { $_->{id} } @definition_rows],
  edge_value_shapes => \%edge_value_shapes,
  source_refs => \%source_refs,
  records => \@records,
  relations => \@relations,
 }
}

sub _emit_expr_calls {
 my (%args) = @_;
 my $expr = $args{expr};
 return undef unless ref($expr) eq 'HASH';
 my $kind = $expr->{kind} // '';
 if ($kind eq 'assign_scalar') {
  return _emit_expr_calls(%args, expr => $expr->{value})
 }
 return undef unless $kind eq 'call';

 my $name = $expr->{name} // '';
 my $is_function = exists $args{functions}{$name};
 my $helper = $HELPER_CONTRACT{$name};
 my $resolution_kind = $is_function ? 'user_function' : ref($helper) eq 'HASH' ? 'helper' : 'unresolved';
 my $target_id = $is_function ? $args{function_ids}{$name}
  : ref($helper) eq 'HASH' ? _helper_id($name)
  : undef;
 my $local_order = ${$args{local_order_ref}}++;
 my $global_order = ${$args{global_order_ref}}++;
 my $call_id = "call:$args{owner_id}:$local_order";
 my $source = _register_node_source(
  $args{source_refs}, "source_ref:$call_id", $expr, $args{span_offset}, $args{source_args},
 );
 my @argument_shapes = map {
  _infer_expr_shape($_, $args{context}, $args{function_shapes})
 } @{$expr->{args} || []};
 my $return_shape = $is_function ? $args{function_shapes}{$name}
  : ref($helper) eq 'HASH' && $name eq 'return' && @argument_shapes
   ? $argument_shapes[0]
   : ref($helper) eq 'HASH'
    ? _value_shape($helper->{return_kind})
    : _value_shape('unknown');
 push @{$args{records}}, _record(
  id => $call_id,
  kind => 'call',
  name => $name,
  owner_id => $args{owner_id},
  order => $global_order,
  source => $source,
  facts => {
   call_form => 'function',
   resolution_kind => $resolution_kind,
   argument_shapes => \@argument_shapes,
   return_shape => $return_shape,
   target_shape => _target_shape($resolution_kind eq 'unresolved' ? 'unknown' : $resolution_kind),
  },
 );

 if (!$is_function && ref($helper) eq 'HASH' && !$args{helper_ids}{$name}) {
  my $helper_id = _helper_id($name);
  my $helper_order = scalar keys %{$args{helper_ids}};
  $args{helper_ids}{$name} = $helper_id;
  push @{$args{records}}, _record(
   id => $helper_id,
   kind => 'helper',
   name => $name,
   owner_id => undef,
   order => $helper_order,
   source => undef,
   facts => {
    signature => _signature_from_parameters($helper->{parameters}),
    effects => [@{$helper->{effects}}],
    return_shape => _value_shape($helper->{return_kind}),
   },
  );
 }

 if (defined $target_id) {
  if ($is_function) {
   push @{$args{relations}}, _relation('calls', $call_id, $target_id, 0, $source, []);
   _add_call_resolution_explanation(
    %args,
    call_id => $call_id,
    call_source => $source,
    function_id => $target_id,
    function_name => $name,
    argument_shapes => \@argument_shapes,
    return_shape => $return_shape,
   );
  } else {
   my $evidence = $args{owner_surface} eq 'function' ? [$args{owner_id}] : [];
   push @{$args{relations}}, _relation('resolves_to', $call_id, $target_id, 0, $source, $evidence);
  }
 }

 if ($name eq 'return') {
  foreach my $arg (@{$expr->{args} || []}) {
   next unless ref($arg) eq 'HASH' && ($arg->{kind} // '') eq 'variable';
   my $binding_id = $args{binding_by_owner_name}{"$args{owner_id}\0$arg->{name}"};
   push @{$args{relations}}, _relation('reads', $call_id, $binding_id, 0, $source, [])
    if defined $binding_id;
  }
 }

 foreach my $arg (@{$expr->{args} || []}) {
  _emit_expr_calls(%args, expr => $arg);
 }
 return $call_id
}

sub _add_call_resolution_explanation {
 my (%args) = @_;
 my $decision_id = "decision:call:$args{call_id}";
 push @{$args{records}}, _record(
  id => $decision_id,
  kind => 'decision',
  name => "$args{function_name} call resolution",
  owner_id => $args{call_id},
  order => 0,
  source => $args{call_source},
  facts => { decision_kind => 'call_resolution', outcome => $args{function_id} },
 );
 my $exact_id = "explanation:$decision_id:0";
 push @{$args{records}}, _record(
  id => $exact_id,
  kind => 'explanation_step',
  name => undef,
  owner_id => $decision_id,
  order => 0,
  source => $args{call_source},
  facts => {
   rule_code => 'call_exact_user_function',
   summary => "The exact user-function name $args{function_name} is registered.",
   input_ids => [$args{call_id}, $args{function_id}],
   output_fact => {
    record_id => $args{call_id},
    path => '/facts/resolution_kind',
    value => 'user_function',
   },
  },
 );
 my $signature_id = "explanation:$decision_id:1";
 my $definition = $args{functions}{$args{function_name}};
 my @params = @{$definition->{params} || []};
 my $count = scalar @{$args{argument_shapes}};
 my $count_words = $count == 1 ? 'one' : "$count";
 my $shape_word = $count == 1 ? $args{argument_shapes}[0]{kind} . ' argument' : 'arguments';
 push @{$args{records}}, _record(
  id => $signature_id,
  kind => 'explanation_step',
  name => undef,
  owner_id => $decision_id,
  order => 1,
  source => $args{call_source},
  facts => {
   rule_code => 'call_signature_accepts',
   summary => "The $count_words supplied $shape_word satisfies $args{function_name}(" . join(', ', @params) . ').',
   input_ids => [$args{call_id}, $args{function_id}],
   output_fact => {
    record_id => $args{call_id},
    path => '/facts/return_shape/kind',
    value => $args{return_shape}{kind},
   },
  },
 );
 push @{$args{relations}}, _relation(
  'resolves_to', $args{call_id}, $args{function_id}, 0, $args{call_source}, [$decision_id],
 );
 push @{$args{relations}}, _relation(
  'explained_by', $decision_id, $exact_id, 0, $args{call_source}, [$args{function_id}],
 );
 push @{$args{relations}}, _relation(
  'explained_by', $decision_id, $signature_id, 1, $args{call_source}, [$args{function_id}],
 );
 return
}

sub _add_staged_records {
 my (%args) = @_;
 my $function_id = $args{function_id};
 my $name = $args{function_name};
 my $status = ref($args{definition}{body_ast}) eq 'HASH' ? 'succeeded' : 'failed';
 my @rows = (
  ['payload', 'action_source', 'string'],
  ['parse_job', 'action_program', 'unknown'],
  ['result', 'action_program', 'unknown'],
 );
 my %ids;
 foreach my $order (0 .. $#rows) {
  my ($artifact_kind, $node_kind, $shape_kind) = @{$rows[$order]};
  my $id = "staged:$artifact_kind:$function_id:$order";
  $ids{$artifact_kind} = $id;
  push @{$args{records}}, _record(
   id => $id,
   kind => 'staged_artifact',
   name => "$name body " . ($artifact_kind eq 'parse_job' ? 'parse job' : $artifact_kind),
   owner_id => $function_id,
   order => $order,
   source => $args{function_source},
   facts => {
    artifact_kind => $artifact_kind,
    payload_kind => 'function_body',
    node_kind => $node_kind,
    parent_path => [$function_id],
    parser_spec_id => 'linkedspec-action-v1',
    top_rule => 'FunctionBody',
    result_policy => 'typed_action_program',
    failure_policy => 'compile_diagnostic',
    status => $status,
    value_shape => _value_shape($shape_kind),
   },
  );
  push @{$args{relations}}, _relation(
   'contains', $function_id, $id, $order, $args{function_source}, [],
  );
 }
 push @{$args{relations}}, _relation(
  'lowered_from', $ids{payload}, 'source:0', 0, $args{function_source}, [],
 );
 push @{$args{relations}}, _relation(
  'consumes', $ids{parse_job}, $ids{payload}, 0, $args{function_source}, [],
 );
 push @{$args{relations}}, _relation(
  'produces', $ids{parse_job}, $ids{result}, 0, $args{function_source}, [],
 );
 push @{$args{relations}}, _relation(
  'lowered_from', $ids{result}, $ids{payload}, 0, $args{function_source}, [],
 );
 push @{$args{relations}}, _relation(
  'staged_by', $ids{result}, $ids{parse_job}, 0, $args{function_source}, [],
 );
 return
}

sub _add_generated_plan {
 my (%args) = @_;
 my $descriptor = $args{descriptor};
 my $selected = $args{selected_rule};
 my $rule = defined($selected) && ref($descriptor->{spec}{$selected}) eq 'HASH'
  ? $descriptor->{spec}{$selected}
  : {};
 my $meta = ref($rule->{meta}) eq 'HASH' ? $rule->{meta} : {};
 my $family = LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::GeneratedSource',
  'family_for_handler_variant',
  $meta->{selected_handler_variant},
 );
 my $identity = LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::GeneratedSource',
  'contract_identity',
 );
 my $id = 'generated:handler_plan:0';
 push @{$args{records}}, _record(
  id => $id,
  kind => 'generated_artifact',
  name => 'handler plan',
  owner_id => 'spec:0',
  order => 0,
  source => undef,
  facts => {
   artifact_kind => 'handler_plan',
   contract_id => $identity->{contract_id},
   format_version => $identity->{format_version},
   plan_family => $family,
  },
 );
 push @{$args{relations}}, _relation('generated_as', 'spec:0', $id, 0, undef, []);
 return
}

sub _function_return_shape {
 my ($definition, $function_shapes) = @_;
 my $ast = $definition->{body_ast};
 return _value_shape('unknown') unless ref($ast) eq 'HASH';
 my %context = map { $_ => _value_shape('unknown') } @{$definition->{params} || []};
 foreach my $statement (@{$ast->{statements} || []}) {
  my $expr = ref($statement) eq 'HASH' ? $statement->{expr} : undef;
  next unless ref($expr) eq 'HASH';
  if (($expr->{kind} // '') eq 'call' && ($expr->{name} // '') eq 'return') {
   my $arg = $expr->{args}[0];
   return _infer_expr_shape($arg, \%context, $function_shapes)
    if ref($arg) eq 'HASH';
  }
  if (($expr->{kind} // '') eq 'assign_scalar') {
   $context{$expr->{name}} = _infer_expr_shape($expr->{value}, \%context, $function_shapes);
  }
 }
 return _value_shape('unknown')
}

sub _infer_expr_shape {
 my ($expr, $context, $function_shapes) = @_;
 return _value_shape('unknown') unless ref($expr) eq 'HASH';
 my $kind = $expr->{kind} // '';
 return _value_shape('string') if $kind eq 'string';
 return _value_shape('number') if $kind eq 'number';
 return _value_shape('boolean') if $kind eq 'boolean';
 return _value_shape('null') if $kind eq 'null';
 return $context->{$expr->{name}} || _value_shape('unknown') if $kind eq 'variable';
 return _infer_expr_shape($expr->{value}, $context, $function_shapes)
  if $kind eq 'assign_scalar';
 if ($kind eq 'call') {
  my $name = $expr->{name} // '';
  return $function_shapes->{$name} if exists $function_shapes->{$name};
  return _infer_expr_shape($expr->{args}[0], $context, $function_shapes)
   if $name eq 'return' && ref($expr->{args}) eq 'ARRAY' && @{$expr->{args}};
  my $helper = $HELPER_CONTRACT{$name};
  return _value_shape($helper->{return_kind}) if ref($helper) eq 'HASH';
 }
 return _value_shape('unknown')
}

sub _function_signature {
 my ($definition) = @_;
 my @parameters;
 my ($arity_min, $arity_max, $rest_parameter);
 if (($definition->{version} // 1) == 2 && ref($definition->{signature}) eq 'HASH') {
  my $signature = $definition->{signature};
  @parameters = map { { name => $_, kind => 'value', required => 1 } }
   @{$signature->{positional_params} || []};
  $rest_parameter = $signature->{rest_param};
  $arity_min = 0 + ($signature->{min_arity} // scalar @parameters);
  $arity_max = $signature->{max_arity};
 } else {
  my $parameter_kinds = ref($definition->{parameter_kinds}) eq 'HASH'
   ? $definition->{parameter_kinds}
   : {};
  @parameters = map {
   { name => $_, kind => $parameter_kinds->{$_} // 'value', required => 1 }
  } @{$definition->{params} || []};
  $arity_min = 0 + ($definition->{arity} // scalar @parameters);
  $arity_max = $arity_min;
 }
 return {
  parameters => [map { { %$_, required => _boolean($_->{required}) } } @parameters],
  arity_min => $arity_min,
  arity_max => $arity_max,
  rest_parameter => $rest_parameter,
  final_codeblock => _boolean(@parameters && $parameters[-1]{kind} eq 'codeblock'),
 }
}

sub _signature_from_parameters {
 my ($parameters) = @_;
 my @parameters = map { { %$_, required => _boolean($_->{required}) } } @$parameters;
 return {
  parameters => \@parameters,
  arity_min => scalar @parameters,
  arity_max => scalar @parameters,
  rest_parameter => undef,
  final_codeblock => _boolean(@parameters && $parameters[-1]{kind} eq 'codeblock'),
 }
}

sub _register_node_source {
 my ($source_refs, $key, $node, $offset, $args) = @_;
 return undef unless ref($node) eq 'HASH' && ref($node->{source_span}) eq 'HASH';
 return _register_character_source(
  $source_refs,
  $key,
  {
   start => 0 + ($node->{source_span}{start} // 0) + $offset,
   end => 0 + ($node->{source_span}{end} // 0) + $offset,
  },
  $args,
 )
}

sub _register_character_source {
 my ($source_refs, $key, $range, $args) = @_;
 return undef unless ref($range) eq 'HASH';
 my ($start, $end) = @{$range}{qw(start end)};
 return undef unless defined($start) && defined($end);
 $source_refs->{$key} = {
  source_id => 'source:0',
  logical_name => $args->{logical_name},
  span => $args->{source_map}->span_from_character_range($start, $end),
  excerpt => substr($args->{source_text}, $start, $end - $start),
  content_digest => $args->{content_digest},
  provenance_ids => [],
 };
 return $key
}

sub _record {
 my (%args) = @_;
 return {
  id => $args{id},
  kind => $args{kind},
  name => $args{name},
  owner_id => $args{owner_id},
  order => 0 + ($args{order} // 0),
  source => $args{source},
  facts => $args{facts},
  redactions => [],
 }
}

sub _relation {
 my ($kind, $from_id, $to_id, $order, $source, $evidence_ids) = @_;
 return {
  id => "relation:$kind:$from_id:$to_id:$order",
  kind => $kind,
  from_id => $from_id,
  to_id => $to_id,
  order => 0 + $order,
  source => $source,
  facts => {},
  evidence_ids => $evidence_ids,
 }
}

sub _value_shape {
 my ($kind) = @_;
 return { kind => $kind, element => undef, key => undef, value => undef, signature => undef, members => [] }
}

sub _target_shape {
 my ($kind) = @_;
 return _value_shape($kind)
}

sub _boolean {
 return $_[0] ? JSON::PP::true : JSON::PP::false
}

sub _function_id {
 return 'function:' . _escape_name($_[0])
}

sub _helper_id {
 return 'helper:' . _escape_name($_[0])
}

sub _escape_name {
 my ($name) = @_;
 my $bytes = encode('UTF-8', $name, FB_CROAK | LEAVE_SRC);
 my $escaped = '';
 foreach my $byte (unpack('C*', $bytes)) {
  my $character = chr($byte);
  $escaped .= $character =~ /[A-Za-z0-9._~-]/ ? $character : sprintf('%%%02X', $byte);
 }
 return $escaped
}

1;
