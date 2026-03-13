package LinkedSpec::ActionIR::Scanner;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::ActionIR::Scanner::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _require_scanner_core_pkg {
 _require_pkg('LinkedSpec::ActionIR::ScannerCore') unless LinkedSpec::ActionIR::ScannerCore->can('scan_contract_ir_events');
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return _call_preserving_err(sub {
  no strict 'refs';
  my $cb = *{"${pkg}::${name}"}{CODE};
  die "(LinkedSpec::ActionIR::Scanner::_require_pkg_cb) -E- missing callback ${pkg}::${name}"
   unless ref($cb) eq 'CODE';
  return $cb
 })
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   parse_method_function_expr => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_parse_method_function_expr'),
   normalize_method_args_with_optional_scope => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_normalize_method_args_with_optional_scope'),
   build_array_pipeline_plan_from_expr => _require_pkg_cb($pkg, '_build_array_pipeline_plan_from_expr'),
   extract_declare_statement_from_method_expr => _require_pkg_cb($pkg, '_extract_declare_statement_from_method_expr'),
   parse_declare_binding_entry => _require_pkg_cb($pkg, '_parse_declare_binding_entry'),
  }
 })
}

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_scanner_core_pkg();
  return LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(@args)
 })
}

1;
