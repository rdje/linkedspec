---
id: rust-generic-final-codeblock-normalization
title: Rust normalizes contextual final blocks through callable metadata
answers:
  - "does Rust support attached final codeblock arguments"
  - "does Rust support parenthesized contextual codeblock arguments"
  - "how does Rust decide whether a block argument is a callback"
  - "does the Rust expression parser hard code trailing block method names"
  - "why does Rust have two ActionIR block parse modes"
  - "does Rust preserve ordinary eager blocks in function arguments"
  - "does Rust preserve attached if switch and while controls"
  - "does Rust expose final codeblock parameter kinds in descriptors"
  - "does emitted Rust execute contextual final codeblocks"
  - "what rejects a Rust harray passed to a final codeblock parameter"
date: 2026-09-07
status: current
tags: [rust, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source]
evidence: "FUTURE-PARITY-BACKLOG.11.4.3 adds provenance-preserving callable candidates, one metadata registry and normalization pass, exact final parameter_kinds, typed codeblock_argument execution through the shared dynamic evaluator, established-parser/control/eager-block preservation, and native/reconstructed/generated-plan/independently-emitted proof."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core --lib && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test callable_codeblock_literal_contract"
---

# Rust Generic Final-Codeblock Normalization

Rust recognizes attached `call(args) { body }` and direct parenthesized `call(args, { body })` block arguments
structurally, preserving spelling, typed body, source text, and character-coordinate spans until the complete
compiled callable registry is available. `linkedspec_core::callable_contract` then admits only helper `with`,
receiver `with`/`walk_leaves`/`map_leaves`/`reduce_leaves`, or a user function whose exact final
`parameter_kinds` entry is `codeblock`. Both contextual spellings become the same zero-positional
`codeblock_argument`; an explicit `{|params| ...}` retains its authored signature.

Parsing and semantic admission are deliberately separate. `CodeBlock::parse` retains the established public
eager-block and builtin trailing-block behavior. Compilation and staged function-body parsing use
`CodeBlock::parse_with_callable_candidates`, then normalize only after typed user-function metadata exists.
Attached `if`/`when`, `switch`, and `while` heads are parsed as controls before generic callable candidates, so
their bodies retain established control semantics. Parenthesized blocks in ordinary non-codeblock positions are
restored to `block_value`; unknown attached callees fail as `callable_contract_rejected`.

Typed user-function descriptors use version 3 with ordinary `params`/`arity` plus exactly one final
`parameter_kinds` entry. The staged body payload/job and compiled function retain that same map. A contextual
block executes through the existing dynamic codeblock evaluator and current caller/function frame—there is no
closure, captured environment, second evaluator, or emitted-source special case. A non-codeblock final value,
including an harray, fails as `final_argument_not_codeblock` with its value kind.

Native execution, compiled-JSON reconstruction, generated-plan execution, and independently compiled emitted
Rust prove the same helper, typed-user-function, receiver, and tree behavior. Established core parser tests,
ordinary eager blocks, callable literals/dynamic calls, variadic functions, semantic projection, structured
failures, and static precedence remain unchanged.

## September 7 callback evaluation reading

`SESSION-STARTUP-READING.3.3.19` reads the complete helper/receiver `with` and
tree-callback coordinators. Contextual `CodeblockArgument` values receive no
positional argument; explicit callable values receive the scoped receiver/leaf.
Both forms still see the temporary `value` binding, and tree callbacks also see
their key/index, path, depth and reduce-only accumulator. `with` restores its
temporary value after callback construction, validation or execution returns a
Result. Traversal constructs/validates its callback and evaluates any initial
accumulator before root-kind dispatch. These are source-reading observations;
the neutral callable contract passes 7 literals/11 calls/23 mutations, while the
native/carrier counts above remain the July milestone evidence.

Related facts: [[rust-callable-codeblock-literal-state]], [[rust-callable-codeblock-dynamic-invocation]],
[[perl-generic-final-codeblock-normalization]], [[final-codeblock-parameter-declaration]].

## September 7 contextual consumer prefix reading

`SESSION-STARTUP-READING.3.3.41` reads callable test lines 1–791. The typed-definition check pins
descriptor version 3 and the final parameter kind in the definition, body payload and staged parse job.
Attached/parenthesized helper, receiver and tree pairs compare five selected normalized fields; user-function
forms separately require codeblock_argument, explicit forms retain codeblock_literal, and serialized compiled
state contains no contextual candidate. Semantic function records retain final-codeblock signature metadata.
Eleven contextual results are compared exactly across native, reconstructed and generated-plan routes.
The subsequent eager-block test only begins in this range; its body and later emitted contextual tests
remain unread. These are assertion-scope observations, not fresh native or emitted execution results.

## September 8 consumer reading completion

Checkpoint SESSION-STARTUP-READING.3.3.42 completes the eager-block test: compiled JSON retains block_value, execution expects the eager result, and an unknown attached callee must contain callable_contract_rejected plus its name. Invalid declarations compare neutral code substrings; typed-function/helper/receiver harray calls compare the exact final_argument_not_codeblock code and harray kind. A separate offline Cargo fixture compiles emitted contextual code and compares the exact result. These are read assertions; fresh proof is the neutral checker, not a new emitted execution.
