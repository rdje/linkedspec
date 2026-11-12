"""Prepare unused Julia normal/inverse/repair instruments after own policy freeze."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OLD = ROOT / 'docs/checkpoints/array-pipeline-callable-julia-2026-11-11'
baseline = json.loads((BASE / 'baseline.json').read_bytes())
assert len(baseline['observed']) == 312
red = baseline['supported_targets'] + baseline['separate_initial_compatibility']
assert len(red) == 31
for key in red:
    assert all(json.dumps(baseline['observed'][key][route], sort_keys=True) != json.dumps(baseline['expected'][key][route], sort_keys=True)
        for route in ('native', 'restored', 'plan', 'fresh'))

def adapt(text):
    return (text.replace('array-pipeline-callable-julia-2026-11-11', BASE.name)
        .replace('580fe233a7d0299d177ecbd442ad8ba027bbe6da', '3767c87c7167bdcb29b0092be35bc139520e3509')
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))

capture = adapt((OLD / 'capture.py').read_text())
start = capture.index('    paths += [BASE / name for name in (')
end = capture.index('\n    sdk = ', start)
capture = capture[:start] + "    paths += [path for path in BASE.iterdir() if path.is_file() and path.suffix in ('.py', '.jl', '.json', '.gz')]\n" + capture[end:]
capture = capture.replace("tests += ['julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/key_count_callable_result_guard_composition_test.jl']", "tests += ['julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/array_pipeline_callable_result_guard_composition_test.jl']")
# The old callable normal intentionally permits capture only inside its own
# historical packet. Run both unchanged dependents semantically, without a new
# custody claim for their transient generated strings. Do not write old packets.
for line in (
    "        ENVIRONMENT['LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE'] = str(OUT / 'prior-transform')\n",
    "        ENVIRONMENT['LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE'] = str(OUT / 'prior-key-count')\n"):
    assert capture.count(line) == 1
    capture = capture.replace(line, '')
start = capture.index("    if phase == 'direct':\n        for name, count in ")
end = capture.index("    freeze('artifacts'", start)
capture = capture[:start] + capture[end:]
start = capture.index('    for directory in (([OUT, OUT /')
end = capture.index("    if phase == 'private-fixed':", start)
capture = capture[:start] + "    for name in ('emitted', 'parsed'):\n        (OUT / name).rmdir()\n" + capture[end:]
capture = capture.replace('== 194', '== 312').replace('actual194', 'actual312')
capture = capture.replace(r'696\s+80\s+776\s', r'1124\s+124\s+1248\s').replace(r'776\s+776\s', r'1248\s+1248\s')
anchor = "    baseline = json.loads((BASE / 'baseline.json').read_bytes())\n"
extra = '''    if phase == 'direct':
        assert re.search(rb'Julia ordinary Array-transform result guards\\s*\\|\\s*903\\s+903\\s', result.stdout)
        assert re.search(rb'Julia callable Array-pipeline result guards\\s*\\|\\s*776\\s+776\\s', result.stdout)
'''
assert capture.count(anchor) == 1
capture = capture.replace(anchor, extra + anchor)
# Reuse the already executed intake's retained host-memory preflight verbatim.
intake = (BASE / 'capture_intake.py').read_text()
memory = intake[intake.index('    # Check the shared host'):intake.index("    run('version', ['--version'])")]
marker = "    run('version', prefix + ['--version'])"
assert capture.count(marker) == 1
capture = capture.replace(marker, memory + marker)
(BASE / 'capture.py').write_text(capture)

repair = adapt((OLD / 'repair.py').read_text())
start = repair.index("old = '''")
end = repair.index("include = ", start)
blocks = '''old = b"""    if receiver isa ActionCallExpr
        has_user_function_name(engine.compiled_spec.function_registry, receiver.name) && return false
        if something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
"""
new = b"""    # Invocation keeps its arity checks and caller effects. A canonical transform
    # prefix owns the produced result without becoming an unregistered free call.
    if receiver isa ActionCallExpr
        if !has_user_function_name(engine.compiled_spec.function_registry, receiver.name) &&
            something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
"""
'''
repair = repair[:start] + blocks + repair[end:]
old = """            assert not target.exists()
            target.write_bytes(gzip.compress(body, mtime=0))
            assert gzip.decompress(target.read_bytes()) == body"""
new = """            if phase == 'before':
                assert gzip.decompress(target.read_bytes()) == body
            else:
                assert not target.exists()
                target.write_bytes(gzip.compress(body, mtime=0))
                assert gzip.decompress(target.read_bytes()) == body"""
assert repair.count(old) == 1
repair = repair.replace(old, new)
(BASE / 'repair.py').write_text(repair)
(BASE / 'run_repair.py').write_text((OLD / 'run_repair.py').read_text())
print('Prepared Julia312 four-route old/current capture, semantic direct2927 and bounded classifier/runner rehearsal; no production edits')
