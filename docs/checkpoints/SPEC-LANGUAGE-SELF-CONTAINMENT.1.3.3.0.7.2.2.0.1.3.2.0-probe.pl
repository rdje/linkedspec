use strict;
use warnings;
use utf8;
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();
use Scalar::Util qw(refaddr);
use JSON::PP ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
sub clone { $json->decode($json->encode($_[0])) }
sub bool { $_[0] ? JSON::PP::true : JSON::PP::false }
my $parse = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
my $split = \&LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv;
my (@rows, @controls, $dump, $descriptor, $substitution, $failure);
my ($stdout, $stderr) = ('', '');
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        for my $case (@$cases) {
            my (@calls, $returned, $observed);
            my $ordinary = $parse->($case->{source}, $case->{receiver});
            {
                no warnings 'redefine';
                local *LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv = sub {
                    my $row = {args => clone([@_])};
                    push @calls, $row;
                    $returned = $split->(@_);
                    $row->{result} = clone($returned);
                    return $returned;
                };
                $observed = $parse->($case->{source}, $case->{receiver});
            }
            push @rows, {id => $case->{id}, source => $case->{source}, ordinary => $ordinary,
                         observed => $observed, calls => \@calls,
                         args_same => bool(refaddr($observed->{args}) == refaddr($returned))};
        }
        for my $kind (qw(copy changed foreign opaque nested exception)) {
            my (@calls, $returned, $inner, $result, $error);
            {
                no warnings 'redefine';
                local *LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv = sub {
                    push @calls, clone([@_]);
                    die "controlled CSV failure\n" if $kind eq 'exception';
                    $inner = $parse->('inner( "β" )') if $kind eq 'nested' && @calls == 1;
                    my $actual = $split->($kind eq 'foreign' ? 'foreign,foreign' : $_[0], $_[1]);
                    $returned = $kind eq 'copy' ? [@$actual]
                              : $kind eq 'opaque' ? {opaque => 'exact'} : $actual;
                    $returned->[0] = 'changed' if $kind eq 'changed';
                    return $returned;
                };
                my $ok = eval { $result = $parse->(' call( same, same ) '); 1 };
                $error = $@ unless $ok;
            }
            push @controls, {kind => $kind, calls => \@calls, result => $result, error => $error,
                             inner => $inner, args_same => defined($result)
                                 ? bool(refaddr($result->{args}) == refaddr($returned)) : undef};
        }
        my @invalid = map { {source => $_, result => $parse->($_)} }
                      (undef, '', '  ', 'call', 'call(a', 'call(a))');
        push @controls, {kind => 'invalid', cases => \@invalid};
        my $saved;
        { local $@ = 'caller sentinel'; $parse->('call(x)'); $saved = $@ }
        push @controls, {kind => 'caller-error', after => $saved};
        my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
        my $action = 'switch(kind, case("x", case("nested")), default(default())); case("tail")';
        for my $kind (qw(default copy changed foreign nested exception)) {
            my (@calls, $last, $events, $error);
            my %observed = %$deps;
            $observed{parse_method_function_expr} = sub {
                push @calls, clone([@_]);
                die "controlled parser failure\n" if $kind eq 'exception';
                my $actual = $kind eq 'foreign'
                    ? $deps->{parse_method_function_expr}->('case("foreign")')
                    : $deps->{parse_method_function_expr}->(@_);
                $last = $kind eq 'copy' ? {%$actual, args => [@{$actual->{args}}]} : $actual;
                $last->{args}[0] = 'changed' if $kind eq 'changed';
                LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
                    {id => 'case_flow'}, 'case("inner")', $deps) if $kind eq 'nested';
                return $last;
            };
            my $ok = eval {
                $events = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
                    {id => 'case_flow'}, $action, \%observed); 1;
            };
            $error = $@ unless $ok;
            push @controls, {kind => 'flow-'.$kind, calls => \@calls, events => $events, error => $error};
        }
        $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
        my $source = "Top::\n I { $action }\nDone: /x/ I.return(1)\n";
        LinkedSpec::Get(\$source, dump_parser_source => 1, parser_source_ref => \$dump);
        $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1)->{spec}{Top}{meta}{action_rewriter};
        1;
    };
    $failure = $@ unless $ok;
}
print $json->pretty->encode({rows => \@rows, controls => \@controls,
    substitution => $substitution, descriptor => $descriptor, dump => $dump,
    failure => $failure, internal_stdout => $stdout, internal_stderr => $stderr});
