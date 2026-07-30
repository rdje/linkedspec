#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use File::Spec;
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec::MCPContract ();
use LinkedSpec::MCPContractRuntime ();

my $ROOT = File::Spec->rel2abs(File::Spec->catdir($Bin, '..'));
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
 my ($relative) = @_;
 return $JSON->decode(read_bytes(File::Spec->catfile($ROOT, split m{/}, $relative)))
}

my $contract = read_json('capability_conformance/mcp_semantic_transport_contract.json');
my $corpus = read_json('capability_conformance/mcp_semantic_transport/corpus.json');
my $validator = read_json('capability_conformance/mcp_semantic_transport/validator_cases.json');
my $frames_path = File::Spec->catfile(
 $ROOT,
 qw(capability_conformance mcp_semantic_transport canonical_frames.jsonl),
);
my @frame_lines = grep { length } split /\n/, read_bytes($frames_path);
my %frame_by_id;
@frame_by_id{@{$corpus->{canonical_order}}} = map { $JSON->decode($_) } @frame_lines;

subtest 'generated binding is exact, deterministic, and repository routed' => sub {
 my $python_boundary = File::Spec->catfile($ROOT, qw(tools run_python_project_data.sh));
 is(
  system('bash', $python_boundary, 'tools/generate_perl_mcp_contract.py'),
  0,
  'generator check mode accepts the committed binding through project-local storage',
 );
 my $digests = LinkedSpec::MCPContractRuntime::source_sha256();
 foreach my $name (sort keys %{$contract->{artifacts}}) {
  my $path = File::Spec->catfile($ROOT, split m{/}, $contract->{artifacts}{$name});
  is(sha256_hex(read_bytes($path)), $digests->{$name}, "$name source digest is embedded exactly");
 }
 like(LinkedSpec::MCPContract::bundle_sha256(), qr/\A[0-9a-f]{64}\z/, 'embedded bundle has one exact SHA-256');
};

subtest 'all canonical frames are embedded with exact value identity' => sub {
 is(scalar(@frame_lines), 35, 'neutral stream still contains exactly thirty-five canonical frames');
 foreach my $id (@{$corpus->{canonical_order}}) {
  is(
   LinkedSpec::MCPContractRuntime::canonical_json(LinkedSpec::MCPContractRuntime::frame($id)),
   LinkedSpec::MCPContractRuntime::canonical_json($frame_by_id{$id}),
   "$id has exact canonical identity",
  );
 }
};

subtest 'frozen schema profile accepts and rejects the canonical classifications' => sub {
 foreach my $id (@{$validator->{frame_schema}{accepted}}) {
  ok(LinkedSpec::MCPContractRuntime::validate_frame($frame_by_id{$id}), "$id is accepted");
 }
 foreach my $row (@{$validator->{frame_schema}{rejected}}) {
  ok(!LinkedSpec::MCPContractRuntime::validate_frame($frame_by_id{$row->{id}}), "$row->{id} is rejected");
 }
 my $request = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $request->{extra} = 1;
 ok(!LinkedSpec::MCPContractRuntime::validate_named('discoverRequest', $request), 'additional envelope fields are rejected');
 $request = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $request->{id} = JSON::PP::true;
 ok(!LinkedSpec::MCPContractRuntime::validate_named('discoverRequest', $request), 'boolean request ids are rejected');
 $request->{id} = 'é' x 65;
 ok(!LinkedSpec::MCPContractRuntime::validate_named('discoverRequest', $request), 'request ids enforce the UTF-8 byte ceiling');
 my $query = LinkedSpec::MCPContractRuntime::frame('query_call_request')->{params}{arguments}{request};
 $query->{contract} = 'linkedspec-semantic-query-v2';
 ok(LinkedSpec::MCPContractRuntime::validate_named('semanticQueryRequest', $query), 'a bounded future query contract is transport-valid');
 $query->{contract} = 'a' x 128;
 ok(LinkedSpec::MCPContractRuntime::validate_named('semanticQueryRequest', $query), 'query contract admits the exact character and byte boundary');
 $query->{contract} = '';
 ok(!LinkedSpec::MCPContractRuntime::validate_named('semanticQueryRequest', $query), 'empty query contract is rejected');
 $query->{contract} = 'a' x 129;
 ok(!LinkedSpec::MCPContractRuntime::validate_named('semanticQueryRequest', $query), 'query contract rejects character overflow');
 $query->{contract} = 'é' x 65;
 ok(!LinkedSpec::MCPContractRuntime::validate_named('semanticQueryRequest', $query), 'query contract rejects UTF-8 byte overflow');
};

subtest 'contract values and builders are isolated from caller mutation' => sub {
 my $first = LinkedSpec::MCPContractRuntime::frame('discover_response_perl');
 my $before = LinkedSpec::MCPContractRuntime::canonical_json($first);
 $first->{result}{supportedVersions}[0] = 'host-mutated';
 is(
  LinkedSpec::MCPContractRuntime::canonical_json(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')),
  $before,
  'frame mutation cannot alter retained generated data',
 );
 my $contract_copy = LinkedSpec::MCPContractRuntime::contract();
 $contract_copy->{protocol_version} = 'host-mutated';
 is(LinkedSpec::MCPContractRuntime::protocol_version(), '2026-07-28', 'contract mutation cannot alter protocol state');
 my $payload = LinkedSpec::MCPContractRuntime::payload('capabilities_default');
 my $response = LinkedSpec::MCPContractRuntime::tool_success_response(101, $payload);
 $payload->{records}[0]{name} = 'host-mutated';
 isnt($response->{result}{structuredContent}{records}[0]{name}, 'host-mutated', 'tool result clones the native payload');
 is($response->{result}{content}[0]{text}, LinkedSpec::MCPContractRuntime::canonical_json($response->{result}{structuredContent}), 'text content is exact canonical structured content');
};

subtest 'production runtime has no contract-path or I/O authority' => sub {
 my $runtime = read_bytes(File::Spec->catfile($ROOT, qw(perl LinkedSpec MCPContractRuntime.pm)));
 unlike($runtime, qr/capability_conformance|mcp_semantic_transport/, 'runtime names no neutral artifact path');
 unlike($runtime, qr/\b(?:open|sysopen|opendir|readlink)\b/, 'runtime contains no filesystem I/O operation');
 my $generated = read_bytes(File::Spec->catfile($ROOT, qw(perl LinkedSpec MCPContract.pm)));
 unlike($generated, qr/\b(?:open|sysopen|opendir|readlink)\b/, 'generated binding contains data only');
};

done_testing;
