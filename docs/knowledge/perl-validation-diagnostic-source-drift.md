---
id: perl-validation-diagnostic-source-drift
title: Perl validation diagnostics repeat the current line and can misidentify the failing occurrence or rule
answers:
  - "why does a DSL error repeat the current line as Next"
  - "why does get_dsl_context erase a line containing zero"
  - "why does a duplicate rule error point to the first definition"
  - "why is an invalid regex attributed to the last rule"
  - "which tasks repair Perl validation diagnostic source context"
date: 2026-09-06
status: confirmed diagnostic defects; SESSION-STARTUP-READING.11.1-.11.3 own repair after required reading
tags: [perl, validation, diagnostics, source-location, defect, continuity]
evidence: "SESSION-STARTUP-READING.3.2.9 read Validation.pm 1–1320 at unchanged baeb984e and ran direct context/formatter, validator callback, and public LinkedSpec::Get runtime-context probes. Three-line controls repeat current text as Next; literal zero becomes empty current text; line-4 duplicate reports line 1; Top regex error carries Next as rule_label. Invalid specs remain rejected."
reverify: "rg -n 'sub get_dsl_context|my [$]current_line|my [$]next_line|index[(][$][$]spec_content, [$]line|my [$]regex_depth|Invalid regex pattern' perl/LinkedSpec/Validation.pm"
---

These are separate causal defects in one validation diagnostic surface. Reading did not change source.

| Probe | Observed result | Cause | Repair |
| --- | --- | --- | --- |
| `first\nmiddle\nlast\n`, position 6 | Current `middle`; Previous `first`; Next `middle` | `next_line` indexes `line_number - 1` again instead of the next row | `.11.1` |
| `before\n0\nafter\n`, position 7 | Current is empty instead of `0` | `current_line` uses truthiness (`||`) instead of definedness | `.11.1` |
| `Top:\n /a/\n\nTop:\n /b/\n` | Duplicate definition rejected at line 1 instead of line 4 | `index(source, line)` returns the first identical occurrence | `.11.2` |
| `Top:\n /[/\n\nNext:\n /x/\n` | Regex failure at line 2, but `rule_label` is `Next` | The later regex pass uses the final paragraph pass's `current_rule` | `.11.3` |

The first/middle/last context control returned next values `first`, `middle`, and empty respectively.
The formatter reproduced `Line: middle` followed by `Next: middle`; the final line correctly has no next row.
The duplicate and regex controls reproduced through both `validate_dsl_syntax`'s `on_failure` callback and
public `LinkedSpec::Get(..., runtime_ctx_ref => ...)`: parser result is undefined, error type is
`compiler_pipeline`, and stage is `validate_dsl_syntax`. The public context preserves the same wrong line/rule.
No change to valid parsing or failure acceptance is implied by these observations.

The bounded repairs must preserve position units, existing codes, strict validation, and rule/edge semantics.
Occurrence repair must carry physical offsets through callers instead of searching by line content. Regex
attribution must follow its own pass's containing rule. Context tests include blank/trailing lines, literal
zero, Unicode and CRLF where relevant; direct callbacks and public diagnostics must agree. Book and Knowledge
updates follow implementation under `.11.1`–`.11.3` after required reading and repairs `.7`–`.10`.

Related: [[rule-starts-open-block-validation]], [[perl-compiler-pipeline-stage-and-mode-boundaries]],
[[runtimecontext-boundary]].
