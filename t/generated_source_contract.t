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

subtest 'neutral direct result, deterministic source, metadata, trace, and errors' => sub {
 my $spec = read_text(File::Spec->catfile($fixture_dir, 'input.spec'));
 my $input = read_text(File::Spec->catfile($fixture_dir, 'input.txt'));
 my $expected = decode_json(read_text(File::Spec->catfile($fixture_dir, 'expected.json')));
 my $identity = 'generated-source/default-action-result.spec';

 my $normal_input = $input;
 my $normal = LinkedSpec::Get(\$spec, parse_mode => 'consume')->(\$normal_input);
 is_deeply($normal, $expected, 'normal generated Perl parser satisfies the neutral expected value');

 my $source = capture_source(
  $spec,
  parse_mode => 'consume',
  generated_source_identity => $identity,
 );
 my $source_again = capture_source(
  $spec,
  parse_mode => 'consume',
  generated_source_identity => $identity,
 );
 is($source_again, $source, 'same compiled input and identity emit deterministic source');
 my $legacy_source = '';
 my $legacy_result = LinkedSpec::Get(
  \$spec,
  parse_mode => 'consume',
  generate_only => 1,
  dump_parser_source => 1,
  parser_source_ref => \$legacy_source,
  generated_source_identity => $identity,
 );
 is($legacy_result, undef, 'legacy generate-only capture keeps its return contract');
 is($legacy_source, $source, 'public emitter and legacy capture return identical source');
 like($source, qr/contract_id: linkedspec-generated-source-v1/, 'source carries contract marker');
 like($source, qr/format_version: 1/, 'source carries format marker');
 like($source, qr/our \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY = '\Q$identity\E'/, 'source carries quoted identity');
 like($source, qr/LinkedRE::oredRE\(/, 'source reconstructs indexed dependency alternation');
 unlike($source, qr/dependency_regex_map.*=>\s*qr\/.*\(\?\{\$pos=/s, 'source does not stringify indexed dependency regex state');

 my $module = load_generated_source($source, 'Direct');
 ok(ref($module->{execute}) eq 'CODE', 'generated source exposes execute role');
 ok(ref($module->{execute_with_trace}) eq 'CODE', 'generated source exposes execute-with-trace role');
 ok(ref($module->{validate_plan}) eq 'CODE', 'generated source exposes plan validation');

 my $metadata = $module->{metadata}->();
 is($metadata->{contract_id}, 'linkedspec-generated-source-v1', 'metadata reports contract id');
 is($metadata->{format_version}, 1, 'metadata reports format version');
 is($metadata->{source_identity}, $identity, 'metadata reports exact source identity');
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
  parse_mode => 'consume',
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
  my $normal = LinkedSpec::Get(\$spec, parse_mode => 'consume')->(\$normal_input);
  my $generated_input = $text;
  my $generated = $module->{execute}->(\$generated_input);
  is_deeply($normal, $expected, "$label normal result is exact");
  is_deeply($generated, $expected, "$label generated result is exact");
 }
};

done_testing;
