---
id: perl-recognition-invalidated-token-restoration
title: "Invalidated Perl recognition tokens can restore obsolete snapshots on cross-owner misuse"
answers:
  - "can reusing a committed recognition token change previously committed frame state"
  - "why does cross-invocation misuse of an invalidated Perl token roll back newer marks"
  - "does cross-source token rejection preserve state after terminal invalidation"
  - "which task repairs stale transaction snapshot restoration after commit or rollback"
  - "does Rust restoration guard already invalidated recognition tokens"
date: 2026-09-07
status: confirmed-open
tags: [perl, rust, recognition, token, transaction, invalidation, rollback, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.40: six private-authority controls, RecognitionTransaction.pm 358–410 and 496–518; authority/carrier suites pass 59 top-level tests."
reverify: "Run the managed six-case post-terminal probe below and compare owner cursor/boundary/marks before and after rejection."
---

# An invalid token can still restore its snapshot

The neutral token machine makes commit and rollback terminal transitions into invalidated state.
The existing Perl core rejects later use, but its rejection can still mutate the owner.

`_token_for_operation` checks source and invocation identity before testing invalidated state.
Those mismatch branches call `_restore_and_invalidate`, which assigns the old snapshot whenever the
owner frame remains active. Only the subsequent `_invalidate` call checks whether the token was
already invalidated; that check comes after restoration.

Six controls first complete a matching attempt with commit or rollback, then explicitly advance the
owner frame to cursor six, boundary five, and mark m four. They reuse the completed token through
`commit` in one of three contexts:

| Prior terminal | Reuse route | Error | Owner after rejection |
| --- | --- | --- | --- |
| Commit | Same frame | recognition_token_reused | New state retained |
| Commit | Other frame | recognition_cross_invocation | Old cursor/boundary zero, no marks |
| Commit | Other source | recognition_cross_source | Old cursor/boundary zero, no marks |
| Rollback | Same frame | recognition_token_reused | New state retained |
| Rollback | Other frame | recognition_cross_invocation | Old cursor/boundary zero, no marks |
| Rollback | Other source | recognition_cross_source | Old cursor/boundary zero, no marks |

The valid restore-before-report behavior for a live token must remain. Existing cross-owner tests
at t/recognition_transaction_perl_authority.t 398–456 intentionally test that live case. They do not
cover the completed-token-plus-later-state combination above. The managed authority/carrier pair
passes 59 top-level tests, and neutral governance remains 138 node rows / 250 calls / 58 mutations
with 9/9 rollout. Passing those fixtures does not close the post-terminal defect.

This evidence uses the existing private authority API. It does not establish that authored token
escape reaches the same state, and it does not measure the other five runtime routes. The separately
recorded lexical/compilation-order escape checker defect remains
[[perl-recognition-token-lexical-order-drift]] under `.21`.

[[SESSION-STARTUP-READING]] `.38.1` owns all-operation/ownership and six-runtime census, bounded repair
decomposition, preservation of live rollback, and independent post-terminal regressions.
`.38.2` owns neutral/runtime/book/Knowledge and recurring closeout after repair.

## September 7 Rust source comparison

`SESSION-STARTUP-READING.3.3.27` reads Rust authority lines 1–872 plus supporting
drop/restoration helpers 1387–1454. Rust also checks source/invocation ownership before
its reused-token diagnostic, but `restore_and_invalidate` reads token status and returns
immediately if already invalidated, before assigning the saved frame state. Its terminal
`invalidate` helper has the same early status guard. Thus this exact Perl restoration
mechanism is absent from the inspected Rust helper. This is source evidence, not a fresh
six-case Rust behavioral run or closure of `.38.1`'s full operation/runtime census.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec::RecognitionTransaction -MJSON::PP - <<'PERL'
use strict;use warnings;my $j=JSON::PP->new->canonical;
for my $terminal ('commit','rollback'){
 for my $route ('same_frame','other_frame','other_source'){
  my $src='source';my $a=LinkedSpec::RecognitionTransaction->new(source_authority=>\$src,source_identity=>'source');
  my $f=$a->enter_invocation(rule=>'Top',origin=>'probe',cursor=>0,boundary=>0);my $t=$a->checkpoint(frame=>$f);
  $a->attempt(frame=>$f,token=>$t,matched=>1,payload=>'ok',state=>{cursor=>4,boundary=>3,marks=>{m=>2}});
  $a->$terminal(frame=>$f,token=>$t);
  $a->set_frame_state(frame=>$f,state=>{cursor=>6,boundary=>5,marks=>{m=>4}});
  my $before=$a->frame_snapshot(frame=>$f);my($owner,$frame)=($a,$f);my $other='other';
  if($route eq 'other_frame'){$frame=$a->enter_invocation(rule=>'Child',origin=>'probe',cursor=>6,boundary=>5)}
  if($route eq 'other_source'){$owner=LinkedSpec::RecognitionTransaction->new(source_authority=>\$other,source_identity=>'other');$frame=$owner->enter_invocation(rule=>'Child',origin=>'probe',cursor=>6,boundary=>5)}
  my $ok=eval{$owner->commit(frame=>$frame,token=>$t);1};my $e=$@;die 'misuse accepted' if $ok;die $e unless ref($e) eq 'LinkedSpec::RecognitionTransaction::Error';
  my $after=$a->frame_snapshot(frame=>$f);
  print $j->encode({terminal=>$terminal,route=>$route,code=>$e->{code},before=>{map {$_=>$before->{$_}} qw(cursor boundary marks)},after=>{map {$_=>$after->{$_}} qw(cursor boundary marks)}}),"\n";
  $owner->leave_invocation(frame=>$frame) if $route ne 'same_frame';
  $a->leave_invocation(frame=>$f);
 }
}
PERL
```
