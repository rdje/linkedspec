# ActionIR Lowering Mental Model

ActionIR is the bridge between LinkedSpec action syntax and emitted runtime code.

It exists because the project does not want `.spec` files to remain tied forever to raw Perl fragments. The target is a cleaner semantic layer:

```text
.spec helper DSL -> canonical ActionIR -> emitted backend code
```

Today the emitted backend is Perl. The direction is backend-neutrality.

## Why not just keep raw Perl?

Raw Perl is powerful, but it has a cost:

- it is hard to validate structurally
- it is hard to translate to non-Perl backends
- it hides parser intent inside host-language details
- it makes examples harder for new users to generalize

Helper DSL makes common parser actions explicit.

Instead of asking readers to understand a substring expression, a mutable array push, and a return shape all at once, a rule can say:

```text
name = entry_group(0);
push(items, name);
return(hash("kind", "names", "items", copy(items)));
```

That is still compact, but it is more self-describing.

## A simple lowering example

Source-level helper DSL:

```text
name = entry_group(0);
return(hash("kind", "token", "name", name));
```

Semantic reading:

- write the first entry capture group to local scalar `name`
- return a structured payload with a fixed `kind` and the captured `name`

The exact emitted Perl is an implementation detail for most users. What matters is that these helper forms describe operations LinkedSpec can reason about.

## Current Helper Forms

Public `.spec` actions should use the current helper surface:

```text
retv = call(Child);
push(items, retv);
```

Deleted helper names are not part of the contract resolver. A backend may still report
an unknown-helper diagnostic for an unrecognized helper-looking call, but that is not a
compatibility path and it does not lower through a name-specific replacement table.

## What counts as a good helper form?

A good helper form should make these questions easy to answer:

- What value is being read?
- What value is being written?
- Which parser boundary or mark is being used?
- Does the helper mutate a boundary or only read it?
- Is the result a scalar, array, hash, boolean, or rule call?

That is why recent naming work strongly favors explicit names such as:

- `capture_rest_from(name)`
- `capture_take_until_cursor_len_from(name)`
- `dependency_regex_map`
- `dependency_refs`

Names should reduce guessing.

## How to learn the surface

Start with the core families:

- `set(...)` for writing values
- `return(...)` for returning payloads
- bare scalar reads plus `array(...)` / `hash(...)` for value construction
- `entry_*` and `match_*` readers for match data
- `capture_*` and `mark_*` helpers for parser boundary work
- `if(...)` and `switch` helpers for structured control flow

Then move into the more specialized helper families as needed.

## The lowering pipeline

The lowering *pipeline* — discover which helper contracts are present, split statements, canonicalize helpers into ActionIR events, then dispatch each to a lowering owner before emitting backend code — is a **backend-neutral** sequence. The specific owner modules named in this section (`ActionIR::Scanner`, `ScannerCore`, `StatementSplit`, `CanonicalEvents`, `RewritePipeline`, the per-family lowering owners, and `ActionIR::Contracts`) are the **Perl reference backend's** realization of those stages; another backend organizes the same scan → split → canonicalize → lower → emit flow in its own modules.

ActionIR lowering is not one monolithic pass. It flows through a pipeline of owners, each responsible for one stage:

```text
source rule paragraph text
  -> Scanner (contract discovery)
  -> StatementSplit (safe statement splitting)
  -> CanonicalEvents (normalize helpers into canonical ActionIR)
  -> RewritePipeline (glue scan/classify/lower phases)
  -> FlowExpr / ValueExpr / ControlFlow / MethodLowering / DeclareMethod / ArrayPipeline
  -> Emit (final backend code generation — Perl in the reference backend)
```

### Scanner

`ActionIR::Scanner` discovers which helper contracts are present in a rule's action text. Its ordered registry contains `StagedParseJob`, `ProgressiveSpanDispatch`, `RecognitionTransactionRules`, `PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules` and `LegacyRules`. The first dispatcher that returns a defined result selects the contract result, including an empty or opaque result. `ScannerCore` is the single source of truth for the scanner dependency contract — the mapping between recognized helper patterns and their lowering handlers.

The pipeline family has a separately retained nineteen-contract diagnosis. Eleven contracts
scan the original full input, while eight select original statements; nested hash assignment
and value-only expressions each have two event-construction branches. The diagnostic source
repeats literal receivers and structured plans around Unicode, CRLF, quoted helper text and
ignored comments. Its public and private scans keep the same arguments and dependency
callback inputs/results. All eleven full-input regex pipeline contracts now retain private
source origins; ten new hooks preserve the existing `set_value` channel. Match coordinates
and raw expressions are captured before parser/planner callbacks, and recording keeps the
original event and argument objects. All eight statement contracts now carry original
occurrence frames through their ten existing event constructors. The supplied splitter runs
once and returns its original array. Ignored statements still advance the frame index;
copied, changed, opaque or foreign-source arrays supply no occurrence authority.
Quoted matches are syntactic observations, not executable membership.

For repeated calls, the private channel identifies each original occurrence:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'push'}, "push(items, '雪'); push(items, '雪');", $scanner_deps
);
# source_origins spans: [0, 16), [18, 34)
```

The same original-owner regression first fails for the ten missing hooks, then passes for
all eleven regex contracts; empty and rejected calls add no origins. Public events still
contain only `raw` and `args`. Independent before/after probes preserve full generated
source, substitution and descriptor channels, including original pipeline plan inputs.

Statement occurrences use the same private channel. Repeated equal text keeps distinct
scalar intervals, and nested scans restore the outer collector:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'scalar_assignment_operator'}, 'value = 7; value = 7;', $scanner_deps
);
# source_origins spans: [0, 9), [11, 20)
```

Direct and nested hash assignments each keep their original constructor branch:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'hash_index_assignment_operator'}, "tree['key'] = '雪'; tree['key'][0] = '雪';", $scanner_deps
);
# source_origins spans: [0, 17), [19, 39)
```

The eight covered statement contracts are print-foreach, split/trim/filter assignment,
scalar assignment, array append, array end mutation, hash-index assignment, key assignment
and value discard. Both value-discard branches and all four array end methods retain their
existing arguments. Later callback transformations preserve events but decline origins when
the resulting raw text no longer matches the original frame. Exceptions and caller error
state retain their existing behavior. This is private compiler provenance; public events
remain `raw`/`args`, and family signoff still requires its canonical closeout.

A fresh immutable Git recurrence now repeats all nineteen pipeline contracts from the
committed implementation, with no candidate overlays. Three controlled seeds preserve
the literal source/argument/interval oracle, actual returned-event and constructor/argument
references, all five callback effects, and the exact earlier complete compiler channels.
The normalized split and equal-valued copied-return controls also recur unchanged.
Fourteen direct suites check the composed pipeline and existing source-frame consumers.
Canonical acceptance additionally requires the exact staged local CI receipt before family
closure. This closes private pipeline provenance. The other producer proofs are retained
separately and composed below; executable membership, comments and replacement
remain separate work.

The split scanner now reports the normalized source expression from its successful planner:

```perl
split(items, input, ',')
# planner split op: source_expr => '$input'
# current scanner event: source => '$input'
# lowering still reads $input
```

A bare input binding appears as `$input`; literal inputs keep their quoted text, and
compound inputs keep their trimmed call expression. The descriptor's helper and canonical
events report the same source expression. These examples show the event field:

```perl
split(items, ' 雪,β ', ',')
# args.source => "' 雪,β '"
split(items, cat('雪', ',β'), ',')
# args.source => "cat('雪', ',β')"
```

Supplied planner callbacks that publish only the older `source_symbol` retain that value.
A defined `source_expr` takes priority when both fields exist, including the expression
`"0"`; an undefined canonical field falls back to the older field. Generated lowering,
raw expressions, target/delimiter fields and private occurrence origins stay unchanged.
The original null metadata remains retained as the before observation, with complete
compiler channels and an independent source/argument/plan oracle. This correction adds
no DSL form or native-execution guarantee.

### StatementSplit

`ActionIR::StatementSplit` splits action text into individual statements safe for independent lowering. This is important because a single action block can contain multiple helper calls (`set(...)`, `push(...)`, `return(...)`) that must be lowered separately.

The separator contract is deliberately narrow: top-level newlines split helper statements,
and a semicolon separates adjacent statements on one physical line. It is a separator, not
a line terminator, so the last statement on that line needs no trailing semicolon. Plain
spaces do not create a boundary. Nested semicolons inside expression payloads stay inside
the payload. Executable examples without inline comments therefore omit line-ending semicolons
when a newline already separates the statements.

The Perl reference supports newline separation after assignments, captures, cursor
changes, and marker-control statements as well as helper calls. These sequences
lower like their equivalents separated by semicolons on one line. Newlines inside parentheses, brackets, blocks, quoted strings, regex payloads,
and comments use the scanner state appropriate to that construct.

Perl still has comment limitations (`SESSION-STARTUP-READING.34`). An inline
comment can hide a generated separator; an explicit semicolon before it avoids
that LF/CRLF lowering failure. However, closing-delimiter text inside an inline
comment, such as `# pattern/)`, can still affect structural validation even with
that semicolon. Put such comments on their own line. CR-only comments can absorb
the following statement; use LF or CRLF for comment-bearing source until that
repair lands.

The lowering pipeline retains the canonical contract ID while deciding whether a newline
boundary needs host syntax. This matters for marker-style `switch`: its Perl representation is
an expression-shaped `do { ... }`, so `endswitch()` needs a generated host terminator before a
following newline-separated statement. Ordinary `if` block closure remains statement-shaped
and receives no such terminator. Neither detail changes the source-level separator rule.

### Flow source occurrences and recursive traversal

Flow scanner events describe syntactic observations. The original family has sixteen
contract dispatchers: thirteen scan regex matches, `next_stmt` splits statements,
and `case_flow` / `default_flow` each concatenate two traversals. At the original
pipeline acceptance boundary, only `if_flow` recorded private original-source origins
in this family. All fourteen direct Flow contracts now retain original occurrence
frames: thirteen regex producers and the `next_stmt` statement producer. The
recursive case/default producers now translate their original block and parsed
argument frames into the full action source. These private hooks
do not change recognition or executable membership.

Direct aliases and bare markers preserve their original spelling in event `raw`:

```text
otherwise { next }  -> else_flow raw: otherwise { next }, args: {}
endif              -> endif_flow raw: endif, args: {}
while(false) { next() } -> while_flow args.condition: false
```

Parsing `otherwise` through a normalized `else()` helper does not authorize an
`else()` source span: the source occurrence is still the authored `otherwise`.
Likewise, callbacks can parse nested syntax and replace regex match globals; a
producer must snapshot its own match coordinates before invoking them.

Direct origins retain the complete original action, scalar intervals and original
returned event/argument objects. For example:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'elseif_flow'}, 'elseif(true); elseif(true)', $scanner_deps
);
# source_origins spans: [0, 12), [14, 26)
```

Bare markers retain their authored spelling rather than the normalized parser call:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'else_flow'}, 'otherwise', $scanner_deps
);
# event raw: otherwise; source_origins span: [0, 9)
```

`next` uses the same private statement-frame authority as basic and pipeline
statement producers. Ignored statements still consume their occurrence frame:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'next_stmt'}, 'note(); next; next()', $scanner_deps
);
# source_origins spans: [8, 12), [14, 20)
```

Unknown/copied/foreign callback arrays cannot lend frames. If a callback changes
one returned entry, that entry declines authority while an exact unchanged entry
retains its own frame. A later trim transformation also retains its ordinary event
without inventing a source interval. Nested scans restore the outer recorder;
ordinary scans keep the original callback count, arguments, results and event schema.

Case/default first scan marker matches, recursing into attached blocks in depth-first
order. They then append the inline-switch branch traversal, including nested branch
arguments. For example:

```text
switch(kind, case("inline", case("nested")), default(default())); case("tail")
# case_flow event order:
# case("tail"), case("inline", case("nested")), case("nested")
```

The complete inline branch raw above is `case("inline", case("nested"))`.
The later tail marker precedes the earlier inline branch in this composite stream.
Sorting events by source position would change the original contract. Repeated
`case("twin")` or `default()` arguments also require separate occurrence frames;
equal raw text cannot identify which original argument produced an event.

Recursive source provenance translates each captured block and each trimmed
parser argument back to the full original action. Leading/trailing whitespace and
empty comma slots affect source offsets even when the parser drops them from its
argument array. Private frame authority must therefore come from the actual parser
invocation and returned argument references, with transformed/copied/foreign callback
results retaining their events but receiving no invented source authority.

Captured attached blocks retain their original base; nested inline arguments use
the actual parser's retained argument frames. Both paths record the full original
action rather than the local recursive substring:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'case_flow'}, 'case("outer") { case("inner") }', $scanner_deps
);
# event order: outer, inner
# source_origins spans: [0, 31), [16, 29)
# both source fields contain the complete original action
```

