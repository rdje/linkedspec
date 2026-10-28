# Rust callable semantic rule label

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.43; target freeze43.0.
Status: frozen existing-contract repair target; production43.1 follows.

ADR0031 and callable_codeblock_contract.json require dynamic caller state at
invocation time, without capturing an environment at construction. The complete
named-mark contract isolates marks by declared rule label for one execution.
Combining these existing contracts means a callback invoked by Value uses Value's
mark bucket. A callback name is diagnostic identity, never a new rule namespace.
Same-label recursive invocation-frame isolation remains the separate14.3 target.

## Distinguishing evidence

34.2 retains exact producers, inputs, outputs and three permanent scope tests in
named-mark-number-rust-intake.json.gz. Explicit ignored-test execution produced
three RED failures on native/restored CompiledSpec/generated-plan routes:

- A literal callback reads seven default0! values instead of the caller's stored
  location/width values6!/1!/7!/3!/6!/6!/6! on Unicode inputαβ:cat.
- A callback writing inside cannot read caller finish; its write disappears from
  the caller view: [[[6,null],null,6]] instead of [[[6,6],6,6]].
- First and Second both name a callback cb. First's mark leaks into Second's cb,
  producing [[1,null],[1,null]] instead of [[1,1],[null,null]]. Direct rule reads
  remain missing, distinguishing the pseudo-bucket from normal rule isolation.

## Sole repair owner and boundaries

Engine::execute_codeblock_value already receives the invocation rule_label. Its
body currently calls eval_block_value with a formatted diagnostic codeblock_label.
Bound calls, free/receiver with, and Hash/Array tree callbacks all forward the
semantic label into this same owner. eval_block_value forwards its label through
statements/expressions to mark helpers; typed_mark_byte/offset select that bucket.
Use the existing rule_label for evaluation. Keep callback name/identity in the
existing error wrapper, typed failures and recursion stack; no new API is needed.

Preserve temporary parameter/rest copies, reverse restoration after success or
failure, active-identity cleanup, once-only argument order, local returns and
static-call precedence. Nested callbacks inherit the invocation's semantic rule.
A callback defined under one rule and invoked under another uses the latter's
bucket, not the construction rule. Free/receiver helper and tree callback routes
must preserve that same label. Pure functions keep their active function state
fence even when invoking a callback; this repair grants no parser-state rights.

43.1 enables the three exact regressions without changing their oracles, adds
focused dynamic-invocation/nested/helper/tree scope distinctions, and checks the
nearest callable diagnostics/cycles/parameter cleanup, named marks, ordinary
Number methods and function fences. Retain actual before/after source and output
epochs. No runtime or schema change in43.0, no new vocabulary/name-role/domain,
global bucket, lexical closure, invocation-frame migration or full admission.
