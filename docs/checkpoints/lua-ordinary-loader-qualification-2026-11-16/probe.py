"""Retain isolated header experiments; --review verifies them without host replay."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
REPRESENTATIVE = 'lua/test/array_concat_open_arity_result_guard_composition_test.lua'
FLAG = 'LINKEDSPEC_ARRAY_CONCAT_INPUT_ROOT'


def reader():
    spec = importlib.util.spec_from_file_location('lua_ordinary_epoch', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module


def specimen(sources, label):
    source = sources[REPRESENTATIVE].decode()
    end = source.index('local json = l.json\n') + len('local json = l.json\n')
    header = source[:end]
    prefix = '' if label == 'repository-compile-only' else 'inert-prefix/'
    if label == 'toy-invocation-inverse':
        old = 'assert(loadfile(input_root .. "lua/src/linkedspec/interpreter.lua"))'
        assert header.count(old) == 1
        header = header.replace(old, old + '()', 1)
    assert label in ('repository-compile-only', 'prefix-compile-only', 'toy-invocation-inverse')
    toy = str(BASE / 'toy_chunk.lua')
    # Only the toy has a callable inverse. Repository chunks are compiled, never invoked.
    bootstrap = '''local real_loadfile = loadfile
local requests, modules, calls = {}, {}, 0
probe_chunk_calls = 0
os.getenv = function(name)
  assert(name == %s)
  return %s
end
require = function(name)
  modules[#modules+1] = name
  assert(name == "linkedspec")
  return {json={}}
end
loadfile = function(path)
  requests[#requests+1] = path
  local mapped = path
  if %s ~= "" then
    assert(path:sub(1, #%s) == %s)
    mapped = %s
  end
  local chunk, err = real_loadfile(mapped)
  if not chunk then return nil, err end
  return function(...)
    assert(mapped == %s, "repository chunk execution forbidden")
    calls = calls + 1
    return chunk(...)
  end
end
''' % tuple(json.dumps(x) for x in (FLAG, prefix, prefix, prefix, prefix, toy, toy))
    trailer = '''for _, path in ipairs(requests) do print("REQUEST\\t" .. path) end
for _, name in ipairs(modules) do print("MODULE\\t" .. name) end
print("COUNTS\\t" .. #requests .. "\\t" .. calls .. "\\t" .. probe_chunk_calls)
'''
    return (bootstrap + header + trailer).encode(), dict(prefix=prefix, toy_mapping=toy if prefix else None,
        require='inert replacement returning only json={}', header_source=REPRESENTATIVE,
        header_sha256=hashlib.sha256(header.encode()).hexdigest(), inverse=label == 'toy-invocation-inverse')


def expected(label):
    prefix = '' if label == 'repository-compile-only' else 'inert-prefix/'
    calls = '1' if label == 'toy-invocation-inverse' else '0'
    return ('REQUEST\t' + prefix + 'lua/src/linkedspec/interpreter.lua\nREQUEST\t' + prefix +
        'lua/test/run.lua\nMODULE\tlinkedspec\nCOUNTS\t2\t' + calls + '\t' + calls + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--review', action='store_true'); args = parser.parse_args()
    module = reader(); sources, _ = module.recover()
    result = {}
    for label in ('repository-compile-only', 'prefix-compile-only', 'toy-invocation-inverse'):
        body, spec = specimen(sources, label); folder = BASE / label
        command = dict(argv=['bash','tools/project_data_run.sh','lua','-E','-'], cwd='.',
            controlled_header_input=spec, stdin='stdin.lua.gz', inherited_environment='project_data_run routing; -E ignores Lua environment; header getenv and require replaced')
        if not args.review:
            folder.mkdir()
            (folder / 'command.json').write_text(json.dumps(command, indent=2) + '\n')
            (folder / 'stdin.lua.gz').write_bytes(gzip.compress(body, mtime=0))
            for path in ['lua/src/linkedspec/interpreter.lua','lua/test/run.lua',str(BASE/'toy_chunk.lua')]:
                assert Path(path).read_bytes() == sources[path], 'pre-use logical body'
            actual = subprocess.run(command['argv'], input=body, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            for channel in ('stdout','stderr'):
                (folder / (channel+'.gz')).write_bytes(gzip.compress(getattr(actual,channel), mtime=0))
            (folder / 'exit.txt').write_text(str(actual.returncode)+'\n')
        assert json.loads((folder/'command.json').read_bytes()) == command
        assert gzip.decompress((folder/'stdin.lua.gz').read_bytes()) == body
        assert (folder/'exit.txt').read_text() == '0\n'
        assert gzip.decompress((folder/'stderr.gz').read_bytes()) == b''
        stdout = gzip.decompress((folder/'stdout.gz').read_bytes())
        assert stdout == expected(label), 'host compile/call distinction'
        result[label] = dict(result='RED' if spec['inverse'] else 'PASS', stdout=stdout.decode(),
            oracle='zero returned-chunk invocation distinguishes compile-only; toy inverse calls exactly one')
    print(json.dumps(dict(result='PASS', experiments=result,
        limits='Only one exact retained representative header, inert package and controlled getenv. Repository chunks compile but cannot execute; inverse only toy. No SDK/package/regression body/native or actual module origin claim.'), sort_keys=True))


if __name__ == '__main__': main()
