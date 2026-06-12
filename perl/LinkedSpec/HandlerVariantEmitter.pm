#------------------------------------------------------------------------------
# Package: LinkedSpec::HandlerVariantEmitter
# Purpose: Generate Perl source strings for each handler variant (AND, OR, REP,
#          and their acode/bcode/combination shapes).  Extracted from SpecEntry.pm
#          to keep the variant builders in one focused module.
#
# All functions here produce HandlerIR nodes (hashref-based ASTs) that describe
# handler structure — loop type, match expression, dispatch style, lifecycle slot
# placement — without raw Perl source strings.  _emit_handler_perl() consumes
# HandlerIR nodes to generate the final Perl source.
#
# =head1 HandlerIR Structure
#
#   {
#     kind       => 'default' | 'and_bcode' | 'and_single_acode' | 'and_acode_seq'
#                 | 'or_bcode' | 'or_acode' | 'rep_bcode' | 'rep_and_bcode'
#                 | 'rep_and_acode' | 'rep_acode',
#     label      => '<rule_label>',
#     parse_mode => 'seek' | 'consume',
#
#     # Lifecycle code bodies (strings from ActionIR lowering)
#     preamble   => '<icode>;',         # I-block (Initial) — code executed when the handler is first entered
#     lxcode     => '<lxcode>;',        # Loop eXit — no-match / failure path
#     lscode     => '<lscode>;',        # Loop Start — after successful match
#     lecode     => '<lecode>;',        # Loop End — before collection / return
#     ecode      => '<ecode>;',         # End — exhaustion / final return
#     excode     => '<excode>;',        # EXit — REP loop exhaustion fallback
#     itcode     => '<itcode>;',        # ITeration — REP per-iteration collection
#
#     # Dispatch (raw refs — emitter builds the if/elsif dispatch strings)
#     acodes_ref => [ '<acode_0>', '<acode_1>', ... ],
#     bcodes_ref => { call1 => '<bcode>', ... },
#     bcalls_ref => [ 'call1', 'call2', ... ],
#
#     # Repetition bounds (only for REP_* variants; undef for others)
#     rep_min => undef | int,
#     rep_max => undef | int,
#   }
#
# =head1 Variant Kinds
#
#   default          while(1) loop, LinkedRE::or match, acode if/elsif dispatch
#   and_bcode        foreach call loop, bcode if/elsif dispatch
#   and_single_acode single match, index==0 check, acode if/elsif dispatch
#   and_acode_seq    while(idx<N) loop, LinkedRE::or + index check, acode dispatch
#   or_bcode         foreach call loop, first-match-wins bcode dispatch
#   or_acode         single match, no index check, acode if/elsif dispatch
#   rep_bcode        while(1) + rep bounds, inner OR_BCODE as coderef
#   rep_and_bcode    while(1) + rep bounds, inner AND_BCODE as coderef
#   rep_and_acode    while(1) + rep bounds, inner AND_ACODE as coderef
#   rep_acode        while(1) + rep bounds, LinkedRE::or + acode dispatch
#
# =head1 Emitter Contract
#
#   _emit_handler_perl($ir) takes a HandlerIR hashref and returns the identical
#   Perl source string that the old inline builders used to produce.  The emitter
#   is the single source of truth for Perl code generation; variant builders only
#   make structural decisions (which kind, what the match expression is, which
#   lifecycle slots are active).
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

#===========================================================================
# HandlerIR variant builders — return hashref AST, NOT Perl source strings
#===========================================================================

#------------------------------------------------------------------------------
# _build_default_handler_variant — while(1) loop with LinkedRE::or + acode dispatch.
#------------------------------------------------------------------------------
sub _build_default_handler_variant {
    my (%args) = @_;
    my $acodes_ref = $args{acodes_ref};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    return {
        kind       => 'default',
        label      => $args{label},
        parse_mode => $args{parse_mode} // 'seek',
        preamble   => $args{preamble}   // '',
        lxcode     => $args{lxcode}     // '',
        lscode     => $args{lscode}     // '',
        lecode     => $args{lecode}     // '',
        acodes_ref => $acodes_ref,
    };
}

