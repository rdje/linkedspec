package LinkedSpec::ActionIR::Contracts;

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
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::Contracts::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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
  _require_pkg($pkg) unless $pkg->can($name);
  my $code = $pkg->can($name);
  die "(LinkedSpec::ActionIR::Contracts::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   lower_return_general_statement => _require_pkg_cb($pkg, '_lower_return_general_statement'),
   lower_return_imatch_statement  => _require_pkg_cb($pkg, '_lower_return_imatch_statement'),
   lower_assign_method_statement  => _require_pkg_cb($pkg, '_lower_assign_method_statement'),
   lower_push_value_statement     => _require_pkg_cb($pkg, '_lower_push_value_statement'),
   lower_regex_subst_statement    => _require_pkg_cb($pkg, '_lower_regex_subst_statement'),
   lower_array_pipeline_expr      => _require_pkg_cb($pkg, '_lower_array_pipeline_expr'),
   lower_if_flow_statement        => _require_pkg_cb($pkg, '_lower_if_flow_statement'),
   lower_elseif_flow_statement    => _require_pkg_cb($pkg, '_lower_elseif_flow_statement'),
   lower_else_flow_statement      => _require_pkg_cb($pkg, '_lower_else_flow_statement'),
   lower_endif_flow_statement     => _require_pkg_cb($pkg, '_lower_endif_flow_statement'),
   lower_switch_flow_statement    => _require_pkg_cb($pkg, '_lower_switch_flow_statement'),
   lower_case_flow_statement      => _require_pkg_cb($pkg, '_lower_case_flow_statement'),
   lower_default_flow_statement   => _require_pkg_cb($pkg, '_lower_default_flow_statement'),
   lower_endcase_flow_statement   => _require_pkg_cb($pkg, '_lower_endcase_flow_statement'),
   lower_endswitch_flow_statement => _require_pkg_cb($pkg, '_lower_endswitch_flow_statement'),
   lower_say_statement            => _require_pkg_cb($pkg, '_lower_say_statement'),
   lower_print_statement          => _require_pkg_cb($pkg, '_lower_print_statement'),
   lower_return_undef_statement   => _require_pkg_cb($pkg, '_lower_return_undef_statement'),
   lower_return_array_statement   => _require_pkg_cb($pkg, '_lower_return_array_statement'),
   lower_declare_method_statement => _require_pkg_cb($pkg, '_lower_declare_method_statement'),
  }
 })
}

sub _require_lowering_deps {
 my ($deps) = @_;
 return {
  lower_return_general_statement => _require_dep($deps, 'lower_return_general_statement'),
  lower_return_imatch_statement  => _require_dep($deps, 'lower_return_imatch_statement'),
  lower_assign_method_statement  => _require_dep($deps, 'lower_assign_method_statement'),
  lower_push_value_statement     => _require_dep($deps, 'lower_push_value_statement'),
  lower_regex_subst_statement    => _require_dep($deps, 'lower_regex_subst_statement'),
  lower_array_pipeline_expr      => _require_dep($deps, 'lower_array_pipeline_expr'),
  lower_if_flow_statement        => _require_dep($deps, 'lower_if_flow_statement'),
  lower_elseif_flow_statement    => _require_dep($deps, 'lower_elseif_flow_statement'),
  lower_else_flow_statement      => _require_dep($deps, 'lower_else_flow_statement'),
  lower_endif_flow_statement     => _require_dep($deps, 'lower_endif_flow_statement'),
  lower_switch_flow_statement    => _require_dep($deps, 'lower_switch_flow_statement'),
  lower_case_flow_statement      => _require_dep($deps, 'lower_case_flow_statement'),
  lower_default_flow_statement   => _require_dep($deps, 'lower_default_flow_statement'),
  lower_endcase_flow_statement   => _require_dep($deps, 'lower_endcase_flow_statement'),
  lower_endswitch_flow_statement => _require_dep($deps, 'lower_endswitch_flow_statement'),
  lower_say_statement            => _require_dep($deps, 'lower_say_statement'),
  lower_print_statement          => _require_dep($deps, 'lower_print_statement'),
  lower_return_undef_statement   => _require_dep($deps, 'lower_return_undef_statement'),
  lower_return_array_statement   => _require_dep($deps, 'lower_return_array_statement'),
  lower_declare_method_statement => _require_dep($deps, 'lower_declare_method_statement'),
 }
}

