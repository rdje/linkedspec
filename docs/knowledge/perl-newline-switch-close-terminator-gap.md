---
id: perl-newline-switch-close-terminator-gap
title: "Perl newline-separated statement after endswitch lacks the required generated do-block terminator"
answers:
  - "why does a statement after newline endswitch fail to compile in Perl"
  - "does newline endswitch followed by return work in Perl"
  - "what does FUTURE-PARITY-BACKLOG.1.6.1.2.1 own"
  - "why is newline if followed by assignment valid but switch followed by return invalid"
date: 2026-07-10
status: confirmed-gap
tags: [actionir, rewrite-pipeline, switch, newline, semicolon, perl-reference, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.0 toolbox audit. After universal splitting landed, `call_spec_handler_subst` on a newline-only if chain, assignment, switch chain, and return emits valid `if (...) { ... }` followed by `$selected = ...`, but emits the switch close as `} }\nreturn [...]`. Perl requires a separator after the expression-style `do { ... }` switch wrapper. `RewritePipeline::_lowered_statement_needs_terminator` currently suppresses a pending terminator for every lowered statement beginning with `}`, which is correct for if/while block closures but too broad for `endswitch_flow`. FUTURE-PARITY-BACKLOG.1.6.1.2.1 owns the contract-aware repair."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", \"switch(\\\"b\\\")\\ncase(\\\"b\\\")\\nvalue = 1\\nendcase()\\nendswitch()\\nreturn(value)\"), \"\\n\"'"
---

# Newline Switch-Close Terminator Gap

The language contract remains unchanged: the newline after `endswitch()` separates it from the following
statement. The Perl reference already splits both statements correctly. The remaining defect is emitted-host
syntax: marker-style switch lowers through an expression-style `do { ... }` wrapper, which needs a generated
semicolon before the following Perl statement.

An `if` or `while` block closure does not need that semicolon, so the repair must use the control contract or an
equally precise lowered-shape distinction rather than treating every leading `}` the same.

## Links

- Separator contract: [[terse-statement-separator-contract]].
- Resolved splitter gap: [[perl-newline-statement-separator-coverage-gap]].
- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.1`.
