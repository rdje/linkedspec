# Array contains ordinary result handoff

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.13; implementations23.3.13.1-.5.
Required-receiver normalization: FUTURE-PARITY-BACKLOG.5.6, explicitly activated
from the existing .5 caveat owner before production changes.

contains(array,needle) retains existing membership/equality, scalar coercion and
null/empty behavior. Array is the receiver; one authored needle is required.
Return the actual producer kind to existing compatible scalar/text/generic
consumers; container-only consumers reject until an explicit bridge produces one.
Source evaluates once before needle once, comparison completes before consumer
operands, and later mutations do not recompute the result. Preserve copied/source
values. Hit/miss, empty/null/zero and source-family controls distinguish behavior;
no new equality policy, free signature, logical helper or Regex kind is introduced.

Missing/extra ordinary receiver operands return null before effects, including
source blocks. A terminal .contains and .contains() both supply zero arguments
and must have identical rejection. Canonical function arity[2,2] and published
punctuation-light method contract remain unchanged. This intentionally replaces
the known Rust/Dart/Julia/Lua missing-needle0 compatibility drift under5.6; update
each actual backend's named calibration test with its implementation. No other
helper's invalid-source, argument or equality policy is normalized here.

Targets include ["a"].contains("a").cat("!") ->1!, missing-entry false retained
through coalesce_nonempty ->0! on the reference, repeated generic predicates,
.cat(",x").split(",").last().uppercase() ->X and scalar-only consumer guards.
Cover literal/named/selected/split/concat/Hash-view/function/default/copied Arrays,
source/operand/result mutations, required shape guards and actual raw kinds.

Public probe_contains_results.pl retains native/fresh/substitution controls.
Perl free hit/miss/empty/null-distinct/zero/false returns numeric
[1,0,0,1,0,0,1,1,1]; nested cat true1! works. Ordinary fluent continuations lower
to undef, including selected/bridge/generic; effect blocks are wholly skipped.
Nested source/operand/consumer already gives1!/SOC/final-null, null-source0/SO;
named source captured before rebinding needle gives1/O/[z]. Preserve snapshots.
Direct missing/extra and both missing aliases return undef/no effects. Nested
Array missing aliases both emit raw items.contains() and fail an undefined host
subroutine; immediate Perl1 owns that fallthrough and valid result routing.
Other backends need independent producer-kind/domain assessment, not a uniform
Boolean assumption. Full domains/context/deferred/portable admission remains23.4.
