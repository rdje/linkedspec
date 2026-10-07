use strict;
use warnings;
use utf8;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $rules = LinkedSpec::RuleIR::EmitContext::_build_action_lowering_contracts('Top');
my @sources = (
    q{' 雪 '.trim()},
    q{trim(' 雪 ')},
    q{return('return("x")'); return("x")},
    q{text="set(counter,1)"; set(counter,2); set(counter,1); return(counter)},
    q{q|set(counter,1)|; set(counter,2)},
    q{return(matches("ifXtrue", /if(true)/))},
);
my @rows;
for my $source (@sources) {
    my @scans;
    for my $rule (@$rules) {
        my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance($rule, $source, $deps);
        next unless ref($result->{events}) eq 'ARRAY' && @{$result->{events}};
        push @scans, {contract => $rule->{id}, %$result};
    }
    push @rows, {source => $source, scans => \@scans,
        lowered => LinkedSpec::call_spec_handler_subst('Top', $source)};
}
binmode STDOUT, ':raw';
print JSON::PP->new->canonical->utf8->encode(\@rows), "\n";
