"""Review complete current diagnosis; desired quote oracles stay RED until repair."""
from pathlib import Path
import base64
import collections
import copy
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = '012038a637e727a57fe8ac387b27d7267f76f465'
spec = importlib.util.spec_from_file_location('capture', ROOT / (PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)


def require(ok, reason):
    if not ok:
        raise ValueError(reason)


def digest(text):
    return hashlib.sha256(text.encode('utf-8')).hexdigest()


def read(suffix):
    return json.loads((ROOT / (PREFIX + suffix)).read_bytes())


def reply(row):
    require(row['exit'] == 0, 'producer exit')
    return json.loads(capture.unpack(row['stdout']))


def source_calls(action):
    """Independent fixture lexer: only quote/comment/slash forms authored in cases.json."""
    result = []
    pos = 0
    while pos < len(action):
        ch = action[pos]
        if ch in "\"'":
            quote = ch
            pos += 1
            while pos < len(action):
                if action[pos] == '\\':
                    pos += 2
                elif action[pos] == quote:
                    pos += 1
                    break
                else:
                    pos += 1
            continue
        if ch == '#':
            end = action.find('\n', pos)
            pos = len(action) if end < 0 else end + 1
            continue
        if ch == '/':
            pos += 1
            while pos < len(action):
                if action[pos] == '\\':
                    pos += 2
                elif action[pos] == '/':
                    pos += 1
                    break
                else:
                    pos += 1
            continue
        found = re.match(r'[A-Za-z_][A-Za-z0-9_]*(?=\s*\()', action[pos:])
        if found:
            result.append({'name': found[0], 'start': pos})
            pos += len(found[0])
        else:
            pos += 1
    return result


def nodes(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from nodes(child)
    elif isinstance(value, list):
        for child in value:
            yield from nodes(child)


def check_observations(report, cases):
    require(report['mode'] == 'observations', 'observation mode')
    require(len(report['cases']) == len(cases) * 3, 'source/seed population')
    by = {case['id']: case for case in cases}
    require(len(by) == len(cases), 'unique source ids')
    groups = collections.defaultdict(list)
    for row in report['cases']:
        case = by[row['id']]
        require(row['command'] == ['perl', '-Iperl', PREFIX + 'probe.pl', case['id']], 'probe command')
        require(capture.unpack(row['stderr']) == b'', 'probe process stderr')
        o = reply(row)
        require(o['id'] == case['id'] and o['source'] == case['source'], 'authored source')
        require(o['action'] == case['action'] and o['source_sha256'] == digest(case['source']), 'action/source hash')
        require(o['seed'] == str(row['seed']) and o['perturb'] == '2', 'process seed')
        require(o['ast']['kind'] == 'action_block' and o['ast']['source'] == case['action'], 'typed AST source')
        for field in ('substitution', 'emitted'):
            require(isinstance(o[field], str) and o[field + '_sha256'] == digest(o[field]), field + ' bytes')
        require(isinstance(o['dump'], str) and o['dump'], 'public generated dump')
        require(o['fresh']['emitted_sha256'] == o['emitted_sha256'], 'fresh emitted input')
        require(o['native']['exception'] is None, 'native thrown error')
        if case['id'] in ('nested_data', 'regex_data'):
            helper = 'cat' if case['id'] == 'nested_data' else 'matches'
            native_error, fresh_error = o['native']['context_error'], o['fresh']['exception']
            require(isinstance(native_error, dict) and native_error['type'] == 'runtime_handler'
                    and native_error['owner_stage'] == 'runtime_handler:rule_handler_eval', 'native host-call error')
            require('Undefined subroutine &LinkedSpec::SpecEntry::' + helper + ' called' in native_error['detail'], 'native host error detail')
            require(isinstance(fresh_error, dict) and fresh_error['code'] == 'generated_execution_failed'
                    and fresh_error['stage'] == 'execute_generated' and fresh_error['source_identity'] == case['id'] + '.spec', 'fresh host-call error')
            require('Undefined subroutine &QuotedSource::Fresh::' + helper + ' called' in fresh_error['detail'], 'fresh host error detail')
            require('DECISION rule_handler_eval:Top => SKIPPED' in o['native']['stdout']
                    and native_error['detail'].strip() in o['native']['stdout'], 'native retained error trace')
            require(o['native']['value'] is None and o['fresh']['value'] is None, 'failed host-call values')
        else:
            require(o['native']['context_error'] is None and o['fresh']['exception'] is None, 'healthy current error boundary')
        require(o['native']['value'] == o['fresh']['value'], 'native/fresh value')
        # Warnings belong to the actual channels; no blanket quietness assumption.
        for route in ('native', 'fresh'):
            require(isinstance(o[route]['stdout'], str) and isinstance(o[route]['stderr'], str), 'runtime channels')
        require(o['native']['stderr'] == '', 'native stderr boundary')
        if case['id'] not in ('nested_data', 'regex_data'):
            require(o['native']['stdout'] == '', 'native stdout boundary')
        require(o['fresh']['stdout'] == '', 'fresh stdout boundary')
        warning = o['fresh']['stderr']
        if case['id'] in ('quoted_set', 'standalone_quoted_set'):
            require('Use of uninitialized value $QuotedSource::Fresh::counter in concatenation' in warning, 'retained quoted interpolation warning')
        elif case['id'] == 'regex_data':
            require('Use of uninitialized value $_ in pattern match' in warning, 'retained unlowered regex warning')
        elif case['id'] == 'raw_operand':
            require('Unquoted string "i" may clash' in warning and 'isn\'t numeric in addition' in warning, 'retained raw host warnings')
        else:
            require(warning == '', 'fresh stderr boundary')
        m = o['metadata']
        for family in ('helper', 'canonical'):
            events = m[family + '_action_ir_events']
            require(m[family + '_action_ir_count'] == len(events), family + ' count')
            kind = 'ir_node' if family == 'helper' else 'kind'
            require(m[family + '_action_ir_hits'] == dict(collections.Counter(e[kind] for e in events)), family + ' hits')
        require(m['unresolved_helper_count'] == len(m['unresolved_helper_events']), 'unresolved count')
        require(m['unresolved_helper_hits'] == dict(collections.Counter(e['helper'] for e in m['unresolved_helper_events'])), 'unresolved hits')
        for n in nodes(o['ast']):
            span = n.get('source_span')
            if span:
                require(0 <= span['start'] <= span['end'] <= len(case['action']), 'AST scalar span')
        actual_calls = [c['name'] for c in source_calls(case['action'])]
        selected = [name for name in actual_calls if name != 'cb']
        require(collections.Counter(selected) == collections.Counter(case['executable_helpers']), 'independent source call oracle')
        groups[case['id']].append(o)
    for id, group in groups.items():
        require(sorted(o['seed'] for o in group) == ['0', '1', '2'], 'distinct seeds')
        for o in group[1:]:
            for field in ('ast', 'substitution', 'dump', 'emitted', 'metadata'):
                require(o[field] == group[0][field], field + ' seed drift')
    require(set(groups) == set(by), 'complete source ids')
    return groups


def check_witnesses(groups, cases):
    by = {case['id']: case for case in cases}
    summary = []
    for id, group in groups.items():
        o = group[0]
        case = by[id]
        m = o['metadata']
        summary.append({'id': id, 'desired_value_matches': o['native']['value'] == case.get('expected') if 'expected' in case else None,
                        'actual_value': o['native']['value'], 'ready': m['language_agnostic_action_ir_ready'],
                        'raw': m['raw_perl_dependency_count'], 'fallback': m['canonical_action_ir_fallback_count'],
                        'unresolved': m['unresolved_helper_count'],
                        'set_events': sum(e['contract_id'] == 'set_value' for e in m['helper_action_ir_events']),
                        'if_events': sum(e['contract_id'] == 'if_flow' for e in m['helper_action_ir_events'])})
    def first(id):
        return groups[id][0]
    double = first('double_control')
    require(double['ast']['statements'][0]['expr']['args'][0]['kind'] == 'string', 'quoted typed string')
    require(double['native']['value'] == by['double_control']['expected'], 'quoted control value')
    require(any(e['kind'] == 'IF' and e['raw'] == 'if(true)' for e in double['metadata']['canonical_action_ir_events']), 'false quoted IF witness')
    require(double['metadata']['unresolved_helper_count'] == 3 and not double['metadata']['language_agnostic_action_ir_ready'], 'false quoted readiness witness')
    quoted_set = first('quoted_set')
    require(quoted_set['native']['value'] != by['quoted_set']['expected'], 'quoted primitive value corruption witness')
    require('set(counter, 2)' not in quoted_set['substitution'], 'quoted primitive substitution witness')
    require(any(e['kind'] == 'ASSIGN' and e['source'] == 'unmatched_helper_scan_event' for e in quoted_set['metadata']['canonical_action_ir_events']), 'false quoted assignment witness')
    literal = first('sentinel_data')
    require(literal['native']['value'] == by['sentinel_data']['expected'], 'literal marker value')
    require(literal['metadata']['unresolved_helper_count'] == 1 and literal['metadata']['raw_perl_dependency_count'] == 0, 'false authored marker witness')
    for id, helper in [('unsupported_substr', 'substr'), ('unsupported_count', 'count'), ('unsupported_nested', 'substr')]:
        m = first(id)['metadata']
        require(m['unresolved_helper_count'] == 1 and m['unresolved_helpers'] == [helper], 'real unsupported helper guard')
        require(m['raw_perl_dependency_count'] == 0 and not m['language_agnostic_action_ir_ready'], 'unsupported helper guard readiness')
    require(first('mixed_sentinel')['metadata']['unresolved_helper_count'] == 2, 'mixed marker provenance witness')
    raw = first('raw_operand')['metadata']
    require(raw['raw_perl_dependency_count'] == 1 and not raw['language_agnostic_action_ir_ready'], 'real raw guard')
    deps = raw['raw_perl_expression_dependencies']
    require(len(deps) == 1 and deps[0]['source'] == 'i+1', 'real raw operand source')
    unit = raw['raw_perl_expression_source_units'][deps[0]['source_unit']]
    span = deps[0]['source_span']
    require(unit['source'][span['start']:span['end']] == 'i+1', 'real raw operand span')
    for id in ('mixed_set', 'repeated_set'):
        require(first(id)['native']['value'] != by[id]['expected'], 'mixed real/quoted literal corruption')
        desired = by[id]['executable_helpers'].count('set')
        actual = sum(e['contract_id'] == 'set_value' for e in first(id)['metadata']['helper_action_ir_events'])
        require(actual > desired, 'mixed real/quoted event inflation')
    return summary


def check_trace(report, groups):
    require(report['mode'] == 'trace' and len(report['cases']) == len(groups), 'trace population')
    result = {}
    for row in report['cases']:
        require(row['seed'] == 0 and row['command'] == ['perl', '-Iperl', PREFIX + 'trace.pl', row['id']], 'trace command/seed')
        o = reply(row)
        control = groups[row['id']][0]
        require(o['source'] == control['source'] and o['action'] == control['action'], 'trace source')
        require(o['substitution'] == control['substitution'] and o['substitution_sha256'] == control['substitution_sha256'], 'trace lowering correspondence')
        raw = base64.b64decode(o['trace_base64'], validate=True)
        require(len(raw) == o['trace_bytes'] and hashlib.sha256(raw).hexdigest() == o['trace_sha256'], 'trace bytes')
        trace = raw.decode('utf-8')
        stderr = capture.unpack(row['stderr']).decode('utf-8')
        if row['id'] == 'unicode_crlf':
            lines = stderr.splitlines()
            require(len(lines) == 6 and all(line.startswith('Wide character in print at ') and line.endswith('/perl/LinkedSpec/Trace.pm line 199.') for line in lines), 'owned Unicode trace warning')
        else:
            require(stderr == '', 'trace process stderr')
        require('EXIT LinkedSpec::ActionIR::RewritePipeline::rewrite_action_code_with_diagnostics:Top' in trace, 'complete trace reach')
        result[row['id']] = trace
    require(set(result) == set(groups), 'trace source ids')
    for id in ('double_control', 'quoted_set', 'mixed_set'):
        require('Top:unmatched_helper_event_rewritten => TAKEN' in result[id], 'actual quoted replacement decision')
    for id in ('sentinel_data', 'unsupported_substr', 'mixed_sentinel'):
        require('action_code:unsupported_ast_helper_call => TAKEN' in result[id], 'actual sentinel diagnostic decision')
    for id in ('double_control', 'nested_data', 'regex_data'):
        require('Top:unbalanced_flow_stack => TAKEN' in result[id] and "'status' => 'fallback_original'" in result[id], 'actual original-source fallback')


def check_tests(report):
    require(len(report['rows']) == 10, 'test population')
    counts = []
    for row in report['rows']:
        require(row['exit'] == 0 and row['command'] == ['prove', '-v', '-Iperl', row['test']], 'test command/exit')
        stdout = capture.unpack(row['stdout']).decode('utf-8')
        capture.unpack(row['stderr'])
        count = re.search(r'Files=1, Tests=(\d+),', stdout)
        require(count and 'Result: PASS' in stdout and not re.search(r'^not ok ', stdout, re.M), 'complete TAP pass')
        counts.append({'path': row['test'], 'tests': int(count[1])})
    require(len({c['path'] for c in counts}) == 10, 'unique suites')
    return counts


def check_book(report, cases):
    require(report['command'] == ['bash', 'tools/run_mdbook_local.sh'] and report['exit'] == 0, 'book command/exit')
    capture.unpack(report['stdout'])
    capture.unpack(report['stderr'])
    html = capture.unpack(report['html'])
    require(b'Ignoring every quoted string would erase' in html and b'phantom replacement' in html, 'actual rendered explanation')
    ids = ['double_control', 'quoted_set', 'sentinel_data', 'unsupported_substr']
    expected = [{'id': id, 'source': next(c['source'] for c in cases if c['id'] == id)} for id in ids]
    require(report['source_examples'] == expected, 'exact published source examples')
    source = (ROOT / 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md').read_text()
    blocks = re.findall(r'```spec\n(.*?)\n```', source, re.S)
    require(all(row['source'] in blocks for row in expected), 'current book example source')


def change(report, id, mutate):
    row = next(r for r in report['cases'] if r['id'] == id)
    value = reply(row)
    mutate(value)
    row['stdout'] = capture.envelope(json.dumps(value, ensure_ascii=False).encode('utf-8'))


def main():
    cases = read('cases.json')
    observations, traces, tests = (read(s) for s in ('observations.json', 'trace.json', 'tests.json'))
    groups = check_observations(observations, cases)
    summary = check_witnesses(groups, cases)
    check_trace(traces, groups)
    counts = check_tests(tests)
    check_book(read('book.json'), cases)
    initial = read('review-initial.json')
    initial_bytes = (ROOT / (PREFIX + 'review-initial.py')).read_bytes()
    require(initial['exit'] == 1 and hashlib.sha256(initial_bytes).hexdigest() == initial['source_sha256'], 'initial reviewer identity/failure')
    require(b'ValueError: native error' in capture.unpack(initial['stderr']), 'initial reviewer actual failure')
    require(capture.unpack(initial['stdout']) == b'', 'initial reviewer stdout')
    original_cases = read('cases-initial.json')
    require(len(original_cases) == len(cases), 'initial/current source population')
    for before, after in zip(original_cases, cases):
        for field in ('id', 'source', 'action', 'input', 'executable_helpers'):
            require(before[field] == after[field], 'initial/current executed source identity')
    unchanged = subprocess.run(['git', 'diff', '--exit-code', BASE, '--', 'perl', 'specs', 't'], cwd=ROOT, capture_output=True)
    require(unchanged.returncode == 0, 'production/spec/test activation identity')
    controls = []
    def reject(label, check):
        try:
            check()
        except (ValueError, AssertionError, KeyError, IndexError, TypeError):
            controls.append(label)
            return
        raise ValueError('control accepted: ' + label)
    mutations = [
        ('authored source', 'double_control', lambda o: o.update(source='other')),
        ('typed string ownership', 'double_control', lambda o: o['ast']['statements'][0]['expr']['args'][0].update(kind='raw_perl')),
        ('fresh emitted identity', 'double_control', lambda o: o['fresh'].update(emitted_sha256='0' * 64)),
        ('hidden false IF', 'double_control', lambda o: o['metadata']['canonical_action_ir_events'].pop()),
        ('hidden quoted value corruption', 'quoted_set', lambda o: [o[r].update(value='set(counter, 2)') for r in ('native', 'fresh')]),
        ('hidden authored marker', 'sentinel_data', lambda o: o['metadata'].update(unresolved_helper_count=0)),
        ('hidden true unsupported helper', 'unsupported_substr', lambda o: o['metadata'].update(language_agnostic_action_ir_ready=1)),
        ('raw span drift', 'raw_operand', lambda o: o['metadata']['raw_perl_expression_dependencies'][0]['source_span'].update(start=0)),
        ('lost mixed helper occurrence', 'repeated_set', lambda o: o['metadata']['helper_action_ir_events'].pop()),
        ('hidden fresh interpolation warning', 'quoted_set', lambda o: o['fresh'].update(stderr='')),
        ('hidden native host-call failure', 'nested_data', lambda o: o['native'].update(context_error=None)),
    ]
    for label, id, mutation in mutations:
        broken = copy.deepcopy(observations)
        change(broken, id, mutation)
        def check(broken=broken):
            g = check_observations(broken, cases)
            check_witnesses(g, cases)
        reject(label, check)
    broken = copy.deepcopy(traces)
    row = next(r for r in broken['cases'] if r['id'] == 'unicode_crlf')
    row['stderr'] = capture.envelope(b'')
    reject('hidden Unicode trace warning', lambda: check_trace(broken, groups))
    broken = copy.deepcopy(traces)
    def remove_reached(o):
        raw = base64.b64decode(o['trace_base64'])
        raw = raw.replace(b'Top:unmatched_helper_event_rewritten => TAKEN', b'Top:unmatched_helper_event_rewritten => SKIPPED')
        o.update(trace_base64=base64.b64encode(raw).decode(), trace_sha256=hashlib.sha256(raw).hexdigest(), trace_bytes=len(raw))
    change(broken, 'quoted_set', remove_reached)
    reject('hidden reached replacement', lambda: check_trace(broken, groups))
    broken = copy.deepcopy(tests)
    broken['rows'][0]['exit'] = 1
    reject('hidden failed suite', lambda: check_tests(broken))
    report = {'owner': OWNER, 'activation': BASE, 'sources': len(cases), 'native_fresh_pairs': len(observations['cases']),
              'trace_processes': len(traces['cases']), 'trace_capture_exit': 1,
              'trace_warning_owner': 'PERL-TRACE-UNICODE-SINK.1',
              'desired_oracle_summary': summary, 'suites': counts, 'tests': sum(c['tests'] for c in counts),
              'rejected_evidence_controls': controls,
              'limits': 'Diagnostic current quote oracles remain RED; no repair/backend/syntax admission. Raw host values and warnings are not portable positives. Complete streams remain unprojected. Three named seeds are exact observations, not a statistical confidence interval.'}
    (ROOT / (PREFIX + 'verification.json')).write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'desired_oracle_summary'}))


if __name__ == '__main__':
    main()
