use strict;
use warnings;
use utf8;
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::ActionIR::StagedParseJob ();
use LinkedSpec::ActionIR::ProgressiveSpanDispatch ();
use LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $literal = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

sub observe_dispatch {
    my ($body, $selected) = @_;
    my $runner = $body;
    for my $package (reverse qw(
        LinkedSpec::ActionIR::StagedParseJob
        LinkedSpec::ActionIR::ProgressiveSpanDispatch
        LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules
    )) {
        no strict 'refs';
        my $original = \&{$package.'::try_scan_contract_ir_events'};
        my $next = $runner;
        $runner = sub {
            no warnings 'redefine';
            local *{$package.'::try_scan_contract_ir_events'} = sub {
                my $result = $original->(@_);
                if (ref($result) eq 'ARRAY') {
                    $selected->{array} = $result;
                    $selected->{objects} = [map { [$_, $_->{args}] } @$result];
                }
                return $result;
            };
            return $next->();
        };
    }
    return $runner->();
}

my @reports;
for my $case (@{$literal->{cases}}) {
    my $framed = LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(
        $deps->{split_action_ir_statements}, $case->{action});
    my @rows;
    for my $expected (@{$case->{rows}}) {
        my $contract = $expected->{contract};
        my $scan = sub {
            my ($private) = @_;
            my (@calls, %selected, %observed);
            for my $key (sort keys %$deps) {
                my $callback = $deps->{$key};
                $observed{$key} = sub {
                    my $row = {callback => $key, args => $json->decode($json->encode([@_]))};
                    push @calls, $row;
                    my $result = $callback->(@_);
                    $row->{result} = $json->decode($json->encode($result));
                    return $result;
                };
            }
            my $result = observe_dispatch(sub {
                return LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                    {id => $contract}, $case->{action}, \%observed) if $private;
                return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
                    {id => $contract}, $case->{action}, \%observed);
            }, \%selected);
            my $events = $private ? $result->{events} : $result;
            my @identity;
            for my $index (0 .. $#$events) {
                push @identity, {
                    event => refaddr($events->[$index]) == refaddr($selected{objects}[$index][0])
                        ? JSON::PP::true : JSON::PP::false,
                    args => refaddr($events->[$index]{args}) == refaddr($selected{objects}[$index][1])
                        ? JSON::PP::true : JSON::PP::false,
                };
            }
            return {
                result => $result, calls => \@calls, identity => \@identity,
                returned_array => refaddr($events) == refaddr($selected{array})
                    ? JSON::PP::true : JSON::PP::false,
            };
        };
        push @rows, {contract => $contract, public => $scan->(0), private => $scan->(1)};
    }
    push @reports, {
        id => $case->{id}, action => $case->{action},
        statement_frames => $framed->{source_frames}, rows => \@rows,
    };
}

my @compiler;
for my $case (@{$literal->{toolbox}}) {
    my ($stdout, $stderr, $dump, $descriptor, $substitution, $parser, $failure);
    $stdout = $stderr = '';
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        my $ok = eval {
            $substitution = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
            my $source = "Top::\n I { $case->{action} }\nDone: /x/ I.return(\"child\")\n";
            $parser = LinkedSpec::Get(\$source, dump_parser_source => 1, parser_source_ref => \$dump);
            my $full_descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
            $descriptor = ref($full_descriptor) eq 'HASH'
                ? $full_descriptor->{spec}{Top}{meta}{action_rewriter} : undef;
            1;
        };
        $failure = $@ unless $ok;
    }
    push @compiler, {
        id => $case->{id}, action => $case->{action}, substitution => $substitution,
        dump => $dump, descriptor => $descriptor, failure => $failure,
        parser_built => ref($parser) eq 'CODE' ? JSON::PP::true : JSON::PP::false,
        internal_stdout => $stdout, internal_stderr => $stderr,
    };
}
print $json->pretty->encode({cases => \@reports, toolbox => \@compiler});
