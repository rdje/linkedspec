---
id: and-or-cursor-ownership-audit
title: "Global parse_mode mutates whole-grammar semantics and already causes default AND parity drift"
answers:
  - "should parse_mode remain a global public override"
  - "what objective justifies overriding seek or consume"
  - "why does default AND behavior differ between Rust and the other backends"
  - "does Rust already derive cursor semantics from rule kind"
  - "what did FUTURE-PARITY-BACKLOG.9.1.0 find"
  - "are AND seek and OR consume meaningful combinations"
  - "what should replace the global parse_mode option"
date: 2026-07-16
status: confirmed
tags: [dsl, runtime, cursor, parse-mode, and-rule, or-rule, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.0 traced parser construction, compiled state, engines, primary commands, descriptors, generated execution, tests, and public docs across Perl/Rust/Dart/Julia/Lua. Exact primary probes over `Top::AND /x/` plus input `prefix x` return `hit` by default on Perl/Dart/Julia/Lua but null on Rust; explicit seek returns hit and explicit consume returns null on all five. Perl toolbox output proves the selected global mode is baked into every generated LinkedRE call. Rust compiler.rs derives Consume for AND and Seek otherwise, but ExecutionOptions can globally overwrite every compiled rule. The shared 62-case CLI matrix does not contain default-AND-leading-junk coverage."
reverify: "rg -n 'parse_mode|parseMode|effective_parse_mode|Determine parse mode' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/HandlerVariantEmitter.pm rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/runtime.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua cli_conformance/manifest.json"
---

## Confirmed current architecture

The public `parse_mode` / `--parse-mode` surface is a whole-parser override, not
an entry-only preference:

- Perl defaults to `seek` and injects the selected value into every generated
  handler.
- Dart, Julia, and Lua store one engine-wide mode, defaulting to `seek`, and use
  it for every rule match.
- Rust alone compiles a per-rule mode (`AND` -> `consume`, otherwise `seek`;
  blind-call-dispatch rules currently receive an additional consume special
  case), but `ExecutionOptions::with_parse_mode` can replace every compiled
  rule's mode for one invocation.
- The primary commands expose the same global override. Rust leaves its override
  unset when the flag is omitted; the other four effectively run global seek.

That last difference creates an uncovered default parity defect. For the same
one-regex `Top::AND` grammar and leading-junk input, Perl/Dart/Julia/Lua seek and
return the match while Rust obeys its compiled AND mode and returns null. The
existing cross-backend primary matrix proves explicit seek and consume but does
not cover default AND behavior.

Descriptor state is also inconsistent with runtime ownership. Perl records the
selected global mode; Dart/Julia/Lua and Rust outward descriptor metadata
hard-code global `seek`; only Rust rule metadata carries a derived per-rule
mode.

## The legitimate semantic objective

All four mathematical combinations are meaningful:

- `AND + seek` is an ordered landmark extractor. The current Perl reference
  accepts `aXXb` for blind-called `First(/a/)`, then `Second(/b/)`.
- `AND + consume` makes the sequence contiguous and rejects that input.
- `OR + seek` scans forward for the first successful alternative.
- `OR + consume` is a strict choice at the current cursor and rejects leading
  junk.

So seek/consume are real matching primitives. This does **not** justify a
caller-global parser override: changing one option silently changes every
nested rule and makes the same `.spec` contract mean different things to
different callers.

## Audit recommendation

Remove the public/global parser override and derive cursor behavior from the
authored rule kind: OR/default families seek; AND families consume. Keep
seek/consume in the low-level alternation API because the runtime needs both
algorithms; a direct matcher choice is not a rule-semantic override.

Do not add a rule-local escape hatch merely to preserve the old four-way matrix.
If a future real grammar proves that the two cross-combinations cannot be
expressed clearly through rule structure or regex composition, that grammar
should motivate a separately designed `.spec` surface rather than reviving a
caller option.

The director resolved the remaining semantic boundary on 2026-07-17: parent
OR/AND mode never propagates to or overrides child OR/AND mode. An OR child
therefore keeps intrinsic seek behavior when invoked by an AND parent, and an
AND child keeps intrinsic consume behavior under an OR parent. ADR `0044` /
`.9.1.1.1` now ratifies the exact contract and implementation split; see
[[rule-local-cursor-ownership-decision]] and
[[rule-local-cursor-and-bare-edge-contract]].

## Migration surface

Implementation must migrate, not silently ignore:

- Perl `Get` / `get_parser` / emitted-source construction and descriptor
  metadata;
- Rust `ExecutionOptions`, runtime-context override, primary command, and the
  blind-call parse-mode special case;
- Dart/Julia/Lua engine constructors, loaded-spec factories, generated roles,
  and primary commands;
- the shared CLI help/usage/success/trace fixture contract;
- the outward descriptor contract from one global mode to derived per-rule
  cursor metadata;
- current tests and examples that use global consume to obtain strict parsing.

Legacy public options should fail with a targeted migration diagnostic rather
than be accepted and ignored. Current behavior remains unchanged until the
backend-neutral decision and implementation leaves land.

Related task: [[FUTURE-PARITY-BACKLOG]] `.9.1.0` / `.9.1.1`.
