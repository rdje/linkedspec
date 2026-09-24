#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../perl";
use LinkedSpec ();
use Test::More;

open my $fh, '<:encoding(UTF-8)', "$Bin/../examples/compact-hash-keys.spec"
 or die "cannot read compact hash-key example: $!";
my $source = do { local $/; <$fh> };
close $fh or die "cannot close compact hash-key example: $!";
my $expected = { stage => 7, fixed => 'stage', 'é🦀' => { stage_nested => 7 } };

for my $ending ('LF', 'CRLF') {
 my $authored = $source;
 $authored =~ s/\n/\r\n/g if $ending eq 'CRLF';
 my %ctx;
 my $parser = eval { LinkedSpec::Get(\$authored, runtime_ctx_ref => \%ctx) };
 is($@, '', "$ending book source compiles without exception");
 ok(ref($parser) eq 'CODE', "$ending book source builds a parser");
 SKIP: {
  skip 'parser did not compile', 4 unless ref($parser) eq 'CODE';
  for my $run (1, 2) {
   my $input = 'x';
   my $value = eval { $parser->(\$input) };
   is($@, '', "$ending native run $run has no exception");
   is_deeply($value, $expected, "$ending native run $run preserves evaluated and quoted keys");
  }
 }
 ok(!$ctx{last_error}, "$ending native context has no handler error");
 my $generated = eval { LinkedSpec::emit_generated_source(\$authored,
   source_identity => 'examples/compact-hash-keys.spec') };
 is($@, '', "$ending book source emits independently loadable source");
 ok(defined($generated) && length($generated), "$ending generated source is present");
 my $package = "LinkedSpec::BookHashKeys::$ending";
 my $loaded = defined($generated) && eval "package $package; $generated; 1";
 is($@, '', "$ending generated source loads without exception");
 ok($loaded, "$ending generated source loaded");
 SKIP: {
  skip 'generated source did not load', 2 unless $loaded;
  my $input = 'x';
  my $value = eval { no strict 'refs'; &{"${package}::Execute"}(\$input) };
  is($@, '', "$ending emitted book example has no exception");
  is_deeply($value, $expected, "$ending emitted example preserves evaluated and quoted keys");
 }
}

done_testing();
