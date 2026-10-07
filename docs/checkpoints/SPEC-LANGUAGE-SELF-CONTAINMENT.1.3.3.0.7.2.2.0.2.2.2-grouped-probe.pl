use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::SourceMembership ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my @rows;
for my $params ('x,y', 'x,z', 'x,...y') {
    for my $pattern ('/(set(counter,1)).*x/', '/(set(counter,1)),x/') {
        my $body = 'return(matches("setcounter,1,x", ' . $pattern . '))';
        my $action = 'cb={|' . $params . '| ' . $body . ' }; return(cb("ok","unused"))';
        my $source = 'Top:: I { ' . $action . ' }';
        my $contract = {id => 'set_value'};
        my ($produced, $events);
        my $original = \&LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance;
        {
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance = sub {
                $produced = $original->(@_); return $produced;
            };
            $events = LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_events($contract, $action);
        }
        my %selected = map {refaddr($_) => 1} @$events;
        my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
        my %ctx;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
        my $input = '';
        my $value = $parser->(\$input);
        push @rows, {params => $params, pattern => $pattern, action => $action,
            contract => 'set_value', expected_events => [],
            observed_events => [map { $_->{raw} } @$events], expected_value => 1,
            original_origins => [map { {raw => $_->{event}{raw}, span => $_->{source_span},
                selected => $selected{refaddr($_->{event})} ? 1 : 0} } @{$produced->{source_origins}}],
            value => $value, context_error => $ctx{last_error}, substitution => $lowered,
            helper_patterns => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($action),
            literal_ranges => LinkedSpec::ActionIR::SourceMembership::_literal_source_ranges($action)};
    }
}
print JSON::PP->new->canonical->pretty->encode(\@rows);
