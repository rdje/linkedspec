use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::Diagnostics ();
use LinkedSpec::ActionIR::CanonicalEvents ();
use LinkedSpec::ActionIR::CanonicalEvents::Core ();
use LinkedSpec::ActionIR::RewritePipeline ();

# Authored before production: absence means no authority, never fabricated spans.
my $available = -f 'perl/LinkedSpec/ActionIR/SourceOrigins.pm';
require LinkedSpec::ActionIR::SourceOrigins if $available;
sub scope {
    my ($source, $callback) = @_;
    return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, $callback) if $available;
    return $callback->();
}
sub origin {
    return $available ? LinkedSpec::ActionIR::SourceOrigins::_origin_for($_[0]) : undef;
}
sub remember {
    return LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin(@_) if $available;
    return $_[0];
}
sub transfer {
    return LinkedSpec::ActionIR::SourceOrigins::_copy_source_origin(@_) if $available;
    return $_[1];
}
sub record {
    my ($event, $source, $start, $end) = @_;
    return {event => $event, source => $source, source_span => {start => $start, end => $end}};
}
my $json = JSON::PP->new->canonical;
my $scanner_deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $canonical_deps = LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

subtest 'selected original references survive both actual copies' => sub {
    # Cumulative authored segments give independent Unicode-scalar intervals.
    my @segments = ('quoted="set(counter,2)"', 'set(counter,2)', 'set(counter,2)');
    my $source = join('; ', @segments);
    my @starts = (0, length($segments[0])+2, length($segments[0])+length($segments[1])+4);
    my @scanned;
    my $events;
    scope($source, sub {
        my $rules = [{id => 'set_value', ir_node => 'SET'}];
        my $diag = LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes($source, $rules, {
            scan_contract_ir_events => sub {
                my $result = LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events(@_, $scanner_deps);
                @scanned = @$result;
                return $result;
            },
        });
        is(scalar(@scanned), 2, 'literal twin is excluded; two actual events remain');
        my $snapshot = $json->encode(\@scanned);
        my $canonical = LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(
            'Top', $source, $diag->{helper_action_ir_events}, $canonical_deps);
        $events = $canonical->{canonical_action_ir_events};
        is_deeply([map { $_->{raw} } @$events], \@segments, 'existing source/queue order is preserved');
        for my $i (0, 1) {
            my $helper = $diag->{helper_action_ir_events}[$i];
            my $copy = $events->[$i+1];
            isnt(refaddr($helper), refaddr($scanned[$i]), 'diagnostic event is an actual copy');
            is(refaddr($helper->{args}), refaddr($scanned[$i]{args}), 'diagnostic copy retains original argument object');
            isnt(refaddr($copy), refaddr($helper), 'canonical event is a distinct actual copy');
            isnt(refaddr($copy->{args}), refaddr($helper->{args}), 'canonical normalized arguments are a distinct object');
            for my $event ($scanned[$i], $helper, $copy) {
                my $o = origin($event);
                is_deeply($o && $o->{source_span}, {start => $starts[$i+1], end => $starts[$i+1]+length($segments[$i+1])},
                    'each real object carries its independently authored occurrence');
                is($o && $o->{source}, $source, 'authority keeps the original action');
                ok(!exists($event->{source_span}) && !exists($event->{source_origins}), 'private origin adds no public fields');
            }
        }
        is($json->encode(\@scanned), $snapshot, 'copies leave original event/arguments unchanged');
        is_deeply(origin($events->[0]) && origin($events->[0])->{source_span},
            {start => 0, end => length($segments[0])}, 'actual raw fallback gets its original splitter frame');
    });
    ok(!origin($events->[1]), 'all references lose private lookup authority outside the invocation');
};

