---
id: dart-staged-resource-boundary-gaps
title: Dart staged diagnostics can exceed byte allowances and exhausted call counters can wrap
answers:
  - "can Dart staged diagnostics exceed max_diagnostic_bytes"
  - "does the staged truncation sentinel fit a tiny byte ceiling"
  - "why do staged siblings retain diagnostics after their byte allowance is exhausted"
  - "can Dart staged totalCalls overflow at the signed integer limit"
  - "does Dart reject an exhausted staged call counter before incrementing"
  - "which tasks own staged diagnostic and call-count boundary repairs"
  - "why do existing staged resource tests miss retained byte overruns"
date: 2026-09-10
status: confirmed private scheduler gaps; repairs owned by DART-STARTUP-READING.2.17 and .2.18 behind startup gates
tags: [dart, staged-parsing, diagnostics, budgets, integer-overflow, startup, defect]
evidence: "Reading .1.26 probes the admitted private recursive API with existing fixture builders. Seven diagnostic controls show three retained-byte overruns and four accepted/rejected controls; four call controls show one signed wrap and three ordinary/boundary controls. All 44 selected runtime tests and staged governance 123 neutral/129 public mutations pass. No repair, other-backend failure or fresh production-carrier defect proof is claimed."
reverify:
  - "Run DART_STAGED_RESOURCE_PROBE, the managed Dart command, and DART_STAGED_RESOURCE_VERIFY below; these assert exact pre-repair behavior."
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

# Exact staged resource boundary observations

Owner `DART-STARTUP-READING.1.26` activates from clean
`692c5363e2dbdde7def2e8b3697aa65fac737858`. The executable source remains identical.
These are private `enrichStagedRecursively` calls with caller-frozen compiled
callbacks and the existing admitted consumer's logical marker/snapshot builders.
They do not establish the same failure through authored native, reconstructed,
generated or emitted production execution, or through another backend.

| Diagnostic allowance | Markers | Retained diagnostic bytes | Remaining | Result |
| --- | ---: | ---: | ---: | --- |
| 0 | 1 | none | unavailable | Invalid snapshot before callback |
| 1 | 1 | 187 | 0 | Truncation sentinel exceeds allowance |
| 64 | 1 | 188 | 0 | Truncation sentinel exceeds allowance |
| 256 | 1 | 189 | 67 | Sentinel fits |
| 4096 | 1 | 1671 | 2425 | Complete child diagnostic fits |
| 64 | 2 | 188 + 187 = 375 | 0 | Second sentinel retained with maximum_bytes 0 |
| 4096 | 2 | 1671 + 1671 = 3342 | 754 | Both complete diagnostics fit |

The byte measurements use canonical compact UTF-8 JSON for each diagnostic
record, without charging the diagnostic-list wrapper or duplicate sidecar copies.
Even that narrower count exceeds the small allowances.

`_boundedDiagnostic` in `dart/lib/src/runtime/staged_ast_enrichment.dart`
measures the original diagnostic, replaces it with the governed sentinel when
oversized, measures the sentinel, and returns it without another ceiling
decision (lines 2189–2203). It clamps remaining capacity at zero, so that counter
does not prove that retained bytes fit. A later sibling can emit another sentinel.

ADR0088 and the neutral contract require bounded diagnostic bytes and narrowing
authority, while the sentinel has five required context fields. The existing
Dart test at lines 1544–1562 checks its code, maximum_bytes 64, remaining zero
and retained text, but never measures the retained record. Repair .2.17.1 owns
the compatible accounting/representation decision, including a sentinel that
cannot fit and cumulative exhaustion; .2.17.2 enforces it and .2.17.3 closes
carriers and public evidence. No unlimited metadata exemption is inferred.

| Initial calls / maximum | Callbacks | Outcome |
| --- | ---: | --- |
| 31 / 32 | 1 | totalCalls 32 |
| 32 / 32 | 0 | staged_call_limit_exceeded, candidate 33 |
| 9223372036854775806 / 9223372036854775807 | 1 | totalCalls 9223372036854775807 |
| 9223372036854775807 / 9223372036854775807 | 1 | totalCalls -9223372036854775808 |

