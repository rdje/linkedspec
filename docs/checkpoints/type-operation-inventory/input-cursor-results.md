# Read-only input and cursor scalar result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.7; implementation family23.3.27.
Status: all five bounded backend children implemented/targeted-checked; full admission23.4 separate.

The existing scalar readers input_text, input_len, input_end_pos, input_end_line,
input_end_col, input_slice, cursor_pos, cursor_line, cursor_col, cursor_rest and
cursor_rest_len return String/Number/null values under the typed source-location
contract. Their ordinary results should compose with existing compatible value
methods without a mandatory working binding. This adds no helper/type/schema,
cursor movement, capture side effect or callback capability.

Preserve each reader's existing signature, source authority, character/position
projection, absence/empty/zero semantics and argument errors. Input_slice retains
two arguments and its existing bounds/null policy. Evaluate source operands once
left-to-right; capture the result before later fallback/consumer effects. Defined
empty String and numeric zero keep their kinds and skip defined-only fallbacks.
String methods can split into Arrays, select signed entries and resume String
methods. Number results can enter numeric/text/generic continuations. An explicit
compatible default can recover a container from a missing result.

Enable existing actual-result guards for these statically owned sources, including
through with and later bridges. Array/Hash-only consumers reject scalar/null
results before their operands, retaining permitted source and prefix effects.
Do not normalize old bare-binding/literal/unknown-bound-call/free-helper policies
or expand deferred/context/control/marker/write/copy/flat rights. Mutation helpers,
capture_take and other capture/mark readers are outside this bounded family.

## Public intake at af1fda392