#------------------------------------------------------------------------------
# _build_and_bcode_sequence_body — foreach call loop with bcode dispatch.
#------------------------------------------------------------------------------
sub _build_and_bcode_sequence_body {
    my (%args) = @_;
    my $bcodes_ref = $args{bcodes_ref};
    my $bcalls_ref = $args{bcalls_ref};
    return undef unless ref($bcodes_ref) eq 'HASH' && keys %$bcodes_ref;
    return undef unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return {
        kind       => 'and_bcode',
        label      => $args{label},
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        lecode     => $args{lecode}   // '',
        ecode      => $args{ecode}    // '',
        bcodes_ref => $bcodes_ref,
        bcalls_ref => $bcalls_ref,
    };
}

sub _build_and_bcode_variant {
    my (%args) = @_;
    return _build_and_bcode_sequence_body(%args);
}

#------------------------------------------------------------------------------
# _build_and_single_acode_variant — single match, index==0 check, acode dispatch.
#------------------------------------------------------------------------------
sub _build_and_single_acode_variant {
    my (%args) = @_;
    my $acodes_ref = $args{acodes_ref};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    return {
        kind       => 'and_single_acode',
        label      => $args{label},
        parse_mode => $args{parse_mode} // 'seek',
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        lscode     => $args{lscode}   // '',
        lecode     => $args{lecode}   // '',
        acodes_ref => $acodes_ref,
    };
}

#------------------------------------------------------------------------------
# _build_and_acode_sequence_body — sequential index matching for AND+acode.
#------------------------------------------------------------------------------
sub _build_and_acode_sequence_body {
    my (%args) = @_;
    my $acodes_ref  = $args{acodes_ref};
    my $acode_count = $args{acode_count};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    return undef unless defined($acode_count) && $acode_count > 0;
    return {
        kind        => 'and_acode_seq',
        label       => $args{label},
        parse_mode  => $args{parse_mode} // 'seek',
        preamble    => $args{preamble} // '',
        lxcode      => $args{lxcode}   // '',
        lscode      => $args{lscode}   // '',
        lecode      => $args{lecode}   // '',
        acodes_ref  => $acodes_ref,
        acode_count => $acode_count,
    };
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
    my $bcodes_ref = $args{bcodes_ref};
    my $bcalls_ref = $args{bcalls_ref};
    return undef unless ref($bcodes_ref) eq 'HASH' && keys %$bcodes_ref;
    return undef unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return {
        kind       => 'or_bcode',
        label      => $args{label},
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        ecode      => $args{ecode}    // '',
        bcodes_ref => $bcodes_ref,
        bcalls_ref => $bcalls_ref,
    };
}

#------------------------------------------------------------------------------
# _build_or_acode_variant — single match, no index check, acode dispatch.
#------------------------------------------------------------------------------
sub _build_or_acode_variant {
    my (%args) = @_;
    my $acodes_ref = $args{acodes_ref};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    return {
        kind       => 'or_acode',
        label      => $args{label},
        parse_mode => $args{parse_mode} // 'seek',
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        acodes_ref => $acodes_ref,
    };
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
    my $bcodes_ref = $args{bcodes_ref};
    my $bcalls_ref = $args{bcalls_ref};
    return undef unless ref($bcodes_ref) eq 'HASH' && keys %$bcodes_ref;
    return undef unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return {
        kind       => 'rep_bcode',
        label      => $args{label},
        preamble   => $args{preamble} // '',
        excode     => $args{excode}   // '',
        ecode      => $args{ecode}    // '',
        itcode     => $args{itcode}   // '',
        bcodes_ref => $bcodes_ref,
        bcalls_ref => $bcalls_ref,
        rep_min    => $min,
        rep_max    => $max,
    };
}

#------------------------------------------------------------------------------
# _build_rep_and_bcode_variant — repeat loop with min/max, and bcode sequence.
#------------------------------------------------------------------------------
sub _build_rep_and_bcode_variant {
    my (%args) = @_;
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;
    my $bcodes_ref = $args{bcodes_ref};
    my $bcalls_ref = $args{bcalls_ref};
    return undef unless ref($bcodes_ref) eq 'HASH' && keys %$bcodes_ref;
    return undef unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return {
        kind       => 'rep_and_bcode',
        label      => $args{label},
        preamble   => $args{preamble} // '',
        excode     => $args{excode}   // '',
        ecode      => $args{ecode}    // '',
        itcode     => $args{itcode}   // '',
        bcodes_ref => $bcodes_ref,
        bcalls_ref => $bcalls_ref,
        rep_min    => $min,
        rep_max    => $max,
    };
}

