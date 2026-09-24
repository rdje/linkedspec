#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempdir);
use JSON::PP qw(decode_json);

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 my $perl_lib = File::Spec->catdir($repo_root, 'perl');
 unshift @INC, $perl_lib unless grep { defined($_) && $_ eq $perl_lib } @INC;
}

use LinkedSpec;
use LinkedSpec::GeneratedSource;
use LinkedSpec::SpecLoader ();
use LinkedSpec::Trace;

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $fixture_dir = File::Spec->catdir(
 $repo_root,
 qw(capability_conformance generated_source fixtures default_action_result_trace_identity),
);
my $package_counter = 0;

sub read_text {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $text = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $text
}

sub capture_source {
 my ($spec, %options) = @_;
 my $source = LinkedSpec::emit_generated_source(
  \$spec,
  %options,
 );
 ok(defined($source) && length($source), 'public emitter returns generated source text');
 return $source
}

sub load_generated_source {
 my ($source, $suffix) = @_;
 ++$package_counter;
 my $package = 'LinkedSpec::GeneratedSourceContract::' . $suffix . $package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, "$suffix generated source compiles in isolated package") or diag($error);
 no strict 'refs';
 return {
  package => $package,
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
  validate_plan => *{"${package}::ValidateGeneratedPlan"}{CODE},
 }
}

sub clone_plan {
 my ($plan) = @_;
 return [map { { %$_ } } @$plan]
}

sub generated_error {
 my ($callback) = @_;
 my $ok = eval {
  $callback->();
  1
 };
 my $error = $@;
 ok(!$ok, 'generated-source failure rejects the request');
 ok(ref($error) eq 'HASH', 'generated-source failure is a structured object');
 return $error
}

{
 package LinkedSpec::GeneratedSourceContract::LegacyV1Artifact;
 our $LINKEDSPEC_GENERATED_SOURCE_CONTRACT = 'linkedspec-generated-source-v1';

 sub validate_plan {
  return LinkedSpec::GeneratedSource::validate_plan(@_)
 }
}

subtest 'v2 derives the exact ten handler-family cursor policies' => sub {
 is_deeply(
  LinkedSpec::GeneratedSource::family_cursor_policy_rows(),
  [
   { family => 'default', cursor_policy => 'seek' },
   { family => 'or_acode', cursor_policy => 'seek' },
   { family => 'or_bcode', cursor_policy => 'seek' },
   { family => 'rep_acode', cursor_policy => 'seek' },
   { family => 'rep_bcode', cursor_policy => 'seek' },
   { family => 'and_single_acode', cursor_policy => 'consume' },
   { family => 'and_acode_seq', cursor_policy => 'consume' },
   { family => 'and_bcode', cursor_policy => 'consume' },
   { family => 'rep_and_acode', cursor_policy => 'consume' },
   { family => 'rep_and_bcode', cursor_policy => 'consume' },
  ],
  'the ten admitted families derive exactly five seek and five consume policies',
 );
 is(
  LinkedSpec::GeneratedSource::family_cursor_policy('invented'),
  undef,
  'an unknown family has no cursor policy',
 );
};

subtest 'removed public cursor overrides reject before source parsing or emission' => sub {
 my $invalid_spec = "not a spec\n";
 foreach my $option_name (qw(parse_mode parseMode)) {
  my %runtime_ctx;
  my $result = LinkedSpec::Get(
   \$invalid_spec,
   $option_name => 'seek',
   runtime_ctx_ref => \%runtime_ctx,
  );
  ok(!defined($result), "$option_name override rejects before invalid source parsing");
  my $error = $runtime_ctx{last_error} || {};
  is($error->{stage}, 'prepare_options', "$option_name rejection uses the portable option stage");
  is($error->{code}, 'parse_mode_override_removed', "$option_name rejection uses the portable code");
  is($error->{option_name}, 'parse_mode', "$option_name rejection reports the normalized option name");
 }

 my $emitter_error = generated_error(sub {
  LinkedSpec::emit_generated_source(
   \$invalid_spec,
   parse_mode => 'consume',
   source_identity => 'generated-source/removed-option.spec',
  );
 });
 is($emitter_error->{type}, 'generated_source_error', 'emitter removal uses the generated-source error envelope');
 is($emitter_error->{stage}, 'prepare_options', 'emitter removal rejects during option preparation');
 is($emitter_error->{code}, 'parse_mode_override_removed', 'emitter removal preserves the portable code');
 is($emitter_error->{option_name}, 'parse_mode', 'emitter removal preserves the normalized option name');
 is(
  $emitter_error->{source_identity},
  'generated-source/removed-option.spec',
  'emitter removal preserves source identity before parsing',
 );
};

