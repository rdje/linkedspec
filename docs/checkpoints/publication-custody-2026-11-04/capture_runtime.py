"""One-shot read-only publication/Git-object custody capture on repository storage."""
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess

import model as m
import source_capture

ROOT, HERE = m.ROOT, m.HERE
OUTPUT = HERE / 'publication.json.gz'
CURRENT_PRODUCERS = ('source_capture.py', 'model.py', 'capture_runtime.py', 'review.py')
GIT_SOURCES = (m.PREFIX + 'publish.py', m.PREFIX + 'push-plan.json',
               m.PREFIX + 'publication-intake.json', m.PREFIX + 'thin-pack-estimate.json',
               m.PREFIX + 'publication-remote-refs.txt', '.githooks/pre-push',
               'tools/verification_receipt.sh', 'tools/run_ci_local.sh',
               'tools/project_data_env.sh', 'tools/project_data_run.sh',
               'tools/run_python_project_data.sh')


def read_local(name):
    relative = Path(name)
    m.require(not relative.is_absolute() and '..' not in relative.parts, 'unsafe local input path')
    cursor = ROOT
    for number, part in enumerate(relative.parts):
        cursor /= part
        info = cursor.lstat()
        m.require(not stat.S_ISLNK(info.st_mode) and info.st_dev == ROOT.stat().st_dev,
                  'local input boundary')
        if number < len(relative.parts) - 1:
            m.require(stat.S_ISDIR(info.st_mode) and not (cursor / '.git').exists(),
                      'nested repository input')
        else:
            m.require(stat.S_ISREG(info.st_mode), 'nonregular local input')
    return cursor.read_bytes()


def run_remote():
    command = ['git', 'ls-remote', '--refs', 'origin', 'refs/heads/main', m.TEMPORARY]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout': m.packet(result.stdout), 'stderr': m.packet(result.stderr)}


def object_ids(raw):
    rows = [line.split(b' ', 1)[0].decode('ascii') for line in raw.splitlines()]
    m.require(all(re.fullmatch('[0-9a-f]{40}', oid) for oid in rows), 'invalid Git object identifier')
    m.require(len(set(rows)) == len(rows), 'duplicate Git object identifier')
    return set(rows)


