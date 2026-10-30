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
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name name);
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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'rule-call-selection.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::RuleCallSelection'.++$sequence;
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
        diag('RULE_CALL_SELECTION_ACTUAL '.$name.' '.$json->encode($actual));
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

# TYPE-REFERENCE-BOOK.1.2.23.3.54.1 — static child return selections.
check_source('frozen rule-call result selection target',
    read_file('tests/fixtures/rule_call_selection_values.spec'), "\x{03b1}\x{03b2}:ENDTAIL",
    $json->decode(read_file('tests/fixtures/rule_call_selection_values.json')), 3, 'Top');

check_source('selected child values retain every ordinary kind',q{
Top:: I {return([call(Child)[0],call(Child)[1],call(Child)[2],call(Child)[3],call(Child)[4],call(Child)[5]])}
Child: I {return([false,0,"0",undef,["a"],hash("name","b")])}
},'x',[JSON::PP::false,0,"0",undef,['a'],{name=>'b'}],0,'Top');

check_source('scalar null empty and missing child values retain typed null reads',q{
Top:: I {return([call(Text)[-1].coalesce("M"),call(Nothing)[0].coalesce("N"),call(Empty)[-1].coalesce("E"),call(Object)["missing"].coalesce("K")])}
Text: I {return("red:tail")}
Nothing: I {return(undef)}
Empty: I {return([])}
Object: I {return(hash())}
},'x',['M','N','E','K'],0,'Top');

check_source('existing bound and direct method rule-call controls remain healthy',q{
Top:: I {part=call(Child);return([part[-1].uppercase(),call(Child).last().uppercase()])}
Child: I {return(["red","tail"])}
},'x',['TAIL','TAIL'],0,'Top');

check_source('pure function still cannot invoke a child parser',q{
fn forbidden(){return(call(Child)[-1].uppercase())}
Top:: I {return(forbidden())}
Child: I {return(["tail"])}
},'x',undef,0,'Top',['call']);

subtest 'deferred literals and contextual callbacks keep raw rule-call selector grammar' => sub {
    require LinkedSpec::ActionIR::AST::Parser;
    my $literal=q{{|| return(call(Child)[-1]) }};
    my $node=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($literal,{base_start=>17});
    my $read=$node->{body_ast}{statements}[0]{expr}{args}[0];
    is($read->{kind},'raw_perl','explicit literal does not gain value_access');
    is($read->{source},'call(Child)[-1]','explicit literal preserves source');
    my $offset=index($literal,$read->{source});
    is_deeply($read->{source_span},{start=>17+$offset,end=>17+$offset+length($read->{source})},'explicit literal preserves authored span');
    my $registry={by_name=>{apply=>{kind=>'user_function_definition',name=>'apply',params=>['callback'],arity=>1,parameter_kinds=>{callback=>'codeblock'}}}};
    for my $source ('apply() {return(call(Child)[-1])}','apply({return(call(Child)[-1])})') {
        local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry=$registry;
        my $call=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source);
        my $deferred=$call->{args}[-1]{block}{statements}[0]{expr}{args}[0];
        is($deferred->{kind},'raw_perl','registered final callback keeps existing grammar');
        is($deferred->{source},'call(Child)[-1]','registered final callback source exact');
    }
    my $plain=LinkedSpec::ActionIR::AST::Parser::parse_action_expr('call(Child)');
    is($plain->{kind},'call','ordinary call remains typed');
    is($plain->{args}[0]{kind},'variable','existing bare word rule label is a variable-shaped argument');
    is($plain->{args}[0]{name},'Child','existing authored label is retained');
};

done_testing() unless caller;
1;
