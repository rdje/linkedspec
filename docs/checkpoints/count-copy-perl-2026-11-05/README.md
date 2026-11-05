# Perl Count rejection through copy

Owner: `TYPE-REFERENCE-BOOK.1.2.23.3.73.6.1`.
Activation: `c7c3a466f571efc97e3597412167b1a189d74a24`.

The normal `t/count_copy_source_composition.t` consumes the authored
`tests/fixtures/count_copy_source_cases.json`: the assessment's source/copy cases
plus receiver/repeated-copy, no-with, valid-null/default and function controls.
Expected values come from the frozen Count source/rejection contract and ADR0138;
broken baseline values are never the oracle. JSON equality distinguishes false,
Number0, String0 and null. Native context errors, actual fresh loading/execution,
readiness and warnings are checked separately.

`capture.sh before|after` is a historical one-shot acquisition producer. Each
phase saves the actual owner, fixture, normal and emitted module bodies before
their fresh execution, raw TAP/stderr/exit, interpreter configuration and public
substitution output. The original assessment remains immutable. Direct source
custody does not establish complete transitive/native/toolchain closure; that
remains owned by23.4.2. General isolation, recurring registration and full23.4
admission stay separate. The logical producer repair belongs to73.6.6.

Baseline qualification: `before` completes the first fifteen assessment cases,
with native/fresh value failures in `rejection_through_copy` and
`repeated_count_after_copy`. The original added control16 is interrupted while
compiling (exit143); no result is inferred for16-19. Only that added source is
then replaced with a smaller repeated-copy control. The first fifteen inputs
and the normal are identical across phases; `after` completes all nineteen
cases with exit0. Both copies retain original emitted modules and public
lowerings. Compatibility TAP retains source fences, Count/length and selected
copied-null index controls.

The original long source remains in `before/cases.json`. `probe-slow.pl` retains
bounded public phase diagnosis and a debug substitution trace; the host sample
is `before/slow-sample.txt`. Both public probes reach their bounded stops.
This locates compilation work before parser execution, without proving the
algorithmic root cause. Separate P2 owner73.7 schedules that diagnosis and repair
after the six P1 Count repairs and before full23.4. The smaller normal and the
copy-state fix do not close the scaling concern. Probe writers are one-shot and
must not overwrite their retained outputs.

Re-run the maintained normal through repository-local storage:

```sh
source tools/project_data_env.sh
perl -Iperl t/count_copy_source_composition.t
```

Capture writers must never overwrite these phase directories. The SDK remainder
is recoverable from the activation Git tree plus the retained phase owner.
