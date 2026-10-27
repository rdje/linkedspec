---
id: rust-with-final-callback-snapshot
title: Rust resolves final with callback values before temporary value rebinding
answers:
  - why does a Rust callback named value fail as final_argument_not_codeblock
  - can a caller codeblock named value be passed to Rust with
  - when does Rust evaluate the final callback relative to scoped value
  - do Rust with callback argument effects survive validation failure
  - which task owns Rust helper receiver callback shadowing
date: 2026-10-27
status: bounded31.6.5 repaired; full argument/context admission remains23.4
tags: [rust, with, callback, evaluation-order, scope, defect]
evidence: "TYPE31.6.5 at cleanceb4382a4 retains callback-snapshot-rust-intake.json.gz; four first-native source failures and one healthy all-route control before production."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test with_callback_snapshot"
---

Helper with and receiver with previously installed scoped value before resolving
the final callback expression. A caller callback stored as value was then read as
the supplied String and rejected as final_argument_not_codeblock/scalar. Named cb
controls were healthy; opaque callback expressions and first-source replacement
of the callback independently distinguish the same scope/order defect.

31.6.5 evaluates the value argument/receiver first, then resolves and validates
the final callback once in caller context, then installs scoped value and invokes.
Only the callback value is retained; its body still uses dynamic caller context.
There is no environment capture or new helper/signature/AST/serialized field.

Five native/restored/plan tests pass helper/receiver ok!/again!, opaque SCB/SCBB,
new:ok/new:again after first-source replacement, and healthy cb/SC/outer. Direct
identity8 and with-result5 pass. One unit confirms ordinary argument assignment
persists when final callback validation fails; a failed body restores scoped value,
removes its temporary parameter and leaves no active callback frame. Offline
compile/rustfmt pass. Existing arity guards/error vocabulary stay in their owners;
full argument/context/alias/backend admission is not inferred.
