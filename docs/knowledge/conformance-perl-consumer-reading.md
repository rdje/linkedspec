---
id: conformance-perl-consumer-reading
title: Perl conformance consumers distinguish fixture adaptation and in-process generated loading
answers:
  - which Perl contract consumers load generated source in the same process
  - does the diagnostic-output Perl consumer execute the neutral source unchanged
  - what does the CLI runner test prove about fixture bytes
  - what Perl conformance reading and focused proof completed in group 34
  - what generated-source inspector and gap coverage is read in group 35
  - what logical mutation and MCP Perl test coverage is read in group 36
  - why does the exported TestHelpers subprocess helper fail with include paths containing spaces
  - what MCP loader and oracle Perl tests are read in group 37
  - why does the Phase0 source header say 989 when the gate reports 1032
  - what does Phase0 reading group 38 prove about lazy loading and plugins
  - what do Phase0 owner-dispatch source-shape checks establish
  - what do Phase0 substituted wrapper and owner-map tests prove
  - what do Phase0 plugin compatibility and spec lookup tests establish
  - what do Phase0 resolution error and rule-family tests establish
  - what do Phase0 bounded AND and paragraph validation tests establish
  - what do Phase0 compiler boundary and runtime context tests establish
  - what do Phase0 context preparation and compiler error attribution tests establish
  - what do Phase0 compiler-state composition and parser-factory failure tests establish
  - what do Phase0 mode-result validation and context reuse tests establish
  - what do Phase0 public diagnostic and handler lifecycle tests establish
  - what do Phase0 compiler owner and lazy-load tests establish
  - does the Phase0 MethodExpr test detect Deps loading during parsing
  - which task fixes the MethodExpr pre-call observation gap
  - does MethodExpr currently load the retired Deps module
  - what do Phase0 owner loading and capture lowering tests establish
  - why do six Phase0 tests incorrectly claim helpers lazy-load EmitContext
  - what do Phase0 capture cursor and named mark tests establish
  - does the mark_copy missing-source test detect failure to clear an existing target
  - which task fixes the mark_copy deletion observation gap
  - what do Phase0 entry and local match projection tests establish
  - which numeric lowering fixture compares invalid generated code
  - what do Phase0 collection and branch lowering tests establish
  - why do two push assertions still describe wrapped target symbols
  - what do Phase0 structured branch and lifecycle equivalence tests establish
  - what do Phase0 mixed branch and nested switch equivalence tests establish
  - what do Phase0 nested switch and flat-list descriptor tests establish
  - what do Phase0 snapshot and bare-marker descriptor tests establish
  - what do Phase0 mixed switch and nested marker tests establish
  - what do Phase0 deeply nested inline and marker switch tests establish
  - what do Phase0 multi-case switch composition metadata tests cover
  - what do Phase0 structured switch branch output comparisons actually observe
  - what do Phase0 outer switch family comparisons establish about node and hit coverage
  - which Phase0 outer switch comparisons check only selected marker nodes
  - what do Phase0 deep mutual marker nesting helper-hit checks establish
  - what do Phase0 fluent container helper descriptor comparisons establish
  - what do Phase0 scalar and numeric descriptor comparisons establish
  - what do Phase0 payload branch and captured-call comparisons establish
  - which Phase0 fallback and normalization tests inspect actual lowering text
  - what do Phase0 membership replacement boundary and reducer lowering checks observe
  - what do Phase0 hash transformation and snapshot lowering checks observe
  - what do Phase0 array ordering and numeric reduction lowering checks observe
  - which Phase0 lifecycle tests observe generated markers and actual return values
  - what do Phase0 switch loop and migration summary tests actually observe
  - what do Phase0 source boundary projection and legacy classification checks observe
  - what do Phase0 quote boundary and shipped grammar migration checks observe
  - what do Phase0 shipped grammar runtime smokes and legacy adapter checks establish
