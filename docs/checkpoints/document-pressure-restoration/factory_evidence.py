"""Retain once; review the reached factory consumers without changing old captures."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import types

from book_review import Visible, normal

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'
DESTINATION = HERE / 'factory-evidence.json.gz'
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'
FIXTURE = 't/actionir_method_value_capture.t'
TESTS = ['t/' + name + '.t' for name in (
    'trace_actionir_method_lowering', 'actionir_method_inline_capture',
    'actionir_method_ast_call_capture', 'actionir_method_ast_call_capture_cold',
    'actionir_method_value_capture', 'actionir_scalar_receiver_required_capture',
    'actionir_method_kind_capture', 'actionir_ast_optional_capture', 'actionir_named_dispatch_capture')]


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'factory evidence identity'
    return raw


def capture():
    assert not DESTINATION.exists(), 'preserve completed evidence epochs'
    intake = HERE / 'factory-intake.json.gz'
    old = json.loads(gzip.decompress(intake.read_bytes()))
    names = set(old['inputs']) | {SCANNER, 'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
        'docs/knowledge/free-numeric-result-source-guards.md',
        'docs/knowledge/scalar-to-text-coercion-cross-backend-gap.md'}
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.18', intake=packet(intake.read_bytes()),
                 after={name: packet((ROOT / name).read_bytes()) for name in sorted(names)},
                 selector_intake=packet((HERE / 'factory-selector-intake.json.gz').read_bytes()),
                 preparations={name: packet((HERE / name).read_bytes()) for name in (
                     'factory-probe-preparation.json.gz', 'factory-scope-preparation.json.gz')},
                 channels={name: packet((SCRATCH / name).read_bytes()) for name in (
                     'factory-nine-after.tap', 'factory-public-guarded.json', 'factory-coercion-lowering.json',
                     'factory-ast-after.json', 'factory-value-after.json', 'factory-inline-after.json',
                     'factory-selector-green.log', 'factory-public-selector-green.log', 'book-factory-build.log',
                     'factory-first-focused.tap', 'factory-path-focused.tap', 'factory-writes-focused.tap',
                     'factory-inline-trace-focused.tap')},
                 producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
                     Path(__file__), HERE / 'factory_probe.pl', HERE / 'capture_factory_intake.py')},
                 rendered=packet((ROOT / 'docs/linkedspec-book/book/development/local-ci-and-regression.html').read_bytes()),
                 limits='Nine reached current consumers only; frozen native records and all production Perl bytes stay unchanged. Current paths exercise active callback sites; typed public values and exact scope reads replace withdrawn/static-layout assumptions. Nine native/fresh programs, actual emitted replay, current key-order execution and function-scope guard control do not establish full feature/domain/portable or transitive binary/generation closure. Initial two expectation predictions and tied-map/component instrumentation errors are retained as rejected preparation, not product RED. Intermediate narrow TAP channels are diagnostic attempts, without a claim of independently closed original intermediate source epochs. Original complete136-assertion failure and final source populations are retained; broader fixture custody remains23.4.2. Exact staged canonical CI and normal hooks govern integrated10 acceptance; authorized push is followed by pause.')
    historical = HERE / 'objective-recovery-selector-literals.json.gz'
    saved['historical_membership'] = dict(path=str(historical.relative_to(ROOT)),
                                         sha256=hashlib.sha256(historical.read_bytes()).hexdigest())
    DESTINATION.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('factory evidence retained:', len(saved['after']), 'inputs')


def strict_equal(left, right):
    assert json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))


def observations(rows):
    oracle = dict(number=[5, 'V'], number_invalid_value=[None, 'V'], number_container_reject=[None, ''],
                  string='a', string_number=['7!', 'V'], string_container_reject=[None, ''],
                  condition=['defined', 'yes'], branch_once=['yes', 'CT'],
                  key_snapshot=[{'first': 'payload'}, 'later', 'V'])
    assert [row['id'] for row in rows['public']] == list(oracle)
    for row in rows['public']:
        strict_equal(row['expected'], oracle[row['id']])
        strict_equal(row['native'], oracle[row['id']]); strict_equal(row['fresh'], oracle[row['id']])
        assert row['loaded'] == 1 and all(not row[key] for key in ('error', 'native_error', 'native_exception', 'output'))
    assert [(r['active'], r['fault']) for r in rows['scope']] == [(0, 0), (0, 1), (1, 0), (1, 1)]
    inactive, inactive_fault, guarded, bypassed = rows['scope']
    assert all(row['error'] is None for row in rows['scope'])
    for row in (inactive, inactive_fault, bypassed):
        assert row['value'] == 'FALLBACK' and row['calls'] == 1
    assert guarded['calls'] == 0 and 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:entry_text' in guarded['value']
    assert inactive['fetches'] == ['__user_function_call_stack'] and inactive_fault['fetches'] == []
    assert guarded['fetches'] == ['__user_function_call_stack'] * 2
    assert bypassed['fetches'] == ['__user_function_call_stack']


def selector_review(saved):
    intake = json.loads(gzip.decompress(decode(saved['selector_intake'])))
    before = decode(intake['inputs'][SCANNER]).decode()
    after = decode(saved['after'][SCANNER]).decode()
    fixture = decode(saved['after'][FIXTURE])
    original_hash = '9e9e1d9ab525d387ae3d1689a1c1465dab08f39ecccb78868ad62cee6ed50269'
    current_hash = hashlib.sha256(fixture).hexdigest()
    entry = "    't/actionir_method_value_capture.t': (\n        'TYPE-REFERENCE-BOOK.1.2.20.1.18.2',\n        '" + original_hash + "',\n        '" + current_hash + "',\n    ),\n"
    marker = 'REVIEWED_DIAGNOSTIC_EVOLUTIONS = {\n'
    old_owner = "and evolved[0] == 'TYPE-REFERENCE-BOOK.1.2.3'"
    new_owner = "and evolved[0] == ('TYPE-REFERENCE-BOOK.1.2.20.1.18.2'\n                                   if path == 't/actionir_method_value_capture.t'\n                                   else 'TYPE-REFERENCE-BOOK.1.2.3')"
    assert before.count(marker) == before.count(old_owner) == 1
    assert before.replace(marker, marker + entry, 1).replace(old_owner, new_owner, 1) == after
    failure = decode(intake['failure']).decode()
    lines = re.findall(r'^t/actionir_method_value_capture.t:\d+:(.*)$', failure, re.M)
    assert len(lines) == 2 and 'positive selector source remains' in failure
    old_fixture = decode(json.loads(gzip.decompress(decode(saved['intake'])))['inputs'][FIXTURE])
    assert hashlib.sha256(old_fixture).hexdigest() == original_hash
    for line in lines:
        old_lines = [raw for raw in old_fixture.decode().splitlines() if raw.strip() == line]
        new_lines = [raw for raw in fixture.decode().splitlines() if raw.strip() == line]
        assert len(old_lines) == len(new_lines) == 1 and old_lines == new_lines

    def module(source, label):
        value = types.ModuleType(label); value.__file__ = str(ROOT / SCANNER)
        exec(compile(source, value.__file__, 'exec'), value.__dict__)
        return value

    old, new = module(before, 'factory_selector_before'), module(after, 'factory_selector_after')
    assert old.HISTORICAL_DIAGNOSTIC_INPUTS == new.HISTORICAL_DIAGNOSTIC_INPUTS
    for line in lines:
        assert old.classified_compatibility(FIXTURE, line, old_fixture)
        assert not old.classified_compatibility(FIXTURE, line, fixture)
        assert new.classified_compatibility(FIXTURE, line, fixture)
        assert new.classified_compatibility(FIXTURE, line, old_fixture)
    original = new.REVIEWED_DIAGNOSTIC_EVOLUTIONS[FIXTURE]
    for index, changed in ((0, 'TYPE-REFERENCE-BOOK.1.2.3'), (1, '0' * 64), (2, '0' * 64)):
        altered = list(original); altered[index] = changed
        new.REVIEWED_DIAGNOSTIC_EVOLUTIONS[FIXTURE] = tuple(altered)
        assert not new.classified_compatibility(FIXTURE, lines[0], fixture)
    del new.REVIEWED_DIAGNOSTIC_EVOLUTIONS[FIXTURE]
    assert not new.classified_compatibility(FIXTURE, lines[0], fixture)
    new.REVIEWED_DIAGNOSTIC_EVOLUTIONS[FIXTURE] = original
    assert not new.classified_compatibility('t/copied_method_value_capture.t', lines[0], fixture)
    assert not new.classified_compatibility(FIXTURE, lines[0], fixture + b'\n# edited\n')
    positive = lines[0]
    assert not new.classified_compatibility(FIXTURE, positive, fixture + b'\n' + positive.encode() + b'\n')


def review():
    saved = json.loads(gzip.decompress(DESTINATION.read_bytes()))
    assert saved['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.18'
    intake = json.loads(gzip.decompress(decode(saved['intake'])))
    for section in ('after', 'channels', 'producers', 'preparations'):
        for row in saved[section].values(): decode(row)
    for name, row in intake['inputs'].items():
        decode(row)
        if name.startswith('perl/') or name.startswith('t/lib/') and not name.endswith('/EmittedValues.pm'):
            assert decode(row) == decode(saved['after'][name]), 'unexpected production/coordinate edit: ' + name
        if name.endswith('.json'):
            assert decode(row) == decode(saved['after'][name]), 'historical native record changed: ' + name
    failure = decode(intake['failure']).decode()
    failures = {name: (int(count), int(failed)) for name, count, failed in
                re.findall(r'^(t/\S+)\s+\(Wstat:.*? Tests: (\d+) Failed: (\d+)\)', failure, re.M)}
    assert set(failures) == set(TESTS) and sum(value[1] for value in failures.values()) == 136
    assert sum(value[0] for value in failures.values()) == 2838 and 'Files=91, Tests=32248' in failure
    channels = {name: decode(row) for name, row in saved['channels'].items()}
    assert b'Files=9, Tests=2850' in channels['factory-nine-after.tap'] and b'Result: PASS' in channels['factory-nine-after.tap']
    assert b'Use of uninitialized value' not in channels['factory-nine-after.tap']
    rows = json.loads(channels['factory-public-guarded.json']); observations(rows)
    # Native re-derivation uses the checkout only after binding every captured
    # project Perl input; the independently retained emitted sources replay below.
    for name, row in saved['after'].items():
        if name.startswith('perl/'):
            assert (ROOT / name).read_bytes() == decode(row), 'native replay runtime drift: ' + name
    env = dict(os.environ, PERL5LIB='', PERL5OPT='')
    producer = decode(saved['producers'][str((HERE / 'factory_probe.pl').relative_to(ROOT))]).decode()
    native = subprocess.run(['perl', '-Iperl', '-e', producer], cwd=ROOT, env=env, capture_output=True)
    assert native.returncode == 0 and not native.stderr, native.stderr
    observations(json.loads(native.stdout))
    for mutation in ('loss', 'effect', 'coercion', 'snapshot', 'guard', 'kind'):
        changed = copy.deepcopy(rows)
        if mutation == 'loss': changed['public'].pop()
        elif mutation == 'effect': changed['public'][2]['fresh'][1] = 'V'
        elif mutation == 'coercion': changed['public'][4]['native'][0] = None
        elif mutation == 'snapshot': changed['public'][-1]['fresh'][0] = {'later': 'payload'}
        elif mutation == 'guard': changed['scope'][2]['calls'] = 1
        else: changed['public'][0]['fresh'][0] = True
        try: observations(changed)
        except AssertionError: pass
        else: raise AssertionError('factory semantic evidence corruption admitted: ' + mutation)
    replay = r'''use strict; use warnings; use JSON::PP; use LinkedSpec ();
local $/;my $j=JSON::PP->new->canonical;my $rows=$j->decode(<STDIN>);my(@out,$n);
for my $r(@$rows){my $p='FactoryReplay'.($n++);my $ok=eval "package $p; $r->{emitted}; 1";my $e="$@";my $v;
if($ok){eval{no strict 'refs';my $in='x';$v=&{$p.'::Execute'}(\$in);1}or $e="$@";}
push @out,{loaded=>$ok?1:0,error=>$e,value=>$v};}print $j->encode(\@out);'''
    run = subprocess.run(['perl', '-Iperl', '-e', replay], cwd=ROOT, env=env,
                         input=json.dumps(rows['public']).encode(), capture_output=True)
    assert run.returncode == 0 and not run.stderr, run.stderr
    result = json.loads(run.stdout)
    for actual, row in zip(result, rows['public'], strict=True):
        assert actual['loaded'] == 1 and not actual['error']; strict_equal(actual['value'], row['expected'])
    helper = decode(saved['after']['t/lib/LinkedSpecTest/EmittedValues.pm']).decode()
    sources = [r['value'] for r in json.loads(channels['factory-ast-after.json'])['callbacks']
               if r['role'] == 'extract_hash_symbol_name' and r['outcome'] == 'string']
    assert len(sources) == 1
    writes = r'''use strict;use warnings;use JSON::PP;local $/;my $j=JSON::PP->new->canonical;my $d=$j->decode(<STDIN>);
eval $d->{helper};die $@ if $@;print $j->encode([map {LinkedSpecTest::EmittedValues::hash_write($_)} @{$d->{sources}}]);'''
    run = subprocess.run(['perl', '-e', writes], cwd=ROOT, env=env,
                         input=json.dumps(dict(helper=helper, sources=sources + ['$meta{KEY} = VALUE'])).encode(), capture_output=True)
    assert run.returncode == 0 and not run.stderr, run.stderr
    current, old = json.loads(run.stdout)
    strict_equal(current, dict(meta={'first': 'payload'}, zero_target={}, effects=['K', 'V'], key='later'))
    strict_equal(old, dict(meta={'later': 'payload'}, zero_target={}, effects=['V', 'K'], key='later'))
    selector_review(saved)
    reference = saved['historical_membership']; historical = (ROOT / reference['path']).read_bytes()
    assert hashlib.sha256(historical).hexdigest() == reference['sha256']
    report = json.loads(decode(json.loads(gzip.decompress(historical))['report']))
    assert len(report['tracked_inputs']) == 196
    for path in (SCANNER, FIXTURE):
        assert path not in report['tracked_inputs'] and path not in report['observed_artifact_inputs']
    assert b'executable-aggregate-selector-scan: OK' in channels['factory-selector-green.log']
    assert b'OK' in channels['factory-public-selector-green.log']
    visible = Visible(); visible.feed(decode(saved['rendered']).decode())
    assert 'Text-only scalar adapters' in normal(' '.join(visible.parts))
    return dict(focused_tests=2850, suites=9, original_failed_assertions=136,
                public_programs=9, retained_emitted_source_replay=True,
                legacy_key_order_and_scope_bypass='RED; inactive scope healthy',
                semantic_corruption_controls='loss/effect/coercion/snapshot/guard/kind RED',
                exact_diagnostic_evolution='old/current pass; foreign/loss/hash/copy/edit/positive reject',
                production_and_frozen_native_records_unchanged=True, limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--capture', action='store_true'); args = parser.parse_args()
    if args.capture: capture()
    else: print(json.dumps(review(), sort_keys=True))
