"""Publish identities after source-bound review; no runtime repair claim."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0'
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
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
    assert stage == b'0'
    inputs[name.decode()] = 'input'
for path in ROOT.glob(PREFIX+'*'):
    assert path.is_file() and not path.is_symlink()
    inputs[str(path.relative_to(ROOT))] = 'producer' if path.suffix in ('.py','.pl','.t') else 'input'
for row in verified['suites']:
    inputs[row['path']] = 'producer'
for path,role in [
    ('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py','producer'),
    ('docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md','input'),
    ('docs/linkedspec-book/book.toml','input'),
    ('tools/run_python_project_data.sh','producer'),('tools/project_data_run.sh','producer'),
    ('tools/project_data_env.sh','producer'),('tools/run_mdbook_local.sh','producer'),
    ('tools/run_ci_local.sh','input'),('tests/language-readiness/verify_objectives.py','input'),
]:
    inputs[path] = role
manifest = [{'path':path,'sha256':hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),'role':role}
            for path,role in sorted(inputs.items())]
record = {'version':1,'owner':OWNER,'claims':[{
    'name':'helper-scan-occurrence-mapping-ambiguity',
    'statement':'Two exact seed0 public AST/substitution/diagnostic probes falsify two candidate raw-key occurrence mappers: one drops a genuine return, one reorders real set calls. The exact preserved fixture replays all13 groups, with11 expected failures and two genuine unsupported/raw and opaque-return guards passing. Four unchanged consumer suites pass45 top-level tests; seven source-bound scanner families are inventoried, twelve executed evidence corruptions reject, and two exact book examples render.',
    'scope':'Evidence/ownership decomposition only at unchanged production ea45d933d6af8776bb4205514f423e3b7627af0d. Candidate mapper simulations are not production mutants or a repaired compiler. Current helper arrays and typed spans identify the ambiguity; no new public event schema, lexer/grammar/backend admission or global lexical event order. Inventory counts describe textual construction/composition sites, not runtime reachability or language completeness. One fixed seed is a named observation, not a probability estimate. Original tests-before producer/command/TAP and fixture SHA are retained; replay uses the exact fixture under the checkpoint path rather than installing a failing standard test. Initial regex expected1 is preserved and corrected to0 before any new runtime-value measurement. The26-case parent input list and four earlier decoded occurrence records remain preparation evidence; this leaf does not claim26 native/fresh executions. Earlier diagnosis is frozen historically at ea45 with unchanged manifest; only its existing scope supplies historical66-pair/22-trace facts. Current production/spec/standard-test/CI/governance bytes remain activation-identical; diagnostic provenance/comments and the Unicode trace defect retain separate owners. Host Perl/OS/toolchain installations are the observed environment, not universal dependency acceptance.',
    'rederive':{'status':'checked',
        'command':'bash tools/run_python_project_data.sh '+PREFIX+'mapping.py; bash tools/run_python_project_data.sh '+PREFIX+'replay-red.py; bash tools/run_python_project_data.sh '+PREFIX+'inventory.py; bash tools/run_python_project_data.sh '+PREFIX+'consumers.py; bash tools/run_python_project_data.sh '+PREFIX+'book.py; bash tools/run_python_project_data.sh '+PREFIX+'review.py; bash tools/run_python_project_data.sh '+PREFIX+'claim.py',
        'granularity':'Exact authored source/typed scalar spans and ordered full helper arrays for two public probe cases; independently declared real occurrence lists; complete actual stdout/stderr envelopes, original/replayed thirteen-group TAP, four full unchanged consumer streams and actual rendered chapter. Source-bound family inventory and frozen three-owner modules remain recoverable.',
        'result':'PASS read-only review and12 rejected evidence controls,45 unchanged consumer tests, two actual candidate mismatches and complete expected RED replay. The preserving replay command exits0 after explicitly asserting the child prove exit1; it never labels the failing runtime fixture green.'},
    'falsify':{'status':'checked',
        'hypothesis':'Equal raw text plus per-key cursors is sufficient to select genuine occurrences while preserving scan order.',
        'oracle':'Independently authored source positions and typed AST string/call spans distinguish a quoted inner return suppressed by the outer regex match and an interleaved quoted/real set twin. Actual helper arrays feed each proposed mapper; desired source occurrence lists remain independent of scanner output and mapper implementation.',
        'red_control':'Both actual candidate simulations disagree with their independent occurrence oracles. Twelve executed in-memory evidence corruptions reject hidden real return, hidden quoted set, erased typed string, moved real span, concealed false drop, concealed wrong order, truncated RED plan, hidden failing group, concealed true guard failure, omitted scanner family, changed family digest and changed book example. Evidence controls do not mutate production or captures.'},
    'durability':{'status':'checked','mode':'live','inputs':manifest}
}]}
(ROOT/('docs/claims/'+OWNER+'.json')).write_text(json.dumps(record,indent=2)+'\n')
print(f"claim inputs={len(manifest)} producers={sum(row['role']=='producer' for row in manifest)}")
