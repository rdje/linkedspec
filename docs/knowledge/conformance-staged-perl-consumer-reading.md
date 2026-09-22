---
id: conformance-staged-perl-consumer-reading
title: Perl staged-enrichment reading separates the complete executable prefix from later carrier proof
answers:
  - what staged enrichment declaration and scheduling consumers are read in group 87
  - how do I replay only the completely read staged enrichment test prefix
  - which staged target and identity repairs remain open after prefix reading
date: 2026-09-22
status: staged consumer read through 1504; execution through 1461; suffix and repairs remain open
tags: [conformance, perl, staged-parsing, reading, tests]
evidence: "CONFORMANCE-SOURCE-READING.1.87 at d95047136 reads nine windows/1500 fragments/54923 bytes. Exact prefix 1–1461 passes 135 top-level/227 nested results; later payload and carrier proof remains .1.88-owned."
reverify: "Run STAGED_PREFIX_READING below through the project-data wrapper; run tools/check_staged_ast_enrichment_contract.py, tools/check_typed_source_location_contract.py and tools/check_recognition_transaction_contract.py through tools/run_python_project_data.sh."
---

The consumer pins neutral inventories separately from execution. Function-body v1 retains its adapter, phases, errors and body_ast target. Dedicated assignment markers carry direct/ordered Unicode-scalar provenance and detached sidecars; malformed/dynamic declarations and recognition reachability reject statically. Resolution, narrowed authority, normalized job/cache identity, frozen callbacks, four stitch policies, three failure policies and detached results execute through private host APIs. Typed index 2 precedes 10; plan-cache hits still execute fresh results and retry failed children. Individual invalid targets reject before callbacks; a displaced later marker rejects after one callback, matching open startup .73. One-depth enrichment leaves new markers inert. Live recursive proof covers breadth-first order, detached lineage, four fresh contexts and shared steps; later payload/decrease/resource/carrier assertions remain unread.

The exact complete prefix through 1461 passes 135 top-level/227 nested TAP results. Staged governance passes 9 rollout legs/123 base mutations and public 6/17/10/129; typed source passes 14/0/231; recognition passes 138 ActionIR rows/250 calls/58 mutations and 9/9 rollout.

Existing startup .44 identity-lifetime and .73 competing-target repairs remain open, along with all prior defects and required source/book/policy prerequisites. No suffix execution, new runtime defect, repair closure, production change, canonical run, dependency build or push is claimed.

The competing-target mechanism remains [[staged-target-preparation-gaps]];
identity lifetime remains [[perl-staged-marker-retired-identity-risk]].
The ten neutral chain rows exercise their case evaluator, while the completed
recursive subtest executes actual breadth-first callbacks. Their scopes differ.

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
