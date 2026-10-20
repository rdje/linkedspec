"""Retain candidate1 and add terminal boundaries to recurring numeric coverage."""
import common as c


def main():
    path = 't/scalar_numeric_contract.t'
    before = c.read(path)
    assert c.decode(before['base64']) == c.decode(c.load('test-proposals.json.gz')['after'])
    text = c.decode(before['base64']).decode()
    old = 'qw(cases effects stability receiver-invalid)'
    assert text.count(old) == 1
    after = text.replace(old, 'qw(cases effects stability receiver-invalid terminals)', 1).encode()
    sources = tuple(c.load('terminal-before.json.gz')['sources'])
    c.write_new('terminal-proposals.json.gz', dict(producer=c.read(c.PREFIX + 'terminal_accept.py'),
        test_before=before, test_after=c.encode(after),
        source_before=c.load('terminal-before.json.gz')['sources'],
        source_after={name: c.read(name) for name in sources},
        scope='Candidate1 and its20-case mixed-terminal failure epoch remain intact. '
              'Compiler/interpreter numeric shape validation now precedes evaluation across mixed chains. '
              'Existing unknown calls with valid numeric shapes and separately saved comparison values remain controls.'))
    (c.ROOT / path).write_bytes(after)
    print('Mixed numeric terminal cases added to recurring contract coverage')


if __name__ == '__main__':
    main()
