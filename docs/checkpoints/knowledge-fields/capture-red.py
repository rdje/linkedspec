"""Retain projection assertions RED before changing the generator."""
import gzip
import json
import re
from pathlib import Path
import common as c

baseline = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'before.json.gz')).read_bytes()))
closure = json.loads((c.ROOT / (c.HOME + 'controls-final.json')).read_bytes())
assert closure['result'] == 'PASS' and closure['observation'] == baseline['original_controls']
paths = ['t/knowledge_map_header_lists.t',
         'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json',
         'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
         '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
         c.HOME + 'capture-red.py', c.HOME + 'common.py', c.HOME + 'before.json.gz',
         c.HOME + 'controls-final.json']
inputs = {path: c.read(path) for path in paths}
assert inputs['knowledge-map/scripts/gen_knowledge_map.sh']['sha256'] == baseline['inputs']['knowledge-map/scripts/gen_knowledge_map.sh']['sha256']
observed = c.run(['perl', 't/knowledge_map_header_lists.t'])
stdout = c.decode(observed['stdout_base64'])
original = c.decode(baseline['original_controls']['stdout_base64']).splitlines()
assert stdout.splitlines()[:80] == original[:80], 'original80 assertions stay byte-identical controls'
failed = re.findall(rb'^not ok (\d+) - (.*)$', stdout, re.M)
assert observed['returncode'] != 0 and failed
assert all(int(number) > 80 for number, _ in failed)
assert any(b'projects reverify metadata' in name for _, name in failed)
assert any(b'projects evidence metadata' in name for _, name in failed)
assert c.unchanged(inputs)
record = dict(result='PASS', phase='observed projection RED', observation=observed,
              failures=[dict(number=int(number), name=name.decode()) for number, name in failed],
              original80_exact=True, inputs_unchanged=True, inputs=inputs,
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='The extended already-selected suite retains original80 exact assertion lines, '
                    'then asserts complete scalar/list projection, authored order/multiplicity, '
                    'quoted commas/escapes, Unicode, code spans, fact pointers and nonexecution. '
                    'Generator/checker are unchanged original bytes. All actual inputs, including '
                    'the fixed historical census, precede execution and remain byte/mode exact.')
c.write_new(c.HOME + 'red.json.gz', record, packed=True)
print('Projection RED retained:', len(failed), 'new assertion failures; original80 exact controls')