#------------------------------------------------------------------------------
# _build_rep_and_acode_variant — repeat loop with min/max, and acode sequence.
#------------------------------------------------------------------------------
sub _build_rep_and_acode_variant {
    my (%args) = @_;
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;
    my $acodes_ref = $args{acodes_ref};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    return {
        kind        => 'rep_and_acode',
        label       => $args{label},
        parse_mode  => $args{parse_mode} // 'seek',
        preamble    => $args{preamble} // '',
        excode      => $args{excode}   // '',
        ecode       => $args{ecode}    // '',
        itcode      => $args{itcode}   // '',
        acodes_ref  => $acodes_ref,
        acode_count => scalar(@$acodes_ref),
        rep_min     => $min,
        rep_max     => $max,
    };
}

#------------------------------------------------------------------------------
# _build_rep_acode_variant — repeat loop with min/max, acode dispatch.
#------------------------------------------------------------------------------
sub _build_rep_acode_variant {
    my (%args) = @_;
    my $acodes_ref = $args{acodes_ref};
    return undef unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    my ($min, $max) = _resolve_rep_bounds(%args);
    return undef unless defined $min && defined $max;
    return {
        kind       => 'rep_acode',
        label      => $args{label},
        parse_mode => $args{parse_mode} // 'seek',
        preamble   => $args{preamble} // '',
        lscode     => $args{lscode}   // '',
        lecode     => $args{lecode}   // '',
        excode     => $args{excode}   // '',
        ecode      => $args{ecode}    // '',
        itcode     => $args{itcode}   // '',
        acodes_ref => $acodes_ref,
        rep_min    => $min,
        rep_max    => $max,
    };
}

#===========================================================================
# Emitter helpers — build Perl source fragments from HandlerIR fields
#===========================================================================

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

#------------------------------------------------------------------------------
# Function: _build_lmatch_extraction
# Purpose : Common LMATCH/LMATCH_LIST/LMATCH_HASH/LINDEX/LSPOS extraction block.
#------------------------------------------------------------------------------
sub _build_lmatch_extraction {
    return '
   my $LMATCH      = $$minfo{match};
   my @LMATCH_LIST = @{$$minfo{match_list} // []};
   my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
   my $LINDEX      = $$minfo{index};
   my $LSPOS       = pos $$STRING;';
}

#===========================================================================
# Backend dispatch table — maps backend names to emitter functions.
# The "perl" backend is the default and only backend; additional backends
# (e.g. JSON/AST diagnostic) register here through MEDIUM-IMPACT.1.5.
#===========================================================================
my %BACKEND_EMITTERS = (
    perl => \&_emit_handler_perl,
);

#------------------------------------------------------------------------------
# Function: _emit_handler
# Purpose : Backend-aware dispatch — select emitter by name (default: "perl").
# Args    : ($ir, %opts) where %opts may include backend => '<name>'
# Returns : handler source string for the selected backend, or undef
#------------------------------------------------------------------------------
sub _emit_handler {
    my ($ir, %opts) = @_;
    return undef unless ref($ir) eq 'HASH';
    my $backend = $opts{backend} // 'perl';
    my $emitter = $BACKEND_EMITTERS{$backend};
    return undef unless defined $emitter;
    return $emitter->($ir);
}

#===========================================================================
# _emit_handler_perl — dispatch handler IR to the matching Perl code template
#===========================================================================
sub _emit_handler_perl {
    my ($ir) = @_;
    return undef unless ref($ir) eq 'HASH';
    my $kind = $ir->{kind} // '';
    my %emit = (
        default          => \&_emit_default_handler,
        and_bcode        => \&_emit_and_bcode_handler,
        and_single_acode => \&_emit_and_single_acode_handler,
        and_acode_seq    => \&_emit_and_acode_seq_handler,
        or_bcode         => \&_emit_or_bcode_handler,
        or_acode         => \&_emit_or_acode_handler,
        rep_bcode        => \&_emit_rep_bcode_handler,
        rep_and_bcode    => \&_emit_rep_and_bcode_handler,
        rep_and_acode    => \&_emit_rep_and_acode_handler,
        rep_acode        => \&_emit_rep_acode_handler,
    );
    my $emitter = $emit{$kind};
    return undef unless defined $emitter;
    return $emitter->($ir);
}

#------------------------------------------------------------------------------
# _emit_default_handler — while(1) loop, LinkedRE::or match, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_default_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $lxcode     = $ir->{lxcode} || 'return undef';
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    my $acodes     = _build_acodes_dispatch_block($ir->{acodes_ref});
    my $lmatch     = _build_lmatch_extraction();
    return '

 while (1) {
  my $minfo = ' . $match_expr . ';

  unless($minfo) {
  ' . $lxcode . '
  }
' . $lmatch . '

  ' . $lscode . '

  ' . $acodes . '

  ' . $lecode . '

 }';
}

