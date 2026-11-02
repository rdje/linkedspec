"""Replay exact emitted sources and distinguish Count callable-path repair from re-blessing."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

from book_review import Visible, normal

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
sys.path.insert(0, str(ROOT / 'tools'))
RUNTIME = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BEFORE = b'''  if ($logical_receiver || $emitted_result_chain) {
   my $current_expr = $logical_receiver
    ? $lower_ast_logical_call_node->($receiver)
    : $lower_ast_value_node->($receiver, { bare_scalar_read => 1 });
'''
AFTER = b'''  if ($logical_receiver || $emitted_result_chain) {
   # The compatibility callable-result path was already lowered above.
   # Re-reading its raw AST source would emit invalid Perl such as pick()[0].
   my $current_expr = $logical_receiver
    ? $lower_ast_logical_call_node->($receiver)
    : (($receiver->{kind} // '') eq 'raw_perl' && $ordinary_count_result_chain
      ? $receiver_expr
      : $lower_ast_value_node->($receiver, { bare_scalar_read => 1 }));
'''


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'signed-result packet identity'
    return raw


def observations(before, after):
    ids = ['control/result_path_' + name for name in ('positive', 'negative', 'float', 'string')]
    assert [row['case']['id'] for row in before] == ids
    assert [row['case']['id'] for row in after] == ids
    expected = [1, 2, 0, 0]
    for old, new, value in zip(before, after, expected):
        assert old['case'] == new['case'] and new['case']['expected'] == value
        assert not old['loaded'] and 'syntax error' in old['load_error']
        assert old['native'] is None and 'rule_handler_compile:Top => SKIPPED' in old['native_output']
        assert not old['native_error'] and not old['emit_error']
        assert new['loaded'] and new['native'] == value and new['generated'] == value
        assert all(not new[key] for key in ('native_error', 'native_output', 'emit_error', 'load_error', 'execute_error'))


def review():
    saved = json.loads(gzip.decompress((HERE / 'signed-result-repair.json.gz').read_bytes()))
    assert saved['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.14'
    intake = json.loads(gzip.decompress(decode(saved['intake'])))
    for section in ('after_inputs', 'channels', 'producers'):
        for row in saved[section].values():
            decode(row)
    for row in intake['inputs'].values():
        decode(row)
    original = decode(intake['inputs'][RUNTIME])
    current = decode(saved['after_inputs'][RUNTIME])
    assert original.count(BEFORE) == current.count(AFTER) == 1
    assert original.replace(BEFORE, AFTER, 1) == current, 'unreviewed runtime edit'
    from check_claim_verification import InputSnapshot, index_files
    files = index_files()
    snapshot = InputSnapshot(files)
    for name, expected in saved['prior_runtime_epoch'].items():
        assert hashlib.sha256(snapshot.read(name, '0db5e9e87b7c1cfaf09936b9629974787038f5e3')).hexdigest() == expected
    assert index_files() == files
    assert b'Failed 1/7 subtests' in decode(intake['canonical_failure'])
    diagnostic = json.loads(decode(intake['diagnosis']))
    assert diagnostic['ast']['receiver']['kind'] == 'raw_perl'
    before = json.loads(decode(intake['probe']))
    after = json.loads(decode(saved['channels']['signed-result-after.json']))
    observations(before, after)
    for mutation in ('loss', 'value', 'source', 'native'):
        changed = copy.deepcopy(after)
        if mutation == 'loss':
            changed.pop()
        elif mutation == 'value':
            changed[1]['generated'] = 1
        elif mutation == 'source':
            changed[0]['case']['source'] += ' '
        else:
            changed[0]['native'] = None
        try:
            observations(before, changed)
        except AssertionError:
            pass
        else:
            raise AssertionError('signed observation loss admitted: ' + mutation)
    # Execute the retained source itself, rather than trusting a reported loaded flag.
    replay = r'''use strict; use warnings; use JSON::PP; use LinkedSpec ();
my $j=JSON::PP->new->canonical->allow_nonref; local $/; my $rows=$j->decode(<STDIN>);
my @out; my $n=0; for my $r (@$rows) { my $p='SignedReplay'.$n++;
my $ok=eval "package $p; $r->{emitted}; 1"; my $error="$@"; my ($v,$e);
if ($ok) { eval { no strict 'refs'; my $in='x'; $v=&{$p.'::Execute'}(\$in); 1 } or $e="$@"; }
push @out,{loaded=>$ok?1:0,error=>$error,value=>$v,execute_error=>$e}; }
print $j->encode(\@out);'''
    result = subprocess.run(['perl', '-Iperl', '-e', replay], cwd=ROOT,
                            input=json.dumps(before + after).encode(), capture_output=True)
    assert result.returncode == 0 and not result.stderr, result.stderr
    actual = json.loads(result.stdout)
    assert len(actual) == 8
    assert all(not row['loaded'] and 'syntax error' in row['error'] for row in actual[:4])
    assert [row['value'] for row in actual[4:]] == [1, 2, 0, 0]
    assert all(row['loaded'] and not row['error'] and not row['execute_error'] for row in actual[4:])
    channels = {name: decode(row) for name, row in saved['channels'].items()}
    assert b'Files=3, Tests=42' in channels['signed-count-after.log'] and b'Result: PASS' in channels['signed-count-after.log']
    assert b'Tests=7' in channels['signed-native-check-final.log'] and b'Result: PASS' in channels['signed-native-check-final.log']
    assert b'unreviewed Count image admitted' in channels['objective-recovery-count.stderr']
    assert b"COUNT_CALLABLE_AFTER" not in decode(saved['auditor']), 'rejected audit inverse survived'
    assert b"unexpected argument 'build'" in channels['book-count-build.log']
    book = saved['book']
    old, new = decode(book['before']), decode(book['after'])
    start, end = new.index(b'Perl also preserves the existing callable-result indexed Count form.'), new.index(b'### 7.4 Hash Helpers')
    assert new[:start] + new[end:] == old, 'unreviewed book change'
    visible = Visible(); visible.feed(decode(book['rendered']).decode())
    assert 'native and independently emitted Perl return 2' in normal(''.join(visible.parts))
    return 'four actual source-load RED/native+fresh GREEN cases replay; exact runtime edit, native assertion ordering, source epochs, selected42+7 checks and loss/value/source/native denials PASS'


if __name__ == '__main__':
    print(review())
