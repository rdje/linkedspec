# SUPPORTING-SOURCE-READING: Configuration, legacy adapters and authored grammar reading

## Metadata

- Tree ID: `SUPPORTING-SOURCE-READING`
- Status: `active` / one historical reading group complete; six fixture-reading groups superseded; fourteen code-reading groups pending
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.7`
- Created: `2026-09-13`
- Last updated: `2026-09-13`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.7.0`

## Goal

Read every currently required supporting-source range and current delta, preserving
original baseline coverage, explicit historical exclusions, comprehension and finding ownership. Reading is distinct
from runtime signoff. Existing startup and backend repairs remain open.

## Scope and acceptance

- Baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; planning activation `735f0337883baef5ac4422976879d09725e0e8ea`.
- Exact selectors: prefixes `conf/`, `tablescript/`, `noncore/`, `specs/`, `ebnf/`.
- All 158 baseline modes/blobs/current bytes are unchanged: 25,612 LF delimiters, 25,613 fragments, 964,256 bytes; no empty or binary member.
- Twenty-one groups contain 174 disjoint inclusive line ranges, bounded by 1500 fragments /65536 bytes each. Smaller output windows remain mandatory.
- Original root order and baseline ranges remain below. .0 changes current execution order to authored specs, EBNF, then remaining legacy code; historical configuration/TableScript content is not a current application-maintenance requirement. Crossing constructs retain explicit suffix ownership.
- No complete baseline-range reading is credited from earlier startup source records; isolated diagnostics and references do not establish exhaustive physical coverage.
- Historical-data disposition under .0: conf/ (58 files) and tablescript/ (23 files) are Lispish-era application data. Retain all inputs and existing parser-corpus tests; stop further manual fixture-content reading under superseded .1.2-.1.7. Completed .1.1 and every original Scope/digest remain historical evidence, with no excluded-byte credit. Current required code: 77 files/88 ranges/17291 fragments/673899 bytes in .1.8-.1.21. Read authored specs and EBNF first (.1.17-.1.21), then remaining legacy code (.1.8-.1.16).
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
  Children: `.0`, `.1`, `.2`, `.3`

- ID: `SUPPORTING-SOURCE-READING.0`
  Status: `done`
  Activation commit: `0e3423a19addad30c8f932b1f23fb270e22f1677`.
  Verification tier: `focused`
  Focused checks: Tracked current dependency-reference census and exact caller/loader/test-fixture inspection; canonical retirement and Lispish facts; original source/range/history preservation, Knowledge, memory, histories, book and normal doctrines.
  Canonical trigger: Director-authorized read-only reading-scope disposition; no source, test, runtime, build or gate change.
  Director clarification: Conf, Tk and TableScript inputs were Lispish data for obsolete day-job applications whose Perl AST consumers are no longer here. The director supplies their provenance/background and clarifies their limited current value, so .0 retains smoke coverage without further manual data reading. Original application specs described work activities; spec.spec attempted to describe the spec format itself. Current roles must be checked from current source/tests; historical provenance alone does not remove a maintained grammar.
  Goal: Apply the director’s historical-configuration reading boundary using current dependency evidence.
  Dependencies: .1.1 committed clean; no further historical configuration reading before this audit.
  Scope: Current corpus/spec/test/tool references, historical conf/TableScript provenance, exact focused corpus extraction, and retirement of further historical fixture reading while preserving every source/test and original range.
  Acceptance: Distinguish retained Lispish smoke-test inputs from obsolete application requirements; honor the director’s relevance clarification by ending further manual conf/TableScript reading. Preserve all source/tests, original inventory and completed evidence; mark omitted reading superseded without credit, prioritize current authored grammar, and synchronize tasks/Knowledge/roadmaps/book.
  Verification: Supporting .0 records conf and TableScript as historical Lispish application data, retaining their existing narrow parser-corpus use. The exact focused Phase 0 subtest passes six assertions over 53 conf/23 TableScript/7 EBNF inputs; no obsolete application consumer or dependency build runs. Further manual reading of conf and TableScript data is retired under .1.2-.1.7, with no deletion or reading credit; completed .1.1 and the original 158-file/174-range inventory remain exact. Required supporting code is now 77 files/88 ranges/17291 fragments/673899 bytes in 14 pending groups. Next .1.17 reads shipped backend-neutral specs, followed by EBNF and the remaining legacy-code review. Every prior defect owner and later startup obligation remains. Exact source/reference and scope replay: docs/knowledge/legacy-configuration-source-contracts.md. Focused corpus block and six helper bodies are copied byte-exact; full test-source SHA-256 6b7fc16ee751ab02f2ae06109cfe4fb2516aa29b22c7a5ba3b2f77827a98a82a. No complete-input/AST-content validation or full CI is claimed.
  Candidate proof: 2480 prior files remain byte-exact; two mutable Knowledge cards preserve earlier evidence with declared current-state updates and the explicit superseded-status extension to tree replay. Preserve 2605/2617 prior task nodes; twelve intended scope/order/provenance nodes change, no new ID, all repair nodes and completed .1.1 remain exact. All 92 prior book limitation headings remain. Exact new audit/extraction recipes and successful six-assertion TAP agree; memory is 60 lines, Knowledge 1140 facts/9099 keys, histories 389/35965 and 319/35219 lines/bytes. Rendered book and all nine doctrine hooks govern focused landing.
  Commit: `SUPPORTING-SOURCE-READING.0 - reconcile historical Lispish inputs with current corpus use`

