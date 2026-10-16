---
id: perl-legacy-hash-kind-callback
title: Native optional kind selection and private callback identity
answers:
  - "why does uniform binding target recognition depend on the first container"
  - "which small optional kind helpers preserve actual tied map second selections"
  - "can a tied bare_symbol_kind map select a symbolic call after a CODE check"
  - "why must a non CODE optional kind selection remain opaque"
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
  - "why must FlowExpr optional callback delegation preserve the opening if line"
date: 2026-10-12
status: small optional and FlowExpr kind boundaries isolated; current-container guard repaired under .3.2.1.9
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify: "Historical accepted .5.1.0 and earlier routes use a4a9e5c503460a8bd7db06e57b827dd053724d00 Git inputs. Current ControlFlow attached-parser overlay and preserved complete historical population: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/publish.py. Original capture writers/observations stay retired; MEMORY.md/task frontier own current selection."
---

The private legacy hash normalizer used an unbound package variable for its kind
callback. A valid injected hash callback therefore failed before being called
when package state was undefined. Conflicting package callbacks could also select
the wrong container family.

The normalizer now selects the actual CODE reference from its dependency map once,
before trim. Missing/non-CODE callbacks supply an undefined kind. A trim callback
may replace the map entry, but the current invocation retains its selected
callback. The caller's map and actual callback references remain intact.

Known hashes admit a single copy; known arrays decline hash normalization. An
unknown kind can still use the existing next-method family lookahead. Explicit
container, arity, terminal-chain and early-source guards keep their native results.
The callback receives the original match argument in scalar context, preserving
its write rejection and fatal-object identity. Its private capture separates
nested publication from the enclosing normalizer; known callback authority uses
the actual reference. Require-only use keeps the emission channel unloaded.

The separate public scalar-held copy repair remains accepted at770cffcc. This
bounded private repair does not admit complete helper/AST/language behavior or
the required hash callback capture owned by `.3.1.6.3`. Other optional/direct,
output/mapping, full-private and independent parent admissions retain their owners.

The match flag/write distinction has its own canonical fact card:
`docs/knowledge/perl-match-alias-writability.md`.

Small optional-kind .3.2.1.2 covers _infer_assignment_source_container_kind,
_uniform_binding_target_symbol and _codeblock_variable_call_candidate. First216
supplied inputs retain18 callback cases/105 guard cases/6 authority rows/9 cold
cases before assertions or source changes. Required/secondary helpers are explicit
controls; original callbacks inherit eligibility1 and donate all six parent packets.

The native map expression checks one value for CODE and reads a second for selection.
MethodLowering has no strict refs, so the selected value may be a qualified or
unqualified symbolic name or blessed CODE and still execute. Separate217-input
first-native proof retains42 rows: those three variants execute in18 rows, while
GLOB/undefined/ARRAY/HASH fail in24 rows at the actual original helper call sites.
Match arguments reject writes; local target/candidate arguments accept them without
changing the caller scalar. All actual channels and first probe bytes are retained.

SourceEmissions::_capture_emission uses strict refs and only actual unblessed CODE
identities can be known. Directly binding a non-CODE second value would change
native dispatch or errors. The three bindings keep the actual CODE identity when
selected and treat caller-local delegation of a non-CODE value as opaque, preserving
its native call site and aliases. Resolving a symbolic name must not confer authority.
The original native producers are retired one-shot writers; current acceptance and
next work follow MEMORY.md and docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md.

The native target helper caches its first dynamic container interpolation through
/o. The .2 first paired1135 fixture exposed a wrong authored container-empty
expectation in the array-first probe order. Exact first fixture/capture and its
sole authored map correction are retained; all original native observations remain
unchanged. Separate216-input fresh-process diagnosis runs array then hash and
hash then array. Each first target is recognized; each second correct-container
target is rejected before kind lookup. P2 .3.2.1.9 owns the guard repair immediately
after .2 and due daily hygiene, before .3. This is a private-helper diagnosis;
public Toolbox reproduction is required before claiming an authored-language failure.

