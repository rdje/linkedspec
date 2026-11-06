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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'key-count-domain.spec') };
    $result{emission_error} = error_value($@);
    my $artifact_id = ++$sequence;
    if (defined($emitted) && defined($ENV{LINKEDSPEC_KEY_COUNT_DOMAIN_DIR})) {
        my $path = $ENV{LINKEDSPEC_KEY_COUNT_DOMAIN_DIR}."/module-$artifact_id.pm.gz";
        gzip \$emitted => $path or die $GzipError;
        print 'KEY_COUNT_DOMAIN_INPUT '.$artifact_id.' '.$json->encode({source=>$source,emitted=>$emitted}), "\n";
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
    my $package = 'LinkedSpec::KeyCountDomainComposition'.$artifact_id;
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
    my ($case) = @_;
    my ($name, $source, $input, $expected, $rule) = @{$case}{qw(id source input expected rule)};
    my $cursor = 0;
    return if @ARGV && !grep { $_ eq $name } @ARGV;
    subtest $name => sub {
        my $actual = observe_source($source, $input, $rule);
        $actual->{seeds} = observe_seeds($case, $sequence) if $case->{seed_namespace};
        diag('KEY_COUNT_DOMAIN_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error} && !$actual->{native_error}, 'native executes without handler error');
        is($json->encode($actual->{native}), $json->encode($expected), 'native exact values and kinds');
        is($actual->{native_cursor}, $cursor, 'native cursor preserved');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh source loads');
        ok($actual->{loaded} && !$actual->{fresh_error}, 'fresh execution succeeds');
        is($json->encode($actual->{fresh}), $json->encode($expected), 'fresh exact values and kinds');
        is($actual->{fresh_cursor}, $cursor, 'fresh cursor preserved');
        ok(!$actual->{descriptor_error}, 'descriptor resolves');
        is_deeply($actual->{warnings}, [], 'build/load/run stay warning-free');
        if ($case->{seed_namespace}) {
            is(scalar(@{$actual->{seeds}{rows}}), 6, 'public/emitted seed routes complete');
            ok(!$actual->{seeds}{lowering_error} && !$actual->{seeds}{carrier_error}, 'public carrier lowers and loads');
            for my $row (@{$actual->{seeds}{rows}}) {
                is($json->encode($row->{value}), '0', $row->{route}.' '.$row->{seed}.' numeric data stays zero');
                ok(!$row->{error}, 'seed route executes');
                is_deeply($row->{warnings}, [], 'seed route warning-free');
                is_deeply($row->{host_after}, $row->{host_before}, 'localized host data unchanged');
            }
        }
        my $meta = $actual->{metadata};
        is($meta->{raw_perl_dependency_count}, 0, 'no raw dependency');
        is($meta->{canonical_action_ir_fallback_count}, 0, 'no fallback executor');
        is($meta->{unresolved_helper_count}, 0, 'ordinary sources resolve');
        ok($meta->{language_agnostic_action_ir_ready}, 'readiness accompanies actual execution');
    };
}

# TYPE-REFERENCE-BOOK.1.2.23.3.75.0.2 — initial CountKeys source policy.
sub observe_seeds {
    my ($case, $artifact_id) = @_;
    my $namespace = $case->{seed_namespace};
    die 'invalid numeric seed namespace' unless $namespace =~ /\A[0-9]+\z/;
    my $lowered = eval { LinkedSpec::call_spec_handler_subst('Value', $case->{body}) };
    my %result = (lowering_error => error_value($@));
    my $public = 'LinkedSpec::KeyCountDomainPublic'.$artifact_id;
    my $carrier = "package $public; no strict; sub Run { $lowered }";
    if (defined($ENV{LINKEDSPEC_KEY_COUNT_DOMAIN_DIR})) {
        gzip \$carrier => $ENV{LINKEDSPEC_KEY_COUNT_DOMAIN_DIR}."/public-$artifact_id.pl.gz" or die $GzipError;
        print 'KEY_COUNT_DOMAIN_PUBLIC '.$artifact_id.' '.$json->encode({lowered=>$lowered,carrier=>$carrier}), "\n";
    }
    my $loaded = eval "$carrier; 1";
    $result{carrier_error} = error_value($@);
    my @rows;
    for my $route ('public', 'fresh') {
        my $package = $route eq 'public' ? $public : 'LinkedSpec::KeyCountDomainComposition'.$artifact_id;
        for my $seed ('empty','outer','main') {
            no strict 'refs';
            local %{$package.'::'.$namespace};
            local %{'main::'.$namespace};
            %{$package.'::'.$namespace} = (outer=>'OUTER') if $seed eq 'outer';
            %{'main::'.$namespace} = (main=>'MAIN') if $seed eq 'main';
            my $before = {outer=>{%{$package.'::'.$namespace}},main=>{%{'main::'.$namespace}}};
            my @warnings;
            local $SIG{__WARN__} = sub {push @warnings, @_};
            my $value = eval {
                die 'public carrier unavailable' if $route eq 'public' && !$loaded;
                if ($route eq 'public') {$package->can('Run')->()}
                else {my $input=$case->{input};$package->can('Execute')->(\$input)}
            };
            my $error = error_value($@);
            my $after = {outer=>{%{$package.'::'.$namespace}},main=>{%{'main::'.$namespace}}};
            push @rows, {route=>$route,seed=>$seed,value=>$value,error=>$error,warnings=>\@warnings,host_before=>$before,host_after=>$after};
        }
    }
    $result{rows}=\@rows;
    return \%result;
}
for my $case (@{$json->decode(read_file('tests/fixtures/key_count_source_domain_cases.json'))}) {
    check_source($case);
}
done_testing();