Repeated inline twins retain distinct original coordinates. Copied or foreign
parser results keep their ordinary events but cannot lend inline argument
coordinates; directly captured marker text retains its own match authority.
A transformed branch trim also keeps its event without inventing an origin.
Nested private scans restore the outer recorder, and callback counts, arguments,
results, exceptions and public event fields remain unchanged.

The scanner still observes case-like text inside quoted payloads where its
original recognizer did so. Adding an exact source origin does not turn that
observation into executable membership. Quoted-source membership is subsequent
work; the provenance oracle retains the original syntactic population.

A fresh immutable family recurrence repeats all sixteen Flow contracts using
committed producers and fixtures. It checks original event/argument objects,
full-action scalar intervals, callback/compiler channels, MethodExpr argument
frames and custom authority denials under three hash seeds. Exact staged canonical
CI is required before family acceptance closes. This closes private provenance;
quoted executable membership, other scanner families, comments and replacement
remain subsequent work.

Legacy scanner source work is partitioned by producer mechanism: call/return/push,
anonymous captures, named captures, mark controls, cursor/input reads, and
entry/match reads. The original private diagnosis covers 112 internal contracts
with repeated Unicode/CRLF fixtures. Only `return_general` already supplies source
origins at that boundary. These internal compatibility names do not establish new
public helper spellings. Each family must retain its original arguments and
compiler behavior before executable source membership can use its coordinates.

The Perl boundary scanner and lowerer now decode the same recognized quoted-or-word
atoms. A comma inside a quoted atom stays part of its label, so an unresolved
`"a,b,c"` cannot create a false `b` boundary. Their outer recognizer grammar,
raw helper occurrence and quote/backslash decoding stay unchanged; this repair
does not yet add boundary source sidecars. Nested boundary-call serialization
now preserves the original recognized lexical spelling when every decoded atom
agrees with the typed arguments, including empty quoted slots and their complete
count. This prevents assignment or return normalization of `"a\,b"` from losing
the later compatibility rewrite. Fake or inconsistent call sources, discarded
CSV slots and zero arguments retain ordinary AST reconstruction. Ordinary strings
and other calls keep their existing serializer; callback dispatch is unchanged.
This lexical check supplies no source-coordinate authority or occurrence mapping.
The [boundary reference](source-boundary-helper-reference.md) gives executable
quoted-label and unknown-escape examples. Compiler selection now excludes the
covered quoted helper occurrences. Precise residual replacement still has its
own acceptance boundary; helper-looking literal data can still be rewritten as
code on routes not covered by the compiler-membership repair.

The call/return/push family now retains its selected original scalar occurrences
through the private recorder. Seven hooks complement the existing `return_general`
hook: internal `call`, the five push variants, and the two-argument `return`.
They snapshot regex bounds before prefix exclusions or trim callbacks and return
the same event and argument objects. Repeated equal text keeps distinct origins:

```text
call(Done); call(Done)
# original scalar intervals: [0, 10), [12, 22)
```

Exclusions still belong to the original recognizer. A nested `call` in
`recognize_once` or `observe_recognition` gains no independent call origin; the
following standalone call does:

```text
recognize_once(scope, call(Hidden)); call(Done)
# the selected original occurrence is call(Done)
```

Likewise the target-push scanner still excludes its primitive literal targets:

```text
push(items, true); push(items, target)
# the target-push contract selects only push(items, target)
```

The public event fields, callback effects, substitution, descriptors and parser
source remain unchanged. These internal compatibility IDs admit no new helper
spelling.

Anonymous capture producers also retain their own original scalar occurrences.
The 26 internal contracts cover capture macros, rule-label capture, zero-argument
slice/rest/start/position reads, take aliases and structural-boundary capture.
Each producer snapshots its regex bounds before constructing arguments or decoding
boundary labels. The private recorder retains the original event and argument
objects; the public event fields and complete compiler/callback channels stay the
same. Both repeated macro occurrences keep separate frames:

```text
$CAPTURE; $CAPTURE
# original scalar intervals: [0, 8), [10, 18)
```

Aliases retain the spelling that actually appeared in the source:

```text
capture_take(); capture_take()
# capture_take_slice dispatcher; scalar intervals: [0, 14), [16, 30)
```

A quoted comma inside `capture_until_boundary("a,b", end)` remains one label;
its source origin covers the complete original call before quote decoding. The
nested lexical serializer described above still supplies no coordinate authority.
These private origins preserve the original syntactic population, including
helper-looking quoted data: executable membership has not yet been admitted.
Named captures preserve their original symbolic mark arguments and start/end order.
Their17 producers save physical match coordinates and keep the same event and
argument objects, including the bridge that restores the anonymous capture
boundary from a named mark. One-mark take forms retain their actual spelling;
`capture_take(edge)` differs from anonymous `capture_take()` by its existing
argument grammar. Two-mark readers retain the first mark as `start` and the
second as `end`:

```text
capture_from(edge); capture_from(edge)
# mark: edge; scalar intervals: [0, 18), [20, 38)
```

```text
capture_between(first, second); capture_between(first, second)
# start: first; end: second; scalar intervals: [0, 30), [32, 62)
```

These private source frames preserve the original syntactic population and public
compiler output. They add no executable quoted/comment membership authority and
change no runtime mark storage or capture semantics. Mark-control producers preserve target/source order and their original event objects.
All14 creation, copy, query and clearing producers save physical regex bounds
before argument construction. For `mark_copy(first, second)`, `first` stays the
target and `second` stays the source mark. The source mark argument remains inside
the event's arguments; the private source frame separately retains the original
action text. These fields never overwrite each other:

```text
mark_here(edge); mark_here(edge)
# mark: edge; scalar intervals: [0, 15), [17, 32)
```

```text
mark_copy(first, second); mark_copy(first, second)
# target: first; source: second; scalar intervals: [0, 24), [26, 50)
```

Position, line, column, existence and clearing calls retain the same symbolic
mark names and public compiler output. This source work changes no runtime mark
storage, missing-source clearing semantics or executable quoted/comment membership.
Cursor/input producers also retain their original physical occurrences. Each of
these15 producers saves its match bounds before constructing the event. Position,
line, column, rest, input, save/restore and rewind calls keep their original raw
spelling and empty argument object. Equal calls retain distinct scalar frames:

```text
cursor_pos(); cursor_pos()
# original scalar intervals: [0, 12), [14, 26)
```

The balanced `input_slice` recognizer keeps the complete nested expression,
including quoted commas, as its original raw event. Its scanner arguments remain
empty; the separate compiler lowerer interprets the expression as before. Source
provenance adds no argument parser or new grammar:

```text
input_slice(1, nested("a,b")); input_slice(1, nested("a,b"))
# empty scanner args; scalar intervals: [0, 29), [31, 60)
```

These private frames change no cursor movement, runtime source projections,
public event schema or executable quoted/comment membership.

Entry/match producers retain their original raw spelling and argument objects.
All32 regex producers save their own physical bounds before creating the event.
Group indices and symbolic names remain their original scanner arguments;
zero-argument readers keep empty arguments. The index is the captured source
string, while the existing compiler still applies its original group semantics:

```text
entry_group(2); entry_group(2)
# index argument: "2"; scalar intervals: [0, 14), [16, 30)
```

```text
match_named(part); match_named(part)
# name argument: part; scalar intervals: [0, 17), [19, 36)
```

Compatibility aliases keep the spelling actually present in each occurrence,
even when they project the same runtime boundary:

```text
entry_start_line(); entry_line()
# distinct spellings; scalar intervals: [0, 18), [20, 32)
```

All original Legacy producer families now retain syntactic source origins. This
changes no entry/local-match capture values, absent/empty distinctions, cursor
movement, public event schema or compiler channels. Complete-family validation
replays all112 original internal contracts through115 literal cases, including
the original recognition, primitive-target and quoted-boundary controls. Its six
families are call/return/push, anonymous capture, named capture, mark control,
cursor/input and entry/match. Independent authored scalar intervals and actual
event/argument references distinguish repeated equal text from its occurrences.
Fresh immutable inputs, three hash seeds and complete callback/compiler channels
check each family against its original behavior.

The focused compatibility fixtures can be run with:

```sh
bash tools/project_data_run.sh prove -v -Iperl \
  t/actionir_helper_source_provenance.t t/generated_source_contract.t
```

Executable quoted/comment membership and source-based replacement remain
separate work; a syntactic source origin alone does not authorize rewriting
helper-looking data as executable code.

### Dedicated annotation source provenance

The staged producer now retains a private source origin for each unchanged
original annotation. The progressive producer now retains a private source origin
for its unchanged whole statement too. All five recognition/observation scanners now retain their
selected private whole-statement origins. Their canonical statement splitter supplies
physical frames before trim or operand parsing; each scanner keeps the original
list snapshot and matches frames by occurrence. A dedicated annotation owns its
whole statement, including its original target and operands:

```text
job = parse_job(entry_text(), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","replace_marker","on_error","fail"))
```

Staged source frames retain the original statement occurrence before trim or
operand parsing callbacks run. The private sidecar points at the actual returned
event and argument objects; public events and generated parser text keep their
existing shape. Repeated equal annotations retain distinct original intervals.
Copied splitter arrays, foreign source and changed raw text gain no invented
coordinates. Nested scans keep independent recorder contexts.

A derived text plan and normalized options retain their existing validation:

```text
job = parse_job(cat(entry_group(1), cat(match_text(), entry_text())), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","append_child","on_error","keep_text","top","Expr","into","children","required_capabilities",array("z.cap","a.cap")))
```

The concatenation keeps its ordered entry-group, match-text and entry-text
segments; required capabilities normalize to `a.cap`, `z.cap`. An invalid option
still produces the original scanner event and its validation failure:

```text
job = parse_job(entry_text(), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","replace_marker","on_error","fail","unknown","value"))
```

The source origin does not make `unknown` a supported option. Staged payload
provenance continues to describe parsed input text, separately from this authored
annotation's source position. Progressive dispatch also keeps the distinction
between a literal parser identity and a dynamic operand:

```text
child = dispatch_span("expr-v1", "Expr", span)
child = dispatch_span(parser, "Expr", span)  # rejected: parser identity must be literal
```

Progressive frames retain the original parser, top-rule and span operands, together
with the result binding. Equal repeated dispatches keep independent scalar positions:

```text
child = dispatch_span("expr-v1", "Expr", span); child = dispatch_span("expr-v1", "Expr", span)
# original scalar intervals: [0, 46), [48, 94)
```

The original event and argument references survive, including dynamic parser and
wrong-arity events that static validation rejects. For example:

```text
child = dispatch_span("expr-v1", "Expr", span, other)
# rejected: dispatch_span requires exactly three operands
```

Private source provenance does not grant parser authority or relax static policy.
Copied splitter arrays, foreign source and transformed raw text gain no invented
progressive coordinates; nested scans restore independent recorder contexts.
Host registry authority, capability restrictions and separately tracked resource
ceiling enforcement retain their existing contracts.

Recognition statement provenance preserves the token and unevaluated static
callee. A transaction selects one terminal operation:

```text
scope = recognition_checkpoint()
matched = recognize_once(scope, call(Done))
payload = recognition_commit(scope)
# Alternative terminal: recognition_rollback(scope)
```


Each checkpoint, attempt, commit, rollback and observation origin retains the
same returned event and argument objects. The selected statement includes its
original result or token slot and unevaluated callee. Repeated equal checkpoints
keep distinct scalar intervals:

```text
scope = recognition_checkpoint(); scope = recognition_checkpoint()
# original scalar intervals: [0, 32), [34, 66)
```

Recursive observation also owns its whole annotation; the nested static `call`
is not a second generic call or assignment event:

```text
value = observe_recognition(observation, call(Done)); value = observe_recognition(observation, call(Done))
# original scalar intervals: [0, 52), [54, 106)
```

Malformed operands and arity retain their original scanner fields for static
policy to reject:

```text
matched = recognize_once(scope, Done)
value = observe_recognition(observation)
value = observe_recognition(observation, call(Done), extra)
# rejected: static call operand, missing observation operand, extra observation operand
```

The bare attempt operand gains no invented callee. Missing observation operands
keep `operand_kind=missing` and `argument_count=1`; an extra operand keeps
`argument_count=3`. These syntactic events remain available to validation.
Copied, foreign or transformed recognition callback data gains no invented
coordinates. Fatal callbacks preserve their error; real nested scans restore
independent recorder contexts. Source origins do not repair token order,
restoration, boolean payload kind or other separately tracked runtime defects.