The separate object-name native probe retains10 rows over218 supplied inputs.
Its first child returned0 with a compile-time once-warning; the parent rejected
nonempty stderr. Exact first probe/producer/native result and available merged
parent failure remain retained. Only the probe's warning declaration changes;
all ten stdout observations are byte-identical and all other217 inputs stay exact.
The actual overloaded name object reaches the callback unchanged, preserving
coercion count, shared-object mutation and fatal object identity.

The first1135-assertion fixture has58 failures:57 intended isolation REDs and one
wrong authored container-empty expectation. Only that authored result map changes
before final paired capture. The identical final1135 TAP has57 isolation REDs and
1078 passing controls against accepted61cca1ccc, then all1135 current GREEN.
Nine syntax-valid full-source faults fail15/15/27/7/29/34/19/12/70 assertions for
named boundary, identity, alias, object, CODE validation, early function inventory
and name-authority reasons. Supplied69 suites/223 inputs/15093 assertions and
complete book89 inputs/three controls pass. Original339 bindings/full78325-byte
trim publication stay exact except its sole live mode/revision becoming historical
at61cca1ccc. The initial census instrument's non-live-input KeyError and available
merged output remain retained; the complete guarded census precedes all bound writes.

These facts establish three private callback boundaries and the explicit controlled
helper cases. They do not admit all secondary helper behavior, authored-language
failure, full-private/parent behavior or canonical CI. Thirteen original ingress
sites remain under .3-.8; the separately discovered cache repair .9 runs first.
The current readonly publication gates the retained native, paired, full-source,
consumer, book and evidence records. First capture writers are retired.

Readonly census repair .3.2.1.10 leaves the three callback bindings unchanged.
The first actual post-maintenance refusal is a missing new hygiene claim at
fixed61cca1ccc. A new reader enumerates the claim population from that same Git
boundary. Original accepted publication replay supplies532 files, including33
missing published historical inputs; extended533-file cases distinguish the old
namespace failure, corrected review, three population faults and restoration.
The first499-file incomplete replay and the initial wrong Git wording matcher
remain retained. The original report keeps its actual capture producer identity;
executed corrected source is separately retained/hash-bound. Original390 declared
bindings and both full publications are preserved with mode/revision changes only.
Canonical namespace/recovery facts: docs/knowledge/repo-generated-artifact-cleanup-boundary.md.

Current-container repair .3.2.1.9 removes only /o from the interpolated target regex.
Each call uses its actual literal container, preserving bare-name early return,
CODE selection/isolation and native argument/effect/error behavior. Four first
224-input native/public observations precede assertions and source edits. The old
callback fixture migrates only target/container-empty: value, eligibility, events,
trace and successful error state now reflect rejection before lookup. All other
main observations and full symbolic/object observations remain exact. Public
Toolbox selector rejection, supported live execution and independently loaded
emitted source stay unchanged across explicit first-container orders. This is a
private guard repair; no authored-language failure or new syntax is admitted.


Mutation/write predicate boundaries now follow the current .3.2.1.6 readonly
publication route above. Native280 loaded/16 cold rows, exact unchanged-source
recurrence and the identical516/156/360 RED/GREEN proof retain single-FETCH
selection, the writable helper-local target slot, boolean1/0, actual CODE
identity and real guard/assignment consumers. Five original ingress sites remain
under .7-.8; complete helper and independent admissions remain open.


Formal trim .3.2.1.7 now binds the one brace and three dot invocation expressions.
Complete230 loaded/68 cold native rows repeat byte-exactly before assertions;
only20 actual-CODE authority and32 symbolic authority rows change afterward.
The identical507 checks retain144 original authority REDs/363 controls/all GREEN;
fourteen source faults and all75 supplied suites/243 inputs/17188 assertions
distinguish selection, local and substring aliases, call context and parsing.
Named/blessed/amp-callable dispatch and already-bound nesting retain native
behavior. One original named-helper dispatch ingress remains under .8; no
complete helper/private/parent/canonical or other-backend admission is claimed.


