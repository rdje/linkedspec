"""Preserve the first test instrument and narrowly repair its grep grouping."""
import ast
import gzip
import json
import re
from pathlib import Path
import common as c

first_raw = (c.ROOT / (c.HOME + 'red.json.gz')).read_bytes()
first = json.loads(gzip.decompress(first_raw))
test_path = 't/knowledge_map_header_lists.t'
before = c.read(test_path)
assert before == first['inputs'][test_path]
old = b'Test::More::ok(@questions == 2 && !grep { !/ \xc2\xb7 reverify: \\Q$expected\\E$/ } @questions,'
new = b'Test::More::ok(@questions == 2 && !(grep { !/ \xc2\xb7 reverify: \\Q$expected\\E$/ } @questions),'
source = c.decode(before['base64'])
assert source.count(old) == 1
after = source.replace(old, new, 1)
all_failures = re.findall(rb'^not ok (\d+)(?: - (.*))?$', c.decode(first['observation']['stdout_base64']), re.M)
assert len(all_failures) == first['observation']['returncode'] == 40
assert len(first['failures']) == 32
assert sum(not name for _, name in all_failures) == 8
producer_path = c.HOME + 'capture-red.py'
producer = (c.ROOT / producer_path).read_bytes()
assert c.sha(producer) == first['producer_sha256']
final = producer.replace(b"c.HOME + 'capture-red.py'", b"c.HOME + 'capture-red-final.py'")
final = final.replace(b"c.HOME + 'controls-final.json']", b"c.HOME + 'controls-final.json', c.HOME + 'red.json.gz',\n         c.HOME + 'assertion-repair.json', c.HOME + 'repair-assertion.py']")
pattern = b"re.findall(rb'^not ok (\\d+) - (.*)$', stdout, re.M)"
replacement = b"re.findall(rb'^not ok (\\d+)(?: - (.*))?$', stdout, re.M)"
assert final.count(pattern) == 1
final = final.replace(pattern, replacement, 1)
line = b'assert all(int(number) > 80 for number, _ in failed)'
assert final.count(line) == 1
final = final.replace(line,
    b"assert all(int(number) > 120 and name for number, name in failed)\n"
    b"assert not any(name.startswith((b'scalar ', b'quoted-scalar ', b'unknown-list-is-not-proof ')) for _, name in failed)", 1)
final = final.replace(b"c.HOME + 'red.json.gz', record", b"c.HOME + 'red-final.json.gz', record", 1)
ast.parse(final, filename=c.HOME + 'capture-red-final.py')
record = dict(result='PASS', first_record_sha256=c.sha(first_raw), before_test=before,
              after_test_sha256=c.sha(after), original_producer_base64=c.encode(producer),
              final_producer_sha256=c.sha(final), producer_base64=c.encode(Path(__file__).read_bytes()),
              first_actual_failure_count=len(all_failures), first_named_failure_count=len(first['failures']),
              first_all_failures=[dict(number=int(number), name=name.decode()) for number, name in all_failures],
              scope='Perl grep consumed the following test-description argument as another list item, '
                    'creating eight anonymous failures including two scalar controls. Parentheses end '
                    'that grep list explicitly. The first recorder enumerated named failures only; '
                    'all40 actual failures remain in its complete unchanged TAP/stderr. The distinct '
                    'final recorder enumerates named and anonymous lines, rejects any anonymous '
                    'failure or native-header/scalar-control failure, and has a separate target. '
                    'Generator/checker and all original/native before observations stay unchanged.')
c.write_new(c.HOME + 'assertion-repair.json', record)
assert c.read(test_path) == before
(c.ROOT / test_path).write_bytes(after)
with (c.ROOT / (c.HOME + 'capture-red-final.py')).open('xb') as output:
    output.write(final)
print('Exact assertion grouping repair retained:40 actual/32 named first failures;distinct final RED producer')
