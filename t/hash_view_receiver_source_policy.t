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
    my $root = $ENV{LINKEDSPEC_VIEW_RECEIVER_SOURCE_CAPTURE};
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
    $result{substitution} = eval { LinkedSpec::call_spec_handler_subst($case->{rule}, $case->{body}) };
    $result{substitution_error} = error_value($@);
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $result{descriptor_error} = error_value($@);
    my $metadata = $descriptor->{spec}{$case->{rule}}{meta}{action_rewriter} // {};
    $result{metadata} = { map { $_ => $metadata->{$_} }
        qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers) };
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'hash-view-receiver-source-policy.spec') };
    $result{emission_error} = error_value($@);
    my $native = eval { LinkedSpec::Get(\$source, dump_parser_source => 1,
        parser_source_ref => \$handler, runtime_ctx_ref => \%context) };
    $result{build_error} = error_value($@);
    $result{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    $result{module_input} = persist($identifier, 'pm', $emitted);
    $result{handler_input} = persist($identifier, 'handler.pl', $handler);
    if (defined($ENV{LINKEDSPEC_VIEW_RECEIVER_SOURCE_CAPTURE})) {
        diag('VIEW_RECEIVER_SOURCE_INPUT ' . $identifier . ' ' . $json->encode({ source => $source, emitted => $emitted, handler => $handler }));
    }
    my $package = 'LinkedSpec::HashViewReceiverSourcePolicy::' . $identifier;
    my $state = $case->{seed} // 'empty';
    no strict 'refs';
    local %{'main::3'} = $state eq 'main' ? (host_main => 'MAIN') : ();
    local %{$package . '::3'} = $state eq 'outer' ? (host_outer => 'OUTER') : ();
    $result{host_before} = { main => { %{'main::3'} }, outer => { %{$package . '::3'} } };
    if ($result{native_callable}) {
        my $input = $case->{input};
        $result{native} = eval { $native->(\$input) };
        $result{native_error} = error_value($@ || $context{last_error});
        $result{native_cursor} = pos($input);
    }
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $result{loaded} = $loaded ? 1 : 0;
    $result{load_error} = error_value($@);
    if ($loaded) {
        my $input = $case->{input};
        $result{fresh} = eval { $package->can('Execute')->(\$input) };
        $result{fresh_error} = error_value($@);
        $result{fresh_cursor} = pos($input);
    }
    $result{host_after} = { main => { %{'main::3'} }, outer => { %{$package . '::3'} } };
    $result{warnings} = \@warnings;
    return \%result;
}


sub common {
    my ($actual) = @_;
    ok($actual->{native_callable} && !$actual->{build_error}, 'native parser builds');
    ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh module loads');
    ok(!$actual->{descriptor_error} && !$actual->{substitution_error}, 'public descriptor/substitution resolve');
    is_deeply($actual->{warnings}, [], 'build/load/execute stay warning-free');
    is_deeply($actual->{metadata}, {
        language_agnostic_action_ir_ready => 1, raw_perl_dependency_count => 0,
        canonical_action_ir_fallback_count => 0, unresolved_helper_count => 0, unresolved_helpers => [],
    }, 'canonical ready without fallback/raw/unresolved');
    is_deeply($actual->{host_after}, $actual->{host_before}, 'localized host values unchanged');
}

for my $case (@{read_json('tests/fixtures/hash_view_receiver_policy_perl_cases.json')}) {
    subtest $case->{id} => sub {
        my $actual = observe($case);
        diag('VIEW_RECEIVER_SOURCE_PERL ' . $case->{id} . ' ' . $json->encode($actual));
        common($actual);
        for my $route (qw(native fresh)) {
            is($actual->{$route . '_cursor'}, $case->{cursors}{$route}, "$route cursor preserved");
            if ($case->{expected_error}) {
                my $error = $actual->{$route . '_error'};
                ok(ref($error) eq 'HASH', "$route needed initial-source error survives");
                if (ref($error) eq 'HASH') {
                    like($error->{detail}, qr/\A\Q$case->{expected_error}\E at /, "$route original error reason");
                    my %metadata = %$error;
                    delete $metadata{detail};
                    is_deeply(\%metadata, $case->{expected_error_meta}{$route}, "$route original error type/stage/code");
                }
            } else {
                is($actual->{$route . '_error'}, undef, "$route no execution error");
                is($json->encode($actual->{$route}), $json->encode($case->{expected}), "$route own original source/result policy");
            }
        }
    };
}
for my $case (@{read_json('tests/fixtures/hash_view_numeric_source_perl_cases.json')}) {
    subtest 'seed_' . $case->{id} => sub {
        for my $state (qw(empty outer main)) {
            my %seeded = (%$case, id => 'seed_' . $case->{id} . '_' . $state, seed => $state);
            my $actual = observe(\%seeded);
            diag('VIEW_RECEIVER_SOURCE_PERL ' . $seeded{id} . ' ' . $json->encode($actual));
            common($actual);
            my $expected_host = {
                main => $state eq 'main' ? { host_main => 'MAIN' } : {},
                outer => $state eq 'outer' ? { host_outer => 'OUTER' } : {},
            };
            is_deeply($actual->{host_before}, $expected_host, "$state actual distinguishing host input");
            for my $route (qw(native fresh)) {
                is($actual->{$route . '_error'}, undef, "$route $state no execution error");
                is($json->encode($actual->{$route}), $json->encode($case->{expected}), "$route $state uses only DSL numeric/Hash source");
                is($actual->{$route . '_cursor'}, 0, "$route $state cursor preserved");
            }
        }
    };
}
done_testing();
