---
id: dart-reading-engineering-history-capacity-blocker
title: Dart reading needs one additional engineering-history archive slot
answers:
  - which engineering history limits block Dart reading after child 24
  - did Dart child 24 preserve every engineering history byte
  - does the prior change history greenlight authorize another engineering history slot
  - what exact capacity proposal does DART STARTUP READING 5 own
date: 2026-09-10
status: proposed; director decision pending; no capacity limit changed
tags: [dart, startup, continuity, history, capacity, approval]
evidence: "DART-STARTUP-READING.1.24's mandatory draft rollover preserves clean 62b02fec notes lines 249-447, 199 lines / 31079 bytes. Routing rejects only collection files 27/26 and manifest lines 26/25. The verified uncommitted rollover was restored; a concise 292-byte summary lets .1.24 land at 453 lines / 58932 bytes, with full findings in task/Knowledge/book. Only 50 bytes remain below rollover. Intake .5 owns the separate proposal."
reverify: "Pinned draft: DART_ENGINEERING_HISTORY_PROPOSAL below. Current unapproved controls: DART_ENGINEERING_HISTORY_BOUNDARIES below. For later live pressure run both roll_document_history.pl --check commands and scripts/check_readme_stability.sh; accepted implementation must remeasure actual source and candidate."
---

## Exact proposal

| Control | Current | Proposed |
| --- | ---: | ---: |
| `engineering_notes.limits.max_files` | 26 | 27 |
| `docs/history/development-notes/manifest.jsonl` max_lines | 25 | 26 |

The manifest is 15,618 bytes, within its unchanged 16,384-byte ceiling. The draft
collection is 27 files / 25,860 lines / 2,775,501 bytes; aggregate ceilings remain
27,000 lines / 3,145,728 bytes. Root 512 lines / 65,536 bytes and segment
4,096 lines / 524,288 bytes also stay unchanged. Owner, routes, lifecycle,
verifier, immutable records and all unrelated limits remain unchanged.

`COMMIT.md` requires the governed rollover after a complete record crosses 90%.
The .1.24 draft reaches 455 lines / 59,104 bytes. The tool archives the exact
199-line / 31,079-byte clean-source suffix as `4981-dc8219d5abb8`, leaving
256 lines / 28,025 bytes. Every old manifest record remains byte-identical and
ordered; the resulting routing gate rejects exactly the two count limits above.

No accepted history is rewritten to make room. After independent source/hash
verification and a repository-local draft copy, only the newly generated,
uncommitted rollover was restored. The final summary is 292 bytes; full
comprehension remains in .1.24 and its existing authority cards. The root is
453 lines / 58,932 bytes, leaving 50 bytes below mandatory rollover. This
permits the verified reading slice to commit, but cannot fit another complete
meaningful engineering record. Further reading therefore needs the .5 decision.

ADR0107 admits only 26 files / 25 manifest lines, with no later allowance.
ADR0109 says “No further capacity increase, cleanup/purge or parked feature
activation is authorized here.” The subsequent greenlight and ADR0110 cover
`change_history` alone. None authorizes this distinct engineering-history
increase before the remaining startup gates. `README_POLICY.md` requires a new
accepted indexed decision for any limit increase; no such increase is applied.

`DART-STARTUP-READING.5` owns the director decision. Approval must be implemented
under a new bounded leaf of `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`, from a clean
repository, with an indexed exact-limit ADR, actual-source remeasurement,
full-history reconstruction, real-validator boundary checks and receipt-bound
canonical proof. The proposal does not grant another future slot. .1.25 remains
the next source slice after that boundary.

## Exact historical draft replay

The source and draft are pinned; later implementation must remeasure current
coordinates and counts. The recipe reads Git and does not recreate files.

```bash
bash tools/project_data_run.sh python3 - <<'DART_ENGINEERING_HISTORY_PROPOSAL'
from pathlib import Path
import hashlib,json,re,subprocess
BASE='62b02fecb4b2e8a2ed779281a37300e5e3ca1fe5'
def git(*args):return subprocess.check_output(['git',*args])
root='DEVELOPMENT_NOTES.md';manifest='docs/history/development-notes/manifest.jsonl'
source=git('show',BASE+':'+root);old=git('show',BASE+':'+manifest)
part=b''.join(source.splitlines(keepends=True)[248:447])
digest=hashlib.sha256(part).hexdigest()
assert len(part)==31079 and len(part.splitlines())==199
assert digest=='dc8219d5abb8a57b27ca22971d1ae48d19b192277585cf7d98529bdfea90cf8c'
assert source.endswith(part)
rows=[json.loads(line) for line in old.splitlines()]
row={'byte_count':len(part),'current_path':root,'immutable':True,'line_count':199,
 'retrieval_command':'perl tools/read_document_history.pl --surface engineering_notes --segment 4981',
 'segment_id':'4981','sha256':digest,'source_blob':git('rev-parse',BASE+':'+root).decode().strip(),
 'source_commit':BASE,'source_end_line':447,'source_path':root,'source_start_line':249,
 'surface':'engineering_notes','target_path':'docs/history/development-notes/segment-4981-'+digest[:12]+'.md','type':'segment'}
assert row['source_blob']=='e716c35d72da21283a3579fbcad06364082e8494'
rows[0]['segment_count']+=1;rows.insert(1,row)
proposed=('\n'.join(json.dumps(r,sort_keys=True,separators=(',',':')) for r in rows)+'\n').encode()
assert len(proposed)==15618 and len(rows)==26 and rows[0]['segment_count']==25
assert proposed.splitlines(keepends=True)[2:]==old.splitlines(keepends=True)[1:]
record='''## 2026-09-10 — recognition and source authority reconciliation

Dart reading .1.24 completes recognition, semantic observation and source location.
Token misuse restores frame/gap snapshots before invalidation; private source
values retain authority/source/scalar identity. Staged seeds own reusable data
and create fresh invocation authority/cache. All 58 tests pass; existing effect,
observer-wrapper and input-slice defects retain their owners. Next .1.25.

'''.encode()
assert len(record)==464
start=re.search(rb'^## ',source,re.M).start()
draft=source[:start]+record+source[start:]
assert (len(draft.splitlines()),len(draft))==(455,59104)
retained=draft[:-len(part)]
assert (len(retained.splitlines()),len(retained))==(256,28025)
old_paths=git('ls-tree','-r','--name-only',BASE,'--','docs/history/development-notes/').decode().splitlines()
old_parts=[p for p in old_paths if p.endswith('.md')]
contents=[git('show',BASE+':'+p) for p in old_parts]
population=[retained,proposed,part,*contents]
metrics={'files':len(population),'lines':sum(len(b.splitlines()) for b in population),'bytes':sum(map(len,population))}
assert metrics=={'files':27,'lines':25860,'bytes':2775501}
assert metrics['lines']<=27000 and metrics['bytes']<=3145728
print(json.dumps({'source_commit':BASE,'source_blob':row['source_blob'],'source_lines':[249,447],
 'segment_bytes':len(part),'segment_sha256':digest,'manifest_lines':len(rows),'manifest_bytes':len(proposed),
 'collection':metrics,'old_records_exact':True}))
print('PASS pinned historical draft, exact source suffix, byte-identical old manifest records and finite proposal')
DART_ENGINEERING_HISTORY_PROPOSAL
```

