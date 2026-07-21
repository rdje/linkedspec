#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
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

sub canonical_digest {
 my ($value) = @_;
 return sha256_hex($JSON->encode($value))
}

sub capture_index {
 my (%args) = @_;
 my ($stdout, $stderr) = ('', '');
 local *STDOUT;
 local *STDERR;
 open STDOUT, '>', \$stdout or die "cannot capture stdout: $!";
 open STDERR, '>', \$stderr or die "cannot capture stderr: $!";
 my $source = read_bytes("$Bin/../capability_conformance/semantic_introspection/$args{fixture}.spec");
 my $index = LinkedSpec::semantic_index(
  \$source,
  logical_name => $args{logical_name},
  source_detail_ceiling => $args{ceiling},
 );
 if ($args{id} eq 'failed') {
  like($stdout, qr/CRITICAL ERROR/, 'failed construction retains its pre-existing compiler diagnostic output');
 } else {
  is($stdout, '', "$args{id} construction is stdout-silent");
 }
 is($stderr, '', "$args{id} construction is stderr-silent");
 return $index
}

my $contract = read_json("$Bin/../capability_conformance/semantic_introspection_contract.json");
my %snapshot_input = (
 graph => {fixture => 'graph', logical_name => 'graph.spec', ceiling => 'text'},
 calls => {fixture => 'calls_and_staging', logical_name => 'calls_and_staging.spec', ceiling => 'text'},
 failed => {fixture => 'failed', logical_name => 'failed.spec', ceiling => 'span'},
 privacy => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'text'},
 privacy_limited => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'identity'},
);
my %index;
sub index_for {
 my ($id) = @_;
 return $index{$id} if $index{$id};
 my %args = (%{$snapshot_input{$id}}, id => $id);
 return $index{$id} = capture_index(%args)
}

my $graph_index = index_for('graph');
ok($graph_index->can('capabilities'), 'opaque Perl semantic index exposes native capabilities');
ok($graph_index->can('query'), 'opaque Perl semantic index exposes native query');
unless ($graph_index->can('capabilities') && $graph_index->can('query')) {
 done_testing;
 exit
}

subtest 'all nineteen static canonical query responses match exact v1 digests' => sub {
 my @static_cases = grep { $_->{id} ne 'runtime_events' } @{$contract->{query_cases}};
 is(scalar(@static_cases), 19, 'runtime observation is the sole query case left to the next leaf');
 foreach my $case (@static_cases) {
  my $request = clone_plain($case->{request});
  my $before = clone_plain($request);
  my $response = index_for($case->{snapshot})->query($request);
  is_deeply($request, $before, "$case->{id} does not mutate its request");
  is($response->{ok} ? 1 : 0, $case->{expected}{ok} ? 1 : 0, "$case->{id} status is exact");
  is_deeply([map { $_->{id} } @{$response->{records}}], $case->{expected}{record_ids}, "$case->{id} record ids are exact");
  is_deeply([map { $_->{id} } @{$response->{relations}}], $case->{expected}{relation_ids}, "$case->{id} relation ids are exact");
  is_deeply([map { $_->{code} } @{$response->{diagnostics}}], $case->{expected}{diagnostic_codes}, "$case->{id} diagnostics are exact");
  is($response->{page}{complete} ? 1 : 0, $case->{expected}{complete} ? 1 : 0, "$case->{id} page completion is exact");
  is(canonical_digest($response), $case->{expected}{response_sha256}, "$case->{id} full canonical response digest is exact");
 }
};

subtest 'capabilities is the canonical capabilities operation and returns isolated data' => sub {
 my ($case) = grep { $_->{id} eq 'capabilities' } @{$contract->{query_cases}};
 my $native = $graph_index->capabilities;
 my $queried = $graph_index->query(clone_plain($case->{request}));
 is_deeply($native, $queried, 'native convenience method returns the exact neutral capabilities response');
 is(canonical_digest($native), $case->{expected}{response_sha256}, 'native capabilities response has the canonical digest');
 $native->{records}[0]{facts}{record_kinds}[0] = 'host_private_kind';
 $native->{snapshot}{source_detail_ceiling} = 'none';
 is(canonical_digest($graph_index->capabilities), $case->{expected}{response_sha256}, 'caller mutation cannot alter retained capabilities state');
};

