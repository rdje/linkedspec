---
id: julia-spec-lexical-boundary-defects
title: Julia body fluents discard suffixes and outer scanners misread literal delimiters
answers:
  - "does Julia body fluent parsing discard invalid suffixes"
  - "why does Julia compile a body fluent with an empty method name"
  - "why does Julia I.return with a quoted opening parenthesis return null"
  - "why does Julia reject a quoted closing parenthesis in a compact lifecycle call"
  - "does Julia outer spec parsing truncate regex closing braces"
  - "does Julia reject an unterminated explicit or shorthand lifecycle block"
date: 2026-09-11
status: confirmed bounded lexical defects; separate repair owners pending
tags: [julia, parser, fluent, regex, source-retention, startup-reading]
evidence: "JULIA-STARTUP-READING.1.31 at clean 71f7b176ac7e1b7847688b81b32e11f3adc340db completes Parser693-1370 and reads UnicodeRuleLabel1-822. Eighteen native probes separate body suffix loss, compact literal corruption, regex-brace truncation and correct EOF rejection. Julia .2.19 is extended; .2.20 and .2.21 own separate lexical repairs."
reverify: "Run both managed blocks below and the original frontend selection identified at the end."
---

## Body-fluent remainder loss

`julia/src/spec/Parser.jl`871–878 takes only the fluent helper's calls and
hardcodes an empty remainder. This precedes the two conditional remainder loops
already owned by Julia `.2.19`. Both layers must preserve unsupported text.
`.Töp()` compiles as method T; `.Top-Rule()` and `.Top() @unexpected` compile
with the same body as `.Top()`. The Unicode host-word adapter also accepts
`.öp()`, while the ASCII method scanner yields an empty method; compilation
accepts that empty identity. Exact source remains `.Töp` or `.öp`, so even
the retained token source disagrees with the compiled fluent's method.

The helper at1242–1266 does retain the Unicode/hyphen/unknown suffix. The adapter
discards it at876. An own-line `@unexpected` remains raw and rejects at line3;
ASCII and comment twins are accepted. `.2.19.1` now explicitly owns this earlier
adapter boundary and empty/partial identity rejection. These body-fluent controls
measure parsing and compilation only, without claiming runtime helper execution.

## Compact quoted parentheses

The completeness scanner at1136–1203 skips quoted/regex literals, but argument
extraction at1280–1299 counts all parentheses. A failed extraction becomes an
empty argument list and empty remainder at1257–1258. Thus `I.return("(")`
becomes `return()` and executes to null with matched=false. Its braced twin
returns the opening parenthesis. `I.return(")")` instead truncates to
`return(")`, retains a raw `")` suffix and fails validation; its braced twin
returns the closing parenthesis. Plain compact return remains valid.
Julia `.2.20.1/.2` owns lexical extraction, malformed-input retention and supported
routes, coordinated with Rust startup `.52.2` and Dart `.2.7`.

## Regex braces and retained EOF failures

The outer brace scanner at1205–1239 tracks quotes but has no regex state.
`I { return(matches("}", /}/)) }` therefore ends its outer source at the regex
brace, leaving partial code `return(matches("}", /` and raw `/)) }`.
Compilation rejects that tail, while ordinary `/x/` compiles and executes true.
Julia `.2.21.1/.2` owns outer lexical tracking plus downstream balance audit and
shared startup `.54.3` public recurrence. No other-backend result is newly claimed.

At EOF, `_consume_block_from_rest` returns accumulated content even if depth is
nonzero, but preserves the opening source. Both explicit `I {` and shorthand `{`
unterminated controls are subsequently rejected as one unmatched open brace.
Their closed twins return ok. This is a positive validation boundary, not a
confirmed missing-brace acceptance defect.