#------------------------------------------------------------------------------
# _emit_and_bcode_handler — foreach call loop, bcode dispatch, collect array.
#------------------------------------------------------------------------------
sub _emit_and_bcode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $lxcode     = $ir->{lxcode} || 'return undef';
    my $lecode     = $ir->{lecode} || 'push @' . $label . '_collect, $' . $label;
    my $ecode      = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $bcodes     = _build_bcodes_dispatch_block($ir->{bcalls_ref}, $ir->{bcodes_ref});
    my $bcalls     = join(' ', @{$ir->{bcalls_ref}});
    return '

  my $' . $label . ';
  my @' . $label . '_collect;
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   unless ($' . $label . ') {
    ' . $lxcode . '
   }

   ' . $lecode . '
  }

  ' . $ecode . '
 ';
}

#------------------------------------------------------------------------------
# _emit_and_single_acode_handler — single match, index==0, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_and_single_acode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $lxcode     = $ir->{lxcode} || 'return undef';
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    my $acodes     = _build_acodes_dispatch_block($ir->{acodes_ref});
    my $lmatch     = _build_lmatch_extraction();
    return '

 my @' . $label . '_collect;
 my $minfo = ' . $match_expr . ';
 unless($minfo) {
  ' . $lxcode . '
 }

 unless($$minfo{index} == 0) {
  ' . $lxcode . '
 }
' . $lmatch . '

 ' . $lscode . '

 ' . $acodes . '

 ' . $lecode . '

 return \@' . $label . '_collect;
 ';
}

#------------------------------------------------------------------------------
# _emit_and_acode_seq_handler — sequential index matching loop, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_and_acode_seq_handler {
    my ($ir) = @_;
    my $label       = $ir->{label};
    my $match_expr  = _linkedre_or_expr(%$ir, label => $label);
    my $lxcode      = $ir->{lxcode} || 'return undef';
    my $lscode      = $ir->{lscode} || '';
    my $lecode      = $ir->{lecode} || '';
    my $acode_count = $ir->{acode_count};
    my $acodes      = _build_acodes_dispatch_block($ir->{acodes_ref});
    my $lmatch      = _build_lmatch_extraction();
    return '

 my @' . $label . '_collect;
 my $idx = 0;

 while ($idx < ' . $acode_count . ') {
  my $minfo = ' . $match_expr . ';
  unless($minfo) {
   ' . $lxcode . '
  }

  unless($$minfo{index} == $idx) {
   ' . $lxcode . '
  }
' . $lmatch . '

  ' . $lscode . '

  ' . $acodes . '

  ' . $lecode . '

  $idx++;
 }

 return \@' . $label . '_collect;
 ';
}

#------------------------------------------------------------------------------
# _emit_or_bcode_handler — first-match-wins foreach over bcalls.
#------------------------------------------------------------------------------
sub _emit_or_bcode_handler {
    my ($ir) = @_;
    my $label  = $ir->{label};
    my $lxcode = $ir->{lxcode} || 'return $' . $label;
    my $ecode  = $ir->{ecode}  || 'return undef';
    my $bcodes = _build_bcodes_dispatch_block($ir->{bcalls_ref}, $ir->{bcodes_ref});
    my $bcalls = join(' ', @{$ir->{bcalls_ref}});
    return '

  my $' . $label . ';
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   if ($' . $label . ') {
    ' . $lxcode . '
   }
  }

  ' . $ecode . '
 ';
}

#------------------------------------------------------------------------------
# _emit_or_acode_handler — single match, no index check, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_or_acode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $lxcode     = $ir->{lxcode} || 'return undef';
    my $acodes     = _build_acodes_dispatch_block($ir->{acodes_ref});
    my $lmatch     = _build_lmatch_extraction();
    return '

 my $minfo = ' . $match_expr . ';
 unless($minfo) {
 ' . $lxcode . '
 }
