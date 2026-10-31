# String-predicate source and prefix guards

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.31; independent implementations70.1-.5.

Preserve the existing starts_with/ends_with/contains_substr/matches producers and
their source/operand domains. Only canonical two-operand positional free calls
and ordinary one-operand prefixes join current actual-kind/rejection guards.
Keep regex literal operands and flags on their existing typed representation;
this adds no regex operation, dynamic pattern promise, context or serialized field.
The three text predicates return numeric1/0 on the checked backends. matches
returns numeric1/0 on Perl and Boolean on the native peers. Preserve that difference.

Required examples:

```text
starts_with("abc","z").take(1)                       # undef
"abc".ends_with("z").take(1).with(){return("ran")}    # undef; body skipped
"abc".matches(/^z/).cat("x").split(",").set_key("k",1).with(){return("ran")} # undef
starts_with("abc","z").cat(",x").split(",").last().uppercase() # X; already healthy
```

Source then operand then consumer evaluation/snapshots remain once/ordered.
Required SO prefix effects stay before a rejected consumer; rejected operands and
later bodies skip. Legitimate false/null/empty with inputs and actual returned
Array values remain valid. Keep copy/default/generic/strict arithmetic and needed
source errors. Do not normalize producer flags, free signatures, unknown names,
aliases, traversal/deferred/callable/context rights or full text/regex domains.

Shared22: tests/fixtures/string_predicate_result_guard_cases.json. Four existing
expected_nonperl profiles preserve numeric/Boolean kinds and repeated-definedness
false text; three are directly qualified by a public producer profile on all
backends, the fourth follows existing28.0/native-peer authority. Every backend
independently baselines guard behavior before production. Excluded18 public syntax/
lowering snapshots are source fences, not exhaustive excluded-runtime proof.

## Selection evidence

Selection31 freezes existing String-predicate result source/prefix guards70 for starts_with/ends_with/contains_substr/matches, canonical free-two/ordinary one-operand only. One public Perl22 Get/descriptor/substitution/full-emission/native-fresh intake yields thirteen ready healthy values/seven ready wrong groups/one matching-null unsupported-with unready/one qualified needed source error, raw0/fallback0/warnings[]. Free guards yield[]/Hash{k:1}/KV, free-with SOW, receiver-with drops SO/runs W, variants WWWW/function WX; receiver bridge is unsupported-with while free cat-split bridge already works. Actual substitution exposes Array fallback, Hash dispatch on predicate scalar, with(undef) normalization and unsupported with; current pure String transform/free/prefix source lists exclude predicates, despite scalar_result method metadata. Public canonical4/excluded18 syntax/lowering observations retain regex operand kind=regex/flags=i. Freeze selected helpers through current emitted/scoped-with/intermediate actual-kind guards, preserving source then operand then consumer SOC snapshots, domains/arity/copies/defaults/strict numeric/generic/valid null-empty with/returned Array/errors/function caller state. One additional finite public producer profile independently qualifies all five backends on available native/restored/plan/fresh routes and both Lua hosts: three text predicates retain numeric1-0, matches retains Perl numeric versus native Boolean, strict arithmetic/null-empty/literal i remain. Three kind profiles directly checked; fourth repeated-definedness false-text profile adopts existing28.0/native-peer authority. All observer exits0 establish transport, not feature acceptance. Exact declared source/authority/producer/case identities before-after, not complete transitive closure; actual temporary Cargo-consumed example is bound, retained then removed. Shared22/four profiles/excluded18/target/card/book/map/task/roadmap/live/resume/history and actual instruments/source/raw channels retained in string-predicate-guard-selection-intake.json.gz. Create independent Perl70.1/Rust70.2/Dart70.3/Julia70.4/safe Lua70.5 before production. No runtime production change, peer guard failure inference, producer or regex/domain normalization, deferred/context/alias/unknown/traversal/schema/full23.4 admission.

## Bounded Perl70.1 implementation