subtest 'source privacy is structural and monotonic' => sub {
 my %case = map { $_->{id} => $_ } @{$contract->{query_cases}};
 my $none = index_for('privacy')->query(clone_plain($case{privacy_none}{request}));
 my $record = $none->{records}[0];
 is($record->{source}, undef, 'none detail removes the source reference');
 is($record->{facts}{pattern}, undef, 'none detail nulls source-sensitive regex text');
 is_deeply($record->{redactions}, ['/facts/pattern'], 'none detail lists the exact redacted fact path');

 my $text = index_for('privacy')->query(clone_plain($case{privacy_text_and_digest}{request}));
 $record = $text->{records}[0];
 is($record->{facts}{pattern}, 'é', 'text detail retains decoded regex text');
 is($record->{source}{excerpt}, '/é/', 'text detail retains the exact Unicode excerpt');
 like($record->{source}{content_digest}, qr/^sha256:[0-9a-f]{64}\z/, 'text plus digest returns the canonical source digest');

 my $forbidden = index_for('privacy_limited')->query(clone_plain($case{source_ceiling_forbidden}{request}));
 is_deeply($forbidden->{diagnostics}[0]{fields}, {requested => 'span', ceiling => 'identity'}, 'lower construction ceiling is rejected without downgrade');
};

subtest 'request validation emits portable exact diagnostics' => sub {
 my ($base_case) = grep { $_->{id} eq 'graph_list_rules' } @{$contract->{query_cases}};
 my $base = $base_case->{request};
 my @invalid;
 push @invalid, ['request_not_object', [], 'semantic_query_invalid', 'request_not_object'];
 my $unsupported = clone_plain($base); $unsupported->{contract} = 'linkedspec-semantic-query-v0';
 push @invalid, ['unsupported_contract', $unsupported, 'semantic_query_contract_unsupported', undef];
 my $missing = clone_plain($base); delete $missing->{direction};
 push @invalid, ['request_fields', $missing, 'semantic_query_invalid', 'request_fields'];
 my $page_fields = clone_plain($base); delete $page_fields->{page}{limit};
 push @invalid, ['page_fields', $page_fields, 'semantic_query_invalid', 'page_fields'];
 my $budget_fields = clone_plain($base); delete $budget_fields->{budget}{max_depth};
 push @invalid, ['budget_fields', $budget_fields, 'semantic_query_invalid', 'budget_fields'];
 my $source_fields = clone_plain($base); delete $source_fields->{source}{detail};
 push @invalid, ['source_fields', $source_fields, 'semantic_query_invalid', 'source_fields'];
 my $operation = clone_plain($base); $operation->{operation} = 'search';
 push @invalid, ['operation', $operation, 'semantic_query_invalid', 'operation'];
 my $subjects_type = clone_plain($base); $subjects_type->{subjects} = 'rule:Top';
 push @invalid, ['subjects_type', $subjects_type, 'semantic_query_invalid', 'subjects_type'];
 my $subjects_duplicate = clone_plain($base); $subjects_duplicate->{operation} = 'get'; $subjects_duplicate->{subjects} = ['rule:Top', 'rule:Top']; $subjects_duplicate->{record_kinds} = [];
 push @invalid, ['subjects_duplicate', $subjects_duplicate, 'semantic_query_invalid', 'subjects_duplicate'];
 my $record_kind = clone_plain($base); $record_kind->{record_kinds} = ['host_ast'];
 push @invalid, ['record_kind', $record_kind, 'semantic_query_invalid', 'record_kind'];
 my $relation_kind = clone_plain($base); $relation_kind->{operation} = 'relations'; $relation_kind->{subjects} = ['rule:Top']; $relation_kind->{record_kinds} = []; $relation_kind->{relation_kinds} = ['host_edge'];
 push @invalid, ['relation_kind', $relation_kind, 'semantic_query_invalid', 'relation_kind'];
 my $record_order = clone_plain($base); $record_order->{record_kinds} = ['regex_slot', 'rule'];
 push @invalid, ['record_kind_order', $record_order, 'semantic_query_invalid', 'record_kind_order'];
 my $relation_order = clone_plain($relation_kind); $relation_order->{relation_kinds} = ['contains', 'declares'];
 push @invalid, ['relation_kind_order', $relation_order, 'semantic_query_invalid', 'relation_kind_order'];
 my $direction = clone_plain($base); $direction->{direction} = 'sideways';
 push @invalid, ['direction', $direction, 'semantic_query_invalid', 'direction'];
 my $after_id = clone_plain($base); $after_id->{page}{after_id} = 7;
 push @invalid, ['after_id', $after_id, 'semantic_query_invalid', 'after_id'];
 my $page_limit = clone_plain($base); $page_limit->{page}{limit} = 0;
 push @invalid, ['page_limit', $page_limit, 'semantic_query_invalid', 'page_limit'];
 foreach my $budget_case ([max_records => 0], [max_relations => 0], [max_depth => 9]) {
  my ($key, $value) = @$budget_case;
  my $request = clone_plain($base); $request->{budget}{$key} = $value;
  push @invalid, [$key, $request, 'semantic_query_invalid', $key];
 }
 my $source_policy = clone_plain($base); $source_policy->{source}{detail} = 'full';
 push @invalid, ['source_policy', $source_policy, 'semantic_query_invalid', 'source_policy'];
 my $numeric_boolean = clone_plain($base); $numeric_boolean->{source}{include_content_digest} = 0;
 push @invalid, ['numeric_boolean', $numeric_boolean, 'semantic_query_invalid', 'source_policy'];
 my $digest_requires_text = clone_plain($base); $digest_requires_text->{source}{include_content_digest} = JSON::PP::true;
 push @invalid, ['digest_requires_text', $digest_requires_text, 'semantic_query_invalid', 'digest_requires_text'];
 my $combination = clone_plain($base); $combination->{subjects} = ['rule:Top'];
 push @invalid, ['operation_combination', $combination, 'semantic_query_invalid', 'operation_combination'];
 my $unknown = clone_plain($base); $unknown->{operation} = 'get'; $unknown->{subjects} = ['rule:Unknown']; $unknown->{record_kinds} = [];
 push @invalid, ['unknown_subject', $unknown, 'semantic_query_invalid', 'unknown_subject'];
 my $cursor = clone_plain($base); $cursor->{page}{after_id} = 'rule:Unknown';
 push @invalid, ['after_id_not_in_primary_stream', $cursor, 'semantic_query_invalid', 'after_id_not_in_primary_stream'];
 my $explain = clone_plain($base); $explain->{operation} = 'explain'; $explain->{subjects} = ['rule:Child']; $explain->{record_kinds} = [];
 push @invalid, ['not_explainable', $explain, 'semantic_query_invalid', 'not_explainable'];

 is(scalar(@invalid), 26, 'the complete request/error boundary matrix is present');
 foreach my $case (@invalid) {
  my ($label, $request, $code, $reason) = @$case;
  my $response = $graph_index->query($request);
  ok(!$response->{ok}, "$label is rejected");
  is($response->{diagnostics}[0]{code}, $code, "$label uses the exact portable diagnostic");
  is($response->{diagnostics}[0]{fields}{reason}, $reason, "$label reports the exact reason") if defined $reason;
  is_deeply($response->{records}, [], "$label returns no records");
  is_deeply($response->{relations}, [], "$label returns no relations");
 }
};