Historical header routes retained at accepted22132b2b:
- Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults.
- Historical .3.2.1.10 readonly commands require accepted de02b83a1 logical inputs/full original claim. Its original422 bindings/full97759-byte publication and actual baseline are preserved before .9 changes. Earlier .2 and trim commands retain their recorded accepted input boundaries; never run retired capture/freezer/fault writers as resume commands.
- Historical .3.2.1.9 readonly commands require accepted61a73324 logical inputs/full original claim. Its original490 bindings/full113730-byte publication and actual baseline are preserved before .3 changes. Original .9/earlier producers and observations remain unchanged.
- Historical .3.2.1.3 readonly commands require accepted dd82f9cb logical inputs/full original claim. Original531 bindings/full125217-byte publication and actual baseline are preserved before .4 changes; original runtime/native/diagnostic producers and observations remain unchanged.
- Historical .3.2.1.4 readonly commands require accepted15197dfd logical inputs/full original claim. Original498 bindings/full114980 publication and actual baseline remain exact before .5; original producers/observations are unchanged.
- Historical .3.2.1.5 readonly commands require accepted99f2939ac logical inputs/full original claim. Original517 bindings/full119899 publication and actual baseline remain exact before .6; original producers/observations are unchanged.
- Historical .3.2.1.6 readonly commands require accepted b1133da42 logical inputs/full original claim. Original519 bindings/full119936 publication and actual baseline remain exact before .7; original producers/observations are unchanged.

Selected named-helper dispatch .3.2.1.8 binds only invocation694. Exact244-input
recurrence retains185 loaded/28 cold rows; only54 authority rows change afterward.
The identical487 checks retain132 original authority REDs/355 controls/all GREEN.
Twelve source faults and all76 supplied suites/246 inputs/17675 assertions pass.
Six literal helper references are selected before iteration. Mid-call name
replacement affects the next owner call; trimmed/deps helper-local scalar slots
remain writable and separate from caller slots. Mutating map contents remains
shared, while replacing the local deps scalar reaches later callbacks/fallback
without replacing the caller reference. Zero stays nonempty; native context,
reference/coercion/error/fatal/guard/fallback/cold behavior remains exact.
All17 sites from the original inventory now have their bounded repairs; full
named helper, FlowExpr/ControlFlow, private/parent/canonical admissions remain open.

Historical .8 header route retained at accepted328b11c5ed1d5ffbc870f6785448e3a8249fe882:

reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-publish-claim.py; review.py, native-review.py, book-review.py, headers-review.py and evidence.py under the same wrapper/prefix have readonly defaults. Historical routes below require their accepted Git inputs; capture writers are retired."


# First uncommitted Knowledge gate candidate

The complete first 136-input/35,512-byte publication and this original header are retained in the supplied-byte capsule. It is not an accepted Git revision. The current readonly publication verifies its isolated replay; original observations are unchanged.

---
id: perl-legacy-hash-kind-callback
title: Native optional kind selection and private callback identity
answers:
  - "why does uniform binding target recognition depend on the first container"
  - "which small optional kind helpers preserve actual tied map second selections"
  - "can a tied bare_symbol_kind map select a symbolic call after a CODE check"
  - "why must a non CODE optional kind selection remain opaque"
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
date: 2026-10-12
status: small optional and FlowExpr kind boundaries isolated; current-container guard repaired under .3.2.1.9
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-publish-claim.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Second uncommitted Knowledge gate candidate

The complete second337-input/full79329 publication and every input byte are frozen before this header route changes. Its actual supplied-byte replay and two corruption controls remain separate from the current documentation repair. This is not an accepted Git revision. The original header follows verbatim.

---
id: perl-legacy-hash-kind-callback
title: Native optional kind selection and private callback identity
answers:
  - "why does uniform binding target recognition depend on the first container"
  - "which small optional kind helpers preserve actual tied map second selections"
  - "can a tied bare_symbol_kind map select a symbolic call after a CODE check"
  - "why must a non CODE optional kind selection remain opaque"
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
date: 2026-10-12
status: small optional and FlowExpr kind boundaries isolated; current-container guard repaired under .3.2.1.9
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---