date: 2026-09-21
status: groups 34–76 physically read; Phase0 partial through line 42887; all observation-gap and runtime repairs retain prerequisites
tags: [conformance, perl, reading, diagnostics, generated-source]
evidence: "CONFORMANCE-SOURCE-READING.1.34 at activation d10305097eb502c0fe29309ec230437396e26d82; eleven complete windows, 1500 fragments, 56255 bytes, ordered window SHA-256 db04deab6c0365f8bc454e2695d410324a120104a232c213346f2b23ad16aef3. Five managed Perl targets pass43 top-level tests; neutral named marks3, diagnostics20 and duplicate-slot59 mutations pass."
evidence_update_2026_09_21: "Ten complete windows cover 1,500 fragments / 51,804 baseline bytes; ordered window SHA-256 1164b42887bab92a4ea03d85fcaf4a9dc0c6913fc7607fe21a0d66cb0a424992. Cumulative reading is 35/143, 46,538 fragments / 1,405,327 baseline bytes and 86 complete files; gap tests remain partial through line 1026. Retained exact integration commit 87b35665e proof passes generated-source (6), inspector (2) and gap (124) tests (132 total), with unchanged source identities. The old uniform-identity audit fails on the approved integration delta; its corrected recipe passes all 160 inputs/143 groups/302 ranges and six rejected snapshot mutations. No new runtime execution, native build, full CI or push is claimed for this focused reading leaf."
evidence_update_2026_09_21_group36: "Eleven complete windows cover 1,500 fragments / 58,957 baseline bytes; ordered window SHA-256 071b58880845a0a7108956fb5110d4cc52fb015640fdb95b9e4d286d3e472f1f. Cumulative reading is 36/143: 48,038 fragments / 1,464,284 baseline bytes and 91 complete files. MCP admission remains partial through line 451. Fresh managed logical/map-leaves tests pass 16 top-level tests. Exact unchanged integration proof retains gap (124) and admission (13), plus the binding target within the earlier three-target MCP group (23 tests). Three bounded helper controls confirm the literal include-path defect and its mechanism; .2.3 owns implementation and independent verification after required prerequisites. No production repair, dependency build, new canonical CI or push is claimed."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/complete_named_mark_contract.t t/diagnostic_output_perl_contract.t t/duplicate_regex_slot_identity_perl_contract.t t/generated_source_contract.t; bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py; bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py; bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
evidence_update_2026_09_21_group37: "Fourteen complete windows cover 1,500 fragments / 63,613 baseline bytes; ordered window SHA-256 98d4de26a6f747975c45fe91277d218c6947936925d1ae233586706bef952d64. Cumulative reading is 37/143: 49,538 fragments / 1,527,897 baseline bytes and 97 complete files. Phase0 remains partial at lines 1–43. Fresh managed metadata/oracle checks pass 9 top-level tests. Unchanged integration commit 87b35665e retains native-loader (5), MCP binding/dispatch/stdio (23), admission (13) and Phase0 1032 proof. Full-target execution grants no reading credit to the unread Phase0 body. Header correction .2.4 is pending after prerequisites; helper repair .2.3 and existing runtime repairs remain open. No dependency build, new canonical run or push is claimed."
evidence_update_2026_09_21_group38: "Eleven complete windows cover 1,067 fragments / 65,529 baseline bytes; ordered window SHA-256 f57116fee0db80f49969546da5cd033988e06b55191fc88358b7c6d6d334fd3e. Cumulative reading is 38/143: 50,605 fragments / 1,593,426 baseline bytes and 97 complete files. Phase0 is partial through line 1110. Exact unchanged canonical commit 87b35665e supplies PASS for all 38 fully read subtests (ordinals 2–39). The crossing facade error-state test remains partial; its suffix is .1.39-owned. The complete 1032-test gate remains retained historical proof, not new execution or reading credit. No new defect, runtime repair, dependency build, full CI or push is claimed; all existing repairs retain their prerequisites."
evidence_phase0_checkpoint: "11 complete windows cover 800 fragments / 65,456 baseline bytes; ordered window SHA-256 4cf7775ac2ba5691da7e40961a1fffa66cb8f9db6837120d880949270205683c. Cumulative reading is 76/143 groups, 92,382 fragments / 4,019,804 baseline bytes and 97 complete files. Phase0 is partial through line 42887. Unchanged canonical commit ec10be6b retains PASS for 33 completed subtests, ordinals 893–925 with 650 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. VHDL source migrations and shipped-spec readiness remain bounded metadata/source checks. Runtime smokes cover ifelse undef/quiet stdout, three hlink ASTs, lib_reader grouped attributes, EBNF logging annotations and seven portmap classifications. Pplugin preserves body text before its legacy Perl adapter creates and executes coderefs. Tkgui is partial after its three-rule metadata loop; .1.77 owns node/summary assertions. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain."
reverify_phase0_checkpoint: "Replay .1.76 using conformance-source-reading-coverage; verify 33 completed subtests, ordinals 893–925 with 650 direct assertions and no nested plans against unchanged ec10be6b sources. Distinguish descriptor/source observations, exact parser results, quiet-output limits and legacy Perl callback execution."
reverify_group38: "Replay .1.38 using conformance-source-reading-coverage and compare its 38 complete subtest names with retained canonical commit 87b35665e; this grants no new source-reading or runtime credit."
reverify_group37: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/noncurrent_helper_metadata.t t/oracle_root_target_regex_semantics.t; retain unchanged dated MCP/native-loader proof separately."
reverify_group36: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/logical_helper_perl_contract.t t/map_leaves_mutation_perl_contract.t; reproduce the helper observation with HELPER_PATH below, and retain the dated gap/MCP proof separately."
evidence_methodexpr_observation_gap: "CONFORMANCE-SOURCE-READING.1.49 at 7a166581c: exact TOOLBOX6.2 extraction passes seven assertions both unchanged and with a project-local inert Deps fixture required after the parse. Independent cold before/after probes give 0/0 normally and 0/1 with the fixture. No production source or test changes; this is fresh focused diagnostic evidence, separate from retained canonical proof."
reverify_methodexpr_observation_gap: "Run the repository-managed observation-gap recipe below; it extracts the current test and helper and verifies original and injected-load results separately. After repair, the injected-load case must fail the post-call assertion and this record becomes historical."
---