## Proposed boundary verification

This executes the actual pure routing validator against a detached proposed
object: below/equal, each independent excess and simultaneous excess, plus
the measured draft under old/proposed limits. It changes no control. All 22
executions pass; this is proposal proof, not canonical infrastructure admission.

```bash
bash tools/project_data_run.sh perl - <<'DART_ENGINEERING_HISTORY_BOUNDARIES'
use strict;use warnings;use JSON::PP ();
sub read_source {my($p)=@_;open my $f,'<:raw',$p or die "$p: $!";local $/;my $s=<$f>;close $f or die $!;return $s}
my $src=read_source('scripts/check_readme_routing_pressure.pl');
my($fn)=$src=~/(^sub exceeds_limits \{.*?^\})/ms;die 'missing validator' unless defined $fn;
eval($fn."\n1;") or die $@;
my $json=JSON::PP->new->canonical(1);
my @rs=map {$json->decode($_)} split /\n/,read_source('doctrine/readme_stability/routes.jsonl');
my($r)=grep {$_->{type} eq 'surface' && $_->{id} eq 'engineering_notes'} @rs;
my $manifest='docs/history/development-notes/manifest.jsonl';
die 'proposal baseline moved; remeasure' unless $r->{limits}{max_files}==26 && $r->{member_limits}{$manifest}{max_lines}==25;
my $proposal=$json->decode($json->encode($r));
$proposal->{limits}{max_files}=27;$proposal->{member_limits}{$manifest}{max_lines}=26;
my $l=$proposal->{limits};my $n=0;
my @labels=('files','aggregate lines','aggregate bytes','segment.md lines','segment.md bytes');
for my $case(-2..5) {
 my $m={files=>$l->{max_files},lines=>$l->{max_total_lines},bytes=>$l->{max_total_bytes},
  members=>['segment.md'],per_file=>{'segment.md'=>{lines=>$l->{max_lines_per_file},bytes=>$l->{max_bytes_per_file}}}};
 my @slots=(\$m->{files},\$m->{lines},\$m->{bytes},\$m->{per_file}{'segment.md'}{lines},\$m->{per_file}{'segment.md'}{bytes});
 if($case==-2){--$$_ for @slots}elsif($case==5){++$$_ for @slots}elsif($case>=0){++${$slots[$case]}}
 my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$l);
 my @want=$case==5?@labels:$case>=0?($labels[$case]):();
 die "collection case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
}
for my $path ('DEVELOPMENT_NOTES.md',$manifest) {
 my $cap=$proposal->{member_limits}{$path};
 for my $case(-2..2){
  my $m={lines=>$cap->{max_lines},bytes=>$cap->{max_bytes}};
  --$m->{$_} for $case==-2?qw(lines bytes):();
  ++$m->{lines} if $case==0 || $case==2;++$m->{bytes} if $case==1 || $case==2;
  my @got=map {s/ \d+\/\d+\z//r} exceeds_limits($m,$cap);
  my @want=$case==2?qw(lines bytes):$case==0?('lines'):$case==1?('bytes'):();
  die "$path case $case: @got" unless $json->encode(\@got) eq $json->encode(\@want);++$n;
 }
}
my $m={files=>27,lines=>25860,bytes=>2775501,members=>[],per_file=>{}};
my @old=exceeds_limits($m,$r->{limits});my @new=exceeds_limits($m,$l);
die 'collection measured control' unless "@old" eq 'files 27/26' && !@new;
my $mm={lines=>26,bytes=>15618};
@old=exceeds_limits($mm,$r->{member_limits}{$manifest});@new=exceeds_limits($mm,$proposal->{member_limits}{$manifest});
die 'manifest measured control' unless "@old" eq 'lines 26/25' && !@new;
$n+=4;die "count $n" unless $n==22;
print "PASS 22 actual validator executions; proposed two-scalar controls fit measured draft and retain every independent boundary. No registry mutation.\n";
DART_ENGINEERING_HISTORY_BOUNDARIES
```

Related: [[engineering-notes-twenty-sixth-member-capacity]],
[[dart-reading-history-capacity-blocker]], [[bounded-change-notes-history-contract]].
