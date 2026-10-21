"""Measure sort flags before Storable legitimately caches integers on its input."""
import json
import common as c
import context


def main():
    first = c.load('checks-test-run.json.gz')
    assert first['inputs_unchanged'] and first['run']['returncode'] == 1
    diagnostic = c.decode(first['run']['stderr_base64'])
    assert b"$got->[0]{iOK} = '1'" in diagnostic
    assert b"$expected->[0]{iOK} = '0'" in diagnostic
    raw = c.load('decimal-observed.json.gz')
    assert raw['inputs_unchanged'] and raw['run']['returncode'] == 0
    assert not c.decode(raw['run']['stderr_base64'])
    rows = json.loads(c.decode(raw['run']['stdout_base64']))['rows']
    assert [row['operation'] for row in rows] == ['assignment', 'copied-sort', 'binding', 'clone']
    for row in rows[:3]:
        assert row['before'] == row['input_flags']
        order = [0,1,2,3] if row['operation'] == 'assignment' else [2,3,1,0]
        assert row['result_flags'] == [row['before'][index] for index in order]
    clone = rows[3]
    assert clone['result_flags'] == clone['before']
    assert clone['input_flags'] != clone['before']
    for before, after in zip(clone['before'], clone['input_flags']):
        assert not before['pOK'] and not after['pOK']
        assert before['nOK'] == after['nOK'] and after['iOK'] == 1
    path = 't/uniform_binding_contract.t'
    before = c.read(path)
    text = c.decode(before['base64']).decode()
    old = '''  my ($result, $copy, @warnings);
  {
   local $SIG{__WARN__} = sub { push @warnings, @_ };
   $result = LinkedSpec::BindingRuntime::array_transform($input, 'items', 'sorted');
   $copy = Storable::dclone($result);
  }
  # Read every flag before JSON encoding can request text from any scalar.
  my $source_flags = $flags_for->($input);
  my $result_flags = $flags_for->($result);
'''
    new = '''  my ($result, $copy, $source_flags, $result_flags, @warnings);
  {
   local $SIG{__WARN__} = sub { push @warnings, @_ };
   $result = LinkedSpec::BindingRuntime::array_transform($input, 'items', 'sorted');
   # Observe sort before cloning: Storable may cache private integer flags
   # on floating-point input scalars without changing their numeric kind.
   $source_flags = $flags_for->($input);
   $result_flags = $flags_for->($result);
   $copy = Storable::dclone($result);
  }
'''
    old = ''.join(' ' + line if line.strip() else line for line in old.splitlines(keepends=True))
    new = ''.join(' ' + line if line.strip() else line for line in new.splitlines(keepends=True))
    assert text.count(old) == 1
    supplied = context.snapshot()
    c.write_new('checks-correction-inputs.json.gz', supplied)
    c.source(path).write_text(text.replace(old, new, 1))
    c.source(path).chmod(before['mode'])
    c.write_new('checks-correction.json.gz', dict(before=before, after=c.read(path),
        diagnosis='Actual assignment, copied-sort and BindingRuntime preserve the exact source/permuted scalar flags. Storable dclone adds private iOK to its floating-point source while keeping nOK and no pOK, and emits a numeric clone. The first test measured sorted flags after that clone. Capture the exact sort flags before cloning; keep typed clone/value/source assertions unchanged. No production change.'))
    test_inputs = context.snapshot()
    c.write_new('checks-test2-inputs.json.gz', test_inputs)
    run = c.run(['bash','tools/project_data_run.sh','prove','-v','-Iperl',path])
    stable = c.unchanged(test_inputs['inputs'])
    c.write_new('checks-test2-run.json.gz', dict(run=run,inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    assert b'ok 13 - sorted scalar kinds survive lexical selection and cloning' in output
    assert output.count(b'1..8\n') == 9 and b'Result: PASS' in output
    proposal = 't/sorted_value_kinds_perl.t'
    original = c.read(proposal)
    assert original == c.load('permanent.json.gz')['kind_test']
    c.source(proposal).unlink()
    unaffected = {name: item for name,item in supplied['inputs'].items() if name not in (path,proposal)}
    assert c.unchanged(unaffected)
    c.write_new('checks-admission.json.gz',dict(target=path, after=c.read(path),
        original_proposal=original, proposal_absent=not (c.ROOT/proposal).exists(),
        run='checks-test2-run.json.gz', cases=9, assertions=72,
        scope='Mandatory uniform suite; exact sort flags captured before clone, separate JSON-strict clone kinds and source/result independence. Original unexecuted standalone proposal preserved whole before exact deletion. Original failed test and diagnostic epochs retained.'))
    print('Direct scalar checks admitted: nine cases / 72 assertions; actual clone-cache cause retained; mandatory uniform suite PASS')


if __name__ == '__main__':
    main()
