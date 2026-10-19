"""Retain the wrong-destination attempt and prepare an explicit scoped render."""
import ast
import json
import os
from pathlib import Path
import common as c

original_path = c.HOME + 'render-containment.py'
original = c.read(original_path)
failure_path = '.linkedspec-data/verification/knowledge-fields-render-containment-attempt1.log'
failure = c.read(failure_path)
assert b'FileNotFoundError' in c.decode(failure['base64']) and b'book/output/original.html' in c.decode(failure['base64'])
root = c.ROOT / 'output'
assert root.is_dir() and not root.is_symlink() and root.stat().st_dev == c.ROOT.stat().st_dev
files, directories = {}, {}
for directory, names, filenames in os.walk(root, followlinks=False):
    parent = Path(directory)
    assert not (parent / '.git').exists() and not parent.is_symlink(), 'no foreign or linked output traversal'
    stat = parent.stat()
    directories[parent.relative_to(root).as_posix()] = dict(mode=stat.st_mode & 0o7777,
        birthtime=getattr(stat, 'st_birthtime', None), mtime_ns=stat.st_mtime_ns)
    for name in names:
        assert not (parent / name).is_symlink()
    for name in filenames:
        source = parent / name
        assert source.is_file() and not source.is_symlink() and source.stat().st_dev == c.ROOT.stat().st_dev
        value = source.read_bytes()
        stat = source.stat()
        files[source.relative_to(root).as_posix()] = dict(base64=c.encode(value), sha256=c.sha(value),
            mode=stat.st_mode & 0o7777, birthtime=getattr(stat, 'st_birthtime', None), mtime_ns=stat.st_mtime_ns)
mains = {name: c.decode(files[name + '.html']['base64']).split(b'<main>', 1)[1].rsplit(b'</main>', 1)[0]
         for name in ('original', 'compact', 'changed')}
source = c.decode(original['base64'])
old = b"command = [command_name, 'build', book.relative_to(c.ROOT).as_posix(), '-d', 'output']"
new = b"command = [command_name, 'build', book.relative_to(c.ROOT).as_posix(), '-d', str(book / 'output')]"
assert source.count(old) == 1
corrected = source.replace(old, new, 1)
marker = b'    built = c.run(command)\n'
assert corrected.count(marker) == 1
corrected = corrected.replace(marker, b'''    assert not (book / 'output').exists()
    preparation = dict(producer_base64=c.encode(Path(__file__).read_bytes()), command=command,
        version=version, tool_sha256=c.sha(binary.read_bytes()),
        sources={path: dict(base64=c.encode(value), sha256=c.sha(value), mode=modes[path]) for path, value in sources.items()},
        first_recovery_sha256=c.sha((c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes()))
    c.write_new(c.HOME + 'render-inputs.json.gz', preparation, packed=True)
    built = c.run(command)
    c.write_new(c.HOME + 'render-build.json', built)
''', 1)
marker = b"    assert mains['original'] == mains['compact'],"
assert corrected.count(marker) == 1
corrected = corrected.replace(marker,
    b"    c.write_new(c.HOME + 'render-pages.json.gz', dict(pages={name: c.encode(value) for name, value in pages.items()}, main_sha256={name: c.sha(value) for name, value in mains.items()}), packed=True)\n" + marker, 1)
corrected = corrected.replace(b"c.HOME + 'render-containment.json.gz', record", b"c.HOME + 'render-final.json.gz', record", 1)
ast.parse(corrected, filename=c.HOME + 'render-final.py')
recovery = dict(result='retained first failed instrument', original_producer=original,
    complete_outer_failure=failure, output_root='output', files=files, directories=directories,
    recovered_main_sha256={name: c.sha(value) for name, value in mains.items()},
    recovered_main_equal=mains['original'] == mains['compact'],
    recovered_visible_control=mains['changed'] != mains['compact'] and b'Changed visible heading' in mains['changed'],
    corrected_producer_base64=c.encode(corrected), corrected_sha256=c.sha(corrected),
    producer_base64=c.encode(Path(__file__).read_bytes()),
    scope='The original build returned0 before its reader looked in book/output and failed. '
          'Its original build/version stdout/stderr variables were not serialized and are '
          'unavailable; do not invent them or prior source-mode guards. Actual output landed '
          'in repository output/, consistent with the published CLI destination relative to '
          'caller cwd. Every recovered output byte/mode and filesystem metadata is retained '
          'before any cleanup. A distinct corrected actor uses an explicit runtime-derived '
          'destination, retains all inputs before building and saves complete channels/pages '
          'before adjudication. No output is deleted here; fresh whole-output equivalence '
          'and exact restoration custody must precede removing that known generated tree.')
c.write_new(c.HOME + 'render-recovery.json.gz', recovery, packed=True)
with (c.ROOT / (c.HOME + 'render-final.py')).open('xb') as output:
    output.write(corrected)
print('First render retained:', len(files), 'files;', sum(len(c.decode(item['base64'])) for item in files.values()),
      'bytes;recovered main equality', recovery['recovered_main_equal'], ';explicit corrected destination prepared')
