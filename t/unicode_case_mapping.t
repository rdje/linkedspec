#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use JSON::PP ();

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 unshift @INC, File::Spec->catdir($repo_root, 'perl');
}

use LinkedSpec;
use LinkedSpec::UnicodeCaseMapping;

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile($repo_root, qw(capability_conformance unicode_case_contract.json));
open my $contract_fh, '<:encoding(UTF-8)', $contract_path or die "cannot read $contract_path: $!";
my $contract = JSON::PP->new->utf8(0)->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

is($LinkedSpec::UnicodeCaseMapping::CONTRACT_ID, $contract->{contract_id}, 'Perl module contract id is pinned');
is($LinkedSpec::UnicodeCaseMapping::UNICODE_VERSION, $contract->{unicode_version}, 'Perl module Unicode version is pinned');
is($LinkedSpec::UnicodeCaseMapping::DATA_SHA256, $contract->{data_sha256}, 'Perl module logical digest is pinned');

sub spec_quote {
 my ($value) = @_;
 $value =~ s/\\/\\\\/g;
 $value =~ s/"/\\"/g;
 $value =~ s/\n/\\n/g;
 $value =~ s/\r/\\r/g;
 $value =~ s/\t/\\t/g;
 return '"'.$value.'"'
}

foreach my $fixture (@{$contract->{fixtures}}) {
 my $id = $fixture->{id};
 is(
  LinkedSpec::UnicodeCaseMapping::lowercase($fixture->{input}),
  $fixture->{lower},
  "$id direct lowercase",
 );
 is(
  LinkedSpec::UnicodeCaseMapping::uppercase($fixture->{input}),
  $fixture->{upper},
  "$id direct uppercase",
 );

 my $literal = spec_quote($fixture->{input});
 my $spec = "Top::\n"
  . " /x/ -> Done {\n"
  . "   set(array(lower_items), [$literal])\n"
  . "   lowercase_each(array(lower_items))\n"
  . "   set(array(upper_items), [$literal])\n"
  . "   uppercase_each(array(upper_items))\n"
  . "   return(array(lowercase($literal), $literal.lowercase(), uppercase($literal), "
  . "$literal.uppercase(), copy(array(lower_items)), copy(array(upper_items))))\n"
  . " }\n\n"
  . "Done::\n /x/\n";
 my $parser = LinkedSpec::Get(\$spec, parse_mode => 'consume');
 ok(ref($parser) eq 'CODE', "$id Perl runtime compiles") or next;
 my $input = 'xx';
 is_deeply(
  $parser->(\$input),
  [
   $fixture->{lower},
   $fixture->{lower},
   $fixture->{upper},
   $fixture->{upper},
   [$fixture->{lower}],
   [$fixture->{upper}],
  ],
  "$id helper, receiver, and array paths use the pinned contract",
 );
}

my $source_probe = "Top::\n /x/ -> Done { return(lowercase(\"X\")) }\n\nDone::\n /x/\n";
my $generated = LinkedSpec::emit_generated_source(\$source_probe, parse_mode => 'consume');
like(
 $generated,
 qr/use LinkedSpec::UnicodeCaseMapping \(\);/,
 'independently loadable Perl generated source declares its casing dependency',
);

done_testing;
