"""Retain the initial doc actor and make the contract wording/list spacing explicit."""
import common as c


def main():
    paths = (c.PREFIX + 'docs.py', 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md')
    before = {path: c.read(path) for path in paths}
    actor = c.decode(before[paths[0]]['base64']).decode()
    noop = ("    text = text.replace('Array/harray literals and constructors, dynamic hash keys and callable arguments',\n"
            "        'Array/harray literals and constructors, dynamic hash keys and callable arguments', 1)\n")
    assert actor.count(noop) == 1
    actor = actor.replace(noop, '', 1)
    old = 'Scalar numeric helpers accept finite numbers and untrimmed decimal strings such as'
    new = 'Under the scalar numeric contract, inputs are finite numbers or untrimmed decimal strings such as'
    assert actor.count(old) == 1
    actor = actor.replace(old, new, 1)
    actor = actor.replace("        'boolean-literal and deferred aggregate limits. The separate grouping boundary remains:\\n', 1)",
                          "        'boolean-literal and deferred aggregate limits. The separate grouping boundary remains:\\n\\n', 1)")
    catalog = c.decode(before[paths[1]]['base64']).decode()
    assert catalog.count(old) == 1
    catalog = catalog.replace(old, new, 1)
    catalog = catalog.replace('The separate grouping boundary remains:\n- Wrapping',
                              'The separate grouping boundary remains:\n\n- Wrapping', 1)
    after = {paths[0]: actor.encode(), paths[1]: catalog.encode()}
    c.write_new('docs-clarity.json.gz', dict(before=before,
        after={path: c.encode(raw) for path, raw in after.items()}, producer=c.read(c.PREFIX + 'docs_refine.py'),
        scope='Initial applied proposals and original actor remain whole. Remove an inert replacement, '
              'identify normative scalar rules explicitly and keep a blank line before the remaining grouping list.'))
    for path, raw in after.items():
        (c.ROOT / path).write_bytes(raw)
    print('Doc actor/contract wording/list spacing refined; before versions retained')


if __name__ == '__main__':
    main()
