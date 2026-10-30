---
id: perl-sorted-values-scalar-host-isolation
title: "Perl sorted_values scalar inputs must not select symbolic host hashes"
answers:
  - "why did sorted_values of length read main numeric hash storage"
  - "can sorted_values numeric literals be mistaken for legacy Hash bindings"
  - "does sorted_values scalar host isolation require parser regeneration"
  - "does the sorted_values repair close all collection host slot defects"
date: 2026-10-30
status: bounded producer repair; broader collection isolation remains open
tags: ["perl", "hash", "generated-source", "receiver"]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.45.11.1; perl-sorted-values-scalar-isolation-intake.json.gz retains actual producer, before/after source,8RED/7healthy ->15GREEN, Hash14, String6, five old/new emitted sources and exact metadata controls."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/sorted_values_scalar_isolation.t"
---

# Perl sorted_values scalar inputs must not select symbolic host hashes

At activation `c813d59d9d4d1eaa2d8714aa64ababcc4a7f4458`, public emitted
`sorted_values(3)`, `sorted_values(length("abc"))` and
`"abc".length().sorted_values()` returned `[]` in empty host state but
`["HOST_MAIN"]` with a controlled `main::3` Hash. Seeding only the generated
package's numeric Hash did not distinguish the defect. Computed and bound
Strings also selected symbolic Hash storage in the emitted module's package.

The `sorted_values` branch in `perl/LinkedSpec/ActionIR/MethodLowering.pm`
accepted numeric literals through the legacy `\w+` Hash-symbol matcher and
dereferenced computed scalars under generated `no strict`. The bounded repair
uses the existing numeric AST kind to distinguish literals from legacy Hash
bindings, then requires a reference before computed Hash dereference. It
evaluates the source once, preserves the existing nonreference/undefined `[]`
fallback, actual Hash key ordering, and legitimate legacy Hash bindings.

This does not introduce a universal wrong-kind policy. A direct Array-reference
probe retains the native runtime-handler failure and fresh emitted thrown
reference failure. Copy and scalar-String result guards still yield null for
incompatible Hash continuations. `count-length-results.md` explicitly preserves
the next helper's existing policy; it does not require all such tails to be null.

Five retained modules replayed after the compiler fix retain their old behavior;
regenerate affected parsers. Their complete six-key metadata, including v2
contract, source identity and plan, agrees with newly emitted modules. No schema
or serialized format changes. The seeded normal names its exact namespaces;
no all-host/native-namespace isolation claim is inferred.

Broader absent/legacy binding isolation and other collection helpers remain
owned by `SESSION-STARTUP-READING.17`, especially `.17.2`. This repair does not
close that task. Original String receiver oracle reconciliation follows under
`TYPE-REFERENCE-BOOK.1.2.23.3.45.11.2`; portable admission remains separate.
