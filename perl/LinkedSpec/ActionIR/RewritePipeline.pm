package LinkedSpec::ActionIR::RewritePipeline;

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
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 my $code = $pkg->can($name);
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
  unless ref($code) eq 'CODE';
 return $code
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return {
  build_action_lowering_contracts => _require_pkg_cb($pkg, '_build_action_lowering_contracts'),
  collect_action_helper_ir_nodes  => _require_pkg_cb($pkg, '_collect_action_helper_ir_nodes'),
  build_canonical_action_ir_events => _require_pkg_cb($pkg, '_build_canonical_action_ir_events'),
  find_unresolved_action_helpers  => _require_pkg_cb($pkg, '_find_unresolved_action_helpers'),
 }
}

sub _lower_action_code_from_canonical_ir {
 my ($label, $code, $rewrite_rules, $canonical_ir_diag) = @_;

 my %rewrite_by_id = map { $_->{id} => $_ } @$rewrite_rules;
 my $rewritten = $code;
 my $lower_ctx = {
  if_stack      => [],
  switch_stack  => [],
  switch_counter => 0,
  rewrite_rules => $rewrite_rules,
 };
 foreach my $event (@{$canonical_ir_diag->{canonical_action_ir_events}}) {
  my $kind = $event->{kind} // '';
  next if $kind eq 'RAW_PERL';

  my $contract_id = $event->{contract_id};
  next unless defined $contract_id && exists $rewrite_by_id{$contract_id};

  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);
  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);
  next unless defined($lowered_stmt) && length($lowered_stmt);
  next if $lowered_stmt eq $source_stmt;

  my $pos = index($rewritten, $source_stmt);
  next if $pos < 0;
  substr($rewritten, $pos, length($source_stmt), $lowered_stmt);
 }
 if (@{$lower_ctx->{if_stack}} || @{$lower_ctx->{switch_stack}}) {
  return $code;
 }

 return $rewritten
}

sub _build_action_rewrite_rules {
 my ($label, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $build_action_lowering_contracts = _require_dep($deps, 'build_action_lowering_contracts');
 my $contracts = $build_action_lowering_contracts->($label);
 return [map {{
  id                 => $_->{id},
  ir_node            => $_->{ir_node},
  diag_name          => $_->{diag_name},
  unresolved_pattern => $_->{unresolved_pattern},
  apply              => $_->{lower},
 }} @$contracts]
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $collect_action_helper_ir_nodes = _require_dep($deps, 'collect_action_helper_ir_nodes');
 my $build_canonical_action_ir_events = _require_dep($deps, 'build_canonical_action_ir_events');
 my $find_unresolved_action_helpers = _require_dep($deps, 'find_unresolved_action_helpers');

 $rewrite_rules //= _build_action_rewrite_rules($label, $deps);
 my $ir_diag = $collect_action_helper_ir_nodes->($code, $rewrite_rules);
 my $canonical_ir_diag = $build_canonical_action_ir_events->($label, $code, $ir_diag->{helper_action_ir_events});
 my $rewritten = _lower_action_code_from_canonical_ir($label, $code, $rewrite_rules, $canonical_ir_diag);
 my $diag = $find_unresolved_action_helpers->($rewritten, $rewrite_rules);
 return ($rewritten, {
  %$diag,
  helper_action_ir_count => $ir_diag->{helper_action_ir_count},
  helper_action_ir_hits  => $ir_diag->{helper_action_ir_hits},
  helper_action_ir_nodes => $ir_diag->{helper_action_ir_nodes},
  helper_action_ir_events => $ir_diag->{helper_action_ir_events},
  canonical_action_ir_count => $canonical_ir_diag->{canonical_action_ir_count},
  canonical_action_ir_hits  => $canonical_ir_diag->{canonical_action_ir_hits},
  canonical_action_ir_nodes => $canonical_ir_diag->{canonical_action_ir_nodes},
  canonical_action_ir_events => $canonical_ir_diag->{canonical_action_ir_events},
  canonical_action_ir_fallback_count => $canonical_ir_diag->{canonical_action_ir_fallback_count},
 })
}

1;
