"""Enroll retained first-party macro inputs before final measurement."""
import common as c


def main():
    path=c.PREFIX+'epoch.py';before=c.read(path);text=c.decode(before['base64']).decode()
    old='''    paths = sorted(set(rust_paths() + FIXED + owned + list(extras)))
    packets = {path: c.read(path) for path in paths}
'''
    new='''    closure_path = c.PREFIX + 'first-party-include-closure.json.gz'
    closure = c.load('first-party-include-closure.json.gz')
    paths = sorted(set(rust_paths() + FIXED + owned + list(extras)
        + list(closure['accepted_inputs'])))
    packets = {path: c.read(path) for path in paths}
    inputs = {path: {key: packet[key] for key in ('sha256', 'mode')} for path, packet in packets.items()}
    inputs[closure_path] = c.identity(closure_path)
'''
    assert text.count(old)==1;text=text.replace(old,new,1)
    old="inputs={path: {key: packet[key] for key in ('sha256', 'mode')} for path, packet in packets.items()},"
    assert text.count(old)==1;text=text.replace(old,'inputs=inputs,',1)
    text=text.replace('Complete tracked LinkedSpec-owned Rust inputs, named wrappers/contracts/program plan and current owned proof sources.',
        'Complete tracked LinkedSpec-owned Rust inputs, named wrappers/contracts/program plan, first-party include inputs from the retained accepted-Git closure and current owned proof sources. The closure artifact is hash/mode gated without recursive copying.')
    raw=text.encode()
    c.write_new('epoch-closure-enrollment.json.gz',dict(producer=c.read(c.PREFIX+'finish_closure.py'),
        before=before,after=dict(base64=c.encode(raw),sha256=c.sha(raw),mode=before['mode']),
        scope='Only final epochs enroll the additional root include paths explicitly. Original bounded epochs/actual binaries and late accepted-Git identity qualification remain unchanged.'))
    c.source(path).write_bytes(raw)
    print('Final epoch includes unchanged first-party root macro inputs explicitly.')


if __name__=='__main__':main()
