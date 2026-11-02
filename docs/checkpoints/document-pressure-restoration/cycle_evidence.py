"""Retain once, then independently review the origin-label fixture calibration."""
import argparse
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
SCRATCH = ROOT / '.linkedspec-data/normal-hook-restoration'
sys.path.insert(0, str(ROOT / 'tools'))
DESTINATION = HERE / 'cycle-repair.json.gz'
TEST = 't/codeblock_push_composition_perl.t'
BOOK = 'docs/linkedspec-book/src/appendix/formal-grammar.md'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'cycle evidence identity'
    return raw


def capture():
    assert not DESTINATION.exists(), 'preserve completed evidence epochs'
    intake = HERE / 'cycle-intake.json.gz'
    source = json.loads(gzip.decompress(intake.read_bytes()))
    for name in ('t/callback_identity.t', 'perl/LinkedSpec/CodeblockRuntime.pm'):
        assert (ROOT / name).read_bytes() == decode(source['inputs'][name]), 'unexpected identity implementation edit'
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.15', intake=packet(intake.read_bytes()),
                 after={name: packet((ROOT / name).read_bytes()) for name in source['inputs']},
                 channels={name: packet((SCRATCH / name).read_bytes()) for name in (
                     'cycle-probe-final.json', 'cycle-after.log', 'book-cycle-build.log',
                     'cycle-probe-scope-rejected.pl', 'cycle-probe-scope-rejected.log')},
                 producers={str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in (
                     Path(__file__), HERE / 'cycle_probe.pl', ROOT / 'tools/project_data_run.sh',
                     ROOT / 'tools/project_data_env.sh', ROOT / 'tools/run_mdbook_local.sh')},
                 rendered=packet((ROOT / 'docs/linkedspec-book/book/appendix/formal-grammar.html').read_bytes()),
                 limits='Four exact authored native/emitted diagnostic cases, complete push/identity fixtures and current book. Identity runtime remains byte-identical. Earlier producer stdout and scope setup errors are retained without product RED credit. No expanded historical objective source population, broader fixture/generation closure or portable admission. Canonical CI/normal hooks govern landing; broader custody remains TYPE-REFERENCE-BOOK.1.2.23.4.2.')
    DESTINATION.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('cycle-label calibration evidence retained')


def observations(rows):
    assert [row['id'] for row in rows] == ['callback', 'copy', 'aggregate', 'function_copy']
    expected = dict(code='codeblock_recursion_unsupported', kind='codeblock_runtime_error',
                    cycle=['cb', 'cb'], **{'class': 'LinkedSpec::CodeblockRuntime::Error'})
    for row in rows:
        assert row['loaded'] == 1 and not row['load_error']
        assert row['native'] is None and row['fresh'] is None
        assert row['native_error'] == row['fresh_error'] == expected
        assert row['fresh_wrapper'] == dict(type='generated_source_error', code='generated_execution_failed',
                                            stage='execute_generated', source_identity=row['id'] + '.spec')


