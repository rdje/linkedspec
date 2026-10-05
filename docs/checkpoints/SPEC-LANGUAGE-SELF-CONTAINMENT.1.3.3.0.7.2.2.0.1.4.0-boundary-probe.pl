use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();

my $json = JSON::PP->new->canonical->utf8;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @rows;
for my $action (q{capture_until_boundary("stop", end)},
                q{capture_until_boundary(stop, end)},
                q{capture_until_boundary("a,b", end)}) {
    my ($stdout, $stderr) = ('', '');
    my $row = {source => $action};
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        eval {
            $row->{events} = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
                {id => 'capture_until_boundary'}, $action, $deps);
            $row->{substitution} = LinkedSpec::call_spec_handler_subst('Top', $action);
            my $spec = "Top::\n /x/ { $action; return(1) }\n";
            my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
            $row->{action_rewriter} = $descriptor->{spec}{Top}{meta}{action_rewriter}
                if $descriptor && $descriptor->{spec}{Top};
            my $dump;
            LinkedSpec::Get(\$spec, dump_parser_source => 1, parser_source_ref => \$dump);
            $row->{parser_source} = $dump;
            1;
        } or $row->{error} = "$@";
    }
    $row->{stdout} = $stdout;
    $row->{stderr} = $stderr;
    push @rows, $row;
}
print $json->encode(\@rows), "\n";
