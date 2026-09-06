---
id: perl-recognition-commit-boolean-kind-drift
title: "Perl recognition commit converts semantic booleans into numeric payloads"
answers:
  - "does recognition_commit preserve a Perl boolean payload kind"
  - "why does a recognized true or false serialize as one or zero"
  - "which task fixes boolean type loss in recognition commit"
date: 2026-09-06
status: confirmed-open
tags: [perl, recognition, boolean, payload, type, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.41: eight public Get controls; RecognitionTransactionRuntime.pm 334–346; the consumer expects numeric zero for commit_false at t/recognition_transaction_perl_contract.t 439–467."
reverify: "Run the managed public direct/transaction matrix below and check JSON::PP::is_bool as well as serialized value."
---

# Commit changes the staged payload kind

The private recognition authority returns its staged payload from commit. The runtime adapter then explicitly
converts JSON::PP booleans to native numeric one or zero in `finish_commit`. Public parsing therefore changes
the semantic kind even though falsey acceptance remains separate from payload.

Eight controls compare direct return and a successful recognized child followed by commit:

| Authored value | Direct result | Transaction result |
| --- | --- | --- |
| true | JSON boolean true | JSON number 1 |
| false | JSON boolean false | JSON number 0 |
| 1 | JSON number 1 | JSON number 1 |
| 0 | JSON number 0 | JSON number 0 |

All parser contexts report zero errors. `JSON::PP::is_bool` is true only for the two direct boolean results.
The current final-path consumer explicitly expects numeric zero for `commit_false`; that expectation cannot
establish typed payload preservation. The earlier checkpoint's 59 passing authority/carrier tests do not
close this discrepancy, and other runtime/carrier routes are not measured here.

[[SESSION-STARTUP-READING]] `.39` owns neutral/typed authority review, six-runtime census, bounded repair
decomposition, type-sensitive independent regressions, and book/Knowledge/recurring closeout. The separate
dynamic-codeblock conversion remains [[perl-codeblock-boolean-literal-kind-drift]] under `.35`.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;my $j=JSON::PP->new->canonical->allow_nonref;
for my $literal ('true','false','1','0'){
 for my $route ('direct','transaction'){
  my $source=$route eq 'direct' ? "Top:: { return($literal) }\n" : "Top::\n I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); payload = recognition_commit(tx); return(payload) }\n /never/\nChild::AND\n /a/ -> Tail { return($literal) }\nTail::AND\n /b/\n";
  my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);die 'compile failed' unless ref($parser) eq 'CODE' && !($ctx{error_count}//0);
  my $input='ab';my $value=$parser->(\$input);
  print $j->encode({literal=>$literal,route=>$route,value=>$value,is_boolean=>JSON::PP::is_bool($value)?JSON::PP::true:JSON::PP::false,errors=>$ctx{error_count}//0}),"\n";
 }
}
PERL
```
