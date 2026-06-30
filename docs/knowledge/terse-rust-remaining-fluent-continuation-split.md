---
id: terse-rust-remaining-fluent-continuation-split
title: "SPEC-FORMAT-TERSE.2.3.3.3 splits remaining Rust fluent continuations by mechanism"
answers:
  - "how is SPEC-FORMAT-TERSE.2.3.3.3 split"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.3.3"
  - "does Rust drop I.return fluent chains"
  - "does Rust support compact lifecycle I.return chains"
  - "is I.declare(...).return(...) portable on Rust"
  - "why is I.return separate from action edge push fluent chains in Rust"
  - "which Rust fluent continuation leaf owns I.return"
  - "which Rust fluent continuation leaf owns action-edge push child target"
  - "when should tclite be re-enabled after Rust fluent parity"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust, fluent, lifecycle, action-edge, tclite, task-tree]
evidence: "SPEC-FORMAT-TERSE.2.3.3.3 split on 2026-06-30 after KM retrieval, Perl reference probes, shipped-spec/code search, and Rust parser/compiler/runtime code-read. That split found Rust parser.rs parsed compact lifecycle forms such as `I.return(...)` and `I.declare(...).return(...)` as a bare lifecycle marker followed by BodyElementKind::FluentChain, while compiler.rs dropped standalone/body FluentChain elements. SPEC-FORMAT-TERSE.2.3.3.3.1 then fixed that first child: Rust parser.rs now normalizes lifecycle-marker receiver chains into lifecycle CodeBlock statement strings (`I.declare(...).set(...).return(...)` -> `declare(...); set(...); return(...)`) on multiline body and regex-first header-line inline paths; compiler.rs compiles those CodeBlocks into preamble/E/etc.; runtime locks prove compact lifecycle `return(expr)` writes the surrounding rule return channel and ordered declaration/mutation chains execute. Action-edge metadata exists after .2.3.3.1, but engine.rs::execute_action_edge_fluent_chain only executes no-arg `.push`, `.return(expr)`, and `.return_undef`; explicit/flow chains such as `.push(child,target)` and `.if(...).push(...).else().return_undef().endif()` are SPEC-FORMAT-TERSE.2.3.3.3.2. The deferred tclite oracle should be retried only after that remaining action-edge fluent child lands; any remaining default-mode repetition divergence is SPEC-FORMAT-TERSE.2.3.3.3.3."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.2\\.3\\.3\\.3|BodyElementKind::FluentChain|execute_action_edge_fluent_chain|I\\.return|\\.push\\(' docs/tasks/SPEC-FORMAT-TERSE.md rust/linkedspec-core/src/parser.rs rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/src/engine.rs specs/ebnf.spec specs/spec.spec"
---

# Rust Remaining Fluent Continuation Split

`.2.3.3.3` is a split-only leaf. The remaining Rust fluent work was not one mechanism:

- `.2.3.3.3.1`: compact lifecycle/body receiver chains such as `I.return(...)` and
  `I.declare(...).return(...)` — landed by normalizing the accepted lifecycle-marker surface into executable
  lifecycle statement blocks.
- `.2.3.3.3.2`: action-edge explicit/flow chains such as `.push(child,target)` and
  `.if(...).push(...).else().return_undef().endif()`.
- `.2.3.3.3.3`: retry `tclite` oracle fixtures after the fluent children land, then split any remaining
  default-mode repetition gap before code.

Do not broaden `.2.3.3.3.2` into lifecycle-marker semantics already closed by `.2.3.3.3.1`; its job is the
remaining action-edge fluent forms.
