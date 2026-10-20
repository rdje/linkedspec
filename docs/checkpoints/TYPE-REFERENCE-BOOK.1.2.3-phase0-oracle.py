"""Execute accepted historical test goldens, never the candidate lowering producer."""
import ast
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

prefix = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
preserved = json.loads(gzip.decompress((ROOT / (prefix + 'preservation.json.gz')).read_bytes()))
path = 't/phase0_regression.t'
assert c.read(path) == preserved['before'][path]
source = c.decode(preserved['before'][path]['base64']).decode()
# These four assignments are declarative fixtures in the unexecuted first plan.
# Execute only their trusted literal/list expressions; no writer body is run.
declarations = {}
draft_path = prefix + 'align.py'
for node in ast.parse((ROOT / draft_path).read_text()).body:
    if isinstance(node, ast.Assign) and isinstance(node.targets[0], ast.Name):
        if node.targets[0].id in ('pipeline', 'snapshot', 'projection', 'cases'):
            exec(compile(ast.Module(body=[node], type_ignores=[]), draft_path, 'exec'), declarations)
manual = {label: (setup, expected) for label, setup, expected in declarations['cases']}
setup = '''
my %meta = (kind => "token", source => "fixture");
my $meta = { %meta };
my %extra = (source => "extra");
my $extra = { %extra };
my @parts = (1, 3, 11);
my $parts = [@parts];
my $items = ["alpha", "beta"];
my @IMATCH_LIST = ("alpha", "beta");
my @LMATCH_LIST = ("local", "groups");
my $retv = { content => undef, parts => undef, meta => undef };
my $raw_name = " Node_fix.txt ";
my $stage = "parsed";
my $name = "node";
my $key = "kind";
my ($total, $avg, $median, $span, $lowest);
my $text = "entry";
my $STRING = \$text;
my $info = {};
my ($IPOS, $LSPOS, $LMATCH) = (0, 5, "");
'''
log_path = '.linkedspec-data/verification/type-values-phase0.log'
log = (ROOT / log_path).read_text()
failures = re.findall(r"^    #   Failed test '([^\n]*)'\n    #   at t/phase0_regression.t line (\d+)\.", log, re.M)
cases = []
for label, line in failures:
    if label in ('isolated real-fallback suite passes',
                 'input_end_pos() lowers through the typed whole-input right-edge position projection'):
        continue
    marker = "'" + label + "'"
    assert source.count(marker) == 1, label
    end = source.index(marker)
    starts = list(re.finditer(r'^    (is|like)\(', source[:end], re.M))
    assert starts
    start, kind = starts[-1].start(), starts[-1][1]
    end = source.index(');', end) + 2
    old = source[start:end]
    row = dict(label=label, line=int(line), original_assertion=old, setup=setup)
    if label in manual:
        row['setup'], row['manual_expected_perl'] = manual[label]
    if kind == 'is':
        lines = old.splitlines()
        assert len(lines) == 5, label
        assert lines[2].rstrip().endswith(',')
        row['historical_expected_expr'] = lines[2].strip()[:-1]
    else:
        assert label in manual, ('declare independent manual oracle', label)
    cases.append(row)
source_inputs = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'final-inputs.json.gz')).read_bytes()))['inputs']
runtime = {path: item for path, item in source_inputs.items() if path.startswith('perl/')}
assert c.unchanged(runtime)
plan = dict(cases=cases, partial_diagnostic_snapshot=c.read(log_path),
    original_phase0_source=preserved['before'][path],
    producer=c.read(prefix + 'oracle.py'), actor=c.read(prefix + 'oracle.pl'),
    declarative_draft=c.read(draft_path),
    runtime_identities={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in runtime.items()},
    scope='Finite observed source-layout failures only; this diagnostic may precede full Phase0 completion. '
          'Accepted c053 Phase0 literals and explicit independent manual expectations produce goldens '
          'under declared caller fixtures. The candidate lowering producer is never invoked to derive '
          'expected values. Public runtime source is unchanged except the unused MethodLowering candidate. '
          'No missing environment/channel evidence or exhaustive behavior is inferred.')
c.write_new(prefix + 'oracle-inputs.json.gz', plan, packed=True)
run = c.run(['perl', '-Iperl', prefix + 'oracle.pl'], input=json.dumps(plan).encode())
c.write_new(prefix + 'oracle-run.json.gz', dict(run=run, runtime_inputs_unchanged=c.unchanged(runtime)), packed=True)
assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), run
data = json.loads(c.decode(run['stdout_base64']))
assert len(data['rows']) == len(cases) and all(row['error'] is None for row in data['rows'])
print('Historical/manual finite value oracles PASS:', len(cases))
