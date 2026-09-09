---
id: dart-progressive-nested-authority-gap
title: Dart nested progressive requests can reset child budgets and widen effective grants
answers:
  - "does Dart nested progressive dispatch preserve parent effective authority"
  - "can a Dart progressive child dispatch after its remaining budget reaches zero"
  - "can Dart nested progressive requests widen capabilities and ceilings"
  - "does Dart enforce direct progressive result and diagnostic limits"
  - "which task owns Dart nested progressive budget inheritance"
date: 2026-09-09
status: confirmed-open
tags: [dart, progressive, authority, budgets, source-detail, SESSION-STARTUP-READING]
evidence: "DART-STARTUP-READING.1.15; ten direct private-authority controls, bounded_child_parse_authority.dart dispatchNested line 522, request construction 925-938, safe point 969-996 and effective authority 1159-1228; existing startup .37.1/.37.2 own cross-runtime repair review."
reverify: "Run DART_PROGRESSIVE_LIMITS, the managed Dart command and DART_PROGRESSIVE_LIMITS_VERIFY below; these assert observed pre-repair behavior, not desired acceptance."
---

# Nested limits are not inherited from the active child

ADR 0080 requires stricter effective ceilings and no extension of parent remaining budgets.
The neutral contract's state/capability/ceiling/cancellation rows reinforce those constraints.
The existing source-view expiry defense works, but it does not bind a live nested request
to its parent's effective authority.

`ProgressiveDispatchRequest.dispatchNested` checks view lifetime and forwards arguments
unchanged. Request construction gives the callback a narrowed remainingSteps value, but
binds nestedDispatch directly to the same invocation's dispatch method. That method checks
the invocation-wide remaining steps and newly supplied caller ceilings, while
_effectiveAuthority intersects the selected entry with those supplied caller grants.
Neither path consults the active child's effective grants or remainingSteps.

The ten-case private API probe uses one caller-owned source, the same cancellation token,
ten invocation steps, depth/call ceilings of three, and two distinct logical identities
for nesting. Distinct identities deliberately avoid confusing budget inheritance with
the separate non-decreasing-repeat guard.

| Control | Current result |
| --- | --- |
| Scalar zero, cost one, max_steps/result_nodes one | Accepted; nine invocation steps remain |
| Three-element result under one-node ceiling | Rejected with progressive_result_not_detached |
| Cost two under one-step ceiling | Rejected before callback; ten steps remain |
| Cost eleven under ten invocation steps | Rejected before callback; ten steps remain |
| Callback reads its source at detail none | Returns the supplied source |
| Callback throws 57-byte source-containing text, diagnostic ceiling eight | Failure retains exactly eight bytes: owned-pr |
| Outer cost one consumes its one effective step; nested cost one | Accepted despite outer remainingSteps zero; two calls, eight invocation steps remain |
| Outer has one effective step left; nested cost one | Accepted positive control |
| Outer grants only test, max_steps two and result_nodes one; nested supplies extra, max_steps/result_nodes 100 | Inner receives extra plus test and both 100 ceilings; its reported remaining steps rise from the parent's one to eight |
| Same outer, nested requires extra without widening caller grants | Nested capability denial before inner callback; outer normalizes it to child failure |

The direct numeric/result controls show that the earlier Perl omissions are not identical
in Dart. The diagnostic byte cap is enforced; source input visibility versus outward detail
semantics remains the independently justified review already owned by startup .37.2.
Returning source text alone does not establish an exposure defect. The raw failure-prefix
observation supplies that owner with concrete evidence rather than a new policy.

`SESSION-STARTUP-READING.37.1` owns nested budget/grant inheritance and cross-runtime
repair decomposition; .37.2 owns diagnostic/source-detail interpretation and containment;
.37.3 owns recurring/public closeout. Required reading and policy review still precede fixes.
The selected 82 Dart tests and unchanged neutral progressive checker pass, including existing
emitted-source consumers. These ten new cases use private callbacks directly: no fresh
authored, emitted or other-backend reproduction of the gap is claimed. Prior passing
capability-minimum fixtures do not prove narrowing across nested requests.

