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
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'key-count-result-guards.spec') };
    $result{emission_error} = error_value($@);
    my $artifact_id = ++$sequence;
    if (defined($emitted) && defined($ENV{LINKEDSPEC_KEY_COUNT_GUARD_DIR})) {
        my $path = $ENV{LINKEDSPEC_KEY_COUNT_GUARD_DIR}."/module-$artifact_id.pm.gz";
        gzip \$emitted => $path or die $GzipError;
        print 'KEY_COUNT_GUARD_INPUT '.$artifact_id.' '.$json->encode({source=>$source,emitted=>$emitted}), "\n";
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
    my $package = 'LinkedSpec::KeyCountGuardComposition'.$artifact_id;
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

sub observe_seeds {
    my ($case, $artifact_id) = @_;
    my $namespace = $case->{seed_namespace};
    die 'invalid numeric seed namespace' unless $namespace =~ /\A[0-9]+\z/;
    my $lowered = eval { LinkedSpec::call_spec_handler_subst('Value', $case->{body}) };
    my %result = (lowering_error => error_value($@));
    my $public = 'LinkedSpec::KeyCountGuardPublic'.$artifact_id;
    my $carrier = "package $public; no strict; sub Run { $lowered }";
    if (defined($ENV{LINKEDSPEC_KEY_COUNT_GUARD_DIR})) {
        gzip \$carrier => $ENV{LINKEDSPEC_KEY_COUNT_GUARD_DIR}."/public-$artifact_id.pl.gz" or die $GzipError;
        print 'KEY_COUNT_GUARD_PUBLIC '.$artifact_id.' '.$json->encode({lowered=>$lowered,carrier=>$carrier}), "\n";
    }
    my $loaded = eval "$carrier; 1";
    $result{carrier_error} = error_value($@);
    my @rows;
    for my $route ('public', 'fresh') {
        my $package = $route eq 'public' ? $public : 'LinkedSpec::KeyCountGuardComposition'.$artifact_id;
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
# TYPE-REFERENCE-BOOK.1.2.23.3.75.1 — CountKeys source/result ownership.
my $profiles = $json->decode(read_file('tests/fixtures/key_count_perl_source_profiles.json'));
my @cases = (
    @{$json->decode(read_file('tests/fixtures/key_count_result_guard_cases.json'))},
    @{$json->decode(read_file('tests/fixtures/key_count_perl_source_owner_cases.json'))},
);
for my $case (@cases) {
    my $name=$case->{id};
    next if @ARGV && !grep { $_ eq $name } @ARGV;
    $case->{expected}=$profiles->{source_domain} if $name eq 'source_domain';
    if ($name eq 'seeded_hash') {
        $case->{seed_namespace}='2';
        $case->{body}='return(count_keys({"a":1,"b":2}).set_key("k",1))';
        die 'seed body differs from retained source' unless $case->{source} eq 'Value:: I {'.$case->{body}.'}';
    }
    die 'missing authored target' unless exists($case->{expected}) || $case->{expected_error};
    subtest $name => sub {
        my $actual=observe_source($case->{source},$case->{input},$case->{rule});
        $actual->{seeds}=observe_seeds($case,$sequence) if $case->{seed_namespace};
        diag('KEY_COUNT_GUARD_ACTUAL '.$name.' '.$json->encode($actual));
        ok($actual->{native_callable} && !$actual->{build_error}, 'native source builds');
        ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'actual fresh module loads');
        for my $route ('native','fresh') {
            if ($case->{expected_error}) {
                my $error=$actual->{$route.'_error'};
                is(ref($error),'HASH',$route.' structured needed error');
                like($json->encode($error),qr/\Q$case->{expected_error}\E/,$route.' required binding error');
                is(ref($error) eq 'HASH' ? $error->{stage} : undef,$route eq 'native' ? 'rule_handler_eval' : 'execute_generated',$route.' execution error stage');
                ok(!defined($actual->{$route}),$route.' later default cannot mask source error');
            } else {
                ok(!$actual->{$route.'_error'},$route.' executes without error');
                is($json->encode($actual->{$route}),$json->encode($case->{expected}),$route.' exact values/kinds/effects');
            }
            is($actual->{$route.'_cursor'},0,$route.' cursor unchanged');
        }
        is_deeply($actual->{warnings},[],'build/load/run warning-free');
        ok(!$actual->{descriptor_error},'descriptor resolves');
        my $meta=$actual->{metadata};
        is($meta->{raw_perl_dependency_count},0,'no raw dependency');
        is($meta->{canonical_action_ir_fallback_count},0,'no fallback executor');
        my $unresolved=$case->{expected_unresolved} // [];
        is($meta->{unresolved_helper_count},scalar(@$unresolved),'exact current unresolved profile');
        is_deeply($meta->{unresolved_helpers},$unresolved,'exact unresolved names');
        is($meta->{language_agnostic_action_ir_ready},@$unresolved ? 0 : 1,'current admission profile preserved');
        if ($case->{seed_namespace}) {
            my $seeds=$actual->{seeds};
            ok(!$seeds->{lowering_error} && !$seeds->{carrier_error},'actual public carrier lowers/loads');
            is(scalar(@{$seeds->{rows}}),6,'public/emitted seed population complete');
            for my $row (@{$seeds->{rows}}) {
                is($json->encode($row->{value}),'null',$row->{route}.' '.$row->{seed}.' rejects Number2 Hash consumer');
                ok(!$row->{error},'seed rejection is not an exception');
                is_deeply($row->{warnings},[],'seed execution warning-free');
                is_deeply($row->{host_after},$row->{host_before},'localized host data unchanged');
            }
        }
    };
}
done_testing();