## Exact native replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
cases=[("fluent_ascii",".Top()"),("fluent_unicode",".Töp()"),("fluent_hyphen",".Top-Rule()"),("fluent_suffix",".Top() @unexpected"),("fluent_comment",".Top() # comment"),("fluent_own_line",".Top()\n @unexpected"),("fluent_no_prefix",".öp()"),("compact_plain","I.return(\"ok\")"),("compact_close","I.return(\")\")"),("braced_close","I { return(\")\") }"),("compact_open","I.return(\"(\")"),("braced_open","I { return(\"(\") }"),("regex_brace","I { return(matches(\"}\", /}/)) }"),("regex_plain","I { return(matches(\"x\", /x/)) }"),("block_closed","I { return(\"ok\") }"),("block_eof","I { return(\"ok\")"),("shorthand_closed","{ return(\"ok\") }"),("shorthand_eof","{ return(\"ok\")")]
methods=Dict("fluent_ascii"=>"Top","fluent_unicode"=>"T","fluent_hyphen"=>"Top","fluent_suffix"=>"Top","fluent_comment"=>"Top","fluent_own_line"=>"Top","fluent_no_prefix"=>"")
remainders=Dict("fluent_ascii"=>"","fluent_unicode"=>"öp()","fluent_hyphen"=>"-Rule()","fluent_suffix"=>"@unexpected","fluent_comment"=>"# comment","fluent_own_line"=>"@unexpected","fluent_no_prefix"=>"öp()")
failures=Dict("fluent_own_line"=>"unrecognized body syntax at line 3: @unexpected","compact_close"=>"unrecognized body syntax at line 2: \")","regex_brace"=>"unrecognized body syntax at line 2: /)) }","block_eof"=>"unbalanced braces: 1 unmatched open","shorthand_eof"=>"unbalanced braces: 1 unmatched open")
values=Dict{String,Any}("compact_plain"=>"ok","braced_close"=>")","compact_open"=>nothing,"braced_open"=>"(","regex_plain"=>true,"block_closed"=>"ok","shorthand_closed"=>"ok")
attempt(f)=try f() catch e;e end
@testset "Julia .1.31 lexical boundary controls" begin
 @test length(cases)==18 && length(unique(first.(cases)))==18
 for (name,member) in cases
  source="Top::\n "*member*"\n";ast=parse_spec(source)
  @test length(ast.rules)==1
  first_kind=ast.rules[1].body[1].kind
  compiled=attempt(()->compile_spec(ast))
  if startswith(name,"fluent_")
   @test first_kind isa FluentChainBodyElementKind
   @test [(c.method,c.args) for c in first_kind.calls]==[(methods[name],"")]
   helper=LinkedSpecJulia._parse_fluent_chain_with_remainder(member)
   @test helper.remainder==remainders[name]
   expected_source=name=="fluent_unicode" ? ".Töp" : name=="fluent_no_prefix" ? ".öp" : ".Top"
   @test ast.rules[1].body[1].source==expected_source
  else
   @test first_kind isa CodeBlockBodyElementKind && first_kind.lifecycle=="I"
  end
  if haskey(failures,name)
   @test compiled isa SpecValidationException
   @test occursin(failures[name],sprint(showerror,compiled))
  else
   @test compiled isa CompiledSpec
   @test all(!(e.kind isa RawBodyElementKind) for e in ast.rules[1].body)
  end
  if haskey(values,name)
   result=runtime_parse(LinkedSpecRuntimeEngine(compiled),"x")
   @test result.value==values[name]
   @test result.matched==(name!="compact_open")
  end
  if name=="compact_open"
   @test first_kind.code=="return()"
  elseif name=="compact_close"
   @test first_kind.code=="return(\")"
   @test ast.rules[1].body[2].kind.text=="\")"
  elseif name=="regex_brace"
   @test first_kind.code=="return(matches(\"}\", /"
   @test ast.rules[1].body[1].source=="I { return(matches(\"}\", /}"
   @test ast.rules[1].body[2].kind.text=="/)) }"
  elseif name in ("block_eof","shorthand_eof")
   @test ast.rules[1].body[1].source==member*"\n"
  end
  println(name,": compile=",haskey(failures,name) ? "rejected" : "accepted",haskey(values,name) ? " value="*repr(values[name]) : "")
 end
end
JL
```

Eighteen cases pass116 assertions: seven limitation cases and eleven comparison
controls. Existing classifier1674/routes81 pass1755, and original frontend224
adds a separate selection assertion. Fresh existing proof totals1979 assertions.
No emitted, reconstructed-runtime, CLI, MCP or fresh other-backend diagnostic
recurrence is claimed. Unicode control coverage includes programmatic and JSON
label validation; classifier functions after line822 remain unread.

## Existing Unicode boundaries

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/unicode_rule_label_classifier_test.jl"); include("julia/test/unicode_rule_label_routes_test.jl")'
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py
```

The original frontend selection is the second managed block of
[[julia-parser-member-suffix-loss]]; it was rerun unchanged for this slice.
