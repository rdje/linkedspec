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
#     cursor_policy => 'seek' | 'consume',
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
        cursor_policy => $args{cursor_policy} // 'seek',
        preamble   => $args{preamble}   // '',
        lxcode     => $args{lxcode}     // '',
        lscode     => $args{lscode}     // '',
        lecode     => $args{lecode}     // '',
        acodes_ref => $acodes_ref,
        capture_gaps => $args{capture_gaps} ? 1 : 0,
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
    my $ir = {
        kind       => 'and_bcode',
        label      => $args{label},
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        lecode     => $args{lecode}   // '',
        ecode      => $args{ecode}    // '',
        bcodes_ref => $bcodes_ref,
        bcalls_ref => $bcalls_ref,
    };
    # Optional fields for AND rules that also have a regex + per-regex I-block:
    # REs (for match expression) and and_icode (IMATCH bridge + return->assignment).
    $ir->{REs} = $args{REs} if ref($args{REs}) eq 'ARRAY' && @{$args{REs}};
    $ir->{cursor_policy} = $args{cursor_policy} if defined($args{cursor_policy});
    $ir->{and_icode} = $args{and_icode} if defined($args{and_icode}) && length($args{and_icode});
    return $ir;
}

sub _build_and_bcode_variant {
    my (%args) = @_;
    return _build_and_bcode_sequence_body(%args);
}

#------------------------------------------------------------------------------
# _build_and_single_acode_variant — single match, index==0 check, acode dispatch.
# Accepts optional 'and_icode' — per-regex I-block code that runs after regex match
# with return→assignment applied, before edge acode dispatch.
#------------------------------------------------------------------------------
sub _build_and_single_acode_variant {
    my (%args) = @_;
    my $acodes_ref = $args{acodes_ref};
    my $and_icode  = $args{and_icode};
    return undef unless (ref($acodes_ref) eq 'ARRAY' && @$acodes_ref)
                     || defined($and_icode);
    my $ir = {
        kind       => 'and_single_acode',
        label      => $args{label},
        cursor_policy => $args{cursor_policy} // 'seek',
        preamble   => $args{preamble} // '',
        lxcode     => $args{lxcode}   // '',
        lscode     => $args{lscode}   // '',
        lecode     => $args{lecode}   // '',
        acodes_ref => $acodes_ref,
    };
    $ir->{and_icode} = $and_icode if defined($and_icode);
    return $ir;
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
    my $ir = {
        kind        => 'and_acode_seq',
        label       => $args{label},
        cursor_policy => $args{cursor_policy} // 'seek',
        preamble    => $args{preamble} // '',
        lxcode      => $args{lxcode}   // '',
        lscode      => $args{lscode}   // '',
        lecode      => $args{lecode}   // '',
        acodes_ref  => $acodes_ref,
        acode_count => $acode_count,
    };
    $ir->{required_slot_mode} = $args{required_slot_mode}
        if defined($args{required_slot_mode});
    $ir->{required_slot_count} = $args{required_slot_count}
        if defined($args{required_slot_count});
    $ir->{acode_dispatch_indices} = [@{$args{acode_dispatch_indices}}]
        if ref($args{acode_dispatch_indices}) eq 'ARRAY';
    return $ir;
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
        cursor_policy => $args{cursor_policy} // 'seek',
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
    my $ir = {
        kind        => 'rep_and_acode',
        label       => $args{label},
        cursor_policy => $args{cursor_policy} // 'seek',
        preamble    => $args{preamble} // '',
        excode      => $args{excode}   // '',
        ecode       => $args{ecode}    // '',
        itcode      => $args{itcode}   // '',
        acodes_ref  => $acodes_ref,
        acode_count => scalar(@$acodes_ref),
        rep_min     => $min,
        rep_max     => $max,
    };
    $ir->{required_slot_mode} = $args{required_slot_mode}
        if defined($args{required_slot_mode});
    $ir->{required_slot_count} = $args{required_slot_count}
        if defined($args{required_slot_count});
    $ir->{acode_dispatch_indices} = [@{$args{acode_dispatch_indices}}]
        if ref($args{acode_dispatch_indices}) eq 'ARRAY';
    return $ir;
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
        cursor_policy => $args{cursor_policy} // 'seek',
        preamble   => $args{preamble} // '',
        lscode     => $args{lscode}   // '',
        lecode     => $args{lecode}   // '',
        excode     => $args{excode}   // '',
        ecode      => $args{ecode}    // '',
        itcode     => $args{itcode}   // '',
        acodes_ref => $acodes_ref,
        rep_min    => $min,
        rep_max    => $max,
        capture_gaps => $args{capture_gaps} ? 1 : 0,
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
    my $cursor_policy = defined($args{cursor_policy}) && length($args{cursor_policy})
        ? $args{cursor_policy}
        : 'seek';
    return $cursor_policy eq 'consume'
        ? "LinkedRE::or(\$STRING, \$\$descr{dependency_regex_map}{$label}, 'consume', \$info)"
        : "LinkedRE::or(\$STRING, \$\$descr{dependency_regex_map}{$label}, \$info)";
}

