use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::SourceMembership ();
use LinkedSpec::ActionIR::MethodExpr ();
use JSON::PP ();

my @rows;
for my $params ('x,y', 'x,z', 'x,...y') {
    for my $pattern ('/(return(fake)).*x/', '/(return(fake)),x/') {
        my $body = 'return(matches("returnfake,x", ' . $pattern . '))';
        my $action = 'cb={|' . $params . '| ' . $body . ' }; return(cb("ok","unused"))';
        my $source = 'Top:: I { ' . $action . ' }';
        my $events = LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_events({id => 'return_general'}, $action);
        my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
        my %ctx;
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
        my $input = '';
        my $value = $parser->(\$input);
        push @rows, {params => $params, pattern => $pattern, action => $action,
            expected_returns => [$body, 'return(cb("ok","unused"))'],
            observed_returns => [map { $_->{raw} } @$events], expected_value => 1,
            value => $value, context_error => $ctx{last_error}, substitution => $lowered,
            helper_patterns => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($action),
            literal_ranges => LinkedSpec::ActionIR::SourceMembership::_literal_source_ranges($action)};
    }
}
print JSON::PP->new->canonical->pretty->encode(\@rows);
