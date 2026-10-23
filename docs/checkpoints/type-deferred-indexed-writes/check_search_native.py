"""Calibrate the restricted wrapper decoder against native JavaScript JSON.parse."""
import json
import os
import common as c
import search_data

def main():
    supplied = c.load('search-inspection.json.gz')
    environment = dict(os.environ)
    for name in ('NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'NODE_PATH'):
        environment.pop(name, None)
    environment['NODE_DISABLE_COMPILE_CACHE'] = '1'
    results = {}
    for name in ('old', 'new'):
        asset = supplied[name]['search']
        decoded = search_data.decode_asset(asset)
        run = c.run(['node', c.PREFIX+'check-search-json.js'],
                    input=c.decode(asset['base64']), env=environment)
        results[name] = dict(run=run, asset=asset)
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        assert json.loads(c.decode(run['stdout_base64'])) == decoded
    c.save('native-search-json.json.gz', dict(results=results,
           producer=c.read(c.PREFIX+'check_search_native.py'),
           decoder=c.read(c.PREFIX+'search_data.py'),
           javascript=c.read(c.PREFIX+'check-search-json.js'),
           input=c.read(c.PREFIX+'search-inspection.json.gz'),
           environment_overrides=dict(NODE_OPTIONS=None,NODE_PATH=None,
                                      NODE_COMPILE_CACHE=None,NODE_DISABLE_COMPILE_CACHE='1'),
           version=c.run(['node','--version'],env=environment)))
    assert search_data.canonical(results['old']['asset']) == search_data.canonical(results['new']['asset'])
    print('Native JSON.parse matches both complete search datasets; canonical data equal')

if __name__ == '__main__':
    main()
