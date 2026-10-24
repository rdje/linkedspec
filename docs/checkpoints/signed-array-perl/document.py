"""One-shot bounded current Perl teaching after verified runtime restoration."""
import common as c
import context

FLOW = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
CARD = "docs/knowledge/write-vivification-perl-reference.md"
EXAMPLES = {
    "examples/negative-array-write-perl.spec":
        'Top: /x/\n I { items=[10,20,30]; items[-2]=99; return([items[-1],items]) }\n',
    "examples/negative-array-write-callable-perl.spec":
        'Top: /x/\n I { tree={"rows":[[1],[2,3]]}; edit={|| tree["rows"][-1][-2]=99; return(tree) }; return(edit()) }\n',
}


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new, 1)


def main():
    assert c.load("green-runs.json.gz")["observations"]["focused"]["returncode"] == 0
    assert c.load("verified-faults.json.gz")["exact_restoration"]
    c.write_new("documentation-inputs.json.gz", dict(context=context.snapshot(),
        producer=c.read(c.PREFIX + "document.py"), before={path: c.read(path) for path in (FLOW, CARD)},
        scope="Bounded current Perl teaching and two new exact executable examples; other backends and frozen signed authority remain unchanged."))
    text = c.source(FLOW).read_text()
    text = once(text,
        "String selectors choose hashes, including quoted numeric strings; nonnegative integer selectors choose arrays. A literal boolean or null, a negative or fractional number, or an aggregate or codeblock cannot select a container and reports `nested_write_segment_invalid`.",
        "String selectors choose hashes, including quoted numeric strings. Integer selectors choose arrays: nonnegative indexes can replace or append at the exact length; negative indexes can replace an existing position. A literal boolean or null, a floating-point selector (including `-1.0`), or an aggregate or codeblock cannot select a container and reports `nested_write_segment_invalid`.")
    text = once(text,
        "The current implementations still reject negative writes. A separate target contract now defines tail-relative array indexes: for size `L`, `[-n]` selects `[L-n]` when `L-n >= 0`. Backend implementation and portable admission remain pending; the frozen historical write-v1 authority stays unchanged.",
        "Perl native and independently emitted execution implement tail-relative reads and writes in ordinary actions and callable bodies: for size `L`, `[-n]` selects `[L-n]` when `L-n >= 0`. The frozen historical write-v1 authority stays unchanged. Other backend implementations and portable admission remain separately owned.")
    text = once(text, "#### Current negative-index read status", "#### Signed array selectors in Perl")
    text = once(text,
        "Tail-relative indexing is being extended across the runtimes. For an existing array of size `L`, the requested rule is `[-n] = [L-n]` when `L-n >= 0`; negative selectors never create missing elements. The extension is not yet admitted portably.",
        "For an existing array of size `L`, a supported negative integer selector resolves to `L + index`: `[-1]` is the last entry, `[-2]` the one before it, and `[-L]` the first. Reads outside the array return `null` without creating state. The extension is available on Perl; it is not yet admitted portably.")
    text = once(text, "| Perl callable body | `null` |", "| Perl callable body | `30` |")
    text = once(text,
        "These are implementation observations while the extension is pending. Negative writes remain rejected by the libraries.",
        "The other-runtime rows retain the dated transition observations until their backend slices land. Perl negative writes now replace existing array entries.")
    text = once(text, "The callable example currently returns `[null,[10,20,30]]`:",
        "The callable example also returns `[30,[10,20,30]]`:")
    text = once(text, "#### Target signed-selector contract (backend implementation pending)",
        "#### Signed-selector contract and write examples")
    text = once(text,
        "The following table describes the target rule, rather than the current runtime results above. Its authority is `capability_conformance/signed_array_selector_contract.json`; it introduces no new assignment syntax.",
        "Perl implements the following rule from `capability_conformance/signed_array_selector_contract.json`. The same rule governs the pending backend slices; it introduces no new assignment syntax.")
    text = once(text, "#### Existing parameter and effect behavior",
        "The ordinary write example returns `[30,[10,99,30]]`:\n\n```text\n{{#include ../../../../examples/negative-array-write-perl.spec}}\n```\n\n"
        "The callable write uses each nested array's own length and returns `{\"rows\":[[1],[99,3]]}`:\n\n```text\n{{#include ../../../../examples/negative-array-write-callable-perl.spec}}\n```\n\n"
        "For example, writing `[-2]` into `[10]` fails with `nested_write_array_underflow`, `index = -2`, `length = 1` and `resolved_index = -1`; the binding stays `[10]`. Writing `[-1]` into an absent binding instead reports the existing invalid-segment diagnostic. A dynamic negative integer works like the literal; a dynamic string or a negative float retains its earlier read coercion behavior and is not promoted to an integer selector.\n\n"
        "#### Existing parameter and effect behavior")
    c.source(FLOW).write_text(text)
    card = c.source(CARD).read_text()
    card = once(card,
        'reverify: "Dated source-bound intake: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/review.py. No current signed-policy admission."',
        'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/signed-array-perl/publish.py; recurring: prove -Iperl t/signed_array_selector_perl_contract.t. Perl scope only."')
    card = once(card, "## Signed-selector intake (October23)", "## Signed array selectors on Perl (October24)")
    card = once(card, "builds on an isolated copy, and infers absent roots/intermediates from selector\nkinds.",
        "builds on an isolated copy, and infers absent roots/intermediates only for\neligible string/nonnegative selectors.")
    start = card.index("Ordinary reads rooted at bare Perl bindings already select existing tail entries", card.index("## Signed array"))
    card = card[:start] + (
        "TYPE-REFERENCE-BOOK.1.2.17.2 extends ordinary/deferred native and emitted Perl\n"
        "execution with existing-array L+index reads/writes. BindingRuntime admits\n"
        "negative integers globally, rejects missing required arrays, normalizes\n"
        "against each post-expression array and reports exact underflow fields.\n"
        "Raw authored prefixes, old diagnostics, effects, guard identity and detached\n"
        "copies remain governed by the frozen signed/v1 authorities.\n\n"
        "CodeblockRuntime::_read_array_entry serves indexed_var, nested_access and\n"
        "read_path. Literal number spelling distinguishes -1 from serialized -1.0;\n"
        "dynamic NV/string controls and ordinary bare-binding read coercions stay\n"
        "separate. The callable-result form pick()[-1].count() now selects the tail\n"
        "but retains compatibility marker1; no pure-source classification is added.\n"
        "The permanent consumer executes all33 frozen writes through real deferred\n"
        "callbacks, plus authored native/emitted programs and detachment controls;\n"
        "tools/run_ci_local.sh enrolls this Perl-only regression consumer.\n"
        "Historical before/after packets and two qualified infix-oracle mistakes\n"
        "remain under docs/checkpoints/signed-array-perl/. Other backend/portable\n"
        "admission and complete spelling inventory remain separately owned.\n")
    c.source(CARD).write_text(card)
    for path, value in EXAMPLES.items():
        with (c.ROOT / path).open("x") as stream:
            stream.write(value)
    c.write_new("documentation.json.gz", dict(outputs={path: c.read(path)
        for path in (FLOW, CARD, *EXAMPLES)}))
    print("Current Perl teaching and two exact examples written; full render/runtime proof follows.")


if __name__ == "__main__":
    main()
