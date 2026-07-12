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
my $parser = LinkedSpec::Get(\$spec, parse_mode => 'consume');
ok(ref($parser) eq 'CODE', 'Perl reference compiles the neutral scalar numeric fixture');
my $input = 'xx';
is_deeply($parser->(\$input), $contract->{expected}, 'Perl reference matches all scalar numeric cases');

is(LinkedSpec::Numeric::scalar_number(1e20), 1e20, 'numeric SV flags preserve finite host numbers');
ok(!defined(LinkedSpec::Numeric::scalar_number('1e2')), 'string exponent remains invalid');
ok(!defined(LinkedSpec::Numeric::scalar_number(JSON::PP::true)), 'typed boolean remains nonnumeric');

my $generated = LinkedSpec::emit_generated_source(\$spec, parse_mode => 'consume');
like(
 $generated,
 qr/use LinkedSpec::Numeric \(\);/,
 'independently loadable generated source declares its numeric dependency',
);

done_testing;