The canonical public selector guard classifies each sentence or table paragraph locally. The private target-recognition table introduced at fc96936f and updated at61a73324 used retired public spellings without local historical context. The later rejection paragraph did not classify those earlier rows. The current book uses literal bag/record labels, verified directly through the real helper in both fresh-process orders; public authoring stays with bare typed bindings. The unchanged classifier and its population/count contract govern this correction.

The composed executable-source guard distinguishes immutable private/negative probe bytes through HISTORICAL_DIAGNOSTIC_INPUTS in tools/check_executable_aggregate_selector_sources.py. Eight accepted .2/.4/.9 probe/assertion sources had14 unregistered selector-shaped lines. Their direct MethodLowering calls, original observation checks and explicit public rejection calls are now registered only at exact paths and SHA256s. The scanning algorithm is unchanged; copied paths, changed bytes and added selector lines reject in24 actual per-file controls. There is no public syntax allowance. The actual composed public gate then passes its original70-file/40-reference contract, source discovery/concurrency controls, five-backend retirement and capability admission.


# Third uncommitted Knowledge gate candidate

The whole177-input/full44317 publication retains its original logical inputs through unchanged files and ten complete supplied byte overlays. Only the two failure reports change diagnostic representation; decoded bytes are exact. The original header follows verbatim.

---
id: perl-legacy-hash-kind-callback
title: Native optional kind selection and private callback identity
answers:
  - "why does uniform binding target recognition depend on the first container"
  - "which small optional kind helpers preserve actual tied map second selections"
  - "can a tied bare_symbol_kind map select a symbolic call after a CODE check"
  - "why must a non CODE optional kind selection remain opaque"
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
date: 2026-10-12
status: small optional and FlowExpr kind boundaries isolated; current-container guard repaired under .3.2.1.9
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Fourth uncommitted Knowledge gate candidate

The whole198-input/full51535 publication and eight complete original route/card/map overlays preserve its original logical inputs. The current claim binds the published RGX README through an exact parent-owned snapshot; the submodule and pin are unchanged. The original header follows verbatim.

---
id: perl-legacy-hash-kind-callback
title: Native optional kind selection and private callback identity
answers:
  - "why does uniform binding target recognition depend on the first container"
  - "which small optional kind helpers preserve actual tied map second selections"
  - "can a tied bare_symbol_kind map select a symbolic call after a CODE check"
  - "why must a non CODE optional kind selection remain opaque"
  - "why did legacy hash receiver copy call an undefined package variable"
  - "does legacy hash normalization use the injected bare_symbol_kind callback"
  - "what happens when the legacy hash kind callback is missing or non CODE"
  - "when does legacy hash normalization select its kind callback"
  - "can the hash kind callback donate publication to its enclosing normalizer"
  - "where is the legacy hash kind callback repair verified"
date: 2026-10-12
status: small optional and FlowExpr kind boundaries isolated; current-container guard repaired under .3.2.1.9
tags: [perl, actionir, callbacks, receivers, hash, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 retains35 first-native cases:23 unchanged controls and12 intended selection/default repairs, plus two cold rows. Paired487 assertions have48 original REDs/439 controls/all487 current GREEN. Five syntax-valid faults reject48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions and full book89/three controls and six actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035; it has no full transitive input capsule. All546 predecessor bindings remain historical at770cffcc. Original draft/refused-wrapper observations are retained and their bounded corrections replay exactly."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (perl-legacy-hash-kind-callback). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.

FlowExpr .4.2 retains150 first native warm and150 cold rows, exact recurrences
and the two original optional map reads. A tied second selection can execute a
qualified/unqualified symbol, blessed CODE or amp-callable object; those remain
opaque even when their underlying actual callback is registered. GLOB/undefined/
ARRAY/HASH second selections retain original fatal diagnostics at246/256. Actual
CODE identity, once-only scalar calls, match write rejection, map replacement
after selection, overloaded kind coercion and fatal object identity are preserved.
The final762 paired assertions have154 original REDs/608 controls/all GREEN;14
full-source controls include both rejected candidate mechanisms. Complete prior
required proof451/full112004 remains historical at accepted708c1afa. No original
native observation is refreshed; default registration and broader admissions stay open.
