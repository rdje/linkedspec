"""Accept preparation observations without promoting them to full-suite proof."""
from pathlib import Path
import copy
import html
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('accept.py')
spec = importlib.util.spec_from_file_location('capsule_review', PREFIX + 'review.py')
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
plan = json.loads(Path(PREFIX + 'plan.json').read_bytes())
manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
files = review.read_capsule(Path(PREFIX + 'inputs.tar.gz').read_bytes())
summary = review.verify_capsule(plan, manifest, files)
graph = json.loads(Path(PREFIX + 'input-graph.json').read_bytes())
sources = list(dict.fromkeys(plan['tests'] + plan['nested_tests']))
for path in sources:
    review.check((ROOT / path).read_bytes() == files[path], 'activation-exact reader source ' + path)
# Independent rg census applies the declared lexical hit definition to exact
# source bytes. These include writes and quoted program text: never label them
# all runtime reads or classified defects.
pattern = r'\b(open|opendir|slurp|read_text|discover_specs|discover_markdown_docs|discover_dir_files_by_suffix|run_perl_test_file_in_subprocess)\b|docs/checkpoints|\bdo\s+[\x27\x22]'
result = subprocess.run(['rg', '--no-heading', '-n', '--color', 'never', '-e', pattern, *sources],
                        cwd=ROOT, capture_output=True)
review.check(result.returncode == 0 and not result.stderr, 'independent rg reader-site census')
expected = sorted((path, int(number), source) for path, number, source in
                  (line.split(':', 2) for line in result.stdout.decode().splitlines()))


def verify_graph(candidate):
    actual = sorted((site['path'], site['line'], site['source']) for site in candidate['source_related_sites'])
    review.check(actual == expected, 'complete source-related lexical census')
    edges = candidate['required_input_edges']
    review.check([(edge['path'], edge['literal'], edge['role']) for edge in edges] ==
                 [tuple(edge) for edge in plan['graph_sentinels']], 'complete named input edge population')
    for edge in edges:
        lines = files[edge['path']].decode().splitlines()
        found = [number for number, line in enumerate(lines, 1) if edge['literal'] in line]
        review.check(edge['lines'] == found, 'actual named input edge source positions')


verify_graph(graph)
controls = []
for name, key, reason in [('drop_lexical_site', 'source_related_sites', 'complete source-related lexical census'),
                          ('drop_input_edge', 'required_input_edges', 'complete named input edge population')]:
    altered = copy.deepcopy(graph)
    altered[key].pop()
    try:
        verify_graph(altered)
    except ValueError as error:
        review.check(str(error) == reason, 'graph control rejection reason')
        controls.append({'name': name, 'rejected': True, 'reason': reason})
    else:
        raise ValueError('graph corruption accepted')
smoke = json.loads(Path(PREFIX + 'smoke.json').read_bytes())
review.check(smoke['mode'] == 'smoke' and smoke['complete'] is True, 'completed smoke boundary')
review.check(smoke['capsule_sha256'] == manifest['capsule_sha256'] and smoke['input_summary'] == summary, 'actual smoke input capsule')
review.check([row['test'] for row in smoke['rows']] == ['t/actionir_helper_source_provenance.t', 't/generated_source_contract.t'], 'bounded smoke suite population')
count = sum(review.verify_tap(row) for row in smoke['rows'])
review.check(all(row['inputs_before'] == row['inputs_after'] == summary['files'] for row in smoke['rows']), 'all smoke input boundaries')
for instrument in smoke['instruments']:
    review.check(review.sha((ROOT / instrument['path']).read_bytes()) == instrument['sha256'], 'actual executing smoke instrument')
book = smoke['book']
review.check(book['exit'] == 0 and smoke['inputs_after_book'] == summary['files'], 'actual book exit/input boundary')
review.unpack(book['stdout']); review.unpack(book['stderr'])
cases = json.loads(files[plan['book_examples']])
examples = [cases[index]['source'] for index in plan['book_example_indices']]
review.check(book['source_examples'] == examples, 'original authored example identities')
blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n') for block in
          re.findall(r'<code class="language-spec">(.*?)</code>', review.unpack(book['html']).decode(), re.S)]
review.check(all(source.replace('\r\n', '\n').rstrip('\n') in blocks for source in examples), 'actual source-identical rendered blocks')
review.check(b'A test can read more than its own source file.' in review.unpack(book['overlay_html']), 'actual declared overlay rendered')
failure = json.loads(Path(PREFIX + 'control-run.json').read_bytes())
control = json.loads(Path(PREFIX + 'run-controls.json').read_bytes())
review.check(failure['complete'] is False and len(failure['rows']) == 1 and control['observed_rejection'] is True, 'actual input RED cannot claim completion')
review.check(failure['rows'][0]['input_check_failure'] == control['reason'] == 'runtime input directory population', 'actual input RED reason')
review.check(review.verify_tap(failure['rows'][0]) == 13, 'completed RED-run consumer channels preserved')
for instrument in failure['instruments'] + [control['instrument']]:
    review.check(review.sha((ROOT / instrument['path']).read_bytes()) == instrument['sha256'], 'actual RED executing instrument')
falsifiers = json.loads(Path(PREFIX + 'verification.json').read_bytes())['controls']
review.check(len(falsifiers) == 15 and all(row['rejected'] for row in falsifiers), 'executed capsule/TAP falsifiers')
original = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
for suffix in ('consumers.json', 'book.json', 'claim-initial.json', 'claim-initial.py', 'publish.py'):
    path = original + suffix
    expected_bytes = subprocess.check_output(['git', 'show', plan['revision'] + ':' + path], cwd=ROOT)
    review.check((ROOT / path).read_bytes() == expected_bytes, 'original observations/instruments preserved ' + suffix)
prior = json.loads((ROOT / 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0.json').read_bytes())
review.check(prior['claims'][0]['durability']['mode'] == 'historical' and prior['claims'][0]['durability']['revision'] == plan['revision'], 'historical private/compiler claim preserved')
for key in ('falsify', 'durability'):
    review.check(prior['claims'][1][key]['status'] == 'gap', 'original broader boundary remains disclosed')
report = {'boundary': smoke['boundary'], 'files': summary['files'], 'input_bytes': summary['input_bytes'],
          'lexical_sites': len(expected), 'named_input_edges': len(plan['graph_sentinels']),
          'smoke_suites': 2, 'smoke_tests': count, 'rendered_examples': len(examples),
          'capsule_TAP_controls': len(falsifiers), 'actual_post_run_input_RED': control,
          'graph_controls': controls,
          'limit': 'Preparation and two-suite smoke only. Thirteen-suite remeasurement and broader gap adjudication remain .3.1; wider historical claim audit remains SESSION-STARTUP-READING.5.'}
Path(PREFIX + 'acceptance.json').write_text(json.dumps(report, indent=2) + '\n')
print(f'PASS preparation: {summary["files"]} inputs, {count} smoke groups, two rendered examples, 18 reason-checked controls; full remeasurement pending')
