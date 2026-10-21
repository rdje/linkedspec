---
id: perl-numeric-reducer-string-result-kinds
title: Perl selected numeric-string results can hide string kind behind numeric JSON
answers:
  - "why does numeric array minimum return a string on Perl"
  - "why does odd median of capture groups return a quoted number"
  - "does is_deeply distinguish Perl numeric strings from JSON numbers"
  - "which task fixes numeric reducer result kinds"
  - "can JSON show a number while Perl still treats a reducer result as a string"
  - "how must a historical Perl source shadow verify the loaded owner"
date: 2026-10-21
status: current internal-kind defect95; historical JSON observations qualified
tags: [perl, numeric, arrays, captures, serialization, mdbook]
evidence: "Aggregate7 retains five public native/fresh index controls and scalar flags: selected min/max/odd median reject; scalar min/add succeed. JSON::PP4.06 emits1 for all five, while selected results retain POK/string kind."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/type-aggregate-codeblocks/verify_kinds.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/type-aggregate-codeblocks/verify_library.py"
---

Array min/max and odd median select terms without scalar0+ conversion;
comparisons can retain POK alongside numeric flags. BindingRuntime::_runtime_kind gives that string flag
priority, so `index=min(["2","1"]); items[index]="changed"` requires a harray
and rejects an array with nested_write_kind_conflict. Max/odd-median twins fail;
scalar min/add controls update the array successfully. Scalar arithmetic such
as add(min(["2","1"]),0) supplies a numeric index as a workaround.

Perl5.34.1/JSON::PP4.06 emits1 for all five despite three string flags. Original95
reported three quoted results. Exact8 now render numbers through native/fresh,
three emitter epochs and real accepted91 library bytes (192 inputs,65 loaded
owners verified), with current tools/dependencies. Original instrument/environment
is unretained: keep quoted observations dated, without guessing a source cause.

Evidence: docs/checkpoints/type-aggregate-codeblocks/ (raw channels, source bytes,
loaded owners, flags and public failures).95 stays after93/92/94 before51: audit
aggregate inputs and repair kinds with consumer recurrence. No95 fix/backend
admission from7.

The retained minimum of [true,3] also remains Boolean;95 must audit input admission separately from numeric result kind.

A shadow path alone does not prove the selected owner loaded. Initial shadows misloaded current modules and were rejected; loaded-byte verification plus exact restoration admits the actual replay.
