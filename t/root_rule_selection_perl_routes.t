#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir);
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/../perl";

use LinkedSpec;
use LinkedSpec::GeneratedSource ();
use LinkedSpec::SpecLoader ();
use LinkedSpec::Trace ();

my $marked_source = <<'SPEC';
Earlier:
 /x/ -> EarlierDone { return("earlier") }
EarlierDone: /x/
Marked::
 /x/ -> MarkedDone { return("marked") }
MarkedDone: /x/
Later::
 /x/ -> LaterDone { return("later") }
LaterDone: /x/
SPEC

my $markerless_source = <<'SPEC';
First:
 /x/ -> FirstDone { return("first") }
FirstDone: /x/
Second:
 /x/ -> SecondDone { return("second") }
SecondDone: /x/
SPEC

my $generated_package_counter = 0;

sub write_text {
 my ($path, $text) = @_;
 open my $fh, '>:encoding(UTF-8)', $path or die "cannot write $path: $!";
 print {$fh} $text;
 close $fh or die "cannot close $path: $!";
 return $path
}

sub read_text {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 my $text = do { local $/; <$fh> };
 close $fh or die "cannot close $path: $!";
 return $text
}

sub load_generated_source {
 my ($source, $suffix) = @_;
 my $package = 'LinkedSpec::RootRuleRoutes::Generated'
  . ++$generated_package_counter . $suffix;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, "$suffix generated source loads independently") or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  get => *{"${package}::Get"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
 }
}

sub generated_role_cases {
 my ($generated) = @_;
 return (
  [Execute => sub {
   my ($input_ref, $options) = @_;
   return $generated->{execute}->($input_ref, $options)
  }],
  [ExecuteWithTrace => sub {
   my ($input_ref, $options) = @_;
   return $generated->{execute_with_trace}->(
    $input_ref,
    { trace_level => 'none' },
    $options,
   )
  }],
  [Get => sub {
   my ($input_ref, $options) = @_;
   return $generated->{get}->($input_ref, $options)
  }],
 )
}

sub invoke_generated {
 my ($callback, $selector) = @_;
 my $input = 'x';
 my $options = defined($selector) ? { top_rule => $selector } : undef;
 return $callback->(\$input, $options)
}

sub generated_failure {
 my ($callback) = @_;
 my $ok = eval {
  $callback->();
  1
 };
 my $error = $@;
 ok(!$ok, 'generated request fails');
 ok(ref($error) eq 'HASH', 'generated failure is a structured hash');
 return $error
}

subtest 'file-loaded parsers preserve selection and structured context' => sub {
 my $scratch = tempdir('linkedspec-root-routes-XXXXXX', TMPDIR => 1, CLEANUP => 1);
 my $marked_path = write_text(File::Spec->catfile($scratch, 'marked.spec'), $marked_source);
 my $markerless_path = write_text(File::Spec->catfile($scratch, 'markerless.spec'), $markerless_source);

 my %default_ctx;
 my $default_parser = LinkedSpec::get_parser($marked_path, runtime_ctx_ref => \%default_ctx);
 ok(ref($default_parser) eq 'CODE', 'get_parser loads marked source');
 my $default_input = 'x';
 is($default_parser->(\$default_input), 'marked', 'loaded default selects the first marker');
 is($default_ctx{top_rule}, 'Marked', 'loaded runtime context records the effective marker');
 is($default_ctx{spec_path}, $marked_path, 'loaded runtime context retains resolved source identity');

 my %explicit_ctx;
 my $explicit_parser = LinkedSpec::get_parser(
  $marked_path,
  top_rule => 'Earlier',
  runtime_ctx_ref => \%explicit_ctx,
 );
 my $explicit_input = 'x';
 is($explicit_parser->(\$explicit_input), 'earlier', 'loaded explicit ordinary rule beats markers');
 is($explicit_ctx{top_rule}, 'Earlier', 'loaded context records the effective explicit rule');

 my %unknown_ctx;
 my $unknown_parser = LinkedSpec::get_parser(
  $marked_path,
  top_rule => 'Missing',
  runtime_ctx_ref => \%unknown_ctx,
 );
 ok(ref($unknown_parser) eq 'CODE', 'loaded unknown selector preserves compile-before-input ordering');
 my $unknown_input = 'x';
 my $unknown_diagnostic = '';
 open my $unknown_capture, '>', \$unknown_diagnostic
  or die "cannot capture unknown-selector diagnostic: $!";
 my $unknown_ok;
 {
  local *STDOUT = $unknown_capture;
  local *STDERR = $unknown_capture;
  $unknown_ok = eval {
   $unknown_parser->(\$unknown_input);
   1
  };
 }
 ok(!$unknown_ok, 'loaded unknown selector fails before a handler runs');
 is($unknown_ctx{last_error}{stage}, 'select_entry_rule', 'loaded failure retains selection stage');
 is($unknown_ctx{last_error}{code}, 'entry_rule_not_found', 'loaded failure retains portable code');
 is($unknown_ctx{last_error}{entry_rule}, 'Missing', 'loaded failure attributes requested missing rule');
 is($unknown_ctx{spec_path}, $marked_path, 'loaded failure retains resolved source identity');

 my %markerless_ctx;
 my $markerless_parser = LinkedSpec::get_parser(
  $markerless_path,
  runtime_ctx_ref => \%markerless_ctx,
 );
 my $markerless_input = 'x';
 is($markerless_parser->(\$markerless_input), 'first', 'loaded markerless source selects its first rule');
 is($markerless_ctx{top_rule}, 'First', 'loaded markerless context records the first-rule fallback');

 my $loaded = LinkedSpec::SpecLoader::load_and_compile_spec(
  LinkedSpec::SpecLoader::path_request('marked.spec'),
  LinkedSpec::SpecLoader::load_options(cwd => $scratch),
  { top_rule => 'Earlier' },
 );
 my $spec_loader_input = 'x';
 is($loaded->compiled->(\$spec_loader_input), 'earlier', 'portable spec loader forwards explicit selection');
 is($loaded->runtime_ctx->{top_rule}, 'Earlier', 'portable spec loader context records effective selection');
};

