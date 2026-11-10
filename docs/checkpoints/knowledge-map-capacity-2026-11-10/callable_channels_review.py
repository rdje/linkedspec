"""Readonly coverage of the retained callable/direct-dependent test channels."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
PREFIX = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-Iperl']
TESTS = ['t/' + name + '.t' for name in ('callable_codeblock_literal_contract', 'count_result_guard_composition',
         'count_result_guard_source_fences', 'length_result_guard_composition', 'length_count_source_ownership')]
CASES = ['count-array', 'length-array', 'length-empty', 'length-string', 'length-null', 'uppercase-string']


def channels(row, stem, digest_domain='physical-gzip'):
    result = {}
    assert row['cwd'] == '.'
    for channel in ('stdout', 'stderr'):
        item = row['channels'][channel]
        path = HERE / (stem + '-' + channel + '.log.gz')
        assert item['path'] == path.relative_to(ROOT).as_posix(), 'wrong channel path'
        raw = path.read_bytes()
        decoded = gzip.decompress(raw)
        assert digest_domain in ('physical-gzip', 'decoded-channel')
        # The original before record names decoded-channel hashes. Later
        # packaging names physical gzip hashes. Preserve both original domains.
        measured = decoded if digest_domain == 'decoded-channel' else raw
        assert hashlib.sha256(measured).hexdigest() == item['sha256'], 'channel identity'
        result[channel] = decoded.decode()
    return dict(metadata=row, **result)


def titles(raw):
    return re.findall(r"Failed test '([^\n]+)'", raw)


def check(data):
    before, after, final = (data[name] for name in ('before', 'after', 'final'))
    assert before['metadata']['argv'] == PREFIX + TESTS[:1], 'wrong original target'
    assert after['metadata']['argv'] == PREFIX + TESTS, 'wrong direct targets'
    assert final['metadata']['argv'] == PREFIX + [TESTS[2]], 'wrong calibrated target'
    assert [row['metadata']['observed_exit'] for row in (before, after, final)] == [1, 1, 0], 'wrong observed exit'
    assert all(type(row['metadata']['observed_exit']) is int for row in (before, after, final))
    assert re.search(r'^Files=1, Tests=40,', before['stdout'], re.M)
    assert 'Failed tests:  9-10' in before['stdout'] and before['stdout'].endswith('Result: FAIL\n')
    expected_titles = ['the contract-sourced Perl fixture matches every neutral invocation result',
                       'standalone generated source containing codeblock calls loads',
                       'neutral fixture executes with dynamic caller context']
    for name in CASES[1:]:
        expected_titles.extend([name + ' executes the callable once and preserves its selected result', name + ' emitted source loads'])
    expected_titles.append('indexed callable results retain lowering through value receivers')
    assert titles(before['stderr']) == expected_titles, 'original target failures differ'
    assert 'syntax error' in before['stderr'] and 'near ")["' in before['stderr']
    for name in (TESTS[0], TESTS[1], TESTS[3], TESTS[4]):
        assert re.search('^' + re.escape(name) + r' \.+ ok$', after['stdout'], re.M), 'missing direct PASS: ' + name
    assert re.search(r'^Files=5, Tests=102,', after['stdout'], re.M)
    assert after['stdout'].endswith('Result: FAIL\n') and 'Failed test:  1' in after['stdout']
    assert titles(after['stderr']) == ['original source AST, lowering and diagnostics: count().take(1).with(){return("x")}']
    assert '$got->{lowered}' in after['stderr'] and '$expected->{lowered}' in after['stderr']
    assert re.search('^' + re.escape(TESTS[2]) + r' \.+ ok$', final['stdout'], re.M)
    assert re.search(r'^Files=1, Tests=18,', final['stdout'], re.M)
    assert final['stdout'].endswith('Result: PASS\n') and final['stderr'] == ''
    # Bind the six authored cases and their shared independent value/effect oracle
    # to the actual frozen consumer, rather than inferring cases from a summary.
    source = data['consumer']
    part = source.split("subtest 'indexed callable results retain lowering through value receivers' => sub {", 1)[1].split("subtest 'standalone discard", 1)[0]
    assert re.findall(r"\['([^']+)',", part) == CASES, 'missing/extra authored case'
    assert "my $expected = [$value, 'C'];" in part
    assert 'is_deeply(run_spec($spec' in part and 'is_deeply(&{"${package}::Execute"}' in part
    assert 'ok($loaded,' in part and 'done_testing();' in source


def review():
    records = json.loads((HERE / 'callable-focused-results.json').read_bytes())
    before = json.loads((HERE / 'codeblock-focused-before.json').read_bytes())
    data = dict(before=channels(before, 'codeblock-focused-before', 'decoded-channel'),
                after=channels(records['first-five-file'], 'codeblock-focused-first-after'),
                final=channels(records['calibrated-source-fence'], 'count-fence-final'),
                consumer=(ROOT / TESTS[0]).read_text())
    for stage in ('before', 'after'):
        capture = json.loads(gzip.decompress((HERE / ('codeblock-qualified-' + stage + '.json.gz')).read_bytes()))
        packet = capture['instruments'][TESTS[0]]
        raw = base64.b64decode(packet['base64'], validate=True)
        assert hashlib.sha256(raw).hexdigest() == packet['sha256']
        assert raw == data['consumer'].encode(), 'consumer source epoch changed'
    check(data)
    rejected = []
    for label in ('missing-pass', 'wrong-target', 'wrong-exit', 'missing-original-failure', 'missing-authored-case'):
        changed = copy.deepcopy(data)
        if label == 'missing-pass':
            changed['after']['stdout'] = re.sub('^' + re.escape(TESTS[0]) + r' \.+ ok\n', '', changed['after']['stdout'], flags=re.M)
        elif label == 'wrong-target': changed['after']['metadata']['argv'][-1] = 't/unrelated.t'
        elif label == 'wrong-exit': changed['final']['metadata']['observed_exit'] = 1
        elif label == 'missing-original-failure': changed['before']['stderr'] = changed['before']['stderr'].replace('uppercase-string emitted source loads', 'unrelated')
        else: changed['consumer'] = changed['consumer'].replace("['length-null',", "['unrelated-null',")
        try: check(changed)
        except AssertionError: rejected.append(label)
        else: raise AssertionError('channel/coverage corruption admitted: ' + label)
    return dict(result='PASS', authored_cases=CASES, original_failure_targets=CASES[1:],
                direct_passing_files=[TESTS[i] for i in (0, 1, 3, 4)], calibrated_source_fences=18,
                rejected_controls=rejected,
                limits='Readonly retained command/channel and frozen-consumer evidence. Nonverbose completed test results are interpreted against the exact authored consumer. Post-exit packaging remains qualified; no re-execution of the historical native epoch or complete runtime/cache/OS/transitive custody credit.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
