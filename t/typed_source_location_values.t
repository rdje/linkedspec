#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec::SourceLocation ();

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'typed_source_location_contract.json',
);
my $contract = slurp_json($contract_path);
is(
 $contract->{contract_id},
 'linkedspec-typed-source-location-v1',
 'loads the frozen typed source-location contract',
);

my %decoded_sources = map {
 ($_->{id} => $_->{decoded_text})
} @{$contract->{sources}};
my $authority = LinkedSpec::SourceLocation->new(sources => \%decoded_sources);
isa_ok($authority, 'LinkedSpec::SourceLocation', 'decoded-source authority');

my $context = {
 rule_role       => 'typed_source_fixture_rule',
 invocation_role => 'typed_source_fixture_invocation',
};

my %position_by_key;
sub position_for {
 my ($source_id, $offset) = @_;
 my $key = "$source_id\0$offset";
 return $position_by_key{$key} ||= $authority->position(
  source_id => $source_id,
  offset    => $offset,
  context   => $context,
 )
}

subtest 'all neutral positions retain scalar identity and derive exact coordinates' => sub {
 for my $fixture (@{$contract->{position_conversions}}) {
  my $position = position_for($fixture->{source_id}, $fixture->{offset});
  isa_ok($position, 'LinkedSpec::SourceLocation::Position', $fixture->{id});
  is_deeply(
   $position->as_record,
   {
    source_id => $fixture->{source_id},
    offset    => $fixture->{offset},
   },
   "$fixture->{id} exposes only source identity and scalar offset",
  );
  is_deeply(
   $authority->coordinates($position, context => $context),
   {
    source_id        => $fixture->{source_id},
    offset           => $fixture->{offset},
    line             => $fixture->{line},
    column           => $fixture->{column},
    utf8_byte_offset => $fixture->{utf8_byte_offset},
   },
   "$fixture->{id} derives exact line, column, and UTF-8 byte evidence",
  );
 }

 my $detached = position_for('unicode', 1)->as_record;
 $detached->{offset} = 99;
 is(
  position_for('unicode', 1)->as_record->{offset},
  1,
  'mutating a detached position record cannot mutate the immutable value',
 );
};

my %span_by_id;
subtest 'all neutral direct spans materialize on demand without embedded text' => sub {
 for my $fixture (@{$contract->{direct_spans}}) {
  my $span = $authority->direct_span(
   start      => position_for($fixture->{source_id}, $fixture->{start}),
   end        => position_for($fixture->{source_id}, $fixture->{end}),
   provenance => $fixture->{provenance},
   context    => $context,
  );
  $span_by_id{$fixture->{id}} = $span;
  isa_ok($span, 'LinkedSpec::SourceLocation::Span', $fixture->{id});
  is_deeply(
   $span->as_record,
   {
    source_id  => $fixture->{source_id},
    start      => $fixture->{start},
    end        => $fixture->{end},
    provenance => $fixture->{provenance},
   },
   "$fixture->{id} exposes only identity, scalar bounds, and provenance",
  );
  is(
   $authority->materialize($span, context => $context),
   $fixture->{expected_text},
   "$fixture->{id} materializes exact decoded text through the authority",
  );
 }
};

subtest 'derived text preserves its ordered direct-span provenance' => sub {
 for my $fixture (@{$contract->{derived_text_cases}}) {
  my @spans = map { $span_by_id{$_} } @{$fixture->{span_ids}};
  my $derived = $authority->derived_text(
   policy  => $fixture->{policy},
   spans   => \@spans,
   context => $context,
  );
  isa_ok($derived, 'LinkedSpec::SourceLocation::DerivedText', $fixture->{id});
  is_deeply(
   $derived->as_record,
   {
    policy => 'concatenate_in_order',
    spans  => [map { $_->as_record } @spans],
   },
   "$fixture->{id} exposes policy plus the ordered span sequence",
  );
  is(
   $authority->materialize($derived, context => $context),
   $fixture->{expected_text},
   "$fixture->{id} materializes exact derived text",
  );
 }
};

my %diagnostic_by_id = map {
 ($_->{id} => $_)
} @{$contract->{diagnostics}};