subtest 'synthetic events use exact canonical splitter frames' => sub {
    my @cases = (
        ['host_call()', {}, 'RAW_PERL', 'fallback_non_helper_statement'],
        ['registered()', {user_function_registry => {by_name => {registered => {kind => 'user_function_definition'}}}},
            'VALUE_DROP', 'registered_user_function_value_drop'],
        ['bound()', {bare_symbol_kind => sub { 'scalar' }}, 'VALUE_DROP', 'bound_codeblock_value_drop'],
        ['tree.map_leaves!() { return(value) }', {}, 'VALUE_DROP', 'receiver_mutation_value_drop'],
    );
    for my $case (@cases) {
        my ($raw, $extra, $kind, $producer) = @$case;
        my $source = " \x{2003}".$raw."\r\n";
        scope($source, sub {
            my $d = LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(
                'Top', $source, [], {%$canonical_deps, %$extra});
            is(scalar(@{$d->{canonical_action_ir_events}}), 1, 'one actual synthetic event');
            my $event = $d->{canonical_action_ir_events}[0];
            is($event->{kind}, $kind, 'existing event kind');
            is($event->{source}, $producer, 'existing synthetic producer');
            is_deeply(origin($event) && origin($event)->{source_span}, {start => 2, end => 2+length($raw)},
                'frame retains authored whitespace/Unicode/CRLF coordinates');
        });
    }
};

subtest 'foreign copied changed and opaque splitter results cannot borrow frames' => sub {
    my $split = $canonical_deps->{split_action_ir_statements};
    my @cases = (
        ['unknown', sub { ['host_call()'] }, [0]],
        ['copied', sub { [@{$split->($_[0])}] }, [0,0]],
        ['foreign', sub { $split->('host_call()') }, [0]],
        ['changed', sub { my $a=$split->($_[0]); $a->[0]='changed()'; $a }, [0,1]],
    );
    for my $case (@cases) {
        my ($name, $callback, $expected) = @$case;
        my $source = ' host_call(); other_call()';
        my ($calls, $returned) = (0);
        scope($source, sub {
            my $d = LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top', $source, [], {
                %$canonical_deps, split_action_ir_statements => sub {
                    ++$calls; is_deeply([@_], [$source], 'original splitter arguments '.$name);
                    $returned = $callback->(@_); return $returned;
                },
            });
            is_deeply([map { origin($_) ? 1 : 0 } @{$d->{canonical_action_ir_events}}], $expected,
                'only unchanged reference-bound source entries authorize frames '.$name);
            is($calls, 1, 'splitter called exactly once '.$name);
        });
    }
    my $opaque = bless {}, 'OriginFixture::Opaque';
    scope('x', sub {
        my $ran=eval {
            LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top','x',[],
                {%$canonical_deps, split_action_ir_statements => sub { $opaque }}); 1;
        };
        ok(!$ran, 'opaque non-array still fails at existing dereference');
        like($@, qr/Not an ARRAY reference/, 'existing opaque return error');
    });
};

subtest 'helper queue matches do not invent missing scanner authority' => sub {
    my $source='return(x)';
    scope($source, sub {
        my $helper={raw=>$source,ir_node=>'RETURN',contract_id=>'return_general',args=>{value=>'x'}};
        my $d=LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top',$source,[$helper],$canonical_deps);
        ok(!origin($d->{canonical_action_ir_events}[0]), 'opaque helper cannot borrow the matching statement frame');
    });
};

subtest 'source validation identity detached copies and ambiguity' => sub {
    my $source='x;x'; my $event={raw=>'x'};
    scope($source, sub {
        is(refaddr(remember($event,record($event,$source,0,1))),refaddr($event),'remember retains caller reference');
        is_deeply(origin($event) && origin($event)->{source_span},{start=>0,end=>1},'valid exact interval');
        my $detached=origin($event);
        $detached->{source_span}{start}=99 if $detached;
        is_deeply(origin($event) && origin($event)->{source_span},{start=>0,end=>1},'query exposes no mutable stored coordinates');
        my $equal={%$event}; ok(!origin($equal),'equal-valued foreign reference has no authority');
        is(refaddr(transfer($event,$equal)),refaddr($equal),'explicit copy retains target object');
        is_deeply(origin($equal) && origin($equal)->{source_span},{start=>0,end=>1},'explicit copy transfers exact original authority');
        remember($event,record($event,$source,2,3));
        ok(!origin($event),'conflicting repeated occurrences decline ambiguous authority');
        remember($event,record($event,$source,0,1));
        ok(!origin($event),'ambiguity cannot silently revive');
    });
    for my $bad (
        sub { record($_[0],'foreign',0,1) }, sub { record({},$source,0,1) },
        sub { record($_[0],$source,-1,1) }, sub { record($_[0],$source,2,1) },
        sub { record($_[0],$source,0,8) }, sub { record($_[0],$source,0,'1x') },
        sub { record($_[0],$source,1,2) }, sub { {event=>$_[0],source=>$source,source_span=>[]} },
    ) {
        scope($source, sub { my $e={raw=>'x'}; remember($e,$bad->($e)); ok(!origin($e),'malformed or foreign authority is declined'); });
    }
};

