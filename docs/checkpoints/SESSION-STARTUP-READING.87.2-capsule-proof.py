"""Decode exact historical observation bytes in memory; never use observed paths."""
import base64
import copy
import hashlib
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SESSION-STARTUP-READING.87.2-'


def require(value, message):
    if not value:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def decode(capsule, expected):
    require(set(capsule) == {'version','encoding','original_path','bytes','sha256','data'}, 'capsule schema')
    require(capsule['version'] == 1 and capsule['encoding'] == 'base64', 'capsule encoding')
    require(all(capsule[k] == expected[k] for k in ('original_path','bytes','sha256')), 'capsule metadata')
    raw = base64.b64decode(capsule['data'], validate=True)
    require(len(raw) == expected['bytes'] and sha(raw) == expected['sha256'], 'capsule byte identity')
    return raw


def main():
    write_attempts = []

    def audit(event, arguments):
        if event == 'open':
            mode, flags = arguments[1], arguments[2]
            if (isinstance(mode, str) and any(c in mode for c in 'wax+')) or (
                    isinstance(flags, int) and flags & (os.O_WRONLY | os.O_RDWR | os.O_CREAT | os.O_TRUNC | os.O_APPEND)):
                write_attempts.append(arguments[0])
                raise PermissionError('decoder write denied')

    sys.addaudithook(audit)
    manifest = json.loads((ROOT / (PREFIX+'capsules.json')).read_bytes())
    names = {'green-before.json','verification-before.json','verification-path-before.json',
             'test-red.json','test-intermediate.json','doctrines-before.json'}
    require(len(manifest) == 6 and {r['path'] for r in manifest} == {PREFIX+n for n in names}, 'capsule population')
    recovered = {}
    for row in manifest:
        recovered[row['path']] = decode(json.loads((ROOT/row['path']).read_bytes()), row)
    first = json.loads(recovered[PREFIX+'verification-before.json'])
    final = json.loads(recovered[PREFIX+'verification-path-before.json'])
    require(final['retained_observations']['green']['sha256'] == sha(recovered[PREFIX+'green-before.json']), 'original green capture identity')
    for capsule, old_path in [('verification-before.json','verification-before.json'),
                              ('test-red.json','test-red.log'),('test-intermediate.json','test-intermediate.log')]:
        require(final['tracked_inputs'][PREFIX+old_path] == sha(recovered[PREFIX+capsule]), 'original watched artifact identity')
    for report, source in [(first,'review-before.py'),(final,'review-path-before.py')]:
        require(report['tracked_inputs'][PREFIX+'review.py'] == sha((ROOT/(PREFIX+source)).read_bytes()), 'original reviewer identity')
    require(final['tracked_inputs']['perl/LinkedSpec/CodeblockRuntime.pm'] == sha((ROOT/(PREFIX+'runtime-intermediate.pm')).read_bytes()), 'original runtime identity')
    claim = json.loads((ROOT/(PREFIX+'claim-before.json')).read_bytes())
    expected = next(r['sha256'] for r in claim['claims'][0]['durability']['inputs'] if r['path'] == PREFIX+'verification.json')
    require(expected == sha(recovered[PREFIX+'verification-path-before.json']), 'original claim capture identity')
    controls = []
    row = manifest[0]
    original = json.loads((ROOT/row['path']).read_bytes())
    for name in ('bytes','metadata','path'):
        changed = copy.deepcopy(original)
        if name == 'bytes': changed['data'] = ('A' if changed['data'][0] != 'A' else 'B') + changed['data'][1:]
        elif name == 'metadata': changed['bytes'] += 1
        else: changed['original_path'] = '../observed-path'
        try: decode(changed, row)
        except ValueError as error: controls.append({'name':name,'reason':str(error)})
        else: raise ValueError('corruption accepted: '+name)
    require(not write_attempts, 'decoder attempted a write')
    denied_path = ROOT / '.linkedspec-data/scratch/codeblock-matches/capsule-write-denied.bin'
    require(not denied_path.exists(), 'write control destination already exists')
    try: open(denied_path, 'wb')
    except PermissionError: pass
    else: raise ValueError('write control was not denied')
    require(len(write_attempts) == 1 and not denied_path.exists(), 'write control created a file')
    print(json.dumps({'capsules':6,'raw_bytes':sum(len(v) for v in recovered.values()),'controls':controls,
                      'original_source_and_capture_links':'PASS','decoder_write_attempts':0,
                      'actual_write_denial':{'attempts':len(write_attempts),'created':denied_path.exists()}},indent=2))


if __name__ == '__main__':
    main()
