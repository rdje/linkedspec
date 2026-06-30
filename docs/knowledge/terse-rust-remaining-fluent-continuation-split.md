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
  - "does Rust support action-edge push target fluent chains"
  - "does Rust support action-edge fluent if push return_undef chains"
  - "which leaf owns tclite default-mode repetition audit"
  - "when should tclite be re-enabled after Rust fluent parity"
  - "did tclite pass after Rust fluent parity"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust, fluent, lifecycle, action-edge, tclite, task-tree]
evidence: "SPEC-FORMAT-TERSE.2.3.3.3 split on 2026-06-30 after KM retrieval, Perl reference probes, shipped-spec/code search, and Rust parser/compiler/runtime code-read. That split found Rust parser.rs parsed compact lifecycle forms such as `I.return(...)` and `I.declare(...).return(...)` as a bare lifecycle marker followed by BodyElementKind::FluentChain, while compiler.rs dropped standalone/body FluentChain elements. SPEC-FORMAT-TERSE.2.3.3.3.1 then fixed that first child: Rust parser.rs now normalizes lifecycle-marker receiver chains into lifecycle CodeBlock statement strings (`I.declare(...).set(...).return(...)` -> `declare(...); set(...); return(...)`) on multiline body and regex-first header-line inline paths; compiler.rs compiles those CodeBlocks into preamble/E/etc.; runtime locks prove compact lifecycle `return(expr)` writes the surrounding rule return channel and ordered declaration/mutation chains execute. SPEC-FORMAT-TERSE.2.3.3.3.2 then fixed the action-edge child: parser.rs attaches multiline dotted continuations to the preceding ActionEdge, compiler.rs preserves them in AcodeEntry.fluent_chain, and engine.rs executes `.push(target)`, `.push(child,target)`, `.if/.else/.endif` gating, helper calls such as `.say(...)`, `.return(expr)`, and `.return_undef()` with parent-visible child return-channel semantics. SPEC-FORMAT-TERSE.2.3.3.3.3 then retried tclite after those fluent children landed: Perl returned tagged tcl_script values for `[]` and `\"\"`, but Rust still returned `[]` for both temporarily re-enabled fixtures. The remaining implementation leaf is SPEC-FORMAT-TERSE.2.3.3.3.3.1 default-mode recursive repetition parity."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.2\\.3\\.3\\.3|BodyElementKind::FluentChain|execute_action_edge_fluent_chain|I\\.return|\\.push\\(' docs/tasks/SPEC-FORMAT-TERSE.md rust/linkedspec-core/src/parser.rs rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/src/engine.rs specs/ebnf.spec specs/spec.spec"
---

# Rust Remaining Fluent Continuation Split

`.2.3.3.3` is a split-only leaf. The remaining Rust fluent work was not one mechanism:

- `.2.3.3.3.1`: compact lifecycle/body receiver chains such as `I.return(...)` and
  `I.declare(...).return(...)` — landed by normalizing the accepted lifecycle-marker surface into executable
  lifecycle statement blocks.
- `.2.3.3.3.2`: action-edge explicit/flow chains such as `.push(child,target)` and
  `.if(...).push(...).else().return_undef().endif()` — landed by keeping multiline dotted continuations on the
  preceding action edge and executing explicit-target child-return pushes plus branch controls.
- `.2.3.3.3.3`: retried `tclite` oracle fixtures after the fluent children landed; Rust still returned `[]`
  for the two Perl-tagged outputs, so the implementation split is now `.2.3.3.3.3.1`.
- `.2.3.3.3.3.1`: default-mode recursive repetition parity for `tclite`, including re-enabling the two oracle
  fixtures once Rust reproduces the Perl values.

Do not keep re-auditing fluent forms after `.2.3.3.3.3`: the next check is the default-mode recursive
repetition implementation leaf, with any broader recursive-rule value work split from that evidence.
