---
id: grouped-edge-book-child-return-drift
title: "The grouped-edge book example reads a child return that its action never produces"
answers:
  - "why does the grouped quoted_string bare_word book example return null text"
  - "does an explicit grouped action automatically call the matched child"
  - "which task corrects grouped-edge retv teaching"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","book","edges","perl"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.30. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/HandlerVariantEmitter.pm docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md"
  - "sed -n '489,519p' perl/LinkedSpec/HandlerVariantEmitter.pm"
  - "sed -n '300,335p' docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md"
---

# The grouped-edge book example reads a child return that its action never produces

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.30](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

For both bare and quoted inputs, the book's shared action returns {kind:token,text:null}. Two explicit per-edge calls produce the expected bare-child/quoted-child values; a shared match_text block produces each raw matched input. All public Get contexts are error-free.

Complete generated-source inspection shows two authored action branches with a retv read and no child call. HandlerVariantEmitter emits the authored action rather than synthesizing that missing call. The repair corrects the teaching and both alternatives; it must not introduce implicit dispatch or a new dynamic-callee feature.

Sources: `perl/LinkedSpec/HandlerVariantEmitter.pm`, `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`.

The following managed control was executed during intake; its output establishes the bounded observation above.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP -MData::Dumper - <<'PERL'
use strict;use warnings;
my $children=qq{\nquoted_string:\n /"([^"]*)"/ I { return("quoted-child") }\n\nbare_word:\n /[a-z]+/ I { return("bare-child") }\n};
my @forms=(
 ['book_grouped',q{-> quoted_string | bare_word { return(hash("kind", "token", "text", retv)); }}],
 ['explicit_children',qq{-> quoted_string { retv = call(quoted_string); return(hash("kind", "token", "text", retv)); }\n-> bare_word { retv = call(bare_word); return(hash("kind", "token", "text", retv)); }}],
 ['matched_text',q{-> quoted_string | bare_word { return(hash("kind", "token", "text", match_text())); }}]
);
for my $form (@forms) {
 my $source="token::\n".$form->[1]."\n".$children;
 my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
 die Dumper(\%ctx) unless ref($parser) eq 'CODE';
 for my $input ('word','"word"') {
  my $text=$input;my $value=eval {$parser->(\$text)};die $@ if length $@;die Dumper($ctx{last_error}) if defined $ctx{last_error};
  print JSON::PP->new->canonical->encode({form=>$form->[0],input=>$input,value=>$value,context_error=>undef}),"\n";
 }
}
PERL
```
