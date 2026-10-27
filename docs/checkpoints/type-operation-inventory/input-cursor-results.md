# Read-only input and cursor scalar result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.7; implementation family23.3.27.
Status: frozen bounded target; Perl27.1 first, independent backends after it.

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

## Other discoveries remain owned

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
