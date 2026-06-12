#------------------------------------------------------------------------------
# Package: LinkedSpec::HandlerVariantEmitter
# Purpose: Generate Perl source strings for each handler variant (AND, OR, REP,
#          and their acode/bcode/combination shapes).  Extracted from SpecEntry.pm
#          to keep the variant builders in one focused module.
#
# All functions here produce Perl source strings only — no eval, no runtime
# handler wrapping, no trace or diagnostics.  That stays in SpecEntry.pm.
#------------------------------------------------------------------------------
package LinkedSpec::HandlerVariantEmitter;

use 5.010;

# REP node-type min/max bounds (used by _resolve_rep_bounds)
my $rep_nodes_minmax = {
    REP_PLUS    => [1, 10**9],
    REP_STAR    => [0, 10**9],
    REP_OPT     => [0, 1],
    REP_OR_PLUS => [1, 10**9],
};

#------------------------------------------------------------------------------
# Function: _resolve_rep_bounds
# Purpose : Resolve min/max repetition bounds from node type or explicit args.
#------------------------------------------------------------------------------
sub _resolve_rep_bounds {
    my (%args) = @_;
    my $node_type = $args{node_type};
    my $rep_min   = $args{rep_min};
    my $rep_max   = $args{rep_max};

    if (defined($rep_min) || defined($rep_max)) {
        $rep_min = defined($rep_min) ? $rep_min : 0;
        $rep_max = defined($rep_max) ? $rep_max : 10**9;
        return ($rep_min, $rep_max);
    }

    return unless defined($node_type) && exists $rep_nodes_minmax->{$node_type};
    return @{$rep_nodes_minmax->{$node_type}};
}

#------------------------------------------------------------------------------
# Function: _linkedre_or_expr
# Purpose : Build the LinkedRE::or(...) call expression for a given rule label.
#------------------------------------------------------------------------------
sub _linkedre_or_expr {
    my (%args) = @_;
    my $label      = $args{label};
    my $parse_mode = defined($args{parse_mode}) && length($args{parse_mode})
        ? $args{parse_mode}
        : 'seek';
    return $parse_mode eq 'consume'
        ? "LinkedRE::or(\$STRING, \$\$descr{dependency_regex_map}{$label}, 'consume', \$info)"
        : "LinkedRE::or(\$STRING, \$\$descr{dependency_regex_map}{$label}, \$info)";
}

#------------------------------------------------------------------------------
# Function: _build_acodes_dispatch_block
# Purpose : Build the if/elsif dispatch block for per-regex acode entries.
#------------------------------------------------------------------------------
sub _build_acodes_dispatch_block {
    my ($acodes_ref) = @_;
    return '' unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    my $once   = 0;
    my $idx    = 0;
    my $acodes = '';
    $acodes .= ($once++ ? " elsif " : "\n   if")
        . '($$minfo{index} == ' . $idx++ . ") {\n    $_\n   }"
        foreach (@$acodes_ref);
    return $acodes;
}

#------------------------------------------------------------------------------
# Function: _build_bcodes_dispatch_block
# Purpose : Build the if/elsif dispatch block for per-edge bcode entries.
#------------------------------------------------------------------------------
sub _build_bcodes_dispatch_block {
    my ($bcalls_ref, $bcodes_ref) = @_;
    return '' unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return '' unless ref($bcodes_ref) eq 'HASH';
    my $once   = 0;
    my $bcodes = '';
    foreach my $call (@$bcalls_ref) {
        my $call_code = defined($bcodes_ref->{$call}) ? $bcodes_ref->{$call} : '';
        $bcodes .= ($once++ ? " elsif " : "\n   if")
            . "(\$call eq \"$call\") {\n    $call_code\n   }";
    }
    return $bcodes;
}

#===========================================================================
# Handler variant builders
#===========================================================================

#------------------------------------------------------------------------------
# _build_default_handler_variant — while(1) loop with acode dispatch.
#------------------------------------------------------------------------------
sub _build_default_handler_variant {
    my (%args) = @_;
    my $acodes = $args{acodes} // '';
    return undef unless length $acodes;
    my $label          = $args{label};
    my $match_expr     = _linkedre_or_expr(%args, label => $label);
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    my $actual_lscode  = $args{actual_lscode}  // '';
    my $actual_lecode  = $args{actual_lecode}  // '';
    return '

 while (1) {
  my $minfo = ' . $match_expr . ';

  unless($minfo) {
  ' . ($actual_lxcode || 'return undef') . '
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;

  ' . $actual_lscode . '

  ' . $acodes . '

  ' . $actual_lecode . '

 }';
}

#------------------------------------------------------------------------------
# _build_and_bcode_sequence_body — foreach call loop with bcode dispatch.
#------------------------------------------------------------------------------
sub _build_and_bcode_sequence_body {
    my (%args) = @_;
    my $bcodes = $args{bcodes} // '';
    return undef unless length $bcodes;
    my $label          = $args{label};
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    my $actual_lecode  = $args{actual_lecode}  // '';
    my $actual_ecode   = $args{actual_ecode}   // '';
    my $bcalls         = $args{bcalls}         // '';
    return '

  my $' . $label . ';
  my @' . $label . '_collect;
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   unless ($' . $label . ') {
    ' . ($actual_lxcode || 'return undef') . '
   }

   ' . ($actual_lecode || 'push @' . $label . '_collect, $' . $label) . '
  }

  ' . ($actual_ecode || 'return \@' . $label . '_collect') . '
 ';
}

