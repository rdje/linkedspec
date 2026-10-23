# Signed-array transition plan

Owner: TYPE-REFERENCE-BOOK.1.2.17.0. Runtime-source base: accepted
92c98fb3de0f8392abde59043bd6f67ba0199452. This is an internal implementation
plan, not portable capability admission.

The survey of 32 sources retains 192 primary-command observations plus Perl
descriptor/Get-dump/native/fresh execution. Ordinary Perl already reads the
tail; its callable reads return null. Rust's existing numeric-to-usize coercion
selects element0, even for underflow. Dart, Julia and both Lua ABIs return null.
Every library rejects the tested negative writes. The Perl CLI conceals twelve
recorded write failures as successful null output; the other five command
routes report the existing invocation-failure protocol.

The requested arithmetic is independent of those legacy results: for a selected
existing array of length L and an integer index i<0, resolve j=L+i. A legal j
must satisfy `0 <= j < L`. Negative selection cannot append, create a missing array or
manufacture fillers. Positive index replacement, exact-length append and
explicit quoted harray keys retain their existing contracts.

1. Complete and commit this source-bound intake. Preserve the original wrong
   ordinary dynamic-string comparison target and documentation-budget refusal
   as qualified instrument observations, with no product RED credit.
2. Repair P1 TYPE-REFERENCE-BOOK.1.2.17.8 at the next clean boundary. Observe the
   already-wired Perl runtime context as well as thrown exceptions; distinguish
   failed actions from legitimate null/false/no-match outcomes. Add permanent
   primary-command regressions and canonical proof before contract work.
3. Under 17.1, add a separate signed-selector neutral authority/checker. Preserve
   the historical write-vivification-v1 JSON, digest-bound composition and old
   proof unchanged. A concrete candidate is
   capability_conformance/signed_array_selector_contract.json and a corresponding
   tools/check_signed_array_selector_contract.py. Bind the old authority by
   identity and state exactly which existing-array negative restriction the
   new authority supersedes. Freeze lower-bound error identity/fields and
   precedence before touching production; keep unchanged v1 diagnostics exact.
4. Preserve the existing v1 native fixtures during staged implementation. Their
   negative failure is an absent-root case, including the permanent deferred
   fixture; that case remains invalid under the new rule. The public/source
   guards pin the old authority's bytes, status, driver order and digest. Add
   the new proof alongside them, with explicit pending implementation state;
   do not silently rewrite those historical measurements.
5. Implement separately under 17.2 Perl, 17.3 Rust, 17.4 Dart, 17.5 Julia and 17.6
   shared Lua. Verify PUC Lua and LuaJIT independently. Each child establishes
   its own fresh emitted-source before/after evidence before production edits;
   non-Perl emitted routes were not part of this native CLI survey. Update the
   old Rust negative-coercion assertion explicitly, preserving unrelated
   legacy coercion scope and its original source.
6. Under 17.7, split capability, recurrence and public closeout when necessary.
   Admit the extension only after all six runtime routes, direct dependents,
   generated routes, bounds/effects/copy/guard diagnostics and examples pass.
   Register its recurring/public proof without changing frozen history.

Writes inherit v1's ordered segment/RHS evaluation and post-expression isolated
snapshot. Resolve negative positions against the array encountered by that
structural walk; keep detached roots/results and atomic publication. Test nested
mixed containers, empty/missing/null states, dynamic/literal indexes, copied
parameters, index/RHS effects, receiver guards and diagnostic source spans.

The read extension covers integer array selectors and preserves read purity.
Existing effectful-selector receiver order and nonnumeric read coercions are
separately governed and are not promoted into a new portable policy by this
intake. The complete type/spelling inventory remains owned by .1.2.1; preserve
those distinctions when mapping its reference coverage.

All work stays inside LinkedSpec. Other repositories and submodules remain
read-only black boxes; documented public build outputs and SDK/OS products are
prerequisites. Project data stays on the repository volume. No push before PNT
is exhausted.
