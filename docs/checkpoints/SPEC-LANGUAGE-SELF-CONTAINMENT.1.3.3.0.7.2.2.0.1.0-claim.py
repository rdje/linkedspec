"""Publish the bounded private channel after source-bound acceptance."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0'
PREFIX = 'docs/checkpoints/'+OWNER+'-'
subprocess.run(['bash','tools/run_python_project_data.sh',PREFIX+'review.py'],cwd=ROOT,check=True)
verified = json.loads((ROOT/(PREFIX+'verification.json')).read_bytes())
inputs = {}
for line in subprocess.check_output(['git','ls-files','--stage','-z','--','perl','specs'],cwd=ROOT).split(b'\0'):
    if not line:
        continue
    metadata,name = line.split(b'\t',1)
    mode,_,stage = metadata.split()
    if mode not in (b'100644',b'100755'):
        continue
    assert stage==b'0'
    inputs[name.decode()] = 'input'
for path in ROOT.glob(PREFIX+'*'):
    assert path.is_file() and not path.is_symlink()
    inputs[str(path.relative_to(ROOT))] = 'producer' if path.suffix in ('.py','.pl','.pm') else 'input'
for row in verified['suites']:
    inputs[row['path']] = 'producer'
for path,role in [
    ('t/actionir_helper_source_provenance.t','producer'),
    ('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py','producer'),
    ('docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md','input'),
    ('docs/linkedspec-book/book.toml','input'),
    ('tools/run_python_project_data.sh','producer'),('tools/project_data_run.sh','producer'),
    ('tools/project_data_env.sh','producer'),('tools/run_mdbook_local.sh','producer'),
    ('tools/run_ci_local.sh','input'),('tests/language-readiness/verify_objectives.py','input'),
]:
    inputs[path]=role
manifest = [{'path':path,'sha256':hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),'role':role}
            for path,role in sorted(inputs.items())]
record = {'version':1,'owner':OWNER,'claims':[{
    'name':'three-contract-private-helper-source-provenance',
    'statement':'The Perl return_general, set_value and if_flow producers retain exact original match positions in an invocation-local private sidecar. Six exact sources across seeds0/1/2 provide18 before/after pairs with identical public event arrays, diagnostics, substitutions, parser dumps and emitted source;39 private origin records satisfy independent scalar-span oracles. The permanent13-group test fails11 groups before and passes all13 after; empty/opaque/caller-error controls pass both. Full Phase0 and ten unchanged consumers pass1199 top-level tests. Twelve actual evidence corruptions reject; two exact examples render.',
    'scope':'Exactly three instrumented contracts and four source owners, activated from clean8d71b3b5cbea894416c14a9fade10968a73a8a5f. Private provenance is source match telemetry, not executable membership or runtime events. Quoted syntactic matches are deliberately retained; current quote corruption/readiness, marker diagnostics and comments remain unresolved with exact successors. No new public event fields, five-callback dependency changes, grammar/helper/backend admission, CI registration or generated format change. Probe routes inspect/compile public Perl outputs but do not execute newly emitted source; existing full Phase0 supplies its own unchanged runtime assertions. No whole-language/family/provenance coverage beyond the three named contracts; recursive/statement/argument frames remain sibling work. Before mode freezes all four owner bytes and explicitly calls the published scanner with an empty sidecar when the private entry is absent; it never invents an old feature or spans. Complete actual TAP, compiler/dump/emission/process channels and rendered chapter remain lossless envelopes. Three fixed seeds are named observations, not a stochastic interval. Repo-owned regular Perl/spec inputs are hash-bound; OS/Perl/public dependency installations are the observed environment, not universal acceptance. Historical mapping claim is frozen at8d71 with unchanged manifest.',
    'rederive':{'status':'checked',
        'command':'bash tools/run_python_project_data.sh '+PREFIX+'tests.py before; bash tools/run_python_project_data.sh '+PREFIX+'capture.py before; bash tools/run_python_project_data.sh '+PREFIX+'tests.py after; bash tools/run_python_project_data.sh '+PREFIX+'capture.py after; bash tools/run_python_project_data.sh '+PREFIX+'consumers.py; bash tools/run_python_project_data.sh '+PREFIX+'book.py; bash tools/run_python_project_data.sh '+PREFIX+'review.py; bash tools/run_python_project_data.sh '+PREFIX+'claim.py',
        'granularity':'Six independently authored original action/source/raw/start-position fixtures, one seeded process per case for each frozen/current mode; complete public arrays/arguments, original generated source/dumps/diagnostics, exact private event/source/scalar-span records. Actual permanent before/after TAP tests object identity, nested and unowned isolation, source validation, opaque/empty/error and inactive passthrough. Eleven unchanged consumer suites and complete rendered chapter.',
        'result':'PASS18 complete before/after public identities,39 independent origin spans, thirteen GREEN provenance groups,1199 unchanged tests and12 rejected evidence controls. The original before command truthfully exits1 with complete13-group/11-failure RED; its empty and opaque/caller-error groups pass. No original input, TAP or captured output is rewritten.'},
    'falsify':{'status':'checked',
        'hypothesis':'A private provenance layer can infer positions by equal raw text, mask original arguments, leak source fields, or change public code generation without detection.',
        'oracle':'Independently authored scalar positions distinguish quoted inner8 from genuine return23 and quoted set6/real23/39. Original raw sources and arguments, before/current full public compiler outputs, actual event-object identity assertions, nested/opaque/error/unowned controls and unchanged runtime consumers independently distinguish those alternatives.',
        'red_control':'Actual frozen-owner permanent tests fail11 of13 groups and pass the two existing behavior guards; after all13 groups pass with identical fixture SHA. Twelve executed in-memory evidence corruptions reject mapping a real return to quoted8, losing a real set origin, public source-field leakage, masked literal arguments, changed substitution, changed diagnostics, changed emitted source, changed Unicode frame, missing seeded process, hidden before failure, hidden after guard failure and changed rendered example. Evidence mutations do not modify production or capture files.'},
    'durability':{'status':'checked','mode':'live','inputs':manifest}
}]}
(ROOT/('docs/claims/'+OWNER+'.json')).write_text(json.dumps(record,indent=2)+'\n')
print(f"claim inputs={len(manifest)} producers={sum(row['role']=='producer' for row in manifest)}")