## Group 34 checkpoint — September 13

The exact task scope finishes callable literals and reads the complete CLI runner,
named-mark, diagnostic-output and duplicate-slot Perl consumers. Generated-source
contract reading covers only lines 1-153; group35 owns the opened family fixture.
Whole-target execution does not grant source-reading credit for its unread suffix.

Callable suffix tests inspect final-codeblock function version3 metadata, preserve
parameter kinds in all three carriers, and compare normalized attached versus
parenthesized AST payloads. Helper, receiver, explicit-literal and user-function
forms execute. Invalid declaration diagnostics distinguish a malformed header
from a colon appearing only in its body. An harray in the final codeblock slot
fails with its actual kind preserved; it is not promoted into a callback.
The unchanged complete callable target10 and neutral23-mutation proof are retained
from group33. Existing startup19 receiver and startup35 boolean defects remain.

The CLI runner test concurrently drains child stdout/stderr as raw bytes and
checks a real help fixture, schema-before-launch, workspace/template substitution,
expected artifact bytes, non-text hexadecimal materialization, six invalid hex
source shapes, and the exact first differing byte in a channel mismatch. All
temporary data for the fresh run inherits the managed repository-local root.
This target is not a new full66-case CLI matrix; group32 retains that separate proof.

The named-mark test checks seven symbolic bare-name lowerings and the exact
Unicode Top/Child fixture. Different labels do not establish same-label recursive
isolation. The diagnostic-output consumer explicitly rewrites each neutral E block
to an action edge, adds a Done rule and appends x to the input. Its result/event
comparisons therefore validate this adapted Perl fixture, not byte-identical
neutral-source execution. It checks ordered eager effects, quiet default output,
caller exception identity, typed exit, arity before effects, generated sink
propagation and primary-command normalization of exit status23 to failure1.

Duplicate-slot coverage has twelve roles over five neutral fixtures. Ordered
matching reaches each required structural slot; choice retains first-authored
priority; repetition resets its sequence. Loaded and descriptor routes preserve
target/index identity, and generated plans stay exact label/family rows. Trace
and invalid/lost identity diagnostics are checked with capture snapshots.

These consumers load emitted Perl through eval into distinct packages in the
same test process. That is generated execution with package isolation; none of
those loaders alone demonstrates a fresh process or an independently deployed
artifact. The generated-source prefix also checks five seek/five consume family
policies and removed cursor-option precedence over invalid source parsing.

## Group 35 checkpoint — September 21

The generated-source suffix checks exact ten-family plan classification. It separately
executes the neutral default result, seek/consume policies and two indexed alternatives,
including a slash-bearing regex; plan classification alone is not every-family execution.
Deterministic emission matches the legacy capture seam. Metadata, root-entry order, trace
roles, v1 rejection and four plan-shape errors preserve typed stages and source identity.
The emitted source loads into another package in the same process, not a fresh host.

The inspector test calls the real script for five raw/lifecycle/edge forms and statically
locks its explicit BootstrapSpec/EmitContext owners. The observed output contains generated
Perl and canonical nodes with zero fallback/unresolved counts; it does not execute each
printed fragment. Its current repair owner is [[codegen-inspector-thin-facade-break]].

