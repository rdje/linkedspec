use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $sequence = 0;

sub read_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
    local $/;
    my $text = <$fh>;
    close $fh or die $!;
    return $text;
}

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    if ((reftype($error) // '') eq 'HASH') {
        my %result = map { $_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_} }
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name name phase rule_label source_id invocation_id accessor);
        $result{class} = ref($error) if ref($error) ne 'HASH';
        return \%result;
    }
    return "$error";
}

sub observe_source {
    my ($source, $input, $rule) = @_;
    my (%context, @warnings, %result);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $native = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    if ($result{native_callable}) {
        my $text = $input;
        $result{native} = eval { $native->(\$text) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($text);
    }
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'gap-slot-record-selection.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::GapSlotRecordSelection'.++$sequence;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $result{loaded} = $loaded ? 1 : 0;
    $result{load_error} = error_value($@);
    if ($loaded) {
        my $text = $input;
        $result{fresh} = eval { $package->can('Execute')->(\$text) };
        $result{fresh_error} = error_value($@);
        $result{fresh_cursor} = pos($text);
    }
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $result{descriptor_error} = error_value($@);
    my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
    $result{metadata} = {map { $_ => $meta->{$_} } qw(canonical_action_ir_fallback_count raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)};
    $result{warnings} = \@warnings;
    return \%result;
}

sub check_source {
    my ($name, $source, $input, $expected, $cursor, $rule, $unsupported) = @_;
    return if @ARGV && !grep { $_ eq $name } @ARGV;
    $unsupported //= [];
    subtest $name => sub {
        my $actual = observe_source($source, $input, $rule);
        diag('GAP_SLOT_RECORD_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error} && !$actual->{native_error}, 'native executes without handler error');
        is($json->encode($actual->{native}), $json->encode($expected), 'native exact values and kinds');
        is($actual->{native_cursor}, $cursor, 'native cursor preserved');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh source loads');
        ok($actual->{loaded} && !$actual->{fresh_error}, 'fresh execution succeeds');
        is($json->encode($actual->{fresh}), $json->encode($expected), 'fresh exact values and kinds');
        is($actual->{fresh_cursor}, $cursor, 'fresh cursor preserved');
        ok(!$actual->{descriptor_error}, 'descriptor resolves');
        is_deeply($actual->{warnings}, [], 'build/load/run stay warning-free');
        my $meta = $actual->{metadata};
        is($meta->{raw_perl_dependency_count}, 0, 'no raw dependency');
        is($meta->{canonical_action_ir_fallback_count}, 0, 'no fallback executor');
        if (@$unsupported) {
            ok(!$meta->{language_agnostic_action_ir_ready}, 'pure-function state access remains unready');
            my %found = map { $_ => 1 } @{$meta->{unresolved_helpers} // []};
            ok($found{$_}, "specific forbidden helper $_ retained") for @$unsupported;
        } else {
            is($meta->{unresolved_helper_count}, 0, 'ordinary sources resolve');
            ok($meta->{language_agnostic_action_ir_ready}, 'readiness accompanies actual execution');
        }
    };
}

# TYPE-REFERENCE-BOOK.1.2.23.3.55.1 — existing context records as computed sources.
sub carrier {
    my ($action,$item)=@_;
    return "List::\n \@capture_gaps\n I {rows=[];order=\"\"}\n -> Item[word] {$action}\n LX {return([rows,order])}\nItem:\n word=/[^,;]+/\n I {$item}\n";
}
check_source('frozen gap and slot record selection target',
    read_file('tests/fixtures/gap_slot_record_selection_values.spec'),'a,b',
    $json->decode(read_file('tests/fixtures/gap_slot_record_selection_values.json')),3,'List');

my $slot={target_rule=>'Item',regex_index=>0,slot_id=>'word',selector_kind=>'named',authored_selector=>'word'};
my $span0={source_id=>'input',start=>0,end=>0,provenance=>'gap'};
my $span1={source_id=>'input',start=>1,end=>2,provenance=>'gap'};
check_source('primitive records preserve source fields and named provenance',
    carrier('push(rows,[gap_span(),call(Item)])','return(entry_slot())'),
    'a,b',[[[$span0,$slot],[$span1,$slot]],''],3,'List');

check_source('direct entry slot stays null and selected field can default',
    q{List:: I {return(entry_slot()["slot_id"].coalesce("M"))}},'x','M',0,'List');

check_source('named first consumer retains legacy empty Array and skips operands',
    carrier(q{part=gap_span();value=part["source_id"].take({order=cat(order,"BAD");1});push(rows,[value,call(Item)])},
        q{part=entry_slot();entry_order="";value=part["target_rule"].take({entry_order=cat(entry_order,"BAD");1});return([value,entry_order])}),
    'a,b',[[[[],[[],'']],[[],[[],'']]],''],3,'List');

for my $helper ('entry_slot','gap_span') {
    my $field=$helper eq 'entry_slot' ? 'slot_id' : 'start';
    check_source("pure function retains $helper state restriction",
        'fn forbidden(){return('.$helper.'()["'.$field.'"].coalesce("M"))} List:: I {return(forbidden())}',
        'x','M',0,'List',[$helper]);
    check_source("primitive pure function default policy $helper",
        'fn forbidden(){return('.$helper.'().coalesce("M"))} List:: I {return(forbidden())}',
        'x','M',0,'List',[$helper]);
}

sub find_gap_error {
    my ($value)=@_;
    return undef unless (reftype($value) // '') eq 'HASH';
    return $value if ($value->{code} // '') eq 'gap_capture_context_unavailable';
    return find_gap_error($value->{detail});
}
subtest 'unavailable gap remains a typed source error before field defaults' => sub {
    for my $expression ('gap_span()','gap_span()["start"].coalesce(99)') {
        my $actual=observe_source('List:: /x/ I {return('.$expression.')}','x','List');
        diag('GAP_SLOT_CONTEXT '.$json->encode($actual));
        ok($actual->{native_callable} && $actual->{loaded},'both execution routes compile');
        for my $route ('native_error','fresh_error') {
            my $error=find_gap_error($actual->{$route});
            ok($error,"$route keeps the gap context error");
            is($error && $error->{class},'LinkedSpec::InterMatchGapRuntime::Error',"$route keeps typed class");
            is($error && $error->{accessor},'gap_span',"$route keeps accessor");
            is($error && $error->{rule_label},'List',"$route keeps rule owner");
        }
        ok(!defined($actual->{native}) && !defined($actual->{fresh}),'no fallback value masks the source failure');
    }
};

subtest 'record source roles do not expand deferred grammar or arity' => sub {
    require LinkedSpec::ActionIR::AST::Parser;
    for my $helper ('entry_slot','gap_span') {
        my $literal='{|| return('.$helper.'()["missing"]) }';
        my $node=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($literal);
        my $read=$node->{body_ast}{statements}[0]{expr}{args}[0];
        is($read->{kind},'raw_perl','explicit deferred literal retains old grammar');
        is($read->{source},$helper.'()["missing"]','deferred source remains exact');
        my $invalid=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($helper.'(1)["missing"]');
        is($invalid->{kind},'raw_perl','extra helper argument gains no computed source role');
    }
};
done_testing() unless caller;
1;
