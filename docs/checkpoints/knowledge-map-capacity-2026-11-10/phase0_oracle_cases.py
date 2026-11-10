"""Author finite value/effect oracles for the twenty observed source assertions."""
import gzip
import json
from pathlib import Path

HERE = Path(__file__).parent
before = gzip.decompress((HERE / 'phase0-before.t.gz').read_bytes()).decode()
lines = before.splitlines(keepends=True)
aggregate_setup = ('my %meta=(kind=>"token",source=>"fixture",stage=>"parsed"); '
    'my ($rest_keys,$first_keys,$middle_keys,$last_keys,$leading_keys,$first_key); '
    'my $skip_count=1; my $take_count=2; my $start_idx=1; my $slice_count=1; '
    'my $take_last_count=2; my $drop_count=1;')
simple_setup = 'my %meta=(kind=>"token",source=>"fixture"); my $first_key;'
# Values are authored from the named operations on these finite inputs, before
# executing either activation or repaired lowering. They are never source goldens.
definitions = [
    (16185, aggregate_setup, ['source', 'stage']),
    (16200, aggregate_setup, ['source', 'stage']),
    (16210, simple_setup, 'source'),
    (16225, aggregate_setup, ['kind', 'source']),
    (16235, simple_setup, 'kind'),
    (16250, aggregate_setup, ['source']),
    (16260, simple_setup, 'source'),
    (16275, aggregate_setup, ['source', 'stage']),
    (16285, simple_setup, 'source'),
    (16300, aggregate_setup, ['kind', 'source']),
    (16310, simple_setup, 'kind'),
    (16325, simple_setup, 'kind'),
    (16330, simple_setup, 'NODE'),
    (16335, simple_setup, 1),
    (36340, simple_setup, [0, {'kind': 'token', 'source': 'fixture'}]),
    (37692, 'my %meta=(kind=>"token",old_stage=>"draft");',
     [{'kind': 'token', 'stage': 'draft'}, {'kind': 'token', 'old_stage': 'draft'}]),
    (37810, 'my %meta=(kind=>"token",debug=>1,span=>[2]);',
     [{'kind': 'token'}, {'kind': 'token', 'debug': 1, 'span': [2]}]),
    (37935, 'my %meta=(kind=>"token",source=>"fixture",debug=>1);',
     [{'kind': 'token', 'source': 'fixture'}, {'kind': 'token', 'source': 'fixture', 'debug': 1}]),
    (39456, 'require LinkedSpec::RuntimeDiagnosticOutput; my @foo_arr=("skip","match","tail"); '
     'my %foo_hash=(kind=>"match",other=>"noise"); my $idx=1; my $key="kind"; '
     'my @seen; my $descr={}; $descr->{LinkedSpec::RuntimeDiagnosticOutput::sink_slot_name()}='
     'sub {push @seen,$_[0]{message}};', ['shape\n'.replace('\\n', '\n')]),
    (47967, 'my $meta={kind=>"token"}; my $key="stage"; my $value="payload"; '
     'my %__ls_binding_presence;',
     [2, {'kind': 'token', 'stage': 'payload'}, {'kind': 'token'}]),
]
cases = []
for line, setup, value in definitions:
    start = line - 1
    stop = start
    while not lines[stop].rstrip().endswith(');'):
        stop += 1
    old = ''.join(lines[start:stop + 1])
    if line == 47967:
        lowering = "LinkedSpec::call_spec_handler_subst('Top', 'return((meta[key] = value).count_keys())')"
        template = 'my $before=$meta; my $result=(sub { %s })->(); return [$result,$meta,$before];'
    elif line == 39456:
        lowering = "LinkedSpec::call_spec_handler_subst('Top', 'if(str_eq(foo_arr.drop_front(idx).first(), foo_hash.pick_keys(key).sorted_values().first())); say(\"shape\"); endif()')"
        template = '%s; return \\@seen;'
    else:
        lowering = lines[start + 1].strip().removesuffix(',')
        template = 'return [0 + (%s), {%%meta}];' if line == 36340 else (
            'return [%s, {%%meta}];' if line in (37692, 37810, 37935) else '%s')
    expected = json.dumps(dict(value=value, warnings=[]), sort_keys=True, separators=(',', ':'))
    assert "q#" not in setup and '#' not in expected
    code = (lowering if template == '%s' else
            "q#" + template.split('%s')[0].replace('%%', '%') + "# . " + lowering +
            " . q#" + template.split('%s')[1].replace('%%', '%') + "#")
    title = ("'nested-write assignment expression can feed a hash receiver chain'"
             if line == 47967 else lines[stop - 1].strip().removesuffix(');'))
    replacement = ('    is(\n        evaluate_lowered_json(\n            ' + code +
        ',\n            q#' + setup + '#,\n        ),\n        q#' + expected + '#,\n        ' + title + '\n    );\n')
    assert before.count(old) == 1
    cases.append(dict(line=line, original_assertion=old, lowering=lowering, setup=setup,
                      program_template=template, expected=expected, replacement=replacement))
assert len(cases) == 20
destination = HERE / 'phase0-oracle-cases.json'
assert not destination.exists(), 'one-shot pre-observation authored fixture'
destination.write_text(json.dumps(cases, indent=2) + '\n')
print(json.dumps(dict(result='authored', cases=len(cases))))
