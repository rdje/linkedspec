---
id: julia-progressive-parent-state-test-gap
title: Julia progressive parent-state matrix compares a disconnected fixture copy
answers:
  - does the Julia progressive authority matrix observe real parent state
  - can Julia progressive parent-state assertions detect mutation outside their fixture copy
  - which repair owns Julia progressive parent-state test coverage
  - does the admitted Julia progressive carrier verify the actual parent cursor
date: 2026-09-11
status: confirmed test-coverage gap; runtime parent-state corruption not reproduced
tags: [julia, progressive, parent-state, testing, startup]
evidence: "JULIA-STARTUP-READING.1.52; activationddf175b01553f886102d4e6eeff2f6759a22e52c; authority consumer348/380 and admitted carrier351; repair .2.27."
reverify: "Run the exact managed matrix diagnostic below; it checks the existing test's observation scope, not desired runtime behavior."
---

# Disconnected parent-state observation

In `julia/test_dormant/progressive_span_dispatch_authority_test.jl:348`, each
execution row copies parent_before. Its only later reference at380 compares that
local dictionary with parent_after. Neither callback, invocation configuration nor
dispatch arguments receive the copy. This assertion checks fixture consistency;
it does not observe runtime parent registers or prove their preservation.

The source has exactly two parent_state references in the complete first testset.
Four row controls create independently changed state: those controls differ from
parent_after while the old assertion still passes. Direct invocation fields do not
reference the fixture dictionary. These are scope controls, not a reproduced
runtime corruption or a claim that the trusted callback was given parent access.

The admitted `julia/test/progressive_span_dispatch_contract_test.jl:351` separately
checks actual native_result.cursor_char_offset equals0. That narrow runtime proof
remains valid, as do resource and result assertions in the authority matrix.
Earlier claims about covering all four execution rows must retain this distinction.
Source architecture intentionally excludes parent registers from the authority;
that structural fact alone is not an integration mutation regression test.

Julia .2.27 owns actual supported-carrier parent-state observations and a mutation
control that the same observation predicate rejects. Other state fields, success
and failure paths and peer consumers need bounded audit after startup .3/.4/.5.
No existing authority-pattern or inherited-grant repair is closed; discovery and
admission remain unchanged. The historical dormant header about a final-path RED
consumer describes its original stage; the final-path carrier is now admitted.

# Exact scope diagnostic

The fully read first testset ends490. Only its enclosing end is appended. The
original184 assertions plus12 row controls pass196 inside the suite, with2 source
selection assertions outside it:198 executed checks. No unread suffix is run.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_PARENT_MATRIX_PROBE'
using LinkedSpecJulia,JSON3,Test
path=joinpath(pwd(),"julia/test_dormant/progressive_span_dispatch_authority_test.jl")
source=join(readlines(path;keep=true)[1:490])*"\nend\n"
@test length(collect(eachmatch(r"\bparent_state\b",source)))==2
anchor="            @test parent_state == row[\"parent_after\"]"
@test count(anchor,source)==1
replacement="""
            @test parent_state == row["parent_after"]
            independent = _julia_progressive_authority_deepcopy(row["parent_before"])
            independent["coverage_probe"] = "changed state outside the assertion"
            @test independent != row["parent_after"]
            @test parent_state == row["parent_after"]
            @test all(name -> getfield(invocation,name) !== parent_state, fieldnames(typeof(invocation)))
"""
include_string(Main,replace(source,anchor=>replacement;count=1),path)
println("PASS execution-row assertion reads only its fixture copy; independent state corruption is invisible, and invocation holds no direct reference to that copy. This is a test-scope diagnostic, not a runtime corruption reproduction.")
JULIA_PARENT_MATRIX_PROBE
```

Related: [[julia-progressive-span-dispatch-authority]],
[[julia-progressive-span-dispatch-carriers]],
[[julia-progressive-authority-boundary-gaps]],
[[julia-staged-result-isolation-test-gap]].