Gap reading includes exact authored slot metadata, named/numeric provenance, Unicode
identity, duplicate-text reorder and ten static diagnostic fixtures. Live cases cover
empty/Unicode gaps, child-extended commits, nested distinct owners, rollback, terminal tails,
unavailable contexts, post-commit IT and cursor regression, plus unchanged legacy output.
Generated cases compare canonical JSON values and cursor positions with live execution.
Returned-span mutation is checked against a subsequent invocation. Distinct nested rule
labels do not independently prove same-rule recursive isolation. Reading stops inside the
generated nested/rollback parity call at 1026; group 36 owns the remaining source.

Current gap admission is [[inter-match-gap-recurring-governance]], not the older authored
staging milestone. The unchanged integration CI at 87b35665e passes generated (6), inspector (2)
and gap (124) top-level tests. Whole-target proof gives no extra reading credit for the suffix.

## Group 36 checkpoint — September 21

The gap suffix checks matching typed diagnostics across live Execute and generated
Execute/ExecuteWithTrace, then direct-entry and legacy compatibility. Logical tests
adapt neutral E fixtures to a Done edge. Real booleans, typed truthiness, eager effects
and arity rejection before operands are checked separately from lazy control. The
emitted roles load into the same process; the primary command runs a new process.
[[perl-logical-truthiness-host-scalars]] retains the host-scalar explanation.

Mutation tests compare only the requested AST projection, then exercise the runtime's
first eight neutral success cases, guarded writes, rollback, unrelated effects, detached
callback/results, shadow identities and post-commit continuations. The final generated
Perl check inspects runtime-call text and syntax residue; it does not execute that emitted
artifact. [[map-leaves-mutation-neutral-contract]] owns the wider admitted contract;
known callback-substitution and Rust write exceptions remain separately owned.

The MCP binding verifies embedded digests, all 35 canonical frames, schema classification,
cloned values and static source exclusions. Admission reads all native capabilities plus
nineteen query responses across six snapshots, exact raw-input outcomes and lifecycle
controls. A runtime snapshot executes the fixture and attaches three observations. The
range ends after closing the I/O output handle at line 451; later assertions/roles are unread.
[[perl-mcp-decoded-server]] retains implementation authority and
[[perl-mcp-validation-error-order-drift]] owns the known mixed-failure discrepancy.
Existing individual-error fixtures do not establish combined-error precedence.

### Exported test-helper include paths — confirmed, repair pending

`t/lib/TestHelpers.pm` joins @INC into text at line 105 and splits it on whitespace at line 117.
Three managed local controls use the same module contents and isolate argument boundaries:

| Route | Exit | Output |
| --- | ---: | --- |
| Exported helper, plain include directory | 0 | `ok` |
| Exported helper, directory ending in `with space` | 2 | empty; Perl attempts script `space` |
| Direct child, same space path as one literal -I argument | 0 | `ok` |

