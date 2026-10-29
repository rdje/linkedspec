---
id: rust-named-capture-endpoint-presence-repair
title: Rust named capture helpers require match presence and named text take preserves anonymous state
answers:
  - "why did Rust capture_from return empty text before matching"
  - "does Rust capture_take with a name advance the anonymous boundary"
  - "does Rust preserve name effects before unavailable capture endpoints"
  - "must Rust emitted source regenerate after named capture endpoint repair"
date: 2026-10-29
status: bounded47.2 four-route repair verified; independent peers/writer49/selection/full admission separate
tags: [rust, capture, named, endpoint, absence, overload, mutation, generated]
evidence: "TYPE47.2 rust-named-capture-endpoint-intake.json.gz retains15-source4healthy11RED ->15pass,33 ordinary bad route observations before code,9 selected tests and exact original source/metadata/healthy proof."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test named_capture_endpoint_absence --test named_mark_number_results --test capture_endpoint_absence -- --test-threads=1"
---

Named text/width/take-width used stored match_start_byte without match_present.
capture_take ignored its named argument and read/mutated anonymous capture_start.
Three named branches now resolve names then check existing presence. A one-argument
named text take uses the same name resolver/typed mark/span and moves only its mark
to live cursor after a valid read. Args were already evaluated before call_helper,
so name effects remain. Anonymous zero-arg, available endpoints and scope/function
owners remain; no new state/frame/schema/helper/domain/arity policy.

Independent15-source SDK/reconstructed/plan/separate emitted4healthy11RED ->15pass.
Ordinary1 harness33 bad routes ->pass. Endpoint1/anonymous1/named Number-scope-
function7 pass9 tests; engine/new normal format clean. Original4 healthy observations
and all source/parsed/compiled/serde/plan/emitted/public metadata exact. Same15 red
source modules relink against updated runtime and pass: rebuild apps, no source
regeneration. Lock versions/sources/checksums match; dependency diagnostics opaque.
Initial formatter issue is only two expanded temporary logging lines; actual red/
final producer retained and temporary probe exactly verified/archived/removed.
Normal consumer has no allocator. No direct final-cursor API, Perl host seed,
peer/writer49/full gate/admission claim; broader prerequisites stay owned.
