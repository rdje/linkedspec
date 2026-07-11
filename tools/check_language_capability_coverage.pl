#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Find qw(find);
use File::Spec;
use JSON::PP qw(decode_json);

my $repo_root = abs_path(File::Spec->catdir(dirname(__FILE__), '..'));
my $report_only = 0;
for my $arg (@ARGV) {
 if ($arg eq '--report') {
  $report_only = 1;
  next;
 }
 fail("unknown argument '$arg'");
}

sub fail {
 my ($message) = @_;
 die "language-capability-coverage: ERROR: $message\n";
}

sub read_text {
 my ($relative) = @_;
 my $path = File::Spec->catfile($repo_root, split m{/}, $relative);
 open my $fh, '<:raw', $path or fail("cannot read $relative: $!");
 local $/;
 my $text = <$fh>;
 close $fh or fail("cannot close $relative: $!");
 return $text;
}

sub dart_names {
 my $text = read_text('dart/lib/src/action/action_contracts.dart');
 my @names;
 for my $constant (qw(supportedActionIrCallNames numericAliasActionIrCallNames currentAliasActionIrCallNames)) {
  $text =~ /const \Q$constant\E = <String>\{(.*?)\n\};/s
   or fail("cannot locate Dart $constant");
  push @names, $1 =~ /'([^']+)'/g;
 }
 return sort @names;
}

sub julia_names {
 my $text = read_text('julia/src/action/ActionContracts.jl');
 my @names;
 for my $constant (qw(_SUPPORTED_ACTION_IR_CALL_NAMES _NUMERIC_ALIAS_ACTION_IR_CALL_NAMES _CURRENT_ALIAS_ACTION_IR_CALL_NAMES)) {
  $text =~ /const \Q$constant\E = Set\{String\}\(\[(.*?)\n\]\)/s
   or fail("cannot locate Julia $constant");
  push @names, $1 =~ /"([^"]+)"/g;
 }
 return sort @names;
}

my @dart = dart_names();
my @julia = julia_names();
fail('Dart and Julia current ActionIR call-name inventories differ')
 unless join("\0", @dart) eq join("\0", @julia);

my %seen;
for my $name (@dart) {
 fail("duplicate current call name '$name'") if $seen{$name}++;
}

my $book_source = '';
my $book_root = File::Spec->catdir($repo_root, 'docs', 'linkedspec-book', 'src');
find(
 sub {
  return unless -f $_ && $_ =~ /\.md\z/;
  open my $fh, '<:raw', $File::Find::name or fail("cannot read $File::Find::name: $!");
  local $/;
  $book_source .= <$fh> . "\n";
  close $fh or fail("cannot close $File::Find::name: $!");
 },
 $book_root,
);
my $manifest = decode_json(read_text('rust/linkedspec-runtime/tests/corpus/manifest.json'));
fail('oracle manifest cases must be an array') unless ref($manifest->{cases}) eq 'ARRAY';
my $corpus_source = '';
for my $case (@{$manifest->{cases}}) {
 fail('oracle manifest case must be a non-empty string') if ref($case) || !defined($case) || $case eq '';
 $corpus_source .= read_text("rust/linkedspec-runtime/tests/corpus/$case/input.spec");
 $corpus_source .= "\n";
}

my (@missing_book, @missing_corpus);
for my $name (@dart) {
 my $quoted = quotemeta($name);
 my $word_prefix = $name =~ /^[A-Za-z_]/ ? '\\b' : '';
 my $word_suffix = $name =~ /[A-Za-z0-9_]\z/ ? '\\b' : '';
 push @missing_book, $name unless $book_source =~ /$word_prefix$quoted$word_suffix/;
 my $corpus_pattern = $name eq 'otherwise'
  ? qr/$word_prefix$quoted$word_suffix/
  : qr/$word_prefix$quoted\s*\(/;
 push @missing_corpus, $name unless $corpus_source =~ $corpus_pattern;
}

if ($report_only) {
 printf "language-capability-coverage: REPORT (%d current call names; %d neutral fixtures)\n",
  scalar(@dart), scalar(@{$manifest->{cases}});
 printf "  missing from mdBook: %d%s\n", scalar(@missing_book),
  @missing_book ? ' (' . join(', ', @missing_book) . ')' : '';
 printf "  missing from neutral corpus source: %d%s\n", scalar(@missing_corpus),
  @missing_corpus ? ' (' . join(', ', @missing_corpus) . ')' : '';
 exit 0;
}

fail('current call names missing from the mdBook: ' . join(', ', @missing_book)) if @missing_book;
fail('current call names missing from neutral corpus source: ' . join(', ', @missing_corpus)) if @missing_corpus;

printf "language-capability-coverage: OK (%d current call names documented and present in %d neutral fixtures)\n",
 scalar(@dart), scalar(@{$manifest->{cases}});
