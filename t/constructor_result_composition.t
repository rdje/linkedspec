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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'constructor-result-composition.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::ConstructorResultComposition'.++$sequence;
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
        diag('CONSTRUCTOR_ACTUAL '.$name.' '.$json->encode($actual));
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





# TYPE-REFERENCE-BOOK.1.2.23.3.61.1 — retained constructor result consumers.
for my $row (@{$json->decode(read_file('tests/fixtures/constructor_result_cases.json'))}) {
    next if $row->{expected_error};
    check_source($row->{id},$row->{source},$row->{input},$row->{expected},0,'Value');
}
check_source('hash_rejection_source_once_with',q|Value:: I {order="";out=hash({order=cat(order,"S");return("k")},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}|,'x',$json->decode(q|[null,"S"]|),0,'Value');
check_source('array_prefix_rejection_skips_with',q|Value:: I {order="";out=array("head","tail").take(1).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}|,'x',$json->decode(q|[null,""]|),0,'Value');
check_source('valid_empty_array_prefix_with',q|Value:: I {order="";out=array("tail").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}|,'x',$json->decode(q|[[0,"tail"],"W"]|),0,'Value');
check_source('valid_null_result_with',q|Value:: I {order="";out=array("tail").with(){order=cat(order,"N");return(undef)}.with(){order=cat(order,"W");return("recovered")};return([out,order])}|,'x',$json->decode(q|["recovered","NW"]|),0,'Value');
subtest 'needed constructor argument failure precedes recovery' => sub {
    my ($row)=grep {$_->{expected_error}} @{$json->decode(read_file('tests/fixtures/constructor_result_cases.json'))};
    my $actual=observe_source($row->{source},$row->{input},$row->{rule});
    diag('CONSTRUCTOR_SOURCE_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','original native runtime stage');
    is($actual->{fresh_error}{code},'generated_execution_failed','original generated wrapper');
    for my $route ('native','fresh') {
        like($actual->{$route.'_error'}{detail}//'',qr/binding_kind_mismatch/,$route.' needed failure retained');
        ok(!defined($actual->{$route}),$route.' recovery does not mask constructor error');
    }
};

check_source('hash_block_key_value_order_snapshot',q|Value:: I {name="old";order="";out=hash({order=cat(order,"K");return(name)},{name="new";order=cat(order,"V");return([false,0,"tail"])});return([out,name,order])}|,'x',$json->decode(q|[{"old":[false,0,"tail"]},"new","KV"]|),0,'Value');
check_source('hash_block_key_function_scope',q|fn build(key){return(hash({return(key)},array("tail",false)))} Value:: I {key="caller";return([build("inside"),key])}|,'x',$json->decode(q|[{"inside":["tail",false]},"caller"]|),0,'Value');
check_source('computed_key_keeps_existing_policy',q|Value:: I {return(hash(cat("k","x"),1))}|,'x',$json->decode(q|{"kx":1}|),0,'Value');
subtest 'needed Hash key failure precedes consumer' => sub {
    my $actual=observe_source(q|Value:: I {return(hash({items="text";push(items,"x")},"tail").take(1))}|,'x','Value');
    diag('CONSTRUCTOR_KEY_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','key runtime stage');
    is($actual->{fresh_error}{code},'generated_execution_failed','generated key failure');
    for my $route ('native','fresh') {
        like($actual->{$route.'_error'}{detail}//'',qr/binding_kind_mismatch/,$route.' original needed key error');
        ok(!defined($actual->{$route}),$route.' consumer cannot recover key error');
    }
};

check_source('computed_key_forms',q|Value:: I {names=["idx"];meta={"key":"field"};return([hash("k".cat("x"),1),hash(names[0],2),hash(meta["key"],3),hash({return("block")},4),hash(cat("c","all"),5)])}|,'x',$json->decode(q|[{"kx":1},{"idx":2},{"field":3},{"block":4},{"call":5}]|),0,'Value');
check_source('bare_tag_policy',q|Value:: I {token="changed";return(hash(token,1))}|,'x',$json->decode(q|{"token":1}|),0,'Value');
done_testing();