The original diagnosis checks all seven dedicated contracts: one staged annotation,
one progressive annotation, four transaction forms and recursive observation.
Independent original intervals distinguish repeated equal statements; actual
dispatcher references and complete callback/compiler channels preserve the original
behavior. Invalid annotations retain their original event arguments so validation
can reject them; attaching provenance must preserve that path.
This diagnosis changes no static policy, recognition behavior or public event fields.
The staged, progressive and recognition repairs preserve those boundaries and
complete public compiler channels. Complete dedicated-family validation replays all seven original contracts through
22 literal cases from a fresh committed input tree without overlays. It preserves
all 42 event origins, actual returned references and complete callback/compiler
channels under the original three seeds. Constructor and custom-callback checks
remain recurring fixture observations; the four Toolbox compiler examples build
parsers without adding four parser executions. Canonical CI gates this family
checkpoint; the complete producer composition is reviewed below.
Executable membership, precise replacement and separately owned runtime defects
remain subsequent work.

The existing behavior consumers can be run with:

```sh
bash tools/project_data_run.sh prove -v -Iperl \
  t/staged_ast_enrichment_perl_contract.t \
  t/progressive_span_dispatch_perl_contract.t \
  t/recognition_transaction_perl_contract.t \
  t/recursive_observation_perl_contract.t
```

### Composition across the seven scanner families

The independent composition check replays the retained literal oracles for all
174 selected contract IDs. The populations remain separate authored inputs;
these numbers are measured **per seed**, rather than adding earlier three-seed totals:

| Retained corpus | Selected contract IDs | Selected events and private origins per seed |
| --- | ---: | ---: |
| Basic | 20 | 49 |
| Pipeline | 19 | 69 |
| Flow | 16 | 49 |
| Legacy | 112 | 227 |
| Staged, progressive and recognition | 7 | 42 |
| Total | 174 | 436 |

All complete prior compiler, callback and origin channels recur unchanged under
seeds 0, 1 and 42. Physical statement frames count the authored source statements;
they are a different population from selected events. The separate method-expression
and CSV probe retains 46 argument frames per seed. These counts describe the
selected syntactic corpus, not every possible program or callback.

A second probe uses one retained contract from each actual dispatcher family.
Each representative repeats equal statement text after Unicode and CRLF. For example:

```text
note("雪😀");
my $dx;  my $dx;
# my_declare_bare: two equal statements, distinct authored scalar intervals
```

The display uses LF line endings; the probe input keeps its actual CRLF bytes.

Its 49 ordered nested pairs include both directions for every pair of families
and seven same-family pairs. The inner scan starts while the outer producer
records its first event. Both scans retain their own original source, event and
argument objects. Complete inner observations equal their unnested baselines;
the outer scan preserves its callback log, selected dispatcher and occurrence order.
Seven further routes throw inside an inner trim callback, catch the exception,
and then finish the outer scan. The outer recorder and caller error state are restored.

The composition probe covers seven representatives; it does not execute nested
scans for all 174 contracts. The original family probes supply the full selected
population independently. An empty first-defined result stops dispatch, and an
opaque result preserves its identity. Neither invents origins from earlier
unselected records. Public scanner events remain `raw` and `args`.

The independent reviewer rejected the initial exception probe because its inner
visits contaminated the outer dispatcher log. The retained corrected instrument
isolates that log without changing product code. The original rejected channels
remain part of the evidence; successful process exits alone do not establish order.

```sh
bash tools/run_python_project_data.sh \
  docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0-review.py
```

This command reviews retained observations and their exact input identities;
it does not launch additional runtime scans. Fresh committed acceptance replays
all 174 selected contract IDs with no runtime overlays. The complete committed
input population is 4,745 regular Git files. All 436 selected events and origins
per seed, complete earlier compiler/callback channels and the representative
nested scans recur unchanged. Exact staged canonical CI gates private provenance
closeout, separately from these runtime and rendered-evidence measurements.

The committed acceptance can be reviewed with:

```sh
bash tools/run_python_project_data.sh \
  docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1-review.py
```

Private source provenance is now independently composed, and the compiler bridge
uses it to select executable lexical membership. A syntactic source origin alone
still does not authorize replacement. Identical literal twins remain a separate
selected-occurrence replacement concern. No arbitrary callback, new helper,
static-policy relaxation or runtime-defect closure follows from this composition.

### Compiler executable source selection

The private selector now distinguishes quoted or pattern data from executable
occurrences using the original scanner's event references and scalar intervals.
It leaves the source and argument objects untouched. For example:

```text
note("set(counter,1)"); set(counter,2); set(counter,1)
# selected original occurrences: set(counter,2), then set(counter,1)
# the quoted first twin remains data
```

A quote opener remains eligible as the start of a real literal receiver:

```text
' 雪 '.trim()
# selected original occurrence: the entire literal-receiver expression
```

Host quote forms, escaped payloads and helper patterns use the existing lexical
contracts. Numeric slash calls keep their existing interpretation. Missing,
foreign or copied event origins grant no inferred source authority; malformed
matching-source intervals fail explicitly. Selection preserves producer order
and the caller's error state.

The compiler's EmitContext callback now uses this selector before Diagnostics
collects helper events. The ordinary scanner API still returns all syntactic
observations. Compiler selection uses actual producer origins and preserves the
original event and argument objects, family order, dependencies and errors.

For example, these Perl lifecycle actions preserve the quoted payload and lower
their real enclosing helpers on native and independently emitted routes:

```spec
Top:: I { return("set(counter, 2)") }
# result: "set(counter, 2)"
```

```spec
Top:: I { return(cat("set(counter, 2)","; if(true); return(inner)")) }
# result: "set(counter, 2); if(true); return(inner)"
```

```spec
Top:: I { return(matches("if(true)", /if\(true\)/)) }
# result: 1
```

Independent corrected committed recurrence verifies the bounded membership
fixtures and callable signatures.
Callable signature delimiters now retain their existing lexical ownership in
the compiler selector. A final parameter named `y`, `tr`, `s`, `q`, `qq`, `qx`,
`qr` or `m` cannot turn the closing signature pipe into a host quote opener.
The same rule applies to fixed and rest parameters; genuine quoted payloads
still keep their own delimiters and data interiors. For example:

```spec
Top:: I { cb={|x,y| return(x) }; return(cb("ok","unused")) }
# result: "ok"
```

The original typed signature, inert body and real return origins are preserved
on native and independently emitted routes. This corrects the undefined `cb`
failure caused by the private membership range scan. The earlier
statement-splitter signature repair still holds. The compiler selector also
requests that exact delimiter ownership in its helper-pattern role query.
Grouped helper patterns inside callable bodies therefore retain their data
interiors, including dot/comma punctuation that otherwise resembles a numeric
slash call. The ordinary scanner and default operand query retain their existing
policy. For example:

```spec
Top:: I { cb={|x,y| return(matches("setcounter,1,x", /(set(counter,1)).*x/)) }; return(cb("ok","unused")) }
# result: 1
```

The regex's `set(counter,1)` is data. Its primitive event is excluded from
compiler membership and the helper/canonical metadata event lists; genuine
assignments and returns retain their source authority and order. A correct
return value alone would not reveal an extra metadata event. Compiler membership
acceptance independently recurs the original membership, signature and grouped-pattern
oracles from committed inputs without overlays. Exact staged canonical proof is
also required before closure. This acceptance does not close exact selected-occurrence replacement, source
comments or compiler-marker diagnostic origin. Mixed equal literal/executable
spellings still need the replacement repair. The original membership population
covers 36 authored sources and five authority/error guards; the subsequent
signature and grouped-pattern populations cover 27 and 72 authored rows,
respectively. These scanner cases do not admit
new executable syntax or establish another backend's behavior.

Selection and replacement have separate source obligations. In current Perl,
an assignment selected from executable source can still replace an earlier
identical spelling inside a literal after preceding statements are lowered:

```spec
Top:: I { quoted='out=matches("x", /x/)'; out=matches("x", /x/); return([quoted,out]) }
# current Perl: handler compilation fails after the quoted payload is rewritten
```

The reverse order preserves the literal and executes the actual assignment:

```spec
Top:: I { out=matches("x", /x/); quoted='out=matches("x", /x/)'; return([quoted,out]) }
# result: ["out=matches(\"x\", /x/)", 1]
```

The typed AST and selected scanner origin distinguish the real occurrence from
its quoted twin. Replacement must retain that distinction as earlier statements
expand; finding equal text in the rewritten action loses it. Repeated assignments,
interleaved equal spellings and data inside lowered expressions need the same
protection. The selected-occurrence repair remains open; successful reverse-order
execution does not establish the failing order or ActionIR readiness.

Perl retains selected original coordinates in a private rewrite invocation through
the helper and canonical event copies. Raw fallback statements and synthesized
value drops receive coordinates only from the canonical splitter's actual returned
array and unchanged entry frames. Copied arrays, foreign source and transformed
entries cannot borrow those coordinates. This channel adds no public event fields
and does not yet translate original intervals across preceding replacements, so
the failing quoted-first example above still needs that separate repair.

An interval-only replacement candidate was rejected before landing. Its quoted-first
cases preserved the literal, but treating every enclosing replacement as consumption
also discarded nested executable helpers that the existing lowerer intentionally
leaves for later canonical residual events. For example:

```text
if(is_nonempty(trim(capture_slice()))); push(items, trim(capture_slice())); endif()
```

The outer conditional and push become Perl expressions while retaining executable
`capture_slice()` calls. Those real calls still require their later helper lowering.
The rejected candidate marked their original intervals missing and left unresolved
host calls in the generated handler. The current runtime replacement still uses
the preceding verified pipeline. A safe replacement repair must preserve explicit
producer-bound authority for those nested continuations while denying generated or
quoted equal spellings and already consumed duplicate events. It must retain
canonical family order and callback behavior; an unrestricted generated-text search
or an overlap waiver cannot provide that distinction.

The private construction foundation now supports explicit generated, copied-source
and consumed-source pieces. A packet belongs to the actual callback, event and
source invocation that produced it; copied objects and equal scalar output cannot
transfer that authority. Ordinary callback results, argument references, scalar
context and exceptions retain their existing behavior. For example, generating
the text `capture_slice()` gives it no original source coordinates, while an
explicit copy records its selected original character interval. Duplicate copies
remain separate fragments so later translation can reject ambiguous continuations.
Producer integration and interval translation remain subsequent work; this
standalone foundation does not change the quoted-first example above.

Input authority and output authority have separate boundaries. The standalone
AST constructor collector now retains the callback's actual returned root and
reachable constructed nodes. Copying public source fields does not copy their
private identity; replacing an equal child or changing a descendant also declines
the retained description. Nested and exceptional captures restore the enclosing
scope. These descriptions grant no original-source coordinates by themselves.
Native parser-input frames now retain original root trims and the CSV producer's
actual argument boundaries for ordinary calls and array literals, including omitted
empty slots. They use character offsets in the actual parser input independently
of the public `base_start`. For `cat("a", "a")` parsed with `base_start => 23`:

| Node | Public AST interval | Native input interval |
| --- | --- | --- |
| Root call | `[23, 36)` | `[0, 13)` |
| First string | `[27, 30)` | `[4, 7)` |
| Second string | `[32, 35)` | `[9, 12)` |

MethodExpr input captures likewise retain the actual callback return and original
argument array within a private scope. For ` cat("a", "a") `, its argument frames
are `[5, 8)` and `[10, 13)` in that original input. Copying a capture or array cannot
select those frames. A changed value loses its own frame; changing the array shape
or method/source fields declines the capture. Returned frame descriptions are
detached. Direct captures preserve callback scalar aliases, while the earlier
frame wrappers retain their existing copied-argument behavior. Nested successes
and exceptions restore the enclosing scope. These input descriptions still require
the selected compiler event before they can authorize original-source copying.

The native frames follow actual returned CSV occurrences, so equal arguments keep
separate positions. Unsupported descendant split paths conservatively decline
frames. A private event-input layer now joins these descriptions to the actual
selected compiler event within its original source invocation. It retains the
actual parser capture, callback, returned construction or argument array, and
parent input grant. Its opaque grant selects that original occurrence; returned
coordinate descriptions are detached and cannot transfer authority.

For example, suppose the original action begins with `λ😀` followed by CRLF,
then the selected event is `cat("a", "a")`. The prefix occupies four Unicode
character positions, including both CR and LF. The private join produces:

| Selected input | Native parser interval | Original action interval |
| --- | --- | --- |
| Root call | `[0, 13)` | `[4, 17)` |
| First string | `[4, 7)` | `[8, 11)` |
| Second string | `[9, 12)` | `[13, 16)` |

Changing the public AST `base_start`, or deliberately collapsing its public
text-search offsets, does not change these original intervals. A nested capture
rebases through its actual parent grant and its own native input offsets. This
also supports retained CSV occurrences with omitted empty slots. An empty input
keeps its ordered zero-width interval after the original leading whitespace.