sub _build_and_bcode_variant {
    my (%args) = @_;
    return _build_and_bcode_sequence_body(%args);
}

#------------------------------------------------------------------------------
# _build_and_single_acode_variant — single match, acode dispatch, index==0.
#------------------------------------------------------------------------------
sub _build_and_single_acode_variant {
    my (%args) = @_;
    my $acodes = $args{acodes} // '';
    return undef unless length $acodes;
    my $label          = $args{label};
    my $match_expr     = _linkedre_or_expr(%args, label => $label);
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    my $actual_lscode  = $args{actual_lscode}  // '';
    my $actual_lecode  = $args{actual_lecode}  // '';
    return '

 my @' . $label . '_collect;
 my $minfo = ' . $match_expr . ';
 unless($minfo) {
  ' . ($actual_lxcode || 'return undef') . '
 }

 unless($$minfo{index} == 0) {
  ' . ($actual_lxcode || 'return undef') . '
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;

 ' . $actual_lscode . '

 ' . $acodes . '

 ' . $actual_lecode . '

 return \@' . $label . '_collect;
 ';
}

#------------------------------------------------------------------------------
# _build_and_acode_sequence_body — sequential index matching for AND+acode.
#------------------------------------------------------------------------------
sub _build_and_acode_sequence_body {
    my (%args) = @_;
    my $acodes = $args{acodes} // '';
    return undef unless length $acodes;
    my $label          = $args{label};
    my $match_expr     = _linkedre_or_expr(%args, label => $label);
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    my $actual_lscode  = $args{actual_lscode}  // '';
    my $actual_lecode  = $args{actual_lecode}  // '';
    my $acode_count    = $args{acode_count}    // 0;
    return '

 my @' . $label . '_collect;
 my $idx = 0;

 while ($idx < ' . $acode_count . ') {
  my $minfo = ' . $match_expr . ';
  unless($minfo) {
   ' . ($actual_lxcode || 'return undef') . '
  }

  unless($$minfo{index} == $idx) {
   ' . ($actual_lxcode || 'return undef') . '
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;

  ' . $actual_lscode . '

  ' . $acodes . '

  ' . $actual_lecode . '

  $idx++;
 }

 return \@' . $label . '_collect;
 ';
}

sub _build_and_acode_variant {
    my (%args) = @_;
    return _build_and_acode_sequence_body(%args);
}

#------------------------------------------------------------------------------
# _build_or_bcode_choice_body — first-match-wins loop over bcalls.
#------------------------------------------------------------------------------
sub _build_or_bcode_choice_body {
    my (%args) = @_;
    my $bcodes = $args{bcodes} // '';
    return undef unless length $bcodes;
    my $label          = $args{label};
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    my $actual_ecode   = $args{actual_ecode}   // '';
    my $bcalls         = $args{bcalls}         // '';
    return '

  my $' . $label . ';
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   if ($' . $label . ') {
    ' . ($actual_lxcode || 'return $' . $label) . '
   }
  }

  ' . ($actual_ecode || 'return undef') . '
 ';
}

#------------------------------------------------------------------------------
# _build_or_acode_variant — single match, acode dispatch, no index check.
#------------------------------------------------------------------------------
sub _build_or_acode_variant {
    my (%args) = @_;
    my $acodes = $args{acodes} // '';
    return undef unless length $acodes;
    my $label          = $args{label};
    my $match_expr     = _linkedre_or_expr(%args, label => $label);
    my $actual_lxcode  = $args{actual_lxcode}  // '';
    return '

 my $minfo = ' . $match_expr . ';
 unless($minfo) {
 ' . ($actual_lxcode || 'return undef') . '
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;

 ' . $acodes . '
 ';
}

sub _build_or_bcode_variant {
    my (%args) = @_;
    return _build_or_bcode_choice_body(%args);
}

#------------------------------------------------------------------------------
# _build_rep_bcode_variant — repeat loop with min/max, bcode choice body.
#------------------------------------------------------------------------------
sub _build_rep_bcode_variant {
    my (%args) = @_;
    my ($min, $max) = _resolve_rep_bounds(%args);
    if (!defined($min) || !defined($max)) {
        my $node_type = $args{node_type} // '';
        if ($node_type eq 'default') {
            ($min, $max) = (1, 10**9);
        }
    }
    return undef unless defined $min && defined $max;

    my $label           = $args{label};
    my $actual_itcode   = $args{actual_itcode}   // '';
    my $actual_excode   = $args{actual_excode}   // '';
    my $actual_ecode    = $args{actual_ecode}    // '';
    my $or_code = _build_or_bcode_choice_body(
        %args,
        actual_ecode => 'return undef',
    );
    return undef unless defined $or_code;

    return '
   my $min=' . $min . ';
   my $max=' . $max . ';
   my $' . $label . ';
   my @' . $label . '_collect;

   my $ccount = 0;
   my $or_code = sub {' . $or_code . '
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $or_ret = $or_code->();
    unless ($or_ret) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . ($actual_itcode || 'push @' . $label . '_collect, $or_ret;') . '

    last unless $ccount < $max
   }

   ' . ($actual_ecode || 'return \@' . $label . '_collect') . '
   ';
}

#------------------------------------------------------------------------------
# _build_rep_and_bcode_variant — repeat loop with min/max, and bcode sequence.
#------------------------------------------------------------------------------
sub _build_rep_and_bcode_variant {
    my (%args) = @_;
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;

    my $label           = $args{label};
    my $actual_itcode   = $args{actual_itcode}   // '';
    my $actual_excode   = $args{actual_excode}   // '';
    my $actual_ecode    = $args{actual_ecode}    // '';
    my $and_code = _build_and_bcode_sequence_body(
        %args,
        actual_ecode => 'return \@' . $label . '_collect',
    );
    return undef unless defined $and_code;

    return '
   my $min=' . $min . ';
   my $max=' . $max . ';
   my $' . $label . ';
   my @' . $label . '_collect;

   my $ccount = 0;
   my $and_code = sub {' . $and_code . '
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . ($actual_itcode || 'push @' . $label . '_collect, $and_ret;') . '

    last unless $ccount < $max
   }

   ' . ($actual_ecode || 'return \@' . $label . '_collect') . '
   ';
}

#------------------------------------------------------------------------------
# _build_rep_and_acode_variant — repeat loop with min/max, and acode sequence.
#------------------------------------------------------------------------------
sub _build_rep_and_acode_variant {
    my (%args) = @_;
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;

    my $label           = $args{label};
    my $actual_itcode   = $args{actual_itcode}   // '';
    my $actual_excode   = $args{actual_excode}   // '';
    my $actual_ecode    = $args{actual_ecode}    // '';
    my $acode_count     = (ref($args{acodes_ref}) eq 'ARRAY') ? scalar(@{$args{acodes_ref}}) : 0;
    return undef unless $acode_count;

    my $and_code = _build_and_acode_sequence_body(
        %args,
        acode_count  => $acode_count,
        actual_ecode => 'return \@' . $label . '_collect',
    );
    return undef unless defined $and_code;

    return '

   my $min=' . $min . ';
   my $max=' . $max . ';
   my @' . $label . '_collect;
   my $ccount = 0;
   my $and_code = sub {' . $and_code . '
   };

   while(1) {
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . ($actual_itcode || 'push @' . $label . '_collect, $and_ret;') . '

    last unless $ccount < $max
   }

   ' . ($actual_ecode || 'return \@' . $label . '_collect') . '
 ';
}

#------------------------------------------------------------------------------
# _build_rep_acode_variant — repeat loop with min/max, acode dispatch.
#------------------------------------------------------------------------------
sub _build_rep_acode_variant {
    my (%args) = @_;
    my $acodes = $args{acodes} // '';
    return undef unless length $acodes;
    my $label       = $args{label};
    my $match_expr  = _linkedre_or_expr(%args, label => $label);
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;

    my $actual_lscode  = $args{actual_lscode}  // '';
    my $actual_lecode  = $args{actual_lecode}  // '';
    my $actual_itcode  = $args{actual_itcode}  // '';
    my $actual_excode  = $args{actual_excode}  // '';
    my $actual_ecode   = $args{actual_ecode}   // '';

    return '

   my $min=' . $min . ';
   my $max=' . $max . ';
   my @' . $label . '_collect;
   my $ccount = 0;

   while(1) {
    my $minfo = ' . $match_expr . ';
    unless($minfo) {
     if ($ccount >= $min) {
      ' . ($actual_excode || 'return \@' . $label . '_collect') . '
     } else {
      return undef
     }
    }

    my $LMATCH      = $$minfo{match};
    my @LMATCH_LIST = @{$$minfo{match_list} // []};
    my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
    my $LINDEX      = $$minfo{index};
    my $LSPOS       = pos $$STRING;

    ' . $actual_lscode . '

    ' . $acodes . '

    ' . $actual_lecode . '

    ++$ccount;

    ' . ($actual_itcode || 'push @' . $label . '_collect, $' . $label . ';') . '

    last unless $ccount < $max
   }

   ' . ($actual_ecode || 'return \@' . $label . '_collect') . '
 ';
}

1;
