---
id: julia-attached-switch-body-omission
title: Julia attached-switch extraction can omit authored content and replace an earlier default
answers:
  - can Julia attached switch silently discard a trailing statement
  - does Julia reject duplicate default blocks
  - why does Julia contract resolution miss a helper inside switch
  - which task owns Julia attached-switch body validation
  - why was an E-only Perl switch probe inconclusive
date: 2026-09-11
status: confirmed current limitation; repair pending
tags: [julia, switch, actionir, validation, generated-source, startup]
evidence: "JULIA-STARTUP-READING.1.4 reads ActionContracts767-1128 and ActionParser1-1138; five asserted native/reconstructed/generated-plan/in-process emitted cases and ten causal resolver cases isolate projected-body omission. Five same-source Perl reference cases qualify the normative boundary; no source fix or full gate."
reverify: "Run the JULIA_SWITCH_REPLAY recipe below from the repository root; all probe files and logs remain project-local."
---

# Mechanism and current outcomes

`julia/src/action/ActionParser.jl:906` extracts recognized case/default branches from an attached switch,
ignores other body expressions and overwrites an earlier default. The AST also retains the complete body.
`julia/src/action/ActionContracts.jl:871` visits the extracted branches when any exist, otherwise the retained body.
`julia/src/runtime/Interpreter.jl:3110` selects only the extracted first matching case or final default.
The runtime windows are diagnostic reads, not advance reading credit.

All examples wrap the listed body in `switch(1) { BODY }`, initialize `result = 0`, then `return(result)`
inside the same `Top:: /x/ -> Done { ... }` edge handler, with `Done:: /x/` and input `x`.

| Body | Retained statements | Resolver diagnostics | Julia value on all four routes | Perl reference |
| --- | ---: | --- | --- | --- |
| `case(1) { result = 7 }` | 1 | none | 7 | 7 |
| `mystery_probe(1)` | 1 | unknown_helper | 0 | 0 |
| `case(1) { result = 7 }; mystery_probe(1)` | 2 | none | 7 | 7 |
| `default() { mystery_probe(1) }; default() { result = 9 }` | 2 | none | 9 | handler compile error |
| `default() { result = 9 }; default() { mystery_probe(1) }` | 2 | unknown_helper | unsupported runtime helper | handler evaluation error |

Julia compiles all five, including rows with a resolver diagnostic. These measurements do not establish that
every unknown helper must fail compilation. The lost diagnostic and replaced default are separate from that question.
The four routes are native, normalized SpecFile JSON reconstruction, generated plan and freshly included emitted
source. Emitted modules load in the same Julia process; no independent child-process emission proof is claimed.
Perl factory creation returns a coderef for all five. That does not prove its lazy handler compiles:
row four records `runtime_handler:rule_handler_compile` with "Can't modify constant item in scalar assignment";
row five records `runtime_handler:rule_handler_eval` with an undefined `mystery_probe` call.

A process-local replacement of exactly the resolver's projection-selection condition with `if false` makes it
visit the retained full body. Ten before/after assertions change diagnostic rows from 2/5 to 2/3/4/5 while the
valid first case stays clear. This isolates the lost semantic traversal; it is a diagnostic intervention,
not a production repair, and does not change runtime selection or any repository source.

# Repair boundary and reference qualification

Pending `JULIA-STARTUP-READING.2.2.1` must establish the precise control contract for leading/interleaved/trailing
non-branches, duplicate defaults and malformed/nested bodies, then ensure complete semantic accounting or an
explicit diagnostic with source spans. Perl also skips the tested non-branch forms, so this intake does not
invent a blanket rejection rule. Duplicate-default behavior differs between Julia and Perl as shown above.
`.2.2.2` owns caller-constructed/reconstructed/generated/emitted proof and public reconciliation after repair.
Both remain behind startup `.3/.4/.5` and complete relevant source reading. Existing valid attached, marker and
lazy value switches must remain supported. Dart's separate finding is [[dart-attached-switch-body-omission]].

An earlier E-only carrier `Top:: E { ... }` returned null on Perl even for the positive switch, on both empty
and nonempty input. Toolbox descriptor/source inspection shows zero action/blind edges and
`selected_handler_variant = <none>`; the generated handler contains the variable declaration but no E body.
`perl/LinkedSpec/SpecEntry.pm:528` omits E from the condition for building variants; the default builder at
`perl/LinkedSpec/HandlerVariantEmitter.pm:100` also requires action code. This is the existing
[[perl-lifecycle-final-value-e-drift]] / `SESSION-STARTUP-READING.27` mechanism. The E-only experiment is excluded
from switch parity conclusions; the shared outgoing-edge positive control above returns 7 on both backends.

