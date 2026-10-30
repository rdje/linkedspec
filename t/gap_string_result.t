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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'gap-string-result.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::GapStringResult'.++$sequence;
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
        diag('GAP_STRING_RESULT_ACTUAL '.$name.' '.$json->encode($actual));
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


# TYPE-REFERENCE-BOOK.1.2.23.3.57.1 — existing gap Strings as guarded sources.
sub carrier {
    my ($action, $tail, $definitions, $pattern) = @_;
    $tail //= 'return([rows,gap_text(),gap_kind(),order,cursor_pos()])';
    $definitions //= '';
    $pattern //= '[^,;]+';
    return "$definitions\nList::\n \@capture_gaps\n I {rows=[];order=\"\"}\n -> Item[word] {$action}\n LX {$tail}\nItem:\n word=/$pattern/\n I {return(entry_text())}\n";
}
check_source('frozen guarded gap String target',
    read_file('tests/fixtures/gap_string_result_values.spec'), 'a,b;',
    $json->decode(read_file('tests/fixtures/gap_string_result_values.json')), 3, 'List');
check_source('primitive gap Strings retain empty prefix interstitial tail',
    carrier('push(rows,[gap_text(),gap_kind(),call(Item)])'), 'a,b;',
    [[["",'prefix','a'],[',','interstitial','b']],';','tail','',3], 3, 'List');
check_source('existing bound and direct compatible String methods remain healthy',
    carrier(q{text=gap_text();kind=gap_kind();push(rows,[text.coalesce("F").cat("!"),gap_text().coalesce("F").cat("!"),kind.uppercase(),gap_kind().uppercase(),call(Item)])}),
    'a,b;', [[['!','!','PREFIX','PREFIX','a'],[',!',',!','INTERSTITIAL','INTERSTITIAL','b']],';','tail','',3], 3, 'List');
check_source('direct incompatible consumers return null and skip operands',
    carrier(q{a=gap_text().take({order=cat(order,"A");1});b=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])}),
    'a,b;', [[[undef,undef,'a'],[undef,undef,'b']],';','tail','',3], 3, 'List');
check_source('both noncontainer reads recover Array Bool Number and String',
    carrier(q{push(rows,[gap_text()[0].coalesce(["a","tail"])[-1].uppercase(),gap_kind()["missing"].coalesce(false),gap_kind()[0].coalesce(0).add(1),gap_text()[0].coalesce("").cat("!"),call(Item)])}),
    'a,b;', [[['TAIL',JSON::PP::false,1,'!','a'],['TAIL',JSON::PP::false,1,'!','b']],';','tail','',3], 3, 'List');
check_source('with returns actual Array Hash Bool kinds and restores outer value',
    carrier(q{value="outer";a=gap_text().with(){return([value,"tail"])}[-1].uppercase();b=gap_kind().with(){return({"k":[false]})}["k"][-1];push(rows,[a,b,value,call(Item)])}),
    'a,b;', [[['TAIL',JSON::PP::false,'outer','a'],['TAIL',JSON::PP::false,'outer','b']],';','tail','',3], 3, 'List');
my $symbol=chr(0x1f642);
check_source('decoded Unicode text remains a String with character length',
    carrier(q{push(rows,[gap_text().length(),gap_text().cat("!"),call(Item)])},undef,undef,'[ab]'),
    'a'.$symbol.'b;', [[[0,'!','a'],[1,$symbol.'!','b']],';','tail','',3], 3, 'List');
check_source('raw named first consumers retain existing legacy policy',
    carrier(q{text=gap_text();kind=gap_kind();a=text.take({order=cat(order,"A");1});b=kind.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])}),
    'a,b;', [[[[],{k=>1},'a'],[[],{k=>1},'b']],';','tail','AKVAKV',3], 3, 'List');
for my $helper ('gap_text','gap_kind') {
    check_source("pure function $helper default remains unsupported and unready",
        'fn forbidden(){return('.$helper.'().coalesce("M"))} List:: I {return(forbidden())}',
        'x', 'M', 0, 'List', [$helper]);
}
# Additional preservation epoch: exercise the newly admitted computed-read path
# inside pure functions too. These two controls have no historical RED credit.
for my $helper ('gap_text','gap_kind') {
    check_source("pure function $helper computed read remains unsupported and unready",
        'fn forbidden(){return('.$helper.'()[0].coalesce("M"))} List:: I {return(forbidden())}',
        'x', 'M', 0, 'List', [$helper]);
}
check_source('ordinary explicit caller String arguments remain valid',
    carrier(q{push(rows,[selected(gap_text(),gap_kind()),call(Item)])},undef,
        q{fn selected(text,kind){return([text.cat("!"),kind.uppercase()])}}),
    'a,b;', [[[['!','PREFIX'],'a'],[[',!','INTERSTITIAL'],'b']],';','tail','',3], 3, 'List');
sub find_gap_error {
    my ($value)=@_;
    return undef unless (reftype($value) // '') eq 'HASH';
    return $value if ($value->{code} // '') eq 'gap_capture_context_unavailable';
    return find_gap_error($value->{detail});
}
subtest 'unavailable String context errors still precede defaults' => sub {
    for my $helper ('gap_text','gap_kind') {
        for my $suffix ('','.coalesce("M")') {
            my $actual=observe_source('List:: I {return('.$helper.'()'.$suffix.')}','x','List');
            diag('GAP_STRING_CONTEXT '.$helper.$suffix.' '.$json->encode($actual));
            ok($actual->{native_callable} && $actual->{loaded},'both routes compile');
            for my $route ('native_error','fresh_error') {
                my $error=find_gap_error($actual->{$route});
                ok($error,"$route retains context error");
                is($error && $error->{class},'LinkedSpec::InterMatchGapRuntime::Error','typed error class');
                is($error && $error->{accessor},$helper,'authored accessor retained');
            }
            ok(!defined($actual->{native}) && !defined($actual->{fresh}),'default does not mask error');
        }
    }
};
subtest 'source roles preserve deferred and invalid argument grammar' => sub {
    require LinkedSpec::ActionIR::AST::Parser;
    for my $helper ('gap_text','gap_kind') {
        my $literal='{|| return('.$helper.'()[0]) }';
        my $node=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($literal);
        my $read=$node->{body_ast}{statements}[0]{expr}{args}[0];
        is($read->{kind},'raw_perl','explicit deferred helper read keeps old grammar');
        is($read->{source},$helper.'()[0]','deferred authored source exact');
        my $invalid=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($helper.'(1)[0]');
        is($invalid->{kind},'raw_perl','surplus arguments gain no computed source role');
    }
};
done_testing() unless caller;
1;
