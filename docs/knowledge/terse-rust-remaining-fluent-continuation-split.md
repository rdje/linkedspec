---
id: terse-rust-remaining-fluent-continuation-split
title: "SPEC-FORMAT-TERSE.2.3.3.3 splits remaining Rust fluent continuations by mechanism"
answers:
  - "how is SPEC-FORMAT-TERSE.2.3.3.3 split"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.3.3"
  - "does Rust drop I.return fluent chains"
  - "why is I.return separate from action edge push fluent chains in Rust"
  - "which Rust fluent continuation leaf owns I.return"
  - "which Rust fluent continuation leaf owns action-edge push child target"
  - "when should tclite be re-enabled after Rust fluent parity"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust, fluent, lifecycle, action-edge, tclite, task-tree]
evidence: "SPEC-FORMAT-TERSE.2.3.3.3 split on 2026-06-30 after KM retrieval, Perl reference probes, shipped-spec/code search, and Rust parser/compiler/runtime code-read. Rust parser.rs currently parses compact lifecycle forms such as `I.return(...)` and `I.declare(...).return(...)` as a bare lifecycle marker followed by BodyElementKind::FluentChain; compiler.rs drops standalone/body FluentChain elements. That makes compact lifecycle/body receiver chains the first implementation child, SPEC-FORMAT-TERSE.2.3.3.3.1. Action-edge metadata exists after .2.3.3.1, but engine.rs::execute_action_edge_fluent_chain only executes no-arg `.push`, `.return(expr)`, and `.return_undef`; explicit/flow chains such as `.push(child,target)` and `.if(...).push(...).else().return_undef().endif()` are SPEC-FORMAT-TERSE.2.3.3.3.2. The deferred tclite oracle should be retried only after those fluent children land; any remaining default-mode repetition divergence is SPEC-FORMAT-TERSE.2.3.3.3.3."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.2\\.3\\.3\\.3|BodyElementKind::FluentChain|execute_action_edge_fluent_chain|I\\.return|\\.push\\(' docs/tasks/SPEC-FORMAT-TERSE.md rust/linkedspec-core/src/parser.rs rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/src/engine.rs specs/ebnf.spec specs/spec.spec"
---

# Rust Remaining Fluent Continuation Split

`.2.3.3.3` is a split-only leaf. The remaining Rust fluent work is not one mechanism:

- `.2.3.3.3.1`: compact lifecycle/body receiver chains such as `I.return(...)` and
  `I.declare(...).return(...)`.
- `.2.3.3.3.2`: action-edge explicit/flow chains such as `.push(child,target)` and
  `.if(...).push(...).else().return_undef().endif()`.
- `.2.3.3.3.3`: retry `tclite` oracle fixtures after the fluent children land, then split any remaining
  default-mode repetition gap before code.

Do not broaden `.2.3.3.3.1` into action-edge semantics. Its first job is to stop dropping accepted lifecycle
receiver chains by normalizing them into executable lifecycle statement blocks.