def review():
    saved = json.loads(gzip.decompress(DESTINATION.read_bytes()))
    assert saved['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.15'
    intake = json.loads(gzip.decompress(decode(saved['intake'])))
    for section in ('inputs',):
        for row in intake[section].values():
            decode(row)
    for section in ('after', 'channels', 'producers'):
        for row in saved[section].values():
            decode(row)
    old, new = decode(intake['inputs'][TEST]), decode(saved['after'][TEST])
    assert old.count(b"'cycle'=>['cb','callback']") == 1 and old.count(b"'cycle'=>['cb','fresh']") == 3
    assert old.replace(b"'cycle'=>['cb','callback']", b"'cycle'=>['cb','cb']").replace(
        b"'cycle'=>['cb','fresh']", b"'cycle'=>['cb','cb']") == new, 'unreviewed push test edit'
    for name in ('t/callback_identity.t', 'perl/LinkedSpec/CodeblockRuntime.pm'):
        assert decode(intake['inputs'][name]) == decode(saved['after'][name])
    identity = decode(saved['after']['t/callback_identity.t'])
    assert all(text in identity for text in (b'equal independent literal may execute while original is active',
                                             b"['a','b','a']", b"['outer','outer']"))
    failure = decode(intake['failure'])
    assert b'Failed 8/605 subtests' in failure and b'Result: FAIL' in failure
    channels = {name: decode(row) for name, row in saved['channels'].items()}
    assert b'Files=2, Tests=613' in channels['cycle-after.log'] and b'Result: PASS' in channels['cycle-after.log']
    assert b'Global symbol "$input"' in channels['cycle-probe-scope-rejected.log']
    rows = json.loads(channels['cycle-probe-final.json'])
    observations(rows)
    prototype = decode(intake['prototype_stdout'])
    assert b'DECISION rule_handler_eval:Top' in prototype
    original_rows = json.loads(prototype.splitlines()[-1])
    for old_row, row in zip(original_rows, rows):
        assert {key: row[key] for key in old_row} == old_row, 'prototype diagnostic observation changed'
    for mutation in ('alias', 'loss', 'wrapper', 'kind'):
        changed = copy.deepcopy(rows)
        if mutation == 'alias':
            changed[0]['native_error']['cycle'][-1] = 'callback'
        elif mutation == 'loss':
            changed.pop()
        elif mutation == 'wrapper':
            changed[0]['fresh_wrapper']['source_identity'] = 'foreign.spec'
        else:
            changed[0]['fresh_error']['code'] = 'unknown_helper'
        try:
            observations(changed)
        except AssertionError:
            pass
        else:
            raise AssertionError('cycle observation mutation admitted: ' + mutation)
    replay = r'''use strict; use warnings; use JSON::PP; use Scalar::Util qw(reftype); use LinkedSpec ();
my $j=JSON::PP->new->canonical->allow_nonref; local $/; my $rows=$j->decode(<STDIN>); my @out; my $n=0;
for my $r (@$rows) { my $p='CycleReplay'.$n++; my $ok=eval "package $p; $r->{emitted}; 1";
my $load_error="$@"; my ($v,$e); if ($ok) { eval { no strict 'refs'; my $in='x'; $v=&{$p.'::Execute'}(\$in); 1 } or $e=$@; }
my $detail=$e; while ((reftype($detail)//'') eq 'HASH' && ($detail->{type}//'') eq 'generated_source_error') {$detail=$detail->{detail};}
push @out,{loaded=>$ok?1:0,load_error=>$load_error,value=>$v,error=>{class=>ref($detail),%$detail},
wrapper=>{map {$_=>$e->{$_}} qw(type code stage source_identity)}}; } print $j->encode(\@out);'''
    result = subprocess.run(['perl', '-Iperl', '-e', replay], cwd=ROOT,
                            input=json.dumps(rows).encode(), capture_output=True)
    assert result.returncode == 0 and not result.stderr, result.stderr
    actual = json.loads(result.stdout)
    assert len(actual) == 4
    for row, emitted in zip(rows, actual):
        assert emitted == dict(loaded=1, load_error='', value=None, error=row['fresh_error'], wrapper=row['fresh_wrapper'])
    old_book, new_book = decode(intake['inputs'][BOOK]), decode(saved['after'][BOOK])
    start = new_book.index(b'On Perl, recursion diagnostics identify the active callable origin.')
    end = new_book.index(b'The `{|` opener is exact.')
    assert new_book[:start] + new_book[end:] == old_book, 'unreviewed cycle book change'
    visible = Visible(); visible.feed(decode(saved['rendered']).decode())
    assert 'Passing or copying cb under another name retains that origin' in normal(''.join(visible.parts))
    return 'four native/fresh complete origin diagnostics and emitted sources replay; exact four-label fixture correction; push605/identity8 and alias/loss/carrier/kind denials PASS'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    else:
        print(review())
