#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;

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
  source_detail_ceiling => $args{ceiling},
 );
 return ($index, $stdout, $stderr)
}

my $model_path = "$Bin/../capability_conformance/semantic_introspection_model.json";
my $model = read_json($model_path);
my %expected = map { $_->{id} => $_ } @{$model->{snapshots}};

subtest 'graph static records and relations deep-equal the corrected neutral oracle' => sub {
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/graph.spec");
 my ($index) = capture_index(
  source => $source,
  logical_name => 'graph.spec',
  ceiling => 'text',
 );
 my $actual = materialize_sources($index->_static_projection);
 my $wanted = materialize_sources($expected{graph});
 delete $wanted->{id};
 delete $wanted->{fixture};
 is_deeply($actual, $wanted, 'graph rules, duplicate slots, edges, lifecycle, entry evidence, sources, ids, and order are exact');
};

subtest 'Unicode privacy projections are exact at full and limited construction ceilings' => sub {
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/privacy.spec");
 foreach my $case (
  ['privacy', 'text'],
  ['privacy_limited', 'identity'],
 ) {
  my ($snapshot_id, $ceiling) = @$case;
  my ($index) = capture_index(
   source => $source,
   logical_name => 'privacy.spec',
   ceiling => $ceiling,
  );
  my $actual = materialize_sources($index->_static_projection);
  my $wanted = materialize_sources($expected{$snapshot_id});
  delete $wanted->{id};
  delete $wanted->{fixture};
  is_deeply($actual, $wanted, "$snapshot_id retains exact UTF-8 id, span, pattern, ceiling, and source identity");
 }
};

subtest 'runtime fixture static half preserves self-indexed slot identity before observation' => sub {
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/runtime.spec");
 my ($index) = capture_index(
  source => $source,
  logical_name => 'runtime.spec',
  ceiling => 'text',
 );
 my $actual = materialize_sources($index->_static_projection);
 my $wanted = clone_plain($expected{runtime});
 my @records = grep { $_->{kind} ne 'execution' && $_->{kind} ne 'event' } @{$wanted->{records}};
 my %retained = map { $_->{id} => 1 } @records;
 my @relations = grep { $retained{$_->{from_id}} && $retained{$_->{to_id}} } @{$wanted->{relations}};
 $wanted->{records} = \@records;
 $wanted->{relations} = \@relations;
 $wanted->{snapshot}{has_execution} = JSON::PP::false;
 $wanted = materialize_sources($wanted);
 delete $wanted->{id};
 delete $wanted->{fixture};
 is_deeply($actual, $wanted, 'repetition bounds, self-indexed regex slots, edges, spans, and canonical order are exact');
};

subtest 'failed compilation normalizes the portable diagnostic and explanation exactly' => sub {
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/failed.spec");
 my ($index) = capture_index(
  source => $source,
  logical_name => 'failed.spec',
  ceiling => 'span',
 );
 my $actual = materialize_sources($index->_static_projection);
 my $wanted = materialize_sources($expected{failed});
 delete $wanted->{id};
 delete $wanted->{fixture};
 is_deeply($actual, $wanted, 'failed rule intent, unknown-rule diagnostic, decision, explanation, and source evidence are exact');
};

subtest 'projection copies are immutable and contain no host compiler objects' => sub {
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/graph.spec");
 my ($index) = capture_index(
  source => $source,
  logical_name => 'graph.spec',
  ceiling => 'text',
 );
 my $first = $index->_static_projection;
 $first->{records}[0]{facts}{definition_order}[0] = 'rule:Injected';
 $first->{source_refs}{'source_ref:rule:Top'}{logical_name} = '/tmp/private.spec';
 my $second = $index->_static_projection;
 is($second->{records}[0]{facts}{definition_order}[0], 'rule:Top', 'record mutation cannot alter retained static state');
 is($second->{source_refs}{'source_ref:rule:Top'}{logical_name}, 'graph.spec', 'source mutation cannot inject a path');
 ok(eval { $JSON->encode($second); 1 }, 'the complete private projection is canonical-JSON encodable');
 unlike($JSON->encode($second), qr/(?:CODE|Regexp|SCALAR)\(0x[0-9a-f]+\)/i, 'no coderef, compiled regex, or object identity crosses the boundary');
 ok($index->can('capabilities') && $index->can('query'), 'public capabilities/query are supplied by the later query leaf');
};

done_testing;