The grant is validated again whenever it is used. Copying an AST, capture,
argument array or grant description cannot borrow it. Another actual event cannot
borrow the capture even when it has equal text and coordinates. Changing the AST
tree invalidates its dependent grants; changing one MethodExpr argument invalidates
that occurrence while an unchanged neighbor keeps its own frame. Nested equal-source
invocations have distinct identities, and finished scopes leave no global cache.
Opaque AST callback returns keep the native collector's immediate release behavior.

Input copying and consumption remain separate operations. Copying the first string
twice records two copies of `[8, 11)`; it does not select the second equal string.
Generating `"a"` records generated text with no original interval. Transforming the
first string to `"A"` also records generated text. Consuming the first input records
only `[8, 11)`, leaving the second occurrence available. Invalid, stale or foreign
grants preserve ordinary builder text as generated and consume no original source.
Later output composition and interval translation must still adjudicate duplicated
copies and executable continuations.

Nested input grants retain the whole parent chain. For example, in
`set(counter, cat(trim("λ😀"), cat("λ😀", "λ😀")))`, an AST capture can select the
outer `cat`, a MethodExpr capture can select its inner `cat` argument, a CSV
capture can retain that whole argument, and a fresh AST capture can select each
inner string. These joins keep the two equal inner strings distinct. Repeating
the whole `set` expression produces another pair of original occurrences; a
quoted copy of the expression contributes no executable helper event.

Independent input acceptance exercises that chain through actual compiler events.
Changing an intermediate argument or CSV shape invalidates dependent grants even
after selection. An unchanged neighboring branch remains valid. A failed nested
scope restores the enclosing chain, and scope exit removes its authority.

This input composition is verified before production factory and output
integration. It does not change the quoted-first replacement example or establish
complete private Phase0 or mapped/canonical admission.

Private dependency calls preserve native context while isolating publication.
The standalone framework now lets a factory register its actual callback in the
current source and producer scope, returning that same reference. A fresh scope
cannot borrow registrations; finished scopes release their references. Two
factory invocations can return the same actual callback, so invocation count or a
public name cannot establish distinct identities.

Each injected call receives a separate boundary. For example, an opaque callback
can call a producer and return the equal literal `same`. The ordinary result stays
`same`, while its enclosing callback receives no nested publication. The boundary
preserves caller aliases, one invocation, successful error effects and fatal
exception identity:

| Native call context | Ordinary result | Private publication behavior |
| --- | --- | --- |
| Scalar | The actual scalar, reference or undefined result | Separate capture; only an actually registered callback can publish its own scalar-string packet |
| List | The actual returned list | Isolated call with publication disabled |
| Void | The original effects | Isolated call with publication disabled |

A known child captured explicitly retains its own packet. Returning that child's
text does not transfer the packet to its parent; later output builders must
compose the actual retained child capture. Public dependency maps and callback
fields stay unchanged. The framework is verified independently. Current factory integration is
described below; other dependency owners and pipeline activation remain open.

EmitContext now selects definition-owned callback references for contract defaults.
It snapshots the actual native facade references when the module loads. Replacing
`_lower_method_value_expr` under the same public name leaves the replacement
opaque; retaining the original actual reference still selects the native facade.
Copying a contract description with that public name cannot select another callback.
Selection returns the exact original callback and keeps require-only consumers
lazy: it does not load the private emission channel or Trace.

The facade's resolved default factory and owner each receive their own call
boundary. An opaque owner or factory that emits `same` and returns that equal
text cannot donate publication to the facade. Native scalar/list/void behavior,
return and exception identities, once-only effects and the actual factory map
remain unchanged. The existing bridge copies scalar arguments before dispatch,
shares referenced objects, and restores the caller's successful error state;
private isolation preserves those existing rules. Contract construction is
described below; other dependency owners and pipeline activation remain open.

Contracts now isolate injected callbacks through private bindings.
Their public default maps and returned callback fields keep the actual original
references. Private required, optional dropped-value and bare-type bindings
retain and invoke the actual callback with the original argument aliases and
scalar/list/void context. They stay lazy when the emission channel is absent.
Only the built-in EmitContext target can select native defaults, and each actual
reference must also match its retained native definition. A custom target cannot
register defaults merely by aliasing those native references; replacing a native
public name with another callback also leaves that replacement opaque.

For example, an opaque `input_slice(0, 1)` dependency can invoke a producer and
return the equal literal `same`. The contract still returns `same`, with the same
native effect order and scalar call, while its enclosing capture receives no
nested publication. The optional dropped-value fallback and both bare child-call
push paths follow the same rule. Private bindings release retained callbacks
when they are released. Actual lower construction registration is described below; other dependency
owners and pipeline scope activation remain later integration steps.

Built-in lower callbacks now register at their own construction sites.
Each local contract constructor registers the actual callbacks in its own literal
array and returns that same array, its hashes and its callback references. The
staged parse-job and progressive span-dispatch constructors register their own
callbacks too. Catalogue assembly keeps the existing family order.

A substituted factory can return a contract with the same name and an opaque
callback that emits and returns `opaque_literal`. Its ordinary result stays the
same; catalogue assembly does not register it. Copying the metadata cannot borrow
another constructor's authority. A retained callback already selected in the
current scope still has its own actual identity.

Constructor registration lasts only within the actual source and producer scope.
Nested equal-source and producer scopes cannot borrow it; leaving the nested
scope restores the enclosing selection. The producer scope retains its actual
callbacks while eligible and releases those references at exit. Cold construction
does not load the private emission channel or Trace. Registration selects a
callback; later output builders must still publish and explicitly compose actual
packets. Other dependency owners and pipeline activation remain open.

MethodLowering defaults now select their actual native callback references.
The built-in EmitContext target returns its original dependency map and callback
fields. A separate definition-owned catalogue compares each actual callback with
the reference retained when EmitContext loaded. Replacing `_trim_action_ir_value`
under the same public name keeps the replacement in the public map and leaves it
opaque. Retaining the original callback still selects that actual native reference
in the current scope. A custom target that aliases native callbacks keeps those
references but cannot register them through the default factory.

For example, a same-name replacement can emit and return the literal `same`.
Its ordinary value survives; equal text supplies no selected emission packet.
Native-reference selection is scoped to the actual source and producer invocation,
so nested equal-source or producer scopes cannot borrow the enclosing selection.
Cold default construction loads neither the private emission channel nor Trace.
MethodLowering required trim bindings are described below; remaining required and
optional calls precede other owners, pipeline scopes and explicit output composition.
Default selection alone makes no claim that a helper has published a packet.

MethodLowering now isolates trim dependencies in three small value helpers.
Direct shape inference, method-tag normalization and inline switch-case label
normalization retain the actual injected callback through a private lexical
binding. Public dependency maps keep their original callback references. The
binding forwards native scalar/list/void context, argument aliases, ordinary
values, once-only effects and error identities; it stays lazy when the private
emission channel is absent. Existing top-level argument copies stay intact.

For example, an opaque trim callback may publish the generated literal `"tag"`
and return the ordinary atom `tag`. Tag normalization still returns `"tag"`;
the enclosing callback receives no donated publication. Inline switch-case
normalization retains its existing two trim calls for that bare atom. Direct
shape inference still delegates accepted shape values to the method/value owner.
A known child's explicit capture can retain its own packet, while its enclosing
callback receives only the ordinary value. Remaining required function families,
optional/direct dependencies, other owners and pipeline/output composition stay
separate integration steps. This private boundary changes no authored DSL form.

MethodLowering also isolates assignment and declaration inference dependencies.
The private required-callback boundaries cover assignment container inference,
value binding and the retained typed-declaration helper. Their dependency maps
still expose the actual callbacks. A parser may return a shared argument array;
normalization receives that same array and its native mutations remain visible.
Scalar inputs retain the helpers' existing local-copy behavior. Ordinary string,
reference and undefined returns, callback counts and error identities stay intact.

For example, the historical container-inference fixture supplies a retired
aggregate selector to the retained helper and observes the internal `array`
classification. This controlled fixture does not describe current authored syntax.
An injected parser or argument normalizer may publish that same text while it
runs, but the enclosing inference capture cannot inherit its packet. A known
callback receives its own identity boundary; selecting a private wrapper in its
place would incorrectly hide that identity. Value binding likewise preserves
its actual assignment-source result, including a returned reference. The retained
typed-declaration helper keeps its existing split, parse and initializer calls;
this private integration adds no authored declaration syntax. Required missing
or non-CODE dependencies retain their original diagnostics. Inline/block and
other required families, optional/direct calls and pipeline composition remain
separate steps.

Inline if and switch dependencies now use their own private capture boundaries.
The two caller bodies retain their actual parser and argument-normalizer callbacks;
inline `if` also retains the actual condition lowerer. Public dependency maps keep
those references. Required calls preserve native scalar context, callback counts,
ordinary values and error identities. Parser-returned argument arrays remain shared:
normalization sees the actual arrays and preserves their native mutation effects.
The existing scalar argument behavior also remains intact: inline `if` parses a
local branch-scalar copy, while `switch` passes its shared branch scalar.

For example, the existing value forms remain:

```text
return(if(flag, "yes", elseif(other, "other"), else("no")))
return(switch(kind, case(word, "word"), default("other")))
```

An injected branch parser or normalizer may publish text equal to the enclosing
Perl expression while it runs. The caller still returns its ordinary expression;
its parent capture receives no donated packet. Selecting a known actual callback
preserves its identity in its own boundary. Private wrappers cannot substitute for
that identity. This integration changes neither branch selection nor authored
syntax. Branch payload/case/truthiness helpers, block-value dependencies and later
pipeline composition keep their separate responsibilities.

Block component and side-effect dependencies now have separate private captures.
These two required resolvers retain the actual callbacks in their public maps.
The component owner invokes trim, primitive-literal and direct-access lowerers;
the side-effect owner invokes trim, method parsing and argument normalization.
The component's flow callback remains an eagerly validated requirement that this
body never invokes. Validation and invocation are separate contract obligations.

An undefined primitive-literal result still permits direct-access fallback, and
an undefined direct-access result can still reach method-value fallback. An
unrecognized side-effect parse can likewise fall back to component lowering.
A returned reference stays the same reference. These native outcomes remain
intact alongside scalar contexts, copied top-level inputs, callback counts and
error identities. Argument normalization keeps the actual parser-returned array
and its shared mutation effects.

For example, an injected primitive lowerer can return no literal while the next
lowerer supplies the ordinary value expression. Publishing equal text inside
that child does not donate a packet to the enclosing component. A selected known
child retains its own callback identity; its wrapper cannot replace that identity.
Required missing/non-CODE diagnostics remain in force, including the validation-only
flow callback. AST routing and secondary helper behavior are unchanged. Block-value
dependencies and later pipeline composition remain separate steps.

Local-return required callbacks now have separate private capture boundaries.
The parser and argument normalizer retain their actual public callback references.
Normalization receives the parser's shared argument array and both original count
arguments. Existing scalar copies, once-only effects, scalar context and error
identities remain intact. Undefined parses and non-return methods stop before
normalization; missing parser arguments still supply an empty array.

For example, an injected normalizer can publish `VALUE` while returning its actual
argument array. The local-return owner can produce the ordinary payload expression
`VALUE`, but its enclosing capture cannot inherit that child's packet. A selected
actual callback keeps its own identity boundary. After payload lowering, undefined
or empty output is rejected, `0` stays valid, and a leading hash-shaped expression
receives its existing unary `+` prefix. Required missing/non-CODE diagnostics remain
exact. The payload helper, block-value AST routing/fallback and later pipeline
composition keep their separate responsibilities.

Block-value required callbacks now have separate private capture boundaries.
The resolver validates trim, statement splitting, method parsing and argument
normalization. This caller directly invokes the first three; normalization is
validated here and belongs to other helper calls. Public dependency maps retain
the actual callbacks. Scalar context, native invocation counts, scalar copies,
error effects and fatal object identities stay intact. Trimming a raw statement
still receives the actual slot in the array returned by statement splitting,
so its existing mutation effects reach that array.

AST-first dispatch retains its original dependency map for parsing, then copies
the map and adds the bridge guard for AST lowering. A defined, nonempty result
returns immediately, including `0` and an actual reference result. Undefined or
empty AST output falls back to the existing brace-block path. The required
callback captures preserve this order and the guard without changing AST or
secondary-helper semantics.

For example, a statement splitter may publish `do { VALUE }` while returning
its actual statement array. When the block owner also returns the ordinary
expression `do { VALUE }`, its enclosing capture cannot inherit the splitter's
packet. A selected known child keeps its actual identity in its own capture.
This boundary also applies to repeated trim calls; it preserves their native
effects. Required missing/non-CODE diagnostics remain exact, including the
locally uninvoked normalizer.

Existing block-local returns keep their control flow. With explicit helper
results, a nonfinal return sets the generated done flag and skips later side
effects; an ordinary final return follows earlier side effects. These capture
boundaries add no block syntax or return semantics. Complete AST/helper behavior,
other required owners and later pipeline composition retain their separate
verification responsibilities.

