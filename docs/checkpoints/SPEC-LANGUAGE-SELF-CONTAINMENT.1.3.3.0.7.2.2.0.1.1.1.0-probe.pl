use strict;
use warnings;
use utf8;
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use B ();
use Cwd ();
use File::Spec ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $split = $deps->{split_action_ir_statements};
my $trim = $deps->{trim_action_ir_value};
my $cv = B::svref_2object($split);
my @rows;
for my $case (@$cases) {
    my ($split_rows, $public, $private, $substitution, $diagnostics, $dump, $failure);
    my ($stdout, $stderr) = ('', '');
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        my $ok = eval {
            $split_rows = [map { +{split_text => $_, trimmed => $trim->($_)} } @{$split->($case->{action})}];
            my $contract = {id => $case->{contract}};
            $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $case->{action}, $deps);
            $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance($contract, $case->{action}, $deps);
            $substitution = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
            my $source = "Top::\n I { $case->{action} }\n";
            LinkedSpec::Get(\$source, dump_parser_source => 1, parser_source_ref => \$dump);
            my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
            $diagnostics = $descriptor->{spec}{Top}{meta}{action_rewriter};
            1;
        };
        $failure = $@ unless $ok;
    }
    push @rows, {case => $case, split => $split_rows, public_events => $public,
        private_result => $private, substitution => $substitution, diagnostics => $diagnostics,
        dump => $dump, failure => $failure, internal_stdout => $stdout, internal_stderr => $stderr};
}
print $json->pretty->encode({dependency_keys => [sort keys %$deps],
    split_callback => {file => File::Spec->abs2rel($cv->GV->FILE, Cwd::getcwd()), line => $cv->GV->LINE}, rows => \@rows});
