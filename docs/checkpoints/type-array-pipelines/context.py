"""Capture complete regular main-repository context and immutable mapper inputs."""
import ast
import subprocess
import common as c


def snapshot(extras):
    paths, excluded = set(extras), []
    rows = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=c.ROOT).split(b'\0')
    for row in rows:
        if not row:
            continue
        metadata, name = row.split(b'\t', 1)
        mode = metadata.split()[0].decode()
        path = name.decode()
        if mode in ('100644', '100755'):
            paths.add(path)
        else:
            excluded.append(dict(path=path, git_mode=mode,
                reason='Gitlink/symlink implementation and targets are not inspected.'))
    inputs = {path: c.identity(path) for path in sorted(paths)}
    changed = subprocess.check_output(['git', 'diff', '--name-only', '-z', c.BASE], cwd=c.ROOT).decode().split('\0')
    overrides = {path: c.read(path) for path in changed if path in inputs and not path.endswith(('.gz','.part'))}
    mapper = 't/lib/method_locations.py'
    parsed = ast.parse((c.ROOT / mapper).read_bytes())
    revisions = [ast.literal_eval(node.value) for node in parsed.body if isinstance(node, ast.Assign)
        and any(isinstance(target, ast.Name) and target.id == 'BEFORE' for target in node.targets)]
    assert len(revisions) == 1 and len(revisions[0]) == 40
    path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    raw = subprocess.check_output(['git', 'show', revisions[0] + ':' + path], cwd=c.ROOT)
    entry = subprocess.check_output(['git', 'ls-tree', revisions[0], '--', path], cwd=c.ROOT).split()
    return dict(inputs=inputs, overrides=overrides, base=c.BASE, excluded=excluded,
        git_inputs=[dict(revision=revisions[0], path=path, sha256=c.sha(raw),
                         git_mode=entry[0].decode(), base64=c.encode(raw))],
        scope='Every regular tracked main-repository file, actual supplied new actors/fixtures and immutable '
              'mapper Git input precedes the commands. Changed plain sources are retained whole; immutable gzip/chunk inputs stay byte/mode-hash-gated without embedding prior snapshots. Any later immutable-input change requires its own before packet; '
              'unchanged bytes recover from the real accepted base. External installed tools/core libraries '
              'are read-only prerequisites. Git submodules are excluded black boxes.')