Guarded hash-index key callbacks now have private capture boundaries.
The scalar-held hash-index assignment owner keeps its existing validation order:
a nonmatching AST node or invalid target name stops before dependency lookup.
A valid node requires the key-lowering callback before extracting key/value
source. When the source helper has no nonempty expression, the existing node
source fallback remains available. Missing/non-CODE callback diagnostics stay
exact.

The actual key callback receives a local copy of the selected key-source scalar.
Mutating that argument retains its native local effect without changing the AST
node's source field. Public dependency maps keep the actual callback reference;
scalar context, once-only effects, ordinary values and error identities remain
intact. A child may publish `VALUE` while returning its ordinary lowered key.
Even when the enclosing assignment lowerer also produces `VALUE`, its capture
cannot inherit that child's packet. Selecting a known child retains that actual
callback's own identity boundary.

Source extraction, mutation-value lowering and final binding assembly retain
their existing responsibilities. Bounded caller controls preserve source fallback,
undefined/empty rejection and zero/reference handoff without admitting complete
secondary helpers or new AST grammar. Other guarded AST owners and pipeline
composition remain separate verification steps; this adds no assignment syntax.

AST call-statement required callbacks now have private capture boundaries.
The existing statement owner retains six callback roles. Normalization and trim
are validated eagerly after the AST call/method/argument guards. The additional
requirements retain their branch order:

| Statement path | Additional required callbacks and timing |
| --- | --- |
| `return(...)` | Trim is already validated; tagged returns trim the label and may trim payload fallbacks. |
| `return_undef()` | Normalization receives the actual argument array and the existing zero-argument count contract. |
| `set(...)` | Normalization keeps its two-argument count contract; assignment lowering retains its existing separate responsibility. |
| `set_key(...)` | Hash-symbol extraction and key lowering are required only after successful three-argument normalization. |
| `push(...)` | Array-symbol extraction is required before the arity guard; primitive lowering is required after arity and scoped-target guards. |

For example, an invalid `push` arity still diagnoses a missing array extractor,
while it never requires the primitive lowerer. Rejected `set_key` normalization
never requires the hash/key callbacks. Capturing dependencies preserves these
existing outcomes and exact missing/non-CODE diagnostics.

Normalizer calls keep the actual source-helper argument array. Trim calls keep
its scalar-slot aliases; a scoped push first trims that original array and then
uses the existing copied effective-argument array. Hash/key/array/primitive calls
receive the owner's local scalar copies. Tagged-return payload helpers retain
the original array-slice aliases. These distinctions preserve native mutation,
call order, scalar context, public callback references and error identities.
Each required child gets its own capture: publishing text equal to the final
statement cannot donate a packet to the enclosing statement lowerer. Selecting
a known child preserves that actual callback's identity. Explicit secondary
helper controls verify the bounded caller paths; complete helpers, AST grammar,
optional assignment callbacks and pipeline composition retain separate owners.
This introduces no statement syntax or new helper semantics.

AST array-end symbol extraction now has a private capture boundary.
The existing `push_back`, `push_front`, `pop_back` and `pop_front` statement
owner still checks the fluent node, single method call and method name first.
Push requires one argument and pop requires none; invalid arity reaches the
existing unsupported-helper result before a missing dependency is diagnosed.
A valid arity requires the actual array-symbol extractor before reading the
receiver source, with the same missing/non-CODE diagnostic.

The extractor receives the owner's local receiver scalar copy. If a custom
extractor changes `items` to `items!`, the AST source field stays unchanged,
while later binding lookup sees `items!`. If that callback returns undefined,
the changed spelling no longer permits the bare-name fallback. An undefined
result without that mutation still falls back from `items` to the same named
target. Private capture preserves these native outcomes rather than normalizing
the callback's effects away.

Each extractor call has its own capture. An opaque callback may publish and
return text equal to the final statement without transferring its packet to
the enclosing lowerer; selecting a known child retains that actual callback's
identity. Public dependency maps, scalar context, fatal objects, host
push/unshift/pop/shift fallback text and direct receiver-guard results stay
unchanged. Controlled secondary helpers verify the bounded owner paths;
complete helper/AST grammar, other callback owners and pipeline composition
remain separately owned. The public array mutation contract still yields an
independent updated array and discards the removed element for pop operations.

AST assignment key lowering now has a private capture boundary.
The assignment owner uses its required key callback only on the hash-index
fallback. It first checks the node and expected kind, validates the target name,
and tries the existing scalar-held assignment helper. A nonempty helper result,
including `0`, bypasses the callback. Otherwise it extracts both key and value
sources and rejects undefined or empty sources before requiring the key callback.
Scalar assignment, array append and delegated nested-access branches do not
validate this unreachable dependency. Missing/non-CODE diagnostics remain exact
when the fallback actually reaches it.

The callback receives a local key-source scalar copy. For example, changing
`key` to `key!` inside that callback leaves the AST key source unchanged; its
ordinary returned key still supplies the hash-write text. Undefined or empty
returned keys stop before payload lowering, while `0` remains valid. Public
dependency maps keep the actual callback, scalar context and fatal objects.
An opaque child publishing `VALUE` cannot donate its packet when the enclosing
guard also returns `VALUE`; selecting a known child uses its actual identity.

The existing guard first rejects an empty inner expression. An untracked target
returns the inner expression directly. A tracked target needs an original span
and receives a new target-only span: target `meta` at original start `17` produces
`{start => 17, end => 21}`, leaving the original span untouched. The guard's
undefined, empty, zero or reference result returns directly. Existing variable
source selection still prefers a nonempty function-scalar read and otherwise
falls back to the AST source. Explicit secondary-helper controls verify these
owner paths; complete helpers, AST grammar, other callback owners and later
pipeline composition retain separate admission. This adds no assignment syntax
or public mutation semantics.

Main method/value required callbacks now have separate private capture boundaries.
The resolver validates its eager callbacks before checking whether the input is
undefined or empty. This includes the locally unused scalar-container inference
binding: a missing callback still produces its existing diagnostic even when no
expression will be lowered. The initializer callback remains lazy. For example,
a synthetic array-set AST targeting `meta` needs it after the target and shape
checks, whereas an early primitive result or a mismatched aggregate shape does
not reach it.
These are compiler dependency contracts; they introduce no authored syntax.

The local AST hash-assignment adapter re-acquires the key callback after its
source and scalar-held fallback checks. Replacing that callback in the public
dependency map after eager acquisition therefore affects this AST path. The
legacy `has_key` path keeps its earlier selected callback. Each acquisition
preserves that existing selection rule and validates the actual selected CODE
reference. The public map retains the caller's callbacks.

Aliases depend on the actual adapter. Argument normalization receives the parser's
returned array, so mutating that array remains visible to its caller. Trim can
receive a parser argument slot, a split statement slot or an array-constructor
CSV slot directly. In contrast, shape-member lowering copies a CSV element
before trimming it: changing that local scalar leaves the returned CSV array
unchanged. Array/hash symbol adapters also keep their existing local receiver
copies. A declaration initializer receives a read-only container-kind literal
(`array` or `hash`) and a writable local source copy. Mutating the latter leaves
the AST source field unchanged. The final array-pipeline callback receives the
actual source-span reference.

Callback capture preserves scalar context, call order, successful error effects,
fatal exception objects, undefined/empty/zero results and these alias distinctions.
For example, primitive lowering accepts a defined empty result, while the AST
key and initializer paths reject empty results and accept `0`. A child may
publish text equal to the enclosing result without donating its packet to that
parent. Selecting a known child uses the actual callback's identity. Explicit
secondary-helper controls verify these bounded owner paths; complete helper and
AST language behavior, optional/direct callbacks, output composition and mapped
replacement retain separate admission.

Bare-source and mutation-slot required callbacks now have separate private capture boundaries.
The bare-source owner requires trim; the mutation-slot owner requires trim and
primitive-literal lowering. Both validate those callbacks before rejecting an
undefined input. Each callback receives the existing local source scalar copy,
so changing that argument leaves the caller's original source unchanged. Public
dependency maps keep the actual callbacks, and scalar context, successful error
effects and fatal exception objects retain their native behavior.

Bare-source classification still rejects reserved literals and engine locals.
For an ordinary name such as `items`, remembered array kind produces `[@items]`,
hash kind produces `{%items}`, and other or unknown kind produces `$items` in
the Perl backend. The optional kind callback receives the existing local name
slot. A retired `:items` spelling still reaches its migration diagnostic.

Mutation values try bare-source lowering before primitive lowering. A nonempty
bare result, including `0`, returns immediately; a defined primitive result,
including an empty string, also returns immediately. An unclaimed identifier
stops before flow and method fallback. A trimmed numeric string `0` continues
through those fallbacks if the controlled earlier lowerers return undefined.
Method fallback rejects empty results, accepts `0`, and otherwise keeps the
current trimmed source. A legacy flow callback's source mutation remains visible
to that fallback.

The legacy optional flow branch selects an existing package callback rather than
the public dependency map's same-named entry. Required callback isolation preserves
that selection; isolating this direct callback remains separate work. Opaque and
known required children each have their own capture, so equal returned text cannot
transfer their publication to a parent. Explicit secondary-helper controls bound
these checks; they do not admit complete helper or language behavior.

Generalized-return required callbacks now have separate private capture boundaries.
The payload owner rejects an undefined input before requiring trim. The statement
owner requires its parser before trying the AST fast path, even when that fast
path returns immediately; it acquires trim only for the labelled multi-argument
path. Required validation keeps its original diagnostic and selection order.
Public dependency maps still hold the actual callbacks. Local source scalar
copies, scalar context, successful error effects and fatal exception objects
retain their native behavior.

The labelled fallback passes actual parser-array slots to trim: both the label
and a payload whose lowering is empty or undefined can be mutated through those
slots. For example, trimming `Node` and `payload` may leave the parser array as
`["Node!", "payload!"]` while returned pre-mutation values produce
`return ['?Node:',  payload]`. This internal Perl example describes alias behavior,
not new DSL syntax. Labels must match the existing word-character rule; `0` is
valid. Nonempty payload results include `0`, while empty or undefined results
trigger the existing fallback or rejection.

Payload lowering keeps its AST/method, bare-read and legacy raw-helper order.
The raw compatibility rewrite still stops when stable or after 64 passes; that
limit does not admit arbitrary host expressions as typed ActionIR. Required
children cannot donate publication to the enclosing return, even if their text
is equal, and capture uses the selected actual callback's identity. Secondary
helpers remain explicit controls in this bounded proof; complete helper/AST
behavior and optional/direct callbacks retain separate admission.

Assignment required callbacks now have separate private capture boundaries.
The `set(target, source)` lowering owner validates its three symbol extractors,
assignment-source callback, initializer callback and trim callback before
selecting a target branch. Both operator owners require trim before checking
their input. These checks preserve the existing missing-callback diagnostic and
leave the public dependency map holding the actual callbacks.

For example, the existing public forms `set(counter, 1)`, `counter = 1` and
`items += 1` still lower successfully. The scalar and append operators first try
their existing AST path. Their compatibility regex fallback trims the complete
expression and then its captured right-hand side, using two distinct local
scalar slots. The value helper receives that same right-hand-side slot after
the trim result replaces any mutation made during the callback. This preserves
native Perl argument aliases, scalar context, successful error effects and fatal
exception identity.

The private legacy aggregate branches pass a readonly literal kind (`array` or
`hash`) and a writable local copy of the source to the initializer callback.
Callback mutation may change that local source; it cannot change the caller's
source or the kind literal. The symbol extractors share the local target slot
previously passed to trim. Private scalar and aggregate branches accept defined
empty results where their existing guards do so; operator and bare-binding paths
require nonempty results and continue to accept the string `0`.

These private branches do not make removed public selectors valid:
`set(array(items), 1)` still reports
`aggregate_selector_removed surface=array identifier=items replacement=items`,
and `set(hash(meta), 1)` reports the corresponding hash diagnostic. The optional
kind callback for scalar-held wrappers keeps its existing selection and local
name alias. Its isolation remains separate work.

Opaque and known required children cannot transfer their publication to an
enclosing assignment with equal result text. Known-child capture uses the
selected actual callback's identity. Secondary AST, value, tracked-assignment,
push and migration helpers are explicit controls in this bounded verification;
complete helper and language admission remain separate.

Set-key required callbacks now have separate private capture boundaries.
The statement owner requires its parser, optional-scope argument normalizer,
hash-symbol extractor, key lowerer and trim callback before the AST fast path.
The normalizer receives the actual parser argument array and readonly literal
arity bounds `3, 3`. Its selected result supplies the target, key and value slots
that trim receives. All three trim calls occur before the nonempty guards, so a
failed first trim still preserves the native effects of the later trim calls.

