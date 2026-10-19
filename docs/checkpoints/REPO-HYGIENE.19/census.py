"""Read-only current census using the accepted non-following metadata helper."""
import datetime
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
LEGACY='docs/checkpoints/REPO-HYGIENE.18-census.py'
legacy_source=(ROOT/LEGACY).read_bytes()
namespace=dict(__name__='hygiene19_accepted_census',__file__=str(ROOT/LEGACY))
exec(compile(legacy_source,str(ROOT/LEGACY),'exec'),namespace)
# Exclude the current review's own fixture as well as every earlier hygiene fixture.
namespace['EXCLUDED']=namespace['EXCLUDED']|{'.linkedspec-data/scratch/hygiene19'}
scan=namespace['scan']
census=namespace['census']

if __name__=='__main__':
    result=census(ROOT)
    result.update(owner='REPO-HYGIENE.19',at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        activation_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        base_census=LEGACY,base_census_sha256=hashlib.sha256(legacy_source).hexdigest(),
        scope='Dated non-following parent metadata and three explicit Rust log/bin locations; all managed runs/caches and old/current hygiene fixtures excluded.',
        removed_files=0,removed_bytes=0,
        disposition='Retention only: no exact target has content-ownership/disposability proof. Keep all proof inputs/logs and reusable outputs. No liveness/recovery/purge or concurrent adversarial guarantee.')
    print(json.dumps(result,indent=2,sort_keys=True))
