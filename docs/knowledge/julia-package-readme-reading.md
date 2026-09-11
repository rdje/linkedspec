---
id: julia-package-readme-reading
title: Julia package metadata and README examples separate current APIs from historical claims
answers:
  - which Julia package and README bytes have been read at startup
  - which Julia README examples pass on the current installed runtime
  - does Julia MCP construct a parser or semantic index
  - why does Julia README still call semantic queries later work
  - which task owns unwrapped Julia README corpus commands
date: 2026-09-11
status: dated reading and focused diagnostics; documentation repairs remain pending
tags: [julia, startup, reading, documentation, semantic, mcp, storage]
evidence: "JULIA-STARTUP-READING.1.1 reads Manifest 1-88, Project 1-20 and README 1-963: 1071 fragments /65410 baseline-identical bytes. Seven exact README Julia fences pass on Julia 1.12.7, as does the primary canonical JSON example. The semantic checker passes 6/20/128 with rollout 9/9 and admission 6/6 while older README pending claims survive its finite marker/denial checks. Startup .41.2/.41.3/.41.7 own corrections; no runtime change or complete gate is claimed."
reverify:
  - "Run the exact source-example extraction below through repository-managed Python and Julia."
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "Run JULIA_READING_COVERAGE in docs/knowledge/julia-startup-reading-coverage.md."
---

# Reading and package boundary

The first Julia child reads all of `julia/Manifest.toml` and `julia/Project.toml`,
plus `julia/README.md` lines 1–963. It credits 1,071 LF fragments /65,410 bytes,
two complete files and a README prefix. The remaining six README lines belong to
child .1.2. All 95 Julia files still match baseline
`baeb984e36a94a15951cd23d4c52def5064cdaca`; executing later consumers grants no
additional physical-reading credit.

`LinkedSpecJulia` is version 0.1.0 with four direct dependencies: Base64, JSON3,
Random and SHA. Its manifest uses the package-relative `path = "."`, records Julia
1.12.6 and locks five external source trees: JSON3 1.14.3, Parsers 2.8.6,
PrecompileTools 1.3.4, Preferences 1.5.2 and StructTypes 1.11.0. The project declares
Julia 1.12 compatibility. The installed runtime successfully used here is 1.12.7;
this single execution does not prove every compatible interpreter version.
[[julia-project-data-ssd-storage]] owns depot/source locality and
[[julia-local-verification-gate]] owns the complete component gate.

# Exact examples exercised

Seven unmodified Julia fences at README lines 71, 141, 214, 256, 372, 751 and 772
execute together in authored dependency order. They cover source identity and
immutable compilation outcome; typed/raw static queries; ordered semantic events;
derived observation with an unchanged base index; authorized MCP registration,
dispatch, revocation and shutdown; ordinary traced parsing; and staged function
parsing. Their authored assertions pass. Query construction without an assertion
is execution evidence only, not an exhaustive response comparison.

The separate primary example at README lines 512–514 exits zero, has empty stderr
and writes exactly `{"a":1,"b":2}\n`. No package test suite, complete Julia gate,
canonical CI, generated-module matrix or PGEN/RGX build ran for this reading child.

These examples already compile source strings without a physical specification.
The native semantic constructor retains compiled-or-failed source outcomes; query
works over detached immutable projections. MCP accepts a host-created index and
restricts access through authorization and deployment policy. It does not gain
source-authoring, parser-building or execution authority. The proposed builder and
generic/library authoring discussions remain parked.

# Concrete documentation repairs, with existing owners

- Startup `.41.2`: README lines 474–475 still say root topology waits for .4.3,
  despite its current top summary and the admitted root authority.
- Startup `.41.3`: README lines 169–207, 243–250, 311–338 retain pending query/
  runtime/emitted-boundary statements. Some are identifiable milestone snapshots;
  their current-tense transitions need explicit historical framing. In particular,
  “No query symbol is public at this boundary” and “query and runtime observation
  remain later work” must not be mistaken for the API exercised above.
- Startup `.41.7`: README lines 515 and 963 invoke bare `julia` for corpus runs,
  bypassing the documented managed wrapper. This reading did not execute those
  unmanaged commands or infer that they caused an off-volume write. Repair must
  route copyable commands through the wrapper and qualify historical gate counts.

The unchanged semantic checker includes this README at lines 277–284 but validates
required markers and exact forbidden strings at lines 445–463. Its successful
6 fixture groups /20 queries /128 mutations, rollout 9 complete /0 pending and
admission 6 complete /0 pending do not verify every surrounding sentence. This
repeats the mechanism in [[startup-public-teaching-checker-blind-spots]]; the repair
must test the actual misleading claims, not merely retain a passing marker check.
No original README, historical record or runtime source is edited by the intake.

# Reproduce the selected source examples

This extracts the actual fences without rewriting them and writes its diagnostic
script beneath the managed run directory. The source-identity replay above guards
the baseline; inspect any intentional later README delta before reusing indexes.

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_README_EXAMPLES'
from pathlib import Path
import os,re,subprocess
text=Path('julia/README.md').read_text()
blocks=list(re.finditer(r'(?ms)^```julia\n(.*?)^```$',text))
parts=['using LinkedSpecJulia, JSON3, TOML\n']
for index in [0,1,2,3,5,10,11]:
    match=blocks[index]
    parts.append(match[1])
    parts.append('println("PASS README fence '+str(index)+'")\n')
script=Path(os.environ['TMPDIR'])/'readme_examples.jl'
script.write_text('\n'.join(parts))
subprocess.run(['bash','tools/run_julia_project_data.sh','--project=julia',str(script)],check=True)
JULIA_README_EXAMPLES
```
