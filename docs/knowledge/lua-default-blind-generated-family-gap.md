---
id: lua-default-blind-generated-family-gap
title: Lua implicit Default blind repetition is misclassified as generated AND blind
answers:
  - "why do Lua Default blind native and generated collections differ"
  - "why does Lua emit and_bcode for Default blind repetition"
  - "who owns Lua Default blind generated-family repair"
date: 2026-10-29
status: P1 owned39.4.9 immediately after runtime collection .4 before .5/admission
tags: [lua, luajit, default, blind, generated, family, classifier]
evidence: "39.4.4 lua-blind-collection-intake.json.gz retains exact Default source/SDK/plan/emission/actual trace and diagnosis: metadata Default/is_repetitiontrue/rep_min0/is_andfalse but plan Top and_bcode, native flat collection vs generated nested AND group after runtime-only fix."
reverify: "Recover inspect_lua_blind_default.py and current owned producers; use both installed hosts and exact Default source. Unsafe formatter/full suite excluded."
---

Actual compiled metadata makes Top Default an OR/default repetition with minimum0;
native trace enters or_default/seek and chooses A/B/B/A on abba. Generated plan
instead selects and_bcode. source_emitter.lua classify_generated_rule_family lists
explicit repeated modes, omits Default implicit blind repetition, then defaults
nonexplicit blind cases to and_bcode. Generated interpreter correctly follows its
supplied family, exposing the classification defect. On the baseline native A
already differed from generated[A,B]; after bounded runtime collection native
[A,B,B,A] is correct while generated[[A,B]] remains wrong. Both hosts reproduce.

P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.4.9 owns immediate existing-authority repair
after runtime .4 before post-call .5/admission, explicit derived-row correction,
stale-artifact/regeneration and metadata/SDK/plan/fresh/trace controls. Preserve
format2/minimal label-family rows/ten-family vocabulary; any new schema/authority
needs separate canonical ownership. Default gets no completed portable .4 credit.
The initial diagnosis reader assumed a nonexistent regex_patterns JSON key;
corrected projection reads the actual mode_metadata/plan/trace, no product RED
credit from that harness error. All original runtime/source epochs retained.
