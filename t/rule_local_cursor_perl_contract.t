use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir tempfile);
use FindBin qw($Bin);
use IPC::Open3 qw(open3);
use JSON::PP ();
use Symbol qw(gensym);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::BootstrapSpec ();
use LinkedSpec::RuleIR ();
use LinkedSpec::Trace ();

my $contract_path = "$Bin/../capability_conformance/rule_local_cursor_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

sub family_header_source {
 my ($header) = @_;
 return "$header\n /x/\n" if $header =~ /::/;
 return "Root::\n -> Top\n$header\n /x/\n"
}

sub edge_source {
 my ($family, $sources, $declared_rules) = @_;
 my $header = $family eq 'and' ? 'Top::AND' : 'Top::';
 my $source = $header . "\n" . join("\n", map { " $_" } @$sources) . "\n";
 for my $label (@$declared_rules) {
  my $literal = lc(substr($label, 0, 1) || 'x');
  my $needs_second_regex = grep { /\b\Q$label\E\s*\[\s*[1-9]/ } @$sources;
  $source .= "$label: /$literal/" . ($needs_second_regex ? " /${literal}2/" : '') . "\n";
 }
 return $source
}

sub compile_descriptor {
 my ($source) = @_;
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%runtime_ctx);
 return ($descriptor, \%runtime_ctx)
}

my $generated_package_counter = 0;

sub load_generated_source {
 my ($source) = @_;
 my $package = 'LinkedSpec::RuleLocalCursorAdmission::Generated' . ++$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, 'admission generated source loads in an isolated package') or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
  validate_plan => *{"${package}::ValidateGeneratedPlan"}{CODE},
 }
}

sub read_text {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read $path: $!";
 my $text = do { local $/; <$fh> };
 close $fh or die "cannot close $path: $!";
 return $text
}

sub run_primary_command {
 my (@arguments) = @_;
 my $stderr_fh = gensym();
 my $pid = open3(
  my $stdin_fh,
  my $stdout_fh,
  $stderr_fh,
  $^X,
  "-I$Bin/../perl",
  "$Bin/../bin/linkedspec",
  @arguments,
 );
 close $stdin_fh or die "cannot close primary-command stdin: $!";
 my $stdout = do { local $/; <$stdout_fh> } // '';
 my $stderr = do { local $/; <$stderr_fh> } // '';
 waitpid($pid, 0);
 return ($? >> 8, $stdout, $stderr)
}

