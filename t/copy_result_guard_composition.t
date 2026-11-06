use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;

sub read_json {
    my ($path) = @_;
    open my $file, '<:raw', $path or die "cannot read $path: $!";
    my $rows = $json->decode(do { local $/; <$file> });
    close $file or die $!;
    return $rows;
}

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    return "$error" unless (reftype($error) // '') eq 'HASH';
    my %result = map { $_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_} }
        grep { exists $error->{$_} } qw(type code stage detail summary helper_name phase rule_label actual_arity expected_arity arguments_evaluated);
    $result{class} = ref($error) if ref($error) ne 'HASH';
    return \%result;
}

sub persist {
    my ($identifier, $suffix, $body) = @_;
    my $root = $ENV{LINKEDSPEC_COPY_RESULT_CAPTURE};
    return undef unless defined($root) && length($root) && defined($body);
    my $path = "$root/$identifier.$suffix.gz";
    die "one-shot artifact already exists: $path" if -e $path;
    gzip \$body => $path or die $GzipError;
    return { path => $path, sha256 => sha256_hex($body), bytes => length($body) };
}

sub observe {
    my ($case) = @_;
    my ($identifier, $source) = @{$case}{qw(id source)};
    my (%result, %context, @warnings, $handler);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $result{descriptor_error} = error_value($@);
    my $metadata = $descriptor->{spec}{$case->{rule}}{meta}{action_rewriter} // {};
    $result{metadata} = { map { $_ => $metadata->{$_} }
        qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers) };
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'copy-result-guard-composition.spec') };
    $result{emission_error} = error_value($@);
    my $native = eval { LinkedSpec::Get(\$source, dump_parser_source => 1,
        parser_source_ref => \$handler, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    $result{module_input} = persist($identifier, 'pm', $emitted);
    $result{handler_input} = persist($identifier, 'handler.pl', $handler);
    if (defined($ENV{LINKEDSPEC_COPY_RESULT_CAPTURE})) {
        diag('COPY_RESULT_INPUT ' . $identifier . ' ' . $json->encode({ source => $source, emitted => $emitted, handler => $handler }));
    }
    if ($result{native_callable}) {
        my $input = $case->{input};
        $result{native} = eval { $native->(\$input) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($input);
    }
    my $package = 'LinkedSpec::CopyResultGuardComposition::' . $identifier;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $result{loaded} = $loaded ? 1 : 0;
    $result{load_error} = error_value($@);
    if ($loaded) {
        my $input = $case->{input};
        $result{fresh} = eval { $package->can('Execute')->(\$input) };
        $result{fresh_error} = error_value($@);
        $result{fresh_cursor} = pos($input);
    }
    $result{warnings} = \@warnings;
    return \%result;
}

my @cases = map { @{read_json($_)} } qw(tests/fixtures/copy_result_guard_cases.json tests/fixtures/copy_result_guard_perl_preservation_cases.json);
for my $case (@cases) {
    my $identifier = $case->{id};
    die 'unsafe authored case id' unless $identifier =~ /\A[a-z][a-z0-9_]*\z/;
    subtest $identifier => sub {
        my $actual = observe($case);
        diag('COPY_RESULT_PERL ' . $identifier . ' ' . $json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error}, 'native parser builds');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh module loads');
        ok(!$actual->{descriptor_error}, 'descriptor resolves');
        is_deeply($actual->{warnings}, [], 'build/load/execute remain warning-free');
        my $metadata = $actual->{metadata};
        ok($metadata->{language_agnostic_action_ir_ready}, 'canonical source ready');
        is($metadata->{raw_perl_dependency_count}, 0, 'no raw dependency');
        is($metadata->{canonical_action_ir_fallback_count}, 0, 'no fallback executor');
        is($metadata->{unresolved_helper_count}, 0, 'no unresolved helper');
        is_deeply($metadata->{unresolved_helpers}, [], 'no unresolved names');
        if ($case->{expected_error}) {
            for my $route (qw(native fresh)) {
                like($json->encode($actual->{$route . '_error'}), qr/\Q$case->{expected_error}\E/, "$route preserves needed source error");
            }
            is($actual->{native_error}{stage}, 'rule_handler_eval', 'native error stage preserved');
            is($actual->{fresh_error}{stage}, 'execute_generated', 'fresh error stage preserved');
        } else {
            is($actual->{native_error}, undef, 'native has no handler error');
            is($actual->{fresh_error}, undef, 'fresh has no execution error');
            is($json->encode($actual->{native}), $json->encode($case->{expected}), 'native exact values and kinds');
            is($json->encode($actual->{fresh}), $json->encode($case->{expected}), 'fresh exact values and kinds');
        }
    };
}
done_testing();