## Exact reproduction

```sh
bash tools/project_data_run.sh python3 - <<'DART_PROGRESSIVE_LIMITS'
from pathlib import Path
Path('.linkedspec-data/scratch/dart115-progressive-probe.dart').write_text(r'''import 'dart:convert';
import '../../dart/lib/src/runtime/bounded_child_parse_authority.dart';

const source = 'owned-probe-text';
ProgressiveCeilings limits(int steps, {int nodes = 1}) => ProgressiveCeilings(
  sourceDetail: ProgressiveSourceDetail.none,
  policyModes: ['fail-only'], maxSteps: steps, maxResultNodes: nodes,
  maxDiagnosticBytes: 8,
);
ProgressiveRegistryEntry entry(String id, ProgressiveCompiledAuthority callback,
    ProgressiveCeilings ceilings, List<String> capabilities) =>
  ProgressiveRegistryEntry(parserId: id, compiledAuthority: callback,
    fingerprint: 'sha256:' + '0' * 64, allowedTopRules: ['Top'],
    capabilities: capabilities, ceilings: ceilings);
ProgressiveInvocation invocation(ProgressiveRegistry registry,
    ProgressiveCancellationToken token) => registry.startInvocation(
  ProgressiveInvocationConfig(sources: {'source': source}, sourceId: 'source',
    cancellationToken: token, clock: ProgressiveClock(() => 0), deadlineTick: 10,
    remainingSteps: 10, maxDepth: 3, maxCalls: 3),
);
ProgressiveDispatchArguments arguments(String id, ProgressiveCancellationToken token,
    ProgressiveCeilings ceilings, int cost,
    {List<String> capabilities = const ['test'],
     List<String> required = const []}) =>
  ProgressiveDispatchArguments(origin: 'reading-probe', parserId: id, topRule: 'Top',
    span: {'source_id': 'source', 'start': 0, 'end': source.runes.length,
      'provenance': 'test'}, callerCapabilities: capabilities,
    requiredCapabilities: required, callerCeilings: ceilings,
    requiredSourceDetail: ProgressiveSourceDetail.none, childToken: token, cost: cost);

void single(String name, ProgressiveCompiledAuthority callback, int cost) {
  final token = ProgressiveCancellationToken();
  final ceiling = limits(1);
  Map<String, Object?>? seen;
  final registry = ProgressiveRegistry(entries: [
    entry('probe-v1', (request) {
      seen = request.effective.toJson();
      return callback(request);
    }, ceiling, ['test']),
  ]);
  final state = invocation(registry, token);
  final out = <String, Object?>{'case': name};
  try {
    out['result'] = state.dispatch(arguments('probe-v1', token, ceiling, cost));
    out['accepted'] = true;
  } on ProgressiveDispatchException catch (error) {
    out['accepted'] = false;
    out['code'] = error.code;
    final record = error.toJson();
    if (record.containsKey('child_diagnostic')) {
      out['diagnostic'] = record['child_diagnostic'];
      out['diagnostic_bytes'] = utf8.encode(record['child_diagnostic']! as String).length;
    }
  }
  out['remaining'] = state.remainingSteps;
  if (seen != null) out['effective'] = seen;
  print(jsonEncode(out));
}

void nested(String name, {required int outerSteps, required bool widen,
    bool requireExtra = false}) {
  final token = ProgressiveCancellationToken();
  final outer = limits(outerSteps);
  final wider = limits(100, nodes: 100);
  final out = <String, Object?>{'case': name};
  final registry = ProgressiveRegistry(entries: [
    entry('outer-v1', (request) {
      out['outer_effective'] = request.effective.toJson();
      out['outer_remaining'] = request.remainingSteps;
      try {
        return request.dispatchNested(arguments('inner-v1', token,
          widen ? wider : outer, 1,
          capabilities: widen ? ['test', 'extra'] : ['test'],
          required: requireExtra ? ['extra'] : []));
      } on ProgressiveDispatchException catch (error) {
        out['nested_code'] = error.code;
        rethrow;
      }
    }, outer, ['test']),
    entry('inner-v1', (request) {
      out['inner_effective'] = request.effective.toJson();
      out['inner_remaining'] = request.remainingSteps;
      return 0;
    }, wider, ['test', 'extra']),
  ]);
  final state = invocation(registry, token);
  try {
    out['result'] = state.dispatch(arguments('outer-v1', token, outer, 1));
    out['accepted'] = true;
  } on ProgressiveDispatchException catch (error) {
    out['accepted'] = false;
    out['code'] = error.code;
  }
  out['remaining'] = state.remainingSteps;
  out['calls'] = state.totalCalls;
  print(jsonEncode(out));
}

void main() {
  single('bounded_scalar', (_) => 0, 1);
  single('result_nodes', (_) => [1, 2, 3], 1);
  single('steps_above_ceiling', (_) => 0, 2);
  single('steps_above_remaining', (_) => 0, 11);
  single('source_view_above_detail', (r) => r.sourceView.text, 1);
  single('diagnostic_above_limits',
    (r) => throw (r.sourceView.text + ':' + 'x' * 40), 1);
  nested('nested_zero_parent_remaining', outerSteps: 1, widen: false);
  nested('nested_positive_parent_remaining', outerSteps: 2, widen: false);
  nested('nested_wider_grants', outerSteps: 2, widen: true, requireExtra: true);
  nested('nested_narrow_grant_control', outerSteps: 2, widen: false, requireExtra: true);
}
''')
DART_PROGRESSIVE_LIMITS
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart115-progressive-probe.dart > .linkedspec-data/scratch/dart115-progressive-probe.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_PROGRESSIVE_LIMITS_VERIFY'
from pathlib import Path
import json
rows=[json.loads(s) for s in Path('.linkedspec-data/scratch/dart115-progressive-probe.log').read_text().splitlines()]
names=['bounded_scalar','result_nodes','steps_above_ceiling','steps_above_remaining',
'source_view_above_detail','diagnostic_above_limits','nested_zero_parent_remaining',
'nested_positive_parent_remaining','nested_wider_grants','nested_narrow_grant_control']
assert [r['case'] for r in rows]==names
base=dict(capabilities=['test'],source_detail='none',policy_modes=['fail-only'],
max_steps=1,max_result_nodes=1,max_diagnostic_bytes=8)
expected=[
dict(case=names[0],result=0,accepted=True,remaining=9,effective=base),
dict(case=names[1],accepted=False,code='progressive_result_not_detached',remaining=9,effective=base),
dict(case=names[2],accepted=False,code='progressive_budget_exhausted',remaining=10),
dict(case=names[3],accepted=False,code='progressive_budget_exhausted',remaining=10),
dict(case=names[4],result='owned-probe-text',accepted=True,remaining=9,effective=base),
dict(case=names[5],accepted=False,code='progressive_child_failed',diagnostic='owned-pr',
diagnostic_bytes=8,remaining=9,effective=base),
]
for i,steps in [(6,1),(7,2)]:
    effective={**base,'max_steps':steps}
    expected.append(dict(case=names[i],outer_effective=effective,outer_remaining=steps-1,
    inner_effective=effective,inner_remaining=steps-1,result=0,accepted=True,remaining=8,calls=2))
outer={**base,'max_steps':2}
expected.append(dict(case=names[8],outer_effective=outer,outer_remaining=1,
inner_effective={**base,'capabilities':['extra','test'],'max_steps':100,'max_result_nodes':100},
inner_remaining=8,result=0,accepted=True,remaining=8,calls=2))
expected.append(dict(case=names[9],outer_effective=outer,outer_remaining=1,
nested_code='progressive_capability_denied',accepted=False,code='progressive_child_failed',
remaining=9,calls=1))
assert rows==expected,(rows,expected)
print('PASS ten exact pre-repair Dart private-authority controls; nested widening remains open')
DART_PROGRESSIVE_LIMITS_VERIFY
```
