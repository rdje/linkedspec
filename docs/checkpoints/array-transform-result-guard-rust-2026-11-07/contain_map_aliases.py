"""Preserve all fact content while consolidating two pairs of new lookup aliases."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OUT = BASE / 'map-capacity'
assert OUT.is_dir() and not (OUT / 'inputs-before-alias-change.tar.gz').exists()
paths = [p for directory in ('docs/knowledge', 'docs/decisions') for p in Path(directory).rglob('*.md')]
paths += [Path(p) for p in ('KNOWLEDGE_MAP.md', 'doctrine/readme_stability/routes.jsonl',
    '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh')]
paths += [BASE / 'contain_map_aliases.py', BASE / 'review_map_aliases.py', BASE / 'record.py']
rows = {}
with tarfile.open(OUT / 'inputs-before-alias-change.tar.gz', 'w:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink()
        body = path.read_bytes()
        rows[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
golden = subprocess.check_output(['git', 'show', 'b0376420ba6258420b146981b848d4646fb3ff55:KNOWLEDGE_MAP.md'])
(OUT / 'activation-knowledge-map.md.gz').write_bytes(gzip.compress(golden, mtime=0))
changes = {
    'docs/knowledge/repository-root-path-portability.md': (
        '  - why does a raw process argv snapshot fail repository root portability\n',
        '  - how can exact observed argv bytes survive portable evidence storage\n',
        '  - why do raw process argv snapshots need compressed evidence for root portability\n'),
    'docs/knowledge/rust-array-transform-result-guards.md': (
        '  - "which Rust guard paths own ordinary Array transform results"\n',
        '  - "why did the first Rust Array repair writer fail before changing source"\n',
        '  - "where are the Rust Array transform guard paths and original writer failure recorded"\n'),
}
for name, (first, second, combined) in changes.items():
    path = Path(name)
    text = path.read_text()
    assert text.count(first) == text.count(second) == 1
    path.write_text(text.replace(first, combined, 1).replace(second, '', 1))
(OUT / 'alias-changes.json').write_text(json.dumps(changes, indent=2) + '\n')
print('two overlapping new alias pairs consolidated; all factual content retained; published lookup preservation follows regeneration')
