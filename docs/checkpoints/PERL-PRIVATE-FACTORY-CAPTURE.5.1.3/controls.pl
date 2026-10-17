use v5.20;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $JSON = JSON::PP->new->canonical(1);
my $INDEX_MODE = 1;
my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/';
my $adr = 'docs/decisions/0135-finite-engineering-notes-member.md';
sub raw {
 open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
 local $/; return <$fh>;
}
my $source = raw('scripts/check_readme_routing_pressure.pl');
my $code = '';
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_is_accepted adr_authorizes_limit_change adr_authorizes_contract_change)) {
 $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "actual function missing: $name";
 $code .= $1;
}
eval $code; die $@ if $@;
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
 for my $path (@paths) {my $r=raw($path); $lines += () = $r =~ /\n/g; $bytes += length($r)}
 $measured{$surface} = {files=>scalar(@paths), lines=>$lines, bytes=>$bytes};
}
my $manifest = raw('docs/history/development-notes/manifest.jsonl');
$measured{manifest} = {lines=>scalar(()=$manifest=~/\n/g), bytes=>length($manifest)};
my @thresholds;
my $member='docs/history/development-notes/manifest.jsonl';
my @dimensions = (
 ['engineering_notes','files','max_files',$plan->{old_limits}{engineering_notes},$plan->{new_limits}{engineering_notes}],
 ['manifest','lines','max_lines',$plan->{old_contract}{member_limits}{$member},$plan->{new_contract}{member_limits}{$member}],
 ['manifest','bytes','max_bytes',$plan->{old_contract}{member_limits}{$member},$plan->{new_contract}{member_limits}{$member}],
 ['decisions','files','max_files',$plan->{old_limits}{decisions},$plan->{new_limits}{decisions}],
 ['decisions','lines','max_total_lines',$plan->{old_limits}{decisions},$plan->{new_limits}{decisions}],
);
for my $dimension (@dimensions) {
 my ($surface,$metric,$key,$old,$new)=@$dimension;
 for my $value ($measured{$surface}{$metric}, $new->{$key}, $new->{$key}+1) {
  for my $limit ($old->{$key},$new->{$key}) {
   my @errors=exceeds_limits({$metric=>$value},{$key=>$limit});
   die 'independent threshold disagrees' if !!@errors != ($value>$limit);
   push @thresholds,{surface=>$surface,metric=>$metric,value=>$value,limit=>$limit,rejected=>@errors?JSON::PP::true:JSON::PP::false,reasons=>\@errors};
  }
 }
}
my @checks = (
 ['engineering_notes','limits',$plan->{old_limits}{engineering_notes},$plan->{new_limits}{engineering_notes}],
 ['engineering_notes','contract',$plan->{old_contract},$plan->{new_contract}],
 ['decisions','limits',$plan->{old_limits}{decisions},$plan->{new_limits}{decisions}],
);
my %original=%files;
my @authority;
for my $item (@checks) {
 my ($surface,$kind,$old,$new)=@$item;
 my $check=sub {$kind eq 'limits' ? adr_authorizes_limit_change($surface,$old,$new) : adr_authorizes_contract_change($surface,$old,$new)};
 die "exact positive authority: $surface/$kind" unless $check->();
 for my $case (qw(missing_new_record missing_index proposed_status missing_status duplicate_status wrong_old_object wrong_new_object)) {
  %files=%original; @adrs=($adr);
  if ($case eq 'missing_new_record') {@adrs=()}
  elsif ($case eq 'missing_index') {$files{'docs/decisions/INDEX.md'}=''}
  elsif ($case eq 'proposed_status') {$files{$adr}=~s/^- Status:.*$/- Status: proposed/m or die 'status mutation'}
  elsif ($case eq 'missing_status') {$files{$adr}=~s/^- Status:.*\n//m or die 'status mutation'}
  elsif ($case eq 'duplicate_status') {$files{$adr}.="\n- Status: accepted\n"}
  else {
   my $marker=$case eq 'wrong_old_object'?'Previous':'New';
   my $value=$case eq 'wrong_old_object'?$old:$new;
   my $exact='- '.$marker.' routed '.$kind.': `'.$JSON->encode($value).'`';
   $files{$adr}=~s/^\Q$exact\E$//m or die 'exact authority marker mutation';
  }
  die "authority corruption admitted: $surface/$kind/$case" if $check->();
  push @authority,{surface=>$surface,kind=>$kind,name=>$case,observed=>'RED'};
 }
 %files=%original; @adrs=($adr);
 die 'restored positive authority' unless $check->();
}
for my $surface (qw(engineering_notes decisions)) {
 die 'unreviewed increase admitted' if limit_change_permitted($plan->{old_limits}{$surface},$plan->{new_limits}{$surface},0);
 die 'reviewed increase denied' unless limit_change_permitted($plan->{old_limits}{$surface},$plan->{new_limits}{$surface},1);
 push @authority,{surface=>$surface,kind=>'limits',name=>'unreviewed_increase',observed=>'RED'};
}
print $JSON->pretty->encode({production_sha256=>sha256_hex($source),instrument_sha256=>sha256_hex(raw(__FILE__)),
 measured=>\%measured,thresholds=>\@thresholds,authority=>\@authority,
 scope=>'Unchanged actual production functions; complete current census and in-memory ADR/index controls. Exact staged canonical CI/receipt separately governs landing.'});
