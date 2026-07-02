#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedParserRegistry
# Purpose: Minimal staged parse-job registry and dispatcher. This first
#          implementation supports the neutral actionir-body.spec/action_block
#          identity through a built-in adapter while preserving the registry
#          phases required by the staged parsing contract.
#------------------------------------------------------------------------------
package LinkedSpec::StagedParserRegistry;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

use constant ACTIONIR_BODY_SPEC_ID => 'actionir-body.spec';
use constant ACTIONIR_BODY_TOP_RULE => 'action_block';
use constant ACTIONIR_BODY_RESOLVED_SPEC_ID => 'builtin:actionir-body.spec';
use constant ACTIONIR_BODY_ADAPTER_SOURCE => 'linkedspec:staged-parser/actionir-body:v1';
use constant ACTIONIR_BODY_ADAPTER_DIGEST => 'sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c';
use constant SPEC_LANGUAGE_VERSION => 'spec-language-v1';
use constant HELPER_ACTION_CONTRACT_VERSION => 'actionir-v1';
use constant STAGED_PARSING_CONTRACT_VERSION => 'staged-parsing-v1';

sub execute_parse_job {
 my ($job, %opts) = @_;
 my $results = execute_parse_jobs([$job], %opts);
 die "(LinkedSpec::StagedParserRegistry::execute_parse_job) -E- missing parse result\n"
  unless ref($results) eq 'ARRAY' && @$results == 1 && ref($results->[0]) eq 'HASH';
 return $results->[0]{result}
}

sub execute_parse_jobs {
 my ($jobs, %opts) = @_;
 die "(LinkedSpec::StagedParserRegistry::execute_parse_jobs) -E- expected ARRAY job list\n"
  unless ref($jobs) eq 'ARRAY';

 my @queue = map { _normalize_job($_) } @$jobs;
 @queue = sort { _compare_jobs($a, $b) } @queue;

 my @results;
 my $queue_index = 0;
 foreach my $job (@queue) {
  my $resolved = resolve($job, %opts);
  my $loaded = load($resolved, %opts);
  my $compiled = compile($loaded, $job->{top_rule}, $opts{capability_set});
  my $result = execute($compiled, $job->{text}, job => $job);
  push @results, _parse_result_record($queue_index, $job, $resolved, $loaded, $compiled, $result);
  ++$queue_index;
 }
 return \@results
}

sub resolve {
 my ($job, %opts) = @_;
 $job = _normalize_job($job);
 if ($job->{parser_spec_id} ne ACTIONIR_BODY_SPEC_ID) {
  _die_dispatch_error('resolve', $job, "unsupported parser spec id '$job->{parser_spec_id}'");
 }
 return {
  kind => 'staged_parser_resolution',
  version => 1,
  phase => 'resolve',
  parser_spec_id => $job->{parser_spec_id},
  base_spec_id => defined($opts{base_spec_id}) ? $opts{base_spec_id} : undef,
  resolved_spec_id => ACTIONIR_BODY_RESOLVED_SPEC_ID,
  provider => 'builtin',
 }
}

sub load {
 my ($resolved, %opts) = @_;
 die "(LinkedSpec::StagedParserRegistry::load) -E- expected resolution HASH\n"
  unless ref($resolved) eq 'HASH';
 my $resolved_spec_id = $resolved->{resolved_spec_id} // '';
 if ($resolved_spec_id ne ACTIONIR_BODY_RESOLVED_SPEC_ID) {
  my $job = $opts{job};
  _die_dispatch_error('load', $job, "unsupported resolved spec id '$resolved_spec_id'");
 }
 return {
  kind => 'staged_parser_load',
  version => 1,
  phase => 'load',
  parser_spec_id => $resolved->{parser_spec_id},
  resolved_spec_id => ACTIONIR_BODY_RESOLVED_SPEC_ID,
  source_kind => 'builtin_adapter',
  adapter_contract => ACTIONIR_BODY_ADAPTER_SOURCE,
  content_digest => ACTIONIR_BODY_ADAPTER_DIGEST,
  import_graph_fingerprint => 'none',
 }
}

