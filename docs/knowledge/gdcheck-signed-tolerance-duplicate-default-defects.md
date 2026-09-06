---
id: gdcheck-signed-tolerance-duplicate-default-defects
title: "gdcheck mishandles negative tolerance intervals, duplicate rows, and DEFAULT cardinality"
answers:
  - "why does gdcheck mark equal negative numbers outside tolerance"
  - "why does gdcheck skip duplicate added or removed rows"
  - "why does gdcheck accept zero or two DEFAULT patterns"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","utility","comparison"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.25. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/gdcheck.pl"
  - "rg -n 'tol|DEFAULT|length\\(@EVAL\\)|\\[0\\]' perl/gdcheck.pl"
---

# gdcheck mishandles negative tolerance intervals, duplicate rows, and DEFAULT cardinality

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.25](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

With tolerance 10, equal -100 values are marked below, and -100 to -95 is marked above; the positive twins are unmarked. The margin multiplies the signed baseline and reverses the intended interval.

Duplicate additions/removals use only each key's first indexed row. Two removed rows receive only the first removal mask, and adding two rows preserves only one. DEFAULT accepts zero and two patterns because length(@EVAL) measures the decimal string length of the count.

The three owned repairs separately cover signed/zero boundaries, every duplicate row and stable correspondence, and exactly-one DEFAULT cardinality. None is recorded as fixed by the diagnostic intake.

Sources: `perl/gdcheck.pl`.

## Current reading and diagnostic checkpoint

At `SESSION-STARTUP-READING.3.2.54`, all 431 lines / 10,279 bytes were reread, including the raw `0xb5`
comment bytes shown with escaping. The file is unchanged from the recorded baseline (SHA-256
`e12ddba1c2a252c91ba48f24ad888e7693f92bdb167a791e847025fe41f153f5`). Managed syntax checks pass for
all three legacy utilities. The following nine assertions pass **by reproducing the defects**, including positive
numeric controls; they do not certify corrected behavior. `.25.1`–`.25.3` remain the repair owners.

```bash
bash tools/project_data_run.sh perl -Iperl - <<'GDC58'
use strict; use Test::More;
require './perl/gdcheck.pl';
my $config={lineids=>{S=>[0]},numbers=>{S=>{1=>10}},diff=>{above=>'above',below=>'below',notequal=>'different'}};
for my $case ([-100,-100,'below'],[-100,-95,'above'],[100,100,undef],[100,105,undef]) {
 my ($a,$b,$want)=@$case; my $m=gd_check($config,'S',[['key',$a]],[['key',$b]]);
 is($m->[0][1],$want,"observed signed tolerance $a to $b");
}
my $removed=gd_check($config,'S',[['same',1],['same',2]],[]);
is(scalar(@$removed),1,'observed only first duplicate removal mask');
my $base=[]; gd_check($config,'S',$base,[['same',1],['same',2]]);
is_deeply($base,[['same',1]],'observed only first duplicate addition');
for my $case (['DEFAULT',undef],['DEFAULT "one"','one'],['DEFAULT "one" "two"','one']) {
 my $r=checkinfo_uniquify(['uniquify',[$case->[0]]]);
 is($r->{DEFAULT},$case->[1],"observed DEFAULT cardinality: $case->[0]");
}
done_testing();
GDC58
```