The retained public probe uses Get, independently loaded emitted source, Value's
actual descriptor metadata and substitution. Existing direct match/input String
split flows and named input/cursor default controls work. The corresponding direct
input/cursor default chain fails generated compilation near )[; simpler cursor_rest
coalesce/cat leaves a host coalesce call. Both report raw0/unresolved0/ready1.
Input scalar take/set_key chains with block operands fail compilation near {{.
MethodLowering's typed call fallback cannot lower several getters before composition;
only later Contracts substitutions know them. Existing legacy family dispatch
also bypasses selected-result guards and leaves a set_key key block authored.
Perl27.1 repairs this reader/result boundary using the existing getter owners.

The first six-case instrument selected Top metadata/substitution instead of Value;
its exact bytes/stdout/stderr remain in context-scalar-first-intake.json.gz and are
not credited as action-bearing readiness proof. Corrected finite observations and
separate input/cursor controls retain Value metadata and original diagnostic stdout
preludes. Native child handler failures may appear in stdout while the outer rule
returns [null]; independently loaded generated failures distinguish those from a
successful null result. Existing SESSION7 setpgid EPERM is disclosed, not resolved.

## Other discoveries at intake

Quoted match_has/entry_has names leave host calls and ready metadata, whereas the
canonical bare-name spelling works.29.1 owns the static capture-name syntax and
readiness/diagnostic repair after27's bounded feature work and before admission;
first establish whether the public string-typed signature intends quoted names,
then implement supported lowering or an explicit rejection without ready leakage.

Bare/literal/context scalar roots currently use legacy take/set_key policies:
constant consumers return empty Arrays or constructed Hashes, while block-key
consumers can generate invalid Perl.28.1 owns the canonical first-consumer policy
assessment and verified block-key compiler repair after27, before admission.
Do not silently change every legacy free/named root policy in this reader slice.
These findings are tracked work, not successful clean-null denials.

## Schedule and proof boundary

Implement/compile/quick focused native/generated checks/docs/commit for Perl, then
independently Rust/Dart/Julia/safe available Lua. Use unchanged fixture and finite
source-order/default/with/error distinctions, not an exhaustive matrix. No backend
failure is inferred from Perl; no new serialized fields. Full source/domain/context/
portable/generated admission23.4, required Perl test registration, pressure repair
and declared Lua5.4 stay separately owned. Other findings28.1/29.1 precede admission.


## Bounded Perl implementation

27.1 shares ten zero-argument getter expression bodies between the existing native
contract callbacks and typed method lowering. Input_slice retains its existing
two-operand implementation. Exactly eleven static readonly source shapes enter
the existing actual-result dispatcher. The typed reader origin propagates through
with/fluent nodes; the owned trailing-with path folds existing AST fields instead
of rebuilding host text and losing the guard. No new schema or callback operation.

Five native/fresh/Value-metadata groups pass; the with group is expanded and
independently rechecked for Array/Hash/Bool results and outer value restoration.
The shared fixture preserves all spellings, kinds/empty/zero, source SWC order,
lazy fallbacks, split/signed/String flow, typed Number selector and operand skips.
Direct defaults13 and source-location contract4 pass, as do module/test syntax.
The retained with-result packet labels its first getter/direct-guard candidate
epoch and supplies the actual AST/substitution producer, then the repaired output.
Other backend failures are not inferred. Full admission and28.1/29.1 stay open.


## Bounded Rust implementation

27.2 independently observes three RED result cases and a healthy source/default/
named/snapshot control. Existing producers and with's actual returned kinds work.
A static ten-zero-argument/two-argument-input_slice predicate now enables the
existing actual-kind guards at ordinary and trailing-block dispatch entrypoints.
Four cases pass native/restored CompiledSpec/plan with Top/Value rows; six direct
computed cases also pass. Shared positions/kinds/SWC/lazy/split/signed flow and
with returned Array/Hash/Bool/scope hold; incompatible operands skip. Old malformed
extra/missing-reader counts10/0 and bound/flat counts0 remain. Offline compile/
rustfmt pass; no parser/reader/coordinate/bounds/serde/callback policy change.


## Bounded Dart implementation

27.3 independently observes three RED result cases and a healthy source/default/
named/snapshot case. Existing getters and with-return kinds work. Its static
name/sourceMethod/no-trailing/ordinary-arity predicate now enables the existing
kindGuardedResult flag, which persists through with/bridges. Four execution cases
pass native/restoredSpec/plan; seven computed cases also pass. Shared all-spelling
SWC/positions/kinds/lazy/split/signed data, Number indices and actual returned with
kinds/outer restoration hold. Malformed reader counts0/0 and bound/flat counts0
stay unchanged, without borrowing Rust's10/0 oracle. Format/fatal analysis pass;
no parser/getter/source coordinate/bounds/codec/free/callback policy change.


## Bounded Julia implementation

27.4 independently records nine RED result comparisons and three healthy source/
default/named/snapshot controls. Its existing source flag now recognizes ten zero-
argument readers and two-argument input_slice, with matching name/source_method and
no trailing block. All12 native/plan/fresh strict-kind comparisons and computed25
pass with --depwarn=error/normal registration. Shared SWC/positions/kinds/lazy/
split/signed data, Number indices and returned with Array/Hash/Bool/outer scope
hold; incompatible operands skip. Malformed reader/bound/flat counts0 remain.
No parser/getter/coordinate/bounds/compiled format/free/callback policy change.


## Bounded safe Lua implementation

27.5 independently records nine RED result comparisons on each available host;
source/default/named/snapshot and malformed-source controls already work. A private
table-field predicate reuses INPUT_CURSOR_HELPERS and existing name/source_method/
no-trailing/zero-two argument shapes, enabling existing actual-kind guards without
new chunk locals. Four execution groups pass native/plan/fresh on PUC5.5.1 and
LuaJIT2.1.1788460057; two malformed source-error groups preserve native typed
helper_arity_mismatch fields/generated text across those routes. Six direct
computed groups and luac/loadfile/normal registration pass. Shared SWC/positions/
kinds/lazy/split/signed data, Number indices and actual returned with kinds/scope
hold; operands skip and scalar counts yield null, bound/flat counts0 remain.
No getter/parser/source coordinate/bounds/format/callback policy change. All five
bounded27 children complete;28.1/29.1/declared5.4/full admission stay separately owned.


## Current follow-up resolution

28.1 preserves the canonical legacy first-consumer fallbacks and repairs eager
set_key key/value lowering and snapshots; see set-key-operands.md.29.1 repairs
ordinary static bare/quoted named capture reads and honest unsupported diagnostics;
see named-capture-static-names.md. Its confirmed input_text function read violates
the accepted parser-state ban, so the current four named/eleven input readers now
retain that fence. Remaining helper-family/context assessment29.2 follows before
admission. The earlier discovery descriptions above are dated intake, not open
implementation status for28.1/29.1.
