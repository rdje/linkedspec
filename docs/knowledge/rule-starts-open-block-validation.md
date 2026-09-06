---
id: rule-starts-open-block-validation
title: "Rule starts are only allowed at paragraph top level; a bare label-like `word:` line inside an open action/lifecycle block is rejected with `Rule definition not allowed inside open block`, while colon-bearing strings inside valid helper DSL are ordinary block content."
answers:
  - "can a label-like line inside an open action block start a new rule"
  - "why does label colon inside a spec block fail to compile"
  - "what does Rule definition not allowed inside open block mean"
  - "how does the spec parser distinguish rule starts from block content"
  - "can helper DSL contain a string such as label colon"
date: 2026-07-08
status: confirmed
tags: [spec-language, validation, rule-paragraphs, helper-dsl, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.10.5.5 reverified the `user-model/spec-files-and-rule-paragraphs.md` label-in-block example. A bare `label:` line while an `I { ... }` block is open does not become a new top-level rule; `perl/LinkedSpec/Validation.pm` checks `_parse_rule_label_line($line)` while `edge_scan_depth > 0` and rejects it as `Rule definition not allowed inside open block`, suggesting that the preceding block must close before starting a rule. A colon-bearing quoted string remains valid helper DSL block content: `return(hash(\"label:\", \"inside block\"))` compiles and returns the key `label:` in the payload. This distinction is the rule-paragraph boundary: rule starts are top-level constructs, but open blocks still must contain valid helper DSL."
reverify: bash tools/project_data_run.sh perl -Iperl -MLinkedSpec::Validation -e 'my $s=join(chr(10), q!Top::!, q! I {!, q!label:!, q! return(1)!, q! }!, q!!); my %f; my $ok=LinkedSpec::Validation::validate_dsl_syntax(\$s,{on_failure=>sub {%f=@_}}); die q!unexpected result! if $ok || $f{summary} ne q!Rule definition inside open block!; print $f{detail};'
---

# Rule starts versus open action/lifecycle blocks

**Confirmed 2026-07-08** during `SPEC-LANG-REFERENCE.10.5.5`.

**Reverified 2026-09-06 (`SESSION-STARTUP-READING.3.2.9`):** The direct validator rejects the open-block
control at line 3 with summary `Rule definition inside open block`. The retrieval command now uses that
boundary directly and omits the removed `parse_mode` option that prevented the historical command from
reaching validation. The separate repeated `Next:` diagnostic defect is owned in [[perl-validation-diagnostic-source-drift]].

Rule labels such as `Next:` and `Top::` are top-level paragraph starts. They are not valid
inside an open action or lifecycle block. If a bare label-like line such as `label:` appears
before the block closes, validation fails instead of silently treating it as a new rule.

Valid helper DSL inside the block may still contain colon-bearing values, for example a quoted
hash key:

```text
Item:
 /a/ I {
   return(hash(
     "kind", "top",
     "label:", "inside block"
   ))
 }
```

This compiles because `"label:"` is a string argument to `hash(...)`, not a top-level rule
start.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (`.10.5.5`)
- Book page: `docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md`
- Related: [[spec-top-rule-no-regex-two-rule-minimum]], [[top-rule-is-ordinary-rule-entered-first]]
