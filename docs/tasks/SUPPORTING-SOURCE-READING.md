# SUPPORTING-SOURCE-READING: Configuration, legacy adapters and authored grammar reading

## Metadata

- Tree ID: `SUPPORTING-SOURCE-READING`
- Status: `active` / inventory complete; physical reading 0/21
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.7`
- Created: `2026-09-13`
- Last updated: `2026-09-13`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.7.0`

## Goal

Read every supporting-source baseline byte and current delta, preserving exact
coverage, comprehension and actionable finding ownership. Reading is distinct
from runtime signoff. Existing startup and backend repairs remain open.

## Scope and acceptance

- Baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; planning activation `735f0337883baef5ac4422976879d09725e0e8ea`.
- Exact selectors: prefixes `conf/`, `tablescript/`, `noncore/`, `specs/`, `ebnf/`.
- All 158 baseline modes/blobs/current bytes are unchanged: 25,612 LF delimiters, 25,613 fragments, 964,256 bytes; no empty or binary member.
- Twenty-one groups contain 174 disjoint inclusive line ranges, bounded by 1500 fragments /65536 bytes each. Smaller output windows remain mandatory.
- Read roots in order: configuration, TableScript data, legacy adapters/plugins, authored specs, EBNF grammars. Crossing constructs retain explicit suffix ownership.
- No complete baseline-range reading is credited from earlier startup source records; isolated diagnostics and references do not establish exhaustive physical coverage.
- Retrieve Knowledge before interpreting source; use LinkedSpec Toolbox probes before diagnosing specification behavior. Do not classify historical syntax as a new defect by inspection alone.
- Preserve executable/file provenance and qualified legacy versus supported behavior. Do not run historical adapters or arbitrary configuration side effects merely to read them.
- No source repair before remaining startup prerequisites. Reuse compatible dependency products; reading requires no RGX/PGEN compilation.
- Commit each verified reading child; synchronize current evidence, memory, roadmaps and relevant book understanding. Keep prior task bodies and immutable history exact.
- Route new durable facts to their canonical Knowledge owners; related reading can share a coherent fact card. Do not create one card per slice by convention or pack unrelated evidence to evade limits.
- Remeasure every candidate against existing controls; this decomposition changes no capacity limit and does not extend ADR0118 into an unlimited allowance.
- Exact inventory/range replay: `docs/knowledge/supporting-source-reading-coverage.md`.

## Task Tree

- ID: `SUPPORTING-SOURCE-READING`
  Status: `active`
  Goal: Complete supporting-source reading and preserve all repair obligations.
  Children: `.1`, `.2`, `.3`