subtest 'v2 emitted plans retain every exact structural family' => sub {
 my $spec = <<'SPEC';
DefaultRoot::
 I { set(words, []) }
 /hello[ \t]+(\w+)/
 LE { push(words, match_group(0)) }
 E { return(copy(words)) }

OrAcode:|
 /go/ -> OrDone { return("or-acode") }
OrDone: /go/

AndSingle:AND
 /one/ -> AndSingleDone { return("and-single") }
AndSingleDone: /one/

AndSeq:AND
 /a/ -> AndSeqFirst
 /[ \t]+b/ -> AndSeqSecond { return("and-seq") }
AndSeqFirst: /a/
AndSeqSecond: /[ \t]+b/

AndBcode:AND
 => AndBlindA
 => AndBlindB
 E { return("and-bcode") }
AndBlindA: /a/
AndBlindB: /[ \t]+b/

OrBcode:|
 => OrBlindA
 => OrBlindB
 E { return(cat("or-bcode:", retv)) }
OrBlindA: /a/ E { return("A") }
OrBlindB: /b/ E { return("B") }

RepAcode:OR{2,3}
 I { set(rep_acode, []) }
 /a/ -> RepA { push(rep_acode, match_text()) }
 /b/ -> RepB { push(rep_acode, match_text()) }
 E { return(copy(rep_acode)) }
RepA: /a/
RepB: /b/

RepBcode:OR{2,3}
 I { set(rep_bcode, []) }
 => RepBlindA
 => RepBlindB
 LE { push(rep_bcode, retv) }
 E { return(copy(rep_bcode)) }
RepBlindA:& /a/ LE { return("A") }
RepBlindB:& /b/ LE { return("B") }

RepAndAcode:AND{2}
 I { set(rep_and_acode, []); set(rep_and_acode_pair, []) }
 /a/ -> RepAndA { push(rep_and_acode_pair, match_text()) }
 /b/ -> RepAndB { push(rep_and_acode_pair, match_text()) }
 IT { push(rep_and_acode, copy(rep_and_acode_pair)); set(rep_and_acode_pair, []) }
 E { return(copy(rep_and_acode)) }
RepAndA: /a/
RepAndB: /b/

RepAndBcode:AND{2}
 I { set(rep_and_bcode, []); set(rep_and_bcode_group, []) }
 => RepAndBlindA { push(rep_and_bcode_group, retv) }
 => RepAndBlindB { push(rep_and_bcode_group, retv) }
 IT { push(rep_and_bcode, copy(rep_and_bcode_group)); set(rep_and_bcode_group, []) }
 E { return(copy(rep_and_bcode)) }
RepAndBlindA:& /a/ LE { return("A") }
RepAndBlindB:& /b/ LE { return("B") }
SPEC
 my @expected = (
  { label => 'DefaultRoot', family => 'default' },
  { label => 'OrAcode', family => 'or_acode' },
  { label => 'AndSingle', family => 'and_single_acode' },
  { label => 'AndSeq', family => 'and_acode_seq' },
  { label => 'AndBcode', family => 'and_bcode' },
  { label => 'OrBcode', family => 'or_bcode' },
  { label => 'RepAcode', family => 'rep_acode' },
  { label => 'RepBcode', family => 'rep_bcode' },
  { label => 'RepAndAcode', family => 'rep_and_acode' },
  { label => 'RepAndBcode', family => 'rep_and_bcode' },
 );
 my %target = map { $_->{label} => 1 } @expected;
 my $source = capture_source(
  $spec,
  generated_source_identity => 'generated-source/v2-all-families.spec',
 );
 my $module = load_generated_source($source, 'V2AllFamilies');
 my $plan = $module->{plan}->();
 my @actual = grep { $target{$_->{label}} } @$plan;
 is_deeply(\@actual, \@expected, 'emitted plan classifies all ten structural families exactly');
 ok($module->{validate_plan}->($plan), 'complete emitted all-family plan validates');
};

