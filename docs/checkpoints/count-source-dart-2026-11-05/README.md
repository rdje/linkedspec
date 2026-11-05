# Dart initial Boolean Count sources

Owner: `TYPE-REFERENCE-BOOK.1.2.23.3.73.6.3`.
Activation: `bc33c84b656da4557c7f7bb1b0fb83a5ee1c5444`.

The25 authored `count_boolean_source_cases.json` controls extend the existing
Count source/copy/length cases with explicit Boolean continuations, produced
receiver rejection, unowned Array guards, source-once effects and function scope.
Native/restored/plan and independently compiled emitted observations retain
three baseline mismatching groups: receiver source domains, initial Boolean
continuations and Boolean source-once continuation. Twenty-two groups are already
healthy, including function Boolean parameters. All25 final groups match with
strict Bool/Number/String/null identity and unchanged observed error message/class.
Both root and emitted-package fatal analysis pass before and after production.

The change adds only the existing one-step `initialCountSource` exception to
the scalar guard. Its caller already excludes copied/produced sources and the
loop consumes the permission once. Scalar initialization/assignments, common
guards and unrelated dispatch remain unchanged. No generic nullable/Boolean
Array policy, signature or context extension is claimed.

`capture.py before|after` is historical one-shot acquisition. It retains actual
root source/test/probe/fixture/pub manifest/lock/package-config bodies before
native execution, and generated host modules/runner/manifest/resolved lock/config
before host analysis/execution. Surviving declared inputs must match their first
archives before the owned temporary host package is removed. Additional generated
metadata/caches and complete SDK/native/transitive closure are not censused here;
23.4.2 retains that owner and prior gaps. Global managed stores and other repos
are unchanged. Dart jobs use offline resolution,86% RAM admission and periodic
host checks; no full suite or publication is inferred.

`compat.py` retains actual inputs before Count/length2 and copied-null index1.
`review.py` reads all retained direct input archives and observations without
extracting or executing members. Acquisition writers refuse replacement; never
replay them over these phase directories.

Formatting qualification: a whole-runtime formatter probe finds pre-existing
layout drift in `_isFreeDefaultResultSource` and `_isCanonicalSetResultSource`.
Its actual delta is `whole-format-probe.diff.gz`. Those probe changes were restored
byte-for-byte from the already-tested final runtime archive. `format.py` proves
the owned fluent loop is formatted and the complete owner stays byte-unchanged.
New normal/probe full formatting passes. P3 owner73.8 schedules only the two
unrelated member repairs after P1s/P2, before full23.4.

Readonly review qualification: the first reviewer compared the entire synthetic
class wrapper and rejected its single removed blank line outside the owned
method. `review.initial.py` and its captured negative replay remain; the exact
diff is `format-review-wrapper.diff.gz`. The corrected reviewer binds the probe to
the archived actual owner and compares the method boundary, preserving meaningful
interior whitespace checks. This is checker setup, not a product RED or runtime
repeat; the actual runtime owner stays identical to its passing after archive.

```sh
bash tools/run_python_project_data.sh docs/checkpoints/count-source-dart-2026-11-05/review.py
```

Current focused behavior from `dart/`:

```sh
bash ../tools/run_dart_project_data.sh test --reporter expanded \
  --concurrency=1 test/count_source_fallback_test.dart
```

The readonly review is historical proof; the maintained normal rechecks current
behavior. Full registration, source/context/portable admission, general isolation
and complete input custody remain separately owned. Rebuild Dart runtime/apps.
