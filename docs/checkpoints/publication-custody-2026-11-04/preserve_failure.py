"""Preserve the rejected first custody instrument before correcting its model."""
from datetime import datetime, timezone
import gzip
import json
from pathlib import Path

import capture_runtime as capture
import model as m

OUTPUT = m.HERE / 'capture-failure-01.json.gz'


def main():
    m.require(not OUTPUT.exists(), 'failure intake is one-shot')
    names = [str((m.HERE / name).relative_to(m.ROOT)) for name in capture.CURRENT_PRODUCERS]
    names += [str(Path(__file__).relative_to(m.ROOT))]
    names += ['.linkedspec-data/logs/publication-custody-capture.log',
              '.linkedspec-data/logs/push-plan.json', '.linkedspec-data/logs/push-plan-final.json',
              '.linkedspec-data/logs/push-session-' + m.PUBLISHED[:12] + '.json',
              '.linkedspec-data/logs/push-events.jsonl',
              '.linkedspec-data/verification/canonical-v1.receipt']
    events = json.loads('[]')
    for line in capture.read_local('.linkedspec-data/logs/push-events.jsonl').splitlines():
        events.append(json.loads(line))
    names += [row['log'] for row in events]
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.23.4.7',
              'retained_at_utc': datetime.now(timezone.utc).isoformat(),
              'failed_exit': 1, 'reason': 'overlapping batch object population',
              'inputs': {name: m.packet(capture.read_local(name)) for name in sorted(set(names))},
              'published_inputs': {name: m.packet(m.git('cat-file', 'blob', m.PUBLISHED + ':' + name))
                                   for name in capture.GIT_SOURCES},
              'Git_input_roots': {'remote_base': m.BASE, 'initial': m.INITIAL, 'published': m.PUBLISHED},
              'limits': 'Actual failed instrument/log and post-failure unchanged runtime input bytes. '
                        'The failed process did not publish its in-memory object manifest; no completed '
                        'custody measurement is inferred. Immutable Git roots retain its logical inputs. '
                        'No source, history, application record or publication artifact is modified.'}
    raw = json.dumps(report, separators=(',', ':')).encode()
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    m.require(gzip.decompress(OUTPUT.read_bytes()) == raw, 'failure intake recovery')
    print('publication-custody: rejected first instrument and full diagnostic preserved')


if __name__ == '__main__':
    main()
