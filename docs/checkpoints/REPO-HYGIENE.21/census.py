"""Observe dated artifact metadata without following repository boundaries."""
import datetime
import importlib.util
import json
import subprocess
import common as c

HELPER = 'docs/checkpoints/REPO-HYGIENE.19/census.py'
SPEC = importlib.util.spec_from_file_location('hygiene21_retained_census', c.source(HELPER))
BASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BASE)
BASE.namespace['EXCLUDED'] |= {'.linkedspec-data/scratch/hygiene20', '.linkedspec-data/scratch/hygiene21', 'target'}
scan = BASE.scan


def observe():
    result = BASE.census(c.ROOT)
    submodules = {row.split(b'\t', 1)[1].decode() for row in subprocess.check_output(
        ['git', 'ls-files', '--stage', '-z'], cwd=c.ROOT).split(b'\0') if row.startswith(b'160000 ')}
    for path in ('target/release', 'target/debug/incremental', 'target/debug/deps'):
        rows, nested, links, volumes = scan(c.ROOT, c.ROOT / path, set(), submodules)
        result['rust_log_bin'][path] = dict(exists=(c.ROOT/path).is_dir(), files=len(rows),
            bytes=sum(row['bytes'] for row in rows), rows=rows,
            nested_repositories_excluded=nested, symlinks_excluded=links, other_volumes_excluded=volumes)
    conventions = {}
    for path in ('dart/.dart_tool', '.linkedspec-data/cache/dart-pub',
                 '.linkedspec-data/cache/dart-home', '.linkedspec-data/cache/julia-depot/compiled',
                 '.linkedspec-data/cache/julia-depot/packages', '.linkedspec-data/cache/julia-depot/registries'):
        target = c.ROOT / path
        assert not any(parent.is_symlink() for parent in [target, *target.parents] if parent.is_relative_to(c.ROOT))
        conventions[path] = dict(exists=target.is_dir(), retained=True)
        if target.exists():
            assert target.stat().st_dev == c.ROOT.stat().st_dev
    result['retained_conventions'] = conventions
    result['lua_convention'] = dict(producer='tools/run_lua_project_data.sh',
        policy='Native .so outputs use per-run repository scratch; this review excludes managed runs and does not purge bytecode or package data.')
    result.update(owner=c.OWNER, activation_commit=c.BASE,
        at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        removed_files=0, removed_bytes=0,
        scope='Dated non-following parent .log/.bin/.DS_Store metadata; six explicit root/crate Rust locations; retained default Dart/Julia directories and Lua wrapper convention. No content ownership, disposability, concurrent-adversarial, liveness, recovery or purge guarantee.')
    return result


if __name__ == '__main__':
    print(json.dumps(observe(), sort_keys=True, separators=(',', ':')))
