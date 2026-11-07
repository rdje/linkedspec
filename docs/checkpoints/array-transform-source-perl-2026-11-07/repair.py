"""Reuse the existing Number-AST fence at exactly eight demonstrated shortcuts."""
import difflib
import gzip
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
ROLES = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
stdout = gzip.decompress((BASE / 'before/stdout.log.gz').read_bytes())
failed = set(re.findall(rb'^not ok \d+ - (\S+)', stdout, re.M))
expected = {('target_literal_number_' + name + '_' + route + '_main').encode() for name in ROLES for route in ('free', 'receiver')}
assert failed == expected and len(re.findall(rb'^(?:not )?ok \d+ - ', stdout, re.M)) == 189
assert (BASE / 'before/exit.txt').read_text() == '1\n'
original = OWNER.read_bytes()
assert original == subprocess.check_output(['git', 'show', 'df9dc784e368a66f16238caaa41142a649dde4dd:' + str(OWNER)])
text = original.decode()
spans = []
for role in ROLES:
    marker = " if ($method_call && $method_call->{method} eq '" + role + "') {"
    assert text.count(marker) == 1
    start = text.index(marker)
    end = text.index('\n if ($method_call', start + len(marker))
    block = text[start:end]
    line = re.search(r'^( +)if \(defined\(\$array_symbol\) && length\(\$array_symbol\) && \$target_expr =~ \$array_symbol_expr_re\) \{$', block, re.M)
    assert line is not None
    old = line.group(0)
    new = old.replace('$array_symbol_expr_re) {', '$array_symbol_expr_re\n' + line.group(1) + '    && !_method_value_is_numeric_literal($target_expr, $deps)) {')
    assert block.count(old) == 1
    spans.append((start, end, block.replace(old, new)))
for start, end, block in sorted(spans, reverse=True):
    text = text[:start] + block + text[end:]
assert text.count('&& !_method_value_is_numeric_literal($target_expr, $deps)') == original.decode().count('&& !_method_value_is_numeric_literal($target_expr, $deps)') + 8
(BASE / 'owner-before.pm.gz').write_bytes(gzip.compress(original, mtime=0))
(BASE / 'source.patch').write_text(''.join(difflib.unified_diff(original.decode().splitlines(True), text.splitlines(True), fromfile=str(OWNER), tofile=str(OWNER))))
OWNER.write_text(text)
print('Original189 baseline:16 main-only RED; existing numeric predicate reused at exactly eight selected shortcuts')
