"""Preserve scalar kinds in the two generated and one deferred lexical comparators."""
import common as c
import context
import transport_review


def main():
    transport = transport_review.check()
    accepted = c.load('accepted2-run.json.gz')
    assert accepted['inputs_unchanged'] and accepted['failures']
    prior = c.load('prior.json.gz')
    names = c.SOURCES + ['MEMORY.md']
    before = {path: c.read(path) for path in names}
    for path in c.SOURCES:
        assert c.identity(path) == {key: prior['images'][path][key] for key in ('sha256', 'mode')}
    after = {path: c.decode(packet['base64']).decode() for path, packet in before.items()}
    path = 'perl/LinkedSpec/BindingRuntime.pm'
    old_runtime = "  @values = sort { (defined($a) ? $a : '') cmp (defined($b) ? $b : '') } @values;\n"
    new_runtime = '''  # String comparison caches text on its operands. Compare copies so the
  # returned elements keep their original scalar kinds.
  @values = sort {
   my ($left, $right) = ($a, $b);
   (defined($left) ? $left : '') cmp (defined($right) ? $right : '')
  } @values;
'''
    assert after[path].count(old_runtime) == 1
    after[path] = after[path].replace(old_runtime, new_runtime, 1)
    path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    marker = '  return undef unless $sorted_args;\n'
    assert after[path].count(marker) == 1
    declaration = '''
  # Compare scalar copies: cmp must not add string flags to stored elements.
  my $sort_comparison = 'my ($__ls_sort_left, $__ls_sort_right) = ($a, $b); '
   . '(defined($__ls_sort_left) ? $__ls_sort_left : "") cmp '
   . '(defined($__ls_sort_right) ? $__ls_sort_right : "")';
'''
    after[path] = after[path].replace(marker, marker + declaration, 1)
    old_emitted = '(defined($a) ? $a : "") cmp (defined($b) ? $b : "")'
    assert after[path].count(old_emitted) == 2
    after[path] = after[path].replace(old_emitted, "'.$sort_comparison.'")
    path = 'MEMORY.md'
    lines = after[path].splitlines()
    for index, line in enumerate(lines):
        if line.startswith('- next_action:'):
            lines[index] = '- next_action: Run candidate1 on the fixed116 plan, inspect scalar flags/clones and source/index controls, then permanent tests/direct dependents/book/canonical admission before committing13.'
        elif line.startswith('- in_flight_uncommitted:'):
            lines[index] = '- in_flight_uncommitted: Leaf13 comparator implementation and retained proof/metadata. Runtime changes are unverified; book/admission and normal commit remain.'
    after[path] = '\n'.join(lines) + '\n'
    supplied = context.snapshot()
    c.write_new('implementation-inputs.json.gz', supplied)
    for path, text in after.items():
        (c.ROOT / path).write_text(text)
        (c.ROOT / path).chmod(before[path]['mode'])
    unaffected = {path: item for path, item in supplied['inputs'].items() if path not in names}
    stable = c.unchanged(unaffected)
    c.write_new('implementation.json.gz', dict(producer=c.read(c.PREFIX + 'implement.py'),
        before=before, after={path: c.read(path) for path in names},
        runtime_replacement=dict(old=old_runtime, new=new_runtime),
        emitted_replacement=dict(old=old_emitted, declaration=declaration),
        unaffected_inputs_unchanged=stable, transport=transport,
        scope='Only operand comparison changes in BindingRuntime sorted and both MethodLowering sorted emitter paths. Lexical/null ordering, array selection, cloning implementation and typed-index policy stay unchanged. Candidate behavior is not yet admitted.'))
    assert stable
    print('Three lexical comparator paths compare scalar copies; complete before/after and supplied context retained; candidate verification next')


if __name__ == '__main__':
    main()
