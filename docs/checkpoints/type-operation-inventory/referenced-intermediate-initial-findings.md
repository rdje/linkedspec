# Referenced intermediate ownership — initial findings

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.48.0; actual Dart repair48.3, independent peers48.2/.4/.5.

The original41.0 witness writes `-> Middle`, where Middle has no regex. The
published rule contract assigns `->` to declared target regex slots and `=>` to
parser-step calls. Current Perl correctly rejects the four action-to-missing-slot
candidates and compiles all eight candidate valid forms, including changing only
that original edge to `=> Middle`, ordinary/default/AND/bare-AND/marked/markerless
blind targets and direct calls. Public descriptors show no Top regex dependency
for valid blind/direct targets, while regex action controls retain target/slot0.
The historical failure is real, but the inference that a valid Perl blind target
cannot be a no-regex intermediate is withdrawn. Do not weaken the strict catalog
guard or silently convert action ownership to a blind call.

Actual independent Dart compile-only intake accepts direct-call and regex action
controls, but rejects all six valid blind-target variants with the same slot0
error as an action edge. _checkEdgeTargets in spec_validator.dart passes explicit
BlindEdgeBodyElementKind to _checkTarget(...,0); that helper unconditionally checks
the target's regex count. Bare AND targets take the same erroneous slot-validation
path. _checkEdgeStructure already forbids blind indices separately, so declaration
existence must not be conflated with action-slot selection. Failure occurs during
compileSpec validation, before emission/execution. Preserve actual action-slot,
undefined-target and forbidden blind-index diagnostics in the repair.

P1 TYPE48.3 owns this independently reproduced frontend defect before45/wider
features/admission. Runtime/fresh proof is not inferred from compilation, and no
Rust/Julia/Lua failure follows.48.0 continues reference native/fresh/finite-progress
qualification before freezing the target and separate backend slices. Exact12
sources/public descriptors/normalized/compiled/source/error channels are retained
in referenced-intermediate-compile-receipt.json for the eventual authority packet.
Production is unchanged; this finding corrects scope rather than selecting a new
language, catalog, schema or diagnostic policy.

## Completed qualification48.0

Frozen12 edge-ownership target now retains8valid/4action-slot rejects,7runtime
controls14native/fresh calls at cursor1. Two initial AND controls used an unbound
child_result placeholder; public emitted declaration/return and literal-return
replacements qualify that fixture error without a product RED. All initial/refined
observations remain retained; see referenced-intermediate-edge-ownership-authority.md.
Actual Dart6valid blind compile failures stay P1 owner48.3, production unchanged.
