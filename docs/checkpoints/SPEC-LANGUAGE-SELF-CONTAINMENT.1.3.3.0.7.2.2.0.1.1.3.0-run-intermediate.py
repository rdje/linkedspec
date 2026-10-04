"""Execute unchanged consumers and mdBook from a content-gated fixed capsule."""
from pathlib import Path
import argparse
import html
import importlib.util
import json
import os
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('run.py')
spec = importlib.util.spec_from_file_location('input_review', PREFIX + 'review.py')
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)


def environment():
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {key: value for key, value in os.environ.items() if key not in reset and not key.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_HASH_SEED='0', PERL_PERTURB_KEYS='2')
    return env


def write_report(path, report):
    # Every completed operation survives an interrupted later operation.
    candidate = path.with_suffix('.json.new')
    candidate.write_text(json.dumps(report, indent=2) + '\n')
    candidate.replace(path)


def execute(tree, command, env):
    wrapped = ['bash', 'tools/project_data_run.sh', *command]
    result = subprocess.run(wrapped, cwd=tree, env=env, capture_output=True)
    return {'command': wrapped, 'exit': result.returncode,
            'stdout': review.envelope(result.stdout), 'stderr': review.envelope(result.stderr)}


def render_book(tree, plan, env):
    # This existing wrapper enters its own same-volume managed run.
    command = ['bash', 'tools/run_mdbook_local.sh']
    result = subprocess.run(command, cwd=tree, env=env, capture_output=True)
    row = {'command': command, 'exit': result.returncode,
           'stdout': review.envelope(result.stdout), 'stderr': review.envelope(result.stderr)}
    if result.returncode:
        return row
    chapter = plan['book_chapter']
    html_path = chapter.replace('/src/', '/book/').removesuffix('.md') + '.html'
    rendered = (tree / html_path).read_bytes()
    cases = json.loads((tree / plan['book_examples']).read_bytes())
    examples = [cases[index]['source'] for index in plan['book_example_indices']]
    blocks = re.findall(r'```spec\n(.*?)\n```', (tree / chapter).read_text(), re.S)
    rendered_blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n')
                       for block in re.findall(r'<code class="language-spec">(.*?)</code>', rendered.decode(), re.S)]
    row.update(html_path=html_path, html=review.envelope(rendered), source_examples=examples,
               normalization='CRLF to LF; final fence newline removed')
    overlay_html = tree / 'docs/linkedspec-book/book/development/documentation-workflow.html'
    row['overlay_html'] = review.envelope(overlay_html.read_bytes())
    return row


def verify_book(tree, plan, row):
    review.check(row['exit'] == 0, 'actual book render successful exit')
    blocks = re.findall(r'```spec\n(.*?)\n```', (tree / plan['book_chapter']).read_text(), re.S)
    rendered_blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n')
                       for block in re.findall(r'<code class="language-spec">(.*?)</code>', review.unpack(row['html']).decode(), re.S)]
    for source in row['source_examples']:
        normalized = source.replace('\r\n', '\n').rstrip('\n')
        review.check(normalized in blocks and normalized in rendered_blocks, 'source-identical rendered example')
    overlay_rendered = review.unpack(row['overlay_html'])
    review.check(b'A test can read more than its own source file.' in overlay_rendered, 'actual input-closure documentation render')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', choices=('smoke', 'full'), required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    output = ROOT / args.output
    review.check(args.output.startswith('docs/checkpoints/') and args.output.endswith('.json')
                 and '..' not in Path(args.output).parts and not output.is_symlink(), 'owned report path')
    plan = json.loads(Path(PREFIX + 'plan.json').read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    capsule = Path(PREFIX + 'inputs.tar.gz').read_bytes()
    review.check(review.sha(capsule) == manifest['capsule_sha256'], 'actual run capsule identity')
    files = review.read_capsule(capsule)
    summary = review.verify_capsule(plan, manifest, files)
    scratch = ROOT / '.linkedspec-data/scratch/selected-proof-closure'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='fixed-inputs-', dir=scratch))
    review.check(tree.stat().st_dev == ROOT.stat().st_dev, 'same-volume isolated inputs')
    modes = {entry['path']: int(entry['mode'][-3:], 8) for entry in manifest['entries']}
    for path, data in files.items():
        target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        target.chmod(modes[path])
    report = {'version': 1, 'mode': args.mode, 'capsule_sha256': manifest['capsule_sha256'],
              'boundary': {'revision': plan['revision'], 'overlays': plan['overlays']},
              'input_tree': tree.relative_to(ROOT).as_posix(), 'input_summary': summary,
              'toolchain_scope': 'Read-only PATH-resolved host Perl/prove/mdBook and their OS/standard-library dependencies; project payload bytes are capsule-owned. No submodule or other-repository payload is used.',
              'runtime_identities': [], 'rows': [], 'book': None, 'complete': False}
    report['instruments'] = [{'path': Path(path).relative_to(ROOT).as_posix(),
                              'sha256': review.sha(Path(path).read_bytes())}
                             for path in (__file__, PREFIX + 'review.py', PREFIX + 'plan.json')]
    env = environment()
    for program in ('perl', 'prove', 'mdbook'):
        executable = shutil.which(program, path=env.get('PATH'))
        review.check(executable is not None, 'required host tool ' + program)
        data = Path(executable).resolve().read_bytes()
        report['runtime_identities'].append({'tool': program, 'sha256': review.sha(data), 'bytes': len(data)})
    write_report(output, report)
    tests = plan['tests'] if args.mode == 'full' else ['t/actionir_helper_source_provenance.t', 't/generated_source_contract.t']
    for test in tests:
        before = review.verify_tree(tree, manifest)
        row = execute(tree, ['prove', '-v', '-Iperl', test], env)
        row.update(test=test, inputs_before=before)
        report['rows'].append(row)
        write_report(output, report)
        try:
            row['inputs_after'] = review.verify_tree(tree, manifest)
        except ValueError as error:
            row['input_check_failure'] = str(error)
            write_report(output, report)
            raise
        write_report(output, report)
        count = review.verify_tap(row)
        print(f"{test}: PASS complete {count}; fixed inputs before/after {before}", flush=True)
    report['book'] = render_book(tree, plan, env)
    write_report(output, report)
    verify_book(tree, plan, report['book'])
    report['inputs_after_book'] = review.verify_tree(tree, manifest)
    for instrument in report['instruments']:
        review.check(review.sha((ROOT / instrument['path']).read_bytes()) == instrument['sha256'], 'unchanged executing instrument')
    report['complete'] = True
    write_report(output, report)
    print(f"PASS fixed-capsule {args.mode} run and actual source-identical book rendering", flush=True)


if __name__ == '__main__':
    main()