- ID: `SUPPORTING-SOURCE-READING.1`
  Status: `active`
  Goal: Read current required supporting code in the .0 execution order; preserve original inventory, completed historical reading and explicit fixture-reading retirement.
  Dependencies: Startup .3.7.0 decomposition committed; clean activation for every child.
  Children: `.1.1-.1.21`
  Acceptance: Each required code-reading child records exact original Scope coverage, comprehension, Knowledge reconciliation, owned findings, focused checks and clean per-leaf commit. Six superseded historical-data groups are explicit omissions and receive no reading credit.
  Verification: `pending`
  Commit: `pending`

- ID: `SUPPORTING-SOURCE-READING.1.1`
  Status: `done`
  Activation commit: `d806aa674f8b0ae8202b78e3f8b40a1b898ede2a`.
  Verification tier: `focused`
  Focused checks: Director-scope intake and dependency-audit ownership; full exact scoped reading and baseline/window identity; canonical configuration/path/legacy reconciliation and bounded non-executing controls; prior source/task/card/history preservation, memory, Knowledge, histories, book and normal doctrines.
  Canonical trigger: Ordinary read-only source-comprehension evidence; no source/runtime/dependency change. Keep subsequent verification and repair prerequisites; no full CI or dependency compilation is needed for reading.
  Goal: Read and understand supporting conf group 1.
  Scope: `conf/ambitiming.conf` lines 1-13; `conf/cgi.conf` lines 1-53; `conf/dutycycled.conf` lines 1-82; `conf/easytk.conf` lines 1-173; `conf/encountiming.conf` lines 1-18; `conf/fake_memmodule.conf` lines 1-64; `conf/fsmgen.conf` lines 1-88; `conf/fv_check.conf` lines 1-31; `conf/fxstart.conf` lines 1-32; `conf/hold_scale_factors_to_qcmin.conf` lines 1-14; `conf/libview_table2ss.conf` lines 1-10; `conf/lighttpd.conf` lines 1-353; `conf/lispml.conf` lines 1-87; `conf/lstype_long.conf` lines 1-14; `conf/m2g.conf` lines 1-38; `conf/magmatiming.conf` lines 1-5; `conf/matrix.conf` lines 1-6; `conf/n3g_scaling_factors.conf` lines 1-18; `conf/network.conf` lines 1-9; `conf/nlc.conf` lines 1-34; `conf/pcsally_mem.conf` lines 1-187; `conf/peruser.conf` lines 1-4; `conf/postsyn.conf` lines 1-164; `conf/pt_cases_analysis.conf` lines 1-3
  Baseline evidence: 1500 fragments / 61165 bytes; ordered range SHA-256 `7d85ddd590a20f2681eb68cadac6fad5e9e87b51949ec998a289ac60e799166c`.
  Dependencies: startup .3.7.0 decomposition committed with clean handoff.
  Acceptance: Read all scoped bytes in complete bounded windows; preserve comprehension, canonical facts, owned findings, source identity, focused proof and clean per-leaf continuity.
  Comprehension: Timing/report patterns and diagnosis callbacks, grouping/scaling/month tables, Tk/Tix and CGI/HTML configuration, VHDL/memory templates and historical Lighttpd settings are distinguished from modern runtime contracts. Exact per-source findings: docs/knowledge/legacy-configuration-source-contracts.md. No new defect demonstrated; no historical consumer or dependency build executed.
  Verification: Physically read all 29 complete windows, 24 ranges, 1500 fragments/61165 bytes; 23 files reach EOF and case-analysis lines1–3 retain suffix ownership under .1.2. Window SHA-256 a9059071628ba48c22b57d9a2b2bc5715769288bcd74c6504c8af63038ff167d; exact range/window reconstruction passes. All 158 baseline/current sources and independent full plan coverage remain exact. Canonical legacy/path facts reconciled; structural portability, preservation, memory, Knowledge, both histories, rendered book and normal doctrine gates govern focused landing.
  Candidate proof: Source/card/decision/history preservation passes 1590 prior files, 2613/2616 exact prior task nodes, only three intended current-node changes and the new .0 dependency-audit owner; all 92 earlier book limitation headings remain. Three original coverage recipes remain byte-exact; Knowledge generates 1140 facts/9096 keys, memory holds 60 lines, histories pass at 382/35165 and 312/34329 lines/bytes. Structural path controls pass 14 classifier cases/five anchors; rendered book and normal all-doctrine hooks complete focused landing.
  Commit: `SUPPORTING-SOURCE-READING.1.1 - read legacy configuration data and templates`