sub _dependency_ref_expr {
    my (%args) = @_;
    my $label = $args{label};
    my $index_expr = $args{index_expr};
    return '(exists($$descr{dependency_slot_map})'
        . ' ? $$descr{dependency_slot_map}{' . $label . '}[' . $index_expr . ']'
        . ' : $$descr{spec}{' . $label . '}{dependency_refs}[' . $index_expr . '])';
}

sub _linkedre_required_slot_expr {
    my (%args) = @_;
    my $label = $args{label};
    my $index_expr = $args{index_expr};
    my $cursor_policy = defined($args{cursor_policy}) && length($args{cursor_policy})
        ? $args{cursor_policy}
        : 'consume';
    my $dependency_ref = _dependency_ref_expr(label => $label, index_expr => $index_expr);
    my $slot_re = '($$required_slot{re}'
        . ' // $$descr{spec}{$$required_slot{label}}{re}[$$required_slot{idx}])';
    return 'do { my $required_slot = ' . $dependency_ref
        . '; LinkedRE::match_slot($STRING, ' . $slot_re . ', ' . $index_expr . ', '
        . _quote_perl_string($label)
        . ', $$required_slot{label}, $$required_slot{idx}, '
        . _quote_perl_string($cursor_policy)
        . ', $info) }';
}

sub _linkedre_local_structural_slot_expr {
    my (%args) = @_;
    my $label = $args{label};
    my $index_expr = $args{index_expr};
    my $cursor_policy = defined($args{cursor_policy}) && length($args{cursor_policy})
        ? $args{cursor_policy}
        : 'consume';
    my $slot_re = '(exists($$descr{dependency_slot_map})'
        . ' ? $$descr{dependency_slot_map}{' . $label . '}[' . $index_expr . ']{re}'
        . ' : $$descr{spec}{' . $label . '}{re}[' . $index_expr . '])';
    return 'LinkedRE::match_slot($STRING, ' . $slot_re . ', ' . $index_expr . ', '
        . _quote_perl_string($label) . ', ' . _quote_perl_string($label) . ', '
        . $index_expr . ', ' . _quote_perl_string($cursor_policy) . ', $info)';
}

sub _slot_identity_condition {
    my (%args) = @_;
    my $label = $args{label};
    my $index_expr = $args{index_expr};
    my $dependency_ref = _dependency_ref_expr(label => $label, index_expr => $index_expr);
    return 'do { my $required_slot = ' . $dependency_ref
        . '; LinkedRE::assert_slot_identity($minfo, '
        . _quote_perl_string($label)
        . ', ' . $index_expr
        . ', $$required_slot{label}, $$required_slot{idx}) }';
}

sub _local_structural_slot_identity_condition {
    my (%args) = @_;
    my $label = $args{label};
    my $index_expr = $args{index_expr};
    return 'LinkedRE::assert_slot_identity($minfo, '
        . _quote_perl_string($label) . ', ' . $index_expr . ', '
        . _quote_perl_string($label) . ', ' . $index_expr . ')';
}

