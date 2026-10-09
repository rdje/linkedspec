use v5.20;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $JSON = JSON::PP->new->canonical(1);
my $INDEX_MODE = 1;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-';
my $adr = 'docs/decisions/0130-finite-engineering-notes-aggregate.md';
sub raw {
 open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
 local $/;
 return <$fh>;
}
my $source = raw('scripts/check_readme_routing_pressure.pl');
my $code = '';
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_is_accepted adr_authorizes_limit_change)) {
 $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "actual function missing: $name";
 $code .= $1;
}
eval $code;
die $@ if $@;
my $plan = $JSON->decode(raw($prefix.'plan.json'));
my %files = map {$_ => raw($_)} ($adr, 'docs/decisions/INDEX.md');
my @adrs = ($adr);
sub staged_new_adrs { return @adrs }
sub snapshot_content { return $files{$_[0]} }
my %measured;
for my $surface (qw(engineering_notes decisions)) {
 my @paths = $surface eq 'decisions' ? glob('docs/decisions/*.md')
  : ('DEVELOPMENT_NOTES.md', glob('docs/history/development-notes/*.md'), 'docs/history/development-notes/manifest.jsonl');
 my ($lines, $bytes) = (0, 0);
 for my $path (@paths) {
  my $raw = raw($path);
  $lines += () = $raw =~ /\n/g;
  $bytes += length($raw);
 }
 $measured{$surface} = {files=>scalar(@paths), lines=>$lines, bytes=>$bytes};
}
my @thresholds;
for my $surface (qw(engineering_notes decisions)) {
 my $old = $plan->{old_limits}{$surface}{max_total_lines};
 my $new = $plan->{new_limits}{$surface}{max_total_lines};
 for my $value ($measured{$surface}{lines}, $new, $new+1) {
  for my $limit ($old, $new) {
   my @errors = exceeds_limits({lines=>$value}, {max_total_lines=>$limit});
   die 'independent aggregate threshold disagrees' if !!@errors != ($value > $limit);
   push @thresholds, {surface=>$surface, value=>$value, limit=>$limit, rejected=>@errors ? JSON::PP::true : JSON::PP::false, reasons=>\@errors};
  }
 }
}
my %original = %files;
my @authority;
for my $surface (qw(engineering_notes decisions)) {
 my $check = sub {adr_authorizes_limit_change($surface, $plan->{old_limits}{$surface}, $plan->{new_limits}{$surface})};
 die "exact positive authority: $surface" unless $check->();
 for my $case (qw(missing_new_record missing_index proposed_status missing_status duplicate_status wrong_old_limits wrong_new_limits)) {
  %files = %original; @adrs = ($adr);
  if ($case eq 'missing_new_record') {@adrs = ()}
  elsif ($case eq 'missing_index') {$files{'docs/decisions/INDEX.md'} = ''}
  elsif ($case eq 'proposed_status') {$files{$adr} =~ s/^- Status:.*$/- Status: proposed/m or die 'status mutation'}
  elsif ($case eq 'missing_status') {$files{$adr} =~ s/^- Status:.*\n//m or die 'status mutation'}
  elsif ($case eq 'duplicate_status') {$files{$adr} .= "\n- Status: accepted\n"}
  else {
   my $marker = $case eq 'wrong_old_limits' ? 'Previous routed limits' : 'New routed limits';
   my $value = $case eq 'wrong_old_limits' ? $plan->{old_limits}{$surface} : $plan->{new_limits}{$surface};
   my $exact = '- '.$marker.': `'.$JSON->encode($value).'`';
   $files{$adr} =~ s/^\Q$exact\E$//m or die 'exact surface marker mutation';
  }
  die "authority corruption admitted: $surface/$case" if $check->();
  push @authority, {surface=>$surface, name=>$case, observed=>'RED'};
 }
 %files = %original; @adrs = ($adr);
 die 'unreviewed increase admitted' if limit_change_permitted($plan->{old_limits}{$surface}, $plan->{new_limits}{$surface}, 0);
 die 'reviewed increase denied' unless limit_change_permitted($plan->{old_limits}{$surface}, $plan->{new_limits}{$surface}, 1);
 push @authority, {surface=>$surface, name=>'unreviewed_increase', observed=>'RED'};
}
my $result = {production_sha256=>sha256_hex($source), instrument_sha256=>sha256_hex(raw(__FILE__)), measured=>\%measured,
 thresholds=>\@thresholds, authority=>\@authority,
 scope=>'Actual unchanged production functions with actual current file census and in-memory ADR/index controls. Complete resulting-tree doctrine and staged canonical proof remain separately required.'};
open my $out, '>:raw', $prefix.'controls.json' or die $!;
print {$out} $JSON->pretty->encode($result);
print "Actual production12 aggregate observations and16 reason-specific authority REDs pass.\n";
