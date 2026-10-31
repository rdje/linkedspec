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
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name name phase rule_label source_id invocation_id accessor actual_arity expected_arity arguments_evaluated);
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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'definedness-native-numeric-contract.spec') };
    $result{emission_error} = error_value($@);
    my $package = 'LinkedSpec::DefinednessNativeNumericContract'.++$sequence;
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
        diag('DEFINEDNESS_NATIVE_NUMERIC_ACTUAL '.$name.' '.$json->encode($actual));
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

# TYPE-REFERENCE-BOOK.1.2.23.1.28.0 — preserve native predicate slots;
# serialized empty text alone is not a scalar-kind oracle.
check_source('native predicates differ from literal empty text and typed Bool',
    q{Value:: I {return([is_defined(undef),is_undefined(0),"",false,num_add(is_defined(undef),1),is_defined(undef).add(1),num_add(is_undefined(0),1),0.is_undefined().add(1),copy(is_defined(undef)).add(1),copy(is_undefined(0)).add(1),num_add("",1),"".add(1),num_add(false,1),false.add(1),num_add(0,1),"0".add(1)])}},
    'x', ['', '', '', JSON::PP::false, 1, 1, 1, 1, 1, 1, undef, undef, undef, undef, 1, 1], 0, 'Value');
check_source('numeric inspection retains empty text snapshot and rendering',
    q{Value:: I {flag=is_defined(undef);before=flag;out=flag.add(1);return([before,flag,out,flag.cat("!")])}},
    'x', ['', '', 1, '!'], 0, 'Value');
done_testing();
