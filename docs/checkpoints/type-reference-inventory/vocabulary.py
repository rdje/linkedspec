"""Retain current strict/report vocabulary checks against the captured source boundary."""
import gzip
import json
import common as c

snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
assert c.unchanged(snapshot['inputs'])
prepared = dict(source_snapshot_sha256=c.sha((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()),
    producer=c.read(c.PREFIX + 'vocabulary.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='The existing source-presence checker is not operation, per-type documentation depth, '
          'or runtime execution proof. Capture both modes and complete channels without inferring completeness.')
c.write_new(c.PREFIX + 'vocabulary-inputs.json', prepared)
rows = []
for command in (['perl', 'tools/check_language_capability_coverage.pl', '--report'],
                ['perl', 'tools/check_language_capability_coverage.pl']):
    rows.append(c.run(command))
c.write_new(c.PREFIX + 'vocabulary.json', dict(runs=rows, inputs_unchanged=c.unchanged(snapshot['inputs'])))
for row in rows:
    print('Vocabulary command exit:', row['returncode'])
    print(c.decode(row['stdout_base64']).decode(), c.decode(row['stderr_base64']).decode())
