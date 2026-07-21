#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::Compiler ();
use LinkedSpec::GeneratedSource ();

my $JSON = JSON::PP->new->canonical(1)->utf8(1);

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub read_json {
 my ($path) = @_;
 return $JSON->decode(read_bytes($path))
}

sub clone_plain {
 my ($value) = @_;
 return $JSON->decode($JSON->encode($value))
}

sub materialize_sources {
 my ($projection) = @_;
 my $copy = clone_plain($projection);
 my $source_refs = delete $copy->{source_refs};
 foreach my $record (@{$copy->{records}}) {
  $record->{source} = clone_plain($source_refs->{$record->{source}})
   if defined $record->{source};
 }
 foreach my $relation (@{$copy->{relations}}) {
  $relation->{source} = clone_plain($source_refs->{$relation->{source}})
   if defined $relation->{source};
 }
 return $copy
}

sub capture_index {
 my (%args) = @_;
 my ($stdout, $stderr) = ('', '');
 local *STDOUT;
 local *STDERR;
 open STDOUT, '>', \$stdout or die "cannot capture stdout: $!";
 open STDERR, '>', \$stderr or die "cannot capture stderr: $!";
 my $index = LinkedSpec::semantic_index(
  \$args{source},
  logical_name => $args{logical_name},
  source_detail_ceiling => 'text',
 );
 return ($index, $stdout, $stderr)
}

my $model = read_json("$Bin/../capability_conformance/semantic_introspection_model.json");
my ($expected) = grep { $_->{id} eq 'calls' } @{$model->{snapshots}};
my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/calls_and_staging.spec");
my ($index, $stdout, $stderr) = capture_index(
 source => $source,
 logical_name => 'calls_and_staging.spec',
);

subtest 'calls, bindings, shapes, staging, and generated plan deep-equal the corrected neutral oracle' => sub {
 is($stdout, '', 'construction writes no stdout');
 is($stderr, '', 'construction writes no stderr');
 my $actual = materialize_sources($index->_static_projection);
 my $wanted = materialize_sources($expected);
 delete $wanted->{id};
 delete $wanted->{fixture};
 is_deeply($actual, $wanted, 'all 22 records and 25 relations are exact');
};

subtest 'typed traversal preserves source preorder and resolution precedence' => sub {
 my $projection = $index->_static_projection;
 my @calls = sort { $a->{order} <=> $b->{order} }
  grep { $_->{kind} eq 'call' } @{$projection->{records}};
 is_deeply(
  [map { [$_->{name}, $_->{facts}{resolution_kind}, $_->{facts}{return_shape}{kind}] } @calls],
  [
   ['trim', 'helper', 'string'],
   ['normalize', 'user_function', 'string'],
   ['match_text', 'helper', 'string'],
   ['return', 'helper', 'string'],
  ],
  'function body precedes rule action and outer calls precede nested arguments',
 );
 is_deeply(
  $projection->{records}[0]{facts}{definition_order},
  ['function:normalize', 'rule:Top', 'rule:Done'],
  'authored definition order combines function and rule authorities',
 );
 my ($decision) = grep { $_->{id} eq 'decision:call:call:edge:rule:Top:0:0' }
  @{$projection->{records}};
 is($decision->{facts}{outcome}, 'function:normalize', 'registered user function wins before helper lookup');
 my @staged = grep { $_->{kind} eq 'staged_artifact' } @{$projection->{records}};
 is_deeply(
  [map { $_->{facts}{artifact_kind} } @staged],
  [qw(payload parse_job result)],
  'payload, parse job, and result remain separate ordered records',
 );
 my %relation = map { $_->{kind} => 1 } @{$projection->{relations}};
 ok($relation{consumes} && $relation{produces} && $relation{staged_by} && $relation{lowered_from},
  'staged provenance preserves every required direction');
};

subtest 'generated handler family classification has one shared owner' => sub {
 my @rows = (
  ['_default', 'default'],
  ['<none>', 'default'],
  ['OR_ACODE', 'or_acode'],
  ['AND_SINGLE_ACODE', 'and_single_acode'],
  ['AND_ACODE', 'and_acode_seq'],
  ['AND_BCODE', 'and_bcode'],
  ['OR_BCODE', 'or_bcode'],
  ['REP_ACODE', 'rep_acode'],
  ['REP_BCODE', 'rep_bcode'],
  ['REP_AND_ACODE', 'rep_and_acode'],
  ['REP_AND_BCODE', 'rep_and_bcode'],
 );
 foreach my $row (@rows) {
  my ($variant, $family) = @$row;
  is(LinkedSpec::GeneratedSource::family_for_handler_variant($variant), $family,
   "$variant maps to exact generated family");
  is(LinkedSpec::Compiler::_generated_source_family_for_variant($variant), $family,
   "compiler delegates $variant classification to the shared owner");
 }
 my $identity = LinkedSpec::GeneratedSource::contract_identity();
 is_deeply(
  $identity,
  { contract_id => 'linkedspec-generated-source-v2', format_version => 2 },
  'the projector and generator share exact artifact identity',
 );
};

