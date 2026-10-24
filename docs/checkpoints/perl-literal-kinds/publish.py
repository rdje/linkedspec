"""Read-only, byte-bound publication of the retained literal-kind proof."""
import json
import common as c
import read


def check():
    manifest = c.load('publication-inputs.json.gz')
    supplied = {path:c.read(path) for path in manifest['inputs']}
    read.verify_inventory(manifest['inputs'], supplied, manifest['required'])
    result = read.check()
    assert result == manifest['result'], 'changed recorded publication'
    return result


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))
