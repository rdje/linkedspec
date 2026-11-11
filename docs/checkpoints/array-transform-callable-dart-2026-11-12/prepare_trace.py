"""Prepare nine independent Dart guard/source/error/Boolean trace contrasts."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'capture_trace.py').exists()

def adapt(index):
    text = gzip.decompress((BASE / ('template-' + str(index) + '.gz')).read_bytes()).decode()
    for old, new in (
        ('9ed018787cac456a0e0bf95942bcdb735f5e4e6c', '5ac1fac5eb7126cd8f952858f8df194914884830'),
        ('array-pipeline-callable-dart-2026-11-11', BASE.name),
        ('trace_callable_array_pipeline_results', 'trace_callable_array_transform_results'),
        ('callable_array_pipeline_observation', 'callable_array_transform_observation'),
        ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM'),
        ('CallablePipeline', 'CallableTransform')):
        text = text.replace(old, new)
    return text

probe = Path('dart/tool/trace_callable_array_transform_results.dart')
assert not probe.exists()
source = adapt(4)
anchor = "    File('${output.path}/inputs/$id.json').writeAsStringSync(serialized);\n"
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + '''    if (File('${output.path}/inputs/$id.json').readAsStringSync() != serialized) {
      throw StateError('trace parsed snapshot changed before compile');
    }
''')
probe.write_text(source)
capture = adapt(8)
start = capture.index('    ids = {')
end = capture.index('    cases = ', start)
ids = {'take_receiver_hash_guard', 'take_later_with', 'reverse_copy_later_with',
    'drop_logical_later_with', 'source_effect_before_rejection',
    'positive_slice_receiver_composed', 'initial_number_composed',
    'own_scalar_bool_receiver_with', 'own_needed_source_take_receiver'}
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(ids) == 9 and ids <= {row['id'] for row in cases}
capture = capture[:start] + '    ids = ' + repr(ids) + '\n' + capture[end:]
capture = capture.replace('== 7\n', '== 9\n').replace('Seven public Dart', 'Nine public Dart')
(BASE / 'capture_trace.py').write_text(capture)
formatter = (BASE / 'format_tools.py').read_text()
formatter = formatter.replace("BASE / 'tool-format'", "BASE / 'trace-format'", 1)
start = formatter.index('targets = [')
end = formatter.index('\npaths = ', start)
formatter = formatter[:start] + "targets = [Path('dart/tool/trace_callable_array_transform_results.dart')]" + formatter[end:]
(BASE / 'format_trace.py').write_text(formatter)
print('Prepared nine public trace questions including actual Boolean/needed-error boundaries; no production change')