Trim can mutate those actual normalized-array slots. Its returned values become
separate local target, key and value scalars. Hash extraction and the later
uniform-binding helper share the local target; key lowering receives the local
key, and mutation-value lowering receives the local value. A callback's local
target mutation therefore reaches the binding helper while leaving the earlier
normalized target slot unchanged. Public dependency maps keep actual callbacks,
and native scalar context, successful error effects and fatal objects survive.

The existing public distinction also remains visible in generated code:
`set_key(meta, "key", 1)` lowers to a binding-runtime index update, while
`return(set_key(meta, "key", 1))` emits the pure helper's copied hash value.
`set_key(hash(meta), "key", 1)` retains the removed-selector diagnostic.
These observations do not add a new assignment form or expand accepted arity.

Known and opaque required children cannot donate equal-text publication to the
enclosing statement; known capture uses the actual selected callback identity.
Secondary AST, mutation-value, uniform-target and index-assembly helpers are
explicit controls in this proof. Their complete behavior, optional/direct
callbacks and broader language admission remain separate.

Push required callbacks now have separate private capture boundaries.
The statement owner acquires its parser, array-symbol extractor, trim callback
and primitive-literal callback before the AST fast path. Required validation
keeps the existing diagnostic and the public dependency map retains actual
callbacks. Scalar context, successful error effects and fatal exception identity
remain native.

The compatibility path treats two and three arguments differently. Two arguments
reuse the parser's actual argument array. Three arguments first trim and validate
the scoped target, then copy the selected target and value into a separate
array. Later trim effects mutate those copies. The target and value are each
trimmed for ambiguity checks and again for final lowering; the three-argument
path also has its initial scoped-target trim. Extractors and primitive lowering
receive local scalar copies. The final extractor and uniform-binding helper
share the same local target.

For an internal callback that returns the incoming text and appends `!` to its
argument, a two-argument raw array `["legacy target", "value expression"]` ends
as `["legacy target!!", "value expression!!"]`. Its three-argument counterpart
ends as `["scope", "legacy target!", "value expression"]`; the later effects
belong to the separate effective array. These are Perl alias examples, not new
DSL syntax. Empty or undefined guard results keep their existing rejection or
fallback; `0` remains nonempty where that guard accepts it.

Existing child/index precedence remains visible: `push(items, 1)` calls the
child rule `items` and selects element `1` for the current accumulator.
`push(Top, items, 1)` calls `Top` and selects element `1` for `items`.
Quoted-value forms such as `push(items, "v")` and `push(Top, items, "v")`
retain their explicit value append lowering. Two bare names retain the existing
rule-handler-or-value decision. Removed aggregate selectors still diagnose.
These are generated-source observations; this private change adds no language
form or new execution admission.

Known and opaque required children cannot donate equal-text publication to the
enclosing push, and known capture uses the selected actual callback identity.
Secondary AST, value, binding, push-assembly and ambiguity helpers are explicit
controls in this proof. Their complete behavior, optional/direct callbacks and
broader language admission remain separate.

Regex-substitution and undefined-return required callbacks now have separate
private capture boundaries. Substitution eagerly requires scalar extraction,
literal-delimiter stripping and trim. Its target, pattern, replacement and
flags are local scalar copies. It strips both pattern and replacement before
checking either result for undefined; empty strings and `0` retain the existing
defined-only acceptance. Pattern and replacement use distinct local slots.

Defined flags reach trim through a writable local slot. Missing flags instead
supply a readonly empty literal. The trim result replaces the local flags value;
an undefined result falls back to empty flags. For example, an internal trim
callback that returns the incoming `g` and then mutates its argument still emits
`$SCALAR_SLOT =~ s{PATTERN}{REPLACEMENT}g`. The caller's flags stay unchanged.
This is a Perl argument-alias example, not a new regex syntax contract.

The undefined-return owner eagerly requires parser and optional-scope normalizer
before its AST fast path. Its compatibility path passes the actual parser
argument array with readonly literal bounds `0, 0`. A supplied normalizer can
mutate that array even when it then returns undefined or throws. A distinct
normalizer result retains its own identity. These controlled callbacks describe
the private seam; they do not bypass public argument validation.

Existing public generated forms remain: `regex_subst(text, /A/, "X", g)` and
`substr(text, /A/, "X", g)` emit `$text =~ s{A}{X}g`; `return_undef()` and
`return_undef(Top)` emit `return undef`. These are source observations, not new
execution or cross-backend admissions. Quoted flags, callback statement routing
and active-receiver protection remain separately tracked repairs under
`SESSION-STARTUP-READING.59`.

Known and opaque required children cannot donate equal-text publication to either
enclosing owner; known capture uses the actual selected callback identity. The
undefined-return AST helper is an explicit control in this bounded proof. Public
dependency maps, native scalar context, successful error effects and fatal
exception identity stay unchanged. Complete helper/AST/language, optional/direct
callbacks and broader private admission remain separate.

Legacy hash receiver normalization selects its optional kind callback locally.
It retains the caller's actual `bare_symbol_kind` callback before trimming the
expression. A missing or non-CODE callback supplies an undefined kind. For
example, a known hash receiver `meta.copy()` normalizes to `copy(meta)`; a known
array receiver leaves hash normalization without a result. A hash-specific next
method can still establish the hash family when the receiver kind is unknown.
Changing the caller's dependency map during trim does not replace the callback
already selected for this invocation.

The kind callback receives the original Perl match-variable argument. Its clear
`Internals::SvREADONLY` flag does not mean that writes are permitted: assigning
through that alias still raises Perl's read-only-value error. Copying the argument
into a lexical scalar would change that behavior. The compiler preserves the
actual alias, scalar context, once-only effects and fatal-object identity.
The callback has its own private capture, so an opaque child cannot donate
equal-text publication to the enclosing normalizer. A known child retains its
actual callback identity, while the public dependency map retains the caller's
original reference.

Required array receiver callbacks retain their native argument boundaries.
The normalizer acquires trim and method parsing before trimming or checking the
input. A missing or non-CODE callback keeps the existing required-dependency
diagnostic. Replacing the parser entry from a trim callback does not change the
parser already selected for that invocation. Public dependency maps retain
their actual references.

Trim receives local scalar copies and the splitter's actual substring arguments.
These are different alias boundaries despite their clear readonly flags. For
example, a controlled trim callback that returns its incoming text and appends
`!` through its argument changes the splitter's receiver substring. The later
call text becomes `.sorted()` instead of `sorted()`, and normalization declines.
The caller's original `items.sorted()` string stays unchanged. Copying every
callback argument would suppress that native effect. The parser receives its
local call-expression slot; its ordinary mutation remains local.

Each required callback has a separate private emission capture. Opaque children
cannot donate equal-text publication to the enclosing normalizer; known children
retain their actual callback identity. Ordinary values, scalar context, effects,
successful error state, fatal objects, source/arity/family guards and require-only
lazy loading stay native. Optional/direct dependencies and complete helper,
AST, language and private-pipeline admission remain separate work.

Required number and string receiver callbacks retain the same eager selection
and separate child capture. Both normalizers require trim and method parsing
before their input guards. Their splitter keeps actual substring aliases, and
replacing the parser in the public map during trim cannot replace the selected
callback. Number chains such as `score.abs().add(2)` still compose numeric
helpers; string chains such as `raw.trim().lowercase()` still compose string
helpers. This private capture change preserves existing method families,
arity checks and terminal continuation behavior.

The string normalizer writes `__source_expr` on the actual parser-returned call
hash. For example, a controlled parser that recognizes `trim()` and then appends
`!` through its argument returns the same call object, annotated with `trim()!`.
Copying callback arguments would lose that annotation effect. If a controlled
parser returns one shared call object for `raw.trim().lowercase()`, both retained
references see its final `lowercase()` annotation. These injection examples
describe compiler callback contracts; they introduce no new DSL methods.
Number callbacks likewise retain their actual returned references. Both owners
preserve ordinary values, contexts, errors, fatal-object identity, public maps
and require-only lazy loading while isolating opaque publication.

Required hash receiver callbacks retain eager trim/parser selection and separate
child capture. Both required roles are validated before any trim or input guard;
replacing the parser in the dependency map during trim leaves the selected
callback intact. Missing/non-CODE dependencies retain the existing diagnostic.
Ordinary values, scalar contexts, error state, fatal objects and public callback
references remain native, and require-only calls keep SourceEmissions lazy.

Hash trim callbacks receive actual splitter substring arguments. A controlled
trim that returns its incoming text and appends `!` through the argument makes
the later `sorted_keys()` call text become `.sorted_keys()`, which is declined;
the caller's `meta.sorted_keys()` remains unchanged. Parser-returned hash objects
retain their actual references without a source annotation. For example, an
injected parser returning one shared `pick_keys(a)` object for both calls in
`meta.pick_keys(a).drop_keys(b)` produces `pick_keys(pick_keys(meta, a), a)`.
These are callback-injection contracts, not new language features.

Existing hash/array transitions remain intact: `meta.sorted_keys().join_values("-")`
normalizes to `join_values("-", sorted_keys(meta))`, and
`meta.sorted_values().sum()` normalizes to `sum(sorted_values(meta))`.
Copy selection still uses the established explicit receiver, remembered kind
and next-family guards; terminal continuations and wrong arities are declined.
The required callback capture prevents opaque child publication from reaching
the enclosing normalizer and retains known-child authority by actual identity.
Optional/direct dependencies and broader private/canonical admission remain
separately owned.

Whitespace-only expressions have an ordered zero-width interval after leading
whitespace. For example, `parse_action_expr(q{  }, {base_start => 7})` returns an
empty raw node with `{start => 9, end => 9}`; the native parser-input frame is
`[2, 2)`. An empty or undefined input at the same base gives `[7, 7)`.
The statement parser uses the same rule. Leading and trailing trim cannot consume
the same characters twice. Nonempty input retains its original trimmed interval,
and whitespace inside a quoted literal remains part of the literal. This corrects
the earlier reversed public interval while keeping parser-relative descriptions
separate from compiler-event authority.

Unresolved-helper text scans can still count the preserved helper spelling in a
literal. A correct returned value therefore does not establish ActionIR readiness.
For example, the repaired `set(counter, 2)` literal retains an unresolved-helper
count until the separate diagnostic-origin repair distinguishes data from blockers.

Numeric slash calls keep the action splitter's existing newline boundary. The
selector applies the existing call discriminator to the original source through
that boundary, so a following host quote cannot supply a phantom pattern end:

```text
out = /(14,2)
rx = q/;/; return(out)
# existing isolated Perl compatibility lowering returns 7
```

The same compatibility control retains `qr/}/`, `q|/;|` and `s/a;b/c;d/` after
LF or CRLF. Recognized helper pattern roles still take precedence. This preserves
the existing Perl compatibility route; it does not admit host quotes as portable
DSL syntax or change assignment/regex precedence.

```sh
bash tools/project_data_run.sh prove -v -Iperl \
  t/actionir_executable_source_membership.t \
  t/actionir_compiler_source_membership.t
```

### Original method argument boundaries

The current method-expression parser returns the original trimmed expression
and an array of trimmed, nonempty arguments. It keeps the exact object returned
by its CSV splitter. Empty slots disappear from that array:

```text
 call( same, ,same )
# source: call( same, ,same )
# args: [same, same]
# authored scalar argument intervals in the original input: [7, 11), [13, 17)
```

Those intervals describe the original input. The private parser bridge now
publishes an aligned argument-frame sidecar without changing the ordinary result. Matching equal argument strings after parsing
cannot distinguish their occurrences. Coordinates must be captured at the actual
CSV piece boundaries, then translated through leading expression whitespace and
the opening parenthesis. A returned argument index is not the original CSV slot
index when empty slots were dropped.

Regex helper context also matters:

```text
matches("x,雪", /(x),雪/imu)
# args: ["x,雪", /(x),雪/imu]
filter_match(/(x),雪/imu)  # receiver parser context
# args: [/(x),雪/imu]
```

The structural helper-pattern view preserves character offsets and original
CR/LF; returned values come from the original source. Receiver calls pass their
context to CSV splitting. The private bridge preserves all ordinary callback results and references,
including copied, changed, foreign-source and opaque results. It requires the
actual canonical returned parser hash and argument array plus the original source
before lending coordinates. Copied or foreign-source results receive no frames;
a changed entry receives undef while an unchanged neighbor retains its occurrence.
Nested calls and exceptions retain their existing behavior. Recursive Flow consumers now use these parser frames while keeping marker-first
traversal followed by inline branches. Source provenance remains syntactic
observation; executable membership is a separate contract.

The CSV bridge returns its original array under `arguments`; the parser bridge
returns its original hash under `call`. Both keep metadata in `source_frames`:

```perl
my $result = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames(
    $default_parse, ' call( same, ,same )'
);
# call.args: [same, same]
# source_frames spans: [7, 11), [13, 17)
```

