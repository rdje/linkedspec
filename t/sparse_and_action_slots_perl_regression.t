#!/usr/bin/env perl
use strict;
use warnings;

use File::Basename qw(dirname);
use File::Spec;
use JSON::PP qw(decode_json);
use Test::More;

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 unshift @INC, File::Spec->catdir($repo_root, 'perl');
}

use LinkedSpec;

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $corpus_root = File::Spec->catdir(
 $repo_root,
 qw(rust linkedspec-runtime tests corpus),
);
my $generated_package = 0;

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return defined($bytes) ? $bytes : ''
}

sub execute {
 my ($parser, $input_text) = @_;
 my $input = $input_text;
 my $value = $parser->(\$input);
 return ($value, pos($input))
}

sub load_generated_parser {
 my ($source) = @_;
 my $package = 'LinkedSpec::SparseAndRegression::Generated' . ++$generated_package;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, 'generated source loads in an isolated package') or diag($error);
 no strict 'refs';
 return *{"${package}::Execute"}{CODE}
}

for my $case (qw(capability_capture_anonymous_surface capability_capture_named_surface)) {
 subtest $case => sub {
  my $fixture_dir = File::Spec->catdir($corpus_root, $case);
  my $spec = read_bytes(File::Spec->catfile($fixture_dir, 'input.spec'));
  my $input = read_bytes(File::Spec->catfile($fixture_dir, 'input.txt'));
  my $expected = decode_json(read_bytes(File::Spec->catfile($fixture_dir, 'expected.json')));

  ok(defined($expected), 'governed oracle output is not null');

  my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
  is_deeply(
   [map { $_->{regex_index} } @{$descriptor->{spec}{Value}{meta}{resolved_edges}}],
   [0, 2],
   'descriptor retains sparse authored action slots zero and two',
  );
  is(
   scalar(@{$descriptor->{spec}{Value}{re}}),
   3,
   'descriptor retains the non-action middle structural regex slot',
  );

  my $live_parser = LinkedSpec::Get(\$spec);
  my ($live_value, $live_position) = execute($live_parser, $input);
  is_deeply($live_value, $expected, 'live parser preserves the governed capture value');
  is($live_position, length($input), 'live parser consumes all three structural slots');

  my $generated_source = LinkedSpec::emit_generated_source(
   \$spec,
   source_identity => "sparse-and/$case.spec",
  );
  like($generated_source, qr/while \(\$idx < 3\)/, 'generated handler traverses all structural slots');
  like($generated_source, qr/acode_index_0/, 'generated handler dispatches authored action slot zero');
  unlike($generated_source, qr/acode_index_1/, 'generated handler does not invent an action for the middle slot');
  like($generated_source, qr/acode_index_2/, 'generated handler dispatches authored action slot two');

  my $generated_parser = load_generated_parser($generated_source);
  my ($generated_value, $generated_position) = execute($generated_parser, $input);
  is_deeply($generated_value, $expected, 'standalone generated parser preserves the governed capture value');
  is($generated_position, length($input), 'standalone generated parser consumes all three structural slots');
 };
}

subtest 'repeated AND expands generated structural slots around one sparse action' => sub {
 my $spec = <<'SPEC';
Top::AND{1}
 /A/
 /xxB/
 /C/
 -> Top[2] { return("done") }
SPEC
 my $input = 'AxxBC';

 my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
 is(
  $descriptor->{spec}{Top}{meta}{selected_handler_variant},
  'REP_AND_ACODE',
  'fixture selects the repeated ordered-action handler',
 );
 is_deeply(
  [map { $_->{regex_index} } @{$descriptor->{spec}{Top}{meta}{resolved_edges}}],
  [2],
  'descriptor retains the one authored action at structural slot two',
 );

 my $live_parser = LinkedSpec::Get(\$spec);
 my ($live_value, $live_position) = execute($live_parser, $input);
 is_deeply($live_value, ['done'], 'live repeated AND returns the sparse action value');
 is($live_position, length($input), 'live repeated AND consumes all structural slots');

 my $generated_source = LinkedSpec::emit_generated_source(
  \$spec,
  source_identity => 'sparse-and/repeated-single-action.spec',
 );
 like($generated_source, qr/while \(\$idx < 3\)/, 'generated repeated handler traverses all structural slots');
 unlike(
  $generated_source,
  qr/\$\$minfo\{index\} == [01]/,
  'generated repeated handler invents no earlier action',
 );
 like(
  $generated_source,
  qr/\$\$minfo\{index\} == 2/,
  'generated repeated handler dispatches structural slot two',
 );

 my $generated_parser = load_generated_parser($generated_source);
 my ($generated_value, $generated_position) = execute($generated_parser, $input);
 is_deeply($generated_value, ['done'], 'standalone generated repeated AND returns the sparse action value');
 is($generated_position, length($input), 'standalone generated repeated AND consumes all structural slots');
};

done_testing();
