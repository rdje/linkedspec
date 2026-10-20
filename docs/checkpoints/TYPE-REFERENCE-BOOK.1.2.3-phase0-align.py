"""Replace only observed obsolete Phase0 spelling assertions with executed values."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

prefix = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
preserved = json.loads(__import__('gzip').decompress((ROOT / (prefix + 'preservation.json.gz')).read_bytes()))
readonly = json.loads((ROOT / (prefix + 'readonly.json')).read_bytes())
assert readonly['run']['returncode'] == 0 and readonly['claim_unchanged']
assert readonly['all_inputs_bytes_modes_unchanged']
original_run = json.loads((ROOT / (prefix + 'original-run.json')).read_bytes())
assert original_run['returncode'] != 0
path = 't/phase0_regression.t'
before = c.read(path)
assert before == preserved['before'][path]
source = c.decode(before['base64']).decode()
pipeline = 'my @IMATCH_LIST = qw(alpha beta alpha apple);'
snapshot = 'my $name = "node_name"; my $block_namei = "branch"; my $content = "children"; '
projection = 'my %foo_hash = (take => "picked", skip => "ignored"); my $key = "take"; my $name = "node"; '
cases = [
    ('array(...) canonical wrapper rewrite preserves array constructor semantics',
     '', '["A", "B"]'),
    ('hash(...) canonical wrapper rewrite preserves hash constructor semantics',
     '', '{ kind => "node" }'),
    ('typed slot/container lowering reuses the expected scalar/hash/array Perl shapes',
     'my %meta = (kind => "node"); my @parts = qw(A B); my $name;', '{ parts_count => 2 }'),
    ('return(array(...)) canonical helper preserves tagged return payload',
     "no strict 'subs';", '["group_open", ["IMATCH"]]'),
    ('return(array(...)) canonical helper lowers entry/scalar-slot constructor payloads',
     'my @IMATCH_LIST = ("capture"); my $c = "tail";', '["semantic_annotation", ["capture", "tail"]]'),
    ('push accepts wrapped target symbol and lowers nested array(...) value expression',
     'my $items = ["before"]; my $tag = "tag"; my $name = "node";', '["before", ["tag", "node"]]'),
    ('return(payload) snapshots a runtime-typed binding inside structured harray payloads',
     snapshot + 'my $assigns = ["first"];', '{ node_name => "branch", children => ["first"] }'),
    ('structured harray snapshot lowering is deterministic',
     snapshot + 'my $assigns = { child => "first" };',
     '{ node_name => "branch", children => { child => "first" } }'),
    ('general return(payload) lowers nested array/hash payload with scalar helpers',
     'my $key = "field"; my $name = "node"; my $idx = 1; my @foo_arr = qw(zero one two);',
     '["semantic", { field => "node" }, [123, "one"]]'),
    ('general return(payload) lowers projected field/index reads inside nested hash/list payload',
     projection + 'my $item = "chosen"; my $list = "values";', '{ chosen => "picked", values => ["node", 123] }'),
    ('general return(payload) lowers base["..."][...] with hash-first path segments',
     'my $item = "chosen"; my $myref = { A => [{ C => ["zero", "one"] }] }; my $B = 0; my $D = 1;',
     '{ chosen => "one" }'),
    ('general return(payload) lowers hash(...) constructor payloads with nested helper values',
     projection, '{ kind => "node", item => "picked", list => ["node", 123] }'),
    ('general return(payload) lowers nested array-pipeline composition inside array(...) payloads',
     pipeline, '["ALPHA", "APPLE"]'),
    ('nested hash payload values accept array-wrapped array-pipeline composition',
     pipeline, '{ items => ["ALPHA", "APPLE"] }'),
    ('nested array payload values accept array-wrapped array-pipeline composition',
     pipeline, '["items", ["ALPHA", "APPLE"]]'),
    ('set(name, hash(... array(pipeline(...)))) lowers nested collection-valued hash initializer',
     pipeline + 'my $by_name;', '{ A => ["ALPHA", "APPLE"] }'),
    ('set(name, hash(... pipeline(...))) preserves the nested array typed value',
     'my $by_name; my $items = [qw(alpha beta beta)];', '{ A => ["BETA"] }'),
    ('push accepts hash payloads with nested collection-valued array-pipeline composition',
     pipeline + 'my $events = [];', '[{ items => ["ALPHA", "APPLE"] }]'),
    ('return(array(...)) accepts hash payloads with nested collection-valued array-pipeline composition',
     pipeline, '["semantic_annotation", { items => ["ALPHA", "APPLE"] }]'),
]
log = c.decode(original_run['combined_output_base64']).decode()
failed = set(re.findall(r"^    #   Failed test '([^\n]*)'\n    #   at t/phase0_regression.t line \d+\.", log, re.M))
assert failed == {row[0] for row in cases} | {'isolated real-fallback suite passes'}, sorted(failed)
assert 'owned fixture and excluded-tree decoy are removed' in log
changes = []
for label, setup, expected in cases:
    marker = "'" + label + "'"
    assert source.count(marker) == 1, label
    end = source.index(marker)
    starts = list(re.finditer(r'^    (?:is|like)\(', source[:end], re.M))
    assert starts, label
    start = starts[-1].start()
    end = source.index(');', end) + 2
    old = source[start:end]
    if label.startswith('typed slot/container'):
        actual = '$alias_rewrite'
    else:
        found = re.findall(r'^\s*(LinkedSpec::call_spec_handler_subst\([^\n]+\)),\s*$', old, re.M)
        assert len(found) == 1, old
        actual = found[0]
    message = label.replace('lowers', 'executes')
    if label.startswith('typed slot/container'):
        message = 'typed slot/container lowering executes the constructor result'
    if label.startswith('structured harray snapshot'):
        message = 'structured harray snapshot preserves the copied harray kind'
    new = ('    is_deeply(\n        evaluate_lowered_value(\n            ' + actual + ',\n'
           '            q{' + setup + '},\n        ),\n        { value => ' + expected + ' },\n'
           "        '" + message + "'\n    );")
    assert source.count(old) == 1
    source = source.replace(old, new, 1)
    changes.append(dict(label=label, before=old, after=new, setup=setup, expected_perl=expected))
helper = r'''
# Execute focused lowering fragments with explicit caller fixtures. Compilation
# and execution failures stay observable rather than matching an expected value.
# The standalone bare-symbol fixture opts out of strict subs explicitly; the
# capture-group fixture uses the real SourceLocation runtime.
sub evaluate_lowered_value {
    my ($code, $setup) = @_;
    require LinkedSpec::UnicodeCaseMapping;
    require LinkedSpec::SourceLocation::Runtime;
    $code = '+' . $code if $code =~ /^\s*\{/;
    my $execute = eval 'sub { ' . ($setup // '') . '; ' . $code . ' }';
    return { error => "compile: $@" } unless ref($execute) eq 'CODE';
    my $value;
    my $ok = eval { $value = $execute->(); 1 };
    return $ok ? { value => $value } : { error => "execute: $@" };
}

'''
assert source.count('sub discover_specs {') == 1
source = source.replace('sub discover_specs {', helper + 'sub discover_specs {', 1)
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(prefix + 'proposals.json.gz', dict(before={path: before}, after={path: after},
    changes=changes, producer=c.read(prefix + 'align.py'), helper=c.read(c.PREFIX + 'common.py'),
    source_before_measurement='original failed run used the retained accepted test source; '
        'no initial invocation-environment snapshot or separate stdout/stderr channels are invented.',
    scope='Nineteen observed source-layout assertions become independently specified executed values, '
          'one assertion each. Existing native parser results, descriptor metadata, fluent/structured '
          'comparisons, remaining source checks and all plans stay unchanged. The duplicate structured '
          'snapshot assertion now tests the harray kind as well as the first array case. No production edits.'), packed=True)
assert c.read(path) == before
(ROOT / path).write_bytes(raw)
assert c.read(path) == after
print('Nineteen Phase0 constructor/pipeline assertions now execute independent values')
