"""Publish current composed proof while preserving every original rejected capture."""
from pathlib import Path
import ast
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
CLAIM = 'docs/claims/'+LEAF+'.json'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def load(name): return json.loads((ROOT/(PREFIX+name+'.json')).read_bytes())

review = load('capacity-composed-verification')
snapshot = load('capacity-snapshot-verification')
initial = load('capacity-initial-claim')
assert review['complete'] and review['changed_scalars'] == 5 and len(review['composition_controls']) == 13
assert snapshot['complete'] and snapshot['recovery']['regular_inputs'] == 5119
assert len(initial['claims'][0]['durability']['inputs']) == 78
tree = ast.parse((ROOT/(PREFIX+'capacity-final-docs.py')).read_bytes())
statements = [ast.literal_eval(node.value) for node in tree.body if isinstance(node,ast.Assign)
              and any(isinstance(target,ast.Name) and target.id == 'SUMMARY' for target in node.targets)]
assert len(statements) == 1
statement = statements[0]
guarded = ['CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md',
           'ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md',
           'docs/knowledge/replacement-repair-engineering-history-capacity.md','docs/knowledge/routing-decision-accepted-state-gap.md',
           'doctrine/readme_stability/routes.jsonl','docs/history/development-notes/manifest.jsonl']
paths = {row['path'] for row in initial['claims'][0]['durability']['inputs']}
paths.update(guarded)
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(LEAF+'-*') if p.is_file())
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/decisions').glob('*.md'))
paths.update(['README.md','README_POLICY.md','DOCTRINE_ENFORCEMENT.md','COMMIT.md',
              'scripts/check_readme_stability.sh','scripts/check_readme_routing_pressure.pl',
              'scripts/check_claim_verification.sh','tools/check_claim_verification.py',
              'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh'])
publication_path = PREFIX+'capacity-composed-publication.json'
assert publication_path not in paths, 'one-shot publication; do not refresh this capture'
before = {path:sha((ROOT/path).read_bytes()) for path in sorted(paths)}
publication = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),
               'guarded_inputs':before,'continuity_inputs':guarded,
               'initial_declared_inputs':78,'initial_recovered_omitted_guards':7,
               'scope':'Current composed claim-only publication; every current proof input and actual continuity guard is explicit. Original unadmitted claim, complete regular staged graph/delta, producers/errors and observations remain verbatim. No document, history, policy or initial producer replay; canonical receipt is separate admission authority.'}
(ROOT/publication_path).write_text(json.dumps(publication,indent=2)+'\n')
paths.add(publication_path)
inputs = [{'path':path,'sha256':sha((ROOT/path).read_bytes()),
           'role':'producer' if path.endswith(('.py','.pl','.sh')) else 'input'} for path in sorted(paths)]
scope = ('One finite engineering-note rollover and the measured decision-store prerequisites, five exact scalar changes from clean47444428a; '
         'all42 prior archives/rows and127 prior accepted decisions remain exact. Final decision population129 files/13043 lines/959099 bytes. '
         'Initial three-scalar candidate is unadmitted: actual full routing rejects129/128 files and13035/13000 aggregate lines. '
         'Original78-input claim is verbatim and the complete5119-regular staged superset plus reachable clean base/full-index binary delta recovers all inputs, including seven omitted actual publisher continuity guards. '
         'This is a complete regular Git superset, not minimal IO; gitlinks/nonregular payload are metadata-only and uninspected. '
         'Current independent composition and actual production decision functions establish finite storage; retained initial producer proof is historical evidence, not refreshed against the final registry. '
         'The original reviewer KeyError and continuity-writer NameError retain exact used sources and actual combined channels. Distinct original stdout/stderr are unavailable for both. '
         'The first original routing failure has no independently retained before fingerprint; a separate actual guarded recurrence retains both complete channels and unchanged boundary. '
         'The final document adapter is a one-shot continuity journal, not an independently replayed measurement of its intermediate pre-write document state. Current final continuity bytes are explicit claim inputs. '
         'Proposed/missing-status functions authorize separately; .3.1.3 owns full-path diagnosis/repair before private handoff. Current ADR0128 is explicitly accepted and independently checked. '
         'No composed-bypass/runtime/readiness assertion, no new explicit director grant and no unlimited reserve. Exact staged canonical receipt and normal hooks govern admission independently. '
         'No parser/runtime/test/book/CI/hook/checker/dependency implementation changes; other repositories read-only, all project data repository-local/same-volume. Necessary Git/OS/Perl/Python tools are read-only external dependencies.')
claim = {'version':1,'owner':LEAF,'claims':[{
    'name':'finite-composed-engineering-and-decision-capacity','statement':statement,'scope':scope,
    'rederive':{'status':'checked',
               'command':'At the owning committed boundary run bash tools/run_python_project_data.sh '+PREFIX+'capacity-composed-review.py and '+PREFIX+'capacity-snapshot-review.py. Initial plan/apply/review and both continuity writers are one-shot or original-snapshot producers; retain their original channels, do not replay them against changed inputs. Current claim-only publisher: '+PREFIX+'capacity-publish-composed-claim.py.',
               'granularity':json.dumps({'current':review,'initial_snapshot':snapshot['recovery']},sort_keys=True),
               'result':statement},
    'falsify':{'status':'checked','hypothesis':'Matching aggregate capacity or exact routing markers alone establish lossless finite accepted admission with complete producer/input closure.',
              'oracle':'Independent clean Git root/suffix/manifest/archive/decision reconstruction, exact five-scalar comparison, complete alternate-index recovery of every initial regular staged input and actual guarded full routing failure; separate current accepted Status check.',
              'red_control':'Actual initial pressure255/publication0; initial14 evidence corruptions/18 actual thresholds/7 authority denials/5 instrument denials,4 staged graph/patch denials; full initial routing exit1 at both decision controls. Current13 composed corruptions and12 actual decision thresholds/6 authority denials. Status diagnostics remain authorizing, not rejecting controls.'},
    'durability':{'status':'checked','mode':'live','inputs':inputs}}]}
encoded = (json.dumps(claim,indent=2)+'\n').encode()
assert len(encoded) <= 131072, 'bounded claim record'
(ROOT/CLAIM).write_bytes(encoded)
assert before == {path:sha((ROOT/path).read_bytes()) for path in before}, 'no bound input changes during publication'
print(json.dumps({'complete':True,'bound_inputs':len(inputs),'claim_bytes':len(encoded),'canonical_pending':True,'initial_claim_unchanged':True}))
