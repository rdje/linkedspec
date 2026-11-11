"""Read only the retained producer to distinguish a native dump from a precompile input."""
import copy
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(Path.cwd().resolve())
names = [str(REL / 'observer.pl'), 'perl/LinkedSpec/Compiler.pm', 'perl/LinkedSpec/SpecEntry.pm']
records = json.loads((BASE / 'intake/input-identities.json').read_bytes())
with tarfile.open(BASE / 'intake/inputs-before-first-run.tar.gz') as archive:
    sources = {name: archive.extractfile(name).read() for name in names}
for name, raw in sources.items():
    assert len(raw) == records[name]['bytes']
    assert hashlib.sha256(raw).hexdigest() == records[name]['sha256']


def verify(images):
    observer, compiler, entry = (images[name].decode() for name in names)
    assert observer.index("$row{module_input}=persist(") < observer.index('my $loaded=')
    assert observer.index('my $native=eval{LinkedSpec::Get(') < observer.index("$row{handler_input}=persist(")
    assert observer.index("$row{handler_input}=persist(") < observer.index('if ($row{native_callable}) {')
    assert "'LinkedSpec::SpecEntry', 'compile_spec_entry'" in compiler
    assert "$default_compile_spec_entry->(" in compiler
    assert compiler.index("my $default_compile_spec_entry =") < compiler.index("'flush_runtime_ctx_parser_source'")
    build = entry[entry.index('sub _build_runtime_handler {'):entry.index('sub compile_spec_entry {')]
    assert build.index('$compiled_handler = eval $handler_source;') < build.index(' return sub {')
    assert '$info{handler} = _build_runtime_handler(' in entry


verify(sources)
mutations = [
    (names[0], b'my $native=eval{LinkedSpec::Get(', b'my $native=OTHER_GET('),
    (names[0], b'my $loaded=', b'my $not_loaded='),
    (names[2], b'$compiled_handler = eval $handler_source;', b'$compiled_handler = NOT_COMPILED;'),
]
for name, old, new in mutations:
    changed = copy.deepcopy(sources)
    assert changed[name].count(old) == 1
    changed[name] = changed[name].replace(old, new)
    try:
        verify(changed)
    except (AssertionError, ValueError):
        continue
    raise AssertionError('distinguishing source-order control was not rejected')
print('Retained producer confirms: module before fresh eval; native dump after Get/before invocation.')
print('Native handler compilation precedes the dump; no native precompile-custody claim. Three source controls reject.')
