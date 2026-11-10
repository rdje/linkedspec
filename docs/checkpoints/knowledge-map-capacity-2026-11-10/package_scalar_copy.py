"""Retain the final completed focused consumer's exact post-exit channels."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
result = dict(argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-Iperl',
                   't/actionir_receiver_scalar_copy.t'], cwd='.', observed_exit=0,
              digest_domain='physical-gzip', channels={},
              limits='Final completed487-assertion consumer after the blank-only prefix preservation correction. Channels packaged after observed exit; no original first-use/native custody credit. Earlier pre-correction pass channels were not retained before log reuse and receive no original-channel credit.')
for channel in ('stdout', 'stderr'):
    raw = (ROOT / '.linkedspec-data' / ('scalar-copy-final-' + channel + '.log')).read_bytes()
    path = HERE / ('scalar-copy-focused-' + channel + '.log.gz')
    assert not path.exists(), 'one-shot final channel retention'
    path.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(path.read_bytes()) == raw
    result['channels'][channel] = dict(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest())
path = HERE / 'scalar-copy-focused-result.json'
assert not path.exists()
path.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(result='retained', observed_exit=0), sort_keys=True))
