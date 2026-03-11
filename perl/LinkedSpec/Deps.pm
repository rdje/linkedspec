package LinkedSpec::Deps;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 my $code = $pkg->can($name);
 die "(LinkedSpec::Deps::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
  unless ref($code) eq 'CODE';
 return $code
}

sub _require_pkg_value {
 my ($pkg, $name) = @_;
 my $cb = _require_pkg_cb($pkg, $name);
 return $cb->()
}

sub declare_method_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  is_bare_method_scope_token => _require_pkg_cb($pkg, '_is_bare_method_scope_token'),
  normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
  lower_flow_composite_expr => _require_pkg_cb($pkg, '_lower_flow_composite_expr'),
  lower_method_value_expr => _require_pkg_cb($pkg, '_lower_method_value_expr'),
  declare_alias_to_type => _require_pkg_cb($pkg, '_declare_alias_to_type'),
  lower_typed_declare_statement => _require_pkg_cb($pkg, '_lower_typed_declare_statement'),
  lower_assign_statement => _require_pkg_cb($pkg, '_lower_assign_statement'),
 }
}
sub parser_factory_deps_for_package {
 my ($pkg) = @_;
 return {
  apply_trace_options => _require_pkg_cb('LinkedSpec::Trace', '_apply_trace_options'),
  trace_enter => _require_pkg_cb('LinkedSpec::Trace', 'trace_enter'),
  trace_exit => _require_pkg_cb('LinkedSpec::Trace', 'trace_exit'),
  trace_decision => _require_pkg_cb('LinkedSpec::Trace', 'trace_decision'),
  validate_spec_name => _require_pkg_cb('LinkedSpec::Resolver', 'validate_spec_name'),
  resolve_spec_path => _require_pkg_cb('LinkedSpec::Resolver', 'resolve_spec_path'),
  load_spec_content => _require_pkg_cb('LinkedSpec::Resolver', 'load_spec_content'),
  compile_spec => _require_pkg_cb('LinkedSpec::Runtime', 'run_get'),
  dump_low => _require_pkg_value('LinkedSpec::Trace', 'DUMP_LOW'),
  dump_medium => _require_pkg_value('LinkedSpec::Trace', 'DUMP_MEDIUM'),
 }
}

1;
