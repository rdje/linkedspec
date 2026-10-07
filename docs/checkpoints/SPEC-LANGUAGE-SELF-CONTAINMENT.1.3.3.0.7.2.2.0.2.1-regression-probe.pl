use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::SourceMembership ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $rules = LinkedSpec::RuleIR::EmitContext::_build_action_lowering_contracts('Top');
my @rows;
for my $tail ('rx = q/;/', 'rx = qr/}/', 'rx = q|/;|', 'rx = s/a;b/c;d/') {
    my $source = "out = /(14,2)\n$tail; return(out)";
    my @scans;
    for my $rule (@$rules) {
        my $original = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance($rule, $source, $deps);
        next unless ref($original->{events}) eq 'ARRAY' && @{$original->{events}};
        my $selected = LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events($source, $original);
        push @scans, {contract => $rule->{id}, original => $original, selected => $selected};
    }
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $source);
    my $run = eval "sub { no strict; $lowered }";
    my $compile_error = $@;
    local $_ = 'x';
    my $value = $run ? eval { $run->() } : undef;
    push @rows, {source => $source, lowered => $lowered, scans => \@scans,
        ranges => LinkedSpec::ActionIR::SourceMembership::_literal_source_ranges($source),
        numeric_slash => LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($source, 6, 1),
        compile_error => $compile_error, value => $value};
}
print JSON::PP->new->canonical->pretty->encode(\@rows);
