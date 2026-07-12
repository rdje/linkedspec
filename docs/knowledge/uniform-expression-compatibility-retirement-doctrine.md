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
evidence: "Director clarification 2026-07-12: every spec construct is an expression yielding scalar/array/harray/codeblock; if/switch, helper calls, user functions, and method calls participate; unused values are silently dropped; callable signatures may accept a trailing codeblock; backward compatibility is temporary and removed after settlement. Existing SPEC-FORMAT-TERSE and FUTURE-PARITY-BACKLOG.11 records cover most expression/codeblock behavior. FUTURE-PARITY-BACKLOG.12 now owns the remaining compatibility retirement, especially array(name)/hash(name) selecting legacy aggregate storage beside duck-typed variable values."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG.12|VALUE_DROP|inline if|inline switch|generic final-codeblock|duck-typed' docs/tasks docs/knowledge ROADMAP.md ROADMAP_V2.md"
---

## Doctrine

Every `.spec` construct is an expression whose value is scalar, array, harray, or codeblock. Assignment, helper
calls, user-function calls, method calls, `if`, and `switch` follow that rule. A statement is an expression whose
result is unused; dropping that value is silent and harmless. A callable may declare its final argument as a
codeblock, making attached trailing-block syntax equivalent to passing the block value explicitly.

Variables have one binding and runtime value type drives dispatch. The current generated-Perl-compatible split
between a scalar slot holding an array/hash value and separate `@array`/`%hash` stores is transitional debt.
`array(name)` and `hash(name)` therefore cannot remain permanently as alternate namespaces, type assertions, or
mutation authority. Design leaf `FUTURE-PARITY-BACKLOG.12.1` will decide whether those names survive only as
ordinary constructors or are fully replaced by literals, then split cross-backend migration and hard retirement.

Backward compatibility may ease migration temporarily, but every compatibility surface requires an explicit
removal condition and owner. Settled semantics take precedence over preserving historical spellings or storage.
