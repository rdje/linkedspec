---
id: dart-null-return-and-pure-observation-gaps
title: Dart completed null lifecycle returns lose match status and pure-null coordinator observations are classified failed
answers:
  - "why does Dart pure null coordinator observation report failed"
date: 2026-10-28
status: bounded null-return39.2.7.1 and pure-null observation39.2.7.2 repaired/targeted-checked; peers/admission remain
tags: [dart, null, acceptance, lifecycle, observation, coordinator, return-provenance]
evidence: "perl-blind-parent-intake.json.gz retains same10 raw source SDK inputs/results/modules and read_parent_dart_probe.py receipt; native/restored/generated-plan agree, fresh execution unassessed in this diagnostic."
reverify: "Recover retained dart/.dart_tool/blind-parent-probe/intake.dart and fixture; cd dart && bash ../tools/run_dart_project_data.sh run .dart_tool/blind-parent-probe/intake.dart"
---

Same-source native/restored/generated-plan Dart probes show completed blind
OR{2}/AND{2} children followed by EX/E returnundef report[false,null,2]; IT
returnundef after one completed child reports[false,null,1]. _returned derives
matched from value != null, losing the owning path's actual accepted outcome.
Existing strict match/payload separation requires successful null to remain
distinct from true minimum/no-hit failure. No full action/lifecycle family is
inferred defective without its own qualifier/probe. Child post-call group null
and actual ordinary observation failure controls are already healthy.

A pure Coordinator I returnundef with no regex/edges is observed as failed,
with no accepted exit. Canonical normal zero-regex coordinator observation is
accepted and has no invented selected match. Current completion uses matched
without a pure normal-return distinction. P1 .7.1 owns return provenance, .7.2
owns pure-observation classification, both immediately after current Perl39.9.2
before peers/admission. Preserve actual failed matcher/minimum, no-hit, early I,
real errors/progress/source/cursor/lineage and public schema. Never globally
mark every null accepted or use a sticky previous child match.

All10 sources compile and execute the three SDK carriers; emitted modules are
retained but fresh execution is not claimed in this diagnostic. No Dart code
edit or inferred Julia/Lua defect occurs in the current Perl parent repair.

39.2.7.1 now repairs accepted-null action/lifecycle provenance on20 exact
authored sources37 inputs5healthy15RED ->20pass SDK/plan, same baseline emitted
modules and122 nearest controls. Current mechanism/proof is owned by
[[dart-accepted-null-return-provenance]]. Original diagnostic above remains
historical; pure-null coordinator observation .7.2 is the next separate repair.

39.2.7.2 now repairs the pure-normal completion classifier using compiled
recognition-structure presence (regex/action/blind edges), without modifying
parser matched status or selected span. Normal pure coordinators are observed
accepted even for explicit/implicit null and after ordinary child calls. Real
matcher/minimum/no-hit/early I failures still need matchedtrue; abort/rejected
errors remain errors.13 sources17 inputs9healthy4actualRED ->13pass SDK/plan
and same13 baseline fresh modules, exact nine-field records/input identity;63
nearest tests/fatal analysis pass. Packet dart-pure-observation-intake.json.gz
retains actual input/producer/runtime epochs. Bounded .7 complete; peers and
full admission remain.
