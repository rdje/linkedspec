# 0138 — Preserve scalar and null values through copy

- Date: 2026-10-27
- Status: accepted implementation target by explicit director choice; rollout and canonical admission remain open
- Tags: language, values, copy, scalar, null, compatibility
- Owner: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2`

## Context

ADR0007 unified Array/Hash copying. Existing ordinary Perl/Rust scalar fallbacks
and result guards differ from Dart/Julia/Lua value copying. The retained intake is
`docs/checkpoints/type-operation-inventory/copy-domains.md`; its prior observations
remain historical evidence. The director selected the recommended extension:
“Extend copy to preserve scalar/null values,” while retaining existing container
copy-depth rules. This is explicit authority to advance the reference behavior.

## Decision

1. `copy(value)` and ordinary `value.copy()` preserve accepted Bool, Number, String
   and null values and their kinds. False stays Bool, numeric zero stays Number,
   String "0" stays String, and null/missing-value reads stay null. No conversion,
   truth test, empty-array replacement or default substitution defines copying.
2. Evaluate the source once. Preserve its value before later consumer effects,
   existing source-error propagation and non-creating binding reads. Dispatch a
   continuation from the actual copied kind. Incompatible container consumers
   reject before their operands, retaining completed valid prefix effects.
3. Retain existing Array/Hash copy depth, detachment and aliasing by backend and
   execution context. This decision does not authorize a depth normalization or
   new copying/invocation/provenance rights for callable or opaque host values.
4. Receiver `copy()` keeps zero authored operands and its existing malformed-shape
   pre-effect rejection. Preserve free-helper malformed-signature policies pending
   their separate signature owner; `copy(missing)` is not an empty-argument call.
5. Extend input domains only where copy is already supported. Do not add deferred
   vocabulary, computed-call syntax, mutation targets, types or serialized formats.
   Existing interpreted copy paths must be assessed independently before changes.

## Consequences

Perl advances first, followed by independent Rust, Dart, Julia and safe Lua work.
Old scalar fallback/result-guard expectations may change only under this explicit
target; unrelated controls and frozen historical measurements are retained.
Each ordinary implementation child uses focused verification under the director's
feature-first cadence. Full source/context/portable/canonical admission remains
TYPE23.4 and the final clean push boundary. No current backend capability, complete
copy parity or new public support is claimed by this design-only adoption.

## Links

- [Task ownership](../tasks/TYPE-REFERENCE-BOOK.md)
- [Frozen rollout target](../checkpoints/type-operation-inventory/copy-value-preservation.md)
- [Perl-reference authority](0006-multi-backend-vision.md)
- [Terse language evolution](0007-spec-format-terse-direction.md)