#------------------------------------------------------------------------------
# Function: _build_call_and_dispatch_contracts
# Purpose : Contracts that dispatch/call parser handlers and push results.
#------------------------------------------------------------------------------
sub _build_call_and_dispatch_contracts {
 my ($label) = @_;
 return [
  {
   id                 => 'call',
   ir_node            => 'CALL',
   diag_name          => 'call',
   unresolved_pattern => qr/\bcall\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcall\s*\(\s*(\w+)\s*\)/&{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_single_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*\)/push \@$label, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)/push \@$2, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_scope_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)/push \@$3, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'assign_call_my',
   ir_node            => 'CALL',
   diag_name          => 'assign_call_my',
   unresolved_pattern => qr/\bmy\s+\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmy\s+(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/my $1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'assign_call',
   ir_node            => 'CALL',
   diag_name          => 'assign_call',
   unresolved_pattern => qr/\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/$1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_call_indexed_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_call_indexed_builtin',
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)\s*->\s*\[\s*\d+\s*\]/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)\s*->\s*\[\s*(\d+)\s*\]/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)->[$3]/g;
    return $code
   },
  },
  {
   id                 => 'push_call_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_call_builtin',
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)(?!\s*->\s*\[)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)(?!\s*->\s*\[)/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'return_call',
   ir_node            => 'CALL',
   diag_name          => 'return_call',
   unresolved_pattern => qr/\breturn\s+call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn\s+call\s*\(\s*(\w+)\s*\)/return &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_return_contracts
# Purpose : Contracts that lower return-related helper surfaces.
#------------------------------------------------------------------------------
sub _build_return_contracts {
 my ($label, $d) = @_;
 return [
  {
   id                 => 'return_a',
   ir_node            => 'RETURN_A',
   diag_name          => 'return_a',
   unresolved_pattern => qr/\breturn_a\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn_a\s*\(\s*$label(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/return ['?$label:', @{[$+{arg} ? "($+{arg}), " : '']}\\\@$label]/g;
    return $code
   },
  },
  {
   id                 => 'return_general',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*(?:\[|\{|\"|'|-?\d+(?:\.\d+)?|scalar\s*\(|array\s*\(|hash\s*\(|flat_array\s*\(|flat_hash\s*\(|flatten\s*\(|flat\s*\()/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_return_general_statement};
    $code =~ s/\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*\w+\s*,/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn\s*\(\s*$label\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+)\s*\)/return ['?$label:', $+{arg}]/g;
    return $code
   },
  },
  {
   id                 => 'return_ma',
   ir_node            => 'RETURN_MA',
   diag_name          => 'return_ma',
   unresolved_pattern => qr/\breturn_ma\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn_ma\s*\(\s*$label\s*\)/return ['?$label:', \@IMATCH_LIST, \\\@$label]/g;
    return $code
   },
  },
  {
   id                 => 'return_m',
   ir_node            => 'RETURN_M',
   diag_name          => 'return_m',
   unresolved_pattern => qr/\breturn_m\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn_m\s*\(\s*$label\s*\)/return ['?$label:', \@IMATCH_LIST]/g;
    return $code
   },
  },
  {
   id                 => 'return_bare',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'return_imatch',
   ir_node            => 'RETURN',
   diag_name          => 'return_imatch',
   unresolved_pattern => qr/\breturn_im(?:atch)?\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_return_imatch_statement};
    $code =~ s/\breturn_im(?:atch)?\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|\"[^\"]*\"|\w+))\s*\)/$lower->($+{tag}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return_undef',
   ir_node            => 'RETURN',
   diag_name          => 'return_undef',
   unresolved_pattern => qr/\breturn_undef\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_return_undef_statement};
    $code =~ s/\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return_array',
   ir_node            => 'RETURN',
   diag_name          => 'return_array',
   unresolved_pattern => qr/\breturn_array\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_return_array_statement};
    $code =~ s/\breturn_array\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|\"[^\"]*\"|\w+))\s*,\s*(?<payload>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\s*\)/$lower->($+{tag}, $+{payload}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_capture_and_backtrack_contracts
# Purpose : Contracts that normalize capture/backtrack helper macros/functions.
#------------------------------------------------------------------------------
sub _build_capture_and_backtrack_contracts {
 my ($label) = @_;
 return [
  {
   id                 => 'capture_macro',
   ir_node            => 'CAPTURE_MACRO',
   diag_name          => 'capture_macro',
   unresolved_pattern => qr/\$CAPTURE\b/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\$CAPTURE\b/substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\)/g;
    return $code
   },
  },
  {
   id                 => 'capture',
   ir_node            => 'CAPTURE',
   diag_name          => 'capture',
   unresolved_pattern => qr/\bcapture\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture\s*\(\s*\w+\s*\)/push \@$label, substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\)/g;
    return $code
   },
  },
  {
   id                 => 'capture_if',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'capture_if',
   unresolved_pattern => qr/\bcapture_if\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bcapture_if\s*\(\s*\w+\s*\)}{my \$capt = substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\); \$capt =~ s/^\s*|\s*$//go; push \@$label, \$capt if \$capt}g;
    return $code
   },
  },
  {
   id                 => 'capture_if_macro',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'CAPTURE_IF',
   unresolved_pattern => qr/\bCAPTURE_IF\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bCAPTURE_IF\s*\(\s*\)}{my \$capt = substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\); \$capt =~ s/^\s*|\s*$//go; push \@$label, \$capt if \$capt}g;
    return $code
   },
  },
  {
   id                 => 'ibacktrack_macro',
   ir_node            => 'IBACKTRACK',
   diag_name          => 'IBACKTRACK',
   unresolved_pattern => qr/\bIBACKTRACK\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bIBACKTRACK\s*\(\s*\)/pos\(\$\$STRING\) = \$IPOS  - length \$IMATCH/g;
    return $code
   },
  },
  {
   id                 => 'backtrack_macro',
   ir_node            => 'BACKTRACK',
   diag_name          => 'BACKTRACK',
   unresolved_pattern => qr/\bBACKTRACK\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bBACKTRACK\s*\(\s*\)/pos\(\$\$STRING\)  = \$LSPOS - length \$LMATCH/g;
    return $code
   },
  },
  {
   id                 => 'ibacktrack',
   ir_node            => 'IBACKTRACK',
   diag_name          => 'ibacktrack',
   unresolved_pattern => qr/\bibacktrack\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bibacktrack\s*\(\s*\w+\s*\)/pos\(\$\$STRING\) = \$IPOS  - length \$IMATCH/g;
    return $code
   },
  },
  {
   id                 => 'backtrack',
   ir_node            => 'BACKTRACK',
   diag_name          => 'backtrack',
   unresolved_pattern => qr/\bbacktrack\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bbacktrack\s*\(\s*\w+\s*\)/pos\(\$\$STRING\)  = \$LSPOS - length \$LMATCH/g;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_passthrough_ir_contracts
# Purpose : Canonical IR-only contracts that do not rewrite source text.
#------------------------------------------------------------------------------
sub _build_passthrough_ir_contracts {
 return [
  { id => 'exit_bare',                       ir_node => 'EXIT',           diag_name => 'exit',              unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'linecount_prefix_newline_matches',ir_node => 'LINE_COUNT',     diag_name => 'line_count',        unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_capture_substr',            ir_node => 'PRINT',          diag_name => 'print',             unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'my_declare_bare',                 ir_node => 'DECLARE',        diag_name => 'declare',           unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'assign_match_my',                 ir_node => 'ASSIGN',         diag_name => 'assign',            unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'destructure_imatch_list_my',      ir_node => 'ASSIGN',         diag_name => 'assign',            unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'regex_subst_assignment',          ir_node => 'REGEX_SUBST',    diag_name => 'substr',            unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'next_bare',                       ir_node => 'NEXT',           diag_name => 'next',              unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'ref_field_assign',                ir_node => 'ASSIGN',         diag_name => 'assign',            unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'position_tracking',               ir_node => 'POSITION_TRACK', diag_name => 'position_tracking', unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_foreach_iterable',          ir_node => 'PRINT',          diag_name => 'print',             unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'split_trim_filter_assignment',    ir_node => 'ASSIGN',         diag_name => 'assign',            unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_assignment_and_regex_contracts
# Purpose : Contracts that lower assignment and substitution helper methods.
#------------------------------------------------------------------------------
sub _build_assignment_and_regex_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'push_value',
   ir_node            => 'PUSH',
   diag_name          => 'push_value',
   unresolved_pattern => qr/\bpush_value\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_push_value_statement};
    $code =~ s/\b(?<expr>push_value\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'assign_value',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => qr/\bassign\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_assign_method_statement};
    $code =~ s/\b(?<expr>assign\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'regex_subst',
   ir_node            => 'REGEX_SUBST',
   diag_name          => 'substr',
   unresolved_pattern => qr/\b(?:substr|regex_subst)\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:scalar\s*\(\s*\w+\s*\)|\w+)\s*,/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_regex_subst_statement};
    $code =~ s/\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:scalar\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/$lower->($+{target}, $+{pattern}, $+{replacement}, $+{flags}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_array_pipeline_contracts
# Purpose : Contracts for array pipeline helper lowering.
#------------------------------------------------------------------------------
sub _build_array_pipeline_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'split_array',
   ir_node            => 'SPLIT',
   diag_name          => 'split',
   unresolved_pattern => qr/\bsplit\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:array\s*\(\s*\w+\s*\)|\w+)\s*,\s*(?:scalar\s*\(\s*\w+\s*\)|\w+)/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'split_each',
   ir_node            => 'SPLIT_EACH',
   diag_name          => 'split_each',
   unresolved_pattern => qr/\bsplit_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>split_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'trim_each',
   ir_node            => 'TRIM_EACH',
   diag_name          => 'trim_each',
   unresolved_pattern => qr/\btrim_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_nonempty',
   ir_node            => 'FILTER_NONEMPTY',
   diag_name          => 'filter_nonempty',
   unresolved_pattern => qr/\bfilter_nonempty\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'lowercase_each',
   ir_node            => 'MAP_LOWERCASE',
   diag_name          => 'lowercase_each',
   unresolved_pattern => qr/\blowercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uppercase_each',
   ir_node            => 'MAP_UPPERCASE',
   diag_name          => 'uppercase_each',
   unresolved_pattern => qr/\buppercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uniq_array',
   ir_node            => 'UNIQ',
   diag_name          => 'uniq',
   unresolved_pattern => qr/\buniq\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_match',
   ir_node            => 'FILTER_MATCH',
   diag_name          => 'filter_match',
   unresolved_pattern => qr/\bfilter_match\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_flow_control_contracts
# Purpose : Contracts that lower structured flow-control helper forms.
#------------------------------------------------------------------------------
sub _build_flow_control_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'if_flow',
   ir_node            => 'IF',
   diag_name          => 'if',
   unresolved_pattern => qr/\b(?:if|i)\((?<PAREN>(?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|\((?&PAREN)*\))*)\)(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_if_flow_statement};
    $code =~ s/\b(?<expr>(?:if|i)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'elseif_flow',
   ir_node            => 'ELIF',
   diag_name          => 'elseif',
   unresolved_pattern => qr/\b(?:elif|elseif)\((?<PAREN>(?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|\((?&PAREN)*\))*)\)(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_elseif_flow_statement};
    $code =~ s/\b(?<expr>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'else_flow',
   ir_node            => 'ELSE',
   diag_name          => 'else',
   unresolved_pattern => qr/(?:^\s*else\b\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?\s*$|^\s*else\s*$)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_else_flow_statement};
    $code =~ s/^\s*(?<expr>else\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endif_flow',
   ir_node            => 'ENDIF',
   diag_name          => 'endif',
   unresolved_pattern => qr/^\s*endif\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endif_flow_statement};
    $code =~ s/^\s*(?<expr>endif\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'switch_flow',
   ir_node            => 'SWITCH',
   diag_name          => 'switch',
   unresolved_pattern => qr/\bswitch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_switch_flow_statement};
    $code =~ s/\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'case_flow',
   ir_node            => 'CASE',
   diag_name          => 'case',
   unresolved_pattern => qr/\bcase\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_case_flow_statement};
    $code =~ s/\b(?<expr>case\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'default_flow',
   ir_node            => 'DEFAULT',
   diag_name          => 'default',
   unresolved_pattern => qr/(?:^\s*default\b\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?\s*$|^\s*default\s*$)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_default_flow_statement};
    $code =~ s/^\s*(?<expr>default\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endcase_flow',
   ir_node            => 'ENDCASE',
   diag_name          => 'endcase',
   unresolved_pattern => qr/^\s*endcase\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endcase_flow_statement};
    $code =~ s/^\s*(?<expr>endcase\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endswitch_flow',
   ir_node            => 'ENDSWITCH',
   diag_name          => 'endswitch',
   unresolved_pattern => qr/^\s*endswitch\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endswitch_flow_statement};
    $code =~ s/^\s*(?<expr>endswitch\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_emit_and_declare_contracts
# Purpose : Contracts for output statements and declaration lowering.
#------------------------------------------------------------------------------
sub _build_emit_and_declare_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'say_stmt',
   ir_node            => 'SAY',
   diag_name          => 'say',
   unresolved_pattern => qr/\bsay\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_say_statement};
    $code =~ s/\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'print_stmt',
   ir_node            => 'PRINT',
   diag_name          => 'print',
   unresolved_pattern => qr/\bprint\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_print_statement};
    $code =~ s/\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'declare_typed',
   ir_node            => 'DECLARE',
   diag_name          => 'declare',
   unresolved_pattern => qr/\bdeclare\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_declare_method_statement};
    $code =~ s/\b(?<expr>declare\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'declare_alias',
   ir_node            => 'DECLARE',
   diag_name          => 'declare',
   unresolved_pattern => qr/\bdeclare_(?:a|array|s|scalar|h|hash)\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_declare_method_statement};
    $code =~ s/\b(?<expr>declare_(?:a|array|s|scalar|h|hash)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: build_action_lowering_contracts
# Purpose : Build all lowering contracts by composing responsibility-specific
#           contract groups.
#------------------------------------------------------------------------------
sub build_action_lowering_contracts {
 my ($label, $deps) = @_;
 my $d = _require_lowering_deps($deps);
 return [
  @{_build_call_and_dispatch_contracts($label)},
  @{_build_return_contracts($label, $d)},
  @{_build_capture_and_backtrack_contracts($label)},
  @{_build_passthrough_ir_contracts()},
  @{_build_assignment_and_regex_contracts($d)},
  @{_build_array_pipeline_contracts($d)},
  @{_build_flow_control_contracts($d)},
  @{_build_emit_and_declare_contracts($d)},
 ]
}

1;
