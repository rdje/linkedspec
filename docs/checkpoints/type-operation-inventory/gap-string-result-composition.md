# Guarded gap String result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.18; implementation family23.3.57.
Status: Bounded Perl57.1 repaired/targeted-checked; independent Rust/Dart/Julia/safe Lua pending.

## Existing authority and preserved behavior

The current @capture_gaps contract owns canonical-zero gap_text() exact decoded
String and gap_kind() prefix/interstitial/tail String values. Empty spans are
defined empty Strings. Getter ABI/frame/source/cursor/arity/context failures and
pure-function restrictions stay; no state/fields/facade/schema changes. Basic
direct String methods already work on Perl and are healthy controls. Other
backends require independent evidence, not inferred gaps.

## Selected bounded addition

- The two original no-argument/no-trailing String sources use existing actual-kind
  guards. Incompatible Array/Hash consumers yield null before operands.
- Noncontainer read yields null, then explicit recovery can supply an Array/Bool/
  Number/String; existing signed Array selection and String methods compose.
  This gives no String indexing, computed writes, dynamic keys or coercion right.
- Materialize one source before consumer operands; preserve default laziness,
  empty text, decoded character values and returned kinds through compatible with.
- Preserve raw named/context first-consumer legacy behavior. Existing completed
  bound text.cat("") is the normalized healthy comparison, not raw named.take.
- Context errors precede defaults. Pure functions receive ordinary caller values;
  parser state remains forbidden. Invalid arity/trailing/deferred shapes retain
  their current backend phases, no blanket normalization.

## Actual selection evidence

On List:: @capture_gaps -> Item[word], input a,b; yields empty prefix, comma
interstitial, semicolon tail, cursor3. Primitive and bound/direct compatible
String methods and explicit function arguments pass native/fresh raw0/ready1.
Direct guards instead yield[]/constructed Hash and KV; direct read recovery fails
handler/fresh compilation raw2/unready. Raw named first consumers execute AKV
and retain their existing legacy result policy; that is not a new defect oracle.
A completed bound cat String twin yields null and skips operands, and final
same-carrier bound target passes exact shared JSON. Direct target fails raw1/
unready handler/fresh load. All original Perl production inputs remain exact.

Four unavailable primitive/default controls retain gap_capture_context_unavailable
before defaults. Two forbidden-function coalesces return M while metadata is
unready/unresolved under existing unsupported-marker-returns-undef policy
(29.2.6.1/55.1); no healthy function read or runtime-error proof. Explicit caller
String arguments are the positive function control. Actual16 observations,
source/metadata/substitution/generated-source and producers are retained in
gap-string-result-selection-intake.json.gz. No peer/full matrix/domain/context/
portable23.4, pressure/registration/progress/declared5.4 promotion.

## Perl57.1 implementation

Two MethodLowering source-role regex extensions reuse the original zero-argument
gap String ABI and actual-kind guards. Getter/runtime/Contracts/Parser/fence/state
bytes remain exact. Same13groups3RED/10healthy to13GREEN, gap10 groups/deferred22
flat assertions/owner and original-normal syntax pass. Added2 computed-read pure
function controls in an explicit new epoch; final15 passes, no historical RED
credit for added2. All four unsupported function cases may coalesce M with
unready/helper-specific metadata; no successful parser-state read. Four
unavailable source/default errors exact. Shared/empty/tail/Unicode/kind/with/
recovery/skips/cursor/named legacy behavior pass native/fresh. Actual source/
normal/producers/epochs/results in gap-string-result-perl-intake.json.gz.
New15 queued23.4.1, regenerate affected emitted Perl parsers. Rust57.2 next;
no full23.4 or new state/arity/function/deferred/schema authority.
