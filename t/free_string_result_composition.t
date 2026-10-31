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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'free-string-result-composition.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::FreeStringResultComposition'.++$sequence;
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
        diag('FREE_STRING_ACTUAL '.$name.' '.$json->encode($actual));
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





# TYPE-REFERENCE-BOOK.1.2.23.3.62.1 — canonical free String sources and P1 isolation.
for my $row (@{$json->decode(read_file('tests/fixtures/free_string_result_cases.json'))}) {
    next if $row->{expected_error};
    # TYPE-REFERENCE-BOOK.1.2.23.3.62.6.1 explicitly admits the receiver-only bridge.
    check_source($row->{id},$row->{source},$row->{input},$row->{expected},0,'Value');
}
check_source('numeric_identity_remains_an_array_index',q|Value:: I {slots=["old"];index=rm_prefix(0,"x").copy();slots[index]="updated";return([index,slots,rm_suffix(false,"x").copy()])}|,'x',$json->decode(q|[0,["updated"],false]|),0,'Value');
subtest 'needed String source error precedes recovery' => sub {
    my ($row)=grep {$_->{expected_error}} @{$json->decode(read_file('tests/fixtures/free_string_result_cases.json'))};
    my $actual=observe_source($row->{source},$row->{input},$row->{rule});
    diag('FREE_STRING_SOURCE_ERROR '.$json->encode($actual));
    is($actual->{native_error}{stage},'rule_handler_eval','original native runtime stage');
    is($actual->{fresh_error}{code},'generated_execution_failed','generated error wrapper');
    for my $route ('native','fresh') {
        like($actual->{$route.'_error'}{detail}//'',qr/binding_kind_mismatch/,$route.' original source error');
        ok(!defined($actual->{$route}),$route.' recovery cannot mask source error');
    }
};
subtest 'free String Hash consumer isolates synthetic host package data' => sub {
    for my $seed (0,1) {
        my $source=q|Value:: I {return(uppercase("tail").set_key("k",1))}|;
        my @warnings;local $SIG{__WARN__}=sub{push @warnings,@_};
        my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'free-string-host-hash.spec');
        my $package='LinkedSpec::FreeStringIsolation'.$seed;
        no strict 'refs';
        local %{$package.'::TAIL'}=$seed?(probe=>'HOST_PACKAGE'):();
        my $loaded=eval "package $package; $emitted; 1";
        ok($loaded,'fresh package loads') or do{diag($@);next};
        my $input='x';my $value=eval{$package->can('Execute')->(\$input)};my $error=$@;
        diag('FREE_STRING_HOST_HASH '.$json->encode({seed=>$seed,value=>$value,error=>error_value($error),warnings=>\@warnings}));
        is("$error",'','fresh package execution succeeds');
        ok(!defined($value),'incompatible consumer returns null independently of host seed');
        is_deeply([sort keys %{$package.'::TAIL'}],$seed?['probe']:[],'host Hash remains untouched');
        is_deeply(\@warnings,[],'build/run warning-free');
    }
};
done_testing();
