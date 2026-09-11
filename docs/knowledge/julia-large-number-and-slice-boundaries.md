---
id: julia-large-number-and-slice-boundaries
title: Julia wraps integer arithmetic loses large finite results and overflows slice bounds
answers:
  - "can Julia numeric helpers wrap signed integers"
  - "why does Julia adding zero to a large finite number return nothing"
  - "why does Julia reject a large integer literal with OverflowError"
  - "can Julia drop_front or slice overflow a large count"
  - "why does Julia substr return empty for a large valid width"
  - "which tasks own Julia numeric and slicing boundary repairs"
date: 2026-09-11
status: confirmed-open
tags: [julia, numeric, overflow, slice, bounds, scalar-text, startup]
evidence: "JULIA-STARTUP-READING.1.17; activation 975c78a30550f875a24ef17f29ad4e9bd77ff61d; 128 native/reconstructed assertions and 64 Perl assertions across 16 Get controls; .2.9/.2.10 repair ownership"
reverify: "Run the managed Julia and Perl fences below; compare exact pre-repair values/kinds and stage boundaries."
---

# Numeric and bounds failures beyond the finite fixture

All cases use input x and the same zero-regex Top action edge to Done's /x/.
Native and SpecFile-JSON Julia agree. Perl Get generates and executes each parser,
with no exception or context last_error in all 16 cases. The Julia diagnostic checks
128 assertions across 32 source/route outcomes; the exact Perl replay passes 64 assertions.

| Expression / control | Julia | Perl Get |
| --- | --- | --- |
| 42 | 42 | 42 |
| 100000000000000000000 | compile OverflowError | 1e20 |
| 100000000000000000000.0 | 1e20 | 1e20 |
| num_add(100000000000000000000.0, 0) | null | 1e20 |
| num_add(-100000000000000000000.0, 0) | null | -1e20 |
| cat(100000000000000000000.0, "") | string 100000000000000000000 | string 1e+20 |
| num_add("100000000000000000000", 0) | null | 1e20 |
| num_add(9223372036854775807, 1) | -9223372036854775808 | 9223372036854775808 |
| num_abs(-9223372036854775808) | -9223372036854775808 | 9223372036854775808 |
| num_div(1, 0) | null | null |
| drop_front([1,2], 2) | [] | [] |
| drop_front([1,2], 9223372036854775807) | runtime BoundsError wrapper | [] |
| slice([1,2], 1, 2) | [2] | [2] |
| slice([1,2], 1, 9223372036854775807) | [] | [2] |
| substr("ab", 1, 2) | b | b |
| substr("ab", 1, 9223372036854775807) | empty string | b |

ActionParser line 494 chooses parse(Int) for integer spelling without a range adapter;
the decimal spelling instead uses Float64 and reaches runtime. Interpreter's
numeric fold and abs perform host integer operations before result normalization,
so wrapped values remain finite and pass through. `_runtime_json_number` attempts
Int conversion for every integral Real and returns nothing on conversion failure;
this loses valid large Float64 values even when adding zero. Scalar text instead
uses BigInt for integral floats, preserving magnitude but printing full decimal.
That separate text spelling question stays with startup .55.2. ADR0029 forbids
silently delegating numeric semantics to host overflow; this finding does not
promise arbitrary-precision arithmetic.

For range helpers, `_runtime_nonnegative_int` preserves valid Int maximum.
`drop_front` adds count+1 before clipping; array slice and substr add start+width
before clipping. Wrapped indices cause BoundsError or an empty reversed range.
Ordinary bounded controls remain correct. Supporting inspection of Interpreter
8996-9010 confirms integer conversion; it grants no advance physical reading credit.

Julia .2.9.1-.2.9.3 own literal/conversion/arithmetic boundaries; .2.10.1/.2.10.2
own safe range arithmetic. Startup .60.2 retains the cross-backend census and .55.2
retains portable text spelling. [[dart-large-number-helper-corruption]] and
[[rust-array-slice-boundary-panics]] retain their separate backend causes/owners.
Fresh generated/emitted/CLI Julia results and the complete numeric domain remain
unmeasured. No runtime or test source changed during this diagnostic.

Existing scalar-text 5 / numeric 4 / string-numeric 14 / array 2 / hash 1 / tree 2 /
uniform 61 / mutation 496 suites pass (585 plus one selected-set equality). Neutral numeric 55/18
and uniform 11/7/6/8 also pass; their finite cases do not cover these magnitudes.
The initial probe used only integer spelling for 1e20, so compile rejection hid
runtime normalization; the decimal and numeric-string controls separate the causes.

