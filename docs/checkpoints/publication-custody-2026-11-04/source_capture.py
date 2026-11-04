"""Recover selected original tool records; default review needs no application data.

Only --acquire reads the exact current-session application record. That retired,
one-shot acquisition is an explicitly owned read-only external-source exception.
"""
import argparse
import base64
from datetime import datetime, timezone
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import stat

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'original-source-records.json.gz'
THREAD = '01a1a35a-9af5-7dd0-a465-555647c51c44'
PRIMARY = {'flat_pack': 525, 'planner': 565, 'bad_raw_count': 1195,
           'raw_count': 1203, 'thin_pack': 1290}
SESSIONS = (13690, 45060, 86526, 50023)
SESSION_PATTERN = re.compile(r'session_id["\']?\s*:\s*(?:' + '|'.join(map(str, SESSIONS)) + r')\b')
ARCHIVED = ('original-planner.sh.txt', 'original-planner.py.txt')


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(),
            'base64': base64.b64encode(raw).decode()}


def decode(image):
    raw = base64.b64decode(image['base64'])
    assert packet(raw) == image, 'record packet identity'
    return raw


def planner_sources(report):
    record = json.loads(decode(report['records'][str(PRIMARY['planner'])]['image']))
    source = record['payload']['input']
    marker = 'tools.exec_command({cmd:'
    assert source.count(marker) == 2
    command, _ = json.JSONDecoder().raw_decode(source.split(marker, 1)[1].lstrip())
    assert command.startswith("PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'\n")
    python = command.split("<<'PY'\n", 1)[1].rsplit('\nPY', 1)[0]
    assert 'if size>limit:' in python and "Path('.linkedspec-data/logs/push-plan.json')" in python
    return command.encode(), python.encode()


def review(report):
    assert report['source_thread'] == THREAD
    assert report['primary_records'] == PRIMARY
    assert report['measurement_sessions'] == list(SESSIONS)
    assert report['external_writes'] == [] and report['project_cwd_matched']
    records = report['records']
    for number, row in records.items():
        raw = decode(row['image'])
        assert len(raw) == row['bytes'] and row['offset'] >= 0
        value = json.loads(raw)
        assert row['call_id'] == value['payload']['call_id']
        assert value['payload']['type'] in ('custom_tool_call', 'custom_tool_call_output')
    for number in PRIMARY.values():
        source = json.loads(decode(records[str(number)]['image']))
        assert source['payload']['type'] == 'custom_tool_call'
        call_id = source['payload']['call_id']
        assert any(row['call_id'] == call_id and json.loads(decode(row['image']))['payload']['type']
                   == 'custom_tool_call_output' for row in records.values()), 'missing original output'
    for name, raw in zip(ARCHIVED, planner_sources(report)):
        assert packet(raw) == report['archived_sources'][name], 'archived source differs from actual record'
    assert decode(report['acquirer']) == Path(__file__).read_bytes(), 'acquirer source drift'
    return {'selected_records': len(records), 'primary_measurement_calls': len(PRIMARY),
            'original_source_recovered': True, 'external_writes': 0}


def acquire():
    assert not OUTPUT.exists() and all(not (HERE / name).exists() for name in ARCHIVED), 'one-shot acquisition'
    assert os.environ.get('CODEX_THREAD_ID') == THREAD, 'wrong current session'
    # Resolve the application-owned source only at this acquisition boundary.
    # No source path or external application data is needed by normal review.
    store = Path(os.environ.get('CODEX_HOME', str(Path.home() / '.codex'))) / 'sessions'
    matches = list(store.rglob('*' + THREAD + '*.jsonl'))
    assert len(matches) == 1, 'session source is absent or ambiguous'
    source = matches[0]
    info = source.lstat()
    assert stat.S_ISREG(info.st_mode) and not source.is_symlink()
    with source.open('rb') as stream:
        prefix = stream.read(info.st_size)
    header = json.loads(prefix.splitlines()[0])['payload']
    assert header.get('id', header.get('session_id')) == THREAD
    assert Path(header['cwd']).resolve() == ROOT
    parsed, offset = {}, 0
    for number, line in enumerate(prefix.splitlines(keepends=True), 1):
        try:
            record = json.loads(line)
        except ValueError:
            assert offset + len(line) == len(prefix), 'invalid earlier session record'
            break
        parsed[number] = (record, offset, line)
        offset += len(line)
    selected = set(PRIMARY.values())
    for number, (record, _, _) in parsed.items():
        value = record.get('payload', {})
        if (record.get('timestamp', '') < '2026-11-04T00:00:00'
                and value.get('type') == 'custom_tool_call' and value.get('name') == 'exec'
                and SESSION_PATTERN.search(value.get('input', ''))):
            selected.add(number)
    calls = {parsed[number][0]['payload']['call_id'] for number in selected}
    selected.update(number for number, (record, _, _) in parsed.items()
                    if record.get('payload', {}).get('call_id') in calls
                    and record['payload'].get('type') == 'custom_tool_call_output')
    records = {}
    with source.open('rb') as stream:
        current = os.fstat(stream.fileno())
        assert (current.st_dev, current.st_ino) == (info.st_dev, info.st_ino)
        assert current.st_size >= len(prefix)
        for number in sorted(selected):
            record, start, line = parsed[number]
            stream.seek(start)
            assert stream.read(len(line)) == line, 'selected original source changed during acquisition'
            records[str(number)] = {'offset': start, 'bytes': len(line), 'image': packet(line),
                                    'call_id': record['payload']['call_id']}
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.23.4.7',
              'acquired_at_utc': datetime.now(timezone.utc).isoformat(),
              'source_thread': THREAD, 'source_filename': source.name,
              'source_device': info.st_dev, 'repository_device': ROOT.stat().st_dev,
              'source_prefix_bytes': len(prefix), 'source_prefix_sha256': hashlib.sha256(prefix).hexdigest(),
              'project_cwd_matched': True, 'external_writes': [], 'records': records,
              'primary_records': PRIMARY, 'measurement_sessions': list(SESSIONS),
              'acquirer': packet(Path(__file__).read_bytes()),
              'limits': 'Selected relevant original tool-call/output records, not the full application '
                        'session, private account metadata, client implementation or signed server attestation. '
                        'Application-owned source is read only and remains untouched. Normal review uses '
                        'repository-local recovered bytes. Original writer aliases/output paths are historical; '
                        'never execute the archived writer against the current checkout.'}
    report['archived_sources'] = {name: packet(raw) for name, raw in zip(ARCHIVED, planner_sources(report))}
    result = review(report)
    raw = json.dumps(report, separators=(',', ':')).encode()
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(OUTPUT.read_bytes()) == raw
    for name, image in report['archived_sources'].items():
        with (HERE / name).open('xb') as stream:
            stream.write(decode(image))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--acquire', action='store_true')
    args = parser.parse_args()
    if args.acquire:
        result = acquire()
    else:
        report = json.loads(gzip.decompress(OUTPUT.read_bytes()))
        result = review(report)
        for name, image in report['archived_sources'].items():
            assert (HERE / name).read_bytes() == decode(image)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
