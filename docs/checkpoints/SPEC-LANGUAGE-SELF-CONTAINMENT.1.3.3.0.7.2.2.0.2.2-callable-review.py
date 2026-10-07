"""Check the original callable regression against authored source/value authority."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('callable-review.py')


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(channel):
    assert channel['encoding'] == 'gzip-base64'
    raw = gzip.decompress(base64.b64decode(channel['data'], validate=True))
    assert len(raw) == channel['bytes'] and sha(raw) == channel['sha256']
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def check(rows):
    assert [row['params'] for row in rows] == ['x,y', 'x,z', 'x,...y']
    for row, names, rest in zip(rows, [['x', 'y'], ['x', 'z'], ['x']], [None, None, 'y']):
        action = 'cb={|' + row['params'] + '| return(x) }; return(cb("ok","unused"))'
        assert row['action'] == action and row['source'] == 'Top:: I { ' + action + ' }'
        assert row['expected'] == 'ok' and row['errors'] == {}
        block = row['ast']
        assert block['kind'] == 'action_block' and block['source'] == action
        assert len(block['statements']) == 2
        literal = block['statements'][0]['expr']['value']
        assert literal['kind'] == 'codeblock_literal'
        assert literal['signature']['positional_params'] == names
        assert literal['signature']['rest_param'] == rest
        assert literal['body_source'] == ' return(x) '
        assert literal['body_ast']['statements'][0]['expr']['name'] == 'return'
        assert row['emitted'] and row['dump'] and row['fresh']
        assert row['source_origins'], 'actual original compiler origins'
        for origin in row['source_origins']:
            span = origin['span']
            assert action[span['start']:span['end']] == origin['raw']
        tail = [origin for origin in row['source_origins']
                if origin['raw'] == 'return(cb("ok","unused"))']
        assert len(tail) == 1
        if row['params'] == 'x,y':
            assert row['literal_ranges'] == [{'start': 8, 'end': 48, 'text': action[8:48]}]
            assert tail[0]['span'] == {'start': 23, 'end': 48} and tail[0]['selected'] == 0
            assert row['substitution'].endswith('; return(cb("ok","unused"))')
            assert row['native']['value'] is None and row['fresh']['value'] is None
            assert 'Undefined subroutine' in row['native']['context_error']['detail']
            assert row['fresh']['exception']['code'] == 'generated_execution_failed'
            assert 'Undefined subroutine' in row['fresh']['exception']['detail']
        else:
            assert tail[0]['selected'] == 1
            assert row['native']['value'] == row['fresh']['value'] == 'ok'
            assert row['native']['context_error'] is None and row['fresh']['exception'] is None
            assert 'LinkedSpec::CodeblockRuntime::invoke' in row['substitution']
            assert all(not (item['start'] < tail[0]['span']['start'] < item['end'])
                       for item in row['literal_ranges'])


def main():
    actual = json.loads(Path(PREFIX + 'callable-before.json').read_bytes())
    probe = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-callable-probe.pl'
    assert actual['command'] == ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', probe]
    assert actual['exit'] == 0 and decode(actual['stderr']) == b''
    assert actual['producer_sha256'] == sha((ROOT / probe).read_bytes())
    rows = json.loads(decode(actual['stdout']))
    check(rows)
    controls = []
    for name, mutate in [
        ('fabricated healthy value', lambda r: r[0]['native'].update(value='ok')),
        ('lost real tail origin', lambda r: r[0].update(source_origins=[])),
        ('wrong selected tail', lambda r: r[0]['source_origins'][1].update(selected=1)),
        ('forged signature', lambda r: r[0]['ast']['statements'][0]['expr']['value']['signature'].update(positional_params=['x', 'z'])),
        ('forged fresh success', lambda r: r[0]['fresh'].update(value='ok', exception=None)),
    ]:
        changed = copy.deepcopy(rows); mutate(changed); assert changed != rows
        try:
            check(changed)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error) or 'authored source/value/origin authority rejected'})
        else:
            raise AssertionError('unrejected callable control: ' + name)
    initial = json.loads(Path(PREFIX + 'initial-callable-observer.json').read_bytes())
    initial_rows = json.loads(decode(initial['stdout']))
    try:
        check(initial_rows)
    except AssertionError as error:
        assert str(error) == 'actual original compiler origins'
    else:
        raise AssertionError('the original last-empty-packet observer must reject')
    assert initial['producer_sha256'] == sha(Path(PREFIX + 'initial-callable-observer.pl').read_bytes())
    rejected = json.loads(Path(PREFIX + 'initial-callable-before.json').read_bytes())
    assert rejected['exit'] == 255 and rejected['producer_sha256'] == sha(Path(PREFIX + 'initial-callable-probe.pl').read_bytes())
    decode(rejected['stdout']); decode(rejected['stderr'])
    replay = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-initial-callable-replay.pl'
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', replay]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and result.stderr == b''
    failure = json.loads(result.stdout)
    assert failure['returned'] is None and "missing callback 'LinkedSpec::_split_action_ir_statements'" in failure['error']
    failed = json.loads(Path(PREFIX + 'failed-callable-canonical.json').read_bytes())
    assert failed['exit'] == 1 and failed['candidate']['base'] == '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66'
    assert b"Failed test 'x,y native invocation returns its first parameter'" in decode(failed['channel'])
    patch = decode(failed['candidate']['full_index_binary_diff'])
    assert b'diff --git a/tests/language-readiness/verify_objectives.py' in patch
    summary = {'complete': True, 'sources': 3, 'observed_bad_pairs': ['x,y'],
               'observed_healthy_pairs': ['x,z', 'x,...y'], 'controls': controls,
               'initial_empty_origin_observer_red': 'actual original compiler origins',
               'initial_direct_call_exit': 255, 'failed_candidate_sha256': sha(patch),
               'initial_direct_call_replay': {'command': command, 'exit': result.returncode,
                   'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
                   'producer_sha256': sha((ROOT / replay).read_bytes())},
               'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'callable-verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