subtest 'projection copies remain private plain data without host IR or generated source' => sub {
 my $first = $index->_static_projection;
 $first->{records}[0]{facts}{definition_order}[0] = 'function:Injected';
 my ($mutable_call) = grep { $_->{kind} eq 'call' } @{$first->{records}};
 $mutable_call->{facts}{return_shape}{kind} = 'number';
 my $second = $index->_static_projection;
 is($second->{records}[0]{facts}{definition_order}[0], 'function:normalize',
  'definition-order mutation cannot alter retained state');
 my $encoded = eval { $JSON->encode($second) };
 ok(defined($encoded) && !$@, 'complete calls projection is canonical-JSON encodable');
 unlike($encoded, qr/(?:CODE|Regexp|SCALAR)\(0x[0-9a-f]+\)/i,
  'coderefs, regex objects, and object identity do not cross the boundary');
 unlike($encoded, qr/"(?:body_ast|body_source|source_text)"|"kind":"action_block"/,
  'raw descriptor and ActionIR layouts do not cross the boundary');
 unlike($encoded, qr/LinkedSpecGeneratedMetadata|sub\s*\{/,
  'generated implementation source does not cross the boundary');
 ok(!$index->can('capabilities') && !$index->can('query'),
  'public capabilities/query remain owned by later leaves');
};

subtest 'function-body byte offsets normalize to Unicode character coordinates' => sub {
 my $unicode_source = <<'SPEC';
# préface
fn clean(value) { return(trim(value)) }

Top::
 /x/ -> Done { return(clean(match_text())) }

Done:
 /x/
SPEC
 my ($unicode_index, $unicode_stdout, $unicode_stderr) = capture_index(
  source => $unicode_source,
  logical_name => 'unicode_calls.spec',
 );
 is($unicode_stdout, '', 'Unicode construction writes no stdout');
 is($unicode_stderr, '', 'Unicode construction writes no stderr');
 my $projection = $unicode_index->_static_projection;
 my @calls = sort { $a->{order} <=> $b->{order} }
  grep { $_->{kind} eq 'call' } @{$projection->{records}};
 is_deeply(
  [map { $projection->{source_refs}{$_->{source}}{excerpt} } @calls],
  ['trim(value)', 'return(clean(match_text()))', 'clean(match_text())', 'match_text()'],
  'function and edge call excerpts remain exact after a multibyte prefix',
 );
 is_deeply(
  [map { $projection->{source_refs}{$_->{source}}{span}{start_column} } @calls],
  [26, 16, 23, 29],
  'source columns count Unicode scalars rather than UTF-8 bytes',
 );
 my ($function) = grep { $_->{id} eq 'function:clean' } @{$projection->{records}};
 is(
  $projection->{source_refs}{$function->{source}}{excerpt},
  'fn clean(value) { return(trim(value)) }',
  'function shell source uses descriptor character coordinates',
 );
};

subtest 'interleaved function shells cannot become synthetic rule members' => sub {
 my $interleaved_source = <<'SPEC';
Top::
 /x/ -> Done { return(clean(match_text())) }

fn clean(value) { return(trim(value)) }

Done:
 /x/
SPEC
 my ($interleaved_index, $interleaved_stdout, $interleaved_stderr) = capture_index(
  source => $interleaved_source,
  logical_name => 'interleaved_calls.spec',
 );
 is($interleaved_stdout, '', 'interleaved construction writes no stdout');
 is($interleaved_stderr, '', 'interleaved construction writes no stderr');
 my $projection = $interleaved_index->_static_projection;
 my ($spec) = grep { $_->{id} eq 'spec:0' } @{$projection->{records}};
 is_deeply(
  $spec->{facts}{definition_order},
  ['rule:Top', 'function:clean', 'rule:Done'],
  'combined definition order preserves an interleaved top-level function',
 );
 is_deeply(
  [map { $_->{id} } grep { $_->{kind} eq 'rule' } @{$projection->{records}}],
  ['rule:Top', 'rule:Done'],
  'function shell masking leaves exactly the two authored rules',
 );
 is_deeply(
  [map { $_->{id} }
   grep { $_->{kind} eq 'edge' && ($_->{owner_id} // '') eq 'rule:Top' }
   @{$projection->{records}}],
  ['edge:rule:Top:0'],
  'Top retains only its authored action edge',
 );
};

done_testing;
