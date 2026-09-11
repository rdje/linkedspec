---
id: julia-input-slice-arity-and-count-boundaries
title: Julia input slicing clips integer widths safely but accepts wrong arity and throws on large floats
answers:
  - "does Julia input_slice overflow at a large integer width"
  - "does Julia input_slice require two arguments"
  - "does Julia input_slice evaluate an extra argument"
  - "why does Julia converting a large slice count throw InexactError"
  - "why does Perl input_slice with a large floating width return ab"
  - "which task owns Julia input slice arity"
date: 2026-09-11
status: confirmed-open arity and numeric conversion; integer clipping confirmed
tags: [julia, perl, input-slice, arity, numeric, startup]
evidence: "JULIA-STARTUP-READING.1.18; activation d1af4b90f1f52b0b821d6078f55b9076840061b9; 174 Julia assertions across fourteen native/reconstructed controls and44 Perl assertions across eight Get comparisons plus host-cause controls. Julia .2.11 owns arity, .2.9 numeric conversion, and startup .60.2 count coercion review."
reverify: "Run the managed Julia and Perl assertion fences below; expected results describe current defects, not desired behavior."
---

# Three separate input-slicing boundaries

All sources use Top:: -> Done with return(expression), Done: /x/, input xabc.
Native and SpecFile-JSON Julia agree, with empty helper-resolution diagnostics.
Successful Julia results match and retain cursor1; diagnostic events are empty.

| Expression | Julia | Fresh Perl Get |
| --- | --- | --- |
| input_slice(1,2) | ab | ab |
| input_slice(0,maxInt) | xabc | not rerun; dated Dart comparison agrees |
| input_slice(1,maxInt) | abc | abc |
| input_slice(4,maxInt) | empty | not rerun; dated Dart comparison agrees |
| input_slice(4,0) | empty | not rerun |
| input_slice(1,3) | abc | not rerun |
| input_slice(1,0) | empty | not rerun |
| input_slice(0,4) | xabc | not rerun |
| input_text() | xabc | xabc |
| input_slice() | xabc | null and late handler error |
| input_slice(1) | abc | null and late handler error |
| input_slice(1,2,print("extra")) | ab; print ignored | null and late handler error |
| input_slice(1,100000000000000000000.0) | InexactError wrapper | ab |
| drop_front([1,2],100000000000000000000.0) | InexactError wrapper | [1,2] |

Here maxInt is the authored integer 9223372036854775807. The successful typed
integer controls distinguish Julia from [[dart-input-slice-boundary-gaps]] and
from Julia's ordinary array/string range failures in
[[julia-large-number-and-slice-boundaries]]. Interpreter1420 bounds width to the
remaining source length before addition. These controls warrant no typed-slice
integer overflow repair.

Interpreter8183-8215 accepts zero arguments as whole text, one as a suffix, and
ignores operands beyond the second. ActionContracts995-1009 records helper arity
without enforcing this signature. The public catalog requires two arguments;
portable whole-input authoring uses input_text(). Julia .2.11.1/.2 own early
arity validation and carrier proof, coordinated with Dart .2.15 and backlog .5.
Perl MethodLowering5158-5170 requires two normalized operands, leaving the three
malformed calls raw. Get returns null with runtime_handler/rule_handler_eval and
an undefined LinkedSpec::SpecEntry::input_slice at generated_handler:Top:_default
line57. This late reference failure is not the desired rejection behavior.

Separately, Interpreter8996-9000 converts integral floating values directly to
Int without catching range failure. Float64 1e20 therefore throws InexactError
before input_slice/drop_front can apply a fallback. Existing Julia .2.9.1/.2 own
that generic conversion boundary; copying the measured Perl values is not a fix.
Perl SourceLocation558-571 checks ASCII integer spelling and otherwise calls host
substr, as recorded in [[perl-source-location-slice-compatibility]]. Here 1e20
stringifies as 1e+20, fails that check, and host substr(xabc,1,1e20) returns ab.
Perl's generated drop_front rejects that spelling and resets the count to zero.
Startup .60.2 owns coherent count acceptance/repair across these routes. These
measurements establish the mechanism, not a new normative numeric policy.

Existing core4/capture2/scope3/cursor17/complete-marks13/diagnostic82/logical232/
typed-source127/write406 suites pass (886 plus one selected-set equality).
Neutral logical26, typed231 and write105 mutations pass. No source or test file
changes; fresh Julia generated/emitted/CLI reproduction of the new boundary cases
remains pending. Existing carrier tests do not extend that claim.

