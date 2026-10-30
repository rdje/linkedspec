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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'push-fluent-result.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::PushFluentResult'.++$sequence;
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
        diag('PUSH_FLUENT_RESULT_ACTUAL '.$name.' '.$json->encode($actual));
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





# TYPE-REFERENCE-BOOK.1.2.23.3.58.1.2 — full unchanged target plus fluent controls.
check_source('full frozen push snapshot target',
    read_file('tests/fixtures/push_result_selection_values.spec'),'x',
    $json->decode(read_file('tests/fixtures/push_result_selection_values.json')),0,'Value');

check_source('existing read-only target',
    read_file('tests/fixtures/push_result_selection_read_values.spec'),'x',
    $json->decode(read_file('tests/fixtures/push_result_selection_read_values.json')),0,'Value');

check_source('existing completed-value fluent control',
    q{Value:: I {items=[];saved=push(items,"tail");return([saved.coalesce(undef).last().uppercase(),items])}},
    'x',['TAIL',['tail']],0,'Value');

check_source('Array Hash and Number result transitions',
    q{Value:: I {items=[];number=push(items,[3,1]).last().sorted().last().add(4);hash=push(items,{"k":"tail"}).last().sorted_keys().last().uppercase();count=push(items,"tail").count().add(1);return([number,hash,count,items])}},
    'x',[7,'K',4,[[3,1],{k=>'tail'},'tail']],0,'Value');

check_source('copy and logical links consume the actual result',
    q{Value:: I {items=[];text=push(items,"tail").copy().last().uppercase();boolean=push(items,false).last().not();logical=push(items,"tail").is_nonempty().and(false);return([text,boolean,logical,items])}},
    'x',['TAIL',JSON::PP::true,JSON::PP::false,['tail',JSON::PP::false,'tail']],0,'Value');

check_source('with returned kinds guards and outer scope',
    q{Value:: I {items=[];value="outer";order="";array=push(items,"a").with(){return([value,"tail"])}[-1].uppercase();hash=push(items,"b").with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=push(items,"c").with(){return(false)}.take({order=cat(order,"A");1});boolean=push(items,"d").with(){return(false)}.coalesce(true);return([array,hash,bad,boolean,value,order,items])}},
    'x',['TAIL','TAIL',undef,JSON::PP::false,'outer','',['a','b','c','d']],0,'Value');

check_source('source once before consumer rebinding and local returns',
    q{Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");return("tail")}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}},
    'x',['TAIL!',['new'],'SC'],0,'Value');

check_source('function-local fluent push keeps caller scope',
    q{fn pick(){items=[];out=push(items,"tail").last().uppercase();return([out,items])} Value:: I {items=["caller"];return([pick(),items])}},
    'x',[['TAIL',['tail']],['caller']],0,'Value');

check_source('invalid consumer arity still skips source effects',
    q{Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");"tail"}).last(1);return([out,items,order])}},
    'x',[undef,[],''],0,'Value');

subtest 'source wrong-target error precedes fluent default' => sub {
    my $actual=observe_source(q{Value:: I {items="text";return(push(items,"x").last().coalesce("masked"))}},'x','Value');
    diag('PUSH_FLUENT_SOURCE_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','original native runtime stage');
    is($actual->{fresh_error}{code},'generated_execution_failed','original generated wrapper');
    for my $route ('native','fresh') {
        my $error=$actual->{$route.'_error'};
        like($error->{detail}//'',qr/binding_kind_mismatch/,$route.' inherited source error');
        like($error->{detail}//'',qr/identifier=items/,$route.' target preserved');
        ok(!defined($actual->{$route}),$route.' default cannot mask source failure');
    }
};
done_testing();