' . $lmatch . '

 ' . $acodes . '
 ';
}

#------------------------------------------------------------------------------
# _emit_rep_bcode_handler — repeat loop with min/max, inner OR_BCODE coderef.
#------------------------------------------------------------------------------
sub _emit_rep_bcode_handler {
    my ($ir) = @_;
    my $label  = $ir->{label};
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $or_ret;';

    # Build inner OR_BCODE as a coderef
    my $or_body = _emit_or_bcode_handler({
        %$ir,
        kind   => 'or_bcode',
        ecode  => 'return undef',
        lxcode => $ir->{lxcode} || 'return $' . $label,
    });
    return undef unless defined $or_body;

    return '
   my $min=' . $min . ';
   my $max=' . $max . ';
   my $' . $label . ';
   my @' . $label . '_collect;

   my $ccount = 0;
   my $or_code = sub {' . $or_body . '
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $or_ret = $or_code->();
    unless ($or_ret) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . $itcode . '

    last unless $ccount < $max
   }

   ' . $ecode . '
   ';
}

#------------------------------------------------------------------------------
# _emit_rep_and_bcode_handler — repeat loop with min/max, inner AND_BCODE coderef.
#------------------------------------------------------------------------------
sub _emit_rep_and_bcode_handler {
    my ($ir) = @_;
    my $label  = $ir->{label};
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $and_ret;';

    # Build inner AND_BCODE as a coderef
    my $and_body = _emit_and_bcode_handler({
        %$ir,
        kind  => 'and_bcode',
        ecode => 'return \@' . $label . '_collect',
    });
    return undef unless defined $and_body;

    return '
   my $min=' . $min . ';
   my $max=' . $max . ';
   my $' . $label . ';
   my @' . $label . '_collect;

   my $ccount = 0;
   my $and_code = sub {' . $and_body . '
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . $itcode . '

    last unless $ccount < $max
   }

   ' . $ecode . '
   ';
}

#------------------------------------------------------------------------------
# _emit_rep_and_acode_handler — repeat loop with min/max, inner AND_ACODE coderef.
#------------------------------------------------------------------------------
sub _emit_rep_and_acode_handler {
    my ($ir) = @_;
    my $label  = $ir->{label};
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $and_ret;';

    # Build inner AND_ACODE as a coderef
    my $and_body = _emit_and_acode_seq_handler({
        %$ir,
        kind        => 'and_acode_seq',
        acode_count => $ir->{acode_count},
        ecode       => 'return \@' . $label . '_collect',
    });
    return undef unless defined $and_body;

    return '

   my $min=' . $min . ';
   my $max=' . $max . ';
   my @' . $label . '_collect;
   my $ccount = 0;
   my $and_code = sub {' . $and_body . '
   };

   while(1) {
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . $itcode . '

    last unless $ccount < $max
   }

   ' . $ecode . '
 ';
}

#------------------------------------------------------------------------------
# _emit_rep_acode_handler — repeat loop with min/max, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_rep_acode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $min        = $ir->{rep_min};
    my $max        = $ir->{rep_max};
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    my $excode     = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode      = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode     = $ir->{itcode} || 'push @' . $label . '_collect, $' . $label . ';';

    # REP: replace return with assignment so loop collects
    my $acodes_ref = $ir->{acodes_ref};
    my @acodes_transformed;
    foreach my $acode (@$acodes_ref) {
        my $transformed = $acode;
        $transformed =~ s/\breturn\s+/"\$" . $label . " = "/eg;
        push @acodes_transformed, $transformed;
    }
    my $acodes = _build_acodes_dispatch_block(\@acodes_transformed);
    my $lmatch = _build_lmatch_extraction();

    return '

   my $min=' . $min . ';
   my $max=' . $max . ';
   my @' . $label . '_collect;
   my $ccount = 0;

   while(1) {
    my $minfo = ' . $match_expr . ';
    unless($minfo) {
     if ($ccount >= $min) {
      ' . $excode . '
     } else {
      return undef
     }
    }
' . $lmatch . '

    ' . $lscode . '

    ' . $acodes . '

    ' . $lecode . '

    ++$ccount;

    ' . $itcode . '

    last unless $ccount < $max
   }

   ' . $ecode . '
 ';
}

1;