CSV frames are relative to its original payload; parser frames are relative to
its full original expression. Empty slots affect the source coordinates but do
not add returned arguments or frames. Unknown/opaque results stay unchanged,
nested private calls restore the enclosing recorder, and original callback
exceptions and caller error state are preserved. Ordinary parser and CSV calls
publish no new fields or callbacks.

### CanonicalEvents

`ActionIR::CanonicalEvents` records recognized current helper calls as ActionIR event records. Each event carries a contract ID, resolved arguments, and metadata needed by the later lowering stages. Deleted helper names are not canonicalized into replacement events. Raw-Perl compatibility passthroughs may still be classified for migration reporting, but their descriptor-facing diagnostic labels stay neutral instead of reusing retired helper names.

### RewritePipeline

`ActionIR::RewritePipeline` glues the scan, classify, and lower phases together. It orchestrates the flow: scan for contracts, split statements, produce canonical events, and dispatch to the appropriate lowering owner for each event.

At `debug` trace level, the Perl reference pipeline reports these stages with
`actionir:<owner>:<phase>:<label>:<decision>` decisions. That trace can show scanner helper-event discovery,
canonical queue matches or RAW_PERL fallbacks, unresolved helper diagnostics, rewrite-rule construction, compact
flow/value/array/declaration/control-flow lowering choices, source-span or contract skips, normal statement
rewrites, unmatched helper events, implicit attached-if closure insertion, and `MethodLowering` helper-family,
assignment/mutation, receiver-chain, AST-vs-string fallback, and unsupported-helper decisions.

The planned Perl reference compile/ActionIR owner trace coverage is closed through MethodLowering; the remaining
trace work is cross-variant parity rather than another known opaque ActionIR owner.

### Lowering owners

Each contract family has a dedicated lowering owner:

- `FlowExpr` — flow-expression helpers (method chains, fluent continuations)
- `ValueExpr` — value construction (bare scalar reads, `array(...)`, `hash(...)`)
- `ControlFlow` — structured control flow (`if/elseif/else/endif`, `switch/case/default/endswitch`)
- `MethodLowering` — method-like helper lowering to Perl code
- `DeclareMethod` — current `set(...)` assignment lowering and backend declaration initializer helpers
- `ArrayPipeline` — array pipeline operations (filter, map, sort, etc.)

### Contracts catalog

`ActionIR::Contracts` is the contract catalog. It defines supported helper surfaces: their names, ActionIR node types, diagnostic identities, and unresolved patterns (the templates matched before lowering resolves them). The main contract families are:

| Family | Purpose |
| --- | --- |
| capture_and_cursor | Boundary capture, mark, cursor-reader, and explicit cursor-control helpers |
| call_and_dispatch | Rule dispatch and call helpers |
| return | Return value construction |
| passthrough_ir | Backend-owned pass-through surfaces |
| emit_and_declare | Declaration and emit helpers |
| array_pipeline | Array pipeline operations |
| flow_control | Structured control flow |
| assignment_and_regex | Assignment and regex-slot helpers |

Understanding the pipeline matters because it explains why a helper call in a `.spec` rule is not just a string substitution — it passes through discovery, normalization, classification, and lowering before becoming emitted backend code.

## Deeper reference

The repo-root ActionIR guides are the exhaustive working references while this book grows toward absorbing that surface:

- `USER_GUIDE_ActionIR_Contracts.md` — full contract catalog (158 contracts across 8 families)
- `USER_GUIDE_ActionIR_MethodLowering.md` — method lowering pipeline
- `USER_GUIDE_ActionIR_EmittedPerlReference.md` — emitted Perl for every supported helper
- `USER_GUIDE_RuleModesAndSplit.md` — rule modes and split-boundary details

These guides go deeper than the book chapters and include exact emitted-Perl shapes for compatibility and migration work.

## Canonical event order and execution

A descriptor event list is compiler telemetry, not a trace of actions executed at runtime.
Top-level statements keep their authored order and existing exclusive ownership. Remaining
helper occurrences now follow the helper scan input, including equal-text occurrences
interleaved across raw keys. Consumed occurrences and alternatives removed by an exclusive
statement are not replayed. The internal queue bookkeeping adds no public event fields.

Helper scans are grouped by contract precedence, with occurrences retained within each
contract. This is stable scan provenance, not global lexical source order. For example,
`return("a")`, `return("b")`, then `return("a")` are three occurrences. Sorting distinct raw
keys or grouping all equal text together would lose that interleaving.

Equal spelling also cannot establish which source occurrence produced an event.
The following current Perl probe has two genuine return calls. The inner text is
a string value and is consumed as part of the outer scanner match:

```spec
Top:: I { return('return("x")'); return("x") }
```

Pairing each event with its earliest equal source text would attach the second
real return to the inner string and incorrectly discard it. Simply skipping
quoted positions has a different failure:

```spec
Top:: I { text="set(counter,1)"; set(counter,2); set(counter,1); return(counter) }
```

The current set scanner reports the quoted `set(counter,1)` and both real calls.
A raw-key mapper that skips the string can assign the first false event to the
later real twin, keeping `set(counter,1)` before `set(counter,2)` and losing the
last event. The independent source oracle requires the real calls in `2`, then
`1` order. Both candidate mappings were executed against captured public helper
arrays and failed their occurrence oracles; they are not compiler repairs.

The pending quote repair therefore needs source occurrence provenance from
the scanner, followed by executable-source selection and exact replacement.
Original argument and literal bytes must remain available to typed parsing and
lowering. The preserved diagnostic fixture currently fails eleven of thirteen
groups; the genuine unsupported/raw and opaque-return guards pass. This is a
complete failing baseline, not acceptance of the repaired compiler.

The first provenance step now records original scalar source positions privately
for the Perl `return_general`, `set_value`, and `if_flow` scanners. It keeps the
original event object and arguments; the position records remain separate from
public descriptor events. For the standalone action strings inside the two examples
above, without their surrounding framing spaces, return matches start at `0, 23`
and set matches at `6, 23, 39`. The quoted set at `6` is deliberately still recorded
as a syntactic match at this stage. Provenance identifies where a scanner matched;
the subsequent membership repair decides whether that source is executable.

The private collector follows the selected event array by object identity, retains
empty and opaque dispatcher returns, isolates nested invocations, and checks that
each recorded scalar span retrieves its exact original raw source. Ordinary public
scans retain their existing fields and order. Remaining producer families and recursive
frames, quoted-source selection, exact replacement, and final recurring acceptance
are separate steps. This private channel does not repair the quoted-value or readiness
defects described below.

Nine basic regex contracts also retain their full-input scalar match positions in
that private channel: the two call assignments, indexed and unindexed built-in
child pushes, `return call(...)`, and `entry_slot()`, `gap_span()`, `gap_text()`,
`gap_kind()`. This includes the existing syntactic matches inside strings; none
of those matches has yet been classified as executable. Public raw text, arguments,
lowering and event order remain unchanged. The eleven basic statement scans now use their own original splitter frames.

The statement splitter preserves comments and quoted punctuation in its returned
text. Its default trim callback removes whitespace at the edges. For example,
this action string produces a quoted assignment and two separate declarations;
the equal declaration text inside the string is not a declaration statement:

```perl
text="my $x"; my $x; my $x;
```

A top-level line break can end a statement after a comment. This input produces
`my #inside` and `$x`, neither recognized by the bare declaration contract:

```perl
my #inside
 $x;
```

Inside parentheses the same line break remains part of one statement:

```perl
return (7 #inside
);
```

These are splitter/compiler inspection examples, not execution recommendations.
Twenty-two authored inputs, including repeated examples for all eleven basic
statement contracts, were inspected under three hash seeds. Each returned
statement matches an independently authored contiguous scalar interval in the
original input, including Unicode whitespace and CRLF. That bounded observation
supports producer-side statement spans; it does not establish every possible
host-language input or transformation by a custom dependency callback. These
statement producers had zero private origins at the diagnostic boundary. Their implemented
hooks retain the existing five callbacks and capture occurrence identity at the splitter,
without searching the source for equal raw strings. Comment classification, executable
membership and residual replacement remain subsequent work.

The private splitter now publishes an aligned `source_frames` sidecar for its
exact returned array. It captures original boundaries during splitting and checks
each trimmed value against that original scalar interval. The callback still runs
once with its original arguments, and the returned array stays the same object.
A copied or opaque callback return receives no borrowed frames. A changed array
entry or custom interior transformation keeps its result and receives no invented
frame; a source supplied as a reference also receives no scalar frame. Nested
private calls restore the enclosing collector, and callback errors propagate.

For compiler diagnostics, with `$default_split` obtained from the ordinary
Scanner dependency bundle:

```perl
my $result = LinkedSpec::ActionIR::StatementSplit::Core::_split_with_source_frames(
    $default_split, 'my $x; my $x;'
);
# source_frames spans: [0, 5), [7, 12)
```

The preserved 28-group fixture fails 25 groups before this private capture and
passes all 28 afterward. Sixty-six source/seed before-and-after compiler records
remain identical, while 177 statement frames match the independent original
scalar intervals. Initial runs and their actual fixture/source boundaries remain
recoverable. This is a private compiler probe.

All eleven basic statement event producers now connect those aligned frames to the
original event objects when private provenance recording is active. Each producer
captures the occurrence index before filtering a statement, so ignored comments and
quoted assignments do not shift later positions. It retains the original raw text,
argument objects, recognition expressions, event order and callback effects. Ordinary
scans call the existing splitter directly; they add no public source fields.

The covered contracts are:

| Contract | Existing statement family |
| --- | --- |
| `return_bare` | Bare return and payload |
| `exit_bare` | Bare exit and payload |
| `linecount_prefix_newline_matches` | Newline matches in a prefix substring |
| `print_capture_substr` | Print the current captured substring |
| `my_declare_bare` | Bare scalar, array or hash declaration |
| `assign_match_my` | Assign a capture/match scalar |
| `destructure_imatch_list_my` | Destructure the match list |
| `regex_subst_assignment` | Regex substitution assignment |
| `next_bare` | Named loop continuation |
| `ref_field_assign` | Assignment from a referenced field path |
| `position_tracking` | Existing cursor/position bookkeeping forms |

For the same declaration string, with `$scanner_deps` obtained from the ordinary
Scanner dependency bundle:

```perl
my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
    {id => 'my_declare_bare'}, 'my $x; my $x;', $scanner_deps
);
# source_origins spans: [0, 5), [7, 12)
```

Each origin contains the complete original source, scalar interval and the exact event
object in the returned event array. Copied/opaque split arrays and changed entries gain
no borrowed origins. If a later trim callback changes the raw text, the existing event
is preserved and its origin is omitted. Nested scans isolate their collectors and restore
the outer frames. A custom callback that splits a different source also keeps its event,
but that other string cannot authorize coordinates in the requested action. The private
bridge snapshots the requested source before the callback and declines foreign frames.
The original foreign-source probe reproduces one incorrect origin before this guard and
none afterward; those actual channels and source identities remain separate from the
initial 28-group captures. The permanent producer fixture preserves 21 failing groups before the
hooks and passes all 29 afterward, including callback count/argument/error guards.
Across the 22 authored inputs and three seeds, all 111 emitted origins match independent
original occurrence intervals; all 177 statement frames and 66 full public compiler
records remain unchanged. This bounded proof does not classify executable membership,
repair comment semantics or admit arbitrary host syntax. The statement-family acceptance repeats all eleven contracts from one immutable
source boundary. It independently checks original frame/event occurrences, exact event
identity, unchanged complete compiler records, foreign-source rejection and all four
source-provenance fixtures. Complete TAP plans and both output channels are retained;
missing inputs, incomplete plans and nested failures are distinguishing rejection
controls. Canonical CI gates this family closeout on the exact staged candidate. The
mixed twenty-contract proof now uses one shared action input. Its literal construction
includes a quoted row of all nine regex forms, every regex and statement form in
forward order, an ignored comment, then all twenty forms in reverse order. Unicode,
CRLF and Unicode whitespace remain in the original source. For each of three hash
seeds, the nine regex scans retain three syntactic matches each; the eleven statement
scans retain two original statements each. That is 49 event origins and 43 splitter
frames per input, with no origin inferred by searching equal raw text.

The independent oracle checks exact original arguments as well as spans. It distinguishes
an indexed child push from an unindexed push, call-return from bare return, declaration
from assignment, and each zero-argument gap helper. Public and private scans retain the
same values and dependency callback sequence. Every private origin refers to its original
event object and original argument object; the sidecar adds no public event fields.
Eight unchanged source/scanner/AST/order consumers pass 144 complete test groups,
including the existing callback, nested collector, opaque result, foreign-source and
caller-error guards. Actual full output channels and immutable source inputs are retained;
twenty distinguishing controls reject missing or altered occurrences, arguments, references,
callbacks, inputs and incomplete or failed results. The initial missing-test-path harness
failure stays recorded as incomplete evidence. A fresh immutable Git recurrence repeats all twenty contracts from the committed
mixed-proof boundary with no overlays. It independently validates the complete source
population and preserves the exact prior Toolbox channels under all three seeds, alongside
all eight original test plans, occurrence/argument/reference checks and foreign-source
guards. The exact staged canonical CI receipt gates BasicRules family closeout before
landing. Other scanner families still require their own producer frames and independent
composition before executable membership and source replacement can be repaired. This composition does not classify executable text,
repair comment semantics or activate source replacement.


