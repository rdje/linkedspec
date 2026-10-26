# Explicit String comparison receiver counterparts and results

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.11; implementation23.3.12.
Existing free helpers: str_eq/str_ne/str_gt/str_ge/str_lt/str_le. Historical
bridge3.2.3.2 intentionally ships free calls only. The director's comprehensive
fluent directive adds bounded ordinary receiver counterparts; this is a new
feature, not a retroactive claim that earlier receivers were promised.

The source is the helper's left operand; one receiver operand supplies its right
operand. Compare lexical text, retaining the helper's actual result kind and
existing scalar/null/empty/Unicode semantics. Numeric eq/ne/gt/ge/lt/le aliases
and symbols remain numeric; no new String overload for them is introduced.
Reject missing/extra ordinary receiver operands before source/operand effects.
Free helper signatures stay unchanged. Evaluate source once, then operand once,
compute the comparison before compatible consumer operands and preserve snapshots.

The actual result feeds compatible scalar/text/generic methods; container-only
consumers reject until an explicit operation yields a container. Targets include
"a".str_eq("a").cat("!")->"1!", "a".str_eq("b").cat("!")->"0!" on Perl,
and "a".str_eq("a").cat(",x").split(",").last().uppercase()->"X".
Cover all six true/false pairs, empty/zero text, existing null compatibility,
literal/named/selected/pipeline/Hash-view/split/function/default/join Strings,
false retention/repeated generic predicates, bridges/scalar guards and SOC order.
Deferred/callable contexts and full domain/portable admission remain23.4. Keep
existing Dart Unicode-order repair2.13 and other source-kind defects with owners.

## Public Perl baseline

probe_string_comparison_results.pl retains Get/substitution and independent fresh
emitted routes. Six true and six false free calls return[1,1,1,1,1,1,0,0,0,0,0,0]
on native/fresh. Nested true renders1!, false renders0! and remains selected by
coalesce_nonempty. Do not reuse definedness's distinct Perl empty-string false.

Existing Perl lexical operators coerce undef to empty text: str_eq(undef,"") and
str_eq("",undef) return1, as do empty/empty and text-zero equality. This is actual
compatibility, not a new portable null-domain promise. Preserve it; other backends
need independent producer/domain assessment and scoped expectations.

Ordinary .str_* methods remain raw DSL and reach undefined host helpers; complex
source blocks can fail handler compilation. Substitution leaves the direct .str_eq
chain unchanged. MethodLowering's String return-family map intentionally omits
these free-only helpers; typed/legacy free value lowering is already registered.
Do not relabel that historical scope as an old promised receiver defect.

Nested source/operand/consumer blocks return[1!,SOC,null] on native/fresh: source
abc is captured before operand mutates the working value to zzz, then consumer
sets it to null. Preserve this producer/snapshot behavior. Null-source control
still evaluates both blocks once in SO order and returns0 against"a". Freeze
before production and implement/confirm separate Perl/Rust/Dart/Julia/Lua children;
small compile/direct checks/docs/commit only, full admission23.4 separate.

## Bounded Perl counterparts

23.3.12.1 adds the six names to existing one-operand/scalar-result lists only.
Native/fresh shared and direct definedness pass after raw/compile RED: six true/
false pairs and raw1/0, null/empty/zero literal/binding twins, source families,
retained0!, generic/bridges/scalar guards, twelve malformed no-effect controls
and1!/SOC/once-only/final-null snapshots. Free zero-text control already works;
producer/domain/numeric aliases unchanged. Undef retains legacy uninitialized
warnings when enabled. Rust2 follows.

## Bounded Rust counterparts

23.3.12.2 adds the six names to String/scalar/one-operand lists only. Native free
producer control first confirms Bool flags, undef-as-empty/zero compatibility,
retained0! and eager SO. Shared native/restored/plan and direct definedness pass
after receiver-null/24-effect RED. All six pairs/raw kinds, source families,
false/generic/bridges/scalar guards,12 malformed no-effects and existing
1!/SOC/once-only/final-null snapshots pass. .json preserves Bool versus Perl's
.perl.json numeric flags. No producer/domain/numeric alias change; Dart3 follows.

## Bounded Dart counterparts

23.3.12.3 adds six names to scalar/one-operand lists only. Free public producers
return Bool for defined scalar comparisons and null when either operand is null;
false/default texts remain0!/0!, with eager SO. This differs from Perl/Rust
undef-as-empty compatibility: .null.json pins null boundaries/null_effected.
Shared native/restored/plan and direct definedness pass after empty-Array scalar
guard/24-effect RED. All six pairs, source families, false/generic/bridge/shape
and existing1!/SOC/once-only/final-null snapshots pass. Producer/Unicode order
unchanged; DART2.13 still owns its UTF-16 gap, full admission23.4 stays separate.

## Bounded Julia counterparts

23.3.12.4 adds six names to scalar/one-operand lists only. Public native/plan/fresh
free controls independently confirm Bool/null propagation, empty/zero, false0!
and eager SO. Shared .null.json agrees with Dart; explicit isa Bool checks
reject numeric lookalikes. Twelve comparison and nine direct definedness
assertions pass after three shared empty-Array/24-effect REDs. Six pairs, source
families, scalar/bridge/shape and existing1!/SOC/once-only/final-null are retained;
no producer/domain/numeric-alias change or full admission claim.

## Bounded Lua counterparts

23.3.12.5 removes the comparison terminal fence and reuses is_string_comparison
for scalar/one-operand guards. PUC5.5.1/LuaJIT public free controls confirm Bool,
null propagation, empty/zero, false0! and eager SO. Shared native/plan/fresh
.null.json and direct definedness pass on both after terminal-null/24-effect RED.
All six pairs, source families, scalar/bridge/shape and1!/SOC/once-only/final-null
pass; the prior fence stopped C, rather than proving a source capture defect.
No producer/domain/numeric aliases changed. Declared5.4/full admission stays open.
