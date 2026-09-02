use strict;
use warnings;

use FindBin qw($Bin);
use File::Spec;
use JSON::PP qw(decode_json);
use Test::More;

sub slurp_text {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $text = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $text
}

sub match_count {
 my ($text, $pattern) = @_;
 my @matches = $text =~ /$pattern/g;
 return scalar @matches
}

my $root = File::Spec->catdir($Bin, '..');
my $zero_root_edge = qr/^\h*->\h*Done\b/m;
my $inert_root_edge = qr/^\h*\/x\/\h*->\h*Done\b/m;

my $generator = slurp_text(File::Spec->catfile($root, 'tools', 'gen_oracle_corpus.pl'));
is(
 match_count($generator, $zero_root_edge),
 68,
 'all 68 inline controlled wrappers dispatch from a zero-regex root',
);
is(
 match_count($generator, $inert_root_edge),
 0,
 'the generator contains no inert root /x/ before a Done edge',
);

my $marker_source = slurp_text(File::Spec->catfile(
 $root,
 'capability_conformance',
 'fixtures',
 'capability_control_marker_surface.spec',
));
is(
 match_count($marker_source, $zero_root_edge),
 1,
 'the source-backed controlled wrapper dispatches from a zero-regex root',
);
is(
 match_count($marker_source, $inert_root_edge),
 0,
 'the source-backed controlled wrapper contains no inert root /x/',
);

my $corpus_root = File::Spec->catdir(
 $root,
 'rust',
 'linkedspec-runtime',
 'tests',
 'corpus',
);
my $manifest = decode_json(slurp_text(File::Spec->catfile($corpus_root, 'manifest.json')));
is($manifest->{case_count}, 105, 'the governed corpus still contains 105 fixtures');

my @legacy_cases;
my @zero_root_cases;
for my $case (@{$manifest->{cases}}) {
 my $source = slurp_text(File::Spec->catfile($corpus_root, $case, 'input.spec'));
 push @legacy_cases, $case if match_count($source, $inert_root_edge);
 push @zero_root_cases, $case if match_count($source, $zero_root_edge);
}

is_deeply(
 \@legacy_cases,
 [],
 'the committed corpus contains no controlled wrapper with an inert root /x/',
);
cmp_ok(
 scalar(@zero_root_cases),
 '>=',
 69,
 'the committed corpus includes every rewritten inline and source-backed zero-regex wrapper',
);

done_testing();
