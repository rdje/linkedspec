"""Apply current literal-kind teaching and two complete executable examples."""
import common as c
import context
from booklib import FLOW

EXAMPLES = {
    "examples/deferred-literal-kinds-perl.spec": b'Top: /x/\n I { items=[10,20,30]; cb={|| index=-1.0; return([false,true,items[index],index]) }; return(cb()) }\n',
    "examples/deferred-literal-precision-perl.spec": b'Top: /x/\n I { cb={|| return(num_sub(1000000000000000.5,1000000000000000)) }; return(cb()) }\n',
}


def updated(raw):
    text = raw.decode()
    old = ' Boolean literals inside deferred bodies still yield numeric `1`/`0`; boolean arguments passed into a codeblock retain their kind. These separately owned repairs remain pending.'
    new = ' Deferred booleans and floating literals retain their kinds; see [literal examples](#literal-kinds-inside-perl-codeblocks).'
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    old = 'Typed boolean parameters remain nonnumeric. Boolean literals evaluated inside a Perl callback have the separate [kind limitation](#current-perl-limits) above.'
    new = 'Typed boolean literals and parameters remain nonnumeric, including inside Perl callbacks. See [literal examples](#literal-kinds-inside-perl-codeblocks).'
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    start = text.index('#### Current callable literal-kind limitation\n')
    end = text.index('\n#### Existing parameter and effect behavior', start)
    replacement = '''<a id="current-callable-literal-kind-limitation"></a>

#### Literal kinds inside Perl codeblocks

Boolean literals retain typed booleans. Floating literals retain their numeric value and floating kind through assignments, returned containers and copied fixed/rest parameters. Strings and null keep their own kinds; numeric helpers reject booleans.

This parser returns `[false,true,null,-1]` for input `x`:

```text
{{#include ../../../../examples/deferred-literal-kinds-perl.spec}}
```

The assigned `-1.0` remains a float, so it cannot select an entry through the negative-integer extension. JSON number formatting may omit the decimal point.

Large fractional literals also retain the ordinary numeric value through a deferred call. This parser returns `0.5` for input `x`:

```text
{{#include ../../../../examples/deferred-literal-precision-perl.spec}}
```
'''
    return (text[:start] + replacement + text[end:]).encode()


def main():
    before = c.read(FLOW)
    after = updated(c.decode(before["base64"]))
    epoch = context.snapshot()
    c.write_new("document-before.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "document.py"),
        before=before, planned_examples={path: dict(base64=c.encode(raw), sha256=c.sha(raw)) for path, raw in EXAMPLES.items()}))
    assert c.unchanged(epoch["inputs"])
    for path, raw in EXAMPLES.items():
        with (c.ROOT / path).open("xb") as output:
            output.write(raw)
    c.source(FLOW).write_bytes(after)
    c.write_new("document-after.json.gz", dict(after={path: c.read(path) for path in (FLOW, *EXAMPLES)},
        preserved_old_anchor="current-callable-literal-kind-limitation"))
    print("Current literal-kind teaching and two complete example sources written.", flush=True)


if __name__ == "__main__":
    main()
