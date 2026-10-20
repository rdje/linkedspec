"""Make immutable Git inputs explicit, including the diagnostic mapper's old source."""
import ast
import subprocess
import sys
import common as c

MAPPER = 't/lib/method_locations.py'


def paths():
    tree = ast.parse((c.ROOT / MAPPER).read_bytes())
    values = [ast.literal_eval(node.value) for node in tree.body if isinstance(node, ast.Assign)
              and any(isinstance(target, ast.Name) and target.id == 'BEFORE' for target in node.targets)]
    assert len(values) == 1 and isinstance(values[0], str) and len(values[0]) == 40
    return [(c.BASE, 'docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json'),
            (c.BASE, 'docs/checkpoints/type-evaluated-values/publication-selector.json'),
            (values[0], c.SOURCE)]


def identities():
    rows = []
    for revision, path in paths():
        raw = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=c.ROOT)
        entry = subprocess.check_output(['git', 'ls-tree', revision, '--', path], cwd=c.ROOT).split()
        rows.append(dict(revision=revision, path=path, sha256=c.sha(raw), git_mode=entry[0].decode()))
    return rows


def verify():
    saved = c.load('git-inputs.json')
    assert saved['inputs'] == identities()
    assert saved['mapper'] == c.identity(MAPPER)


if __name__ == '__main__':
    assert sys.argv[1:] == ['--capture']
    c.write_new('git-inputs.json', dict(inputs=identities(), mapper=c.identity(MAPPER),
        scope='Real immutable repository Git inputs. The diagnostic mapper source, including its BEFORE '
              'literal, already precedes focused execution in focused-inputs.json. This explicit projection '
              'is added afterward; it does not invent an earlier separate manifest or filesystem-mode capture.'))
    verify()
    print('Immutable Git claim/receipt/diagnostic-source inputs verified')
