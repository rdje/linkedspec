use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::RewritePipeline ();
use LinkedSpec::ActionIR::SourceOrigins ();

my $owner='LinkedSpec::ActionIR::RewritePipeline';
sub source_map {
    return LinkedSpec::ActionIR::RewritePipeline::_new_source_edit_map($_[0])
        if $owner->can('_new_source_edit_map');
    return {source=>$_[0],length=>length($_[0]),edits=>[]};
}
sub edit {
    return LinkedSpec::ActionIR::RewritePipeline::_record_source_edit(@_)
        if $owner->can('_record_source_edit');
    return undef;
}
sub mapped {
    return LinkedSpec::ActionIR::RewritePipeline::_mapped_event_span(@_)
        if $owner->can('_mapped_event_span');
    return undef;
}
sub event {
    my ($source,$raw,$start,$id,$unmatched)=@_;
    my $event={kind=>'ASSIGN',contract_id=>$id,raw=>$raw,args=>{},
        source=>$unmatched ? 'unmatched_helper_scan_event' : 'helper_contract'};
    LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
        {event=>$event,source=>$source,source_span=>{start=>$start,end=>$start+length($raw)}});
    return $event;
}
sub lower_authored {
    my ($segments,$outputs,$order,$unmatched,$separator)=@_;
    $separator='; ' unless defined $separator;
    my $source=join($separator,@$segments);
    my (@events,@calls,@contexts);my $result;
    LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
        my $offset=0;
        for my $i (0..$#$segments) {
            push @events,event($source,$segments->[$i],$offset,'authored_'.$i,$unmatched && $unmatched->{$i});
            $offset+=length($segments->[$i])+length($separator);
        }
        my @rules=map {
            my $i=$_;
            +{id=>'authored_'.$i,apply=>sub {
                my ($raw,$ctx)=@_;
                push @calls,[$i,$raw];push @contexts,$ctx;
                is(refaddr($ctx->{event}),refaddr($events[$i]),'actual canonical event reference reaches unchanged callback');
                return $outputs->[$i];
            }}
        } 0..$#$segments;
        my $ordered=$order ? [map {$events[$_]} @$order] : \@events;
        $result=LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir('Top',$source,\@rules,
            {canonical_action_ir_events=>$ordered});
    });
    is_deeply([map {$_->[0]} @calls],$order || [0..$#$segments],'actual callback family order is unchanged');
    ok(!grep({refaddr($_)!=refaddr($contexts[0])} @contexts),'callbacks retain one actual context object');
    is_deeply([sort keys %{$contexts[0]}],[sort qw(if_stack switch_stack switch_counter while_counter rewrite_rules trace_label)],
        'no mapping state or event field escapes through callback context');
    return $result;
}

subtest 'quoted twin after earlier expansion' => sub {
    my $actual=lower_authored([q{quoted='A'},'A','B'],[q{$quoted = 'A'},'ACTUAL_A','ACTUAL_B']);
    is($actual,q{$quoted = 'A'; ACTUAL_A; ACTUAL_B},'only the original real A is replaced');
};
subtest 'generated literal cannot capture a later event' => sub {
    my $actual=lower_authored(['A','B'],[q{'B'},'ACTUAL_B']);
    is($actual,q{'B'; ACTUAL_B},'new generated data is not original occurrence authority');
};
subtest 'equal real occurrences stay distinct in authored order' => sub {
    my $actual=lower_authored(['A','B','A'],['A_ONE',q{'A'},'A_TWO']);
    is($actual,q{A_ONE; 'A'; A_TWO},'the final real occurrence cannot borrow generated equal text');
};
subtest 'implicit LF CRLF and Unicode source offsets' => sub {
    for my $separator ("\n","\r\n") {
        my $actual=lower_authored([q{quoted='雪 A'},'A','B'],[q{$quoted = '雪 A'},'A_LONG','B_LONG'],undef,undef,$separator);
        is($actual,q{$quoted = '雪 A'}.';'.$separator.'A_LONG;'.$separator.'B_LONG',
            'original scalar spans track both prior expansions and inserted terminators');
    }
};
subtest 'nonmonotone family order rebases the pending terminator' => sub {
    my $actual=lower_authored(['A','B','C'],['AGEN_LONG','BGEN','CGEN'],[1,0,2],{0=>1},"\n");
    is($actual,"AGEN_LONG\nBGEN;\nCGEN",'earlier residual edits do not leave a stale cached insertion point');
};
subtest 'already consumed original intervals cannot replace generated data twice' => sub {
    my $source='A';my (@calls,$result);
    LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
        my $first=event($source,'A',0,'first',0);my $duplicate=event($source,'A',0,'second',1);
        $result=LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir('Top',$source,
            [{id=>'first',apply=>sub {push @calls,'first';return q{'A'}}},
             {id=>'second',apply=>sub {push @calls,'second';return 'WRONG'}}],
            {canonical_action_ir_events=>[$first,$duplicate]});
    });
    is($result,q{'A'},'replaced original source is consumed even if its raw spelling survives as data');
    is_deeply(\@calls,['first'],'consumed occurrence does not invoke its lowerer again');
};
subtest 'implicit closure insertion uses the actual source occurrence' => sub {
    my $source=q{quoted='A'; A};my $rewritten=$source;
    LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
        my $e=event($source,'A',length(q{quoted='A'; }),'authored',0);
        my $map=source_map($source);
        my $ctx={if_stack=>[{implicit_close=>1}],trace_label=>'Top'};
        LinkedSpec::ActionIR::RewritePipeline::_insert_pending_implicit_if_closures_before_stmt(\$rewritten,$ctx,'A',$e,$map);
        is($rewritten,q{quoted='A'; }.'} A','closure is inserted before the real event, preserving the literal');
        is_deeply($ctx->{if_stack},[],'original closure-stack effect remains');
    });
};
subtest 'actual edit translation validates original raw and decline paths' => sub {
    my $source='A; B';
    LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
        my $a=event($source,'A',0,'a',0);my $b=event($source,'B',3,'b',0);
        my $map=source_map($source);my $rewritten=$source;
        substr($rewritten,0,1,q{'B'});edit($map,0,1,length(q{'B'}));
        is_deeply(mapped($map,$rewritten,$b),{position=>5,length=>1},'real B moves through actual preceding replacement');
        is_deeply(mapped($map,$rewritten,$a),{position=>-1,length=>1},'original A is consumed');
        substr($rewritten,5,0,'} ');edit($map,5,0,2);
        is_deeply(mapped($map,$rewritten,$b),{position=>7,length=>1},'same-boundary insertion precedes the original event');
        my $tampered=$rewritten;substr($tampered,7,1,'X');
        is_deeply(mapped($map,$tampered,$b),{position=>-1,length=>1},'current-frame raw mismatch cannot authorize a replacement');
        ok(!mapped($map,$rewritten,{%$b}),'equal copied reference has no original authority');
        ok(!mapped(source_map('foreign'),$rewritten,$b),'another source map cannot borrow the event origin');
    });
};
subtest 'edits after an interval and at its end leave it unchanged' => sub {
    my $source='A; B';
    LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source,sub {
        my $a=event($source,'A',0,'a',0);my $map=source_map($source);my $rewritten=$source;
        substr($rewritten,1,0,';');edit($map,1,0,1);
        is_deeply(mapped($map,$rewritten,$a),{position=>0,length=>1},'end-boundary insertion belongs after A');
        substr($rewritten,4,1,'B_LONG');edit($map,4,1,6);
        is_deeply(mapped($map,$rewritten,$a),{position=>0,length=>1},'later original replacement leaves A coordinates intact');
    });
};
subtest 'opaque direct callers retain the original fallback and exact error' => sub {
    my $e={kind=>'ASSIGN',contract_id=>'authored',raw=>'A',args=>{},source=>'helper_contract'};
    my $actual=LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir('Top','A',
        [{id=>'authored',apply=>sub {is_deeply([$_[0]],['A'],'original raw callback argument');return 'LEGACY'}}],
        {canonical_action_ir_events=>[$e]});
    is($actual,'LEGACY','origin-free direct dependency still delegates through existing fallback');
    my $ran=eval {
        LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir('Top','A',
            [{id=>'authored',apply=>sub {die "authored lowering failure\n"}}],
            {canonical_action_ir_events=>[$e]});1;
    };
    ok(!$ran,'opaque callback exception still propagates');is($@,"authored lowering failure\n",'exact original callback exception');
};

done_testing();
