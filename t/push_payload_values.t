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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'push-payload-values.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::PushPayloadValues'.++$sequence;
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
        diag('PUSH_PAYLOAD_ACTUAL '.$name.' '.$json->encode($actual));
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



# TYPE-REFERENCE-BOOK.1.2.23.3.58.0 — existing explicit-value push payloads.
check_source('saved Hash payload preserves shape and kind',
    q{Value:: I {items=[];saved=push(items,{"k":"tail","flag":false,"zero":0,"missing":undef});return([saved,items])}},
    'x', [[{k=>'tail',flag=>JSON::PP::false,zero=>0,missing=>undef}],
          [{k=>'tail',flag=>JSON::PP::false,zero=>0,missing=>undef}]], 0, 'Value');

check_source('nested Hash in Array payload stays one appended value',
    q{Value:: I {items=[];saved=push(items,["a",{"k":[false,0,undef,"tail"]}]);return([saved,items])}},
    'x', [[['a',{k=>[JSON::PP::false,0,undef,'tail']}]],
          [['a',{k=>[JSON::PP::false,0,undef,'tail']}]]], 0, 'Value');

check_source('payload effects local return and saved snapshot',
    q{Value:: I {items=[];order="";saved=push(items,{"k":{order=cat(order,"V");return("tail")}});items.push_back("later");return([saved,items,order])}},
    'x', [[{k=>'tail'}],[{k=>'tail'},'later'],'V'], 0, 'Value');

check_source('function local aggregate push keeps caller binding',
    q{fn pack(){items=[];saved=push(items,{"k":"tail"});return(saved)} Value:: I {items=["caller"];out=pack();return([out,items])}},
    'x', [[{k=>'tail'}],['caller']], 0, 'Value');

check_source('existing primitive Array block and named payloads',
    q{Value:: I {items=[];first=push(items,false);second=push(items,["a",0,undef]);third=push(items,{{"k":"block"}});payload={"k":"named"};fourth=push(items,payload);return([first,second,third,fourth,items])}},
    'x', [[JSON::PP::false],[JSON::PP::false,['a',0,undef]],
          [JSON::PP::false,['a',0,undef],{k=>'block'}],
          [JSON::PP::false,['a',0,undef],{k=>'block'},{k=>'named'}],
          [JSON::PP::false,['a',0,undef],{k=>'block'},{k=>'named'}]], 0, 'Value');

check_source('existing standalone Hash push statement',
    q{Value:: I {items=[];push(items,{"k":"tail"});return(items)}},
    'x', [{k=>'tail'}], 0, 'Value');

check_source('all bare static child precedence remains',
    qq{Value::\n I {items=["unchanged"];outputs=[];saved=push(items,outputs);return([saved,items,outputs])}\nitems::\n /x/ I {return("child")}\n},
    'x', [['child'],['unchanged'],['child']], 0, 'Value');

subtest 'existing wrong target kind diagnostic' => sub {
    my $actual=observe_source(q{Value:: I {items="text";saved=push(items,"x");return(saved)}},'x','Value');
    diag('PUSH_PAYLOAD_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','native runtime stage unchanged');
    is($actual->{fresh_error}{code},'generated_execution_failed','fresh wrapper code unchanged');
    for my $route ('native','fresh') {
        my $error=$actual->{$route.'_error'};
        like($error->{detail}//'',qr/binding_kind_mismatch/,$route.' original binding error');
        like($error->{detail}//'',qr/identifier=items/,$route.' original target');
        like($error->{detail}//'',qr/expected_kind=array/,$route.' expected kind');
        like($error->{detail}//'',qr/actual_kind=scalar/,$route.' actual kind');
    }
};
done_testing();
