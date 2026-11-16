"""Retain the actual startup monitor metadata and disclose its unverified legs."""
import hashlib
import json
from pathlib import Path
import shutil

BASE = Path(__file__).resolve().parent
SOURCE = Path('.linkedspec-data/push-monitor/20261116T105751.125946Z')
OUT = BASE / 'push-monitor-current'
OUT.mkdir()
identities = {}
for source in sorted(SOURCE.iterdir()):
    if source.suffix in ('.pack', '.idx'):
        continue
    assert source.is_file() and not source.is_symlink()
    destination = OUT / source.name
    shutil.copy2(source, destination)
    assert destination.read_bytes() == source.read_bytes()
    assert destination.stat().st_mode & 0o777 == source.stat().st_mode & 0o777
    identities[source.name] = dict(sha256=hashlib.sha256(destination.read_bytes()).hexdigest(), mode=source.stat().st_mode & 0o777)
(OUT / 'identities.json').write_text(json.dumps(identities, indent=2) + '\n')
result = json.loads((OUT / 'result.json').read_bytes())
assert result['head'] == 'b3ab04a22019bd8e95fcba47d278b95bb401d709'
path = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.33.json')
record = json.loads(path.read_bytes())
assert len(record['claims']) == 1
record['claims'].append(dict(
    name='startup-committed-outgoing-pack-telemetry',
    statement=f"Actual committed HEAD versus cached origin/main estimate: {result['estimated_non_thin_pack_bytes']} bytes, {result['ahead']} outgoing commits, {result['remaining_to_trigger_bytes']} bytes below the director1.5GB trigger.",
    scope='Exact b3ab04a22019bd8e95fcba47d278b95bb401d709 against cached4683555ec51f04b8977812ce4e984c5cc6e6f42c; this maintenance is excluded. No remote freshness, wire/server size, complete independent validation or future-size promise. Raw pack stays ignored on the repository volume.',
    rederive=dict(status='checked', command='bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='One actual serial non-thin/no-sparse pack, streamed/stat/header/footer/empty-range/ref/config checks; actual project-source input archive and full command channels retained in push-monitor-current.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Current estimate has producer consistency controls but no independent current pack validator/falsification. Parent30 owns qualification before publication; older qualified measurements do not supply this leg.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Exact project-source input archive, metadata/config/refs/commands/channels are retained; ignored raw pack and complete native Git/cache/compressor/toolchain/OS input custody remain4.2/SESSION5. Native logical/physical completeness is not claimed.')))
path.write_text(json.dumps(record, indent=2) + '\n')
print('actual monitor metadata retained; current falsification and native custody gaps explicit')
