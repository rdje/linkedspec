"""Run the authored private-origin RED against the exact retained original tree."""
from pathlib import Path
import hashlib, importlib.util, json, os, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('tap-probe.py')
CAPTURE=PREFIX+'capture.py'
spec=importlib.util.spec_from_file_location('handoff_capture',CAPTURE)
module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
manifest=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'before-observations.json').read_bytes())
tree=ROOT/report['input_tree']
entries=manifest['entries']
assert manifest['overlays']==[str(Path(PREFIX+'origin-fixture.t').relative_to(ROOT))]
before=module.streams.verify_tree(tree,entries)
command=['bash','tools/project_data_run.sh','prove','-v','-Iperl',manifest['overlays'][0]]
result=subprocess.run(command,cwd=tree,env=module.environment(0),capture_output=True)
after=module.streams.verify_tree(tree,entries)
out={'complete':True,'revision':module.REVISION,'producer_sha256':module.streams.sha(Path(__file__).read_bytes()),'capture_sha256':module.streams.sha(Path(CAPTURE).read_bytes()),'inputs_manifest_sha256':module.streams.sha(Path(PREFIX+'before-inputs.json').read_bytes()),'command':command,'exit':result.returncode,'stdout':module.streams.envelope(result.stdout),'stderr':module.streams.envelope(result.stderr),'inputs_before':before,'inputs_after':after,'scope':'Actual authored original RED from the retained complete clean-Git tree plus fixture only; no production change. Public capture may still be running in the same immutable supplied tree; project runtime data is excluded from regular source guards.'}
Path(PREFIX+'before-tap.json').write_text(json.dumps(out,indent=2)+'\n')
print(result.stdout.decode(errors='replace')); print(result.stderr.decode(errors='replace')); print('actual exit:',result.returncode)
