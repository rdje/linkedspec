"""Capture current complete book after the bounded negative-reference correction."""
import json
import os
import shutil
from pathlib import Path
import book
import common as c

inputs, count = book.population()
tool = shutil.which(os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'))
assert tool
identity = dict(name=Path(tool).name, sha256=c.sha(Path(tool).read_bytes()))
c.write_new(c.PREFIX + 'book-final-inputs.json.gz', dict(inputs=inputs, tool=identity,
    producer=c.read(c.PREFIX + 'book-final.py'), renderer=c.read(c.PREFIX + 'book.py'), book_sources=count), packed=True)
healthy, changed = book.render(inputs), book.render(inputs, True)
c.write_new(c.PREFIX + 'book-final-run.json.gz', dict(healthy=healthy, changed_heading=changed,
    tool=identity, book_sources=count, recursive_include_sources=len(inputs)-count), packed=True)
assert c.unchanged(inputs)
print('Corrected complete book builds retained:', healthy['returncode'], changed['returncode'])
