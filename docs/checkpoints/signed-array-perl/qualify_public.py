"""Qualify two invalid effect-oracle programs without rewriting original runs."""
import json
import common as c
import context

target = "tests/numeric-codeblocks/signed-array-selectors.json"
before = c.read(target)
plan = json.loads(c.decode(before["base64"]))
c.write_new("public-qualification-inputs.json.gz", dict(context=context.snapshot(),
    original=before, producer=c.read(c.PREFIX + "qualify_public.py"),
    scope="Original before/after packets remain immutable. Toolbox Get dump identifies trail*10+n as raw_perl; runtime raises unsupported_codeblock_actionir before the write. Canonical arithmetic/callable records and existing callable contract use explicit helper calls. These two instrument errors earn no product RED or signed failure credit."))
changed = []
for row in plan["cases"]:
    if row["id"] not in ("write-order/ordinary", "write-order/callable"):
        continue
    old = row["source"]
    assert row["expected"] == [{"rows": [[1], [99, 3]]}, 1234]
    assert old.count("trail=0;") == 1
    new = old.replace("trail=0;", 'trail="";', 1)
    for digit in range(1, 5):
        atom = "trail=trail*10+" + str(digit)
        assert new.count(atom) == 1
        new = new.replace(atom, 'trail=cat(trail,"' + str(digit) + '")', 1)
    row["source"] = new
    row["expected"][1] = "1234"
    row["scope"] = "Actual callback order as explicit cat calls. Gold literal1234 derives from authored callback labels; unsupported infix arithmetic in the original instrument is separately qualified."
    changed.append(dict(id=row["id"], old_source=old, new_source=new))
assert len(changed) == 2
c.source(target).write_bytes((json.dumps(plan, ensure_ascii=False, indent=2) + "\n").encode())
c.write_new("public-qualification.json.gz", dict(output=c.read(target), changed=changed,
    target_basis="Independent ordered labels1,2,3,4 and unchanged aggregate target; no observed post-fix output supplies the target."))
print("Qualified exactly two raw-infix instrument programs; original evidence retained.")
