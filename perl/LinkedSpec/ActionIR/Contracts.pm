#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Contracts
# Purpose: ActionIR contract catalog owner for helper scanning metadata and
#          lowering-entry dispatch across the supported DSL surface.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Contracts;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default contracts dependency bundle for one owner
#           package.
# Args    : ($pkg)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'lower_return_general_statement',
   'lower_assign_method_statement',
   'lower_push_value_statement',
   'lower_push_nonempty_statement',
   'lower_regex_subst_statement',
   'lower_array_pipeline_expr',
   'lower_if_flow_statement',
   'lower_elseif_flow_statement',
   'lower_else_flow_statement',
   'lower_endif_flow_statement',
   'lower_switch_flow_statement',
   'lower_case_flow_statement',
   'lower_default_flow_statement',
   'lower_endcase_flow_statement',
   'lower_endswitch_flow_statement',
   'lower_say_statement',
   'lower_print_statement',
   'lower_print_each_statement',
   'lower_return_undef_statement',
   'lower_declare_method_statement',
   'lower_method_value_expr',
  ],
 )
}

sub _require_lowering_deps {
 my ($deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::Contracts::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb
 };
 return {
  lower_return_general_statement => $require_dep->('lower_return_general_statement'),
  lower_assign_method_statement  => $require_dep->('lower_assign_method_statement'),
  lower_push_value_statement     => $require_dep->('lower_push_value_statement'),
  lower_push_nonempty_statement  => $require_dep->('lower_push_nonempty_statement'),
  lower_regex_subst_statement    => $require_dep->('lower_regex_subst_statement'),
  lower_array_pipeline_expr      => $require_dep->('lower_array_pipeline_expr'),
  lower_if_flow_statement        => $require_dep->('lower_if_flow_statement'),
  lower_elseif_flow_statement    => $require_dep->('lower_elseif_flow_statement'),
  lower_else_flow_statement      => $require_dep->('lower_else_flow_statement'),
  lower_endif_flow_statement     => $require_dep->('lower_endif_flow_statement'),
  lower_switch_flow_statement    => $require_dep->('lower_switch_flow_statement'),
  lower_case_flow_statement      => $require_dep->('lower_case_flow_statement'),
  lower_default_flow_statement   => $require_dep->('lower_default_flow_statement'),
  lower_endcase_flow_statement   => $require_dep->('lower_endcase_flow_statement'),
  lower_endswitch_flow_statement => $require_dep->('lower_endswitch_flow_statement'),
  lower_say_statement            => $require_dep->('lower_say_statement'),
  lower_print_statement          => $require_dep->('lower_print_statement'),
  lower_print_each_statement     => $require_dep->('lower_print_each_statement'),
  lower_return_undef_statement   => $require_dep->('lower_return_undef_statement'),
  lower_declare_method_statement => $require_dep->('lower_declare_method_statement'),
  lower_method_value_expr        => $require_dep->('lower_method_value_expr'),
 }
}

sub _build_mark_trace_call {
 my (%args) = @_;
 return '_trace_runtime_mark_event('
  ."operation => '$args{operation}', "
  ."rule_label => '$args{label}', "
  ."mark_name => '$args{mark_name}', "
  ."string_ref => \$STRING, "
  ."mark_pos => $args{mark_pos_expr}, "
  ."left_edge => \$LSPOS - length \$LMATCH, "
  ."parser_pos => pos \$\$STRING"
  .')'
}

