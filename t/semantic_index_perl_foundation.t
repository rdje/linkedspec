#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Encode qw(decode FB_CROAK LEAVE_SRC);
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(reftype);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;

sub fixture_bytes {
 my ($name) = @_;
 my $path = "$Bin/../capability_conformance/semantic_introspection/$name.spec";
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub capture_constructor {
 my ($operation) = @_;
 my ($stdout, $stderr) = ('', '');
 local *STDOUT;
 local *STDERR;
 open STDOUT, '>', \$stdout or die "cannot capture stdout: $!";
 open STDERR, '>', \$stderr or die "cannot capture stderr: $!";
 my $result;
 my $ok = eval {
  $result = $operation->();
  1;
 };
 return ($ok ? 1 : 0, $result, $@, $stdout, $stderr)
}

sub assert_constructor_error {
 my ($label, $operation, $stage, $code) = @_;
 my ($ok, undef, $error) = capture_constructor($operation);
 ok(!$ok, "$label is rejected");
 isa_ok($error, 'LinkedSpec::SemanticIndex::Error', "$label returns a typed error");
 is($error->stage, $stage, "$label reports the exact stage");
 is($error->code, $code, "$label reports the exact code");
 return $error
}

subtest 'opaque constructor normalizes raw graph bytes and compiles once without execution' => sub {
 ok(!$INC{'LinkedSpec/SemanticIndex.pm'}, 'semantic-index owner is lazy before first construction');
 my $source = fixture_bytes('graph');
 my $original = $source;
 my $index = LinkedSpec::semantic_index(
  \$source,
  logical_name => 'graph.spec',
  source_detail_ceiling => 'text',
 );
 isa_ok($index, 'LinkedSpec::SemanticIndex', 'constructor returns the opaque native index');
 ok($INC{'LinkedSpec/SemanticIndex.pm'}, 'first construction lazy-loads the semantic-index owner');
 is(reftype($index), 'SCALAR', 'index storage is opaque rather than a caller-visible compiler hash');
 is($source, $original, 'construction does not mutate caller source bytes');
 is_deeply(
  $index->_foundation_snapshot,
  {
   id => 'snapshot:0',
   state => 'compiled',
   has_execution => 0,
   source_detail_ceiling => 'text',
   content_digest_available => 1,
  },
  'compiled snapshot metadata is exact and does not claim execution',
 );
 is_deeply(
  $index->_foundation_source_identity,
  {
   source_id => 'source:0',
   logical_name => 'graph.spec',
   byte_length => 128,
   character_length => 128,
   content_digest => 'sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf',
  },
  'source identity uses only caller logical name and exact canonical bytes',
 );
 ok($index->_foundation_compiled_authority_present, 'compiled descriptor authority remains private and available');
 is($index->_foundation_compilation_error, undef, 'compiled outcome has no failure payload');

 my $snapshot_copy = $index->_foundation_snapshot;
 $snapshot_copy->{state} = 'mutated';
 my $source_copy = $index->_foundation_source_identity;
 $source_copy->{logical_name} = '/tmp/leak.spec';
 is($index->_foundation_snapshot->{state}, 'compiled', 'returned snapshot data cannot mutate the index');
 is($index->_foundation_source_identity->{logical_name}, 'graph.spec', 'returned source data cannot inject a path');

 $source = "Broken:\n";
 is($index->_foundation_source_identity->{byte_length}, 128, 'later caller mutation cannot alter captured source');
};

subtest 'source map locks exact byte, line, scalar-column, and ordered-occurrence coordinates' => sub {
 my $source = fixture_bytes('graph');
 my $index = LinkedSpec::semantic_index(
  \$source,
  logical_name => 'graph.spec',
  source_detail_ceiling => 'span',
 );
 is_deeply(
  $index->_foundation_span_for_bytes(0, 8),
  {start_byte => 0, end_byte => 8, start_line => 1, start_column => 1, end_line => 1, end_column => 9},
  'ASCII rule header span is exact',
 );
 is_deeply(
  $index->_foundation_span_for_bytes(85, 107),
  {start_byte => 85, end_byte => 107, start_line => 4, start_column => 2, end_line => 4, end_column => 24},
  'lifecycle span is exact',
 );

 my (@starts, $cursor);
 $cursor = 0;
 for (1 .. 4) {
  my $span = $index->_foundation_locate_exact('/a/', after_byte => $cursor);
  push @starts, $span->{start_byte};
  $cursor = $span->{end_byte};
 }
 is_deeply(\@starts, [10, 47, 119, 124], 'ordered exact lookup distinguishes all duplicate source occurrences');
 is($index->_foundation_locate_exact('/a/', after_byte => $cursor), undef, 'ordered lookup ends deterministically');
 is($index->_foundation_source_identity->{content_digest}, undef, 'span ceiling does not expose a content digest');
};

subtest 'raw and decoded Unicode sources converge on canonical UTF-8 coordinates' => sub {
 my $raw_source = fixture_bytes('privacy');
 my $raw_index = LinkedSpec::semantic_index(
  \$raw_source,
  logical_name => 'privacy.spec',
  source_detail_ceiling => 'text',
 );
 is($raw_index->_foundation_snapshot->{state}, 'compiled', 'raw strict UTF-8 privacy source is decoded before Get');
 is_deeply(
  $raw_index->_foundation_span_for_bytes(0, 6),
  {start_byte => 0, end_byte => 6, start_line => 1, start_column => 1, end_line => 1, end_column => 6},
  'Unicode rule header uses byte offsets and scalar columns',
 );
 is($raw_index->_foundation_excerpt_for_bytes(0, 6), "Töp::", 'Unicode rule excerpt is exact decoded text');
 is_deeply(
  $raw_index->_foundation_span_for_bytes(8, 12),
  {start_byte => 8, end_byte => 12, start_line => 2, start_column => 2, end_line => 2, end_column => 5},
  'Unicode regex uses byte offsets and scalar columns',
 );
 is($raw_index->_foundation_excerpt_for_bytes(8, 12), "/é/", 'Unicode regex excerpt is exact decoded text');

 my $decoded_source = decode('UTF-8', fixture_bytes('privacy'), FB_CROAK | LEAVE_SRC);
 my $decoded_index = LinkedSpec::semantic_index(
  \$decoded_source,
  logical_name => 'privacy.spec',
  source_detail_ceiling => 'text',
 );
 is_deeply(
  $decoded_index->_foundation_source_identity,
  $raw_index->_foundation_source_identity,
  'decoded character input and strict byte input produce identical source identity',
 );
 is_deeply(
  $decoded_index->_foundation_span_for_bytes(8, 12),
  $raw_index->_foundation_span_for_bytes(8, 12),
  'decoded character input and strict byte input produce identical spans',
 );

 my (undef, undef, $split_error) = capture_constructor(sub {
  $raw_index->_foundation_span_for_bytes(2, 3)
 });
 like("$split_error", qr/byte range splits a UTF-8 character/, 'mid-codepoint ranges are rejected');
};

subtest 'failed compilation remains an immutable source-aware outcome' => sub {
 my $source = fixture_bytes('failed');
 my ($ok, $index, $constructor_error) = capture_constructor(sub {
  LinkedSpec::semantic_index(
   \$source,
   logical_name => 'failed.spec',
   source_detail_ceiling => 'span',
  )
 });
 ok($ok, 'language compilation failure still constructs a semantic index') or diag("$constructor_error");
 isa_ok($index, 'LinkedSpec::SemanticIndex', 'failed outcome uses the same opaque native type');
 is_deeply(
  $index->_foundation_snapshot,
  {
   id => 'snapshot:0',
   state => 'failed_compilation',
   has_execution => 0,
   source_detail_ceiling => 'span',
   content_digest_available => 0,
  },
  'failed snapshot metadata is exact',
 );
 ok(!$index->_foundation_compiled_authority_present, 'failed outcome exposes no compiled descriptor authority');
 my $error = $index->_foundation_compilation_error;
 is($error->{code}, 'bare_edge_target_undefined', 'structured compiler code is preserved');
 is($error->{stage}, 'normalize_edges', 'structured compiler stage is preserved');
 is($error->{summary}, "Bare edge in rule 'Top' targets undefined rule 'Missing'", 'structured compiler summary is preserved');
 is_deeply(
  $index->_foundation_span_for_bytes(6, 13),
  {start_byte => 6, end_byte => 13, start_line => 2, start_column => 2, end_line => 2, end_column => 9},
  'source mapping remains available after compilation failure',
 );
 is($index->_foundation_excerpt_for_bytes(6, 13), 'Missing', 'failed target excerpt remains exact internally');

 $error->{code} = 'mutated';
 is($index->_foundation_compilation_error->{code}, 'bare_edge_target_undefined', 'returned failure data cannot mutate the index');
 my $safe_projection = {
  snapshot => $index->_foundation_snapshot,
  source => $index->_foundation_source_identity,
  error => $index->_foundation_compilation_error,
 };
 ok(eval { JSON::PP->new->canonical(1)->encode($safe_projection); 1 }, 'foundation projections contain no host objects');
};

subtest 'constructor validation is strict and typed before compilation' => sub {
 my $source = fixture_bytes('graph');
 assert_constructor_error(
  'non-scalar source reference',
  sub { LinkedSpec::semantic_index({}, logical_name => 'graph.spec', source_detail_ceiling => 'text') },
  'validate_source',
  'semantic_index_invalid_source',
 );
 assert_constructor_error(
  'odd option list',
  sub { LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', 'source_detail_ceiling') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 assert_constructor_error(
  'missing logical name',
  sub { LinkedSpec::semantic_index(\$source, source_detail_ceiling => 'text') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 assert_constructor_error(
  'missing source ceiling',
  sub { LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 assert_constructor_error(
  'unknown option',
  sub { LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text', source_path => '/tmp/private.spec') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 assert_constructor_error(
  'invalid source ceiling',
  sub { LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'full') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 assert_constructor_error(
  'multiline logical name',
  sub { LinkedSpec::semantic_index(\$source, logical_name => "private\npath", source_detail_ceiling => 'text') },
  'validate_options',
  'semantic_index_invalid_option',
 );
 my $malformed = "\xC3\x28";
 my $utf8_error = assert_constructor_error(
  'malformed UTF-8 source',
  sub { LinkedSpec::semantic_index(\$malformed, logical_name => 'bad.spec', source_detail_ceiling => 'text') },
  'decode_source',
  'semantic_index_invalid_utf8',
 );
 like("$utf8_error", qr/semantic_index_invalid_utf8/, 'typed UTF-8 failure string is stable');
};

done_testing;
