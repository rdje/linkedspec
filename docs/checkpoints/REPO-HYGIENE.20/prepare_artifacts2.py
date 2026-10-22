from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
before={name:c.read(c.PREFIX+name) for name in ('artifact_controls.py','publish.py','review.py')}
source=c.decode(before['artifact_controls.py']['base64']).decode()
publisher=c.decode(before['publish.py']['base64']).decode()
assert publisher.count('def validate_inputs(declared, actual):\n')==1
c.write_new('artifact-preparation-refusal.json.gz',dict(before=before,
    merged_log=c.read('.linkedspec-data/verification/hygiene20-artifacts.log'),
    inputs=c.load('artifact-inputs.json.gz'),healthy=c.load('artifact-healthy.json.gz'),
    actor=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix()),
    scope='Copied fault instrumentation expects a no-space signature, while the actual validator has a space. The marker preflight stops before producer mutation. Original healthy declarations reject; no bypass/restoration success is claimed for this refused epoch.'))
source=source.replace('artifact-','artifact2-').replace('def validate_inputs(declared,actual):', 'def validate_inputs(declared, actual):')
with (c.ROOT/c.PREFIX/'artifact_controls2.py').open('x') as out:out.write(source)
publisher=publisher.replace("c.load('artifact-inputs.json.gz')", "c.load('artifact2-inputs.json.gz')")
c.source(c.PREFIX+'publish.py').write_text(publisher)
review=c.decode(before['review.py']['base64']).decode().replace("c.load('artifact-inputs.json.gz')", "c.load('artifact2-inputs.json.gz')").replace("c.load('artifact-run.json.gz')", "c.load('artifact2-run.json.gz')")
c.source(c.PREFIX+'review.py').write_text(review)
producer=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix())
with (c.ROOT/c.PREFIX/'prepare_artifacts2.py').open('xb') as out:out.write(c.decode(producer['base64']))
c.write_new('artifact-preparation2.json.gz',dict(before=before,
    after={name:c.read(c.PREFIX+name) for name in ('artifact_controls2.py','publish.py','review.py')},producer=producer,
    scope='Only the exact actual function signature and distinct proof filenames change; original refused source/channels stay immutable.'))