- ID: `SUPPORTING-SOURCE-READING.1.2`
  Status: `superseded`
  Goal: Read and understand supporting conf group 2.
  Scope: `conf/pt_cases_analysis.conf` lines 4-57; `conf/ptiming.conf` lines 1-44; `conf/qcflow.conf` lines 1-488; `conf/qcflow_filter.conf` lines 1-11; `conf/qcflow_table2ss.conf` lines 1-183; `conf/regrestatus.conf` lines 1-6; `conf/regrestatus.tk` lines 1-35; `conf/router.conf` lines 1-98; `conf/rpt_consolidate.tk` lines 1-80; `conf/rtl.conf` lines 1-21; `conf/sdcgen.conf` lines 1-6; `conf/setup_hold_tmaxmin.conf` lines 1-40; `conf/seview.conf` lines 1-36; `conf/skew.conf` lines 1-91; `conf/spyglass.conf` lines 1-30; `conf/stan_backend.conf` lines 1-52; `conf/stan_backend_table2ss.conf` lines 1-20; `conf/stan_dm_measures.conf` lines 1-98; `conf/stan_dm_sheets.conf` lines 1-107
  Baseline evidence: 1500 fragments / 56777 bytes; ordered range SHA-256 `256ce40549a189f8c3d437233d412f6d1ab4108720d0e9a63938bb036f73109c`.
  Dependencies: .1.1 and .0 dependency disposition committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.3`
  Status: `superseded`
  Goal: Read and understand supporting conf group 3.
  Scope: `conf/stan_dm_sheets.conf` lines 108-255; `conf/stan_old.conf` lines 1-313; `conf/table2ss.conf` lines 1-431; `conf/tablegrep.conf` lines 1-200; `conf/tcfix.conf` lines 1-7; `conf/tcfix.tk` lines 1-21; `conf/tcflow.conf` lines 1-77; `conf/tcflow.tk` lines 1-149; `conf/tkcommands.conf` lines 1-154
  Baseline evidence: 1500 fragments / 50605 bytes; ordered range SHA-256 `04db2e07831eb7022523d7703879b76fe35ab20e225a30b45d46bdb81a457061`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.4`
  Status: `superseded`
  Goal: Read and understand supporting conf group 4.
  Scope: `conf/tkcommands.conf` lines 155-417; `conf/tkgui.tk` lines 1-179; `conf/tss2sta.conf` lines 1-171; `conf/tssio.conf` lines 1-75; `conf/uref_2cidl.conf` lines 1-278; `conf/vhdl_template.conf` lines 1-4; `conf/vhdl_uc.conf` lines 1-8; `conf/violators.conf` lines 1-522
  Baseline evidence: 1500 fragments / 47232 bytes; ordered range SHA-256 `48ab9238732756db5df119fdde4b5626d73af695fcb609bd2dcd2e5f74f6d8b4`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.5`
  Status: `superseded`
  Goal: Read and understand supporting conf group 5.
  Scope: `conf/violators.conf` lines 523-1110; `conf/xif.conf` lines 1-64
  Baseline evidence: 652 fragments / 21863 bytes; ordered range SHA-256 `c3d7df0e453accaf0569cc3f879b6a817e3f2a4b1deda86068df1a8ec753c348`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.6`
  Status: `superseded`
  Goal: Read and understand supporting tablescript group 6.
  Scope: `tablescript/designsync.ts` lines 1-4; `tablescript/edalog.ts` lines 1-20; `tablescript/jpcts.ts` lines 1-14; `tablescript/libview_table2ss.ts` lines 1-19; `tablescript/lstype_long_i2chs.ts` lines 1-20; `tablescript/matrix.ts` lines 1-24; `tablescript/module_interface.ts` lines 1-98; `tablescript/network.ts` lines 1-53; `tablescript/nlc.ts` lines 1-138; `tablescript/peruser.ts` lines 1-9; `tablescript/postsyn.ts` lines 1-242; `tablescript/pt_cases_analysis.ts` lines 1-38; `tablescript/qcflow_table2ss.ts` lines 1-431; `tablescript/quick_omap2430c_dft_table2ss.ts` lines 1-12; `tablescript/raw.ts` lines 1-11; `tablescript/seview.ts` lines 1-15; `tablescript/skew.ts` lines 1-53; `tablescript/spyglass.ts` lines 1-26; `tablescript/stan_backend_table2ss.ts` lines 1-61; `tablescript/table2ss.ts` lines 1-212
  Baseline evidence: 1500 fragments / 47282 bytes; ordered range SHA-256 `b0997334b5fc70e981b8d452a574c0cd6030bff6f7685c3cc825198dbb7db8df`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.7`
  Status: `superseded`
  Goal: Read and understand supporting tablescript group 7.
  Scope: `tablescript/table2ss.ts` lines 213-257; `tablescript/tree.ts` lines 1-16; `tablescript/wrapgen.ts` lines 1-9; `tablescript/xhierarchy.ts` lines 1-100
  Baseline evidence: 170 fragments / 5433 bytes; ordered range SHA-256 `7ec16ed9dba9a4a259323295bcb92287a7d96bace88edf84cff8f987913cee8e`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Superseded by .0 historical-data disposition; retain original Scope/digest as inventory only. No physical reading or application verification is claimed for this group; all files and current corpus tests remain.
  Superseded by: `SUPPORTING-SOURCE-READING.0`
  Verification: Further manual reading omitted as historical Lispish application data; existing focused corpus smoke remains green and unchanged. This is scope retirement, not completed reading.
  Commit: `none - superseded without additional reading`

- ID: `SUPPORTING-SOURCE-READING.1.8`
  Status: `pending`
  Goal: Read and understand supporting noncore group 8.
  Scope: `noncore/AmbiTiming.pm` lines 1-214; `noncore/EasyTk.pm` lines 1-788; `noncore/EncounTiming.pm` lines 1-216; `noncore/Global.pm` lines 1-61; `noncore/HDisplay.pm` lines 1-32; `noncore/HLinkSubst.pm` lines 1-152; `noncore/HTML/PathLinks.pm` lines 1-37
  Baseline evidence: 1500 fragments / 44204 bytes; ordered range SHA-256 `40b62d3cefc4bd4f39121ed8fd98919ab71a1b0dc13717cda614f8a4753d80c5`.
  Dependencies: .1.21 authored-spec/EBNF reading and .0 historical-data disposition committed with clean handoff; this begins remaining legacy-code review.
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
  Dependencies: .0 historical-data disposition committed with clean handoff; prioritize current authored specs before remaining legacy-code reading.
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
  Director provenance (2026-09-13, recorded by .0): tclite.spec attempted to capture basic Tcl constructs. A separate historical Perl tclite script walked its returned AST and executed basic Tcl files; that script is no longer in this repository. Preserve grammar-versus-interpreter distinction; determine current behavior from current source/tests rather than assuming the old interpreter is shipped.
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
| 1 | `SUPPORTING-SOURCE-READING.1.17` | `pending` | After clean .0, read current authored specs (1099 fragments/62580 bytes); historical conf/TableScript data and tests remain intact without further manual reading. |

## Decisions

- `2026-09-13` .0 provenance intake: The director explains that old application specs modeled work activities, spec.spec attempted self-description, and tclite.spec returned ASTs executed by a now-absent separate Perl script. The tclite owner SUPPORTING-SOURCE-READING.1.18 retains that history without a current interpreter claim.

- `2026-09-13` .0: Director background identifies .conf, .tk and TableScript .ts as Lispish-era application inputs and clarifies their limited relevance to current LinkedSpec. Current 53-conf/23-TableScript smoke remains useful but does not require further manual application-data reading. Retire .1.2-.1.7, preserve original evidence and every source/test, and prioritize current authored grammar.

- `2026-09-13` director clarification during .1.1: These configurations belong to historical Perl-only handwritten LinkedSpec and no longer apply to FSMGEN; further reading is warranted only where current LinkedSpec specs/tests require them. .0 owns dependency evidence and explicit scope disposition before remaining configuration reading. Existing .1.1 physical evidence remains valid.

- `2026-09-13`: Freeze 21 groups/174 ranges within existing controls. Earlier startup records provide no exact completed baseline-range credit for these 158 files; all remain physically unread in this lane.

## Blockers

- None for current authored-spec reading. Historical fixture/application behavior stays outside current maintenance scope. Existing failures, repair prerequisites, capacity controls and dependency reuse retain their owners.

## Verification Log

- `2026-09-13` .0: Supporting .0 records conf and TableScript as historical Lispish application data, retaining their existing narrow parser-corpus use. The exact focused Phase 0 subtest passes six assertions over 53 conf/23 TableScript/7 EBNF inputs; no obsolete application consumer or dependency build runs. Further manual reading of conf and TableScript data is retired under .1.2-.1.7, with no deletion or reading credit; completed .1.1 and the original 158-file/174-range inventory remain exact. Required supporting code is now 77 files/88 ranges/17291 fragments/673899 bytes in 14 pending groups. Next .1.17 reads shipped backend-neutral specs, followed by EBNF and the remaining legacy-code review. Every prior defect owner and later startup obligation remains.

- `2026-09-13` .1.1: Supporting reading .1.1 completes 29 windows/24 configuration ranges: 1500 fragments/61165 bytes, 23 files through EOF and case-analysis lines 1–3 only. Exact baseline/current identity and independent 174-range coverage pass; physical reading is 1/21. Canonical path facts distinguish caller design inputs and historical templates from supported runtime proof. No new defect is demonstrated and every previous repair remains open. The director identifies these configurations as historical and limits further reading to current test/spec dependencies. Next .0 audits that reachability before remaining configuration reading; no dependency compilation or canonical gate is required for this ordinary reading slice.

- `2026-09-13` decomposition: Exact baseline/current identity and disjoint range reconstruction pass; physical reading remains 0/21. Startup .3.7.0 owns independent candidate/continuity validation and commit.

## Commit Log

- `2026-09-13` .0: `SUPPORTING-SOURCE-READING.0 - reconcile historical Lispish inputs with current corpus use`; activation 0e3423a19addad30c8f932b1f23fb270e22f1677; next .1.17 authored specs after clean proof and empty brief.

- `2026-09-13` .1.1: `SUPPORTING-SOURCE-READING.1.1 - read legacy configuration data and templates`; activation d806aa674f8b0ae8202b78e3f8b40a1b898ede2a; next .0 dependency audit after clean proof and empty brief.

- `2026-09-13`: Decomposition lands with `SESSION-STARTUP-READING.3.7.0`; current Git identifies its commit.

## Changelog

- `2026-09-13` .0: Reconcile historical Lispish provenance and current smoke coverage; supersede six further fixture-reading groups and prioritize current grammar, with no source/test change or omitted-byte credit.

- `2026-09-13` .1.1: Read first exact configuration group; preserve historical source, all repair nodes and remaining reading obligations.

- `2026-09-13`: Define supporting-source reading ownership without changing source bytes or granting reading credit.
