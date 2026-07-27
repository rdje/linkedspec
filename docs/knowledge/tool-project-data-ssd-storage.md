---
id: tool-project-data-ssd-storage
title: Python, Knowledge Map, mdBook, and tool output stay on the repository filesystem
answers:
  - how should a LinkedSpec Python checker be run
  - where does LinkedSpec store Python bytecode
  - where do Unicode contract checkers create temporary files
  - can KM_OUTPUT point to another filesystem
  - how does Knowledge Map validate generated output
  - can mdBook output be written to another volume
  - how are mdBook destination overrides validated
  - which oracle proves tool project data stays on the SSD
  - how many Python temporary allocation owners exist
  - how many shell temporary allocation owners exist
  - how many Python checker entrypoints exist
  - where do TAP and oracle capture artifacts go
  - what old tool data was deleted from private tmp
date: 2026-07-26
status: current
tags: [storage, ssd, python, bytecode, knowledge-map, mdbook, tap, oracle, temporary-data, portability]
evidence: "PROJECT-DATA-SSD-ROOTING.2.6 adds tools/run_python_project_data.sh and tools/test_tool_project_data_storage.sh; exports retained PYTHONPYCACHEPREFIX from tools/project_data_env.sh; gives both Unicode generators explicit validated scratch; configures generic KM_OUTPUT_VALIDATOR in .knowledge_map.conf; validates Knowledge Map output before/after generation and mdBook output before/after build; routes canonical/current checker commands; and deletes the exact unreferenced 88-line /private/tmp/linkedspec-julia-reverify-cards.txt after classification."
reverify: "bash tools/test_tool_project_data_storage.sh; bash knowledge-map/scripts/check_knowledge_map.sh; bash tools/run_mdbook_local.sh"
---

# Tool project data on repository storage

Use `bash tools/run_python_project_data.sh tools/<checker>.py [args...]` for a maintained Python checker. The
wrapper accepts a repository-root-relative nonsymlink script, enters managed scratch, and retains imported bytecode
under `/.linkedspec-data/cache/python-pycache/`. The two Python checkers that regenerate Unicode artifacts also
select an explicit same-device temporary root, including when invoked directly.

LinkedSpec configures the portable Knowledge Map bundle's optional `KM_OUTPUT_VALIDATOR` through the repo-relative
environment initializer. Generation validates before creating output and after writing it; checking validates the
configured committed map before use. The mdBook wrapper resolves default, environment, and CLI destinations using
the current checkout, rejects another-filesystem or symlink output before launch, and verifies the created output.

`tools/test_tool_project_data_storage.sh` freezes three Python temporary owners, 12 actual shell allocator owners,
and 19 Python checker entrypoints. It proves real bytecode, map, HTML, CLI workspace, TAP, and oracle capture paths
use the repository device and hostile external destinations remain absent. Its deliberate cross-volume reads are
limited to device and exact-path absence checks required for that rejection proof.

The old-root census found one missed disposable audit list,
`/private/tmp/linkedspec-julia-reverify-cards.txt` (88 lines, 4,646 bytes). Metadata, content, and repository-reference
checks proved it contained only derived knowledge-card path names; the exact file was deleted, and both frozen old
temporary roots then contained zero exact LinkedSpec tool residue.
