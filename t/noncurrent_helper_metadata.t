#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();

my %retired_helper = map { $_ => 1 } qw(
    declare declare_s declare_a declare_h
    assign
    scalar s a h
    array_copy hash_copy concat
    push_value push_nonempty
    return_a return_m return_ma return_imatch return_im
    return_array return_hash return_scalar
);

subtest 'contract metadata does not publish retired helper ids' => sub {
    my $contracts = LinkedSpec::RuleIR::EmitContext::_build_action_lowering_contracts('Top');
    ok(ref($contracts) eq 'ARRAY' && @$contracts, 'ActionIR contract table builds');

    my @bad;
    for my $contract (@$contracts) {
        next unless ref($contract) eq 'HASH';
        for my $field (qw(id diag_name)) {
            my $value = $contract->{$field};
            next unless defined($value) && exists $retired_helper{$value};
            push @bad, "$field=$value";
        }
    }

    is_deeply(\@bad, [], 'contract ids and diagnostic names avoid the retired SPEC-FORMAT-TERSE.8 helper set');
};

subtest 'canonical metadata keeps generic unknown calls out of retired helper contracts' => sub {
    my $spec_content = <<'SPEC';
Top:: /a/ -> Top {
    return(unknown_alpha("a","b"));
    return(unknown_beta(foo))
}
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descriptor => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for generic unknown-helper metadata probe');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'action rewriter metadata is present');

    my @bad_rewrite_ids = grep { defined($_) && exists $retired_helper{$_} } @{$meta->{rewrite_contract_ids} || []};
    is_deeply(\@bad_rewrite_ids, [], 'rewrite contract id metadata avoids retired helper ids');

    my @bad_event_ids = grep {
        ref($_) eq 'HASH'
            && defined($_->{contract_id})
            && exists $retired_helper{$_->{contract_id}}
    } @{$meta->{canonical_action_ir_events} || []};
    is_deeply(\@bad_event_ids, [], 'canonical ActionIR events do not use retired helper contract ids');

    my @unsupported_helpers = sort grep { defined($_) }
        map { ref($_) eq 'HASH' ? $_->{helper} : undef } @{$meta->{unresolved_helper_events} || []};
    is_deeply(\@unsupported_helpers, [qw(unknown_alpha unknown_beta)], 'generic unsupported-helper events remain visible');

    my @bad_unsupported_helpers = grep { exists $retired_helper{$_} } @unsupported_helpers;
    is_deeply(\@bad_unsupported_helpers, [], 'generic unsupported-helper events avoid retired helper ids');
};

done_testing();
