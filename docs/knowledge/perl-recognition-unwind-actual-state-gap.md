---
id: perl-recognition-unwind-actual-state-gap
title: "Perl recognition unwind restores private state without restoring the input cursor"
answers:
  - "does exit_now roll back an unfinished recognition attempt in Perl"
  - "why is the input cursor still advanced after recognition transaction unwind"
  - "where does recognition guard cleanup apply restored state to parser registers"
  - "which task repairs actual parser state restoration on recognition abort"
date: 2026-09-06
status: confirmed-open
tags: [perl, recognition, unwind, cursor, diagnostic, control-error, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.41: four public Get/exit_now controls; RecognitionTransactionRuntime.pm 601–642 / 667–678 and RecognitionTransaction.pm 107–135."
reverify: "Run the managed four-route exit probe below; compare caller input pos and exact typed exit status."
---

# Unwind leaves actual input advanced

The recognition authority's `leave_invocation` restores a live token snapshot and reports the missing terminal.
Runtime `_finish_guard` synchronizes actual state into that authority before leaving, but after the private
restoration it removes the guard/context without calling `_apply_authority_state`. The destructor suppresses
the secondary terminal error when an original error is already propagating. Explicit rollback does apply
the restored private snapshot back to actual parser state.

Four public controls use input ab and a checkpoint at cursor zero:

| Exit placement | Typed exit status | Caller input cursor |
| --- | --- | --- |
| Before the recognition attempt | 7 | 0 |
| After the successful attempt, before its commit | 7 | 2 |
| After explicit rollback | 7 | 0 |
| After explicit commit | 7 | 2 |

Every parser context reports zero errors, and every thrown object is `LinkedSpec::RuntimeExitNow`.
The uncommitted exit case leaves the same advanced cursor as the committed case. This is public authored
execution, separate from the private post-terminal misuse in [[perl-recognition-invalidated-token-restoration]].

The probe measures the externally visible input cursor. The source shows the missing general synchronization
step; boundary/mark/gap values, other abort causes, emitted/reconstructed carriers, and other runtimes require
their own controls. Do not claim those unmeasured outcomes or replace the original control error during repair.

[[SESSION-STARTUP-READING]] `.40.1` owns complete unwind-state census and bounded repairs, preserving original
exception identity and committed state. `.40.2` owns neutral/runtime/book/Knowledge and recurring closeout.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;my $j=JSON::PP->new->canonical;
for my $route ('exit_before_attempt','exit_after_attempt','rollback_before_exit','commit_before_exit'){
 my @parts=('tx = recognition_checkpoint()','matched = recognize_once(tx, call(Child))');
 if($route eq 'exit_before_attempt'){splice @parts,1,0,'exit_now(7)'}
 elsif($route eq 'exit_after_attempt'){push @parts,'exit_now(7)'}
 push @parts,$route eq 'rollback_before_exit'?'recognition_rollback(tx)':'payload = recognition_commit(tx)';
 push @parts,'exit_now(7)' if $route eq 'rollback_before_exit'||$route eq 'commit_before_exit';
 push @parts,'return("finished")';
 my $source="Top::\n I { ".join('; ',@parts)." }\n /never/\nChild::AND\n /a/ -> Tail { return(9) }\nTail::AND\n /b/\n";
 my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'compile failed' unless ref($parser) eq 'CODE' && !($ctx{error_count}//0);
 my $input='ab';my $ok=eval{$parser->(\$input);1};my $e=$@;die 'exit failed' if $ok||ref($e) ne 'LinkedSpec::RuntimeExitNow';
 print $j->encode({route=>$route,status=>$e->status,cursor=>pos($input)//0,errors=>$ctx{error_count}//0}),"\n";
}
PERL
```
