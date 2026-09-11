---
id: julia-parser-member-suffix-loss
title: Julia drops unsupported member suffixes before default and strict validation
answers:
  - "does Julia silently discard trailing garbage after a rule member"
  - "can malformed Julia member syntax pass strict validation"
  - "why does Julia reject an I suffix but accept an E suffix"
  - "where do Julia inline and body parsers lose unparsed remainders"
  - "which task repairs Julia complete member consumption"
date: 2026-09-11
status: confirmed source-loss defect; repair pending behind startup prerequisites
tags: [julia, parser, syntax, validation, source-retention, startup-reading]
evidence: "JULIA-STARTUP-READING.1.30 at clean d8956a25e912ca998218a66e4c4567f78493a65f reads spec/Ast102-909 and spec/Parser1-692. Julia .2.19.1/.2 owns both parser loops and supported-route/public repair. Exact managed controls and original frontend test selection follow."
reverify: "Run all three managed blocks below."
---

## Unsupported source is discarded before validation

`julia/src/spec/Parser.jl`555–560 and650–655 handle a failed next-element parse.
They preserve its remainder as `RawBodyElementKind` only when no element has
yet parsed, the remainder begins with an arrow token, or the last element is an
unsupported `I` lifecycle remainder. Otherwise they break and discard the text.
The lifecycle exception is explicitly restricted to `I` at675–684.

A valid `/x/ -> Top { return("ok") }` member followed by `garbage` therefore
has the same parsed body as its clean counterpart. Both normal body and inline
header routes accept it; default and strict validation pass, compilation succeeds,
and runtime returns `"ok"`. A trailing `garbage` after an `E` block is also lost,
and execution returns that block's `"exit"` value. These are successful parses of
incomplete authored syntax, not a runtime mismatch between two valid programs.

The self-target controls intentionally satisfy strict unused-rule policy so
that an unrelated unused-rule error cannot hide this source loss. In an initial
single-rule regex-only control, strict validation reported unused Top after the
suffix had already disappeared; that rejection does not repair member consumption.

An `I` suffix, malformed arrow suffix and separate unsupported line retain exact
raw text and fail both validation modes and compilation. A valid comment remains
accepted. The initial exploratory probe incorrectly tried to serialize
`validate_spec`'s successful `nothing` return with `to_json`; that harness-only
MethodError is excluded from the corrected, asserted controls below.

Julia `.2.19.1` owns both remainder loops and exact RED/GREEN coverage while
preserving deliberate lifecycle/header compatibility. `.2.19.2` owns public,
staged/generated/reconstructed and counterpart recurrence plus designated
canonical closure. This mechanism is separate from attached-switch body omission
under Julia `.2.2` and the previously repaired Lua fluent adapter.

