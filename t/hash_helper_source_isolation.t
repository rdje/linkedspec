use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $capture = $ENV{LINKEDSPEC_HASH_HELPER_SOURCE_CAPTURE};
die 'capture requires an owned relative phase directory' if defined($capture)
    && ($capture !~ m{\Adocs/checkpoints/hash-helper-source-isolation-perl-2026-11-07/[a-z_]+\z}
        || !-d $capture || -l $capture);

sub read_json {
    my ($path) = @_;
    open my $file, '<:raw', $path or die "cannot read $path: $!";
    my $value = $json->decode(do { local $/; <$file> });
    close $file or die $!;
    return $value;
}

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    return "$error" unless (reftype($error) // '') eq 'HASH';
    my %value = map { $_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_} }
        grep { exists $error->{$_} } qw(type code stage detail summary helper_name name phase rule_label actual_arity expected_arity arguments_evaluated);
    $value{class} = ref($error) if ref($error) ne 'HASH';
    return \%value;
}

sub persist {
    my ($identifier, $suffix, $body) = @_;
    return undef unless defined($capture) && defined($body);
    my $path = "$capture/$identifier.$suffix.gz";
    die 'one-shot artifact already exists' if -e $path;
    gzip \$body => $path or die $GzipError;
    return { path => $path, sha256 => sha256_hex($body), bytes => length($body) };
}

sub observe {
    my ($case, $identifier, $seeded) = @_;
    my $source = $case->{source};
    my (%row, %context, @warnings, $handler);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    $row{substitution} = eval { LinkedSpec::call_spec_handler_subst($case->{rule}, $case->{body}) };
    $row{substitution_error} = error_value($@);
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $row{descriptor_error} = error_value($@);
    my $meta = $descriptor->{spec}{$case->{rule}}{meta}{action_rewriter} // {};
    $row{metadata} = { map { $_ => $meta->{$_} } qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers) };
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'hash-helper-source-isolation.spec') };
    $row{emission_error} = error_value($@);
    $row{module_input} = persist($identifier, 'pm', $emitted);
    my $native = eval { LinkedSpec::Get(\$source, dump_parser_source => 1,
        parser_source_ref => \$handler, runtime_ctx_ref => \%context) };
    $row{build_error} = error_value($@);
    $row{native_callable} = ref($native) eq 'CODE' ? 1 : 0;
    $row{handler_input} = persist($identifier, 'handler.pl', $handler);
    diag('HASH_HELPER_SOURCE_INPUT ' . $identifier . ' ' . $json->encode({ source => $source, emitted => $emitted, handler => $handler }))
        if defined($capture);
    my $package = 'LinkedSpec::HashHelperSourceIsolation::' . $identifier;
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    $row{loaded} = $loaded ? 1 : 0;
    $row{load_error} = error_value($@);
    my $run = sub {
        my %actual;
        if ($row{native_callable}) {
            my $input = $case->{input};
            $actual{native} = eval { $native->(\$input) };
            $actual{native_error} = error_value($@ || $context{last_error});
            $actual{native_cursor} = pos($input);
        }
        if ($loaded) {
            my $input = $case->{input};
            $actual{fresh} = eval { $package->can('Execute')->(\$input) };
            $actual{fresh_error} = error_value($@);
            $actual{fresh_cursor} = pos($input);
        }
        return \%actual;
    };
    {
        no strict 'refs';
        if ($seeded) {
            for my $state (qw(empty outer main)) {
                local %{'main::3'} = $state eq 'main' ? (a => 'HOST_MAIN', host_main => 'MAIN') : ();
                local %{$package . '::3'} = $state eq 'outer' ? (a => 'HOST_OUTER', host_outer => 'OUTER') : ();
                my $actual = { host_before => { main => { %{'main::3'} }, outer => { %{$package . '::3'} } } };
                my $executed = $run->();
                $actual->{$_} = $executed->{$_} for keys %$executed;
                $actual->{host_after} = { main => { %{'main::3'} }, outer => { %{$package . '::3'} } };
                $row{runs}{$state} = $actual;
            }
        } else {
            local %{'main::3'} = ();
            my $actual = $run->();
            $row{$_} = $actual->{$_} for keys %$actual;
        }
    }
    $row{warnings} = \@warnings;
    return \%row;
}

sub normalize_eval_serials {
    my ($value) = @_;
    return [map { normalize_eval_serials($_) } @$value] if ref($value) eq 'ARRAY';
    return { map { $_ => normalize_eval_serials($value->{$_}) } keys %$value } if ref($value) eq 'HASH';
    return $value if !defined($value) || ref($value);
    $value =~ s/\(eval \d+\)/(eval SERIAL)/g;
    return $value;
}

sub projection {
    my ($row) = @_;
    my @keys = qw(metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings);
    return normalize_eval_serials({ map { $_ => $row->{$_} } grep { exists $row->{$_} } @keys });
}

my @targets = map { @{read_json($_)} } qw(tests/fixtures/hash_helper_source_isolation_perl_cases.json tests/fixtures/hash_helper_source_isolation_perl_extra_cases.json);
for my $case (@targets) {
    my $identifier = 'host_' . $case->{id};
    subtest $identifier => sub {
        my $row = observe($case, $identifier, 1);
        diag('HASH_HELPER_SOURCE_PERL ' . $identifier . ' ' . $json->encode($row));
        ok($row->{native_callable} && !$row->{build_error}, 'native parser builds');
        ok($row->{loaded} && !$row->{emission_error} && !$row->{load_error}, 'fresh module loads');
        is($row->{descriptor_error}, undef, 'descriptor resolves');
        is($row->{substitution_error}, undef, 'substitution resolves');
        is_deeply($row->{warnings}, [], 'all public channels warning-free');
        for my $state (qw(empty outer main)) {
            my $run = $row->{runs}{$state};
            is_deeply($run->{host_after}, $run->{host_before}, "$state host maps unchanged");
            for my $route (qw(native fresh)) {
                is($run->{$route . '_error'}, undef, "$state $route has no error");
                is($json->encode($run->{$route}), $json->encode($case->{expected}), "$state $route independent of host names");
                is($run->{$route . '_cursor'}, 0, "$state $route cursor retained");
            }
        }
    };
}
for my $profile (@{read_json('tests/fixtures/hash_value_result_guard_perl_profiles.json')}) {
    my $case = $profile->{case};
    my $identifier = 'policy_' . $case->{id};
    subtest $identifier => sub {
        my $row = observe($case, $identifier, 0);
        diag('HASH_HELPER_SOURCE_PERL ' . $identifier . ' ' . $json->encode($row));
        is($json->encode(projection($row)), $json->encode($profile->{expected_observation}),
            'original public source/arity/error policy retained; only eval serials normalized');
    };
}
done_testing();
