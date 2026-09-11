---
id: julia-selected-slot-mode-validation-gap
title: Julia selected-slot matching validates mode only after a regex match
answers:
  - "does Julia selected regex slot matching reject invalid modes on a miss"
  - "why does Julia match_runtime_regex_slot ignore an invalid mode"
  - "do Julia ordinary and selected-slot matchers validate mode at the same time"
  - "which task owns Julia selected-slot mode preflight"
date: 2026-09-11
status: confirmed-open
tags: [julia, matching, regex, validation, startup]
evidence: "JULIA-STARTUP-READING.1.19; activation c746951cf298f103e48d1b20c6510c425109ca5c;28 assertions across8 malformed-mode and4 valid controls; Julia .2.12 owns repair."
reverify: "Run the managed direct-matcher assertion fence below; it pins pre-repair behavior."
---

# Selected-slot mode rejection depends on input

Both runtime_match and match_runtime_regex_slot are exported low-level match APIs.
For a single pattern x at cursor0, ordinary runtime_match rejects invalid mode
name scan and integer7 for both input x and y. Selected-slot matching rejects
both bad modes on x but returns nothing with no error on y. Four seek/consume
controls retain expected matching/missing behavior and offsets.

Matching175-205 selects the slot, checks the cursor, performs native match, and
returns immediately on a miss. Only a successful match reaches _normalize_parse_mode.
The ordinary runtime_match normalizes first. This is a validation-order defect in
the low-level API. It neither restores the removed global engine/CLI mode option
nor establishes a failing authored rule-local mode path: normal callers pass a
valid mode. Julia .2.12.1/.2 own deterministic preflight and dependent proof.

Existing matcher60/diagnostic7/duplicate-slot121/recognition207/gap319 assertions
pass (714 plus one selected-set equality); neutral recognition138/250/58 and
gap63/public34 also pass. Fresh generated/emitted reproduction of this invalid
host-argument defect is not claimed; source and tests remain unchanged.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_SLOT19_PROBE'
using LinkedSpecJulia,JSON3,Test
alt=RuntimeRegexAlternation(["x"])
@testset "Julia selected-slot mode validation order" begin
 for mode in Any["scan",7], input in ["x","y"], route in ["ordinary","selected"]
  result=nothing;error=try result=route=="ordinary" ? runtime_match(alt,input;parse_mode=mode) : match_runtime_regex_slot(alt,0,input;parse_mode=mode);nothing catch error;error end
  rejects=route=="ordinary" || input=="x"
  @test rejects ? error isa RuntimeRegexException : error===nothing
  @test rejects ? occursin(mode isa String ? "unsupported parse mode 'scan'" : "parse mode must be seek or consume",sprint(showerror,error)) : result===nothing
  println(JSON3.write(Dict("mode"=>mode,"input"=>input,"route"=>route,"error"=>error===nothing ? nothing : sprint(showerror,error))))
 end
 for (mode,input,expected) in [("seek","yx",1),("consume","yx",nothing),("seek","y",nothing),("consume","x",0)]
  error=nothing;result=try match_runtime_regex_slot(alt,0,input;parse_mode=mode) catch problem;error=problem;nothing end
  @test error===nothing
  @test expected===nothing ? result===nothing : result!==nothing
  @test expected===nothing ? result===nothing : result.codeunit_start==expected
 end
end
JULIA_SLOT19_PROBE
```
