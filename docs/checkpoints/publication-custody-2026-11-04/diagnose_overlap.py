"""Observe actual repeated Git range inputs without reading object contents."""
from datetime import datetime, timezone
import gzip
import json
from pathlib import Path
import subprocess

import model as m

OUTPUT = m.HERE / 'object-overlap-diagnosis.json.gz'


def names(raw):
    return {line.split(b' ', 1)[0].decode(): line for line in raw.splitlines()}


def main():
    m.require(not OUTPUT.exists(), 'overlap diagnosis is one-shot')
    plan_raw = m.git('cat-file', 'blob', m.PUBLISHED + ':' + m.PREFIX + 'push-plan.json')
    plan = json.loads(plan_raw)
    streams = {}

    def observe(name, revision):
        raw = m.git('rev-list', '--objects', revision)
        streams[name] = {'command': ['git', 'rev-list', '--objects', revision], 'image': m.packet(raw)}
        return names(raw)

    base = observe('base_closure', m.BASE)
    full = observe('initial_closure', m.INITIAL)
    outgoing = observe('original_range', m.BASE + '..' + m.INITIAL)
    seen, samples, ranges, total = {}, [], [], 0
    for number, row in enumerate(plan['batches'], 1):
        current = observe(f'batch_{number:02}', row['base'] + '..' + row['target'])
        repeated = set(current) & set(seen)
        ranges.append({'number': number, 'object_rows': len(current), 'repeated_objects': len(repeated)})
        if repeated and len(samples) < 4:
            history = observe(f'negative_base_{number:02}', row['base'])
            command = ['git', 'ls-tree', '-r', '-t', '-z', row['base']]
            tip_raw = subprocess.check_output(command, cwd=m.ROOT)
            streams[f'negative_tip_{number:02}'] = {'command': command, 'image': m.packet(tip_raw)}
            tip = {entry.split(b'\t', 1)[0].split()[2].decode()
                   for entry in tip_raw.split(b'\0') if entry}
            tip.add(m.git('rev-parse', row['base'] + '^{tree}').decode().strip())
            for oid in sorted(repeated)[:4 - len(samples)]:
                kind = m.git('cat-file', '-t', oid).decode().strip()
                size = int(m.git('cat-file', '-s', oid))
                earlier, hint = seen[oid]
                samples.append({'oid': oid, 'kind': kind, 'bytes': size,
                                'earlier_batch': earlier, 'later_batch': number,
                                'later_negative_base': row['base'],
                                'in_negative_base_history': oid in history,
                                'in_negative_base_tip_tree': oid in tip,
                                'earlier_input_line': hint.decode(errors='backslashreplace'),
                                'later_input_line': current[oid].decode(errors='backslashreplace')})
        for oid, line in current.items():
            seen.setdefault(oid, (number, line))
        total += len(current)
    union = set(seen)
    essential = set(full) - set(base)
    summary = {'range_rows': total, 'unique_range_objects': len(union),
               'repeated_occurrences': total - len(union),
               'global_query_objects': len(outgoing), 'required_new_objects': len(essential),
               'missing_global_query_objects': sorted(set(outgoing) - union),
               'extra_beyond_global_query': sorted(union - set(outgoing)),
               'missing_required_new_objects': sorted(essential - union),
               'all_inputs_inside_initial_closure': union <= set(full)}
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.23.4.7',
              'at_utc': datetime.now(timezone.utc).isoformat(), 'summary': summary,
              'samples': samples, 'ranges': ranges, 'streams': streams,
              'plan': m.packet(plan_raw), 'producer': m.packet(Path(__file__).read_bytes()),
              'model_source': m.packet((m.HERE / 'model.py').read_bytes()),
              'limits': 'Actual immutable initial-range object-list and metadata observations. '
                        'No object contents, dependency implementation, Git implementation cause, '
                        'wire bytes, disk reclamation or new publication is inferred.'}
    raw = json.dumps(report, separators=(',', ':')).encode()
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    m.require(gzip.decompress(OUTPUT.read_bytes()) == raw, 'diagnosis recovery')
    print(json.dumps({'summary': summary, 'samples': samples}, sort_keys=True))


if __name__ == '__main__':
    main()
