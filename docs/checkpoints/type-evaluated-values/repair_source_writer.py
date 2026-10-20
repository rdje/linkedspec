"""Retain a no-write assertion-reader failure before using a separate corrected producer."""
import common as c

paths = ('t/actionir_ast_parser.t', 't/trace_actionir_method_lowering.t',
    c.PREFIX + 'strengthen_source_tests.py', c.PREFIX + 'strengthen_source_tests_final.py',
    c.PREFIX + 'repair_source_writer.py', c.PREFIX + 'common.py')
inputs = {path: c.read(path) for path in paths}
c.write_new(c.PREFIX + 'source-writer-inputs.json.gz', dict(inputs=inputs,
    first_combined_log=c.read('.linkedspec-data/verification/type-values-source-tests.log'),
    scope='The first writer assumes a multiline is assertion; the first actual assertion is '
          'one line. It asserts before any source write. Exact original source and first combined '
          'channels remain, followed by a distinct full-channel no-write recurrence.'), packed=True)
red = c.run(['python3', c.PREFIX + 'strengthen_source_tests.py'])
assert red['returncode'] == 1 and b'assert starts' in c.decode(red['stderr_base64'])
assert c.unchanged(inputs) and not (c.ROOT / (c.PREFIX + 'source-test-proposals.json.gz')).exists()
corrected = c.run(['python3', c.PREFIX + 'strengthen_source_tests_final.py'])
c.write_new(c.PREFIX + 'source-writer-run.json', dict(original_red=red, corrected=corrected,
    original_no_write_verified=True))
assert corrected['returncode'] == 0, corrected
print('Original no-write writer RED retained; separate single/multiline reader PASS')