subtest 'generated metadata preserves authored entry identity beside the family plan' => sub {
 my $identity = 'root-selection/marked.spec';
 my $source = LinkedSpec::emit_generated_source(
  \$marked_source,
  source_identity => $identity,
 );
 my $captured = '';
 my $captured_result = LinkedSpec::Get(
  \$marked_source,
  generate_only => 1,
  dump_parser_source => 1,
  parser_source_ref => \$captured,
  generated_source_identity => $identity,
 );
 is($captured_result, undef, 'legacy generated capture keeps its return contract');
 is($captured, $source, 'legacy capture and public emission remain byte-identical');

 my $generated = load_generated_source($source, 'Metadata');
 my $metadata = $generated->{metadata}->();
 is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'existing generated-source contract stays v2');
 is(
  $metadata->{entry_rule_contract},
  'linkedspec-root-rule-selection-v1',
  'generated metadata publishes the entry-rule contract',
 );
 is($metadata->{source_identity}, $identity, 'generated metadata retains exact source identity');
 is_deeply(
  $metadata->{entry_rules},
  [
   { label => 'Earlier', is_top => 0 },
   { label => 'EarlierDone', is_top => 0 },
   { label => 'Marked', is_top => 1 },
   { label => 'MarkedDone', is_top => 0 },
   { label => 'Later', is_top => 1 },
   { label => 'LaterDone', is_top => 0 },
  ],
  'generated metadata preserves exact order and authored marker identity',
 );
 ok(
  !(grep { exists($_->{is_top}) } @{$metadata->{plan}}),
  'the existing minimal label/family execution plan is unchanged',
 );
};

subtest 'all generated roles resolve default explicit markerless and configured selectors' => sub {
 my $marked_generated = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$marked_source,
   source_identity => 'root-selection/roles-marked.spec',
  ),
  'MarkedRoles',
 );
 for my $role (generated_role_cases($marked_generated)) {
  my ($name, $callback) = @$role;
  is(invoke_generated($callback, undef), 'marked', "$name uses the first authored marker by default");
  is(invoke_generated($callback, 'Earlier'), 'earlier', "$name lets an explicit ordinary rule beat markers");
  is(invoke_generated($callback, 'Later'), 'later', "$name lets an explicit later marker beat the first marker");
 }

 my $markerless_generated = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$markerless_source,
   source_identity => 'root-selection/roles-markerless.spec',
  ),
  'MarkerlessRoles',
 );
 for my $role (generated_role_cases($markerless_generated)) {
  my ($name, $callback) = @$role;
  is(invoke_generated($callback, undef), 'first', "$name uses first-rule markerless fallback");
  is(invoke_generated($callback, 'Second'), 'second', "$name accepts explicit markerless selection");
 }

 my $configured_generated = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$marked_source,
   source_identity => 'root-selection/configured.spec',
   top_rule => 'Earlier',
  ),
  'ConfiguredRoles',
 );
 is_deeply(
  $configured_generated->{metadata}->()->{entry_rules},
  $marked_generated->{metadata}->()->{entry_rules},
  'emission-time selection does not rewrite authored entry identity',
 );
 for my $role (generated_role_cases($configured_generated)) {
  my ($name, $callback) = @$role;
  is(invoke_generated($callback, undef), 'earlier', "$name preserves the configured explicit selector");
  is(invoke_generated($callback, 'Marked'), 'marked', "$name lets invocation-local selection override configuration");
 }
};

