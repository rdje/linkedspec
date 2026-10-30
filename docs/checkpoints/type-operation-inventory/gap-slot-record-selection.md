# Ordinary gap and incoming-slot record field selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.16; family23.3.55.
Status: bounded target frozen; independent implementations pending.

## Established source authority

entry_slot() and gap_span() are existing zero-argument parser-context readers
returning detached ordinary harrays. Entry slots retain target_rule/regex_index/
slot_id/selector_kind/authored_selector. Gap spans retain source_id/start/end/
provenance with decoded-scalar half-open offsets. Existing gap invocation owner,
candidate/terminal phase, child provenance, lifecycle/commit/rollback, slot names,
directive eligibility and typed-source identity remain authoritative.

A direct entry_slot() without an incoming edge returns null. Unavailable gap
access raises gap_capture_context_unavailable; it is not a null read/default.
Pure functions cannot read parser context; pass values explicitly instead.
This feature adds no gap state, helper, field, facade, source authority or schema.

At fc39c431d, public primitive/bound controls already pass native/fresh on the
documented List @capture_gaps -> Item[word] carrier and a,b. Gap spans are
[{source_id:input,start:0,end:0,provenance:gap},
 {source_id:input,start:1,end:2,provenance:gap}]; bound start.add(1) gives[1,2].
Both incoming-slot records name Item/word/regex_index0/named/word; bound slot_id
uppercase gives[WORD,WORD]. Direct brackets after either helper fail native
handler/fresh-source compilation with affected-rule raw1/unready. Current early
value lowering already owns both helper ABIs, but the governed computed-call
source predicate excludes these boxed records. Reuse that owner/typed reader.

## Frozen additive target

- Existing ordinary zero-argument entry_slot()/gap_span() feed current Hash
  field reads, nested reads and compatible selected-result methods. Use the
  existing value_access representation/source/span and actual-kind guards.
- Retain existing literal String Hash keys/Array index roles, selected kinds,
  null/missing/wrong-kind reads and explicit default recovery. No dynamic Hash
  key, String indexing, selector coercion or computed-write grant.
- Materialize the existing readonly source once before ordered selectors and
  consumer operands. Preserve source failures and existing copy/snapshot bounds;
  equality of JSON is not deep-copy/alias-isolation proof.
- Ordinary computed-result incompatible consumers skip their operands to null.
  Existing named/context first-consumer policies stay qualified and unchanged.
  A defined numeric zero skips lazy fallbacks; missing record fields may recover
  an Array and continue into signed selection and String methods.
- Preserve gap/slot native bodies/ABI/tags, owner and context checks, lifecycle/
  rollback/metadata, function/callback/deferred vocabulary, shape/arity/error
  policy and generated formats. Only the two existing zero-argument spellings
  gain this source role; no blanket contextual helper allowlist.

Shared prospective gap_slot_record_selection_values.spec/.json uses prefix and
interstitial records on a,b and named incoming child slots. Its two rows retain
start+1, end default/text, source/provenance text, missing-to-Array recovery,
incompatible-operand rejection and child selected slot fields. Parent and child
orders remain empty, zero fallbacks skip F, rejected consumers skip BAD, and
final live cursor is3. Distinct entry_* child locals avoid independently owned
cross-rule working-variable scope differences48.4.2.1.

## Reference calibration and legacy root policy

Four primitive/bound controls pass; two direct controls fail. The initial richer
bound twin compiles and skips BAD, but first take on a named Hash-selected String
returns[] through the existing MethodLowering ARRAY guard/else[] branch. The
initial null expectation was not a product defect or a healthy calibration.
entry-match-number-results.md and capture-boundary-text-results.md explicitly
preserve legacy first-consumer policies. Actual native/fresh values and exact
public substitution identify the mechanism, with no unexplained anomaly.

The final healthy bound twin uses the already-admitted completed fluent record
carrier source.coalesce(undef)[field]. That is the existing ordinary computed-
read oracle, with null/operand-skip guards. Its direct-helper twin preserves the
same expected values/field/consumer operations and fails compilation. Original
cases/producers/results remain retained; no oracle or legacy reader is weakened.

Actual source/producers/inputs/metadata/substitutions/calibrations are retained
in gap-slot-record-selection-intake.json.gz.55.1 Perl/55.2 Rust/55.3 Dart/55.4
Julia/55.5 safe Lua independently assess before production, retaining healthy
peers. No peer support, complete source/domain/context/error-phase/portable23.4,
canonical registration, typed-source facade or declared Lua5.4 admission here.
