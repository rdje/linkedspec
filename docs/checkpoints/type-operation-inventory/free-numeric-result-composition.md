# Canonical arithmetic source and Number-prefix result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.24; implementation family23.3.63.
Authority: scalar-arithmetic-results.md16, scalar-numeric-v1, selected-values,
aggregate-null-and-snapshot-contract and current helper catalog. Existing
producers, short receiver arities, numeric conversions and domains do not change.

Admit canonical ordinary free num_abs/floor/ceil/round(one argument),
num_sub/div/mod(two), num_clamp(three), num_add/mul/scalar min/max(two-or-more),
with recognized positional values and no trailing overload. Canonical source
spelling is required. One-array num_min/max belongs to the existing Array
reducer, not this scalar source predicate. Ordinary short arithmetic first
receiver methods use their existing shape preflight. Zero-extra min/max remains
the Array reducer; comparisons, word/symbol aliases, malformed arities, keywords,
deferred/traversal/context/copy/function/parser/schema policies stay separate.

Carry actual Number/null results through current compatible operations and
explicit Array bridges. Incompatible known consumers reject before their
operands and later immediate with bodies. Preserve legitimate null/empty with,
source once, operands once in order, snapshots, local returns, function scope,
Number0 indices and needed errors. Retain actual-kind guards after intermediate
split/select/default results; no new helper, signature or numeric subtype.

```text
num_add(1,2,3).cat("!")                  # "6!"
num_add(1,2).take(1)                     # null
1.add(2).take(1).with(){return("ran")}   # null; body skipped
num_add(1,2).split(",").first().cat("!") # "3!"
num_div(1,0).with(){return("free")}      # "free"
```

Public Perl intake17 retains native/fresh/descriptor/substitution/emitted source:
eight ready healthy values, six ready wrong values, two matching nulls actually
unready with unsupported-with markers, one qualified needed error. Free
container guards produce[]/Hash{k:1}/KV; direct receiver guards already work.
Rejected chains can run later W; the effectful receiver source can lose S.
All twelve free arithmetic sources produce[] from take; all twelve short
receiver prefixes can enter later bodies. Compatible, valid bridge, snapshots,
Number0 indices and valid null/empty with controls are healthy.

MethodLowering's emitted-result source and scoped with-rejection predicates
omit canonical free numeric calls and arithmetic receiver prefixes. Original
numeric producers work. Freeze these source-role additions, reuse existing
guards, and preserve excluded source/overload behavior. A fresh-package numeric
Hash seed control gives{k:1} in both empty and seeded package::3 cases, with
host keys unchanged: it does not establish seeded contamination or general
host isolation. Its terminal session output was lost; complete final JSON and
closed session were recovered, no terminal exit status is claimed for that probe.

Shared free_numeric_result_cases.json17 is the immutable authored behavior
target (sixteen values/one needed error). Perl63.1 first, independently assess
Rust63.2/Dart63.3/Julia63.4/safe installed Lua63.5. Peer defects are not inferred.
Full23.4/pressure20.1/registration/progress/declared-host/general isolation remain
separate. Actual producers/all inputs: free-numeric-selection-intake.json.gz.
