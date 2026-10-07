use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-';
open my $file, '<:raw', $prefix . 'cases.json' or die $!;
my $rows = JSON::PP->new->utf8->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @observed;
for my $row (@$rows) {
    my $source = $row->{source};
    my $slash = index($source, '/');
    push @observed, {
        id => $row->{id}, source => $source,
        default_helper_ranges => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source),
        explicit_default_ranges => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source, 0),
        default_structural_view => LinkedSpec::ActionIR::MethodExpr::_helper_pattern_view($source),
        default_numeric_discriminator => $slash < 0 ? undef :
            LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($source, $slash),
        numeric_only_discriminator => $slash < 0 ? undef :
            LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($source, $slash, 1),
        syntactic_set => LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => 'set_value'}, $source, $deps),
        syntactic_return => LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => 'return_general'}, $source, $deps),
    };
}
print JSON::PP->new->canonical->pretty->encode(\@observed);
