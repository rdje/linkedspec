use strict;
use warnings;
use Cwd qw(abs_path);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use IO::Select;
use IPC::Open3 qw(open3);
use JSON::PP ();
use MIME::Base64 qw(decode_base64 encode_base64);
use Symbol qw(gensym);

my $observe = 0;
if (@ARGV) {
 die "usage: knowledge_map_header_lists.t [--observe]\n" unless @ARGV == 1 && $ARGV[0] eq '--observe';
 $observe = 1;
}
my $root = abs_path('.');
die "run through tools/project_data_run.sh from the repository root\n"
 unless $ENV{LINKEDSPEC_RUN_ACTIVE} && $ENV{TMPDIR}
 && (stat($root))[0] == (stat($ENV{TMPDIR}))[0];
my $scratch = tempdir('knowledge-header-XXXXXXXX', DIR => $ENV{TMPDIR}, CLEANUP => 1);
my $json = JSON::PP->new->canonical;

sub command {
 my (@args) = @_;
 my $error = gensym;
 my $pid = open3(undef, my $output, $error, @args);
 my $readers = IO::Select->new($output, $error);
 my %name = (fileno($output) => 'stdout', fileno($error) => 'stderr');
 my %bytes = (stdout => '', stderr => '');
 while ($readers->count) {
  for my $reader ($readers->can_read) {
   my $count = sysread($reader, my $buffer, 65536);
   die "read command: $!" unless defined $count;
   if ($count) { $bytes{$name{fileno($reader)}} .= $buffer }
   else { $readers->remove($reader); close $reader }
  }
 }
 waitpid($pid, 0);
 return {status => $?, map {($_.'_base64', encode_base64($bytes{$_}, ''))} qw(stdout stderr)};
}
sub write_bytes {
 open my $file, '>:raw', $_[0] or die "write $_[0]: $!";
 print {$file} $_[1];
 close $file or die "close $_[0]: $!";
}
my $base = "id: sample\ntitle: Sample\ndate: 2026-10-12\n";
my $answers = "answers:\n  - first question\n  - second question\n";
my @cases = (
 ['scalar', $base.$answers."reverify: printf ok\n", 'valid'],
 ['quoted-scalar', $base.$answers."reverify: \"printf ok\"\n", 'valid'],
 ['inline-answers', $base."answers: [first question, second question]\nevidence: source.md\n", 'valid'],
 ['block-tags', $base.$answers."tags:\n  - alpha\n  - beta\nevidence: source.md\n", 'valid'],
 ['inline-tags', $base.$answers."tags: [alpha, beta]\nevidence: source.md\n", 'valid'],
 ['block-evidence', $base.$answers."evidence:\n  - first.md\n  - second.md\n", 'valid'],
 ['block-reverify', $base.$answers."reverify:\n  - printf ok\n", 'valid'],
 ['block-after-comments', $base."answers:\n# questions\n\n  - first question\nevidence: source.md\n", 'valid'],
 ['comma-question', $base."answers:\n  - \"where is alpha, beta\"\nevidence: source.md\n", 'valid'],
 ['orphan-after-reverify', $base.$answers."reverify: printf ok\n  - discarded command\n", 'orphan'],
 ['orphan-after-evidence', $base.$answers."evidence: source.md\n  - discarded source\n", 'orphan'],
 ['orphan-after-inline-tags', $base.$answers."tags: [alpha, beta]\n  - discarded tag\nevidence: source.md\n", 'orphan'],
 ['orphan-before-key', "  - detached item\n".$base.$answers."evidence: source.md\n", 'orphan'],
 ['orphan-after-inline-answers', $base."answers: [first question]\n  - detached question\nevidence: source.md\n", 'orphan'],
 ['orphan-after-scalar-answers', $base."answers: first question\n  - detached question\nevidence: source.md\n", 'orphan'],
 ['missing-title', "id: sample\ndate: 2026-10-12\n".$answers."evidence: source.md\n", 'required'],
 ['nonfact', "title: ordinary metadata\n", 'valid'],
 ['empty-answers', "answers: []\n", 'valid'],
);
open my $old, '<:raw', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json' or die $!;
my $census = do { local $/; $json->decode(<$old>) };
close $old;
for my $row (@{$census->{rows}}) {
 next unless @{$row->{orphan_items}};
 my $text = decode_base64($row->{header_base64});
 $text =~ s/\A---\n//;
 $text =~ s/\n---\n?\z/\n/;
 my (undef, undef, $filename) = File::Spec->splitpath($row->{path});
 push @cases, ['historical-'.$filename, $text, 'orphan'];
}
my @rows;
for my $index (0 .. $#cases) {
 my ($name, $header, $kind) = @{$cases[$index]};
 my $directory = File::Spec->catdir($scratch, "case-$index");
 make_path($directory);
 write_bytes(File::Spec->catfile($directory, 'fact.md'), "---\n".$header."---\n\nBody is not metadata.\n");
 local $ENV{KM_SCAN_DIRS} = File::Spec->abs2rel($directory, $root);
 local $ENV{KM_OUTPUT} = File::Spec->abs2rel(File::Spec->catfile($scratch, "map-$index.md"), $root);
 my $generate = command('bash', 'knowledge-map/scripts/gen_knowledge_map.sh');
 my $check = command('bash', 'knowledge-map/scripts/check_knowledge_map.sh');
 push @rows, {name => $name, kind => $kind, header_base64 => encode_base64($header, ''),
   generate => $generate, check => $check};
}
if ($observe) {
 print $json->encode({rows => \@rows}), "\n";
 exit 0;
}
require Test::More;
for my $row (@rows) {
 my $name = $row->{name};
 Test::More::is($row->{generate}{status}, 0, "$name generator prepares its actual map");
 Test::More::is(decode_base64($row->{check}{stdout_base64}), '', "$name checker keeps stdout empty");
 my $stderr = decode_base64($row->{check}{stderr_base64});
 if ($row->{kind} eq 'valid') {
  Test::More::is($row->{check}{status}, 0, "$name remains accepted");
  Test::More::is($stderr, "knowledge-map: OK (facts valid, ids unique, map in sync)\n", "$name has the exact success diagnostic");
 } else {
  Test::More::isnt($row->{check}{status}, 0, "$name is rejected");
  Test::More::like($stderr, $row->{kind} eq 'orphan' ? qr/front-matter orphan list item at line \d+/ : qr/missing required front-matter: title/,
   "$name reports the distinguishing reason");
 }
}
Test::More::done_testing();
