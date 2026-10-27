# Ordinary data-helper computed-call selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.24.1.2.1; parent target computed-selection.md.
Status: Perl bounded data-helper source class implemented/targeted-checked; registered function results remain24.1.2.2.

Recognize a direct call as a typed computed receiver only when its canonical name
belongs to the existing known data-helper and value-method owners: String,
Array/Hash receiver values, Numeric scalar/reducer helpers, Array/Hash constructors
and logical helpers. This is a static source decision. Known helper precedence
and function-name collision rejection already fence these names; do not classify
unknown/bound calls from their runtime values. Reuse signature/source diagnostics.

Exclude flat/flat_array/flat_hash list splices (no new scalar boxing), context/
capture/control/rule/invocation helpers and unknown/custom registered names from
this bounded source class. The explicit deferred-literal grammar fence remains
first. Preserve the four exact callable result readers/counts/raw1 and other
named/noncall/grouped/write/source/context boundaries. No new AST fields/formats.

The existing typed value_access reader lowers the semantic helper receiver and
selectors, evaluates the source once before ordered selectors, preserves actual
selected kinds/compatible consumers and skips incompatible operands. Missing and
wrong-kind reads remain null; a source error stops selection normally. Public
helper-shadow controls, scoped source/selector effects and strict selected values
must verify the decision on native and fresh execution.

The complete computed_selection_values fixture remains the parent oracle, including
entries() indexing. This child does not certify registered-function or complete
ordinary source/context/portable admission. Complete Perl only after24.1.2.2, then
independently assess Rust/Dart/Julia/safe Lua; full admission remains23.4.

Perl native/fresh regression passes43 after public compile/AST/source-error RED.
The regex split/index/String flow passes too. Cold Parser loading preserves the incoming error; new simple helper descriptors
report raw0/unresolved0/ready1. Frozen callable controls preserve values1/2/0/0
and raw1; noncall/deferred tests pass. A separate full-target public native/fresh
probe still fails handler/load compilation at the registered entries() suffix,
with raw1/unresolved0/ready0. Full target expectations are unchanged; parent24.1
and registered source24.1.2.2 remain open. The full probe also records the known
SESSION7 child-setpgid EPERM recurrence; no lifecycle/receipt claim follows.
