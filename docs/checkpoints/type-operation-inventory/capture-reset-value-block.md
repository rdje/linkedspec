# Anonymous capture reset as an ordinary value-block statement

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.35; target freeze35.0.
Status: frozen bounded target; Perl35.1 repaired/targeted-checked, independent Rust35.2 then Dart/Julia/safe Lua follows.

## Authority and observed failure

The expression-valued block contracts established by SPEC-FORMAT-TERSE.2.1.2,
2.1.4 and2.3.5.5 separate nonfinal statement effects from a yielded value. A local
return supplies that block's value, skips later statements in the block and leaves
the surrounding rule return channel untouched. Empty/keyed braces remain Hash
literals. Existing source-boundary contracts define start_capture_slice() and
capture_slice_here() as zero-argument boundary mutations, with no returned value.
They use the live cursor and current rule frame; operation/alias identity survives.

Seven public Perl controls at clean0d0382338 use explicit Value[2], inputαβ:cat,
anonymous boundary2 and live cursor6. Without reset, native/fresh yield
[["4!",2,4,"SA"]]. Standalone reset yields[["4!",6,0,"SA"]]. Putting reset inside
the cat operand's value block instead produces native[null]/fresh load failure;
it is not successful null handling. The alias, local returns before/after reset
and a lazy-skipped reset block also fail compilation. All misleadingly report
raw0/unresolved0/ready1. Existing no-reset and standalone controls are healthy.

Public call_spec_handler_subst output leaves the operand's order=cat(...) DSL
unlowered while Contracts rewrites only the reset to a native do-block. The
ordinary AST/text block statement paths in MethodLowering fall through to the
value-component owner, which has readonly Number sources but no void reset
statement role. Failure to lower one component abandons the whole operand block.
The late replacement cannot repair the missing statement/value distinction.
Exact source, emitted bytes, metadata, errors and substitutions are retained in
capture-reset-value-block-authority.json.gz; no backend failure is inferred.

## Bounded target

- Accept only the existing zero-argument anonymous reset and compatibility alias
  in nonfinal statement positions of ordinary expression-valued blocks. Reuse
  the canonical boundary-write expression/runtime operation and existing tracing,
  source identity and function-state fences; keep native operation names exact.
- Evaluate the enclosing source before operand effects and only once. A Number
  read before reset remains4 even though later rest width becomes0. The reset
  moves the anonymous boundary2→6 at the live cursor without advancing the cursor,
  changing local match/entry registers or writing named marks.
- Run ordinary side effects in authored order. A local return before reset skips
  it; one after reset preserves the effect. Both skip later T and resume the
  surrounding action, which appends A. Defined coalesce skips its entire fallback
  block, including reset and S. Do not eagerly pre-run a skipped effect.
- Preserve statement-only void semantics. This does not admit reset as a final
  data value, fluent receiver, returned value, array member or direct bracket
  source. Existing incidental host assignment results are not a new API.
- Keep pure-function parser-state rejection and current explicit/registered/
  deferred body vocabulary. This ordinary statement repair grants no new callback
  helper, mutator-as-data, arity, scope, type, AST/schema or generated family.
  Named-mark and advancing/take helpers are separate work.

Shared prospective fixture: tests/fixtures/capture_reset_value_block_values.spec
and.json. It is the exact failing inside source with expected[["4!",6,0,"SA"]],
derived from the established block and boundary contracts and healthy standalone
control. It is not described as currently passing on Perl before35.1.

| Control | Required result | Reason |
| --- | --- | --- |
| no reset | [["4!",2,4,"SA"]] | ordinary block effects and Number snapshot |
| standalone reset | [["4!",6,0,"SA"]] | existing boundary producer authority |
| reset/alias inside operand | [["4!",6,0,"SA"]] | statement mutation before final `"!"` |
| local return before reset | [["4!",2,4,"SA"]] | unreachable reset/T skipped; action resumes |
| local return after reset | [["4!",6,0,"SA"]] | reached reset retained; T skipped; action resumes |
| lazy defined-source fallback | [[4,2,4,"A"]] | fallback/reset/S all skipped |

Implementation leaves independently intake Perl35.1, Rust35.2, Dart35.3,
Julia35.4 and available safe Lua35.5. Already-compatible behavior gets regression
without invented RED. Confirm actual direct/deferred/function fences per backend
before changing anything; preserve existing exclusions rather than broadening
them. Use native/restored/generated/fresh supported routes and focused compilation
plus nearby Number/block controls. Full source/context/portable admission remains
23.4 after35/34/39/38/37/40 and pressure/registration/declared-host repairs.

## Instrument limits

The initial consumer was invoked before producer completion and failed its row
count assertion; no partial result was accepted. Its next completed-input read
rejected the known NONE-level diagnostic prefix, then was refined to require
exactly one final CAPTURE_RESET JSON row and only recognized prefixed diagnostics.
The actual producer/channels, initial/final consumer and prefix rejection output
are retained. The first cardinality failure's tool-only text was not separately
retained. These are instrument failures, not extra product RED or semantic credit.

## Bounded Perl35.1

The original eight-group regression has six actual RED groups, then first
candidate8pass without expected-value changes. Contracts now shares the two
original reset bodies with narrow AST/text block statement lowering after function
guards. Native reset/public standalone bytes remain identical; readonly Number
owner is unchanged. No mutator-as-data or new deferred vocabulary is admitted.
Final test only appends six function/deferred groups, executed separately6pass;
its first8 source prefix is byte-identical to the healthy candidate. Existing
Number7pass and both module syntax checks pass. One fresh shared fixture retains
actual candidate emitted source/raw0/ready1. Packet: capture-reset-value-block-
perl-intake.json.gz. No full14-in-one-run or full context/admission claim.

Pure-function reset remains unready and leaves outer boundary2; four deferred
canonical/alias literal/registered bodies retain typed unknown_helper rejection.
Their false-ready metadata extends existing31.6.4.4. Native collecting parent
clears the real child error and returns[null]; public runtime-only trace confirms
SpecEntry failure followed by Compiler defined-AST clearing. New P1 owner41 after40
before admission repairs that separate error-delivery defect without treating null
as healthy. Independent Rust35.2 follows; complete35/context admission stays open.
