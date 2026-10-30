---
id: perl-pick-keys-conditional-local-reuse
title: Perl pick_keys lowers each key with a fresh temporary
answers:
  - why does pick_keys repeat its first key
  - why does a capture map contain values but pick_keys returns null
  - why does Perl pick_keys reuse a key from a previous compilation
  - must Perl parsers be regenerated after the pick_keys operand repair
date: 2026-10-30
status: bounded TYPE-REFERENCE-BOOK.1.2.23.3.45.3 repair; broader regression/admission separate
tags: [perl, actionir, pick_keys, hash, lowering, isolation]
evidence: "perl-phase0-pick-keys-intake.json.gz retains public original/raw-map/bracket/literal controls, conditional-local origin, eight finite RED/GREEN key controls and old emitted-source replay."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/pick_keys_operand_isolation.t t/capture_collection_selection.t t/defined_default_receiver_contract.t"
---

The exact Phase0 entry/local named-map case captures all values correctly. Public
native/fresh raw-map and bracket controls distinguish those snapshots from the
broken projection: the old generated `pick_keys` calls repeat an earlier key,
including across helper calls and compilations. No match-scope or map oracle
change repairs that mechanism.

MethodLowering's `pick_keys` key loop declared and initialized `key_lowered` under
a block-key-only statement modifier. Ordinary keys then reused a retained lowered
expression, skipping their own fallback. The temporary is now declared on every
iteration, followed by conditional block lowering and the existing scalar-key
fallback. Key order, evaluated blocks, result copying and helper/format contracts
remain with their existing owners.

Relevant blame/production diff identifies TYPE18.1 commit
`1ad4335927d71adb22e331d61ebe7df2fd578046` as the introduction while adding block-key
support. Its earlier bounded observations remain historical. Eight new native/
fresh controls distinguish variadic literals, consecutive receivers, variables,
mixed block/literal keys, nesting, empty/zero/missing keys, functions and detached
results. Seven fail before repair and one is healthy; all pass afterward. The
original five-assertion capture-map group then passes its unchanged expectation.
Two public raw-map/bracket controls keep their complete values/source unchanged.

Old emitted-source replay still has the original values; regenerate affected Perl
modules. Runtime refresh alone cannot replace their already lowered keys. Other
frozen Phase0 failures remain owned45 and require fresh selected assessment after
this shared producer repair; this card establishes no full-suite or peer status.
