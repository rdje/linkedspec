# Ordinary substring optional arguments

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.20; repairs23.3.20.1 Dart, .2 Julia,
.3 safe Lua. Broader signature1.2.1.4/SESSION61.3 and portable23.4 stay open.

## Authority and frozen repair

ADR0006 makes Perl the behavioral oracle. ADR0023 requires equivalent accepted
inputs/results, with temporary skew owned. ADR0029's strict Boolean rejection is
specific to num_* arithmetic; it does not define every integer argument. Align
ordinary substr(value,start[,width]) with its existing Perl behavior, rather
than creating a new helper, grammar, global conversion or numeric policy.

- Source/start null and explicitly supplied width null produce null. Omitted
  width alone means through end. Preserve eager operands and later scalar consumers.
- Boolean slice start/width uses false=0, true=1. This helper-specific compatibility
  does not admit Boolean arithmetic operands or typed Array selectors.
- Preserve integer/integral-number/numeric-text behavior. Existing negative and
  fractional slice arguments normalize to zero; retain Unicode character indexing.
- Preserve source capture once and source/start/width/consumer order, with later
  mutations unable to change the captured source. No new arity/error precedence.
- Keep dedicated named-target regex mutation dispatch and free unary/extra-arity
  behavior unchanged. Clip widths safely using existing bounded interval paths.

## Independent pre-repair observations, October27

Shared authored fixture: tests/fixtures/substring_optional_argument_values.spec
and its explicit JSON oracle. Perl public native/fresh strict reference probe
agrees with that oracle. Rust native/CompiledSpec-JSON-restored/in-process plan
regression also agrees. These are bounded deterministic examples, not a complete
input-domain, standalone-generation or all-backend admission measurement.

| Input/control | Perl/Rust reference | Dart and both safe Lua hosts | Julia |
| --- | --- | --- | --- |
| Omitted width at1 | bc | bc | bc |
| Explicit null width at1 | null | bc | bc |
| Boolean starts true/false | bc / abc | abc / abc | bc / abc |
| Boolean widths true/false at0 | a / empty | empty / empty | a / empty |
| Null-width source effect chain | [null,SIWC,1,null] | [abc!,SIWC,1,null] | [bc!,SIWC,1,null] |
| Boolean-width source effect chain | [b!,SIWC,1,null] | [!,SIWC,1,null] | [b!,SIWC,1,null] |

Every row covers free/receiver where applicable. Null source/start, integral/
text/negative/fractional controls already agree. Dart native/restored/plan and
Julia/Lua native/plan/fresh observations are independent, not inferred from Rust.
Lua hosts are PUC5.5.1/LuaJIT2.1; malformed native patterns/full runner are excluded.

Retained diagnostics: probe_substring_arguments.pl, dart/tool/probe_substring_arguments.dart,
probe_scalar_string_julia.jl arguments, probe_scalar_string_lua.lua arguments.
Rust test substring_optional_arguments is a passing reference regression. Actual
production remains unchanged in this assessment; separate backend leaves retain
RED/GREEN and direct String/mutation checks. No universal conversion rule follows.

## Dart20.1 targeted repair

Local ordinary-arity null guard/Boolean conversion now matches the shared oracle
on native/restored/plan. New2/direct String7 tests, selected format/fatal analysis
pass after RED, including SIWC/source snapshots, Unicode, identity/rejection/shape
and both named mutation aliases. Legacy unary/extra-argument controls stay passing;
global int/numeric/selector and large-slice2.14 remain unchanged/separately owned.
Julia20.2 and safe Lua20.3 still need their recorded local repairs.

## Julia20.2 targeted repair

Ordinary three-argument explicit-null guard fixes the already isolated width
collapse; Boolean conversion already agrees and remains unchanged. Registered
shared9/legacy3 plus direct String54 strict native/plan/fresh assertions pass
after three value REDs, preserving Number-not-Bool counters, SIWC/eager SIL,
Unicode, identity/shape/rejection and both named mutation aliases. No global
converter/free-arity or unsafe large-slice2.10 change; safe Lua20.3 is next.