#------------------------------------------------------------------------------
# Function: _build_column_read_expr
# Purpose : Build one shared 1-based column-read expression from a position
#           expression over the current input string.
# Args    : (%args)
# Returns : emitted Perl expression string
#------------------------------------------------------------------------------
sub _build_column_read_expr {
 my (%args) = @_;
 my $pos_expr = $args{pos_expr};
 my $undef_to_zero = $args{undef_to_zero} ? 1 : 0;
 return 'do { my $__ls_col_pos = '.$pos_expr.'; '
  .($undef_to_zero ? '$__ls_col_pos = 0 unless defined($__ls_col_pos); ' : '')
  .'if (defined($__ls_col_pos)) { my $__ls_col_prefix = substr($$STRING, 0, $__ls_col_pos); my $__ls_col_last_newline = rindex($__ls_col_prefix, "\n"); ($__ls_col_last_newline >= 0) ? ($__ls_col_pos - $__ls_col_last_newline) : ($__ls_col_pos + 1) } else { undef } }'
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
   id                 => 'push_indexed_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\d+)\s*\)/push \@$label, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)->[$2]/g;
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
   id                 => 'push_target_indexed_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*,\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d+)\s*\)/push \@$2, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)->[$3]/g;
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
   compatibility_surface => 1,
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
   compatibility_surface => 1,
   unresolved_pattern => qr/\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/$1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_child_call_indexed_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_child_call_indexed_builtin',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)\s*->\s*\[\s*\d+\s*\]/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)\s*->\s*\[\s*(\d+)\s*\]/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)->[$3]/g;
    return $code
   },
  },
  {
   id                 => 'push_child_call_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_child_call_builtin',
   compatibility_surface => 1,
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
   compatibility_surface => 1,
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
   id                 => 'return_general',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*(?:\[|\{|\"|'|-?\d+(?:\.\d+)?|(?:scalar|s)\s*\(|(?:array|a)\s*\(|(?:hash|h)\s*\(|flat_array\s*\(|flat_hash\s*\(|flat\s*\(|(?:entry_text|match_text|entry_group|match_group|entry_groups|match_groups|input_text|input_len|input_slice)\s*\()/o,
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
   id                 => 'return_bare',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   compatibility_surface => 1,
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
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
 ]
}

#------------------------------------------------------------------------------
# Function: _build_capture_and_backtrack_contracts
# Purpose : Contracts that normalize capture/backtrack helper macros/functions.
#------------------------------------------------------------------------------
sub _build_capture_and_backtrack_contracts {
 my ($label, $d) = @_;
 $d = {} unless ref($d) eq 'HASH';
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
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_if\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bcapture_if\s*\(\s*\w+\s*\)}{q{my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @} . $label . q{, $capt if $capt}}ge;
    return $code
   },
  },
  {
   id                 => 'capture_if_macro',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'CAPTURE_IF',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bCAPTURE_IF\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bCAPTURE_IF\s*\(\s*\)}{q{my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @} . $label . q{, $capt if $capt}}ge;
    return $code
   },
  },
  {
   id                 => 'capture_slice',
   ir_node            => 'CAPTURE_SLICE',
   diag_name          => 'capture_slice',
   unresolved_pattern => qr/\bcapture_slice\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice\s*\(\s*\)
    }{
     'do { substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_len',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   unresolved_pattern => qr/\bcapture_slice_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_len\s*\(\s*\)
    }{
     'do { ($LSPOS - $IPOS - length $LMATCH) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_until_cursor',
   ir_node            => 'CAPTURE_SLICE_UNTIL_CURSOR',
   diag_name          => 'capture_slice_until_cursor',
   unresolved_pattern => qr/\bcapture_slice_until_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_until_cursor\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) ? substr($$STRING, $IPOS, $__ls_cursor - $IPOS) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_until_cursor_len',
   ir_node            => 'CAPTURE_SLICE_UNTIL_CURSOR_LEN',
   diag_name          => 'capture_slice_until_cursor_len',
   unresolved_pattern => qr/\bcapture_slice_until_cursor_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_until_cursor_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) ? ($__ls_cursor - $IPOS) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor',
   ir_node            => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR',
   diag_name          => 'capture_take_until_cursor',
   unresolved_pattern => qr/\bcapture_take_until_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; if (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) { my $__ls_capture = substr($$STRING, $IPOS, $__ls_cursor - $IPOS); $IPOS = $__ls_cursor; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_len',
   ir_node            => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR_LEN',
   diag_name          => 'capture_take_until_cursor_len',
   unresolved_pattern => qr/\bcapture_take_until_cursor_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; if (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) { my $__ls_capture_len = ($__ls_cursor - $IPOS); $IPOS = $__ls_cursor; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_line',
   ir_node            => 'CAPTURE_SLICE_LINE_READ',
   diag_name          => 'capture_slice_line',
   unresolved_pattern => qr/\bcapture_slice_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_line\s*\(\s*\)/do { my \$__ls_capture_pos = defined(\$IPOS) ? \$IPOS : 0; 1 + (() = substr(\$\$STRING, 0, \$__ls_capture_pos) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'capture_slice_col',
   ir_node            => 'CAPTURE_SLICE_COL_READ',
   diag_name          => 'capture_slice_col',
   unresolved_pattern => qr/\bcapture_slice_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$IPOS', undef_to_zero => 1)/gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_pos',
   ir_node            => 'CAPTURE_SLICE_POS_READ',
   diag_name          => 'capture_slice_pos',
   unresolved_pattern => qr/\bcapture_slice_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_pos\s*\(\s*\)/do { \$IPOS }/g;
    return $code
   },
  },
  {
   id                 => 'capture_slice_length',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_slice_length\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_length\s*\(\s*\)
    }{
     'do { ($LSPOS - $IPOS - length $LMATCH) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'start_capture_slice',
   ir_node            => 'CAPTURE_SLICE_START',
   diag_name          => 'start_capture_slice',
   unresolved_pattern => qr/\bstart_capture_slice\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bstart_capture_slice\s*\(\s*\)
    }{
     'do { $IPOS = pos $$STRING }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'start_capture_slice_from_mark',
   ir_node            => 'CAPTURE_SLICE_START_FROM_MARK',
   diag_name          => 'start_capture_slice_from',
   unresolved_pattern => qr/\bstart_capture_slice_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bstart_capture_slice_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? ($IPOS = $__ls_mark) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_here',
   ir_node            => 'CAPTURE_SLICE_START',
   diag_name          => 'start_capture_slice',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_slice_here\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_here\s*\(\s*\)
    }{
     'do { $IPOS = pos $$STRING }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest',
   ir_node            => 'CAPTURE_REST',
   diag_name          => 'capture_rest',
   unresolved_pattern => qr/\bcapture_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest\s*\(\s*\)
    }{
     'do { substr($$STRING, $IPOS, length($$STRING) - $IPOS) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_len',
   ir_node            => 'CAPTURE_REST_LEN',
   diag_name          => 'capture_rest_len',
   unresolved_pattern => qr/\bcapture_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_len\s*\(\s*\)
    }{
     'do { (length($$STRING) - $IPOS) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_length',
   ir_node            => 'CAPTURE_REST_LEN',
   diag_name          => 'capture_rest_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_rest_length\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_length\s*\(\s*\)
    }{
     'do { (length($$STRING) - $IPOS) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest',
   ir_node            => 'CAPTURE_REST_TAKE',
   diag_name          => 'capture_take_rest',
   unresolved_pattern => qr/\bcapture_take_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest\s*\(\s*\)
    }{
     'do { my $__ls_end = length($$STRING); if (defined($IPOS) && $__ls_end >= $IPOS) { my $__ls_capture = substr($$STRING, $IPOS, $__ls_end - $IPOS); $IPOS = $__ls_end; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_len',
   ir_node            => 'CAPTURE_REST_TAKE_LEN',
   diag_name          => 'capture_take_rest_len',
   unresolved_pattern => qr/\bcapture_take_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_len\s*\(\s*\)
    }{
     'do { my $__ls_end = length($$STRING); if (defined($IPOS) && $__ls_end >= $IPOS) { my $__ls_capture_len = ($__ls_end - $IPOS); $IPOS = $__ls_end; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_slice',
   ir_node            => 'CAPTURE_SLICE_TAKE',
   diag_name          => 'capture_take',
   unresolved_pattern => qr/\bcapture_take\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take\s*\(\s*\)
    }{
     'do { my $__ls_capture = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $IPOS = pos $$STRING; $__ls_capture }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_slice_len',
   ir_node            => 'CAPTURE_SLICE_TAKE_LEN',
   diag_name          => 'capture_take_len',
   unresolved_pattern => qr/\bcapture_take_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_len\s*\(\s*\)
    }{
     'do { my $__ls_capture_len = ($LSPOS - $IPOS - length $LMATCH); $IPOS = pos $$STRING; $__ls_capture_len }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_from_rule_start',
   ir_node            => 'CAPTURE_SLICE',
   diag_name          => 'capture_slice',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_from_rule_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_from_rule_start\s*\(\s*\)
    }{
     'do { substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_from_rule_start',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_len_from_rule_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_from_rule_start\s*\(\s*\)
    }{
     'do { ($LSPOS - $IPOS - length $LMATCH) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_from_mark',
   ir_node            => 'CAPTURE_FROM_MARK',
   diag_name          => 'capture_from',
   unresolved_pattern => qr/\bcapture_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? substr($$STRING, $__ls_mark, $LSPOS - $__ls_mark - length $LMATCH) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_from_mark',
   ir_node            => 'CAPTURE_LEN_FROM_MARK',
   diag_name          => 'capture_len_from',
   unresolved_pattern => qr/\bcapture_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? ($LSPOS - $__ls_mark - length $LMATCH) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_from_mark',
   ir_node            => 'CAPTURE_TAKE_FROM_MARK',
   diag_name          => 'capture_take',
   unresolved_pattern => qr/\bcapture_take\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; if (defined($__ls_mark)) { my $__ls_capture = substr($$STRING, $__ls_mark, $LSPOS - $__ls_mark - length $LMATCH); $__ls_mark_bucket->{\''.$+{mark}.'\'} = pos $$STRING; '. _build_mark_trace_call(operation => 'capture_take', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_LEN_FROM_MARK',
   diag_name          => 'capture_take_len_from',
   unresolved_pattern => qr/\bcapture_take_len_from\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; if (defined($__ls_mark)) { my $__ls_capture_len = ($LSPOS - $__ls_mark - length $LMATCH); $__ls_mark_bucket->{\''.$+{mark}.'\'} = pos $$STRING; '. _build_mark_trace_call(operation => 'capture_take_len_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_from_mark',
   ir_node            => 'CAPTURE_REST_FROM_MARK',
   diag_name          => 'capture_rest_from',
   unresolved_pattern => qr/\bcapture_rest_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? substr($$STRING, $__ls_mark, length($$STRING) - $__ls_mark) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_len_from_mark',
   ir_node            => 'CAPTURE_REST_LEN_FROM_MARK',
   diag_name          => 'capture_rest_len_from',
   unresolved_pattern => qr/\bcapture_rest_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? (length($$STRING) - $__ls_mark) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_from_mark',
   ir_node            => 'CAPTURE_TAKE_REST_FROM_MARK',
   diag_name          => 'capture_take_rest_from',
   unresolved_pattern => qr/\bcapture_take_rest_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_end = length($$STRING); if (defined($__ls_mark) && $__ls_end >= $__ls_mark) { my $__ls_capture = substr($$STRING, $__ls_mark, $__ls_end - $__ls_mark); $__ls_mark_bucket->{\''.$+{mark}.'\'} = $__ls_end; '. _build_mark_trace_call(operation => 'capture_take_rest_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_REST_LEN_FROM_MARK',
   diag_name          => 'capture_take_rest_len_from',
   unresolved_pattern => qr/\bcapture_take_rest_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_end = length($$STRING); if (defined($__ls_mark) && $__ls_end >= $__ls_mark) { my $__ls_capture_len = ($__ls_end - $__ls_mark); $__ls_mark_bucket->{\''.$+{mark}.'\'} = $__ls_end; '. _build_mark_trace_call(operation => 'capture_take_rest_len_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_until_cursor_from_mark',
   ir_node            => 'CAPTURE_UNTIL_CURSOR_FROM_MARK',
   diag_name          => 'capture_until_cursor_from',
   unresolved_pattern => qr/\bcapture_until_cursor_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_until_cursor_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_cursor = pos $$STRING; (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) ? substr($$STRING, $__ls_mark, $__ls_cursor - $__ls_mark) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_until_cursor_len_from_mark',
   ir_node            => 'CAPTURE_UNTIL_CURSOR_LEN_FROM_MARK',
   diag_name          => 'capture_until_cursor_len_from',
   unresolved_pattern => qr/\bcapture_until_cursor_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_until_cursor_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_cursor = pos $$STRING; (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) ? ($__ls_cursor - $__ls_mark) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_from_mark',
   ir_node            => 'CAPTURE_TAKE_UNTIL_CURSOR_FROM_MARK',
   diag_name          => 'capture_take_until_cursor_from',
   unresolved_pattern => qr/\bcapture_take_until_cursor_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_cursor = pos $$STRING; if (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) { my $__ls_capture = substr($$STRING, $__ls_mark, $__ls_cursor - $__ls_mark); $__ls_mark_bucket->{\''.$+{mark}.'\'} = $__ls_cursor; '. _build_mark_trace_call(operation => 'capture_take_until_cursor', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_UNTIL_CURSOR_LEN_FROM_MARK',
   diag_name          => 'capture_take_until_cursor_len_from',
   unresolved_pattern => qr/\bcapture_take_until_cursor_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; my $__ls_cursor = pos $$STRING; if (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) { my $__ls_capture_len = ($__ls_cursor - $__ls_mark); $__ls_mark_bucket->{\''.$+{mark}.'\'} = $__ls_cursor; '. _build_mark_trace_call(operation => 'capture_take_until_cursor_len', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{mark}.'\'}') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_between_marks',
   ir_node            => 'CAPTURE_BETWEEN_MARKS',
   diag_name          => 'capture_between',
   unresolved_pattern => qr/\bcapture_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_start = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{start}.'\'} : undef; my $__ls_end = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{end}.'\'} : undef; (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) ? substr($$STRING, $__ls_start, $__ls_end - $__ls_start) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_between_marks',
   ir_node            => 'CAPTURE_LEN_BETWEEN_MARKS',
   diag_name          => 'capture_len_between',
   unresolved_pattern => qr/\bcapture_len_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_start = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{start}.'\'} : undef; my $__ls_end = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{end}.'\'} : undef; (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) ? ($__ls_end - $__ls_start) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_between_marks',
   ir_node            => 'CAPTURE_TAKE_BETWEEN_MARKS',
   diag_name          => 'capture_take_between',
   unresolved_pattern => qr/\bcapture_take_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_start = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{start}.'\'} : undef; my $__ls_end = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{end}.'\'} : undef; if (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) { my $__ls_capture = substr($$STRING, $__ls_start, $__ls_end - $__ls_start); $__ls_mark_bucket->{\''.$+{start}.'\'} = $__ls_end; '. _build_mark_trace_call(operation => 'capture_take_between', label => $label, mark_name => $+{start}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{start}.'\'}') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_between_len_marks',
   ir_node            => 'CAPTURE_TAKE_BETWEEN_LEN_MARKS',
   diag_name          => 'capture_take_between_len',
   unresolved_pattern => qr/\bcapture_take_between_len\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_between_len\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_start = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{start}.'\'} : undef; my $__ls_end = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{end}.'\'} : undef; if (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) { my $__ls_capture_len = ($__ls_end - $__ls_start); $__ls_mark_bucket->{\''.$+{start}.'\'} = $__ls_end; '. _build_mark_trace_call(operation => 'capture_take_between_len', label => $label, mark_name => $+{start}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{start}.'\'}') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_input_start',
   ir_node            => 'MARK_INPUT_START',
   diag_name          => 'mark_input_start',
   unresolved_pattern => qr/\bmark_input_start\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_input_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = 0; '. _build_mark_trace_call(operation => 'mark_input_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; 1 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_input_end',
   ir_node            => 'MARK_INPUT_END',
   diag_name          => 'mark_input_end',
   unresolved_pattern => qr/\bmark_input_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_input_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = length($$STRING); '. _build_mark_trace_call(operation => 'mark_input_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; 1 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_here',
   ir_node            => 'MARK_HERE',
   diag_name          => 'mark_here',
   unresolved_pattern => qr/\bmark_here\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_here\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = pos $$STRING; '. _build_mark_trace_call(operation => 'mark_here', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_entry_start',
   ir_node            => 'MARK_ENTRY_START',
   diag_name          => 'mark_entry_start',
   unresolved_pattern => qr/\bmark_entry_start\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_entry_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = $IPOS - length $IMATCH; '. _build_mark_trace_call(operation => 'mark_entry_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_entry_end',
   ir_node            => 'MARK_ENTRY_END',
   diag_name          => 'mark_entry_end',
   unresolved_pattern => qr/\bmark_entry_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_entry_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = $IPOS; '. _build_mark_trace_call(operation => 'mark_entry_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_match_start',
   ir_node            => 'MARK_MATCH_START',
   diag_name          => 'mark_match_start',
   unresolved_pattern => qr/\bmark_match_start\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_match_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = $LSPOS - length $LMATCH; '. _build_mark_trace_call(operation => 'mark_match_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_match_end',
   ir_node            => 'MARK_MATCH_END',
   diag_name          => 'mark_match_end',
   unresolved_pattern => qr/\bmark_match_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_match_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = $LSPOS; '. _build_mark_trace_call(operation => 'mark_match_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_copy',
   ir_node            => 'MARK_COPY',
   diag_name          => 'mark_copy',
   unresolved_pattern => qr/\bmark_copy\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_copy\s*\(\s*(?<target>\w+)\s*,\s*(?<source>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; my $__ls_mark_bucket = $$info{marks}{\''.$label.'\'}; if (exists $__ls_mark_bucket->{\''.$+{source}.'\'}) { $__ls_mark_bucket->{\''.$+{target}.'\'} = $__ls_mark_bucket->{\''.$+{source}.'\'}; '. _build_mark_trace_call(operation => 'mark_copy', label => $label, mark_name => $+{target}, mark_pos_expr => '$__ls_mark_bucket->{\''.$+{target}.'\'}') .'; $__ls_mark_bucket->{\''.$+{target}.'\'} } else { delete $__ls_mark_bucket->{\''.$+{target}.'\'}; undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_capture_slice',
   ir_node            => 'MARK_CAPTURE_SLICE',
   diag_name          => 'mark_capture_slice',
   unresolved_pattern => qr/\bmark_capture_slice\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_capture_slice\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { $$info{marks}{\''.$label.'\'} = {} unless ref($$info{marks}{\''.$label.'\'}) eq \'HASH\'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} = $IPOS; '. _build_mark_trace_call(operation => 'mark_capture_slice', label => $label, mark_name => $+{mark}, mark_pos_expr => '$$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}') .'; $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'} }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'clear_mark',
   ir_node            => 'CLEAR_MARK',
   diag_name          => 'clear_mark',
   unresolved_pattern => qr/\bclear_mark\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bclear_mark\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { if (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') { delete $$info{marks}{\''.$label.'\'}{\''.$+{mark}.'\'}; } undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_exists',
   ir_node            => 'MARK_EXISTS',
   diag_name          => 'mark_exists',
   unresolved_pattern => qr/\bmark_exists\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_exists\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; (ref($__ls_mark_bucket) eq \'HASH\' && exists $__ls_mark_bucket->{\''.$+{mark}.'\'}) ? 1 : 0 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_pos',
   ir_node            => 'MARK_POS_READ',
   diag_name          => 'mark_pos',
   unresolved_pattern => qr/\bmark_pos\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_pos\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; (ref($__ls_mark_bucket) eq \'HASH\' && exists $__ls_mark_bucket->{\''.$+{mark}.'\'}) ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_line',
   ir_node            => 'MARK_LINE_READ',
   diag_name          => 'mark_line',
   unresolved_pattern => qr/\bmark_line\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_line\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; defined($__ls_mark) ? (1 + (() = substr($$STRING, 0, $__ls_mark) =~ /\\n/g)) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_col',
   ir_node            => 'MARK_COL_READ',
   diag_name          => 'mark_col',
   unresolved_pattern => qr/\bmark_col\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_col\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark_bucket = (ref($$info{marks}) eq \'HASH\' && ref($$info{marks}{\''.$label.'\'}) eq \'HASH\') ? $$info{marks}{\''.$label.'\'} : undef; my $__ls_mark = (ref($__ls_mark_bucket) eq \'HASH\') ? $__ls_mark_bucket->{\''.$+{mark}.'\'} : undef; '. _build_column_read_expr(pos_expr => '$__ls_mark') .' }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'cursor_pos',
   ir_node            => 'CURSOR_POS_READ',
   diag_name          => 'cursor_pos',
   unresolved_pattern => qr/\bcursor_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_pos\s*\(\s*\)/do { pos \$\$STRING }/g;
    return $code
   },
  },
  {
   id                 => 'cursor_line',
   ir_node            => 'CURSOR_LINE_READ',
   diag_name          => 'cursor_line',
   unresolved_pattern => qr/\bcursor_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_line\s*\(\s*\)/do { my \$__ls_cursor_pos = pos \$\$STRING; 1 + (() = substr(\$\$STRING, 0, defined(\$__ls_cursor_pos) ? \$__ls_cursor_pos : 0) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'cursor_col',
   ir_node            => 'CURSOR_COL_READ',
   diag_name          => 'cursor_col',
   unresolved_pattern => qr/\bcursor_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_col\s*\(\s*\)/_build_column_read_expr(pos_expr => 'pos $$STRING', undef_to_zero => 1)/gex;
    return $code
   },
  },
  {
   id                 => 'cursor_rest',
   ir_node            => 'CURSOR_REST',
   diag_name          => 'cursor_rest',
   unresolved_pattern => qr/\bcursor_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcursor_rest\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; defined($__ls_cursor) ? substr($$STRING, $__ls_cursor, length($$STRING) - $__ls_cursor) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'cursor_rest_len',
   ir_node            => 'CURSOR_REST_LEN',
   diag_name          => 'cursor_rest_len',
   unresolved_pattern => qr/\bcursor_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcursor_rest_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; defined($__ls_cursor) ? (length($$STRING) - $__ls_cursor) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'input_slice',
   ir_node            => 'INPUT_SLICE_READ',
   diag_name          => 'input_slice',
   unresolved_pattern => qr/\binput_slice\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_method_value_expr};
    return $code unless ref($lower) eq 'CODE';
    $code =~ s/\b(?<expr>input_slice\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'input_text',
   ir_node            => 'INPUT_TEXT_READ',
   diag_name          => 'input_text',
   unresolved_pattern => qr/\binput_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_text\s*\(\s*\)/do { \$\$STRING }/g;
    return $code
   },
  },
  {
   id                 => 'input_len',
   ir_node            => 'INPUT_LEN_READ',
   diag_name          => 'input_len',
   unresolved_pattern => qr/\binput_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_len\s*\(\s*\)/do { length\(\$\$STRING\) }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_pos',
   ir_node            => 'INPUT_END_POS_READ',
   diag_name          => 'input_end_pos',
   unresolved_pattern => qr/\binput_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_pos\s*\(\s*\)/do { length\(\$\$STRING\) }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_line',
   ir_node            => 'INPUT_END_LINE_READ',
   diag_name          => 'input_end_line',
   unresolved_pattern => qr/\binput_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, length(\$\$STRING)) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_col',
   ir_node            => 'INPUT_END_COL_READ',
   diag_name          => 'input_end_col',
   unresolved_pattern => qr/\binput_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_col\s*\(\s*\)/_build_column_read_expr(pos_expr => 'length($$STRING)', undef_to_zero => 1)/gex;
    return $code
   },
  },
  {
   id                 => 'entry_text',
   ir_node            => 'IMATCH_TEXT_READ',
   diag_name          => 'entry_text',
   unresolved_pattern => qr/\bentry_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_text\s*\(\s*\)/do { \$IMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'entry_group',
   ir_node            => 'IMATCH_GROUP_READ',
   diag_name          => 'entry_group',
   unresolved_pattern => qr/\bentry_group\s*\(\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_group\s*\(\s*(?<index>\d+)\s*\)
    }{
     'do { scalar(@IMATCH_LIST) > '.$+{index}.' ? $IMATCH_LIST['.$+{index}.'] : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_groups',
   ir_node            => 'IMATCH_GROUPS_READ',
   diag_name          => 'entry_groups',
   unresolved_pattern => qr/\bentry_groups\s*\(\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_groups\s*\(\s*\)/do { [\@IMATCH_LIST] }/g;
    return $code
   },
  },
  {
   id                 => 'entry_named',
   ir_node            => 'IMATCH_NAMED_READ',
   diag_name          => 'entry_named',
   unresolved_pattern => qr/\bentry_named\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_named\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { exists $IMATCH_HASH{\''.$+{name}.'\'} ? $IMATCH_HASH{\''.$+{name}.'\'} : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_has',
   ir_node            => 'IMATCH_NAMED_EXISTS',
   diag_name          => 'entry_has',
   unresolved_pattern => qr/\bentry_has\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_has\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { exists $IMATCH_HASH{\''.$+{name}.'\'} ? 1 : 0 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_map',
   ir_node            => 'IMATCH_NAMED_MAP_READ',
   diag_name          => 'entry_map',
   unresolved_pattern => qr/\bentry_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_map\s*\(\s*\)/do { +{\%IMATCH_HASH} }/g;
    return $code
   },
  },
  {
   id                 => 'entry_named_map',
   ir_node            => 'IMATCH_NAMED_MAP_READ',
   diag_name          => 'entry_named_map',
   unresolved_pattern => qr/\bentry_named_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_named_map\s*\(\s*\)/do { +{\%IMATCH_HASH} }/g;
    return $code
   },
  },
  {
   id                 => 'entry_line',
   ir_node            => 'IMATCH_LINE_READ',
   diag_name          => 'entry_line',
   unresolved_pattern => qr/\bentry_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$IPOS - length \$IMATCH) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_start_line',
   ir_node            => 'IMATCH_START_LINE_READ',
   diag_name          => 'entry_start_line',
   unresolved_pattern => qr/\bentry_start_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$IPOS - length \$IMATCH) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_col',
   ir_node            => 'IMATCH_COL_READ',
   diag_name          => 'entry_col',
   unresolved_pattern => qr/\bentry_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$IPOS - length $IMATCH')/gex;
    return $code
   },
  },
  {
   id                 => 'entry_start_col',
   ir_node            => 'IMATCH_START_COL_READ',
   diag_name          => 'entry_start_col',
   unresolved_pattern => qr/\bentry_start_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$IPOS - length $IMATCH')/gex;
    return $code
   },
  },
  {
   id                 => 'entry_len',
   ir_node            => 'IMATCH_LEN_READ',
   diag_name          => 'entry_len',
   unresolved_pattern => qr/\bentry_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_len\s*\(\s*\)/do { length \$IMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'entry_start_pos',
   ir_node            => 'IMATCH_START_POS_READ',
   diag_name          => 'entry_start_pos',
   unresolved_pattern => qr/\bentry_start_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_pos\s*\(\s*\)/do { \$IPOS - length \$IMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_pos',
   ir_node            => 'IMATCH_END_POS_READ',
   diag_name          => 'entry_end_pos',
   unresolved_pattern => qr/\bentry_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_pos\s*\(\s*\)/do { \$IPOS }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_line',
   ir_node            => 'IMATCH_END_LINE_READ',
   diag_name          => 'entry_end_line',
   unresolved_pattern => qr/\bentry_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$IPOS) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_col',
   ir_node            => 'IMATCH_END_COL_READ',
   diag_name          => 'entry_end_col',
   unresolved_pattern => qr/\bentry_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$IPOS', undef_to_zero => 1)/gex;
    return $code
   },
  },
  {
   id                 => 'match_start_pos',
   ir_node            => 'MATCH_START_POS_READ',
   diag_name          => 'match_start_pos',
   unresolved_pattern => qr/\bmatch_start_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_pos\s*\(\s*\)/do { \$LSPOS - length \$LMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'match_text',
   ir_node            => 'MATCH_TEXT_READ',
   diag_name          => 'match_text',
   unresolved_pattern => qr/\bmatch_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_text\s*\(\s*\)/do { \$LMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'match_group',
   ir_node            => 'MATCH_GROUP_READ',
   diag_name          => 'match_group',
   unresolved_pattern => qr/\bmatch_group\s*\(\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_group\s*\(\s*(?<index>\d+)\s*\)
    }{
     'do { scalar(@LMATCH_LIST) > '.$+{index}.' ? $LMATCH_LIST['.$+{index}.'] : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_groups',
   ir_node            => 'MATCH_GROUPS_READ',
   diag_name          => 'match_groups',
   unresolved_pattern => qr/\bmatch_groups\s*\(\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_groups\s*\(\s*\)/do { [\@LMATCH_LIST] }/g;
    return $code
   },
  },
  {
   id                 => 'match_named',
   ir_node            => 'MATCH_NAMED_READ',
   diag_name          => 'match_named',
   unresolved_pattern => qr/\bmatch_named\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_named\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { exists $LMATCH_HASH{\''.$+{name}.'\'} ? $LMATCH_HASH{\''.$+{name}.'\'} : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_has',
   ir_node            => 'MATCH_NAMED_EXISTS',
   diag_name          => 'match_has',
   unresolved_pattern => qr/\bmatch_has\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_has\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { exists $LMATCH_HASH{\''.$+{name}.'\'} ? 1 : 0 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_map',
   ir_node            => 'MATCH_NAMED_MAP_READ',
   diag_name          => 'match_map',
   unresolved_pattern => qr/\bmatch_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_map\s*\(\s*\)/do { +{\%LMATCH_HASH} }/g;
    return $code
   },
  },
  {
   id                 => 'match_named_map',
   ir_node            => 'MATCH_NAMED_MAP_READ',
   diag_name          => 'match_named_map',
   unresolved_pattern => qr/\bmatch_named_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_named_map\s*\(\s*\)/do { +{\%LMATCH_HASH} }/g;
    return $code
   },
  },
  {
   id                 => 'match_len',
   ir_node            => 'MATCH_LEN_READ',
   diag_name          => 'match_len',
   unresolved_pattern => qr/\bmatch_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_len\s*\(\s*\)/do { length \$LMATCH }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_pos',
   ir_node            => 'MATCH_END_POS_READ',
   diag_name          => 'match_end_pos',
   unresolved_pattern => qr/\bmatch_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_pos\s*\(\s*\)/do { \$LSPOS }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_line',
   ir_node            => 'MATCH_END_LINE_READ',
   diag_name          => 'match_end_line',
   unresolved_pattern => qr/\bmatch_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$LSPOS) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_col',
   ir_node            => 'MATCH_END_COL_READ',
   diag_name          => 'match_end_col',
   unresolved_pattern => qr/\bmatch_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$LSPOS', undef_to_zero => 1)/gex;
    return $code
   },
  },
  {
   id                 => 'match_start_line',
   ir_node            => 'MATCH_START_LINE_READ',
   diag_name          => 'match_start_line',
   unresolved_pattern => qr/\bmatch_start_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$LSPOS - length \$LMATCH) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'match_line',
   ir_node            => 'MATCH_LINE_READ',
   diag_name          => 'match_line',
   unresolved_pattern => qr/\bmatch_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_line\s*\(\s*\)/do { 1 + (() = substr(\$\$STRING, 0, \$LSPOS - length \$LMATCH) =~ \/\\n\/g) }/g;
    return $code
   },
  },
  {
   id                 => 'match_start_col',
   ir_node            => 'MATCH_START_COL_READ',
   diag_name          => 'match_start_col',
   unresolved_pattern => qr/\bmatch_start_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$LSPOS - length $LMATCH')/gex;
    return $code
   },
  },
  {
   id                 => 'match_col',
   ir_node            => 'MATCH_COL_READ',
   diag_name          => 'match_col',
   unresolved_pattern => qr/\bmatch_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_col\s*\(\s*\)/_build_column_read_expr(pos_expr => '$LSPOS - length $LMATCH')/gex;
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
  { id => 'exit_bare',                       ir_node => 'EXIT',           diag_name => 'exit',              compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'linecount_prefix_newline_matches',ir_node => 'LINE_COUNT',     diag_name => 'line_count',        compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_capture_substr',            ir_node => 'PRINT',          diag_name => 'print',             compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'my_declare_bare',                 ir_node => 'DECLARE',        diag_name => 'declare',           compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'assign_match_my',                 ir_node => 'ASSIGN',         diag_name => 'assign',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'destructure_imatch_list_my',      ir_node => 'ASSIGN',         diag_name => 'assign',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'regex_subst_assignment',          ir_node => 'REGEX_SUBST',    diag_name => 'substr',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'next_bare',                       ir_node => 'NEXT',           diag_name => 'next',              compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'ref_field_assign',                ir_node => 'ASSIGN',         diag_name => 'assign',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'position_tracking',               ir_node => 'POSITION_TRACK', diag_name => 'position_tracking', compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_foreach_iterable',          ir_node => 'PRINT',          diag_name => 'print',             compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'split_trim_filter_assignment',    ir_node => 'ASSIGN',         diag_name => 'assign',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
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
   id                 => 'push_nonempty',
   ir_node            => 'PUSH',
   diag_name          => 'push_nonempty',
   unresolved_pattern => qr/\bpush_nonempty\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_push_nonempty_statement};
    $code =~ s/\b(?<expr>push_nonempty\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'assign_value',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   # SPEC-FORMAT-TERSE.1.4.1 — `set(...)` is the terse rename of `assign(...)` (ADR 0007).
   # The statement-level recognition is a raw-text scan (it runs before parse-time
   # name normalization), so it must accept both spellings; the lowered call
   # (_lower_assign_method_statement) then normalizes `set`->`assign` and emits identical code.
   unresolved_pattern => qr/\b(?:assign|set)\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_assign_method_statement};
    $code =~ s/\b(?<expr>(?:assign|set)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'regex_subst',
   ir_node            => 'REGEX_SUBST',
   diag_name          => 'substr',
   unresolved_pattern => qr/\b(?:substr|regex_subst)\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:(?:scalar|s)\s*\(\s*\w+\s*\)|\w+)\s*,/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_regex_subst_statement};
    $code =~ s/\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:(?:scalar|s)\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/$lower->($+{target}, $+{pattern}, $+{replacement}, $+{flags}) || $&/ge;
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
   unresolved_pattern => qr/\bsplit\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:(?:array|a)\s*\(\s*\w+\s*\)|\w+)\s*,\s*(?:(?:scalar|s)\s*\(\s*\w+\s*\)|\w+)/o,
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
    $code =~ s/^\s*(?<expr>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
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
   id                 => 'print_each',
   ir_node            => 'PRINT',
   diag_name          => 'print_each',
   unresolved_pattern => qr/\bprint_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_print_each_statement};
    $code =~ s/\b(?<expr>print_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
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
   id                 => 'exit_now',
   ir_node            => 'EXIT',
   diag_name          => 'exit_now',
   unresolved_pattern => qr/\bexit_now\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code) = @_;
    my $lower_value = $d->{lower_method_value_expr};
    $code =~ s/\bexit_now\s*\(\s*\)/exit/g;
    $code =~ s/\bexit_now\s*\(\s*(?<payload>(?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?<P>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&P))*\)))*)\s*\)/do { my $payload = defined($+{payload}) ? $+{payload} : ''; my $lowered = $lower_value->($payload); 'exit(' . (defined($lowered) && length($lowered) ? $lowered : $payload) . ')' }/ge;
    return $code
   },
  },
  {
   id                 => 'next_stmt',
   ir_node            => 'NEXT',
   diag_name          => 'next',
   unresolved_pattern => qr/\bnext\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bnext\s*\(\s*\)/next/g;
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
  @{_build_capture_and_backtrack_contracts($label, $d)},
  @{_build_passthrough_ir_contracts()},
  @{_build_assignment_and_regex_contracts($d)},
  @{_build_array_pipeline_contracts($d)},
  @{_build_flow_control_contracts($d)},
  @{_build_emit_and_declare_contracts($d)},
 ]
}

1;