## Exact Julia replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_BOUNDARY_ASSERT17'
using LinkedSpecJulia,JSON3,Test
rows=[
("small_literal","42",42,"Int64",nothing),
("large_integer_literal","100000000000000000000",nothing,"OverflowError","overflow parsing"),
("large_float_literal","100000000000000000000.0",1e20,"Float64",nothing),
("large_float_add","num_add(100000000000000000000.0, 0)",nothing,"Nothing",nothing),
("negative_float_add","num_add(-100000000000000000000.0, 0)",nothing,"Nothing",nothing),
("large_float_text","cat(100000000000000000000.0, \"\")","100000000000000000000","String",nothing),
("large_string_add","num_add(\"100000000000000000000\", 0)",nothing,"Nothing",nothing),
("integer_add","num_add(9223372036854775807, 1)",typemin(Int),"Int64",nothing),
("integer_abs","num_abs(-9223372036854775808)",typemin(Int),"Int64",nothing),
("invalid_division","num_div(1, 0)",nothing,"Nothing",nothing),
("normal_drop","drop_front([1,2], 2)",Any[],"Vector{Any}",nothing),
("large_drop","drop_front([1,2], 9223372036854775807)",nothing,"RuntimeInterpreterException","BoundsError"),
("normal_slice","slice([1,2], 1, 2)",Any[2],"Vector{Any}",nothing),
("large_slice","slice([1,2], 1, 9223372036854775807)",Any[],"Vector{Any}",nothing),
("normal_substr","substr(\"ab\", 1, 2)","b","String",nothing),
("large_substr","substr(\"ab\", 1, 9223372036854775807)","","String",nothing)]
@testset "Julia numeric and slicing boundary diagnostic" begin
 for (name,expr,expected,kind,message) in rows
  spec=parse_spec("Top::\n -> Done { return("*expr*") }\nDone:\n /x/\n")
  normalized=JSON3.read(JSON3.write(to_json(spec)),Dict{String,Any})
  for (route,carrier) in [("native",spec),("spec_json",from_json(SpecFile,normalized))]
   result=nothing;stage="compile"
   error=try engine=LinkedSpecRuntimeEngine(compile_spec(carrier));stage="runtime";result=runtime_parse(engine,"x");nothing catch error;error end
   @test stage==(name=="large_integer_literal" ? "compile" : "runtime")
   if message===nothing
    @test error===nothing
    @test isequal(result.value,expected)
    @test string(typeof(result.value))==kind
   else
    @test error!==nothing
    @test string(typeof(error))==kind
    @test occursin(message,sprint(showerror,error))
   end
   println(JSON3.write(Dict("case"=>name,"route"=>route,"stage"=>stage,"value"=>result===nothing ? nothing : result.value,"error"=>error===nothing ? nothing : sprint(showerror,error))))
  end
 end
end
JULIA_BOUNDARY_ASSERT17
```

## Exact Perl reference replay

```bash
bash tools/project_data_run.sh perl -Iperl -Mstrict -Mwarnings -MJSON::PP -MLinkedSpec -MTest::More - <<'PERL_BOUNDARY17'
my @rows=(
 ['small_literal','42',42],['large_integer_literal','100000000000000000000',1e20],
 ['large_float_literal','100000000000000000000.0',1e20],['large_float_add','num_add(100000000000000000000.0, 0)',1e20],
 ['negative_float_add','num_add(-100000000000000000000.0, 0)',-1e20],['large_float_text','cat(100000000000000000000.0, "")','1e+20'],
 ['large_string_add','num_add("100000000000000000000", 0)',1e20],['integer_add','num_add(9223372036854775807, 1)',9223372036854775808],
 ['integer_abs','num_abs(-9223372036854775808)',9223372036854775808],['invalid_division','num_div(1, 0)',undef],
 ['normal_drop','drop_front([1,2], 2)',[]],['large_drop','drop_front([1,2], 9223372036854775807)',[]],
 ['normal_slice','slice([1,2], 1, 2)',[2]],['large_slice','slice([1,2], 1, 9223372036854775807)',[2]],
 ['normal_substr','substr("ab", 1, 2)','b'],['large_substr','substr("ab", 1, 9223372036854775807)','b']);
my $J=JSON::PP->new->canonical(1)->allow_nonref(1);
for my $row (@rows) {
 my ($name,$expr,$expected)=@$row;my $source="Top::\n -> Done { return($expr) }\nDone:\n /x/\n";my %ctx;my ($value,$emitted,$error);
 eval { my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$emitted);my $input='x';$value=$parser->(\$input);1 } or $error="$@";
 ok(!defined($error),"$name no exception");
 ok(!defined($ctx{last_error}),"$name no context error");
 ok(defined($emitted),"$name generated source captured");
 is($J->encode($value),$J->encode($expected),"$name exact JSON value");
}
done_testing();
PERL_BOUNDARY17
```
