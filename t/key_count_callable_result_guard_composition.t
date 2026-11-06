use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use IO::Compress::Gzip qw(gzip $GzipError);

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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'key-count-callable-result.spec') };
    $result{emission_error} = error_value($@);
    my $artifact_id = ++$sequence;
    if (defined($emitted) && defined($ENV{LINKEDSPEC_KEY_COUNT_CALLABLE_DIR})) {
        my $path = $ENV{LINKEDSPEC_KEY_COUNT_CALLABLE_DIR}."/module-$artifact_id.pm.gz";
        gzip \$emitted => $path or die $GzipError;
        print 'CALLABLE_KEY_COUNT_NORMAL_INPUT '.$artifact_id.' '.$json->encode({source=>$source,emitted=>$emitted}), "\n";
    }
    my $native = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    if ($result{native_callable}) {
        my $text = $input;
        $result{native} = eval { $native->(\$text) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($text);
    }
    my $package = 'LinkedSpec::KeyCountCallableComposition'.$artifact_id;
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

# TYPE-REFERENCE-BOOK.1.2.23.3.75.6.1 — compatible callable CountKeys results.
my $profiles=$json->decode(read_file('tests/fixtures/key_count_callable_perl_profiles.json'));
my $cases=$json->decode(read_file('tests/fixtures/key_count_callable_result_cases.json'));
for my $case (@$cases) {
    my $name=$case->{id};
    next if @ARGV && !grep { $_ eq $name } @ARGV;
    subtest $name => sub {
        my $actual=observe_source($case->{source},$case->{input},$case->{rule});
        diag('CALLABLE_KEY_COUNT_NORMAL_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error},'native source builds');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error},'fresh emitted module loads');
        for my $route ('native','fresh') {
            if ($case->{profile_only} || $case->{expected_error}) {
                is($json->encode($actual->{$route}),$json->encode($profiles->{$name}{$route}),$route.' independently frozen value profile');
                is_deeply($actual->{$route.'_error'},$profiles->{$name}{$route.'_error'},$route.' exact source error profile');
            } else {
                ok(!$actual->{$route.'_error'},$route.' error-free');
                is($json->encode($actual->{$route}),$json->encode($case->{expected}),$route.' exact values/kinds/effects');
            }
            is($actual->{$route.'_cursor'},0,$route.' cursor unchanged');
        }
        is_deeply($actual->{warnings},[],'warning-free build/load/execution');
        ok(!$actual->{descriptor_error},'descriptor resolves');
        my $meta=$case->{profile_only} || $case->{expected_error}
            ? $profiles->{$name}{metadata}
            : {language_agnostic_action_ir_ready=>1,raw_perl_dependency_count=>0,canonical_action_ir_fallback_count=>0,unresolved_helper_count=>0,unresolved_helpers=>[]};
        is_deeply($actual->{metadata},$meta,'exact independent admission profile');
    };
}
done_testing();
