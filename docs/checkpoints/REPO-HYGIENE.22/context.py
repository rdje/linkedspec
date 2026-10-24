"""Capture only the inputs to this metadata observation, with actual Git channels."""
import json
import common as c


def snapshot():
    import metadata_review
    paths = metadata_review.PRODUCERS
    packets = {path: c.read(path) for path in paths}
    run = c.run(['git', 'ls-files', '--stage', '-z'])
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    gitlinks = sorted(row.split(b'\t', 1)[1].decode()
        for row in c.decode(run['stdout_base64']).split(b'\0')
        if row.startswith(b'160000 '))
    return dict(base=c.BASE, inputs={path: {key: packet[key] for key in ('sha256', 'mode')}
        for path, packet in packets.items()}, sources=packets, git_run=run, gitlinks=gitlinks,
        scope='Complete metadata producers and wrappers, actual Gitlink enumeration, dated OS metadata and independent oracle rows. File contents do not produce size/path observations and are not captured. This is neither content ownership nor runtime admission.')


if __name__ == '__main__':
    print(json.dumps(snapshot(), sort_keys=True))