## Exact Julia replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_SLICE18_ASSERT'
using LinkedSpecJulia,JSON3,Test
rows=[("small","input_slice(1,2)","ab"),("large_zero","input_slice(0,9223372036854775807)","xabc"),("large_one","input_slice(1,9223372036854775807)","abc"),("large_end","input_slice(4,9223372036854775807)",""),("zero_end","input_slice(4,0)",""),("suffix","input_slice(1,3)","abc"),("zero_width","input_slice(1,0)",""),("whole","input_slice(0,4)","xabc"),("input_text","input_text()","xabc"),("zero_args","input_slice()","xabc"),("one_arg","input_slice(1)","abc"),("extra_arg",raw"input_slice(1,2,print(\"extra\"))","ab"),("float_width","input_slice(1,100000000000000000000.0)",nothing),("float_drop","drop_front([1,2],100000000000000000000.0)",nothing)]
@testset "Julia typed slice arity and count diagnostic" begin
 for (name,expr,expected) in rows
  @test isempty(resolve_action_block_contracts(parse_action_block("return("*expr*")")).diagnostics)
  spec=parse_spec("Top::\n -> Done { return("*expr*") }\nDone:\n /x/\n")
  for (route,carrier) in [("native",spec),("spec_json",from_json(SpecFile,JSON3.read(JSON3.write(to_json(spec)),Dict{String,Any})))]
   events=Any[];result=nothing;stage="compile"
   error=try engine=LinkedSpecRuntimeEngine(compile_spec(carrier));stage="runtime";result=runtime_parse(engine,"xabc";diagnostic_output_sink=e->push!(events,to_json(e)));nothing catch error;error end
   @test stage=="runtime"
   @test isempty(events)
   if expected!==nothing
    @test error===nothing
    @test result.value==expected
    @test result.matched
    @test result.cursor_codeunit==1
   else
    @test error isa RuntimeInterpreterException
    @test occursin("InexactError: Int64(1.0e20)",sprint(showerror,error))
   end
  end
 end
end
JULIA_SLICE18_ASSERT
```

## Exact Perl reference and host-cause replay

```bash
bash tools/project_data_run.sh perl -Iperl -Mstrict -Mwarnings -MJSON::PP -MLinkedSpec -MTest::More - <<'PERL_SLICE18_ASSERT'
my @rows=(['two','input_slice(1,2)','ab'],['large_one','input_slice(1,9223372036854775807)','abc'],['text','input_text()','xabc'],['zero','input_slice()',undef],['one','input_slice(1)',undef],['extra','input_slice(1,2,print("extra"))',undef],['float_width','input_slice(1,100000000000000000000.0)','ab'],['float_drop','drop_front([1,2],100000000000000000000.0)',[1,2]]);
my $J=JSON::PP->new->canonical(1)->allow_nonref(1);
for my $row (@rows) {
 my ($name,$expr,$expected)=@$row;my $source="Top::\n -> Done { return($expr) }\nDone:\n /x/\n";my %ctx;my ($value,$emitted,$error);my $lower=LinkedSpec::call_spec_handler_subst('Top',"return($expr)");
 eval {my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$emitted);my $input='xabc';$value=$parser->(\$input);1} or $error="$@";
 ok(!defined($error),"$name no outer exception");ok(defined($emitted),"$name source captured");ok(index($emitted,$lower)>=0,"$name lowering captured");is($J->encode($value),$J->encode($expected),"$name exact value");
 if ($name =~ /\A(?:zero|one|extra)\z/) {
  is_deeply($ctx{last_error},{type=>'runtime_handler',stage=>'rule_handler_eval',owner_stage=>'runtime_handler:rule_handler_eval',rule_label=>'Top',top_rule=>'Top',spec_name=>'',spec_path=>'',summary=>'Rule handler execution failed',handler_variant=>'_default',handler_source_label=>'LinkedSpec::generated_handler:Top:_default',detail=>"Undefined subroutine &LinkedSpec::SpecEntry::input_slice called at LinkedSpec::generated_handler:Top:_default line 57.\n"},"$name exact late failure");
 } else {ok(!defined($ctx{last_error}),"$name no context error")}
}
my $width=100000000000000000000.0;my $raw='xabc';my $text="$width";
is($text,'1e+20','host scientific width');ok($text !~ /\A[0-9]+\z/,'typed ASCII guard rejects width');is(substr($raw,1,$width),'ab','host fallback reproduces partial suffix');ok($text !~ /\A-?\d+\z/,'drop guard rejects width');
done_testing();
PERL_SLICE18_ASSERT
```
