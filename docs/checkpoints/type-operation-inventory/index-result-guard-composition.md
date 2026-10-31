# Index results: canonical source and prefix guards

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.72; selection33 precedes production.
Existing index7/null14/ADR0138 authority stays: zero is numeric, missing/no-match
is undef, null differs from empty text, source is captured before the needle,
copy depth/equality/free signatures do not change. No new -1 sentinel.

```text
index_of(["a"],"a").add(1)                      # 1
index_of(["a"],"z").coalesce(7).add(1)          # 8
index_of(["a"],"a").take(1).with(){return("ran")} # undef; body skipped
index_of(["a"],"z").with(){return("fallback")} # "fallback"; legitimate null
```

Ordinary one-needle receiver and canonical free-two forms dispatch continuations
from the actual result. Incompatible consumers reject before their operands and
later bodies; valid prefixes retain effects. Explicit String-to-Array/default/
with-returned Array bridges continue with the produced kind. Preserve required
source and needle errors, malformed-shape/preflight/unknown/deferred/traversal/
function/context boundaries. Null source policy does not authorize every Array
consumer on null. Copy/null/rejection72.6 is assessed after primary guards and
repaired before unrelated selection.

Shared16: tests/fixtures/index_result_guard_cases.json. Excluded18 public shapes:
tests/fixtures/index_result_guard_excluded_ast.json. Perl typed-block producer72.0
precedes independent backend guards72.1-.5; preserve healthy controls and assess
each backend before production. Full source/domain/context/portable admission
remains23.4; general rejection isolation remains SESSION17.

## Actual reference assessment

Selection33 freezes canonical index_of source/prefix guards72 from public20 Get/descriptor/substitution/full emission/native-fresh controls. Primary16 has ten matching value/error observations, including one explicitly unready receiver bridge with unresolved with, and six gaps: free container guards, free/receiver rejected-with, two compile-failing required operand errors and function scope. Existing index0/null/no-match/null-empty distinction/equality, compatible scalar/default/Array bridges, source-needle snapshot0!/SNC and valid null/empty/Array with controls stay. The extra rejected-copy control runs ran/W; the push-yielding source also fails compilation. These three compilation controls report ready1 despite fresh-load0/warnings, never credited as executable success. Public operand AST4 retains block_value source/needle; actual lowering reconstructs raw braces. MethodLowering aggregate argument block handling is contains-only; legacy index_of target/needle fallback repeats the seam. Missing canonical index source/with role loses early rejection and source effects; existing receiver-only scalar checks already protect the direct no-with case. Null-source direct/free/selected controls return allnull with FRS while copied-null forms keep onlyC. ADR0138/null-source authority requires independent P1 copy/null/rejection assessment72.6 after primary guards before unrelated selection, not a generic nullable Array policy. Four canonical/eighteen excluded public syntax snapshots preserve shape/context/unknown/deferred/traversal boundaries; numeric index/equality/source snapshots/copy depth/free signatures/parser/schema stay. All declared source/authority/producer/case identities exact at public/syntax/operand epochs, production unchanged; no peer guard failure or complete coverage inference. Freeze shared16/excluded18 and detailed72: Perl typed-block producer72.0 first, independent guards72.1-.5, mandatory copy assessment72.6.0. Actual instruments/templates/inputs/raw errors/warnings/compile output and two setup/orchestration qualifications retained in index-guard-selection-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align. Full23.4/pressure/registration/input-custody/task-evidence/general isolation remain separate; no full suite or push.
