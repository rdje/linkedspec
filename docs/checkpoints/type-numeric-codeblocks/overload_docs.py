"""Preserve the overload-selection clarification as a separate documentation epoch."""
import common as c


def main():
    guide = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
    fact = 'docs/knowledge/terse-type-method-surface-inventory.md'
    before = {path: c.read(path) for path in (guide, fact)}
    text = c.decode(before[guide]['base64']).decode()
    old = 'in a binding to use it as the receiver of a separate expression.\n'
    assert text.count(old) == 1
    text = text.replace(old, old + 'A one-argument min/max call evaluates its input to choose the array overload;\n'
                        'scalar input then yields `undef`.\n', 1)
    old = 'calls keep their typed `unknown_helper` cause; they are not quiet null results.'
    assert text.count('Unsupported\n' + old) == 1
    text = text.replace('Unsupported\n' + old,
                        'An executed unsupported\ncall keeps its typed `unknown_helper` cause.', 1)
    card = c.decode(before[fact]['base64']).decode()
    assert card.count('kinds; invalid arity skips') == 1
    card = card.replace('kinds; invalid arity skips', 'kinds; known invalid arity skips', 1)
    after = {guide: text.encode(), fact: card.encode()}
    c.write_new('overload-docs.json.gz', dict(before=before,
        after={path: c.encode(raw) for path, raw in after.items()},
        producer=c.read(c.PREFIX + 'overload_docs.py'),
        scope='Document the already-tested single-input overload-selection exception and executed-call boundary.'))
    for path, raw in after.items():
        (c.ROOT / path).write_bytes(raw)


if __name__ == '__main__':
    main()