subtest 'generated selection and execution failures use effective attribution' => sub {
 my $generated = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$marked_source,
   source_identity => 'root-selection/failures.spec',
  ),
  'Failures',
 );
 for my $role (generated_role_cases($generated)) {
  my ($name, $callback) = @$role;
  my $error = generated_failure(sub { invoke_generated($callback, 'Missing') });
  is($error->{type}, 'generated_source_error', "$name missing selector uses generated error envelope");
  is($error->{stage}, 'select_entry_rule', "$name missing selector uses selection stage");
  is($error->{code}, 'entry_rule_not_found', "$name missing selector uses portable code");
  is($error->{entry_rule}, 'Missing', "$name missing selector attributes requested entry rule");
  is($error->{rule_label}, 'Missing', "$name missing selector does not claim another rule ran");
  is(
   $error->{source_identity},
   'root-selection/failures.spec',
   "$name missing selector retains generated source identity",
  );
 }

 my $configured_unknown = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$marked_source,
   source_identity => 'root-selection/configured-missing.spec',
   top_rule => 'Missing',
  ),
  'ConfiguredMissing',
 );
 for my $role (generated_role_cases($configured_unknown)) {
  my ($name, $callback) = @$role;
  my $error = generated_failure(sub { invoke_generated($callback, undef) });
  is($error->{stage}, 'select_entry_rule', "$name configured missing selector uses selection stage");
  is($error->{code}, 'entry_rule_not_found', "$name configured missing selector uses portable code");
  is($error->{entry_rule}, 'Missing', "$name configured missing selector retains requested identity");
  is(
   $error->{source_identity},
   'root-selection/configured-missing.spec',
   "$name configured missing selector retains generated source identity",
  );
 }

 my $execution_error = generated_failure(sub {
  $generated->{execute}->([], { top_rule => 'Earlier' })
 });
 is($execution_error->{stage}, 'execute_generated', 'execution failure retains generated execution stage');
 is($execution_error->{code}, 'generated_execution_failed', 'execution failure retains generated execution code');
 is($execution_error->{rule_label}, 'Earlier', 'execution failure attributes the effective explicit rule');
};

subtest 'native and generated runtime traces attribute the effective entry rule' => sub {
 my $scratch = tempdir('linkedspec-root-trace-XXXXXX', TMPDIR => 1, CLEANUP => 1);

 my $native = LinkedSpec::Get(\$marked_source, top_rule => 'Earlier');
 my $native_trace_path = File::Spec->catfile($scratch, 'native.trace');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $native_trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );
 my $native_input = 'x';
 is($native->(\$native_input), 'earlier', 'native traced invocation preserves explicit value');
 my $native_trace = read_text($native_trace_path);
 like($native_trace, qr/ENTER LinkedSpec::parser_invoke:Earlier/, 'native runtime trace enters effective rule');
 like(
  $native_trace,
  qr/DECISION resolve_top_rule_handler => TAKEN.*Resolved top-level rule 'Earlier'/s,
  'native runtime trace resolves the effective rule',
 );

 my $generated = load_generated_source(
  LinkedSpec::emit_generated_source(
   \$marked_source,
   source_identity => 'root-selection/trace.spec',
  ),
  'Trace',
 );
 my $generated_trace_path = File::Spec->catfile($scratch, 'generated.trace');
 my $generated_input = 'x';
 is(
  $generated->{execute_with_trace}->(
   \$generated_input,
   {
    trace_level => 'debug',
    trace_log_file => $generated_trace_path,
    trace_log_mode => 'route',
    trace_reset_log => 1,
    trace_topic_spacing => 0,
   },
   { top_rule => 'Earlier' },
  ),
  'earlier',
  'generated traced invocation preserves explicit value',
 );
 my $generated_trace = read_text($generated_trace_path);
 like(
  $generated_trace,
  qr/GENERATED_SOURCE generated_entry_selection.*rule=Earlier.*family=default.*basis=explicit_selector.*status=ok/s,
  'generated trace records effective label and selection basis',
 );
 like(
  $generated_trace,
  qr/GENERATED_SOURCE generated_rule_enter.*rule=Earlier/s,
  'generated runtime trace enters the effective rule',
 );
 like(
  $generated_trace,
  qr/GENERATED_SOURCE generated_rule_exit.*rule=Earlier.*status=ok/s,
  'generated runtime trace exits the effective rule',
 );

 my $unknown_trace_path = File::Spec->catfile($scratch, 'unknown.trace');
 my $unknown_input = 'x';
 my $unknown_error = generated_failure(sub {
  $generated->{execute_with_trace}->(
   \$unknown_input,
   {
    trace_level => 'debug',
    trace_log_file => $unknown_trace_path,
    trace_log_mode => 'route',
    trace_reset_log => 1,
    trace_topic_spacing => 0,
   },
   { top_rule => 'Missing' },
  )
 });
 is($unknown_error->{entry_rule}, 'Missing', 'traced unknown selection retains requested identity');
 my $unknown_trace = read_text($unknown_trace_path);
 like(
  $unknown_trace,
  qr/GENERATED_SOURCE generated_entry_selection.*rule=Missing.*status=error/s,
  'unknown generated trace attributes the requested missing label at selection',
 );
 unlike($unknown_trace, qr/GENERATED_SOURCE generated_rule_enter/, 'unknown selection runs no generated rule');

 LinkedSpec::Trace::configure_trace(
  trace_level => 'none',
  trace_log_file => '',
  trace_log_mode => 'stdout',
 );
};

done_testing;
