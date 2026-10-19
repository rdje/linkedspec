"""Measure actual mdBook equivalence and a changed-visible-heading control."""
import gzip
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
import common as c

before = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()))
compact = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'compact.json.gz')).read_bytes()))
old_map, new_map = c.decode(before['map_base64']), c.decode(compact['map_base64'])
assert len(old_map.splitlines()) == 22596 and len(new_map.splitlines()) == 21247
assert [line for line in old_map.splitlines() if line] == [line for line in new_map.splitlines() if line]
heading = new_map.splitlines()[0]
assert heading.startswith(b'# ')
changed = new_map.replace(heading, b'# Changed visible heading', 1)
command_name = os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook')
executable = shutil.which(command_name)
assert executable is not None
binary = Path(executable).resolve()
version = c.run([command_name, '--version'])
assert version['returncode'] == 0
sources = {
    'book.toml': b'[book]\ntitle = "Knowledge projection containment"\nsrc = "src"\n\n[output.html]\nno-section-label = true\n',
    'src/SUMMARY.md': b'# Summary\n\n- [Original](original.md)\n- [Compact](compact.md)\n- [Changed](changed.md)\n',
    'src/original.md': old_map, 'src/compact.md': new_map, 'src/changed.md': changed,
}
with tempfile.TemporaryDirectory(prefix='knowledge-fields-render-', dir=os.environ['TMPDIR']) as directory:
    book = Path(directory) / 'book'
    book.mkdir()
    assert book.stat().st_dev == c.ROOT.stat().st_dev
    modes = {}
    for path, value in sources.items():
        target = book / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        modes[path] = target.stat().st_mode & 0o7777
    command = [command_name, 'build', book.relative_to(c.ROOT).as_posix(), '-d', str(book / 'output')]
    assert not (book / 'output').exists()
    preparation = dict(producer_base64=c.encode(Path(__file__).read_bytes()), command=command,
        version=version, tool_sha256=c.sha(binary.read_bytes()),
        sources={path: dict(base64=c.encode(value), sha256=c.sha(value), mode=modes[path]) for path, value in sources.items()},
        first_recovery_sha256=c.sha((c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes()))
    c.write_new(c.HOME + 'render-inputs.json.gz', preparation, packed=True)
    built = c.run(command)
    c.write_new(c.HOME + 'render-build.json', built)
    assert built['returncode'] == 0, built
    pages = {name: (book / ('output/' + name + '.html')).read_bytes() for name in ('original', 'compact', 'changed')}
    mains = {}
    for name, value in pages.items():
        assert b'<main>' in value and b'</main>' in value
        mains[name] = value.split(b'<main>', 1)[1].rsplit(b'</main>', 1)[0]
    c.write_new(c.HOME + 'render-pages.json.gz', dict(pages={name: c.encode(value) for name, value in pages.items()}, main_sha256={name: c.sha(value) for name, value in mains.items()}), packed=True)
    generated = {}
    generated_dirs = {}
    output_root = book / 'output'
    for target in sorted(output_root.rglob('*')):
        assert not target.is_symlink() and not (target / '.git').exists()
        if target.is_dir():
            generated_dirs[target.relative_to(output_root).as_posix()] = target.stat().st_mode & 0o7777
        elif target.is_file():
            value = target.read_bytes()
            generated[target.relative_to(output_root).as_posix()] = dict(base64=c.encode(value), sha256=c.sha(value), mode=target.stat().st_mode & 0o7777)
        else:
            raise AssertionError('unexpected generated output entry')
    generated_dirs['.'] = output_root.stat().st_mode & 0o7777
    c.write_new(c.HOME + 'render-outputs.json.gz', dict(files=generated, directories=generated_dirs), packed=True)
    assert mains['original'] == mains['compact'], 'actual rendered main content remains byte-identical'
    assert mains['changed'] != mains['compact'] and b'Changed visible heading' in mains['changed'], 'actual visible-content RED distinguishes changed input'
    assert all((book / path).read_bytes() == value and (book / path).stat().st_mode & 0o7777 == modes[path] for path, value in sources.items())
record = dict(result='PASS', producer_sha256=c.sha(Path(__file__).read_bytes()),
              version=version, tool=dict(path_base64=c.encode(str(binary).encode()), sha256=c.sha(binary.read_bytes()),
                                         mode=binary.stat().st_mode & 0o7777, device=binary.stat().st_dev,
                                         readonly=True),
              command=built, sources={path: dict(base64=c.encode(value), sha256=c.sha(value), mode=modes[path]) for path, value in sources.items()},
              pages={name: dict(base64=c.encode(value), sha256=c.sha(value)) for name, value in pages.items()},
              main_sha256={name: c.sha(value) for name, value in mains.items()},
              original_lines=22596, compact_lines=21247, source_inputs_unchanged=True,
              scope='Actual readonly mdBook executable renders all three complete supplied maps '
                    'in one controlled miniature book. Removing only title blank separators '
                    'preserves actual main-content bytes; a distinct changed-heading input '
                    'produces observed different visible output. All five complete source bytes '
                    'and modes are guarded. The external host executable is an identified '
                    'readonly toolchain prerequisite; every project input/output stays on the '
                    'repository volume. No cross-toolchain identical-HTML guarantee is inferred.')
c.write_new(c.HOME + 'render-final.json.gz', record, packed=True)
print('Actual mdBook containment PASS:main bytes identical;changed-heading visible RED;all source guards')