## Exact managed controls

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
member="/x/ -> Top { return(\"ok\") }"
body="Top::\n "*member*"\n"
cases=[
 ("plain",body,nothing,"ok"),
 ("body_suffix","Top::\n "*member*" garbage\n",nothing,"ok"),
 ("inline_suffix","Top:: "*member*" garbage\n",nothing,"ok"),
 ("comment","Top::\n "*member*" # garbage\n",nothing,"ok"),
 ("exit_suffix",replace(body,"return(\"ok\")"=>"set(out,\"ok\")")*" E { return(\"exit\") } garbage\n",nothing,"exit"),
 ("init_suffix",body*" I { return(\"init\") } garbage\n","garbage",nothing),
 ("arrow_suffix","Top::\n "*member*" -> ???\n","-> ???",nothing),
 ("separate_raw",body*" garbage text\n","garbage text",nothing),
]
attempt(f)=try f() catch e;e end
@testset "Julia .1.30 complete member consumption controls" begin
 accepted=String[]; rejected=String[]
 plain_body=to_json(parse_spec(body).rules[1])["body"]
 for (name,source,raw_text,value) in cases
  ast=parse_spec(source)
  raw=[e.kind.text for e in ast.rules[1].body if e.kind isa RawBodyElementKind]
  @test raw==(raw_text===nothing ? String[] : [raw_text])
  regular=attempt(()->validate_spec(ast));strict=attempt(()->validate_spec(ast;strict_syntax=true))
  compiled=attempt(()->compile_spec(ast))
  if raw_text===nothing
   @test regular===nothing
   @test strict===nothing
   @test compiled isa CompiledSpec
   @test runtime_parse(LinkedSpecRuntimeEngine(compiled),"x").value==value
   @test all(!occursin("garbage",e.source) for e in ast.rules[1].body)
   if name in ("plain","body_suffix","comment")
    @test to_json(ast.rules[1])["body"]==plain_body
   end
   push!(accepted,name)
  else
   @test regular isa SpecValidationException
   @test strict isa SpecValidationException
   @test compiled isa SpecValidationException
   @test all(occursin("unrecognized body syntax",sprint(showerror,e)) && occursin(raw_text,sprint(showerror,e)) for e in (regular,strict,compiled))
   push!(rejected,name)
  end
  println(name,": raw=",repr(raw)," default/strict=",raw_text===nothing ? "accepted" : "rejected"," runtime=",repr(value))
 end
 @test accepted==["plain","body_suffix","inline_suffix","comment","exit_suffix"]
 @test rejected==["init_suffix","arrow_suffix","separate_raw"]
 for suffix in (""," garbage")
  returning=body*" E { return(\"exit\") }"*suffix*"\n"
  nonreturning=replace(body,"return(\"ok\")"=>"set(out,\"ok\")")*" E { return(\"exit\") }"*suffix*"\n"
  @test runtime_parse(LinkedSpecRuntimeEngine(compile_spec(parse_spec(returning))),"x").value=="ok"
  @test runtime_parse(LinkedSpecRuntimeEngine(compile_spec(parse_spec(nonreturning))),"x").value=="exit"
 end
end
JL
```

The initial exit control incorrectly expected the E value after an explicit
edge return. Four clean/suffixed comparisons prove explicit return yields ok,
while an edge assignment permits E to yield exit. Interpreter1968 catches the
rule return before later lifecycle execution; the action-block adapter at2872
preserves that return channel. The corrected exit-suffix control uses assignment
so it actually exercises E. This is a corrected probe expectation, not a runtime
repair or a changed parser expectation. The full replay checks both variants.

Eight suffix controls and four explicit-return comparisons pass54 assertions.
Three suffix cases lose source; three rejection controls preserve it; plain and
comment controls remain valid. No production source change is part of intake.

## Original frontend tests without unrelated package execution

The following selection evaluates five unchanged helper definitions and the
three original parser, validator and AST JSON testsets from `runtests.jl`.
It does not replace their assertions or grant unread-test-source credit.
Parser185, validation23 and AST16 pass224 existing assertions; one additional
selection assertion verifies all requested original nodes were evaluated.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust","linkedspec-runtime","tests","corpus")
helpers=Set([:_regex_patterns_of,:_starts_with_top_level_function,:_spec_with_functions,:_function_definition,:_throws_validation_message])
tests=Set(["Spec parser","Spec validation","Spec AST JSON contract"])
seen_helpers=Set{Symbol}();seen_tests=Set{String}()
for expr in Meta.parseall(read("julia/test/runtests.jl",String)).args
 expr isa Expr || continue
 if expr.head==:function && expr.args[1] isa Expr && expr.args[1].head==:call && expr.args[1].args[1] in helpers
  push!(seen_helpers,expr.args[1].args[1]);Core.eval(Main,expr)
 elseif expr.head==:macrocall && expr.args[1]==Symbol("@testset") && length(expr.args)>=3 && expr.args[3] in tests
  push!(seen_tests,expr.args[3]);Core.eval(Main,expr)
 end
end
@test seen_helpers==helpers && seen_tests==tests
println("Exact selection: five original helpers and three original top-level testsets")
JL
```

## Adjacent lifecycle compatibility

The existing standalone lifecycle suite passes103 assertions, bringing existing
frontend/lifecycle proof to327 plus the separate selection assertion. Its neutral
checker passes9 placements/4 duplicates/6 ownership cases/3 malformed twins,
6 runtime routes/15 public documents/7 stale-claim denials/14 mutations. These
finite controls preserve legitimate lifecycle compatibility without closing .2.19.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/standalone_lifecycle_block_contract_test.jl")'
bash tools/run_python_project_data.sh tools/check_standalone_lifecycle_block_contract.py
```
