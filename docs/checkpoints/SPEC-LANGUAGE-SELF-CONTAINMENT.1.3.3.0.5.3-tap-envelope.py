"""Preserve this leaf's exact raw TAP bytes in whitespace-clean JSON envelopes."""
import base64
import copy
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-'
NAMES = ('test-green-before-body-ast', 'test-green', 'test-red-before-correction',
         'test-red-before-direct-arity', 'test-red-final', 'test-red')


def decode(record, original):
    if set(record) != {'original_path', 'bytes', 'sha256', 'base64'}:
        raise ValueError('envelope fields')
    if record['original_path'] != original:
        raise ValueError('original path')
    raw = base64.b64decode(record['base64'], validate=True)
    if len(raw) != record['bytes'] or hashlib.sha256(raw).hexdigest() != record['sha256']:
        raise ValueError('raw byte identity')
    return raw


def main():
    capture = sys.argv[1:] == ['--capture']
    if sys.argv[1:] and not capture:
        raise ValueError('expected --capture or no arguments')
    rows = []
    before = json.loads((ROOT / (PREFIX + 'verification-before-tap-envelope.json')).read_bytes())
    for name in NAMES:
        original = PREFIX + name + '.tap'
        path = ROOT / (original + '.json')
        if capture:
            raw = (ROOT / original).read_bytes()
            record = {'original_path': original, 'bytes': len(raw),
                      'sha256': hashlib.sha256(raw).hexdigest(),
                      'base64': base64.b64encode(raw).decode('ascii')}
            path.write_text(json.dumps(record, indent=2) + '\n')
            if decode(json.loads(path.read_bytes()), original) != raw:
                raise ValueError('capture round trip')
            (ROOT / original).unlink()
        record = json.loads(path.read_bytes())
        decode(record, original)
        if record['sha256'] != before['tracked_inputs'][original]:
            raise ValueError('pre-envelope proof identity')
        controls = []
        for field, value in (('base64', '!'), ('sha256', '0' * 64), ('original_path', 'wrong')):
            changed = copy.deepcopy(record)
            changed[field] = value
            try:
                decode(changed, original)
            except (ValueError, TypeError):
                controls.append(field)
            else:
                raise ValueError('corruption accepted: ' + field)
        rows.append({'path': original + '.json', 'bytes': record['bytes'],
                     'sha256': record['sha256'], 'rejected_controls': controls})
    print(json.dumps({'owner': 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3',
                      'envelopes': rows, 'limits': 'Exact raw TAP identity and corruption rejection only.'}, indent=2))


if __name__ == '__main__':
    main()
