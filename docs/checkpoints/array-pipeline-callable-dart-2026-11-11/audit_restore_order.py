"""Verify the retained Dart instrument's original parsed-input timing boundary."""
import hashlib
import json
from pathlib import Path
import tarfile

OLD = Path('docs/checkpoints/array-pipeline-result-guard-dart-2026-11-11')
name = 'dart/tool/probe_array_pipeline_results.dart'
packets = json.loads((OLD / 'intake/custody.json').read_bytes())
owners = [packet for packet in packets if name in packet['files']]
assert len(owners) == 2
bodies = []
for packet in owners:
    with tarfile.open(packet['archive']) as archive:
        body = archive.extractfile(name).read()
    row = packet['files'][name]
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    bodies.append(body)
assert bodies[0] == bodies[1]
source = bodies[0]
compile_at = source.index(b'final compiled = compileSpec(parsed);')
restore_at = source.index(b'final restored = SpecFile.fromJson(')
persist_at = source.index(b'writeAsStringSync(jsonEncode(parsed.toJson()))')
assert compile_at < restore_at < persist_at
print(json.dumps(dict(source=name, archive_owners=[packet['archive'] for packet in owners],
    bytes=len(source), sha256=hashlib.sha256(source).hexdigest(),
    compile_line=source[:compile_at].count(b'\n') + 1,
    restore_line=source[:restore_at].count(b'\n') + 1,
    persist_line=source[:persist_at].count(b'\n') + 1,
    limit='Original parsed bodies are retained after compilation/restoration. Before-first-use parsed-input retention is not established. Original grammar/source inputs and outcomes remain actual; no missing historical fields or custody are reconstructed.'), indent=2))