sub compile {
 my ($loaded, $top_rule, $capability_set) = @_;
 die "(LinkedSpec::StagedParserRegistry::compile) -E- expected load HASH\n"
  unless ref($loaded) eq 'HASH';
 $top_rule = ACTIONIR_BODY_TOP_RULE unless defined($top_rule) && length($top_rule);
 my $job = { parser_spec_id => $loaded->{parser_spec_id}, top_rule => $top_rule };
 if (($loaded->{resolved_spec_id} // '') ne ACTIONIR_BODY_RESOLVED_SPEC_ID) {
  _die_dispatch_error('compile', $job, "unsupported resolved spec id '$loaded->{resolved_spec_id}'");
 }
 if ($top_rule ne ACTIONIR_BODY_TOP_RULE) {
  _die_dispatch_error('compile', $job, "unsupported top rule '$top_rule'");
 }

 my $capabilities = _normalize_capability_set($capability_set);
 return {
  kind => 'staged_compiled_parser',
  version => 1,
  phase => 'compile',
  parser_spec_id => $loaded->{parser_spec_id},
  resolved_spec_id => $loaded->{resolved_spec_id},
  top_rule => $top_rule,
  source_kind => $loaded->{source_kind},
  capabilities => $capabilities,
  cache_key => _cache_key($loaded, $top_rule, $capabilities),
 }
}

sub execute {
 my ($compiled, $text, %opts) = @_;
 die "(LinkedSpec::StagedParserRegistry::execute) -E- expected compiled parser HASH\n"
  unless ref($compiled) eq 'HASH';
 my $job = $opts{job};
 $text = '' unless defined $text;
 if (($compiled->{resolved_spec_id} // '') ne ACTIONIR_BODY_RESOLVED_SPEC_ID
  || ($compiled->{top_rule} // '') ne ACTIONIR_BODY_TOP_RULE) {
  _die_dispatch_error('execute', $job, 'compiled parser identity is unsupported');
 }

 my $body_ast = eval {
  return LinkedSpec::OwnerDispatch::dispatch_owner_call(
   __PACKAGE__,
   'LinkedSpec::ActionIR::AST',
   'parse_action_block',
   $text,
  )
 };
 my $error = $@;
 if ($error) {
  _die_dispatch_error('execute', $job, "action block parse failed: $error", $compiled);
 }
 return $body_ast
}

sub _parse_result_record {
 my ($queue_index, $job, $resolved, $loaded, $compiled, $result) = @_;
 return {
  kind => 'staged_parse_result',
  version => 1,
  stage_depth => 1,
  queue_index => $queue_index,
  phases => [qw(resolve load compile execute)],
  job_id => $job->{job_id},
  parent_ast_path => [@{$job->{parent_ast_path}}],
  parser_spec_id => $job->{parser_spec_id},
  resolved_spec_id => $resolved->{resolved_spec_id},
  registry_provider => $resolved->{provider},
  top_rule => $job->{top_rule},
  payload_kind => $job->{payload_kind},
  source_span => _clone_plain($job->{source_span}),
  result_policy => $job->{result_policy},
  result_field => $job->{result_field},
  failure_policy => $job->{failure_policy},
  cache_key => _clone_plain($compiled->{cache_key}),
  result => $result,
 }
}

sub _cache_key {
 my ($loaded, $top_rule, $capabilities) = @_;
 my $capability_text = join(',', @$capabilities);
 my $fingerprint = join('|',
  $loaded->{resolved_spec_id},
  $loaded->{content_digest},
  $loaded->{import_graph_fingerprint},
  $top_rule,
  SPEC_LANGUAGE_VERSION,
  HELPER_ACTION_CONTRACT_VERSION,
  STAGED_PARSING_CONTRACT_VERSION,
  $capability_text,
 );
 return {
  kind => 'staged_parser_cache_key',
  version => 1,
  normalized_spec_identity => $loaded->{resolved_spec_id},
  content_digest => $loaded->{content_digest},
  import_graph_fingerprint => $loaded->{import_graph_fingerprint},
  top_rule => $top_rule,
  spec_language_version => SPEC_LANGUAGE_VERSION,
  helper_action_contract_version => HELPER_ACTION_CONTRACT_VERSION,
  staged_parsing_contract_version => STAGED_PARSING_CONTRACT_VERSION,
  backend_capabilities => [@$capabilities],
  fingerprint => $fingerprint,
 }
}

sub _normalize_job {
 my ($job) = @_;
 die "(LinkedSpec::StagedParserRegistry::_normalize_job) -E- parse job must be HASH\n"
  unless ref($job) eq 'HASH';
 my $out = _clone_plain($job);
 $out->{kind} = _require_string($out, 'kind');
 die "Invalid staged parse job: kind must be parse_job\n"
  unless $out->{kind} eq 'parse_job';
 foreach my $field (qw(job_id node_kind payload_kind text parser_spec_id top_rule result_policy result_field failure_policy)) {
  $out->{$field} = _require_string($out, $field);
 }
 $out->{diagnostic_owner} = _require_string($out, 'diagnostic_owner')
  if exists $out->{diagnostic_owner};
 $out->{parent_ast_path} = _require_string_array($out, 'parent_ast_path');
 $out->{source_span} = _require_span($out, 'source_span');
 return $out
}

sub _compare_jobs {
 my ($left, $right) = @_;
 return _path_text($left->{parent_ast_path}) cmp _path_text($right->{parent_ast_path})
  || ($left->{source_span}{start} <=> $right->{source_span}{start})
  || ($left->{source_span}{end} <=> $right->{source_span}{end})
  || ($left->{job_id} cmp $right->{job_id})
}

sub _normalize_capability_set {
 my ($capability_set) = @_;
 return ['actionir_ast_v1'] unless ref($capability_set) eq 'ARRAY';
 my %seen;
 my @capabilities;
 foreach my $capability (@$capability_set) {
  next unless defined($capability) && !ref($capability) && length($capability);
  next if $seen{$capability}++;
  push @capabilities, $capability;
 }
 return @capabilities ? \@capabilities : ['actionir_ast_v1']
}

sub _die_dispatch_error {
 my ($phase, $job, $detail, $compiled) = @_;
 $job = {} unless ref($job) eq 'HASH';
 $compiled = {} unless ref($compiled) eq 'HASH';
 my $job_id = defined($job->{job_id}) ? $job->{job_id} : '<unknown>';
 my $parent_path = ref($job->{parent_ast_path}) eq 'ARRAY' ? _path_text($job->{parent_ast_path}) : '<unknown>';
 my $parser_spec_id = defined($job->{parser_spec_id}) ? $job->{parser_spec_id} : '<unknown>';
 my $resolved_spec_id = defined($compiled->{resolved_spec_id}) ? $compiled->{resolved_spec_id} : '<unresolved>';
 my $top_rule = defined($job->{top_rule}) ? $job->{top_rule} : '<default>';
 my $payload_kind = defined($job->{payload_kind}) ? $job->{payload_kind} : '<unknown>';
 my $failure_policy = defined($job->{failure_policy}) ? $job->{failure_policy} : '<unknown>';
 my $source_span = ref($job->{source_span}) eq 'HASH'
  ? (($job->{source_span}{start} // '?').'-'.($job->{source_span}{end} // '?'))
  : '<unknown>';
 die join(' ',
  'staged parse dispatch failed:',
  "phase=$phase;",
  "job_id=$job_id;",
  "parent_ast_path=$parent_path;",
  "parser_spec_id=$parser_spec_id;",
  "resolved_spec_id=$resolved_spec_id;",
  "top_rule=$top_rule;",
  "payload_kind=$payload_kind;",
  "source_span=$source_span;",
  "failure_policy=$failure_policy;",
  "detail=$detail",
 )."\n";
}

sub _require_string {
 my ($object, $field) = @_;
 die "Invalid staged parse job: missing string field '$field'\n"
  unless exists($object->{$field}) && defined($object->{$field}) && !ref($object->{$field});
 return $object->{$field}
}

sub _require_string_array {
 my ($object, $field) = @_;
 die "Invalid staged parse job: missing array field '$field'\n"
  unless ref($object->{$field}) eq 'ARRAY';
 my @out;
 foreach my $item (@{$object->{$field}}) {
  die "Invalid staged parse job: field '$field' must contain only strings\n"
   unless defined($item) && !ref($item);
  push @out, $item;
 }
 return \@out
}

sub _require_span {
 my ($object, $field) = @_;
 die "Invalid staged parse job: missing span field '$field'\n"
  unless ref($object->{$field}) eq 'HASH';
 my %span = %{$object->{$field}};
 foreach my $key (qw(start end line_start line_end)) {
  die "Invalid staged parse job: span field '$field.$key' must be numeric\n"
   unless exists($span{$key}) && defined($span{$key}) && !ref($span{$key}) && $span{$key} =~ /\A\d+\z/;
  $span{$key} = 0 + $span{$key};
 }
 die "Invalid staged parse job: span field '$field' has invalid range\n"
  if $span{start} > $span{end} || $span{line_start} < 1 || $span{line_start} > $span{line_end};
 return \%span
}

sub _path_text {
 my ($path) = @_;
 return join('.', @$path)
}

sub _clone_plain {
 my ($value) = @_;
 return undef unless defined $value;
 return $value unless ref($value);
 if (ref($value) eq 'ARRAY') {
  return [map { _clone_plain($_) } @$value]
 }
 if (ref($value) eq 'HASH') {
  my %copy;
  foreach my $key (keys %$value) {
   $copy{$key} = _clone_plain($value->{$key});
  }
  return \%copy
 }
 return $value
}

1;
