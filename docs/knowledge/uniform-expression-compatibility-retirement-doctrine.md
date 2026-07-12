---
id: uniform-expression-compatibility-retirement-doctrine
title: LinkedSpec compatibility is temporary and variables have one duck-typed value binding
answers:
  - is backward compatibility permanent in LinkedSpec
  - why should array name and hash name wrappers be retired
  - are if and switch expressions in LinkedSpec
  - are helper and user function calls expressions
  - what values can every LinkedSpec expression return
  - what happens when an expression value is unused
date: 2026-07-12
status: current
tags: [language, doctrine, expressions, duck-typing, compatibility, wrappers, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification 2026-07-12: every spec construct is an expression yielding scalar/array/harray/codeblock; if/switch, helper calls, user functions, and method calls participate; unused values are silently dropped; callable signatures may accept a trailing codeblock; backward compatibility is temporary and removed after settlement. The director explicitly settles removal of spec-facing array(IDENTIFIER)/hash(IDENTIFIER) namespace, typed-read, and mutation semantics. FUTURE-PARITY-BACKLOG.12.1 owns migration and hard retirement; only ordinary non-selector constructor classification is separate."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG.12|VALUE_DROP|inline if|inline switch|generic final-codeblock|duck-typed' docs/tasks docs/knowledge ROADMAP.md ROADMAP_V2.md"
---

## Doctrine

Every `.spec` construct is an expression whose value is scalar, array, harray, or codeblock. Assignment, helper
calls, user-function calls, method calls, `if`, and `switch` follow that rule. A statement is an expression whose
result is unused; dropping that value is silent and harmless. A callable may declare its final argument as a
codeblock, making attached trailing-block syntax equivalent to passing the block value explicitly.

Variables have one binding and runtime value type drives dispatch. The current `.spec` forms `array(name)` and
`hash(name)` contradict that rule when they select an alternate namespace, assert the read type, identify a
mutation target, or grant mutation authority. Those selector forms are decided for removal; they are not a pending
language-design question. Active `FUTURE-PARITY-BACKLOG.12.1` inventories, migrates, diagnoses, and hard-retires
them across all backends and shipped sources. It separately classifies whether ordinary non-selector constructor
calls remain useful or literals replace them.

Backward compatibility may ease migration temporarily, but every compatibility surface requires an explicit
removal condition and owner. Settled semantics take precedence over preserving historical spellings or storage.
