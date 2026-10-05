use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_FLOW_DIRECT_BASELINE}) {
        my $path='./docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1-before-FlowRules.pm';
        require $path;
        $INC{'LinkedSpec/ActionIR/Scanner/FlowRules.pm'}=$path;
    }
}
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();

my $json=JSON::PP->new->canonical->utf8;
my $fixture='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-review-cases.json';
open my $file,'<:raw',$fixture or die $!;
my $cases=$json->decode(do {local $/;<$file>});close $file or die $!;
my @cases=grep {$_->{id} ne 'recursive' && $_->{id} ne 'arguments'} @$cases;
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
for my $case (@cases) {
    subtest $case->{id} => sub {
        my @expected=map {{raw=>$_->{raw},args=>$_->{args}}} @{$case->{expected}{$case->{id}}};
        is_deeply(public_scan($case->{id},$case->{action}),\@expected,'literal original public events and arguments');
        my (@constructed,$result);
        {
            my $record=\&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event=sub {
                push @constructed,[$_[0],$_[0]{args}];
                return $record->(@_);
            };
            $result=private_scan($case->{id},$case->{action});
        }
        is_deeply($result->{events},\@expected,'private values retain original contract');
        my $origins=$result->{source_origins};
        is(scalar(@$origins),scalar(@expected),'each original direct occurrence has an origin');
        is_deeply([map {$_->{source_span}} @$origins],
            [map {{start=>$_->{start},end=>$_->{end}}} @{$case->{expected}{$case->{id}}}],
            'literal Unicode scalar intervals preserve CRLF and repeated twins');
        is(scalar(@constructed),scalar(@expected),'all original constructors reach the source hook');
        for my $index (0 .. $#$origins) {
            my $origin=$origins->[$index];
            is($origin->{source},$case->{action},'full original action');
            is(refaddr($origin->{event}),refaddr($result->{events}[$index]),'origin references actual returned event');
            is(refaddr($constructed[$index][0]),refaddr($result->{events}[$index]),'original constructor event retained');
            is(refaddr($constructed[$index][1]),refaddr($result->{events}[$index]{args}),'original argument object retained');
            my $span=$origin->{source_span};
            is(substr($case->{action},$span->{start},$span->{end}-$span->{start}),$origin->{event}{raw},'exact authored source slice');
        }
        ok(!grep({join(',',sort keys %$_) ne 'args,raw'} @{$result->{events}}),'public schema unchanged');
    };
}
subtest 'default callback signatures counts and results remain identical' => sub {
    for my $case (@cases) {
        my @observations;
        for my $private (0,1) {
            my @calls;
            my %callbacks=map {
                my $name=$_;my $callback=$deps->{$name};
                $name=>sub {
                    my $row={callback=>$name,args=>$json->decode($json->encode([@_]))};push @calls,$row;
                    my $result=$callback->(@_);$row->{result}=$json->decode($json->encode($result));return $result;
                }
            } keys %$deps;
            my $events=$private ? private_scan($case->{id},$case->{action},\%callbacks)->{events}
                : public_scan($case->{id},$case->{action},\%callbacks);
            push @observations,{events=>$events,calls=>\@calls};
        }
        is_deeply($observations[1],$observations[0],$case->{id}.' exact default effects');
        if ($case->{id} eq 'next_stmt') {
            is(scalar(grep {$_->{callback} eq 'split_action_ir_statements'} @{$observations[1]{calls}}),1,'next splits once');
        }
    }
    is_deeply([sort keys %$deps],[sort qw(build_array_pipeline_plan_from_expr normalize_method_args_with_optional_scope
        parse_method_function_expr split_action_ir_statements trim_action_ir_value)],'five original interfaces');
};
subtest 'unknown copied changed and foreign split results decline authority' => sub {
    for my $callback (sub {return ['next']},sub {return [@{$split->($_[0])}]},
                      sub {my $result=$split->($_[0]);$result->[0]='next';return $result},
                      sub {return $split->('next;')}) {
        my %callbacks=(%$deps,split_action_ir_statements=>$callback);
        my $result=private_scan('next_stmt','note(); next;',\%callbacks);
        is_deeply($result->{events},public_scan('next_stmt','note(); next;',\%callbacks),'ordinary callback results retained');
        is_deeply($result->{source_origins},[],'no invented occurrence authority');
    }
};
subtest 'transformed trim returns an event without a source origin' => sub {
    my %callbacks=(%$deps,trim_action_ir_value=>sub {
        my $value=$deps->{trim_action_ir_value}->(@_);return $value eq 'note()' ? 'next' : $value;
    });
    my $result=private_scan('next_stmt','note();',\%callbacks);
    is_deeply($result->{events},[{raw=>'next',args=>{}}],'original transformed callback event');
    is_deeply($result->{source_origins},[],'transformed text cannot borrow coordinates');
};
subtest 'nested private scan restores outer statement source frames' => sub {
    my $inner;
    my %callbacks=(%$deps,split_action_ir_statements=>sub {
        $inner=private_scan('if_flow','if(true)');return $split->(@_);
    });
    my $outer=private_scan('next_stmt','next; next;',\%callbacks);
    is_deeply([map {$_->{source_span}} @{$outer->{source_origins}}],[{start=>0,end=>4},{start=>6,end=>10}],'outer occurrence frames restored');
    is_deeply([map {$_->{source_span}} @{$inner->{source_origins}}],[{start=>0,end=>8}],'inner original frame remains independent');
};
subtest 'exceptions and caller error state retain original behavior' => sub {
    for my $pair (['next_stmt','next;','split_action_ir_statements'],['elseif_flow','elseif(true)','parse_method_function_expr']) {
        my @errors;
        for my $private (0,1) {
            my $calls=0;
            my %callbacks=(%$deps,$pair->[2]=>sub {++$calls;die "controlled Flow callback failure\n"});
            my $ok=eval {$private ? private_scan($pair->[0],$pair->[1],\%callbacks) : public_scan($pair->[0],$pair->[1],\%callbacks);1};
            ok(!$ok,'original exception propagates');push @errors,$@;is($calls,1,'throwing callback once');
        }
        is_deeply(\@errors,["controlled Flow callback failure\n","controlled Flow callback failure\n"],'exact public and private errors');
    }
    $@='Flow caller sentinel';private_scan('next_stmt','next;');is($@,'Flow caller sentinel','caller error state preserved');
};
subtest 'empty rejected and recursive results remain original' => sub {
    for my $case (@cases) {
        is_deeply(private_scan($case->{id},'not_a_flow_statement'),{events=>[],source_origins=>[]},$case->{id}.' empty');
    }
    is_deeply(private_scan('while_flow','while(true)'),{events=>[],source_origins=>[]},'while still requires its block');
    is_deeply(private_scan('endif_flow','endif(7)'),{events=>[],source_origins=>[]},'invalid marker arity unchanged');
    for my $id ('case_flow','default_flow') {
        my $case=next_recursive_case();
        my $result=private_scan($id,$case->{action});
        is_deeply($result->{events},public_scan($id,$case->{action}),$id.' recursive values unchanged');
        is_deeply($result->{source_origins},[],$id.' recursive implementation stays separately owned');
    }
};
sub next_recursive_case {return (grep {$_->{id} eq 'recursive'} @$cases)[0]}
subtest 'authored aliases and bare markers retain exact original spelling' => sub {
    for my $pair (['if_flow','i(true)',{condition=>'true'}],['if_flow','when(false)',{condition=>'false'}],
                  ['elseif_flow','elif(true)',{condition=>'true'}],['else_flow','else',{}],
                  ['else_flow','otherwise',{}],['endif_flow','endif()',{}],['endcase_flow','endcase()',{}],
                  ['endswitch_flow','endswitch()',{}],['next_stmt','next()',{}]) {
        my $result=private_scan($pair->[0],$pair->[1]);
        is_deeply($result->{events},[{raw=>$pair->[1],args=>$pair->[2]}],'original spelling and arguments');
        is_deeply([map {$_->{source_span}} @{$result->{source_origins}}],[{start=>0,end=>length($pair->[1])}],'authored alias span');
    }
};
done_testing();
