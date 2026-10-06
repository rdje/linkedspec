use strict;
use warnings;
use utf8;
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::StatementSplit::Core ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my @reports;
for my $case (@$cases) {
my $id = $case->{id};
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my ($frames, @rows, $substitution, $diagnostics, $dump, $failure);
my ($stdout, $stderr) = ('', '');
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        my $framed = LinkedSpec::ActionIR::StatementSplit::Core::_split_with_source_frames(
            $deps->{split_action_ir_statements}, $case->{action});
        $frames = $framed->{source_frames};
        for my $contract (@{$case->{contracts}}) {
            my (@public_calls, @private_calls, @constructed);
            my $scan = sub {
                my ($private, $calls) = @_;
                my %observed_deps;
                for my $key (sort keys %$deps) {
                    my $callback = $deps->{$key};
                    $observed_deps{$key} = sub {
                        my $record = {callback => $key, args => $json->decode($json->encode([@_]))};
                        push @$calls, $record;
                        my $result = $callback->(@_);
                        $record->{result} = $json->decode($json->encode($result));
                        return $result;
                    };
                }
                return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
                    {id => $contract}, $case->{action}, \%observed_deps) unless $private;
                my $recorder = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
                no warnings 'redefine';
                local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
                    my $event = $_[0];
                    push @constructed, [$event, $event->{args}];
                    my $returned = $recorder->(@_);
                    die 'recorder changed event identity' unless refaddr($returned) == refaddr($event);
                    return $returned;
                };
                return LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                    {id => $contract}, $case->{action}, \%observed_deps);
            };
            my $public = $scan->(0, \@public_calls);
            my $private = $scan->(1, \@private_calls);
            my @identity;
            for my $index (0 .. $#{$private->{source_origins}}) {
                my $event = $private->{source_origins}[$index]{event};
                push @identity, {
                    origin_event => refaddr($private->{source_origins}[$index]{event}) == refaddr($private->{events}[$index]) ? JSON::PP::true : JSON::PP::false,
                    constructed_event => refaddr($constructed[$index][0]) == refaddr($event) ? JSON::PP::true : JSON::PP::false,
                    constructed_args => refaddr($constructed[$index][1]) == refaddr($event->{args}) ? JSON::PP::true : JSON::PP::false,
                };
            }
            push @rows, {contract => $contract, public_events => $public, private_result => $private,
                         public_calls => \@public_calls, private_calls => \@private_calls, identity => \@identity};
        }
        if ($case->{toolbox}) {
        $substitution = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
        my $source = "Top::\n I { $case->{action} }\nDone: /x/ I.return(\"child\")\n";
        LinkedSpec::Get(\$source, dump_parser_source => 1, parser_source_ref => \$dump);
        my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
        $diagnostics = $descriptor->{spec}{Top}{meta}{action_rewriter};
        }
        1;
    };
    $failure = $@ unless $ok;
}
push @reports, {id => $id, action => $case->{action}, dependency_keys => [sort keys %$deps], rows => \@rows,
    statement_frames => $frames, substitution => $substitution, diagnostics => $diagnostics, dump => $dump,
    failure => $failure, internal_stdout => $stdout, internal_stderr => $stderr};
}
print $json->pretty->encode(\@reports);