sub parsed_rule_ir {
 my ($source, $label) = @_;
 my ($ok, $parsed, $error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
 ok($ok, "$label bootstrap source parses") or diag($error // 'bootstrap parse failed without detail');
 return unless $ok;
 my %declared = map {
  my $entry = $_;
  my $entry_label = ref($entry) eq 'ARRAY' && ref($entry->[0]) eq 'ARRAY' ? $entry->[0][1] : undef;
  defined($entry_label) ? ($entry_label => 1) : ()
 } @$parsed;
 my ($tokens) = grep {
  ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && defined($_->[0][1]) && $_->[0][1] eq $label
 } @$parsed;
 return unless $tokens;
 my $rule_ir = LinkedSpec::RuleIR::_collect_rule_ir($tokens);
 my $normalized = eval {
  LinkedSpec::RuleIR::_normalize_rule_ir_edges($rule_ir, declared_rule_labels => \%declared);
  1;
 };
 ok($normalized, "$label RuleIR normalizes") or diag(ref($@) eq 'HASH' ? JSON::PP->new->canonical->encode($@) : $@);
 return $normalized ? $rule_ir : undef
}

for my $case (@{$contract->{family_cases}}) {
 my ($descriptor, $ctx) = compile_descriptor(family_header_source($case->{header}));
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
 next unless $descriptor;
 is($descriptor->{spec}{Top}{meta}{family}, $case->{family}, "$case->{id} derives family");
 is($descriptor->{spec}{Top}{meta}{cursor_policy}, $case->{cursor_policy}, "$case->{id} derives cursor policy");
}

my %diagnostic_contract = map { $_->{code} => $_ } @{$contract->{diagnostics}};
my %observed_diagnostic;

for my $case (@{$contract->{edge_resolution_cases}}) {
 my $source = edge_source($case->{parent_family}, [$case->{source}], $case->{declared_rules});
 if (my $expected_error = $case->{expected_error}) {
  my ($descriptor, $ctx) = compile_descriptor($source);
  ok(!$descriptor, "$case->{id} rejects before handler emission");
  my $error = $ctx->{last_error} || {};
  is($error->{code}, $expected_error, "$case->{id} reports portable code");
  is($error->{stage}, $diagnostic_contract{$expected_error}{stage}, "$case->{id} reports portable stage");
  for my $field (@{$diagnostic_contract{$expected_error}{fields}}) {
   ok(exists($error->{$field}), "$case->{id} reports required field $field");
  }
  $observed_diagnostic{$error->{code}} = 1 if defined($error->{code});
  next;
 }

 my $expected = $case->{expected};
 my $rule_ir = parsed_rule_ir($source, 'Top');
 next unless $rule_ir;
 my ($descriptor, $ctx) = compile_descriptor($source);
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));

 if ($expected->{kind} eq 'lifecycle') {
  my ($ok, $parsed) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
  my ($top) = grep { ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && ($_->[0][1] // '') eq 'Top' } @$parsed;
  ok(grep({ $_->[0] eq $expected->{name} . 'CODE' } @$top), "$case->{id} keeps reserved lifecycle precedence");
  is($rule_ir->{edge_ownership}, 'none', "$case->{id} does not become a rule edge");
  next;
 }

 my $expected_ownership = $expected->{ownership};
 is($descriptor->{spec}{Top}{meta}{edge_ownership}, $expected_ownership, "$case->{id} preserves resolved ownership");
 if ($expected->{source_form} eq 'bare') {
  is(scalar(@{$rule_ir->{normalized_edges}}), 1, "$case->{id} produces one normalized edge");
  my $normalized = $rule_ir->{normalized_edges}[0];
  is($normalized->{kind}, 'edge', "$case->{id} produces typed edge kind");
  is($normalized->{ownership}, $expected_ownership, "$case->{id} normalizes family ownership");
  is($normalized->{source_form}, 'bare', "$case->{id} retains source form");
  is($normalized->{has_block}, $expected->{has_block} ? 1 : 0, "$case->{id} retains block presence");
  is($normalized->{fluent}, $expected->{targets}[0]{fluent}, "$case->{id} retains normalized fluent form");
  is_deeply($normalized->{targets}, $expected->{targets}, "$case->{id} retains target/index structure");
 }
}

for my $case (@{$contract->{rule_edge_set_cases}}) {
 my $source = edge_source($case->{parent_family}, $case->{sources}, $case->{declared_rules});
 my ($descriptor, $ctx) = compile_descriptor($source);
 if (my $expected_error = $case->{expected_error}) {
  ok(!$descriptor, "$case->{id} rejects mixed normalized ownership");
  my $error = $ctx->{last_error} || {};
  is($error->{code}, $expected_error, "$case->{id} reports portable code");
  is($error->{stage}, $diagnostic_contract{$expected_error}{stage}, "$case->{id} reports portable stage");
  is_deeply($error->{ownerships}, ['action', 'blind'], "$case->{id} reports exact ownership set");
  $observed_diagnostic{$error->{code}} = 1 if defined($error->{code});
  next;
 }
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
 next unless $descriptor;
 is($descriptor->{spec}{Top}{meta}{edge_ownership}, $case->{expected_ownership}, "$case->{id} has one normalized ownership");
}

my $lifecycle_body_source = <<'SPEC';
Top::
 I {
  set(name, "Child")
 }
Child:
 /c/
SPEC
my $lifecycle_ir = parsed_rule_ir($lifecycle_body_source, 'Top');
is($lifecycle_ir->{edge_ownership}, 'none', 'identifier text inside lifecycle code is not re-scanned as a bare edge');

my $multiline_bare_source = <<'SPEC';
Top::AND
 Child {
  return(child_result)
 }
Child:
 /c/
SPEC
my $multiline_ir = parsed_rule_ir($multiline_bare_source, 'Top');
is($multiline_ir->{edge_ownership}, 'blind', 'multiline complete-line bare block normalizes as one blind edge');
is($multiline_ir->{normalized_edges}[0]{has_block}, 1, 'multiline bare block retains block presence');

my $bare_group_without_block = edge_source('or_default', ['A | B'], ['A', 'B']);
my ($missing_block_descriptor, $missing_block_ctx) = compile_descriptor($bare_group_without_block);
ok(!$missing_block_descriptor, 'bare grouped action without a shared block rejects');
is($missing_block_ctx->{last_error}{code}, 'grouped_action_shared_block_required', 'bare grouped action uses portable shared-block diagnostic');
is_deeply($missing_block_ctx->{last_error}{targets}, ['A', 'B'], 'bare grouped action diagnostic reports all targets');

my $live_boundary_source = <<'SPEC';
Top::AND
 /x/
 -> Top { return("hit") }
SPEC
my $live_parser = LinkedSpec::Get(\$live_boundary_source);
ok($live_parser, 'derived AND policy compiles for live rule-local cursor execution');
my $live_input = 'prefix x';
ok(!defined($live_parser->(\$live_input)), 'live Perl execution spends the derived AND consume policy');

my $admission_default_source = <<'SPEC';
Top::
 /x/
 -> Top { return("hit") }
SPEC
my $admission_and_source = <<'SPEC';
Top::AND
 /x/
 -> Top { return("hit") }
SPEC
my ($admission_generated_source, $admission_generated_module);

my %admission_role = (
 live_default_family => sub {
  my $parser = LinkedSpec::Get(\$admission_default_source);
  ok(ref($parser) eq 'CODE', 'default-family live parser compiles');
  my $input = 'prefix x';
  is($parser->(\$input), 'hit', 'default-family live parser seeks from its authored family');
 },
 live_and_family => sub {
  my $parser = LinkedSpec::Get(\$admission_and_source);
  ok(ref($parser) eq 'CODE', 'AND-family live parser compiles');
  my $leading = 'prefix x';
  ok(!defined($parser->(\$leading)), 'AND-family live parser consumes at the current cursor');
  my $exact = 'x';
  is($parser->(\$exact), 'hit', 'AND-family live parser accepts a contiguous match');
 },
 descriptor_v1 => sub {
  my $source = <<'SPEC';
Top::AND
 Child
Child:
 /x/
 -> Child { return("hit") }
SPEC
  my ($descriptor, $ctx) = compile_descriptor($source);
  ok(ref($descriptor) eq 'HASH', 'admission descriptor compiles')
   or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
  return unless ref($descriptor) eq 'HASH';
  is($descriptor->{meta}{cursor_contract}, $contract->{descriptor_contract}{meta}{cursor_contract}, 'descriptor exposes v1 cursor identity');
  is($descriptor->{spec}{Top}{meta}{cursor_policy}, 'consume', 'descriptor derives parent consume policy');
  is($descriptor->{spec}{Child}{meta}{cursor_policy}, 'seek', 'descriptor derives child seek policy');
  is($descriptor->{spec}{Top}{meta}{resolved_edges}[0]{ownership}, 'blind', 'descriptor projects normalized blind ownership');
 },
 emitted_source_v2 => sub {
  $admission_generated_source = LinkedSpec::emit_generated_source(
   \$admission_default_source,
   source_identity => 'rule-local-cursor/perl-admission.spec',
  );
  ok(defined($admission_generated_source) && length($admission_generated_source), 'public emitter returns admission source');
  like($admission_generated_source, qr/\Q$contract->{generated_source_v2}{contract_id}\E/, 'emitted source identifies contract v2');
  like($admission_generated_source, qr/format_version: \Q$contract->{generated_source_v2}{format_version}\E/, 'emitted source identifies format v2');
  unlike($admission_generated_source, qr/cursor_policy\s*=>/, 'emitted plan carries no independent cursor-policy field');
 },
 generated_direct => sub {
  $admission_generated_module = load_generated_source($admission_generated_source);
  ok(ref($admission_generated_module->{execute}) eq 'CODE', 'generated direct role is callable');
  my $input = 'prefix x';
  is($admission_generated_module->{execute}->(\$input), 'hit', 'generated direct role preserves default-family seek');
  my $metadata = $admission_generated_module->{metadata}->();
  is($metadata->{contract_id}, $contract->{generated_source_v2}{contract_id}, 'generated metadata preserves v2 identity');
  my $plan = $admission_generated_module->{plan}->();
  my $ok = eval {
   $admission_generated_module->{validate_plan}->($plan, 'linkedspec-generated-source-v1');
   1;
  };
  my $error = $@;
  ok(!$ok && ref($error) eq 'HASH', 'generated v1 reconstruction rejects structurally');
  is($error->{code}, $contract->{generated_source_v2}{v1_reconstruction_error}, 'generated reconstruction reports the portable code');
  $observed_diagnostic{$error->{code}} = 1 if ref($error) eq 'HASH' && defined($error->{code});
 },
 generated_trace => sub {
  my $trace_dir = tempdir(CLEANUP => 1);
  my $trace_path = File::Spec->catfile($trace_dir, 'generated.trace');
  my $input = 'prefix x';
  my $result = $admission_generated_module->{execute_with_trace}->(
   \$input,
   {
    trace_level => 'debug',
    trace_log_file => $trace_path,
    trace_log_mode => 'route',
    trace_reset_log => 1,
    trace_topic_spacing => 0,
   },
  );
  is($result, 'hit', 'generated traced role preserves the direct result');
  my $trace = read_text($trace_path);
  like($trace, qr/GENERATED_SOURCE generated_family_decision/, 'generated trace exposes its family decision');
  like($trace, qr/source_identity=rule-local-cursor\/perl-admission\.spec/, 'generated trace preserves source identity');
  LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');
 },
 loaded_spec => sub {
  my ($fh, $path) = tempfile(SUFFIX => '.spec');
  print {$fh} $admission_and_source or die "cannot write $path: $!";
  close $fh or die "cannot close $path: $!";
  my $parser = LinkedSpec::get_parser($path);
  ok(ref($parser) eq 'CODE', 'loaded-spec factory returns a parser');
  my $leading = 'prefix x';
  ok(!defined($parser->(\$leading)), 'loaded AND spec retains consume policy');
  my $exact = 'x';
  is($parser->(\$exact), 'hit', 'loaded AND spec accepts contiguous input');
 },
 mixed_parent_child => sub {
  my $source = <<'SPEC';
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'mixed-family parent/child parser compiles');
  my $input = 'prefix x';
  is_deeply($parser->(\$input), ['hit'], 'AND parent does not override its seeking default child');
 },
 recursion => sub {
  my $source = <<'SPEC';
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'mixed-family recursive parser compiles');
  my $input = 'p junk xp junk z';
  is_deeply($parser->(\$input), [['done']], 'recursive calls re-derive each entered rule policy');
 },
 structural_ordered_landmarks => sub {
  my $source = <<'SPEC';
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'ordered-landmark structure compiles');
  my $input = 'junk h junk b';
  is_deeply($parser->(\$input), ['header', 'body'], 'AND over seeking children replaces a global seek combination');
 },
 structural_anchored_choice => sub {
  my $source = <<'SPEC';
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
SPEC
  my $parser = LinkedSpec::Get(\$source);
  ok(ref($parser) eq 'CODE', 'anchored-choice structure compiles');
  my $leading = 'prefix x';
  ok(!defined($parser->(\$leading)), 'OR over consuming children replaces a global consume combination');
 },
 dynamic_option_removal => sub {
  my $invalid_source = "not a spec\n";
  for my $option_name (@{$contract->{option_retirement}{dynamic_option_names}}) {
   my %runtime_ctx;
   my $result = LinkedSpec::Get(
    \$invalid_source,
    runtime_ctx_ref => \%runtime_ctx,
    $option_name => 'seek',
   );
   ok(!defined($result), "$option_name rejects before source parsing");
   my $error = $runtime_ctx{last_error} || {};
   is($error->{stage}, $contract->{option_retirement}{error}{stage}, "$option_name reports portable stage");
   is($error->{code}, $contract->{option_retirement}{error}{code}, "$option_name reports portable code");
   is($error->{option_name}, $contract->{option_retirement}{error}{fields}{option_name}, "$option_name reports normalized field");
   $observed_diagnostic{$error->{code}} = 1 if defined($error->{code});
  }
 },
 primary_command => sub {
  my ($help_exit, $help_stdout, $help_stderr) = run_primary_command('--help');
  is($help_exit, 0, 'primary help exits successfully');
  is($help_stderr, '', 'primary help keeps stderr empty');
  unlike($help_stdout, qr/\Q$contract->{option_retirement}{cli}{flag}\E/, 'primary help omits the retired flag');

  my ($default_exit, $default_stdout, $default_stderr) = run_primary_command(
   '--inline-spec', $admission_default_source,
   '--input', 'prefix x',
  );
  is($default_exit, 0, 'primary default-family request succeeds');
  is($default_stdout, '"hit"' . "\n", 'primary default-family request preserves canonical JSON');
  is($default_stderr, '', 'primary default-family request keeps stderr empty');

  my ($and_exit, $and_stdout, $and_stderr) = run_primary_command(
   '--inline-spec', $admission_and_source,
   '--input', 'x',
  );
  is($and_exit, 0, 'primary AND-family request succeeds');
  is($and_stdout, '"hit"' . "\n", 'primary AND-family request preserves canonical JSON');
  is($and_stderr, '', 'primary AND-family request keeps stderr empty');

  my ($removed_exit, $removed_stdout, $removed_stderr) = run_primary_command($contract->{option_retirement}{cli}{flag});
  is($removed_exit, $contract->{option_retirement}{cli}{exit}, 'primary retired flag uses exact usage exit');
  is($removed_stdout, '', 'primary retired flag keeps stdout empty');
  like($removed_stderr, qr/\Q$contract->{option_retirement}{cli}{stderr}\E/, 'primary retired flag reports the targeted message');
 },
 portable_diagnostics => sub {
  is_deeply(
   [sort keys %observed_diagnostic],
   [sort map { $_->{code} } @{$contract->{diagnostics}}],
   'composed Perl roles observe every portable cursor diagnostic code',
  );
 },
);

is_deeply(
 [sort keys %admission_role],
 [sort @{$contract->{perl_reference_admission}{roles}}],
 'Perl admission consumer implements every contract-declared role exactly once',
);
my %completed_admission_role;
for my $role (@{$contract->{perl_reference_admission}{roles}}) {
 subtest "Perl reference admission role: $role" => sub {
  $admission_role{$role}->();
  $completed_admission_role{$role}++;
 };
}
is_deeply(
 \%completed_admission_role,
 { map { $_ => 1 } @{$contract->{perl_reference_admission}{roles}} },
 'Perl admission consumer completes every declared role once',
);

done_testing;