sub _slot_selection_observation_and_trace {
    my (%args) = @_;
    my $selection_role = $args{selection_role};
    my $target_rule_expr;
    my $regex_index_expr;
    if ($selection_role eq 'ordered_required') {
        $target_rule_expr = '$$minfo{target_rule}';
        $regex_index_expr = '$$minfo{regex_index}';
    } else {
        my $dependency_ref = _dependency_ref_expr(
            label => $args{label},
            index_expr => '$$minfo{index}',
        );
        $target_rule_expr = $dependency_ref . '->{label}';
        $regex_index_expr = $dependency_ref . '->{idx}';
    }
    my $observation = ($args{indent} // '')
        . 'LinkedSpec::RuntimeSemanticObservation::emit_slot_selected('
        . '$descr, rule_label => ' . _quote_perl_string($args{label})
        . ', target_rule => ' . $target_rule_expr
        . ', regex_index => ' . $regex_index_expr
        . ', position => pos($$STRING));' . "\n";
    my $trace = _trace_branch_statement(
        enabled => $args{enabled},
        indent => $args{indent},
        label => $args{label},
        handler_kind => $args{handler_kind},
        branch => 'regex_slot_selected',
        taken_expr => '1',
        meta => [
            [ selection_role => _quote_perl_string($selection_role) ],
            [ target_rule => $target_rule_expr ],
            [ regex_index => $regex_index_expr ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "compiled_structural_slot" }',
    );
    return $observation . $trace;
}

#------------------------------------------------------------------------------
# Function: _build_acodes_dispatch_block
# Purpose : Build the if/elsif dispatch block for per-regex acode entries.
#------------------------------------------------------------------------------
sub _build_acodes_dispatch_block {
    my ($acodes_ref, %args) = @_;
    return '' unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
    my $trace_enabled = $args{trace_enabled} ? 1 : 0;
    my $label = $args{label};
    my $handler_kind = $args{handler_kind};
    my $once   = 0;
    my $idx    = 0;
    my $acodes = '';
    foreach my $acode (@$acodes_ref) {
        my $expected_idx = ref($args{dispatch_indices}) eq 'ARRAY'
            && defined($args{dispatch_indices}->[$idx])
            ? $args{dispatch_indices}->[$idx]
            : $idx;
        ++$idx;
        my $condition = _trace_branch_condition(
            enabled => $trace_enabled,
            label => $label,
            handler_kind => $handler_kind,
            branch => 'acode_index_' . $expected_idx,
            taken_expr => '$$minfo{index} == ' . $expected_idx,
            meta => [
                [ match_index => '$$minfo{index}' ],
                [ pos => 'pos($$STRING)' ],
            ],
            details_expr => 'sub { ' . _quote_perl_string('expected_index=' . $expected_idx) . ' }',
        );
        $acodes .= ($once++ ? " elsif " : "\n   if")
            . "($condition) {\n    $acode\n   }";
    }
    return $acodes;
}

#------------------------------------------------------------------------------
# Function: _build_bcodes_dispatch_block
# Purpose : Build the if/elsif dispatch block for per-edge bcode entries.
#------------------------------------------------------------------------------
sub _build_bcodes_dispatch_block {
    my ($bcalls_ref, $bcodes_ref, %args) = @_;
    return '' unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
    return '' unless ref($bcodes_ref) eq 'HASH';
    my $trace_enabled = $args{trace_enabled} ? 1 : 0;
    my $label = $args{label};
    my $handler_kind = $args{handler_kind};
    my $once   = 0;
    my $bcodes = '';
    foreach my $call (@$bcalls_ref) {
        my $call_code = defined($bcodes_ref->{$call}) ? $bcodes_ref->{$call} : '';
        my $condition = _trace_branch_condition(
            enabled => $trace_enabled,
            label => $label,
            handler_kind => $handler_kind,
            branch => 'bcode_call_' . $call,
            taken_expr => '$call eq ' . _quote_perl_string($call),
            meta => [
                [ call => '$call' ],
                [ pos => 'pos($$STRING)' ],
            ],
            details_expr => 'sub { ' . _quote_perl_string('expected_call=' . $call) . ' }',
        );
        $bcodes .= ($once++ ? " elsif " : "\n   if")
            . "($condition) {\n    $call_code\n   }";
    }
    return $bcodes;
}

#------------------------------------------------------------------------------
# Function: _build_lmatch_extraction
# Purpose : Common LMATCH/LMATCH_LIST/LMATCH_HASH/LINDEX/LSPOS extraction block.
#------------------------------------------------------------------------------
sub _build_lmatch_extraction {
    my (%args) = @_;
    my $label = _quote_perl_string($args{label});
    my $handler_kind = _quote_perl_string($args{handler_kind});
    return '
   my $LMATCH      = $$minfo{match};
   my @LMATCH_LIST = @{$$minfo{match_list} // []};
   my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
   my $LINDEX      = $$minfo{index};
   my $LSPOS       = pos $$STRING;
   LinkedSpec::RecognitionTransactionRuntime::note_match(
    $descr, $STRING, ' . $label . ', ' . $handler_kind . ',
    $LSPOS - length($LMATCH // ""), $LSPOS
   );';
}

sub _recognition_miss_statement {
    my ($label) = @_;
    return 'LinkedSpec::RecognitionTransactionRuntime::note_miss($descr, $STRING, '
        . _quote_perl_string($label) . '); '
}

sub _quote_perl_string {
    my ($value) = @_;
    $value = '' unless defined $value;
    $value =~ s/\\/\\\\/g;
    $value =~ s/'/\\'/g;
    $value =~ s/\r/\\r/g;
    $value =~ s/\n/\\n/g;
    return "'" . $value . "'";
}

sub _trace_branches_enabled {
    my ($ir) = @_;
    return 0 if ref($ir) eq 'HASH'
        && exists($ir->{trace_generated_handler_branches})
        && !$ir->{trace_generated_handler_branches};
    return 1;
}

sub _trace_branch_condition {
    my (%args) = @_;
    my $taken_expr = $args{taken_expr} // '0';
    return $taken_expr unless $args{enabled};

    my @fields = (
        'rule_label => ' . _quote_perl_string($args{label}),
        'handler_kind => ' . _quote_perl_string($args{handler_kind}),
        'branch => ' . _quote_perl_string($args{branch}),
        'taken => (' . $taken_expr . ')',
    );
    if (ref($args{meta}) eq 'ARRAY') {
        foreach my $pair (@{$args{meta}}) {
            next unless ref($pair) eq 'ARRAY' && @$pair == 2;
            push @fields, $pair->[0] . ' => ' . $pair->[1];
        }
    }
    push @fields, 'details => ' . $args{details_expr}
        if defined($args{details_expr}) && length($args{details_expr});
    return 'LinkedSpec::Trace::trace_generated_handler_branch(' . join(', ', @fields) . ')';
}

sub _trace_branch_statement {
    my (%args) = @_;
    return '' unless $args{enabled};
    my $indent = defined($args{indent}) ? $args{indent} : '';
    return $indent . _trace_branch_condition(%args) . ";\n";
}

#===========================================================================
# Backend dispatch table — maps backend names to emitter functions.
# The "perl" backend is the default and only backend; additional backends
# (e.g. JSON/AST diagnostic) register here through MEDIUM-IMPACT.1.5.
#===========================================================================
my %BACKEND_EMITTERS = (
    perl => \&_emit_handler_perl,
    json => \&_emit_handler_json,
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $gap_tail = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::install_tail($descr, $STRING, '
            . _quote_perl_string($label) . ', "LX"); '
        : '';
    my $lxcode     = _recognition_miss_statement($label) . $gap_tail
        . ($ir->{lxcode} || 'return undef');
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    my $acodes     = _build_acodes_dispatch_block(
        $ir->{acodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $lmatch     = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
    my $gap_candidate = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::install_candidate($descr, $STRING, $minfo, '
            . _quote_perl_string($label) . ');'
        : '';
    my $gap_ls = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "LS");'
        : '';
    my $gap_edge = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "edge");'
        : '';
    my $gap_le = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "LE");'
        : '';
    my $gap_commit = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::commit_candidate($descr, $STRING, '
            . _quote_perl_string($label) . ');'
        : '';
    my $match_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'match',
        taken_expr => 'defined($minfo) ? 1 : 0',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
    );
    my $slot_trace = _slot_selection_observation_and_trace(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        selection_role => 'choice',
    );
    my $lx_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '   ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'no_match_lx',
        taken_expr => '1',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "no regex match; executing LX/default miss path" }',
    );
    return '

 while (1) {
  my $minfo = ' . $match_expr . ';
' . $match_trace . '

  unless($minfo) {
' . $lx_trace . '
  ' . $lxcode . '
  }
' . $slot_trace . '
' . $lmatch . '

  ' . $gap_candidate . '

  ' . $gap_ls . '

  ' . $lscode . '

  ' . $gap_edge . '

  ' . $acodes . '

  ' . $gap_le . '

  ' . $lecode . '

  ' . $gap_commit . '

 }';
}

#------------------------------------------------------------------------------
# _emit_and_bcode_handler — foreach call loop, bcode dispatch, collect array.
#------------------------------------------------------------------------------
sub _emit_and_bcode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $lxcode     = _recognition_miss_statement($label) . ($ir->{lxcode} || 'return undef');
    my $lecode     = $ir->{lecode} || 'push @' . $label . '_collect, $' . $label;
    my $ecode      = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $bcodes     = _build_bcodes_dispatch_block(
        $ir->{bcalls_ref},
        $ir->{bcodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $bcalls     = join(' ', @{$ir->{bcalls_ref}});
    my $child_result_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'bcode_child_result',
        taken_expr => 'LinkedSpec::RecognitionTransactionRuntime::result_is_match($descr, $STRING, $' . $label . ')',
        meta => [
            [ call => '$current_call' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($' . $label . ') || "") }',
    );

    # When REs + and_icode are present (AND rule with per-regex I-block), emit
    # regex match + IMATCH bridge + return->assignment + push before edge dispatch.
    # This is the AND_BCODE-with-match extension that avoids MIXED_ACTIONS.
    my $match_section = '';
    if (ref($ir->{REs}) eq 'ARRAY' && @{$ir->{REs}}) {
        my $match_expr = _linkedre_or_expr(%$ir, label => $label);
        my $lmatch = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
        my $match_trace = _trace_branch_statement(
            enabled => $trace_enabled,
            indent => '  ',
            label => $label,
            handler_kind => $handler_kind,
            branch => 'match',
            taken_expr => 'defined($minfo) ? 1 : 0',
            meta => [
                [ pos => 'pos($$STRING)' ],
            ],
            details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
        );
        my $lx_trace = _trace_branch_statement(
            enabled => $trace_enabled,
            indent => '   ',
            label => $label,
            handler_kind => $handler_kind,
            branch => 'no_match_lx',
            taken_expr => '1',
            meta => [
                [ pos => 'pos($$STRING)' ],
            ],
            details_expr => 'sub { "no regex match; executing LX/default miss path" }',
        );
        $match_section .= '
  my $minfo = ' . $match_expr . ';
' . $match_trace . '
  unless($minfo) {
' . $lx_trace . '
   ' . $lxcode . '
  }
 ' . $lmatch . '
';

        # Per-regex I-block: apply return->assignment + IMATCH bridge + push
        my $and_icode = $ir->{and_icode};
        if (defined($and_icode) && length($and_icode)) {
            my $transformed = $and_icode;
            $transformed =~ s/\breturn\s*/"\$" . $label . " = "/eg;
            $match_section .= '
   # IMATCH bridge — let I-block code read the regex captures
   $IMATCH      = $LMATCH;
   @IMATCH_LIST = @LMATCH_LIST;
   %IMATCH_HASH = %LMATCH_HASH;
   $IINDEX      = $LINDEX;
   $IPOS        = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position(
    $info, $STRING, $LSPOS, "and_imatch_bridge"
   );

   ' . $transformed . ';

   push @' . $label . '_collect, $' . $label . ';
';
        }
    }

    return '

  my $' . $label . ';
  my @' . $label . '_collect;
 ' . $match_section . '
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   unless (' . $child_result_condition . ') {
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $match_expr = _linkedre_required_slot_expr(%$ir, label => $label, index_expr => '0');
    my $lxcode     = _recognition_miss_statement($label) . ($ir->{lxcode} || 'return undef');
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    # Edge acodes are emitted verbatim (already lowered): a `return(...)` edge lowers
    # to `return [...]` and surfaces the author payload directly (a single-regex AND
    # has one slot, index 0, so the edge return is the rule's result). Earlier code
    # looped over the acodes but never collected the rewritten string — the
    # `push @acodes_transformed` was missing — so the edge action was dropped and the
    # handler fell through to an empty `[]`; it also used the same broken `\$"`
    # substitution (a reference to the list-separator $") as the multi-regex handler.
    my $acodes = _build_acodes_dispatch_block(
        $ir->{acodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $lmatch     = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
    my $match_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => ' ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'match',
        taken_expr => 'defined($minfo) ? 1 : 0',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
    );
    my $lx_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'no_match_lx',
        taken_expr => '1',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "no regex match; executing LX/default miss path" }',
    );
    my $index_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'required_index_0',
        taken_expr => _slot_identity_condition(label => $label, index_expr => '0'),
        meta => [
            [ match_index => '$$minfo{index}' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "expected_index=0" }',
    );
    my $slot_trace = _slot_selection_observation_and_trace(
        enabled => $trace_enabled,
        indent => ' ',
        label => $label,
        handler_kind => $handler_kind,
        selection_role => 'ordered_required',
    );

    # Per-regex I-block code (routed through acode_entries by RuleIR for AND rules).
    # It runs after the regex match with return→assignment so the handler collects
    # the result instead of exiting early, and with an IMATCH←LMATCH bridge so
    # entry_group / match_text helpers can read the regex captures.
    my $and_icode_block = '';
    my $and_icode = $ir->{and_icode};
    if (defined($and_icode) && length($and_icode)) {
        my $transformed = $and_icode;
        $transformed =~ s/\breturn\s*/"\$" . $label . " = "/eg;
        $and_icode_block = '
   # IMATCH←LMATCH bridge — let I-block code read regex captures
   $IMATCH      = $LMATCH;
   @IMATCH_LIST = @LMATCH_LIST;
   %IMATCH_HASH = %LMATCH_HASH;
   $IINDEX      = $LINDEX;
   $IPOS        = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position(
    $info, $STRING, $LSPOS, "and_imatch_bridge"
   );

   ' . $transformed . ';

   push @' . $label . '_collect, $' . $label . ';
';
    }

    return '

 my @' . $label . '_collect;
 my $minfo = ' . $match_expr . ';
' . $match_trace . '
 unless($minfo) {
' . $lx_trace . '
  ' . $lxcode . '
 }

 unless(' . $index_condition . ') {
  ' . $lxcode . '
 }
' . $slot_trace . '
' . $lmatch . '
' . $and_icode_block . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $uses_local_structural_slots = ($ir->{required_slot_mode} // '') eq 'local_structural';
    my $match_expr  = $uses_local_structural_slots
        ? _linkedre_local_structural_slot_expr(%$ir, label => $label, index_expr => '$idx')
        : _linkedre_required_slot_expr(%$ir, label => $label, index_expr => '$idx');
    my $lxcode      = _recognition_miss_statement($label) . ($ir->{lxcode} || 'return undef');
    my $lscode      = $ir->{lscode} || '';
    my $lecode      = $ir->{lecode} || '';
    my $acode_count = $ir->{acode_count};
    my $required_slot_count = $uses_local_structural_slots
        ? $ir->{required_slot_count}
        : $acode_count;
    # Edge acodes are emitted verbatim: they are already lowered (e.g.
    # return(array(...)) -> `return [...]`, assignment helpers -> in-place mutation). A
    # `return` edge then surfaces the author payload directly — from the whole
    # handler in a direct AND, or from the per-iteration coderef in a REP-AND
    # (`:AND+`, where _emit_rep_and_acode_handler wraps this body in `sub { ... }`),
    # which is the correct collection point in both cases. Earlier code rewrote
    # `return` into a `$<label> =` assignment with a mis-written `\$"` substitution —
    # `\$"` parses as a reference to the list-separator variable $", so the emitter
    # produced invalid `SCALAR(0x..)<label> = ...` Perl (compile-fail for a top rule,
    # dropped payload for a child) AND the wrong (collect-wrapped) result shape.
    my $acodes = _build_acodes_dispatch_block(
        $ir->{acodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
        dispatch_indices => $ir->{acode_dispatch_indices},
    );
    my $lmatch      = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
    my $match_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'match',
        taken_expr => 'defined($minfo) ? 1 : 0',
        meta => [
            [ loop_count => '$idx' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
    );
    my $index_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'required_sequence_index',
        taken_expr => $uses_local_structural_slots
            ? _local_structural_slot_identity_condition(label => $label, index_expr => '$idx')
            : _slot_identity_condition(label => $label, index_expr => '$idx'),
        meta => [
            [ loop_count => '$idx' ],
            [ match_index => '$$minfo{index}' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "expected_index=$idx" }',
    );
    my $slot_trace = _slot_selection_observation_and_trace(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        selection_role => 'ordered_required',
    );
    return '

 my @' . $label . '_collect;
 my $idx = 0;

 while ($idx < ' . $required_slot_count . ') {
  my $minfo = ' . $match_expr . ';
' . $match_trace . '
  unless($minfo) {
   ' . $lxcode . '
  }

  unless(' . $index_condition . ') {
   ' . $lxcode . '
  }
' . $slot_trace . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $lxcode = $ir->{lxcode} || 'return $' . $label;
    my $ecode  = $ir->{ecode}  || 'return undef';
    my $bcodes = _build_bcodes_dispatch_block(
        $ir->{bcalls_ref},
        $ir->{bcodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $bcalls = join(' ', @{$ir->{bcalls_ref}});
    my $child_result_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'bcode_child_result',
        taken_expr => 'LinkedSpec::RecognitionTransactionRuntime::result_is_match($descr, $STRING, $' . $label . ')',
        meta => [
            [ call => '$current_call' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($' . $label . ') || "") }',
    );
    my $no_child_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'bcode_no_child_match',
        taken_expr => '1',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "executing OR bcode miss/default E path" }',
    );
    return '

  my $' . $label . ';
  foreach my $call (qw(' . $bcalls . ')) {
   my $current_call = $call;

   ' . $bcodes . '

   if (' . $child_result_condition . ') {
    ' . $lxcode . '
   }
  }

' . $no_child_trace . '
  ' . $ecode . '
 ';
}

#------------------------------------------------------------------------------
# _emit_or_acode_handler — single match, no index check, acode dispatch.
#------------------------------------------------------------------------------
sub _emit_or_acode_handler {
    my ($ir) = @_;
    my $label      = $ir->{label};
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $lxcode     = _recognition_miss_statement($label) . ($ir->{lxcode} || 'return undef');
    my $acodes     = _build_acodes_dispatch_block(
        $ir->{acodes_ref},
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $lmatch     = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
    my $match_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => ' ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'match',
        taken_expr => 'defined($minfo) ? 1 : 0',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
    );
    my $slot_trace = _slot_selection_observation_and_trace(
        enabled => $trace_enabled,
        indent => ' ',
        label => $label,
        handler_kind => $handler_kind,
        selection_role => 'choice',
    );
    my $lx_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '  ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'no_match_lx',
        taken_expr => '1',
        meta => [
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "no regex match; executing LX/default miss path" }',
    );
    return '

 my $minfo = ' . $match_expr . ';
' . $match_trace . '
 unless($minfo) {
' . $lx_trace . '
 ' . $lxcode . '
 }
' . $slot_trace . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $or_ret;';
    my $loop_enter_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'loop_enter',
        taken_expr => '1',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "starting REP bcode iteration" }',
    );
    my $or_result_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'iteration_result',
        taken_expr => 'LinkedSpec::RecognitionTransactionRuntime::result_is_match($descr, $STRING, $or_ret)',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($or_ret) || "") }',
    );
    my $miss_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'miss_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "inner OR_BCODE result was false" }',
    );
    my $zero_progress_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'zero_progress',
        taken_expr => '$loop_end_pos == $loop_start_pos',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => '$loop_end_pos' ],
        ],
        details_expr => 'sub { "loop_start_pos=$loop_start_pos loop_end_pos=$loop_end_pos" }',
    );
    my $zero_progress_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'zero_progress_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => '$loop_end_pos' ],
        ],
        details_expr => 'sub { "zero progress cutoff" }',
    );
    my $max_continue_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'max_continue',
        taken_expr => '$ccount < $max',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "continue while loop_count < max" }',
    );

    # Build inner OR_BCODE as a coderef
    my $or_body = _emit_or_bcode_handler({
        %$ir,
        kind   => 'or_bcode',
        ecode  => 'return undef',
        lxcode => $ir->{lxcode} || 'return $' . $label,
        trace_generated_handler_branches => 0,
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
' . $loop_enter_trace . '
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $or_ret = $or_code->();
    unless (' . $or_result_condition . ') {
     if (' . $miss_min_condition . ') {
      ' . $excode . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    LinkedSpec::RecognitionTransactionRuntime::assert_repetition_progress(
     $descr, $STRING, ' . _quote_perl_string($label) . ', $loop_start_pos, $loop_end_pos
    );
    if (' . $zero_progress_condition . ') {
     if (' . $zero_progress_min_condition . ') {
      ' . $excode . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . $itcode . '

    last unless ' . $max_continue_condition . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $and_ret;';
    my $loop_enter_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'loop_enter',
        taken_expr => '1',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "starting REP AND_BCODE iteration" }',
    );
    my $and_result_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'iteration_result',
        taken_expr => 'LinkedSpec::RecognitionTransactionRuntime::result_is_match($descr, $STRING, $and_ret)',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($and_ret) || "") }',
    );
    my $miss_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'miss_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "inner AND_BCODE result was false" }',
    );
    my $zero_progress_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'zero_progress',
        taken_expr => '$loop_end_pos == $loop_start_pos',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => '$loop_end_pos' ],
        ],
        details_expr => 'sub { "loop_start_pos=$loop_start_pos loop_end_pos=$loop_end_pos" }',
    );
    my $zero_progress_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'zero_progress_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => '$loop_end_pos' ],
        ],
        details_expr => 'sub { "zero progress cutoff" }',
    );
    my $max_continue_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'max_continue',
        taken_expr => '$ccount < $max',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "continue while loop_count < max" }',
    );

    # Build inner AND_BCODE as a coderef
    my $and_body = _emit_and_bcode_handler({
        %$ir,
        kind  => 'and_bcode',
        ecode => 'return \@' . $label . '_collect',
        trace_generated_handler_branches => 0,
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
' . $loop_enter_trace . '
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $and_ret = $and_code->();
    unless (' . $and_result_condition . ') {
     if (' . $miss_min_condition . ') {
      ' . $excode . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    LinkedSpec::RecognitionTransactionRuntime::assert_repetition_progress(
     $descr, $STRING, ' . _quote_perl_string($label) . ', $loop_start_pos, $loop_end_pos
    );
    if (' . $zero_progress_condition . ') {
     if (' . $zero_progress_min_condition . ') {
      ' . $excode . '
     } else {
      return undef
     }
    }

    ++$ccount;

    ' . $itcode . '

    last unless ' . $max_continue_condition . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $min    = $ir->{rep_min};
    my $max    = $ir->{rep_max};
    my $excode = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode  = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode = $ir->{itcode} || 'push @' . $label . '_collect, $and_ret;';
    my $loop_enter_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'loop_enter',
        taken_expr => '1',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "starting REP AND_ACODE iteration" }',
    );
    my $and_result_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'iteration_result',
        taken_expr => 'LinkedSpec::RecognitionTransactionRuntime::result_is_match($descr, $STRING, $and_ret)',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($and_ret) || "") }',
    );
    my $miss_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'miss_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "inner AND_ACODE result was false" }',
    );
    my $max_continue_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'max_continue',
        taken_expr => '$ccount < $max',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "continue while loop_count < max" }',
    );

    # Build inner AND_ACODE as a coderef
    my $and_body = _emit_and_acode_seq_handler({
        %$ir,
        kind        => 'and_acode_seq',
        acode_count => $ir->{acode_count},
        ecode       => 'return \@' . $label . '_collect',
        trace_generated_handler_branches => 0,
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
' . $loop_enter_trace . '
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $and_ret = $and_code->();
    unless (' . $and_result_condition . ') {
     if (' . $miss_min_condition . ') {
      ' . $excode . '
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    LinkedSpec::RecognitionTransactionRuntime::assert_repetition_progress(
     $descr, $STRING, ' . _quote_perl_string($label) . ', $loop_start_pos, $loop_end_pos
    );

    ++$ccount;

    ' . $itcode . '

    last unless ' . $max_continue_condition . '
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
    my $handler_kind = $ir->{kind};
    my $trace_enabled = _trace_branches_enabled($ir);
    my $match_expr = _linkedre_or_expr(%$ir, label => $label);
    my $min        = $ir->{rep_min};
    my $max        = $ir->{rep_max};
    my $lscode     = $ir->{lscode} || '';
    my $lecode     = $ir->{lecode} || '';
    my $excode     = $ir->{excode} || 'return \@' . $label . '_collect';
    my $ecode      = $ir->{ecode}  || 'return \@' . $label . '_collect';
    my $itcode     = $ir->{itcode} || 'push @' . $label . '_collect, $' . $label . ';';
    my $gap_ex = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::install_tail($descr, $STRING, '
            . _quote_perl_string($label) . ', "EX");'
        : '';
    my $gap_e = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::install_tail($descr, $STRING, '
            . _quote_perl_string($label) . ', "E");'
        : '';
    my $gap_candidate = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::install_candidate($descr, $STRING, $minfo, '
            . _quote_perl_string($label) . ');'
        : '';
    my $gap_ls = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "LS");'
        : '';
    my $gap_edge = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "edge");'
        : '';
    my $gap_le = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "LE");'
        : '';
    my $gap_commit = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::commit_candidate($descr, $STRING, '
            . _quote_perl_string($label) . ');'
        : '';
    my $gap_it = $ir->{capture_gaps}
        ? 'LinkedSpec::InterMatchGapRuntime::set_phase($descr, $STRING, '
            . _quote_perl_string($label) . ', "IT");'
        : '';

    # REP: replace return with assignment so loop collects
    my $acodes_ref = $ir->{acodes_ref};
    my @acodes_transformed;
    foreach my $acode (@$acodes_ref) {
        my $transformed = $acode;
        $transformed =~ s/\breturn\s+/"\$" . $label . " = "/eg;
        push @acodes_transformed, $transformed;
    }
    my $acodes = _build_acodes_dispatch_block(
        \@acodes_transformed,
        label => $label,
        handler_kind => $handler_kind,
        trace_enabled => $trace_enabled,
    );
    my $lmatch = _build_lmatch_extraction(label => $label, handler_kind => $handler_kind);
    my $loop_enter_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'loop_enter',
        taken_expr => '1',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "starting REP acode iteration" }',
    );
    my $match_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'match',
        taken_expr => 'defined($minfo) ? 1 : 0',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { defined($minfo) ? "match_index=$$minfo{index}" : "no_match" }',
    );
    my $miss_min_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'miss_min_satisfied',
        taken_expr => '$ccount >= $min',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "regex match was false" }',
    );
    my $iteration_success_trace = _trace_branch_statement(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        branch => 'iteration_result',
        taken_expr => '1',
        meta => [
            [ loop_count => '$ccount' ],
            [ match_index => '$$minfo{index}' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "return_ref=" . (ref($' . $label . ') || "") }',
    );
    my $slot_trace = _slot_selection_observation_and_trace(
        enabled => $trace_enabled,
        indent => '    ',
        label => $label,
        handler_kind => $handler_kind,
        selection_role => 'choice',
    );
    my $max_continue_condition = _trace_branch_condition(
        enabled => $trace_enabled,
        label => $label,
        handler_kind => $handler_kind,
        branch => 'max_continue',
        taken_expr => '$ccount < $max',
        meta => [
            [ loop_count => '$ccount' ],
            [ rep_min => '$min' ],
            [ rep_max => '$max' ],
            [ pos => 'pos($$STRING)' ],
        ],
        details_expr => 'sub { "continue while loop_count < max" }',
    );

    return '

   my $min=' . $min . ';
   my $max=' . $max . ';
   my @' . $label . '_collect;
   my $ccount = 0;

   while(1) {
' . $loop_enter_trace . '
    my $minfo = ' . $match_expr . ';
    unless(' . $match_condition . ') {
     if (' . $miss_min_condition . ') {
      ' . $gap_ex . '
      ' . $excode . '
     } else {
      return undef
     }
    }
' . $slot_trace . '
' . $lmatch . '

    ' . $gap_candidate . '

    ' . $gap_ls . '

    ' . $lscode . '

    ' . $gap_edge . '

    ' . $acodes . '

    ' . $gap_le . '

    ' . $lecode . '

    ' . $gap_commit . '
' . $iteration_success_trace . '

    ++$ccount;

    ' . $gap_it . '

    ' . $itcode . '

    last unless ' . $max_continue_condition . '
   }

   ' . $gap_e . '

   ' . $ecode . '
 ';
}