subtest 'strong references prevent address reuse and scope releases them' => sub {
    my $event={raw=>'x'}; my $weak=$event; weaken($weak);
    scope('x',sub {
        remember($event,record($event,'x',0,1)); undef $event;
        ok(defined($weak),'actual event stays strongly retained until invocation ends');
    });
    ok(!defined($weak),'invocation does not leave a global cache');
};

subtest 'nested scopes and errors restore enclosing authority' => sub {
    my $outer={raw=>'x'}; my $inner={raw=>'y'};
    scope('x',sub {
        remember($outer,record($outer,'x',0,1));
        my $ran=eval {
            scope('y',sub {
                ok(!origin($outer),'inner invocation cannot see outer object authority');
                remember($inner,record($inner,'y',0,1));
                ok(origin($inner),'inner owns its actual reference');
                die "authored nested failure\n";
            }); 1;
        };
        ok(!$ran,'nested exception propagates');
        is($@,"authored nested failure\n",'exact authored failure survives');
        ok(origin($outer),'exception restores enclosing invocation');
        ok(!origin($inner),'inner reference cannot escape into outer authority');
    });
};

subtest 'private scope preserves scalar list void and successful error effects' => sub {
    my (@contexts,$calls);
    my $callback=sub { ++$calls; push @contexts, defined(wantarray) ? wantarray ? 'list' : 'scalar' : 'void'; $@='callback effect'; return ('a','b'); };
    $@='caller error'; my @list=scope('x',$callback); my $list_error=$@;
    $@='caller error'; my $scalar=scope('x',$callback); my $scalar_error=$@;
    $@='caller error'; scope('x',$callback); my $void_error=$@;
    is_deeply(\@contexts,['list','scalar','void'],'exact callback evaluation contexts');
    is_deeply(\@list,['a','b'],'list result'); is($scalar,'b','scalar result'); is($calls,3,'one callback per call');
    is_deeply([$list_error,$scalar_error,$void_error],[('callback effect') x 3],'successful callback error effects remain observable');
};

subtest 'actual canonical splitter callback context effects and failure' => sub {
    my $source='host_call()'; my (@calls,$seen_error);
    scope($source,sub {
        my $split=$canonical_deps->{split_action_ir_statements};
        my $d=LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top',$source,[],{
            %$canonical_deps,
            split_action_ir_statements=>sub {
                push @calls, [defined(wantarray) ? wantarray ? 'list':'scalar':'void', [@_]];
                my $result=$split->(@_); $@='actual splitter effect'; return $result;
            },
        });
        $seen_error=$@;
        is_deeply(\@calls,[['scalar',[$source]]],'actual splitter once in original scalar context');
        # RAW host parsing clears this effect in both original and corrected owners.
        is($seen_error,'','existing later AST evaluation error state');
        my $ran=eval {
            LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events('Top',$source,[],
                {%$canonical_deps,split_action_ir_statements=>sub { die "authored split failure\n" }});1;
        };
        ok(!$ran,'actual callback failure propagates'); is($@,"authored split failure\n",'exact callback failure');
    });
};

subtest 'actual rewrite invocation carries origins to unchanged lowering only' => sub {
    my $source='set(counter,2)'; my ($seen,$saved);
    my $lower=\&LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir;
    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir=sub {
            my ($label,$code,$rules,$diag)=@_;
            my ($event)=grep { ($_->{contract_id}//'') eq 'set_value' } @{$diag->{canonical_action_ir_events}};
            $saved=$event; $seen=origin($event); return $lower->(@_);
        };
        my $rewritten=LinkedSpec::call_spec_handler_subst('Top',$source);
        like($rewritten,qr/counter/,'existing lowering still runs');
    }
    is_deeply($seen && $seen->{source_span},{start=>0,end=>length($source)},'actual pipeline creates original invocation authority');
    ok(!origin($saved),'pipeline scope ends after unchanged lowering/diagnostics');
};

done_testing();
