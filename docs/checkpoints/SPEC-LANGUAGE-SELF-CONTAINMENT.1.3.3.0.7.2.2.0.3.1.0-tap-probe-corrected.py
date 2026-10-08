"""Run the authored private-origin RED against the exact original tree with only the corrected authored expectation."""
from pathlib import Path
import hashlib, importlib.util, json, os, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('tap-probe-corrected.py')
CAPTURE=PREFIX+'capture.py'
spec=importlib.util.spec_from_file_location('handoff_capture',CAPTURE)
module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
manifest=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'before-observations.json').read_bytes())
original=ROOT/report['input_tree']
entries=manifest['entries']
module.streams.verify_tree(original,entries)
import tempfile
scratch=ROOT/'.linkedspec-data/scratch/private-source-handoff'
tree=Path(tempfile.mkdtemp(prefix='corrected-red-',dir=scratch))
assert tree.stat().st_dev==ROOT.stat().st_dev
for entry in entries:
    target=tree/entry['path']; target.parent.mkdir(parents=True,exist_ok=True)
    raw=(original/entry['path']).read_bytes()
    if entry['overlay'] if 'overlay' in entry else False:
        raw=(ROOT/entry['path']).read_bytes();entry['sha256']=module.streams.sha(raw);entry['bytes']=len(raw)
    target.write_bytes(raw);target.chmod(int(entry['mode'][-3:],8))
manifest['scope']+=' Corrected authored copied-array expectation only; production is original clean Git.'
Path(PREFIX+'before-corrected-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
assert manifest['overlays']==[str(Path(PREFIX+'origin-fixture.t').relative_to(ROOT))]
before=module.streams.verify_tree(tree,entries)
command=['bash','tools/project_data_run.sh','prove','-v','-Iperl',manifest['overlays'][0]]
result=subprocess.run(command,cwd=tree,env=module.environment(0),capture_output=True)
after=module.streams.verify_tree(tree,entries)
out={'complete':True,'revision':module.REVISION,'producer_sha256':module.streams.sha(Path(__file__).read_bytes()),'capture_sha256':module.streams.sha(Path(CAPTURE).read_bytes()),'inputs_manifest_sha256':module.streams.sha(Path(PREFIX+'before-corrected-inputs.json').read_bytes()),'command':command,'exit':result.returncode,'stdout':module.streams.envelope(result.stdout),'stderr':module.streams.envelope(result.stderr),'inputs_before':before,'inputs_after':after,'scope':'Actual authored original RED from the retained complete clean-Git tree plus fixture only; no production change. Public capture continues in a separate immutable supplied tree; project runtime data is excluded from regular source guards.'}
Path(PREFIX+'before-corrected-tap.json').write_text(json.dumps(out,indent=2)+'\n')
print(result.stdout.decode(errors='replace')); print(result.stderr.decode(errors='replace')); print('actual exit:',result.returncode)
