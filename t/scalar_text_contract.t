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

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile(
 $repo_root,
 qw(capability_conformance scalar_text_contract.json),
);
open my $contract_fh, '<:encoding(UTF-8)', $contract_path
 or die "cannot read $contract_path: $!";
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

is($contract->{format}, 1, 'scalar-text contract format is pinned');
is($contract->{contract_id}, 'linkedspec-scalar-text-v1', 'scalar-text contract id is pinned');
is_deeply($contract->{retired_names}, ['concat'], 'retired concat is not restored by coercion parity');
ok(!defined($contract->{policy}{codeblock}), 'codeblock is explicitly non-text');

my $spec = $contract->{spec_source};
my $parser = LinkedSpec::Get(\$spec);
ok(ref($parser) eq 'CODE', 'Perl reference compiles the neutral scalar-text fixture');
my $input = 'xx';
is_deeply($parser->(\$input), $contract->{expected}, 'Perl reference matches the neutral scalar-text fixture');

my $retired = LinkedSpec::call_spec_handler_subst('Top', 'return(concat("a", "b"))');
like($retired, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:concat/, 'retired concat remains unsupported');

done_testing;