`_dispatchResourceCheck` computes `invocation.totalCalls + 1` before comparing
against maxCalls (line 1892). At the signed maximum the increment wraps, the
comparison accepts the negative candidate, and line 1905 stores it. The
callback therefore runs despite an exhausted allowance. .2.18.1 owns checked
admission and .2.18.2 owns seed/carrier proof. Ordinary numeric helper repair
.2.12 and progressive startup .37 remain separate.

All 44 selected staged/registry/progressive/typed-source/matching tests pass.
The neutral checker also passes 123 semantic and 129 public mutations. These
existing proofs cover their stated cases; they do not eliminate the measured
boundary gaps. No source or contract correction occurs in the reading slice.

## Reproduction

The generator borrows only the already-read fixture builders from the admitted
test. The probe invokes LinkedSpec's private runtime APIs directly and records
actual outputs; it contains no replacement scheduler implementation.

```bash
bash tools/project_data_run.sh python3 - <<'DART_STAGED_RESOURCE_PROBE'
from pathlib import Path
program = r'''
import 'dart:convert';
import 'dart:io';
import '../../dart/lib/src/runtime/staged_ast_enrichment.dart';
typedef _JsonObject = Map<String, Object?>;
const _markerKind = 'STAGED_PARSE_JOB_MARKER';
_JsonObject _object(Object? x) => (x! as Map).cast<String,Object?>();
List<Object?> _list(Object? x) => (x! as List).cast<Object?>();
_JsonObject _cloneObject(Object? x) => _object(jsonDecode(jsonEncode(x)));
Object? canonical(Object? value) {
  if (value is Map) {
    final keys=value.keys.cast<String>().toList()..sort();
    return <String,Object?>{for(final key in keys) key:canonical(value[key])};
  }
  if(value is List) return <Object?>[for(final v in value) canonical(v)];
  return value;
}
int size(Object? value)=>utf8.encode(jsonEncode(canonical(value))).length;
void main() {
  final contract=_object(jsonDecode(File('capability_conformance/staged_ast_enrichment_contract.json').readAsStringSync()));
  final rows=<Object?>[];
  for(final limits in [(0,1),(1,1),(64,1),(256,1),(4096,1),(64,2),(4096,2)]) {
    final (ceiling,count)=limits; var calls=0;
    final registry=_registry(contract,(request,context) {
      calls++;
      return StagedChildExecution.failure(<String,Object?>{'code':'large_child_failure','detail':'x'*1024});
    });
    try {
    final result=enrichStagedRecursively(
      registry:registry,
      ast:<String,Object?>{'nodes':<Object?>[for(var i=0;i<count;i++) _marker(text:'x',start:i,end:i+1,failurePolicy:'keep_text')]},
      options:_enrichmentOptions(maxDiagnosticBytes:ceiling),
      authority:_recursiveAuthority(),
    );
    final bytes=[for(final diagnostic in result.diagnostics) size(diagnostic)];
    rows.add(<String,Object?>{'kind':'diagnostic','ceiling':ceiling,'markers':count,'callbacks':calls,'diagnostic_bytes':bytes,'retained_bytes':bytes.fold<int>(0,(a,b)=>a+b),'remaining':result.resources.remainingDiagnosticBytes,'diagnostics':result.diagnostics,'ast':result.ast});
    } on StagedAstEnrichmentException catch(error) {
      rows.add(<String,Object?>{'kind':'diagnostic','ceiling':ceiling,'markers':count,'callbacks':calls,'error':error.toJson()});
    }
  }
  const maximum=9223372036854775807;
  for(final limits in [(31,32),(32,32),(maximum-1,maximum),(maximum,maximum)]) {
    final (initial,cap)=limits;var calls=0;
    final registry=_registry(contract,(request,context){calls++;return StagedChildExecution.success('ok');});
    try {
      final result=enrichStagedRecursively(registry:registry,ast:<String,Object?>{'payload':_marker(text:'x',end:1)},options:_enrichmentOptions(),authority:_recursiveAuthority(totalCalls:initial,maxCalls:cap));
      rows.add(<String,Object?>{'kind':'calls','initial':initial,'maximum':cap,'callbacks':calls,'total':result.resources.totalCalls,'ast':result.ast});
    } on StagedAstEnrichmentException catch(error) {
      rows.add(<String,Object?>{'kind':'calls','initial':initial,'maximum':cap,'callbacks':calls,'error':error.toJson()});
    }
  }
  stdout.writeln(jsonEncode(rows));
}
'''
s=Path('dart/test/staged_ast_enrichment_contract_test.dart').read_text()
a=s.index('FrozenStagedRegistry _registry('); z=s.index('Matcher _stagedCode(',a)
Path('.linkedspec-data/scratch/dart126-staged-bounds.dart').write_text(program.lstrip('\n')+s[a:z])
DART_STAGED_RESOURCE_PROBE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart126-staged-bounds.dart > .linkedspec-data/scratch/dart126-staged-bounds.json 2> .linkedspec-data/scratch/dart126-staged-bounds.stderr
```

