"""Retain independent host list-copy observations before adopting a source template."""
import json
import common as c

paths = [c.PREFIX + 'host_list.pl', c.PREFIX + 'capture_host_list.py', c.PREFIX + 'common.py',
    'docs/knowledge/perl-generic-flat-runtime-values.md',
    'docs/knowledge/dart-array-flat-list-context-splice.md']
c.write_new(c.PREFIX + 'host-list-inputs.json', dict(inputs={path: c.read(path) for path in paths},
    scope='A scalar temporary loses an explicit flat list. This separate host actor checks a '
          'private per-operand list copy, same-name initializer/caller references, primitive kinds '
          'and unchanged container reference identity. No original actor or runtime source changes.'))
run = c.run(['perl', c.PREFIX + 'host_list.pl'])
c.write_new(c.PREFIX + 'host-list-run.json', dict(run=run))
assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
print('Independent list-preserving host observations retained')
