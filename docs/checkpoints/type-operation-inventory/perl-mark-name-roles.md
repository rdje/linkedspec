# Ordinary Perl mark-name roles and readiness

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.42; target freeze42.0.
Status: bounded reader42.1 and writer statements42.2.1 repaired/targeted-checked; readonly42.2.2 and advancing42.2.3 next; wider42.3 separate.

The helper catalog declares logical String mark-name arguments. The complete
named-mark contract explicitly makes a bare identifier symbolic rather than a
working-variable read. Existing Perl native/scanner patterns accept word keys;
the implementation restriction must not leave known DSL calls executing as host
Perl. Four native peer intakes34.2-.5 already support quoted/computed word names.
This repair adds those representations for existing Perl word keys, without
admitting a wider key grammar or new non-String conversion policy.

## Observed source distinctions

The retained13-case public Get/descriptor/substitution/native/fresh intake proves:

- Bare begin/finish ignore equally named scalar bindings and return0/6; legacy
  bare numeric mark0 reads6. Both remain ready1 and must be preserved.
- Quoted/computed word readers, wrong-arity mark_pos and a numeric expression
  leave raw host calls with raw0/unresolved0/ready1. Fresh execution fails in
  undefined mark_pos/capture_len_between/cat/num_add. Native collecting parents
  lose these errors under separately owned41; their null is not success.
- Quoted/computed/punctuation/Unicode writers already report raw1/ready0. Their
  host execution failures belong here, but they are not all false-ready cases.
- return(mark_pos({return("finish")})) returns String finish native/fresh. Public
  substitution and emitted source contain host return mark_pos({return("finish")}).
  Its inner host return exits before the undefined helper runs. Readiness0 with
  unresolved return does not prevent this escape. Never bless it as an offset.

The source of false-ready readers is exact: Contracts/LegacyRules use word-only
patterns; RewritePipeline forwards the same unresolved pattern; Diagnostics
therefore misses unsupported argument forms, and EmitContext sees zero counts.
SourceLocation::Runtime already keys marks by rule_label/name in the existing
store. Argument lowering, not a storage/frame migration, owns the repair.

## Bounded argument contract

Preserve unmodified bare-word semantics and native operations, including the
tested numeric token0. Bare finish remains the symbol finish. A quoted word such
as "finish" is that literal name; a String expression such as cat(name, "") uses
ordinary value rules inside the expression and its resulting word as the name.
Use the existing String decoder/value lowerer, never textual quote stripping,
String-to-variable substitution, host evaluation or a callback vocabulary grant.

For new expression representations require an actual String yielding an existing
Perl word key. Preserve Unicode word semantics and exact spelling; no normalization
or invented escapes. Do not coerce computed Number/Boolean/null/containers into
names. Wider key domains, including punctuation/empty keys, remain explicitly
unsupported in this bounded Perl target and require42.3 authority before broader
portable admission. Existing native peer domains are not narrowed.

Evaluate accepted names once, left to right, capturing each completed String
before the next name's effects. Finish all name arguments before reading/writing
marks. The Julia four-route oracle makes the distinction concrete: if name2 moves
begin to6, capture_len_between(block-return-begin, block-return-finish) yields0,
with orderAB and begin6. Reading mark1 before evaluating name2 would wrongly give6.
An argument-local return remains local: the second oracle yields6!/AB and skipsX
before a later consumer. This is valid-expression proof, not cross-backend domain
or malformed-call parity admission.

Validate static arity/unsupported roles before their operands execute. Unsupported
known forms must produce governed helper-specific diagnostics/unready metadata;
no raw known-helper host invocation, leaked host return or false-ready shape.
Runtime-invalid values in an otherwise lowered String expression need controlled
helper-specific failure, not a host undefined-subroutine error. Keep that distinct
from a valid absent mark returning undef. Existing broad error-phase parity and
native collecting-parent delivery41 remain their own obligations.

