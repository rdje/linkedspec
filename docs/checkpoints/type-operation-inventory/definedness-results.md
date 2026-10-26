# Generic definedness results in ordinary receiver chains

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.10; implementation23.3.11.
Existing is_defined/is_undefined helpers only; complete admission remains23.4.

is_defined tests whether its expression yields a non-null value; is_undefined
is its inverse. Empty text, numeric zero, false and empty Array/Hash values are
defined. Do not substitute emptiness/truthiness or infer kinds from binding names.
Each ordinary receiver takes zero operands; reject extras before source/operand
effects. Free helper signatures remain unchanged. Evaluate source once, predicate
once and compatible consumer operands once in order, preserving earlier snapshots.

Keep each backend's existing result kind and scalar-text/default semantics. Public
Perl native/fresh currently returns numeric1 or empty text, not numeric0/Boolean
false. Consequently cat(is_defined(undef),"!") returns"!" and
is_defined(undef).coalesce_nonempty("late").cat("!") returns"late!". These are
preservation controls. Other backends require independent producer assessment;
no common JSON truth encoding or default-result normalization is inferred.

The current result feeds existing compatible scalar/text and generic predicates;
container-only consumers reject until an explicit operation yields a container.
Targets include "abc".is_defined().cat("!")->"1!",
[].first().is_undefined().cat("!")->"1!" and an explicit cat/split/last bridge.
Cover literal/named/selected/pipeline/default/function/copy Array/Hash/String,
actual null/false/zero/empty values and source/result snapshots. Deferred/callable
contexts, comparison receiver additions and full domain/portable admission stay
separate; no codeblock method table is inferred.

## Public Perl baseline

probe_definedness_results.pl retains Get/substitution and independent fresh emitted
routes. Producer[empty-text,1,1,1,1,1,1,empty-text] and six defined boundary texts
[1!,1!,1!,1!,1!,1!] agree on native/fresh. Direct returned and nested forms work;
ordinary receiver form emits unchanged raw DSL and reaches undefined host helpers.
Computed fluent sources can fail handler compilation for that same missing chain
registration. _string_receiver_value_chain_return_family recognizes the prior
String predicate family but not definedness; typed free helpers already lower
through defined()/!defined() in MethodLowering.

Nested source/consumer control yields[1!,SC,changed] on native/fresh; preserve the
existing producer/order. Do not relabel unsupported fluent compile failures as a
snapshot bug. Freeze this contract, then implement/confirm Perl/Rust/Dart/Julia/Lua
in separate committed children. Small targeted checks only; full admission23.4,
Perl canonical registration23.4.1 and Lua declared5.4 remain separate.
