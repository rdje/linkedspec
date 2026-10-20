"""Retain the whole prior publication before changing any of its bound inputs."""
import json
import subprocess
import common as c


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT).decode().strip() == c.BASE
    prefix = 'docs/checkpoints/type-scoped-with/'
    manifest = c.read(prefix + 'publication-inputs.json')
    inputs = json.loads(c.decode(manifest['base64']))['inputs']
    assert c.unchanged(inputs)
    claim = c.read('docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json')
    for entry in json.loads(c.decode(claim['base64']))['claims']:
        assert entry['durability']['mode'] == 'live'
        for binding in entry['durability']['inputs']:
            assert c.identity(binding['path'])['sha256'] == binding['sha256']

    entries = {}
    raw = subprocess.check_output(['git', 'ls-tree', '-r', '-z', '--full-tree', c.BASE], cwd=c.ROOT)
    for line in raw.split(b'\0'):
        if not line:
            continue
        metadata, path = line.split(b'\t', 1)
        mode, kind, oid = metadata.decode().split()
        entries[path.decode()] = dict(mode=mode, kind=kind, oid=oid)
    retained = {}
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=c.ROOT,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        for path, item in inputs.items():
            entry = entries[path]
            assert entry['kind'] == 'blob'
            assert (entry['mode'] == '100755') == bool(item['mode'] & 0o111), path
            process.stdin.write((c.BASE + ':' + path + '\n').encode())
            process.stdin.flush()
            oid, kind, size = process.stdout.readline().decode().split()
            assert oid == entry['oid'] and kind == 'blob'
            contents = process.stdout.read(int(size))
            assert len(contents) == int(size) and process.stdout.read(1) == b'\n'
            assert c.sha(contents) == item['sha256'], path
            retained[path] = dict(item, git=entry)
        process.stdin.close()
        assert process.wait() == 0 and not process.stderr.read()
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()

    baseline = {name: c.read('.linkedspec-data/verification/type-numeric-prior4-baseline.' + name)
        for name in ('log', 'status')}
    assert c.decode(baseline['status']['base64']).strip() == b'0'
    assert b'Scoped with publication PASS: 2179 closed inputs; 30 GREEN; 19 baseline RED' in c.decode(baseline['log']['base64'])
    assert c.unchanged(inputs)
    c.write_new('prior.json.gz', dict(base=c.BASE, claim=claim, manifest=manifest,
        publication=c.read(prefix + 'publication.json'), inputs=retained, baseline=baseline,
        producer=c.read(c.PREFIX + 'preserve.py'), primitives=c.read(c.PREFIX + 'common.py'),
        activation_diff=c.run(['git', 'diff', '--binary', '--full-index', c.BASE]),
        scope='Whole prior record, all closed inputs and full filesystem modes retained before bound writes. '
              'Every input byte is verified against the real accepted Git revision; Git executable status is '
              'separate from full permissions. The actual readonly baseline log/status precedes new sources. '
              'Clean Git was observed separately before invocation; that status observation is not fabricated '
              'inside this later capsule. Unbound task/Memory activation metadata is the only prior edit.'))
    print('Whole prior4 publication preserved:', len(retained), 'closed inputs; actual readonly0')


if __name__ == '__main__':
    main()
