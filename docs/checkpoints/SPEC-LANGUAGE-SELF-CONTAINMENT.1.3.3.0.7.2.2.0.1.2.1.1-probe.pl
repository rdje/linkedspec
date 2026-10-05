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
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases=$json->decode(do {local $/;<$file>});close $file or die $!;
my $defaults=LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @rows;
for my $case (@$cases) {
    my %base=%$defaults;
    $base{build_array_pipeline_plan_from_expr}=sub {return $case->{plan}} if $case->{custom_plan};
    my (@public_calls,@private_calls,@constructed);
    my $scan=sub {
        my ($private,$calls)=@_;
        my %deps;
        for my $key (sort keys %base) {
            my $callback=$base{$key};
            $deps{$key}=sub {
                my $record={callback=>$key,args=>$json->decode($json->encode([@_]))};
                push @$calls,$record;
                my $result=$callback->(@_);
                $record->{result}=$json->decode($json->encode($result));
                return $result;
            };
        }
        return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id=>'split_array'},$case->{action},\%deps) unless $private;
        my $recorder=\&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event=sub {
            push @constructed,[$_[0],$_[0]{args}];return $recorder->(@_);
        };
        return LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id=>'split_array'},$case->{action},\%deps);
    };
    my $public=$scan->(0,\@public_calls);my $private=$scan->(1,\@private_calls);
    my @identity;
    for my $i (0..$#{$private->{source_origins}}) {
        my $event=$private->{events}[$i];
        push @identity,{origin_event=>refaddr($private->{source_origins}[$i]{event})==refaddr($event)?JSON::PP::true:JSON::PP::false,
                        constructed_event=>refaddr($constructed[$i][0])==refaddr($event)?JSON::PP::true:JSON::PP::false,
                        constructed_args=>refaddr($constructed[$i][1])==refaddr($event->{args})?JSON::PP::true:JSON::PP::false};
    }
    my $toolbox;
    unless ($case->{custom_plan}) {
        my ($stdout,$stderr)=('','');my ($substitution,$diagnostics,$dump,$failure);
        {
            open my $out,'>',\$stdout or die $!;open my $err,'>',\$stderr or die $!;
            local *STDOUT=$out;local *STDERR=$err;
            eval {
                $substitution=LinkedSpec::call_spec_handler_subst('Top',$case->{expr});
                my $source="Top::\n I { $case->{expr} }\n";
                $diagnostics=LinkedSpec::Get(\$source,return_descriptor=>1)->{spec}{Top}{meta}{action_rewriter};
                LinkedSpec::Get(\$source,dump_parser_source=>1,parser_source_ref=>\$dump);1;
            } or $failure=$@;
        }
        $toolbox={substitution=>$substitution,diagnostics=>$diagnostics,dump=>$dump,failure=>$failure,internal_stdout=>$stdout,internal_stderr=>$stderr};
    }
    push @rows,{id=>$case->{id},public_events=>$public,private_result=>$private,public_calls=>\@public_calls,private_calls=>\@private_calls,identity=>\@identity,toolbox=>$toolbox};
}
print $json->pretty->encode({rows=>\@rows,dependency_keys=>[sort keys %$defaults]});
