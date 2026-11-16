"""Publish command-path qualification without changing prior observations."""
import gzip
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'command-portability'
stage = BASE / 'steps/portable-review'
assert (stage / 'exit.txt').read_text() == '0\n' and gzip.decompress((stage / 'stderr.gz').read_bytes()) == b''
result = json.loads(gzip.decompress((stage / 'stdout.gz').read_bytes()))
assert result['portable_commands']['records'] == 5 and not result['portable_commands']['selector_replayed']
claim_path = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0.json')
names = ['MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/checkpoints/canonical-discovery-plan-2026-11-16/REVIEW.md',
    str(BASE / 'REVIEW.md'), 'docs/knowledge/canonical-discovery-source-preparation.md',
    'docs/knowledge/tar-source-image-root-relative-paths.md', str(claim_path)]
with tarfile.open(OUT / 'documents-before.tar.gz', 'x:gz') as archive:
    for name in names:
        assert not Path(name).is_absolute() and '..' not in Path(name).parts
        archive.add(name, arcname=name, recursive=False)
for name in names:
    path = Path(name)
    text = path.read_text()
    if name != str(claim_path):
        path.write_text(text.replace(str(BASE / 'verify_epoch.py'), str(BASE / 'review_portable.py')))
note = '''
## Portable selector-command metadata

The first normal path check rejects five absolute script operands recorded by
the old controls producer. Exact original command bytes/modes are retained in
the corresponding `*-command.actual.json.gz` files; the maintained JSON records
are explicitly labeled portable logical equivalents. The same working directory,
other operands and unchanged script bytes are verified. The scripts do not read
their invocation name or working-directory identity. Original actual argv is not
relabeled as a later invocation; no selector or SDK producer is replayed.
Five operand/cwd/digest/body/mapping controls reject. The partial first normal
log is retained under `command-portability/` with no all-doctrine pass credit.
Native/source-origin/physical custody remains4.2/SESSION5.
'''
path = BASE / 'REVIEW.md'
path.write_text(path.read_text() + note)
path = Path('docs/knowledge/tar-source-image-root-relative-paths.md')
path.write_text(path.read_text() + '\nFive selector-command records also held runtime-derived absolute operands.\nTheir exact actual records remain raw historical images; labeled relative replay\nmetadata preserves the observed cwd/other operands and script bytes. The combined\nreader verifies this equivalence and five counterexamples without selector replay.\n')
record = json.loads(claim_path.read_bytes())
for claim in record['claims']:
    claim['rederive']['command'] = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_portable.py')
record['claims'].append(dict(name='portable-selector-command-metadata',
    statement='Five maintained selector-command records use explicitly labeled repository-relative logical replay operands; every exact original actual command record is retained unchanged with its mode and script identity.',
    scope='Only the five captured selector controls. Relative operands are logical equivalents, not new native invocations or replacements for original actual argv. Scripts do not inspect their invocation name. No SDK/selector replay, old observation refresh or source-origin/native closure credit.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review_portable.py'),
        granularity='Every original raw record, portable counterpart, unchanged script body/mode and cwd/other-operand mapping; actual portable-review0/empty stderr is retained.', result=json.dumps(result['portable_commands'], sort_keys=True)),
    falsify=dict(status='checked', hypothesis='An absolute operand, changed cwd, false original digest, changed script or wrong original mapping could be accepted as equivalent replay metadata.',
        oracle='Exact archived actual records and unchanged generated scripts plus the original path-hook rejection; independent readonly mapping validation.',
        red_control='Actual first normal path hook rejects the five original records. Absolute-operand, cwd, actual-digest, script-byte and argv-mapping controls reject; healthy portable recovery returns0 without replaying selectors.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Actual old records/producers, unchanged scripts, before-child source images and full qualification/recovery channels are retained. Complete native/toolchain/cache/library/filesystem/OS and outer-launcher first-use epochs remain4.2/SESSION5; logical equivalence gives no retroactive original custody credit.')))
claim_path.write_text(json.dumps(record, indent=2) + '\n')
print('portable command qualification and recovery entrypoint published; original observations unchanged')