## Implementation and verification ownership

42.1 owns the seven readonly Number readers through existing MethodLowering/value
and sole Contracts producer owners, including exact arity, String expressions,
argument-local returns and readiness guards. Preserve original symbolic native
bodies/operation tags, missing/reversed/zero/coordinates, source snapshots, static
function fences and consumer effect boundaries. Enable exact owned failing source
tests and check nearest34/complete-mark/function/native/generated controls.

42.2 owns remaining ordinary name-taking mark/capture calls: writers/copy/clear/
exists, text readers and advancing forms, with their current arities/aliases,
returns/effects and same name-role guard. Use the same argument owner; no parallel
regex-only semantics or broad generic unknown-helper rule. Verify invalid arity
before effects, source/name order, symbolic shadowing, Unicode word names,
provenance/scopes and original standalone bodies. Deferred helper rights do not
expand;31.6.4.4 still owns their readiness and41 owns swallowed child errors.

42.3 owns wider mark-key authority after ordinary feature coverage and before
full23.4. Any actual key-domain/policy movement is canonical after document-pressure
repair; no implicit portability claim from low-level Hash storage or peer examples.
42.1/42.2 commit separately, then resume39/38/37/40/41. No AST/schema/inventory,
rule-label lifetime, invocation-frame, alias, grammar or writer-as-value/fluent grant.

## Verified prerequisite42.4 before42.1

Before production, two public String-block controls with bare mark_input_end(begin)
produce malformed Perl/native handler compile skips and fresh load errors while
still raw0/unresolved0/ready1. Substitution shows the late native do-block inserted
inside raw Hash braces in cat's parts initializer; the ordinary statement owner
has not lowered the value block. This is independent of String name representations.
42.4 first exposes original mark_input_start/end word bodies to the existing
nonfinal statement owners, matching35's bounded reset pattern. Preserve primitive
body identities, zero/snapshots/cursor/capture-boundary/function/lazy/local-return
rules; no writer-as-data, final-expression, deferred or quoted-name grant. Then
reactivate42.1 and its eager name2-moves-begin oracle from the clean repaired base.

42.4 is now repaired/targeted-checked: shared original input-boundary bodies are
byte-identical, final scoped9 and appended isolated1 pass separately, nearest2
and module syntax pass.42.1 reactivates from the clean boundary. Bare Unicode
legacy already native/fresh6/raw2/ready0 is qualified under42.3; no portable-ready
expectation or new name grammar is smuggled into the statement repair. Exact
source/refinement/results: input-mark-value-block-intake.json.gz.

## Verified reader implementation42.1

All seven ordinary Number readers now use the shared ordered String word-name
argument owner and original primitive bodies. Unchanged18 groups go17 failed
before code,1 failed first candidate,18 pass final; nearest reset/named2 and both
module syntax pass. Seven original native/public body strings are byte-identical.
Existing value-branch lowering removes the smaller operand's inherited recursion
fence, preserving local returns without new body grammar. Static unsupported
roles/arity are helper-specific/unready before effects; runtime-invalid String
domain/kinds produce controlled fresh generated errors, with native delivery41
still separately owned. Packet: mark-name-number-reader-intake.json.gz.42.2 reuses
this same owner; wider keys/bare Unicode qualification42.3/full admission stay open.

42.2 is split into ten statement writers/copy/clear42.2.1, five readonly text/
predicate42.2.2 and eight advancing spans plus bridge42.2.3.42.2.1 is repaired:
unchanged16 groups14RED/candidate12RED/final16pass, nearest complete named3,
three module syntax and ten final native/public body identities pass. Public
standalone/nested source twins isolate missing statement scanner/contract handoff;
one shared method regex connects existing statement recognition to42.1 names.
Quoted Unicode word Strings work without a new bare Unicode/variable grammar
claim. Original native returns/trace/effects and function/deferred/value-role
limits remain. Packet: mark-name-write-statement-intake.json.gz.