# Focused compatibility proof

The existing callable suite passes 125 dynamic, 118 contextual and 239 construction assertions.
The unmodified Action AST parser and Action contract resolver testsets from `julia/test/runtests.jl` pass
74 and 40 assertions after extraction with their six helper definitions. Total: 596 existing assertions.
This is focused reading proof, not a complete Julia component gate, canonical CI, or a dependency build.

# Replay

The following three probes plus the Python oracle are self-contained. Replay creates only managed scratch:

## switch_event_probe.jl

```julia
using LinkedSpecJulia, JSON3
bodies=[
    "case(1) { result = 7 }",
    "mystery_probe(1)",
    "case(1) { result = 7 }; mystery_probe(1)",
    "default() { mystery_probe(1) }; default() { result = 9 }",
    "default() { result = 9 }; default() { mystery_probe(1) }",
]
for body in bodies
    action="switch(1) { "*body*" }"
    ast=parse_action_expression(action)
    resolution=resolve_action_expression_contracts(ast)
    row=Dict{String,Any}("action"=>action,
        "body_statements"=>length(ast.body.statements),
        "case_count"=>length(ast.cases),
        "default_source"=>ast.default_case===nothing ? nothing : ast.default_case.source,
        "diagnostics"=>[d.code for d in resolution.diagnostics])
    source="Top::\n /x/ -> Done { result = 0\n"*action*"\nreturn(result) }\n\nDone::\n /x/\n"
    try
        spec=parse_spec_with_staged_user_function_definitions(source)
        validate_spec(spec)
        compiled=compile_spec(spec)
        row["compiled"]=true
        restored=compile_spec(from_json(SpecFile,JSON3.read(JSON3.write(to_json(spec)))))
        plan=build_generated_rule_plan(compiled)
        emitted=emit_julia_source_v2(compiled,"switch-probe.spec")
        host=Module(gensym(:SwitchProbeHost))
        Base.include_string(host,emitted,"switch-probe-generated.jl")
        generated=Base.invokelatest(getfield,host,:LinkedSpecGeneratedParser)
        for (route,call) in [
            ("native",()->runtime_execute(LinkedSpecRuntimeEngine(compiled),"x").value),
            ("reconstructed",()->runtime_execute(LinkedSpecRuntimeEngine(restored),"x").value),
            ("generated_plan",()->execute_generated_parser_v2(compiled,plan,"x","switch-probe.spec")),
            ("emitted",()->Base.invokelatest(Base.invokelatest(getfield,generated,:execute),"x")),
        ]
            try row[route]=call() catch error row[route*"_error"]=sprint(showerror,error) end
        end
    catch error
        row["compile_error"]=sprint(showerror,error)
    end
    println(JSON3.write(row))
end
```

## switch_causal.jl

```julia
using LinkedSpecJulia, JSON3
const BODIES=[
 "case(1) { result = 7 }",
 "mystery_probe(1)",
 "case(1) { result = 7 }; mystery_probe(1)",
 "default() { mystery_probe(1) }; default() { result = 9 }",
 "default() { result = 9 }; default() { mystery_probe(1) }",
]
function diagnose(round)
 for (index,body) in enumerate(BODIES)
  ast=parse_action_expression("switch(1) { "*body*" }")
  result=resolve_action_expression_contracts(ast)
  codes=[d.code for d in result.diagnostics]
  wanted=(round=="original" ? index in (2,5) : index!=1) ? ["unknown_helper"] : String[]
  @assert codes==wanted (round,index,codes)
  println(JSON3.write(Dict("round"=>round,"case"=>index,"diagnostics"=>codes,
   "body_statements"=>length(ast.body.statements),"cases"=>length(ast.cases))))
 end
end
diagnose("original")
# Causal diagnostic only: resolve the complete retained body instead of its
# extracted branches. Runtime behavior and repository files remain untouched.
source=read("julia/src/action/ActionContracts.jl",String)
a=findfirst("function _visit_expr!",source)
b=findfirst("\nfunction _resolve_helper_call!",source)
method=source[first(a):prevind(source,first(b))]
needle="if !isempty(expr.cases) || expr.default_case !== nothing"
@assert length(findall(needle,method))==1
Base.include_string(LinkedSpecJulia,replace(method,needle=>"if false"),"diagnostic-switch-body-visitor.jl")
Base.invokelatest(diagnose,"full_body_diagnostic")
```

## perl_switch_event.pl

