"""Recover the actual old Rust observer and distinguish persist/restore order."""
import hashlib
import json
from pathlib import Path
import tarfile

OLD = Path('docs/checkpoints/array-pipeline-result-guard-rust-2026-11-11')
packets = json.loads((OLD / 'intake/custody.json').read_bytes())
name = str(OLD / 'intake/native/src/main.rs')
packet, = [packet for packet in packets if name in packet['files']]
with tarfile.open(packet['archive']) as archive:
    source = archive.extractfile(name).read()
row = packet['files'][name]
assert len(source) == row['bytes']
assert hashlib.sha256(source).hexdigest() == row['sha256']
assert source == (OLD / 'observer.rs').read_bytes()
restore = b'let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();'
persist = b'fs::write(fresh.join("inputs").join(format!("{id}.json")), &serialized).unwrap();'
assert source.count(restore) == source.count(persist) == 1
assert source.index(restore) < source.index(persist)
print(json.dumps(dict(
    historical_observer=name, retained_archive=packet['archive'], **row,
    restore_line=source[:source.index(restore)].count(b'\n') + 1,
    persist_line=source[:source.index(persist)].count(b'\n') + 1,
    finding='Original observer restores the in-memory serialized value before persisting it. Later exact recovery is actual; first-use serialized-input retention is not established.',
    repair='Current callable instrument must persist and read back bytes before restoration; historical wording and audit remain separately owned before admission.'
), indent=2))