- ID: `SUPPORTING-SOURCE-READING.1`
  Status: `active`
  Goal: Read every owned supporting-source range in the frozen order.
  Dependencies: Startup .3.7.0 decomposition committed; clean activation for every child.
  Children: `.1.1-.1.21`
  Acceptance: Every child records complete source coverage, comprehension, Knowledge reconciliation, actionable findings, focused checks and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.1`
  Status: `pending`
  Goal: Read and understand supporting conf group 1.
  Scope: `conf/ambitiming.conf` lines 1-13; `conf/cgi.conf` lines 1-53; `conf/dutycycled.conf` lines 1-82; `conf/easytk.conf` lines 1-173; `conf/encountiming.conf` lines 1-18; `conf/fake_memmodule.conf` lines 1-64; `conf/fsmgen.conf` lines 1-88; `conf/fv_check.conf` lines 1-31; `conf/fxstart.conf` lines 1-32; `conf/hold_scale_factors_to_qcmin.conf` lines 1-14; `conf/libview_table2ss.conf` lines 1-10; `conf/lighttpd.conf` lines 1-353; `conf/lispml.conf` lines 1-87; `conf/lstype_long.conf` lines 1-14; `conf/m2g.conf` lines 1-38; `conf/magmatiming.conf` lines 1-5; `conf/matrix.conf` lines 1-6; `conf/n3g_scaling_factors.conf` lines 1-18; `conf/network.conf` lines 1-9; `conf/nlc.conf` lines 1-34; `conf/pcsally_mem.conf` lines 1-187; `conf/peruser.conf` lines 1-4; `conf/postsyn.conf` lines 1-164; `conf/pt_cases_analysis.conf` lines 1-3
  Baseline evidence: 1500 fragments / 61165 bytes; ordered range SHA-256 `7d85ddd590a20f2681eb68cadac6fad5e9e87b51949ec998a289ac60e799166c`.
  Dependencies: startup .3.7.0 decomposition committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.2`
  Status: `pending`
  Goal: Read and understand supporting conf group 2.
  Scope: `conf/pt_cases_analysis.conf` lines 4-57; `conf/ptiming.conf` lines 1-44; `conf/qcflow.conf` lines 1-488; `conf/qcflow_filter.conf` lines 1-11; `conf/qcflow_table2ss.conf` lines 1-183; `conf/regrestatus.conf` lines 1-6; `conf/regrestatus.tk` lines 1-35; `conf/router.conf` lines 1-98; `conf/rpt_consolidate.tk` lines 1-80; `conf/rtl.conf` lines 1-21; `conf/sdcgen.conf` lines 1-6; `conf/setup_hold_tmaxmin.conf` lines 1-40; `conf/seview.conf` lines 1-36; `conf/skew.conf` lines 1-91; `conf/spyglass.conf` lines 1-30; `conf/stan_backend.conf` lines 1-52; `conf/stan_backend_table2ss.conf` lines 1-20; `conf/stan_dm_measures.conf` lines 1-98; `conf/stan_dm_sheets.conf` lines 1-107
  Baseline evidence: 1500 fragments / 56777 bytes; ordered range SHA-256 `256ce40549a189f8c3d437233d412f6d1ab4108720d0e9a63938bb036f73109c`.
  Dependencies: .1.1 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.3`
  Status: `pending`
  Goal: Read and understand supporting conf group 3.
  Scope: `conf/stan_dm_sheets.conf` lines 108-255; `conf/stan_old.conf` lines 1-313; `conf/table2ss.conf` lines 1-431; `conf/tablegrep.conf` lines 1-200; `conf/tcfix.conf` lines 1-7; `conf/tcfix.tk` lines 1-21; `conf/tcflow.conf` lines 1-77; `conf/tcflow.tk` lines 1-149; `conf/tkcommands.conf` lines 1-154
  Baseline evidence: 1500 fragments / 50605 bytes; ordered range SHA-256 `04db2e07831eb7022523d7703879b76fe35ab20e225a30b45d46bdb81a457061`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.4`
  Status: `pending`
  Goal: Read and understand supporting conf group 4.
  Scope: `conf/tkcommands.conf` lines 155-417; `conf/tkgui.tk` lines 1-179; `conf/tss2sta.conf` lines 1-171; `conf/tssio.conf` lines 1-75; `conf/uref_2cidl.conf` lines 1-278; `conf/vhdl_template.conf` lines 1-4; `conf/vhdl_uc.conf` lines 1-8; `conf/violators.conf` lines 1-522
  Baseline evidence: 1500 fragments / 47232 bytes; ordered range SHA-256 `48ab9238732756db5df119fdde4b5626d73af695fcb609bd2dcd2e5f74f6d8b4`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.5`
  Status: `pending`
  Goal: Read and understand supporting conf group 5.
  Scope: `conf/violators.conf` lines 523-1110; `conf/xif.conf` lines 1-64
  Baseline evidence: 652 fragments / 21863 bytes; ordered range SHA-256 `c3d7df0e453accaf0569cc3f879b6a817e3f2a4b1deda86068df1a8ec753c348`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.6`
  Status: `pending`
  Goal: Read and understand supporting tablescript group 6.
  Scope: `tablescript/designsync.ts` lines 1-4; `tablescript/edalog.ts` lines 1-20; `tablescript/jpcts.ts` lines 1-14; `tablescript/libview_table2ss.ts` lines 1-19; `tablescript/lstype_long_i2chs.ts` lines 1-20; `tablescript/matrix.ts` lines 1-24; `tablescript/module_interface.ts` lines 1-98; `tablescript/network.ts` lines 1-53; `tablescript/nlc.ts` lines 1-138; `tablescript/peruser.ts` lines 1-9; `tablescript/postsyn.ts` lines 1-242; `tablescript/pt_cases_analysis.ts` lines 1-38; `tablescript/qcflow_table2ss.ts` lines 1-431; `tablescript/quick_omap2430c_dft_table2ss.ts` lines 1-12; `tablescript/raw.ts` lines 1-11; `tablescript/seview.ts` lines 1-15; `tablescript/skew.ts` lines 1-53; `tablescript/spyglass.ts` lines 1-26; `tablescript/stan_backend_table2ss.ts` lines 1-61; `tablescript/table2ss.ts` lines 1-212
  Baseline evidence: 1500 fragments / 47282 bytes; ordered range SHA-256 `b0997334b5fc70e981b8d452a574c0cd6030bff6f7685c3cc825198dbb7db8df`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.7`
  Status: `pending`
  Goal: Read and understand supporting tablescript group 7.
  Scope: `tablescript/table2ss.ts` lines 213-257; `tablescript/tree.ts` lines 1-16; `tablescript/wrapgen.ts` lines 1-9; `tablescript/xhierarchy.ts` lines 1-100
  Baseline evidence: 170 fragments / 5433 bytes; ordered range SHA-256 `7ec16ed9dba9a4a259323295bcb92287a7d96bace88edf84cff8f987913cee8e`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.8`
  Status: `pending`
  Goal: Read and understand supporting noncore group 8.
  Scope: `noncore/AmbiTiming.pm` lines 1-214; `noncore/EasyTk.pm` lines 1-788; `noncore/EncounTiming.pm` lines 1-216; `noncore/Global.pm` lines 1-61; `noncore/HDisplay.pm` lines 1-32; `noncore/HLinkSubst.pm` lines 1-152; `noncore/HTML/PathLinks.pm` lines 1-37
  Baseline evidence: 1500 fragments / 44204 bytes; ordered range SHA-256 `40b62d3cefc4bd4f39121ed8fd98919ab71a1b0dc13717cda614f8a4753d80c5`.
  Dependencies: .1.7 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.9`
  Status: `pending`
  Goal: Read and understand supporting noncore group 9.
  Scope: `noncore/HTML/PathLinks.pm` lines 38-40; `noncore/HTTP/FileAccess.pm` lines 1-187; `noncore/HUtils.pm` lines 1-449; `noncore/InteractivePrompt.pm` lines 1-63; `noncore/LibReader.pm` lines 1-48; `noncore/LispML.pm` lines 1-170; `noncore/Lispish.pm` lines 1-160; `noncore/MSOffice/Excel.pm` lines 1-47; `noncore/MagmaTiming.pm` lines 1-262; `noncore/PTiming.pm` lines 1-111
  Baseline evidence: 1500 fragments / 48761 bytes; ordered range SHA-256 `eb774f17b3ee3afefa6bcb4d9c1d0a44e0d7421bf32343bf6d1c124ba37cdbe0`.
  Dependencies: .1.8 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.10`
  Status: `pending`
  Goal: Read and understand supporting noncore group 10.
  Scope: `noncore/PTiming.pm` lines 112-413; `noncore/PluginUtils.pm` lines 1-200; `noncore/QC/Flow.pm` lines 1-362; `noncore/QC/Summary.pm` lines 1-51; `noncore/QC/TclInterconn.pm` lines 1-129; `noncore/README.md` lines 1-58; `noncore/Reportiming.pm` lines 1-249; `noncore/Table.pm` lines 1-94; `noncore/Table/GenericFilter.pm` lines 1-55
  Baseline evidence: 1500 fragments / 58017 bytes; ordered range SHA-256 `0843025a54da756ff9deeb9142cf83bd10f58852dd8cdaf045152ba98dd4449c`.
  Dependencies: .1.9 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.11`
  Status: `pending`
  Goal: Read and understand supporting noncore group 11.
  Scope: `noncore/Table/GenericFilter.pm` lines 56-234; `noncore/Table2SS.pm` lines 1-412; `noncore/TableGrep.pm` lines 1-83; `noncore/TableScript.pm` lines 1-425; `noncore/TableSort.pm` lines 1-76; `noncore/TcFlow.pm` lines 1-127; `noncore/Text/VariableSubstitution.pm` lines 1-62; `noncore/Timing/SetupHold.pm` lines 1-136
  Baseline evidence: 1500 fragments / 52510 bytes; ordered range SHA-256 `a747e9d215f83f9273d4eed8711bbf03096ef0b25e0bc6b52bf10c64254dbe7f`.
  Dependencies: .1.10 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.12`
  Status: `pending`
  Goal: Read and understand supporting noncore group 12.
  Scope: `noncore/Timing/SetupHold.pm` lines 137-316; `noncore/Timing/StanBackend.pm` lines 1-70; `noncore/Timing/StanOmap2430cBackend.pm` lines 1-436; `noncore/TkGui.pm` lines 1-162; `noncore/XLSreader.pm` lines 1-64; `noncore/plugin/common.plg` lines 1-25; `noncore/plugin/duty_cycle_degradation.plg` lines 1-13; `noncore/plugin/network.plg` lines 1-285; `noncore/plugin/qc_summary.plg` lines 1-68; `noncore/plugin/qcflow.plg` lines 1-197
  Baseline evidence: 1500 fragments / 54251 bytes; ordered range SHA-256 `91287f948ba350bed66afd0fdbf05864b18c8a52ea54fa3a33f4c8674af4353e`.
  Dependencies: .1.11 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.13`
  Status: `pending`
  Goal: Read and understand supporting noncore group 13.
  Scope: `noncore/plugin/qcflow.plg` lines 198-786; `noncore/plugin/raw.plg` lines 1-8; `noncore/plugin/setup_hold_tmax_tmin.plg` lines 1-43; `noncore/plugin/skew.plg` lines 1-171; `noncore/plugin/spyglass.plg` lines 1-145; `noncore/plugin/stan_backend.plg` lines 1-251; `noncore/plugin/stan_omap2430c_backend.plg` lines 1-82; `noncore/plugin/test.plg` lines 1-32; `noncore/plugin/tree.plg` lines 1-179
  Baseline evidence: 1500 fragments / 63370 bytes; ordered range SHA-256 `b7b54dd266db1dc4ad4aea9da7600130f5085e3ac5d37b601ef5514612c861bb`.
  Dependencies: .1.12 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.14`
  Status: `pending`
  Goal: Read and understand supporting noncore group 14.
  Scope: `noncore/plugin/tree.plg` lines 180-213; `noncore/rvp.pm` lines 1-1466
  Baseline evidence: 1500 fragments / 41582 bytes; ordered range SHA-256 `e25ae44448ff80432df812547d88862b3660ffe2674b9fdf27e6530819b8f51e`.
  Dependencies: .1.13 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.15`
  Status: `pending`
  Goal: Read and understand supporting noncore group 15.
  Scope: `noncore/rvp.pm` lines 1467-2966
  Baseline evidence: 1500 fragments / 50636 bytes; ordered range SHA-256 `a72d34c8c11412abe59ee638235612b21e3098940f58a45963a07f759c1fc08f`.
  Dependencies: .1.14 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.16`
  Status: `pending`
  Goal: Read and understand supporting noncore group 16.
  Scope: `noncore/rvp.pm` lines 2967-4254
  Baseline evidence: 1288 fragments / 44029 bytes; ordered range SHA-256 `478f8d4302ec3983f3c0767908d0cd048ecf132996c814c26dd1fd63a63ff2ed`.
  Dependencies: .1.15 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.17`
  Status: `pending`
  Goal: Read and understand supporting specs group 17.
  Scope: `specs/BNF.spec` lines 1-65; `specs/DT.spec` lines 1-43; `specs/Lispish.spec` lines 1-86; `specs/ds_vhistory.spec` lines 1-95; `specs/ebnf.spec` lines 1-214; `specs/hlink_substitution.spec` lines 1-29; `specs/ifelse.spec` lines 1-30; `specs/lib_reader.spec` lines 1-15; `specs/operators_try.spec` lines 1-47; `specs/portmap.spec` lines 1-33; `specs/pplugin.spec` lines 1-33; `specs/regdef.spec` lines 1-23; `specs/sdce.spec` lines 1-15; `specs/simenv.spec` lines 1-225; `specs/spec.spec` lines 1-146
  Baseline evidence: 1099 fragments / 62580 bytes; ordered range SHA-256 `8248125baaedfc4f2c1ebdfc253610c654da3ca973c28b3ca10aded6872611a3`.
  Dependencies: .1.16 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.18`
  Status: `pending`
  Goal: Read and understand supporting specs group 18.
  Scope: `specs/spec.spec` lines 147-226; `specs/tablegrep.spec` lines 1-86; `specs/tclite.spec` lines 1-35; `specs/tkgui.spec` lines 1-22; `specs/user_function_definition.spec` lines 1-115
  Baseline evidence: 338 fragments / 65500 bytes; ordered range SHA-256 `63dfc52c5cc5e8727600df003f2bdbf1b9cfb9d1de64ca5f32d03fc6b56cdae5`.
  Dependencies: .1.17 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.19`
  Status: `pending`
  Goal: Read and understand supporting specs group 19.
  Scope: `specs/user_function_definition.spec` lines 116-370; `specs/verilog.spec` lines 1-1; `specs/vhdl.spec` lines 1-384
  Baseline evidence: 640 fragments / 25134 bytes; ordered range SHA-256 `b50e1c4b57d9e600cecfd8fdaa76304228ee7572c25b9731bfe8ebd59f612d36`.
  Dependencies: .1.18 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.20`
  Status: `pending`
  Goal: Read and understand supporting ebnf group 20.
  Scope: `ebnf/builtin_return_annotation.ebnf` lines 1-137; `ebnf/builtin_semantic_annotation.ebnf` lines 1-59; `ebnf/ebnf.ebnf` lines 1-637; `ebnf/json.ebnf` lines 1-29; `ebnf/regex.ebnf` lines 1-279; `ebnf/return_annotation.ebnf` lines 1-205; `ebnf/semantic_annotation.ebnf` lines 1-154
  Baseline evidence: 1500 fragments / 49656 bytes; ordered range SHA-256 `3d30718744f09ca09f71d6417304f2519b09dc83a72feb7a5e8409dc8387b391`.
  Dependencies: .1.19 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.21`
  Status: `pending`
  Goal: Read and understand supporting ebnf group 21.
  Scope: `ebnf/semantic_annotation.ebnf` lines 155-580
  Baseline evidence: 426 fragments / 13669 bytes; ordered range SHA-256 `a28ce647ef9730870842323e24241f8f941f525f30bdfb7cd901f2add66eaea6`.
  Dependencies: .1.20 committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.2`
  Status: `pending`
  Goal: Own every newly established supporting-source defect or documentation gap through repair and verification.
  Dependencies: Each finding has exact source/tool evidence; implementation retains startup .3/.4/.5 prerequisites.
  Acceptance: Reconcile existing repair owners first; add bounded actionable nodes before new diagnostic or repair changes. Reading and logging never close a defect.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.3`
  Status: `pending`
  Goal: Independently reconcile all supporting-source reading evidence and route the next startup lane.
  Dependencies: All .1 children committed and every finding repair-owned.
  Acceptance: Audit exact baseline/current coverage, comprehension, commits/activations and repair preservation; retain applicable closeout verification and later startup obligations.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SUPPORTING-SOURCE-READING.1.1` | `pending` | After clean startup .3.7.0, read the first exact configuration ranges with Knowledge reconciliation; grant no implementation or remaining-source credit. |

## Decisions

- `2026-09-13`: Freeze 21 groups/174 ranges within existing controls. Earlier startup records provide no exact completed baseline-range credit for these 158 files; all remain physically unread in this lane.

## Blockers

- None for the first bounded reading slice. Existing failures, repair prerequisites, capacity controls and dependency reuse retain their owners.

## Verification Log

- `2026-09-13` decomposition: Exact baseline/current identity and disjoint range reconstruction pass; physical reading remains 0/21. Startup .3.7.0 owns independent candidate/continuity validation and commit.

## Commit Log

- `2026-09-13`: Decomposition lands with `SESSION-STARTUP-READING.3.7.0`; current Git identifies its commit.

## Changelog

- `2026-09-13`: Define supporting-source reading ownership without changing source bytes or granting reading credit.