These are compiler inspection examples, not recommended parsing actions. Each
contains one quoted syntactic occurrence followed by two equal real occurrences:

```spec
Top:: I { note="雪;my $x = call(Done)";
  my $x = call(Done);	my $x = call(Done) }
Done: /x/ I.return("child")
```

```spec
Top:: I { note="雪;gap_text( )";
  gap_text( );	gap_text( ) }
Done: /x/ I.return("child")
```

The captured action inputs use CRLF after the quoted assignment; the book displays
LF. That display normalization does not alter the retained compiler input or its
Unicode scalar position oracle. Private provenance also keeps the original event
object, rather than reconstructing it by matching equal raw text.

The earlier hash-key residual drain and its raw permutations remain historical evidence.
These exact sources return `ok` and `a` respectively, both natively and from independently
loaded emitted source in the measured before/after source-and-seed comparisons:

```spec
Top:: I { cb={|x,y| nested={|s,q| return(s) }; return(nested(x,y)) }; return(cb("ok","unused")) }
```

```spec
Top:: I { cb={|| if(false) { return("a") }; if(false) { return("b") }; return("a") }; return(cb()) }
```

For the second source, the top-level assignment and outer return precede the residual
`RETURN a`, `RETURN b`, `RETURN a`, then the two attached `IF` events. This ordering records
scanner precedence; it does not say those returns or branches were executed.

The current nine-source matrix preserves full ordered records across three controlled
seeds. Exact substitutions, parser dumps, emitted source, ASTs, metadata populations/counts
and native/fresh values match the before-owner observations. Fifteen current lowering traces
retain the measured source-cursor misses, ambiguous raw skips and single unmatched rewrites.
Those bounded controls do not establish arbitrary-overlap equivalence. Raw compatibility
results and process-specific host warning locations do not establish portable semantics.

Readiness still has separate known defects. This source returns its exact quoted value,
yet reports an extra `IF` event and three unresolved helpers:

```spec
Top:: I { return("return(inner); if(true)") }
```

Its typed argument is a string. The helper-looking contents must remain data; quoted-payload
repair is independently owned. The nested raw-expression reporting repair is explained below.
Stable event order alone does not repair those classifications. A working value cannot establish
portable readiness, and a false blocker must not be removed by hiding genuine raw source.

Literal contents must retain their data meaning during helper discovery, canonical-event
construction, lowering and unresolved-helper reporting. Recognizing the outer `return` does
not make the text inside its quoted argument executable. Diagnosis, a bounded repair and
independent closeout are tracked separately, including the earlier quoted primitive-rewrite
observations. Accepted quote syntax and genuine unsupported operands elsewhere in the action
retain their existing contracts while that work proceeds.

The historical quote diagnosis exposed this value defect:

```spec
Top:: I { return("set(counter, 2)") }
```

The intended result is the literal `set(counter, 2)`. Before compiler membership
selection, the primitive scan created a false `ASSIGN`, and residual lowering
changed the literal contents to `$counter = 2`. Compiler selection now excludes
that data occurrence and preserves the intended value. A mixed action must retain genuine executable assignments while
leaving an identical spelling inside data untouched.

For the quoted `if(true)` example above, the prior lowering trace reached a phantom
replacement, detected an unbalanced flow stack and returned the original action
text. That fallback explained the healthy literal value. Compiler selection now
excludes the false helper occurrence. The original nested `cat` and `matches`
controls also execute correctly on native and fresh emitted Perl; their earlier
fallback left unlowered host calls and failed both routes. Exact mixed-occurrence
replacement remains independently owned.

Unsupported-helper diagnostics also need source ownership:

```spec
Top:: I { return("LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr") }
```

```spec
Top:: I { return(substr("abc")) }
```

The first action returns ordinary authored string data. The second uses an
unsupported helper arity and must remain blocked; its current lowering returns
`undef` through a compiler-owned diagnostic marker. Both currently contribute one
unresolved `substr` because diagnostics search marker text without origin information.
Ignoring every quoted string would erase the second action's genuine blocker.
These examples describe the measured Perl reference behavior and pending repair;
they do not admit unsupported syntax or establish another backend's behavior.

The historical diagnosis keeps unmodified arrays and streams under the `.0.6.0` checkpoint
prefix. The `.0.6.1` successor retains an exact before-owner module, source-identical
before/after public captures, independent occurrence-order oracles, complete TAP and current
traces. Its read-only reviewer rejects corrupted source/order/population/consumer evidence;
it never overwrites captures. The permanent regression is also invoked by Phase 0. Compiler
landing requires canonical acceptance of the exact staged candidate. Three fixed seeds are
named observations, not a probability estimate or another backend's admission.

## Reading portability diagnostics

Perl readiness reporting includes unsupported expressions nested inside recognized
helper statements. Arithmetic and comparison use call form.
These two exact measured sources illustrate the difference:

```spec
Top:: I { i=2; i=i+1; return(i) }
```

```spec
Top:: I { i=2; i=num_add(i,1); return(i) }
```

The first contains an unsupported raw `i+1` AST child. It retains host Perl
behavior and returns1 on both measured routes; the fresh emitted route also
reports bareword/numeric warnings. It now reports ready0/raw1/fallback0 and
exposes `i+1` as a raw dependency and portability blocker. The earlier
ready1/raw0/fallback0 observation remains historical diagnostic evidence.
The second uses the admitted helper and returns3 with no raw child.
Use canonical calls; infix source is not portable authoring.

The same reporting defect reaches deferred bodies:

```spec
Top:: I { cb={|i| i=i+1; return(i) }; return(cb(2)) }
```

Metadata now reports ready0/raw1/fallback0; actual invocation still fails with
`unsupported_codeblock_actionir` for `raw_perl`. Native context and fresh
generated-source errors expose that failure through their own public channels;
native handler evaluation also emits its normal failure trace. A ready flag
does not erase an observed unsupported body.

Data must also be distinguished from executable source. This measured ordinary
action returns ok, but the current AST classifies the comment as raw and reports
a false portability blocker:

```spec
Top:: I { # i=i+1; i < 1
 return("ok") }
```

Source-comment classification has a separate repair owner. This ordinary LF
case establishes no deferred/function comment support. The earlier quoted
string example likewise remains data despite phantom helper telemetry.

The historical diagnosis retains16 full sources/48 native-and-fresh pairs under
three named seeds and16 lowering traces. Its seven hidden raw dependencies are
now visible in rule-action diagnostics. Conditions may appear twice in serialized
ASTs because condition and argument fields share a node; that is one source
occurrence. Equal text at different spans or in different action units remains
separate. For example, this source has two raw expression occurrences, while
the displayed raw text contains `i+1` once:

```spec
Top:: I { i=2; i=i+1; i=i+1; return(i) }
```

`canonical_action_ir_fallback_count` keeps its top-level event meaning.
`raw_perl_dependency_count` adds uncovered nonempty `unsupported_expression`
occurrences to that existing fallback count. A raw-containing statement already
represented by a `RAW_PERL` event covers its child raw nodes; they are not counted
again. Raw display and blocker lists contain unique text rather than occurrence
counts. Existing canonical events and helper diagnostics keep their meanings.

`raw_perl_expression_dependencies` exposes each added occurrence as `source`,
`reason`, `source_span` with `start`/`end`, and `source_unit`.
`raw_perl_expression_source_units` records `kind`, `index`, and the diagnostic
unit's exact `source`; blind actions also record `target`. The span indexes that
recorded action-unit text, not the absolute `.spec` file. Normalized fluent units
may be derived text. Unit kinds distinguish lifecycle slots, action edges,
blind edges and AND-local actions; repeated units retain separate indices.
Both arrays are empty when there are no added expression dependencies.

Nested eager braces, attached calls and attached controls propagate their body
start into child ASTs. Success nodes and typed parse errors use Unicode-scalar
coordinates in the containing action unit, including leading spaces and CRLF.
Correcting those coordinates can change serialized AST payloads in substitutions,
parser dumps and emitted Perl; the executable source around those payloads,
node structure, values and runtime behavior retain their existing contracts.

Semantic rule markers also create compiler-owned lifecycle code:

```spec
Top::
 -> MoveTop

MoveTop: /foo/ /bar/ @mark(body_start)
```

This measured named mark keeps ready1/raw0. RuleIR records the exact generated
LE slot and source; only that matching chunk is excluded from added expression
scanning. An authored identical chunk in a later slot, or changed source in the
recorded slot, remains visible. Position markers `@move_pos`, `@capture_slice`
and `@capture_from_here` keep their existing raw1/fallback1/ready0 diagnostic;
generated ownership does not remove prior canonical fallback events. Their
canonical portability classification has a separate reconciliation task before
readiness closeout; runtime equivalence alone does not establish that contract.


Readiness reports unsupported source present in an action; it is not an execution
trace. These measured keyword calls remain unsupported:

```spec
fn id(value) { return(value) }
Top:: I { cb={|| return(id(value:"x")) }; return(cb()) }

```

```spec
fn pair(first,second) { return([first,second]) }
Top:: I { effects=[]; cb={|| return(pair({ push(effects,"bad"); return("x") },second:"y")) }; return(cb()) }

```

Their raw expression dependencies are `value:"x"` and `second:"y"`, respectively.
Both report ready0/raw1/fallback0. Native and fresh emitted execution retain the
typed `user_function_keyword_arguments_unsupported` error, with
`arguments_evaluated`0. The second control leaves `effects` empty: rejection
occurs before either operand executes. No keyword syntax is admitted by this
reporting change. Its source spans are18–27 and69–79 in the recorded I-action
units; those units include their original leading/trailing spaces.

A blind action's rewrite input includes a compiler-generated call assignment.
Only that caller separates its exact bridge from the diagnostic body. For this
measured source, the added dependency is `i+1`, indexed in ` return(i+1) `:

```spec
Top:: I { i=2 } => Done { return(i+1) }

Done:: I { return("child") }
```

Canonical blind calls remain raw-free. Authored text with the same spelling as the generated bridge
is retained in its diagnostic unit; the existing `assign_call` contract owns that supported wrapper.
A genuine adjacent `i+1` still blocks readiness and retains its authored offset. A mismatched blind
target retains the complete source unit rather than applying the generated-prefix separation.

Supported legacy contracts also matter: a raw whole-expression AST can describe
a statement already owned by an exact canonical helper contract. This measured
wrapper source retains ready1/raw0/fallback0:

```spec
Top::&
 /a/ -> Top { my $retv = call(Leaf); $retv = call(Leaf); push @Top, call(Leaf) }

Leaf:
 /a/ -> Leaf { return(1) }
```

Canonical ownership requires the exact statement and a sanctioned legacy contract;
it never blankets arbitrary descendants of an outer `return(...)`. Bare `return`
and `exit` payloads are inspected independently. This measured method return keeps
its canonical RETURN/CALL events, but its host map/reference operands report
ready0/raw2/fallback0:

```spec
Top::&
 /a/ -> Top .return ((map {lc} @IMATCH_LIST), \@Top, call(Leaf))

Leaf:
 /a/ -> Leaf { return(1) }
```

Existing ordinary assignment-expression lowering also supports grouped mutation
receivers. This measured source retains ready1/raw0 and its existing values:

```spec
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items += value, copy(items), meta[key] = value, copy(meta), (items += "x").count(), (meta["last"] = value).count_keys())) }

Done::
 /[a-z]+/
```

The collector inspects the typed inner assignment and still exposes unsupported
inner values. It leaves grouped assignments inside deferred codeblocks raw: that
executor consumes the original AST and has no corresponding admission. This
reporting classification adds no syntax or runtime behavior.

The repair covers original rule-action and deferred-body ASTs. It does not scan
the function registry or claim a transitive function dependency count. Measured
referenced raw function bodies retain unresolved-helper guards; an unused raw
function does not newly block the rule. Comments and quoted helper-looking data
retain their separate repair owners. Shipped-spec descriptor census is source
compilation evidence, not full execution or syntax admission. Source-reference
compilation must use the exact decoded file text; passing a filename to `Get`
does not establish that file's readiness.

The diagnostic and repair checkpoints preserve original sources, full streams,
before-owner modules and independent fresh observations. The reporting change
leaves ASTs, lowering, emitted source and runtime behavior unchanged. Fixed seeds
are named observations, not a probability estimate. Canonical signoff is required
for landing; dispatcher/full composition and other-backend admission remain open.
