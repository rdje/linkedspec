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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'free-default-result-composition.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::FreeDefaultResultComposition'.++$sequence;
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
        diag('FREE_DEFAULT_ACTUAL '.$name.' '.$json->encode($actual));
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





# TYPE-REFERENCE-BOOK.1.2.23.3.60.1 — canonical free-default result guards.
use LinkedSpec::ActionIR::AST ();
for my $row (@{$json->decode(read_file('tests/fixtures/free_default_result_cases.json'))}) {
    check_source($row->{id},$row->{source},$row->{input},$row->{expected},0,'Value');
}

check_source('valid_null_with_runs',q|Value:: I {order="";out=coalesce(undef,undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}|,'x',$json->decode(q|["recovered","W"]|),0,'Value');
check_source('valid_empty_array_with_runs',q|Value:: I {order="";out=coalesce(["tail"],undef).take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}|,'x',$json->decode(q|[[0,"tail"],"W"]|),0,'Value');
check_source('rejection_skips_with_after_source_once',q|Value:: I {order="";out=coalesce_nonempty({order=cat(order,"S");""},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}|,'x',$json->decode(q|[null,"S"]|),0,'Value');
check_source('valid_with_preserves_outer_value',q|Value:: I {value="outer";out=coalesce(undef,"tail").with(){return(value.cat("!"))};return([out,value])}|,'x',$json->decode(q|["tail!","outer"]|),0,'Value');

subtest 'needed default failure precedes recovery' => sub {
    my $actual=observe_source(q{Value:: I {return(coalesce(undef,{items="text";push(items,"x")}).coalesce("masked"))}},'x','Value');
    diag('FREE_DEFAULT_SOURCE_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','original native runtime stage');
    is($actual->{fresh_error}{code},'generated_execution_failed','original generated wrapper');
    for my $route ('native','fresh') {
        like($actual->{$route.'_error'}{detail}//'',qr/binding_kind_mismatch/,$route.' source failure retained');
        ok(!defined($actual->{$route}),$route.' default does not mask source failure');
    }
};

sub snapshot_ast_value {
 my ($value)=@_;
 return $value unless ref($value);
 my $kind=reftype($value)//'';
 return {map {$_=>snapshot_ast_value($value->{$_})} keys %$value} if $kind eq 'HASH';
 return [map {snapshot_ast_value($_)} @$value] if $kind eq 'ARRAY';
 return "$value";
}
sub snapshot_ast_error {
 my ($error)=@_;
 return undef unless ref($error) || (defined($error) && length($error));
 return {class=>ref($error),value=>snapshot_ast_value($error)};
}
subtest 'excluded source and deferred ASTs stay unchanged' => sub {
    my $rows=$json->decode(read_file('tests/fixtures/free_default_excluded_source_ast.json'));
    is(scalar(@$rows),8,'all authored negative source controls selected');
    for my $row (@$rows) {
        my $actual=eval {$row->{mode} eq 'statement'
            ? LinkedSpec::ActionIR::AST::parse_action_statement($row->{source})
            : LinkedSpec::ActionIR::AST::parse_action_expr($row->{source})};
        my $error=snapshot_ast_error($@);
        is_deeply({ast=>$actual,error=>$error},{ast=>$row->{ast},error=>$row->{error}},
            $row->{label}.' original AST or typed error and spans');
    }
};
done_testing();
