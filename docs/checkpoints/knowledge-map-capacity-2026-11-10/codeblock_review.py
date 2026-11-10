"""Read-only source/diagnostic proof for prepared callable-index receivers."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
METHOD = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
AST_QUERY = HERE / 'codeblock-ast-query.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row, 'packet identity'
    return raw


def same(left, right):
    return json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))


def frame(record):
    command, = record['commands']
    assert command['exit'] == 0
    stdout = decode(command['stdout'])
    assert decode(record['diagnostic_prefix']) + decode(record['frame']) == stdout, 'complete frame/prefix preservation'
    result = json.loads(decode(record['frame']))
    for image in record['instruments'].values(): decode(image)
    return result


def current_sources(record, bundle):
    members = {name: row for name, row in bundle['sources'].items()
               if name.startswith(('perl/', 'specs/', 'conf/', 'tablescript/', 'ebnf/'))}
    assert record['source_members'] == {name: row['sha256'] for name, row in members.items()}, 'source member omission'
    assert set(record['overrides']) == {METHOD}
    for name, row in members.items():
        assert (ROOT / name).read_bytes() == decode(record['overrides'].get(name, row)), 'current runtime source drift: ' + name


def outcome(result, fixture, bad_fragment):
    assert result['source'] == fixture['spec_source'] and result['input'] == fixture['input']
    assert same(result['expected'], fixture['expected'])
    assert type(result['parser_built']) is int and result['parser_built'] == 1
    assert type(result['loaded']) is int and result['loaded'] == 1 and not result['load_error']
    assert not result['native_exception'] and not result['native_error'] and not result['fresh_error']
    assert same(result['native'], fixture['expected']), 'native fixture result mismatch'
    assert same(result['fresh'], fixture['expected']), 'fresh fixture result mismatch'
    assert bad_fragment not in result['generated'], 'authored access leaked into emitted Length'
    assert 'LinkedSpec::CodeblockRuntime::read_path(' in result['generated']


def review(capture=False):
    before = json.loads(gzip.decompress((HERE / 'codeblock-qualified-before.json.gz').read_bytes()))
    after = json.loads(gzip.decompress((HERE / 'codeblock-qualified-after.json.gz').read_bytes()))
    assert before['source_bundle'] == after['source_bundle']
    raw_bundle = (ROOT / before['source_bundle']['path']).read_bytes()
    assert hashlib.sha256(raw_bundle).hexdigest() == before['source_bundle']['sha256']
    bundle = json.loads(gzip.decompress(raw_bundle))
    assert before['overrides'] == {}
    assert before['source_members'] == after['source_members']
    current_sources(after, bundle)
    old = gzip.decompress((HERE / 'codeblock-method-before.pm.gz').read_bytes())
    assert old == decode(bundle['sources'][METHOD])
    assert old == subprocess.check_output(['git', 'show', bundle['activation_commit'] + ':' + METHOD], cwd=ROOT)
    for name, row in after['instruments'].items():
        assert (ROOT / name).read_bytes() == decode(row)
        assert row == before['instruments'][name], 'probe/fixture instrumentation changed'
    a, b = frame(before), frame(after)
    fixture = json.loads(decode(before['instruments']['capability_conformance/callable_codeblock_contract.json']))['fixture']
    expression = re.search(r'"rest_result_receiver_chain"\s*:\s*(.+?),\s*\n', fixture['spec_source']).group(1)
    argv = ['perl', '-Iperl', '-MJSON::PP', '-MLinkedSpec::ActionIR::AST', '-e',
            'local $/; my $j=JSON::PP->new->canonical; my $d=$j->decode(<STDIN>); print $j->encode(LinkedSpec::ActionIR::AST::parse_action_expr($d->{expression})), "\\n";']
    result = subprocess.run(argv, cwd=ROOT, input=json.dumps(dict(expression=expression)).encode(), capture_output=True)
    query = dict(argv=argv, cwd='.', input=packet(json.dumps(dict(expression=expression)).encode()),
                 exit=result.returncode, stdout=packet(result.stdout), stderr=packet(result.stderr))
    if capture:
        assert not AST_QUERY.exists(), 'one-shot independent AST observation'
        AST_QUERY.write_bytes(gzip.compress(json.dumps(query, sort_keys=True).encode(), mtime=0))
    assert json.loads(gzip.decompress(AST_QUERY.read_bytes())) == query
    assert result.returncode == 0 and result.stderr == b''
    ast = json.loads(result.stdout)
    assert ast['kind'] == 'fluent_chain' and ast['receiver']['kind'] == 'raw_perl'
    assert len(ast['calls']) == 1 and ast['calls'][0]['method'] == 'length'
    bad_fragment = 'my $__ls_length = ' + ast['receiver']['source'] + ';'
    assert a['source'] == b['source'] == fixture['spec_source']
    assert same(a['expected'], fixture['expected']) and same(a['metadata'], b['metadata'])
    assert a['parser_built'] == 1 and a['native'] is None and a['loaded'] == 0
    assert a['native_error']['stage'] == 'rule_handler_compile'
    assert 'syntax error' in a['load_error'] and ')[' in a['load_error']
    assert bad_fragment in a['generated']
    outcome(b, fixture, bad_fragment)
    rejected = []
    for label in ('native-value', 'fresh-effect', 'old-emitted-source'):
        changed = copy.deepcopy(b)
        if label == 'native-value': changed['native']['rest_result_receiver_chain'] = 99
        elif label == 'fresh-effect': changed['fresh']['nonparameter_mutation_state'] = 'wrong'
        else: changed['generated'] = a['generated']
        try: outcome(changed, fixture, bad_fragment)
        except AssertionError as error:
            assert str(error) in ('native fixture result mismatch', 'fresh fixture result mismatch', 'authored access leaked into emitted Length')
            rejected.append(label)
        else: raise AssertionError('diagnostic corruption admitted: ' + label)
    missing = copy.deepcopy(after); missing['overrides'].pop(METHOD)
    try: current_sources(missing, bundle)
    except AssertionError: rejected.append('missing-producer-image')
    else: raise AssertionError('producer image omission admitted')
    return dict(result='PASS', unchanged_fixture_and_metadata=True, original_native_and_emitted_refusal=True,
                repaired_native_and_fresh_match=True, source_change=[METHOD], rejected_controls=rejected,
                limits='Retained project-source and diagnostic-artifact identity plus finite unchanged fixture observations. Original outer JSON parse fails on Trace; qualified framing preserves all bytes. No original first-use or full native/cache/transitive input-closure credit; TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5 owns it.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--capture', action='store_true')
    args = parser.parse_args(); print(json.dumps(review(args.capture), sort_keys=True))
