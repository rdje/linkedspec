---
id: conformance-staged-perl-consumer-reading
title: Perl staged-enrichment consumer evidence preserves exact authority and carrier boundaries
answers:
  - what staged enrichment declaration and scheduling consumers are read in group 87
  - how do I replay only the completely read staged enrichment test prefix
  - which staged target and identity repairs remain open after prefix reading
date: 2026-09-22
status: complete staged consumer reading through 2108; fresh 143/322 proof; known repairs remain open
tags: [conformance, perl, staged-parsing, reading, tests]
evidence: "CONFORMANCE-SOURCE-READING.1.87 at d95047136 reads nine windows/1500 fragments/54923 bytes. Exact prefix 1–1461 passes 135 top-level/227 nested results; later payload and carrier proof remains .1.88-owned."
evidence_group88: "CONFORMANCE-SOURCE-READING.1.88 completes lines1505–2108; the full consumer passes143 top-level/322 nested results, with unchanged staged123/public129 governance. Generated plan validation and same-process loading remain distinct from executable reconstruction or fresh-process proof."
reverify: "Run t/staged_ast_enrichment_perl_contract.t with perl -Iperl through tools/project_data_run.sh for current full proof. STAGED_PREFIX_READING below preserves the earlier prefix proof; run tools/check_staged_ast_enrichment_contract.py, tools/check_typed_source_location_contract.py and tools/check_recognition_transaction_contract.py through tools/run_python_project_data.sh."
---

The complete staged consumer is read through line 2108 under .1.88. Fresh full
execution passes 143 top-level and 322 nested TAP results; neutral governance
passes 123 base/129 public mutations. Earlier .1.87 prefix proof below stays exact.

The suffix executes contained decreasing derived lineage and rejects exact cycle,
non-decrease, depth/call/step overflow before the second callback. Cancellation
and deadline controls cover entry and child safe points. Cumulative result nodes,
bounded diagnostic sentinels, narrowed steps, direct/ordered rebasing, transaction
denial and expired callback contexts each retain explicit observations.

Four carriers compare full AST, sidecars, diagnostics, cache and resource results.
Retained inputs prove four distinct snapshots, sixteen compiled callbacks, four
tokens, four cancellation callbacks and four clocks. Cache counters start at one
miss, zero hits per route. The explicit output-mutation observation changes the
first result and checks the second, rather than testing every output pair.
The normalized route calls a newly compiled descriptor handler inside the runtime
wrapper. The plan route validates its minimal label/family plan and then executes
loaded generated source. Both generated packages share the current process.

Function-body v1, dedicated marker provenance, all stitch/failure policies,
frozen resolution, typed queue order, cache retries and first breadth-first proof
remain the earlier prefix's valid observations. The ten neutral chain rows use a
case evaluator; the later recursive tests execute actual callbacks.
Competing destinations remain [[staged-target-preparation-gaps]] / startup .73;
identity lifetime remains [[perl-staged-marker-retired-identity-risk]] / startup .44.
Passing finite fixtures close neither repair and grant no new behavior or admission.

## Historical .1.87 complete-prefix replay

The source-pinned prefix replay relocates FindBin for scratch execution and appends
only done_testing. It grants no reading or execution credit beyond line 1461.

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'STAGED_PREFIX_READING'
from pathlib import Path
import hashlib, subprocess, re, json
path = Path('t/staged_ast_enrichment_perl_contract.t')
lines = path.read_bytes().splitlines(True)
prefix = b''.join(lines[:1461])
assert hashlib.sha256(prefix).hexdigest() == '65f31903dd786eea22daf006e65e51d070a1e541abd8279c31d671e29720d40e'
assert lines[1460].strip() == b'};'
assert lines[1462].startswith(b"subtest 'payload identity")
source = prefix.decode()
assert source.count('use FindBin qw($Bin);') == 1
source = source.replace('use FindBin qw($Bin);', "use Cwd ();\nmy $Bin = Cwd::abs_path('t');", 1)
source += '\ndone_testing;\n'
output = Path('.linkedspec-data/scratch/staged-prefix-reading-reverify')
output.mkdir(parents=True, exist_ok=True)
test = output / 'complete-prefix.t'
test.write_text(source)
result = subprocess.run(['perl', '-Iperl', str(test)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
(output / 'complete-prefix.tap').write_bytes(result.stdout)
tap = result.stdout.decode()
counts = (len(re.findall(r'^ok \d+', tap, re.M)), len(re.findall(r'^ +ok \d+', tap, re.M)))
assert result.returncode == 0 and not re.search(r'^\s*not ok', tap, re.M)
assert counts == (135, 227), counts
print(json.dumps(dict(source=str(path), end=1461, top=counts[0], nested=counts[1], exit=result.returncode)))
STAGED_PREFIX_READING
```


Related: [[conformance-perl-consumer-reading]], [[conformance-source-reading-coverage]].
