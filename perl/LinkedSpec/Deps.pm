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