`CONFORMANCE-SOURCE-READING.2.3` owns the repair, meaningful regression proof and
independent closeout after startup prerequisites. Phase0 defines a separate local helper;
this result does not establish a Phase0 failure or whole-checkout relocation failure.
No dependency source or parser runtime is involved. Reproduce the argument-boundary
failure without a module fixture (the include directory need not exist):

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -I. - <<'HELPER_PATH'
use strict; use warnings; use Cwd qw(abs_path);
use t::lib::TestHelpers qw(run_perl_snippet_in_subprocess);
my $root = abs_path('.');
for my $tail ('plain', 'with space') {
 local @INC = ($root . '/.linkedspec-data/scratch/' . $tail, @INC);
 my ($status, $out, $err) = run_perl_snippet_in_subprocess('print q{ok}');
 if ($tail eq 'plain') { die 'plain control' unless $status == 0 && $out eq 'ok' && $err eq ''; }
 else { die 'space observation changed' unless $status == 2 && $out eq '' && $err =~ /Can't open perl script "space"/; }
 print "$tail: status=$status, stdout=$out\n";
}
HELPER_PATH
```

## Group 37 checkpoint — September 21

MCP admission completes the twelve exact ordered roles. Decoded dispatch tests
check native call counts and distinguish absent/partial policy components from
explicitly lowered ceilings. They compare the externally returned handle-error
values; they do not measure timing equivalence. Production construction rejects
test injection while the private test constructor supplies deterministic entropy/time.

Stdio tests use caller-owned in-memory handles and tied I/O failure fixtures. They
exercise decoded duplicate keys, strict UTF-8, lexical numeric IDs, safe integer
endpoints, 128-byte string IDs, depth 64/65, exact line ceiling with CRLF, canonical LF
output, an unterminated complete EOF frame and dispatch after rejected/overlong input.
Cancellation is checked across preparation/emission and after synchronous completion;
weak references establish release on EOF and I/O failure. These cases do not measure
peak memory or prove fresh-process deployment. The mixed-error ordering repair in
[[perl-mcp-validation-error-order-drift]] remains open.

Native resolution directly consumes 14 name, 9 resolution and 4 text cases. Its fixture
writer represents both directory and non_regular entries as directories; it does not
independently test every special-file kind. The complete pipeline retains exact text,
winning path, requested identity and parser result, then checks structured parse,
validation and missing-path errors. [[perl-native-spec-resolution]] owns the API.

Retired-helper tests inspect contract ids, rewrite events and unresolved-helper metadata;
they do not invoke the two deliberately unknown helpers. The oracle source-shape test
counts 68 inline zero-regex wrappers, one source-backed marker and at least 69 corpus
wrappers across 105 fixtures. It scans source text and does not run those fixtures.

The Phase0 prefix is read through line 43. Its header says 989 subtests, while the unchanged
canonical 87b35665e log has 1,031 top-level subtest headers and 1,032 passing top-level
assertions, with exact plan 1..1032. Repair .2.4 owns replacing that
stale comment after complete reading; no executable assertion changes in this slice.
Fresh metadata/oracle proof passes 9 tests. Retained native-loader (5), MCP group (23) and
admission (13) remain separate from the historical complete Phase0 proof. No test run
grants reading credit to the unread Phase0 body.

## MethodExpr post-parse Deps observation gap

The `emit_context_require_avoids_method_expr_load_until_parse_helper` subtest in
`t/phase0_regression.t` prints `__DEPS_STILL_UNLOADED__` before calling
`_parse_method_function_expr`. Its fourth assertion describes that old marker as
proof that parsing keeps Deps unloaded. The parser result and MethodExpr's own
post-call load marker are independently checked; Deps has no post-call observation.

An isolated mutation explicitly loads an inert project-local `LinkedSpec::Deps`
fixture after the parse and confirms its `%INC` entry. All seven original assertions
still pass. A separate before/after observation sees 0/1, so the mutation changes
precisely the state the assertion purports to check. The ordinary process reports
0/0 and the production Deps module is absent. An initial direct require without the
fixture failed because that retired module does not exist; this is not a runtime defect.

`CONFORMANCE-SOURCE-READING.2.5` owns adding an explicit post-call observation and a
forced-load rejection control after the required source/book/policy reading. Keep
initial-state, result-shape and MethodExpr load checks independent. Do not replace
current behavior or treat this fixture as a production dependency.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'METHOD_EXPR_OBSERVATION'
from pathlib import Path
import subprocess
w=Path('.linkedspec-data/scratch/methodexpr-observation-gap')
w.mkdir(parents=True,exist_ok=True)
s=Path('t/phase0_regression.t').read_text()
name='emit_context_require_avoids_method_expr_load_until_parse_helper'
a=s.index("subtest '"+name+"'");b=s.index("\nsubtest '",a+1);block=s[a:b]
a=s.index('sub run_perl_snippet_in_subprocess {')
b=s.index('\nsub run_perl_test_file_in_subprocess',a);helper=s[a:b]
pre='use strict;use warnings;use Test::More;use IPC::Open3;use Symbol qw(gensym);use Cwd qw(getcwd);our $Bin=getcwd()."/t";\n'+helper+'\n'
lib=w/'lib';stub=lib/'LinkedSpec';stub.mkdir(parents=True,exist_ok=True)
(stub/'Deps.pm').write_text('package LinkedSpec::Deps;\n1;\n')
needle='      . \'my $expr = LinkedSpec::RuleIR::EmitContext::_parse_method_function_expr("return(1)");\''
assert block.count(needle)==1
injected='use lib q{'+str(lib)+'};require LinkedSpec::Deps;die "fixture missing" unless exists $INC{"LinkedSpec/Deps.pm"};'
mutated=block.replace(needle,needle+"\n      . '"+injected+"'")
for tag,body in [('original',block),('injected_load',mutated)]:
 path=w/(tag+'.t');path.write_text(pre+body+'\ndone_testing();\n')
 result=subprocess.run(['perl','-Iperl',str(path)],capture_output=True,text=True)
 (w/(tag+'.log')).write_text(result.stdout+result.stderr)
 assert result.returncode==0,(tag,result.stdout,result.stderr)
 assert 'ok 4 - method-expression parse keeps Deps unloaded' in result.stdout
 assert 'not ok' not in result.stdout
 print(tag+': all seven original assertions pass')
prefix='require LinkedSpec::RuleIR::EmitContext;print exists($INC{"LinkedSpec/Deps.pm"})?"1":"0";my $e=LinkedSpec::RuleIR::EmitContext::_parse_method_function_expr("return(1)");'
for tag,extra,expected in [('original','','00'),('injected_load',injected,'01')]:
 code=prefix+extra+'print exists($INC{"LinkedSpec/Deps.pm"})?"1":"0";'
 result=subprocess.run(['perl','-Iperl','-e',code],capture_output=True,text=True)
 assert result.returncode==0 and not result.stderr and result.stdout==expected,(tag,result)
 print(tag+': before/after='+result.stdout)
METHOD_EXPR_OBSERVATION
```

## EmitContext load description mismatch

Six Phase0 lazy-loading tests cover FlowExpr, ArrayPipeline, ValueExpr, ControlFlow,
MethodLowering and DeclareMethod. Each explicitly requires EmitContext before invoking
its helper. The later EmitContext presence assertion says the helper lazy-loads it;
that description overstates the observation. The owner's own pre/post checks are sound.
Fresh TOOLBOX6.2 extraction at d70f77f4d passes all six tests / 42 assertions. Exact
child snippets show EmitContext 0/1/1 before require / after require / after helper;
the actual ActionIR owner changes from 0 to 1. This is an assertion-description defect,
not a runtime load failure. `CONFORMANCE-SOURCE-READING.2.6` owns correcting those six
descriptions while retaining owner and payload checks after required reading. The
separate MethodExpr missing post-call observation remains open under `.2.5` above.

Reproduce from the current test and local subprocess helper without editing either:

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'EMITCONTEXT_LOAD_LABELS'
from pathlib import Path
import re,subprocess
w=Path('.linkedspec-data/scratch/emitcontext-load-labels');w.mkdir(parents=True,exist_ok=True)
s=Path('t/phase0_regression.t').read_text()
scope=''.join(s.splitlines(True)[12850-1:13631])
blocks=re.findall(r"^subtest '([^']+)' => sub \{\n(.*?)^\};",scope,re.M|re.S)
a=s.index('sub run_perl_snippet_in_subprocess {');b=s.index('\nsub run_perl_test_file_in_subprocess',a)
pre='use strict;use warnings;use Test::More;use IPC::Open3;use Symbol qw(gensym);use Cwd qw(getcwd);our $Bin=getcwd()."/t";\n'+s[a:b]+'\n'
selected=[(n,b) for n,b in blocks if re.search(r"lazy-loads? EmitContext on demand",b)]
assert len(selected)==6
for name,body in selected:
 path=w/(name+'.t');path.write_text(pre+"subtest '"+name+"' => sub {\n"+body+'};\ndone_testing();\n')
 result=subprocess.run(['perl','-Iperl',str(path)],capture_output=True,text=True)
 assert result.returncode==0 and 'not ok' not in result.stdout,(name,result)
 assert len(re.findall(r'^    ok \d+(?: |$)',result.stdout,re.M))==7
 (w/(name+'.log')).write_text(result.stdout+result.stderr)
 code=re.search(r"<<'PERL'\);\n(.*?)^PERL$",body,re.M|re.S).group(1)
 observe='print exists($INC{"LinkedSpec/RuleIR/EmitContext.pm"})?"__EC_1__\n":"__EC_0__\n";'
 assert code.startswith('require LinkedSpec::RuleIR::EmitContext;\n')
 probe=observe+code.replace('require LinkedSpec::RuleIR::EmitContext;','require LinkedSpec::RuleIR::EmitContext;'+observe,1)+observe
 result=subprocess.run(['perl','-Iperl','-e',probe],capture_output=True,text=True)
 assert result.returncode==0 and not result.stderr,(name,result)
 assert re.findall(r'__EC_([01])__',result.stdout)==['0','1','1'],(name,result.stdout)
 assert re.search(r'__(?:FLOW_EXPR|ARRAY_PIPELINE|VALUE_EXPR|CONTROL_FLOW|METHOD_LOWERING|DECLARE_METHOD)_STILL_LAZY__',result.stdout)
 assert re.search(r'__(?:FLOW_EXPR|ARRAY_PIPELINE|VALUE_EXPR|CONTROL_FLOW|METHOD_LOWERING|DECLARE_METHOD)_AFTER_HELPER__',result.stdout)
 (w/(name+'.probe.log')).write_text(result.stdout)
 print(name+': seven assertions pass; EmitContext before-require/after-require/after-helper=0/1/1; target owner=0/1')
EMITCONTEXT_LOAD_LABELS
```

## Mark-copy missing-source clearing observation gap

The four-assertion `named_mark_mark_copy_advances_or_clears_explicit_boundary` test
never initializes `after_end`. Its missing-source copy returns undef and reads an
absent target, so it cannot distinguish deletion from doing nothing. Toolbox
`call_spec_handler_subst` locates `SourceLocation::Runtime::mark_delete` in that
lowering branch. Runtime lives in `LinkedSpec::SourceLocation`, not a separate
Runtime.pm file. The first probe's incorrect module require was a setup failure;
the corrected four fresh-process controls below establish the finding.

At ec10be6b, original and deletion-no-op original both pass 4/4; the latter intercepts
exactly one deletion. Seeding `after_end` at offset 0 and observing it before copying
keeps pristine 4/4 PASS but makes the same no-op fail precisely assertion 2: the last
array element retains 0 instead of undef. Production clears the seeded target.
This is a regression-test gap, not a demonstrated current production bug.
`CONFORMANCE-SOURCE-READING.2.7` owns tracked fixture repair and meaningful isolated
rejection proof after required source/book/policy reading. Scratch controls do not
close that repair. Positive copying and missing-source return checks remain intact.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'MARK_COPY_OBSERVATION'
from pathlib import Path
import json,subprocess
root=Path('.linkedspec-data/scratch/mark-copy-observation');root.mkdir(parents=True,exist_ok=True)
s=Path('t/phase0_regression.t').read_text()
name='named_mark_mark_copy_advances_or_clears_explicit_boundary'
a=s.index("subtest '"+name+"'");b=s.index("\nsubtest '",a+1);block=s[a:b]
seeded=block
for old,new in [
 ('mark_match_start(final_end); return(array(', 'mark_match_start(final_end); mark_input_start(after_end); return(array('),
 ('capture_between(body_start, final_end), mark_copy(after_end, missing_end)', 'capture_between(body_start, final_end), mark_pos(after_end), mark_copy(after_end, missing_end)'),
 ("['?Top:', 5, 'beta', undef, undef]", "['?Top:', 5, 'beta', 0, undef, undef]")]:
 assert seeded.count(old)==1,old
 seeded=seeded.replace(old,new)
pre='use strict;use warnings;use Test::More;use LinkedSpec;require LinkedSpec::SourceLocation;\nour $skipped_clear=0;\n'
mutation='''my $original_delete=\\&LinkedSpec::SourceLocation::Runtime::mark_delete;
{ no warnings 'redefine';
  *LinkedSpec::SourceLocation::Runtime::mark_delete=sub {
    if ($_[1] eq 'Top' && $_[2] eq 'after_end') { ++$skipped_clear; return undef; }
    return $original_delete->(@_);
  };
}
'''
reports=[]
for tag,body,mutant in [('original',block,False),('original_no_clear',block,True),('seeded',seeded,False),('seeded_no_clear',seeded,True)]:
 p=root/(tag+'.t');p.write_text(pre+(mutation if mutant else '')+body+'\ndone_testing();\nprint STDERR "__SKIPPED_CLEAR__:$skipped_clear\\n";\n')
 r=subprocess.run(['perl','-Iperl',str(p)],capture_output=True,text=True)
 (root/(tag+'.log')).write_text(r.stdout+r.stderr)
 expected=1 if tag=='seeded_no_clear' else 0
 assert r.returncode==expected,(tag,r.returncode,r.stdout,r.stderr)
 assert ('not ok 2 - mark_copy(target_mark,source_mark)' in r.stdout)==bool(expected),(tag,r.stdout)
 assert '__SKIPPED_CLEAR__:'+('1' if mutant else '0') in r.stderr,(tag,r.stderr)
 assert '1..4' in r.stdout,(tag,r.stdout)
 if not expected:assert 'not ok' not in r.stdout,(tag,r.stdout)
 reports.append(dict(case=tag,exit_code=r.returncode,skipped_clear=1 if mutant else 0,expected_rejection=bool(expected)))
 print(json.dumps(reports[-1]))
(root/'mark-copy-results.json').write_text(json.dumps(reports,indent=2)+'\n')
print('PASS: original fixture misses deletion no-op; seeded-zero control rejects it; pristine production clears the seeded target.')
MARK_COPY_OBSERVATION
```

## Push descriptions still claim wrapped targets

Two assertions in `emit_context_lowers_push_method_contract` describe wrapped
target symbols, but their inputs are `push(items, array(tag, name))` and
`push(items, retv)`. Fresh Toolbox lowering confirms bare scalar-held items; the
array constructor supplies the value. Two bare tokens retain static-rule-handler
precedence, with binding append as the fallback. [[perl-uniform-binding-runtime]]
owns that distinction. The unchanged canonical subtest passes all 19 assertions.
`CONFORMANCE-SOURCE-READING.2.9` owns correcting these two descriptions after
prerequisites while preserving actual assertions and retired-selector rejection.
This is test wording drift, not a runtime defect or authorization to restore wrappers.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'PUSH_LABELS'
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
open my $fh, '<', 't/phase0_regression.t' or die $!;
local $/;
my $source = <$fh>;
my ($block) = $source =~ /(subtest 'emit_context_lowers_push_method_contract'.*?)(?=\nsubtest ')/s;
die 'missing subtest' unless defined $block;
my @cases;
while ($block =~ /LinkedSpec::call_spec_handler_subst\('Top', '([^']+)'\),\n\s*qr\/[^\n]+\n\s*'([^']*wrapped target[^']*)'/g) {
    my ($action, $description) = ($1, $2);
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
    die 'expected bare target' unless $action =~ /^push\(items, /;
    die 'expected typed binding lowering' unless $lowered =~ /BindingRuntime::push_value\(\$items, "items", /;
    push @cases, { action=>$action, description=>$description, lowered=>$lowered };
}
die 'expected exactly two stale descriptions' unless @cases == 2;
print JSON::PP->new->canonical->pretty->encode(\@cases);
PUSH_LABELS
```

## Phase0 reading checkpoint

Group 76 reads Phase0 lines 42088–42887. VHDL checks source spelling for
port/declaration bindings, entry-group payloads and lowercase header flow.
Simenv, ifelse, BNF, operators_try, DT, hlink, lib_reader, sdce, ebnf, portmap
and pplugin migration checks inspect canonical metadata or helper source forms.

Six runtime-bearing subtests add bounded evidence. Ifelse returns undef with
quiet captured stdout and no exception. Those observations do not prove all
branches executed; [[perl-diagnostic-output-events]] owns sink semantics and
[[rust-null-output-oracle-fixture-boundary]] owns the diagnostic-null distinction.
Hlink checks three exact bracket/brace/mixed ASTs; the earlier scalar-reference
gap is already superseded by [[hlink-scalarref-oracle-gap]]. Lib_reader checks
its cell/attribute AST, clear last_error and an absent-or-lib_file top_rule.
EBNF checks the normalized log_rule annotation plus PUSH/CAPTURE_SLICE_START
and no CAPTURE_IF; [[ebnf-push-nonempty-explicit-filter-migration]] owns that
migration. Seven portmap inputs cover bare names, bit indices including zero,
slices, constants, symbolic indices and concatenation.

Pplugin checks exact names and preserved body text before explicitly invoking
its Perl adapter. The resulting callbacks return 3 and ok. This agrees with
[[pplugin-descriptor-ready-legacy-runtime-boundary]]: the grammar returns text;
legacy callback evaluation is a separate Perl behavior, not a portability claim.
No dependency grammar snapshot was read or trained in this slice.

Canonical ordinals 893–925 retain 650 direct assertions across 33 completed
subtests, with no nested plans. No new defect, fresh target execution or repair
closure is claimed. Tkgui remains partial after its three-rule metadata loop;
.1.77 owns the node/summary suffix. Existing .2.5–.2.12 and earlier repairs remain.

Reading is 76/143 groups, 92,382 fragments / 4,019,804 baseline bytes and 97 complete files.

Related facts: [[perl-callable-codeblock-literal-record]], [[neutral-cli-fixture-runner]],
[[complete-named-mark-perl-rust-parity]], [[perl-diagnostic-output-events]],
[[perl-duplicate-regex-slot-identity-admission]], [[perl-generated-source-contract-v2]].
