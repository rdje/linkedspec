"""Retain exact public channel deltas to diagnose the initial review rejection."""
from pathlib import Path
import base64
import gzip
import hashlib
import json

PREFIX = str(Path(__file__).resolve()).removesuffix('channel-diff.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def decode(value):
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256']
    return raw


def differences(before, after, path=''):
    if isinstance(before, dict) and isinstance(after, dict):
        result = []
        for key in sorted(set(before) | set(after)):
            if key not in before or key not in after:
                result.append({'path': path + '/' + key, 'before': before.get(key), 'after': after.get(key)})
            else:
                result.extend(differences(before[key], after[key], path + '/' + key))
        return result
    return [] if before == after else [{'path': path, 'before': before, 'after': after}]


def main():
    before, after = [json.loads(Path(PREFIX + e + '-observations.json').read_bytes()) for e in ('before', 'after')]
    results = []
    for seed in (0, 1, 42):
        rows = [json.loads(decode(next(r for r in report['runs'] if r['kind'] == 'public' and r['seed'] == seed)['stdout']))
                for report in (before, after)]
        for old, new in zip(*rows):
            assert (old['params'], old['pattern']) == (new['params'], new['pattern'])
            entry = {'seed': seed, 'params': old['params'], 'pattern': old['pattern'],
                'changed_fields': sorted(k for k in old if old[k] != new[k]),
                'metadata_deltas': differences(old['metadata'], new['metadata']),
                'text_deltas': {k: {'before_sha256': sha(old[k].encode()), 'after_sha256': sha(new[k].encode())}
                    for k in ('substitution', 'emitted', 'dump') if old[k] != new[k]}}
            results.append(entry)
            if seed == 0: print(json.dumps(entry))
    report = {'complete': True, 'source_seed_pairs': len(results), 'deltas': results,
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'channel-diff.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
