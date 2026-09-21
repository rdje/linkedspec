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
date: 2026-09-21
status: groups 34–45 physically read; Phase0 partial through line 8871; all runtime repair prerequisites remain
tags: [conformance, perl, reading, diagnostics, generated-source]
evidence: "CONFORMANCE-SOURCE-READING.1.34 at activation d10305097eb502c0fe29309ec230437396e26d82; eleven complete windows, 1500 fragments, 56255 bytes, ordered window SHA-256 db04deab6c0365f8bc454e2695d410324a120104a232c213346f2b23ad16aef3. Five managed Perl targets pass43 top-level tests; neutral named marks3, diagnostics20 and duplicate-slot59 mutations pass."
evidence_update_2026_09_21: "Ten complete windows cover 1,500 fragments / 51,804 baseline bytes; ordered window SHA-256 1164b42887bab92a4ea03d85fcaf4a9dc0c6913fc7607fe21a0d66cb0a424992. Cumulative reading is 35/143, 46,538 fragments / 1,405,327 baseline bytes and 86 complete files; gap tests remain partial through line 1026. Retained exact integration commit 87b35665e proof passes generated-source (6), inspector (2) and gap (124) tests (132 total), with unchanged source identities. The old uniform-identity audit fails on the approved integration delta; its corrected recipe passes all 160 inputs/143 groups/302 ranges and six rejected snapshot mutations. No new runtime execution, native build, full CI or push is claimed for this focused reading leaf."
evidence_update_2026_09_21_group36: "Eleven complete windows cover 1,500 fragments / 58,957 baseline bytes; ordered window SHA-256 071b58880845a0a7108956fb5110d4cc52fb015640fdb95b9e4d286d3e472f1f. Cumulative reading is 36/143: 48,038 fragments / 1,464,284 baseline bytes and 91 complete files. MCP admission remains partial through line 451. Fresh managed logical/map-leaves tests pass 16 top-level tests. Exact unchanged integration proof retains gap (124) and admission (13), plus the binding target within the earlier three-target MCP group (23 tests). Three bounded helper controls confirm the literal include-path defect and its mechanism; .2.3 owns implementation and independent verification after required prerequisites. No production repair, dependency build, new canonical CI or push is claimed."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/complete_named_mark_contract.t t/diagnostic_output_perl_contract.t t/duplicate_regex_slot_identity_perl_contract.t t/generated_source_contract.t; bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py; bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py; bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
evidence_update_2026_09_21_group37: "Fourteen complete windows cover 1,500 fragments / 63,613 baseline bytes; ordered window SHA-256 98d4de26a6f747975c45fe91277d218c6947936925d1ae233586706bef952d64. Cumulative reading is 37/143: 49,538 fragments / 1,527,897 baseline bytes and 97 complete files. Phase0 remains partial at lines 1–43. Fresh managed metadata/oracle checks pass 9 top-level tests. Unchanged integration commit 87b35665e retains native-loader (5), MCP binding/dispatch/stdio (23), admission (13) and Phase0 1032 proof. Full-target execution grants no reading credit to the unread Phase0 body. Header correction .2.4 is pending after prerequisites; helper repair .2.3 and existing runtime repairs remain open. No dependency build, new canonical run or push is claimed."
evidence_update_2026_09_21_group38: "Eleven complete windows cover 1,067 fragments / 65,529 baseline bytes; ordered window SHA-256 f57116fee0db80f49969546da5cd033988e06b55191fc88358b7c6d6d334fd3e. Cumulative reading is 38/143: 50,605 fragments / 1,593,426 baseline bytes and 97 complete files. Phase0 is partial through line 1110. Exact unchanged canonical commit 87b35665e supplies PASS for all 38 fully read subtests (ordinals 2–39). The crossing facade error-state test remains partial; its suffix is .1.39-owned. The complete 1032-test gate remains retained historical proof, not new execution or reading credit. No new defect, runtime repair, dependency build, full CI or push is claimed; all existing repairs retain their prerequisites."
evidence_phase0_checkpoint: "Eleven complete windows cover 1,045 fragments / 65,409 baseline bytes; ordered window SHA-256 57fa586148e84cf02124246fd1ea0621df41394f0111f36e7fa069638e3ac60c. Cumulative reading is 45/143: 58,366 fragments / 2,050,502 baseline bytes and 97 complete files. Phase0 is partial through line 8871. Unchanged canonical commit 87b35665e retains PASS for 26 completed subtests, ordinals 254–279 with 289 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The compile-entry exception test is partial after four of twelve assertions; .1.46 owns the remaining eight. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain."
reverify_phase0_checkpoint: "Replay .1.45 using conformance-source-reading-coverage; compare ordinals 254–279 and unchanged own Perl sources against canonical commit 87b35665e. Retained execution grants no additional reading credit."
reverify_group38: "Replay .1.38 using conformance-source-reading-coverage and compare its 38 complete subtest names with retained canonical commit 87b35665e; this grants no new source-reading or runtime credit."
reverify_group37: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/noncurrent_helper_metadata.t t/oracle_root_target_regex_semantics.t; retain unchanged dated MCP/native-loader proof separately."
reverify_group36: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/logical_helper_perl_contract.t t/map_leaves_mutation_perl_contract.t; reproduce the helper observation with HELPER_PATH below, and retain the dated gap/MCP proof separately."
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

## Phase0 reading checkpoint

Group 45 reads Phase0 lines 7827–8871. [[runtimecontext-boundary]] separates read access,
spec-identity-only clearing and preparation for inline Get, compiler pipeline, compiled-table
construction and file-oriented get_parser. Hashes and populated scalar slots preserve caller
fields; requested top identity, stale errors and capture callbacks reset according to the
specific entry point. File-parser preparation does not add capture storage to a fresh context.
Unhooked calls leave prior contexts untouched; malformed populated slots are rejected.

SpecEntry setter and retired-facade traps cover selected delegation paths, handler presence
and descriptor metadata. Injected bootstrap callbacks and source capture are observed directly.
Repeat-handler assertions check emitted nested helpers and exclude old eval wrappers. They
inspect generated text without independently loading and executing that text.

Compiler failures distinguish setup contracts, validation false returns and exceptions,
bootstrap exceptions and malformed success values, invalid generated dependency indexes and
nested compiled validation. Specific summaries, detail, stage/owner-stage, rule attribution or
requested-top fallback and empty inline spec identity have separate assertions. These controlled
failure paths reconcile with [[perl-compiler-pipeline-stage-and-mode-boundaries]]; they do not
close the separately owned diagnostic-source or combined-return-mode repairs.

Twenty-six completed subtests retain canonical PASS at ordinals 254–279 (289 assertions),
with Phase0, own Perl sources and shipped specs unchanged from 87b35665e. Replay checks every
sequential assertion number. No new execution is claimed. The compile-entry exception test
ends after four of twelve assertions; .1.46 owns its eight remaining diagnostic assertions.
Reading is 45/143, 58,366 fragments / 2,050,502 baseline bytes and 97 complete files. All
prerequisite-gated runtime repairs remain open; prior exact checkpoints remain in task nodes/Git.

Related facts: [[perl-callable-codeblock-literal-record]], [[neutral-cli-fixture-runner]],
[[complete-named-mark-perl-rust-parity]], [[perl-diagnostic-output-events]],
[[perl-duplicate-regex-slot-identity-admission]], [[perl-generated-source-contract-v2]].