The independent check pins measured bytes, callback counts, error identities,
counter values, source identity and control cases. It is a pre-repair evidence
oracle, not acceptance criteria for keeping the defects.

```bash
bash tools/project_data_run.sh python3 - <<'DART_STAGED_RESOURCE_VERIFY'
from pathlib import Path
import hashlib,json,subprocess
rows=json.loads(Path('.linkedspec-data/scratch/dart126-staged-bounds.json').read_text())
assert len(rows)==11
def measure(v):return len(json.dumps(v,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode())
expected=[(0,1,None,None),(1,1,[187],0),(64,1,[188],0),(256,1,[189],67),(4096,1,[1671],2425),(64,2,[188,187],0),(4096,2,[1671,1671],754)]
for row,(ceiling,count,sizes,remaining) in zip(rows[:7],expected):
    assert row['kind']=='diagnostic' and row['ceiling']==ceiling and row['markers']==count
    if sizes is None:
        assert row['callbacks']==0 and row['error']=={'code':'staged_registry_snapshot_invalid','phase':'prepare','snapshot_component':'max_diagnostic_bytes'}
        continue
    assert row['callbacks']==count
    assert row['diagnostic_bytes']==sizes==[measure(d) for d in row['diagnostics']]
    assert row['retained_bytes']==sum(sizes) and row['remaining']==remaining
    assert row['ast']=={'nodes':['x']*count}
    assert [d['code'] for d in row['diagnostics']]==['staged_child_failed' if ceiling==4096 else 'staged_diagnostic_truncated']*count
assert [d['maximum_bytes'] for d in rows[5]['diagnostics']]==[64,0]
assert sum(row['retained_bytes']>row['ceiling'] for row in rows[:7] if 'retained_bytes' in row)==3
maximum=9223372036854775807
for row,(initial,cap,callbacks,total) in zip(rows[7:],[(31,32,1,32),(32,32,0,None),(maximum-1,maximum,1,maximum),(maximum,maximum,1,-9223372036854775808)]):
    assert row['kind']=='calls' and row['initial']==initial and row['maximum']==cap and row['callbacks']==callbacks
    if total is None:
        assert row['error']['code']=='staged_call_limit_exceeded' and row['error']['calls']==33
    else:
        assert row['total']==total and row['ast']=={'payload':'ok'}
assert not Path('.linkedspec-data/scratch/dart126-staged-bounds.stderr').read_bytes()
src=Path('dart/lib/src/runtime/staged_ast_enrichment.dart')
assert src.read_bytes()==subprocess.check_output(['git','show','692c5363e2dbdde7def2e8b3697aa65fac737858:'+str(src)])
text=src.read_text()
assert 'final candidateCalls = invocation.totalCalls + 1;' in text
a=text.index('Map<String, Object?> _boundedDiagnostic(');z=text.index('StagedAstEnrichmentException _exceptionFromDiagnostic(',a)
bounded=text[a:z]
assert bounded.count('if (bytes > maximum)')==1 and 'invocation.remainingDiagnosticBytes - bytes' in bounded
for path in ['.linkedspec-data/scratch/dart126-staged-bounds.dart','.linkedspec-data/scratch/dart126-staged-bounds.json']:
    b=Path(path).read_bytes();print(json.dumps({'path':path,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}))
print('PASS 11 exact private scheduler controls: 3 diagnostic overruns, 1 call wrap, 7 boundary/ordinary controls; no repair or fresh production-carrier claim')
DART_STAGED_RESOURCE_VERIFY
```

Related: [[dart-staged-ast-enrichment-recursive-authority]],
[[dart-staged-ast-enrichment-current-depth-authority]],
[[general-staged-ast-enrichment-neutral-contract]],
[[dart-progressive-nested-authority-gap]].
