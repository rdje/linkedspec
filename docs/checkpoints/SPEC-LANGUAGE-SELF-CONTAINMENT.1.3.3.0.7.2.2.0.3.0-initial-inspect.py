"""Display retained diagnostic channels without changing their bytes."""
from pathlib import Path
import base64
import gzip
import hashlib
import json

PREFIX = __file__.removesuffix('inspect.py')


def decode(envelope):
    assert envelope['encoding'] == 'gzip-base64'
    raw = gzip.decompress(base64.b64decode(envelope['data'], validate=True))
    assert len(raw) == envelope['bytes'] and hashlib.sha256(raw).hexdigest() == envelope['sha256']
    return raw


def main():
    document = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    cases = {case['id']: case for case in json.loads(Path(PREFIX + 'cases.json').read_bytes())}
    print('Capture complete:', document['complete'], 'recorded commands:', len(document['runs']))
    for run in document['runs']:
        if not run['kind'].startswith('public:') or run['seed'] != 0:
            continue
        data = json.loads(decode(run['stdout'])); case = cases[data['id']]
        print(data['id'], 'native=', json.dumps(data['native']['value'], ensure_ascii=False),
              'fresh=', json.dumps(data['fresh']['value'] if data['fresh'] else None, ensure_ascii=False),
              'oracle=', json.dumps(case['expected_value'], ensure_ascii=False))
        print(' lower:', data['substitution'])
        for scan in data['scans']:
            if scan['source'] != case['action']:
                continue
            by_id = {origin['event_id']: origin for origin in scan['origins']}
            for event in scan['events']:
                if event['selected'] and event['event']['contract_id'] == case['contract']:
                    print(' selected original:', event['event']['raw'], by_id[event['event_id']]['source_span'])
        for lookup in data['lookups']:
            if lookup['raw'] in {span['raw'] for span in case['spans']}:
                print(' lookup:', lookup['position'], lookup['length'], lookup['caller'], lookup['line'],
                      'original' if lookup['text'] == case['action'] else 'rewritten')


if __name__ == '__main__':
    main()
