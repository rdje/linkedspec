"""Map unchanged statements in the same named routine to real c053 coordinates."""
import difflib
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BEFORE = 'c053c9dcf24a78cc8b551187f47cdb7aefb03eb3'


def routines(lines):
    starts = [(index, match[1]) for index, line in enumerate(lines)
              if (match := re.match(rb'^sub\s+([A-Za-z_]\w*)\b', line))]
    names = [name for _, name in starts]
    assert len(names) == len(set(names)), 'duplicate named routine in coordinate authority'
    result = {b'(module preamble)': (0, starts[0][0])}
    result.update({name: (start, starts[index + 1][0] if index + 1 < len(starts) else len(lines))
                   for index, (start, name) in enumerate(starts)})
    return result


def main():
    before = subprocess.check_output(['git', 'show', BEFORE + ':' + SOURCE], cwd=ROOT)
    current = (ROOT / SOURCE).read_bytes()
    left, right = before.splitlines(keepends=True), current.splitlines(keepends=True)
    old, new = routines(left), routines(right)
    ranges = []
    for name in old.keys() & new.keys():
        a, b = old[name], new[name]
        for match in difflib.SequenceMatcher(None, left[a[0]:a[1]], right[b[0]:b[1]], autojunk=False).get_matching_blocks():
            if match.size:
                ranges.append(dict(routine=name.decode(), before=a[0] + match.a + 1,
                    current=b[0] + match.b + 1, count=match.size))
    ranges.sort(key=lambda row: row['current'])
    print(json.dumps(dict(source=SOURCE, before_revision=BEFORE,
        before_sha256=hashlib.sha256(before).hexdigest(), current_sha256=hashlib.sha256(current).hexdigest(),
        ranges=ranges), sort_keys=True))


if __name__ == '__main__':
    main()
