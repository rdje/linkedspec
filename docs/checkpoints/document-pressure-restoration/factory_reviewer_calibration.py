"""Replay the exact source-checker rejection/correction of the new reviewer."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import tempfile
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
PRIMARY = HERE / 'factory-evidence.json.gz'
DESTINATION = HERE / 'factory-reviewer-source-calibration.json.gz'
READER = str((HERE / 'factory_evidence.py').relative_to(ROOT))
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    return raw


def replay(before, after, scanner):
    left, right = before.decode(), after.decode()
    lines = [line for line in left.splitlines() if line.startswith('    assert not new.classified_compatibility')
             and 'positive' in line and 'fixture + b' in line]
    assert len(lines) == 1
    replacement = "    positive = lines[0]\n    assert not new.classified_compatibility(FIXTURE, positive, fixture + b'\\n' + positive.encode() + b'\\n')"
    assert left.replace(lines[0], replacement, 1) == right, 'unreviewed reviewer edit'
    module = types.ModuleType('factory_source_checker'); module.__file__ = str(ROOT / SCANNER)
    exec(compile(scanner, module.__file__, 'exec'), module.__dict__)
    observations = {}
    with tempfile.TemporaryDirectory(prefix='factory-reviewer-source-', dir=os.environ['TMPDIR']) as temporary:
        root = Path(temporary); target = root / READER; target.parent.mkdir(parents=True)
        for name, source in (('before', before), ('after', after)):
            target.write_bytes(source)
            findings, recognized = module.scan_files([READER], source_root=root)
            observations[name] = dict(findings=findings, recognized=recognized)
    assert len(observations['before']['findings']) == 1 and not observations['after']['findings']
    return observations


def capture():
    assert not DESTINATION.exists(), 'preserve source calibration epochs'
    primary = PRIMARY.read_bytes(); evidence = json.loads(gzip.decompress(primary))
    before = decode(evidence['producers'][READER]); after = (ROOT / READER).read_bytes()
    scanner = decode(evidence['after'][SCANNER])
    observed = replay(before, after, scanner)
    saved = dict(primary=dict(path=str(PRIMARY.relative_to(ROOT)), sha256=hashlib.sha256(primary).hexdigest()),
                 after=packet(after), observed=observed, producer=packet(Path(__file__).read_bytes()),
                 limits='The scanner correctly rejects a controlled invalid selector literally embedded in the new reviewer. The sole source correction consumes the exact retained diagnostic payload for the same corruption denial. No new path exemption or classifier-policy change. Actual frozen-source scanner replay is RED/GREEN; original primary capsule/reader stays immutable.')
    DESTINATION.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('factory reviewer source calibration retained')


def review():
    saved = json.loads(gzip.decompress(DESTINATION.read_bytes()))
    primary = (ROOT / saved['primary']['path']).read_bytes()
    assert hashlib.sha256(primary).hexdigest() == saved['primary']['sha256']
    evidence = json.loads(gzip.decompress(primary))
    after = decode(saved['after']); assert after == (ROOT / READER).read_bytes()
    decode(saved['producer'])
    assert replay(decode(evidence['producers'][READER]), after, decode(evidence['after'][SCANNER])) == saved['observed']
    return dict(frozen_reader_source='one exact source correction; scanner RED/GREEN',
                corruption_payload='same retained selector remains denied after fixture mutation', limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--capture', action='store_true'); args = parser.parse_args()
    if args.capture: capture()
    else: print(json.dumps(review(), sort_keys=True))
