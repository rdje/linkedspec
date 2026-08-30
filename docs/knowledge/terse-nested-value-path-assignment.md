---
id: terse-nested-value-path-assignment
title: "SPEC-FORMAT-TERSE.11.4 - nested mixed value-path assignment mutates scalar-held array/hash trees without autovivification."
answers:
  - "how do nested mixed value path writes work"
  - "does payload[\"items\"][0][\"name\"] = value autovivify"
  - "what happens when a nested value path intermediate container is missing"
  - "can nested value path assignment append to arrays"
  - "does nested value path assignment return the updated root"
  - "does single segment payload[1] mutate scalar held arrays"
  - "when does nested value path assignment evaluate index expressions"
date: 2026-07-05
status: current
tags: [spec-format-terse, assignment, nested-access, duck-typing, perl, rust, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.11.4 added typed nested assignment support on Perl and Rust. Multi-segment lvalues such as `payload[\"items\"][0][\"name\"] = value` mutate scalar-held `RuntimeValue` / generated-Perl array/hash trees through explicit path checks. Intermediate path containers must already exist and have the required shape; there is no Perl autovivification. A final hash key may be created or replaced. A final array index may replace an existing element or append exactly at len; gaps return undef/null and leave the root unchanged. Successful expression-valued nested assignment returns the updated root, while missing/wrong paths return undef/null. Segment index expressions are evaluated before the RHS value expression, and the root path check/mutation happens after both have been evaluated. Single-segment `payload[1] = value` also mutates a scalar-held array root when `payload` currently holds an array value; named hash storage remains the fallback when the bare name is not scalar-bound. The Rust integration tests `terse_11_4_*` pass, and the manifest-backed oracle corpus includes `terse_11_4_nested_mixed_value_path_assignment` with 92 fixtures."
evidence_update_2026_08_30_future_contract_boundary: "FUTURE-PARITY-BACKLOG.19.1.1 reconfirms this unchanged current boundary on Perl, Rust (three exact tests), Dart (one exact test), Julia (one exact corpus case), PUC Lua, and LuaJIT while freezing a separate future neutral contract. Current lowering chooses quoted key versus computed index statically; the future contract instead uses each segment's evaluated string/integer kind and unifies one-/multi-segment writes under assign_nested_access. No current backend behavior is admitted by .19.1.1."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $spec = qq{Top::\\n /x/ -> Done { set(value, \"new\"); payload = { \"items\" : [{ \"name\" : \"old\" }] }; payload[\"items\"][0][\"name\"] = value; payload[\"items\"][1] = { \"name\" : \"tail\" }; missing_result = payload[\"missing\"][0] = \"bad\"; wrong_result = payload[\"items\"][0][0] = \"bad\"; root_array = [{ \"name\" : \"old\" }]; root_array[0][\"name\"] = value; root_array[1] = { \"name\" : \"tail\" }; return(array(payload, missing_result, wrong_result, root_array, (payload[\"items\"][3] = \"gap\"))) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p = LinkedSpec::Get(\\$spec); my $in = \"xhello\"; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), \"\\n\";' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_11_4 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Nested Value-Path Assignment

Nested value-path assignment mutates scalar-held array/hash payloads through the same direct-access segment
syntax used for reads:

```text
payload["items"][0]["name"] = value
payload["items"][1] = { "name" : "tail" }
```

The write path is explicit and does not inherit Perl autovivification:

- every intermediate hash key or array element must already exist;
- every intermediate value must have the required hash/array shape;
- the final hash key may be created or replaced;
- the final array index may replace an existing element or append exactly at the current array length;
- array gaps, missing intermediates, and wrong-shape transitions return `undef` / `null` and do not mutate the root.

In value positions, successful nested assignment returns the updated root value; failed path checks return
`undef` / `null`. Single-segment assignment such as `payload[1] = value` mutates a scalar-held array root when the
bare name currently holds an array value.

Evaluation order is segment expressions first, then the RHS value expression, then root path validation and
mutation. A failing path therefore does not mutate the root, but any side effects from already evaluated index or
RHS expressions follow the normal expression-evaluation model.

The separately future [[write-vivification-neutral-contract]] preserves this current behavior until its backend
leaves land; it is not evidence that missing intermediates currently create containers.