subtest 'queries are silent, clone-safe, and never recompile or expose a path' => sub {
 my ($case) = grep { $_->{id} eq 'graph_explain_entry' } @{$contract->{query_cases}};
 my ($stdout, $stderr) = ('', '');
 my $first;
 {
  no warnings qw(redefine once);
  local *LinkedSpec::Runtime::run_get = sub { die "query attempted compilation\n" };
  local *STDOUT;
  local *STDERR;
  open STDOUT, '>', \$stdout or die "cannot capture stdout: $!";
  open STDERR, '>', \$stderr or die "cannot capture stderr: $!";
  $first = $graph_index->query(clone_plain($case->{request}));
 }
 is($stdout, '', 'query emits no stdout');
 is($stderr, '', 'query emits no stderr or trace');
 is(canonical_digest($first), $case->{expected}{response_sha256}, 'query remains exact when compilation is unavailable');
 unlike($JSON->encode($first), qr{(?:/tmp/|/Users/|CODE\(|Regexp\(|SCALAR\(0x)}, 'response exposes no path or host object identity');
 $first->{records}[0]{facts}{outcome} = 'mutated';
 is(canonical_digest($graph_index->query(clone_plain($case->{request}))), $case->{expected}{response_sha256}, 'response mutation cannot alter a later query');
};

done_testing;
