"""Measure the quiet observer correction from an explicit complete source/data closure."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import capsules

P = capsules.P
correction = capsules.load('warning-proposals.json.gz')
assert c.unchanged(correction['after'])
prior = capsules.load('closure.json')
paths = set(capsules.load('focused-final-inputs.json')['inputs']) | set(prior['inputs'])
paths.update(correction['after'])
paths.update(str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file())
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'warning-inputs.json', dict(inputs=inputs, producer=c.read(P + 'warning_capture_final.py')))
selected = capsules.load('focused-final-inputs.json')['selected']
syntax = c.run(['perl', '-w', '-Iperl', '-e',
    "require './t/lib/LinkedSpecTest/EmittedValues.pm'; "
    "LinkedSpecTest::EmittedValues::invocation('do { require LinkedSpec::CodeblockRuntime; "
    "LinkedSpec::CodeblockRuntime::invoke($set, [], {set => \\$set}, q{set}, undef, "
    "{descriptor => $descr, input => $STRING, match_info => $minfo}) }');"])
run = c.run(['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-v', '-Iperl'] + selected)
unchanged = all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
                for path, item in inputs.items())
c.write_new(P + 'warning-run.json.gz', dict(syntax=syntax, run=run,
    producer=c.read(P + 'warning_capture_final.py'), inputs_bytes_modes_unchanged=unchanged), packed=True)
assert syntax['returncode'] == 0 and not c.decode(syntax['stderr_base64'])
assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
assert 'Files=12, Tests=5001,' in c.decode(run['stdout_base64']).decode()
assert unchanged
print('Observer correction PASS:5001 assertions, warnings enabled and empty stderr')
