use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_EVENT_ORDER_BASELINE}) {
        require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1-before.pm';
        $INC{'LinkedSpec/ActionIR/CanonicalEvents.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1-before.pm';
    }
}
use LinkedSpec::ActionIR::CanonicalEvents ();
sub helper {
    my ($raw, $payload, $exclusive, $contract) = @_;
    return {raw => $raw, args => {payload => $payload}, ir_node => 'RETURN',
        contract_id => $contract // 'return_general', exclusive_statement => $exclusive // 0};
}
sub build {
    my ($events, $statements) = @_;
    return LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(
        'Top', join(';', @$statements), $events,
        {trim_action_ir_value => sub {
            my ($raw) = @_;
            return undef unless defined $raw;
            $raw =~ s/^\s+|\s+$//g;
            return $raw;
        }, split_action_ir_statements => sub { return $statements }});
}
my $events = [helper('return(a)','a'), helper('return(b)','b'), helper('return(a)','a')];
my $json = JSON::PP->new->canonical;
my $original = $json->encode($events);
my $diag = build($events, []);
my $actual = $diag->{canonical_action_ir_events};
is_deeply([map { $_->{raw} } @$actual], ['return(a)','return(b)','return(a)'],
    'interleaved residual scan occurrences remain A/B/A rather than raw-key groups');
is($diag->{canonical_action_ir_count}, 3, 'all three occurrences counted');
is_deeply($diag->{canonical_action_ir_hits}, {RETURN => 3}, 'kind telemetry retains duplicate occurrences');
isnt(refaddr($actual->[0]), refaddr($actual->[2]), 'equal-text occurrences remain distinct canonical records');
ok(!grep({ exists $_->{_exclusive_statement} } @$actual), 'private ownership flag does not escape');
is($json->encode($events), $original, 'canonical assembly does not mutate scanner input');
$diag = build($events, ['return(b)','return(a)']);
is_deeply([map { $_->{raw} } @{$diag->{canonical_action_ir_events}}], ['return(b)','return(a)','return(a)'],
    'authored top-level order precedes the remaining occurrence');
is_deeply([map { $_->{source} } @{$diag->{canonical_action_ir_events}}],
    ['helper_contract','helper_contract','unmatched_helper_scan_event'], 'consumed occurrences are not replayed');
$diag = build([helper('return(a)','a',1),helper('return(b)','b'),helper('return(a)','a',0,'return')], ['return(a)']);
is_deeply([map { $_->{raw} } @{$diag->{canonical_action_ir_events}}], ['return(a)','return(b)'],
    'exclusive top-level ownership removes the whole matching raw-key queue');
is($diag->{canonical_action_ir_count}, 2, 'discarded exclusive alternatives are not counted');
ok(!grep({ exists $_->{_exclusive_statement} } @{$diag->{canonical_action_ir_events}}), 'exclusive flags remain private');
$diag = build([helper('', 'empty'),helper(undef,'absent')], ['legacy_token']);
is_deeply([map { $_->{kind} } @{$diag->{canonical_action_ir_events}}], ['RAW_PERL'], 'blank helper keys are skipped and fallback retained');
is($diag->{canonical_action_ir_fallback_count}, 1, 'fallback telemetry is unchanged');
is(build([],[])->{canonical_action_ir_count}, 0, 'empty action has no invented occurrence');
$diag = build([helper(' return(a) ','a')], ['return(a)']);
is($diag->{canonical_action_ir_events}[0]{raw}, ' return(a) ', 'matching trims queue keys without altering raw provenance');
done_testing();
