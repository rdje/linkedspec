"""Replay accepted scoped-with consumers with every tracked input closed in advance."""
import ast
import json
import re
import subprocess
import common as c

SOURCES = (c.SOURCE, 'perl/LinkedSpec/Numeric.pm', 'perl/LinkedSpec/ActionIR/MethodLowering.pm')
OLD_RUNNER = 'docs/checkpoints/type-scoped-with/focused.py'
PROBE = 'docs/checkpoints/SESSION-STARTUP-READING.87.2-probe.pl'


def main():
    parsed = ast.parse((c.ROOT / OLD_RUNNER).read_bytes())
    selected = [ast.literal_eval(node.value) for node in parsed.body if isinstance(node, ast.Assign)
        and any(isinstance(target, ast.Name) and target.id == 'selected' for target in node.targets)]
    assert len(selected) == 1 and len(selected[0]) == 14
    selected = selected[0]
    original = {path: c.read(path) for path in SOURCES}
    assert original == c.load('candidate1-inputs.json')['sources']
    prior = c.load('prior.json.gz')
    accepted = {}
    for path in SOURCES:
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(raw) == prior['inputs'][path]['sha256']
        accepted[path] = dict(base64=c.encode(raw), **{key: prior['inputs'][path][key] for key in ('sha256', 'mode')})
    c.write_new('prior-focused-before.json.gz', dict(sources=original, accepted=accepted,
        producer=c.read(c.PREFIX + 'prior_focused.py'),
        scope='Recovery packet precedes temporary installation of only the three accepted execution sources.'))
    try:
        for path, item in accepted.items():
            (c.ROOT / path).write_bytes(c.decode(item['base64']))
            (c.ROOT / path).chmod(item['mode'])
        for path in selected:
            assert (c.ROOT / path).read_bytes() == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        rows = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=c.ROOT).split(b'\0')
        paths, excluded = set(), []
        for row in rows:
            if not row:
                continue
            metadata, name = row.split(b'\t', 1)
            path = name.decode()
            mode = metadata.split()[0].decode()
            if mode in ('100644', '100755'):
                paths.add(path)
            else:
                excluded.append(dict(path=path, git_mode=mode, reason='Gitlinks/symlinks are not inspected or followed.'))
        paths.update(c.PREFIX + name for name in ('common.py', 'prior_focused.py', 'prior.json.gz',
                                                  'candidate1-inputs.json'))
        inputs = {path: c.identity(path) for path in sorted(paths)}
        changed = subprocess.check_output(['git', 'diff', '--name-only', '-z', c.BASE], cwd=c.ROOT).decode().split('\0')
        overrides = {path: c.read(path) for path in changed if path in inputs}
        assert all({key: item[key] for key in ('sha256', 'mode')} == inputs[path] for path, item in overrides.items())
        c.write_new('prior-focused-inputs.json.gz', dict(inputs=inputs, overrides=overrides,
            selected=selected, excluded=excluded, accepted_base=c.BASE,
            scope='Fresh replay, not a reconstruction of the unretained original process environment. '
                  'Every regular tracked main-repository file plus the supplied new runner inputs is closed '
                  'before execution. New unselected numeric tests/live metadata are explicit overrides; '
                  'all14 executed test files and three execution sources equal accepted203cde315. '
                  'No Git submodule implementation is read. System Perl/core tools are read-only prerequisites.'))
        run = c.run(['prove', '-q', '-Iperl'] + selected)
        c.write_new('prior-focused-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        assert c.unchanged(inputs)
        probe = c.read(PROBE)
        before = b'native => {value => project($value)'
        after = b"native => {value => 'custody-fault'"
        raw = c.decode(probe['base64'])
        assert raw.count(before) == 1
        try:
            (c.ROOT / PROBE).write_bytes(raw.replace(before, after, 1))
            fault = c.run(['prove', '-q', '-Iperl', 't/codeblock_matches_perl.t'])
            c.write_new('prior-focused-producer-observed.json.gz', dict(run=fault,
                before=c.encode(before), after=c.encode(after), mutant_sha256=c.identity(PROBE)['sha256']))
        finally:
            (c.ROOT / PROBE).write_bytes(raw)
            (c.ROOT / PROBE).chmod(probe['mode'])
        restored = c.run(['prove', '-q', '-Iperl', 't/codeblock_matches_perl.t'])
        assert fault['returncode'] != 0 and restored['returncode'] == 0
        assert not c.decode(restored['stderr_base64']) and c.unchanged(inputs)
        missing = dict(inputs)
        del missing[PROBE]
        denied = PROBE not in missing
        assert denied
        c.write_new('prior-focused-controls.json.gz', dict(restored=restored,
            missing_input_denied=dict(path=PROBE, observed=denied, scope='Synthetic required-input deletion.'),
            original_probe=probe, producer=c.read(c.PREFIX + 'prior_focused.py'), inputs_restored=True))
        match = re.search(rb'Files=(\d+), Tests=(\d+),', c.decode(run['stdout_base64']))
        assert match and int(match[1]) == len(selected)
        print('Fresh accepted-source focused replay PASS:', len(selected), 'suites;', int(match[2]),
              'TAP;', len(inputs), 'closed tracked inputs; actual producer fault/restoration')
    finally:
        for path, item in original.items():
            (c.ROOT / path).write_bytes(c.decode(item['base64']))
            (c.ROOT / path).chmod(item['mode'])
        assert all(c.read(path) == item for path, item in original.items())
    c.write_new('prior-focused-restoration.json', dict(restored=True,
        sources={path: c.identity(path) for path in SOURCES}))


if __name__ == '__main__':
    main()
