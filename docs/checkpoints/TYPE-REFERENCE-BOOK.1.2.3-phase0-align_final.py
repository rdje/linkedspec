"""Land source-bound finite Phase0 value goldens without changing its test plans."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
readonly = json.loads((ROOT / (P + 'readonly.json')).read_bytes())
assert readonly['run']['returncode'] == 0 and readonly['all_inputs_bytes_modes_unchanged']
assert c.read(c.CLAIM) == preserved['original_claim']
assert all(c.read(path)['sha256'] == item['sha256'] and c.read(path)['mode'] == item['mode']
           for path, item in preserved['identities'].items())
plan = json.loads(gzip.decompress((ROOT / (P + 'oracle-observed-inputs.json.gz')).read_bytes()))
review = json.loads((ROOT / (P + 'oracle-observed-review.json')).read_bytes())
assert review['result'] == 'PASS' and review['value_cases'] == 130 and review['actual_raw_advisories'] == 2
goldens = {row['label']: row['expected_json'] for row in review['goldens']}
path = 't/phase0_regression.t'
before = c.read(path)
assert before == preserved['before'][path] == plan['original_source']
source = c.decode(before['base64']).decode()
changes = []
for row in plan['cases']:
    expected = goldens[row['label']]
    assert '#' not in expected
    fixture = '' if row['setup'] == plan['common_setup'] else ', q{' + row['setup'] + '}'
    message = row['message_expr']
    if row['label'].startswith('typed slot/container'):
        message = "'typed slot/container lowering executes the constructor result'"
    elif row['label'].startswith('structured harray snapshot'):
        message = "'structured harray snapshot preserves the copied harray kind'"
    new = ('    is(\n        evaluate_lowered_json(\n            ' + row['actual_expr'] + fixture
           + ',\n        ),\n        q#' + expected + '#,\n        ' + message + '\n    );')
    old = row['original_assertion']
    assert source.count(old) == 1, row['label']
    source = source.replace(old, new, 1)
    changes.append(dict(label=row['label'], before=old, after=new, kind='executed-value-and-diagnostics'))
for row in plan['structural']:
    assert '#' not in row['pattern']
    new = ('    like(\n        ' + row['actual_expr'] + ',\n        qr#' + row['pattern']
           + '#s,\n        ' + row['message_expr'] + '\n    );')
    old = row['original_assertion']
    assert source.count(old) == 1
    source = source.replace(old, new, 1)
    changes.append(dict(label=row['label'], before=old, after=new, kind='binding-and-api-structure'))
old = '''    ok(index($rewritten, '"end_pos" => do { LinkedSpec::SourceLocation::Runtime::position_offset') >= 0, 'input_end_pos() lowers through the typed whole-input right-edge position projection');'''
new = old.replace('"end_pos" => do { LinkedSpec::SourceLocation::Runtime::position_offset',
                  'LinkedSpec::SourceLocation::Runtime::position_offset')
assert source.count(old) == 1
source = source.replace(old, new, 1)
changes.append(dict(label=plan['identity_label'], before=old, after=new, kind='public-projection-identity'))
helper = r'''
# Evaluate emitted fragments against explicit finite compatibility fixtures.
# Errors and compiler/runtime diagnostics cannot satisfy a value-only result.
sub evaluate_lowered_json {
    my ($code, $setup) = @_;
    require JSON::PP;
    require LinkedSpec::UnicodeCaseMapping;
    require LinkedSpec::SourceLocation;
    $setup = q{__COMMON_FIXTURE__} unless defined $setup;
    my @warnings;
    local $SIG{__WARN__} = sub {
        my $warning = shift;
        # Only dynamic eval transport coordinates are excluded from comparison.
        $warning =~ s/ at \(eval \d+\) line \d+(?:, <STDIN> line \d+)?\.\n\z//;
        push @warnings, $warning;
    };
    my $json = JSON::PP->new->canonical->allow_nonref;
    $code = '+' . $code if $code =~ /^\s*\{/;
    my $execute = eval 'sub { ' . $setup . '; ' . $code . ' }';
    return $json->encode({ error => "compile: $@", warnings => \@warnings })
        unless ref($execute) eq 'CODE';
    my $value;
    my $ok = eval { $value = $execute->(); 1 };
    return $json->encode($ok
        ? { value => $value, warnings => \@warnings }
        : { error => "execute: $@", warnings => \@warnings });
}

'''.replace('__COMMON_FIXTURE__', plan['common_setup'])
assert source.count('sub discover_specs {') == 1
source = source.replace('sub discover_specs {', helper + 'sub discover_specs {', 1)
header = 'phase0_regression.t — LinkedSpec primary regression gate (989 subtests)'
assert source.count(header) == 1
source = source.replace(header, 'phase0_regression.t — LinkedSpec primary regression gate', 1)
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(P + 'proposals-final.json.gz', dict(before={path: before}, after={path: after}, changes=changes,
    producer=c.read(P + 'align_final.py'), helper=c.read(c.PREFIX + 'common.py'),
    oracle_plan=c.read(P + 'oracle-observed-inputs.json.gz'), oracle_review=c.read(P + 'oracle-observed-review.json'),
    scope='140 actual spelling failures:130 independent executed-value/diagnostic goldens, nine '
          'generated binding/API checks and one stable public source projection identity. Each remains '
          'one assertion; every plan, descriptor/native/fluent comparison and unrelated source assertion '
          'is unchanged. Two historical compiler advisories remain exactly asserted, not suppressed. '
          'Remove only the already-stale header count. No production edits.'), packed=True)
assert c.read(path) == before and len(changes) == 140
(ROOT / path).write_bytes(raw)
assert c.read(path) == after
print('Phase0140 spelling checks aligned:130 values/diagnostics, nine binding structures, one projection identity')
