"""Capture and independently verify failed replays and every displayed source line."""
from pathlib import Path
import argparse
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review-retention.py')
LOGICAL = Path(PREFIX + 'review.py').relative_to(ROOT).as_posix()
REPLAY = Path(PREFIX + 'replay-review.py').relative_to(ROOT).as_posix()
CASES = [('heading', 'review-initial.py', 'AssertionError: complete selected suite population', 4),
         ('contract', 'review-contract-initial.py', "KeyError: 'contract'", 2)]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'retention channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'retention channel bytes'
    return raw


def inputs():
    paths = [Path(PREFIX + name).relative_to(ROOT).as_posix() for name in
             ('review-retention.py', 'replay-review.py', 'review.py', 'review-initial.py',
              'review-contract-initial.py', 'inputs.json', 'observations.json', 'capture.py')]
    paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-' + name
              for name in ('review.py', 'capture.py')]
    paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-review.py']
    return [{'path': p, 'sha256': sha((ROOT / p).read_bytes())} for p in sorted(paths)]


def check_context(stderr, source, count):
    text = decode(stderr).decode()
    frames = re.findall(r'  File "[^"\n]*' + re.escape(Path(LOGICAL).name) + r'", line (\d+), in [^\n]+\n    ([^\n]+)', text)
    assert len(frames) == count, 'complete logical traceback frames'
    lines = source.decode().splitlines()
    assert all(0 < int(number) <= len(lines) and shown == lines[int(number) - 1].strip()
               for number, shown in frames), 'traceback context matches executed source'


def check_report(report):
    assert report['complete'] is True, 'complete retention replays'
    assert report['instrument_sha256'] == sha(Path(__file__).read_bytes()), 'actual retention producer'
    assert report['replay_sha256'] == sha((ROOT / REPLAY).read_bytes()), 'actual source-bound replay producer'
    assert report['inputs'] == inputs(), 'exact retention inputs'
    assert [r['case'] for r in report['runs']] == [c[0] for c in CASES], 'complete retained failure population'
    for row, (name, suffix, failure, frames) in zip(report['runs'], CASES):
        source = Path(PREFIX + suffix)
        assert row['command'] == ['bash', 'tools/project_data_run.sh', 'python3', REPLAY,
                                  source.relative_to(ROOT).as_posix(), LOGICAL], 'actual retained failure command'
        assert row['exit'] == 1 and failure.encode() in decode(row['stderr']), 'actual distinguishing failure'
        assert decode(row['stdout']) == b'', 'actual failed replay stdout'
        assert row['source_sha256'] == sha(source.read_bytes()), 'actual executed original bytes'
        assert row['inputs_before'] == row['inputs_after'] == report['inputs'], 'retention input guards'
        check_context(row['stderr'], source.read_bytes(), frames)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    output = Path(PREFIX + 'retention.json')
    if not args.review:
        report = {'complete': False, 'runs': [], 'inputs': inputs(),
                  'instrument_sha256': sha(Path(__file__).read_bytes()),
                  'replay_sha256': sha((ROOT / REPLAY).read_bytes())}
        for name, suffix, failure, frames in CASES:
            source = Path(PREFIX + suffix)
            before = inputs()
            command = ['bash', 'tools/project_data_run.sh', 'python3', REPLAY,
                       source.relative_to(ROOT).as_posix(), LOGICAL]
            result = subprocess.run(command, cwd=ROOT, capture_output=True)
            row = {'case': name, 'command': command, 'exit': result.returncode,
                   'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
                   'source_sha256': sha(source.read_bytes()), 'inputs_before': before}
            report['runs'].append(row)
            output.write_text(json.dumps(report, indent=2) + '\n')
            row['inputs_after'] = inputs()
            assert before == row['inputs_after'] == report['inputs'], 'unchanged executing retention inputs'
            assert result.returncode == 1 and failure.encode() in result.stderr
            check_context(row['stderr'], source.read_bytes(), frames)
            output.write_text(json.dumps(report, indent=2) + '\n')
        report['complete'] = True
        output.write_text(json.dumps(report, indent=2) + '\n')
    report = json.loads(output.read_bytes())
    check_report(report)
    controls = []

    def reject(name, candidate, check, reason):
        try:
            check(candidate)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else:
            raise AssertionError('accepted retention corruption: ' + name)

    for name, suffix, failure, frames in CASES:
        old_suffix = 'review-initial-result.json' if name == 'heading' else 'review-contract-initial-result.json'
        old = json.loads(Path(PREFIX + old_suffix).read_bytes())
        reject('original unbound ' + name + ' context', old['stderr'],
               lambda d: check_context(d, Path(PREFIX + suffix).read_bytes(), frames),
               'traceback context matches executed source')
    for name, change, reason in [
        ('promote partial replays', lambda d: d.update(complete=False), 'complete retention replays'),
        ('forge replay producer', lambda d: d.update(replay_sha256='0' * 64), 'actual source-bound replay producer'),
        ('erase actual failure', lambda d: d['runs'][0].update(exit=0), 'actual distinguishing failure'),
        ('forge retained channel', lambda d: d['runs'][0]['stderr'].update(sha256='0' * 64), 'retention channel bytes'),
    ]:
        candidate = copy.deepcopy(report)
        change(candidate)
        reject(name, candidate, check_report, reason)
    summary = {'complete': True, 'failed_replays': 2, 'logical_frames': 6,
               'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
               'scope': 'Original uncached diagnostics retain an unbound formatter input and are not promoted to complete input closure. Fresh cached replays bind all displayed lines to actual executed bytes.'}
    Path(PREFIX + 'retention-verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('Two source-bound failed replays/six original logical frames; six observed RED controls including both original context mismatches')


if __name__ == '__main__':
    main()
