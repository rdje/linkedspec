---
id: julia-callable-selector-validation-gap
title: Julia skips retired-selector validation inside explicit and contextual callable bodies
answers:
  - does Julia reject aggregate selectors inside callable codeblocks
  - why can Julia array name or hash name compile inside a deferred body
  - do generated Julia parsers retain the callable selector validation gap
  - which task fixes Julia callable-body selector validation
date: 2026-09-11
status: confirmed defect; JULIA-STARTUP-READING.2.1 repair pending
tags: [julia, callable, selector, validation, compiler, generated, startup]
evidence: "JULIA-STARTUP-READING.1.3 reads ActionAst 965-1698 and ActionContracts 1-766, then isolates the skipped callable-body branch. Twenty controlled Julia outcomes establish native/reconstructed/generated-plan/in-process emitted-module acceptance of forbidden selectors and their rejection after diagnostic-only body descent. All four exact array-source Perl Get controls reject. Existing uniform-binding 61 and focused projection/alias 8 pass; the gap remains unfixed."
reverify:
  - "Run the repository-managed causal reproduction below; it changes only this diagnostic process."
  - "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/uniform_binding_contract_test.jl\")'"
---

# Observed defect

At source baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`, Julia rejects
ordinary `array(items)` and `hash(items)` before execution. Put the same form inside
`{|| ... }` or a contextual `with(...) { ... }` body and compilation succeeds.
The inert literal returns 7 without invoking its body. Invoked array cases return
`[[]]` with `items=[]`; invoked hash cases return `{}` with `items={}`. These are
invalid authored selectors regardless of the eventual value.

For both families the same results survive ordinary native execution, normalized
`SpecFile` JSON reconstruction, generated-plan execution and independently
included emitted source in a fresh module in the same Julia process. No child
process or external emitted compilation is claimed. The two retained computed
controls use `array(copy(items))` / `hash(copy(items))` and remain valid.

The four exact array sources also ran through `LinkedSpec::Get` with
`runtime_ctx_ref`: direct, inert literal, called literal and contextual all fail
with `aggregate_selector_removed surface=array identifier=items replacement=items`
at `compiler_pipeline:build_compiled_rule_table`, attributed to rule Top.
No new observation about Dart, Rust or Lua follows from these controls.

# Cause and causal intervention

`julia/src/action/ActionAst.jl` lines 1212–1214 group explicit and contextual
callables with literal-error nodes and return `nothing` without traversing
`body_ast`. The recursive selector visitor otherwise descends controls, arguments,
writes, aggregate contents, fluent receivers and mutation callbacks.

`julia/src/compiler/CompiledSpec.jl` lines 397–462 call that same visitor for
rule payloads, deferred fluent calls and function bodies. The compile boundary
at 1220, emitter at `julia/src/source/SourceEmitter.jl` 207 and generated-plan
validator at 606 therefore all inherit the omission. This is distinct from
ActionContracts 821–823 intentionally omitting eager dependencies of deferred
bodies: structural rejection does not require eager helper resolution or execution.

A fresh diagnostic process replaces only the skipped visitor branch with typed
body descent. All eight forbidden family/case pairs then fail before execution,
including the inert literals; both computed controls still compile and execute
through all four routes. Repository source, tests and generated formats remain
unchanged. The initial diagnostic attempted a dedented Julia multiline match and
failed before intervention; its corrected exact string match and world-age-safe
module access produce all 20 asserted outcomes without warnings.

The existing uniform-binding consumer passes 61 assertions. Its selector section
at `julia/test/uniform_binding_contract_test.jl` 159–223 covers direct/dead/fluent/
unused-function and caller-constructed direct payloads, but not callable bodies.
An additional eight checks confirm detached AST JSON and the expected numeric,
control and source-boundary aliases. Neither passing set closes this defect.

# Repair ownership and reading limits

`JULIA-STARTUP-READING.2.1.1` owns recursive structural validation with nested,
unused/dead, parameter and valid-constructor controls, preserving deferred
execution and unrelated diagnostic timing. `.2.1.2` owns reconstructed/compiled/
generated entry checks and accurate public proof. Implementation remains behind
startup .3/.4/.5; no finding is closed merely by this diagnosis.

Child .1.3 physically reads 1,500 fragments /41,401 bytes, completing ActionAst
through line 1698 and reading ActionContracts through 766. Cumulative Julia
reading is 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files.
Supporting diagnostic ranges receive no advance numeric reading credit.
[[julia-aggregate-selector-compile-rejection]] retains the original milestone
as historical proof with this current limitation prominently attached.

# Causal reproduction

Run with `bash tools/run_julia_project_data.sh --project=julia <script>` after
saving this code to a repository-managed scratch path. The intervention applies
only to the disposable process; it is not a production fix or acceptance suite.

```julia
using LinkedSpecJulia, JSON3
function diagnose_selectors(labelprefix)
    for family in ("array","hash")
        setup=family=="array" ? "items=[]" : "items={}"
        for (label,tail) in [
            ("direct","return("*family*"(items))"),
            ("inert","cb={|| return("*family*"(items)) }; return(7)"),
            ("called","cb={|| return("*family*"(items)) }; return(cb())"),
            ("contextual","return(with(7) { return("*family*"(items)) })"),
            ("computed","cb={|| return("*family*"(copy(items))) }; return(cb())"),
        ]
            source="Top::\n /x/\n E { "*setup*"; "*tail*" }\n"
            outcome=Dict{String,Any}("round"=>labelprefix,"family"=>family,"case"=>label)
            try
                spec=parse_spec_with_staged_user_function_definitions(source)
                validate_spec(spec)
                compiled=compile_spec(spec)
                outcome["compiled"]=true
                outcome["value"]=runtime_execute(LinkedSpecRuntimeEngine(compiled),"x").value
                restored=compile_spec(from_json(SpecFile,JSON3.read(JSON3.write(to_json(spec)))))
                outcome["reconstructed"]=runtime_execute(LinkedSpecRuntimeEngine(restored),"x").value
                plan=build_generated_rule_plan(compiled)
                outcome["generated_plan"]=execute_generated_parser_v2(compiled,plan,"x","selector-probe.spec")
                emitted=emit_julia_source_v2(compiled,"selector-probe.spec")
                host=Module(gensym(:SelectorProbeHost))
                Base.include_string(host,emitted,"selector-probe-generated.jl")
                generated=Base.invokelatest(getfield,host,:LinkedSpecGeneratedParser)
                outcome["emitted"]=Base.invokelatest(Base.invokelatest(getfield,generated,:execute),"x")
            catch error
                outcome["error"]=sprint(showerror,error)
                get!(outcome,"compiled",false)
            end
            should_compile = label=="computed" || (labelprefix=="original" && label!="direct")
            @assert outcome["compiled"]==should_compile outcome
            if should_compile
                @assert !haskey(outcome,"error") outcome
                @assert all(outcome[route]==outcome["value"] for route in
                    ("reconstructed","generated_plan","emitted")) outcome
            else
                @assert occursin("aggregate_selector_removed surface="*family,
                    outcome["error"]) outcome
            end
            println(JSON3.write(outcome))
        end
    end
end
diagnose_selectors("original")
# Diagnostic-only intervention: replace only the skipped callable-body branch,
# using the exact existing method source; no repository source is written.
text=read("julia/src/action/ActionAst.jl",String)
start=findfirst("function find_removed_aggregate_selector(expr::ActionExpr)",text)
stop=findfirst("\nto_json(span::ActionSourceSpan)",text)
method=text[first(start):prevind(text,first(stop))]
before="    elseif expr isa ActionCodeblockLiteralExpr || expr isa ActionCodeblockArgumentExpr ||\n           expr isa ActionCodeblockLiteralErrorExpr\n        return nothing"
after="    elseif expr isa ActionCodeblockLiteralExpr || expr isa ActionCodeblockArgumentExpr\n        return find_removed_aggregate_selector(expr.body_ast)\n    elseif expr isa ActionCodeblockLiteralErrorExpr\n        return nothing"
@assert length(findall(before,method))==1
Base.include_string(LinkedSpecJulia,replace(method,before=>after),"selector-causal-intervention.jl")
Base.invokelatest(diagnose_selectors,"body_descent")
```
