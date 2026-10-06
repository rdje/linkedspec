use strict;
use warnings;
use utf8;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1-';
my $json = JSON::PP->new->canonical->utf8;
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @rows;
for my $case (@$cases) {
    my $row = {id => $case->{id}};
    my ($stdout, $stderr) = ('', '');
    {
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        $row->{events} = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            {id => 'capture_until_boundary'}, $case->{action}, $deps);
        if (defined $case->{labels}) {
            $row->{substitution} = LinkedSpec::call_spec_handler_subst('Top', $case->{raw});
            if ($case->{id} eq 'escaped-comma') {
                my $trace = '';
                {
                    open my $trace_out, '>', \$trace or die $!;
                    local *STDOUT = $trace_out;
                    LinkedSpec::configure_trace(trace_level => 'debug');
                    $row->{assignment_substitution} = LinkedSpec::call_spec_handler_subst('Top', 'body = '.$case->{raw});
                    LinkedSpec::configure_trace(quiet => 1);
                }
                $row->{assignment_trace} = $trace;
            }
            my $spec = "Top::\n I { body = $case->{raw}; return(hash(\"body\", body, \"cursor\", cursor_pos(), \"rest\", cursor_rest())) }\n\na: /a/\nb: /b/\nc: /c/\nend: /END/\n";
            my $dump;
            LinkedSpec::Get(\$spec, dump_parser_source => 1, parser_source_ref => \$dump);
            $row->{parser_source} = $dump;
            my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
            $row->{action_rewriter} = $descriptor->{spec}{Top}{meta}{action_rewriter};
            my %runtime_ctx;
            my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%runtime_ctx);
            $row->{built} = ref($parser);
            my $input = $case->{input};
            $row->{value} = $parser->(\$input);
            $row->{runtime_error} = $runtime_ctx{last_error};
        }
        1;
    };
    $row->{failure} = $@ unless $ok;
    }
    $row->{stdout} = $stdout;
    $row->{stderr} = $stderr;
    push @rows, $row;
}
print $json->encode(\@rows), "\n";
