"""Read-only closure of the actual input-control epoch against retained files."""
import json
import common as c


def check():
    epoch = c.load('artifact2-inputs.json.gz')
    for path, identity in epoch['actual'].items():
        assert c.identity(path) == identity, 'actual control input epoch: ' + path
    assert epoch['producer'] == c.read(c.PREFIX + 'publish.py')
    return dict(scope='Every actual input-control snapshot file remains recoverable with exact bytes and full permissions; the sole faulty publisher source is separately retained and exactly restored.',
        inputs=len(epoch['actual']), unchanged=True)


if __name__ == '__main__':
    print(json.dumps(check(), sort_keys=True))