#===========================================================================
# JSON/AST diagnostic backend — serializes HandlerIR to structured JSON.
# Uses JSON::PP (Perl core since 5.14) for safe, deterministic output.
#===========================================================================

#------------------------------------------------------------------------------
# _emit_handler_json — emit HandlerIR as a JSON document.
# Returns a JSON string with kind, label, cursor_policy, lifecycle slots,
# dispatch refs, and repetition bounds (where applicable).
#------------------------------------------------------------------------------
sub _emit_handler_json {
    my ($ir) = @_;
    return undef unless ref($ir) eq 'HASH';

    require JSON::PP;
    my $json = JSON::PP->new->canonical(1)->pretty(1);

    # Build a clean serializable structure — drop undef/empty values
    my %obj;
    $obj{kind}       = $ir->{kind};
    $obj{label}      = $ir->{label};
    $obj{cursor_policy} = $ir->{cursor_policy}
        if defined $ir->{cursor_policy} && length($ir->{cursor_policy});

    # Lifecycle slots (only include non-empty)
    foreach my $slot (qw(preamble lxcode lscode lecode ecode excode itcode)) {
        $obj{$slot} = $ir->{$slot} if defined $ir->{$slot} && length($ir->{$slot});
    }

    # Dispatch refs (acodes and bcodes)
    if (ref($ir->{acodes_ref}) eq 'ARRAY' && @{$ir->{acodes_ref}}) {
        $obj{acodes} = $ir->{acodes_ref};
    }
    if (ref($ir->{bcodes_ref}) eq 'HASH' && keys %{$ir->{bcodes_ref}}) {
        $obj{bcodes} = $ir->{bcodes_ref};
    }
    if (ref($ir->{bcalls_ref}) eq 'ARRAY' && @{$ir->{bcalls_ref}}) {
        $obj{bcalls} = $ir->{bcalls_ref};
    }

    # Repetition bounds (REP variants only)
    $obj{rep_min} = $ir->{rep_min} if defined $ir->{rep_min};
    $obj{rep_max} = $ir->{rep_max} if defined $ir->{rep_max};

    # Sequence count (AND_ACODE_SEQ variants)
    $obj{acode_count} = $ir->{acode_count} if defined $ir->{acode_count};

    return $json->encode(\%obj);
}

1;
