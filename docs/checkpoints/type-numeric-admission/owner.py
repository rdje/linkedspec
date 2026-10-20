"""Observe the actual corrected staged owner with its complete Git declaration inputs."""
import subprocess
import admission_data as a
c = a.c


def git(*args):
    return subprocess.check_output(['git', *args], cwd=c.ROOT)


def main():
    assert git('rev-parse', 'HEAD').decode().strip() == c.BASE
    paths = git('diff', '--cached', '--no-renames', '--name-only', '-z', '--', 'docs/tasks/*.md').decode().strip('\0').split('\0')
    before, after = {}, {}
    head_list = git('ls-tree', '-r', '--name-only', '-z', 'HEAD', '--', 'docs/tasks/')
    index_list = git('ls-files', '-z', '--', 'docs/tasks/*.md')
    for path in paths:
        raw = git('show', 'HEAD:' + path)
        mode = git('ls-tree', 'HEAD', '--', path).split()[0].decode()
        before[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), git_mode=mode)
        raw = git('show', ':' + path)
        assert raw == (c.ROOT / path).read_bytes()
        after[path] = c.read(path)
    inputs = dict(base=c.BASE, before=before, after=after,
        head_listing_base64=c.encode(head_list), index_listing_base64=c.encode(index_list),
        selection=paths, checker=c.read('tools/check_task_verification_fields.pl'),
        producers={a.PREFIX + name: c.read(a.PREFIX + name) for name in ('owner.py', 'admission_data.py')},
        scope='All actual task declaration Git inputs consumed by the unchanged owner checker; '
              'accepted HEAD and exact staged bytes remain separate authorities. Core Perl/Git are read-only prerequisites.')
    a.write('owner-inputs.json.gz', inputs)
    run = c.run(['perl', 'tools/check_task_verification_fields.pl', '--owner'])
    controls = c.run(['perl', 'tools/check_task_verification_fields.pl', '--self-test'])
    a.write('owner-run.json.gz', dict(run=run, controls=controls,
        inputs_unchanged=all(c.read(path) == packet for path, packet in after.items())))
    assert run['returncode'] == 0 and c.decode(run['stdout_base64']).strip() == c.OWNER.encode()
    assert not c.decode(run['stderr_base64'])
    assert controls['returncode'] == 0 and not c.decode(controls['stderr_base64'])
    assert b'PASS 14 identity/relocation controls' in c.decode(controls['stdout_base64'])
    print('Actual staged single-owner GREEN:', c.OWNER, '; existing14 controls PASS')


if __name__ == '__main__':
    main()
