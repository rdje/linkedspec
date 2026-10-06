use strict;
use warnings;
use utf8;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::MethodLowering ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
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
        if ($case->{node}) {
            $row->{node_before} = $json->decode($json->encode($case->{node}));
            $row->{source} = LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr($case->{node});
            $row->{node_after} = $case->{node};
        } else {
            my $action = $case->{action};
            $row->{substitution} = LinkedSpec::call_spec_handler_subst('Top', $action);
            if ($case->{id} eq 'assignment') {
                my $trace = '';
                {
                    open my $trace_out, '>', \$trace or die $!;
                    local *STDOUT = $trace_out;
                    LinkedSpec::configure_trace(trace_level => 'debug');
                    $row->{traced_substitution} = LinkedSpec::call_spec_handler_subst('Top', $action);
                    LinkedSpec::configure_trace(quiet => 1);
                }
                $row->{trace} = $trace;
            }
            my $spec = "Top::\n I { $action }\na: /a/\nb: /b/\nc: /c/\nend: /END/\n";
            my $dump;
            LinkedSpec::Get(\$spec, dump_parser_source => 1, parser_source_ref => \$dump);
            $row->{parser_source} = $dump;
            my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
            $row->{action_rewriter} = $descriptor->{spec}{Top}{meta}{action_rewriter};
            my %ctx;
            my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
            my $input = $case->{input};
            $row->{built} = ref($parser);
            $row->{value} = $parser->(\$input);
            $row->{runtime_error} = $ctx{last_error};
        }
        1;
    };
    $row->{failure} = $@ unless $ok;
    }
    $row->{stdout} = $stdout; $row->{stderr} = $stderr;
    push @rows, $row;
}
print $json->encode(\@rows), "\n";
