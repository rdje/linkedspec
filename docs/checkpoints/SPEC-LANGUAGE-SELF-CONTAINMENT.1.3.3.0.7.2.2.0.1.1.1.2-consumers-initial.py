"""Run unchanged direct consumers at the exact captured Git/overlay boundary."""
from pathlib import Path
import importlib.util
import hashlib
import json
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('consumers.py')
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
inputs = json.loads(Path(PREFIX+'after-inputs.json').read_bytes())
observations = json.loads(Path(PREFIX+'after.json').read_bytes())
assert observations['complete']
tree = ROOT / observations['input_tree']
plan = ['t/phase0_regression.t','t/actionir_helper_source_provenance.t','t/actionir_basic_regex_source_provenance.t','t/actionir_ast_parser.t','t/actionir_raw_dependency_provenance.t','t/actionir_nested_block_source_spans.t','t/actionir_raw_dependency_compatibility.t','t/canonical_event_occurrence_order.t']
# Keep the complete actual command and both channels; a failed suite never
# becomes a partial successful aggregate.
report = {'revision':inputs['revision'],'runs':[],'complete':False,
          'instrument_sha256':capture.sha(Path(__file__).read_bytes()),
          'executables':{name:capture.sha(Path(shutil.which(name)).resolve().read_bytes()) for name in ('perl','prove')}}
env = {k:v for k,v in os.environ.items() if not k.startswith('LINKEDSPEC_')}
env.update(PERL5LIB='',PERL5OPT='',PERL_HASH_SEED='0',PERL_PERTURB_KEYS='2')
for suite in plan:
    before = capture.verify_tree(tree,inputs['entries'])
    command = ['bash','tools/project_data_run.sh','prove','-v','-Iperl',suite]
    result = subprocess.run(command,cwd=tree,env=env,capture_output=True)
    row = {'command':command,'exit':result.returncode,'stdout':capture.envelope(result.stdout),
           'stderr':capture.envelope(result.stderr),'inputs_before':before}
    report['runs'].append(row)
    Path(PREFIX+'consumers.json').write_text(json.dumps(report,indent=2)+'\n')
    row['inputs_after'] = capture.verify_tree(tree,inputs['entries'])
    Path(PREFIX+'consumers.json').write_text(json.dumps(report,indent=2)+'\n')
    assert result.returncode == 0, suite
    print(suite+' complete',flush=True)
assert report['instrument_sha256'] == capture.sha(Path(__file__).read_bytes())
report['complete'] = True
Path(PREFIX+'consumers.json').write_text(json.dumps(report,indent=2)+'\n')
