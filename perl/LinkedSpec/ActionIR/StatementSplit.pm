package LinkedSpec::ActionIR::StatementSplit;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::ActionIR::StatementSplit::Core ();

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 no strict 'refs';
 my $cb = *{"${pkg}::${name}"}{CODE};
 die "(LinkedSpec::ActionIR::StatementSplit::_require_pkg_cb) -E- missing callback ${pkg}::${name}"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::StatementSplit::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
 }
}

sub _split_action_ir_statements {
 my ($code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 return LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements($code, $trim_action_ir_value)
}

1;
