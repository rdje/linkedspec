"""Add the bounded recurring-review repair without refreshing earlier claims."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TARGET = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
original = TARGET.read_bytes()
record = json.loads(original)
assert len(record['claims']) == 3, 'one-shot supplementary publication'
archive = HERE / 'implementation-pre-factory-claim.json.gz'
assert not archive.exists()
archive.write_bytes(gzip.compress(original, mtime=0))
result = json.loads((HERE / 'factory-boundary-review-result.json').read_bytes())
assert result['result'] == 'PASS' and result['unchanged_current_semantics']
assert result['rejected_controls'] == ['native-kind', 'fresh-effect', 'unrelated-historical-source-edit']
names = ('factory_boundary.py', 'factory_boundary_review.py', 'publish_factory_boundary.py',
         'factory-boundary-before.json.gz', 'factory-boundary-after.json.gz',
         'factory-boundary-review-result.json', 'canonical-fourth.log.gz',
         'implementation-pre-factory-claim.json.gz')
paths = {HERE / name for name in names}
after = json.loads(gzip.decompress((HERE / 'factory-boundary-after.json.gz').read_bytes()))
paths |= {ROOT / name for name in after['sources'] if name.startswith('docs/checkpoints/document-pressure-restoration/')}
inputs = [dict(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
               role='producer' if path.suffix == '.py' or path.suffix == '.pl' else 'input')
          for path in sorted(paths)]
record['claims'].append(dict(
    name='recurring-factory-semantic-and-historical-source-boundaries',
    statement='The recurring factory reviewer accepts current-runtime execution of its unchanged authored semantic targets while retaining the original capture-only byte-preservation and exact historical source-correction oracles. Actual current native-kind and fresh-effect corruptions and an unrelated historical source edit reject.',
    scope='Bounded reviewer maintenance after the fourth canonical failure, with actual old refusal/current successful reviewer channels and unchanged standalone native/fresh targets acquired before and after the correction. No runtime or target policy changes. Historical evidence stays unchanged; its original claims already bind accepted cd3b6adc3e58fb64283ae4ae4a5a37823eabd891. Conservative project-source snapshots retain observed source inputs but do not establish full native/cache/transitive/toolchain custody; that remains TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5. Retained emitted-source execution is current compatibility, not historical runtime reproduction or whole-feature admission.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/factory_boundary_review.py',
                  granularity='Unchanged named public programs and native/fresh effects/kinds; original/candidate actual consumer channels; exact historical reader correction and three reason-sensitive denials.',
                  result=(HERE / 'factory-boundary-review-result.json').read_text().strip()),
    falsify=dict(status='checked', hypothesis='Current source evolution must fail a historical byte comparison even when the original semantic oracle passes, or separating the boundaries lets semantic/historical corruption pass.',
                 oracle='Original unchanged compatibility targets already pass on current source before repair; old consumer refuses only the captured-runtime byte mismatch. Actual corrected consumer still invokes the semantic oracle, while frozen calibration still requires the exact original source correction.',
                 red_control='Original consumer exits1 on MethodLowering source drift; corrected reviewers exit0 with empty stderr. Actual corrected consumer rejects native-kind and fresh-effect injected child results at its native semantic oracle. Frozen calibration rejects an unrelated historical source edit with its exact unreviewed-reviewer-edit diagnostic.'),
    durability=dict(status='checked', mode='live', inputs=inputs)))
assert record['claims'][:3] == json.loads(original)['claims']
body = json.dumps(record, indent=2).encode() + b'\n'
assert len(body) <= 131072
TARGET.write_bytes(body)
print('supplementary bounded reviewer claim published; earlier claim objects unchanged')
