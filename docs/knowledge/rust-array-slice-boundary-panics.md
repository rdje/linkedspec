---
id: rust-array-slice-boundary-panics
title: "Rust array slice panics beyond the array or when start plus count overflows"
answers:
  - "does Rust slice return an empty array for an out of range start"
  - "why does slice panic at engine.rs 9776"
  - "can a large array slice count overflow in Rust"
  - "which task owns Rust array slice bounds repair"
date: 2026-09-07
status: confirmed primary-runtime defects; SESSION-STARTUP-READING.60.1-.60.3 pending
tags: [rust, array, slice, bounds, panic, runtime, parity]
evidence: "SESSION-STARTUP-READING.3.3.21 at 19e943a4b7cbe68a5f538ff3f0ef17c54fc549f3 reads engine.rs 9279-10777, reproduces four small range panics and one Rust-only addition-overflow panic, and compares six bounded cases with Perl Get. Lowered/generated Perl text shows the existing bounds guards. Independent assertions check exact values, exit 101 and panic locations."
reverify: "rg -n 'let end = .start . n.|items\\[start\\.\\.end\\]|__ls_slice_len >' rust/linkedspec-runtime/src/engine.rs perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

# Reproduction and cause

The public catalog `slice(arr, start, n?)` promises an empty array when start
exceeds length. Each case uses input `xhello` and this exact scaffold:

```text
Top::
 I { return(EXPR) }
 /x/ -> Done
Done:
 /[a-z]+/
```

| Name | EXPR | Rust primary | Perl Get |
| --- | --- | --- | --- |
| slice_valid | `slice(["a", "b"], 1, 1)` | `["b"]` | `["b"]` |
| slice_at_end | `slice(["a"], 1, 1)` | `[]` | `[]` |
| slice_beyond | `slice(["a"], 2, 1)` | range panic | `[]` |
| slice_empty_beyond | `slice([], 1, 0)` | range panic | `[]` |
| slice_receiver_beyond | `["a"].slice(2, 1)` | range panic | `[]` |
| slice_omitted_beyond | `slice(["a"], 2)` | range panic | `[]` |
| slice_count_overflow | `slice(["a"], 1, 18446744073709551616)` | addition overflow | not executed |

Successful Rust controls exit 0 with empty stderr. All five failures exit 101
with empty stdout. Four name `engine.rs:9776:49` and `range start index 2 out of
range for slice of length 1` (the empty-array control instead reports index 1,
length 0). The large-count control names `engine.rs:9775:31` and
`attempt to add with overflow`. These are host panics, not structured DSL errors.

The current helper casts start/count to usize, computes
`let end = (start + n).min(items.len())`, then indexes `items[start..end]`.
Clipping end does not constrain start, and addition occurs before clipping.
The exactly representable 2^64 count saturates the usize conversion, then start
1 overflows that addition in the tested debug executable. This result does not
establish release-mode behavior.

Perl `call_spec_handler_subst` and generated-source capture show the existing
`count > 0 && len > start` guard, followed by a clipped end. The implementation
is in `MethodLowering.pm:5913–5945`. All six executed Perl cases create parsers,
return without build/call errors or warnings, and retain null last_error.
All seven descriptors are ready with zero unresolved helpers. The large-count
Perl fixture was lowered/captured, not executed.

`SESSION-STARTUP-READING.60.1` owns normalization/range repair; `.60.2` owns
permanent helper/receiver, carrier and remaining-backend proof; `.60.3` owns book
examples and canonical closure after startup prerequisites. Coordinate integer
conversion ownership `.55`. No repair or generated-runtime result is claimed.

# Retained evidence

All specs, Perl collectors, lowerings, descriptors, generated source and logs are
under `.linkedspec-data/scratch/startup80-helper-boundaries/`. Shared artifact
evidence also includes the scalar controls in
[[rust-scalar-helper-null-and-empty-drift]]: 72 files / 360,400 bytes before the
manifest. The manifest is 14,678 bytes with SHA-256
`7d6398278ab0555a9de0dc3f4395f4c450051a88290895739247465710c73989`.

Primary command: `rust/target/debug/linkedspec-rust --inline-spec <exact spec>
--input xhello` under `tools/project_data_run.sh`. The existing executable is
34,992,496 bytes, SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`.
No compilation was launched. Perl uses `Get` with `runtime_ctx_ref` and a
mutable input reference; generated text was inspected, not independently loaded.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| rust-cli.jsonl | 1666 | 26e5a2a483ad583be562c99a6dfda4b1c417c7221c8f2233b490b31eae5bedfa |
| perl-results.jsonl | 920 | fea770188b8862fd17f511a8cce00fc308c3d004ff44b3bb92fa90531b20850f |

Reconstruct fixtures from the scaffold/table if scratch is later retired. The
reverify field retrieves mechanisms only; it does not rerun native controls.
