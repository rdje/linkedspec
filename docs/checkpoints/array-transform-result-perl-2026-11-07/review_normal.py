"""Readonly actual normal TAP and package-qualification recovery."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import runpy
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
proof = runpy.run_path(str(ROOT / BASE / 'review_preflight.py'))
RED = {'target_' + identifier for identifier in proof['RED']}


def frames(body, tag):
    result = {}
    for line in body.decode().splitlines():
        line = line.lstrip(' #\t')
        if line.startswith(tag + ' '):
            _, identifier, raw = line.split(' ', 2)
            assert identifier not in result
            result[identifier] = json.loads(raw)
    return result


def main():
    originals = {}
    for phase in ('normal_before', 'normal_qualified'):
        directory = ROOT / BASE / phase
        assert (directory / 'exit.txt').read_text() == '1\n'
        stdout = gzip.decompress((directory / 'stdout.log.gz').read_bytes())
        stderr = gzip.decompress((directory / 'stderr.log.gz').read_bytes())
        failures = set(re.findall(rb'^not ok \d+ - (\S+)', stdout, re.M))
        expected = {s.encode() for s in RED}
        if phase == 'normal_before':
            expected |= {('policy_optional_error_' + name).encode() for name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice')}
        assert failures == expected, 'actual-normal-failure-set'
        assert len(re.findall(rb'^(?:not )?ok \d+ - ', stdout, re.M)) == 160
        assert b'1..160' in stdout and b'Tests=160' in stdout
        records = json.loads((directory / 'input-identities.json').read_bytes())
        inputs = {}
        with tarfile.open(directory / 'inputs-before-first-run.tar.gz') as archive:
            for member in archive:
                assert member.isfile() and member.name not in inputs
                raw = archive.extractfile(member).read()
                identity = records[member.name]
                assert len(raw) == identity['bytes'] and hashlib.sha256(raw).hexdigest() == identity['sha256']
                assert member.mode & 0o777 == identity['mode']
                inputs[member.name] = raw
        assert inputs.keys() == records.keys()
        rows = frames(stderr, 'ARRAY_TRANSFORM_COMPOSITION_PERL')
        supplied = frames(stderr, 'ARRAY_TRANSFORM_COMPOSITION_INPUT')
        assert list(rows) == list(supplied) and len(rows) == 160
        profiles = json.loads(inputs['tests/fixtures/array_transform_result_guard_perl_profiles.json'])
        assert len(profiles) == 123
        for profile in profiles:
            identifier = 'policy_' + profile['case']['id']
            row = rows[identifier]
            projected = proof['normalize']({k: row[k] for k in proof['FIELDS'] if k in row})
            if phase == 'normal_before' and profile['case']['id'].startswith('optional_error_'):
                assert projected != profile['expected_observation']
                assert 'LinkedSpec::ArrayTransformComposition::policy_' in projected['fresh_error']['detail']
            else:
                assert proof['same'](projected, profile['expected_observation']), 'exact-original-policy'
        for identifier, row in rows.items():
            for field, payload in (('module_input', 'emitted'), ('handler_input', 'handler')):
                record = row[field]
                assert record['path'].startswith(str(BASE / phase) + '/')
                raw = gzip.decompress((ROOT / record['path']).read_bytes())
                assert hashlib.sha256(raw).hexdigest() == record['sha256'] and len(raw) == record['bytes']
                assert raw.decode() == supplied[identifier][payload]
        originals[phase] = inputs['t/array_transform_result_guard_composition.t']
    old = b"    my $package = 'LinkedSpec::ArrayTransformComposition::' . $identifier;"
    new = b"    (my $public_identifier = $identifier) =~ s/^(?:target_|policy_)//;\n    my $package = 'LinkedSpec::ArrayTransformSelectionProbe::' . $public_identifier;"
    assert originals['normal_before'].replace(old, new) == originals['normal_qualified'], 'only-package-qualification'
    print(json.dumps(dict(result='PASS', original_normal='24RED:19 targets+five exact-package harness mismatches',
                          qualified_normal='19 target RED/141 healthy;123 profiles exact',
                          limit='Expected feature RED; no production repair'), indent=2))


if __name__ == '__main__':
    main()
