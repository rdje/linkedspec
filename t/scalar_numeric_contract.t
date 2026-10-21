#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use JSON::PP ();

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 unshift @INC, File::Spec->catdir($repo_root, 'perl');
}

use LinkedSpec;
use LinkedSpec::Numeric ();

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile(
 $repo_root,
 qw(capability_conformance scalar_numeric_contract.json),
);
open my $contract_fh, '<:encoding(UTF-8)', $contract_path
 or die "cannot read $contract_path: $!";
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

is($contract->{format}, 1, 'scalar numeric contract format is pinned');
is($contract->{contract_id}, $LinkedSpec::Numeric::CONTRACT_ID, 'Perl adapter contract id is pinned');
is(scalar(@{$contract->{cases}}), 55, 'contract case count is pinned');

my $spec = $contract->{spec_source};
my $parser = LinkedSpec::Get(\$spec);
ok(ref($parser) eq 'CODE', 'Perl reference compiles the neutral scalar numeric fixture');
my $input = 'xx';
is_deeply($parser->(\$input), $contract->{expected}, 'Perl reference matches all scalar numeric cases');

is(LinkedSpec::Numeric::scalar_number(1e20), 1e20, 'numeric SV flags preserve finite host numbers');
ok(!defined(LinkedSpec::Numeric::scalar_number('1e2')), 'string exponent remains invalid');
ok(!defined(LinkedSpec::Numeric::scalar_number(JSON::PP::true)), 'typed boolean remains nonnumeric');

my $generated = LinkedSpec::emit_generated_source(\$spec);
like(
 $generated,
 qr/use LinkedSpec::Numeric \(\);/,
 'independently loadable generated source declares its numeric dependency',
);

subtest 'scalar numeric calls and receivers compose inside deferred codeblocks' => sub {
    my @cases;
    foreach my $name (qw(cases effects stability receiver-invalid terminals pipelines sort-kinds)) {
        my $path = File::Spec->catfile($repo_root, 'tests', 'numeric-codeblocks', $name . '.json');
        open my $fh, '<:raw', $path or die "Could not read $path: $!";
        my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fh> });
        close $fh or die "Could not close $path: $!";
        push @cases, @{$fixture->{cases}};
    }
    my $fixture = {cases => \@cases};
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $index = 0;
    foreach my $case (@{$fixture->{cases}}) {
        my $package = 'NumericCodeblockContract' . $index++;
        subtest $case->{id} => sub {
            my $source = $case->{source}
                // (($case->{functions} // '') . "Top: /x/\n I { $case->{body} }\n");
            my (%context, @warnings, $actual, $native_ok, $native_error, $output);
            {
                open my $capture, '>', \$output or die "Capture diagnostic output: $!";
                local *STDOUT = $capture;
                local $SIG{__WARN__} = sub { push @warnings, @_ };
                $native_ok = eval {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                    die "Native parser did not build\n" unless ref($parser) eq 'CODE';
                    my $input = 'x';
                    $actual = $parser->(\$input);
                    1;
                };
                $native_error = $@ unless $native_ok;
            }
            ok($native_ok, 'native parser builds and completes its public invocation');
            diag($native_error) unless $native_ok;
            my ($emitted, $generated, $generated_error, $generated_ok);
            {
                local $SIG{__WARN__} = sub { push @warnings, @_ };
                $generated_ok = eval {
                    $emitted = LinkedSpec::emit_generated_source(
                        \$source, source_identity => 'numeric-codeblocks.spec',
                    );
                    eval "package $package; $emitted; 1" or die $@;
                    my $input = 'x';
                    no strict 'refs';
                    $generated = &{$package . '::Execute'}(\$input);
                    1;
                };
                $generated_error = $@ unless $generated_ok;
            }
            ok(defined($emitted) && length($emitted), 'fresh standalone parser source emits');
            is_deeply(\@warnings, [], 'native and standalone routes preserve warning discipline');
            if (exists $case->{expected}) {
                ok(!defined($context{last_error}), 'native execution has no runtime error');
                is($json->encode($actual), $json->encode($case->{expected}), 'native contract value');
                ok($generated_ok, 'fresh standalone parser loads and executes');
                diag($generated_error) unless $generated_ok;
                is($json->encode($generated), $json->encode($case->{expected}), 'standalone contract value');
                is($output // '', '', 'healthy native invocation emits no diagnostic output');
            } else {
                is($actual, undef, 'native invocation reports no successful value');
                my $detail = $context{last_error}{detail};
                isa_ok($detail, 'LinkedSpec::CodeblockRuntime::Error', 'native typed cause');
                ok(!$generated_ok, 'standalone invocation rejects the invalid call');
                is(ref($generated_error), 'HASH', 'standalone public error envelope');
                is($generated_error->{code}, 'generated_execution_failed', 'standalone execution stage');
                my $cause = $generated_error->{detail};
                isa_ok($cause, 'LinkedSpec::CodeblockRuntime::Error', 'standalone typed cause');
                foreach my $key (sort keys %{$case->{error}}) {
                    is_deeply($detail->{$key}, $case->{error}{$key}, "native diagnostic $key");
                    is_deeply($cause->{$key}, $case->{error}{$key}, "standalone diagnostic $key");
                }
            }
        };
    }
};

done_testing;
