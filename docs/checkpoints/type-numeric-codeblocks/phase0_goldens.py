"""Execute accepted frozen fragments against the complete accepted numeric adapter."""
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
import common as c

TEST = 't/phase0_regression.t'
NUMERIC = 'perl/LinkedSpec/Numeric.pm'
FIXTURE_NAME = 'assign helper accepts num_min(...) over normalized scalar expressions'
SETUP = '''my @parts = (1, 3, 11);
my $raw_name = " Node_fix.txt ";
my $name = "node";
my $offset = 2;
my $factor = 3;
my $limit = 4;
my $divisor = 3;
my $lower_limit = 0;
my $upper_limit = 10;
my ($total, $scaled, $floor_value, $bucket, $bounded);'''


def assertions(text):
    rows = []
    for match in re.finditer(r'(?m)^([ \t]*)is\(\n', text):
        ending = re.search(r'(?m)^' + re.escape(match[1]) + r'\);\n', text[match.end():])
        if not ending:
            continue
        end = match.end() + ending.end()
        block = text[match.start():end]
        expected = re.findall(r'(?m)^\s+q\{(.*)\},\n', block)
        if len(expected) != 1 or not re.search('__ls_num_(add|mul|min|max)_terms', expected[0]):
            continue
        lines = block.splitlines()
        assert len(lines) == 5 and lines[1].rstrip().endswith(',')
        assert lines[-2].strip().startswith("'") and lines[-2].strip().endswith("'")
        rows.append(dict(id=lines[-2].strip()[1:-1], source=expected[0],
            actual=lines[1].strip()[:-1], start=match.start(), end=end, indent=match[1], before=block))
    assert len(rows) == len({row['id'] for row in rows}) == 21
    return rows


def main():
    test = c.read(TEST)
    assert c.decode(test['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + TEST], cwd=c.ROOT)
    rows = assertions(c.decode(test['base64']).decode())
    original = dict(setup=SETUP, cases=[dict(id=row['id'], source=row['source']) for row in rows])
    corrected = json.loads(json.dumps(original))
    fixture = next(row for row in corrected['cases'] if row['id'] == FIXTURE_NAME)
    assert fixture['source'].endswith('})')
    fixture['source'] = fixture['source'][:-1]
    old_numeric = subprocess.check_output(['git', 'show', c.BASE + ':' + NUMERIC], cwd=c.ROOT)
    prior = c.load('prior.json.gz')
    assert c.sha(old_numeric) == prior['inputs'][NUMERIC]['sha256']
    paths = (TEST, c.PREFIX + 'common.py', c.PREFIX + 'phase0_goldens.py',
             c.PREFIX + 'phase0_goldens.pl', 'tools/project_data_env.sh',
             'tools/project_data_run.sh', 'tools/run_python_project_data.sh')
    inputs = {path: c.identity(path) for path in paths}
    c.write_new('phase0-golden-inputs.json', dict(inputs=inputs, test=test, assertions=rows,
        original=original, corrected=corrected,
        numeric=dict(base=c.BASE, path=NUMERIC, sha256=c.sha(old_numeric), base64=c.encode(old_numeric),
                     mode=prior['inputs'][NUMERIC]['mode']),
        scope='Literal expected Perl from the accepted test runs against the entire accepted Numeric.pm, '
              'with an independent finite scalar frame. No candidate lowering supplies a golden. '
              'One authored extra closing parenthesis and its matching malformed expected literal are '
              'retained before a separate corrected oracle run.'))
    runs = {}
    with tempfile.TemporaryDirectory(prefix='numeric-phase0-reference-', dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        relative = root.relative_to(c.ROOT).as_posix()
        target = root / NUMERIC
        target.parent.mkdir(parents=True)
        target.write_bytes(old_numeric)
        target.chmod(prior['inputs'][NUMERIC]['mode'])
        for name, plan in [('original', original), ('corrected', corrected)]:
            run = c.run(['perl', '-I' + relative + '/perl', c.PREFIX + 'phase0_goldens.pl'],
                        input=json.dumps(plan).encode())
            assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
            observed = json.loads(c.decode(run['stdout_base64']))
            assert observed['numeric_module'] == relative + '/' + NUMERIC
            assert c.sha(target.read_bytes()) == c.sha(old_numeric)
            assert target.stat().st_mode & 0o7777 == prior['inputs'][NUMERIC]['mode']
            runs[name] = run
    c.write_new('phase0-golden-run.json.gz', dict(runs=runs, inputs_unchanged=c.unchanged(inputs)))
    assert c.unchanged(inputs)
    for name, run in runs.items():
        observed = json.loads(c.decode(run['stdout_base64']))['rows']
        errors = [row['id'] for row in observed if 'error' in row['observation']]
        print(name, ':', len(observed), 'frozen fragments; errors', errors)


if __name__ == '__main__':
    main()
