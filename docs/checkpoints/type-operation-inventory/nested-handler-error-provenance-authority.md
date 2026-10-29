# Native Perl child handler failure provenance

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.41.0; bounded repair41.1.

This target applies the existing diagnostics fallback contract in the book's
compiler/diagnostics.md and the RuntimeContext operation-boundary contract. A
deeper real failure must survive an outer wrapper with its original detail and
rule/handler identity. It introduces no helper vocabulary, public error schema,
native throwing policy, callback admission or recovery syntax.

- A real SpecEntry compile/evaluation failure belongs to the current parser
  invocation. Preserve that fact through ordinary/direct/nested collecting parents.
- A parent returning a defined Array, a nested null collection or an explicit
  value does not establish that an underlying runtime error was handled. An
  actual outstanding handler failure must use the existing direct native failure
  surface: undefined result, original inner eval error, and structured last_error.
  Keep the original exception/detail object and deepest failing rule attribution;
  do not replace it with a generic parent/runtime_parser payload.
- Ordinary recognition failure, unavailable data, return([match_text()]) before
  matching, and containers holding null remain valid when no actual failure exists.
  Neither nullness nor the returned collection's contents determine error status.
- Preserve the existing low-level synthetic stale-context success test. Its custom
  handler injects an arbitrary runtime_handler payload and returns [ok]; it is not
  evidence of an actual failed SpecEntry invocation. Do not reject it merely from
  matching text/field shape, or treat it as authorization to erase real failures.
- Existing owning error clear can acknowledge discarded state; a successful value
  alone is insufficient. Invocation entry still clears stale state so the same
  parser/context can recover on the next call. Keep provenance private and within
  the existing sole runtime/error owners, with no new public diagnostic field.
- Native actual-error provenance and generated failure envelopes are distinct
  adapters. Preserve current generated_execution_failed/detail unknown_helper/name
  and its top-rule wrapper identity; do not infer a new generated schema or helper
  grant. Excluded deferred callback readiness remains31.6.4.4-owned.

tests/fixtures/nested_handler_error.json freezes9 sources/22 calls: both canonical
and alias names in literal/registered callbacks, two direct callbacks, deeper
defined collection composition through call(), explicit parent override and valid
null collection. Repeated bad/nonmatching/bad inputs reuse the same native parser.
There are12 native nested-error-loss observations,2 already-preserved direct error
observations and8 healthy null/nonmatch/reuse observations. Current separate emitted
execution reports all14 errors and agrees on every healthy value/cursor. Exact
inputs/handler metadata/emitted modules/native context/full public metadata and
typed object fields are retained in perl-nested-error-authority-intake.json.gz.

Public runtime-only trace records Value handler failure followed by the top wrapper
clearing context solely for a defined AST. Six exact canonical Phase0 diagnostic/
recovery groups pass75 nested assertions plus the file's discovery assertion,
including real forced-failure/reuse and synthetic-stale success. No full suite.

Initial deep .push reference composition fails compilation because Middle has no
regex list; exact source/failed intake/public context qualification remain retained.
P1 TYPE48 owns that separate compiler contract/repair after41/47 before45/wider
features/admission. The qualified deep error source uses existing direct call
composition instead. Four nonmatch expected [null] candidates are calibrated to
actual native/emitted[] before this target freezes; source/input/actual outcomes
did not change. These setup epochs receive no handler failure credit.

No production changes here.41.1 retains exact healthy/direct/emitted compatibility,
establishes real RED/GREEN and registers a normal regression before full23.4/push.
Named47/referenced-blind48/exact28 Phase0 owner45 and all broader prerequisites
remain separately owned; no peer/full admission claim follows from this intake.