subtest 'neutral direct result, deterministic source, metadata, trace, and errors' => sub {
 my $spec = read_text(File::Spec->catfile($fixture_dir, 'input.spec'));
 my $input = read_text(File::Spec->catfile($fixture_dir, 'input.txt'));
 my $expected = decode_json(read_text(File::Spec->catfile($fixture_dir, 'expected.json')));
 my $identity = 'generated-source/default-action-result.spec';

 my $normal_input = $input;
 my $normal = LinkedSpec::Get(\$spec)->(\$normal_input);
 is_deeply($normal, $expected, 'normal generated Perl parser satisfies the neutral expected value');

 my $source = capture_source(
  $spec,
  generated_source_identity => $identity,
 );
 my $source_again = capture_source(
  $spec,
  generated_source_identity => $identity,
 );
 is($source_again, $source, 'same compiled input and identity emit deterministic source');
 my $legacy_source = '';
 my $legacy_result = LinkedSpec::Get(
  \$spec,
  generate_only => 1,
  dump_parser_source => 1,
  parser_source_ref => \$legacy_source,
  generated_source_identity => $identity,
 );
 is($legacy_result, undef, 'legacy generate-only capture keeps its return contract');
 is($legacy_source, $source, 'public emitter and legacy capture return identical source');
 like($source, qr/contract_id: linkedspec-generated-source-v2/, 'source carries contract marker');
 like($source, qr/format_version: 2/, 'source carries format marker');
 like($source, qr/our \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY = '\Q$identity\E'/, 'source carries quoted identity');
 unlike($source, qr/\bparse_mode\b/, 'source does not serialize a global parse-mode constructor or field');
 unlike($source, qr/\bcursor_policy\s*=>/, 'plan does not serialize a mutable cursor-policy field');
 like($source, qr/LinkedRE::oredRE\(/, 'source reconstructs indexed dependency alternation');
 unlike($source, qr/dependency_regex_map.*=>\s*qr\/.*\(\?\{\$pos=/s, 'source does not stringify indexed dependency regex state');

 my $module = load_generated_source($source, 'Direct');
 ok(ref($module->{execute}) eq 'CODE', 'generated source exposes execute role');
 ok(ref($module->{execute_with_trace}) eq 'CODE', 'generated source exposes execute-with-trace role');
 ok(ref($module->{validate_plan}) eq 'CODE', 'generated source exposes plan validation');

 my $metadata = $module->{metadata}->();
 is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'metadata reports contract id');
 is($metadata->{format_version}, 2, 'metadata reports format version');
 is($metadata->{source_identity}, $identity, 'metadata reports exact source identity');
 is(
  $metadata->{entry_rule_contract},
  'linkedspec-root-rule-selection-v1',
  'metadata reports root-rule selection contract',
 );
 is_deeply(
  $metadata->{entry_rules},
  [
   { label => 'Top', is_top => 1 },
   { label => 'Done', is_top => 1 },
  ],
  'metadata preserves ordered authored default-entry markers',
 );
 is_deeply(
  $metadata->{plan},
  [
   { label => 'Top', family => 'default' },
   { label => 'Done', family => 'default' },
  ],
  'metadata reports ordered label/family plan',
 );

 my $generated_input = $input;
 my $generated = $module->{execute}->(\$generated_input);
 is_deeply($generated, $expected, 'independently loaded generated source returns exact neutral value');

 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'generated-source.trace');
 my $traced_input = $input;
 my $traced = $module->{execute_with_trace}->(
  \$traced_input,
  {
   trace_level => 'debug',
   trace_log_file => $trace_path,
   trace_log_mode => 'route',
   trace_reset_log => 1,
   trace_topic_spacing => 0,
  },
 );
 is_deeply($traced, $expected, 'traced generated execution preserves exact result');
 my $trace = read_text($trace_path);
 like($trace, qr/GENERATED_SOURCE generated_rule_enter/, 'trace exposes generated-rule enter role');
 like($trace, qr/GENERATED_SOURCE generated_family_decision/, 'trace exposes generated-family decision role');
 like($trace, qr/GENERATED_SOURCE generated_rule_exit/, 'trace exposes generated-rule exit role');
 like($trace, qr/source_identity=\Q$identity\E/, 'trace preserves generated source identity');
 LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

 my $plan = $module->{plan}->();
 ok($module->{validate_plan}->($plan), 'exact generated plan validates');
 my $version_error = generated_error(sub {
  $module->{validate_plan}->($plan, 'linkedspec-generated-source-v1');
 });
 is($version_error->{stage}, 'validate_generated_plan', 'v1 reconstruction rejects at plan-validation stage');
 is(
  $version_error->{code},
  'generated_source_contract_version_mismatch',
  'v1 reconstruction uses the portable contract mismatch code',
 );
 is(
  $version_error->{expected_contract},
  'linkedspec-generated-source-v2',
  'v1 reconstruction reports the expected v2 contract',
 );
 is(
  $version_error->{actual_contract},
  'linkedspec-generated-source-v1',
  'v1 reconstruction reports the actual v1 contract',
 );
 like(
  $version_error->{detail},
  qr/regenerate .* \.spec\s+source/x,
  'v1 reconstruction requires regeneration from the .spec source',
 );
 my $legacy_artifact_error = generated_error(sub {
  LinkedSpec::GeneratedSourceContract::LegacyV1Artifact::validate_plan(
   expected => $plan,
   actual => $plan,
   source_identity => $identity,
  );
 });
 is(
  $legacy_artifact_error->{code},
  'generated_source_contract_version_mismatch',
  'a self-contained v1 caller is rejected even without the new explicit contract argument',
 );
 is(
  $legacy_artifact_error->{actual_contract},
  'linkedspec-generated-source-v1',
  'legacy caller inference preserves the v1 artifact identity',
 );
 my @rejections = (
  [row_count_mismatch => sub { [] }, 'generated_plan_row_count_mismatch'],
  [label_mismatch => sub { my $copy = clone_plan($plan); $copy->[0]{label} = 'Wrong'; $copy }, 'generated_plan_label_mismatch'],
  [family_mismatch => sub { my $copy = clone_plan($plan); $copy->[0]{family} = 'or_acode'; $copy }, 'generated_plan_family_mismatch'],
  [unknown_family => sub { my $copy = clone_plan($plan); $copy->[0]{family} = 'unknown'; $copy }, 'generated_plan_unknown_family'],
 );
 foreach my $case (@rejections) {
  my ($id, $build, $code) = @$case;
  my $error = generated_error(sub { $module->{validate_plan}->($build->()) });
  is($error->{type}, 'generated_source_error', "$id error type is stable");
  is($error->{stage}, 'validate_generated_plan', "$id error stage is stable");
  is($error->{code}, $code, "$id error code is stable");
  is($error->{source_identity}, $identity, "$id error preserves source identity");
 }

 my $execution_error = generated_error(sub { $module->{execute}->([]) });
 is($execution_error->{stage}, 'execute_generated', 'execution failure stage is stable');
 is($execution_error->{code}, 'generated_execution_failed', 'execution failure code is stable');
 is($execution_error->{source_identity}, $identity, 'execution failure preserves source identity');

 my $emission_error = generated_error(sub {
  my $diagnostic = '';
  open my $capture, '>', \$diagnostic or die "cannot open diagnostic capture: $!";
  local *STDOUT = $capture;
  local *STDERR = $capture;
  LinkedSpec::emit_generated_source(
   \"not a spec\n",
   source_identity => 'generated-source/invalid.spec',
  );
 });
 is($emission_error->{stage}, 'emit_source', 'emission failure stage is stable');
 is($emission_error->{code}, 'generated_source_emit_failed', 'emission failure code is stable');
 is($emission_error->{source_identity}, 'generated-source/invalid.spec', 'emission failure preserves source identity');

 my $second_module = load_generated_source($source, 'ArbitraryPackage');
 my $second_input = $input;
 is_deeply(
  $second_module->{execute}->(\$second_input),
  $expected,
  'same source executes outside its first package without binding drift',
 );
};

subtest 'fresh v2 handlers spend family-derived seek and consume policies' => sub {
 my $seek_spec = <<'SPEC';
Top::
 /x/ -> Done { return("x") }
Done: /x/
SPEC
 my $consume_spec = <<'SPEC';
Top::AND
 /x/ -> Done { return("x") }
Done: /x/
SPEC

 my $seek_source = capture_source(
  $seek_spec,
  generated_source_identity => 'generated-source/v2-seek.spec',
 );
 my $consume_source = capture_source(
  $consume_spec,
  generated_source_identity => 'generated-source/v2-consume.spec',
 );
 my $seek_module = load_generated_source($seek_source, 'V2Seek');
 my $consume_module = load_generated_source($consume_source, 'V2Consume');

 is($seek_module->{plan}->()->[0]{family}, 'default', 'default plan row identifies a seek family');
 is(
  $consume_module->{plan}->()->[0]{family},
  'and_single_acode',
  'AND plan row identifies a consume family',
 );
 unlike(
  $seek_source,
  qr/LinkedRE::or\([^\n]+,\s*'consume'/,
  'default generated handler uses the family-derived seek matcher form',
 );
 like(
  $consume_source,
  qr/LinkedRE::match_slot\([^\n]+,\s*'consume',\s*\$info\)/,
  'AND generated handler uses the family-derived required-slot consume form',
 );

 my $seek_input = 'junkx';
 is($seek_module->{execute}->(\$seek_input), 'x', 'fresh default-family source seeks forward');
 my $consume_input = 'junkx';
 is($consume_module->{execute}->(\$consume_input), undef, 'fresh AND-family source rejects leading junk');
 my $exact_input = 'x';
 is($consume_module->{execute}->(\$exact_input), 'x', 'fresh AND-family source consumes at its cursor');
};

subtest 'multiple dependency alternatives and slash-bearing regexes retain indexes' => sub {
 my $spec = <<'SPEC';
Top::|
 /x/ -> Slash { return("slash") }
 /y/ -> Bee { return("bee") }

Slash:
 /a\/b/

Bee:
 /bee/
SPEC

 my $source = capture_source(
  $spec,
  generated_source_identity => 'generated-source/indexes.spec',
 );
 my $module = load_generated_source($source, 'Indexes');
 is($module->{metadata}->()->{plan}[0]{family}, 'or_acode', 'plan classifies OR acode family');

 foreach my $case (
  ['a/b', 'slash', 'alternative zero with slash-bearing regex'],
  ['bee', 'bee', 'alternative one'],
 ) {
  my ($text, $expected, $label) = @$case;
  my $normal_input = $text;
  my $normal = LinkedSpec::Get(\$spec)->(\$normal_input);
  my $generated_input = $text;
  my $generated = $module->{execute}->(\$generated_input);
  is_deeply($normal, $expected, "$label normal result is exact");
  is_deeply($generated, $expected, "$label generated result is exact");
 }
};

subtest 'integration book regex examples execute through loader and fresh generated processes' => sub {
 my $book_path = File::Spec->catfile(
  $repo_root, qw(docs linkedspec-book src public-api integration-perl.md),
 );
 my $book = read_text($book_path);
 my ($section) = $book =~ /^## Regex and division in action code\n(.*?)(?=^## |\z)/ms;
 ok(defined($section), 'published regex section exists');
 return unless defined($section);
 my @sources = $section =~ /^```text\n(.*?)^```\s*$/msg;
 my @cases = (
  ['multiline pattern', 'x', 1],
  ['captured subject substitution', "x\ny", 'ok'],
  ['quoted multiline subject', 'x', 'ok'],
  ['grouped pattern continuation', 'x,y', [1, 'ok']],
  ['final numeric slash call', 'x', 8, ['Top', 'Done'], 'y'],
  ['same-line named slot', 'b', 'b', ['Top', 'Token'], 'a', {
   Token => [{regex_index=>0,slot_id=>'first'}, {regex_index=>1,slot_id=>'second'}, {regex_index=>2,slot_id=>undef}],
  }],
 );
 is(scalar(@sources), scalar(@cases), 'every complete published regex example is covered');
 return unless @sources == @cases;
 my $scratch = tempdir('linkedspec-book-regex-XXXXXX', TMPDIR => 1, CLEANUP => 1);
 for my $index (0 .. $#cases) {
  my ($label, $input, $expected, $labels, $rejected_input, $expected_slots) = @{$cases[$index]};
  $labels //= ['Top', 'Done'];
  my $source = $sources[$index];
  my $name = 'BookRegex' . ($index + 1);
  my $path = File::Spec->catfile($scratch, "$name.spec");
  open my $spec_fh, '>:encoding(UTF-8)', $path or die "cannot write $path: $!";
  print {$spec_fh} $source;
  close $spec_fh or die "cannot close $path: $!";
  my $loaded = eval {
   LinkedSpec::SpecLoader::load_and_compile_spec(
    LinkedSpec::SpecLoader::name_request($name),
    LinkedSpec::SpecLoader::load_options(cwd => $scratch, search_roots => [$scratch]),
   );
  };
  my $load_error = $@;
  ok($loaded, "$label loads through the public file API") or diag($load_error);
  next unless $loaded;
  is($loaded->loaded->source_text, $source, "$label retains the exact Markdown source");
  is($loaded->loaded->resolved->path, $path, "$label retains the resolved path");
  is($loaded->runtime_ctx->{spec_path}, $path, "$label retains runtime source identity");
  my $live_input = $input;
  is_deeply($loaded->compiled->(\$live_input), $expected, "$label returns its documented value");
  is($loaded->runtime_ctx->{last_error}, undef, "$label has no deferred runtime error");
  if (defined $rejected_input) {
   my $unmatched = $rejected_input;
   is($loaded->compiled->(\$unmatched), undef, "$label does not leak I's value when the edge does not match");
   is($loaded->runtime_ctx->{last_error}, undef, "$label unmatched input is ordinary recognition failure");
  }
  my %descriptor_context;
  my $descriptor = LinkedSpec::Get(
   \$source, return_descriptor => 1, runtime_ctx_ref => \%descriptor_context,
  );
  is_deeply(
   [sort keys %{$descriptor->{spec} || {}}], [sort @$labels],
   "$label retains its authored rules in the public descriptor",
  );
  is($descriptor_context{last_error}, undef, "$label descriptor has no compile error");
  for my $rule (sort keys %{$expected_slots || {}}) {
   is_deeply($descriptor->{spec}{$rule}{meta}{regex_slots}, $expected_slots->{$rule},
    "$label retains exact named and anonymous slot identities");
  }

  my $identity = 'book/regex-example-' . ($index + 1) . '.spec';
  my $generated = capture_source($source, source_identity => $identity);
  next unless defined($generated) && length($generated);
  my $program_path = File::Spec->catfile($scratch, "$name.pl");
  open my $program, '>:encoding(UTF-8)', $program_path or die "cannot write $program_path: $!";
  print {$program} "BEGIN { alarm 60 }\n", $generated, <<'BOOK_RUNNER';

{
 require JSON::PP;
 my @book_results;
 for my $book_text (@ARGV) {
  my $book_input = $book_text;
  my $book_result = eval { Execute(\$book_input) };
  my $book_error = $@;
  if ($book_error) {
   print STDERR JSON::PP->new->canonical->encode($book_error), "\n";
   exit 1;
  }
  push @book_results, $book_result;
 }
 print JSON::PP->new->canonical->encode({
  values => \@book_results, metadata => LinkedSpecGeneratedMetadata(),
 });
}
BOOK_RUNNER
  close $program or die "cannot close $program_path: $!";
  # One captured pipe avoids stderr backpressure. Check the full wait status,
  # including signals; the child alarm also covers generated-source loading.
  my @inputs = ($input, defined($rejected_input) ? ($rejected_input) : ());
  open my $child, '-|', $^X, '-I' . File::Spec->catdir($repo_root, 'perl'), $program_path, @inputs
   or die "cannot execute $program_path: $!";
  my $output = do { local $/; <$child> };
  my $closed = close $child;
  my $status = $?;
  ok($closed && $status == 0, "$label fresh generated process exits successfully")
   or diag("wait status=$status; output=" . ($output // ''));
  my $result = eval {
   my $decoded = decode_json($output // '');
   die "expected a generated result object\n" unless ref($decoded) eq 'HASH';
   $decoded;
  };
  is($@, '', "$label fresh process returns JSON");
  next unless ref($result) eq 'HASH';
  my @expected_results = ($expected, defined($rejected_input) ? (undef) : ());
  is_deeply($result->{values}, \@expected_results, "$label fresh process returns its documented outcomes");
  is($result->{metadata}{contract_id}, 'linkedspec-generated-source-v2', "$label retains the v2 contract");
  is($result->{metadata}{format_version}, 2, "$label retains format version 2");
  is($result->{metadata}{source_identity}, $identity, "$label generated identity is exact");
  is_deeply(
   $result->{metadata}{plan},
   [map { +{label => $_, family => 'default'} } @$labels],
   "$label generated plan retains its authored rules",
  );
 }
};

subtest 'direct reads preserve state in native and fresh generated parsers' => sub {
 require Scalar::Util;
 require Cwd;
 my $read_repo_root = Cwd::abs_path($repo_root);
 my $json = JSON::PP->new->canonical->allow_nonref;
 my $clone_value = sub { $json->decode($json->encode($_[0])) };
 my @cases = (
  ['absent_array', '', 'document[0]', undef, undef],
  ['null_array', 'document = undef;', 'document[0]', undef, undef],
  ['absent_hash', '', 'document["missing"]', undef, undef],
  ['empty_hash', 'document = {};', 'document["missing"][0]', {}, undef],
  ['empty_array', 'document = [];', 'document[0][0]', [], undef],
  ['null_hash_child', 'document = {"missing":undef};', 'document["missing"][0]', {missing=>undef}, undef],
  ['null_array_child', 'document = [undef];', 'document[0][0]', [undef], undef],
  ['wrong_root', 'document = 7;', 'document[0]', 7, undef],
  ['wrong_array_kind', 'document = {};', 'document[0]', {}, undef],
  ['wrong_hash_kind', 'document = [];', 'document["missing"]', [], undef],
  ['wrong_hash_child', 'document = {"key":"scalar"};', 'document["key"]["nested"]', {key=>'scalar'}, undef],
  ['wrong_array_child', 'document = ["scalar"];', 'document[0][0]', ['scalar'], undef],
  ['present_mixed', 'document = {"list":["a","b"]};', 'document["list"][1]', {list=>['a','b']}, 'b'],
  ['existing_null_leaf', 'document = [undef];', 'document[0]', [undef], undef],
  ['out_of_range', 'document = ["a"];', 'document[9]', ['a'], undef],
  ['negative_read_index', 'document = ["a","b"];', 'document[-1]', ['a','b'], 'b'],
  ['fractional_read_index', 'document = ["a","b"];', 'document[1.9]', ['a','b'], 'b'],
  ['numeric_string_index', 'document = ["a","b"]; index = "1";', 'document[index]', ['a','b'], 'b'],
  ['single_rebind', 'document = ["old0","old1","old2"];',
   'document[set(document, ["new0","new1"]).count()]', ['new0','new1'], 'old2'],
  ['nested_rebind', 'document = [["old0","old1"]];',
   'document[0][set(document, [["new"]]).count()]', [['new']], 'old1'],
  ['single_rebind_retained', 'document = ["old0","old1","old2"]; saved = document;',
   'document[set(document, ["new0","new1"]).count()]', ['new0','new1'], 'old2'],
  ['nested_rebind_retained', 'document = [["old0","old1"]]; saved = document[0];',
   'document[0][set(document, [["new"]]).count()]', [['new']], 'old1'],
  ['temporary_name_value', 'document = ["a","b"]; __ls_read_value = 1;',
   'document[__ls_read_value]', ['a','b'], 'b'],
  ['temporary_name_index', 'document = ["a","b"]; __ls_read_index = 1;',
   'document[__ls_read_index]', ['a','b'], 'b'],
  ['temporary_name_nested', 'document = [["a","b"]]; __ls_read_value_ = [1];',
   'document[0][__ls_read_value_[0]]', [['a','b']], 'b'],
 );

 my $scratch = tempdir(CLEANUP=>1);
 my @emitted;
 for my $case (@cases) {
  my ($id,$setup,$access,$after,$expected_read) = @$case;
  my $source = "Top::\n -> Done { $setup observed = $access; return(array(document, observed)) }\nDone:\n /x/\n";
  my $expected = [$after,$expected_read];
  subtest "native $id preserves the binding" => sub {
   my %ctx;
   my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref=>\%ctx) };
   is("$@", '', 'source compiles');
   ok(ref($parser) eq 'CODE', 'parser exists');
   if (ref($parser) eq 'CODE') {
    for my $run (1,2) {
     my $input='x';
     my $value=eval { $parser->(\$input) };
     is("$@", '', "run $run has no exception");
     is_deeply($value,$expected,"run $run returns the read and unchanged binding, except authored selector effects");
     ok(!$ctx{last_error},"run $run has no handler error");
    }
   }
  };
  my $generated = eval { LinkedSpec::emit_generated_source(\$source, source_identity=>"read-purity:$id") };
  is("$@", '', "$id emits standalone source");
  if (defined($generated) && length($generated)) {
   my $path=File::Spec->catfile($scratch,"$id.pl");
   open my $fh,'>:encoding(UTF-8)',$path or die $!;
   print {$fh} $generated;
   close $fh or die $!;
   push @emitted,{id=>$id,path=>File::Spec->abs2rel($path,$read_repo_root),expected=>$expected};
  } else { fail("$id generated source is present") }
 }

 subtest 'function parameters and absent local bindings remain pure' => sub {
  my $source = <<'SPEC';
fn from_parameter(document) {
 observed = document["missing"][0];
 return([document, observed])
}
fn from_local() {
 observed = document[0];
 document["created"] = "write";
 return([document, observed])
}
Top::
 -> Done { return(array(from_parameter({}), from_parameter(undef), from_local(), from_local())) }
Done:
 /x/
SPEC
  my $expected=[[{},undef],[undef,undef],[{created=>'write'},undef],[{created=>'write'},undef]];
  my %ctx;
  my $parser=eval { LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx) };
  is("$@", '', 'function source compiles');
  ok(ref($parser) eq 'CODE','function parser exists');
  if(ref($parser) eq 'CODE') {
   my $input='x';
   is_deeply($parser->(\$input),$expected,'parameter state survives reads and later writes create fresh local roots');
   ok(!$ctx{last_error},'function calls have no handler error');
  }
  my $generated=LinkedSpec::emit_generated_source(\$source,source_identity=>'read-purity:functions');
  my $path=File::Spec->catfile($scratch,'functions.pl');
  open my $fh,'>:encoding(UTF-8)',$path or die $!;
  print {$fh} $generated;
  close $fh or die $!;
  push @emitted,{id=>'functions',path=>File::Spec->abs2rel($path,$read_repo_root),expected=>$expected};
 };

 subtest 'the included book example preserves missing and null paths' => sub {
  my $source = read_text(File::Spec->catfile($read_repo_root, 'examples', 'direct-read-purity.spec'));
  my $expected = {tree => {present => ['kept'], null => undef}, missing => undef,
   null_child => undef, wrong_kind => undef, absent => undef, document => {created => 'write'},
   null_root => undef, null_read => undef, present => 'kept'};
  for my $ending ('LF', 'CRLF') {
   my $authored = $source;
   $authored =~ s/\n/\r\n/g if $ending eq 'CRLF';
   my %ctx;
   my $parser = eval { LinkedSpec::Get(\$authored, runtime_ctx_ref => \%ctx) };
   is("$@", '', "$ending book source compiles");
   ok(ref($parser) eq 'CODE', "$ending book parser exists");
   if (ref($parser) eq 'CODE') {
    for my $run (1, 2) {
     my $input = 'x';
     my $value = eval { $parser->(\$input) };
     is("$@", '', "$ending book run $run has no exception");
     is_deeply($value, $expected, "$ending book run $run returns its documented state");
     ok(!$ctx{last_error}, "$ending book run $run has no handler error");
    }
   }
   my $generated = LinkedSpec::emit_generated_source(\$authored,
    source_identity => 'examples/direct-read-purity.spec');
   my $path = File::Spec->catfile($scratch, "book-$ending.pl");
   open my $fh, '>:encoding(UTF-8)', $path or die $!;
   print {$fh} $generated;
   close $fh or die $!;
   push @emitted, {id => "book-$ending", path => File::Spec->abs2rel($path, $read_repo_root), expected => $expected};
  }
 };

 {
  package LinkedSpec::DirectReadObservedScalar;
  sub TIESCALAR { bless {events=>$_[1],label=>$_[2],get=>$_[3],stores=>0},$_[0] }
  sub FETCH { my $s=shift; push @{$s->{events}},$s->{label}; $s->{get}->() }
  sub STORE { ++$_[0]{stores}; push @{$_[0]{events}},'STORE:'.$_[0]{label} }
 }

 subtest 'selectors run once in order and failures preserve state and identity' => sub {
  for my $case (['present',[['a']]],['missing',undef],['missing_child',[]],['null_child',[undef]],['wrong_root',7],['wrong_child',[{}]],
                 ['first_fails',[['a']]],['second_fails',[['a']]]) {
   my ($id,$initial)=@$case;
   my $document=$clone_value->($initial);
   my $identity=ref($document) ? Scalar::Util::refaddr($document) : undef;
   my ($first,$second,$observed);
   my %__ls_binding_presence=(sentinel=>1);
   my @events;
   tie $first,'LinkedSpec::DirectReadObservedScalar',\@events,'first',sub {die "first failed\n" if $id eq 'first_fails'; 0};
   tie $second,'LinkedSpec::DirectReadObservedScalar',\@events,'second',sub {die "second failed\n" if $id eq 'second_fails'; 0};
   my $lowered=LinkedSpec::call_spec_handler_subst('Top',q{observed = document[first][second]});
   my $value=eval $lowered;
   my $error="$@";
   is_deeply(\@events,$id eq 'first_fails' ? ['first'] : ['first','second'],"$id selector count/order");
   is($error,$id=~/^(first|second)_fails$/ ? "$1 failed\n" : '',"$id preserves selector exception");
   is_deeply($document,$initial,"$id does not mutate the binding");
   is(ref($document) ? Scalar::Util::refaddr($document) : undef,$identity,"$id preserves root identity");
   is_deeply(\%__ls_binding_presence,{sentinel=>1},"$id preserves binding presence");
   is($value,$id eq 'present' ? 'a' : undef,"$id returns the selected value");
  }
 };

 subtest 'root observation never stores or substitutes a reference' => sub {
  for my $initial (undef,[],{}, {child=>['a']}) {
   my @events;
   my $document;
   my $slot=tie $document,'LinkedSpec::DirectReadObservedScalar',\@events,'root',sub { $initial };
   my $observed;
   my $before=$clone_value->($initial);
   my $lowered=LinkedSpec::call_spec_handler_subst('Top',q{observed = document["child"][0]});
   my $value=eval $lowered;
   is("$@",'','tied root read has no exception');
   is($slot->{stores},0,'no STORE occurs');
   is_deeply(\@events,['root'],'root is observed once');
   is_deeply($initial,$before,'referenced container remains unchanged');
  }
  my $child=['a'];
  my $document={child=>$child};
  my $observed;
  my $lowered=LinkedSpec::call_spec_handler_subst('Top',q{observed = document["child"]});
  my $value=eval $lowered;
  is("$@",'','container-valued leaf read succeeds');
  is(Scalar::Util::refaddr($value),Scalar::Util::refaddr($child),'read preserves selected reference identity');
  is(Scalar::Util::refaddr($document->{child}),Scalar::Util::refaddr($child),'root retains the same child');
 };

 subtest 'fresh process executes standalone generated parsers twice' => sub {
  my $manifest=File::Spec->catfile($scratch,'manifest.json');
  open my $fh,'>',$manifest or die $!;
  print {$fh} $json->encode(\@emitted);
  close $fh or die $!;
  my $runner=File::Spec->catfile($scratch,'runner.pl');
  open my $run_fh,'>',$runner or die $!;
  print {$run_fh} <<'READ_PURITY_RUNNER';
use strict;
use warnings;
use JSON::PP ();
use File::Spec ();
my $json=JSON::PP->new->canonical->allow_nonref;
open my $fh,'<',$ARGV[0] or die $!;
my $cases=$json->decode(do {local $/; <$fh>});
close $fh;
my @rows;
for my $index (0..$#$cases) {
 my $case=$cases->[$index];
 open my $source_fh,'<:encoding(UTF-8)',File::Spec->catfile($ARGV[2],$case->{path}) or die $!;
 my $source=do {local $/; <$source_fh>};
 close $source_fh;
 my $package="LinkedSpec::DirectReadEmitted::Case$index";
 my $loaded=eval "package $package; $source; 1";
 my $row={load_error=>"$@",runs=>[]};
 if($loaded) {
  for(1,2) {
   my $input='x';
   my $value=eval {no strict 'refs'; &{"${package}::Execute"}(\$input)};
   push @{$row->{runs}},{value=>$value,error=>"$@"};
  }
 }
 push @rows,$row;
}
open my $out,'>',$ARGV[1] or die $!;
print {$out} $json->encode(\@rows);
close $out or die $!;
READ_PURITY_RUNNER
  close $run_fh or die $!;
  my $output=File::Spec->catfile($scratch,'results.json');
  my $status=system($^X,'-I'.File::Spec->catdir($read_repo_root,'perl'),$runner,$manifest,$output,$read_repo_root);
  is($status,0,'fresh generated-source child exits successfully');
  if(open my $result,'<',$output) {
   my $rows=$json->decode(do {local $/; <$result>});
   close $result;
   is(scalar(@$rows),scalar(@emitted),'every emitted fixture returned observations');
   for my $index (0..$#emitted) {
    my $row=$rows->[$index];
    my $case=$emitted[$index];
    is($row->{load_error},'',"$case->{id} loads independently");
    for my $run (0,1) {
     is($row->{runs}[$run]{error},'',"$case->{id} emitted run $run has no exception");
     is_deeply($row->{runs}[$run]{value},$case->{expected},"$case->{id} emitted run $run preserves state");
    }
   }
  } else { fail('fresh child wrote complete observations') }
 };

 done_testing;
};

subtest 'function array constructors read values in native and fresh generated parsers' => sub {
 require Cwd;
 my $root = Cwd::abs_path($repo_root);
 my $scratch = tempdir(CLEANUP => 1);
 my $json = JSON::PP->new->canonical->allow_nonref;
 my $source = <<'SPEC';
fn pack(value) { return(array(value, value)) }
fn literal(value) { return([value, value]) }
fn local_pack(value) { local = value; return(array(local, value)) }
fn nested(value) { return(array(array(value, undef), [value], pack(value), {"kept":value})) }
fn mixed(value) { return(array("value", value, 0, true, false, undef, trim(value))) }
fn collect(prefix, ...items) { return(array(prefix, items)) }
fn helpers(items, meta) { return([count(items), first(items), count_keys(meta), copy(items), copy(meta)]) }
fn ordered(value) { return(array(set(value, 1), set(value, 2), value)) }
fn retained() { return([array(), array("literal"), array(trim(" x "))]) }
fn final_value(value) { array(value, value) }
Top::
 -> Done {
  value = "caller"
  local = "outer"
  return({
   "parameter":pack(7), "literal":literal(7), "local":local_pack(8),
   "null":pack(undef), "false":pack(false), "container":pack({"k":[1]}),
   "nested":nested("x"), "mixed":mixed(" x "),
   "rest":collect("p", 1, 2), "empty_rest":collect("q"),
   "helpers":helpers([3,1,2], {"a":1}), "ordered":ordered(0),
   "retained":retained(), "final":final_value(9),
   "repeat":array(local_pack("first"), local_pack("second")),
   "caller":array(value, local)
  })
 }
Done:
 /x/
SPEC
 my $expected = {
  parameter => [7,7], literal => [7,7], local => [8,8], null => [undef,undef],
  false => [JSON::PP::false,JSON::PP::false], container => [{k=>[1]},{k=>[1]}],
  nested => [['x',undef],['x'],['x','x'],{kept=>'x'}],
  mixed => ['value',' x ',0,JSON::PP::true,JSON::PP::false,undef,'x'],
  rest => ['p',[1,2]], empty_rest => ['q',[]],
  helpers => [3,3,1,[3,1,2],{a=>1}], ordered => [1,2,2],
  retained => [[],['literal'],['x']], final => [9,9],
  repeat => [['first','first'],['second','second']], caller => ['caller','outer'],
 };
 my $book = read_text(File::Spec->catfile($root, 'examples', 'function-array-values.spec'));
 my $book_expected = [[7,7],['tag','x',['x','x']],[undef,undef]];
 my @cases = ({id=>'matrix', source=>$source, expected=>$expected});
 for my $ending ('LF','CRLF') {
  my $authored = $book;
  $authored =~ s/\n/\r\n/g if $ending eq 'CRLF';
  push @cases, {id=>"book-$ending", source=>$authored, expected=>$book_expected};
 }
 my @artifacts;
 for my $case (@cases) {
  subtest "native $case->{id}" => sub {
   my %ctx;
   my $parser = eval { LinkedSpec::Get(\$case->{source}, runtime_ctx_ref=>\%ctx) };
   is("$@", '', 'Get does not throw');
   ok(ref($parser) eq 'CODE', 'Get returns a parser');
   if (ref($parser) eq 'CODE') {
    for my $run (1,2) {
     my $input = 'x';
     my $value = eval { $parser->(\$input) };
     is("$@", '', "run $run does not throw");
     is_deeply($value, $case->{expected}, "run $run returns argument values and preserves function scope");
     ok(!$ctx{last_error}, "run $run has no handler error");
    }
   }
  };
  my $generated = LinkedSpec::emit_generated_source(\$case->{source},
   source_identity=>"function-array:$case->{id}");
  unlike($generated, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, "$case->{id} has no unresolved helper");
  my $path = File::Spec->catfile($scratch, "$case->{id}.pl");
  open my $fh, '>:encoding(UTF-8)', $path or die $!;
  print {$fh} $generated;
  close $fh or die $!;
  push @artifacts, File::Spec->abs2rel($path,$root);
 }

 my $runner = File::Spec->catfile($scratch,'runner.pl');
 open my $runner_fh, '>', $runner or die $!;
 print {$runner_fh} <<'FUNCTION_ARRAY_RUNNER';
use strict;
use warnings;
use File::Spec ();
use JSON::PP ();
my ($root,$output,@artifacts) = @ARGV;
my @rows;
for my $index (0..$#artifacts) {
 open my $fh, '<:encoding(UTF-8)', File::Spec->catfile($root,$artifacts[$index]) or die $!;
 my $source = do { local $/; <$fh> };
 close $fh or die $!;
 my $package = "LinkedSpec::FunctionArrayEmitted::Case$index";
 my $loaded = eval "package $package; $source; 1";
 my $row = {load_error=>"$@", runs=>[]};
 if ($loaded) {
  for (1,2) {
   my $input = 'x';
   my $value = eval { no strict 'refs'; &{"${package}::Execute"}(\$input) };
   push @{$row->{runs}}, {value=>$value, error=>"$@"};
  }
 }
 push @rows,$row;
}
open my $out,'>',$output or die $!;
print {$out} JSON::PP->new->canonical->allow_nonref->encode(\@rows);
close $out or die $!;
FUNCTION_ARRAY_RUNNER
 close $runner_fh or die $!;
 my $output = File::Spec->catfile($scratch,'results.json');
 is(system($^X,'-I'.File::Spec->catdir($root,'perl'),$runner,$root,$output,@artifacts),
  0,'fresh generated-source child exits successfully');
 if (-f $output) {
  my $rows = $json->decode(read_text($output));
  is(scalar(@$rows),scalar(@cases),'fresh process returns every case');
  for my $index (0..$#cases) {
   my $case = $cases[$index];
   my $row = $rows->[$index];
   is($row->{load_error},'',"$case->{id} loads independently");
   for my $run (0,1) {
    is($row->{runs}[$run]{error},'',"$case->{id} emitted run $run does not throw");
    is_deeply($row->{runs}[$run]{value},$case->{expected},"$case->{id} emitted run $run returns argument values");
   }
  }
 } else { fail('fresh process wrote its observations') }
};

done_testing;
