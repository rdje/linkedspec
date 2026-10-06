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

`ActionIR::Scanner` discovers which helper contracts are present in a rule's action text. It uses a registry of scanner rule families (`PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, `LegacyRules`) to match helper syntax patterns and classify them into contract families. `ScannerCore` is the single source of truth for the scanner dependency contract — the mapping between recognized helper patterns and their lowering handlers.

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
closure. This closes private pipeline provenance; Flow, legacy and staged producers,
executable membership, comments and replacement remain separate work.

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
quoted-label and unknown-escape examples. Executable quoted-source membership
remains subsequent work: helper-looking literal data can still be rewritten as
code and produce a generated-handler compile failure.

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
original annotation. Progressive and recognition scanners still return their
events without a private event-source origin. Their canonical statement splitter
already supplies physical statement frames. A dedicated annotation owns its
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

Recognition statement provenance must preserve the token and unevaluated static
callee. A transaction selects one terminal operation:

```text
scope = recognition_checkpoint()
matched = recognize_once(scope, call(Done))
payload = recognition_commit(scope)
# Alternative terminal: recognition_rollback(scope)
```

The original diagnosis checks all seven dedicated contracts: one staged annotation,
one progressive annotation, four transaction forms and recursive observation.
Independent original intervals distinguish repeated equal statements; actual
dispatcher references and complete callback/compiler channels preserve the original
behavior. Invalid annotations retain their original event arguments so validation
can reject them; attaching provenance must preserve that path.
This diagnosis changes no static policy, recognition behavior or public event fields.
The staged repair preserves those boundaries and complete public compiler channels;
progressive and recognition source-origin implementation remains pending.
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

The current quote diagnosis also exposes a value defect:

```spec
Top:: I { return("set(counter, 2)") }
```

The intended result is the literal `set(counter, 2)`. The current primitive scan
creates a false `ASSIGN`, and residual lowering changes the literal contents to
`$counter = 2` before generated Perl evaluates the string. This case remains a
known defect. A mixed action must retain genuine executable assignments while
leaving an identical spelling inside data untouched.

For the quoted `if(true)` example above, the current lowering trace reaches the
phantom replacement, then detects an unbalanced flow stack and returns the original
action text. That fallback explains the healthy literal value; it does not validate
the false compiler events or readiness classification.
For the measured nested `cat` and `matches` controls, this fallback also leaves
unlowered host calls and causes execution errors in both native and fresh emitted
Perl. Those failures are owned by the same source-occurrence repair.

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
