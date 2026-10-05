use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_PIPELINE_STATEMENT_BASELINE}) {
        my $file='./docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2-before-PrimitivePipelineRules.pm';
        require $file;
        $INC{'LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'}=$file;
    }
}
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();
my $json=JSON::PP->new->canonical->utf8;
my $path='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-cases.json';
open my $file,'<:raw',$path or die $!;
my $case=$json->decode(do {local $/;<$file>});close $file or die $!;
my @contracts=grep {$_->{family} eq 'statement'} @{$case->{contracts}};
my $deps=LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $split=$deps->{split_action_ir_statements};
sub private_scan {
    my ($id,$source,$callbacks)=@_;
    return LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id=>$id},$source,$callbacks // $deps);
}
sub public_scan {
    my ($id,$source,$callbacks)=@_;
    return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id=>$id},$source,$callbacks // $deps);
}
for my $contract (@contracts) {
    subtest $contract->{id} => sub {
        my $public=public_scan($contract->{id},$case->{action});
        my (@constructed,$private);
        {
            my $recorder=\&LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event=sub {
                push @constructed,[$_[0],$_[0]{args}];
                return $recorder->(@_);
            };
            $private=private_scan($contract->{id},$case->{action});
        }
        my @expected=map {{raw=>$_->{raw},args=>$_->{args}}} @{$contract->{events}};
        is_deeply($public,\@expected,'independent original arguments and occurrence order');
        is_deeply($private->{events},\@expected,'unchanged private event values');
        my $origins=$private->{source_origins};
        is(scalar(@$origins),scalar(@expected),'each original selected statement has an origin');
        is_deeply([map {$_->{source_span}} @$origins],
            [map {$_->{source_span}} @{$contract->{events}}],'literal scalar intervals retain ignored-statement alignment');
        is(scalar(@constructed),scalar(@expected),'every original constructor invokes the statement hook');
        for my $index (0 .. $#$origins) {
            my $origin=$origins->[$index];
            is($origin->{source},$case->{action},'complete original Unicode/CRLF source');
            is(refaddr($origin->{event}),refaddr($private->{events}[$index]),'origin references actual returned event');
            is(refaddr($constructed[$index][0]),refaddr($private->{events}[$index]),'returned constructor event remains original');
            is(refaddr($constructed[$index][1]),refaddr($private->{events}[$index]{args}),'returned argument object remains original');
            my $span=$origin->{source_span};
            is(substr($case->{action},$span->{start},$span->{end}-$span->{start}),$origin->{event}{raw},'original scalar source slice');
        }
        ok(!grep({join(',',sort keys %$_) ne 'args,raw'} @{$private->{events}}),'public event keys remain unchanged');
    };
}
subtest 'all five default callback signatures results and counts are unchanged' => sub {
    for my $contract (@contracts) {
        my @observations;
        for my $private (0,1) {
            my @calls;
            my %callbacks=map {
                my $name=$_;my $callback=$deps->{$name};
                $name=>sub {
                    my $row={name=>$name,args=>$json->decode($json->encode([@_]))};push @calls,$row;
                    my $result=$callback->(@_);$row->{result}=$json->decode($json->encode($result));return $result;
                }
            } keys %$deps;
            my $events=$private ? private_scan($contract->{id},$case->{action},\%callbacks)->{events}
                : public_scan($contract->{id},$case->{action},\%callbacks);
            push @observations,{events=>$events,calls=>\@calls};
        }
        is_deeply($observations[1],$observations[0],$contract->{id}.' complete callback effects');
        is(scalar(grep {$_->{name} eq 'split_action_ir_statements'} @{$observations[1]{calls}}),1,'split callback once');
    }
    is_deeply([sort keys %$deps],[sort qw(build_array_pipeline_plan_from_expr normalize_method_args_with_optional_scope
        parse_method_function_expr split_action_ir_statements trim_action_ir_value)],'original five interfaces');
};
subtest 'unknown copied and changed split arrays do not borrow origins' => sub {
    for my $callback (sub {return ['value = 7']},sub {return [@{$split->($_[0])}]},
                      sub {my $result=$split->($_[0]);$result->[0]='value = 8';return $result}) {
        my %callbacks=(%$deps,split_action_ir_statements=>$callback);
        my $result=private_scan('scalar_assignment_operator','value = 7;',\%callbacks);
        is_deeply($result->{events},public_scan('scalar_assignment_operator','value = 7;',\%callbacks),'original callback values retained');
        is_deeply($result->{source_origins},[],'no invented array authority');
    }
};
subtest 'later trim transformations retain events without invented origins' => sub {
    my %callbacks=(%$deps,trim_action_ir_value=>sub {
        my $value=$deps->{trim_action_ir_value}->(@_);$value =~ s/\b7\b/8/g;return $value;
    });
    my $result=private_scan('scalar_assignment_operator','value = 7;',\%callbacks);
    is_deeply($result->{events},[{raw=>'value = 8',args=>{target=>'value',source=>'8'}}],'actual transformed event');
    is_deeply($result->{events},public_scan('scalar_assignment_operator','value = 7;',\%callbacks),'same public transformation');
    is_deeply($result->{source_origins},[],'transformed raw declines origin');
};
subtest 'nested private collectors restore outer statement occurrence frames' => sub {
    my $inner;
    my %callbacks=(%$deps,split_action_ir_statements=>sub {
        $inner=private_scan('return_bare','return 7;');return $split->(@_);
    });
    my $outer=private_scan('scalar_assignment_operator','value = 7; value = 7;',\%callbacks);
    is_deeply([map {$_->{source_span}} @{$outer->{source_origins}}],[{start=>0,end=>9},{start=>11,end=>20}],'outer original occurrences');
    is_deeply([map {$_->{source_span}} @{$inner->{source_origins}}],[{start=>0,end=>8}],'independent inner source');
};
subtest 'throwing callbacks and caller error state preserve existing behavior' => sub {
    my @errors;
    for my $private (0,1) {
        my $calls=0;
        my %callbacks=(%$deps,split_action_ir_statements=>sub {++$calls;die "controlled pipeline split failure\n"});
        my $ok=eval {$private ? private_scan('scalar_assignment_operator','value = 7;',\%callbacks)
            : public_scan('scalar_assignment_operator','value = 7;',\%callbacks);1};
        ok(!$ok,'same exception propagates');push @errors,$@;is($calls,1,'throwing callback once');
    }
    is_deeply(\@errors,["controlled pipeline split failure\n","controlled pipeline split failure\n"],'exact existing exception');
    $@='pipeline caller sentinel';private_scan('scalar_assignment_operator','value = 7;');
    is($@,'pipeline caller sentinel','caller error preserved');
};
subtest 'empty and rejected statements retain empty original results' => sub {
    for my $contract (@contracts) {
        is_deeply(private_scan($contract->{id},'no_selected_pipeline_statement'),{events=>[],source_origins=>[]},$contract->{id});
    }
    is_deeply(private_scan('array_end_mutation_method',"items.pop_back('wrong');"),{events=>[],source_origins=>[]},'original invalid pop arguments');
};
subtest 'foreign callback source cannot authorize requested action coordinates' => sub {
    for my $pair (['value = 7;','value = 8;'],['prefix; value = 7;','value = 7;']) {
        my %callbacks=(%$deps,split_action_ir_statements=>sub {return $split->($pair->[1])});
        my $result=private_scan('scalar_assignment_operator',$pair->[0],\%callbacks);
        is_deeply($result->{events},public_scan('scalar_assignment_operator',$pair->[0],\%callbacks),'original foreign callback event');
        is_deeply($result->{source_origins},[],'no foreign source authority');
    }
};
subtest 'all four array end methods retain optional value arguments and source frames' => sub {
    my @forms=("items.push_front('雪')","items.push_back(7)",'items.pop_front()','items.pop_back()');
    my @args=({target=>'items',method=>'push_front',value=>"'雪'"},{target=>'items',method=>'push_back',value=>'7'},
              {target=>'items',method=>'pop_front'},{target=>'items',method=>'pop_back'});
    my $source=" \x{2003}\r\n";my @spans;
    for my $raw (@forms) {
        my $start=length($source);$source.=$raw;push @spans,{start=>$start,end=>length($source)};$source.=";\r\n ";
    }
    my $result=private_scan('array_end_mutation_method',$source);
    is_deeply($result->{events},[map {{raw=>$forms[$_],args=>$args[$_]}} 0..$#forms],'literal four-method event oracle');
    is_deeply([map {$_->{source_span}} @{$result->{source_origins}}],\@spans,'cumulative authored scalar intervals');
};
done_testing();
