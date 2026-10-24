"""One-shot qualification of an unpublished fixture-authoring failure."""
from pathlib import Path
import common as c

path = c.PREFIX + "build_fixtures.py"
assert not (c.ROOT / "capability_conformance/signed_array_selector_contract.json").exists()
before = c.read(path)
reproduction = c.run(["bash", "tools/run_python_project_data.sh", path])
assert reproduction["returncode"] == 1
assert b"got multiple values for argument 'index'" in c.decode(reproduction["stderr_base64"])
assert c.read(path) == before
text = c.decode(before["base64"]).decode()
start = text.index("def error(")
end = text.index("\n\nwrites =", start)
old = text[start:end]
new = old.replace("code, index, prefix", "code, segment_index, prefix")
new = new.replace('[:index]', '[:segment_index]').replace('[index]', '[segment_index]')
new = new.replace('segment_index=index', 'segment_index=segment_index').replace('{index}', '{segment_index}')
assert new != old
c.write_new("builder-qualification.json.gz", {
    "scope": "Instrument-only TypeError before any authority output existed. Original interactive invocation failed the same way; this is a distinct exact-source reproduction with captured channels. No product or oracle RED credit.",
    "producer_before": before, "reproduction": reproduction,
    "producer_after_source": new,
})
Path(path).write_text(text[:start] + new + text[end:])
print("Qualified pre-publication builder failure; renamed only the diagnostic helper argument")