sub capture_error {
 my ($label, $operation) = @_;
 my $ok = eval {
  $operation->();
  1
 };
 ok(!$ok, "$label rejects the invalid value");
 my $error = $@;
 isa_ok($error, 'LinkedSpec::SourceLocation::Error', "$label error");
 return $error
}

sub verify_error {
 my ($diagnostic_id, $error, $expected_context) = @_;
 my $diagnostic = $diagnostic_by_id{$diagnostic_id};
 is($error->{code}, $diagnostic->{code}, "$diagnostic_id uses the exact portable code");
 is($error->{phase}, $diagnostic->{phase}, "$diagnostic_id uses the exact portable phase");
 for my $field (@{$diagnostic->{required_context}}) {
  ok(exists($error->{$field}), "$diagnostic_id carries required context $field");
 }
 for my $field (keys %$expected_context) {
  is($error->{$field}, $expected_context->{$field}, "$diagnostic_id preserves $field");
 }
 for my $forbidden (qw(decoded_text source_text path match parser_state host_reference)) {
  ok(!exists($error->{$forbidden}), "$diagnostic_id does not leak $forbidden");
 }
}

subtest 'the four immutable-value diagnostics are exact and privacy preserving' => sub {
 my $source_mismatch = capture_error('source mismatch', sub {
  $authority->direct_span(
   start      => position_for('unicode', 0),
   end        => position_for('ascii', 1),
   provenance => 'input',
   context    => $context,
  )
 });
 verify_error(
  'source_mismatch',
  $source_mismatch,
  {
   %$context,
   source_id       => 'unicode',
   other_source_id => 'ascii',
  },
 );

 my $out_of_range = capture_error('position out of range', sub {
  $authority->position(
   source_id => 'unicode',
   offset    => 5,
   context   => $context,
  )
 });
 verify_error(
  'position_out_of_range',
  $out_of_range,
  {
   %$context,
   source_id       => 'unicode',
   position_offset => 5,
   source_length   => 4,
  },
 );

 my $reversed = capture_error('reversed span', sub {
  $authority->direct_span(
   start      => position_for('unicode', 2),
   end        => position_for('unicode', 1),
   provenance => 'capture',
   context    => $context,
  )
 });
 verify_error(
  'reversed_span',
  $reversed,
  {
   %$context,
   source_id    => 'unicode',
   start_offset => 2,
   end_offset   => 1,
  },
 );

 my $foreign_authority = LinkedSpec::SourceLocation->new(
  sources => {foreign => 'foreign text'},
 );
 my $foreign_context = {
  rule_role       => $context->{rule_role},
  invocation_role => $context->{invocation_role},
 };
 my $foreign_span = $foreign_authority->direct_span(
  start      => $foreign_authority->position(
   source_id => 'foreign',
   offset    => 0,
   context   => $foreign_context,
  ),
  end        => $foreign_authority->position(
   source_id => 'foreign',
   offset    => 1,
   context   => $foreign_context,
  ),
  provenance => 'input',
  context    => $foreign_context,
 );
 my $invalid_provenance = capture_error('invalid derived provenance', sub {
  $authority->derived_text(
   policy  => 'concatenate_in_order',
   spans   => [$foreign_span],
   context => $context,
  )
 });
 verify_error(
  'invalid_derived_provenance',
  $invalid_provenance,
  {
   %$context,
   provenance_index => 0,
   source_id        => 'foreign',
  },
 );
};

subtest 'the authority snapshots decoded input instead of retaining caller state' => sub {
 my %owned_source = (owned => 'Aβ');
 my $owned_authority = LinkedSpec::SourceLocation->new(sources => \%owned_source);
 $owned_source{owned} = 'changed';
 my $owned_context = {
  rule_role       => 'snapshot_rule',
  invocation_role => 'snapshot_invocation',
 };
 my $owned_span = $owned_authority->direct_span(
  start => $owned_authority->position(
   source_id => 'owned',
   offset    => 0,
   context   => $owned_context,
  ),
  end => $owned_authority->position(
   source_id => 'owned',
   offset    => 2,
   context   => $owned_context,
  ),
  provenance => 'input',
  context    => $owned_context,
 );
 is(
  $owned_authority->materialize($owned_span, context => $owned_context),
  'Aβ',
  'later caller mutation cannot change authority-owned decoded text',
 );
};

done_testing();
