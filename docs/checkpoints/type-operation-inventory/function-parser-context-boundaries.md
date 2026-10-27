# Parser calls and public gap readers in pure functions

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6; Perl child.1 repaired/targeted-checked.

call(rule) performs parser work; entry_slot/gap_span/gap_text/gap_kind are current
public source_read helpers under ADR0079. Their absence from source-location
projection rows does not grant pure functions parser-state rights. Existing
SPEC-FORMAT-TERSE.4.2.3 authority bans parser-state helpers in pure bodies.

At clean7b915ba54, ordinary and function call(Child) both return child with ready
metadata. The initial copied List::OR/LX gap control returns null-valued collectors
in both contexts; public substitution/emission shows normal hash/call lowering,
then rep_acode miss-min-satisfied installs EX and returns before LX/E. Existing
perl-lossless-segmentation-readiness and the current book already document this.
The neutral executable_example still has old OR/LX source; canonical repair.6 is
scheduled P1 before admission after feature/prerequisite work, with exact source,
expected execution and old-header RED required. This is a stale example, not a
new lifecycle implementation bug.

The refined diagnostic uses documented default List::/LX. Ordinary gaps return
empty/comma and function gaps still return caller text/kinds/spans with ready
metadata. List's entry_slot is legitimately null, so a separate Item function
negative observes the full non-null incoming slot provenance record. The six new
native/fresh/metadata groups fail three forbidden cases before production, while
three explicit caller-value controls already pass. Exact producers, originals,
refinement/substitution/emission/channels and RED are retained in
function-context-perl-intake.json.gz. The mechanism program normalizes an extra
closing token before compiling its recorded actual hash source.

Contracts adds only the five known parser-context roles to its existing predicate;
current typed/legacy/statement function guards emit existing unsupported markers
without child/parser data and with raw0/unready diagnostics. All six new groups
and the prior function-boundary four pass, plus module/test syntax. Ordinary child
calls, gap text/kind/span and incoming slot records passed into pure functions
retain exact values/provenance. No runtime/context/lifecycle/parser/IR/schema,
callback or arity change. Independent Rust.2, Dart.3, Julia.4 and safe Lua.5 follow;
stale example.6/full source/context/portable23.4 remain separate.