```perl
use strict;use warnings;use lib 'perl';use LinkedSpec;use JSON::PP ();
my $json=JSON::PP->new->canonical(1)->allow_nonref(1);
for my $body(
 'case(1) { result = 7 }',
 'mystery_probe(1)',
 'case(1) { result = 7 }; mystery_probe(1)',
 'default() { mystery_probe(1) }; default() { result = 9 }',
 'default() { result = 9 }; default() { mystery_probe(1) }',
) {
 my $action="switch(1) { $body }";
 my $source="Top::\n /x/ -> Done { result = 0\n$action\nreturn(result) }\n\nDone::\n /x/\n";
 my %ctx;my %row=(action=>$action);my $parser;
 eval {$parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);1} or $row{compile_error}="$@";
 $row{compiled}=ref($parser) eq 'CODE'?JSON::PP::true:JSON::PP::false;
 if(ref($parser) eq 'CODE') {my $input='x';eval {$row{value}=$parser->(\$input);1} or $row{runtime_error}="$@"}
 $row{last_error}=$ctx{last_error} if $ctx{last_error};
 print $json->encode(\%row),"\n";
}
```

## assert_switch.py

```python
from pathlib import Path
import json
root=Path('.linkedspec-data/scratch/julia14')
def rows(name):
    return [json.loads(s) for s in (root/name).read_text().splitlines() if s.startswith('{')]
julia=rows('switch-event.log')
assert len(julia)==5
for index,row in enumerate(julia):
    assert row['compiled'] is True and 'compile_error' not in row
    assert row['body_statements']==[1,1,2,2,2][index]
    assert row['case_count']==[1,0,1,0,0][index]
    assert row['diagnostics']==(['unknown_helper'] if index in (1,4) else [])
    for route in ('native','reconstructed','generated_plan','emitted'):
        if index<4:
            assert row[route]==[7,0,7,9][index] and route+'_error' not in row
        else:
            prefix='Generated Julia parser execution failed: ' if route in ('generated_plan','emitted') else ''
            assert row[route+'_error']==prefix+"unsupported runtime helper 'mystery_probe' in rule Top"
            assert route not in row
assert julia[3]['default_source']=='default() { result = 9 }'
assert julia[4]['default_source']=='default() { mystery_probe(1) }'
causal=rows('switch-causal.log')
assert len(causal)==10
for i,row in enumerate(causal):
    expected_round='original' if i<5 else 'full_body_diagnostic'
    case=i%5+1
    assert (row['round'],row['case'])==(expected_round,case)
    wanted=case in (2,5) if i<5 else case!=1
    assert row['diagnostics']==(['unknown_helper'] if wanted else [])
perl=rows('perl-switch-event.log')
assert len(perl)==5
for i,row in enumerate(perl):
    assert row['action']==julia[i]['action'] and row['compiled'] is True
    assert 'compile_error' not in row and 'runtime_error' not in row
    if i<3:
        assert row['value']==[7,0,7][i] and 'last_error' not in row
    else:
        assert row['value'] is None
        e=row['last_error']
        stage='rule_handler_compile' if i==3 else 'rule_handler_eval'
        assert e['type']=='runtime_handler' and e['stage']==stage
        assert e['owner_stage']=='runtime_handler:'+stage
        assert e['handler_source_label']=='LinkedSpec::generated_handler:Top:_default'
        detail="Can't modify constant item in scalar assignment" if i==3 else 'Undefined subroutine &LinkedSpec::SpecEntry::mystery_probe called'
        assert detail in e['detail']
print('PASS five asserted Julia AST/resolver/four-carrier rows, ten causal rows and five exact Perl reference outcomes.')
```

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_SWITCH_REPLAY'
from pathlib import Path
import re,subprocess
card=Path('docs/knowledge/julia-attached-switch-body-omission.md').read_text()
root=Path('.linkedspec-data/scratch/julia14');root.mkdir(parents=True,exist_ok=True)
fence=chr(96)*3
blocks=re.findall(re.escape(fence)+r'(julia|perl|python)\n(.*?)\n'+re.escape(fence),card,re.S)
names=['switch_event_probe.jl','switch_causal.jl','perl_switch_event.pl','assert_switch.py']
assert len(blocks)==len(names)
for (_,source),name in zip(blocks,names):(root/name).write_text(source+'\n')
jobs=[
 (['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no',str(root/names[0])],'switch-event.log'),
 (['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no',str(root/names[1])],'switch-causal.log'),
 (['bash','tools/project_data_run.sh','perl',str(root/names[2])],'perl-switch-event.log'),
]
for command,log in jobs:
 with (root/log).open('w') as out:subprocess.run(command,stdout=out,stderr=subprocess.STDOUT,check=True)
exec(compile((root/names[3]).read_text(),names[3],'exec'))
JULIA_SWITCH_REPLAY
```
