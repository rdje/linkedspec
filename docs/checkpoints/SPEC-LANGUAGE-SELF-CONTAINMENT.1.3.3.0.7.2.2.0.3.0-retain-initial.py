"""Retain the initial exact Toolbox command and its actual combined tool channel."""
from pathlib import Path
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('retain-initial.py')
SOURCE = ROOT / '.linkedspec-data/scratch/replacement-diagnosis/initial-tool-return.json'


def main():
    raw = SOURCE.read_bytes(); document = json.loads(raw)
    assert document['tool_return']['exit_code'] == 0
    output = document['tool_return']['output']
    lines = [line for line in output.splitlines() if line.startswith('{"action"')]
    assert len(lines) == 1
    observed = json.loads(lines[0])
    assert observed['value'] is None and observed['error'] == ''
    assert 'Can\'t modify constant item in scalar assignment' in output
    assert "'$out = do {" in observed['substitution']
    assert '; out=matches("x", /x/);' in observed['substitution']
    target = Path(PREFIX + 'initial-tool-return.json.gz')
    target.write_bytes(gzip.compress(raw, mtime=0))
    report = {'complete': True, 'command': document['command'],
              'tool_output_scope': document['scope'],
              'raw_bytes': len(raw), 'raw_sha256': hashlib.sha256(raw).hexdigest(),
              'artifact': target.relative_to(ROOT).as_posix(),
              'artifact_sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
              'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'observed_action': observed['action'], 'observed_substitution': observed['substitution']}
    Path(PREFIX + 'initial.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Exact initial Toolbox return retained:', len(raw), 'bytes')


if __name__ == '__main__':
    main()
