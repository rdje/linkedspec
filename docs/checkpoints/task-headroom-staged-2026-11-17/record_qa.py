"""Record publication recovery and exact qualified producer identity after use."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
metadata = json.loads((BASE / 'qualified-composition.json').read_bytes())
assert hashlib.sha256((BASE / 'publish.py').read_bytes()).hexdigest() == metadata['original_publisher_sha256']
assert hashlib.sha256((BASE / 'publish_qualified.py').read_bytes()).hexdigest() == metadata['actual_qualified_publisher_sha256']
ready = json.loads((BASE / 'qualified-publication-ready.json').read_bytes())
assert ready['original_documents_unchanged'] and ready['reused_existing_telemetry'] and ready['first_prefix_replayed'] is False
with tarfile.open(BASE / 'qualified-after-use.tar.gz', 'x:gz') as archive:
    for name in ('record_qa.py', 'publish.py', 'publish_qualified.py', 'qualified-composition.json',
                 'qualified-publication-ready.json', 'review_publication.py'):
        path = BASE / name
        archive.add(path, arcname=str(path), recursive=False)
spec = importlib.util.spec_from_file_location('epoch_qa_recorder', BASE / 'capture.py')
recorder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(recorder)
value = recorder.native('publication-recovery', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_publication.py')])
result = json.loads(value)
assert result['result'] == 'PASS'
copies = []
for label, name in [('qualified-publication', '.linkedspec-data/task-headroom-staged-qualified-publication.log'),
    ('qualified-preparation', '.linkedspec-data/task-headroom-staged-qualified-preparation.log')]:
    body = Path(name).read_bytes()
    target = BASE / (label + '.log.gz')
    with target.open('xb') as stream:
        stream.write(gzip.compress(body, mtime=0))
    copies.append(dict(source=name, target=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), recording='after-use copy'))
(BASE / 'qualified-qa.json').write_text(json.dumps(dict(result='PASS', recovery=result, log_copies=copies,
    producer_identity='Actual unchanged qualified body matches its pre-use composition SHA; complete after-use body image retained.',
    limits='No after-use image receives first-use credit. Original failed prefix/log/before-images and actual qualified continuation remain separate; full native/outer-first-use/per-read/source-origin/physical closure remains4.2/SESSION5.'), indent=2) + chr(10))
print(json.dumps(result, sort_keys=True))
