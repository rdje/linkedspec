---
id: project-data-storage-locality-doctrine
title: Structural doctrine blocks off-repository project-storage defaults
answers:
  - which checker enforces project data storage locality
  - what does the PROJECT DATA STORAGE doctrine reject
  - which tracked files does the project storage doctrine scan
  - why may inert absolute path fixtures remain in tests
  - are Knowledge Map reverify commands checked for storage locality
  - are documented output commands checked for storage locality
  - does the pre commit hook enforce repository filesystem project data
  - does local CI enforce repository filesystem project data
  - how many project storage classifier cases exist
  - why did Toolbox stop writing diagnostics to the operating system temporary root
  - which project data task follows the structural doctrine
date: 2026-07-27
status: current
tags: [architecture, storage, filesystem, ssd, doctrine, enforcement, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.4.1 adds scripts/check_project_data_storage_locality.sh as the registered PROJECT-DATA-STORAGE structural doctrine. It scans tracked code, tests, tools, configuration, README/Toolbox/public-book guidance, and executable scalar or list-form reverify commands in Knowledge cards. It rejects operating-system-temp, developer-home, unrooted cache/depot/build/output, and concrete external storage defaults while accepting explicit caller inputs, inert path/privacy fixtures, external executables/system libraries, rejection-test probes, root-relative operands, and repository-derived storage. Process proof .4.2 adds bare maintained Dart pub/format/analyze/test/run rejection, scalar/list-form Knowledge mutations, an exact inert usage-label exception, and the process oracle's exact contained hostile-cache injection, bringing the embedded rejected/accepted corpus to 28 cases. The registry contains six doctrines, and hostile outside-cwd routing covers 38 entrypoints. Toolbox TAP/diff/focused-test captures use a checkout-derived diagnostic directory. Direct, registry, routing, all six storage oracles, and the relocated process oracle pass with zero managed runs."
reverify: "bash -n scripts/check_project_data_storage_locality.sh && bash scripts/check_project_data_storage_locality.sh && bash scripts/check_doctrines.sh && bash tools/test_project_data_workflow_routing.sh && bash tools/project_data_run.sh --list"
---

`scripts/check_project_data_storage_locality.sh` is a fast read-only structural gate for ADR `0053`. Its governed
surface includes tracked runtime/tool/test/configuration text, current root guidance, every mdBook chapter, and the
`reverify:` command of each Knowledge fact. Cumulative history, task evidence, ADR rationale, and fact-card evidence
may accurately describe old external paths; they are not executable defaults and are not treated as current
commands.

The classifier rejects concrete off-repository storage environment assignments, operating-system temporary
fallbacks, developer-home package caches, bare maintained Dart command surfaces, unrooted storage fallbacks,
temporary allocator templates, active config destinations, and documented output paths. It deliberately accepts root-relative operands, checkout-derived
storage, explicit caller inputs, inert privacy/path values, necessary external executables and libraries, and
hostile external locations read only by rejection tests, and the exact inert Dart CLI usage label. Twenty-eight
embedded examples keep both sides of that boundary mutation-sensitive, including scalar and list-form Knowledge
reverification commands.

The doctrine is registered once as `PROJECT-DATA-STORAGE`. The existing driver makes it part of pre-commit and
local CI enforcement, while the routing oracle proves the checker initializes and enters repository storage before
scanning. Structural enforcement `.4.1` and process-level opened-path proof `.4.2` compose the completed
enforcement parent.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[repository-root-path-portability]], [[project-data-final-residue-proof]],
[[project-data-process-locality-proof]].
