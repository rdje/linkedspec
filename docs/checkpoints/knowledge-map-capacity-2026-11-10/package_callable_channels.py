"""Retain exact post-exit channels; this grants no first-use input custody."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def retain(name, source):
    destination = HERE / name
    assert not destination.exists(), 'one-shot channel packaging'
    raw = source.read_bytes()
    destination.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(destination.read_bytes()) == raw
    return dict(path=destination.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(destination.read_bytes()).hexdigest())


for name in ('codeblock-before-result.json', 'count-fence-capture-result.json'):
    path = HERE / name
    assert path.read_bytes() == b'', 'only the known empty failed outer results'
    retain(name + '.empty.gz', path)
    path.unlink()

records = {}
for label, stem, exit_code, tests in (
    ('first-five-file', 'codeblock-focused-after', 1, ['callable_codeblock_literal_contract', 'count_result_guard_composition',
        'count_result_guard_source_fences', 'length_result_guard_composition', 'length_count_source_ownership']),
    ('calibrated-source-fence', 'count-fence-final', 0, ['count_result_guard_source_fences']),
):
    channels = {}
    for channel in ('stdout', 'stderr'):
        source = ROOT / '.linkedspec-data' / (stem + '.' + channel + '.log') if label == 'first-five-file' else ROOT / '.linkedspec-data' / (stem + '-' + channel + '.log')
        if label == 'first-five-file':
            destination = HERE / ('codeblock-focused-first-after-' + channel + '.log.gz')
            assert gzip.decompress(destination.read_bytes()) == source.read_bytes()
            channels[channel] = dict(path=destination.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(destination.read_bytes()).hexdigest())
        else:
            channels[channel] = retain(stem + '-' + channel + '.log.gz', source)
    records[label] = dict(argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-Iperl'] + ['t/' + name + '.t' for name in tests],
                          cwd='.', observed_exit=exit_code, channels=channels,
                          qualification='Exact channels packaged after the observed completed process. No original first-use or complete native input-closure credit.')
output = HERE / 'callable-focused-results.json'
assert not output.exists()
output.write_text(json.dumps(records, indent=2) + '\n')
print(json.dumps(dict(result='retained', records=list(records)), sort_keys=True))