def capture():
    m.require(not OUTPUT.exists(), 'capture is one-shot')
    source_file = read_local((HERE / 'original-source-records.json.gz').relative_to(ROOT).as_posix())
    source_capture.review(json.loads(gzip.decompress(source_file)))
    sources = {name: m.packet(m.git('cat-file', 'blob', m.PUBLISHED + ':' + name)) for name in GIT_SOURCES}
    original = m.decode(sources[m.PREFIX + 'push-plan.json'])
    initial = json.loads(original)
    final = read_local('.linkedspec-data/logs/push-plan-final.json')
    final_plan = json.loads(final)
    events = read_local('.linkedspec-data/logs/push-events.jsonl')
    event_rows = [json.loads(line) for line in events.splitlines()]
    logs = {}
    for row in event_rows:
        name = row['log']
        m.require(name.startswith('.linkedspec-data/logs/push-') and name.endswith('.txt'),
                  'unexpected publication log location')
        logs[name] = m.packet(read_local(name))
    publication = {'initial_plan': m.packet(original), 'final_plan': m.packet(final),
                   'original_plan_output': m.packet(read_local('.linkedspec-data/logs/push-plan.json')),
                   'session': m.packet(read_local('.linkedspec-data/logs/push-session-' + m.PUBLISHED[:12] + '.json')),
                   'events': m.packet(events), 'logs': logs,
                   'publisher_stdout': m.packet(read_local('.linkedspec-data/logs/backlog-publication.log')),
                   'canonical_receipt': m.packet(read_local('.linkedspec-data/verification/canonical-v1.receipt')),
                   'fresh_remote': run_remote()}
    m.require(publication['original_plan_output'] == publication['initial_plan'],
              'original planner output differs from committed input')
    normalized = m.publication(publication)
    datasets, streams = {}, {}

    def collect(name, revision):
        raw = m.git('rev-list', '--objects', revision)
        image = m.packet(raw)
        streams.setdefault(image['sha256'], image)
        datasets[name] = {'command': ['git', 'rev-list', '--objects', revision],
                          'stream_sha256': image['sha256']}
        return object_ids(raw)

    base_ids = collect('remote_base_closure', m.BASE)
    collect('initial_closure', m.INITIAL)
    original_ids = collect('original_outgoing', m.BASE + '..' + m.INITIAL)
    published_ids = collect('published_outgoing', m.BASE + '..' + m.PUBLISHED)
    complete_ids = collect('published_closure', m.PUBLISHED)
    for prefix, plan in (('initial', initial), ('runtime', final_plan)):
        for number, row in enumerate(plan['batches'], 1):
            collect(f'{prefix}_batch_{number:02}', row['base'] + '..' + row['target'])
    m.require(base_ids | published_ids == complete_ids and original_ids <= published_ids,
              'Git logical input closure')
    # Every logical object reachable from the published root is retained by Git.
    # This also covers candidate thin-pack bases under the advertised remote root.
    # Recompute the Git content address and SHA256 from opaque actual body bytes.
    rows = []
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    success = False
    try:
        for number, oid in enumerate(sorted(complete_ids), 1):
            process.stdin.write((oid + '\n').encode())
            process.stdin.flush()
            header = process.stdout.readline().split()
            m.require(len(header) == 3 and header[0].decode() == oid, 'missing Git input object')
            kind, size = header[1].decode(), int(header[2])
            m.require(kind in ('blob', 'tree', 'commit', 'tag') and size >= 0, 'Git object header')
            address = hashlib.sha1((kind + ' ' + str(size) + '\0').encode())
            digest = hashlib.sha256()
            remaining = size
            while remaining:
                block = process.stdout.read(min(remaining, 1024 * 1024))
                m.require(bool(block), 'truncated Git object body')
                digest.update(block)
                address.update(block)
                remaining -= len(block)
            m.require(process.stdout.read(1) == b'\n', 'Git object frame')
            m.require(address.hexdigest() == oid, 'Git object content address')
            rows.append({'oid': oid, 'kind': kind, 'bytes': size, 'sha256': digest.hexdigest()})
            if number % 4096 == 0:
                print('publication-custody: verified logical object bodies', number, flush=True)
        success = True
    finally:
        process.stdin.close()
        if not success:
            process.terminate()
        code = process.wait()
        if success:
            m.require(code == 0, 'Git object retrieval failed')
    producer_names = [str((HERE / name).relative_to(ROOT)) for name in CURRENT_PRODUCERS]
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.23.4.7',
              'captured_at_utc': datetime.now(timezone.utc).isoformat(),
              'activation_commit': m.git('rev-parse', 'HEAD').decode().strip(),
              'published_root': m.PUBLISHED, 'initial_root': m.INITIAL, 'remote_base': m.BASE,
              'git_version': m.git('version').decode().strip(), 'object_format': 'sha1',
              'objects': rows, 'datasets': datasets, 'streams': streams,
              'publication': publication, 'normalized_final_plan': normalized,
              'source_record_file': m.packet(source_file), 'published_sources': sources,
              'producers': {name: m.packet(read_local(name)) for name in producer_names},
              'limits': 'Logical Git-object/input-stream identities and retained actual command/receipt/log '
                        'observations. Full Git clone at the published root retrieves the object bodies; '
                        'no duplicated payload archive or new repository is created. Physical pack layout, '
                        'old/current Git executable and transitive Git/SSH/CI/toolchain implementation closure, '
                        'exact wire bytes and future/concurrent remote-state guarantees are not claimed. '
                        'Original pack byte observations keep their original encoding epoch and values. '
                        'No oversized upload, new push, history rewrite or external write occurs here.'}
    import review
    result = review.validate(report)
    report['controls'] = review.controls(report)
    raw = json.dumps(report, separators=(',', ':')).encode()
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    m.require(gzip.decompress(OUTPUT.read_bytes()) == raw, 'capture recovery')
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    capture()
