"""Distinguish private-name promotion from shared-vocabulary presence in a fixture."""
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c


def controls():
    inputs = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))['inputs']
    changes = {
        'dart/lib/src/action/action_contracts.dart':
            ('const supportedActionIrCallNames = <String>{', "\n  'dispatch_span',"),
        'julia/src/action/ActionContracts.jl':
            ('const _SUPPORTED_ACTION_IR_CALL_NAMES = Set{String}([', '\n    "dispatch_span",'),
        'lua/src/linkedspec/action_call_names.lua':
            ('local CURRENT_CALL_NAMES = {', '\n  ["dispatch_span"] = true,'),
    }
    with tempfile.TemporaryDirectory(prefix='type-vocabulary-control-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in inputs.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])

        def run(report=False):
            command = ['perl', 'tools/check_language_capability_coverage.pl'] + (['--report'] if report else [])
            result = subprocess.run(command, cwd=fixture, env=dict(os.environ, PERL5LIB=''), capture_output=True)
            return dict(command=command, returncode=result.returncode,
                        stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))

        healthy = run()
        assert healthy['returncode'] == 0
        patches = {}
        for path, (needle, insertion) in changes.items():
            raw = c.decode(inputs[path]['base64'])
            assert raw.count(needle.encode()) == 1
            changed = raw.replace(needle.encode(), (needle + insertion).encode(), 1)
            (fixture / path).write_bytes(changed)
            patches[path] = dict(base64=c.encode(changed), sha256=c.sha(changed), mode=inputs[path]['mode'])
        report, red = run(True), run()
        assert report['returncode'] == 0
        assert b'classified non-generic Perl names admitted by backend inventories: 1 (dispatch_span)' in c.decode(report['stdout_base64'])
        assert red['returncode'] != 0 and b'dispatch_span' in c.decode(red['stderr_base64'])
        for path in changes:
            (fixture / path).write_bytes(c.decode(inputs[path]['base64']))
        restored = run()
        assert restored == healthy
        for path, item in inputs.items():
            target = fixture / path
            assert target.read_bytes() == c.decode(item['base64']) and target.stat().st_mode & 0o7777 == item['mode']
    return dict(result='PASS', healthy=healthy, private_report=report, private_red=red,
                restored=restored, exact_changed_inputs=patches, all_source_bytes_modes_restored=True)


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'vocabulary-controls-inputs.json', dict(producer=c.read(c.PREFIX + 'vocabulary_controls.py'),
            helper=c.read(c.PREFIX + 'common.py'), source_snapshot_sha256=c.sha((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes())))
    result = controls()
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'vocabulary-controls.json', result)
    print('Actual private promotion: report0 / strict RED / exact restoration PASS')