Perl70.1 adds a dedicated canonical String-predicate source/prefix role for starts_with/ends_with/contains_substr/matches. Unchanged shared22 groups14PASS8RED become22PASS native/fresh: seven wrong groups and one unsupported-with readiness gap repaired, thirteen healthy values and the needed source error exact. All21 value programs ready/raw0/fallback0/unresolved0/warning-free. Existing emitted/scoped-with/intermediate actual-kind guards reject incompatible operands and later bodies while preserving source-operand SOC snapshots, numeric flags, null/empty/text/regex domains, copy/default/strict arithmetic/generic predicates and valid false/null/empty with/returned Array/function caller state. Regex kind is admitted only in the existing matches operand, with producer/flags untouched. Canonical free-two/ordinary one-operand spelling/arity and recognized operands required; unknown/traversal/deferred/trailing overloads stay excluded. Nearest predicate/free String/receiver bridge/presence 59 assertions, excluded18 public AST/lowering fences and owner/normal syntax pass. 461 other declared activation inputs exact; seven actual primary/nearest fixtures derived from consumers and all phase identities retained, not complete transitive closure. Actual instruments/templates/inputs/raw channels/four before-after public substitutions retained in string-predicate-guard-perl-intake.json.gz. Regenerate emitted Perl. Rust70.2 independently next; general rejection isolation, full regex/domain/context/portable admission23.4 and canonical registration remain separate.

## Bounded Rust70.2 implementation

Rust70.2 preserves canonical String-predicate free-two/ordinary one-operand source guards. Independent unchanged23 tests15PASS8RED become23PASS on native/restored CompiledSpec/in-process plan routes;15 includes thirteen healthy values/one needed source error/one eighteen-shape scaffold. All21 values/four existing profiles/thirteen healthy observations/error/eighteen public syntax observations retain exact kinds and behavior. Initial pure-role implementation gives20PASS3RED: only matches members still yield free[]/A or run with/AW. Existing public CodeBlock::parse observations expose kind=regex/Expr::RegexLiteral omitted from the copied lexical operand union. Recognize that existing node only as matches final positional operand (free index1/prefix index0), leaving payload/flags/evaluator and text-predicate operands unchanged. Both existing guard admissions retain source-operand SOC snapshots, numeric text flags versus Bool matches, strict arithmetic/copy/default/generic/valid false-null-empty with/returned Array/errors/function state; incompatible operands/later bodies skip. Selected nearest predicate/free String/receiver bridge/presence 58 tests and owned core/runtime fmt pass. 533 other declared activation inputs exact. Twelve actual include_str fixtures derive from five consumers and match base Git bytes; all phase declared identities exact, not complete transitive closure. Initial fixture instrument correctly derived twelve but assumed ten; repaired before runtime baseline with original writer retained, no runtime RED credit. Original/intermediate/repaired epochs, actual instruments/templates/inputs/raw channels retained in string-predicate-guard-rust-intake.json.gz. Rebuild Rust apps/runtime. Dart70.3 independently next; no isolated emitted, full regex/domain/context/portable admission23.4 or general isolation claim. Dependency warnings remain opaque/upstream-owned.

## Bounded Dart70.3 implementation

Dart70.3 retains canonical String-predicate free-two/ordinary one-operand source guards. Independent unchanged23 tests17PASS6RED become23PASS on native/restoredSpec/in-process plan routes;17 includes fifteen healthy values/one needed source error/one eighteen-shape scaffold. All21 values/four existing profiles/fifteen healthy observations/error/eighteen public syntax observations exact. Public baseline exposes free[]/Number1/AKV, free-with SOAW, receiver bridge KVW and function/free-predicate variants; existing receiver-with/short-prefix controls already work. A dedicated pure role joins common kindGuardedResult, recognizing the existing ActionRegexLiteralExpr only in matches final positional operand. Producer/regex representation/flags/scalarResult assignment/with/preflight remain unchanged. Numeric text flags versus Boolean matches, strict arithmetic/copy/default/generic predicates, source-operand SOC snapshots/once-order and valid false-null-empty with/returned Array/errors/function caller state stay; incompatible operands/later bodies skip. Selected nearest 59 tests/fatal owner-new-normal analysis/new-normal formatting/verbatim isolated new-member formatting pass; all runtime/analysis/format stderr empty. 223 other declared activation inputs exact. Six actual literal/stem-extension runtime fixtures derive from five consumers; two nearest consumers embed programs. All phase identities exact, not complete transitive generation closure. Actual instruments/templates/inputs/raw channels retained in string-predicate-guard-dart-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; rebuild Dart applications/runtime. Julia70.4 independently next. No whole-SDK formatting, peer fix, regex/domain/context normalization/general isolation/full23.4 admission.
