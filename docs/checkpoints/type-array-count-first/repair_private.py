"""Admit three current count-source expectations without rewriting native captures."""
from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0, str(ROOT / PREFIX))
import common as c
import context

TEST = 't/actionir_method_kind_capture.t'
LOWERING = c.SOURCES[1]
OLD = 'do { my $__ls_count = VALUE; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }'
NEW = "do { my $__ls_count = VALUE; ref($__ls_count) eq 'ARRAY' ? scalar(@{$__ls_count}) : 0 }"
IDS = ['outer/scalar', 'outer/function-present', 'outer/function-tied-bad']


def observe(stem):
    supplied = context.snapshot()
    run = c.run(['prove', '-v', '-Iperl', TEST])
    c.write_new(stem + '.json.gz', dict(context=supplied, run=run,
        inputs_unchanged=c.unchanged(supplied['inputs'])))
    return run


def main():
    draft = c.load('draft3.json.gz')
    assert draft['baseline']['returncode'] == 0 and draft['inputs_unchanged']
    assert draft['private']['returncode'] != 0
    before = {path: c.read(path) for path in [TEST, 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'MEMORY.md']}
    c.write_new('private-repair-inputs.json.gz', dict(context=context.snapshot(),
        producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()), before=before,
        plan=dict(ids=IDS, old=OLD, new=NEW,
            expected_values=[0, 3, 0, 0, 0, 0, 0],
            scope='Exact three observe/branches rows only; all other fields and original native files stay unchanged. Execute emitted expressions on empty/mixed arrays and undef/number/string/hash/callable nonarrays.')))
    tree = c.decode(before['docs/tasks/TYPE-REFERENCE-BOOK.md']['base64']).decode()
    tree = tree.replace('- Status: `active` / next registered pipeline .1.2.11; before enumeration',
                        '- Status: `active` / count/first10 private fixture repair; before enumeration', 1)
    start, end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'), tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `done` / selected proof; exact canonical admission required',
                                  'Status: `active` / private generated-source expectation repair', 1)
    leaf += ('  Defect owned: Canonical attempt2 completes1 with three stale count-source expectations in '
             't/actionir_method_kind_capture.t (outer/scalar, outer/function-present, outer/function-tied-bad). '
             'All90 other private files pass. Preserve whole unpublished draft3/actual readonly0 and complete '
             'failed channels, keep native capture bytes exact, update only these current expected guards, '
             'and independently execute every affected emitted expression against arrays/nonarrays. '
             'Require actual translation-omission and matched old-guard semantic RED, exact restoration, '
             'new publication and exact canonical admission.\n\n')
    c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(tree[:start] + leaf + tree[end:])
    memory = c.decode(before['MEMORY.md']['base64']).decode()
    memory = memory.replace('- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.10`', '- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.13`')
    memory = memory.replace('`TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first`', '`TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`')
    memory = memory.replace('(completed); task_owner:', '(active); task_owner:')
    lines = memory.splitlines()
    lines = [('- next_action: Repair the three private count-source expectations under10, preserve native captures, verify semantic controls and retry exact canonical admission.' if line.startswith('- next_action:') else
              '- in_flight_uncommitted: Owned10 private expectation repair; draft3 and actual readonly0/full canonical2 failure are retained; no canonical success yet.' if line.startswith('- in_flight_uncommitted:') else line) for line in lines]
    c.source('MEMORY.md').write_text('\n'.join(lines) + '\n')
    text = c.decode(before[TEST]['base64']).decode()
    marker = 'sub command {\n'
    assert text.count(marker) == 1
    helper = '''# Evaluate a controlled VALUE operand independently of the emitted spelling.
sub count_values {
 my ($source) = @_;
 return {error => 'expected one VALUE operand'} unless ($source =~ s/\\bVALUE\\b/\\$item/g) == 1;
 my $execute = eval 'sub { my ($item) = @_; ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my @values;
 my $ok = eval {
  push @values, $execute->($_) for ([], [undef, 7, []], undef, 7, 'x', {}, sub {die 'operand must not be called'});
  1;
 };
 return $ok ? {values => \\@values} : {error => "execute: $@"};
}
'''
    text = text.replace(marker, helper + marker, 1)
    marker = '   my $observed = $actual->{$group}[$row];\n'
    assert text.count(marker) == 1
    adjustment = '''   if ($surface eq 'observe' && $group eq 'branches'
       && $expected->{id} =~ m{^outer/(?:scalar|function-present|function-tied-bad)$}) {
    is($expected->{value}, q~OLD_SOURCE~,
     "$expected->{id} retains the original native count source");
    $expected->{value} = q~NEW_SOURCE~;
    is_deeply(count_values($observed->{value}), {values => [0, 3, 0, 0, 0, 0, 0]},
     "$expected->{id} emitted count handles array and nonarray operands");
   }
'''.replace('OLD_SOURCE', OLD).replace('NEW_SOURCE', NEW)
    text = text.replace(marker, marker + adjustment, 1)
    c.source(TEST).write_text(text)
    after = c.read(TEST)
    actor = c.PREFIX + 'repair_private.py'
    with (c.ROOT / actor).open('xb') as stream:
        stream.write(Path(__file__).read_bytes())
    green = observe('private-green')
    assert green['returncode'] == 0
    try:
        mutant = text.replace('    $expected->{value} = q~' + NEW + '~;', '    # Deliberately omit current source expectation.', 1)
        assert mutant != text
        c.source(TEST).write_text(mutant)
        omitted = observe('private-translation-fault')
    finally:
        c.source(TEST).write_bytes(c.decode(after['base64']))
        c.source(TEST).chmod(after['mode'])
    assert omitted['returncode'] != 0
    assert b'Failed 3/236 subtests' in c.decode(omitted['stdout_base64'])
    production = c.read(LOWERING)
    try:
        raw = c.decode(production['base64'])
        guard = b"ref($__ls_count) eq \\'ARRAY\\'"
        assert raw.count(guard) == 1
        c.source(LOWERING).write_bytes(raw.replace(guard, b'defined($__ls_count)', 1))
        # Match the emitted old spelling, so only execution distinguishes the bad guard.
        faulty = text.replace('    $expected->{value} = q~' + NEW + '~;', '    $expected->{value} = q~' + OLD + '~;', 1)
        assert faulty != text
        c.source(TEST).write_text(faulty)
        semantic = observe('private-semantic-fault')
    finally:
        c.source(LOWERING).write_bytes(c.decode(production['base64']))
        c.source(LOWERING).chmod(production['mode'])
        c.source(TEST).write_bytes(c.decode(after['base64']))
        c.source(TEST).chmod(after['mode'])
    assert semantic['returncode'] != 0
    assert b'Failed 3/236 subtests' in c.decode(semantic['stdout_base64'])
    errors = c.decode(semantic['stderr_base64'])
    assert errors.count(b'emitted count handles array and nonarray operands') == 3
    assert b'preserves complete native row' not in errors
    restored = observe('private-restored')
    assert restored['returncode'] == 0
    assert c.read(TEST) == after and c.read(LOWERING) == production
    original_inputs = draft['context']['inputs']
    native = {path: identity for path, identity in original_inputs.items()
        if path.startswith('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-')}
    assert native and c.unchanged(native)
    c.write_new('private-repair.json.gz', dict(before=before[TEST], after=after,
        production=production, ids=IDS, native=native, green=green,
        omission=omitted, semantic=semantic, restored=restored, sources_restored=True,
        scope='Original230 native comparisons retained; six assertions add exact original source and independent seven-input execution across three rows. Both actual faults reject; matched old-source semantic fault isolates behavior from source spelling. Native captures and production are restored exactly.'))
    print('Private count fixture:236 assertions GREEN; omission RED; matched old-guard semantic RED; exact restoration; native captures unchanged')


if __name__ == '__main__':
    main()
