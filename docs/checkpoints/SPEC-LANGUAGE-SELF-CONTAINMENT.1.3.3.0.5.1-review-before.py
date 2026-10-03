"""Replay exact public RED/GREEN sources and focused suites; write scratch only."""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-'
BASE = '5174958ea5d2d9aa709faff6d9c7d91189553b08'
SUITES = ('t/codeblock_attached_if_perl.t', 't/codeblock_matches_perl.t', 't/callable_codeblock_literal_contract.t',
          't/logical_helper_perl_contract.t', 't/variadic_user_function_contract.t',
          't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t',
          't/composed_normalization_perl.t', 't/actionir_ast_parser.t',
          't/multiline_helper_pattern_validation.t')
ENV = dict(os.environ, PERL5LIB='')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def equal(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(equal(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(equal(a[k], b[k]) for k in a)
    return a == b


def check(observation, cases, baseline=False):
    rows = observation['cases']
    require(len(rows) == 46 and [r['id'] for r in rows] == [c['id'] for c in cases], 'case population')
    for row, case in zip(rows, cases):
        require(row['source'] == case['source'] and digest(row['source'].encode()) == row['source_sha256'], 'source identity')
        require(row['dump'] and digest(row['emitted'].encode()) == row['emitted_sha256'] == row['fresh']['emitted_sha256'], 'emitted identity')
        require(row['native']['exception'] is None, 'native host failure')
        for route in ('native', 'fresh'):
            actual = row[route]
            error = actual['context_error'] if route == 'native' else actual['exception']
            require(actual['stderr'] == '', 'host warning')
            broken = baseline and case['baseline_control_failure']
            if 'expected' in case and not broken:
                require(error is None and actual['stdout'] == '' and equal(actual['value'], case['expected']), 'value/effect oracle')
            else:
                require(actual['value'] is None and isinstance(error, dict), 'typed failure absent')
                detail = error['detail']
                require(detail['observed_class'] == 'LinkedSpec::CodeblockRuntime::Error' and actual['actual_error_identity'] == 1, 'actual typed error identity')
                code = 'unsupported_codeblock_actionir' if broken else case.get('baseline_error',case.get('error')) if baseline else case.get('error')
                require(detail['code'] == code, 'typed failure code')
                kind = 'control_if' if broken else case.get('baseline_kind',case.get('kind')) if baseline else case.get('kind')
                if kind: require(detail['kind'] == kind, 'unsupported kind')
                if 'name' in case and not (baseline and 'baseline_error' in case):
                    require(detail['name'] == case['name'], 'unsupported helper name')
            if case['id'].endswith('scope'):
                invocation = actual['invocations'][0]
                require(invocation['x_before'] == invocation['x_after'] == 'outside' and
                        invocation['x_same_actual_slot'] == 1 and invocation['equal_value_distinct_slot_rejected'] == 1,
                        'actual slot restoration')
            expected_effects = {
                'nested_continue':['inner','outer'], 'selected_effects':['before','selected','after'],
                'condition_effects':['first','second'], 'after_return_effects':['hit']}
            if case['id'] in expected_effects:
                expected = ['before'] if baseline and case['id']=='selected_effects' else [] if baseline else expected_effects[case['id']]
                # Nested condition callbacks produce their own invocation rows; use the outer final row.
                require(actual['invocations'][-1]['effects_after'] == expected, 'actual branch effects')


def core(observation):
    return [{key: row[key] for key in ('id','source_sha256','emitted_sha256','native','fresh')}
            for row in observation['cases']]


def comparison(observation):
    rows = copy.deepcopy(core(observation))
    for row in rows:
        if row['native']['context_error'] is not None:
            row['native']['stdout'] = re.sub(r'(?m)^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]', '[wall-clock]', row['native']['stdout'])
    return rows


def main():
    cases = json.loads((ROOT / (PREFIX+'cases.json')).read_bytes())
    scratch = ROOT / '.linkedspec-data/scratch/codeblock-attached-if'
    scratch.mkdir(parents=True, exist_ok=True)
    require(scratch.resolve().is_relative_to(ROOT / '.linkedspec-data/scratch') and scratch.stat().st_dev == ROOT.stat().st_dev, 'scratch locality')
    native_run = subprocess.run([sys.executable,PREFIX+'native-compare.py'],cwd=ROOT,env=ENV,capture_output=True)
    require(native_run.returncode == 0 and not native_run.stderr, 'published native comparison failed')
    native_comparison = json.loads(native_run.stdout)
    require(native_comparison == json.loads((ROOT/(PREFIX+'native-comparison.json')).read_bytes()), 'native comparison drift')
    old_runtime = (ROOT / (PREFIX+'runtime-before.pm')).read_bytes()
    require(old_runtime == subprocess.check_output(['git','show',BASE+':perl/LinkedSpec/CodeblockRuntime.pm'],cwd=ROOT), 'baseline runtime drift')
    replays, retained = {}, {}
    for mode in ('red','green'):
        raw = (ROOT / (PREFIX+mode+'.json')).read_bytes()
        observation = json.loads(raw)
        check(observation, cases, mode == 'red')
        command = ['perl','-Iperl',PREFIX+'probe.pl'] + (['--baseline'] if mode == 'red' else [])
        run = subprocess.run(command, cwd=ROOT, env=ENV, capture_output=True)
        (scratch / (mode+'-replay.json')).write_bytes(run.stdout)
        require(run.returncode == 0 and not run.stderr, 'public replay failed')
        current = json.loads(run.stdout)
        check(current, cases, mode == 'red')
        require(comparison(current) == comparison(observation), 'public replay drift')
        replays[mode] = {'command':command,'exit':run.returncode,'core':core(current)}
        retained[mode] = {'path':PREFIX+mode+'.json','sha256':digest(raw)}
    require([r['emitted_sha256'] for r in replays['red']['core']] == [r['emitted_sha256'] for r in replays['green']['core']], 'generated format drift')
    controls = []
    green = json.loads((ROOT / (PREFIX+'green.json')).read_bytes())
    for name in ('truthiness','lazy-condition','selected-effects','nested-return','eager-boundary','implicit-statement','source','fresh-source','slot','exception'):
        changed = copy.deepcopy(green)
        rows = {r['id']:r for r in changed['cases']}
        if name == 'truthiness': rows['truth_zero_string']['fresh']['value'] = 'no'
        elif name == 'lazy-condition': rows['condition_effects']['fresh']['value'].append('third')
        elif name == 'selected-effects': rows['selected_effects']['native']['invocations'][-1]['effects_after'].append('bad')
        elif name == 'nested-return': rows['nested_return']['native']['value'] = 'after'
        elif name == 'eager-boundary': rows['eager_local_return']['fresh']['value'] = 'inner'
        elif name == 'implicit-statement': rows['implicit_true']['native']['value'] = 'hit'
        elif name == 'source': rows['original']['source'] += ' changed'
        elif name == 'fresh-source': rows['true']['fresh']['emitted_sha256'] = '0'*64
        elif name == 'slot': rows['parameter_scope']['native']['invocations'][0]['x_same_actual_slot'] = 0
        else: rows['body_failure_scope']['fresh']['actual_error_identity'] = 0
        try: check(changed, cases)
        except ValueError as error: controls.append({'name':name,'reason':str(error)})
        else: raise ValueError('corruption accepted: '+name)
    logs, tests = [], []
    for path in SUITES:
        command = ['prove','-v','-Iperl',path]
        run = subprocess.run(command, cwd=ROOT, env=ENV, capture_output=True)
        require(run.returncode == 0, 'focused suite failed: '+path)
        match = re.search(rb'Files=1, Tests=(\d+),', run.stdout)
        require(match and b'Result: PASS' in run.stdout, 'incomplete TAP: '+path)
        tests.append({'path':path,'tests':int(match.group(1))})
        logs.append({'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode()})
    paths = set(subprocess.check_output(['git','ls-files','perl','lua'],cwd=ROOT).decode().splitlines()) | set(SUITES)
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob('SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-*') if p.name != 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-verification.json')
    paths.update(('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm',
                  'capability_conformance/callable_codeblock_contract.json','capability_conformance/callable_signature_contract.json',
                  'capability_conformance/logical_helper_contract.json','capability_conformance/uniform_binding_contract.json',
                  'capability_conformance/outward_descriptor_contract.json','specs/spec.spec',
                  'tests/language-readiness/composed/normalization-calls.spec',
                  'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh','tools/run_lua_project_data.sh','tools/project_data_lua_env.sh'))
    inputs = {p:digest((ROOT/p).read_bytes()) for p in sorted(paths)}
    for path in paths:
        if path.startswith(('perl/','lua/','t/','capability_conformance/','specs/','tests/')) and path not in {'perl/LinkedSpec/CodeblockRuntime.pm','t/codeblock_attached_if_perl.t'}:
            require(inputs[path] == digest(subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)), 'unowned production/test/authority drift: '+path)
    print(json.dumps({'version':1,'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1','cases':len(cases),'retained_observations':retained,
                      'actual_public_replays':replays,'native_comparison':native_comparison,'controls':controls,'tests':tests,'logs':logs,'tracked_inputs':inputs,
                      'projection':'Only anchored native failure trace datetime prefixes project; both raw streams retained. Raw descriptor ordering belongs to self-containment .0.6.',
                      'limits':'Typed attached statement families and return propagation only. Marker/value forms, loops and null-return forms retain separately owned failures. Existing fn statement bodies, raw descriptor ordering/readiness, dispatcher/full16 and other-backend admission remain separate. Report corruptions are not semantic runtime mutants.'},indent=2,sort_keys=True))


if __name__ == '__main__':
    main()
