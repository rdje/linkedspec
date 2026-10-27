use strict;
use warnings;
use utf8;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.1.5: execute the actual corrected book sources.
my $json = JSON::PP->new->canonical;
my @cases = (
 {
  path => 'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
  marker => 'Worked example: entry versus local match.',
  expected => [{
   entry_end=>4,entry_groups=>['name'],entry_map=>{head=>'name'},entry_named=>'name',
   entry_start=>0,entry_text=>'name',local_end=>10,local_groups=>['Alpha'],
   local_map=>{value=>'Alpha'},local_named=>'Alpha',local_start=>5,
   local_text=>'Alpha',separator=>'=',
  }],
 },
 {
  path => 'docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md',
  marker => '## Entry versus match example',
  expected => [{
   entry_text=>'name',entry_name=>'name',local_text=>'Alpha',local_name=>'Alpha',
   entry_group_count=>1,local_group_count=>1,separator=>'=',
  }],
 },
 {
  path => 'docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md',
  marker => '## When `entry_*` and `match_*` diverge',
  expected => [{
   entry_text=>'name',entry_name=>'name',local_text=>'Alpha',local_name=>'Alpha',separator=>'=',
  }],
 },
);

my $sequence = 0;
for my $case (@cases) {
 my $path = $case->{path};
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 my $text = do {local $/; <$file>};
 $text =~ s/^> ?//mg;
 my $position = index($text,$case->{marker});
 die "missing marker in $path\n" if $position < 0;
 my ($source) = substr($text,$position) =~ /```text\n(.*?)\n```/s;
 die "missing source in $path\n" unless defined($source);

 my %context;
 my $parser = LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input = 'name=Alpha';
 my $actual = $parser->(\$input);
 die "native example failure in $path: ".$json->encode($actual)."\n"
  if $context{last_error} || $json->encode($actual) ne $json->encode($case->{expected});

 my $emitted = LinkedSpec::emit_generated_source(\$source,source_identity=>'capture-doc-example.spec');
 my $package = 'LinkedSpec::CaptureDocExample'.++$sequence;
 eval "package $package; $emitted;1" or die $@;
 $input = 'name=Alpha';
 my $fresh;
 {
  no strict 'refs';
  $fresh = &{$package.'::Execute'}(\$input);
 }
 die "fresh example failure in $path\n"
  unless $json->encode($fresh) eq $json->encode($case->{expected});
 print "PASS native/fresh $path\n";
}
