"""Accept actual consumer runs at their distinct retained input boundaries."""
from pathlib import Path
import argparse
import copy
import html
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
PREP = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0-'
ACTIVATION = 'e853cd5a7537c0ad8452ffac57af18ef48215df1'


def load_oracle(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


oracle = load_oracle('expanded_inputs', PREFIX + 'input-oracle.py')
old_oracle = load_oracle('original_inputs', ROOT / (PREP + 'review.py'))
old_plan = json.loads((ROOT / (PREP + 'plan.json')).read_bytes())
old_manifest = json.loads((ROOT / (PREP + 'inputs.json')).read_bytes())
plan = json.loads(Path(PREFIX + 'plan.json').read_bytes())
manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
old_capsule = (ROOT / (PREP + 'inputs.tar.gz')).read_bytes()
capsule = Path(PREFIX + 'inputs.tar.gz').read_bytes()
oracle.check(oracle.sha(old_capsule) == old_manifest['capsule_sha256'], 'original retained capsule identity')
oracle.check(oracle.sha(capsule) == manifest['capsule_sha256'], 'expanded retained capsule identity')
old_files = oracle.read_capsule(old_capsule)
files = oracle.read_capsule(capsule)
original_path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-consumers.json'
overlay_path = 'docs/linkedspec-book/src/development/documentation-workflow.md'
historical_overlay = subprocess.check_output(['git', 'show', ACTIVATION + ':' + overlay_path], cwd=ROOT)
oracle.check(old_files[overlay_path] == files[overlay_path] == historical_overlay, 'exact historical e853 book overlay')
original_bytes = subprocess.check_output(['git', 'show', ACTIVATION + ':' + original_path], cwd=ROOT)
oracle.check((ROOT / original_path).read_bytes() == original_bytes, 'original passing observations preserved')
expected_counts = {row['test']: oracle.verify_tap(row) for row in json.loads(original_bytes)['rows']}
initial_bytes = Path(PREFIX + 'consumers-initial.json').read_bytes()
oracle.check(initial_bytes == Path(PREFIX + 'consumers.json').read_bytes(), 'initial failed run preserved exactly')
initial = json.loads(initial_bytes)
remaining = json.loads(Path(PREFIX + 'consumers-repair.json').read_bytes())


def verify_instruments(candidate, paths, historical):
    oracle.check([item['path'] for item in candidate['instruments']] == paths, 'actual executing instrument population')
    for instrument in candidate['instruments']:
        source = (subprocess.check_output(['git', 'show', ACTIVATION + ':' + instrument['path']], cwd=ROOT)
                  if historical else (ROOT / instrument['path']).read_bytes())
        oracle.check(oracle.sha(source) == instrument['sha256'], 'actual executing instrument byte identity')


def verify_row(row, summary):
    oracle.check(row['command'] == ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', row['test']], 'actual selected consumer command')
    oracle.check(row['inputs_before'] == row['inputs_after'] == summary['files'] and 'input_check_failure' not in row, 'closed runtime input boundaries')


def verify_book(candidate, inputs, summary):
    book = candidate['book']
    oracle.check(book['command'] == ['bash', 'tools/run_mdbook_local.sh'], 'actual measured book command')
    oracle.check(book['exit'] == 0 and candidate['inputs_after_book'] == summary['files'], 'successful measured book/input boundary')
    oracle.unpack(book['stdout']); oracle.unpack(book['stderr'])
    cases = json.loads(inputs[plan['book_examples']])
    examples = [cases[index]['source'] for index in plan['book_example_indices']]
    oracle.check(book['source_examples'] == examples, 'independent authored example identity')
    blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n') for block in
              re.findall(r'<code class="language-spec">(.*?)</code>', oracle.unpack(book['html']).decode(), re.S)]
    oracle.check(all(source.replace('\r\n', '\n').rstrip('\n') in blocks for source in examples), 'actual measured rendered example bytes')
    oracle.check(b'A test can read more than its own source file.' in oracle.unpack(book['overlay_html']), 'actual measured candidate overlay render')


def verify(first, last, first_inputs, last_inputs):
    first_summary = old_oracle.verify_capsule(old_plan, old_manifest, first_inputs)
    last_summary = oracle.verify_capsule(plan, manifest, last_inputs)
    oracle.check(set(last_inputs) - set(first_inputs) == set(plan['checkpoint_paths']), 'exact four additive checkpoint inputs')
    old_entries = {item['path']: item for item in old_manifest['entries']}
    new_entries = {item['path']: item for item in manifest['entries']}
    oracle.check(all(last_inputs.get(path) == raw and new_entries[path] == old_entries[path]
                     for path, raw in first_inputs.items()), 'unchanged common supplied input bytes and modes')
    oracle.check(first['mode'] == 'full' and first['complete'] is False and first['book'] is None, 'honest initial incomplete boundary')
    oracle.check(last['mode'] == 'remaining' and last['complete'] is True, 'completed remaining measurement boundary')
    for candidate, inputs_manifest, summary in ((first, old_manifest, first_summary), (last, manifest, last_summary)):
        oracle.check(candidate['boundary'] == {'revision': plan['revision'], 'overlays': plan['overlays']}, 'declared measured source boundary')
        oracle.check(candidate['capsule_sha256'] == inputs_manifest['capsule_sha256'] and candidate['input_summary'] == summary, 'actual per-run fixed input capsule')
    oracle.check([row['test'] for row in first['rows']] == plan['tests'] and
                 [row['test'] for row in last['rows']] == plan['tests'][-1:], 'exact named consumer population')
    verify_instruments(first, [PREP + name for name in ('run.py', 'review.py', 'plan.json')], True)
    verify_instruments(last, [Path(PREFIX + name).relative_to(ROOT).as_posix() for name in ('run.py', 'input-oracle.py', 'plan.json')], False)
    oracle.check(first['runtime_identities'] == last['runtime_identities'], 'same observed host tool identities')
    total = 0
    for row in first['rows'][:-1] + last['rows']:
        summary = last_summary if row is last['rows'][0] else first_summary
        verify_row(row, summary)
        count = oracle.verify_tap(row)
        oracle.check(count == expected_counts[row['test']], 'unchanged named consumer plan')
        total += count
    failed = first['rows'][-1]
    verify_row(failed, first_summary)
    stdout = oracle.unpack(failed['stdout']); stderr = oracle.unpack(failed['stderr'])
    oracle.check(failed['exit'] == 1 and b'No such file or directory at t/codeblock_matches_perl.t line 8.' in stderr
                 and b'No subtests run' in stdout and b'Result: FAIL' in stdout
                 and not re.search(rb'^1\.\.\d+\s*$', stdout, re.M), 'actual initial missing-input RED')
    verify_book(last, last_inputs, last_summary)
    return total


def verify_graph(candidate):
    sources = list(dict.fromkeys(plan['tests'] + plan['nested_tests'] + plan['nested_sources']))
    for path in sources:
        oracle.check((ROOT / path).read_bytes() == files[path], 'exact reader census source ' + path)
    pattern = r'\b(open|opendir|slurp|read_text|discover_specs|discover_markdown_docs|discover_dir_files_by_suffix|run_perl_test_file_in_subprocess)\b|docs/checkpoints|\bdo\s+[\x27\x22]'
    result = subprocess.run(['rg', '--no-heading', '-n', '--color', 'never', '-e', pattern, *sources], cwd=ROOT, capture_output=True)
    oracle.check(result.returncode == 0 and not result.stderr, 'independent reader-site census')
    expected = sorted((path, int(number), source) for path, number, source in
                      (line.split(':', 2) for line in result.stdout.decode().splitlines()))
    actual = sorted((site['path'], site['line'], site['source']) for site in candidate['source_related_sites'])
    oracle.check(actual == expected, 'complete source-related lexical census')
    edges = candidate['required_input_edges']
    oracle.check([(edge['path'], edge['literal'], edge['role']) for edge in edges] ==
                 [tuple(edge) for edge in plan['graph_sentinels']], 'complete named input edge population')
    for edge in edges:
        lines = files[edge['path']].decode().splitlines()
        oracle.check(edge['lines'] == [i for i, line in enumerate(lines, 1) if edge['literal'] in line], 'actual named input edge source positions')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--public-book', action='store_true')
    args = parser.parse_args()
    total = verify(initial, remaining, old_files, files)
    graph = json.loads(Path(PREFIX + 'input-graph.json').read_bytes())
    verify_graph(graph)
    for path, raw in files.items():
        if path.startswith(('perl/', 'specs/', 't/')):
            oracle.check((ROOT / path).read_bytes() == raw, 'current exact measured production/consumer owner ' + path)
    for candidate, inputs_manifest in ((initial, old_manifest), (remaining, manifest)):
        tree = ROOT / candidate['input_tree']
        oracle.check(tree.resolve().is_relative_to(ROOT / '.linkedspec-data/scratch/selected-proof-closure'), 'owned measured input tree')
        oracle.check(oracle.verify_tree(tree, inputs_manifest) == len(inputs_manifest['entries']), 'actual retained post-run input contents/modes/population')
    controls = []

    def reject(name, reason, mutation):
        first, last, first_inputs, last_inputs = copy.deepcopy((initial, remaining, old_files, files))
        mutation(first, last, first_inputs, last_inputs)
        try:
            verify(first, last, first_inputs, last_inputs)
        except ValueError as error:
            oracle.check(reason in str(error), 'control rejected for wrong reason ' + name)
            controls.append({'name': name, 'reason': str(error), 'rejected': True})
        else:
            raise ValueError('unrejected composed measurement control ' + name)

    def alter_tap(candidate, transform):
        row = candidate['rows'][0]
        raw = oracle.unpack(row['stdout'])
        changed = transform(raw)
        oracle.check(changed != raw, 'actual distinguishing TAP mutation')
        row['stdout'] = oracle.envelope(changed)

    reject('missing_named_suite', 'exact named consumer population', lambda a, b, c, d: a['rows'].pop(0))
    reject('incomplete_repair', 'completed remaining measurement boundary', lambda a, b, c, d: b.update(complete=False))
    reject('promote_initial_failure', 'honest initial incomplete boundary', lambda a, b, c, d: a.update(complete=True))
    reject('promote_smoke_mode', 'completed remaining measurement boundary', lambda a, b, c, d: b.update(mode='smoke'))
    reject('relabel_initial_capsule', 'actual per-run fixed input capsule', lambda a, b, c, d: a.update(capsule_sha256=manifest['capsule_sha256']))
    reject('ungated_post_run_inputs', 'closed runtime input boundaries', lambda a, b, c, d: a['rows'][0].update(inputs_after=0))
    reject('false_executing_source', 'actual executing instrument byte identity', lambda a, b, c, d: b['instruments'][0].update(sha256='0' * 64))
    reject('wrong_consumer_command', 'actual selected consumer command', lambda a, b, c, d: b['rows'][0]['command'].append('--changed'))
    reject('failed_top_level_TAP', 'consumer failing TAP', lambda a, b, c, d: alter_tap(a, lambda raw: re.sub(rb'^ok 1\b', b'not ok 1', raw, count=1, flags=re.M)))
    reject('failed_nested_TAP', 'consumer failing TAP', lambda a, b, c, d: alter_tap(a, lambda raw: re.sub(rb'^( +)ok 1\b', rb'\1not ok 1', raw, count=1, flags=re.M)))
    reject('missing_final_plan', 'consumer complete positive plan', lambda a, b, c, d: alter_tap(b, lambda raw: re.sub(rb'^1\.\.\d+\s*$', b'', raw, flags=re.M)))
    reject('missing_planned_reach', 'consumer complete ordered reach', lambda a, b, c, d: alter_tap(a, lambda raw: re.sub(rb'^ok 2\b[^\n]*\n', b'', raw, count=1, flags=re.M)))
    reject('false_prove_completion', 'prove final success marker', lambda a, b, c, d: alter_tap(b, lambda raw: raw.replace(b'Result: PASS', b'Result: UNKNOWN')))
    reject('hidden_stream_change', 'stream byte identity', lambda a, b, c, d: a['rows'][0]['stderr'].update(sha256='0' * 64))
    reject('erase_actual_input_failure', 'actual initial missing-input RED', lambda a, b, c, d: a['rows'][-1].update(stderr=oracle.envelope(b'')))
    reject('failed_book_render', 'successful measured book/input boundary', lambda a, b, c, d: b['book'].update(exit=1))
    reject('changed_authored_example', 'independent authored example identity', lambda a, b, c, d: b['book']['source_examples'].__setitem__(0, 'changed'))
    reject('missing_transitive_JSON', 'capsule directory population', lambda a, b, c, d: d.pop('tests/lispish/quoted-newlines.json'))
    reject('missing_checkpoint_probe', 'capsule directory population', lambda a, b, c, d: d.pop(plan['checkpoint_paths'][1]))
    reject('changed_nested_consumer', 'input byte identity', lambda a, b, c, d: d.update({'t/staged_ast_enrichment_perl_contract.t': b'changed'}))
    for name, key, reason in [('drop_lexical_site', 'source_related_sites', 'complete source-related lexical census'), ('drop_input_edge', 'required_input_edges', 'complete named input edge population')]:
        changed = copy.deepcopy(graph); changed[key].pop()
        try:
            verify_graph(changed)
        except ValueError as error:
            oracle.check(str(error) == reason, 'graph rejection reason')
            controls.append({'name': name, 'reason': str(error), 'rejected': True})
        else:
            raise ValueError('unrejected graph control ' + name)
    report = {'activation': ACTIVATION, 'measured_boundary': initial['boundary'],
              'capsules': [{'sha256': old_manifest['capsule_sha256'], 'files': len(old_files), 'passing_suites': 12, 'passing_tests': sum(expected_counts[t] for t in plan['tests'][:-1])},
                           {'sha256': manifest['capsule_sha256'], 'files': len(files), 'passing_suites': 1, 'passing_tests': expected_counts[plan['tests'][-1]]}],
              'added_checkpoint_inputs': plan['checkpoint_paths'], 'suites': 13, 'top_level_tests': total,
              'suite_plans': [{'test': t, 'tests': expected_counts[t]} for t in plan['tests']],
              'source_related_sites': len(graph['source_related_sites']), 'named_input_edges': len(graph['required_input_edges']),
              'rendered_examples': 2, 'controls': controls,
              'scope': 'Twelve unchanged suites passed at the original738-file fixed boundary; the last suite passed39 groups after four exact Git checkpoint inputs were added. Each actual per-run boundary is preserved; shared bytes/modes are identical. The original missing-input failure remains recorded. This source-bound composition supersedes earlier broader acceptance without recovering its unretained live-document reads. Wider historical audit remains startup .5. Canonical closeout follows the exact staged current candidate.'}
    if args.public_book:
        book_manifest = json.loads(Path(PREFIX + 'book-inputs.json').read_bytes())
        book_capsule = Path(PREFIX + 'book-inputs.tar.gz').read_bytes()
        book = json.loads(Path(PREFIX + 'book.json').read_bytes())
        oracle.check(oracle.sha(book_capsule) == book_manifest['capsule_sha256'] == book['capsule_sha256'], 'final public book capsule identity')
        public_inputs = oracle.read_capsule(book_capsule)
        paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
        expected = {p for p in paths if p and not p.startswith('docs/linkedspec-book/book/')}
        oracle.check(set(public_inputs) == {item['path'] for item in book_manifest['entries']} == expected, 'complete final public book population')
        for entry in book_manifest['entries']:
            raw = public_inputs[entry['path']]
            oracle.check(len(raw) == entry['bytes'] and oracle.sha(raw) == entry['sha256'] and (ROOT / entry['path']).read_bytes() == raw, 'actual final public book input identity')
        oracle.check(book['complete'] is True and book['exit'] == 0 and book['inputs_after'] == len(expected), 'final public book complete render')
        for key in ('stdout', 'stderr', 'html', 'workflow_html'):
            oracle.unpack(book[key])
        oracle.check(book['source_examples'] == remaining['book']['source_examples'], 'final public source-identical examples')
        blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n') for block in re.findall(r'<code class="language-spec">(.*?)</code>', oracle.unpack(book['html']).decode(), re.S)]
        oracle.check(all(source.replace('\r\n', '\n').rstrip('\n') in blocks for source in book['source_examples']), 'final public rendered original example bytes')
        oracle.check(b'The selected thirteen-suite remeasurement' in oracle.unpack(book['workflow_html']), 'final public acceptance explanation')
        report['public_book'] = {'inputs': len(expected), 'capsule_sha256': book['capsule_sha256'], 'rendered_examples': 2}
    Path(PREFIX + 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'PASS composed source-bound execution: 13 suites/{total} groups, two rendered examples, {len(controls)} reason-checked RED controls')


if __name__ == '__main__':
    main()
