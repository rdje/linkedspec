"""Finish source qualification from the existing capture after a retained reader refusal."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    assert not (BASE / 'qualification-sources.tar.gz').exists(), 'one-shot qualification'
    identities = {}
    with tarfile.open(BASE / 'qualification-sources.tar.gz', 'x:gz') as archive:
        for name in ('review.py', 'review_qualified.py', 'qualify.py', 'run_qualified.py'):
            path = BASE / name
            assert not path.is_symlink()
            body = path.read_bytes()
            identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=str(path), recursive=False)
    (BASE / 'qualification-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    spec = importlib.util.spec_from_file_location('qualified_export', BASE / 'review_qualified.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    _, source = module.qualified_source()
    (BASE / 'qualified-source.py.gz').write_bytes(gzip.compress(source, mtime=0))
    source = module.verify_qualification(True)
    qualified = module.load_source(source, 'qualified_export_reader')
    sources, _ = qualified.recover()
    assert not (BASE / 'loaders.json').exists(), 'first ledger publication'
    (BASE / 'loaders.json').write_text(json.dumps(qualified.reconstruct(sources), indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', original_capture_retained=True, capture_replayed=False, dart_executed=False), sort_keys=True))


if __name__ == '__main__':
    main()
