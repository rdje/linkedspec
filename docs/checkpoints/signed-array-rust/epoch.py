"""Bound the CLI producer inputs without inspecting dependency implementation."""
import subprocess
import common as c

FIXED = ['tools/run_cargo_local.sh', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'capability_conformance/signed_array_selector_contract.json',
    'capability_conformance/write_vivification_contract.json',
    'capability_conformance/map_leaves_mutation_contract.json',
    'capability_conformance/write_map_leaves_composition_contract.json',
    'docs/checkpoints/signed-array-selectors/cases.json']


def rust_paths():
    result = []
    for row in subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=c.ROOT).split(b'\0'):
        if not row:
            continue
        metadata, path = row.split(b'\t', 1)
        mode, _, stage = metadata.split()
        assert stage == b'0'
        if path.startswith(b'rust/') and mode in (b'100644', b'100755'):
            result.append(path.decode())
    return result


def snapshot(extras=()):
    owned = [path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
        if path.is_file() and path.suffix in ('.py', '.json', '.md', '.rs')]
    closure_path = c.PREFIX + 'first-party-include-closure.json.gz'
    closure = c.load('first-party-include-closure.json.gz')
    paths = sorted(set(rust_paths() + FIXED + owned + list(extras)
        + list(closure['accepted_inputs'])))
    packets = {path: c.read(path) for path in paths}
    inputs = {path: {key: packet[key] for key in ('sha256', 'mode')} for path, packet in packets.items()}
    inputs[closure_path] = c.identity(closure_path)
    return dict(base=c.BASE, head=subprocess.check_output(['git', 'rev-parse', 'HEAD'],
        cwd=c.ROOT, text=True).strip(), sources=packets,
        inputs=inputs,
        scope='Complete tracked LinkedSpec-owned Rust inputs, named wrappers/contracts/program plan, first-party include inputs from the retained accepted-Git closure and current owned proof sources. The closure artifact is hash/mode gated without recursive copying. Gitlinks and dependency implementations are not read. Installed SDK/OS libraries and already-prepared published RGX products are read-only prerequisites; no historical environment reconstruction or dependency preparation is claimed. Binaries actually used by the probes are retained separately. Later test phases must add their actual fixture inputs before measurement.')
